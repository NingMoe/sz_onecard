
CREATE OR REPLACE PROCEDURE SP_SD_AutoRenew
(
    p_renewDate      VARCHAR2,--:ect 200806
    p_currOper	     CHAR,
    p_currDept	     CHAR,
    p_retCode        OUT CHAR,
    p_retMsg         OUT VARCHAR2
)
AS
    v_currdate   DATE := SYSDATE;
    v_seqNo      CHAR(16);
    v_quantity   INT;
  	v_ex         EXCEPTION;
  	
  	v_renewMon   CHAR(2);
  	
  	v_id	             CHAR(30);
	  v_cardno	         CHAR(16);
	  v_rectype	         CHAR(1);
	  v_ictradetypecode	 CHAR(2);
	  v_asn	             CHAR(16);
	  v_cardtradeno	     CHAR(4);
	  v_samno	           CHAR(12);
	  v_psamverno        CHAR(2);
	  v_posno	           CHAR(6);
	  v_postradeno	     CHAR(8);
	  v_tradedate        CHAR(8);
	  v_tradetime	       CHAR(6);
	  v_premoney	       INT;
	  v_trademoney	     INT;
	  v_smoney	         INT;
	  v_balunitno	       CHAR(8);
	  v_callingno	       CHAR(2);
	  v_corpno	         CHAR(4);
	  v_departno	       CHAR(4);
	  v_callingstaffno	 CHAR(6);
	  v_cityno	         CHAR(4);
	  v_tac	             CHAR(8);
	  v_tacstate	       CHAR(1);
	  v_mac	             CHAR(8);
	  v_sourceid	       CHAR(16);
	  v_batchno	         CHAR(14);
	  v_dealtime	       DATE;
	  v_errorreasoncode	 CHAR(1);
	
	  v_maxCardTradeNo   CHAR(4);
	  v_cardTradeNoExt   CHAR(4);
	  
	  v_tradeTimeExt     DATE;
	  
	  v_tmpCardNo        CHAR(16); 
	  v_srcCardNo        CHAR(16); 
	      
	  v_cnt              NUMBER := 0 ;
BEGIN 
	
	 --0) get the renwe month
	 v_renewMon := SUBSTR(p_renewDate, 5, 2); --'200806',get 06
	   
	 
	 --1) get total record from TF_TRADE_ERROR_p_renewMon
	 BEGIN
		 EXECUTE IMMEDIATE 'select count(*) ' 
		     || ' FROM TF_TRADE_ERROR_' || v_renewMon 
	       || ' WHERE (ERRORREASONCODE = ''1'' OR ERRORREASONCODE = ''2'')'
	       || ' AND CALLINGNO = ''01'' AND DEALSTATECODE = ''0'' ' into v_cnt;
	   	                     
    IF v_cnt = 0 THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'A009103022';
        p_retMsg  := '';
        RETURN;
   END;
	 

   --2) insert the TMP_COUSUME_AUTO_RECYCLE data from TF_TRADE_ERROR_p_renewMon
   BEGIN
     EXECUTE IMMEDIATE 'INSERT INTO TMP_COUSUME_AUTO_RECYCLE ' 
       || ' SELECT * FROM TF_TRADE_ERROR_' || v_renewMon 
       || ' WHERE (ERRORREASONCODE = ''1'' OR ERRORREASONCODE = ''2'')'
       || ' AND CALLINGNO = ''01'' AND DEALSTATECODE = ''0'' ' ;    
                             
    IF SQL%ROWCOUNT = 0 THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009103027';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END;
	 
	 --3) get the current recycle one by one records from TMP_COUSUME_AUTO_RECYCLE
   BEGIN
     FOR cur_renewdata IN (    
       SELECT ID, CARDNO, RECTYPE, ICTRADETYPECODE, ASN, CARDTRADENO,
         SAMNO, PSAMVERNO, POSNO, POSTRADENO,	TRADEDATE, TRADETIME,	
         PREMONEY, TRADEMONEY, SMONEY, BALUNITNO,	CALLINGNO, CORPNO, DEPARTNO,	
         CALLINGSTAFFNO, CITYNO, TAC, TACSTATE, MAC, SOURCEID,        	
         BATCHNO, DEALTIME, ERRORREASONCODE	FROM TMP_COUSUME_AUTO_RECYCLE) LOOP				
           
         v_id              := cur_renewdata.ID;            
	       v_cardno	         := cur_renewdata.CARDNO;   
	       v_srcCardNo       := v_cardno;
	       v_rectype         := cur_renewdata.RECTYPE;   	         
	       v_ictradetypecode := cur_renewdata.ICTRADETYPECODE;     
	       v_asn	           := cur_renewdata.ASN;                
	       v_cardtradeno	   := cur_renewdata.CARDTRADENO;        
	       v_samno	         := cur_renewdata.SAMNO;             
	       v_psamverno       := cur_renewdata.PSAMVERNO;          
	       v_posno	         := cur_renewdata.POSNO;           
	       v_postradeno	     := cur_renewdata.POSTRADENO;         
	       v_tradedate       := cur_renewdata.TRADEDATE;           
	       v_tradetime       := cur_renewdata.TRADETIME;    	       
	       v_premoney	       := cur_renewdata.PREMONEY;          
	       v_trademoney	     := cur_renewdata.TRADEMONEY;         
	       v_smoney	         := cur_renewdata.SMONEY;        
	       v_balunitno	     := cur_renewdata.BALUNITNO;           
	       v_callingno	     := cur_renewdata.CALLINGNO;           
	       v_corpno	         := cur_renewdata.CORPNO;        
	       v_departno	       := cur_renewdata.DEPARTNO;     
	       v_callingstaffno	 := cur_renewdata.CALLINGSTAFFNO;    
	       v_cityno	         := cur_renewdata.CITYNO;         
	       v_tac	           := cur_renewdata.TAC;          
	       v_tacstate	       := cur_renewdata.TACSTATE;           
	       v_mac	           := cur_renewdata.MAC;          
	       v_sourceid	       := cur_renewdata.SOURCEID;         
	       v_batchno	       := cur_renewdata.BATCHNO;          
	       v_dealtime	       := cur_renewdata.DEALTIME;     
	       v_errorreasoncode := cur_renewdata.ERRORREASONCODE;   
	       
	       v_tradeTimeExt    := TO_DATE(cur_renewdata.TRADEDATE || cur_renewdata.TRADETIME, 'YYYYMMDDHH24MISS');  
            
         v_maxCardTradeNo  := '0';
          
	       SELECT MAX(CARDTRADENO) INTO v_cardTradeNoExt FROM TQ_TRADE_RIGHT WHERE CARDNO = v_cardno;
	     
	       IF v_maxCardTradeNo < v_cardTradeNoExt THEN 
            v_maxCardTradeNo := v_cardTradeNoExt;
         END IF;
         
         IF v_cardtradeno < v_maxCardTradeNo THEN
            
            SELECT COUNT(*) INTO v_quantity FROM TQ_TRADE_RIGHT 
              WHERE CARDNO = v_cardno and CARDTRADENO = v_cardtradeno;
              
            IF v_quantity = 0 THEN
           
	            --a.update renew month table info 
	            BEGIN
	               EXECUTE IMMEDIATE 'UPDATE TF_TRADE_ERROR_' || v_renewMon
	                 ||' SET DEALSTATECODE = ''2'' ' || ' WHERE ID =''' || v_id || '''';
	                            
	               IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
	               EXCEPTION
	                 WHEN OTHERS THEN
	                   p_retCode := 'S009103004';
	                   p_retMsg  := '';
	                   ROLLBACK; RETURN;
	            END;
	            
	            --b.update TF_F_CARDEWALLETACC info
	            																																											
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
																								
	            BEGIN
	            	--1.update the first consume time
	              UPDATE TF_F_CARDEWALLETACC																							
						       SET FIRSTCONSUMETIME = v_tradeTimeExt																				
	               WHERE CARDNO = v_cardno AND TOTALCONSUMETIMES = 0;	
	         
	              EXCEPTION
	                WHEN OTHERS THEN
	                p_retCode := 'S009103005';
	                p_retMsg  := '';
	                ROLLBACK; RETURN;
	            END;
	         	
	         
	            BEGIN
	              --2.update the CARDACCMONEY, TOTALCONSUMEMONEY, TOTALCONSUMETIMES info
	              UPDATE TF_F_CARDEWALLETACC																					
	                 SET TOTALCONSUMETIMES = TOTALCONSUMETIMES + 1,		
			                 TOTALCONSUMEMONEY = TOTALCONSUMEMONEY + v_trademoney,		
			                 CARDACCMONEY      = CARDACCMONEY - v_trademoney																																	
	               WHERE CARDNO = v_cardno;		
	        
	              IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
	              EXCEPTION
	                WHEN OTHERS THEN
	                  p_retCode := 'S009103006';
	                  p_retMsg  := '';
	                   ROLLBACK; RETURN;
	            END;
	 
	        			
				      BEGIN
				      	--3.update the LASTCONSUMETIME, OFFLINECARDTRADENO, CONSUMEREALMONEY														
				        UPDATE TF_F_CARDEWALLETACC																								
	                 SET LASTCONSUMETIME    = v_tradeTimeExt,																					
			                 OFFLINECARDTRADENO = v_cardtradeno,																					
			                 CONSUMEREALMONEY   = v_premoney																					
					       WHERE CARDNO = v_cardno AND (OFFLINECARDTRADENO < v_cardtradeno OR OFFLINECARDTRADENO IS NULL);
					        
					     EXCEPTION
	               WHEN OTHERS THEN
	                 p_retCode := 'S009103007';
	                 p_retMsg  := '';
	                 ROLLBACK; RETURN;
	           END;
	            					 
						 --4) get the sequence number 
	           SP_GetSeq(seq => v_seqNo);
	           
			       
						 --5) add TF_B_TRADE_MANUAL info
						 BEGIN	
						  INSERT INTO TF_B_TRADE_MANUAL			
							 (TRADEID, ID, CARDNO, RECTYPE, ICTRADETYPECODE, ASN, CARDTRADENO, 
							  SAMNO, PSAMVERNO, POSNO, POSTRADENO, TRADEDATE, TRADETIME, 
							  PREMONEY, TRADEMONEY, SMONEY, BALUNITNO, TRADECOMFEE,
							  CALLINGNO, CORPNO, DEPARTNO, CALLINGSTAFFNO, CITYNO, TAC, 
							  TACSTATE, MAC, SOURCEID, BATCHNO, DEALTIME, ERRORREASONCODE, 
							  RENEWTIME, RENEWSTAFFNO, 
							  DEALSTATECODE, RENEWTYPECODE, RENEWSTATECODE) 																	
						  VALUES
						   ( v_seqNo, v_id, v_srcCardNo, v_rectype, v_ictradetypecode, v_asn, v_cardtradeno, 	   
		           	 v_samno, v_psamverno, v_posno, v_postradeno, v_tradedate, v_tradetime, 
	               v_premoney, v_trademoney, v_smoney, v_balunitno, 0,	     
			           v_callingno, v_corpno, v_departno, v_callingstaffno, v_cityno, v_tac, 	           
			           v_tacstate, v_mac, v_sourceid, v_batchno, v_dealtime, v_errorreasoncode, 
							   v_currdate, p_currOper, 	 
							   '0', '0', '1');
							   
						  IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
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
							   SAMNO, PSAMVERNO, POSNO, POSTRADENO, TRADEDATE, TRADETIME, 
							   PREMONEY, TRADEMONEY, SMONEY, BALUNITNO, TRADECOMFEE,
							   CALLINGNO, CORPNO, DEPARTNO, CALLINGSTAFFNO, CITYNO, TAC, 
							   TACSTATE, MAC, SOURCEID, BATCHNO, DEALTIME, ERRORREASONCODE, 
							   RENEWTRADEID, RENEWTIME, RENEWSTAFFNO, RENEWTYPECODE, DEALSTATECODE) 																	
						     
						   VALUES
						    ( v_id, v_srcCardNo, v_rectype, v_ictradetypecode, v_asn, v_cardtradeno, 	   
		            	v_samno, v_psamverno, v_posno, v_postradeno, v_tradedate, v_tradetime, 
	                v_premoney, v_trademoney, v_smoney, v_balunitno, 0,    
			            v_callingno, v_corpno, v_departno, v_callingstaffno, v_cityno, v_tac, 	           
			            v_tacstate, v_mac, v_sourceid, v_batchno, v_dealtime, v_errorreasoncode, 
			            v_seqNo, v_currdate, p_currOper, '0', '0' );
			            
			         IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
	             EXCEPTION
	              WHEN OTHERS THEN
	                p_retCode := 'S009103003';
	                p_retMsg  := '';
	                ROLLBACK; RETURN;   
	            END;      
			            
            END IF; 

       END IF;        
       
    END LOOP;
   END;
   
   p_retCode := '0000000000';
   p_retMsg  := '';
   COMMIT; RETURN;

END;
/
show errors
        
								       


