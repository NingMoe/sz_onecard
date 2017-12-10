CREATE OR REPLACE PROCEDURE SP_PB_ReadRecord
(
		p_CARDNO	          char,
		p_SESSIONID	        varchar2,
		p_CARDMONEY         int,
		p_currOper	        char,
		p_currDept	        char,
		p_retCode	          out char, -- Return Code
		p_retMsg     	      out varchar2  -- Return Message

)
AS
    v_TradeID           char(16);
    v_CURRENTTIME date  := sysdate;
    v_ex                exception;
BEGIN
		-- 1) Get trade id  
    SP_GetSeq(seq => v_TradeID);
    
		-- 2)record RECQUY
		BEGIN
			INSERT INTO TF_CARD_RECQUY
					(TRADEID,CARDNO,CARDMONEY,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
			VALUES
					(v_TradeID,p_CARDNO,p_CARDMONEY,p_currOper,p_currDept,v_CURRENTTIME);
					
		EXCEPTION
					WHEN OTHERS THEN
							p_retCode := 'S001023101';
							p_retMsg  := 'Error occurred while record RECQUY' || SQLERRM;
							ROLLBACK; RETURN;
		END;
		
		-- 3)record RECLIST
		BEGIN
			INSERT INTO TF_CARD_RECLIST
					(TRADEID,SEQ,CARDTRADENO,TRADEMONEY,ICTRADETYPECODE,SAMNO,TRADEDATE,TRADETIME, PREMONEY)
				SELECT
						v_TradeID,ID,CARDTRADENO,TRADEMONEY,ICTRADETYPECODE,SAMNO,TRADEDATE,TRADETIME, PREMONEY
				FROM TMP_PB_ReadRecord
				WHERE SESSIONID = p_SESSIONID;
				
			EXCEPTION
					WHEN OTHERS THEN
							p_retCode := 'S001023102';
							p_retMsg  := 'Error occurred while record RECLIST' || SQLERRM;
							ROLLBACK; RETURN;
		END;
		
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors