--------------------------------------------------
--  卡面确认存储过程
--  初次编写
--  石磊
--  2012-07-27
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_CARDFACECONFIRM
(
	P_FUNCCODE             VARCHAR2 ,  --功能编码
	P_APPLYORDERID         CHAR     ,  --需求单号
	P_CARDSAMPLECODE       CHAR     ,  --卡样编码
	p_currOper	           char     ,
	p_currDept	           char     ,
	P_OUTSAMPLECODE    OUT CHAR     ,  --返回卡样编码
	p_retCode          out char     ,  -- Return Code
	p_retMsg           out varchar2    -- Return Message  
)
AS
    V_EX                EXCEPTION      ;
    V_TODAY             DATE := SYSDATE;
    v_seqNo             CHAR(16);     --流水号
BEGIN
	IF P_FUNCCODE = 'CARDSAMPLEUPLOAD' THEN
	  BEGIN
	    	SELECT TD_M_CARDSAMPLE_SEQ.NEXTVAL INTO P_OUTSAMPLECODE FROM DUAL;
	  	  --记录卡样编码表
		  	INSERT INTO TD_M_CARDSAMPLE(
		  	    CARDSAMPLECODE  , UPDATESTAFFNO , UPDATETIME
		   )VALUES(
		        P_OUTSAMPLECODE , p_currOper    , V_TODAY
		        );
		EXCEPTION
		  WHEN OTHERS THEN
		      p_retCode := 'S094570105'; 
		      p_retMsg  := '记录卡样编码表失败'|| SQLERRM;
		      ROLLBACK;RETURN;	  
	  END;
  END IF;
  IF P_FUNCCODE = 'CARDFACECONFIRM' THEN
    BEGIN
    	--更新需求单
      UPDATE TF_F_APPLYORDER
      SET    CARDSAMPLECODE = P_CARDSAMPLECODE
      WHERE  APPLYORDERID = P_APPLYORDERID
      AND    CARDSAMPLECODE IS NULL
      AND    APPLYORDERTYPE = '02'  --新制卡片
      AND    APPLYORDERSTATE = '0'; --未下订购单
      
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S094570106';
        P_RETMSG  := '更新卡片需求单失败'||SQLERRM;      
        ROLLBACK; RETURN;       
    END;
    BEGIN
    	--更新订购单
      UPDATE TF_F_CARDORDER
      SET    CARDSAMPLECODE = P_CARDSAMPLECODE
      WHERE  APPLYORDERID = P_APPLYORDERID
      AND    CARDSAMPLECODE IS NULL
      AND    CARDORDERTYPE = '02'  --新制卡片
      AND    CARDORDERSTATE = '0'; --待审核
      
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S094570121';
        P_RETMSG  := '更新卡片订购单失败'||SQLERRM;      
        ROLLBACK; RETURN;       
    END;    
    
    --获取流水号
    SP_GetSeq(seq => v_seqNo);
    
		--记录单据管理台账表
		BEGIN
			INSERT INTO TF_B_ORDERMANAGE(
			    TRADEID           , ORDERTYPECODE  , ORDERID        , OPERATETYPECODE  ,
			    CARDSAMPLECODE    , CARDNUM        , REQUIREDATE    , OPERATETIME      , 
			    OPERATESTAFF      
			)SELECT
			    v_seqNo           , '01'           , t.APPLYORDERID , '11'             ,
			    t.CARDSAMPLECODE  , t.CARDNUM      , t.REQUIREDATE  , V_TODAY          , 
			    P_CURROPER        
			 FROM  TF_F_APPLYORDER t
			 WHERE APPLYORDERID = P_APPLYORDERID; 
			 
	     IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	  EXCEPTION
	     WHEN OTHERS THEN
	          p_retCode := 'S094570108'; p_retMsg  := '记录单据管理台账表失败' || SQLERRM;
	          ROLLBACK; RETURN;				       		
		END;    
  END IF;
  
    p_retCode := '0000000000';
	  p_retMsg  := '成功';
	  COMMIT; RETURN;     
END;

/
show errors