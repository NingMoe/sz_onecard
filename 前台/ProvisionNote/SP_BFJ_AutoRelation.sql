/*
create time:2014/8/14
creator:dongx
content:银行账单和系统账单自动对账
update: 20140915 代理营业厅改为从主台账生成数据，不自动对账
update：20140925 出租车不自动对账
update: 20141009 修复有交易金额和账户完全一样的情况下会发生异常BUG
update: 20141110 增加退充值自动匹配
*/

CREATE OR REPLACE PROCEDURE SP_BFJ_AutoRelation
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
	v_tradeMoney     int; 
	v_count          int;
BEGIN
	
	-- 1)查询备付金任务表 
	BEGIN  
		SELECT COUNT(BFJDATE) INTO  v_count FROM TF_F_BFJ_TASK WHERE BFJDATE = p_tradeDate AND TASKSTATE != '0';
		IF v_count != 1 THEN
			p_retCode := 'SBFJ002001';
			p_retMsg  := '查询备付金任务表失败' || SQLERRM;
			ROLLBACK; RETURN;			
		END IF;  
	END;
	
	--2)查询订单记录
	BEGIN
		 FOR v_cur IN (
			SELECT DISTINCT T.TRADEID TID,OC.TRADEID BID,O.ORDERNO,C.ACCOUNTNUMBER ACCOUNT,
			R.MONEY,NVL(OC.USEDMONEY,0) BUSED,NVL(OC.LEFTMONEY,OC.TRADECHARGE) BLEFT,T.USEDMONEY TUSED,T.LEFTMONEY TLEFT 																																
			FROM TF_F_BFJ_TRADERECORD T																																		
			INNER JOIN TF_F_ORDERFORM O ON T.SYSTRADEID = O.ORDERNO																																		
			INNER JOIN TF_F_ORDERCHECKRELATION R ON R.ORDERNO = O.ORDERNO																																		
			INNER JOIN TF_F_CHECK C ON C.CHECKID = R.CHECKID	  
			INNER JOIN TF_F_BFJ_OCAB OC ON OC.OTHERUSERNAME  =  C.ACCOUNTNAME  																													
			AND C.MONEY = OC.TRADECHARGE																																		
			WHERE T.ISNEEDMATCH = '0' 
			AND C.USETAG = '1'
		    AND (OC.ISNEEDMATCH IS NULL OR OC.ISNEEDMATCH = '0')
			AND (OC.LEFTMONEY IS NULL OR OC.LEFTMONEY > 0)
			AND (T.LEFTMONEY IS NULL OR T.LEFTMONEY > 0)
		 )
		 LOOP 
		 --判断记录是否已经被匹配
		 BEGIN
			SELECT COUNT(1) INTO v_count
			FROM TF_F_BFJ_BANKRELATION
			WHERE BANKTRADEID = v_cur.BID OR SYSTEMTRADEID = v_cur.TID;  
		 END;
		
		 IF v_count = 0 THEN
		 
			 --2.1)更新【银行备付金交易明细表】
			 BEGIN
				UPDATE TF_F_BFJ_OCAB SET TRADEMEG = TRADEMEG || ' 订单编号' || v_cur.ORDERNO,
				USEDMONEY = NVL(USEDMONEY,0) + v_cur.MONEY,LEFTMONEY = NVL(LEFTMONEY,TRADECHARGE) - v_cur.MONEY																																					
				WHERE TRADEID = v_cur.BID;
				EXCEPTION WHEN OTHERS THEN
				p_retCode := 'SBFJ002002';
				p_retMsg  := '更新【银行备付金交易明细表】失败' || SQLERRM;
				ROLLBACK; RETURN;	 
			 END;
			 
			 --2.2)更新【系统业务账单表】
			 BEGIN
				UPDATE TF_F_BFJ_TRADERECORD SET USEDMONEY = USEDMONEY + v_cur.MONEY,LEFTMONEY = NVL(LEFTMONEY,TRADEMONEY) - v_cur.MONEY, 
				ACCOUNT = v_cur.ACCOUNT
				WHERE TRADEID = v_cur.TID;
				EXCEPTION WHEN OTHERS THEN
				p_retCode := 'SBFJ002003';
				p_retMsg  := '更新【系统业务账单表】失败' || SQLERRM;
				ROLLBACK; RETURN;	 
			 END;
			 v_tradeID := FUN_GETBFJTRADEID(p_tradeDate);
			 --2.3)插入【账单关联表】
			 BEGIN
				INSERT INTO TF_F_BFJ_BANKRELATION																										
				(TRADEID,BANKTRADEID,SYSTEMTRADEID,MONEY,UPDATESTAFFNO,UPDATETIME)																										
				VALUES																										
				(v_tradeID,v_cur.BID,v_cur.TID,v_cur.MONEY,p_currOper,v_now);			 
				EXCEPTION WHEN OTHERS THEN
				p_retCode := 'SBFJ002004';
				p_retMsg  := '插入【账单关联表】失败' || SQLERRM;
				ROLLBACK; RETURN;	 
			 END;
			 
			 --2.4插入【账单关联台账表】
			 BEGIN
				INSERT INTO TF_B_BFJ_CHECK																																										
				(TRADEID,BANKTRADEID,SYSTEMTRADEID,TRADECODE,MONEY,BANKUSEDMONEY,BANKLEFTMONEY,TRADEUSEDMONEY,TRADELEFTMONEY,OPERATESTAFFNO,OPERATETIME)																																										
				VALUES																																										
				(v_tradeID,v_cur.BID,v_cur.TID,'1',v_cur.MONEY,v_cur.BUSED,v_cur.BLEFT,v_cur.TUSED,v_cur.TLEFT,p_currOper,v_now);	 
				EXCEPTION WHEN OTHERS THEN
				p_retCode := 'SBFJ002005';
				p_retMsg  := '插入【账单关联台账表】失败' || SQLERRM;
				ROLLBACK; RETURN;	 
			 END; 
		 END IF;
		 END LOOP;
	END;
	
	 
	
	/*
	--3) 查询代理营业厅入金及银行账务
	已取消
	*/
	
	--4)查询出租车转账系统账单及银行账单
	/*
	 已取消
	*/
	
	--5.查询商户转账系统账单及银行账单
	BEGIN
		FOR v_cur IN (
			SELECT T.TRADEID TID,O.TRADEID BID,T.TRADEMONEY MONEY,NVL(O.USEDMONEY,0) BUSED,NVL(O.LEFTMONEY,O.TRADECHARGE) BLEFT,T.USEDMONEY TUSED,T.LEFTMONEY TLEFT																																																			
			FROM  TF_F_BFJ_TRADERECORD T  																																																					
			INNER JOIN TF_F_BFJ_OCAB O ON O.TRADECHARGE = T.TRADEMONEY AND O.OTHERUSERNAME = T.OTHERUSERNAME AND O.OTHERBANKACCOUNT = T.OTHERBANKACCOUNT
			--INNER JOIN TD_M_BFJ_BANK B ON O.BANKNAME = B.SYSTEMCODE AND O.BANKACCOUNT = B.ACCOUNT
			WHERE T.TRADETYPECODE IN('06', '08')	 
			AND T.ISNEEDMATCH = '0'  				
			AND O.AMOUNTTYPE = '1'		
			AND  (O.ISNEEDMATCH IS NULL OR O.ISNEEDMATCH = '0')  	
			AND  (O.LEFTMONEY IS NULL OR O.LEFTMONEY  =  O.TRADECHARGE) 
			AND  (T.LEFTMONEY IS NULL OR T.LEFTMONEY  =  T.TRADEMONEY)
			ORDER BY O.FILEDATE,T.TRADEDATE
		 )
		 LOOP
		 BEGIN
					--判断记录是否已经被匹配
					BEGIN
						SELECT COUNT(1) INTO v_count
						FROM TF_F_BFJ_BANKRELATION
						WHERE BANKTRADEID = v_cur.BID OR SYSTEMTRADEID = v_cur.TID; 
						EXCEPTION WHEN OTHERS THEN
						p_retCode := 'SBFJ002006';
						p_retMsg  := '判断记录是否已经被匹配失败' || SQLERRM;
						ROLLBACK; RETURN; 
					END;
					
					IF v_count = 0 THEN
					
						--5.2)更新【银行备付金交易明细表】 	
						BEGIN
							UPDATE TF_F_BFJ_OCAB SET USEDMONEY = NVL(USEDMONEY,0) + v_cur.MONEY,LEFTMONEY = NVL(LEFTMONEY,TRADECHARGE) - v_cur.MONEY																																					
							WHERE TRADEID = v_cur.BID;
							EXCEPTION WHEN OTHERS THEN
							p_retCode := 'SBFJ002003';
							p_retMsg  := '更新【银行备付金交易明细表】失败' || SQLERRM;
							ROLLBACK; RETURN;	 
						END;
						
						--5.3)更新【系统业务账单表】
						 BEGIN
							UPDATE TF_F_BFJ_TRADERECORD SET USEDMONEY = NVL(USEDMONEY,0) + v_cur.MONEY,LEFTMONEY = NVL(LEFTMONEY,TRADEMONEY) - v_cur.MONEY																																					
							WHERE TRADEID = v_cur.TID;
							EXCEPTION WHEN OTHERS THEN
							p_retCode := 'SBFJ002003';
							p_retMsg  := '更新【系统业务账单表】失败' || SQLERRM;
							ROLLBACK; RETURN;	 
						 END;
						 v_tradeID := FUN_GETBFJTRADEID(p_tradeDate);
						 --5.4)插入【账单关联表】
						 BEGIN
							INSERT INTO TF_F_BFJ_BANKRELATION																										
							(TRADEID,BANKTRADEID,SYSTEMTRADEID,MONEY,UPDATESTAFFNO,UPDATETIME)																										
							VALUES																										
							(v_tradeID,v_cur.BID,v_cur.TID,v_cur.MONEY,p_currOper,v_now);			 
							EXCEPTION WHEN OTHERS THEN
							p_retCode := 'SBFJ002004';
							p_retMsg  := '插入【账单关联表】失败' || SQLERRM;
							ROLLBACK; RETURN;	 
						 END;
						 
						 --5.5插入【账单关联台账表】
						 BEGIN
							INSERT INTO TF_B_BFJ_CHECK																																										
							(TRADEID,BANKTRADEID,SYSTEMTRADEID,TRADECODE,MONEY,BANKUSEDMONEY,BANKLEFTMONEY,TRADEUSEDMONEY,TRADELEFTMONEY,OPERATESTAFFNO,OPERATETIME)																																										
							VALUES																																										
							(v_tradeID,v_cur.BID,v_cur.TID,'1',v_cur.MONEY,v_cur.BUSED,v_cur.BLEFT,v_cur.TUSED,v_cur.TLEFT,p_currOper,v_now);	 
							EXCEPTION WHEN OTHERS THEN
							p_retCode := 'SBFJ002005';
							p_retMsg  := '插入【账单关联台账表】失败' || SQLERRM;
							ROLLBACK; RETURN;	 
						 END;
				END IF;
		 END;
		 END LOOP; 
	END;
	
	
	
	p_retCode := '0000000000';
    p_retMsg  := 'OK';
    COMMIT; 
    RETURN;  
end;
/
show errors