CREATE OR REPLACE PROCEDURE SP_GC_ORDERMAKECUSTOMERACC
(
    p_ORDERNO           CHAR,  --订单号  
    P_BATCH             CHAR,  --批次号
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS
    v_seqNo              CHAR(16); --业务流水号
    V_MONEY              INT;
    V_TOTALMONEY         INT;
    V_HASCHARGEMOENY     INT;
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;
    V_COUNT              INT;
    V_ORDERSTATE         CHAR(2);
/*
    订单制卡-专有账户关联
    石磊
*/    
BEGIN
    --查询专有账户充值批次总金额
    BEGIN
        SELECT SUPPLYMONEY INTO V_MONEY FROM TF_F_SUPPLYSUM WHERE ID = P_BATCH;
        
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
        p_retCode := 'S094570327';
        p_retMsg  := '未找到该专有账户充值批次';
        RETURN;
    END;
    --查询充值批次是否已被关联
    SELECT COUNT(*) INTO V_COUNT FROM TF_F_CUSTOMERACCRELATION WHERE BATCHNO = P_BATCH;
    IF V_COUNT > 0 THEN
        p_retCode := 'S094570329';
        p_retMsg  := '该专有账户充值批次已被关联';
        RETURN;    
    END IF;
    --记录专有账户订单关系表
    BEGIN
        INSERT INTO TF_F_CUSTOMERACCRELATION(ORDERNO,BATCHNO,MONEY)VALUES(p_ORDERNO,P_BATCH,V_MONEY);
        
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570328';
        p_retMsg  := '记录专有账户订单关系表失败,'|| SQLERRM;
        ROLLBACK; RETURN;
    END;
    
    --校验专有账户实际充值金额是否超过订单要求的专有账户总充值金额
    SELECT NVL(CUSTOMERACCMONEY,0),NVL(CUSTOMERACCHASMONEY,0),ORDERSTATE 
    INTO V_TOTALMONEY,V_HASCHARGEMOENY,V_ORDERSTATE 
    FROM TF_F_ORDERFORM 
    WHERE ORDERNO = p_ORDERNO ;
    
    IF V_HASCHARGEMOENY + V_MONEY > V_TOTALMONEY THEN
        p_retCode := 'S094570318';
        p_retMsg  := '专有账户实际充值金额超过了订单中要求的专有账户总充值金额';
        ROLLBACK;RETURN;
    END IF;
    
    --修改订单表
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
        p_retMsg  := '更新订单表失败,'|| SQLERRM;
        ROLLBACK; RETURN;           
    END;
    

    --生成流水号
    SP_GetSeq(seq => v_seqNo);
    
    --记录订单台账表
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
        p_retMsg :=  '记录订单台账表失败'|| SQLERRM ;
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
        P_RETMSG  := '更新订单表失败,'||SQLERRM;      
        ROLLBACK; RETURN;          
    END;
    END IF;     
    
    p_retCode := '0000000000'; 
    p_retMsg  := '成功';
    COMMIT; RETURN;    
END;

/
SHOW ERRORS