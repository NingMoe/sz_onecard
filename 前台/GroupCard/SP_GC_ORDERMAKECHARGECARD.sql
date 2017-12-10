CREATE OR REPLACE PROCEDURE SP_GC_ORDERMAKECHARGECARD
(
    P_SESSIONID         VARCHAR2, --SESSIONID
    p_ORDERNO           CHAR,  --订单号
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS
    v_seqNo              CHAR(16); --业务流水号
    V_FROMCARDNO         CHAR(14);
    V_TOCARDNO           CHAR(14);
    V_BEGINCARDNO        CHAR(14);
    V_ENDCARDNO          CHAR(14);
    V_VALUECODE          CHAR(1);
    V_NUMBER             INT;
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;
    V_MOENY              INT;
    V_COUNT              INT:=0;
    V_ORDERSTATE         CHAR(2);    
/*
    订单制卡-充值卡关联
    石磊
*/    
BEGIN
    FOR cur_data IN(SELECT * FROM tmp_order TMP WHERE TMP.F0 = P_SESSIONID)LOOP
        V_FROMCARDNO := cur_data.F1;
        V_TOCARDNO := cur_data.F2;
        V_VALUECODE := cur_data.F3;
        V_NUMBER := cur_data.F4;
        --修改充值卡订单明细表
        BEGIN
            UPDATE TF_F_CHARGECARDORDER
            SET    LEFTQTY = LEFTQTY - V_NUMBER
            WHERE  ORDERNO = p_ORDERNO
            AND    VALUECODE = V_VALUECODE
            AND    LEFTQTY > 0;
            
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570328';
            p_retMsg  := '更新充值卡订单明细表失败,'|| SQLERRM;
            ROLLBACK; RETURN;
        END;
        
        --判断是否已有充值卡被关联
        SELECT COUNT(*) INTO V_COUNT
        FROM TF_F_CHARGECARDRELATION 
        WHERE (V_FROMCARDNO BETWEEN FROMCARDNO AND TOCARDNO);
        
        IF V_COUNT > 0 THEN
            SELECT FROMCARDNO,TOCARDNO INTO V_BEGINCARDNO,V_ENDCARDNO 
            FROM TF_F_CHARGECARDRELATION 
            WHERE (V_FROMCARDNO BETWEEN FROMCARDNO AND TOCARDNO);
            
            p_retCode := 'S094570330';
            p_retMsg  := '充值卡'||V_BEGINCARDNO||'-'||V_ENDCARDNO||'已被关联,关联的充值卡中存在已被关联的充值卡';
            ROLLBACK; RETURN;
        END IF;
        
        --判断是否已有充值卡被关联
        SELECT COUNT(*) INTO V_COUNT
        FROM TF_F_CHARGECARDRELATION 
        WHERE (V_TOCARDNO BETWEEN FROMCARDNO AND TOCARDNO);
         
        IF V_COUNT > 0 THEN
            SELECT FROMCARDNO,TOCARDNO INTO V_BEGINCARDNO,V_ENDCARDNO 
            FROM TF_F_CHARGECARDRELATION 
            WHERE (V_TOCARDNO BETWEEN FROMCARDNO AND TOCARDNO);
            
            p_retCode := 'S094570330';
            p_retMsg  := '充值卡'||V_BEGINCARDNO||'-'||V_ENDCARDNO||'已被关联,关联的充值卡中存在已被关联的充值卡';
            ROLLBACK; RETURN;
        END IF;        
        
        --记录充值卡订单关系表
        BEGIN
            INSERT INTO TF_F_CHARGECARDRELATION(ORDERNO,FROMCARDNO,TOCARDNO,VALUECODE,COUNT)
            VALUES (p_ORDERNO,V_FROMCARDNO,V_TOCARDNO,V_VALUECODE,V_NUMBER);
            
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570325';
            p_retMsg  := '记录充值卡订单关系表失败,'|| SQLERRM;
            ROLLBACK; RETURN;           
        END;        
        
        --计算总金额
        SELECT MONEY*V_NUMBER INTO V_MOENY FROM TP_XFC_CARDVALUE WHERE VALUECODE = V_VALUECODE;

        --生成流水号
        SP_GetSeq(seq => v_seqNo);
        --记录订单台账表
        BEGIN
            INSERT INTO TF_F_ORDERTRADE (
                TRADEID         , ORDERNO           , TRADECODE       , MONEY             , GROUPNAME      , NAME   ,
                CASHGIFTMONEY   , CHARGECARDMONEY   , SZTCARDMONEY    , CUSTOMERACCMONEY  , GETDEPARTMENT  ,
                GETDATE         , REMARK            , OPERATEDEPARTNO , OPERATESTAFFNO    , OPERATETIME    ,
                MAKETYPE        , MAKECARDTYPE      , RSRV1           , RSRV2             , RSRV3          ,
                READERMONEY     , GARDENCARDMONEY   , RELAXCARDMONEY
           )SELECT
                v_seqNo         , p_ORDERNO         , '07'            , V_MOENY           , A.GROUPNAME    , A.NAME ,
                A.CASHGIFTMONEY , A.CHARGECARDMONEY , A.SZTCARDMONEY  , A.CUSTOMERACCMONEY , A.GETDEPARTMENT,
                A.GETDATE       , A.REMARK          , p_currDept      , p_currOper         , v_today        ,
                '3'             , V_VALUECODE       , V_FROMCARDNO    , V_TOCARDNO         , V_NUMBER       ,
                A.READERMONEY   , A.GARDENCARDMONEY , A.RELAXCARDMONEY
            FROM TF_F_ORDERFORM A
            WHERE ORDERNO = p_ORDERNO;
        exception when others then
            p_retCode := 'S094570326';
            p_retMsg :=  '记录订单台账表失败'|| SQLERRM ;
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