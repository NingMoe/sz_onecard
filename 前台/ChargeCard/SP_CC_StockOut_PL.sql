CREATE OR REPLACE PROCEDURE SP_CC_StockOut
(
    p_fromCardNo char,
    p_toCardNo   char,
    p_assignDepartNo char,
    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    V_IsDepaBal     int;
    V_USABLEVALUE   int;
    V_DBALUNITNO    varchar(8);
    v_seqNo  char(16);
    v_ex         exception;
BEGIN

    SP_GetSeq(seq => v_seqNo);

    BEGIN
        SP_CC_StockOut_ChargeCard(p_fromCardNo, p_toCardNo,p_assignDepartNo,
             v_seqNo,
            p_currOper, p_currDept, p_retCode, p_retMsg);
        IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK; RETURN;
    END;
    
    p_retCode := '0000000000'; p_retMsg  := '';
END;
/
show errors