--------------------------------------------------
--  项目管理-添加项目计划
--  初次编写
--  董翔
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
	
	--获取流水号
	SP_GetSeq(seq => v_seqNo); 
	
	--校验项目
	BEGIN
		SELECT COUNT(1) INTO V_COUNT 
		FROM TD_M_PROJECT
		WHERE PROJECTCODE = P_PROJECTCODE;
		IF V_COUNT != 1 THEN 
			P_RETCODE := 'S094780025';
			P_RETMSG  := '所选项目不存在';
			ROLLBACK; RETURN;
		END IF;
	END;
	
	--添加到项目计划表
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
					  P_RETMSG  := '添加到项目计划表失败'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	--记录项目台帐表
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
					  P_RETMSG  := '记录项目台帐表失败'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
show errors


