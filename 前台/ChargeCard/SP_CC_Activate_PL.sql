CREATE OR REPLACE PROCEDURE SP_CC_Activate
(
    p_fromCardNo char,
    p_toCardNo   char,
    p_stateCode  char, -- 3 Stockout 4 Activate
    p_remark     varchar2,
    p_currOper   char,
    p_currDept   char,
    p_retCode    out char,
    p_retMsg     out varchar2
)
AS
    v_seqNo      char(16) ;
    v_ex         exception;
BEGIN
    SP_GetSeq(seq => v_seqNo);

    BEGIN
	    SP_CC_Activate_ChargeCard(p_fromCardNo, p_toCardNo, p_stateCode, p_remark,
	        v_seqNo, p_currOper, p_currDept, p_retCode, p_retMsg);
	    IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
	    ROLLBACK; RETURN;
    END;

    COMMIT; RETURN;
END;

/

show errors
