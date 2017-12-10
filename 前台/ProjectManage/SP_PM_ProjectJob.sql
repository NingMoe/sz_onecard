--------------------------------------------------
--  项目修改
--  初次编写
--  董翔
--  2012-12-19
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_PM_ProjectJob
(
  P_PROJECTCODE    varchar2, 			 
  P_JOBCODE   		 varchar2, 			
  P_COMPLETEDESC   varchar2,			  
	P_ACTUALDATE	   varchar2,			 
	P_CURROPER        CHAR,
  P_CURRDEPT        CHAR,
  p_retCode     out char, -- Return Code
  p_retMsg      out varchar2  -- Return Message
)
AS
    v_seqNo						CHAR(16);
    V_COUNT           INT     ;      
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
	
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
	
	--验证项目计划是否已经完成
	BEGIN
		SELECT  COUNT(1) INTO V_COUNT FROM  TF_B_PROJECTJOB WHERE JOBCODE = P_JOBCODE AND ACTUALDATE IS NOT NULL ;
		IF V_COUNT > 0 THEN 
			P_RETCODE := 'S094780025';
			P_RETMSG  := '当前项目计划已经完成,无法修改';
			ROLLBACK; RETURN;
		END IF;
	END;
	
	--修改项目计划表
	BEGIN
		UPDATE TF_B_PROJECTJOB SET 	ACTUALDATE = TO_DATE(P_ACTUALDATE,'YYYYMMDD')   ,													
                        COMPLETEDESC    =  P_COMPLETEDESC,													
                        UPDATESTAFFNO = P_CURROPER,													
                        UPDATETIME    = V_TODAY													
                     WHERE JOBCODE = P_JOBCODE;													

		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S094780027';
					  P_RETMSG  := '修改项目计划表失败'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	--添加到项目台帐表
	BEGIN
		INSERT INTO TF_B_PROJECTTRADE(																					
    TRADEID         , OPERATETYPECODE  ,  PROJECTNAME     ,  STARTDATE     ,																					
    PROJECTDESC     , JOBDESC          ,  EXPECTEDDATE    ,  JOBSTAFF      ,																					
    COMPLETEDESC    , ACTUALDATE       ,  OPERATETIME     ,  OPERATESTAFF  , REMARK	)																				
		SELECT v_seqNo  ,'06'              ,  PROJECTNAME     ,  STARTDATE     ,
	    PROJECTDESC   ,JOBDESC           ,  EXPECTEDDATE    ,  JOBSTAFF      ,
	    P_COMPLETEDESC,TO_DATE(P_ACTUALDATE,'YYYYMMDD')     ,     V_TODAY    ,   P_CURROPER    , null
	    FROM TD_M_PROJECT P
	    INNER JOIN TF_B_PROJECTJOB PB ON P.PROJECTCODE = PB.PROJECTCODE
	    WHERE P.PROJECTCODE = P_PROJECTCODE AND JOBCODE = P_JOBCODE;	
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S094780025';
					  P_RETMSG  := '添加项目台帐表失败'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
show errors


