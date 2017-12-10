-- =============================================
-- AUTHOR:		LIUHE
-- CREATE DATE: 2011-06-27
-- DESCRIPTION:	联机账户重置客户账户密码存储过程
-- =============================================
CREATE OR REPLACE PROCEDURE SP_CA_RESETPASSWORD
(
    P_SESSIONID CHAR,   
    P_CARDNO    CHAR,      --卡号
    P_PWD       VARCHAR2,  --初始密码
    P_CURROPER  CHAR,      --操作员工
    P_CURRDEPT  CHAR,      --操作员工部门
    P_RETCODE    OUT CHAR,     -- 错误编码
    P_RETMSG     OUT VARCHAR2  -- 错误信息

)
AS
    V_TODAY         DATE := SYSDATE;
    V_TRADEID      CHAR(16);
    V_EX           EXCEPTION;
BEGIN
    FOR V_C IN (SELECT * FROM TMP_COMMON WHERE F0 = P_SESSIONID) 
      LOOP
          -- 1)写入客户账户历史表
          BEGIN
              INSERT INTO TF_F_CUST_ACCT_HIS
                    (
                      ICCARD_NO,                  ACCT_TYPE_NO,         ACCT_ID,            CUST_ID,                 ACCT_NAME,               STATE, 
                      STATE_DATE,                 CREATE_DATE,          EFF_DATE,           ACCT_PAYMENT_TYPE,       ACCT_BALANCE, 
                      REL_BALANCE,                CUST_PASSWORD,      TOTAL_CONSUME_TIMES,     TOTAL_SUPPLY_TIMES,
                      TOTAL_CONSUME_MONEY,        TOTAL_SUPPLY_MONEY,   LAST_CONSUME_TIME,  LAST_SUPPLY_TIME,        LIMIT_DAYAMOUNT,
                      AMOUNT_TODAY,               LIMIT_EACHTIME,       CODEERRORTIMES,     BAK_DATE
                    )
              SELECT
                      ICCARD_NO,                  ACCT_TYPE_NO,         ACCT_ID,            CUST_ID,                 ACCT_NAME,               STATE, 
                      STATE_DATE,                 CREATE_DATE,          EFF_DATE,           ACCT_PAYMENT_TYPE,       ACCT_BALANCE, 
                      REL_BALANCE,                CUST_PASSWORD,      TOTAL_CONSUME_TIMES,     TOTAL_SUPPLY_TIMES,
                      TOTAL_CONSUME_MONEY,        TOTAL_SUPPLY_MONEY,   LAST_CONSUME_TIME,  LAST_SUPPLY_TIME,        LIMIT_DAYAMOUNT,
                      AMOUNT_TODAY,               LIMIT_EACHTIME,       CODEERRORTIMES,     V_TODAY
              FROM TF_F_CUST_ACCT
              WHERE ACCT_ID = V_C.F1;
          EXCEPTION
                WHEN OTHERS THEN
                    P_RETCODE := 'S006001124';
                    P_RETMSG  := '写入业务台账主表失败' || SQLERRM;
                    ROLLBACK; RETURN;
          END;

          -- 2) 更新客户账户表
          BEGIN
              UPDATE   TF_F_CUST_ACCT
                  SET  CUST_PASSWORD = P_PWD
                  WHERE ACCT_ID = V_C.F1;

          IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
                WHEN OTHERS THEN
                    P_RETCODE := 'S001090502';
                    P_RETMSG  := '更新客户账户表失败' || SQLERRM;
                    ROLLBACK; RETURN;
          END;

          -- 3) 记录台账
          BEGIN
          SP_GETSEQ(SEQ => V_TRADEID);
              INSERT INTO TF_B_TRADE
                  (TRADEID,TRADETYPECODE,CARDNO,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
              VALUES
                  (V_TRADEID,'8J',P_CARDNO,P_CURROPER,P_CURRDEPT,V_TODAY);

          EXCEPTION
                WHEN OTHERS THEN
                    P_RETCODE := 'S004111011';
                    P_RETMSG  := '写入台账主表失败' || SQLERRM;
                    ROLLBACK; RETURN;
          END;      
          
          BEGIN
         
              INSERT INTO TF_B_TRADE_ACCOUNT
                  (TRADEID,ACCTID,TRADETYPECODE,CARDNO,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
              VALUES
                  (V_TRADEID,V_C.F1,'8J',P_CARDNO,P_CURROPER,P_CURRDEPT,V_TODAY);

          EXCEPTION
                WHEN OTHERS THEN
                    P_RETCODE := 'S006002000';
                    P_RETMSG  := '写入专有账户台账主表失败' || SQLERRM;
                    ROLLBACK; RETURN;
          END;     
      
      END LOOP;  

  P_RETCODE := '0000000000';
  P_RETMSG  := '';
  COMMIT; RETURN;
  
END;



/
SHOW ERROR
