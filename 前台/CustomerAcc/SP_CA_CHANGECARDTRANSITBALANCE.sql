/*
		企服卡换卡补账户
*/
CREATE OR REPLACE PROCEDURE SP_CA_CHANGECARDTRANSITBALANCE
(
  P_OCARDNO  NUMBER,      --旧卡卡号
  P_ICARDNO  NUMBER,      --新卡卡号
  p_TRADEORIGIN varchar2, --业务来源
  P_CURROPER CHAR,        --当前操作者
  P_CURRDEPT CHAR,        --当前操作者部门
  P_RETCODE  OUT CHAR,    --错误编码
  P_RETMSG   OUT VARCHAR2,--错误信息
  p_TRADEID  out char,    -- Return Trade Id
  P_PWD      VARCHAR2     --初始密码
) 
AS
  V_OCARDNO CHAR(16);     --旧卡卡号
  V_ICARDNO CHAR(16);     --新卡卡号
  V_IACCT_ID NUMBER;      --新卡帐号
  V_OACCT_ID NUMBER;      --旧卡账号
  V_PAYMENT_ID varchar(16);
  V_PREMONEY INT;
  
  V_ACCT_BALANCE_ID INT;   --旧卡余额账本ID
  V_ACCT_BALANCE_NEW_ID INT;   --新卡余额账本ID
  
  V_ACCT_BALANCE INT;
  V_REL_BALANCE INT;
  V_SEQ CHAR(16);
  V_ACCT_ITEM_ID CHAR(30);
  V_TODAY DATE := SYSDATE;
  V_QUANTITY_A INT;
  V_QUANTITY_B INT;
  V_EX EXCEPTION;
  v_CORPNO         char(4);  --集团客户号
  V_COUNT INT := 0;
  
  V_PAPERTYPECODE   VARCHAR2(2);    --证件类型
  V_PAPERNO         VARCHAR2(200);   --证件号码
  V_CUSTNAME        VARCHAR2(250);  --客户姓名
  V_CUSTSEX         VARCHAR2(2);    --性别
  V_CUSTBIRTH       VARCHAR2(8);    --生日
  V_CUSTADDR        VARCHAR2(600);  --地址
  V_CUSTPOST        VARCHAR2(6);    --邮编
  V_CUSTPHONE       VARCHAR2(200);   --手机
  V_CUSTTELPHONE    VARCHAR2(200);   --固话
  V_CUSTEMAIL       VARCHAR2(30);   --邮箱
  
  V_CUST_ID NUMBER; --客户ID
  v_quantity  int;
  v_TOTAL_SUPPLY_TIMES  INT;
BEGIN
  
  --校验旧卡是否开通了联机账户
    BEGIN
        SELECT 1 INTO v_quantity FROM TF_F_CUST_ACCT A   
        WHERE A.ICCARD_NO = P_OCARDNO
        AND   A.STATE = 'A' ;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_retCode := 'A004P08B04'; p_retMsg  := '旧卡未开通联机账户或账户状态无效';
        RETURN;
    END;
	
    --校验新卡是否是售出状态
    BEGIN
        SELECT 1 INTO v_quantity 
        FROM   TF_F_CARDREC 
        WHERE  CARDNO = P_ICARDNO
        AND    USETAG = '1' 
		    AND    CARDSTATE IN ('10', '11');
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_retCode := 'A004P08B05'; p_retMsg  := '新卡不是已售出状态';
            RETURN;
    END;
  
  --循环遍历旧卡的账户类型 如果新卡没有对应的账户类型，则新卡自动开户
  FOR V_CUR IN (select * from tf_f_cust_acct A where A.ICCARD_NO = P_OCARDNO AND A.STATE = 'A')  
    LOOP
         V_COUNT := 0;
         select count(*) into V_COUNT FROM tf_f_cust_acct WHERE ICCARD_NO = P_ICARDNO AND ACCT_TYPE_NO = V_CUR.acct_type_no;
         IF V_COUNT = 0 THEN  --没有开户
            BEGIN
		            --获取旧卡的客户标识
		            SELECT CUST_ID INTO V_CUST_ID FROM  TF_F_CUST_ACCT WHERE ACCT_ID = V_CUR.ACCT_ID;
		            --获取旧卡的客户信息
		            SELECT PAPER_TYPE_CODE,PAPER_NO,CUST_NAME,CUST_SEX,CUST_BIRTH,CUST_ADDR,CUST_POST,CUST_PHONE,CUST_TELPHONE,CUST_EMAIL
		            INTO V_PAPERTYPECODE,V_PAPERNO,V_CUSTNAME,V_CUSTSEX,V_CUSTBIRTH,V_CUSTADDR,V_CUSTPOST,V_CUSTPHONE,V_CUSTTELPHONE,V_CUSTEMAIL
		            FROM TF_F_CUST WHERE CUST_ID = V_CUST_ID;
		            EXCEPTION
		            	WHEN NO_DATA_FOUND THEN
		            		P_RETCODE := 'S006023019';
	            			P_RETMSG := '没有找到旧卡客户信息' || SQLERRM;
	            			ROLLBACK;
		           			RETURN;
            END;
            --系统自动开户
            BEGIN
                SP_CA_OPENACC(P_ICARDNO,  --新卡卡号
                        V_CUR.acct_type_no, --账户类型
                        V_CUSTNAME,
                        V_CUSTBIRTH,
                        V_PAPERTYPECODE,
                        V_PAPERNO,
                        V_CUSTSEX,
                        V_CUSTPHONE,
                        V_CUSTTELPHONE,
                        V_CUSTPOST,
                        V_CUSTADDR,
                        V_CUSTEMAIL,
                        '0',
                        P_PWD,
                        '0',
                        '0',
                        P_CURROPER,
                        P_CURRDEPT,
                        P_RETCODE,
                        P_RETMSG);
                IF P_RETCODE != '0000000000' THEN
                  ROLLBACK;
                  RAISE V_EX;
                END IF;
                EXCEPTION
                  WHEN OTHERS THEN
                    ROLLBACK;
                    RETURN;        
            END;
         END IF;
         
        --查询出新卡的账户标识
        SELECT  ACCT_ID INTO V_IACCT_ID FROM TF_F_CUST_ACCT WHERE ICCARD_NO = P_ICARDNO AND ACCT_TYPE_NO = V_CUR.ACCT_TYPE_NO;
        --查询出旧卡账户标识
        SELECT ACCT_ID INTO V_OACCT_ID FROM TF_F_CUST_ACCT WHERE ICCARD_NO = P_OCARDNO AND ACCT_TYPE_NO = V_CUR.ACCT_TYPE_NO;
        --查出旧卡集团客户号
        BEGIN
	        SELECT CORPNO INTO v_CORPNO FROM TD_GROUP_ACCT WHERE ACCT_ID = V_OACCT_ID ;
	        --新卡建立账户集团客户关系
	           BEGIN
	           		INSERT INTO TD_GROUP_ACCT (ACCT_ID,CORPNO,USETAG) VALUES (V_IACCT_ID,v_CORPNO,'1');
	           		EXCEPTION WHEN OTHERS THEN
	           			P_RETCODE := 'S006023016';
            			P_RETMSG := '写入账户集团客户表失败' || SQLERRM;
            			ROLLBACK;
	           			RETURN;
	           END;
	        --删除旧卡账户集团客户关系
	          BEGIN
	             UPDATE TD_GROUP_ACCT SET USETAG = '0' WHERE ACCT_ID = V_OACCT_ID;
	             IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	             EXCEPTION WHEN OTHERS THEN
	           			P_RETCODE := 'S006023017';
            			P_RETMSG := '修改账户集团客户表失败' || SQLERRM;
            			ROLLBACK;
	           			RETURN;
	          END;
	        EXCEPTION
	           WHEN NO_DATA_FOUND THEN NULL;
        END;
        
        -- 1)写入新卡客户账户历史表
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
             WHERE ACCT_ID = V_CUR.ACCT_ID
             AND   STATE = 'A';

        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023012';
            P_RETMSG := '写入客户账户历史主表失败' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        -- 2)更新旧卡客户账户表
        BEGIN
          SELECT ACCT_BALANCE, REL_BALANCE
            INTO V_ACCT_BALANCE, V_REL_BALANCE
            FROM TF_F_CUST_ACCT
           WHERE ACCT_ID = V_CUR.ACCT_ID
           AND   STATE = 'A';

          UPDATE TF_F_CUST_ACCT
             SET ACCT_BALANCE = 0, REL_BALANCE = 0, STATE = 'X'
           WHERE ACCT_ID = V_CUR.ACCT_ID
           AND   STATE = 'A';
          IF SQL%ROWCOUNT != 1 THEN
            RAISE V_EX;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023013';
            P_RETMSG := '更新客户账户表失败' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        -- 3)更新旧卡余额账本表
        BEGIN
          
          UPDATE TF_F_ACCT_BALANCE
             SET BALANCE = 0, STATE = 'X'
           WHERE ACCT_ID = V_CUR.ACCT_ID
           AND   STATE = 'A';

          IF SQL%ROWCOUNT != 1 THEN
            RAISE V_EX;
          END IF;
          
          EXCEPTION
            WHEN OTHERS THEN
              P_RETCODE := 'S006023014';
              P_RETMSG := '更新余额账本表失败' || SQLERRM;
              ROLLBACK;
              RETURN;
        END;

        -- 5)写入旧卡余额支出记录表
        BEGIN
        	SP_GETSEQ(SEQ => V_SEQ);
          
          SELECT ACCT_BALANCE_ID
            INTO V_ACCT_BALANCE_ID
            FROM TF_F_ACCT_BALANCE
           WHERE ACCT_ID = V_CUR.ACCT_ID
           AND   STATE = 'X';

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
             'D', --扣
             P_CURROPER,
             V_TODAY,
             V_REL_BALANCE,
             '0',
             '1', --有效
             V_TODAY
             );
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023015';
            P_RETMSG := '写入余额支出记录表失败' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        -- 6)写入台账主表
        BEGIN
          
          p_TRADEID := V_SEQ;
          SELECT REL_BALANCE
            INTO V_PREMONEY
            FROM TF_F_CUST_ACCT
           WHERE ACCT_ID = V_CUR.ACCT_ID
           AND   STATE = 'X';

          SELECT ICCARD_NO
            INTO V_OCARDNO
            FROM TF_F_CUST_ACCT
           WHERE ACCT_ID = V_CUR.ACCT_ID
           AND   STATE = 'X';

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
             OPERATETIME,
             TRADEORIGIN)
            SELECT V_SEQ,
                   V_SEQ,
                   '8P',
                   V_OCARDNO,
                   T.ASN,
                   T.CARDTYPECODE,
                   -V_REL_BALANCE,
                   V_PREMONEY,
                   P_CURROPER,
                   P_CURRDEPT,
                   V_TODAY,
                   p_TRADEORIGIN
              FROM TF_F_CARDREC T
             WHERE T.CARDNO = V_OCARDNO;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023017';
            P_RETMSG := '写入业务台账主表失败' || SQLERRM;
            ROLLBACK;
            RETURN;
            
        END;
        --记账户台账
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
             OPERATETIME
             )
            SELECT V_SEQ,
                   V_CUR.ACCT_ID,
                   V_SEQ,
                   '8P',
                   V_OCARDNO,
                   T.ASN,
                   T.CARDTYPECODE,
                   -V_REL_BALANCE,
                   V_PREMONEY,
                   P_CURROPER,
                   P_CURRDEPT,
                   V_TODAY
              FROM TF_F_CARDREC T
             WHERE T.CARDNO = V_OCARDNO;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023030';
            P_RETMSG := '写入账户业务台账主表失败' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        -- 7)写入新卡台账主表

        BEGIN
          
          --SELECT TF_F_BALANCE_PAYIN_SEQ.NEXTVAL INTO V_PAYMENT_ID FROM DUAL;
          V_PAYMENT_ID := V_SEQ;
          --SP_GETTRADEID(SEQNAME  => 'TF_F_BALANCE_PAYIN_SEQ',TRADEID => V_PAYMENT_ID);
          
          SELECT REL_BALANCE
            INTO V_PREMONEY
            FROM TF_F_CUST_ACCT
           WHERE ACCT_ID = V_IACCT_ID
           AND   STATE = 'A';

          SELECT ICCARD_NO
            INTO V_ICARDNO
            FROM TF_F_CUST_ACCT
           WHERE ACCT_ID = V_IACCT_ID
           AND   STATE = 'A';

          INSERT INTO TF_B_TRADE
            (TRADEID,
             ID,
             TRADETYPECODE,
             CARDNO,
             OLDCARDNO,
             ASN,
             CARDTYPECODE,
             CURRENTMONEY,
             PREMONEY,
             OPERATESTAFFNO,
             OPERATEDEPARTID,
             OPERATETIME,
             TRADEORIGIN)
            SELECT V_SEQ,
                   V_PAYMENT_ID,
                   '8P',
                   V_ICARDNO,
                   P_OCARDNO,
                   T.ASN,
                   T.CARDTYPECODE,
                   V_REL_BALANCE,
                   V_PREMONEY,
                   P_CURROPER,
                   P_CURRDEPT,
                   V_TODAY,
                   p_TRADEORIGIN
              FROM TF_F_CARDREC T
             WHERE T.CARDNO = V_ICARDNO;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023018';
            P_RETMSG := '写入业务台账主表失败' || SQLERRM;
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
             OLDCARDNO,
             ASN,
             CARDTYPECODE,
             CURRENTMONEY,
             PREMONEY,
             OPERATESTAFFNO,
             OPERATEDEPARTID,
             OPERATETIME)
            SELECT V_SEQ,
                   V_IACCT_ID,
                   V_PAYMENT_ID,
                   '8P',
                   V_ICARDNO,
                   P_OCARDNO,
                   T.ASN,
                   T.CARDTYPECODE,
                   V_REL_BALANCE,
                   V_PREMONEY,
                   P_CURROPER,
                   P_CURRDEPT,
                   V_TODAY
              FROM TF_F_CARDREC T
             WHERE T.CARDNO = V_ICARDNO;
            EXCEPTION
              WHEN OTHERS THEN
                P_RETCODE := 'S006023027';
                P_RETMSG := '写入业务台账主表失败' || SQLERRM;
                ROLLBACK;
                RETURN;

          END;
          
				--写入余额账本充值记录表
		    BEGIN
		    	    SELECT ACCT_BALANCE_ID INTO V_ACCT_BALANCE_NEW_ID
              FROM TF_F_ACCT_BALANCE
              WHERE ACCT_ID = V_IACCT_ID
              AND   STATE = 'A';
		    		  INSERT INTO TF_F_BALANCE_PAYIN
				    		  (
					    		   PAYIN_ID, 		  ACCT_BALANCE_ID, 	OPERATE_TYPE, 	AMOUNT,         BALANCE,
					    		   STAFFNO,    		OPERATETIME,     	STATECODE,      UPDATETIME, 	  ORDER_NO
				    		  )
		    		  VALUES
		    		  		(
			    		  		 V_PAYMENT_ID,	V_ACCT_BALANCE_NEW_ID,       'D',         		V_REL_BALANCE,  V_REL_BALANCE + V_PREMONEY,
			    		  		 P_CURROPER,    V_TODAY,     			'1',            V_TODAY,        V_PAYMENT_ID               
		    		  		);
		    		  EXCEPTION
		          WHEN OTHERS THEN
		          P_RETCODE := 'S006001125';
		          P_RETMSG  := '写入余额账本充值记录表失败' || SQLERRM;
		          ROLLBACK; RETURN;				
		    END;

        -- 10)更新转入卡余额账本表
        BEGIN
          UPDATE TF_F_ACCT_BALANCE
             SET BALANCE = BALANCE + V_REL_BALANCE
           WHERE ACCT_ID = V_IACCT_ID
           AND   STATE = 'A';

          IF SQL%ROWCOUNT != 1 THEN
            RAISE V_EX;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023021';
            P_RETMSG := '更新余额账本表失败' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        -- 11)写入转入卡客户账户历史表
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
             WHERE ACCT_ID = V_IACCT_ID
             AND   STATE = 'A';

        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023022';
            P_RETMSG := '写入客户账户历史主表失败' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        -- 12)更新转入卡客户账户表
        BEGIN
          UPDATE TF_F_CUST_ACCT
             SET ACCT_BALANCE       = ACCT_BALANCE + V_ACCT_BALANCE,
                 REL_BALANCE        = REL_BALANCE + V_REL_BALANCE,
                 LAST_SUPPLY_TIME   = V_TODAY,
                 TOTAL_SUPPLY_MONEY = TOTAL_SUPPLY_MONEY + V_REL_BALANCE,
                 TOTAL_SUPPLY_TIMES = TOTAL_SUPPLY_TIMES + 1
           WHERE ACCT_ID = V_IACCT_ID
           AND   STATE = 'A';
          IF SQL%ROWCOUNT != 1 THEN
            RAISE V_EX;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023023';
            P_RETMSG := '更新客户账户表失败' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;
        
        -- 3) Determine whether the recharge is the first time
				BEGIN
				    SELECT TOTAL_SUPPLY_TIMES INTO v_TOTAL_SUPPLY_TIMES
				    FROM  TF_F_CUST_ACCT WHERE ACCT_ID = V_IACCT_ID;
		
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
				        WHERE  ACCT_ID = V_IACCT_ID;
		
				        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
						EXCEPTION
					        WHEN OTHERS THEN
					            p_retCode := 'S001002113';
					            p_retMsg  := 'S001002113:Update failure';
					            ROLLBACK; RETURN;
				    END;
		    END IF;
        
        

        --13)旧卡退款处理
        BEGIN
          SP_GETITEMID(ITEMID  => V_ACCT_ITEM_ID,
                P_ICCARDNO => V_OCARDNO,
                P_SAMNO    => '000000000000');
                
          
          
          SELECT COUNT(*) INTO V_QUANTITY_A FROM TF_B_ACCT_SPEADJUSTACC WHERE ICCARD_NO = V_OCARDNO;
          
          UPDATE TF_B_ACCT_SPEADJUSTACC
             SET ICCARD_NO = V_ICARDNO
           WHERE ICCARD_NO = V_OCARDNO;
           
           IF SQL%ROWCOUNT != V_QUANTITY_A THEN RAISE V_EX; END IF;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023024';
            P_RETMSG := '更新特殊调账录入表失败' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        --14)旧卡消费欠费处理 --插入新纪录
        BEGIN
          INSERT INTO TF_F_ACCT_ITEM_OWE
            (ID,
             ACCT_ID,
             ACCT_TYPE,
             CONSUME_TYPE,
             TRADE_NO,
             ACCT_TYPE_NO,
             ICCARD_NO,
             ICCARD_PARTITION_ID,
             CARD_TRADE_NO,
             ORDER_NO,
             TRADE_CHARGE,
             TRADE_DATE,
             DEALTIME,
             STATE,
             CANCEL_TAG,
             STATE_DATE,
             POSNO,
             SAMNO,
             BALUNITNO,
             RSRV_FEE,
             RSRV_INFO)
            SELECT V_ACCT_ITEM_ID,
                   V_IACCT_ID,
                   ACCT_TYPE,
                   CONSUME_TYPE,
                   TRADE_NO,
                   ACCT_TYPE_NO,
                   V_ICARDNO,
                   ICCARD_PARTITION_ID,
                   CARD_TRADE_NO,
                   ORDER_NO,
                   TRADE_CHARGE,
                   TRADE_DATE,
                   DEALTIME,
                   STATE,
                   CANCEL_TAG,
                   STATE_DATE,
                   POSNO,
                   SAMNO,
                   BALUNITNO,
                   RSRV_FEE,
                   RSRV_INFO
              FROM TF_F_ACCT_ITEM_OWE
             WHERE STATE = 'A'
               AND ACCT_ID = V_CUR.ACCT_ID;
        EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S006023025';
            P_RETMSG := '插入消费欠费帐目表失败' || SQLERRM;
            ROLLBACK;
            RETURN;
        END;

        --15)旧卡消费欠费处理 --更新旧纪录
        BEGIN
          
          SELECT COUNT(*) INTO V_QUANTITY_B FROM TF_F_ACCT_ITEM_OWE WHERE STATE = 'A' AND ACCT_ID = V_CUR.ACCT_ID;
          
          UPDATE TF_F_ACCT_ITEM_OWE
             SET STATE = 'X'
           WHERE STATE = 'A'
           AND ACCT_ID = V_CUR.ACCT_ID;
           
           IF SQL%ROWCOUNT != V_QUANTITY_B THEN RAISE V_EX; END IF;
          EXCEPTION WHEN OTHERS THEN P_RETCODE := 'S006023026';
          P_RETMSG := '更新消费欠费帐目表失败' || SQLERRM;
          ROLLBACK;
          RETURN;
        END;
        
    END LOOP;
    
    --关闭旧卡与联机账户功能项的关联关系
    BEGIN
        UPDATE TF_F_CARDUSEAREA 
		    SET    USETAG = '0',  
               UPDATESTAFFNO = p_currOper, 
			         UPDATETIME = v_today
        WHERE  CARDNO = P_OCARDNO 
		    AND    FUNCTIONTYPE = '14';
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P08B09'; p_retMsg  := '关闭旧卡与企服卡功能项的关联关系失败,' || SQLERRM;
            RETURN;
    END;

  P_RETCODE := '0000000000';
  P_RETMSG := '';
  RETURN;
  
END;

/
  SHOW ERROR;
