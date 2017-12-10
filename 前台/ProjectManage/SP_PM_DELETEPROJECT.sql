--------------------------------------------------
--  ɾ����Ŀ
--  ���α�д
--  ����
--  2012-12-18
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_PM_DELETEPROJECT
(
    P_PROJECTCODE     varchar2,
		P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    V_EXIST           INT     ;     --��������
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
	  v_seqNo						CHAR(16);
BEGIN
	--��֤�ƻ���
	
	SELECT  COUNT(*) INTO v_exist FROM  TF_B_PROJECTJOB WHERE PROJECTCODE = P_PROJECTCODE;
		IF v_exist > 0 THEN
			P_RETCODE := 'A094780037';
			P_RETMSG  := '���мƻ������Ŀ����ɾ��';
			ROLLBACK; RETURN;
		END IF;
	
	--��ȡ��ˮ��
 	SP_GetSeq(seq => v_seqNo); 
	
	--��ӵ���Ŀ̨�ʱ�
	BEGIN
		INSERT INTO TF_B_PROJECTTRADE(																					
    TRADEID         , OPERATETYPECODE  ,  PROJECTNAME     ,  STARTDATE     ,																					
    PROJECTDESC     , JOBDESC          ,  EXPECTEDDATE    ,  JOBSTAFF      ,																					
    COMPLETEDESC    , ACTUALDATE       ,  OPERATETIME     , OPERATESTAFF   , REMARK																					
		)
		SELECT v_seqNo     ,      '01'        ,PROJECTNAME   , STARTDATE    ,																					
    PROJECTDESC   ,    null          ,        null      ,   null         ,      																					
       null         ,    null          ,     V_TODAY      ,   P_CURROPER    , null
    FROM TD_M_PROJECT
    WHERE PROJECTCODE = P_PROJECTCODE;																					
		IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		  EXCEPTION
			 WHEN OTHERS THEN
				  p_retCode := 'S094780025'; p_retMsg  := '��ӵ���Ŀ̨�ʱ�ʧ��' || SQLERRM;
				  ROLLBACK; RETURN;		
	END;
	
	--ɾ����Ŀ��
	BEGIN
		DELETE  TD_M_PROJECT   WHERE  PROJECTCODE = P_PROJECTCODE;
		IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		  EXCEPTION
			 WHEN OTHERS THEN
				  p_retCode := 'S094780026'; p_retMsg  := 'ɾ����Ŀ��ʧ��' || SQLERRM;
				  ROLLBACK; RETURN;		
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
show errors


