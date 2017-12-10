CREATE OR REPLACE PROCEDURE SP_GC_ORDERMAKEOLDSZTCARD
(
    p_ORDERNO           CHAR,  --������  
    P_CARDTYPECODE      CHAR,  --����B����Ƭ���� 
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS
    v_TradeID            char(16);
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;
    V_MONEY              INT;
    V_ORDERSTATE         CHAR(2);    
/*
    �����ƿ�-�ɵ�����B����ֵȷ�����
    ����
*/
BEGIN
    --����ǳ����ƿ������޸Ķ���״̬
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
    
    --�޸�����B��������ϸ��  ISCHARGE=0����ɿ���ֵȷ�����
    BEGIN
        UPDATE TF_F_SZTCARDORDER
        SET    ISCHARGE = 0
        WHERE  ORDERNO = p_ORDERNO
        AND    CARDTYPECODE = P_CARDTYPECODE
        AND    COUNT = 0
        AND    UNITPRICE = 0;
        
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570321';
        p_retMsg  := '��������B��������ϸ��ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;             
    END;
    

    SP_GetSeq(seq => v_TradeID);   
    --��¼����̨�˱�
    BEGIN
        INSERT INTO TF_F_ORDERTRADE (
            TRADEID         , ORDERNO           , TRADECODE       , MONEY             , GROUPNAME      , NAME   ,
            CASHGIFTMONEY   , CHARGECARDMONEY   , SZTCARDMONEY    , CUSTOMERACCMONEY  , GETDEPARTMENT  ,
            GETDATE         , REMARK            , OPERATEDEPARTNO , OPERATESTAFFNO    , OPERATETIME    ,
            MAKETYPE        , MAKECARDTYPE      , READERMONEY     , GARDENCARDMONEY   , RELAXCARDMONEY
       )SELECT
            v_TradeID       , p_ORDERNO         , '07'            , V_MONEY            , A.GROUPNAME    , A.NAME ,
            A.CASHGIFTMONEY , A.CHARGECARDMONEY , A.SZTCARDMONEY  , A.CUSTOMERACCMONEY , A.GETDEPARTMENT,
            A.GETDATE       , A.REMARK          , p_currDept      , p_currOper         , v_today        ,
            '2'             , P_CARDTYPECODE    , A.READERMONEY   , A.GARDENCARDMONEY  , A.RELAXCARDMONEY
        FROM TF_F_ORDERFORM A
        WHERE ORDERNO = p_ORDERNO;
    exception when others then
        p_retCode := 'S094570323';
        p_retMsg :=  '��¼����̨�˱�ʧ��'|| SQLERRM ;
        rollback; return;
    END;            
    
   
    
    p_retCode := '0000000000'; 
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;    
END;

/
SHOW ERRORS