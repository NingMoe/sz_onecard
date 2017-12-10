-- =============================================
-- AUTHOR:		LIUHE
-- CREATE DATE: 2011-06-22
-- DESCRIPTION:	联机账户账户充值存储过程
-- =============================================
CREATE OR REPLACE PROCEDURE SP_CA_CHARGE_nocom
(
    P_ACCID                 CHAR,         --账户标识
    P_CARDNO                CHAR,         --卡号
    P_SUPPLYMONEY           CHAR,         --充值金额
    P_NEEDTRADEFEE          CHAR DEFAULT '1',    -- 是否需要记录现金台帐
    P_TRADETYPECODE         CHAR DEFAULT '8Y',   -- 台账业务类型
    P_CURROPER              CHAR,         --当前操作者
    P_CURRDEPT              CHAR,         --当前操作者部门
    p_TRADEID               OUT CHAR,
    P_RETCODE               OUT CHAR,     --错误编码
    P_RETMSG                OUT VARCHAR2  --错误信息
)
AS
    v_TOTAL_SUPPLY_TIMES  INT;
    V_ACCID           NUMBER;
    V_PAYMENT_ID      varchar(16);
    V_ACCT_BALANCE_ID NUMBER;
    V_PREMONEY          INT;
    V_SEQ              CHAR(16);
    V_TODAY           DATE := SYSDATE;
    V_EX              EXCEPTION;
BEGIN
    V_ACCID := to_number(P_ACCID);

    -- 1)写入台账主表

    BEGIN
    SP_GETSEQ(SEQ => V_SEQ);
    p_TRADEID := V_SEQ;
    V_PAYMENT_ID := V_SEQ;

    --SELECT TF_F_BALANCE_PAYIN_SEQ.NEXTVAL INTO V_PAYMENT_ID FROM DUAL;
    --SP_GETTRADEID(SEQNAME  => 'TF_F_BALANCE_PAYIN_SEQ',TRADEID => V_PAYMENT_ID);

    SELECT REL_BALANCE INTO V_PREMONEY FROM TF_F_CUST_ACCT
    WHERE ICCARD_NO = P_CARDNO AND ACCT_ID = V_ACCID ;

        INSERT INTO TF_B_TRADE
            (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CURRENTMONEY  ,   PREMONEY, NEXTMONEY,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        SELECT
            V_SEQ,V_PAYMENT_ID,P_TRADETYPECODE,P_CARDNO,T.ASN,T.CARDTYPECODE,  P_SUPPLYMONEY ,  V_PREMONEY, TO_NUMBER(P_SUPPLYMONEY) + V_PREMONEY,
            P_CURROPER,P_CURRDEPT,V_TODAY
         FROM TF_F_CARDREC T WHERE T.CARDNO=P_CARDNO;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S001002119';
              P_RETMSG  := '写入业务台账主表失败' || SQLERRM;
              ROLLBACK; RETURN;

    END;

    BEGIN

       INSERT INTO TF_B_TRADE_ACCOUNT
            (TRADEID,ACCTID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CURRENTMONEY,PREMONEY, NEXTMONEY,
             OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        SELECT
            V_SEQ,V_ACCID,V_PAYMENT_ID,P_TRADETYPECODE,P_CARDNO,T.ASN,T.CARDTYPECODE,P_SUPPLYMONEY,V_PREMONEY,TO_NUMBER(P_SUPPLYMONEY) + V_PREMONEY,
            P_CURROPER,P_CURRDEPT,V_TODAY
         FROM TF_F_CARDREC T WHERE T.CARDNO=P_CARDNO;
       EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S006002000';
              P_RETMSG  := '写入专有账户业务台账主表失败' || SQLERRM;
              ROLLBACK; RETURN;

    END;

    -- 2)写入现金台账表
     BEGIN
       IF P_NEEDTRADEFEE = '1' THEN
         BEGIN
                INSERT INTO TF_B_TRADEFEE
                    (ID,TRADEID,TRADETYPECODE,CARDNO,PREMONEY,
                SUPPLYMONEY,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
                VALUES
                    (V_PAYMENT_ID,V_SEQ,P_TRADETYPECODE,P_CARDNO,V_PREMONEY,
                    P_SUPPLYMONEY,P_CURROPER,P_CURRDEPT,V_TODAY);

            EXCEPTION
                  WHEN OTHERS THEN
                      P_RETCODE := 'S001002114';
                      P_RETMSG  := 'ERROR OCCURRED WHILE LOG THE OPERATION' || SQLERRM;
                      ROLLBACK; RETURN;
         END;
      END IF;
    END;

    --写入余额账本充值记录表
    BEGIN
    	    SELECT ACCT_BALANCE_ID
					INTO V_ACCT_BALANCE_ID
					FROM TF_F_ACCT_BALANCE
					WHERE  ICCARD_NO = P_CARDNO AND ACCT_ID = V_ACCID;

    		  INSERT INTO TF_F_BALANCE_PAYIN
		    		  (
			    		   PAYIN_ID, 		  ACCT_BALANCE_ID, 		OPERATE_TYPE, 	AMOUNT,     	  BALANCE,
			    		   STAFFNO,    		OPERATETIME,     		STATECODE,      UPDATETIME, 	  ORDER_NO,
			    		   CANCEL_TAG
		    		  )
    		  VALUES
    		  		(
	    		  		 V_PAYMENT_ID,	V_ACCT_BALANCE_ID,  'A',         		P_SUPPLYMONEY,  V_PREMONEY + P_SUPPLYMONEY,
	    		  		 P_CURROPER,    V_TODAY,     			'1',            V_TODAY,        V_PAYMENT_ID,
	    		  		 '0'
    		  		);
    		  EXCEPTION
          WHEN OTHERS THEN
          P_RETCODE := 'S006001125';
          P_RETMSG  := '写入余额账本充值记录表失败' || SQLERRM;
          ROLLBACK; RETURN;
    END;

    -- 5)更新余额账本表
    BEGIN
          UPDATE  TF_F_ACCT_BALANCE
          SET  BALANCE = BALANCE + P_SUPPLYMONEY
          WHERE  ICCARD_NO = P_CARDNO AND ACCT_ID = V_ACCID;

          IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S006001123';
              P_RETMSG  := '更新余额账本表失败' || SQLERRM;
             ROLLBACK; RETURN;
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
        WHERE ICCARD_NO = P_CARDNO AND ACCT_ID = V_ACCID;

    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S006001124';
              P_RETMSG  := '写入客户账户历史表失败' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 7)更新客户账户表
    BEGIN
        UPDATE  TF_F_CUST_ACCT
          SET   ACCT_BALANCE = ACCT_BALANCE + P_SUPPLYMONEY,
                REL_BALANCE = REL_BALANCE + P_SUPPLYMONEY,
                LAST_SUPPLY_TIME = V_TODAY,
                TOTAL_SUPPLY_MONEY = TOTAL_SUPPLY_MONEY + P_SUPPLYMONEY,
                TOTAL_SUPPLY_TIMES = TOTAL_SUPPLY_TIMES + 1
                WHERE  ICCARD_NO = P_CARDNO AND ACCT_ID = V_ACCID;
          IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S006001123';
              P_RETMSG  := '更新客户账户表失败' || SQLERRM;
             ROLLBACK; RETURN;
    END;

    -- 3) Determine whether the recharge is the first time
		BEGIN
		    SELECT TOTAL_SUPPLY_TIMES INTO v_TOTAL_SUPPLY_TIMES
		    FROM  TF_F_CUST_ACCT WHERE ACCT_ID = V_ACCID;

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
		        WHERE  ACCT_ID = V_ACCID;

		        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
				EXCEPTION
			        WHEN OTHERS THEN
			            p_retCode := 'S001002113';
			            p_retMsg  := 'S001002113:Update failure';
			            ROLLBACK; RETURN;
		    END;
    END IF;

  P_RETCODE := '0000000000';
  P_RETMSG  := '';
  RETURN;
END;
/
SHOW ERROR
