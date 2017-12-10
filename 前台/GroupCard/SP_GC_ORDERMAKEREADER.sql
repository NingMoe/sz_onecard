CREATE OR REPLACE PROCEDURE SP_GC_ORDERMAKEREADER
(
    P_SESSIONID         VARCHAR2, --SESSIONID
    p_ORDERNO           CHAR,  --������
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS
    v_seqNo              CHAR(16); --ҵ����ˮ��
    V_FROMCARDNO         CHAR(16);
    V_TOCARDNO           CHAR(16);
    V_BEGINCARDNO        CHAR(16);
    V_ENDCARDNO          CHAR(16);
    V_PRICE              INT;
    V_NUMBER             INT;
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;
    V_MOENY              INT;
    V_COUNT              INT:=0;
    V_ORDERSTATE         CHAR(2);    
/*
    �����ƿ�-����������
    ʯ��
*/    
BEGIN
    FOR cur_data IN(SELECT * FROM tmp_order TMP WHERE TMP.F0 = P_SESSIONID)LOOP
        V_FROMCARDNO := cur_data.F1;
        V_TOCARDNO := cur_data.F2;
        V_PRICE := cur_data.F3;
        V_NUMBER := cur_data.F4;
        --�޸Ķ�����������ϸ��
        BEGIN
            UPDATE TF_F_READERORDER
            SET    LEFTQTY = LEFTQTY - V_NUMBER
            WHERE  ORDERNO = p_ORDERNO
            AND    VALUE = V_PRICE
            AND    LEFTQTY > 0;
            
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570343';
            p_retMsg  := '���¶�����������ϸ��ʧ��,'|| SQLERRM;
            ROLLBACK; RETURN;
        END;
        
        --�ж��Ƿ����ж�����������
        SELECT COUNT(*) INTO V_COUNT
        FROM TF_F_READERRELATION 
        WHERE (V_FROMCARDNO BETWEEN BEGINSERIALNUMBER AND ENDSERIALNUMBER);
        
        IF V_COUNT > 0 THEN
            SELECT BEGINSERIALNUMBER,ENDSERIALNUMBER INTO V_BEGINCARDNO,V_ENDCARDNO 
            FROM TF_F_READERRELATION 
            WHERE (V_FROMCARDNO BETWEEN BEGINSERIALNUMBER AND ENDSERIALNUMBER);
            
            p_retCode := 'S094570344';
            p_retMsg  := '������'||V_BEGINCARDNO||'-'||V_ENDCARDNO||'�ѱ�����,�����Ķ������д����ѱ������Ķ�����';
            ROLLBACK; RETURN;
        END IF;
        
        --�ж��Ƿ����ж�����������
        SELECT COUNT(*) INTO V_COUNT
        FROM TF_F_READERRELATION 
        WHERE (V_TOCARDNO BETWEEN BEGINSERIALNUMBER AND ENDSERIALNUMBER);
         
        IF V_COUNT > 0 THEN
            SELECT BEGINSERIALNUMBER,ENDSERIALNUMBER INTO V_BEGINCARDNO,V_ENDCARDNO 
            FROM TF_F_READERRELATION 
            WHERE (V_TOCARDNO BETWEEN BEGINSERIALNUMBER AND ENDSERIALNUMBER);
            
            p_retCode := 'S094570345';
            p_retMsg  := '������'||V_BEGINCARDNO||'-'||V_ENDCARDNO||'�ѱ�����,�����Ķ������д����ѱ������Ķ�����';
            ROLLBACK; RETURN;
        END IF;        
        
        --��¼������������ϵ��
        BEGIN
            INSERT INTO TF_F_READERRELATION(ORDERNO,BEGINSERIALNUMBER,ENDSERIALNUMBER,VALUE,COUNT)
            VALUES (p_ORDERNO,V_FROMCARDNO,V_TOCARDNO,V_PRICE,V_NUMBER);
            
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570346';
            p_retMsg  := '��¼������������ϵ��ʧ��,'|| SQLERRM;
            ROLLBACK; RETURN;           
        END;        
        
        --�����ܽ��
        V_MOENY := V_PRICE*V_NUMBER;

        --������ˮ��
        SP_GetSeq(seq => v_seqNo);
        --��¼����̨�˱�
        BEGIN
            INSERT INTO TF_F_ORDERTRADE (
                TRADEID         , ORDERNO           , TRADECODE       , MONEY             , GROUPNAME      , NAME   ,
                CASHGIFTMONEY   , CHARGECARDMONEY   , SZTCARDMONEY    , CUSTOMERACCMONEY  , GETDEPARTMENT  ,
                GETDATE         , REMARK            , OPERATEDEPARTNO , OPERATESTAFFNO    , OPERATETIME    ,
                MAKETYPE        , MAKECARDTYPE      , RSRV1           , RSRV2             , RSRV3          ,
                READERMONEY     , GARDENCARDMONEY   , RELAXCARDMONEY
           )SELECT
                v_seqNo         , p_ORDERNO         , '07'            , V_MOENY            , A.GROUPNAME    , A.NAME ,
                A.CASHGIFTMONEY , A.CHARGECARDMONEY , A.SZTCARDMONEY  , A.CUSTOMERACCMONEY , A.GETDEPARTMENT,
                A.GETDATE       , A.REMARK          , p_currDept      , p_currOper         , v_today        ,
                '5'             , V_PRICE           , V_FROMCARDNO    , V_TOCARDNO         , V_NUMBER       ,
                A.READERMONEY   , A.GARDENCARDMONEY , A.RELAXCARDMONEY
            FROM TF_F_ORDERFORM A
            WHERE ORDERNO = p_ORDERNO;
        exception when others then
            p_retCode := 'S094570347';
            p_retMsg :=  '��¼����̨�˱�ʧ��'|| SQLERRM ;
            rollback; return;
        END;       
    END LOOP;
    
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