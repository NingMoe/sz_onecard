CREATE OR REPLACE PROCEDURE SP_CA_SPEADJUSTACCINPUT
(
  P_ID          CHAR, --记录流水号
  P_CARDNO      CHAR, --IC卡号
  P_CARDUSER    VARCHAR2, --持卡人用户名
  P_USERPHONE   VARCHAR2, --持卡人电话
  P_REFUNDMONEY INT, --退款金额
  P_BROKERAGE   INT, --佣金金额
  P_ADJACCRESON CHAR, --调帐原因
  P_REMARK      VARCHAR2, --交易说明
  P_CURROPER    CHAR, --操作员工工号
  P_CURRDEPT    CHAR, --操作员工所在部门
  P_RETCODE     OUT CHAR, --错误代码
  P_RETMSG      OUT VARCHAR2 --错误消息
) AS
  V_CURRDATE DATE := SYSDATE;
  V_SEQNO CHAR(16);
  V_EX EXCEPTION;

BEGIN

  --1) get the sequence number
  SP_GETSEQ(SEQ => V_SEQNO);

  --2) add TF_B_SPEADJUSTACC info
  BEGIN
    INSERT INTO TF_B_ACCT_SPEADJUSTACC
      (TRADEID,
       ID,
       ICCARD_NO,
       ACCT_TYPE_NO,
       ORADE_NO,
       TRADETIME,
       TRADEMONEY,
       REFUNDMENT,
       BROKERAGE,
       CUSTPHONE,
       CUSTNAME,
       CALLINGNO,
       CORPNO,
       DEPARTNO,
       BALUNITNO,
       REASONCODE,
       REMARK,
       STATECODE,
       STAFFNO,
       OPERATETIME,
       OPERATEUSER)
      SELECT V_SEQNO,
             ID,
             O.ICCARD_NO,
             O.ACCT_TYPE_NO,
             TO_CHAR(O.ORDER_NO) ORADE_NO,
             O.TRADE_DATE,
             O.TRADE_CHARGE TRADE_CHARGE,
             P_REFUNDMONEY,
             P_BROKERAGE,
             P_USERPHONE,
             P_CARDUSER,
             B.CALLINGNO,
             B.CORPNO,
             B.DEPARTNO,
             O.BALUNITNO,
             P_ADJACCRESON,
             P_REMARK,
             '0',
             P_CURROPER,
             V_CURRDATE,
             '0'
        FROM TF_F_ACCT_ITEM_OWE O, TF_TRADE_BALUNIT B
       WHERE (O.BALUNITNO = B.BALUNITNO)
         AND O.ID = P_ID;
  
    IF SQL%ROWCOUNT != 1 THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S009110002';
      P_RETMSG := '';
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
