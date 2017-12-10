CREATE OR REPLACE PROCEDURE SP_PB_Destroy
(
		p_ID	          char,
		p_CARDNO	      char,
		p_ASN	          char,
		p_CARDTYPECODE	char,
		p_CARDACCMONEY	int,
		p_RDFUNDMONEY	  int,
		p_TRADEID	      out char, -- Return trade id
		p_currOper	    char,
		p_currDept	    char,
		p_retCode       out char, -- Return Code
		p_retMsg        out varchar  -- Return Message

) 
AS
    v_TradeID char(16);
		v_CURRENTTIME date := sysdate;
    v_ex          exception;
BEGIN
    -- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;
    
    -- 2) Log the operate
		BEGIN
			UPDATE TF_F_CARDREC
			SET  CARDSTATE ='01'
			WHERE CARDNO = p_CARDNO 
			AND CARDSTATE!='01';--∑¿÷π÷ÿ∏¥Ã·Ωªwdx 20120206
				
			IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
		       WHEN OTHERS THEN
		           p_retCode := 'S001007113';
		           p_retMsg  := 'Error occurred while updating statecode' || SQLERRM;
		           ROLLBACK; RETURN;
	   END;
	  
    -- 3) Log the operate
    BEGIN
		    INSERT INTO TF_B_TRADE       
		        (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CURRENTMONEY,OPERATESTAFFNO,     
		        OPERATEDEPARTID,OPERATETIME)     
		    VALUES
		        (v_TradeID,p_ID,'06',p_CARDNO,p_ASN,p_CARDTYPECODE,0-p_CARDACCMONEY,     
		         p_currOper,p_currDept,v_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001008106';
	            p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    -- 4) Log account change
    BEGIN
		    INSERT INTO TF_B_TRADEFEE       
		        (ID,TRADEID,TRADETYPECODE,CARDNO,SUPPLYMONEY,OPERATESTAFFNO,     
		        OPERATEDEPARTID,OPERATETIME)     
		    VALUES       
		        (p_ID,v_TradeID,'06',p_CARDNO,0 - p_CARDACCMONEY,     
		         p_currOper,p_currDept,v_CURRENTTIME);
         
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001008107';
	            p_retMsg  := 'Error to log account change' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors

  