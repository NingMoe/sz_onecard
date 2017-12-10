CREATE OR REPLACE PROCEDURE SP_PS_CORPAPPROVALCANCEL
(

   P_SESSIONID  CHAR,
   P_CURROPER CHAR, --��ǰ������
   P_CURRDEPT CHAR  ,
   P_RETCODE  OUT CHAR, --�������
   P_RETMSG   OUT VARCHAR2 --������Ϣ

)
AS
    V_ID           CHAR(16); 
    V_COUNT           int;
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
BEGIN




  FOR V_CUR IN (
      SELECT a.f0 FROM TMP_SECURITYVALUEAPPROVAL a WHERE a.f1 = P_SESSIONID
    )
  LOOP
    V_ID := V_CUR.f0;

    BEGIN
       UPDATE   TF_F_CORPSECURITYAPPROVAL
       SET      ISVALID = '0',--����
                OPERDEPT = P_CURRDEPT,
                OPERATOR= P_CURROPER,
                OPERATETIME = V_TODAY
       WHERE    ID = V_ID ;
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
       EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002802';
            P_RETMSG := '�����̻���ȫֵ��˱�ʧ��' || SQLERRM;
          ROLLBACK;RETURN;
     END;
     
    

  
  
 

  END LOOP;

   P_RETCODE := '0000000000';
   P_RETMSG  := '';
   COMMIT; RETURN;
END;
/
show errors;