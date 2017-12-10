-- =============================================
-- AUTHOR:		LIUHE
-- CREATE DATE: 2011-06-24
-- DESCRIPTION:	联机账户圈存存储过程
--修改 殷华荣  增加账户标识字段
-- =============================================
CREATE OR REPLACE PROCEDURE SP_CA_FONTCHARGE
(
    P_CARDNO                CHAR,         --卡号
    P_ACCID                 CHAR,         --账户标识
    P_ID	                  CHAR,		      --TF_SUPPLY_REALTIME表ID
    P_CARDTRADENO	          CHAR,		      --交易序号
    P_CARDMONEY	            INT,		      --卡上余额
	  P_CARDACCMONEY	        INT,		      --卡账户余额
    P_ASN	                  CHAR,		      --ASN
	  P_CARDTYPECODE	        CHAR,		      --卡类型编码
    P_OPERCARDNO	          CHAR,		      --操作员卡号
    P_SUPPLYMONEY           INT,          --充值金额
    P_CURROPER              CHAR,         --当前操作者
    P_CURRDEPT              CHAR,         --当前操作者部门
    P_RETCODE               OUT CHAR,     --错误编码
    P_RETMSG                OUT VARCHAR2  --错误信息
)
AS
    v_TOTAL_LOAD_TIMES INT;
    V_SEQ              CHAR(16);
    V_TODAY            DATE := SYSDATE;
    V_EX               EXCEPTION;
	  V_ACCT_BALANCE_ID  NUMBER;
	  V_REL_BALANCE      INT;
	  V_PAYOUT_ID 	     NUMBER;
    V_ACCID            NUMBER;
BEGIN
  
    V_ACCID := TO_NUMBER(P_ACCID); 
    
    -- 1) 取台账序号
    SP_GETSEQ(SEQ => V_SEQ);
	
	  

    -- 2) 更新电子钱包账户 SP_PB_UPDATEACC
    SP_PB_UPDATEACC (P_ID, P_CARDNO,
    P_CARDTRADENO, P_CARDMONEY, P_CARDACCMONEY, V_SEQ,
    P_ASN, P_CARDTYPECODE, P_SUPPLYMONEY, '8H', '112233445566', V_TODAY,
    P_CURROPER, P_CURRDEPT,P_RETCODE, P_RETMSG);

    IF P_RETCODE != '0000000000' THEN
    ROLLBACK; RETURN;
      END IF;
    
    -- 3)更新余额账本表
    BEGIN
          UPDATE  TF_F_ACCT_BALANCE
          SET  BALANCE = BALANCE - P_SUPPLYMONEY
          WHERE  ICCARD_NO = P_CARDNO AND ACCT_ID = V_ACCID;

          IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S006001123';
              P_RETMSG  := '更新余额账本表失败' || SQLERRM;
             ROLLBACK; RETURN;
    END;

    -- 4)写入客户账户历史表
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

    -- 5)更新客户账户表
    BEGIN
	SELECT REL_BALANCE INTO V_REL_BALANCE FROM TF_F_CUST_ACCT WHERE ACCT_ID = V_ACCID;
	
        UPDATE  TF_F_CUST_ACCT
          SET  ACCT_BALANCE = ACCT_BALANCE - P_SUPPLYMONEY,
               REL_BALANCE = REL_BALANCE - P_SUPPLYMONEY,
               TOTAL_LOAD_TIMES = TOTAL_LOAD_TIMES + 1,                
               TOTAL_LOAD_MONEY = TOTAL_LOAD_MONEY + P_SUPPLYMONEY,
               LAST_LOAD_TIME = V_TODAY
         WHERE ACCT_ID = V_ACCID;
         
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S006001125';
              P_RETMSG  := '更新客户账户表失败' || SQLERRM;
             ROLLBACK; RETURN;
    END;
    
    -- 3) Determine whether the recharge is the first time
		BEGIN
		    SELECT TOTAL_LOAD_TIMES INTO v_TOTAL_LOAD_TIMES
		    FROM  TF_F_CUST_ACCT WHERE ACCT_ID = V_ACCID;

    EXCEPTION
				    WHEN NO_DATA_FOUND THEN
				    p_retCode := 'A001002112';
				    p_retMsg  := 'A001002112:Can not find the record or Error';
				    ROLLBACK; RETURN;
    END;
    
    -- 4) for the first time
    IF v_TOTAL_LOAD_TIMES = 1 THEN
		    BEGIN
		        UPDATE TF_F_CUST_ACCT
		        SET  FIRST_LOAD_TIME = V_TODAY
		        WHERE  ACCT_ID = V_ACCID;

		        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
				EXCEPTION
			        WHEN OTHERS THEN
			            p_retCode := 'S001002113';
			            p_retMsg  := 'S001002113:Update failure';
			            ROLLBACK; RETURN;
		    END;
    END IF;

    -- 6)写入台账主表
    BEGIN
        INSERT INTO TF_B_TRADE
            (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CURRENTMONEY  ,   PREMONEY, NEXTMONEY,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        SELECT
            V_SEQ,V_SEQ,'8H',P_CARDNO,T.ASN,T.CARDTYPECODE,  P_SUPPLYMONEY ,V_REL_BALANCE,P_SUPPLYMONEY + V_REL_BALANCE,
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
            (TRADEID,ACCTID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CURRENTMONEY  ,PREMONEY, NEXTMONEY,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        SELECT
            V_SEQ,V_ACCID,V_SEQ,'8H',P_CARDNO,T.ASN,T.CARDTYPECODE,  P_SUPPLYMONEY ,V_REL_BALANCE,P_SUPPLYMONEY + V_REL_BALANCE,
            P_CURROPER,P_CURRDEPT,V_TODAY
         FROM TF_F_CARDREC T WHERE T.CARDNO=P_CARDNO;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S006002000';
              P_RETMSG  := '写入专有账户业务台账主表失败' || SQLERRM;
              ROLLBACK; RETURN;     
    
    END;

    -- 7) 写卡台账
	BEGIN
		INSERT INTO TF_CARD_TRADE
				(TRADEID,TRADETYPECODE,STROPERCARDNO,STRCARDNO,LMONEY,LOLDMONEY,STRTERMNO,
				CARDTRADENO,OPERATETIME,SUCTAG)
		VALUES
				(V_SEQ,'8H',P_OPERCARDNO,P_CARDNO,P_SUPPLYMONEY,P_CARDMONEY,
				'112233445566',P_CARDTRADENO,V_TODAY,'0');

	EXCEPTION
		WHEN OTHERS THEN
			P_RETCODE := 'S001001139';
			P_RETMSG  := '写入写卡台账表失败' || SQLERRM;
			ROLLBACK; RETURN;
    END;

	-- 8)余额支出记录表
	BEGIN
		SELECT ACCT_BALANCE_ID
		INTO V_ACCT_BALANCE_ID
		FROM TF_F_ACCT_BALANCE
		WHERE  ICCARD_NO = P_CARDNO AND ACCT_ID = V_ACCID;
		 	
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
		   'B', --圈存
		   P_CURROPER,
		   V_TODAY,
		   P_SUPPLYMONEY,
		   V_REL_BALANCE - P_SUPPLYMONEY,
		   '1', --有效
		   V_TODAY
		   );
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001122';
      P_RETMSG := '写入余额支出记录表失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  P_RETCODE := '0000000000';
  P_RETMSG  := '';
  COMMIT; RETURN;
END;

/
SHOW ERROR
