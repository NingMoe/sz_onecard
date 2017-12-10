/******************************************************/
-- Author  : wdx
-- Created : 收款方，开户行应该以红冲的时候选择的为准
-- Updated : 2012-03-08 下午 15:26
/******************************************************/
create or replace procedure SP_IT_Reverse
(
    p_oldVolumn            	char,
    p_oldNo                	char,
    p_newNo                	char,
    p_newVolumn            	char,
    p_drawer              	varchar2,
    p_date                	date,
	p_validatecode			char,
	p_payeeName            	varchar2,
	p_bankName             	varchar2,
	p_bankAccount           varchar2,
    p_currOper            	char,
    p_currDept            	char,
    p_retCode         		out char,
    p_retMsg          		out varchar2
)
as
    v_today         date  := sysdate;
    v_useState      char(2);
    v_allotState    char(2);
    v_drawtime      date;
    v_reverseNo     char(8);
    v_firstday      date;
    
    v_ex            exception;
    v_seqNo         TF_B_INVOICE.TRADEID%TYPE;
	v_quantity		int;

begin


begin
    SELECT count(*) into v_quantity  FROM TL_R_INVOICE tri where 
    tri.ALLOTSTATECODE='02' and tri.usestatecode='00'         		
    and tri.ALLOTSTAFFNO=p_currOper and tri.invoiceno=p_newNo
    and volumeno=p_newVolumn;	
    if v_quantity=0 then
            p_retCode := 'A200004001';
            p_retMsg  := '';
            return;
    end if;	
    exception
        when others then
            p_retCode := 'A200004002';
            p_retMsg  := '';
            return;
    end;



    begin
        select l.USESTATECODE,f.TRADETIME,f.OLDINVOICENO,l.allotstatecode
        into v_useState, v_drawtime, v_reverseNo,v_allotState
        from TL_R_INVOICE l left join TF_F_INVOICE f on (l.INVOICENO = f.INVOICENO and f.VOLUMENO = p_newVolumn)
        where l.INVOICENO = p_oldNo
        and   l.VOLUMENO  = p_oldVolumn;
        --01已开票，03
        if v_useState != '01' or v_allotState='03' then
            p_retCode   := 'A200006101';
            p_retMsg    := '';
            return; 
        end if;
        
        if v_reverseNo is not null then
            p_retCode   := 'A200006115';
            p_retMsg    := '';
            return;
        end if;
        
        v_firstday := trunc(sysdate,'month');
        if v_drawtime >= v_firstday then
            p_retCode   := 'A200006102';
            p_retMsg    := '';
            return; 
        end if;
        
    exception when no_data_found then
            p_retCode   := 'A200006100';
            p_retMsg    := '';
            return;
    end;

    begin
        select USESTATECODE,ALLOTSTATECODE
        into v_useState,v_allotState
        from TL_R_INVOICE
        where INVOICENO = p_newNo
        and   VOLUMENO  = p_newVolumn;
        
        if v_allotState != '02' or v_useState != '00' then
            raise v_ex;
        end if;
    
    exception
        when no_data_found then
            p_retCode := 'A200006103';
            p_retMsg  := '';
            return;
        when others then
            p_retCode := 'A200006104';
            p_retMsg  := '';
            return;
    end;
        
    begin
        update TL_R_INVOICE
        set    USESTATECODE  = '02'
        where  INVOICENO     = p_oldNo
        and    VOLUMENO      = p_oldVolumn;
        
        if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
    exception when others then
        p_retCode := 'S200006110';
        p_retMsg  := '';
        rollback; return;
    end;

    begin
        update TL_R_INVOICE
        set    USESTATECODE  = '01'
        where  INVOICENO     = p_newNo
        and    VOLUMENO      = p_newVolumn;
        
        if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
    exception when others then
            p_retCode := 'S200006111';
            p_retMsg  := '';
            rollback; return;
    end;
    
    begin
        insert into TF_F_INVOICE(    
            INVOICENO, VOLUMENO, PROJ1,FEE1,PROJ2,FEE2,PROJ3,FEE3,PROJ4,FEE4,PROJ5,FEE5,TRADEFEE,
            PAYMAN,TRADESTAFF,TRADETIME,TAXNO,OLDINVOICENO,OPERATESTAFFNO,OPERATEDEPARTID,
            OPERATETIME,REMARK,ISFREE,RSRV3,OLDVOLUMENO,bankname,bankaccount,payeeName,CallingCode,CallingName)
        select p_newNo, p_newVolumn, PROJ1,-FEE1,PROJ2,-FEE2,PROJ3,-FEE3,PROJ4,-FEE4,PROJ5,-FEE5,-TRADEFEE,
            PAYMAN,p_drawer,p_date,TAXNO,p_oldNo,p_currOper,p_currDept,
            v_today, REMARK,ISFREE,p_validatecode,p_oldVolumn,p_bankname,p_bankaccount,p_payeeName,CallingCode,CallingName
        from TF_F_INVOICE t
        where t.INVOICENO = p_oldNo
        and   t.VOLUMENO  = p_oldVolumn;
        
        if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
    exception when others then
            p_retCode := 'S200006112';
            p_retMsg  := '';
            rollback; return;
    end;
    
    SP_GetSeq(seq => v_seqNo);
    
    begin
        insert into TF_B_INVOICE(    
            TRADEID,INVOICENO, VOLUMENO,FUNCTIONTYPECODE,PROJ1,FEE1,PROJ2,FEE2,PROJ3,FEE3,PROJ4,FEE4,PROJ5,FEE5,TRADEFEE,
            PAYMAN,TRADESTAFF,TRADETIME,TAXNO,OLDINVOICENO,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,REMARK,ISFREE,RSRV3,OLDVOLUMENO,bankname,bankaccount,payeeName,CallingCode,CallingName)
        select v_seqNo,p_newNo, p_newVolumn,'L1',PROJ1,-FEE1,PROJ2,-FEE2,PROJ3,-FEE3,PROJ4,-FEE4,PROJ5,-FEE5,-TRADEFEE,
            PAYMAN,p_drawer,p_date,TAXNO,p_oldNo,p_currOper,p_currDept,v_today, REMARK,ISFREE,p_validatecode,p_oldVolumn,p_bankname,p_bankaccount,p_payeeName,CallingCode,CallingName
        from TF_F_INVOICE t
        where t.INVOICENO = p_oldNo
        and   t.VOLUMENO  = p_oldVolumn;
        
        if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
    exception when others then
            p_retCode := 'S200006113';
            p_retMsg  := '';
            rollback; return;
    end;

    p_retCode := '0000000000';
    p_retMsg    := '';

    commit; return;

end;
/
show errors