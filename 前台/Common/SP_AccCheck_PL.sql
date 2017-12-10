CREATE OR REPLACE PROCEDURE SP_AccCheck
(
		p_CARDNO	  char,
		p_currOper	char,
		p_currDept	char,
		p_retCode	  out char, -- Return Code
		p_retMsg 	  out varchar2  -- Return Message

)
AS
    v_ex                exception;
BEGIN
		SP_Credit_Check(p_CARDNO, p_currOper, p_currDept, p_retCode, p_retMsg);
		IF p_retCode != '0000000000' THEN
        ROLLBACK; RETURN;
    END IF;
		
    SP_CashGift_Check(p_CARDNO, p_retCode, p_retMsg);
    IF p_retCode != '0000000000' THEN
        ROLLBACK; RETURN;
    END IF;
    
  p_retCode := '0000000000';
	p_retMsg  := '';

  END;  
/

show errors

