/*
create time:2014/8/18
creator:dongx
modify time:2014-11-14 by jiangbb
content:入金匹配完成返销
*/

CREATE OR REPLACE PROCEDURE SP_BFJ_CompleteInCancel
(
	p_tradeDate	char,    		-- 日期 格式YYYYMMDD
	p_currOper	char,           -- 操作员工
	p_currDept	char,		    -- 操作部门
    p_retCode    out char,   	-- Return Code
    p_retMsg     out varchar2   -- Return Message
)
as
    v_now            date := sysdate;  --当前时间
	v_tradeID	     char(16);		   --序列   
	v_count				 int;	
	v_bankCount          int;
	v_sum_bankless       int :=0;	   --银行未达账汇总
	v_sum_businessless   int :=0;	   --业务未达账汇总
	v_bankless       int;			   --银行未达账
	v_businessless   int;		       --业务未达账
	v_bankaccount    varchar2(120);    --银行账号
BEGIN
	--查询备付金任务表
	BEGIN 
		SELECT count(1) INTO v_count FROM TF_F_BFJ_TASK WHERE BFJDATE = p_tradeDate AND ISINMATCH = '1';
		IF v_count != 1 THEN
			p_retCode := 'SBFJ004000';
			p_retMsg  := p_tradeDate || '并未入金确认完成，不可取消';
			ROLLBACK; RETURN;			
		END IF;   
	END;
	
	
	-- 1)查询备付金任务表  
	BEGIN  
		SELECT count(1) INTO v_count FROM 
		(SELECT DISTINCT FILEDATE,BANKCODE FROM TF_F_BFJ_OBAB WHERE FILEDATE = p_tradeDate) O
		INNER JOIN TD_M_BFJ_BANK B ON B.SYSTEMCODE = O.BANKCODE
		WHERE FILEDATE = p_tradeDate;
		SELECT count(1) INTO v_bankCount FROM TD_M_BFJ_BANK WHERE ISCOOPERATIVE = '1';
		IF v_count != v_bankCount THEN
			p_retCode := 'SBFJ003001';
			p_retMsg  := '还有银行没有入账，无法确认完成';
			ROLLBACK; RETURN;			
		END IF;  
	END; 
	
	--2)查询后一日确认状态
	IF p_tradeDate != '20141001' THEN 
		BEGIN
			SELECT COUNT(BFJDATE) INTO  v_count																		
			FROM TF_F_BFJ_TASK																				
			WHERE BFJDATE = TO_CHAR(TO_DATE(p_tradeDate,'yyyyMMdd') + 1,'yyyyMMdd')
			AND BANKLESS IS NOT NULL 
			AND BUSINESSLESS IS NOT NULL
			AND ISOUTMATCH = '1'
			AND ISINMATCH = '1';																		
			IF v_count != 1 THEN
				p_retCode := 'SBFJ004002';
				p_retMsg  := '请先返销完成后一日账务' || SQLERRM;
				ROLLBACK; RETURN;			
			END IF;  
		END; 
	END IF;
	
	--3) 查询备付金信息明细表
	BEGIN
		 FOR v_cur IN (
			SELECT B.SYSTEMCODE, O.BANKACCOUNT, B.SYSTEMNAME 																										
			FROM TD_M_BFJ_BANK B																												
			LEFT JOIN TF_F_BFJ_OBAB O ON B.SYSTEMCODE = O.BANKCODE AND O.FILEDATE = p_tradeDate																												
			WHERE ISCOOPERATIVE  = '1'		  
		 )
		 LOOP
			 IF v_cur.BANKACCOUNT IS NULL THEN
				p_retCode := 'SBFJ003003';
				p_retMsg  := v_cur.SYSTEMNAME ||'没有入账，无法确认入金' || SQLERRM;
				ROLLBACK; RETURN;		
			 END IF;
			 
			 --查询银行默认账户
			 BEGIN 
			 SELECT ACCOUNT INTO v_bankaccount
			 FROM TD_M_BFJ_BANK 
			 WHERE SYSTEMCODE = v_cur.SYSTEMCODE; 
			 EXCEPTION WHEN OTHERS THEN
				p_retCode := 'SBFJ003004';
				p_retMsg  := '查询银行默认账户败' || SQLERRM;
				ROLLBACK; RETURN;
			 END; 
			 
			IF v_bankaccount = v_cur.BANKACCOUNT THEN
			BEGIN
				--计算业务未达账
				BEGIN
				SELECT NVL(SUM(NVL(LEFTMONEY,TRADECHARGE)),0) INTO v_businessless
				FROM TF_F_BFJ_OCAB
				WHERE TO_DATE(FILEDATE,'yyyyMMdd') <= TO_DATE(p_tradeDate,'yyyyMMdd')
				AND BANKNAME = v_cur.SYSTEMCODE	
				AND BANKACCOUNT = v_bankaccount
				AND (ISNEEDMATCH IS NULL OR ISNEEDMATCH = '0')
				AND AMOUNTTYPE = '0';
				EXCEPTION WHEN OTHERS THEN
					p_retCode := 'SBFJ003006';
					p_retMsg  := '计算业务未达账失败' || SQLERRM;
					ROLLBACK; RETURN;
				END;
				
				--计算银行未达账
				BEGIN
				SELECT NVL(SUM(NVL(LEFTMONEY,TRADEMONEY)),0) INTO v_bankless
				FROM TF_F_BFJ_TRADERECORD
				WHERE TRADEDATE <= TO_DATE(p_tradeDate,'yyyyMMdd')
				AND OTHERBANK = v_cur.SYSTEMCODE																				
				AND ISNEEDMATCH = '0'																				
				AND AMOUNTTYPE = '0';
				EXCEPTION WHEN OTHERS THEN
					p_retCode := 'SBFJ003007';
					p_retMsg  := '计算银行未达账失败' || SQLERRM;
					ROLLBACK; RETURN;
				END;
				 
				v_sum_businessless := v_sum_businessless + v_businessless;
				
				--更新银行备付金信息明细表
				BEGIN
				UPDATE TF_F_BFJ_OBAB 
				SET BANKLESS = NVL(BANKLESS,0) - v_bankless,
					BUSINESSLESS = NVL(BUSINESSLESS,0) - v_businessless 
				WHERE BANKCODE = v_cur.BANKACCOUNT 
				AND FILEDATE = p_tradeDate;
				EXCEPTION WHEN OTHERS THEN
					p_retCode := 'SBFJ003008';
					p_retMsg  := '更新银行备付金信息明细表失败' || SQLERRM;
					ROLLBACK; RETURN; 
				END;
			END;
			ELSE
			BEGIN
				--更新银行备付金信息明细表
				BEGIN
				UPDATE TF_F_BFJ_OBAB 
				SET BANKLESS = 0,
					BUSINESSLESS = 0 
				WHERE BANKCODE = v_cur.BANKACCOUNT
				AND FILEDATE = p_tradeDate;
				EXCEPTION WHEN OTHERS THEN
					p_retCode := 'SBFJ003008';
					p_retMsg  := '更新银行备付金信息明细表失败' || SQLERRM;
					ROLLBACK; RETURN; 
				END;		
			END;
			END IF; 
		 END LOOP;
	END;
	
	--计算银行未达帐汇总 
	BEGIN
	SELECT NVL(SUM(NVL(LEFTMONEY,TRADEMONEY)),0) INTO v_sum_bankless
	FROM TF_F_BFJ_TRADERECORD
	WHERE TRADEDATE <= TO_DATE(p_tradeDate,'yyyyMMdd')
	AND ISNEEDMATCH = '0'
	AND AMOUNTTYPE = '0';
	EXCEPTION WHEN OTHERS THEN
		p_retCode := 'SBFJ003011';
		p_retMsg  := '计算银行未达帐汇总失败' || SQLERRM;
		ROLLBACK; RETURN;
	END;
	
	-- 4)查询备付金任务表 
	BEGIN  
		SELECT count(1) INTO v_count FROM TF_F_BFJ_TASK WHERE BFJDATE = p_tradeDate AND ISOUTMATCH = '1';
		IF v_count = 1 THEN
		BEGIN
			UPDATE TF_F_BFJ_OBAB SET SYNCSTATES = '1' WHERE FILEDATE = p_tradeDate;
			EXCEPTION WHEN OTHERS THEN
				p_retCode := 'SBFJ003009';
				p_retMsg  := '更新银行备付金信息明细表失败' || SQLERRM;
				ROLLBACK; RETURN;  	
		END;
		--更新系统业务账单表
		BEGIN
			UPDATE TF_F_BFJ_TRADERECORD SET SYNCSTATES = '1' WHERE TRADEDATE = TO_DATE(p_tradeDate,'YYYYMMDD');
			EXCEPTION WHEN OTHERS THEN
				p_retCode := 'SBFJ003011';
				p_retMsg  := '更新系统业务账单表失败' || SQLERRM;
				ROLLBACK; RETURN; 
		END;
		END IF;
	END;
	
	
	--5.更新备付金任务表
	BEGIN
		UPDATE TF_F_BFJ_TASK SET ISINMATCH = '1' ,INMATCHSTAFFNO = NULL , INMATCHDATE = NULL,
		BANKLESS = NVL(BANKLESS,0) - v_sum_bankless, BUSINESSLESS = NVL(BUSINESSLESS,0) - v_sum_businessless
		WHERE BFJDATE = p_tradeDate;
		EXCEPTION WHEN OTHERS THEN
			p_retCode := 'SBFJ003010';
			p_retMsg  := '更新备付金任务表失败' || SQLERRM;
			ROLLBACK; RETURN; 
	END;
	
	p_retCode := '0000000000';
    p_retMsg  := 'OK';
    COMMIT; 
    RETURN;  
end;
/
show errors