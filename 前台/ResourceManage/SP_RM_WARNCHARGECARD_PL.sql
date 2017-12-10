create or replace procedure SP_RM_WARNCHARGECARD
(
		p_sessionID		 char,		--会话ID
		p_currOper       char,
		p_currDept	     char,
		p_retCode	     out char, -- Return Code
		p_retMsg     	 out varchar2  -- Return Message
)
as
		v_data		date;
		v_ex		EXCEPTION;
BEGIN
	v_data :=sysdate;
	BEGIN
		FOR v_c in (select * from tmp_common where F0 = p_sessionID)
			LOOP
				IF v_c.F1 = '0' THEN	--添加过滤
				BEGIN
					INSERT INTO TD_M_CHCARDWARNCONFIG
						(VALUECODE,UPDATESTAFFNO,UPDATETIME)
						VALUES(v_c.F2,p_currOper,v_data);
					IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
					EXCEPTION
							  WHEN OTHERS THEN
								  p_retCode := 'S094780004';
								  p_retMsg  := '添加充值卡库存过滤表失败' || SQLERRM;
							  ROLLBACK; RETURN;
					
				END;
				END IF;
				IF v_c.F1 = '1' THEN	--删除过滤
				BEGIN
					DELETE TD_M_CHCARDWARNCONFIG WHERE VALUECODE = v_c.F2;
					IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
					EXCEPTION
							  WHEN OTHERS THEN
								  p_retCode := 'S094780005';
								  p_retMsg  := '取消充值卡库存过滤表失败' || SQLERRM;
							  ROLLBACK; RETURN;
				END;
				END IF;
			END LOOP;
	END;
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/
show errors