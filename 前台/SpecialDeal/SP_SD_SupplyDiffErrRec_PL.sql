
CREATE OR REPLACE PROCEDURE SP_SD_SupplyDiffErrRec
(
    p_renewRemark	       VARCHAR2,
    p_sessionID          VARCHAR2, 
    p_currOper	         CHAR,      
    p_currDept	         CHAR,         
    p_retCode            OUT CHAR,
    p_retMsg             OUT VARCHAR2 
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
	  v_renewmoney      INT;
	  v_tmpCardNo       CHAR(16);  
	  v_PREMONEY        INT; 

BEGIN
	  
  --1) get total records from TMP_SUPPLY_DIFFERR_RECYCLE
  SELECT COUNT(*) INTO v_quantity  FROM TMP_SUPPLY_DIFFERR_RECYCLE WHERE SessionId = p_sessionID; 
  
 	--2) add TF_SUPPLY_EXCLUDE info when COMPSTATE = '0'(联机有脱机无)
 	BEGIN						
   INSERT INTO TF_SUPPLY_EXCLUDE (IDENTIFYNO)														
	   SELECT ID FROM 	TMP_SUPPLY_DIFFERR_RECYCLE													
	    WHERE COMPSTATE = '0'	AND SessionId = p_sessionID;
	 
	   EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S009106010';
         p_retMsg  := '';
         ROLLBACK; RETURN;
  END;    
	    
	--3) update TP_SUPPLY_DIFF RENEWTYPECODE info 	
	BEGIN															
	  UPDATE TP_SUPPLY_DIFF																				
			 SET RENEWTYPECODE = '1' --(全额回收)																																						
	   WHERE ID IN (SELECT ID FROM TMP_SUPPLY_DIFFERR_RECYCLE 																				
						       WHERE COMPSTATE = '0' AND SessionId = p_sessionID );
						       
		 EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009106005';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;  			       
	
	BEGIN       	
		UPDATE TP_SUPPLY_DIFF																				
			 SET RENEWTYPECODE = '2' --(差额回收)																				
	   WHERE ID IN (SELECT ID FROM TMP_SUPPLY_DIFFERR_RECYCLE 																				
						       WHERE COMPSTATE = '2' AND SessionId = p_sessionID  );
		 EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009106005';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;  							       
																					
																																							
  --4) get the current recycle one by one records from TMP_SUPPLY_DIFFERR_RECYCLE
  --update TF_F_CARDEWALLETACC info
  
   BEGIN
    FOR cur_renewdata IN (   
      SELECT CARDNO, CARDTRADENO, TRADEDATE, TRADETIME, RENEWMONEY, PREMONEY 
       FROM	TMP_SUPPLY_DIFFERR_RECYCLE WHERE SessionId = p_sessionID ) LOOP	
       
    	  	v_tradetime := TO_DATE(cur_renewdata.TRADEDATE || cur_renewdata.TRADETIME, 'YYYYMMDDHH24MISS');		
          v_cardno	  := cur_renewdata.CARDNO;
          v_cardtradeno	:= cur_renewdata.CARDTRADENO;
          v_renewmoney  := cur_renewdata.RENEWMONEY; 
          
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
         		     TOTALSUPPLYMONEY = TOTALSUPPLYMONEY + v_renewmoney,
         		     CARDACCMONEY     = CARDACCMONEY + v_renewmoney																					
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
	 
	 
   --5) add  TH_SUPPLY_DIFF info(全额回收)
   BEGIN
	   INSERT INTO TH_SUPPLY_DIFF																						
		  (	ID, CARDNO, ASN, CARDTRADENO, TRADETYPECODE, CARDTYPECODE,																				
		   	TRADEDATE,  TRADETIME,    TRADEMONEY,  PREMONEY,  SUPPLYLOCNO,																				
		  	SAMNO,  POSNO,   STAFFNO, TAC,  TRADEID, TACSTATE,    BATCHNO,																				
		  	SUPPLYCOMFEE,  BALUNITNO, CALLINGNO,  CORPNO,   DEPARTNO,																				
		  	DEALTIME,   COMPTTIME,   COMPMONEY,    COMPSTATE ,RENEWTYPECODE )						
		  SELECT  ID, CARDNO, ASN, CARDTRADENO, TRADETYPECODE, CARDTYPECODE,																				
			  TRADEDATE,  TRADETIME,    TRADEMONEY,  PREMONEY,  SUPPLYLOCNO,																				
			  SAMNO,  POSNO,   STAFFNO, TAC,  TRADEID, TACSTATE,    BATCHNO,																				
			  SUPPLYCOMFEE,  BALUNITNO, CALLINGNO,  CORPNO,   DEPARTNO,																				
			  DEALTIME,   COMPTTIME,   COMPMONEY,    COMPSTATE, '1'						
	    FROM TMP_SUPPLY_DIFFERR_RECYCLE WHERE COMPSTATE = '0' AND SessionId  = p_sessionID;
	    
	    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009106101';
        p_retMsg  := '';
        ROLLBACK; RETURN;    
	 END; 
	   
   --6) add  TH_SUPPLY_DIFF info(差额回收)
   BEGIN
     INSERT INTO TH_SUPPLY_DIFF																						
	     (ID, CARDNO, ASN, CARDTRADENO, TRADETYPECODE, CARDTYPECODE,																				
		    TRADEDATE,  TRADETIME,    TRADEMONEY,  PREMONEY,  SUPPLYLOCNO,																				
		    SAMNO,  POSNO,   STAFFNO, TAC,  TRADEID, TACSTATE,    BATCHNO,																				
		    SUPPLYCOMFEE,  BALUNITNO, CALLINGNO,  CORPNO,   DEPARTNO,																				
		    DEALTIME,   COMPTTIME,   COMPMONEY,    COMPSTATE ,RENEWTYPECODE )																								
       SELECT ID, CARDNO, ASN, CARDTRADENO, TRADETYPECODE, CARDTYPECODE,																				
		    TRADEDATE,  TRADETIME,    TRADEMONEY,  PREMONEY,  SUPPLYLOCNO,																				
		    SAMNO,  POSNO,   STAFFNO, TAC,  TRADEID, TACSTATE,    BATCHNO,																				
		    SUPPLYCOMFEE,  BALUNITNO, CALLINGNO,  CORPNO,   DEPARTNO,																				
		    DEALTIME,   COMPTTIME,   COMPMONEY,    COMPSTATE , '2'																		
      FROM  TMP_SUPPLY_DIFFERR_RECYCLE WHERE COMPSTATE = '2' AND SessionId  = p_sessionID;
      
      EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009106101';
        p_retMsg  := '';
        ROLLBACK; RETURN;    
	 END; 
    
       
	 --7) del the TP_SUPPLY_DIFF info
	 BEGIN
     DELETE FROM TP_SUPPLY_DIFF																				
      WHERE ID IN ( SELECT ID FROM TMP_SUPPLY_DIFFERR_RECYCLE 
                    WHERE SessionId = p_sessionID	);
      
     IF SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S009106102';
         p_retMsg  := '';
         ROLLBACK; RETURN;
   END;               
   
   --8) get the sequence number  
   SP_GetSeq(v_quantity, v_seqNo);   
   v_seqNum := TO_NUMBER(v_seqNo);  
    
      
   --9)add TF_B_SUPPLY_MANUAL info(全额回收)
   BEGIN
	   INSERT INTO  TF_B_SUPPLY_MANUAL																											
				(	BUSINESSID,	CARDNO,	ASN	,	CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
				  TRADEDATE,	TRADETIME  ,	TRADEMONEY, 	PREMONEY ,SUPPLYLOCNO,
					SAMNO			,	POSNO			,	  STAFFNO,      TAC		,		TRADEID,	TACSTATE,	
					BATCHNO   ,	SUPPLYCOMFEE ,BALUNITNO     ,CALLINGNO,	CORPNO,	DEPARTNO,				
					DEALTIME  ,	COMPTTIME,		COMPMONEY			,	COMPSTATE,	RENEWMONEY,
					RENEWTIME	,	RENEWSTAFFNO,	RENEWTYPECODE	,RENEWREMARK								)
					
			SELECT SUBSTR('0000000000000000'|| TO_CHAR(v_seqNum + SEQ), -16),  
					CARDNO,	ASN	,	CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
					TRADEDATE	,	TRADETIME  ,	TRADEMONEY, 	PREMONEY, SUPPLYLOCNO,
					SAMNO			,	POSNO			,	  STAFFNO,      TAC		,		TRADEID,	TACSTATE,	
					BATCHNO   ,	SUPPLYCOMFEE ,BALUNITNO     ,CALLINGNO,	CORPNO,	DEPARTNO,																					
					DEALTIME  ,	COMPTTIME,		COMPMONEY			,	COMPSTATE,	RENEWMONEY,
					v_currdate, p_currOper,  '1', p_renewRemark 																
			 FROM TMP_SUPPLY_DIFFERR_RECYCLE WHERE COMPSTATE = '0'	AND SessionId  = p_sessionID;
			
		  EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S009106003';
         p_retMsg  := '';
         ROLLBACK; RETURN;
   END;     
		 	
   --10) add TF_B_SUPPLY_MANUAL info(差额回收)
   BEGIN
     INSERT INTO  TF_B_SUPPLY_MANUAL																											
			(	BUSINESSID,	CARDNO,	ASN	,	CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
			  TRADEDATE,	TRADETIME  ,	TRADEMONEY, 	PREMONEY	,SUPPLYLOCNO,
				SAMNO			,	POSNO			,	  STAFFNO,      TAC		,		TRADEID,	TACSTATE,	
				BATCHNO   ,	SUPPLYCOMFEE ,BALUNITNO     ,CALLINGNO,	CORPNO,	DEPARTNO,				
				DEALTIME  ,	COMPTTIME,		COMPMONEY			,	COMPSTATE,	RENEWMONEY,
				RENEWTIME	,	RENEWSTAFFNO,	RENEWTYPECODE	,RENEWREMARK								)
				
		 SELECT SUBSTR('0000000000000000'|| TO_CHAR(v_seqNum + SEQ), -16),   
					CARDNO,	ASN	,	CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
					TRADEDATE	,	TRADETIME  ,	TRADEMONEY, 	PREMONEY	,SUPPLYLOCNO,
					SAMNO			,	POSNO			,	  STAFFNO,      TAC		,		TRADEID,	TACSTATE,	
					BATCHNO   ,	SUPPLYCOMFEE ,BALUNITNO     ,CALLINGNO,	CORPNO,	DEPARTNO,																					
					DEALTIME  ,	COMPTTIME,		COMPMONEY			,	COMPSTATE,	RENEWMONEY,
					v_currdate, p_currOper,  '2', p_renewRemark 																
		 FROM TMP_SUPPLY_DIFFERR_RECYCLE WHERE COMPSTATE = '2'	AND SessionId  = p_sessionID;
		 
		 EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S009106003';
         p_retMsg  := '';
         ROLLBACK; RETURN;
   END;     
	 	
   
   --11) add the TI_SUPPLY_MANUAL info(全额回收)
   BEGIN
    INSERT INTO TI_SUPPLY_MANUAL
     (
       ID,	CARDNO,	ASN,	CARDTRADENO,	TRADETYPECODE,	CARDTYPECODE,
       TRADEDATE,	TRADETIME,	TRADEMONEY,	PREMONEY,	SUPPLYLOCNO	,
       SAMNO,	POSNO,	STAFFNO,	TAC,	TRADEID,	TACSTATE,	BATCHNO,	SUPPLYCOMFEE,	
       BALUNITNO,	CALLINGNO,CORPNO,	DEPARTNO,	DEALTIME,	
       COMPTTIME,	COMPMONEY,	COMPSTATE	,
       RENEWMONEY,	RENEWTIME,	RENEWSTAFFNO,	RENEWTYPECODE	,
       RENEWREMARK,	DEALSTATECODE 
     )
     SELECT  
       ID,	CARDNO,	ASN,	CARDTRADENO,	TRADETYPECODE,	CARDTYPECODE	,
       TRADEDATE,	TRADETIME,	TRADEMONEY,	PREMONEY,	SUPPLYLOCNO	,
       SAMNO,	POSNO,	STAFFNO,	TAC,	TRADEID,	TACSTATE,	BATCHNO,	SUPPLYCOMFEE,	
       BALUNITNO,	CALLINGNO,CORPNO,	DEPARTNO,	DEALTIME,	
       COMPTTIME,	COMPMONEY,	COMPSTATE	,
       RENEWMONEY, v_currdate, p_currOper, '1',
       p_renewRemark, '0' 
     FROM TMP_SUPPLY_DIFFERR_RECYCLE WHERE COMPSTATE = '0' AND SessionId  = p_sessionID;
      
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S009106004';
         p_retMsg  := '';
         ROLLBACK; RETURN;
   END;  
    
   --12) add the TI_SUPPLY_MANUAL info(差额回收)
   BEGIN
     INSERT INTO TI_SUPPLY_MANUAL
     (
       ID,	CARDNO,	ASN,	CARDTRADENO,	TRADETYPECODE,	CARDTYPECODE,
       TRADEDATE,	TRADETIME,	TRADEMONEY,	PREMONEY,	SUPPLYLOCNO	,
       SAMNO,	POSNO,	STAFFNO,	TAC,	TRADEID,	TACSTATE,	BATCHNO,	SUPPLYCOMFEE,	
       BALUNITNO,	CALLINGNO,CORPNO,	DEPARTNO,	DEALTIME,	
       COMPTTIME,	COMPMONEY,	COMPSTATE	,
       RENEWMONEY,	RENEWTIME,	RENEWSTAFFNO,	RENEWTYPECODE	,
       RENEWREMARK,	DEALSTATECODE 
     )
     
     SELECT 
       SUBSTR('0000000000000000'|| TO_CHAR(v_seqNum + SEQ), -16),  
       CARDNO,	ASN,	CARDTRADENO,	TRADETYPECODE,	CARDTYPECODE,
       TRADEDATE, TRADETIME,	TRADEMONEY,	PREMONEY,	SUPPLYLOCNO	,
       SAMNO,	POSNO,	STAFFNO,	TAC,	TRADEID,	TACSTATE,	BATCHNO,	SUPPLYCOMFEE,	
       BALUNITNO,	CALLINGNO, CORPNO,	DEPARTNO,	DEALTIME,	
       COMPTTIME,	COMPMONEY,	COMPSTATE	,
       RENEWMONEY, v_currdate, p_currOper, '2',
       p_renewRemark,'0' 
     FROM TMP_SUPPLY_DIFFERR_RECYCLE WHERE COMPSTATE = '2'	AND SessionId  = p_sessionID;
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