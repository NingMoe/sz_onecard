-- =============================================
-- AUTHOR:		LIUHE
-- CREATE DATE: 2011-06-24
-- DESCRIPTION:	联机账户修改客户账户密码存储过程
-- =============================================
CREATE OR REPLACE PROCEDURE SP_CA_CHANGEACCPASS
(
  P_SESSIONID CHAR,
  P_CARDNO    CHAR,
  P_OLDPASSWD CHAR,
  P_NEWPASSWD CHAR,
  P_CURROPER  CHAR,
  P_CURRDEPT  CHAR,
  P_RETCODE   OUT CHAR, -- RETURN CODE
  P_RETMSG    OUT VARCHAR2 -- RETURN MESSAGE
) AS
  V_ACCT_ID NUMBER;
  V_CODEERRORTIMES INTEGER;
  V_TODAY DATE := SYSDATE;
  V_DBPASSWD CHAR(32);
  V_TRADEID CHAR(16);
  V_EX EXCEPTION;
BEGIN
  
   for v_c in (select * from tmp_common tmp where tmp.F0 = P_SESSIONID)
     loop
        -- 1) 验证旧密码
        SELECT CUST_PASSWORD, ACCT_ID, CODEERRORTIMES
          INTO V_DBPASSWD, V_ACCT_ID, V_CODEERRORTIMES
          FROM TF_F_CUST_ACCT
         WHERE ACCT_ID = v_c.f1;

        IF V_DBPASSWD != P_OLDPASSWD THEN
          SP_CA_PWDERRORTIMES(V_ACCT_ID,V_CODEERRORTIMES,P_CURROPER,P_CURRDEPT,P_RETCODE,P_RETMSG);
          P_RETCODE := 'S001090501';
          P_RETMSG := '原密码错误';
          RETURN;
        END IF;

        -- 2)写入客户账户历史表
        BEGIN
          INSERT INTO TF_F_CUST_ACCT_HIS
            (ICCARD_NO,
             ACCT_ID,
             ACCT_TYPE_NO,
             CUST_ID,
             ACCT_NAME,
             STATE,
             STATE_DATE,
             CREATE_DATE,
             EFF_DATE,
             ACCT_PAYMENT_TYPE,
             ACCT_BALANCE,
             REL_BALANCE,
             CUST_PASSWORD,
             TOTAL_CONSUME_TIMES,
             TOTAL_SUPPLY_TIMES,
             TOTAL_CONSUME_MONEY,
             TOTAL_SUPPLY_MONEY,
             LAST_CONSUME_TIME,
             LAST_SUPPLY_TIME,
             LIMIT_DAYAMOUNT,
             AMOUNT_TODAY,
             LIMIT_EACHTIME,
             CODEERRORTIMES,
             BAK_DATE)
            SELECT ICCARD_NO,
                   ACCT_ID,
                   ACCT_TYPE_NO,
                   CUST_ID,
                   ACCT_NAME,
                   STATE,
                   STATE_DATE,
                   CREATE_DATE,
                   EFF_DATE,
                   ACCT_PAYMENT_TYPE,
                   ACCT_BALANCE,
                   REL_BALANCE,
                   CUST_PASSWORD,
                   TOTAL_CONSUME_TIMES,
                   TOTAL_SUPPLY_TIMES,
                   TOTAL_CONSUME_MONEY,
                   TOTAL_SUPPLY_MONEY,
                   LAST_CONSUME_TIME,
                   LAST_SUPPLY_TIME,
                   LIMIT_DAYAMOUNT,
                   AMOUNT_TODAY,
                   LIMIT_EACHTIME,
                   CODEERRORTIMES,
                   V_TODAY
              FROM TF_F_CUST_ACCT
             WHERE ACCT_ID = v_c.f1;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006001124';
            P_RETMSG := '写入客户账户历史表失败' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        -- 3) 更新客户账户表
        BEGIN
          UPDATE TF_F_CUST_ACCT
             SET CUST_PASSWORD = P_NEWPASSWD
             ,CODEERRORTIMES = 0
           WHERE ACCT_ID = v_c.f1;
        
          IF SQL%ROWCOUNT != 1 THEN
            RAISE V_EX;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001090502';
            P_RETMSG := '更新客户账户表失败' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        -- 4) 记录台账
        BEGIN
          SP_GETSEQ(SEQ => V_TRADEID);
          INSERT INTO TF_B_TRADE
            (TRADEID,
             TRADETYPECODE,
             CARDNO,
             OPERATESTAFFNO,
             OPERATEDEPARTID,
             OPERATETIME)
          VALUES
            (V_TRADEID, '8I', P_CARDNO, P_CURROPER, P_CURRDEPT, V_TODAY);
        
          EXCEPTION
            WHEN OTHERS THEN
              P_RETCODE := 'S004111011';
              P_RETMSG := 'FAIL TO LOG THE OPERATION' || SQLERRM;
              ROLLBACK;
              RETURN;
        END;
        
        BEGIN
         
          INSERT INTO TF_B_TRADE_ACCOUNT
            (TRADEID,
             ACCTID,
             TRADETYPECODE,
             CARDNO,
             OPERATESTAFFNO,
             OPERATEDEPARTID,
             OPERATETIME)
          VALUES
            (V_TRADEID,v_c.f1, '8I', P_CARDNO, P_CURROPER, P_CURRDEPT, V_TODAY);
        
          EXCEPTION
            WHEN OTHERS THEN
              P_RETCODE := 'S006002000';
              P_RETMSG := 'FAIL TO LOG THE OPERATION' || SQLERRM;
              ROLLBACK;
              RETURN;
            
        END;
     end loop;
 
  P_RETCODE := '0000000000';
  P_RETMSG := '';
  COMMIT;
  RETURN;
END;


/
SHOW ERROR
