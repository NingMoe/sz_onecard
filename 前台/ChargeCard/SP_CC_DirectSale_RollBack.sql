/*
充值卡批量直销返销
创建：2013-03-27
*/
CREATE OR REPLACE PROCEDURE SP_CC_DirectSale_RollBack
(
    p_fromCardNo char,
    p_toCardNo   char,
    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_totalValue int      ;
    v_quantity   int      ;
    v_today      date     ;
    v_ex         exception;
    v_seqNo      char(16) ;
BEGIN

    BEGIN
        SP_CC_SaleChargeCard_RollBack(p_fromCardNo, p_toCardNo,
            v_quantity, v_today,
            p_currOper, p_currDept, p_retCode, p_retMsg);

        IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg := '';
    RETURN;
END;
/

show errors;
