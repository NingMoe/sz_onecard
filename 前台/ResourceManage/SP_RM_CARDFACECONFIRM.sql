--------------------------------------------------
--  ����ȷ�ϴ洢����
--  ���α�д
--  ʯ��
--  2012-07-27
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_CARDFACECONFIRM
(
	P_FUNCCODE             VARCHAR2 ,  --���ܱ���
	P_APPLYORDERID         CHAR     ,  --���󵥺�
	P_CARDSAMPLECODE       CHAR     ,  --��������
	p_currOper	           char     ,
	p_currDept	           char     ,
	P_OUTSAMPLECODE    OUT CHAR     ,  --���ؿ�������
	p_retCode          out char     ,  -- Return Code
	p_retMsg           out varchar2    -- Return Message  
)
AS
    V_EX                EXCEPTION      ;
    V_TODAY             DATE := SYSDATE;
    v_seqNo             CHAR(16);     --��ˮ��
BEGIN
	IF P_FUNCCODE = 'CARDSAMPLEUPLOAD' THEN
	  BEGIN
	    	SELECT TD_M_CARDSAMPLE_SEQ.NEXTVAL INTO P_OUTSAMPLECODE FROM DUAL;
	  	  --��¼���������
		  	INSERT INTO TD_M_CARDSAMPLE(
		  	    CARDSAMPLECODE  , UPDATESTAFFNO , UPDATETIME
		   )VALUES(
		        P_OUTSAMPLECODE , p_currOper    , V_TODAY
		        );
		EXCEPTION
		  WHEN OTHERS THEN
		      p_retCode := 'S094570105'; 
		      p_retMsg  := '��¼���������ʧ��'|| SQLERRM;
		      ROLLBACK;RETURN;	  
	  END;
  END IF;
  IF P_FUNCCODE = 'CARDFACECONFIRM' THEN
    BEGIN
    	--��������
      UPDATE TF_F_APPLYORDER
      SET    CARDSAMPLECODE = P_CARDSAMPLECODE
      WHERE  APPLYORDERID = P_APPLYORDERID
      AND    CARDSAMPLECODE IS NULL
      AND    APPLYORDERTYPE = '02'  --���ƿ�Ƭ
      AND    APPLYORDERSTATE = '0'; --δ�¶�����
      
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S094570106';
        P_RETMSG  := '���¿�Ƭ����ʧ��'||SQLERRM;      
        ROLLBACK; RETURN;       
    END;
    BEGIN
    	--���¶�����
      UPDATE TF_F_CARDORDER
      SET    CARDSAMPLECODE = P_CARDSAMPLECODE
      WHERE  APPLYORDERID = P_APPLYORDERID
      AND    CARDSAMPLECODE IS NULL
      AND    CARDORDERTYPE = '02'  --���ƿ�Ƭ
      AND    CARDORDERSTATE = '0'; --�����
      
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S094570121';
        P_RETMSG  := '���¿�Ƭ������ʧ��'||SQLERRM;      
        ROLLBACK; RETURN;       
    END;    
    
    --��ȡ��ˮ��
    SP_GetSeq(seq => v_seqNo);
    
		--��¼���ݹ���̨�˱�
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
	          p_retCode := 'S094570108'; p_retMsg  := '��¼���ݹ���̨�˱�ʧ��' || SQLERRM;
	          ROLLBACK; RETURN;				       		
		END;    
  END IF;
  
    p_retCode := '0000000000';
	  p_retMsg  := '�ɹ�';
	  COMMIT; RETURN;     
END;

/
show errors