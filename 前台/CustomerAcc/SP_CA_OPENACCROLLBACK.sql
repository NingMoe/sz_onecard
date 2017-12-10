  -- =============================================
  -- AUTHOR:    董翔
  -- CREATE DATE: 2011-06-30
  -- DESCRIPTION:  联机账户开卡返销
  -- MODIFY BY liuhe20110907返销时删除客户表改为更新客户表
  --修改 殷华荣 增加了账户标识 多账户返销处理
  -- =============================================
  CREATE OR REPLACE PROCEDURE SP_CA_OPENACCROLLBACK
(
  P_ACCTID        CHAR,       --账户标识
  P_CARDNO        CHAR,       --卡号
  P_TRADE_ID      CHAR,       --台账记录号
  P_PAPERTYPECODE VARCHAR2,   --证件类型
  P_PAPERNO       VARCHAR2,   --证件号码
  P_CURROPER      CHAR,       --当前操作者
  P_CURRDEPT      CHAR,       --当前操作者部门
  P_RETCODE       OUT CHAR,   --错误编码
  P_RETMSG        OUT VARCHAR2 --错误信息
) AS
	V_ACCT_ID         INT;
	V_CUST_ID         INT;
	V_SEQ             CHAR(16);
	V_TODAY           DATE := SYSDATE;
	V_EX              EXCEPTION;
	V_COUNT           INT;
	V_TRADE_DATE      DATE; --开户时间
	V_CUSTNAME        VARCHAR2(250); --客户姓名
	V_CUSTBIRTH       VARCHAR2(50); --生日
	V_PAPERTYPECODE   VARCHAR2(50); --证件类型
	V_PAPERNO         VARCHAR2(200); --证件号码
	V_CUSTSEX         VARCHAR2(50); --性别
	V_CUSTPHONE       VARCHAR2(200); --手机
	V_CUSTTELPHONE    VARCHAR2(200); --固话
	V_CUSTPOST        VARCHAR2(50); --邮编
	V_CUSTADDR        VARCHAR2(600); --地址
	V_CUSTEMAIL       VARCHAR2(50); --邮箱
 
BEGIN

  V_ACCT_ID := TO_NUMBER(P_ACCTID);

  -- 1)验证是否已经开通过账户
 /*BEGIN
  SELECT ACCT_ID
    INTO V_ACCT_ID
    FROM TF_F_CUST_ACCT
   WHERE ICCARD_NO = P_CARDNO;
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
    P_RETCODE := 'S006001106';
    P_RETMSG := '该卡号未关联账户' || SQLERRM;
    ROLLBACK;
    RETURN;
 END;*/
 
 -- 2)查找开户时间
	BEGIN
		SELECT OPERATETIME INTO V_TRADE_DATE FROM TF_B_TRADE_ACCOUNT
		WHERE ACCTID = V_ACCT_ID AND TRADEID = P_TRADE_ID;
		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			P_RETCODE := 'S004P08B01'; 
			P_RETMSG  := '未能找到开户台账记录' || SQLERRM;
			RETURN;
  END;
	
  -- 3)更新客户表
  BEGIN
      --a)查询客户ID
      SELECT CUST_ID INTO V_CUST_ID FROM TF_F_CUST_ACCT WHERE ACCT_ID = V_ACCT_ID;
    	
      --b)判断是否存在客户历史
      SELECT COUNT(*) INTO V_COUNT FROM TH_F_CUST D
      WHERE CUST_ID = V_CUST_ID AND OPERATE_TIME = V_TRADE_DATE;
    	
      IF V_COUNT = 1 THEN
        --c)查询历史表的信息
        SELECT 
        CUST_NAME,             CUST_SEX,           CUST_BIRTH,          CUST_ADDR,            CUST_POST,
        CUST_PHONE,            CUST_TELPHONE,      CUST_EMAIL,          PAPER_TYPE_CODE,      PAPER_NO
        INTO 
        V_CUSTNAME,            V_CUSTSEX,          V_CUSTBIRTH,         V_CUSTADDR,           V_CUSTPOST,
        V_CUSTPHONE,           V_CUSTTELPHONE,     V_CUSTEMAIL,         V_PAPERTYPECODE,      V_PAPERNO
        FROM TH_F_CUST 
        WHERE CUST_ID = V_CUST_ID AND OPERATE_TIME = V_TRADE_DATE;
        
      --d)还原前再记录历史
        INSERT INTO TH_F_CUST
          (
           CUST_ID,            OPERATE_TIME,       PAPER_TYPE_CODE,     PAPER_NO,             CUST_NAME,
           CUST_SEX,           CUST_BIRTH,         CUST_ADDR,           CUST_POST,            CUST_PHONE,
           CUST_TELPHONE,      CUST_EMAIL,         CUST_TYPE_ID,        CUST_SERVICE_SCOPE,   ICCARD_NO,
           IS_VIP,             PARENT_ID,          STATE,               STAFF_ID,             CREATE_DATE,
           EFF_DATE,           EXP_DATE
          )
          SELECT 
           CUST_ID,            V_TODAY,            PAPER_TYPE_CODE,     PAPER_NO,             CUST_NAME,
           CUST_SEX,           CUST_BIRTH,         CUST_ADDR,           CUST_POST,            CUST_PHONE,
           CUST_TELPHONE,      CUST_EMAIL,         CUST_TYPE_ID,        CUST_SERVICE_SCOPE,   ICCARD_NO,
           IS_VIP,             PARENT_ID,          STATE,               STAFF_ID,             CREATE_DATE,
           EFF_DATE,           EXP_DATE
           FROM TF_F_CUST
           WHERE CUST_ID = V_CUST_ID;

        --e)还原客户历史表
        UPDATE TF_F_CUST 
        SET CUST_NAME     = V_CUSTNAME,
            CUST_SEX      = V_CUSTSEX,
            CUST_BIRTH    = V_CUSTBIRTH,
            CUST_ADDR     = V_CUSTADDR,
            CUST_POST     = V_CUSTPOST,
            CUST_PHONE    = V_CUSTPHONE,
            CUST_TELPHONE = V_CUSTTELPHONE,
            CUST_EMAIL    = V_CUSTEMAIL,
            PAPER_TYPE_CODE = V_PAPERTYPECODE,
            PAPER_NO	  = V_PAPERNO
        WHERE  CUST_ID=V_CUST_ID;
    		
      END IF;
    	
      EXCEPTION
        WHEN OTHERS THEN
          P_RETCODE := 'S006001110';
          P_RETMSG := '更新客户表失败' || SQLERRM;
          ROLLBACK;
          RETURN;
  END;
  
  -- 4)更新持卡人资料表
	BEGIN
		--a)判断是否记录台账
		SELECT COUNT(*) INTO V_COUNT FROM TF_B_CUSTOMERCHANGE D
		WHERE CARDNO = P_CARDNO AND OPERATETIME = V_TRADE_DATE;
	
		IF V_COUNT = 1 THEN
			--c)查询开户时的持卡人信息
			SELECT 
      CUSTNAME,             CUSTSEX,          CUSTBIRTH,                PAPERTYPECODE,            PAPERNO,
      CUSTADDR,             CUSTPOST,         CUSTPHONE,                CUSTEMAIL
			INTO 
      V_CUSTNAME,           V_CUSTSEX,        V_CUSTBIRTH,              V_PAPERTYPECODE,          V_PAPERNO,
      V_CUSTADDR,           V_CUSTPOST,       V_CUSTPHONE,              V_CUSTEMAIL
			FROM TF_B_CUSTOMERCHANGE  
			WHERE CARDNO = P_CARDNO AND OPERATETIME = V_TRADE_DATE;
			
			--d）还原前记录台账
			SP_GETSEQ(SEQ => V_SEQ);
			INSERT INTO TF_B_CUSTOMERCHANGE
			  SELECT V_SEQ,CARDNO,CUSTNAME,CUSTSEX,CUSTBIRTH,PAPERTYPECODE,PAPERNO
			  ,CUSTADDR,CUSTPOST,CUSTPHONE,CUSTEMAIL,NULL,'00',P_CURROPER,'0003',V_TODAY
			  ,REMARK 
			  FROM TF_F_CUSTOMERREC WHERE CARDNO = P_CARDNO;
			
			--e)还原持卡人资料
			UPDATE TF_F_CUSTOMERREC 
			SET CUSTNAME      = V_CUSTNAME,
				CUSTSEX       = V_CUSTSEX,
				CUSTBIRTH     = V_CUSTBIRTH,
				PAPERTYPECODE = V_PAPERTYPECODE,
				PAPERNO       = V_PAPERNO,
				CUSTADDR      = V_CUSTADDR,
				CUSTPOST      = V_CUSTPOST,
				CUSTPHONE     = V_CUSTPHONE,
				CUSTEMAIL     = V_CUSTEMAIL,
				UPDATESTAFFNO = P_CURROPER,
				UPDATETIME    = V_TODAY
			WHERE CARDNO = P_CARDNO;
		END IF;
	   
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S001011130';
      P_RETMSG := '更新持卡人资料表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;
  
  -- 5)删除客户表账户表  
  BEGIN
    DELETE FROM TF_F_CUST_ACCT WHERE ACCT_ID = V_ACCT_ID;
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001119';
      P_RETMSG := '删除客户账户表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;
	
  -- 6)删除新卡余额账本
  BEGIN
    DELETE FROM TF_F_ACCT_BALANCE WHERE ACCT_ID = V_ACCT_ID;
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001112';
      P_RETMSG := '删除余额账本表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 7) 更新原台帐记录
  BEGIN
    UPDATE TF_B_TRADE
       SET CANCELTAG = '1'
     WHERE CARDNO = P_CARDNO
       AND TRADEID = P_TRADE_ID;
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001113';
      P_RETMSG := '更新业务台账主表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;
  
  BEGIN
    UPDATE TF_B_TRADE_ACCOUNT
       SET CANCELTAG = '1'
     WHERE ACCTID = V_ACCT_ID
       AND TRADEID = P_TRADE_ID;
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001120';
      P_RETMSG := '更新专有账户业务台账主表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 8)记录返销业务台账  TRADETYPECODE为L3
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
             'L3',
             P_CARDNO,
             T.ASN,
             T.CARDTYPECODE,
             P_CURROPER,
             P_CURRDEPT,
             V_TODAY
        FROM TF_F_CARDREC T
       WHERE T.CARDNO = P_CARDNO;
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001114';
      P_RETMSG := '写入业务台账主表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;
  
  --记录专有账户返销业务台账 
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
             V_ACCT_ID,
             'L3',
             P_CARDNO,
             T.ASN,
             T.CARDTYPECODE,
             P_CURROPER,
             P_CURRDEPT,
             V_TODAY
        FROM TF_F_CARDREC T
       WHERE T.CARDNO = P_CARDNO;
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006002000';
      P_RETMSG := '写入业务台账主表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
      
  END;
  
  -- 9) 删除开通功能表
  BEGIN
    V_COUNT := 0;
    SELECT COUNT(*) INTO V_COUNT FROM TF_F_CUST_ACCT WHERE ICCARD_NO = P_CARDNO;
    IF V_COUNT < 1 THEN
        BEGIN
              DELETE FROM TF_F_CARDUSEAREA
              WHERE CARDNO = P_CARDNO
              AND FUNCTIONTYPE = '14';
             IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
            EXCEPTION
              WHEN OTHERS THEN
                P_RETCODE := 'S00509B003';
                P_RETMSG := '删除开通功能失败,' || SQLERRM;
                ROLLBACK;
                RETURN;
        END;
    END IF;
  END;

  P_RETCODE := '0000000000';
  P_RETMSG := '';
  COMMIT;
  RETURN;
END;

/
  SHOW ERROR;
