create or replace procedure SP_TL_SpecialAward
(
  P_LOTTERYPERIOD		CHAR,	--领奖期数
  P_CUSTNAME        VARCHAR2, --客户姓名
  P_PAPERTYPECODE   VARCHAR2, --证件类型
  P_PAPERNO         VARCHAR2, --证件号码 
  P_CUSTPHONE       VARCHAR2, --手机    
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
 	 SP_GetSeq(seq => v_tradeID);
   --记录【特等奖领奖登记表】
   BEGIN
	   	INSERT INTO TF_B_SPECIALAWARDS																																						
			(TRADEID,LOTTERYPERIOD,OPERATETIME,OPERATEDEPARTID,OPERATESTAFFNO,NAME,PAPERTYPECODE,PAPERNO,TEL)																																						
			VALUES																																						
			(v_tradeID,P_LOTTERYPERIOD,V_TODAY,P_CURRDEPT,P_CURROPER,P_CUSTNAME,P_PAPERTYPECODE,P_PAPERNO,P_CUSTPHONE);	
			EXCEPTION
			WHEN OTHERS THEN
		            p_retCode := 'S210030001'; p_retMsg  := '记录特等奖领奖登记表失败' || SQLERRM;
		            ROLLBACK; RETURN;
   END;
   
   --更新【中奖名单表】
   BEGIN
	   	UPDATE TF_TT_WINNERLIST SET STATES = '1',AWARDSTRADE = 	v_tradeID																																										
			WHERE LOTTERYPERIOD = P_LOTTERYPERIOD AND AWARDS = '0';																																												
 			IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
 			EXCEPTION
 			WHEN OTHERS THEN
          p_retCode := 'S210030002'; p_retMsg  := '更新中奖名单表失败' || SQLERRM;
          ROLLBACK; RETURN;
   END; 
	
  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN; 
	
END;

/
SHOW ERRORS	