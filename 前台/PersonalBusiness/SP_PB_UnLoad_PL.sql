CREATE OR REPLACE PROCEDURE SP_PB_UnLoad
(
		p_CARDNO	        char,
		p_TRADETYPECODE	  char,
		p_CARDMONEY	      int,
		p_OPERCARDNO			char,
		p_TERMNO					char,
		p_TRADEID    	    out char, -- Return Trade Id
		p_currOper	      char,
		p_currDept	      char,
		p_retCode	        out char, -- Return Code
		p_retMsg     	    out varchar2  -- Return Message

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
				INSERT INTO TF_B_TRADE
							(TRADEID,TRADETYPECODE,CARDNO,CURRENTMONEY,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
				VALUES
							(v_TradeID,p_TRADETYPECODE,p_CARDNO,p_CARDMONEY,p_currOper,p_currDept,v_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001014101';
	            p_retMsg  := 'Fail to log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
   	
    -- 3) Log the writeCard
    BEGIN
		    INSERT INTO TF_CARD_TRADE
		    			(TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,lMoney,lOldMoney,strTermno,OPERATETIME,SUCTAG)
		   	VALUES
		   				(v_TradeID,p_TRADETYPECODE,p_OPERCARDNO,p_CARDNO,p_CARDMONEY,p_CARDMONEY,p_TERMNO,v_CURRENTTIME,'0');

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001139';
	            p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors

 