-- =============================================
-- AUTHOR:		LIUHE
-- CREATE DATE: 2011-06-23
-- DESCRIPTION:	�����˻�����ⶳ�洢����
-- =============================================
CREATE OR REPLACE PROCEDURE SP_CA_BLOCK
(
    P_CARDNO                CHAR,         --����
    P_TRADETYPECODE         CHAR,         --ҵ�����ͱ���
    P_CURROPER              CHAR,         --��ǰ������
    P_CURRDEPT              CHAR,         --��ǰ�����߲���
    P_RETCODE               OUT CHAR,     --�������
    P_RETMSG                OUT VARCHAR2  --������Ϣ
)
AS
    V_SEQ             CHAR(16);    -- ҵ����ˮ��
    V_TODAY           DATE := SYSDATE;
    V_EX              EXCEPTION;
    V_COUNT           INT; --��Ҫ��ʧ���˻�����
    V_OLDACCSTATE     CHAR;
    V_NEWACCSTATE     CHAR;
BEGIN

    -- 1)��ʼ��״ֵ̬
     IF P_TRADETYPECODE = '8E' THEN V_OLDACCSTATE := 'A'; V_NEWACCSTATE:='F';

     ELSIF P_TRADETYPECODE = '8F'  THEN V_OLDACCSTATE := 'F'; V_NEWACCSTATE:='A';
     
     ELSE P_RETCODE := 'A099001100'; P_RETMSG  := '�������ʹ���' ;
          RETURN;

     END IF;


    -- 2)д��ͻ��˻���ʷ��
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
              P_RETMSG  := 'д��ͻ��˻���ʷ��ʧ��' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    
    SELECT COUNT(*) INTO V_COUNT FROM TF_F_CUST_ACCT WHERE ICCARD_NO = P_CARDNO AND STATE = V_OLDACCSTATE;
    
    -- 3)���¿ͻ��˻���״̬
    BEGIN
          UPDATE  TF_F_CUST_ACCT
          SET  STATE = V_NEWACCSTATE
              WHERE  ICCARD_NO = P_CARDNO
              AND STATE=V_OLDACCSTATE;

              
          IF  SQL%ROWCOUNT != V_COUNT THEN RAISE V_EX; END IF;

    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'A099001101';
              P_RETMSG  := '���¿ͻ��˻���״̬ʧ��' || SQLERRM;
              ROLLBACK; RETURN;

    END;

    -- 4)��������˱���״̬
    BEGIN
          UPDATE  TF_F_ACCT_BALANCE
          SET  STATE = V_NEWACCSTATE
              WHERE  ICCARD_NO = P_CARDNO
              AND STATE=V_OLDACCSTATE;

          IF  SQL%ROWCOUNT != V_COUNT THEN RAISE V_EX; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'A099001102';
              P_RETMSG  := '�����˻����ʧ��' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 5)��¼ҵ����̨��
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
              P_RETMSG  := '��¼ҵ��̨��ʧ��' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    
  P_RETCODE := '0000000000';
  P_RETMSG  := '';
  COMMIT; RETURN;
END;

/
SHOW ERROR
