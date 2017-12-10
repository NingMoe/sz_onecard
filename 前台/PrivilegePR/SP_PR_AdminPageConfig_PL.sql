/******************************************************/
-- Author  : liuhe
-- Created : 20120831
-- UpdatedAuthor : 
-- Updated : 
-- Content : 
-- Purpose : 添加或删除logonadmin页面登陆配置表
/******************************************************/
CREATE OR REPLACE PROCEDURE SP_PR_AdminPageConfig
(
		P_SESSIONID		 CHAR,		--会话ID
		P_CURROPER       CHAR,		--员工编码
		P_CURRDEPT	     CHAR,		--部门编码
		P_RETCODE	     OUT CHAR, -- RETURN CODE
		P_RETMSG     	 OUT VARCHAR2  -- RETURN MESSAGE
)
AS
		V_TODAY		DATE := SYSDATE;
		V_EX		EXCEPTION;
BEGIN

	BEGIN
		FOR V_C IN (SELECT * FROM TMP_COMMON WHERE F0 = P_SESSIONID)			
			LOOP
				IF V_C.F3 = '0' THEN	--添加到允许logonadmin页面登陆
				BEGIN
					INSERT INTO TD_M_ADMINLOGCONFIG
						(STAFFNO,DEPARTNO,UPDATESTAFFNO,UPDATETIME)
						VALUES(V_C.F1,V_C.F2,P_CURROPER,V_TODAY);
					IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;    
					EXCEPTION
							  WHEN OTHERS THEN
								  P_RETCODE := 'S095270991';
								  P_RETMSG  := '' || SQLERRM;
							  ROLLBACK; RETURN;
				END;
				END IF;
				IF V_C.F3 = '1' THEN	--取消允许logonadmin页面登陆
				BEGIN
					DELETE TD_M_ADMINLOGCONFIG WHERE STAFFNO = V_C.F1;
					IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;    
					EXCEPTION
							  WHEN OTHERS THEN
								  P_RETCODE := 'S095270991';
								  P_RETMSG  := '' || SQLERRM;
							  ROLLBACK; RETURN;
				END;
				END IF;
			END LOOP;
	END;
	P_RETCODE := '0000000000';
	P_RETMSG  := '';
	COMMIT; RETURN;
END;

/
SHOW ERRORS