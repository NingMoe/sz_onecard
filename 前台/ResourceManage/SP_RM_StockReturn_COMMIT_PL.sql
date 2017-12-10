
--用户卡退库 create by Yin

CREATE OR REPLACE PROCEDURE SP_RM_StockReturn_COMMIT
(
    p_fromCardNo    char, -- From Card No.
    p_toCardNo      char, -- End  Card No.
    p_returnReason  varchar2,
    p_seqNo         out char,
    p_currOper      char, -- Current Operator
    p_currDept      char, -- Curretn Operator's Department
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message
)
AS
    v_seqNo         char(16);
    v_today         date := sysdate;
    v_ex            EXCEPTION;
BEGIN
    
    --用户卡出库
    BEGIN
    SP_RM_StockReturn(p_fromCardNo,p_toCardNo,p_returnReason,p_seqNo,p_currOper,p_currDept,p_retCode,p_retMsg);
    IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
       EXCEPTION
       WHEN OTHERS THEN
           ROLLBACK; RETURN;
    END;
    
    p_retCode := '0000000000';
	  p_retMsg  := '';
	  COMMIT; RETURN;    
END;

/
show errors
