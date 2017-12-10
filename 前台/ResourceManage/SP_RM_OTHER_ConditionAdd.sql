--------------------------------------------------
--  ��Դ������Ӵ洢����
--  ���α�д
--  ������
--  2012-12-06
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_OTHER_ConditionAdd
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
	
	SELECT count(*) INTO v_exist FROM  TD_M_RESOURCE WHERE RESOURCECODE = P_RESOURCECODE;
		IF v_exist > 0 THEN
			P_RETCODE := 'A094780195';
			P_RETMSG  := '���д���Դ��������ڿ���';
			ROLLBACK; RETURN;
		END IF;
	
	--��֤��Դ�����ڿ����Ƿ����
		SELECT count(*) INTO v_exist FROM  TD_M_RESOURCE WHERE RESOURCENAME = P_RESOURCENAME;
		IF v_exist > 0 THEN
			P_RETCODE := 'A094780194';
			P_RETMSG  := '���д���Դ���ƴ����ڿ���';
		ROLLBACK; RETURN;
		END IF;
	
	--��¼��Դ��
	BEGIN
		
		INSERT INTO TD_M_RESOURCE(
		RESOURCECODE     , RESOURCENAME    , RESOURCETYPE     , DESCPIRTION     , ATTRIBUTE1     , ATTRIBUTETYPE1    , ATTRIBUTEISNULL1,
		ATTRIBUTE2       ,ATTRIBUTETYPE2   , ATTRIBUTEISNULL2 , ATTRIBUTE3      , ATTRIBUTETYPE3 , ATTRIBUTEISNULL3  , ATTRIBUTE4      ,
		ATTRIBUTETYPE4 , ATTRIBUTEISNULL4  , ATTRIBUTE5      ,ATTRIBUTETYPE5 , ATTRIBUTEISNULL5  , ATTRIBUTE6      ,ATTRIBUTETYPE6 		,
		ATTRIBUTEISNULL6 ,UPDATESTAFFNO    , UPDATETIME)
		VALUES(
		P_RESOURCECODE    , P_RESOURCENAME   , P_RESOURCETYPE     , P_DESCPIRTION    , P_ATTRIBUTE1     , P_ATTRIBUTETYPE1   ,P_ATTRIBUTEISNULL1,
		P_ATTRIBUTE2      ,P_ATTRIBUTETYPE2  , P_ATTRIBUTEISNULL2 , P_ATTRIBUTE3     , P_ATTRIBUTETYPE3 , P_ATTRIBUTEISNULL3  , P_ATTRIBUTE4   ,
		P_ATTRIBUTETYPE4 , P_ATTRIBUTEISNULL4  , P_ATTRIBUTE5   ,P_ATTRIBUTETYPE5 , P_ATTRIBUTEISNULL5  , P_ATTRIBUTE6   ,P_ATTRIBUTETYPE6 		,
		P_ATTRIBUTEISNULL6 ,P_CURROPER  , V_TODAY); 
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S001002104';
					  P_RETMSG  := '��¼��Դ��ʧ��'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	--��¼�����ܱ�
	BEGIN
		INSERT INTO  TL_R_RESOURCESUM(																					
		RESOURCECODE    , INSNUM        , USENUM        ,UPDATESTAFFNO  ,UPDATETIME  )
		VALUES(
		P_RESOURCECODE  , 0             ,0              ,P_CURROPER     ,V_TODAY    );
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S001002105';
					  P_RETMSG  := '��¼�����ܱ�ʧ��'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
show errors


