CREATE OR REPLACE PROCEDURE SP_EW_UPDATECARDORDER
(
    p_CARDORDERID    CHAR,
    p_COUNT          INT,
    p_currOper       CHAR, -- Current Operator 
    p_retCode    OUT CHAR, -- Return Code 
    p_retMsg     OUT VARCHAR2
)
AS
    v_today    date := sysdate;
    v_seqNo    CHAR(16);  
    v_ex            EXCEPTION;    
    V_CARDORDERSTATE    CHAR(1);   --������״̬
    V_ORDERCARDNUM      INT    ;   --������Ҫ������
    V_ALREADYARRIVENUM  INT    ;   --�ѵ�������    
BEGIN
    --��ѯ�������������ź����󵥺�
    SELECT CARDNUM ,
           ALREADYARRIVENUM
    INTO   V_ORDERCARDNUM ,
           V_ALREADYARRIVENUM
    FROM TF_F_SMK_CARDORDER 
    WHERE  CARDORDERID = p_CARDORDERID
    AND    CARDORDERSTATE IN('1','3') --1���ͨ����3���ֵ���
    AND    USETAG = '1'    ;
    
    IF p_COUNT + V_ALREADYARRIVENUM >= V_ORDERCARDNUM THEN
       V_CARDORDERSTATE := '4';  --ȫ������
    ELSE
       V_CARDORDERSTATE := '3';  --���ֵ���
    END IF;     
    
    BEGIN
        --���¶�����
        UPDATE TF_F_SMK_CARDORDER
        SET    CARDORDERSTATE = V_CARDORDERSTATE ,  --������״̬
               ALREADYARRIVENUM = V_ALREADYARRIVENUM + p_COUNT  --�ѵ�������
        WHERE  CARDORDERID = p_CARDORDERID
        AND    USETAG = '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570117'; p_retMsg  := '���¶�����ʧ��'|| SQLERRM;
            ROLLBACK; RETURN;
    END;    
    
	SP_GetSeq(seq => v_seqNo);
	
    BEGIN
        --��¼���ݹ���̨�˱�
        INSERT INTO TF_B_SMK_ORDERMANAGE(
            TRADEID          , ORDERID           , OPERATETYPECODE   ,
            CARDNUM          , OPERATETIME       , OPERATESTAFF      
        )VALUES(
            v_seqNo          , p_CARDORDERID     , '07'              ,
            p_COUNT          , V_TODAY           , P_CURROPER        
            );    
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570119'; p_retMsg  := '��¼���ݹ���̨�˱�ʧ��'|| SQLERRM;
            ROLLBACK; RETURN;       
    END;

    p_retCode := '0000000000'; p_retMsg  := '';
    RETURN;
END;

/
SHOW ERRORS