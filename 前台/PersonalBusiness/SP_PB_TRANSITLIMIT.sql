CREATE OR REPLACE PROCEDURE SP_PB_TRANSITLIMIT
(
	  P_FUNCCODE  VARCHAR2 , --功能编码
	  P_TRADEID   VARCHAR2 , --业务流水号
  	P_CARDNO    CHAR     , --卡号
  	P_REMARK    VARCHAR2 , --备注
  	P_CURROPER  CHAR     , --员工编码 
  	P_CURRDEPT  CHAR     , --部门编码
    P_RETCODE   OUT CHAR , --返回编码
    P_RETMSG    OUT VARCHAR2 
)
AS
    V_COUNT     INT;
    V_TODAY     DATE := SYSDATE ;
    V_SEQNO     CHAR(16);  
    V_EX        EXCEPTION;
BEGIN
	  IF P_FUNCCODE = 'ADD' THEN
	  
		  SELECT COUNT(*) INTO V_COUNT 
		  FROM   TF_B_TRANSITLIMIT
		  WHERE  CARDNO = P_CARDNO
		  AND    STATE = '0';
	  
	  	IF V_COUNT > 0 THEN 
	    	 p_retCode := 'S094570042'; p_retMsg  := '已有该卡号处于添加状态' ;
         ROLLBACK;RETURN;    
	    END IF;
	  --获取业务流水号
	  SP_GetSeq(seq => V_SEQNO);
	  BEGIN
	  	INSERT INTO TF_B_TRANSITLIMIT(
	  	    TRADEID    , CARDNO   , STATE , ADDTIME ,
	  	    ADDSTAFFNO , REMARK
	   )VALUES(
	        V_SEQNO    , P_CARDNO , '0'   , V_TODAY ,
	        P_CURROPER , P_REMARK
	        );
	        
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570040'; p_retMsg  := '新增换卡转值限制台账表记录失败' || SQLERRM;
            ROLLBACK;RETURN;    
	  END;
  	END IF;
  	IF P_FUNCCODE = 'DELETE' THEN
  	BEGIN 
  		UPDATE TF_B_TRANSITLIMIT
  		SET    STATE         = '1'       ,
  		       DELETETIME    = V_TODAY   , 
  		       DELETESTAFFNO = P_CURROPER
  		WHERE  TRADEID = P_TRADEID
  		AND    STATE   = '0';
  		
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570041'; p_retMsg  := '更新换卡转值限制台账表记录失败' || SQLERRM;
            ROLLBACK;RETURN;	        		
  	END;
    END IF;
     P_RETCODE := '0000000000';
     P_RETMSG  := '';
     COMMIT; RETURN;    
END;

/
show errors