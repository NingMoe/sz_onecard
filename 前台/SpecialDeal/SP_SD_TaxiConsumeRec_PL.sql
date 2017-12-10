
CREATE OR REPLACE PROCEDURE SP_SD_TaxiConsumeRec
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
  	
  	v_tradeTime   DATE;
  	v_tradeMoney  INT;
  	v_cardNo      CHAR(16);
  	v_cardTradeNo CHAR(4);
  	v_tmpCardNo   CHAR(16);   
  	v_PREMONEY    INT;
  	
BEGIN
	
  
  --1) get total records from TMP_TAXICONSUME_RECYCYLE
  SELECT COUNT(*) INTO v_quantity FROM TMP_TAXICONSUME_RECYCYLE WHERE SessionId = p_sessionID; 
  
  --2) update the TF_B_TRADE_ACPMANUAL info
  BEGIN
    UPDATE TF_B_TRADE_ACPMANUAL																																				
	     SET RENEWSTATECODE  =  '1',		
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
  
	--3) update TF_F_CARDEWALLETACC info
	BEGIN
    FOR cur_renewdata IN ( 
      SELECT CARDNO, CARDTRADENO, TRADEDATE, TRADETIME, TRADEMONEY, PREMONEY  
        FROM TMP_TAXICONSUME_RECYCYLE WHERE SessionId = p_sessionID) LOOP			
         
        v_tradeTime   := TO_DATE(cur_renewdata.TRADEDATE || cur_renewdata.TRADETIME, 'YYYYMMDDHH24MISS');
        v_tradeMoney  := cur_renewdata.TRADEMONEY;
        v_cardNo      := cur_renewdata.CARDNO;
        v_cardTradeNo := cur_renewdata.CARDTRADENO;
        
        v_PREMONEY    := cur_renewdata.PREMONEY;
        
         -- if the cardno is CARDSTATE = '02', get the new cardno		
        BEGIN																					
					SELECT RSRV1 INTO v_tmpCardNo FROM TF_F_CARDREC WHERE CARDNO = v_cardNo and CARDSTATE = '02';																											
					IF v_tmpCardNo IS NOT NULL THEN
							v_cardNo := v_tmpCardNo; 
					END IF;
				  EXCEPTION
	          WHEN OTHERS THEN
	             v_cardNo := v_cardNo; 
	      END; 				  			
        
        --a.update the first consume time
        BEGIN
          UPDATE TF_F_CARDEWALLETACC																							
					   SET FIRSTCONSUMETIME = v_tradeTime																				
           WHERE CARDNO = v_cardNo AND TOTALCONSUMETIMES = 0;	
         
          EXCEPTION
          WHEN OTHERS THEN
            p_retCode := 'S009103005';
            p_retMsg  := '';
            ROLLBACK; RETURN;
        END;
         	
         
        --b.update the CARDACCMONEY, TOTALCONSUMEMONEY, TOTALCONSUMETIMES info
        BEGIN
          UPDATE TF_F_CARDEWALLETACC																					
             SET TOTALCONSUMETIMES = TOTALCONSUMETIMES + 1,		
		             TOTALCONSUMEMONEY = TOTALCONSUMEMONEY + v_tradeMoney,		
		             CARDACCMONEY      = CARDACCMONEY - v_tradeMoney																																	
           WHERE CARDNO = v_cardNo;		
        
          IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S009103006';
              p_retMsg  := '';
              ROLLBACK; RETURN;
        END;
 
        			
			  --c.update the LASTCONSUMETIME, OFFLINECARDTRADENO, CONSUMEREALMONEY
			  BEGIN														
			    UPDATE TF_F_CARDEWALLETACC																								
             SET LASTCONSUMETIME    = v_tradeTime,																					
		             OFFLINECARDTRADENO = v_cardTradeNo,																						
		             CONSUMEREALMONEY   = v_PREMONEY																						
				   WHERE CARDNO = v_cardNo AND (OFFLINECARDTRADENO < v_cardTradeNo OR OFFLINECARDTRADENO IS NULL);
				      
				   EXCEPTION
             WHEN OTHERS THEN
               p_retCode := 'S009103007';
               p_retMsg  := '';
               ROLLBACK; RETURN;
        END;
         	   
    END LOOP;
 
  END;     
 	
 	--4) get the sequence number  
  SP_GetSeq(v_quantity, v_seqNo);   
  v_seqNum := TO_NUMBER(v_seqNo);                                      
 
  --5) add TF_B_TRADE_MANUAL info , 
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
	    DEALSTATECODE, '2', '1', p_renewRemark  
    FROM TMP_TAXICONSUME_RECYCYLE WHERE SessionId = p_sessionID;
    
    IF SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009103002';
        p_retMsg  := '';
        ROLLBACK; RETURN;   
   END; 
    
   --6) add TI_TRADE_MANUAL info
   BEGIN
     INSERT INTO TI_TRADE_MANUAL			
	    (ID, CARDNO, RECTYPE, ICTRADETYPECODE, ASN, CARDTRADENO,
	     SAMNO, POSNO, POSTRADENO, TRADEDATE, TRADETIME,
	     PREMONEY, TRADEMONEY, SMONEY, BALUNITNO,TRADECOMFEE,
	     CALLINGNO, CORPNO, DEPARTNO, CALLINGSTAFFNO, CITYNO, TAC,
	     SOURCEID, DEALTIME, ERRORREASONCODE,
	     RECTRADEID, RECSTAFFNO,
	     RENEWTRADEID, RENEWTIME, RENEWSTAFFNO,	RENEWTYPECODE,
       DEALSTATECODE, RENEWREMARK ) 																	
     SELECT  
       ID, CARDNO, RECTYPE, ICTRADETYPECODE, ASN, CARDTRADENO,
	     SAMNO, POSNO, POSTRADENO, TRADEDATE, TRADETIME,
	     PREMONEY, TRADEMONEY, SMONEY, BALUNITNO,0,
	     CALLINGNO, CORPNO, DEPARTNO, CALLINGSTAFFNO, CITYNO, TAC,
	     SOURCEID, DEALTIME, ERRORREASONCODE,
	     TRADEID, STAFFNO,
	     SUBSTR('0000000000000000'|| TO_CHAR(v_seqNum + SEQ), -16), 
	     v_currdate, p_currOper, '2',
		   DEALSTATECODE, p_renewRemark  
		   FROM TMP_TAXICONSUME_RECYCYLE WHERE SessionId = p_sessionID;
	 
	   IF SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S009103003';
         p_retMsg  := '';
         ROLLBACK; RETURN;   
   END; 
     
        
   p_retCode := '0000000000';
   p_retMsg  := '';
   COMMIT;RETURN;						
END;

/
show errors

