--------------------------------------------------
--  ��Ŀ����-�����Ŀ�ƻ�
--  ���α�д
--  ����
--  2012-12-18
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_PM_ADDPROJECTJOB
(
		P_PROJECTCODE		 varchar2,
    P_JOBDESC      	 varchar2, 			 
    P_EXPECTEDDATE   varchar2,			 
		P_JOBSTAFF			 varchar2,			 
		P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
		v_seqNo							CHAR(16);
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
    V_COUNT           INT;

BEGIN
	
	--��ȡ��ˮ��
	SP_GetSeq(seq => v_seqNo); 
	
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
	
	--��ӵ���Ŀ�ƻ���
	BEGIN
		INSERT INTO TF_B_PROJECTJOB(																					
    JOBCODE         , PROJECTCODE     , JOBDESC           ,  EXPECTEDDATE      ,																						
    JOBSTAFF        , COMPLETEDESC    , ACTUALDATE        ,  UPDATESTAFFNO     , UPDATETIME																					
		)
		VALUES
		(v_seqNo       ,  P_PROJECTCODE   ,  P_JOBDESC        ,  TO_DATE(P_EXPECTEDDATE,'YYYYMMDD'),																						
		 P_JOBSTAFF    , null             ,   null            ,   P_CURROPER       , V_TODAY);																						
															
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S094780027';
					  P_RETMSG  := '��ӵ���Ŀ�ƻ���ʧ��'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	--��¼��Ŀ̨�ʱ�
	BEGIN
			INSERT INTO TF_B_PROJECTTRADE(																						
	    TRADEID         , OPERATETYPECODE  ,  PROJECTNAME     ,  STARTDATE     ,																						
	    PROJECTDESC     , JOBDESC          ,  EXPECTEDDATE    ,  JOBSTAFF      ,																						
	    COMPLETEDESC    , ACTUALDATE       ,  OPERATETIME     , OPERATESTAFF   , REMARK		)
	    SELECT v_seqNo  ,'03'              ,  PROJECTNAME     ,STARTDATE       ,
	    PROJECTDESC,P_JOBDESC,TO_DATE(P_EXPECTEDDATE,'YYYYMMDD'),P_JOBSTAFF,
	     null         ,    null          ,     V_TODAY      ,   P_CURROPER    , null
	    FROM TD_M_PROJECT
	    WHERE PROJECTCODE = P_PROJECTCODE;																			
			 
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S094780025';
					  P_RETMSG  := '��¼��Ŀ̨�ʱ�ʧ��'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
show errors


