CREATE OR REPLACE PROCEDURE SP_GC_BuyCardApprovalCancel
(

   P_SESSIONID  CHAR,
   P_TYPE     CHAR,
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
   IF P_TYPE = '1' THEN  --��λ��ȫֵ���
    BEGIN
       UPDATE   TF_F_COMBUYCARDAPPROVAL
       SET      ISVALID = '0',--����
                OPERDEPT = P_CURRDEPT,
                OPERATOR= P_CURROPER,
                OPERATETIME = V_TODAY
       WHERE    ID = V_ID ;
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
       EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002802';
            P_RETMSG := '���¹�����λ��ȫֵ��˱�ʧ��' || SQLERRM;
          ROLLBACK;RETURN;
     END;
     
   

END IF;
 

   IF P_TYPE = '2' THEN
   BEGIN
       UPDATE   TF_F_PERBUYCARDAPPROVAL
       SET      ISVALID = '0',--����
                OPERDEPT = P_CURRDEPT,
                OPERATOR= P_CURROPER,
                OPERATETIME = V_TODAY
       WHERE    ID = V_ID ;
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
       EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002803';
            P_RETMSG := '���¹������˰�ȫֵ��˱�ʧ��' || SQLERRM;
          ROLLBACK;RETURN;
     END;
           
         

   END IF;
  
 

  END LOOP;

   P_RETCODE := '0000000000';
   P_RETMSG  := '';
   COMMIT; RETURN;
END;
/
show errors;