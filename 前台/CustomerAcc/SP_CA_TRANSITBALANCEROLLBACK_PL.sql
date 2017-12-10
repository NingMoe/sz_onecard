CREATE OR REPLACE PROCEDURE SP_CA_TRANSITBALANCEROLLBACK
(
  P_OACCT_ID     NUMBER, --ת�����ʺ�
  P_IACCT_ID     NUMBER, --ת�뿨�ʺ�
  P_TRADE_ID     CHAR, --̨�˼�¼��
  P_TRANSITMONEY CHAR, --ת�˽��
  P_ID           CHAR, --̨�˼�¼��ˮ��
  P_CURROPER     CHAR, --��ǰ������
  P_CURRDEPT     CHAR, --��ǰ�����߲���
  P_RETCODE      OUT CHAR, --�������
  P_RETMSG       OUT VARCHAR2 --������Ϣ
) AS
  V_OCARDNO CHAR(16);
  V_ICARDNO CHAR(16);
  V_PAYMENT_ID varchar(16);
  V_ACCT_BALANCE_ID INT;
  V_PREMONEY INT;
  V_SEQ CHAR(16);
  V_TODAY DATE := SYSDATE;
  V_EX EXCEPTION;
BEGIN


  --0)У��ת�뿨���
  BEGIN
  	SELECT  REL_BALANCE
  	INTO V_PREMONEY
  	FROM TF_F_CUST_ACCT
  	WHERE ACCT_ID = P_IACCT_ID;
  	
  	IF V_PREMONEY < P_TRANSITMONEY THEN 
  		RAISE V_EX;
    END IF;
	  EXCEPTION
	    WHEN OTHERS THEN
	      P_RETCODE := 'S006001135';
	      P_RETMSG := 'ת�뿨����,�޷�����' || SQLERRM;
	      ROLLBACK;
	      RETURN;
  END;



  -- 1)д��ת�뿨�ͻ��˻���ʷ��
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
       WHERE ACCT_ID = P_IACCT_ID;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001124';
      P_RETMSG := 'д��ͻ��˻���ʷ����ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 2)����ת�뿨�ͻ��˻���
  BEGIN
  
    UPDATE TF_F_CUST_ACCT
       SET ACCT_BALANCE       = ACCT_BALANCE - P_TRANSITMONEY,
           REL_BALANCE        = REL_BALANCE - P_TRANSITMONEY,
           TOTAL_SUPPLY_MONEY = TOTAL_SUPPLY_MONEY - P_TRANSITMONEY,
           TOTAL_SUPPLY_TIMES = TOTAL_SUPPLY_TIMES - 1
     WHERE ACCT_ID = P_IACCT_ID;
    IF SQL%ROWCOUNT != 1 THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001123';
      P_RETMSG := '���¿ͻ��˻���ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 3)����ת�뿨����˱���
  BEGIN
    UPDATE TF_F_ACCT_BALANCE
       SET BALANCE = BALANCE - P_TRANSITMONEY
     WHERE ACCT_ID = P_IACCT_ID;
  
    IF SQL%ROWCOUNT != 1 THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001133';
      P_RETMSG := '��������˱���ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

 -- 4)����ת�뿨�����¼��
  BEGIN
  	SELECT ICCARD_NO
      INTO V_ICARDNO
      FROM TF_F_CUST_ACCT
     WHERE ACCT_ID = P_IACCT_ID;
  	
		SELECT ID INTO V_PAYMENT_ID
	  FROM  TF_B_TRADE
	  WHERE TRADEID = P_TRADE_ID 
	  AND CARDNO = V_ICARDNO;
    
    UPDATE TF_F_BALANCE_PAYIN SET
     CANCEL_TAG = '1'
    WHERE PAYIN_ID = V_PAYMENT_ID;
    
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001125';
      P_RETMSG := '��������˱���ֵ��¼ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  --6)����ת��ת����ԭ̨������
  BEGIN
  
    UPDATE TF_B_TRADE
       SET CANCELTAG = '1'
     WHERE TRADETYPECODE = '8T'
       AND TRADEID = P_TRADE_ID
       AND CANCELTAG = '0';
       
     IF  SQL%ROWCOUNT != 2 THEN RAISE V_EX; END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001113';
      P_RETMSG := 'д��ҵ��̨������ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;
  
  --����ת�뿨ר���˻�ҵ��̨�˱�  ���ӣ�����
  BEGIN
  
    UPDATE TF_B_TRADE_ACCOUNT
       SET CANCELTAG = '1'
     WHERE TRADETYPECODE = '8T'
       AND TRADEID = P_TRADE_ID
       AND CANCELTAG = '0';
       
     IF  SQL%ROWCOUNT != 2 THEN RAISE V_EX; END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001114';
      P_RETMSG := 'д��ר���˻�ҵ��̨������ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 7)д��ת�뿨̨������
  BEGIN
    SP_GETSEQ(SEQ => V_SEQ);
  
    

    INSERT INTO TF_B_TRADE
      (TRADEID,
       ID,
       TRADETYPECODE,
       CARDNO,
       ASN,
       CARDTYPECODE,
       CURRENTMONEY,
       PREMONEY,
       OPERATESTAFFNO,
       OPERATEDEPARTID,
       OPERATETIME)
      SELECT V_SEQ,
             P_ID,
             'L1',
             V_ICARDNO,
             T.ASN,
             T.CARDTYPECODE,
             -P_TRANSITMONEY,
             V_PREMONEY,
             P_CURROPER,
             P_CURRDEPT,
             V_TODAY
        FROM TF_F_CARDREC T
       WHERE T.CARDNO = V_ICARDNO;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S001002119';
      P_RETMSG := 'д��ҵ��̨������ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;
  
  BEGIN
      INSERT INTO Tf_b_Trade_Account
        (TRADEID,
         ACCTID,
         ID,
         TRADETYPECODE,
         CARDNO,
         ASN,
         CARDTYPECODE,
         CURRENTMONEY,
         PREMONEY,
         OPERATESTAFFNO,
         OPERATEDEPARTID,
         OPERATETIME)
        SELECT V_SEQ,
               P_IACCT_ID,
               P_ID,
               'L1',
               V_ICARDNO,
               T.ASN,
               T.CARDTYPECODE,
               -P_TRANSITMONEY,
               V_PREMONEY,
               P_CURROPER,
               P_CURRDEPT,
               V_TODAY
          FROM TF_F_CARDREC T
         WHERE T.CARDNO = V_ICARDNO;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S001002120';
        P_RETMSG := 'д��ר���˻�ҵ��̨������ʧ��' || SQLERRM;
        ROLLBACK;
        RETURN;
  END;

  -- 8)д��ת����̨������

  BEGIN
    SELECT REL_BALANCE
      INTO V_PREMONEY
      FROM TF_F_CUST_ACCT
     WHERE ACCT_ID = P_OACCT_ID;
  
    SELECT ICCARD_NO
      INTO V_OCARDNO
      FROM TF_F_CUST_ACCT
     WHERE ACCT_ID = P_OACCT_ID;
  
    INSERT INTO TF_B_TRADE
      (TRADEID,
       ID,
       TRADETYPECODE,
       CARDNO,
       ASN,
       CARDTYPECODE,
       CURRENTMONEY,
       PREMONEY,
       OPERATESTAFFNO,
       OPERATEDEPARTID,
       OPERATETIME)
      SELECT V_SEQ,
             P_ID,
             'L1',
             V_OCARDNO,
             T.ASN,
             T.CARDTYPECODE,
             P_TRANSITMONEY,
             V_PREMONEY,
             P_CURROPER,
             P_CURRDEPT,
             V_TODAY
        FROM TF_F_CARDREC T
       WHERE T.CARDNO = V_OCARDNO;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S001002129';
      P_RETMSG := 'д��ҵ��̨������ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
    
  END;
  
  BEGIN
      INSERT INTO TF_B_TRADE_ACCOUNT
      (TRADEID,
       ACCTID,
       ID,
       TRADETYPECODE,
       CARDNO,
       ASN,
       CARDTYPECODE,
       CURRENTMONEY,
       PREMONEY,
       OPERATESTAFFNO,
       OPERATEDEPARTID,
       OPERATETIME)
      SELECT V_SEQ,
             P_OACCT_ID,
             P_ID,
             'L1',
             V_OCARDNO,
             T.ASN,
             T.CARDTYPECODE,
             P_TRANSITMONEY,
             V_PREMONEY,
             P_CURROPER,
             P_CURRDEPT,
             V_TODAY
        FROM TF_F_CARDREC T
       WHERE T.CARDNO = V_OCARDNO;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S001002130';
      P_RETMSG := 'д��ҵ��̨������ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 10)����ת�������֧����¼
  BEGIN
   SELECT ID INTO V_PAYMENT_ID
	  FROM  TF_B_TRADE
	  WHERE TRADEID = P_TRADE_ID 
	  AND CARDNO = V_OCARDNO;
  
   UPDATE TF_F_BALANCE_PAYOUT SET 
    CANCEL_TAG = '1'
    WHERE PAYOUT_ID = V_PAYMENT_ID;
    
   IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001132';
      P_RETMSG := 'д�����֧����ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 11)����ת��������˱���
  BEGIN
    UPDATE TF_F_ACCT_BALANCE
       SET BALANCE = BALANCE + P_TRANSITMONEY
     WHERE ACCT_ID = P_OACCT_ID;
  
    IF SQL%ROWCOUNT != 1 THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001128';
      P_RETMSG := '��������˱���ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 12)д��ת�����ͻ��˻���ʷ��
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
       WHERE ACCT_ID = P_OACCT_ID;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001134';
      P_RETMSG := 'д��ͻ��˻���ʷ����ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 13)����ת�����ͻ��˻���
  BEGIN
    UPDATE TF_F_CUST_ACCT
       SET ACCT_BALANCE = ACCT_BALANCE + P_TRANSITMONEY,
           REL_BALANCE  = REL_BALANCE + P_TRANSITMONEY
     WHERE ACCT_ID = P_OACCT_ID;
    IF SQL%ROWCOUNT != 1 THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001129';
      P_RETMSG := '���¿ͻ��˻���ʧ��' || SQLERRM;
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
