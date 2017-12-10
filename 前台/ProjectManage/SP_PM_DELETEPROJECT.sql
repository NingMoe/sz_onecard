--------------------------------------------------
--  删除项目
--  初次编写
--  董翔
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
    V_EXIST           INT     ;     --存在数量
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
	  v_seqNo						CHAR(16);
BEGIN
	--验证计划项
	
	SELECT  COUNT(*) INTO v_exist FROM  TF_B_PROJECTJOB WHERE PROJECTCODE = P_PROJECTCODE;
		IF v_exist > 0 THEN
			P_RETCODE := 'A094780037';
			P_RETMSG  := '已有计划项的项目不能删除';
			ROLLBACK; RETURN;
		END IF;
	
	--获取流水号
 	SP_GetSeq(seq => v_seqNo); 
	
	--添加到项目台帐表
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
				  p_retCode := 'S094780025'; p_retMsg  := '添加到项目台帐表失败' || SQLERRM;
				  ROLLBACK; RETURN;		
	END;
	
	--删除项目表
	BEGIN
		DELETE  TD_M_PROJECT   WHERE  PROJECTCODE = P_PROJECTCODE;
		IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		  EXCEPTION
			 WHEN OTHERS THEN
				  p_retCode := 'S094780026'; p_retMsg  := '删除项目表失败' || SQLERRM;
				  ROLLBACK; RETURN;		
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
show errors


