CREATE OR REPLACE PROCEDURE SP_GC_ORDERCOMFIRMUNRELATED
(
    p_ORDERNO           CHAR,  --������
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS
    v_seqNo               CHAR(16); --ҵ����ˮ��
    V_CHARGECARDMONEY     INT := 0;
    V_HASRELATEDMONEY     INT := 0;
    V_CUSTOMERACCMONEY    INT := 0;
    V_CUSTOMERACCHASMONEY INT := 0;
    V_EX                  EXCEPTION;
    V_TODAY               DATE := SYSDATE;
BEGIN
    --��ȡר���˻��ܳ�ֵ���ѳ�ֵ���ͳ�ֵ���ܽ��
    SELECT NVL(CUSTOMERACCMONEY,0),NVL(CUSTOMERACCHASMONEY,0),NVL(CHARGECARDMONEY ,0)
    INTO V_CUSTOMERACCMONEY,V_CUSTOMERACCHASMONEY,V_CHARGECARDMONEY
    FROM TF_F_ORDERFORM
    WHERE ORDERNO = p_ORDERNO;
    
    --��ȡ��ֵ���ѹ����ܽ��
    SELECT nvl(SUM(A.COUNT*nvl(B.MONEY,0)),0) INTO V_HASRELATEDMONEY
    FROM TF_F_CHARGECARDRELATION A,TP_XFC_CARDVALUE B 
    WHERE ORDERNO = p_ORDERNO 
    AND A.VALUECODE = B.VALUECODE;
    
    --�����ֵ���ܽ�����ֵ���ѹ����ܽ�һ�£�����ʾδ��ɳ�ֵ������
    IF V_CHARGECARDMONEY <> V_HASRELATEDMONEY THEN
        p_retCode := 'S094570333';
        p_retMsg  := 'δ��ɳ�ֵ������,'|| SQLERRM;
        RETURN;  
    END IF;    
    
    --���ר���˻��ܳ�ֵ�����ѳ�ֵ��һ������ʾδ���ר���˻�����
    IF V_CUSTOMERACCMONEY <> V_CUSTOMERACCHASMONEY THEN
        p_retCode := 'S094570334';
        p_retMsg  := 'δ���ר���˻�����,'|| SQLERRM;
        RETURN;  
    END IF;
    
    --���¶�����
    BEGIN
        UPDATE TF_F_ORDERFORM
        SET    ORDERSTATE = '06', --������ȷ�����
               UPDATEDEPARTNO = p_currDept,
               UPDATESTAFFNO = p_currOper,
               UPDATETIME = V_TODAY
        WHERE  ORDERNO = p_ORDERNO
        AND    ISRELATED = '0'; --������
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570320';
        p_retMsg  := '���¶�����ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;
    END;
    
    --������ˮ��
    SP_GetSeq(seq => v_seqNo);        
    
    --��¼����̨�˱�
    BEGIN
        INSERT INTO TF_F_ORDERTRADE(
            TRADEID         , ORDERNO        , TRADECODE    , 
            OPERATEDEPARTNO , OPERATESTAFFNO , OPERATETIME
        )SELECT 
            v_seqNo         , p_ORDERNO      , '08'         , 
            p_currDept      , p_currOper     , V_TODAY
        FROM TF_F_ORDERFORM 
        WHERE ORDERNO = p_ORDERNO
        ;    
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570332';
        p_retMsg  := '��¼����̨�˱�ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;    
    
    p_retCode := '0000000000'; 
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;    
END;

/
SHOW ERRORS