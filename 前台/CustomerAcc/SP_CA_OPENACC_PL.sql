  -- =============================================
  -- AUTHOR:    LIUHE
  -- CREATE DATE: 2011-06-21
  -- DESCRIPTION: 联机账户开户存储过程
  -- =============================================
  CREATE OR REPLACE PROCEDURE SP_CA_OPENACC
(
  P_CARDNO          CHAR, --卡号
  P_ACCTYPE         VARCHAR2, --账户类型编码
  P_CUSTNAME        VARCHAR2, --客户姓名
  P_CUSTBIRTH       VARCHAR2, --生日
  P_PAPERTYPECODE   VARCHAR2, --证件类型
  P_PAPERNO         VARCHAR2, --证件号码
  P_CUSTSEX         VARCHAR2, --性别
  P_CUSTPHONE       VARCHAR2, --手机
  P_CUSTTELPHONE    VARCHAR2, --固话
  P_CUSTPOST        VARCHAR2, --邮编
  P_CUSTADDR        VARCHAR2, --地址
  P_CUSTEMAIL       VARCHAR2, --邮箱
  P_ISUPOLDCUS      CHAR, --是否更新原客户表,'1':是'0':否
  P_PWD             VARCHAR2,
  P_LIMIT_EACHTIME  INT, --每笔消费限额
  P_LIMIT_DAYAMOUNT INT, --当日消费限额
  P_CURROPER        CHAR, --当前操作者
  P_CURRDEPT        CHAR, --当前操作者部门
  P_RETCODE         OUT CHAR, --错误编码
  P_RETMSG          OUT VARCHAR2 --错误信息
) AS
  V_CUST_ID NUMBER; --客户ID
  V_ACCT_BALANCE_ID NUMBER; --余额账本ID
  V_COUNT INT; --用于存放查询数据行数返回结果
  V_CUSTPHONE VARCHAR2(200); --联系电话，更新持卡人资料表时使用
  V_ACC_ID NUMBER; --账户ID
  V_SEQ CHAR(16); --台账流水号  
  V_TODAY DATE := SYSDATE;
  V_EX EXCEPTION;
  V_CUSID   NUMBER; --历史表中CUST_ID
  V_C INT := 0;          --历史表中相同客户记录的条数
BEGIN

  -- 1)验证是否已经开通过账户
  SELECT COUNT(*)
    INTO V_COUNT
    FROM TF_F_CUST_ACCT
   WHERE ICCARD_NO = P_CARDNO AND ACCT_TYPE_NO = P_ACCTYPE;
  IF (V_COUNT != 0) THEN
    P_RETCODE := 'S006001115';
    P_RETMSG := '该卡号已存在该类型的账户';
    ROLLBACK;
    RETURN;
  END IF;
  
  -- 2)写入客户历史表
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
             IF V_C < 1 THEN  --如果客户表中有相同客户ID,相同时间的记录，则不再插入
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
                        P_RETMSG := '写入客户资料历史表失败' || SQLERRM;
                        ROLLBACK;
                        RETURN;
                END;
             END IF;
      END;     
    END IF; 
    
    
  END;

  -- 3)写入或更新客户表
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
      P_RETMSG := '写入或更新客户表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 4) 更新持卡人资料表
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
      P_RETMSG := '更新持卡人资料表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
    
  END;

  -- 5)写入客户账户表
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
      P_RETMSG := '写入客户账户表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 6)写入余额账本表
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
      P_RETMSG := '写入余额账本表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 7) 写入业务台账主表
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
      P_RETMSG := '写入业务台账主表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;
  
  --记专有账户业务台账主表
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
      P_RETMSG := '写入专有账户业务台账主表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 8) 写入开通功能表
  BEGIN
    
     SELECT COUNT(*) INTO V_COUNT
     FROM TF_F_CARDUSEAREA WHERE CARDNO = P_CARDNO and FUNCTIONTYPE='14'; --标记是否是第一次开通账户

	    IF V_COUNT = 0 THEN
	        BEGIN
	          INSERT INTO TF_F_CARDUSEAREA
	            (CARDNO, FUNCTIONTYPE, USETAG, UPDATESTAFFNO, UPDATETIME)
	          VALUES
	            (P_CARDNO, '14', '1', P_CURROPER, V_TODAY);
	          EXCEPTION
	            WHEN OTHERS THEN
	              P_RETCODE := 'S00509B003';
	              P_RETMSG := '写入开通功能失败,' || SQLERRM;
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
