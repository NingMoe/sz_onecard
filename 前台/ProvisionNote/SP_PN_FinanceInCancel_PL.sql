/* ------------------------------------
COPYRIGHT (C) 2010-2015 LINKAGE SOFTWARE 
 ALL RIGHTS RESERVED.
<AUTHOR>JIANGBB</AUTHOR>
<CREATEDATE>2014-08-08</CREATEDATE>
<DESCRIPTION>入金确认取消存储过程</DESCRIPTION>
------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_PN_FinanceInCancel
(
	P_SESSIONID			VARCHAR2,	--SESSIONID
	
	P_CURROPER          CHAR,
    P_CURRDEPT          CHAR,
    P_RETCODE   		OUT CHAR, 		-- RETURN CODE
    P_RETMSG    		OUT VARCHAR2	-- RETURN MESSAGE
)
AS		
    V_SEQ				CHAR(16);		--序号
	V_COUNT				INT;			--
	V_TRADEID			VARCHAR2(30);	--交易流水号
	V_MONEY				INT;			--交易金额
	V_TODAY         	DATE := SYSDATE;--日期
	V_TRADEDATE			CHAR(8);		--业务日期
	V_DEPARTID			CHAR(4);		--部门编号
	V_EX				EXCEPTION;		--错误信息
BEGIN
	
		FOR V_C IN (SELECT F2,F3 FROM TMP_COMMON WHERE F0 = P_SESSIONID AND F1 = '3') LOOP
		
			--检查业务流水号业务类型
			BEGIN
				SELECT COUNT(1) INTO V_COUNT FROM TF_F_BFJ_TRADERECORD T WHERE T.TRADETYPECODE IN ('01','14','15') AND T.ISFINANCEIN !='1'
				AND T.TRADEID = V_C.F3;
				EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
			END;
			
			IF V_COUNT > 0 THEN
				P_RETCODE := 'S05021B129'; P_RETMSG  := '业务流水号为'||V_C.F3||'的记录请在解款页面取消匹配';
				ROLLBACK; RETURN;
			END IF;
			
			--GET TRADE ID
			SP_GETSEQ(SEQ => V_SEQ);
			
			--查询账单关联表
			BEGIN
			SELECT MONEY INTO V_MONEY FROM TF_F_BFJ_BANKRELATION WHERE BANKTRADEID = V_C.F2 AND SYSTEMTRADEID = V_C.F3;
				EXCEPTION WHEN
					NO_DATA_FOUND THEN
					P_RETCODE := 'S05021B044'; P_RETMSG  := '查询账单关联表失败,'||SQLERRM;
					ROLLBACK; RETURN;
			END;
			
			--新增备付金业务关联明细表
			BEGIN
				INSERT INTO TF_B_BFJ_CHECK
				(TRADEID,BANKTRADEID,SYSTEMTRADEID,TRADECODE,MONEY,
				BANKUSEDMONEY,BANKLEFTMONEY,TRADEUSEDMONEY,TRADELEFTMONEY,
				OPERATESTAFFNO,OPERATETIME)
				SELECT * FROM (
				SELECT V_SEQ,BANKTRADEID,SYSTEMTRADEID,'2',MONEY,
				BANKUSEDMONEY+V_MONEY,BANKLEFTMONEY-V_MONEY,TRADEUSEDMONEY+V_MONEY,TRADELEFTMONEY-V_MONEY,
				P_CURROPER,V_TODAY
				FROM TF_B_BFJ_CHECK
				WHERE BANKTRADEID = V_C.F2 AND SYSTEMTRADEID = V_C.F3 AND TRADECODE = '1' ORDER BY OPERATETIME DESC
				) WHERE ROWNUM = 1;
				IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				EXCEPTION WHEN OTHERS THEN
					P_RETCODE := 'S05001B002'; P_RETMSG  := '更新备付金业务关联明细表失败,' || SQLERRM;
					ROLLBACK; RETURN;
			END;
			
			--更新账单关联表
			BEGIN
				DELETE TF_F_BFJ_BANKRELATION WHERE BANKTRADEID = V_C.F2 AND SYSTEMTRADEID = V_C.F3;
				
				IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				EXCEPTION
				WHEN OTHERS THEN
					P_RETCODE := 'S05001B003'; P_RETMSG  := '更新账单关联表失败,' || SQLERRM;
					ROLLBACK; RETURN;
			END;
			
			--更新银行业务表
			BEGIN
				UPDATE TF_F_BFJ_OCAB T
				SET T.LEFTMONEY = T.LEFTMONEY + V_MONEY,
					T.USEDMONEY = T.USEDMONEY - V_MONEY
				WHERE T.TRADEID = V_C.F2;
				EXCEPTION
				WHEN OTHERS THEN
					P_RETCODE :='S05001B004'; P_RETMSG :='更新银行备付金交易明细表失败'|| SQLERRM;
				ROLLBACK; RETURN;
			END;
			
			--更新网点业务表
			BEGIN
			UPDATE TF_F_BFJ_TRADERECORD T
				SET T.LEFTMONEY = T.LEFTMONEY + V_MONEY,
					T.USEDMONEY = T.USEDMONEY - V_MONEY,
					T.ISFINANCEIN = '0'
			WHERE T.TRADEID = V_C.F3;
			EXCEPTION
				WHEN OTHERS THEN
					P_RETCODE :='S05001B005'; P_RETMSG :='更新系统业务账单表失败'|| SQLERRM;
				ROLLBACK; RETURN;
			END;
			
			BEGIN
			SELECT TO_CHAR(TRADEDATE,'YYYYMMDD'),DEPARTID INTO V_TRADEDATE,V_DEPARTID 
			FROM TF_F_BFJ_TRADERECORD WHERE TRADEID = V_C.F3;
				EXCEPTION
					WHEN NO_DATA_FOUND THEN
					P_RETCODE :='S05001B125'; P_RETMSG :='查询系统业务账单表失败'|| SQLERRM;
					ROLLBACK; RETURN;
			END;
			
			--更新网点解款确认表
			BEGIN
			DELETE TF_F_BFJ_STAFFCONFIRM T WHERE CONFIRMDATE = V_TRADEDATE AND DEPTID = V_DEPARTID;
			EXCEPTION
				WHEN OTHERS THEN
					NULL;
			END;
			
		END LOOP;

    P_RETCODE := '0000000000'; P_RETMSG := '';
    COMMIT;RETURN;
END;
/

SHOW ERRORS