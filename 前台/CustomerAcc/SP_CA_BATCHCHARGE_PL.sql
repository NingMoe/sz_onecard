-- =============================================
-- AUTHOR:		董翔
-- CREATE DATE: 2011-07-6
-- DESCRIPTION:	联机账户批量充值
-- =============================================
CREATE OR REPLACE PROCEDURE SP_CA_BATCHCHARGE  
(                       
  P_SESSIONID VARCHAR2, -- Session ID
  P_GroupCode char, --集团客户号
  P_CURROPER  CHAR, -- Current Operator
  P_CURRDEPT  CHAR, -- Current Operator's Department
  P_RETCODE   OUT CHAR, -- Return Code
  P_RETMSG    OUT VARCHAR2 -- Return Message
) AS
  V_TATALMONEY INT; -- Total money of charging
  V_AMNT INT; -- Amount of cards

  V_TODAY DATE := SYSDATE;
  V_EX EXCEPTION;
  V_SEQNO CHAR(16);

BEGIN
  -- 1) Check the v_amount and total money of charging
  SELECT SUM(CHARGEAMOUNT), COUNT(*)
    INTO V_TATALMONEY, V_AMNT
    FROM TMP_CA_BATCHCHARGEFILE
   WHERE SESSIONID = P_SESSIONID;

  IF V_AMNT <= 0 THEN
    P_RETCODE := 'A004P04B01';
    P_RETMSG := '没有任何充值数据需要处理';
    RETURN;
  END IF;

  SP_GETSEQ(SEQ => V_SEQNO);

  -- 2) New a tracing record for this batch charging operation
  BEGIN
    INSERT INTO TF_F_SUPPLYSUM
      (ID,
       CORPNO,
       SUPPLYMONEY,
       AMOUNT,
       SUPPLYSTAFFNO,
       SUPPLYDEPARTNO,
       SUPPLYTIME,
       STATECODE)
    VALUES
      (V_SEQNO,P_GroupCode, V_TATALMONEY, V_AMNT, P_CURROPER, P_CURRDEPT, V_TODAY, '0');
  
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006012010';
      P_RETMSG := '新增联机帐户批量充值总量台帐失败,' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 3) Create the charging detail
  BEGIN
    INSERT INTO TF_F_SUPPLY
      (ID,
       CARDNO,
       ACCT_TYPE_NO,
       SUPPLYMONEY,
       STATECODE,
       OPERATESTAFFNO,
       OPERATEDEPARTID,
       OPERATETIME,
       RSRV1)
      SELECT V_SEQNO,
             CARDNO,
             TMP_CA_BATCHCHARGEFILE.ACCT_ID,
             CHARGEAMOUNT,
             '0',
             P_CURROPER,
             P_CURRDEPT,
             V_TODAY,
             P_GroupCode
        FROM TMP_CA_BATCHCHARGEFILE
       INNER JOIN TF_F_CUST_ACCT
          ON TMP_CA_BATCHCHARGEFILE.CARDNO = TF_F_CUST_ACCT.ICCARD_NO
       WHERE SESSIONID = P_SESSIONID;
  
    IF SQL%ROWCOUNT != V_AMNT THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006012011';
      P_RETMSG := '新增联机帐户批量充值明细台帐失败,' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  P_RETCODE := '0000000000';
  P_RETMSG := '';
  COMMIT;
  RETURN;
END;
/
SHOW ERROR