CREATE OR REPLACE PROCEDURE SP_PB_Speloadcancel
(
		p_TRADEID	      char,
		p_currOper	    char,
		p_currDept	    char,
		p_retCode       out char, -- Return Code
		p_retMsg        out varchar2  -- Return Message

)
AS
		v_CURRENTTIME date := sysdate;
    v_ex          exception;
BEGIN
    -- 1) Log the operate
    BEGIN
		    UPDATE TF_B_SPELOAD
		    SET   STATECODE = '2',
		          OPERATESTAFFNO = p_currOper,
		          OPERATETIME = v_CURRENTTIME
		    WHERE TRADEID = p_TRADEID;

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001018101';
	            p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors

 