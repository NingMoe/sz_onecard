create or replace procedure SP_EM_CARDFACEADD
(
	p_cardsurfacecode char,		--卡面编码
	p_cardsurfacename char,		--卡面名称
	p_cardsurfacenote char,		--卡面说明
	p_usetag		  char,		--有效标志
	p_hascardsample   char,     --是否添加卡样
	p_currOper       char,		--员工编码
	p_currDept	     char,		--部门编码
	p_outcardsamplecode out char,	--卡样编码
	p_retCode	     out char, -- Return Code
	p_retMsg     	 out varchar2  -- Return Message
)
as
	v_cardsample     BLOB;
	v_cardsamplecode int;
	v_data           date := sysdate;
	v_ex             EXCEPTION;
BEGIN
	IF p_hascardsample = '1' THEN --同时添加卡样
		SELECT TD_M_CARDSAMPLE_SEQ.NEXTVAL INTO v_cardsamplecode FROM DUAL;
		
		BEGIN
			INSERT INTO TD_M_CARDSURFACE
				(CARDSURFACECODE,CARDSURFACENAME,CARDSURFACENOTE,USETAG,CARDSAMPLECODE,UPDATESTAFFNO,UPDATETIME)
			VALUES(p_cardsurfacecode,p_cardsurfacename,p_cardsurfacenote,p_usetag,v_cardsamplecode,p_currOper,v_data);

			IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
			EXCEPTION
					  WHEN OTHERS THEN
						  p_retCode := 'S094780008';
						  p_retMsg  := '增加卡面编码表失败' || SQLERRM;
					  ROLLBACK; RETURN;
		END;
		
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
	
	ELSE --不添加卡样
		BEGIN
			INSERT INTO TD_M_CARDSURFACE
				(CARDSURFACECODE,CARDSURFACENAME,CARDSURFACENOTE,USETAG,UPDATESTAFFNO,UPDATETIME)
			VALUES(p_cardsurfacecode,p_cardsurfacename,p_cardsurfacenote,p_usetag,p_currOper,v_data);

			IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
			EXCEPTION
				WHEN OTHERS THEN
				p_retCode := 'S094780008';
				p_retMsg  := '增加卡面编码表失败' || SQLERRM;
				ROLLBACK; RETURN;
		END;
	
	END IF;
	
	p_outcardsamplecode := v_cardsamplecode;
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/
show errors