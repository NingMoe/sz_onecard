create or replace procedure SP_IT_Void
(
    p_volno              char,
    p_invoiceNo            char,
    p_reason               varchar,
    p_isCw                 char,
    p_currOper           char,
    p_currDept           char,
    p_retCode        out char,
    p_retMsg         out varchar2
)
as
    v_today         date  := sysdate;
    v_tmp           int;

    v_state         char(2);
    v_allotState    char(2);
    v_drawtime      date;

    v_firstday      date;
    v_ex            exception;
    v_seqNo         TF_B_INVOICE.TRADEID%TYPE;

    v_oldno         TL_R_INVOICE.VOLUMENO%type;

begin
if p_isCw='1' then
select count(*) into v_tmp from TL_R_INVOICE t
    where t.INVOICENO =p_invoiceNo
    and   t.VOLUMENO = p_volno;
    if v_tmp =0 then
        p_retCode   := 'A200EE3001';
        p_retMsg    := '需要作废的发票不存在于库存中';
        return;
    end if;
else

--检查是否部门负责人
    select  count(*) into v_tmp  from TD_M_ROLEPOWER rp where powercode='201007' and
rp.roleno in( select ROLENO from TD_M_INSIDESTAFFROLE ti where ti.Staffno=p_currOper);
if v_tmp>0 then
  select count(*) into v_tmp from TL_R_INVOICE t
    where t.INVOICENO =p_invoiceNo
    and   t.VOLUMENO = p_volno and t.allotdepartno=p_currDept;
    if v_tmp =0 then
        p_retCode   := 'A200EE3001';
        p_retMsg    := '需要作废的发票不存在于库存中或不归属于此部门';
        return;
    end if;
else
  select count(*) into v_tmp from TL_R_INVOICE t
    where t.INVOICENO =p_invoiceNo
    and   t.VOLUMENO = p_volno and t.allotstaffno=p_currOper;
    if v_tmp =0 then
        p_retCode   := 'A200EE3002';
        p_retMsg    := '需要作废的发票不存在于库存中或不归属于此员工';
        return;
    end if;
end if;

end if;



        select l.USESTATECODE,l.allotstatecode
        into   v_state ,v_allotState
        from   TL_R_INVOICE l
        where  l.INVOICENO = p_invoiceno and l.VOLUMENO = p_volno;

        begin
            select f.TRADETIME,f.OLDINVOICENO
            into   v_drawtime, v_oldno
            from   TF_F_INVOICE f
            where  f.INVOICENO = p_invoiceno and f.VOLUMENO = p_volno;
        exception when no_data_found then
            v_drawtime := null;
            v_oldno    := null;
        end;

        if(v_allotState='03') then
            p_retCode   := 'A200EE3002';
            p_retMsg    := '此发票已作废';
            rollback; return;
        end if;

        if (v_state ='02') or (v_state = '01' and v_oldno is not null) then
            p_retCode   := 'A200EE3002';
            p_retMsg    := '红冲及被红冲发票不能作废';
            rollback; return;
        end if;

        if v_state = '01' and v_drawtime is not null then
            v_firstday := trunc(sysdate,'month');
            if v_drawtime < v_firstday then
                p_retCode   := 'A20EE03002';
                p_retMsg    := '非本月开票不能作废';
                rollback; return;
            end if;
        end if;

        begin
            update TL_R_INVOICE
            set    ALLOTSTATECODE = '03',
                   RSRV2        = p_reason,
                   DELSTAFFNO   = p_currOper,
                   DELTIME      = v_today
            where  INVOICENO    = p_invoiceno
            and    VOLUMENO     = p_volno;

            if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
        exception when others then
            p_retCode := 'S200003003';
            p_retMsg  := '';
            rollback; return;
        end;

        SP_GetSeq(seq => v_seqNo);

        begin
			if(v_drawtime is  null) then --未开发票
				p_retCode := 'S2EEEE3003';
				p_retMsg  := '未开发票不能作废';
				rollback; return;
				--insert into TF_B_INVOICE(    
				--	TRADEID, INVOICENO, VOLUMENO, FUNCTIONTYPECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME
				--) 
				--values(    
				--	v_seqNo,  p_invoiceno    , p_volno , 'L3' , p_currOper    , p_currDept     , v_today
				--);
			ELSE--已开票作废
				insert into TF_B_INVOICE(    
				TRADEID,INVOICENO, VOLUMENO,FUNCTIONTYPECODE,PROJ1,FEE1,PROJ2,FEE2,PROJ3,FEE3,PROJ4,FEE4,PROJ5,FEE5,TRADEFEE,
				PAYMAN,TRADESTAFF,TRADETIME,TAXNO,OLDINVOICENO,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,REMARK,ISFREE,RSRV3,OLDVOLUMENO,bankname,bankaccount,payeeName,CallingCode,CallingName)
				select v_seqNo,INVOICENO, VOLUMENO,'L2',PROJ1,FEE1,PROJ2,FEE2,PROJ3,FEE3,PROJ4,FEE4,PROJ5,FEE5,TRADEFEE,
				PAYMAN,TRADESTAFF,TRADETIME,TAXNO,OLDINVOICENO,p_currOper,p_currDept,v_today, REMARK,ISFREE,RSRV3,OLDVOLUMENO,bankname,bankaccount,payeeName,CallingCode,CallingName
				from TF_F_INVOICE t
				where t.INVOICENO = p_invoiceno
				and   t.VOLUMENO  = p_volno;
			end if;
            
            if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
        exception when others then
            p_retCode := 'S200003004';
            p_retMsg  := '';
            rollback; return;
        end;
        
        begin
          if (v_drawtime is not null) then
            delete from TF_B_DEPTINVOICE 
            where invoiceno = p_invoiceno and volumeno  = p_volno;
           end if;
           
           exception when others then
            p_retCode := 'S200003005';
            p_retMsg  := '';
            rollback; return;
        end;

    p_retCode := '0000000000';
    p_retMsg  := '';

    commit; return;

end;
/
show errors