CREATE OR REPLACE PROCEDURE SP_GC_ORDERAPPROVAL
(
    P_SESSIONID         VARCHAR2,  --sessionid
    P_FINANCEREMARK     VARCHAR2,  --财务审核意见
    p_ISAPPROVE         CHAR    ,  --是否呈批单
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS 
    v_seqNo              CHAR(16); --业务流水号
    V_ORDERNO            CHAR(16); --订单号
    V_CHECKID            CHAR(16); --账单号
    V_ORDERMONEY         INT;      --订单总金额
    V_ORDERLEFTMONEY     INT;      --订单剩余未匹配金额
    V_CHECKMONEY         INT;      --账单总金额
    V_CHECKUSEDMONEY     INT;      --账单已使用金额
    V_CHECKLEFTMONEY     INT;      --账单剩余金额
    V_TRADEMONEY         INT;      --交易金额
    V_CHECKSTATE         CHAR(1);  --账单状态
    V_ACCOUNTNAME        VARCHAR2(100);--对方户名
    V_ACCOUNTNUMBER      VARCHAR2(30);--对方账号
    V_COUNT              INT;
    V_ORDERSTATE         CHAR(2);   --订单状态
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;
/*
--  订单财务审核
--  初次编写
--  石磊
--  2013-03-26
*/
BEGIN
    --遍历订单
    FOR cur IN (SELECT F2 FROM TMP_ORDER WHERE F0 = P_SESSIONID AND F1 = '0') LOOP
        V_ORDERNO := cur.F2;
        --查询订单状态判断是否是未审核状态
        SELECT ORDERSTATE INTO V_ORDERSTATE FROM TF_F_ORDERFORM WHERE ORDERNO = V_ORDERNO;
        IF V_ORDERSTATE<>'01' THEN
         p_retCode := 'S094570300';
                    p_retMsg := '订单号为'||V_ORDERNO||'的订单不为未审核状态';
                   ROLLBACK;  RETURN; 
        END IF;
        
        --订单剩余未匹配金额赋值
        SELECT TOTALMONEY INTO V_ORDERLEFTMONEY FROM TF_F_ORDERFORM WHERE ORDERNO = V_ORDERNO;
        
        --更新订单表
        BEGIN
            UPDATE TF_F_ORDERFORM
            SET    ORDERSTATE = '02',
                   FINANCEAPPROVERNO = p_currOper,
                   FINANCEAPPROVERTIME = V_TODAY,
                   FINANCEREMARK = P_FINANCEREMARK,
                   UPDATEDEPARTNO = p_currDept,
                   UPDATESTAFFNO = p_currOper,
                   UPDATETIME = V_TODAY
            WHERE  ORDERNO = V_ORDERNO;    
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570308';
            p_retMsg  := '更新订单表失败,'|| SQLERRM;
            ROLLBACK; RETURN;            
        END;
        IF p_ISAPPROVE <> '1' THEN --如果不是呈批单订单则关联账单
            --遍历账单
            FOR cur IN (SELECT F2 FROM TMP_ORDER WHERE F0 = P_SESSIONID AND F1 = '1') LOOP
                V_CHECKID := cur.F2;
                --查询账单金额、已使用金额、余额、对方帐号、对方户名
                SELECT MONEY,USEDMONEY,LEFTMONEY,ACCOUNTNAME,ACCOUNTNUMBER INTO V_CHECKMONEY,V_CHECKUSEDMONEY,V_CHECKLEFTMONEY,V_ACCOUNTNAME,V_ACCOUNTNUMBER FROM TF_F_CHECK WHERE CHECKID = V_CHECKID;
                --如果账单金额 != 已使用金额 + 余额，提示错误
                IF V_CHECKLEFTMONEY + V_CHECKUSEDMONEY <> V_CHECKMONEY THEN
                    p_retCode := 'S094570309';
                    p_retMsg := '该账单已使用金额加余额不等于总金额，请确认' ;
                    RETURN;            
                END IF;
                
                --如果订单要求金额小于等于账单金额
                IF V_ORDERLEFTMONEY <= V_CHECKLEFTMONEY THEN
                    IF V_ORDERLEFTMONEY = V_CHECKLEFTMONEY THEN
                        V_CHECKSTATE := '3'; --完成使用
                    ELSE
                        V_CHECKSTATE := '2'; --部分使用
                    END IF;
                    --更新账单表
                    BEGIN
                        UPDATE TF_F_CHECK 
                        SET    CHECKSTATE = V_CHECKSTATE,
                               USEDMONEY = V_CHECKUSEDMONEY + V_ORDERLEFTMONEY,
                               LEFTMONEY = V_CHECKLEFTMONEY - V_ORDERLEFTMONEY,
                               UPDATEDEPARTNO = p_currDept,
                               UPDATESTAFFNO = p_currOper,
                               UPDATETIME = V_TODAY
                        WHERE  CHECKID = V_CHECKID;
                    IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                    EXCEPTION WHEN OTHERS THEN
                        p_retCode := 'S094570310';
                        p_retMsg  := '更新账单表失败,'|| SQLERRM;
                        ROLLBACK; RETURN;            
                    END;                
                    
                    V_TRADEMONEY := V_ORDERLEFTMONEY;
                    --订单剩余金额为0
                    V_ORDERLEFTMONEY := 0;
                ELSE --如果订单要求金额大于账单金额
                    --更新账单表
                    BEGIN
                        UPDATE TF_F_CHECK 
                        SET    CHECKSTATE = '3', --完成使用
                               USEDMONEY = V_CHECKMONEY, --已用金额等于账单金额
                               LEFTMONEY = 0, --剩余金额为0
                               UPDATEDEPARTNO = p_currDept,
                               UPDATESTAFFNO = p_currOper,
                               UPDATETIME = V_TODAY
                        WHERE  CHECKID = V_CHECKID;
                    IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                    EXCEPTION WHEN OTHERS THEN
                        p_retCode := 'S094570311';
                        p_retMsg  := '更新账单表失败,'|| SQLERRM;
                        ROLLBACK; RETURN;            
                    END;
                    --交易金额赋值
                    V_TRADEMONEY := V_CHECKLEFTMONEY;
                    --计算订单剩余未完成金额
                    V_ORDERLEFTMONEY := V_ORDERLEFTMONEY - V_CHECKLEFTMONEY;
                END IF;
                
                --生成流水号
                SP_GetSeq(seq => v_seqNo); 
                --记录订单与账单关联关系表
                BEGIN
                    INSERT INTO TF_F_ORDERCHECKRELATION(
                        ORDERNO   , CHECKID   , TRADEID , MONEY            , UPDATESTAFFNO , UPDATETIME
                    )VALUES(
                        V_ORDERNO , V_CHECKID , v_seqNo , V_TRADEMONEY , p_currOper    , V_TODAY
                    );
                IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                    p_retCode := 'S094570312';
                    p_retMsg  := '记录订单与账单关联关系表失败,'|| SQLERRM;
                    ROLLBACK; RETURN;            
                END;
                BEGIN
                	SELECT COUNT(*) INTO V_COUNT FROM TF_F_COMBUYCARDREG T WHERE T.REMARK = V_ORDERNO;
                  
                	IF V_COUNT>0 THEN 
                	--更新单位购卡记录表
                	BEGIN
                		UPDATE TF_F_COMBUYCARDREG 
                		SET OUTBANK = v_ACCOUNTNUMBER,--转出银行帐号
                		    OUTACCT = V_ACCOUNTNAME--转出账户户名
                		WHERE REMARK = V_ORDERNO;
                		 IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                    EXCEPTION WHEN OTHERS THEN
                        p_retCode := 'S094570311';
                        p_retMsg  := '更新单位购卡记录表失败,'|| SQLERRM;
                        ROLLBACK; RETURN; 
                	END;
                  END IF;
                	
                END;
                --记录订单台账
                BEGIN
                    INSERT INTO TF_F_ORDERTRADE(
                        TRADEID , ORDERNO   ,TRADECODE , MONEY        , OPERATEDEPARTNO , OPERATESTAFFNO , OPERATETIME
                    )VALUES(
                        v_seqNo , V_ORDERNO ,'05'      , V_TRADEMONEY , p_currDept      , p_currOper     , V_TODAY
                    );
                IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                    p_retCode := 'S094570313';
                    p_retMsg  := '记录订单台账失败,'|| SQLERRM;
                    ROLLBACK; RETURN;            
                END;
                --记录账单台账
                BEGIN
                    INSERT INTO TF_B_CHECK(
                        TRADEID , CHECKID   , TRADECODE , MONEY        , USEDMONEY        , LEFTMONEY        , OPERATESTAFFNO , OPERATETIME
                    )VALUES(
                        v_seqNo , V_CHECKID , '4'       , V_TRADEMONEY , V_CHECKUSEDMONEY , V_CHECKLEFTMONEY , p_currOper     , V_TODAY
                    );
                IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                    p_retCode := 'S094570314';
                    p_retMsg  := '记录账单台账失败,'|| SQLERRM;
                    ROLLBACK; RETURN;            
                END;
                IF V_ORDERLEFTMONEY <= 0 THEN
                    EXIT;
                END IF;
            END LOOP; --遍历账单结束
        ELSE --如果是呈批单订单，记录订单台账
            --生成流水号
            SP_GetSeq(seq => v_seqNo); 
                
            --记录订单台账
            BEGIN
                INSERT INTO TF_F_ORDERTRADE(
                    TRADEID , ORDERNO   ,TRADECODE , MONEY            , OPERATEDEPARTNO , OPERATESTAFFNO , OPERATETIME
                )VALUES(
                    v_seqNo , V_ORDERNO ,'05'      , V_ORDERLEFTMONEY , p_currDept      , p_currOper     , V_TODAY
                );
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                p_retCode := 'S094570313';
                p_retMsg  := '记录订单台账失败,'|| SQLERRM;
                ROLLBACK; RETURN;            
            END;        
        END IF;
        
        IF V_ORDERLEFTMONEY > 0 AND p_ISAPPROVE <> '1' THEN
                p_retCode := 'S094570315';
                p_retMsg := '账单金额不足' ;
                ROLLBACK;RETURN;            
        END IF;
        
    END LOOP;--遍历订单结束
    p_retCode := '0000000000';
    p_retMsg  := '成功';
    COMMIT; RETURN;    
END;

/
show errors    
    