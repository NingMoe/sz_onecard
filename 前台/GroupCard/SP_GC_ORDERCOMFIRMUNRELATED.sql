CREATE OR REPLACE PROCEDURE SP_GC_ORDERCOMFIRMUNRELATED
(
    p_ORDERNO           CHAR,  --订单号
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS
    v_seqNo               CHAR(16); --业务流水号
    V_CHARGECARDMONEY     INT := 0;
    V_HASRELATEDMONEY     INT := 0;
    V_CUSTOMERACCMONEY    INT := 0;
    V_CUSTOMERACCHASMONEY INT := 0;
    V_EX                  EXCEPTION;
    V_TODAY               DATE := SYSDATE;
BEGIN
    --获取专有账户总充值金额，已充值金额和充值卡总金额
    SELECT NVL(CUSTOMERACCMONEY,0),NVL(CUSTOMERACCHASMONEY,0),NVL(CHARGECARDMONEY ,0)
    INTO V_CUSTOMERACCMONEY,V_CUSTOMERACCHASMONEY,V_CHARGECARDMONEY
    FROM TF_F_ORDERFORM
    WHERE ORDERNO = p_ORDERNO;
    
    --获取充值卡已关联总金额
    SELECT nvl(SUM(A.COUNT*nvl(B.MONEY,0)),0) INTO V_HASRELATEDMONEY
    FROM TF_F_CHARGECARDRELATION A,TP_XFC_CARDVALUE B 
    WHERE ORDERNO = p_ORDERNO 
    AND A.VALUECODE = B.VALUECODE;
    
    --如果充值卡总金额与充值卡已关联总金额不一致，则提示未完成充值卡关联
    IF V_CHARGECARDMONEY <> V_HASRELATEDMONEY THEN
        p_retCode := 'S094570333';
        p_retMsg  := '未完成充值卡关联,'|| SQLERRM;
        RETURN;  
    END IF;    
    
    --如果专有账户总充值金额和已充值金额不一致则提示未完成专有账户关联
    IF V_CUSTOMERACCMONEY <> V_CUSTOMERACCHASMONEY THEN
        p_retCode := 'S094570334';
        p_retMsg  := '未完成专有账户关联,'|| SQLERRM;
        RETURN;  
    END IF;
    
    --更新订单表
    BEGIN
        UPDATE TF_F_ORDERFORM
        SET    ORDERSTATE = '06', --不关联确认完成
               UPDATEDEPARTNO = p_currDept,
               UPDATESTAFFNO = p_currOper,
               UPDATETIME = V_TODAY
        WHERE  ORDERNO = p_ORDERNO
        AND    ISRELATED = '0'; --不关联
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570320';
        p_retMsg  := '更新订单表失败,'|| SQLERRM;
        ROLLBACK; RETURN;
    END;
    
    --生成流水号
    SP_GetSeq(seq => v_seqNo);        
    
    --记录订单台账表
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
        p_retMsg  := '记录订单台账表失败,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;    
    
    p_retCode := '0000000000'; 
    p_retMsg  := '成功';
    COMMIT; RETURN;    
END;

/
SHOW ERRORS