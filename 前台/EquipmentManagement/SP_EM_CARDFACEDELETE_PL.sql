create or replace procedure SP_EM_CARDFACEDELETE
(
		p_cardsurfacecode char,	--�������
		p_currOper       char,	--Ա������
		p_currDept	     char,	--���ű���
		p_retCode	     out char, -- Return Code
		p_retMsg     	 out varchar2  -- Return Message
)
as
		v_cardsamplecode	CHAR(6);	--��������
		v_ex		EXCEPTION;
BEGIN
	
	SELECT CARDSAMPLECODE INTO v_cardsamplecode FROM TD_M_CARDSURFACE
		WHERE  CARDSURFACECODE = p_cardsurfacecode;
	BEGIN	
	INSERT INTO TH_M_CARDSAMPLE
			(CARDSAMPLECODE,BACKUPTIME,CARDSAMPLE,UPDATESTAFFNO,UPDATETIME,REMARK)
	SELECT v_cardsamplecode,SYSDATE,CARDSAMPLE,UPDATESTAFFNO,UPDATETIME,REMARK
			FROM TD_M_CARDSAMPLE
			WHERE CARDSAMPLECODE = v_cardsamplecode;
			
	IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
			EXCEPTION
			      WHEN OTHERS THEN
			          p_retCode := 'S094780009';
			          p_retMsg  := '���ӿ�����뱸�ݱ�ʧ��' || SQLERRM;
			      ROLLBACK; RETURN;
	END;		
	
	DELETE TD_M_CARDSAMPLE WHERE CARDSAMPLECODE = v_cardsamplecode;
	
	BEGIN
	UPDATE TD_M_CARDSURFACE 
		SET CARDSAMPLECODE = '',
			UPDATESTAFFNO = p_currOper,
			UPDATETIME = sysdate
		WHERE CARDSURFACECODE = p_cardsurfacecode;
	IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
			EXCEPTION
			      WHEN OTHERS THEN
			          p_retCode := 'S094780007';
			          p_retMsg  := '���¿�������ʧ��' || SQLERRM;
			      ROLLBACK; RETURN;
	END;
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/
show errors