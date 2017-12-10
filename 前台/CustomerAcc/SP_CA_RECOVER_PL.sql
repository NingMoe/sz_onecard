-- =============================================
-- AUTHOR:		LIUHE
-- CREATE DATE: 2011-07-07
-- DESCRIPTION:	�����˻��˻�Ĩ�ʴ洢����
-- =============================================
CREATE OR REPLACE PROCEDURE SP_CA_RECOVER
(
    P_ACCTID         CHAR,
    P_ID             CHAR,
    P_CANCELMONEY    INT,
    P_CARDNO         CHAR,
    P_SUPPLYID       VARCHAR,
    P_PREMONEY       INT,
    P_CURROPER       CHAR,
    P_CURRDEPT       CHAR,
    P_RETCODE        OUT CHAR,     -- RETURN CODE
    P_RETMSG         OUT VARCHAR2  -- RETURN MESSAGE

)
AS
    V_ACCTID          NUMBER;
    V_SEQ             CHAR(16);
    V_ACCT_BALANCE_ID NUMBER;
    V_TODAY           DATE := SYSDATE;
    V_EX              EXCEPTION;
BEGIN

    V_ACCTID := TO_NUMBER(P_ACCTID);

    -- 1) GET TRADE ID
    SP_GETSEQ(SEQ => V_SEQ);
    
    -- 2)д��̨������
    BEGIN
        INSERT INTO TF_B_TRADE        
            (TRADEID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CURRENTMONEY,PREMONEY, 
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)      
        SELECT         
            V_SEQ,'L2',P_CARDNO,T.ASN,T.CARDTYPECODE,-P_CANCELMONEY,P_PREMONEY,
            P_CURROPER,P_CURRDEPT,V_TODAY
         FROM TF_F_CARDREC T WHERE T.CARDNO = P_CARDNO;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S001002119';
              P_RETMSG  := 'д��ҵ��̨������ʧ��' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    
    --д��ר���˻�ҵ��̨��
    BEGIN
        INSERT INTO TF_B_TRADE_ACCOUNT        
            (TRADEID,ACCTID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CURRENTMONEY,PREMONEY, 
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)      
        SELECT         
            V_SEQ,V_ACCTID,'L2',P_CARDNO,T.ASN,T.CARDTYPECODE,-P_CANCELMONEY,P_PREMONEY,
            P_CURROPER,P_CURRDEPT,V_TODAY
         FROM TF_F_CARDREC T WHERE T.CARDNO = P_CARDNO;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S006002000';
              P_RETMSG  := 'д��ר���˻�ҵ��̨������ʧ��' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    
    -- 3)д���ֽ�̨�˱�
     BEGIN
        INSERT INTO TF_B_TRADEFEE
            (ID,TRADEID,TRADETYPECODE,CARDNO,PREMONEY,
        SUPPLYMONEY,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
            (P_ID,V_SEQ,'L2',P_CARDNO,P_PREMONEY,
            -P_CANCELMONEY,P_CURROPER,P_CURRDEPT,V_TODAY);

    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S001002114';
              P_RETMSG  := 'д���ֽ�̨������ʧ��' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 4) ����ԭ��ֵ̨�˼�¼
    BEGIN
        UPDATE TF_B_TRADE
        SET CANCELTAG = '1',
        CANCELTRADEID = V_SEQ
        WHERE ID = P_SUPPLYID;

        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S001009109';
              P_RETMSG  := '���³�ֵ̨�˼�¼ʧ��' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    
     BEGIN
        UPDATE TF_B_TRADE_ACCOUNT
        SET CANCELTAG = '1',
        CANCELTRADEID = V_SEQ
        WHERE ID = P_SUPPLYID;

        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S001009120';
              P_RETMSG  := '���³�ֵ̨�˼�¼ʧ��' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    
     -- 5)д��ͻ��˻���ʷ��
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
        WHERE ICCARD_NO = P_CARDNO;

    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S006001124';
              P_RETMSG  := 'д��ҵ��̨������ʧ��' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    
    
    -- 6)���¿ͻ��˻���
    BEGIN
        UPDATE  TF_F_CUST_ACCT
          SET  ACCT_BALANCE = ACCT_BALANCE - P_CANCELMONEY,
               REL_BALANCE = REL_BALANCE - P_CANCELMONEY,
               TOTAL_SUPPLY_MONEY = TOTAL_SUPPLY_MONEY - P_CANCELMONEY,
               TOTAL_SUPPLY_TIMES = TOTAL_SUPPLY_TIMES -1 
              WHERE  ACCT_ID = V_ACCTID;
          IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S006001123';
              P_RETMSG  := '���¿ͻ��˻���ʧ��' || SQLERRM;
             ROLLBACK; RETURN;
    END;
    
     -- 7)��������˱���
    BEGIN
          UPDATE  TF_F_ACCT_BALANCE
          SET  BALANCE = BALANCE - P_CANCELMONEY
          WHERE  ICCARD_NO = P_CARDNO AND ACCT_ID = V_ACCTID;
          
          IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S006001123';
              P_RETMSG  := '��������˱���ʧ��' || SQLERRM;
             ROLLBACK; RETURN;
    END;
    
    --��������˱���ֵ��¼��
    BEGIN
    		UPDATE TF_F_BALANCE_PAYIN
    		SET CANCEL_TAG = '1'
    		WHERE PAYIN_ID = P_SUPPLYID;
    		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
   			EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S006001125';
              P_RETMSG  := '��������˱���ֵ��¼��ʧ��' || SQLERRM;
             ROLLBACK; RETURN;
    END;
    
    /*-- 8)���¸����¼��
    BEGIN

        UPDATE   TF_F_PAYMENT 
		SET CANCEL_TAG = '1'
		WHERE PAYMENT_ID = P_SUPPLYID;
		
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S006001121';
              P_RETMSG  := '���¸����¼��ʧ��' || SQLERRM;
             ROLLBACK; RETURN;
    END;

    -- 9)���������Դ��¼��
    BEGIN
        UPDATE   BALANCE_SOURCE 
		SET CANCEL_TAG = '1'
		WHERE OPERATE_INCOME_ID = P_SUPPLYID;
        
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S006001122';
              P_RETMSG  := '���������Դ��¼��ʧ��' || SQLERRM;
             ROLLBACK; RETURN;
    END;*/

  P_RETCODE := '0000000000';
  P_RETMSG  := '';
  COMMIT; RETURN;
END;



/
SHOW ERROR
