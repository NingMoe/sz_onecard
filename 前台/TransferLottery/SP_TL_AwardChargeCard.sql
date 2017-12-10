create or replace procedure SP_TL_AwardChargeCard
(
  P_ChargeCard		  VARCHAR2,	--充值卡号
  P_CUSTNAME        VARCHAR2, --客户姓名
  P_PAPERTYPECODE   VARCHAR2, --证件类型
  P_PAPERNO         VARCHAR2, --证件号码
  P_CUSTSEX         VARCHAR2, --性别
  P_CUSTPHONE       VARCHAR2, --手机
 
  P_CARDNO          VARCHAR2, --中奖卡号
  P_CARDTYPECODE    CHAR,     --中奖卡卡类型	 
  P_BONUS           INT,
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode          out char     ,  -- Return Code
	p_retMsg           out varchar2    -- Return Message  
)
AS
  V_EX        EXCEPTION       ;
  V_TODAY DATE :=SYSDATE; 
  V_SUM   INT;
  V_MONEY INT; 
  v_seqNo      char(16) ;
 BEGIN
   --验证冲值卡总金额
   BEGIN
   		SELECT SUM(MONEY) INTO V_SUM																								
			  FROM TD_XFC_INITCARD C																													
			 INNER JOIN TP_XFC_CARDVALUE V																													
			    ON C.VALUECODE = V.VALUECODE																													
			 WHERE XFCARDNO IN																													
			       (SELECT STRVALUE FROM TABLE(FN_SPLIT(P_ChargeCard, ',')));								 
 			EXCEPTION 
   	    WHEN OTHERS THEN 
   	    p_retCode := 'S210020005'; p_retMsg  := '验证冲值卡总金额失败' || SQLERRM;
	      ROLLBACK; RETURN;
   END; 
   IF V_SUM != P_BONUS THEN
				 p_retCode := 'S210020004'; p_retMsg  := '充值卡总充值金额与总奖金不符，请核实' ;
	       ROLLBACK; RETURN;
	 END IF;
   
   --校验中奖总金额
 	 BEGIN
 	 	 SELECT  SUM(BONUS) INTO V_SUM																																					
			FROM TF_TT_WINNERLIST W																																												
			INNER JOIN TF_TT_LOTTERYTASK T ON W.LOTTERYPERIOD = T.LOTTERYPERIOD		
			INNER JOIN TD_M_AWARDS A ON W.AWARDS = A.AWARDSCODE						 																																			
			WHERE W.CARDNO = P_CARDNO AND CARDTYPECODE = P_CARDTYPECODE  AND W.STATES = 0 AND W.AWARDS != '0' AND TO_DATE(T.LOTTERYPERIOD,'YYYYMM')  >=  add_months(sysdate,-13);																																								
 	 	  EXCEPTION 
   	    WHEN OTHERS THEN 
   	    p_retCode := 'S210020009'; p_retMsg  := '校验中奖总金额失败' || SQLERRM;
	      ROLLBACK; RETURN;
 	 END; 
 	 IF V_SUM != P_BONUS THEN
 	 		  p_retCode := 'S210020009'; p_retMsg  := '充值卡总充值金额与总奖金不符' || SQLERRM;
	      ROLLBACK; RETURN;
   END IF;
   
  
   
   BEGIN
   		 FOR v_cur in (SELECT STRVALUE FROM TABLE(FN_SPLIT(P_ChargeCard, ',')))
   		 LOOP
           --验证充值卡状态
           BEGIN
           		SELECT MONEY INTO V_MONEY  FROM TD_XFC_INITCARD C																					
							INNER JOIN TP_XFC_CARDVALUE V ON C.VALUECODE = V.VALUECODE																					
							WHERE CARDSTATECODE IN ('3', '4', '5')																				
							AND XFCARDNO = v_cur.STRVALUE;	
					    EXCEPTION WHEN OTHERS THEN 
									p_retCode := 'S210020005'; p_retMsg  := '充值卡' ||v_cur.STRVALUE ||'状态无效';
	       					ROLLBACK; RETURN;
						  
           END;
           
           --更新充值卡账户表
           BEGIN
           	  UPDATE TD_XFC_INITCARD
			        SET    CARDSTATECODE = DECODE(CARDSTATECODE, '5', '5', '4'),
			               ACTIVETIME    = V_TODAY    ,
			               ACTIVESTAFFNO = p_currOper ,
			               SALETIME      = V_TODAY    ,
			               SALESTAFFNO   = p_currOper
			        WHERE  XFCARDNO = v_cur.STRVALUE
			        AND    CARDSTATECODE in ('3', '4', '5')
			        AND    ASSIGNDEPARTNO = p_currDept
			        AND    SALETIME is null and SALESTAFFNO is null;
			       IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
   					 EXCEPTION WHEN OTHERS THEN
			        p_retCode := 'S210020006'; p_retMsg := '更新充值卡状态失败,' || SQLERRM;
			        ROLLBACK; RETURN;   	
           END;
           
           SP_GetSeq(seq => v_seqNo);
           
           --新增充值卡激活操作日志
           BEGIN
           		INSERT INTO TL_XFC_MANAGELOG
			            (ID,STAFFNO,OPERTIME,OPERTYPECODE,STARTCARDNO,ENDCARDNO)
			        VALUES
			            (v_seqNo,p_currOper,V_TODAY,'04',v_cur.STRVALUE,v_cur.STRVALUE);
			    		EXCEPTION WHEN OTHERS THEN
			        p_retCode := 'S210020007'; p_retMsg := '更新充值卡售卡操作日志失败,' || SQLERRM;
			        ROLLBACK; RETURN; 
           END;
           
            --新增售卡日志
            BEGIN
				        INSERT INTO TF_XFC_SELL
				            (TRADEID, TRADETYPECODE, AMOUNT, STARTCARDNO, ENDCARDNO,
				                MONEY , STAFFNO  , OPERATETIME, REMARK)
				        VALUES(v_seqNo , '8Q'    , 1, v_cur.STRVALUE, v_cur.STRVALUE,
				            V_MONEY, p_currOper, v_today,  '');
				    EXCEPTION WHEN OTHERS THEN
				        p_retCode := 'S210020008'; p_retMsg  := '记录充值卡售卡操作台帐失败,' || SQLERRM;
				        ROLLBACK; RETURN;
				    END;
				    
				    --记录售卡现金台帐
				    BEGIN
				    	INSERT INTO TF_XFC_SELLFEE (TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO, MONEY, STAFFNO,OPERATETIME)
				        VALUES(v_seqNo, '8Q', v_cur.STRVALUE, v_cur.STRVALUE, V_MONEY, p_currOper, v_today);
				    EXCEPTION WHEN OTHERS THEN
				        p_retCode := 'S007P04B04'; p_retMsg  := '记录售卡现金台帐失败,' || SQLERRM;
				        ROLLBACK; RETURN; 
				    END; 
       END LOOP;
   END;
    
   
   --记录【领奖记录台帐表】
   BEGIN
	   	INSERT INTO TF_B_AWARDS																																						
			(TRADEID,CARDNO,CARDTYPECODE,AWARDTYPE,CHARGECARDNO,CHARGEMONEY,OPERATETIME,OPERATEDEPARTID,OPERATESTAFFNO,NAME,PAPERTYPECODE,PAPERNO,TEL)																																						
			VALUES																																						
			(v_seqNo,P_CARDNO,P_CARDTYPECODE,'1',P_ChargeCard,P_BONUS,V_TODAY,P_CURRDEPT,P_CURROPER,P_CUSTNAME,P_PAPERTYPECODE,P_PAPERNO,P_CUSTPHONE);	
			EXCEPTION
			WHEN OTHERS THEN
		            p_retCode := 'S210020002'; p_retMsg  := '记录领奖记录台帐表失败' || SQLERRM;
		            ROLLBACK; RETURN;
   END;
   
   --更新【中奖名单表】
   BEGIN
	   	UPDATE TF_TT_WINNERLIST SET STATES = '1',AWARDSTRADE = 	v_seqNo																																										
			WHERE CARDNO = P_CARDNO AND CARDTYPECODE = P_CARDTYPECODE AND STATES = '0' AND AWARDS != '0' AND TO_DATE(LOTTERYPERIOD,'YYYYMM')  >=  add_months(sysdate,-13);																																												
 			IF  SQL%ROWCOUNT = 0 THEN RAISE v_ex; END IF;
 			EXCEPTION
 			WHEN OTHERS THEN
          p_retCode := 'S210020003'; p_retMsg  := '更新中奖名单表失败' || SQLERRM;
          ROLLBACK; RETURN;
   END; 
	
  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN; 
	
END;

/
SHOW ERRORS	