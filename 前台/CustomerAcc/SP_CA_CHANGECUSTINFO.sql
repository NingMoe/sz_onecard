CREATE OR REPLACE PROCEDURE SP_CA_CHANGECUSTINFO
(
  P_ACCTID          NUMBER,   --账户号
  P_CARDNO          CHAR,     --卡号
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
  P_LIMIT_EACHTIME  INT,     --每笔消费限额
  P_LIMIT_DAYAMOUNT INT,     --当日消费限额
  P_CHANGE_LIMIT    CHAR := 0, --0不修改,1修改
  P_CURROPER        CHAR,      --当前操作者
  P_CURRDEPT        CHAR,      --当前操作者部门
  P_RETCODE         OUT CHAR,  --错误编码
  P_RETMSG          OUT VARCHAR2 --错误信息
) AS
  V_CUST_ID NUMBER; --客户ID
  V_ACCT_ID NUMBER; --帐户ID
  V_COUNT INT;      --用于存放查询数据行数返回结果
  V_SEQ CHAR(16);   --台账流水号
  V_TODAY DATE := SYSDATE;
  V_EX EXCEPTION;
BEGIN

  -- 1)验证是否已经开通过账户
  SELECT COUNT(*)
    INTO V_COUNT
    FROM TF_F_CUST_ACCT
   WHERE ICCARD_NO = P_CARDNO;
  IF (V_COUNT = 0) THEN
    P_RETCODE := 'S006001115';
    P_RETMSG := '该卡未开通专有账户';
    ROLLBACK;
    RETURN;
  END IF;
  IF P_CHANGE_LIMIT = '1' THEN
		  SELECT CUST_ID, ACCT_ID
		    INTO V_CUST_ID, V_ACCT_ID
		    FROM TF_F_CUST_ACCT
		   WHERE ICCARD_NO = P_CARDNO AND ACCT_ID = P_ACCTID
		     AND ROWNUM <= 1;
	ELSE
			SELECT CUST_ID
		    INTO V_CUST_ID
		    FROM TF_F_CUST_ACCT
		   WHERE ICCARD_NO = P_CARDNO
		     AND ROWNUM <= 1;
  END IF;
  -- 2)写入客户历史表
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
       WHERE CUST_ID = V_CUST_ID;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001118';
      P_RETMSG := '写入客户资料历史表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 3)更新客户表
  BEGIN
    UPDATE TF_F_CUST
       SET CUST_NAME     = P_CUSTNAME,
           CUST_SEX      = P_CUSTSEX,
           CUST_BIRTH    = P_CUSTBIRTH,
           CUST_ADDR     = P_CUSTADDR,
           CUST_POST     = P_CUSTPOST,
           CUST_PHONE    = P_CUSTPHONE,
           CUST_TELPHONE = P_CUSTTELPHONE,
           CUST_EMAIL    = P_CUSTEMAIL,
           PAPER_TYPE_CODE = P_PAPERTYPECODE,
           PAPER_NO = P_PAPERNO
     WHERE CUST_ID = V_CUST_ID;
     
     IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001110';
      P_RETMSG := '更新客户表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;
 
 

  --4)更新客户账户表
  BEGIN
      IF P_CHANGE_LIMIT = '1' THEN
      
      UPDATE TF_F_CUST_ACCT
         SET LIMIT_EACHTIME = P_LIMIT_EACHTIME,
             LIMIT_DAYAMOUNT = P_LIMIT_DAYAMOUNT
       WHERE ACCT_ID = V_ACCT_ID;
       
       IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001112';
      P_RETMSG := '更新客户账户表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;
  -- 5) 写入业务台账主表
  BEGIN
    SP_GETSEQ(SEQ => V_SEQ);
  
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
             '8U',
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
  
  IF P_CHANGE_LIMIT = '1' THEN
	  -- 5) 写入业务台账主表
	  BEGIN
	    SP_GETSEQ(SEQ => V_SEQ);
	  
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
	             V_ACCT_ID,
	             '8U',
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
	      P_RETCODE := 'S006001114';
	      P_RETMSG := '写入专有账户业务台账主表失败' || SQLERRM;
	      ROLLBACK;
	      RETURN;
	  END;
  END IF;
  /*  
  BEGIN
    
      UPDATE TF_F_CUSTOMERREC
         SET CUSTNAME      = P_CUSTNAME,
             CUSTSEX       = P_CUSTSEX,
             CUSTBIRTH     = P_CUSTBIRTH,
             PAPERTYPECODE = P_PAPERTYPECODE,
             PAPERNO       = P_PAPERNO,
             CUSTADDR      = P_CUSTADDR,
             CUSTPOST      = P_CUSTPOST,
             CUSTPHONE     = P_CUSTPHONE,
             CUSTEMAIL     = P_CUSTEMAIL,
             UPDATESTAFFNO = P_CURROPER,
             UPDATETIME    = V_TODAY
      WHERE CARDNO = P_CARDNO;
    
      IF SQL%ROWCOUNT != 1 THEN
        RAISE V_EX;
      END IF;
      
      EXCEPTION
        WHEN OTHERS THEN
          P_RETCODE := 'S001011130';
          P_RETMSG := '更新持卡人资料表失败' || SQLERRM;
          ROLLBACK;
          RETURN;
          
  END;
  */
  P_RETCODE := '0000000000';
  P_RETMSG := '';
  COMMIT;
  RETURN;
  
END;

/
show errors
