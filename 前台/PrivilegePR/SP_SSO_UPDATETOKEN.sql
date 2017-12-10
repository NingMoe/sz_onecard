CREATE OR REPLACE PROCEDURE SP_SSO_UPDATETOKEN
(
  P_STAFF CHAR,
  P_TOKEN CHAR,
  P_TABLE CHAR,
  P_CURROPER CHAR, --当前操作者
  P_CURRDEPT CHAR, --当前操作者部门
  P_RETCODE  OUT CHAR, --错误编码
  P_RETMSG   OUT VARCHAR2 --错误信息
) AS
  V_EX EXCEPTION;
BEGIN
  	--更新令牌
	  BEGIN
	  	 execute immediate 'UPDATE '|| P_TABLE ||' SET TOKEN = '''|| P_TOKEN ||'''  WHERE STAFFNO = '''|| P_STAFF ||''' ';
 
			 IF SQL%ROWCOUNT != 1 THEN
				      RAISE V_EX;
			 END IF;
			 EXCEPTION
             WHEN OTHERS THEN
				      P_RETCODE := 'S00L001001';
				      P_RETMSG := '更新令牌失败' || SQLERRM;
				      ROLLBACK;
				      RETURN;
	  END;
		
  P_RETCODE := '0000000000';
  P_RETMSG := '';
  COMMIT;
  RETURN;
END;



/
SHOW ERROR
