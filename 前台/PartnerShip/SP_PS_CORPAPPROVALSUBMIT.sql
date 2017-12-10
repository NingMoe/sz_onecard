CREATE OR REPLACE PROCEDURE SP_PS_CORPAPPROVALSUBMIT
(

   P_SESSIONID  CHAR,
   P_CURROPER CHAR, --��ǰ������
   P_CURRDEPT CHAR  ,
   P_RETCODE  OUT CHAR, --�������
   P_RETMSG   OUT VARCHAR2 --������Ϣ

)
AS
    V_ID           CHAR(16); 
    V_SECURITYVALUE   INT;
    V_CORP       CHAR(4);
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
       SET      APPROVESTATE = '1',--���ͨ��
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
     
    
       
    SELECT SECURITYVALUE,CORPNO INTO V_SECURITYVALUE,V_CORP FROM TF_F_CORPSECURITYAPPROVAL WHERE ID = V_ID;
    SELECT COUNT(*) INTO V_COUNT FROM TD_M_CORP WHERE CORPNO = V_CORP ;
    IF V_COUNT<1 THEN
     P_RETCODE := 'A001002103';
      P_RETMSG  := 'û���д��̻���Ϣ';
      ROLLBACK; RETURN;
     END IF;
      IF V_COUNT =1 THEN
      --���°�ȫֵ
        BEGIN 
          UPDATE   TD_M_CORP tmb
          SET       tmb.SECURITYVALUE=V_SECURITYVALUE,
                    tmb.Updatestaffno  = p_curroper   ,
                    tmb.Updatetime = v_today    
            WHERE   tmb.CORPNO = V_CORP ;
            IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE :=  'S004101002' ;
        P_RETMSG  := '�����̻���Ϣ��ʧ��' || SQLERRM;
        ROLLBACK; RETURN;
      
        END;
      END IF;


 

  
  
 

  END LOOP;

   P_RETCODE := '0000000000';
   P_RETMSG  := '';
   COMMIT; RETURN;
END;
/
show errors;