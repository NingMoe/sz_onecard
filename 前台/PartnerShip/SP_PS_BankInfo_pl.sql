create or replace procedure SP_PS_BankInfo
(
    p_BankCode        char,
    p_Bank            varchar2,
    p_BankAddr        varchar2,
    p_BankPhone       varchar2,
    p_currOper        char,
    p_currDept        char,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
as
    v_Count int;
    v_ex    exception;
BEGIN
    BEGIN
        SELECT COUNT(*) INTO v_Count FROM TD_M_BANK WHERE BANKCODE = p_BankCode;
        
        IF v_Count != 0 THEN
            p_retCode := 'A008113006';
            p_retMsg  := 'Bankcode exists,' || SQLERRM;
            RETURN;
        END IF;

        INSERT INTO TD_M_BANK (BANKCODE,BANK,BANKADDR,BANKPHONE,UPDATESTAFFNO,UPDATETIME)
        VALUES (p_BankCode,p_Bank,p_BankAddr,p_BankPhone,p_currOper,sysdate);
        
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S008113005';
        p_retMsg  := 'Error occurred while log into TD_M_BANK,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    
    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;
END;

/

show errors