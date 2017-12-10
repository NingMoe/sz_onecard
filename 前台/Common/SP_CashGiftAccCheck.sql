CREATE OR REPLACE PROCEDURE SP_CashGiftAccCheck
(
	p_CARDNO	  char,
	p_currOper	  char,
	p_currDept	  char,
	p_retCode	  out char, -- Return Code
	p_retMsg 	  out varchar2  -- Return Message

)
AS
	v_SERSTAKETAG	char(1);
	v_ex            exception;
		
BEGIN
	SP_Credit_Check(p_CARDNO, p_currOper, p_currDept, p_retCode, p_retMsg);
		IF p_retCode != '0000000000' THEN
        ROLLBACK; RETURN;
    END IF;
    
	 IF SUBSTR(p_CARDNO,5,2) != '05' THEN
		p_retCode := 'A001100101';
		p_retMsg  := 'Cardtypecode is not CashGift';
	    RETURN;
	 END IF;
	 
	 SELECT SERSTAKETAG INTO v_SERSTAKETAG
	 FROM TF_F_CARDREC WHERE CARDNO = p_CARDNO;
	 
	 IF v_SERSTAKETAG != '5' THEN
		p_retCode := 'A001100103';
		p_retMsg := 'SERSTAKETAG is not right';
	    RETURN;
	 END IF;
	 
    p_retCode := '0000000000';
    p_retMsg  := '';
	
END;
/

show errors
