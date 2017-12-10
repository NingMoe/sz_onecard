--------------------------------------------------
--  ��Դ�����޸Ĵ洢����
--  ���α�д
--  ������
--  2012-12-06
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_OTHER_ConditionModify
(
    P_RESOURCECODE      CHAR, 			--��Դ����
    P_RESOURCENAME      CHAR,			--��Դ����
	P_RESOURCETYPE		CHAR,			--��Դ����
	P_DESCPIRTION		varchar2,		--��Դ����
	P_ATTRIBUTE1		CHAR,			--����1
	P_ATTRIBUTETYPE1	CHAR,			--����1�Ƿ���������
	P_ATTRIBUTEISNULL1	CHAR,			--����1�Ƿ����
	P_ATTRIBUTE2		CHAR,			--����2
	P_ATTRIBUTETYPE2	CHAR,			--����2�Ƿ���������
	P_ATTRIBUTEISNULL2	CHAR,			--����2�Ƿ����
	P_ATTRIBUTE3		CHAR,			--����3
	P_ATTRIBUTETYPE3	CHAR,			--����3�Ƿ���������
	P_ATTRIBUTEISNULL3	CHAR,			--����3�Ƿ����
	P_ATTRIBUTE4		CHAR,			--����4
	P_ATTRIBUTETYPE4	CHAR,			--����4�Ƿ���������
	P_ATTRIBUTEISNULL4	CHAR,			--����4�Ƿ����
	P_ATTRIBUTE5		CHAR,			--����5
	P_ATTRIBUTETYPE5	CHAR,			--����5�Ƿ���������
	P_ATTRIBUTEISNULL5	CHAR,			--����5�Ƿ����
	P_ATTRIBUTE6		CHAR,			--����6
	P_ATTRIBUTETYPE6	CHAR,			--����6�Ƿ���������
	P_ATTRIBUTEISNULL6	CHAR,			--����6�Ƿ����
	
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
	--��֤��Դ�����ڿ����Ƿ����
	
	SELECT COUNT(*) INTO v_exist FROM  TD_M_RESOURCE WHERE RESOURCENAME = P_RESOURCENAME  AND RESOURCECODE!= P_RESOURCECODE;
		IF v_exist > 0 THEN
			P_RETCODE := 'A001002106';
			P_RETMSG  := '���д���Դ���ƴ����ڿ���';
			ROLLBACK; RETURN;
		END IF;
	
	--��֤����Դ�Ƿ��Ѿ��µ�
		SELECT  COUNT(*) INTO v_exist FROM  TF_F_RESOURCEAPPLYORDER WHERE RESOURCECODE = P_RESOURCECODE;
		IF v_exist > 0 THEN
			P_RETCODE := 'A001002107';
			P_RETMSG  := '����Դ���µ�,�޷�ִ���޸Ĳ���';
		ROLLBACK; RETURN;
		END IF;
	
	--�޸���Դ��
	BEGIN
		
		UPDATE   TD_M_RESOURCE A																														
		SET     A.RESOURCENAME =P_RESOURCENAME, A.RESOURCETYPE =P_RESOURCETYPE,A.DESCPIRTION= P_DESCPIRTION,																														
				A.ATTRIBUTE1=P_ATTRIBUTE1,  A.ATTRIBUTETYPE1=P_ATTRIBUTETYPE1, A.ATTRIBUTEISNULL1=P_ATTRIBUTEISNULL1, 																												
				A.ATTRIBUTE2=P_ATTRIBUTE2,  A.ATTRIBUTETYPE2=P_ATTRIBUTETYPE2, A.ATTRIBUTEISNULL2=P_ATTRIBUTEISNULL2, 																												
				A.ATTRIBUTE3=P_ATTRIBUTE3,  A.ATTRIBUTETYPE3=P_ATTRIBUTETYPE3, A.ATTRIBUTEISNULL3=P_ATTRIBUTEISNULL3, 																												
				A.ATTRIBUTE4=P_ATTRIBUTE4,  A.ATTRIBUTETYPE4=P_ATTRIBUTETYPE4, A.ATTRIBUTEISNULL4=P_ATTRIBUTEISNULL4, 																												
				A.ATTRIBUTE5=P_ATTRIBUTE5,  A.ATTRIBUTETYPE5=P_ATTRIBUTETYPE5, A.ATTRIBUTEISNULL5=P_ATTRIBUTEISNULL5, 																												
				A.ATTRIBUTE6=P_ATTRIBUTE6,  A.ATTRIBUTETYPE6=P_ATTRIBUTETYPE6, A.ATTRIBUTEISNULL6=P_ATTRIBUTEISNULL6, 																												
				A.UPDATESTAFFNO=P_CURROPER ,A.UPDATETIME=V_TODAY																												
		WHERE	A.RESOURCECODE=P_RESOURCECODE;																												

		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S001002106';
					  P_RETMSG  := '������Դ��ʧ��'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
show errors


