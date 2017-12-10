

CREATE OR REPLACE PROCEDURE SP_SD_SupplyErrRec
(
    p_renewRemark	      VARCHAR2,
    p_billMonth         CHAR,
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
  	
  	
  	v_cardno	        CHAR(16);
    v_cardtradeno	    CHAR(4);
	  v_tradetime 	    DATE;
	  v_trademoney	    INT;
	  v_tmpCardNo       CHAR(16);   
  	v_PREMONEY        INT;
    
BEGIN 
	
  --1) get total records from TMP_SUPPLY_ERROR_RECYCLE
  SELECT COUNT(*) INTO v_quantity FROM TMP_SUPPLY_ERROR_RECYCLE WHERE SessionId = p_sessionID;													
  
  --2) update supply Error bill month table info (etc TF_SUPPLY_ERROR_01 )
  BEGIN
    EXECUTE IMMEDIATE 'UPDATE TF_SUPPLY_ERROR_' || p_billMonth || ' SET DEALSTATECODE = ''2'' '
      || ' WHERE ID IN ( SELECT ID FROM TMP_SUPPLY_ERROR_RECYCLE '
      || ' WHERE SessionId= ''' || p_sessionID || ''')';
   
    IF SQL%ROWCOUNT = 0 OR SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009105002';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;
  
 
  --3) get the current recycle one by one records from TMP_SUPPLY_ERROR_RECYCLE
  --update TF_F_CARDEWALLETACC info 
  
  BEGIN
    FOR cur_renewdata IN (   
     SELECT CARDNO, CARDTRADENO, TRADEDATE, TRADETIME, TRADEMONEY, PREMONEY 
       FROM	TMP_SUPPLY_ERROR_RECYCLE WHERE SessionId = p_sessionID ) LOOP
       
       		v_tradetime := TO_DATE(cur_renewdata.TRADEDATE || cur_renewdata.TRADETIME, 'YYYYMMDDHH24MISS');		
          v_cardno	  := cur_renewdata.CARDNO;
          v_cardtradeno	:= cur_renewdata.CARDTRADENO;
          v_trademoney  := cur_renewdata.TRADEMONEY;
          v_PREMONEY    := cur_renewdata.PREMONEY;
        
        -- if the cardno is CARDSTATE = '02', get the new cardno	
        BEGIN																						
					SELECT RSRV1 INTO v_tmpCardNo FROM TF_F_CARDREC WHERE CARDNO = v_cardno and CARDSTATE = '02';																											
					IF v_tmpCardNo IS NOT NULL THEN
							v_cardno := v_tmpCardNo; 
					END IF;
					
					EXCEPTION
	           WHEN OTHERS THEN
	           v_cardno := v_cardno; 
	      END; 			  		  
          
	
        --a. update the first FIRSTSUPPLYTIME
        BEGIN
          UPDATE TF_F_CARDEWALLETACC	
             SET FIRSTSUPPLYTIME = v_tradetime														
           WHERE CARDNO = v_cardno AND TOTALSUPPLYTIMES = 0;
             
          EXCEPTION
          WHEN OTHERS THEN
            p_retCode := 'S009105003';
            p_retMsg  := '';
            ROLLBACK; RETURN;
        END;
       
        --b. update the CARDACCMONEY,	TOTALSUPPLYMONEY, TOTALSUPPLYTIMES info
        BEGIN
          UPDATE TF_F_CARDEWALLETACC	
             SET TOTALSUPPLYTIMES = TOTALSUPPLYTIMES + 1,
         		     TOTALSUPPLYMONEY = TOTALSUPPLYMONEY + v_trademoney,
         		     CARDACCMONEY     = CARDACCMONEY + v_trademoney																					
           WHERE CARDNO = v_cardno;
           
           IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
           EXCEPTION
             WHEN OTHERS THEN
               p_retCode := 'S009105004';
               p_retMsg  := '';
               ROLLBACK; RETURN;
        END;																			
		    															
			  --c. update the LASTSUPPLYTIME,ONLINECARDTRADENO,SUPPLYREALMONEY
			  BEGIN														
			    UPDATE TF_F_CARDEWALLETACC		
			       SET LASTSUPPLYTIME    = v_tradetime, 																					
		             ONLINECARDTRADENO = v_cardtradeno,
		             SUPPLYREALMONEY   = v_PREMONEY
				   WHERE CARDNO = v_cardno AND ( ONLINECARDTRADENO < v_cardtradeno OR ONLINECARDTRADENO IS NULL);
				   
				    EXCEPTION
             WHEN OTHERS THEN
               p_retCode := 'S009105005';
               p_retMsg  := '';
               ROLLBACK; RETURN;
        END;
		 END LOOP;
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
	       POSNO	,STAFFNO	,TAC	,TRADEID,	TACSTATE,	BATCHNO	, SUPPLYCOMFEE,
	       BALUNITNO,	CALLINGNO,	CORPNO,	DEPARTNO	,DEALTIME	,ERRORREASONCODE,	
	       COMPSTATE, RENEWMONEY,
	       RENEWTIME,	RENEWSTAFFNO,	RENEWTYPECODE,	RENEWREMARK
	     )
	   SELECT  
	       SUBSTR('0000000000000000'|| TO_CHAR(v_seqNum + SEQ), -16), 
	       CARDNO, ASN,	CARDTRADENO, TRADETYPECODE,	CARDTYPECODE,	
	       TRADEDATE,	TRADETIME,	TRADEMONEY,	 PREMONEY,SUPPLYLOCNO,	SAMNO,	
	       POSNO	,STAFFNO	,TAC	,TRADEID,TACSTATE,	BATCHNO	, 0, 
	       BALUNITNO,	CALLINGNO,	CORPNO,	DEPARTNO	,DEALTIME	,ERRORREASONCODE,	
	       '3', TRADEMONEY,
	       v_currdate, p_currOper, '3', p_renewRemark 
	       
	     FROM TMP_SUPPLY_ERROR_RECYCLE WHERE SessionId = p_sessionID;
	     
	   IF SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
     EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009106003';
        p_retMsg  := '';
        ROLLBACK; RETURN;   
   END;   
	     
	   
	   
   --6) add the TI_SUPPLY_MANUAL info 
   BEGIN
	   INSERT INTO TI_SUPPLY_MANUAL
	     (
	       ID,	CARDNO,	ASN,	CARDTRADENO,	TRADETYPECODE,	CARDTYPECODE,	
	       TRADEDATE,	TRADETIME,	TRADEMONEY,	PREMONEY,	SUPPLYLOCNO,	SAMNO,	
	       POSNO,	STAFFNO,	TAC,	TRADEID,	TACSTATE,	BATCHNO, SUPPLYCOMFEE,
	       BALUNITNO,	CALLINGNO,	CORPNO,	DEPARTNO,	DEALTIME,	ERRORREASONCODE,	
	       COMPSTATE,RENEWMONEY,
	       RENEWTIME,	RENEWSTAFFNO,	RENEWTYPECODE, RENEWREMARK, DEALSTATECODE
	     )
	    SELECT  
	       ID, CARDNO, ASN,	CARDTRADENO, TRADETYPECODE,	CARDTYPECODE,	
	       TRADEDATE,	TRADETIME,	TRADEMONEY,	 PREMONEY,SUPPLYLOCNO,	SAMNO,	
	       POSNO	,STAFFNO	,TAC	,TRADEID,TACSTATE,	BATCHNO	, 0,
	       BALUNITNO,	CALLINGNO,	CORPNO,	DEPARTNO	,DEALTIME, ERRORREASONCODE,	
	       '3',TRADEMONEY,
	       v_currdate, p_currOper, '3', p_renewRemark, '0'
	       
	     FROM TMP_SUPPLY_ERROR_RECYCLE WHERE SessionId = p_sessionID;
	     
	    IF SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
      EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009106004';
        p_retMsg  := '';
        ROLLBACK; RETURN;   
   END;     
	     
	 p_retCode := '0000000000';       
	 p_retMsg  := '';                     
   COMMIT; RETURN;    

END;

/
show errors



