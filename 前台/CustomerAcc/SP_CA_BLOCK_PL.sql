-- =============================================
-- AUTHOR:		LIUHE
-- CREATE DATE: 2011-06-23
-- DESCRIPTION:	联机账户冻结解冻存储过程
-- =============================================
CREATE OR REPLACE PROCEDURE SP_CA_BLOCK
(
    P_CARDNO                CHAR,         --卡号
    P_TRADETYPECODE         CHAR,         --业务类型编码
    P_CURROPER              CHAR,         --当前操作者
    P_CURRDEPT              CHAR,         --当前操作者部门
    P_RETCODE               OUT CHAR,     --错误编码
    P_RETMSG                OUT VARCHAR2  --错误信息
)
AS
    V_SEQ             CHAR(16);    -- 业务流水号
    V_TODAY           DATE := SYSDATE;
    V_EX              EXCEPTION;
    V_COUNT           INT; --需要挂失的账户数量
    V_OLDACCSTATE     CHAR;
    V_NEWACCSTATE     CHAR;
BEGIN

    -- 1)初始化状态值
     IF P_TRADETYPECODE = '8E' THEN V_OLDACCSTATE := 'A'; V_NEWACCSTATE:='F';

     ELSIF P_TRADETYPECODE = '8F'  THEN V_OLDACCSTATE := 'F'; V_NEWACCSTATE:='A';
     
     ELSE P_RETCODE := 'A099001100'; P_RETMSG  := '操作类型错误' ;
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
        WHERE ICCARD_NO = P_CARDNO
        AND STATE=V_OLDACCSTATE;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S006001124';
              P_RETMSG  := '写入客户账户历史表失败' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    
    SELECT COUNT(*) INTO V_COUNT FROM TF_F_CUST_ACCT WHERE ICCARD_NO = P_CARDNO AND STATE = V_OLDACCSTATE;
    
    -- 3)更新客户账户表状态
    BEGIN
          UPDATE  TF_F_CUST_ACCT
          SET  STATE = V_NEWACCSTATE
              WHERE  ICCARD_NO = P_CARDNO
              AND STATE=V_OLDACCSTATE;

              
          IF  SQL%ROWCOUNT != V_COUNT THEN RAISE V_EX; END IF;

    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'A099001101';
              P_RETMSG  := '更新客户账户表状态失败' || SQLERRM;
              ROLLBACK; RETURN;

    END;

    -- 4)更新余额账本表状态
    BEGIN
          UPDATE  TF_F_ACCT_BALANCE
          SET  STATE = V_NEWACCSTATE
              WHERE  ICCARD_NO = P_CARDNO
              AND STATE=V_OLDACCSTATE;

          IF  SQL%ROWCOUNT != V_COUNT THEN RAISE V_EX; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'A099001102';
              P_RETMSG  := '更新账户表表失败' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 5)记录业务主台帐
    BEGIN
    SP_GETSEQ(SEQ => V_SEQ);
    
          INSERT INTO TF_B_TRADE
                  (TRADEID, CARDNO,TRADETYPECODE,
                ASN, CARDTYPECODE,
                OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
          SELECT    V_SEQ,CARDNO,P_TRADETYPECODE,
                  ASN,CARDTYPECODE,
                  P_CURROPER,P_CURRDEPT, V_TODAY
          FROM TF_F_CARDREC
          WHERE CARDNO = P_CARDNO;

    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'A099001103';
              P_RETMSG  := '记录业务台账失败' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    
  P_RETCODE := '0000000000';
  P_RETMSG  := '';
  COMMIT; RETURN;
END;

/
SHOW ERROR
