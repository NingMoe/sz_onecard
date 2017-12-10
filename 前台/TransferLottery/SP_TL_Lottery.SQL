CREATE OR REPLACE PROCEDURE SP_TL_Lottery
(
	P_AWARDSCODE		CHAR	,	--奖项
	P_LOTTERYPERIOD CHAR  ,	--抽奖期数
	 
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode          out char     ,  -- Return Code
	p_retMsg           out varchar2    -- Return Message  
)
AS
  V_EX        EXCEPTION       ;
  V_TODAY DATE :=SYSDATE; 
  V_COUNT INT;
  V_LOTTERYSTATE CHAR(1);
BEGIN
 
	 --查询【奖项参数表】
	 BEGIN
	  	SELECT COUNT INTO V_COUNT FROM TD_M_AWARDS WHERE AWARDSCODE = P_AWARDSCODE; 
	 EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S210010001'; p_retMsg  := '查询奖项参数表失败' || SQLERRM;
	            ROLLBACK; RETURN;
	 END;
	 
	 IF P_AWARDSCODE = '1' THEN
	   V_LOTTERYSTATE := '3';
	 ELSIF  P_AWARDSCODE = '2' THEN
	   V_LOTTERYSTATE := '4';
	 ELSIF  P_AWARDSCODE = '3' THEN
	 	 V_LOTTERYSTATE := '5';
	 ELSE
	 	 V_LOTTERYSTATE := P_AWARDSCODE;
	 END IF; 
	 
	 --更新【抽奖任务表】
	 BEGIN
	 	UPDATE TF_TT_LOTTERYTASK SET LOTTERYSTATE = '2' 																																			
		WHERE LOTTERYPERIOD = P_LOTTERYPERIOD AND PREPARESTATE = '1' AND  LOTTERYSTATE = V_LOTTERYSTATE;																																		
    IF SQL%ROWCOUNT != 1 THEN
				RAISE V_EX;
		END IF;
		EXCEPTION WHEN OTHERS THEN
				p_retCode := 'S210010002';
				p_retMsg :='更新抽奖任务表失败'||SQLERRM;
				ROLLBACK;	RETURN;
   END;
	 	 
   --如果是抽特等奖或三等奖
   IF P_AWARDSCODE = '0' OR P_AWARDSCODE = '3' THEN
	   --记录【中奖名单表】
	   BEGIN 
	   		INSERT INTO TF_TT_WINNERLIST																																									
				(LOTTERYPERIOD,CARDNO,CARDTYPECODE,SOCIALNO,AWARDS,STATES,ASN)																																									
				SELECT P_LOTTERYPERIOD,CARDNO,CARDTYPECODE,SOCIALNO,P_AWARDSCODE,'0',ASN																																							
				FROM (SELECT ROW_NUMBER() OVER (ORDER BY DBMS_RANDOM.RANDOM) num,CARDNO,CARDTYPECODE,SOCIALNO,ASN  FROM TF_TT_LOTTERYDATA 																																									
				WHERE ISWIN = '0' AND LOTTERYPERIOD = P_LOTTERYPERIOD ) 																																									
				WHERE NUM <= V_COUNT;	 
				IF SQL%ROWCOUNT != V_COUNT THEN
					p_retCode := 'S210010003';
					p_retMsg :='插入中奖名单表记录数据有误'||SQLERRM;
					ROLLBACK;	RETURN;
			  END IF;
				EXCEPTION WHEN OTHERS THEN
					p_retCode := 'S210010004';
					p_retMsg :='记录中奖名单表失败'||SQLERRM;
					ROLLBACK;	RETURN;
	   END;
  ELSE
     --如果是抽一等奖或二等奖
     --记录【中奖名单表】
     BEGIN 
	   		INSERT INTO TF_TT_WINNERLIST																																							
				(LOTTERYPERIOD,CARDNO,CARDTYPECODE,SOCIALNO,AWARDS,STATES,ASN)																																								
				SELECT P_LOTTERYPERIOD,CARDNO,CARDTYPECODE,SOCIALNO,P_AWARDSCODE,'0',ASN																																												
				FROM (SELECT ROW_NUMBER() OVER (ORDER BY RANDOM) num,CARDNO,CARDTYPECODE,SOCIALNO,ASN  FROM TF_TT_LOTTERYDATA																																							
				 WHERE ISWIN = '0' AND LOTTERYPERIOD = P_LOTTERYPERIOD  AND MARK = P_AWARDSCODE) 																																							
				WHERE NUM <= V_COUNT;			
				IF SQL%ROWCOUNT != V_COUNT THEN
					p_retCode := 'S210010003';
					p_retMsg :='插入中奖名单表记录数据有误'||SQLERRM;
					ROLLBACK;	RETURN;
			  END IF;
				EXCEPTION WHEN OTHERS THEN
					p_retCode := 'S210010004';
					p_retMsg :='记录中奖名单表失败'||SQLERRM;
					ROLLBACK;	RETURN;
	   END;
	END IF;
	
	--更新【抽奖名单表】
	BEGIN
		UPDATE TF_TT_LOTTERYDATA L SET ISWIN = '1' 																																							
		WHERE EXISTS (SELECT 1 FROM TF_TT_WINNERLIST W WHERE L.CARDNO = W.CARDNO AND L.CARDTYPECODE = W.CARDTYPECODE 																																							
		AND L.LOTTERYPERIOD  = W.LOTTERYPERIOD  AND W.LOTTERYPERIOD = P_LOTTERYPERIOD AND W.AWARDS = P_AWARDSCODE);																																							
	  EXCEPTION WHEN OTHERS THEN
					p_retCode := 'S210010005';
					p_retMsg :='更新抽奖名单表失败'||SQLERRM;
					ROLLBACK;	RETURN; 
	END;
	
	--更新【抽奖任务表】
	--特等奖
	IF P_AWARDSCODE = '0' THEN
		BEGIN
			UPDATE TF_TT_LOTTERYTASK SET LOTTERYSTATE = '3',GRADNDATETIME = V_TODAY,GRADNDEPARTNO = p_currDept,GRADNSTAFFNO = p_currOper																																							
			WHERE LOTTERYPERIOD = P_LOTTERYPERIOD AND PREPARESTATE = '1' AND  LOTTERYSTATE= '2';																																							
			EXCEPTION WHEN OTHERS THEN
					p_retCode := 'S210010006';
					p_retMsg :='更新抽奖任务表失败'||SQLERRM;
					ROLLBACK;	RETURN;  
		END;
	--一等奖
	ELSIF P_AWARDSCODE = '1' THEN
	 	BEGIN
			UPDATE TF_TT_LOTTERYTASK SET LOTTERYSTATE = '4',FRISTDATETIME = V_TODAY,FRISTDEPARTNO = p_currDept,FRISTSTAFFNO = p_currOper																																							
			WHERE LOTTERYPERIOD = P_LOTTERYPERIOD AND PREPARESTATE = '1' AND  LOTTERYSTATE= '2';																																							
			EXCEPTION WHEN OTHERS THEN
					p_retCode := 'S210010006';
					p_retMsg :='更新抽奖任务表失败'||SQLERRM;
					ROLLBACK;	RETURN;  
		END;
	--二等奖
	ELSIF P_AWARDSCODE = '2' THEN
	  BEGIN
			UPDATE TF_TT_LOTTERYTASK SET LOTTERYSTATE = '5',SECONDDATETIME = V_TODAY,SECONDDEPARTNO = p_currDept,SECONDSTAFFNO = p_currOper																																							
			WHERE LOTTERYPERIOD = P_LOTTERYPERIOD AND PREPARESTATE = '1' AND  LOTTERYSTATE= '2';																																							
			EXCEPTION WHEN OTHERS THEN
					p_retCode := 'S210010006';
					p_retMsg :='更新抽奖任务表失败'||SQLERRM;
					ROLLBACK;	RETURN;  
		END; 
	--三等奖
	ELSIF P_AWARDSCODE = '3' THEN
		BEGIN
			UPDATE TF_TT_LOTTERYTASK SET LOTTERYSTATE = '1',THIRDDATETIME = V_TODAY,THIRDDEPARTNO = p_currDept,THIRDSTAFFNO = p_currOper																																							
			WHERE LOTTERYPERIOD = P_LOTTERYPERIOD AND PREPARESTATE = '1' AND  LOTTERYSTATE= '2';																																							
			EXCEPTION WHEN OTHERS THEN
					p_retCode := 'S210010006';
					p_retMsg :='更新抽奖任务表失败'||SQLERRM;
					ROLLBACK;	RETURN;  
		END; 
	END IF;
	
	
  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN; 
	
END;

/
SHOW ERRORS	