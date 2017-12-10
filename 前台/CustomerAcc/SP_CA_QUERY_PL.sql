  -- =============================================
  -- AUTHOR:   LIUHE
  -- CREATE DATE: 2011-06-23
  -- DESCRIPTION:  联机账户查询存储过程
  -- 修改: 2013-01-25 殷华荣 批量充值 增加卡号排序 
  -- =============================================
  CREATE OR REPLACE PROCEDURE SP_CA_QUERY
(
  P_FUNCCODE VARCHAR2,
  P_VAR1     VARCHAR2,
  P_VAR2     VARCHAR2,
  P_VAR3     VARCHAR2,
  P_VAR4     VARCHAR2,
  P_VAR5     VARCHAR2,
  P_VAR6     VARCHAR2,
  P_VAR7     VARCHAR2,
  P_VAR8     IN OUT VARCHAR2,
  P_VAR9     IN OUT VARCHAR2,
  P_CURSOR   OUT SYS_REFCURSOR
) AS
  V_INT INT;
  V_F0 VARCHAR2(256);
BEGIN
  IF P_FUNCCODE = 'QRYBLOCK' THEN
    OPEN P_CURSOR FOR
      SELECT AC.ICCARD_NO 用户卡号,
             C.CUST_NAME 姓名,
             DECODE(C.CUST_SEX, '0', '男', '1', '女', C.CUST_SEX) 性别,
             C.PAPER_NO 证件号码,
             DECODE(AC.STATE,
                    'A',
                    '有效',
				           	'B',
                    '冻结',
                    'X',
                    '注销',
                    'H',
                    '已归档',
                    'F',
                    '挂失',
                    AC.STATE) 状态,
             AC.REL_BALANCE / 100 余额
        FROM TF_F_CUST C, TF_F_CUST_ACCT AC
       WHERE C.CUST_ID = AC.CUST_ID
         AND (P_VAR1 IS NULL OR P_VAR1 = AC.ICCARD_NO)
         AND (P_VAR2 IS NULL OR P_VAR2 = C.PAPER_NO)
       ORDER BY C.CREATE_DATE DESC;
  ELSIF P_FUNCCODE = 'QUERYCUSTBIZ_CA' THEN
    --查询客户业务
    OPEN P_CURSOR FOR
      SELECT A.TRADEID 流水号,
             A.OPERATETIME 操作时间,
             B.TRADETYPE 类型,
             A.PREMONEY / 100.0 交易前￥,
             A.CURRENTMONEY / 100.0 交易金额￥,
             D.STAFFNAME 操作员,
             C.DEPARTNAME 部门
        FROM TF_B_TRADE        A,
             TD_M_TRADETYPE    B,
             TD_M_INSIDEDEPART C,
             TD_M_INSIDESTAFF  D
       WHERE A.CARDNO = P_VAR1
         AND A.OPERATETIME BETWEEN TO_DATE(P_VAR2, 'YYYYMMDD') AND
             TO_DATE(P_VAR3, 'YYYYMMDD') + 1
         AND A.TRADETYPECODE = B.TRADETYPECODE
         AND A.OPERATEDEPARTID = C.DEPARTNO(+)
         AND A.OPERATESTAFFNO = D.STAFFNO(+)
         AND ((B.TRADETYPECODE >= '8E'AND B.TRADETYPECODE <= '8Z')
		 OR (B.TRADETYPECODE >= 'L1'AND B.TRADETYPECODE <= 'L9'))
       ORDER BY A.OPERATETIME DESC, A.ID DESC;
  ELSIF P_FUNCCODE = 'QUERYSUPPLYCONSUMEINFO_CA' THEN
    OPEN P_CURSOR FOR
        SELECT
             '充值' 业务类型, 
             TO_CHAR(B.ACCT_ID) 账户ID,
             TO_CHAR(PA.PAYIN_ID) 流水号,
             PA.AMOUNT / 100.00   金额￥,
             SF.STAFFNAME 操作员工,
             PA.OPERATETIME 操作时间,
             '' 消费地点,
             '' POS机号,
             '' 状态,
             '' 处理状态
        FROM TF_F_ACCT_BALANCE B,
             TF_F_BALANCE_PAYIN PA,
             /*BALANCE_SOURCE    S,
             TF_F_PAYMENT      P,*/
             TD_M_INSIDESTAFF  SF
       WHERE B.ACCT_BALANCE_ID = PA.ACCT_BALANCE_ID
         AND PA.STAFFNO = SF.STAFFNO
         --AND S.PAYMENT_ID = P.PAYMENT_ID
         AND B.ICCARD_NO = P_VAR1
		 AND PA.OPERATETIME BETWEEN TO_DATE(P_VAR2, 'YYYYMMDD') AND
             TO_DATE(P_VAR3, 'YYYYMMDD') + 1
             
        UNION ALL 
        
        SELECT
             decode(O.CONSUME_TYPE,'A','消费','B','消费撤销','C','退货',O.CONSUME_TYPE) 业务类型,
             '' 账户ID,
             TO_CHAR(O.ORDER_NO) 流水号,
             O.TRADE_CHARGE / 100.00 金额￥,
             '' 操作员工,
             O.Trade_Date 操作时间,
             (CASE B.BALUNITTYPECODE
               WHEN '00' THEN
                CA.CALLING
               WHEN '01' THEN
                CORP.CORP
               WHEN '02' THEN
                DEPT.DEPART
               ELSE
                B.BALUNITTYPECODE
             END) 消费地点,
             O.POSNO POS机号,
             (CASE O.STATE
               WHEN 'A' THEN '未下帐'
               WHEN 'B' THEN '已下帐'
               WHEN 'C' THEN '已个人结算'
               WHEN 'D' THEN '已商户结算'
               WHEN 'E' THEN '已销账'
               WHEN 'F' THEN '单边帐'
						   WHEN 'G' THEN '单边帐销账'
							 WHEN 'X' THEN '换卡后原记录注销'
               ELSE
                O.STATE
             END) 状态,
             (CASE O.DEAL_STATE
                WHEN 'A' THEN '消费'
                WHEN 'B' THEN '撤销'
                WHEN 'C' THEN '退货'
                WHEN 'D' THEN '冲正'
                ELSE O.DEAL_STATE
                END) 处理状态
        FROM TF_F_ACCT_ITEM_OWE O,
             TF_TRADE_BALUNIT   B,
             TD_M_CALLINGNO     CA,
             TD_M_CORP          CORP,
             TD_M_DEPART        DEPT
       WHERE O.BALUNITNO = B.BALUNITNO
	     AND O.ICCARD_NO = P_VAR1
         AND B.CALLINGNO = CA.CALLINGNO(+)
         AND B.CORPNO = CORP.CORPNO(+)
         AND B.DEPARTNO = DEPT.DEPARTNO(+)
		 AND O.Trade_Date BETWEEN TO_DATE(P_VAR2, 'YYYYMMDD') AND
             TO_DATE(P_VAR3, 'YYYYMMDD') + 1
       ORDER BY 6 DESC;
  
  ELSIF P_FUNCCODE = 'QUERYSUPPLYINFO_CA' THEN
    --查询充值信息
    OPEN P_CURSOR FOR
      SELECT TO_CHAR(B.ACCT_ID) 账户ID,
             TO_CHAR(PA.PAYIN_ID) 余额来源流水,
             PA.AMOUNT / 100.00 充值金额￥,
             SF.STAFFNAME 操作员工,
             PA.OPERATETIME 充值时间
        FROM TF_F_ACCT_BALANCE B,
             TF_F_BALANCE_PAYIN PA,
             /*BALANCE_SOURCE    S,
             TF_F_PAYMENT      P,*/
             TD_M_INSIDESTAFF  SF
       WHERE B.ACCT_BALANCE_ID = PA.ACCT_BALANCE_ID
         AND PA.STAFFNO = SF.STAFFNO
         --AND S.PAYMENT_ID = P.PAYMENT_ID
         AND B.ICCARD_NO = P_VAR1
		 AND PA.OPERATETIME BETWEEN TO_DATE(P_VAR2, 'YYYYMMDD') AND
             TO_DATE(P_VAR3, 'YYYYMMDD') + 1
       ORDER BY PA.OPERATETIME DESC;
  
  ELSIF P_FUNCCODE = 'QUERYFONTCHARGEINFO' THEN
   --查询圈存信息
   OPEN P_CURSOR FOR
   SELECT    B.ICCARD_NO 卡号,
             cus.corpname 单位,
             PA.AMOUNT / 100.00 圈存金额￥,
             SF.STAFFNAME 操作员工,
             PA.OPERATETIME 充值时间
        FROM TF_F_ACCT_BALANCE B,
             TF_F_BALANCE_PAYOUT PA,
             TD_M_INSIDESTAFF  SF,
             td_group_acct tg,
             td_group_customer cus
        WHERE B.ACCT_BALANCE_ID = PA.ACCT_BALANCE_ID
         AND PA.STAFFNO = SF.STAFFNO
         AND B.ICCARD_NO = P_VAR1
         AND PA.OPERATETIME BETWEEN TO_DATE(P_VAR2, 'YYYYMMDD') AND TO_DATE(P_VAR3, 'YYYYMMDD') + 1
         AND PA.OPERATE_TYPE = 'B' --圈存
         and B.ACCT_ID = tg.acct_id
         and tg.corpno = cus.corpcode
       ORDER BY PA.OPERATETIME DESC;
  
  ELSIF P_FUNCCODE = 'QUERYCONSUMEINFO_CA' THEN
    --查询账户消费
    OPEN P_CURSOR FOR
      SELECT 
      			 decode(O.CONSUME_TYPE,'A','消费','B','消费撤销','C','退货',O.CONSUME_TYPE) 业务类型,
      			 TO_CHAR(O.ORDER_NO) 消费流水,
             O.TRADE_CHARGE / 100.00 消费金额,
             O.Trade_Date 消费时间,
             (CASE B.BALUNITTYPECODE
               WHEN '00' THEN CA.CALLING
               WHEN '01' THEN CORP.CORP
               WHEN '02' THEN DEPT.DEPART
               ELSE B.BALUNITTYPECODE
              END) 消费地点,
             O.POSNO POS机号,
             (CASE O.STATE
               WHEN 'A' THEN '未下帐'
               WHEN 'B' THEN '已下帐'
               WHEN 'C' THEN '已个人结算'
               WHEN 'D' THEN '已商户结算'
               WHEN 'E' THEN '已销账'
               WHEN 'F' THEN '单边帐'
						   WHEN 'G' THEN '单边帐销账'
							 WHEN 'X' THEN '换卡后原记录注销'
               ELSE O.STATE
              END) 状态,
              (CASE O.DEAL_STATE
                WHEN 'A' THEN '消费'
                WHEN 'B' THEN '撤销'
                WHEN 'C' THEN '退货'
                WHEN 'D' THEN '冲正'
                ELSE O.DEAL_STATE
                END) 处理状态
        FROM TF_F_ACCT_ITEM_OWE O,
             TF_TRADE_BALUNIT   B,
             TD_M_CALLINGNO     CA,
             TD_M_CORP          CORP,
             TD_M_DEPART        DEPT
       WHERE O.BALUNITNO = B.BALUNITNO
	     AND O.ICCARD_NO = P_VAR1
         AND B.CALLINGNO = CA.CALLINGNO(+)
         AND B.CORPNO = CORP.CORPNO(+)
         AND B.DEPARTNO = DEPT.DEPARTNO(+)
		 AND O.Trade_Date BETWEEN TO_DATE(P_VAR2, 'YYYYMMDD') AND
             TO_DATE(P_VAR3, 'YYYYMMDD') + 1
       ORDER BY O.Trade_Date DESC;
       
    --检查批量充值状态
  ELSIF P_FUNCCODE = 'InvalidBatchCharge' THEN
    OPEN P_CURSOR FOR
      SELECT CARDNO
        FROM TMP_CA_BATCHCHARGEFILE A
       WHERE A.SESSIONID = P_VAR1
         AND A.F1 <> 'OK';

         
         
  -- 查询批量充值帐户
  ELSIF P_FUNCCODE = 'ShowBatchCharge' THEN
    DECLARE
        V_CUSTNAME TF_F_CUST.CUST_NAME%type;
        V_PAPERNO  TF_F_CUST.PAPER_NO%TYPE;
        V_ACCTID   TF_F_CUST_ACCT.ACCT_ID%TYPE;
        V_CUSTID   TF_F_CUST_ACCT.CUST_ID%TYPE;
        V_MSG VARCHAR2(600) := '';
        V_F1 CHAR(1) := '1';  --0：不允许提交充值  1: 允许提交充值
    BEGIN
    	 FOR V_CUR IN 
    	 (
	    	 SELECT A.CARDNO,A.ACCT_ID, A.CUSTNAME,A.PAPER_NO
	       FROM TMP_CA_BATCHCHARGEFILE A
	       WHERE SESSIONID = P_VAR1 
    	 )
    	 LOOP
    	    V_F0 := NULL;
    	    V_MSG := NULL;
    	    V_F1 := '1';
    	    BEGIN
		    	 		SELECT T.ACCT_ID , T.CUST_ID INTO V_ACCTID , V_CUSTID 
		    	 		FROM  TF_F_CUST_ACCT T 
		    	 		WHERE T.ICCARD_NO = V_CUR.CARDNO AND T.ACCT_TYPE_NO = V_CUR.ACCT_ID 
		    	 		AND T.STATE IN ('A','F');
		    	 		BEGIN
				    	 		SELECT CUST_NAME ,PAPER_NO INTO V_CUSTNAME , V_PAPERNO 
				    	 		FROM TF_F_CUST C WHERE C.CUST_ID = V_CUSTID;
				    	 		IF V_CUSTNAME IS NOT NULL THEN
				    	 			IF (V_CUR.CUSTNAME IS NULL OR V_CUR.CUSTNAME != V_CUSTNAME) THEN
				    	 			   V_MSG := V_MSG || '姓名不符 ';
					    	 	  END IF;
					    	  END IF;
					    	  IF V_PAPERNO IS NOT NULL THEN
										IF (V_CUR.PAPER_NO IS NULL OR V_CUR.PAPER_NO != V_PAPERNO) THEN
										   V_MSG := V_MSG || '证件号码不符 ';
					    	 	  END IF;
				    	 	  END IF;
				    	 	  V_F0 := V_MSG;
				    	 	  EXCEPTION	 
				    	 		WHEN NO_DATA_FOUND THEN
				    	 		   V_F0 := '未找到卡片客户信息';
		    	 	  END;
		    	 		EXCEPTION	 
		    	 		WHEN NO_DATA_FOUND THEN
		    	 		   V_F0 := '未找到卡片账户信息';
		    	 		   V_F1 := '0'; --未找到卡片账户信息 不允许提交
    	 		END;
    	 		IF V_F0 IS NULL THEN
    	 			V_F0 := 'OK';
    	 		END IF;
    	 		UPDATE  TMP_CA_BATCHCHARGEFILE SET F1 = V_F0,F2 = V_F1
		    	WHERE SESSIONID = P_VAR1  AND CARDNO = V_CUR.CARDNO AND ACCT_ID = V_CUR.ACCT_ID;
    	 END LOOP;
    END;
  	OPEN P_CURSOR
    FOR
      SELECT A.F1,A.F2, A.CARDNO,A.CUSTNAME,A.PAPER_NO, 
      A.ACCT_ID || ':' || B.ACCT_TYPE_NAME ACCT_TYPE_NO, A.CHARGEAMOUNT / 100.0 CHARGEAMOUNT
      FROM TMP_CA_BATCHCHARGEFILE A,TF_F_ACCT_TYPE_INFO B
      WHERE SESSIONID = P_VAR1 AND A.ACCT_ID = B.ACCT_TYPE_NO order by A.F1 desc,A.CARDNO;
      
    --查询批量充值待审批批次
  ELSIF P_FUNCCODE = 'ChargeBatchNo' THEN
    OPEN P_CURSOR FOR
      SELECT ID, ID FROM TF_F_SUPPLYSUM WHERE STATECODE = '0';
    --查询批量充值审批明细
  ELSIF P_FUNCCODE = 'ChargeAprv' THEN
    OPEN P_CURSOR FOR
      SELECT T.CARDNO,T.ACCT_TYPE_NO || ':' || B.ACCT_TYPE_NAME ACCT_TYPE_NO, T.SUPPLYMONEY / 100.0 SUPPLYMONEY
        FROM TF_F_SUPPLY T,TF_F_ACCT_TYPE_INFO B
       WHERE T.ID = P_VAR1 AND T.ACCT_TYPE_NO = B.ACCT_TYPE_NO;
    --查询批量充值审批总额
  ELSIF P_FUNCCODE = 'ChargeAprvTotal' THEN
    OPEN P_CURSOR FOR
      SELECT T.AMOUNT, T.SUPPLYMONEY / 100.0
        FROM TF_F_SUPPLYSUM T
       WHERE T.ID = P_VAR1;
    --查询批量充值财务审批
  ELSIF P_FUNCCODE = 'ChargeFiItems' THEN
    OPEN P_CURSOR FOR
      SELECT T.ID,
             S3.CORPNAME,
             T.AMOUNT,
             T.SUPPLYMONEY / 100.0 SUPPLYMONEY,
             T.SUPPLYTIME,
             S2.STAFFNAME SUPPLYSTAFFNAME,
             T.CHECKTIME,
             S.STAFFNAME
        FROM TF_F_SUPPLYSUM T, TD_M_INSIDESTAFF S, TD_M_INSIDESTAFF S2, Td_Group_Customer S3
       WHERE T.CHECKSTAFFNO = S.STAFFNO
         AND T.SUPPLYSTAFFNO = S2.STAFFNO
         AND T.CORPNO = S3.CORPCODE(+)
         AND T.STATECODE = '1';
  ELSIF P_FUNCCODE = 'QRYRECOVER' THEN
    --抹帐-查询充值记录
    OPEN P_CURSOR FOR
      SELECT A.ID,
             C.TRADETYPE,
             A.SUPPLYMONEY / 100.0 SUPPLYMONEY,
             A.PREMONEY / 100.0 PREMONEY,
             A.OPERATETIME,
             B.STAFFNAME,
             E.CANCELTAG
        FROM TF_B_TRADEFEE    A,
             TD_M_INSIDESTAFF B,
             TD_M_TRADETYPE   C,
             TF_B_TRADE       E,
             TF_B_TRADE_ACCOUNT F
       WHERE A.CARDNO = P_VAR1
         AND A.OPERATETIME BETWEEN TRUNC(SYSDATE, 'dd') AND SYSDATE
         AND A.TRADETYPECODE = '8Y'
         AND B.STAFFNO(+) = A.OPERATESTAFFNO
         AND C.TRADETYPECODE = A.TRADETYPECODE
         AND E.TRADEID = A.TRADEID
         AND A.TRADEID = F.TRADEID
         AND F.ACCTID = P_VAR2
       ORDER BY A.OPERATETIME DESC;
  ELSIF P_FUNCCODE = 'BatchOpenAccChecks' THEN
    DECLARE
        V_CUST_NAME   VARCHAR2(250);
        V_CUST_SEX    VARCHAR2(2);
        V_CUST_BIRTH  NVARCHAR2(8);
        V_PAPER_TYPE_CODE VARCHAR2(2);
        V_PAPER_NO   VARCHAR2(200);
        V_CUST_ADDR  VARCHAR2(600);
        V_CUST_POST  VARCHAR2(6);
        V_CUST_PHONE VARCHAR2(200);
        V_CUST_TELEPHONE VARCHAR2(200);
        V_CUST_EMAIL VARCHAR2(30);
        V_MSG VARCHAR2(600) := '';
        V_F1 CHAR(1); --0: 比对小额客户信息  1: 专有账户客户信息
        V_F2 CHAR(1) := '1'; --0：不允许提交开户  1: 允许提交开户
    BEGIN
    --检查批量开户临时表
    FOR V_C IN (SELECT F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,F14 FROM TMP_COMMON WHERE F13 = P_VAR1) LOOP
      V_F0 := NULL;
      V_MSG := NULL;
      V_F2 := '1';
      BEGIN
        -- 1) 检查卡片是否已经开通联机帐户
        SELECT 1 INTO V_INT FROM TF_F_CUST_ACCT WHERE ICCARD_NO = V_C.F1 AND ACCT_TYPE_NO = V_C.F14;
        V_F0 := '已开通相同类型账户,不允许提交';
        V_F2 := '0';
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          BEGIN
          	    --检查是否已开通其它类型的账户
          	    SELECT COUNT(1) INTO V_INT FROM TF_F_CUST_ACCT WHERE ICCARD_NO = V_C.F1;
          	    IF V_INT > 0 THEN
          	    BEGIN
		          	    --已开通其它类型账户,和专有账户资料比对
		          	    SELECT CUST_NAME,			CUST_SEX,			CUST_BIRTH,			   PAPER_TYPE_CODE,			PAPER_NO,			
		          	           CUST_ADDR,     CUST_POST,    CUST_PHONE,        CUST_TELPHONE,      CUST_EMAIL 
		          	    INTO   V_CUST_NAME,   V_CUST_SEX,   V_CUST_BIRTH,      V_PAPER_TYPE_CODE,   V_PAPER_NO,   
		          	           V_CUST_ADDR,   V_CUST_POST,  V_CUST_PHONE,      V_CUST_TELEPHONE,    V_CUST_EMAIL
		          	    FROM TF_F_CUST WHERE ICCARD_NO = V_C.F1;
		          	    IF V_CUST_NAME is not null THEN       --验证姓名
		          	    	 IF (V_C.F2 is null or V_CUST_NAME != V_C.F2) THEN
		          	    	 		V_MSG := V_MSG || '姓名不符 ';
		          	     	 END IF;
		          	    END IF; 
		          	    IF V_CUST_SEX is not null THEN        --验证性别
		          	    	 IF (V_C.F3 is null or V_CUST_SEX != V_C.F3) THEN
		          	    	 		V_MSG := V_MSG || '性别不符 ';
		          	    	 END IF; 
		          	    END IF;
		          	    IF V_CUST_BIRTH is not null THEN
		          	    	IF (V_C.F4 IS NULL OR V_CUST_BIRTH != V_C.F4) THEN
		          	    		 V_MSG := V_MSG || '出生日期不符 ';
		          	    	END IF;
		          	    END IF;
		          	    IF V_PAPER_TYPE_CODE is not null THEN
		          	    	IF (V_C.F5 IS NULL OR V_PAPER_TYPE_CODE != V_C.F5) THEN
		          	    		 V_MSG := V_MSG || '证件类型不符 ';
		          	    	END IF;
		          	    END IF;
		          	    IF V_PAPER_NO is not null THEN
		          	    	IF (V_C.F6 IS NULL OR V_PAPER_NO != V_C.F6) THEN
		          	    		 V_MSG := V_MSG || '证件号码不符 ';
		          	    	END IF;
		          	    END IF;
		          	    IF V_CUST_ADDR is not null THEN
		          	    	IF (V_C.F7 is null or V_CUST_ADDR <> V_C.F7) THEN
		          	    		 V_MSG := V_MSG || '地址不符 ';
		          	    	END IF;
		          	    END IF;
		          	    IF V_CUST_POST is not null THEN
		          	    	IF (V_C.F8 IS NULL OR V_CUST_POST != V_C.F8) THEN
		          	    		 V_MSG := V_MSG || '邮编不符 ';
		          	    	END IF;
		          	    END IF;
		          	    IF V_CUST_PHONE is not null THEN
		          	    	IF (V_C.F9 IS NULL OR V_CUST_PHONE != V_C.F9) THEN
		          	    		 V_MSG := V_MSG || '手机号不符 ';
		          	    	END IF;
		          	    END IF;
		          	    IF V_CUST_TELEPHONE is not null THEN
		          	    	IF (V_C.F10 IS NULL OR V_CUST_TELEPHONE != V_C.F10) THEN
		          	    		 V_MSG := V_MSG || '固定电话不符 ';
		          	    	END IF;
		          	    END IF;
		          	    IF V_CUST_EMAIL is not null THEN
		          	    	IF (V_C.F11 IS NULL OR V_CUST_EMAIL != V_C.F11) THEN
		          	    		 V_MSG := V_MSG || '邮件地址不符 ';
		          	    	END IF;
		          	    END IF;
		          	    V_F0 := V_MSG;
		          	    V_F1 := '1'; --比对专有账户客户信息
		          	    IF V_F0 IS NOT NULL THEN
		          	      V_F0 := V_F0 || ' 不允许提交';
		          	    	V_F2 := '0'; --比对结果有误,不允许提交开户
		          	    END IF;
		          	    EXCEPTION
		          	      WHEN NO_DATA_FOUND THEN
		          	         V_F0 := '未找到专有账户客户信息';
          	    END;
          	    ELSE --没有开通任何类型账户
          	    	  BEGIN
          	    	  	  -- 2) 检查卡片是否已经售卡
							          SELECT 1 INTO V_INT FROM TF_F_CARDREC
							          WHERE CARDNO = V_C.F1 AND CARDSTATE IN ('10', '11');
							          --已售卡,和小额客户资料比对
							          BEGIN
							          	SELECT 
							          					CUSTNAME, 	 CUSTSEX,	    CUSTBIRTH,	  PAPERTYPECODE,	
							          					PAPERNO,	   CUSTADDR,	  CUSTPOST,	    CUSTPHONE,	    CUSTEMAIL
							          	INTO
							          		      V_CUST_NAME, V_CUST_SEX,  V_CUST_BIRTH, V_PAPER_TYPE_CODE,
							          		      V_PAPER_NO,  V_CUST_ADDR, V_CUST_POST,  V_CUST_PHONE,   V_CUST_EMAIL
							            FROM TF_F_CUSTOMERREC WHERE CARDNO = V_C.F1;
							            IF V_CUST_NAME is not null THEN       --验证姓名
					          	    	 IF (V_C.F2 IS NULL OR V_CUST_NAME != V_C.F2) THEN
					          	    	 		V_MSG := V_MSG || '姓名不符 ';
					          	     	 END IF;
							          	END IF; 
							          	IF V_CUST_SEX is not null THEN        --验证性别
							          	   IF (V_C.F3 IS NULL OR V_CUST_SEX != V_C.F3) THEN
							          	    	V_MSG := V_MSG || '性别不符 ';
							          	   END IF; 
							          	END IF;
							          	IF V_CUST_BIRTH is not null THEN
							          	   IF (V_C.F4 IS NULL OR V_CUST_BIRTH != V_C.F4) THEN
							          	      V_MSG := V_MSG || '出生日期不符 ';
							          	   END IF;
							          	END IF;
							          	IF V_PAPER_TYPE_CODE is not null THEN
							          	   IF (V_C.F5 IS NULL OR V_PAPER_TYPE_CODE != V_C.F5) THEN
							          	    	V_MSG := V_MSG || '证件类型不符 ';
							          	   END IF;
							          	END IF;
							          	IF V_PAPER_NO is not null THEN
							          	   IF (V_C.F6 IS NULL OR V_PAPER_NO != V_C.F6) THEN
							          	    	V_MSG := V_MSG || '证件号码不符 ';
							          	   END IF;
							          	END IF;
							          	IF V_CUST_ADDR is not null THEN
							          	   IF (V_C.F7 IS NULL OR V_CUST_ADDR != V_C.F7) THEN
							          	    	V_MSG := V_MSG || '地址不符 ';
							          	   END IF;
							          	END IF;
							          	IF V_CUST_POST is not null THEN
							          	   IF (V_C.F8 IS NULL OR V_CUST_POST != V_C.F8) THEN
							          	    	V_MSG := V_MSG || '邮编不符 ';
							          	   END IF;
							          	END IF;
							          	IF V_CUST_PHONE is not null THEN
							          	   IF (V_C.F9 IS NULL AND V_C.F10 IS NULL) THEN
							          	    	V_MSG := V_MSG || '联系电话不符 ';
							          	   ELSIF (V_C.F9 IS NOT NULL AND V_C.F10 IS NULL AND V_CUST_PHONE != V_C.F9 ) THEN
							          	      V_MSG := V_MSG || '联系电话不符 ';
							          	   ELSIF (V_C.F9 IS NULL AND V_C.F10 IS NOT NULL AND V_CUST_PHONE != V_C.F10 ) THEN
							          	      V_MSG := V_MSG || '联系电话不符 ';
							          	   ELSIF (V_C.F9 IS NOT NULL AND V_C.F10 IS NOT NULL AND V_CUST_PHONE != V_C.F9 AND V_CUST_PHONE != V_C.F10) THEN
							          	   		V_MSG := V_MSG || '联系电话不符 ';
							          	   END IF;
							          	END IF;
							          	IF V_CUST_EMAIL is not null THEN
							          	   IF V_CUST_EMAIL != V_C.F11 THEN
							          	    	V_MSG := V_MSG || '邮件地址不符 ';
							          	   END IF;
							          	END IF;
							          	V_F0 := V_MSG;
		          	   				V_F1 := '0'; --比对电子钱包客户信息
										      EXCEPTION
										         WHEN NO_DATA_FOUND THEN
										            V_F0 := '未找到电子钱包客户信息';
							          END;
							          EXCEPTION
							            WHEN NO_DATA_FOUND THEN
							              V_F0 := '卡片还未售出,不允许提交';
							              V_F2 := '0';
          	    	  END;
          	    END IF;
          END;
      END;
      IF V_F0 IS NULL THEN
        V_F0 := 'OK';
      END IF;
      UPDATE TMP_COMMON T SET T.F0 = V_F0,T.F15 = V_F1,T.F16 = V_F2 WHERE T.F1 = V_C.F1 AND T.F14 = V_C.F14 AND T.F13 = P_VAR1;
    END LOOP;
    END;
    OPEN P_CURSOR FOR
      SELECT F0  VALIDRET,
             F1  CARDNO,
             F2  CUSTNAME,
             DECODE(F3,'0','男','1','女',F3)  CUSTSEX,
             F4  CUSTBIRTH,
             P.PAPERTYPENAME  PAPERTYPE,
             F6  PAPERNO,
             F7  CUSTADDR,
             F8  CUSTPOST,
             F9  CUSTPHONE,
             F10 CUSTTEL,
             F11 CUSTEMAIL,
             F12 ISUPOLDCUS,
             TF.ACCT_TYPE_NAME ACCTTYPE,
             F15 RESULT1, 
             F16 RESULT2
        FROM TMP_COMMON,TF_F_ACCT_TYPE_INFO TF,TD_M_PAPERTYPE P
        WHERE F13 = P_VAR1 AND F14 = TF.ACCT_TYPE_NO(+) AND F5 = P.PAPERTYPECODE;
  
  ELSIF P_FUNCCODE = 'BadItems' THEN
    --查询批量开户临时表中不正确记录
    OPEN P_CURSOR FOR
      SELECT COUNT(1) FROM TMP_COMMON WHERE F1 not in (select iccard_no from tf_f_cust_acct) AND F13 = P_VAR1;
  
  ELSIF P_FUNCCODE = 'BadOpenItems' THEN
    --查询批量开户临时表中不正确记录
    OPEN P_CURSOR FOR
      SELECT COUNT(1) FROM TMP_COMMON WHERE F0 <> 'OK' AND F13 = P_VAR1;
      
  --批量修改资料信息    
  ELSIF P_FUNCCODE = 'BatchChangeCustInfoChecks' THEN
  DECLARE
        V_CUST_NAME   VARCHAR2(250);
        V_CUST_SEX    VARCHAR2(2);
        V_CUST_BIRTH  NVARCHAR2(8);
        V_PAPER_TYPE_CODE VARCHAR2(2);
        V_PAPER_NO   VARCHAR2(200);
        V_CUST_ADDR  VARCHAR2(600);
        V_CUST_POST  VARCHAR2(6);
        V_CUST_PHONE VARCHAR2(200);
        V_CUST_TELEPHONE VARCHAR2(200);
        V_CUST_EMAIL VARCHAR2(30);
        V_MSG VARCHAR2(600) := '';
        V_F2 CHAR(1) := '1'; --0：不允许提交开户  1: 允许提交开户
    BEGIN
    --检查批量修改资料临时表
    FOR V_C IN (SELECT F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F13 FROM TMP_COMMON WHERE F13 = P_VAR1) LOOP
      V_F0 := NULL;
      V_MSG := NULL;
      V_F2 := '1';
      BEGIN
        -- 1) 检查卡片是否已经开通联机帐户
        SELECT COUNT(1) INTO V_INT FROM TF_F_CUST_ACCT WHERE ICCARD_NO = V_C.F1;
        IF V_INT > 0 THEN
        BEGIN
        	--已开通其它类型账户,和专有账户资料比对
     	    SELECT CUST_NAME,			CUST_SEX,			CUST_BIRTH,			   PAPER_TYPE_CODE,			PAPER_NO,			
     	           CUST_ADDR,     CUST_POST,    CUST_PHONE,        CUST_TELPHONE,      CUST_EMAIL 
     	    INTO   V_CUST_NAME,   V_CUST_SEX,   V_CUST_BIRTH,      V_PAPER_TYPE_CODE,   V_PAPER_NO,   
     	           V_CUST_ADDR,   V_CUST_POST,  V_CUST_PHONE,      V_CUST_TELEPHONE,    V_CUST_EMAIL
     	    FROM TF_F_CUST WHERE ICCARD_NO = V_C.F1;
     	    IF V_CUST_NAME is not null THEN       --验证姓名
     	    	 IF (V_C.F2 is null or V_CUST_NAME != V_C.F2) THEN
     	    	 		V_MSG := V_MSG || '姓名 ';
     	     	 END IF;
     	    END IF; 
     	    IF V_CUST_SEX is not null THEN        --验证性别
     	    	 IF (V_C.F3 is null or V_CUST_SEX != V_C.F3) THEN
     	    	 		V_MSG := V_MSG || '性别 ';
     	    	 END IF; 
     	    END IF;
     	    IF V_CUST_BIRTH is not null THEN
     	    	IF (V_C.F4 IS NULL OR V_CUST_BIRTH != V_C.F4) THEN
     	    		 V_MSG := V_MSG || '出生日期 ';
     	    	END IF;
     	    END IF;
     	    IF V_PAPER_TYPE_CODE is not null THEN
     	    	IF (V_C.F5 IS NULL OR V_PAPER_TYPE_CODE != V_C.F5) THEN
     	    		 V_MSG := V_MSG || '证件类型 ';
     	    	END IF;
     	    END IF;
     	    IF V_PAPER_NO is not null THEN
     	    	IF (V_C.F6 IS NULL OR V_PAPER_NO != V_C.F6) THEN
     	    		 V_MSG := V_MSG || '证件号码 ';
     	    	END IF;
     	    END IF;
     	    IF V_CUST_ADDR is not null THEN
     	    	IF (V_C.F7 is null or V_CUST_ADDR <> V_C.F7) THEN
     	    		 V_MSG := V_MSG || '地址 ';
     	    	END IF;
     	    END IF;
     	    IF V_CUST_POST is not null THEN
     	    	IF (V_C.F8 IS NULL OR V_CUST_POST != V_C.F8) THEN
     	    		 V_MSG := V_MSG || '邮编 ';
     	    	END IF;
     	    END IF;
     	    IF V_CUST_PHONE is not null THEN
     	    	IF (V_C.F9 IS NULL OR V_CUST_PHONE != V_C.F9) THEN
     	    		 V_MSG := V_MSG || '手机号 ';
     	    	END IF;
     	    END IF;
     	    IF V_CUST_TELEPHONE is not null THEN
     	    	IF (V_C.F10 IS NULL OR V_CUST_TELEPHONE != V_C.F10) THEN
     	    		 V_MSG := V_MSG || '固定电话 ';
     	    	END IF;
     	    END IF;
     	    IF V_CUST_EMAIL is not null THEN
     	    	IF (V_C.F11 IS NULL OR V_CUST_EMAIL != V_C.F11) THEN
     	    		 V_MSG := V_MSG || '邮件地址 ';
     	    	END IF;
     	    END IF;
     	    IF V_MSG IS NOT NULL then
     	    	 V_MSG := '修改了' || V_MSG;
     	    END IF;
     	    V_F0 := V_MSG;
     	    EXCEPTION
     	      WHEN NO_DATA_FOUND THEN
     	         V_F0 := '未找到专有账户客户信息';
        END;
        ELSE 
          V_F0 := '卡片还未开通专有账户';
          V_F2 := '0';
        END IF;
      END;
      IF V_F0 IS NULL THEN
        V_F0 := 'OK';
      END IF;
      UPDATE TMP_COMMON T SET T.F0 = V_F0,T.F16 = V_F2 WHERE T.F1 = V_C.F1 AND T.F13 = P_VAR1;
    END LOOP;
    END;
    OPEN P_CURSOR FOR
      SELECT F0  VALIDRET,
             F1  CARDNO,
             F2  CUSTNAME,
             DECODE(F3,'0','男','1','女',F3)  CUSTSEX,
             F4  CUSTBIRTH,
             P.PAPERTYPENAME  PAPERTYPE,
             F6  PAPERNO,
             F7  CUSTADDR,
             F8  CUSTPOST,
             F9  CUSTPHONE,
             F10 CUSTTEL,
             F11 CUSTEMAIL,
             F16 RESULT1
        FROM TMP_COMMON,TD_M_PAPERTYPE P WHERE F13 = P_VAR1 AND F5 = P.PAPERTYPECODE;
		
  ELSIF P_FUNCCODE = 'SpeAdjustAccCheck' THEN
    --查询特殊调账待审信息
    OPEN P_CURSOR FOR
      SELECT TF.ICCARD_NO,
             TYPE.ACCT_TYPE_NAME,
             TF.CALLINGNO,
             TNO.CALLING CALLINGNAME,
             TF.CORPNO,
             TP.CORP CORPNAME,
             TF.DEPARTNO,
             TT.DEPART DEPARTNAME,
             TF.TRADETIME,
             TF.TRADEMONEY,
             TF.REFUNDMENT,
             TF.BROKERAGE,
             TF.STAFFNO,
             TI.STAFFNAME STAFFNAME,
             TF.OPERATETIME,
             (CASE
               WHEN (TF.REASONCODE = '1') THEN
                '隔日退货'
               WHEN (TF.REASONCODE = '2') THEN
                '交易成功,签购单未打印'
               WHEN (TF.REASONCODE = '3') THEN
                '交易不成功,扣款'
               WHEN (TF.REASONCODE = '4') THEN
                '多刷金额'
               WHEN (TF.REASONCODE = '5') THEN
                '其他'
             END) REASONCODE,
             TF.TRADEID,
             TF.CUSTPHONE CUSTPHONE,
             TF.CUSTNAME CUSTNAME
        FROM TF_B_ACCT_SPEADJUSTACC TF,
             TD_M_CALLINGNO         TNO,
             TD_M_CORP              TP,
             TD_M_DEPART            TT,
             TD_M_INSIDESTAFF       TI,
             TF_F_ACCT_TYPE_INFO    TYPE
       WHERE TF.CALLINGNO = TNO.CALLINGNO(+)
         AND TF.CORPNO = TP.CORPNO(+)
         AND TF.DEPARTNO = TT.DEPARTNO(+)
         AND TF.STAFFNO = TI.STAFFNO(+)
         AND TF.ACCT_TYPE_NO = TYPE.ACCT_TYPE_NO
         AND TF.STATECODE = '0'
         AND TF.OPERATEUSER = '0';
  ELSIF P_FUNCCODE = 'SpeAdjustAccQuery' THEN
    --查询待调账记录
    OPEN P_CURSOR FOR
      SELECT DECODE(TF.STATECODE,
                    '0',
                    '录入待审核',
                    '1',
                    '审核通过',
                    '2',
                    '已调帐充值',
                    '3',
                    '确认作废',
                    TF.STATECODE) 审核状态,
             TF.ICCARD_NO IC卡号,
             TNO.CALLING 行业,
             TP.CORP 单位,
             TT.DEPART 部门,
             TF.TRADETIME 交易日期,
             TF.TRADEMONEY / 100.0 交易￥,
             TF.REFUNDMENT / 100.0 退款￥,
             TF.BROKERAGE / 100.0 应退佣金￥,
             TF.STAFFNO || ':' || TI.STAFFNAME 录入员工,
             TF.OPERATETIME 录入时间,
             DECODE(TF.REASONCODE,
                    '1',
                    '隔日退货',
                    '2',
                    '交易成功,签购单未打印',
                    '3',
                    '交易不成功,扣款',
                    '4',
                    '多刷金额',
                    '5',
                    '其他',
                    TF.REASONCODE) 调账原因,
             TJ.STAFFNAME 充值员工,
             TF.SUPPTIME 充值时间,
             TF.CUSTPHONE 持卡人电话,
             TF.CUSTNAME 持卡人
        FROM TF_B_ACCT_SPEADJUSTACC TF,
             TD_M_CALLINGNO         TNO,
             TD_M_CORP              TP,
             TD_M_DEPART            TT,
             TD_M_INSIDESTAFF       TI,
             TD_M_INSIDESTAFF       TJ
       WHERE (P_VAR1 IS NULL OR P_VAR1 = TF.STATECODE)
         AND (P_VAR2 IS NULL OR P_VAR2 = TF.STAFFNO)
         AND (P_VAR3 IS NULL OR
             TF.OPERATETIME >= TO_DATE(P_VAR3, 'YYYYMMDD') AND
             TF.OPERATETIME < TO_DATE(P_VAR3, 'YYYYMMDD') + 1)
         AND (P_VAR4 IS NULL OR P_VAR4 = TF.ICCARD_NO)
         AND TF.CALLINGNO = TNO.CALLINGNO(+)
         AND TF.CORPNO = TP.CORPNO(+)
         AND TF.DEPARTNO = TT.DEPARTNO(+)
         AND TF.STAFFNO = TI.STAFFNO(+)
         AND TF.SUPPSTAFFNO = TJ.STAFFNO(+)
         AND TF.OPERATEUSER = 0
         AND ROWNUM < 1000;
	ELSIF P_FUNCCODE = 'SpeAdjustAccCheckMoney' THEN
	OPEN P_CURSOR FOR
	 SELECT SUM(REFUNDMENT) 
   FROM TF_B_ACCT_SPEADJUSTACC TF
   WHERE TF.ID =  P_VAR1
   AND TF.STATECODE IN ( '0','1','2');
   
	--根据身份证号查询卡号
	ELSIF P_FUNCCODE = 'QRYCARDNO'  THEN
		OPEN P_CURSOR FOR
		SELECT '',A.ICCARD_NO
		FROM TF_F_CUST C,TF_F_CUST_ACCT A
		WHERE A.CUST_ID = C.CUST_ID
		AND (P_VAR1 is null or C.PAPER_NO = P_VAR1)
		AND (P_VAR2 is null or C.CUST_NAME = P_VAR2);
    
  ELSIF P_FUNCCODE = 'QRYACCTOUNT'  THEN --查询账户信息
    OPEN P_CURSOR FOR
    SELECT 
    A.ACCT_ID,      --帐户标识
    A.CUST_ID,      --客户标识
    B.ACCT_TYPE_NO, --账户类型代码
    B.ACCT_TYPE_NO || ':' || B.ACCT_TYPE_NAME ACCT_TYPE_NAME,--账户类型名称
    B.ACCT_ITEM_TYPE,  --账户类别
    A.ICCARD_NO,       --卡号
    A.LIMIT_DAYAMOUNT/100.0 LIMIT_DAYAMOUNT, --每日消费限额
    A.LIMIT_EACHTIME/100.0 LIMIT_EACHTIME,  --每笔消费限额
    to_char(A.EFF_DATE,'yyyyMMdd') EFF_DATE, --生效日期
    A.STATE,    --状态代码
    DECODE(A.STATE,'A','有效','B','冻结','F','挂失','X','注销',A.State) STATENAME, -- 状态名称
    to_char(A.Create_Date,'yyyyMMdd') Create_Date, --创建日期
    A.REL_BALANCE/100.0 REL_BALANCE, -- 余额
    A.Total_Consume_Money/100.0 Total_Consume_Money,-- 总消费金额
    A.Total_Consume_Times,-- 总消费次数
    to_char(A.LAST_CONSUME_TIME,'YYYYMMDD') LAST_CONSUME_TIME,-- 最后消费时间
    A.Total_Supply_Money/100.0 Total_Supply_Money,-- 总充值金额
    A.Total_Supply_Times,-- 总充值次数
    to_char(A.LAST_SUPPLY_TIME,'yyyymmdd') LAST_SUPPLY_TIME -- 最后充值时间
    FROM TF_F_CUST_ACCT A ,TF_F_ACCT_TYPE_INFO B
    WHERE
    A.ACCT_TYPE_NO = B.ACCT_TYPE_NO AND A.ICCARD_NO = P_VAR1
    AND (P_VAR2 IS NULL OR B.ACCT_ITEM_TYPE = P_VAR2);
    
   ELSIF P_FUNCCODE = 'QRYCORPBYACCT'  THEN --根据账户ID查询集团客户信息 
   OPEN P_CURSOR FOR
      SELECT A.CORPCODE,A.CORPNAME FROM td_group_customer A,td_group_acct B 
      WHERE  A.CORPCODE = B.CORPNO AND B.ACCT_ID = P_VAR1;
	
  ELSIF P_FUNCCODE = 'QRYACCTOUNTTYPE'  THEN
    OPEN P_CURSOR FOR
    SELECT A.ACCT_TYPE_NAME,A.ACCT_TYPE_NO FROM TF_F_ACCT_TYPE_INFO A ORDER BY A.ACCT_TYPE_NO;
  
  ELSIF  P_FUNCCODE = 'QRYCUSTOMER' THEN --根据卡号和身份证号查询客户信息
    OPEN P_CURSOR FOR
    SELECT 
    A.CARDNO 卡号,
    A.CUSTNAME 姓名,
    DECODE(A.CUSTSEX, '0', '男', '1', '女', A.CUSTSEX) 性别,
    A.PAPERNO 证件号码
    FROM TF_F_CUSTOMERREC A
    WHERE (P_VAR1 IS NULL OR A.PAPERNO = P_VAR1) 
    AND (P_VAR2 IS NULL OR A.CARDNO = P_VAR2)
    AND (P_VAR3 IS NULL OR A.CUSTNAME = P_VAR3); 
    
    ELSIF  P_FUNCCODE = 'QRYACCTCUSTOMER' THEN --根据卡号和身份证号查询账户客户信息
    OPEN P_CURSOR FOR
    SELECT 
    A.iccard_no 卡号,
    A.CUST_NAME 姓名,
    DECODE(A.CUST_SEX, '0', '男', '1', '女', A.CUST_SEX) 性别,
    A.PAPER_NO 证件号码
    FROM TF_F_CUST A
    WHERE (P_VAR1 IS NULL OR A.PAPER_NO = P_VAR1) 
    AND (P_VAR2 IS NULL OR A.iccard_no = P_VAR2)
    AND (P_VAR3 IS NULL OR A.CUST_NAME = P_VAR3); 
    
    ELSIF  P_FUNCCODE = 'QRYACCTCUSTOMERINFO' THEN --根据卡号、身份证号、单位、姓名查询账户客户信息
		    OPEN P_CURSOR FOR
		    SELECT DISTINCT T.iccard_no 卡号 , T.CUST_NAME 姓名,T.CUST_SEX 性别,T.PAPER_NO 证件号码,D.CORPNAME 单位  FROM 
		    (
		        SELECT
		        A.CUST_ID,
		        A.iccard_no ,
		        A.CUST_NAME ,
		        DECODE(A.CUST_SEX, '0', '男', '1', '女', A.CUST_SEX) CUST_SEX,
		        A.PAPER_NO 
		        FROM TF_F_CUST A 
		        WHERE 
		        (P_VAR1 IS NULL OR A.PAPER_NO = P_VAR1) 
		        AND (P_VAR2 IS NULL OR A.iccard_no = P_VAR2)
		        AND (P_VAR3 IS NULL OR A.CUST_NAME = P_VAR3)
		    ) T, TF_F_CUST_ACCT B, TD_GROUP_ACCT C, TD_GROUP_CUSTOMER D
		    WHERE 
		    (P_VAR4 IS NULL OR C.CORPNO = P_VAR4) AND 
		    T.CUST_ID = B.CUST_ID AND B.ACCT_ID = C.ACCT_ID(+) AND C.CORPNO = D.CORPCODE(+);
    
    ELSIF  P_FUNCCODE = 'QRYACCTCUSTOMERBLOCKINFO' THEN --根据卡号、身份证号、单位、姓名查询账户客户信息
    OPEN P_CURSOR FOR
    SELECT DISTINCT T.iccard_no 卡号 ,DECODE(B.STATE,'A','有效','B','冻结','F','挂失','H','已归档','X','注销',B.STATE) 账户状态,
    T.CUST_NAME 姓名,T.CUST_SEX 性别,T.PAPER_NO 证件号码,D.CORPNAME 单位  FROM 
    (
        SELECT
        A.CUST_ID,
        A.iccard_no ,
        A.CUST_NAME ,
        DECODE(A.CUST_SEX, '0', '男', '1', '女', A.CUST_SEX) CUST_SEX,
        A.PAPER_NO 
        FROM TF_F_CUST A 
        WHERE 
        (P_VAR1 IS NULL OR A.PAPER_NO = P_VAR1) 
        AND (P_VAR2 IS NULL OR A.iccard_no = P_VAR2)
        AND (P_VAR3 IS NULL OR A.CUST_NAME = P_VAR3)
    ) T, TF_F_CUST_ACCT B, TD_GROUP_ACCT C, TD_GROUP_CUSTOMER D
    WHERE 
    (P_VAR4 IS NULL OR C.CORPNO = P_VAR4) AND 
    T.CUST_ID = B.CUST_ID AND B.ACCT_ID = C.ACCT_ID(+) AND C.CORPNO = D.CORPCODE(+) AND B.STATE IN ('A','F') order by 1;
    
    ELSIF  P_FUNCCODE = 'QRYACCTCUSTOMERBLOCKTRANINFO' THEN --根据卡号、身份证号、单位、姓名查询账户客户信息 挂失补账户页面使用
    OPEN P_CURSOR FOR
    SELECT DISTINCT T.iccard_no 卡号 ,DECODE(B.STATE,'A','有效','B','冻结','F','挂失','H','已归档','X','注销',B.STATE) 账户状态,
    T.CUST_NAME 姓名,T.CUST_SEX 性别,T.PAPER_NO 证件号码,D.CORPNAME 单位  FROM 
    (
        SELECT
        A.CUST_ID,
        A.iccard_no ,
        A.CUST_NAME ,
        DECODE(A.CUST_SEX, '0', '男', '1', '女', A.CUST_SEX) CUST_SEX,
        A.PAPER_NO 
        FROM TF_F_CUST A 
        WHERE 
        (P_VAR1 IS NULL OR A.PAPER_NO = P_VAR1) 
        AND (P_VAR2 IS NULL OR A.iccard_no = P_VAR2)
        AND (P_VAR3 IS NULL OR A.CUST_NAME = P_VAR3)
    ) T, TF_F_CUST_ACCT B, TD_GROUP_ACCT C, TD_GROUP_CUSTOMER D
    WHERE 
    (P_VAR4 IS NULL OR C.CORPNO = P_VAR4) AND 
    T.CUST_ID = B.CUST_ID AND B.ACCT_ID = C.ACCT_ID(+) AND C.CORPNO = D.CORPCODE(+) AND B.STATE = 'F' order by 1;
    
    elsif p_funcCode = 'OpenAprvOld' then
    open p_cursor for
    SELECT c.CARDNO ,b.acct_type_no || ':' || b.acct_type_name ACCTYPE, c.CUSTNAME, c.PAPERNO, 
           0.0 DEPOSIT, 
           0.0 CARDFEE, 
           0.0 CHARGEAMOUNT
    FROM   TF_F_OPENACC c,TF_F_ACCT_TYPE_INFO b
    WHERE  c.ID = p_var1 AND c.acctype = b.acct_type_no;

		elsif p_funcCode = 'OpenAprvNew' then
    open p_cursor for
    SELECT change.cardno,change.ACCTYPE, change.custname, change.paperno,
           NVL(change.DEPOSIT, 0.0) DEPOSIT, NVL(change.CARDFEE, 0.0) CARDFEE, NVL(change.CHARGEAMOUNT, 0.0) CHARGEAMOUNT
    FROM 
           (
	            SELECT t.CARDNO,b.acct_type_no || ':' || b.acct_type_name ACCTYPE,t.CUSTNAME,t.PAPERNO,
	               c.deposit/100.0 DEPOSIT, 
	               c.cardcost/100.0 CARDFEE, 
	               a.totalsupplymoney/100.0 CHARGEAMOUNT
	            FROM   TF_F_OPENACC t,TF_F_CARDREC c,TF_F_CARDEWALLETACC a, TF_F_ACCT_TYPE_INFO b
	            WHERE  a.CARDNO = t.CARDNO
	            AND		 c.CARDNO = t.CARDNO
	            AND    t.ID = p_var1
              AND t.acctype = b.acct_type_no
            ) change;
      
   elsif p_funcCode = 'CAConsumeInfoQuery' then
    open p_cursor for 
       SELECT A.ICCARD_NO,
       B.ACCT_TYPE_NAME ,
       DECODE(A.CONSUME_TYPE,'A','POS正常消费','B','POS消费撤销','C','POS退货','D','网上充值(给电子钱包)','E','网上消费',A.CONSUME_TYPE) CONSUME_TYPE,
       DECODE(A.PAY_TYPE,'0','自己付费','1','别人代付',A.PAY_TYPE) PAY_TYPE,
       DECODE(A.DEAL_STATE,'A','消费','B','撤销','C','退货','D','冲正', A.DEAL_STATE) DEAL_STATE,
       A.TRADE_CHARGE/100.0 TRADE_CHARGE,
       A.TRADE_DATE,
       DECODE(A.STATE,'A','未下帐','B', '已下帐','C', '已个人结算','D','已商户结算','E','已销账','F','单边帐','G','单边帐销帐',A.STATE) STATE,
       A.STATE_DATE,
       C.BALUNIT
       FROM TF_F_ACCT_ITEM_OWE A,TF_F_ACCT_TYPE_INFO B,TF_TRADE_BALUNIT C
       WHERE A.ACCT_TYPE_NO = B.ACCT_TYPE_NO AND A.BALUNITNO = C.BALUNITNO
       AND (P_VAR1 IS NULL OR A.BALUNITNO = P_VAR1)
       AND TO_CHAR(A.TRADE_DATE,'YYYYMMDD') >= P_VAR2
       AND TO_CHAR(A.TRADE_DATE,'YYYYMMDD') <= P_VAR3
       AND (P_VAR4 IS NULL OR A.ICCARD_NO = P_VAR4)
       AND (P_VAR5 IS NULL OR A.CONSUME_TYPE = P_VAR5)
       AND (P_VAR6 IS NULL OR A.STATE = P_VAR6) ORDER BY A.TRADE_DATE DESC;
       
   elsif p_funcCode = 'QueryCorpCodeByBatchNo' then 
       open p_cursor for
           select corpno from tf_f_supplysum where  ID = p_var1;
           
   elsif p_funcCode = 'QueryBatchNoByCorpCode' then 
       open p_cursor for
           SELECT ID, ID FROM TF_F_SUPPLYSUM WHERE (P_VAR1 is null or CORPNO = P_VAR1) AND STATECODE = '0';
           
   elsif p_funcCode = 'QueryChangeCardHistory' then
       open p_cursor for
        select distinct tradeid 流水号, tradetypecode || ':' || tradetype 业务类型,
           CARDNO 新卡号, OLDCARDNO 旧卡号,
           operatetime 补换账户时间, operatestaffno || ':' ||  staffname 换卡员工
    from (select t.tradeid, t.tradetypecode, nvl(r.tradetype, '') tradetype, t.CARDNO, t.OLDCARDNO,
           t.operatetime, t.operatestaffno, nvl(s.staffname, '') staffname,
           t.reasoncode,   c.CARDSTATE
          from   TF_B_TRADE t, td_m_insidestaff s, td_m_tradetype r,  TF_F_CARDREC c
          where  (t.tradetypecode = '8P' or t.tradetypecode = '8W')
          and    t.cardno is not null and  t.OLDCARDNO is not null
          and    t.canceltag = '0' and t.canceltradeid is null
          and    t.tradetypecode  = r.tradetypecode(+)
          and    t.operatestaffno = s.staffno(+)
          and    t.OLDCARDNO      = c.cardno (+)
         )
    start with (cardno = p_var1 or oldcardno = p_var1)
    CONNECT BY NOCYCLE (PRIOR oldcardno  = cardno or PRIOR cardno = oldcardno  )
    order by 1 desc;
           
  END IF;
END;

/
  SHOW ERROR
