create or replace procedure SP_RM_SECTIODELETE
(
		p_cardnoconfigid	char,
		p_currOper       	char,
		p_currDept	     	char,
		p_retCode	     	out char, -- Return Code
		p_retMsg     	 	out varchar2  -- Return Message
)
as
		v_data		date;
		v_ex		EXCEPTION;
BEGIN
	v_data :=sysdate;
	
	BEGIN
	UPDATE TD_M_CARDNOCONFIG SET USETAG = '0' WHERE CARDNOCONFIGID = p_cardnoconfigid;
	
	EXCEPTION
			  WHEN OTHERS THEN
				  p_retCode := 'S094780014';
				  p_retMsg  := '…æ≥˝”√ªßø®ø®∫≈∂Œ≈‰÷√±Ì ß∞‹' || SQLERRM;
			  ROLLBACK; RETURN;
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/
show errors