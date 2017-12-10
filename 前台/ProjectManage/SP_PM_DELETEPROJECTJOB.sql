--------------------------------------------------
--  ɾ����Ŀ�ƻ�
--  ���α�д
--  ����
--  2012-12-18
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_PM_DELETEPROJECTJOB
(
    P_PROJECTCODE     varchar2,
    P_JOBCODE   varchar2, 		
		P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    V_COUNT           INT     ;     
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
	  v_seqNo						CHAR(16);
BEGIN
	--У����Ŀ
	BEGIN
		SELECT COUNT(1) INTO V_COUNT 
		FROM TD_M_PROJECT
		WHERE PROJECTCODE = P_PROJECTCODE;
		IF V_COUNT != 1 THEN 
			P_RETCODE := 'S094780025';
			P_RETMSG  := '��ѡ��Ŀ������';
			ROLLBACK; RETURN;
		END IF;
	END;
	
	--��֤��Ŀ�ƻ��Ƿ��Ѿ����
	BEGIN
		SELECT  COUNT(1) INTO V_COUNT FROM  TF_B_PROJECTJOB WHERE JOBCODE = P_JOBCODE AND ACTUALDATE IS NOT NULL ;
		IF V_COUNT > 0 THEN 
			P_RETCODE := 'S094780025';
			P_RETMSG  := '��ǰ��Ŀ�ƻ��Ѿ����,�޷��޸�';
			ROLLBACK; RETURN;
		END IF;
	END;
	
	--��ȡ��ˮ��
 	SP_GetSeq(seq => v_seqNo); 
	
	--��ӵ���Ŀ̨�ʱ�
	BEGIN
		INSERT INTO TF_B_PROJECTTRADE(																					
    TRADEID         , OPERATETYPECODE  ,  PROJECTNAME     ,  STARTDATE     ,																					
    PROJECTDESC     , JOBDESC          ,  EXPECTEDDATE    ,  JOBSTAFF      ,																					
    COMPLETEDESC    , ACTUALDATE       ,  OPERATETIME     , OPERATESTAFF   , REMARK																					
		)
		SELECT v_seqNo  ,'04'              ,  PROJECTNAME     ,STARTDATE       ,
	    PROJECTDESC,  JOBDESC            ,  EXPECTEDDATE    ,JOBSTAFF        ,
	     null         ,    null          ,     V_TODAY      ,   P_CURROPER    , null
	    FROM TD_M_PROJECT P
	    INNER JOIN TF_B_PROJECTJOB PB ON P.PROJECTCODE = PB.PROJECTCODE
	    WHERE P.PROJECTCODE = P_PROJECTCODE AND JOBCODE = P_JOBCODE;		
		IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		  EXCEPTION
			 WHEN OTHERS THEN
				  p_retCode := 'S094780025'; p_retMsg  := '��ӵ���Ŀ̨�ʱ�ʧ��' || SQLERRM;
				  ROLLBACK; RETURN;		
	END;
	
	--ɾ����Ŀ�ƻ���
	BEGIN
		DELETE  TF_B_PROJECTJOB   WHERE  JOBCODE = P_JOBCODE;
		IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		  EXCEPTION
			 WHEN OTHERS THEN
				  p_retCode := 'S094780028'; p_retMsg  := 'ɾ����Ŀ�ƻ���ʧ��' || SQLERRM;
				  ROLLBACK; RETURN;		
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
show errors


