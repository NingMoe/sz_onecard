CREATE OR REPLACE PROCEDURE SP_PB_TRANSITLIMIT
(
	  P_FUNCCODE  VARCHAR2 , --���ܱ���
	  P_TRADEID   VARCHAR2 , --ҵ����ˮ��
  	P_CARDNO    CHAR     , --����
  	P_REMARK    VARCHAR2 , --��ע
  	P_CURROPER  CHAR     , --Ա������ 
  	P_CURRDEPT  CHAR     , --���ű���
    P_RETCODE   OUT CHAR , --���ر���
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
	    	 p_retCode := 'S094570042'; p_retMsg  := '���иÿ��Ŵ������״̬' ;
         ROLLBACK;RETURN;    
	    END IF;
	  --��ȡҵ����ˮ��
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
            p_retCode := 'S094570040'; p_retMsg  := '��������תֵ����̨�˱��¼ʧ��' || SQLERRM;
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
            p_retCode := 'S094570041'; p_retMsg  := '���»���תֵ����̨�˱��¼ʧ��' || SQLERRM;
            ROLLBACK;RETURN;	        		
  	END;
    END IF;
     P_RETCODE := '0000000000';
     P_RETMSG  := '';
     COMMIT; RETURN;    
END;

/
show errors