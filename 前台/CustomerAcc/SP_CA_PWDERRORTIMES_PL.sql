CREATE OR REPLACE PROCEDURE SP_CA_PWDERRORTIMES
(
  P_ACCT_ID        NUMBER, -- �ʻ�ID
  P_CODEERRORTIMES INTEGER, --��ǰ����������
  P_CURROPER       CHAR, --��ǰ������

  P_CURRDEPT       CHAR, --��ǰ�����߲���
  P_RETCODE        OUT CHAR, --�������
  P_RETMSG         OUT VARCHAR2 --������Ϣ
) AS
 V_TODAY         DATE := SYSDATE;

BEGIN

  -- 1)�������������ۼ�
  BEGIN
    UPDATE TF_F_CUST_ACCT
       SET CODEERRORTIMES = P_CODEERRORTIMES + 1,
           LASTCODEERRORDATE = V_TODAY
     WHERE ACCT_ID = P_ACCT_ID;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006001111';
      P_RETMSG := '���¿ͻ��˻���ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;


  P_RETCODE := '0000000000';
  P_RETMSG := '';
  COMMIT;
  RETURN;
END;

/
show errors;