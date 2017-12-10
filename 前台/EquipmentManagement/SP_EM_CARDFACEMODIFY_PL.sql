create or replace procedure SP_EM_CARDFACEMODIFY
(
		p_cardsurfacecode VARCHAR2,	--卡面编码
		p_cardsurfacename VARCHAR2, --卡面名称
		p_cardsurfacenote VARCHAR2, --卡面说明
		p_usetag		  char,		--有效标志
		p_currOper       char,		--员工编码
		p_currDept	     char,		--部门编码
		p_exchange		 char,		--操作编码 
		p_outcardsamplecode out char,	--卡样编码
		p_retCode	     out char, -- Return Code
		p_retMsg     	 out varchar2  -- Return Message
)
as
		v_oldcardsamplecode	char(6);	--卡样编码
		v_data		date;
		v_ex		EXCEPTION;
BEGIN
	v_data :=sysdate;

	
	SELECT CARDSAMPLECODE INTO v_oldcardsamplecode
		FROM TD_M_CARDSURFACE WHERE CARDSURFACECODE = p_cardsurfacecode;
		
	BEGIN
	UPDATE TD_M_CARDSURFACE
			SET CARDSURFACENAME = p_cardsurfacename,
				CARDSURFACENOTE = p_cardsurfacenote,
				USETAG			= p_usetag,
				UPDATESTAFFNO	= p_currOper,
				UPDATETIME		= v_data
		WHERE CARDSURFACECODE = p_cardsurfacecode;

		IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
		EXCEPTION
			      WHEN OTHERS THEN
			          p_retCode := 'S094780007';
			          p_retMsg  := '更新卡面编码表失败' || SQLERRM;
			      ROLLBACK; RETURN;
	END;			  
	IF p_exchange = '2' THEN	--增加操作
	BEGIN
		SP_EM_CARDFACE_SAMPLE(p_cardsurfacecode,p_currOper,p_currDept,p_outcardsamplecode,
			p_retCode,p_retMsg);
		IF p_retCode != '0000000000' THEN
        ROLLBACK; RETURN;
		END IF;
	END;
	ELSIF p_exchange = '4' THEN --图片更新
	BEGIN
		INSERT INTO TH_M_CARDSAMPLE
				(CARDSAMPLECODE,BACKUPTIME,CARDSAMPLE,UPDATESTAFFNO,UPDATETIME,REMARK)
			SELECT v_oldcardsamplecode,SYSDATE,CARDSAMPLE,UPDATESTAFFNO,UPDATETIME,REMARK
				FROM TD_M_CARDSAMPLE
				WHERE CARDSAMPLECODE = v_oldcardsamplecode;
			IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
			EXCEPTION
			      WHEN OTHERS THEN
			          p_retCode := 'S094780009';
			          p_retMsg  := '增加卡面编码备份表失败' || SQLERRM;
			      ROLLBACK; RETURN;
	END;
	
	BEGIN
		UPDATE TD_M_CARDSAMPLE 
			SET UPDATESTAFFNO = p_currOper,
				UPDATETIME    = v_data
		WHERE 	CARDSAMPLECODE = v_oldcardsamplecode;
		IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
			EXCEPTION
			      WHEN OTHERS THEN
			          p_retCode := 'S094780010';
			          p_retMsg  := '更新卡样编码表失败' || SQLERRM;
			      ROLLBACK; RETURN;
	END;
	END IF;
	IF(p_outcardsamplecode is null or p_outcardsamplecode = '') THEN
		p_outcardsamplecode := v_oldcardsamplecode;
	END IF;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/
show errors