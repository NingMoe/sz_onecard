CREATE OR REPLACE PROCEDURE SP_PB_Speloadinput
(
		p_CARDNO	       char,
		p_TRADEMONEY     int,
		p_TRADETYPECODE  char,
		p_TRADEDATE      date,
		p_TRADETIMES     int,
		p_REMARK				 varchar2,
		p_TRADEID        out char,
		p_currOper	     char,
		p_currDept	     char,
		p_retCode        out char, -- Return Code
		p_retMsg         out varchar2  -- Return Message

)
AS
    v_TradeID char(16);
    v_today   date := sysdate;
    v_ex      exception;
BEGIN

		SP_GetSeq(seq => v_TRADEID);
		p_TRADEID := v_TradeID;

		BEGIN
	    INSERT INTO TF_B_SPELOAD
	        (TRADEID,TRADETYPECODE,CARDNO,TRADEMONEY,TRADEDATE,TRADETIMES,REMARK,STATECODE,INPUTSTAFFNO,INPUTTIME)
	    VALUES
	        (v_TradeID,p_TRADETYPECODE,p_CARDNO,p_TRADEMONEY,p_TRADEDATE,p_TRADETIMES,p_REMARK,'0',p_currOper,v_today);
	
	  EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001018100';
	            p_retMsg  := 'Error occurred while log the operation,' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors

 