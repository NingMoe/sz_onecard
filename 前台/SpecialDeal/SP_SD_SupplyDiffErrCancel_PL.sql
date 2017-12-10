

CREATE OR REPLACE PROCEDURE SP_SD_SupplyDiffErrCancel
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
	
  --1) get total records from TMP_SUPPLY_DIFFERR_RECYCLE
  SELECT COUNT(*) INTO v_quantity  FROM TMP_SUPPLY_DIFFERR_RECYCLE WHERE SessionId = p_sessionID; 
  	
 	--2) delete TF_SUPPLY_EXCLUDE info when COMPSTATE = '0'(联机有脱机无)
 	BEGIN
	 	DELETE FROM TF_SUPPLY_EXCLUDE																		
		 WHERE IDENTIFYNO IN (SELECT ID FROM TMP_SUPPLY_DIFFERR_RECYCLE 																				
						               WHERE SessionId = p_sessionID AND COMPSTATE != '0' );
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S009106007';
         p_retMsg  := '';
         ROLLBACK; RETURN;
  END;  
  					               
	--3) update TP_SUPPLY_DIFF RENEWTYPECODE info 	
  BEGIN															
    UPDATE TP_SUPPLY_DIFF																				
		   SET RENEWTYPECODE = '4' --(作废)																																						
     WHERE ID IN (SELECT ID FROM TMP_SUPPLY_DIFFERR_RECYCLE 																				
					         WHERE SessionId = p_sessionID );
	  
	  IF SQL%ROWCOUNT = 0 OR SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009106005';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;  
  		
  --4) add  TH_SUPPLY_DIFF info
  BEGIN
	  INSERT INTO TH_SUPPLY_DIFF																						
		 (ID, CARDNO, ASN, CARDTRADENO, TRADETYPECODE, CARDTYPECODE,																				
			TRADEDATE,  TRADETIME,    TRADEMONEY,  PREMONEY,  SUPPLYLOCNO,																				
			SAMNO,  POSNO,   STAFFNO, TAC,  TRADEID, TACSTATE,    BATCHNO,																				
			SUPPLYCOMFEE,  BALUNITNO, CALLINGNO,  CORPNO,   DEPARTNO,																				
			DEALTIME,   COMPTTIME,   COMPMONEY,  COMPSTATE ,RENEWTYPECODE )						
																							
	   SELECT  ID, CARDNO, ASN, CARDTRADENO, TRADETYPECODE, CARDTYPECODE,																				
			 TRADEDATE,  TRADETIME,    TRADEMONEY,  PREMONEY,  SUPPLYLOCNO,																				
			 SAMNO,  POSNO,   STAFFNO, TAC,  TRADEID, TACSTATE,    BATCHNO,																				
			 SUPPLYCOMFEE,  BALUNITNO, CALLINGNO,  CORPNO,   DEPARTNO,																				
			 DEALTIME,   COMPTTIME,   COMPMONEY,    COMPSTATE, '4'						
	   FROM TMP_SUPPLY_DIFFERR_RECYCLE WHERE SessionId  = p_sessionID;
	  
	   IF SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S009106101';
         p_retMsg  := '';
         ROLLBACK; RETURN;   
  END; 	
	   
	 
  --5) del the TP_SUPPLY_DIFF info
  BEGIN
    DELETE FROM TP_SUPPLY_DIFF																				
    WHERE  ID IN ( SELECT ID FROM TMP_SUPPLY_DIFFERR_RECYCLE 
                    WHERE SessionId  = p_sessionID	);
    
    IF SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009106102';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;                 
         
  
  --6) get the sequence number  
  SP_GetSeq(v_quantity, v_seqNo);   
  v_seqNum := TO_NUMBER(v_seqNo);      
         
  --7) add TF_B_SUPPLY_MANUAL info
  BEGIN
   INSERT INTO  TF_B_SUPPLY_MANUAL																											
			(	BUSINESSID,	CARDNO,	ASN	,	CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
				TRADEDATE	,	TRADETIME  ,	TRADEMONEY, 	PREMONEY	,SUPPLYLOCNO,
				SAMNO			,	POSNO			,	  STAFFNO,      TAC		,		TRADEID,	TACSTATE,	
				BATCHNO   ,	SUPPLYCOMFEE ,BALUNITNO     ,CALLINGNO,	CORPNO,	DEPARTNO,				
				DEALTIME  ,	COMPTTIME,		COMPMONEY			,	COMPSTATE,	RENEWMONEY,
				RENEWTIME	,	RENEWSTAFFNO,	RENEWTYPECODE	,RENEWREMARK								)
				
		SELECT SUBSTR('0000000000000000'|| TO_CHAR(v_seqNum + SEQ), -16),  
					CARDNO,	ASN	,	CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
					TRADEDATE	,	TRADETIME  ,	TRADEMONEY, 	PREMONEY		,SUPPLYLOCNO,
					SAMNO			,	POSNO			,	  STAFFNO,      TAC		,		TRADEID,	TACSTATE,	
					BATCHNO   ,	SUPPLYCOMFEE ,BALUNITNO     ,CALLINGNO,	CORPNO,	DEPARTNO,																					
					DEALTIME  ,	COMPTTIME,		COMPMONEY			,	COMPSTATE,	RENEWMONEY,
					v_currdate, p_currOper,  '4', p_renewRemark																
		 FROM TMP_SUPPLY_DIFFERR_RECYCLE WHERE SessionId  = p_sessionID;
		 
		 IF SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S009106003';
         p_retMsg  := '';
         ROLLBACK; RETURN;   
   END; 	
			
	 p_retCode := '0000000000';       
	 p_retMsg  := '';                     
   COMMIT; RETURN;    

END;

/
show errors


