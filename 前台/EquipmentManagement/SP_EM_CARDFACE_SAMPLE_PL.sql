create or replace procedure SP_EM_CARDFACE_SAMPLE
(
		p_cardsurfacecode char,	--卡面编码
		p_currOper       char,	--员工编码
		p_currDept	     char,	--部门编码
		p_outcardsamplecode out char,	--卡样编码
		p_retCode	     out char, -- Return Code
		p_retMsg     	 out varchar2  -- Return Message
)
as
		v_cardsamplecode	int;
		v_data		date;
		v_ex		EXCEPTION;
BEGIN
	v_data :=sysdate;
	SELECT TD_M_CARDSAMPLE_SEQ.NEXTVAL INTO v_cardsamplecode FROM DUAL;
	
	BEGIN
		INSERT INTO TD_M_CARDSAMPLE
			(CARDSAMPLECODE,UPDATESTAFFNO,UPDATETIME)
			VALUES(v_cardsamplecode,p_currOper,v_data);
		IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
		EXCEPTION
			      WHEN OTHERS THEN
			          p_retCode := 'S094780006';
			          p_retMsg  := '增加卡样编码表失败' || SQLERRM;
			      ROLLBACK; RETURN;
	END;
	BEGIN
		UPDATE TD_M_CARDSURFACE 
		SET CARDSAMPLECODE = v_cardsamplecode,
			UPDATESTAFFNO = p_currOper,
			UPDATETIME = sysdate
		WHERE CARDSURFACECODE = p_cardsurfacecode;
		IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
		EXCEPTION
			      WHEN OTHERS THEN
			          p_retCode := 'S094780007';
			          p_retMsg  := '更新卡面编码表失败' || SQLERRM;
			      ROLLBACK; RETURN;
	END;
	p_outcardsamplecode := v_cardsamplecode;
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/
show errors