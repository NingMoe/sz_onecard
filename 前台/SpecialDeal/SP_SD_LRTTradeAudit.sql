CREATE OR REPLACE PROCEDURE SP_SD_LRTTradeAudit
(
    P_FUNCODE       varchar2 ,  --���ܱ���
    P_TRADEID       char     ,  --ҵ����ˮ��
    P_CARDTRADENO   char     ,  --�������
    p_currOper	    char     ,
		p_currDept	    char     ,
		p_retCode       out char , -- Return Code
		p_retMsg        out varchar2  -- Return Message  
)
AS
    V_EX        EXCEPTION      ;
    V_TODAY     DATE := SYSDATE;
BEGIN
    --���ͨ��
    IF P_FUNCODE = 'PASS' THEN
    	--������콻�ײ�¼̨�˱�
    	BEGIN
    	  UPDATE TF_B_LRTTRADE_MANUAL
        SET    CHECKSTATECODE = '1'           ,
               CARDTRADENO    = P_CARDTRADENO ,
               CHECKSTAFFNO   = p_currOper    ,
               CHECKTIME      = V_TODAY
        WHERE  TRADEID        = P_TRADEID
        AND    CHECKSTATECODE = '0';
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
              P_RETCODE := 'S094570013';
              P_RETMSG  := '����ͨ����콻�ײ�¼̨�˱�ʧ��'||SQLERRM;      
              ROLLBACK; RETURN;          
    	END;
    END IF;
    --�������
    IF P_FUNCODE = 'CANCEL' THEN
    	--������콻�ײ�¼̨�˱�
    	BEGIN
    	  UPDATE TF_B_LRTTRADE_MANUAL
        SET    CHECKSTATECODE = '2'           ,
               CHECKSTAFFNO   = p_currOper    ,
               CHECKTIME      = V_TODAY
        WHERE  TRADEID        = P_TRADEID
        AND    CHECKSTATECODE = '0';
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
              P_RETCODE := 'S094570014';
              P_RETMSG  := '����������콻�ײ�¼̨�˱�ʧ��'||SQLERRM;      
              ROLLBACK; RETURN;           
    	END;    	
    END IF;
    
    p_retCode := '0000000000';
	  p_retMsg  := '�ɹ�';
	  COMMIT; RETURN;    

END;

/
show errors