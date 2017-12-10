--------------------------------------------------
--  项目管理-添加项目
--  初次编写
--  董翔
--  2012-12-18
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_PM_ADDPROJECT
(
    P_PROJECTNAME      varchar2, 			--项目名称
    P_STARTDATE      	 varchar2,			--项目开始日期
		P_PROJECTDESC			 varchar2,			--项目概况
		P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
		v_seqNo							CHAR(16);
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;

BEGIN
	
	--获取流水号
	SP_GetSeq(seq => v_seqNo); 
	
	--新增项目表
	BEGIN
		INSERT INTO TD_M_PROJECT(																			
    PROJECTCODE     , PROJECTNAME      ,  STARTDATE       ,  PROJECTDESC  ,																			
    UPDATESTAFFNO   , UPDATETIME																			
		)VALUES(v_seqNo     , P_PROJECTNAME    ,  to_date(P_STARTDATE,'YYYYMMDD')     ,  P_PROJECTDESC,																			
		    P_CURROPER       , V_TODAY);																			
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S094780024';
					  P_RETMSG  := '新增项目表失败'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	--记录项目台帐表
	BEGIN
		INSERT INTO TF_B_PROJECTTRADE(																					
    TRADEID         , OPERATETYPECODE  ,  PROJECTNAME     ,  STARTDATE     ,																					
    PROJECTDESC     , JOBDESC          ,  EXPECTEDDATE    ,  JOBSTAFF      ,																					
    COMPLETEDESC    , ACTUALDATE       ,  OPERATETIME     , OPERATESTAFF   , REMARK																					
		)VALUES(v_seqNo     ,      '00'        ,  P_PROJECTNAME   , to_date(P_STARTDATE,'YYYYMMDD')    ,																					
		    P_PROJECTDESC   ,    null          ,        null      ,   null         ,      																					
		       null         ,    null          ,     V_TODAY      ,   P_CURROPER    , null);																					
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S094780024';
					  P_RETMSG  := '记录项目台帐表失败'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
show errors


