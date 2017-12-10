create or replace procedure SP_RM_WARNCHARGECARD
(
		p_sessionID		 char,		--�ỰID
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
				IF v_c.F1 = '0' THEN	--��ӹ���
				BEGIN
					INSERT INTO TD_M_CHCARDWARNCONFIG
						(VALUECODE,UPDATESTAFFNO,UPDATETIME)
						VALUES(v_c.F2,p_currOper,v_data);
					IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
					EXCEPTION
							  WHEN OTHERS THEN
								  p_retCode := 'S094780004';
								  p_retMsg  := '��ӳ�ֵ�������˱�ʧ��' || SQLERRM;
							  ROLLBACK; RETURN;
					
				END;
				END IF;
				IF v_c.F1 = '1' THEN	--ɾ������
				BEGIN
					DELETE TD_M_CHCARDWARNCONFIG WHERE VALUECODE = v_c.F2;
					IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
					EXCEPTION
							  WHEN OTHERS THEN
								  p_retCode := 'S094780005';
								  p_retMsg  := 'ȡ����ֵ�������˱�ʧ��' || SQLERRM;
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