  -- =============================================
  -- AUTHOR:    LIUHE
  -- CREATE DATE: 2011-06-21
  -- DESCRIPTION: �����˻������洢����
  -- =============================================
  CREATE OR REPLACE PROCEDURE SP_CA_OPENACC
(
  P_CARDNO          CHAR, --����
  P_ACCTYPE         VARCHAR2, --�˻����ͱ���
  P_CUSTNAME        VARCHAR2, --�ͻ�����
  P_CUSTBIRTH       VARCHAR2, --����
  P_PAPERTYPECODE   VARCHAR2, --֤������
  P_PAPERNO         VARCHAR2, --֤������
  P_CUSTSEX         VARCHAR2, --�Ա�
  P_CUSTPHONE       VARCHAR2, --�ֻ�
  P_CUSTTELPHONE    VARCHAR2, --�̻�
  P_CUSTPOST        VARCHAR2, --�ʱ�
  P_CUSTADDR        VARCHAR2, --��ַ
  P_CUSTEMAIL       VARCHAR2, --����
  P_ISUPOLDCUS      CHAR, --�Ƿ����ԭ�ͻ���,'1':��'0':��
  P_PWD             VARCHAR2,
  P_LIMIT_EACHTIME  INT, --ÿ�������޶�
  P_LIMIT_DAYAMOUNT INT, --���������޶�
  P_CURROPER        CHAR, --��ǰ������
  P_CURRDEPT        CHAR, --��ǰ�����߲���
  P_RETCODE         OUT CHAR, --�������
  P_RETMSG          OUT VARCHAR2 --������Ϣ
) AS
  V_CUST_ID NUMBER; --�ͻ�ID
  V_ACCT_BALANCE_ID NUMBER; --����˱�ID
  V_COUNT INT; --���ڴ�Ų�ѯ�����������ؽ��
  V_CUSTPHONE VARCHAR2(200); --��ϵ�绰�����³ֿ������ϱ�ʱʹ��
  V_ACC_ID NUMBER; --�˻�ID
  V_SEQ CHAR(16); --̨����ˮ��  
  V_TODAY DATE := SYSDATE;
  V_EX EXCEPTION;
  V_CUSID   NUMBER; --��ʷ����CUST_ID
  V_C INT := 0;          --��ʷ������ͬ�ͻ���¼������
BEGIN

  -- 1)��֤�Ƿ��Ѿ���ͨ���˻�
  SELECT COUNT(*)
    INTO V_COUNT
    FROM TF_F_CUST_ACCT
   WHERE ICCARD_NO = P_CARDNO AND ACCT_TYPE_NO = P_ACCTYPE;
  IF (V_COUNT != 0) THEN
    P_RETCODE := 'S006001115';
    P_RETMSG := '�ÿ����Ѵ��ڸ����͵��˻�';
    ROLLBACK;
    RETURN;
  END IF;
  
  -- 2)д��ͻ���ʷ��
  BEGIN
  	BEGIN
		    SELECT CUST_ID INTO V_CUSID FROM TF_F_CUST
		       WHERE ICCARD_NO = P_CARDNO;
		    exception 
		    when no_data_found then
		      begin
		        V_CUSID := '';
		      end;
		    when others then
		    	begin
		    		P_RETCODE := 'S006001119';
		    		rollback;
		    		return;
		    	end;
    END;
    IF V_CUSID != '' THEN
      BEGIN
             SELECT COUNT(*) INTO V_C FROM TH_F_CUST WHERE CUST_ID = V_CUSID AND OPERATE_TIME = V_TODAY;
             IF V_C < 1 THEN  --����ͻ���������ͬ�ͻ�ID,��ͬʱ��ļ�¼�����ٲ���
                BEGIN
                      INSERT INTO TH_F_CUST
                        (CUST_ID,
                         OPERATE_TIME,
                         PAPER_TYPE_CODE,
                         PAPER_NO,
                         CUST_NAME,
                         CUST_SEX,
                         CUST_BIRTH,
                         CUST_ADDR,
                         CUST_POST,
                         CUST_PHONE,
                         CUST_TELPHONE,
                         CUST_EMAIL,
                         CUST_TYPE_ID,
                         CUST_SERVICE_SCOPE,
                         ICCARD_NO,
                         IS_VIP,
                         PARENT_ID,
                         STATE,
                         STAFF_ID,
                         CREATE_DATE,
                         EFF_DATE,
                         EXP_DATE)
                        SELECT CUST_ID,
                               V_TODAY,
                               PAPER_TYPE_CODE,
                               PAPER_NO,
                               CUST_NAME,
                               CUST_SEX,
                               CUST_BIRTH,
                               CUST_ADDR,
                               CUST_POST,
                               CUST_PHONE,
                               CUST_TELPHONE,
                               CUST_EMAIL,
                               CUST_TYPE_ID,
                               CUST_SERVICE_SCOPE,
                               ICCARD_NO,
                               IS_VIP,
                               PARENT_ID,
                               STATE,
                               STAFF_ID,
                               CREATE_DATE,
                               EFF_DATE,
                               EXP_DATE
                          FROM TF_F_CUST
                         WHERE PAPER_TYPE_CODE = P_PAPERTYPECODE
                           AND PAPER_NO = P_PAPERNO;
                    EXCEPTION
                      WHEN OTHERS THEN
                        P_RETCODE := 'S006001118';
                        P_RETMSG := 'д��ͻ�������ʷ��ʧ��' || SQLERRM;
                        ROLLBACK;
                        RETURN;
                END;
             END IF;
      END;     
    END IF; 
    
    
  END;

  -- 3)д�����¿ͻ���
  BEGIN
    SP_GETACCID_NEW(SEQNAME  => 'TF_F_CUST_SEQ',
                AREACODE => '21',
                ACCID    => V_CUST_ID);
  
    MERGE INTO TF_F_CUST D
    USING DUAL
    ON (D.ICCARD_NO = P_CARDNO)
    WHEN MATCHED THEN
      UPDATE
         SET D.PAPER_TYPE_CODE = P_PAPERTYPECODE,
             D.PAPER_NO      = P_PAPERNO,
         		 D.CUST_NAME     = P_CUSTNAME,
             D.CUST_SEX      = P_CUSTSEX,
             D.CUST_BIRTH    = P_CUSTBIRTH,
             D.CUST_ADDR     = P_CUSTADDR,
             D.CUST_POST     = P_CUSTPOST,
             D.CUST_PHONE    = P_CUSTPHONE,
             D.CUST_TELPHONE = P_CUSTTELPHONE,
             D.CUST_EMAIL    = P_CUSTEMAIL
    WHEN NOT MATCHED THEN
      INSERT
        (CUST_ID,
         PAPER_TYPE_CODE,
         PAPER_NO,
         CUST_NAME,
         CUST_SEX,
         CUST_BIRTH,
         CUST_ADDR,
         CUST_POST,
         CUST_PHONE,
         CUST_TELPHONE,
         CUST_EMAIL,
         CUST_TYPE_ID,
         CUST_SERVICE_SCOPE,
         ICCARD_NO,
         IS_VIP,
         STATE,
         STAFF_ID,
         CREATE_DATE,
         EFF_DATE)
      VALUES
        (V_CUST_ID,
         P_PAPERTYPECODE,
         P_PAPERNO,
         P_CUSTNAME,
         P_CUSTSEX,
         P_CUSTBIRTH,
         P_CUSTADDR,
         P_CUSTPOST,
         P_CUSTPHONE,
         P_CUSTTELPHONE,
         P_CUSTEMAIL,
         'A',
         'A',
         P_CARDNO,
         'F',
         'A',
         P_CURROPER,
         V_TODAY,
         V_TODAY);
  
    IF SQL%ROWCOUNT != 1 THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001110';
      P_RETMSG := 'д�����¿ͻ���ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 4) ���³ֿ������ϱ�
  BEGIN
  	
  	SP_GETSEQ(SEQ => V_SEQ);
  	
    IF P_ISUPOLDCUS = '1' THEN
    
      IF P_CUSTPHONE != '' THEN
      
        V_CUSTPHONE := P_CUSTPHONE;
      ELSE
        V_CUSTPHONE := P_CUSTTELPHONE;
      END IF;
    
      INSERT INTO TF_B_CUSTOMERCHANGE
      SELECT V_SEQ,CARDNO,CUSTNAME,CUSTSEX,CUSTBIRTH,PAPERTYPECODE,PAPERNO
      ,CUSTADDR,CUSTPOST,CUSTPHONE,CUSTEMAIL,NULL,'00',P_CURROPER,'0003',V_TODAY
      ,REMARK 
      FROM TF_F_CUSTOMERREC WHERE CARDNO = P_CARDNO;
    
      UPDATE TF_F_CUSTOMERREC
         SET CUSTNAME      = nvl(P_CUSTNAME,CUSTNAME),
             CUSTSEX       = nvl(P_CUSTSEX,CUSTSEX),
             CUSTBIRTH     = nvl(P_CUSTBIRTH,CUSTBIRTH),
             PAPERTYPECODE = nvl(P_PAPERTYPECODE,PAPERTYPECODE),
             PAPERNO       = nvl(P_PAPERNO,PAPERNO),
             CUSTADDR      = nvl(P_CUSTADDR,CUSTADDR),
             CUSTPOST      = nvl(P_CUSTPOST,CUSTPOST),
             CUSTPHONE     = nvl(V_CUSTPHONE,CUSTPHONE),
             CUSTEMAIL     = nvl(P_CUSTEMAIL,CUSTEMAIL),
			 UPDATESTAFFNO = P_CURROPER,
			 UPDATETIME    = V_TODAY
       WHERE CARDNO = P_CARDNO;
    
      IF SQL%ROWCOUNT != 1 THEN
        P_RETCODE := 'S006001110';
        RAISE V_EX;
      END IF;
    
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S001011130';
      P_RETMSG := '���³ֿ������ϱ�ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
    
  END;

  -- 5)д��ͻ��˻���
  BEGIN
    SP_GETACCID_NEW(SEQNAME  => 'TF_F_CUST_ACCT_SEQ',
                AREACODE => '21',
                ACCID    => V_ACC_ID);
 
        SELECT CUST_ID
          INTO V_CUST_ID
          FROM TF_F_CUST
         WHERE ICCARD_NO = P_CARDNO;

    INSERT INTO TF_F_CUST_ACCT
      (ACCT_ID,
       CUST_ID,
       ACCT_TYPE_NO,
       STATE,
       STATE_DATE,
       CREATE_DATE,
       EFF_DATE,
       ACCT_PAYMENT_TYPE,
       ICCARD_NO,
       CUST_PASSWORD,
       LIMIT_EACHTIME,
       LIMIT_DAYAMOUNT,
	   CODEERRORTIMES)
    VALUES
      (V_ACC_ID,
       V_CUST_ID,
       P_ACCTYPE,
       'A',
       V_TODAY,
       V_TODAY,
       V_TODAY,
       'N',
       P_CARDNO,
       P_PWD,            --  'E10ADC3949BA59ABBE56E057F20F883E',
       P_LIMIT_EACHTIME,
       P_LIMIT_DAYAMOUNT,
	   0);
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001111';
      P_RETMSG := 'д��ͻ��˻���ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 6)д������˱���
  BEGIN
    SP_GETACCID_NEW(SEQNAME  => 'TF_F_ACCT_BALANCE_SEQ',
                AREACODE => '21',
                ACCID    => V_ACCT_BALANCE_ID);
  
    INSERT INTO TF_F_ACCT_BALANCE
      (ACCT_BALANCE_ID,
       ACCT_ID,
       ICCARD_NO,
       ACCT_TYPE_NO,
       EFF_DATE,
       STATE,
       STATE_DATE)
    VALUES
      (V_ACCT_BALANCE_ID,
       V_ACC_ID,
       P_CARDNO,
       P_ACCTYPE,
       V_TODAY,
       'A',
       V_TODAY);
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001112';
      P_RETMSG := 'д������˱���ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 7) д��ҵ��̨������
  BEGIN

    INSERT INTO TF_B_TRADE
      (TRADEID,
       TRADETYPECODE,
       CARDNO,
       ASN,
       CARDTYPECODE,
       OPERATESTAFFNO,
       OPERATEDEPARTID,
       OPERATETIME)
      SELECT V_SEQ,
             '8X',
             P_CARDNO,
             T.ASN,
             T.CARDTYPECODE,
             P_CURROPER,
             P_CURRDEPT,
             V_TODAY
        FROM TF_F_CARDREC T
       WHERE T.CARDNO = P_CARDNO;
  
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001113';
      P_RETMSG := 'д��ҵ��̨������ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;
  
  --��ר���˻�ҵ��̨������
  BEGIN
      INSERT INTO TF_B_TRADE_ACCOUNT
        (TRADEID,
         ACCTID,
         TRADETYPECODE,
         CARDNO,
         ASN,
         CARDTYPECODE,
         OPERATESTAFFNO,
         OPERATEDEPARTID,
         OPERATETIME)
      SELECT V_SEQ,
             V_ACC_ID,
             '8X',
             P_CARDNO,
             T.ASN,
             T.CARDTYPECODE,
             P_CURROPER,
             P_CURRDEPT,
             V_TODAY
        FROM TF_F_CARDREC T
       WHERE T.CARDNO = P_CARDNO;
       EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006002000';
      P_RETMSG := 'д��ר���˻�ҵ��̨������ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 8) д�뿪ͨ���ܱ�
  BEGIN
    
     SELECT COUNT(*) INTO V_COUNT
     FROM TF_F_CARDUSEAREA WHERE CARDNO = P_CARDNO and FUNCTIONTYPE='14'; --����Ƿ��ǵ�һ�ο�ͨ�˻�

	    IF V_COUNT = 0 THEN
	        BEGIN
	          INSERT INTO TF_F_CARDUSEAREA
	            (CARDNO, FUNCTIONTYPE, USETAG, UPDATESTAFFNO, UPDATETIME)
	          VALUES
	            (P_CARDNO, '14', '1', P_CURROPER, V_TODAY);
	          EXCEPTION
	            WHEN OTHERS THEN
	              P_RETCODE := 'S00509B003';
	              P_RETMSG := 'д�뿪ͨ����ʧ��,' || SQLERRM;
	              ROLLBACK;
	              RETURN;
	        END;     
	     END IF;
	     
  END;
  P_RETCODE := '0000000000';
  P_RETMSG := '';
  RETURN;
END;

/
  SHOW ERROR
