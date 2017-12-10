--------------------------------------------------
--  删除项目计划
--  初次编写
--  董翔
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
	
	--验证项目计划是否已经完成
	BEGIN
		SELECT  COUNT(1) INTO V_COUNT FROM  TF_B_PROJECTJOB WHERE JOBCODE = P_JOBCODE AND ACTUALDATE IS NOT NULL ;
		IF V_COUNT > 0 THEN 
			P_RETCODE := 'S094780025';
			P_RETMSG  := '当前项目计划已经完成,无法修改';
			ROLLBACK; RETURN;
		END IF;
	END;
	
	--获取流水号
 	SP_GetSeq(seq => v_seqNo); 
	
	--添加到项目台帐表
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
				  p_retCode := 'S094780025'; p_retMsg  := '添加到项目台帐表失败' || SQLERRM;
				  ROLLBACK; RETURN;		
	END;
	
	--删除项目计划表
	BEGIN
		DELETE  TF_B_PROJECTJOB   WHERE  JOBCODE = P_JOBCODE;
		IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		  EXCEPTION
			 WHEN OTHERS THEN
				  p_retCode := 'S094780028'; p_retMsg  := '删除项目计划表失败' || SQLERRM;
				  ROLLBACK; RETURN;		
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
show errors


