CREATE OR REPLACE PROCEDURE SP_PB_Retrade
(
		p_CARDNO	        char,
		p_ID	            char,
		p_TRADEID    	    out char, -- Return Trade Id
		p_currOper	      char,
		p_currDept	      char,
		p_retCode	        out char, -- Return Code
		p_retMsg     	    out varchar2   -- Return Message

)
AS
    v_TradeID char(16);
		v_CURRENTTIME date := sysdate;
    v_ex          exception;
BEGIN
		-- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;
    
		-- 2) Log operation
		BEGIN
				INSERT INTO TF_CARD_RETRADE
							(TRADEID,ID,CARDNO,OPERATESTAFFNO,OPERATETIME)
				VALUES
							(v_TradeID,p_ID,p_CARDNO,p_currOper,v_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001013100';
	            p_retMsg  := 'Fail to log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;				  

  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors

 