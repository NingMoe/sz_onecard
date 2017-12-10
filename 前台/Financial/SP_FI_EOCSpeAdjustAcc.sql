CREATE OR REPLACE PROCEDURE SP_FI_EOCSpeAdjustAcc
(
    P_FUNCTION          VARCHAR, --功能编码
    p_DATE              CHAR,    --日期
    p_CateGory          CHAR,    --收支类别
    p_money             INT,     --金额
    p_remark            VARCHAR, --备注
	p_TYPE				CHAR,	 --业务类型
	p_TRADETYPE			CHAR,	 --交易类型
	p_BFJTRADETYPECODE	CHAR,	 --支付业务类型编码
	p_ISCASH			CHAR,	 --是否现金 0非现金 1现金
	p_ACCOUNT			CHAR,	 --资金账户
    P_ID                CHAR,
    p_currOper          char,
    p_currDept          char,
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message    
)
AS
	V_SEQNO     	CHAR(16);
	V_COUNT			INT;
    v_ex             exception;
	v_CateGofry      varchar2(20);
BEGIN
    IF P_FUNCTION = 'ADD' THEN
		IF p_TYPE = '1' THEN
			BEGIN
				--记录沉淀资金分析表
				insert into TF_FUNDSANALYSIS(
					ID          , STATTIME   , CATEGORY   , NAME  ,
					MONEY       , REMARK
				)values(
					sys_guid()  , p_date     , p_category , '财务调账',
					decode(p_CateGory,'沉淀资金收入',p_money,-abs(p_money)), p_remark);

				IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
			EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S094570360';
					p_retMsg  := '记录沉淀资金分析表失败' || SQLERRM;
					ROLLBACK; RETURN;
			END;
		ELSIF p_TYPE = '2' THEN
			SP_GETSEQ(SEQ => V_SEQNO);
			BEGIN
			--记录业务帐务列表
			INSERT INTO TF_F_BFJ_TRADERECORD
			(TRADEID,TRADEDATE,NAME,AMOUNTTYPE,TRADETYPECODE,TRADEMONEY,
			FEE,BFJTRADETYPECODE,OTHERBANK,OTHERUSERNAME,OTHERBANKACCOUNT,ISCASH,
			DEPARTID,USEDMONEY,LEFTMONEY,ISNEEDMATCH,ACCOUNT,REMARK)
			VALUES
			(V_SEQNO,TO_DATE(p_date,'YYYYMMDD'),p_remark||':备付金手工录入',decode(p_CateGory,'沉淀资金收入','0','1'),p_TRADETYPE,p_money,
			'',p_BFJTRADETYPECODE,'','','',p_ISCASH,
			p_currDept,'0',p_money,'0',p_ACCOUNT,p_remark);
			
				IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
			EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S094570467';
					p_retMsg  := '记录业务帐务列表失败' || SQLERRM;
					ROLLBACK; RETURN;
			END;

		END IF;
    END IF;
    
    IF P_FUNCTION = 'DELETE' THEN
		IF p_TYPE = '1' THEN
			BEGIN
				--删除沉淀资金分析表
				DELETE FROM TF_FUNDSANALYSIS WHERE ID = p_ID;
				
				IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
			EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S094570361';
					p_retMsg  := '删除沉淀资金分析表记录失败' || SQLERRM;
					ROLLBACK; RETURN;        
			END;
		ELSIF p_TYPE = '2' THEN
			
			BEGIN
				SELECT COUNT(1) INTO V_COUNT FROM TF_F_BFJ_TRADERECORD T WHERE T.TRADEID = P_ID AND T.LEFTMONEY = '0';
				EXCEPTION 
					WHEN NO_DATA_FOUND THEN NULL;
			END;
			
			IF V_COUNT > 0 THEN
				p_retCode := 'S094570421';
				p_retMsg  := '业务记录已经使用，不允许删除';
				ROLLBACK; RETURN;  
			END IF;
		
			BEGIN
				--删除业务帐务列表
				DELETE FROM TF_F_BFJ_TRADERECORD WHERE TRADEID = p_ID;
				
				IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
			EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S094570468';
					p_retMsg  := '删除业务帐务列表记录失败' || SQLERRM;
					ROLLBACK; RETURN;
			END;
		END IF;
    END IF;
    
    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;    
END;

/
SHOW ERRORS