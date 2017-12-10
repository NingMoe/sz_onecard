

CREATE OR REPLACE  PROCEDURE SP_SD_TaxiConsumeCancel
(
    p_renewRemark	      VARCHAR2,
    p_sessionID         VARCHAR2,
    p_currOper	        CHAR,      
    p_currDept	        CHAR,         
    p_retCode           OUT CHAR,
    p_retMsg            OUT VARCHAR2
)
AS
    v_currdate   DATE := SYSDATE;
    v_seqNo      CHAR(16);
    v_seqNum     NUMBER(16);
    v_quantity   INT;
  	v_ex         EXCEPTION;

BEGIN

    --1) get total records from TMP_TAXICONSUME_RECYCYLE 
    SELECT COUNT(*) INTO v_quantity FROM TMP_TAXICONSUME_RECYCYLE WHERE SessionId = p_sessionID;
    
    --2) update the TF_B_TRADE_ACPMANUAL info
    BEGIN
      UPDATE TF_B_TRADE_ACPMANUAL																																				
	       SET RENEWSTATECODE  =  '2'	,	
	           STAFFNO         =  p_currOper,                      
             OPERATETIME     =  v_currdate
	         																																											
	     WHERE TRADEID IN (SELECT TRADEID FROM TMP_TAXICONSUME_RECYCYLE WHERE SessionId = p_sessionID);
	   
	    IF SQL%ROWCOUNT = 0 OR SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_retCode := 'S009104003';
          p_retMsg  := '';
          ROLLBACK; RETURN;
    END;  
    	
    --3) delete TF_TRADE_EXCLUDE info
    BEGIN 
      DELETE FROM TF_TRADE_EXCLUDE															
       WHERE IDENTIFYNO IN ( SELECT ID FROM TMP_TAXICONSUME_RECYCYLE WHERE SessionId = p_sessionID );
      
      IF SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_retCode := 'S009103021';
          p_retMsg  := '';
          ROLLBACK; RETURN;
    END;  
    	 
       
   	--4) get the sequence number  
    SP_GetSeq(v_quantity, v_seqNo);   
    v_seqNum := TO_NUMBER(v_seqNo);     
  								  

	  --5) add TF_B_TRADE_MANUAL info	
	  BEGIN
      INSERT INTO TF_B_TRADE_MANUAL			
	      (TRADEID, ID, CARDNO, RECTYPE, ICTRADETYPECODE, ASN, CARDTRADENO,
	       SAMNO, POSNO, POSTRADENO, TRADEDATE, TRADETIME,
	       PREMONEY, TRADEMONEY, SMONEY, BALUNITNO,TRADECOMFEE,
	       CALLINGNO, CORPNO, DEPARTNO, CALLINGSTAFFNO, CITYNO, TAC,
	       SOURCEID, DEALTIME, ERRORREASONCODE,
	       RECTRADEID, RECSTAFFNO,
	       RENEWTIME, RENEWSTAFFNO,
	       DEALSTATECODE, RENEWTYPECODE, RENEWSTATECODE, RENEWREMARK) 																	
       SELECT 
         SUBSTR('0000000000000000'|| TO_CHAR(v_seqNum + SEQ), -16), 
         ID, CARDNO, RECTYPE, ICTRADETYPECODE, ASN, CARDTRADENO, 
         SAMNO, POSNO, POSTRADENO, TRADEDATE, TRADETIME, 
         PREMONEY, TRADEMONEY, SMONEY, BALUNITNO, 0,
	       CALLINGNO, CORPNO, DEPARTNO, CALLINGSTAFFNO, CITYNO, TAC, 
	       SOURCEID, DEALTIME, ERRORREASONCODE, 
	       TRADEID, STAFFNO,
	       v_currdate, p_currOper,	
	       DEALSTATECODE, '2', '2', p_renewRemark  
       FROM TMP_TAXICONSUME_RECYCYLE WHERE SessionId = p_sessionID; 
      
      IF SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_retCode := 'S009103002';
          p_retMsg  := '';
          ROLLBACK; RETURN;   
    END; 	
    

    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;						
END;

/
show errors

