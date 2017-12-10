create or replace procedure SP_IT_StockIn
(
    p_beginNo            char,
    p_endNo              char,
    p_currOper           char,
    p_currDept           char,
    p_volumeno           char,
    p_retCode        out char,
    p_retMsg         out varchar2
)
as
    v_today   date  := sysdate;
    v_tmp     number;
    v_end     number;
    v_TradeID char(16);

begin

    -- 1) 获取业务流水号
    SP_GetSeq(seq => v_TradeID);
    
    --2)判断是否库中已有
    begin
        select 1 into v_tmp from dual where exists (
            select 1 from TL_R_INVOICE t 
            where t.INVOICENO between p_beginNo and p_endNo
            and   t.VOLUMENO = p_volumeno
        );

        p_retCode := 'A200001001';
        p_retMsg  := '';
        return;
    exception when no_data_found then 
        null;
    end;

    v_tmp := to_number(p_beginNo);
    v_end := to_number(p_endNo  );
    
    --3)入库
    begin
        loop
            insert into TL_R_INVOICE( INVOICENO          , VOLUMENO, USESTATECODE, ALLOTSTATECODE, INSTAFFNO , INTIME ,
                   ALLOTSTAFFNO,ALLOTDEPARTNO,ALLOTTIME)
            values(                   lpad(v_tmp, 8, '0'), p_volumeno , '00'        , '00'          , p_currOper, v_today,
                   p_currOper,p_currDept,v_today);
            
            exit when v_tmp >= v_end;
            v_tmp := v_tmp + 1;
        end loop;
    exception when others then
        p_retCode := 'S200001002';
        p_retMsg  := '';
        rollback; return;
    end;

    --4)记台账
    begin
        insert into tf_r_invoicetrade
               (tradeid, opetypecode, volumeno, invoicebeginno, 
               invoiceendno, invoicenum, assignedstaffno, assigneddepartid,
               operatestaffno,operatedepartid, operatetime)
        values
               (v_TradeID, 'K0', p_volumeno, p_beginNo, 
               p_endNo, to_number(p_endNo-p_beginNo)+1, p_currOper, p_currDept, 
               p_currOper, p_currDept, v_today);
      exception when others then
            p_retCode := 'S200001092';
            p_retMsg  := '';
            rollback; return;
    end;
    
    p_retCode := '0000000000';
    p_retMsg  := '';

    commit; return;

end;

/
show errors