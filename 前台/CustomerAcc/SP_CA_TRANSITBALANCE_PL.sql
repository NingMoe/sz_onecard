CREATE OR REPLACE PROCEDURE SP_CA_TRANSITBALANCE
(
  P_OACCT_ID     NUMBER, --ת�����ʺ�
  P_IACCT_ID     NUMBER, --ת�뿨�ʺ�
  P_TRANSITMONEY CHAR, --ת�˽��
  P_ID           CHAR, --̨�˼�¼��ˮ��
  P_CURROPER     CHAR, --��ǰ������
  P_CURRDEPT     CHAR, --��ǰ�����߲���
  P_RETCODE      OUT CHAR, --�������
  P_RETMSG       OUT VARCHAR2 --������Ϣ
) AS
  V_OCARDNO         CHAR(16);
  V_ICARDNO         CHAR(16);
  V_PAYMENT_ID      varchar(16);
  V_ACCT_BALANCE_ID INT;
  V_PREMONEY INT;
  V_SEQ CHAR(16);
  V_TODAY DATE := SYSDATE;
  V_EX EXCEPTION;
  
  v_quantity  int;
  v_TOTAL_SUPPLY_TIMES  INT;
BEGIN

  -- 1)д��ת�����ͻ��˻���ʷ��
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
      P_RETCODE := 'S006001124';
      P_RETMSG := 'д��ͻ��˻���ʷ����ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 2)����ת�����ͻ��˻���
  BEGIN
  	
  	 SELECT REL_BALANCE
      INTO V_PREMONEY
      FROM TF_F_CUST_ACCT
     WHERE ACCT_ID = P_OACCT_ID;
  	
    UPDATE TF_F_CUST_ACCT
       SET ACCT_BALANCE = ACCT_BALANCE - P_TRANSITMONEY,
           REL_BALANCE  = REL_BALANCE - P_TRANSITMONEY
     WHERE ACCT_ID = P_OACCT_ID;
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

  -- 3)����ת��������˱���
  BEGIN
    UPDATE TF_F_ACCT_BALANCE
       SET BALANCE = BALANCE - P_TRANSITMONEY
     WHERE ACCT_ID = P_OACCT_ID;

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

  -- 5)д��ת�������֧����¼��
  BEGIN
                
  	SP_GETSEQ(SEQ => V_SEQ);
  	
    SELECT ACCT_BALANCE_ID
      INTO V_ACCT_BALANCE_ID
      FROM TF_F_ACCT_BALANCE
     WHERE ACCT_ID = P_OACCT_ID;

    INSERT INTO TF_F_BALANCE_PAYOUT
      (PAYOUT_ID,
       ACCT_BALANCE_ID,
       OPERATE_TYPE,
       STAFFNO,
       OPERATETIME,
       AMOUNT,
       BALANCE,
       STATECODE,
       UPDATETIME)
    VALUES
      (V_SEQ,
       V_ACCT_BALANCE_ID,
       'D', --ת��
       P_CURROPER,
       V_TODAY,
       P_TRANSITMONEY,
       V_PREMONEY - P_TRANSITMONEY,
       '1', --��Ч
       V_TODAY
       );
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001122';
      P_RETMSG := 'д�����֧����¼��ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 6)д��ת����̨������
  BEGIN

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
             V_SEQ,
             '8T',
             V_OCARDNO,
             T.ASN,
             T.CARDTYPECODE,
             -P_TRANSITMONEY,
             V_PREMONEY,
             P_CURROPER,
             P_CURRDEPT,
             V_TODAY
        FROM TF_F_CARDREC T
       WHERE T.CARDNO = V_OCARDNO;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S001002119';
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
             V_SEQ,
             '8T',
             V_OCARDNO,
             T.ASN,
             T.CARDTYPECODE,
             -P_TRANSITMONEY,
             V_PREMONEY,
             P_CURROPER,
             P_CURRDEPT,
             V_TODAY
        FROM TF_F_CARDREC T
       WHERE T.CARDNO = V_OCARDNO;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006002000';
      P_RETMSG := 'д��ר���˻�ҵ��̨������ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 7)д��ת�뿨̨������

  BEGIN
                
  	--SELECT TF_F_BALANCE_PAYIN_SEQ.NEXTVAL INTO V_PAYMENT_ID FROM DUAL;
  	V_PAYMENT_ID := V_SEQ;
  	--SP_GETTRADEID(SEQNAME  => 'TF_F_BALANCE_PAYIN_SEQ',TRADEID => V_PAYMENT_ID);
  	
    SELECT REL_BALANCE
      INTO V_PREMONEY
      FROM TF_F_CUST_ACCT
     WHERE ACCT_ID = P_IACCT_ID;

    SELECT ICCARD_NO
      INTO V_ICARDNO
      FROM TF_F_CUST_ACCT
     WHERE ACCT_ID = P_IACCT_ID;

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
             V_PAYMENT_ID,
             '8T',
             V_ICARDNO,
             T.ASN,
             T.CARDTYPECODE,
             P_TRANSITMONEY,
             V_PREMONEY,
             P_CURROPER,
             P_CURRDEPT,
             V_TODAY
        FROM TF_F_CARDREC T
       WHERE T.CARDNO = V_ICARDNO;
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
               P_IACCT_ID,
               V_PAYMENT_ID,
               '8T',
               V_ICARDNO,
               T.ASN,
               T.CARDTYPECODE,
               P_TRANSITMONEY,
               V_PREMONEY,
               P_CURROPER,
               P_CURRDEPT,
               V_TODAY
          FROM TF_F_CARDREC T
         WHERE T.CARDNO = V_ICARDNO;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S006002001';
        P_RETMSG := 'д��ר���˻�ҵ��̨������ʧ��' || SQLERRM;
        ROLLBACK;
        RETURN;
  END;
  
  BEGIN
  	INSERT INTO TF_F_BALANCE_PAYIN
		    		  (
			    		   PAYIN_ID, 		  ACCT_BALANCE_ID, 	OPERATE_TYPE, 	AMOUNT,         BALANCE,    	   
			    		   STAFFNO,    		OPERATETIME,     	STATECODE,      UPDATETIME, 	  ORDER_NO,
			    		   CANCEL_TAG
		    		  )
    		  VALUES
    		  		(
	    		  		 V_PAYMENT_ID,	P_IACCT_ID,          'D',         P_TRANSITMONEY, V_PREMONEY + P_TRANSITMONEY,
	    		  		 P_CURROPER,    V_TODAY,     			   '1',         V_TODAY,        V_PAYMENT_ID,
	    		  		 '0'                  
    		  		);
    		  EXCEPTION
          WHEN OTHERS THEN
          P_RETCODE := 'S006001125';
          P_RETMSG  := 'д������˱���ֵ��¼��ʧ��' || SQLERRM;
          ROLLBACK; RETURN;				
  END;

  -- 10)����ת�뿨����˱���
  BEGIN
    UPDATE TF_F_ACCT_BALANCE
       SET BALANCE = BALANCE + P_TRANSITMONEY
     WHERE ACCT_ID = P_IACCT_ID;

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

  -- 11)д��ת�뿨�ͻ��˻���ʷ��
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
      P_RETCODE := 'S006001134';
      P_RETMSG := 'д��ͻ��˻���ʷ����ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 12)����ת�뿨�ͻ��˻���
  BEGIN
    UPDATE TF_F_CUST_ACCT
       SET ACCT_BALANCE       = ACCT_BALANCE + P_TRANSITMONEY,
           REL_BALANCE        = REL_BALANCE + P_TRANSITMONEY,
           LAST_SUPPLY_TIME   = V_TODAY,
           TOTAL_SUPPLY_MONEY = TOTAL_SUPPLY_MONEY + P_TRANSITMONEY,
           TOTAL_SUPPLY_TIMES = TOTAL_SUPPLY_TIMES + 1
     WHERE ACCT_ID = P_IACCT_ID;
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
  
  -- 3) Determine whether the recharge is the first time
				BEGIN
				    SELECT TOTAL_SUPPLY_TIMES INTO v_TOTAL_SUPPLY_TIMES
				    FROM  TF_F_CUST_ACCT WHERE ACCT_ID = P_IACCT_ID;
		
		    EXCEPTION
						    WHEN NO_DATA_FOUND THEN
						    p_retCode := 'A001002112';
						    p_retMsg  := 'A001002112:Can not find the record or Error';
						    ROLLBACK; RETURN;
		    END;
    
		    -- 4) for the first time
		    IF v_TOTAL_SUPPLY_TIMES = 1 THEN
				    BEGIN
				        UPDATE TF_F_CUST_ACCT
				        SET  FIRST_SUPPLY_TIME = V_TODAY
				        WHERE  ACCT_ID = P_IACCT_ID;
		
				        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
						EXCEPTION
					        WHEN OTHERS THEN
					            p_retCode := 'S001002113';
					            p_retMsg  := 'S001002113:Update failure';
					            ROLLBACK; RETURN;
				    END;
		    END IF;

  P_RETCODE := '0000000000';
  P_RETMSG := '';
  COMMIT;
  RETURN;
END;


/
SHOW ERROR
