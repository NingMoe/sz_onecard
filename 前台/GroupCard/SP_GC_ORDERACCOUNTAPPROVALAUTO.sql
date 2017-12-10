CREATE OR REPLACE PROCEDURE SP_GC_ORDERACCOUNTAPPROVALAUTO
(
    P_CHECKID           CHAR    ,  --账单号
    p_MONEY             CHAR    ,  --金额
    p_ACCOUNTNAME       CHAR    ,  --户名
    p_ACCOUNTNUMBER     CHAR    ,  --转出银行帐号
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS 
    v_seqNo              CHAR(16); --业务流水号
    V_ORDERNO            CHAR(16);
    V_GROUPNAME          VARCHAR2(100);--订单的单位名称
    V_NAME               VARCHAR2(50);--订单的联系人 
    V_NUM                INT;
    V_NUM2               INT;
    V_NUM3               INT;
    V_NUM4               INT;
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;

BEGIN
     --查询是否有符合匹配条件的订单
       
          SELECT COUNT(*) INTO V_NUM FROM TF_F_ORDERFORM T WHERE T.ORDERSTATE='01' AND T.ORDERNO NOT IN (SELECT ORDERNO FROM TF_F_ORDERCHECKRELATION )
          AND T.TOTALMONEY =to_number(p_MONEY) * 100  AND (T.GROUPNAME = p_ACCOUNTNAME OR T.NAME =p_ACCOUNTNAME  ) AND T.USETAG = '1';
          
          IF V_NUM!= 1 THEN
                p_retCode := 'A094570401';
                p_retMsg  := '户名为'||p_ACCOUNTNAME||'的账单没有找到符合匹配审核条件的订单,未进行自动审核';
            RETURN;
          END IF;
          IF V_NUM = 1 THEN
            
            SELECT T.ORDERNO INTO V_ORDERNO FROM TF_F_ORDERFORM T WHERE T.ORDERSTATE='01' AND T.ORDERNO NOT IN (SELECT ORDERNO FROM TF_F_ORDERCHECKRELATION )
            AND T.TOTALMONEY =to_number(p_MONEY) * 100  AND (T.GROUPNAME = p_ACCOUNTNAME OR T.NAME =p_ACCOUNTNAME  ) AND T.USETAG = '1';
            
            
            SELECT COUNT(*) INTO V_NUM3 FROM TF_F_PAYTYPE K WHERE K.ORDERNO =V_ORDERNO;
            SELECT COUNT(*) INTO V_NUM4 FROM TF_F_PAYTYPE K WHERE K.ORDERNO =V_ORDERNO AND K.PAYTYPECODE='4';
            IF V_NUM3= 1 AND V_NUM4=1 THEN
                p_retCode := 'A094570402';
                p_retMsg  := '户名为'||p_ACCOUNTNAME||'的账单没有找到符合匹配审核条件的订单,未进行自动审核';
            RETURN;
            END IF;
            --更新订单表
            BEGIN
                UPDATE TF_F_ORDERFORM
               SET     ORDERSTATE = '02',--审核通过
                       FINANCEAPPROVERNO = P_CURROPER,
                       FINANCEAPPROVERTIME = V_TODAY,
                       FINANCEREMARK = NULL,
                       UPDATEDEPARTNO = P_CURRDEPT,
                       UPDATESTAFFNO = P_CURROPER,
                       UPDATETIME = V_TODAY
              WHERE  ORDERNO = V_ORDERNO;    
              IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                p_retCode := 'S094570401';
                p_retMsg  := '到账导入自动审核时更新订单表失败,订单号为'||V_ORDERNO|| SQLERRM;
                ROLLBACK; RETURN;            
             END;
            --更新账单表
            BEGIN
                UPDATE TF_F_CHECK 
                SET    CHECKSTATE = '3', --完成使用
                       USEDMONEY = to_number(p_MONEY) * 100, --已用金额等于账单金额
                       LEFTMONEY = 0, --剩余金额为0
                       UPDATEDEPARTNO = p_currDept,
                       UPDATESTAFFNO = p_currOper,
                       UPDATETIME = V_TODAY
                WHERE  CHECKID = P_CHECKID;
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                p_retCode := 'S094570402';
                p_retMsg  := '到账导入自动审核时更新账单表失败,账单号为'||P_CHECKID|| SQLERRM;
               ROLLBACK;  RETURN;            
            END;
            --获取流水号
             SP_GetSeq(seq => v_seqNo); 
            --记录订单与账单关联关系表
              BEGIN
                  INSERT INTO TF_F_ORDERCHECKRELATION(
                      ORDERNO   , CHECKID   , TRADEID , MONEY            , UPDATESTAFFNO , UPDATETIME
                  )VALUES(
                      V_ORDERNO , P_CHECKID , v_seqNo , to_number(p_MONEY) * 100 , p_currOper    , V_TODAY
                  );
              IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
              EXCEPTION WHEN OTHERS THEN
                  p_retCode := 'S094570403';
                  p_retMsg  := '到账导入自动审核时记录订单与账单关联关系表失败,订单号为'||V_ORDERNO|| SQLERRM;
                  ROLLBACK; RETURN;            
              END;
              
             BEGIN
                SELECT COUNT(*) INTO V_NUM2 FROM TF_F_COMBUYCARDREG T WHERE T.REMARK = V_ORDERNO;
                
                
                IF V_NUM2>0 THEN 
                --更新单位购卡记录表
                BEGIN
                  UPDATE TF_F_COMBUYCARDREG 
                  SET OUTBANK = p_ACCOUNTNUMBER,--转出银行帐号
                      OUTACCT = p_ACCOUNTNAME --转出账户户名
                  WHERE REMARK = V_ORDERNO;
                   IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                  EXCEPTION WHEN OTHERS THEN
                      p_retCode := 'S094570404';
                      p_retMsg  := '到账导入自动审核时更新单位购卡记录表失败,订单号为'||V_ORDERNO|| SQLERRM;
                     ROLLBACK;  RETURN; 
                END;
                END IF;
                
              END;
              
              --记录订单台账  新增TRADECODE '18'为到账导入自动审核
              BEGIN
                  INSERT INTO TF_F_ORDERTRADE(
                      TRADEID , ORDERNO   ,TRADECODE  , MONEY                    , OPERATEDEPARTNO , OPERATESTAFFNO , OPERATETIME
                  )VALUES(
                      v_seqNo , V_ORDERNO ,'18'      , to_number(p_MONEY) * 100  , p_currDept      , p_currOper     , V_TODAY
                  );
              IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
              EXCEPTION WHEN OTHERS THEN
                  p_retCode := 'S094570405';
                  p_retMsg  := '到账导入自动审核时记录订单台账失败'|| SQLERRM;
                  ROLLBACK; RETURN;            
              END;
              --记录账单台账
              BEGIN
                  INSERT INTO TF_B_CHECK(
                      TRADEID , CHECKID   , TRADECODE , MONEY                    , USEDMONEY                , LEFTMONEY        , OPERATESTAFFNO , OPERATETIME
                  )VALUES(
                      v_seqNo , P_CHECKID , '4'      , to_number(p_MONEY) * 100  ,to_number(p_MONEY) * 100    , 0                , p_currOper     , V_TODAY
                  );
              IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
              EXCEPTION WHEN OTHERS THEN
                  p_retCode := 'S094570406';
                  p_retMsg  := '到账导入自动审核时记录账单台账失败'|| SQLERRM;
                  ROLLBACK; RETURN;            
              END;
          
        END IF;
         
        

    p_retCode := '0000000000';
    p_retMsg  := '成功';
    COMMIT; RETURN;    
END;

 
/
show errors