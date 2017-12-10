  -- =============================================
  -- AUTHOR:    董翔
  -- CREATE DATE: 2011-08-04
  -- DESCRIPTION:  联机账户特殊调账 
  -- =============================================
 CREATE OR REPLACE PROCEDURE SP_CA_SPEADJUSTACC
(
  P_CARDNO      VARCHAR2,    --卡号
  P_TRADEID     VARCHAR2,    --特殊调账流水号
  P_CURROPER    CHAR,        -- Current Operator
  P_CURRDEPT    CHAR,        -- Current Operator's Department
  P_RETCODE     OUT CHAR,    -- Return Code
  P_RETMSG      OUT VARCHAR2 -- Return Message
) AS
  V_TODAY           DATE := SYSDATE;
  V_PREMONEY        INT;
  V_SUPPLYMONEY     INT;
  V_PAYMENT_ID      varchar(16);
  V_ACCT_BALANCE_ID INT;
  V_SEQ             CHAR(16);
  V_EX              EXCEPTION;
  V_ACCT_TYPE       VARCHAR2(8);
  V_ACCID           NUMBER;
BEGIN
  BEGIN
    -- 1) 计算调账总额
    SELECT SUM(REFUNDMENT)
      INTO V_SUPPLYMONEY
      FROM TF_B_ACCT_SPEADJUSTACC
     WHERE ICCARD_NO = P_CARDNO
       AND TRADEID = P_TRADEID;
   IF V_SUPPLYMONEY is null OR V_SUPPLYMONEY  <= 0 THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006022011';
      P_RETMSG := '计算调账总额失败' || SQLERRM ;
      ROLLBACK;
      RETURN;
  END;
  
  BEGIN
     --查询账户类型
     SELECT ACCT_TYPE_NO INTO V_ACCT_TYPE FROM TF_B_ACCT_SPEADJUSTACC
     WHERE ICCARD_NO = P_CARDNO
       AND TRADEID = P_TRADEID;
     IF V_ACCT_TYPE is null OR V_ACCT_TYPE  = '' THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006022013';
      P_RETMSG := '查询账户类型失败' || SQLERRM ;
      ROLLBACK;
      RETURN;
  END;

  -- 2)写入台账主表

  BEGIN
    SP_GETSEQ(SEQ => V_SEQ);
    
    --SELECT TF_F_BALANCE_PAYIN_SEQ.NEXTVAL INTO V_PAYMENT_ID FROM DUAL;
    V_PAYMENT_ID := V_SEQ;
    --SP_GETTRADEID(SEQNAME  => 'TF_F_BALANCE_PAYIN_SEQ',TRADEID => V_PAYMENT_ID);
    
    SELECT REL_BALANCE,ACCT_ID
      INTO V_PREMONEY,V_ACCID
      FROM TF_F_CUST_ACCT
     WHERE ICCARD_NO = P_CARDNO AND ACCT_TYPE_NO = V_ACCT_TYPE;

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
             '8V',
             P_CARDNO,
             T.ASN,
             T.CARDTYPECODE,
             V_SUPPLYMONEY,
             V_PREMONEY,
             P_CURROPER,
             P_CURRDEPT,
             V_TODAY
        FROM TF_F_CARDREC T
       WHERE T.CARDNO = P_CARDNO;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006022010';
      P_RETMSG := '写入业务台账主表失败' || SQLERRM;
      ROLLBACK;
      RETURN;

  END;
  
  --写入余额账本充值记录表
    BEGIN
    		  INSERT INTO TF_F_BALANCE_PAYIN
		    		  (
			    		   PAYIN_ID, 		  ACCT_BALANCE_ID, 	OPERATE_TYPE, 	AMOUNT,     	  
			    		   STAFFNO,    		OPERATETIME,     	STATECODE,      UPDATETIME, 	  ORDER_NO
		    		  )
    		  VALUES
    		  		(
	    		  		 V_PAYMENT_ID,	V_ACCID,          'C',         		V_SUPPLYMONEY,  
	    		  		 P_CURROPER,    V_TODAY,     			'1',            V_TODAY,        V_PAYMENT_ID              
    		  		);
    		  EXCEPTION
          WHEN OTHERS THEN
          P_RETCODE := 'S006001125';
          P_RETMSG  := '写入余额账本充值记录表失败' || SQLERRM;
          ROLLBACK; RETURN;				
    END;
  
  /*-- 2)写入付款记录表
  BEGIN

    INSERT INTO TF_F_PAYMENT
      (PAYMENT_ID,
       ACCT_BALANCE_ID,
       PAYMENT_METHOD_ID,
       OPERATION_TYPE,
       AMOUNT,
       STATE,
       STATE_DATE,
       PAYMENT_DATE,
       CREATED_DATE,
       SOURCE_TYPE)
    VALUES
      (V_PAYMENT_ID,
       V_ACCID,
       '1',
       'A',
       V_SUPPLYMONEY,
       'B',
       V_TODAY,
       V_TODAY,
       V_TODAY,
       'C' --退款
       );
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001121';
      P_RETMSG := '写入付款记录表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 3) 写入余额来源
  BEGIN
    SELECT ACCT_BALANCE_ID
      INTO V_ACCT_BALANCE_ID
      FROM TF_F_ACCT_BALANCE
     WHERE ICCARD_NO = P_CARDNO AND ACCT_TYPE_NO = V_ACCT_TYPE;

    INSERT INTO BALANCE_SOURCE
      (OPERATE_INCOME_ID,
       ACCT_BALANCE_ID,
       OPERATE_TYPE,
       STAFF_ID,
       OPER_DATE,
       AMOUNT,
       SOURCE_TYPE,
       STATE,
       STATE_DATE,
       ALLOW_DRAW_FLAG,
       PAYMENT_ID)
    VALUES
      (V_PAYMENT_ID,
       V_ACCT_BALANCE_ID,
       'C',
       P_CURROPER,
       V_TODAY,
       V_SUPPLYMONEY,
       'C', 
       'A',
       V_TODAY,
       'N',
       V_PAYMENT_ID);
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001122';
      P_RETMSG := '写入余额来源记录表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;
 */
 
  -- 5)更新余额账本表
  BEGIN
    UPDATE TF_F_ACCT_BALANCE
       SET BALANCE = BALANCE + V_SUPPLYMONEY
     WHERE ICCARD_NO = P_CARDNO AND ACCT_TYPE_NO = V_ACCT_TYPE;

    IF SQL%ROWCOUNT != 1 THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001123';
      P_RETMSG := '更新余额账本表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 6)写入客户账户历史表
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
      P_RETMSG := '写入客户账户表历史表' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 7)更新客户账户表
  BEGIN
    UPDATE TF_F_CUST_ACCT
       SET ACCT_BALANCE = ACCT_BALANCE + V_SUPPLYMONEY,
           REL_BALANCE  = REL_BALANCE + V_SUPPLYMONEY
     WHERE ICCARD_NO = P_CARDNO AND ACCT_TYPE_NO = V_ACCT_TYPE;
    IF SQL%ROWCOUNT != 1 THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001123';
      P_RETMSG := '更新客户账户表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  --8更新特殊调账录入表
  BEGIN
    UPDATE TF_B_ACCT_SPEADJUSTACC
       SET STATECODE   = '2',
           SUPPTRADEID = V_SEQ,
           SUPPSTAFFNO = P_CURROPER,
           SUPPTIME    = V_TODAY,
           CHECKTIME   = V_TODAY
     WHERE ICCARD_NO = P_CARDNO
       AND TRADEID = P_TRADEID;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006022012';
      P_RETMSG := '更新特殊调账录入表失败' || SQLERRM;
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
