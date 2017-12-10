CREATE OR REPLACE PROCEDURE SP_GC_RETURNORDER
(
    p_ORDERNO           CHAR,  --订单号
    p_HASAPPROVAL       CHAR,  --是否已审核
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS
    v_seqNo              CHAR(16); --业务流水号
    V_FROMCARDNO         CHAR(14);
    V_TOCARDNO           CHAR(14);
    V_VALUECODE          CHAR(1);
    V_NUMBER             INT;
    V_ORDERSTATE         CHAR(2);
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;
    V_TRADEID            CHAR(16);
BEGIN
    --查询订单状态
    SELECT ORDERSTATE INTO V_ORDERSTATE FROM TF_F_ORDERFORM WHERE ORDERNO = p_ORDERNO;
    
    --更新订单表
    BEGIN
        UPDATE TF_F_ORDERFORM
        SET    ORDERSTATE = '00' , --修改中
               CUSTOMERACCHASMONEY = 0,
               FINANCEAPPROVERNO = '',
               FINANCEAPPROVERTIME = '',
               FINANCEREMARK = '',
               ASSIGNSTAFFNO = '',
               ASSIGNTIME = '',
               ISRELATED = '',
               UPDATEDEPARTNO = p_currDept,
               UPDATESTAFFNO = p_currOper,
               UPDATETIME = V_TODAY
        WHERE  ORDERNO = p_ORDERNO;
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570320';
        p_retMsg  := '更新订单表失败,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;
    
    --更新利金卡订单明细表
    BEGIN
        UPDATE TF_F_CASHGIFTORDER 
        SET    LEFTQTY = COUNT
        WHERE  ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570321';
        p_retMsg  := '更新利金卡订单明细表失败,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;
    
    --更新充值卡订单明细表
    BEGIN
        UPDATE TF_F_CHARGECARDORDER 
        SET    LEFTQTY = COUNT
        WHERE  ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570322';
        p_retMsg  := '更新充值卡订单明细表失败,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;
    
    --更新市民卡B卡订单明细表
    BEGIN
        UPDATE TF_F_SZTCARDORDER
        SET    LEFTQTY = COUNT
        WHERE  ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570323';
        p_retMsg  := '更新市民卡B卡订单明细表失败,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;
	
    --更新读卡器订单明细表
    BEGIN
        UPDATE TF_F_READERORDER
        SET    LEFTQTY = COUNT
        WHERE  ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570349';
        p_retMsg  := '更新读卡器订单明细表失败,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;	
    
    --生成流水号
    SP_GetSeq(seq => v_seqNo);    
    
    IF p_HASAPPROVAL = '1' THEN --如果已经审核通过，取消卡片订单关系和账单订单关系
        --返销制卡台账
        BEGIN
            UPDATE TF_F_ORDERTRADE
            SET    CANCELTAG = '1' ,
                   CANCELTRADEID = v_seqNo
            WHERE  ORDERNO = p_ORDERNO
            AND    TRADECODE = '07'
            AND    CANCELTAG = '0';
            
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S943901B03';
                p_retMsg  := '返销制卡台账失败' || SQLERRM;
                ROLLBACK; RETURN;            
        END;
    
        --取消利金卡订单关系
        BEGIN
            DELETE FROM TF_F_CASHGIFTRELATION WHERE ORDERNO = p_ORDERNO;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570324';
            p_retMsg  := '取消利金卡订单关系失败,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;    
        
        --取消充值卡订单关系
        BEGIN
            DELETE FROM TF_F_CHARGECARDRELATION WHERE ORDERNO = p_ORDERNO;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570325';
            p_retMsg  := '取消充值卡订单关系失败,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;
        
        --取消市民卡B卡订单关系
        BEGIN
            DELETE FROM TF_F_SZTCARDRELATION WHERE ORDERNO = p_ORDERNO;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570326';
            p_retMsg  := '取消市民卡B卡订单关系失败,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;
        
        --取消专有账户订单关系
        BEGIN
            DELETE FROM TF_F_CUSTOMERACCRELATION WHERE ORDERNO = p_ORDERNO;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570327';
            p_retMsg  := '取消专有账户订单关系失败,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;
		
		--取消读卡器订单关系
        BEGIN
            DELETE FROM TF_F_READERRELATION WHERE ORDERNO = p_ORDERNO;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570348';
            p_retMsg  := '取消读卡器订单关系失败,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;
        
        V_TRADEID := v_seqNo;
        for v_c in(SELECT A.CHECKID,A.MONEY FROM TF_F_ORDERCHECKRELATION A WHERE A.ORDERNO = p_ORDERNO)
        LOOP
            --记录账单台账表
            BEGIN
                INSERT INTO TF_B_CHECK(
                    TRADEID   , CHECKID     , TRADECODE , MONEY     , USEDMONEY   , LEFTMONEY   , OPERATESTAFFNO , OPERATETIME
                )SELECT 
                    V_TRADEID , v_c.CHECKID , '5'       , v_c.MONEY , B.USEDMONEY , B.LEFTMONEY , p_currOper     , V_TODAY
                FROM TF_F_CHECK B
                WHERE v_c.CHECKID = B.CHECKID;
            EXCEPTION WHEN OTHERS THEN
                p_retCode := 'S094570328';
                p_retMsg  := '记录账单台账表失败,'|| SQLERRM;
                ROLLBACK; RETURN;            
            END;
            
            --生成流水号
            SP_GetSeq(seq => V_TRADEID);    
        END LOOP;
        
        --更新账单表
        BEGIN
            MERGE INTO TF_F_CHECK T
            USING(SELECT CHECKID,MONEY FROM TF_F_ORDERCHECKRELATION WHERE ORDERNO = p_ORDERNO) A
            ON (T.CHECKID = A.CHECKID)
            WHEN MATCHED THEN UPDATE SET 
                 USEDMONEY = USEDMONEY - A.MONEY ,
                 LEFTMONEY = LEFTMONEY + A.MONEY ,
                 CHECKSTATE = '2';
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570329';
            p_retMsg  := '更新账单表失败,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;    
        
        --更新账单表
        BEGIN
            MERGE INTO TF_F_CHECK T
            USING(SELECT CHECKID FROM TF_F_ORDERCHECKRELATION WHERE ORDERNO = p_ORDERNO) A
            ON (T.CHECKID = A.CHECKID AND T.MONEY = 0)
            WHEN MATCHED THEN UPDATE SET 
                 CHECKSTATE = '1';
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570329';
            p_retMsg  := '更新账单表失败,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END; 
        
        --订单与账单关系入历史表
        BEGIN
            INSERT INTO TH_F_ORDERCHECKRELATION 
                (ORDERNO,CHECKID,TRADEID,MONEY,UPDATESTAFFNO,UPDATETIME)
            SELECT 
                ORDERNO,CHECKID,TRADEID,MONEY,UPDATESTAFFNO,UPDATETIME
            FROM TF_F_ORDERCHECKRELATION 
            WHERE ORDERNO = p_ORDERNO;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570330';
            p_retMsg  := '订单与账单关系入历史表失败,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;        
        
        --取消订单与账单关系
        BEGIN
            DELETE FROM TF_F_ORDERCHECKRELATION WHERE ORDERNO = p_ORDERNO;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570331';
            p_retMsg  := '取消订单与账单关系失败,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;  
    END IF;    
    
    --记录订单台账表
    BEGIN
        INSERT INTO TF_F_ORDERTRADE(
            TRADEID    , ORDERNO         , ORDERSTATE     , TRADECODE    , 
            MONEY      , OPERATEDEPARTNO , OPERATESTAFFNO , OPERATETIME
        )SELECT 
            v_seqNo    , p_ORDERNO       , V_ORDERSTATE   , '04'         , 
            TOTALMONEY , p_currDept      , p_currOper     , V_TODAY
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
show errors