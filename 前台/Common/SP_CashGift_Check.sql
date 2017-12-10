CREATE OR REPLACE PROCEDURE SP_CashGift_Check
(
		p_CARDNO	  char,
		p_retCode	  out char, -- Return Code
		p_retMsg 	  out varchar2  -- Return Message

)
AS
		v_ex                exception;
		
BEGIN
	 IF SUBSTR(p_CARDNO,5,2) = '05' THEN
				p_retCode := 'A001100102';
	 		 RETURN;
	 END IF;
	 
  p_retCode := '0000000000';
	p_retMsg  := '';
	
END;
/

show errors
