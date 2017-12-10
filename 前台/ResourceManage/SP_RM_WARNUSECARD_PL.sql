create or replace procedure SP_RM_WARNUSECARD
(
		p_sessionID		 char,		--�ỰID
		p_currOper       char,		--Ա������
		p_currDept	     char,		--���ű���
		p_retCode	       out char, -- Return Code
		p_retMsg     	   out varchar2  -- Return Message
)
as
		v_data		date;
		v_ex		EXCEPTION;
BEGIN
	v_data :=sysdate;
	BEGIN
		FOR v_c in (select * from tmp_common where F0 = p_sessionID)
			LOOP
				IF v_c.F1 = '0' THEN	--��ӹ���
				BEGIN
					INSERT INTO TD_M_USECARDWARNCONFIG
						(CARDSURFACECODE,UPDATESTAFFNO,UPDATETIME)
						VALUES(v_c.F2,p_currOper,v_data);
					IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
					EXCEPTION
							  WHEN OTHERS THEN
								  p_retCode := 'S094780002';
								  p_retMsg  := '����û��������˱�ʧ��' || SQLERRM;
							  ROLLBACK; RETURN;
				END;
				END IF;
				IF v_c.F1 = '1' THEN	--ȡ������
				BEGIN
					DELETE TD_M_USECARDWARNCONFIG WHERE CARDSURFACECODE = v_c.F2;
					IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
					EXCEPTION
							  WHEN OTHERS THEN
								  p_retCode := 'S094780003';
								  p_retMsg  := 'ȡ���û��������˱�ʧ��' || SQLERRM;
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