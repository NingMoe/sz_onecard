CREATE OR REPLACE PROCEDURE SP_GC_ORDERMAKEREADER
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
    订单制卡-读卡器关联
    石磊
*/    
BEGIN
    FOR cur_data IN(SELECT * FROM tmp_order TMP WHERE TMP.F0 = P_SESSIONID)LOOP
        V_FROMCARDNO := cur_data.F1;
        V_TOCARDNO := cur_data.F2;
        V_PRICE := cur_data.F3;
        V_NUMBER := cur_data.F4;
        --修改读卡器订单明细表
        BEGIN
            UPDATE TF_F_READERORDER
            SET    LEFTQTY = LEFTQTY - V_NUMBER
            WHERE  ORDERNO = p_ORDERNO
            AND    VALUE = V_PRICE
            AND    LEFTQTY > 0;
            
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570343';
            p_retMsg  := '更新读卡器订单明细表失败,'|| SQLERRM;
            ROLLBACK; RETURN;
        END;
        
        --判断是否已有读卡器被关联
        SELECT COUNT(*) INTO V_COUNT
        FROM TF_F_READERRELATION 
        WHERE (V_FROMCARDNO BETWEEN BEGINSERIALNUMBER AND ENDSERIALNUMBER);
        
        IF V_COUNT > 0 THEN
            SELECT BEGINSERIALNUMBER,ENDSERIALNUMBER INTO V_BEGINCARDNO,V_ENDCARDNO 
            FROM TF_F_READERRELATION 
            WHERE (V_FROMCARDNO BETWEEN BEGINSERIALNUMBER AND ENDSERIALNUMBER);
            
            p_retCode := 'S094570344';
            p_retMsg  := '读卡器'||V_BEGINCARDNO||'-'||V_ENDCARDNO||'已被关联,关联的读卡器中存在已被关联的读卡器';
            ROLLBACK; RETURN;
        END IF;
        
        --判断是否已有读卡器被关联
        SELECT COUNT(*) INTO V_COUNT
        FROM TF_F_READERRELATION 
        WHERE (V_TOCARDNO BETWEEN BEGINSERIALNUMBER AND ENDSERIALNUMBER);
         
        IF V_COUNT > 0 THEN
            SELECT BEGINSERIALNUMBER,ENDSERIALNUMBER INTO V_BEGINCARDNO,V_ENDCARDNO 
            FROM TF_F_READERRELATION 
            WHERE (V_TOCARDNO BETWEEN BEGINSERIALNUMBER AND ENDSERIALNUMBER);
            
            p_retCode := 'S094570345';
            p_retMsg  := '读卡器'||V_BEGINCARDNO||'-'||V_ENDCARDNO||'已被关联,关联的读卡器中存在已被关联的读卡器';
            ROLLBACK; RETURN;
        END IF;        
        
        --记录读卡器订单关系表
        BEGIN
            INSERT INTO TF_F_READERRELATION(ORDERNO,BEGINSERIALNUMBER,ENDSERIALNUMBER,VALUE,COUNT)
            VALUES (p_ORDERNO,V_FROMCARDNO,V_TOCARDNO,V_PRICE,V_NUMBER);
            
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570346';
            p_retMsg  := '记录读卡器订单关系表失败,'|| SQLERRM;
            ROLLBACK; RETURN;           
        END;        
        
        --计算总金额
        V_MOENY := V_PRICE*V_NUMBER;

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
                v_seqNo         , p_ORDERNO         , '07'            , V_MOENY            , A.GROUPNAME    , A.NAME ,
                A.CASHGIFTMONEY , A.CHARGECARDMONEY , A.SZTCARDMONEY  , A.CUSTOMERACCMONEY , A.GETDEPARTMENT,
                A.GETDATE       , A.REMARK          , p_currDept      , p_currOper         , v_today        ,
                '5'             , V_PRICE           , V_FROMCARDNO    , V_TOCARDNO         , V_NUMBER       ,
                A.READERMONEY   , A.GARDENCARDMONEY , A.RELAXCARDMONEY
            FROM TF_F_ORDERFORM A
            WHERE ORDERNO = p_ORDERNO;
        exception when others then
            p_retCode := 'S094570347';
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