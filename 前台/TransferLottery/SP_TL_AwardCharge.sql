create or replace procedure SP_TL_AwardCharge
(
  P_AWARDCARDNO		  VARCHAR2,	--领奖卡号
  P_CUSTNAME        VARCHAR2, --客户姓名
  P_PAPERTYPECODE   VARCHAR2, --证件类型
  P_PAPERNO         VARCHAR2, --证件号码
  P_CUSTSEX         VARCHAR2, --性别
  P_CUSTPHONE       VARCHAR2, --手机
  P_PWD             VARCHAR2,

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
  V_COUNT INT;
  V_ACCT_ID NUMBER(12);
  V_SUM   INT;
  v_tradeID char(16);
 BEGIN
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
 	 		  p_retCode := 'S210020009'; p_retMsg  := '充值金额和奖金总金额不符' || SQLERRM;
	      ROLLBACK; RETURN;
   END IF;
 	
   --查询领奖卡是否开通专有帐户
   BEGIN
   		SELECT ACCT_ID INTO V_ACCT_ID  FROM TF_F_CUST_ACCT WHERE ICCARD_NO = P_AWARDCARDNO AND ACCT_TYPE_NO = '0001';
 			EXCEPTION
 				WHEN NO_DATA_FOUND THEN 
   	    V_ACCT_ID := 0;
   	    WHEN OTHERS THEN 
   	    p_retCode := 'S210020001'; p_retMsg  := '查询领奖卡是否开通专有帐户失败' || SQLERRM;
	      ROLLBACK; RETURN;
   END;
   
   IF V_ACCT_ID = 0 THEN
   		--开户
   		BEGIN
      SP_CA_OPENACC(P_CARDNO => P_AWARDCARDNO,
                    P_ACCTYPE => '0001',
                    P_CUSTNAME =>P_CUSTNAME,
                    P_CUSTBIRTH =>'',	
                    P_PAPERTYPECODE =>P_PAPERTYPECODE,
                    P_PAPERNO =>P_PAPERNO,
                    P_CUSTSEX =>P_CUSTSEX,
                    P_CUSTPHONE =>P_CUSTPHONE,
                    P_CUSTTELPHONE =>'',
                    P_CUSTPOST => '',
                    P_CUSTADDR => '',
                    P_CUSTEMAIL =>'',
                    P_ISUPOLDCUS =>'0',
                    P_PWD =>P_PWD,
                    P_LIMIT_EACHTIME =>0,
                    P_LIMIT_DAYAMOUNT =>0,
                    P_CURROPER =>P_CURROPER,
                    P_CURRDEPT =>P_CURRDEPT,
                    P_RETCODE =>P_RETCODE,
                    P_RETMSG =>P_RETMSG);
      IF p_retCode != '0000000000' THEN
          ROLLBACK; RETURN;
      END IF;
      
      --查询领奖卡是否开通专有帐户
	    BEGIN
	   		SELECT ACCT_ID INTO V_ACCT_ID  FROM TF_F_CUST_ACCT WHERE ICCARD_NO = P_AWARDCARDNO AND ACCT_TYPE_NO = '0001';
	 			EXCEPTION 
	   	    WHEN OTHERS THEN 
	   	    p_retCode := 'S210020001'; p_retMsg  := '查询领奖卡是否开通专有帐户失败' || SQLERRM;
		      ROLLBACK; RETURN;
	    END; 
	    END;
   END IF;
   
   --充值
   BEGIN
   	  SP_CA_CHARGE( P_ACCID => V_ACCT_ID,
                    P_CARDNO => P_AWARDCARDNO,
                    P_SUPPLYMONEY =>  P_BONUS,
										P_NEEDTRADEFEE => 0,
										P_TRADETYPECODE => '8Z',
										P_CURROPER =>  P_CURROPER,  
										P_CURRDEPT =>  P_CURRDEPT,   
										p_TRADEID =>  v_tradeID,   
										P_RETCODE =>  P_RETCODE,    
										P_RETMSG  =>  P_RETMSG);
      IF p_retCode != '0000000000' THEN
          ROLLBACK; RETURN;
      END IF; 
   END;
   
   --记录【领奖记录台帐表】
   BEGIN
	   	INSERT INTO TF_B_AWARDS																																						
			(TRADEID,CARDNO,CARDTYPECODE,AWARDTYPE,AWARDCARDNO,CHARGEMONEY,OPERATETIME,OPERATEDEPARTID,OPERATESTAFFNO,NAME,PAPERTYPECODE,PAPERNO,TEL)																																						
			VALUES																																						
			(v_tradeID,P_CARDNO,P_CARDTYPECODE,'0',P_AWARDCARDNO,P_BONUS,V_TODAY,P_CURRDEPT,P_CURROPER,P_CUSTNAME,P_PAPERTYPECODE,P_PAPERNO,P_CUSTPHONE);	
			EXCEPTION
			WHEN OTHERS THEN
		            p_retCode := 'S210020002'; p_retMsg  := '记录领奖记录台帐表失败' || SQLERRM;
		            ROLLBACK; RETURN;
   END;
   
   --更新【中奖名单表】
   BEGIN
	   	UPDATE TF_TT_WINNERLIST SET STATES = '1',AWARDSTRADE = 	v_tradeID																																										
			WHERE CARDNO = P_CARDNO  AND CARDTYPECODE = P_CARDTYPECODE AND STATES = '0' AND AWARDS != '0' AND TO_DATE(LOTTERYPERIOD,'YYYYMM')  >=  add_months(sysdate,-13);																																												
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