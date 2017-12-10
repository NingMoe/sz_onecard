--------------------------------------------------
--  ��Ŀ�޸�
--  ���α�д
--  ����
--  2012-12-18
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_PM_EDITPROJECT
(
  P_PROJECTCODE   varchar2, 			--��Ŀ���
  P_PROJECTNAME   varchar2,			  --��Ŀ����
	P_STARTDATE			varchar2,				--��Ŀ��ʼ����
	P_PROJECTDESC		varchar2,				--��Ŀ�ſ�
	P_CURROPER        CHAR,
  P_CURRDEPT        CHAR,
  p_retCode     out char, -- Return Code
  p_retMsg      out varchar2  -- Return Message
)
AS
    v_seqNo						CHAR(16);
    V_EXIST           DATE     ;      
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
	
BEGIN
  --��ȡ��ˮ��
 	SP_GetSeq(seq => v_seqNo); 
	
	--��֤�������
	BEGIN
		SELECT  MAX(EXPECTEDDATE) INTO v_exist FROM  TF_B_PROJECTJOB WHERE PROJECTCODE = P_PROJECTCODE;
		EXCEPTION WHEN OTHERS THEN
			 v_exist := V_TODAY;
	END;
	
	BEGIN
			IF to_date(P_STARTDATE,'YYYYMMDD') >  v_exist THEN 
				 		P_RETCODE := 'A094780038';
					  P_RETMSG  := '��Ŀ��ʼʱ�䲻�ܳ��ڼƻ�Ԥ���������';
					  ROLLBACK; RETURN;
			END IF;
	END;
	
	--�޸���Ŀ��
	BEGIN
		UPDATE TD_M_PROJECT SET PROJECTNAME  =  P_PROJECTNAME ,																
                        		STARTDATE    =  to_date(P_STARTDATE,'YYYYMMDD'),																
                        		PROJECTDESC  =  P_PROJECTDESC,																
                        		UPDATESTAFFNO = P_CURROPER,																
                        		UPDATETIME    = V_TODAY																
                     		WHERE PROJECTCODE = P_PROJECTCODE;																

		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S094780024';
					  P_RETMSG  := '������Ŀ��ʧ��'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	--��ӵ���Ŀ̨�ʱ�
	BEGIN
		INSERT INTO TF_B_PROJECTTRADE(																					
    TRADEID         , OPERATETYPECODE  ,  PROJECTNAME     ,  STARTDATE     ,																					
    PROJECTDESC     , JOBDESC          ,  EXPECTEDDATE    ,  JOBSTAFF      ,																					
    COMPLETEDESC    , ACTUALDATE       ,  OPERATETIME     , OPERATESTAFF   , REMARK																					
)VALUES(v_seqNo     ,      '02'        ,  P_PROJECTNAME   , to_date(P_STARTDATE,'YYYYMMDD')    ,																					
    P_PROJECTDESC   ,    null          ,        null      ,   null         ,      																					
       null         ,    null          ,     V_TODAY      ,   P_CURROPER    , null);																					

		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S094780025';
					  P_RETMSG  := '�����Ŀ̨�ʱ�ʧ��'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
show errors


