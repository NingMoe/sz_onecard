CREATE OR REPLACE PROCEDURE SP_PR_SYNCSTAFFPWD
(
     p_staffno varchar2,
     P_OPERCARDPWD varchar2,
     P_CURROPER  CHAR,
     P_CURRDEPT CHAR,
     p_retCode   OUT CHAR, 
     p_retMsg    OUT VARCHAR2  
)
AS
V_ONECARD INT;
begin
        
       -- 同步卡管系统中同工号账户的密码
       BEGIN
       		SELECT COUNT(1) INTO V_ONECARD FROM TD_M_INSIDESTAFF1
       		WHERE STAFFNO = p_staffno;
       		IF V_ONECARD > 0 THEN
       			  BEGIN
	       			 UPDATE TD_M_INSIDESTAFF1 SET OPERCARDPWD = P_OPERCARDPWD where STAFFNO = p_staffno;
			         EXCEPTION
			            WHEN OTHERS THEN
			              P_RETCODE := 'S010007099';
			              P_RETMSG  := '同步卡管系统密码失败';
			              ROLLBACK; RETURN;
	            END;
       		END IF;
       END;

			 p_retCode := '0000000000';
	     p_retMsg  := '';
	     COMMIT; RETURN;
end;

/
show error;
