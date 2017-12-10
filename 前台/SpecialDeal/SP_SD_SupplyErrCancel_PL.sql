
CREATE OR REPLACE PROCEDURE SP_SD_SupplyErrCancel
(
    p_renewRemark	     VARCHAR2,
    p_billMonth        CHAR,
    p_sessionID        VARCHAR2,
    p_currOper	       CHAR,      
    p_currDept	       CHAR,         
    p_retCode          OUT CHAR,
    p_retMsg           OUT VARCHAR2
)
AS
    v_currdate   DATE := SYSDATE;
    v_seqNo      CHAR(16);
    v_seqNum     NUMBER(16);
    v_quantity   INT;
  	v_ex         EXCEPTION;

BEGIN 

	--1) get total records from TMP_SUPPLY_ERROR_RECYCLE
  SELECT COUNT(*) INTO v_quantity FROM TMP_SUPPLY_ERROR_RECYCLE WHERE SessionId = p_sessionID;													
  
  --2) update supply Error bill month table info (etc TF_SUPPLY_ERROR_01 )
  BEGIN
    EXECUTE IMMEDIATE 'UPDATE TF_SUPPLY_ERROR_' || p_billMonth || ' SET DEALSTATECODE = ''3'' '
      || ' WHERE ID IN ( SELECT ID FROM TMP_SUPPLY_ERROR_RECYCLE '
      || ' WHERE SessionId= ''' || p_sessionID || ''')'	;
   
    IF SQL%ROWCOUNT = 0 OR SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009105002';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;
  
 
  --3) delete the TF_SUPPLY_EXCLUDE info
  BEGIN
		DELETE FROM TF_SUPPLY_EXCLUDE																				
	   WHERE IDENTIFYNO IN (SELECT ID FROM TMP_SUPPLY_ERROR_RECYCLE WHERE SessionId = p_sessionID );
	   
	   IF SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S009105006';
         p_retMsg  := '';
         ROLLBACK; RETURN;
  END;  
  	
		
  --4) get the sequence number  
  SP_GetSeq(v_quantity, v_seqNo);   
  v_seqNum := TO_NUMBER(v_seqNo); 
  
  
  --5) add the TF_B_SUPPLY_MANUAL info
  BEGIN
   INSERT INTO TF_B_SUPPLY_MANUAL
     (
       BUSINESSID,	CARDNO,	ASN,	CARDTRADENO	,TRADETYPECODE,	CARDTYPECODE,	
       TRADEDATE,	TRADETIME,	TRADEMONEY,	 PREMONEY,	SUPPLYLOCNO,	SAMNO,	
       POSNO	,STAFFNO	,TAC	,TRADEID,	TACSTATE,	BATCHNO	,SUPPLYCOMFEE,
       BALUNITNO,	CALLINGNO,	CORPNO,	DEPARTNO	,DEALTIME	,ERRORREASONCODE,	
       COMPSTATE,RENEWMONEY,
       RENEWTIME,	RENEWSTAFFNO,	RENEWTYPECODE,	RENEWREMARK
     )
     SELECT  
       SUBSTR('0000000000000000'|| TO_CHAR(v_seqNum + SEQ), -16), 
       CARDNO, ASN,	CARDTRADENO, TRADETYPECODE,	CARDTYPECODE,	
       TRADEDATE,	TRADETIME,	TRADEMONEY,	 PREMONEY,SUPPLYLOCNO,	SAMNO,	
       POSNO	,STAFFNO	,TAC	,TRADEID,TACSTATE,	BATCHNO	,0,
       BALUNITNO,	CALLINGNO,	CORPNO,	DEPARTNO	,DEALTIME	,ERRORREASONCODE,	
       '3',TRADEMONEY,
       v_currdate, p_currOper, '4', p_renewRemark 
       
     FROM TMP_SUPPLY_ERROR_RECYCLE WHERE SessionId = p_sessionID;
     
     IF SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_retCode := 'S009106003';
          p_retMsg  := '';
          ROLLBACK; RETURN;   
    END; 	
    
    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT;RETURN;

END;

/
show errors

     