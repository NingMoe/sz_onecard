--------------------------------------------------
--  ��Դ����ɾ���洢����
--  ���α�д
--  ������
--  2012-12-06
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_OTHER_ConditionDelete
(
    P_RESOURCECODE      CHAR, 			--��Դ����
	
	P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    
    V_EXIST           INT     ;     --��������
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
	
BEGIN
	--��֤����Դ�Ƿ��Ѿ��µ�
	
	SELECT  COUNT(*) INTO v_exist FROM  TF_F_RESOURCEAPPLYORDER WHERE RESOURCECODE = P_RESOURCECODE;
		IF v_exist > 0 THEN
			P_RETCODE := 'A001002108';
			P_RETMSG  := '����Դ���µ����޷�ִ��ɾ������';
			ROLLBACK; RETURN;
		END IF;
	
	--ɾ����Դ��
	BEGIN
		
		DELETE  TD_M_RESOURCE   WHERE  RESOURCECODE=P_RESOURCECODE;

		IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		  EXCEPTION
			 WHEN OTHERS THEN
				  p_retCode := 'S001002108'; p_retMsg  := 'ɾ����Դ��ʧ��' || SQLERRM;
				  ROLLBACK; RETURN;		
	END;
	
	--ɾ�������ܱ�
	BEGIN
		
		DELETE  TL_R_RESOURCESUM  WHERE RESOURCECODE = P_RESOURCECODE;

		IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		  EXCEPTION
			 WHEN OTHERS THEN
				  p_retCode := 'S001002109'; p_retMsg  := 'ɾ�������ܱ�ʧ��' || SQLERRM;
				  ROLLBACK; RETURN;		
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
show errors


