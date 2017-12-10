CREATE OR REPLACE PROCEDURE SP_PB_updateCardTrade
(
		p_TRADEID	      char,
		p_CARDTRADENO   char,
		p_currOper	    char,
		p_currDept	    char,
		p_retCode	      out char, -- Return Code
		p_retMsg 	      out varchar2  -- Return Message

)
AS
    v_ex                exception;
BEGIN
		-- 1) update card trade
		BEGIN
			UPDATE TF_CARD_TRADE
			SET NextCardtradeno = p_CARDTRADENO,
			SUCTAG = '1'
			WHERE TRADEID = p_TRADEID;
			
			IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001026101';
	            p_retMsg  := 'Unable to Updated card trade';
	            ROLLBACK; RETURN;
    END;
			
	  p_retCode := '0000000000';
		p_retMsg  := '';
		COMMIT; RETURN;
END;  
/

show errors

