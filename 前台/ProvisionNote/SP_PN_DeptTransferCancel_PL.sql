/* ------------------------------------
COPYRIGHT (C) 2010-2015 LINKAGE SOFTWARE 
 ALL RIGHTS RESERVED.
<AUTHOR>JIANGBB</AUTHOR>
<CREATEDATE>2014-08-08</CREATEDATE>
<DESCRIPTION>取消解款存储过程</DESCRIPTION>
------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_PN_DEPTTRANSFERCANCEL
(
	P_SESSIONID			VARCHAR2,	--SESSIONID
	P_DATE				CHAR,		--解款日期
	P_DEPTID			CHAR,		--部门编号
	
	P_CURROPER          CHAR,
    P_CURRDEPT          CHAR,
    P_RETCODE   		OUT CHAR, 		-- RETURN CODE
    P_RETMSG    		OUT VARCHAR2	-- RETURN MESSAGE
)
AS		
    V_SEQ				CHAR(16);		--序号
	V_TRADEID			VARCHAR2(30);	--交易流水号
	V_MONEY				INT;			--账单关联金额
	V_USEDMONEY			INT;			--已用金额
	V_LEFTMONEY			INT;			--未用金额
	V_BANKCOUNT			INT:= 0;		--银行数量
	V_TRADECOUNT		INT:= 0;		--业务数量
	V_CONFIRMDATE		CHAR(8);		--待取消解款日期
	V_TODAY         	DATE := SYSDATE;--日期
	V_EX				EXCEPTION;		--错误信息
BEGIN
	
	--查询该网点最晚可取消解款日期
	SELECT CONFIRMDATE INTO V_CONFIRMDATE FROM (
	SELECT CONFIRMDATE FROM TF_F_BFJ_STAFFCONFIRM T
	WHERE (P_DEPTID IS NULL OR P_DEPTID = '' OR P_DEPTID = T.DEPTID) ORDER BY T.CONFIRMDATE DESC)
	WHERE ROWNUM = 1;
	
	IF V_CONFIRMDATE IS NOT NULL THEN
		IF V_CONFIRMDATE != P_DATE THEN
			P_RETCODE :='S05001B313'; P_RETMSG :='最晚解款日期为'||V_CONFIRMDATE||'，请从该日开始取消解款';
		END IF;
	END IF;
	
		
	FOR V_C IN (
	SELECT C.BANKTRADEID,C.SYSTEMTRADEID FROM TF_F_BFJ_TRADERECORD T,TF_F_BFJ_BANKRELATION C
	WHERE TO_DATE(P_DATE||'000000','YYYYMMDDHH24MISS') <= T.TRADEDATE
	AND TO_DATE(P_DATE||'235959','YYYYMMDDHH24MISS') >= T.TRADEDATE
	AND T.TRADEID = C.SYSTEMTRADEID
	AND T.DEPARTID = P_DEPTID) LOOP
		--GET TRADE ID
		SP_GETSEQ(SEQ => V_SEQ);
		
		--查询账单关联表
		BEGIN
		SELECT MONEY INTO V_MONEY FROM TF_F_BFJ_BANKRELATION WHERE BANKTRADEID = V_C.BANKTRADEID AND SYSTEMTRADEID = V_C.SYSTEMTRADEID;
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
			WHERE BANKTRADEID = V_C.BANKTRADEID AND SYSTEMTRADEID = V_C.SYSTEMTRADEID AND TRADECODE = '1' ORDER BY OPERATETIME DESC
			) WHERE ROWNUM = 1;
			IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
			EXCEPTION WHEN OTHERS THEN
				P_RETCODE := 'S05001B002'; P_RETMSG  := '更新备付金业务关联明细表失败,' || SQLERRM;
				ROLLBACK; RETURN;
		END;
		
		--更新账单关联表
		BEGIN
			DELETE TF_F_BFJ_BANKRELATION WHERE BANKTRADEID = V_C.BANKTRADEID AND SYSTEMTRADEID = V_C.SYSTEMTRADEID;
			
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
				T.USEDMONEY = T.USEDMONEY - V_MONEY,
				T.ISNEEDMATCH = '0'
			WHERE T.TRADEID = V_C.BANKTRADEID;
			EXCEPTION
			WHEN OTHERS THEN
				P_RETCODE :='S05001B004'; P_RETMSG :='更新银行备付金交易明细表失败'|| SQLERRM;
			RETURN; ROLLBACK;
		END;
		
		--更新网点业务表
		BEGIN
		UPDATE TF_F_BFJ_TRADERECORD T
			SET T.LEFTMONEY = T.LEFTMONEY + V_MONEY,
				T.USEDMONEY = T.USEDMONEY - V_MONEY,
				T.ISNEEDMATCH = '0'
		WHERE T.TRADEID = V_C.SYSTEMTRADEID;
		EXCEPTION
			WHEN OTHERS THEN
				P_RETCODE :='S05001B005'; P_RETMSG :='更新系统业务账单表失败'|| SQLERRM;
			RETURN; ROLLBACK;
		END;
	
	END LOOP;

	--更新解款确认表
	BEGIN
	DELETE TF_F_BFJ_STAFFCONFIRM WHERE CONFIRMDATE = P_DATE AND DEPTID = P_DEPTID;
		IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		EXCEPTION
			WHEN OTHERS THEN
				P_RETCODE :='S05001B007'; P_RETMSG :='更新解款确认表失败'|| SQLERRM;
			RETURN; ROLLBACK;
	END;

    P_RETCODE := '0000000000'; P_RETMSG := '';
    COMMIT;RETURN;
END;
/

SHOW ERRORS