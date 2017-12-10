CREATE OR REPLACE PROCEDURE SP_SSO_UPDATETOKEN
(
  P_STAFF CHAR,
  P_TOKEN CHAR,
  P_TABLE CHAR,
  P_CURROPER CHAR, --��ǰ������
  P_CURRDEPT CHAR, --��ǰ�����߲���
  P_RETCODE  OUT CHAR, --�������
  P_RETMSG   OUT VARCHAR2 --������Ϣ
) AS
  V_EX EXCEPTION;
BEGIN
  	--��������
	  BEGIN
	  	 execute immediate 'UPDATE '|| P_TABLE ||' SET TOKEN = '''|| P_TOKEN ||'''  WHERE STAFFNO = '''|| P_STAFF ||''' ';
 
			 IF SQL%ROWCOUNT != 1 THEN
				      RAISE V_EX;
			 END IF;
			 EXCEPTION
             WHEN OTHERS THEN
				      P_RETCODE := 'S00L001001';
				      P_RETMSG := '��������ʧ��' || SQLERRM;
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
