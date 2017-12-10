--------------------------------------------------
--  项目修改
--  初次编写
--  董翔
--  2012-12-18
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_PM_EDITPROJECT
(
  P_PROJECTCODE   varchar2, 			--项目编号
  P_PROJECTNAME   varchar2,			  --项目名称
	P_STARTDATE			varchar2,				--项目开始日期
	P_PROJECTDESC		varchar2,				--项目概况
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
  --获取流水号
 	SP_GetSeq(seq => v_seqNo); 
	
	--验证完成日期
	BEGIN
		SELECT  MAX(EXPECTEDDATE) INTO v_exist FROM  TF_B_PROJECTJOB WHERE PROJECTCODE = P_PROJECTCODE;
		EXCEPTION WHEN OTHERS THEN
			 v_exist := V_TODAY;
	END;
	
	BEGIN
			IF to_date(P_STARTDATE,'YYYYMMDD') >  v_exist THEN 
				 		P_RETCODE := 'A094780038';
					  P_RETMSG  := '项目开始时间不能迟于计划预计完成日期';
					  ROLLBACK; RETURN;
			END IF;
	END;
	
	--修改项目表
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
					  P_RETMSG  := '更新项目表失败'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	--添加到项目台帐表
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
					  P_RETMSG  := '添加项目台帐表失败'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
show errors


