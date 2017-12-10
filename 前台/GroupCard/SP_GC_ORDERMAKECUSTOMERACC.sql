CREATE OR REPLACE PROCEDURE SP_GC_ORDERMAKECUSTOMERACC
(
    p_ORDERNO           CHAR,  --������  
    P_BATCH             CHAR,  --���κ�
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS
    v_seqNo              CHAR(16); --ҵ����ˮ��
    V_MONEY              INT;
    V_TOTALMONEY         INT;
    V_HASCHARGEMOENY     INT;
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;
    V_COUNT              INT;
    V_ORDERSTATE         CHAR(2);
/*
    �����ƿ�-ר���˻�����
    ʯ��
*/    
BEGIN
    --��ѯר���˻���ֵ�����ܽ��
    BEGIN
        SELECT SUPPLYMONEY INTO V_MONEY FROM TF_F_SUPPLYSUM WHERE ID = P_BATCH;
        
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
        p_retCode := 'S094570327';
        p_retMsg  := 'δ�ҵ���ר���˻���ֵ����';
        RETURN;
    END;
    --��ѯ��ֵ�����Ƿ��ѱ�����
    SELECT COUNT(*) INTO V_COUNT FROM TF_F_CUSTOMERACCRELATION WHERE BATCHNO = P_BATCH;
    IF V_COUNT > 0 THEN
        p_retCode := 'S094570329';
        p_retMsg  := '��ר���˻���ֵ�����ѱ�����';
        RETURN;    
    END IF;
    --��¼ר���˻�������ϵ��
    BEGIN
        INSERT INTO TF_F_CUSTOMERACCRELATION(ORDERNO,BATCHNO,MONEY)VALUES(p_ORDERNO,P_BATCH,V_MONEY);
        
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570328';
        p_retMsg  := '��¼ר���˻�������ϵ��ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;
    END;
    
    --У��ר���˻�ʵ�ʳ�ֵ����Ƿ񳬹�����Ҫ���ר���˻��ܳ�ֵ���
    SELECT NVL(CUSTOMERACCMONEY,0),NVL(CUSTOMERACCHASMONEY,0),ORDERSTATE 
    INTO V_TOTALMONEY,V_HASCHARGEMOENY,V_ORDERSTATE 
    FROM TF_F_ORDERFORM 
    WHERE ORDERNO = p_ORDERNO ;
    
    IF V_HASCHARGEMOENY + V_MONEY > V_TOTALMONEY THEN
        p_retCode := 'S094570318';
        p_retMsg  := 'ר���˻�ʵ�ʳ�ֵ�����˶�����Ҫ���ר���˻��ܳ�ֵ���';
        ROLLBACK;RETURN;
    END IF;
    
    --�޸Ķ�����
    BEGIN
        UPDATE TF_F_ORDERFORM 
        SET    CUSTOMERACCHASMONEY = CUSTOMERACCHASMONEY + V_MONEY,
               UPDATEDEPARTNO = p_currDept,
               UPDATESTAFFNO = p_currOper,
               UPDATETIME = v_today
        WHERE  ORDERNO = p_ORDERNO 
        AND    ORDERSTATE IN('03','04');
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570318';
        p_retMsg  := '���¶�����ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;           
    END;
    

    --������ˮ��
    SP_GetSeq(seq => v_seqNo);
    
    --��¼����̨�˱�
    BEGIN
        INSERT INTO TF_F_ORDERTRADE (
            TRADEID         , ORDERNO           , TRADECODE       , MONEY             , GROUPNAME      , NAME   ,
            CASHGIFTMONEY   , CHARGECARDMONEY   , SZTCARDMONEY    , CUSTOMERACCMONEY  , GETDEPARTMENT  ,
            GETDATE         , REMARK            , OPERATEDEPARTNO , OPERATESTAFFNO    , OPERATETIME    ,
            MAKETYPE        , READERMONEY       , GARDENCARDMONEY , RELAXCARDMONEY
       )SELECT
            v_seqNo         , p_ORDERNO         , '07'              , V_MONEY            , A.GROUPNAME    , A.NAME ,
            A.CASHGIFTMONEY , A.CHARGECARDMONEY , A.SZTCARDMONEY    , A.CUSTOMERACCMONEY , A.GETDEPARTMENT,
            A.GETDATE       , A.REMARK          , p_currDept        , p_currOper         , v_today        ,
            '4'             , A.READERMONEY     , A.GARDENCARDMONEY , A.RELAXCARDMONEY
        FROM TF_F_ORDERFORM A
        WHERE ORDERNO = p_ORDERNO;
    exception when others then
        p_retCode := 'S094570301';
        p_retMsg :=  '��¼����̨�˱�ʧ��'|| SQLERRM ;
        rollback; return;
    END;        
    
    SELECT ORDERSTATE INTO V_ORDERSTATE FROM TF_F_ORDERFORM WHERE ORDERNO = p_ORDERNO;
    IF V_ORDERSTATE = '03' THEN
    BEGIN
        UPDATE TF_F_ORDERFORM
        SET    ORDERSTATE = '04' ,
               UPDATEDEPARTNO = p_currDept,
               UPDATESTAFFNO = p_currOper ,
               UPDATETIME = v_today
        WHERE  ORDERNO = p_ORDERNO
        AND    ORDERSTATE = '03';
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE := 'S094570338';
        P_RETMSG  := '���¶�����ʧ��,'||SQLERRM;      
        ROLLBACK; RETURN;          
    END;
    END IF;     
    
    p_retCode := '0000000000'; 
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;    
END;

/
SHOW ERRORS