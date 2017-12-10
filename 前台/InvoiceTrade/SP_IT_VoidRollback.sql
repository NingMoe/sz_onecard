create or replace procedure SP_IT_VoidRollback
(
    p_INVOICENO          char,
    p_VOLUMENO           char,
    p_TRADEID          out char, -- Return Trade Id
    p_currOper           char,
    p_currDept           char,
    p_retCode        out char,
    p_retMsg         out varchar2
)
as
    
    v_INVOICENO         char(8);
    v_TRADEID           char(16);
    v_TradeID1          char(16);
    v_state             char(2);
    v_today         date  := sysdate;
    
BEGIN
    BEGIN
        SELECT INVOICENO INTO v_INVOICENO FROM TF_F_INVOICE 
        WHERE INVOICENO = p_INVOICENO and VOLUMENO = p_VOLUMENO;
       
        SELECT decode(FUNCTIONTYPECODE,'L0','01','L1','02') into v_state FROM 
             (SELECT FUNCTIONTYPECODE  from TF_B_INVOICE
             where FUNCTIONTYPECODE not in ('L2', 'Y2') and INVOICENO = p_INVOICENO 
             and VOLUMENO = p_VOLUMENO order by OPERATETIME DESC )
        WHERE ROWNUM = 1;
       
        EXCEPTION
        when no_data_found then
        v_state := '00';
    END;
    
    BEGIN
        UPDATE TL_R_INVOICE SET USESTATECODE = v_state WHERE INVOICENO = p_INVOICENO AND VOLUMENO = p_VOLUMENO;
    END;
    
    SP_GetSeq(seq => v_TradeID1);
    p_TRADEID := v_TradeID1;
    
    BEGIN
        INSERT INTO TF_B_INVOICE
        (TRADEID, INVOICENO, VOLUMENO, FUNCTIONTYPECODE, OLDINVOICENO, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
        VALUES
        (v_TradeID1, p_INVOICENO, p_VOLUMENO, 'Y2', p_INVOICENO, p_currOper, p_currDept, v_today);
    END;
    
    select TRADEID INTO v_TRADEID from
    (SELECT TRADEID  FROM TF_B_INVOICE 
    WHERE INVOICENO = p_INVOICENO AND VOLUMENO = p_VOLUMENO AND OLDINVOICENO is null order by OPERATETIME desc)
    where rownum = 1;
    
    BEGIN
        UPDATE TF_B_INVOICE SET OLDINVOICENO = p_INVOICENO
        WHERE INVOICENO = p_INVOICENO AND VOLUMENO = p_VOLUMENO AND OLDINVOICENO is null;
    END;
    
    p_retCode := '0000000000';
    p_retMsg  := '';
    commit; return;

EXCEPTION WHEN OTHERS THEN
    p_retCode := SQLCODE;
    p_retMsg  := SQLERRM;
end;

/

show errors;


