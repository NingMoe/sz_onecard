CREATE OR REPLACE PROCEDURE SP_GC_BuyCardApprovalSubmit
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
    V_SECURITYVALUE   INT;
    V_COMPANYNO       CHAR(6);
    V_COMPANYPAPERTYPE CHAR(2);
    V_COMPANYPAPERNO   VARCHAR2(30);
    V_PAPERTYPE       CHAR(2);
    V_PAPERNO         VARCHAR2(20);
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
       SET      APPROVESTATE = '1',--���ͨ��
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
     
    
       
    SELECT SECURITYVALUE,COMPANYNO,COMPANYPAPERTYPE,COMPANYPAPERNO INTO V_SECURITYVALUE,V_COMPANYNO,V_COMPANYPAPERTYPE,V_COMPANYPAPERNO FROM TF_F_COMBUYCARDAPPROVAL WHERE ID = V_ID;
    SELECT COUNT(*) INTO V_COUNT FROM TD_M_BUYCARDCOMINFO WHERE COMPANYNO = V_COMPANYNO AND COMPANYPAPERTYPE = V_COMPANYPAPERTYPE AND COMPANYPAPERNO = V_COMPANYPAPERNO;
    IF V_COUNT<1 THEN
     P_RETCODE := 'A001002103';
      P_RETMSG  := 'û���д˹�����λ��Ϣ';
      ROLLBACK; RETURN;
     END IF;
      IF V_COUNT =1 THEN
      --���°�ȫֵ
        BEGIN 
          UPDATE   TD_M_BUYCARDCOMINFO tmb
          SET       tmb.SECURITYVALUE=V_SECURITYVALUE,
                    tmb.operator  = p_curroper   ,
                    tmb.operdept  = p_currdept   ,
                    tmb.operatetime = v_today    
            WHERE   tmb.COMPANYPAPERTYPE = V_COMPANYPAPERTYPE
            AND     tmb.COMPANYPAPERNO   = V_COMPANYPAPERNO;
            IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE :=  'S004101002' ;
        P_RETMSG  := '���¹�����λ��Ϣ��ʧ��' || SQLERRM;
        ROLLBACK; RETURN;
      
        END;
      END IF;

END IF;
 

   IF P_TYPE = '2' THEN
   BEGIN
       UPDATE   TF_F_PERBUYCARDAPPROVAL
       SET      APPROVESTATE = '1',--���ͨ��
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
     
     
     SELECT SECURITYVALUE,PAPERTYPE,PAPERNO INTO V_SECURITYVALUE,V_PAPERTYPE,V_PAPERNO FROM TF_F_PERBUYCARDAPPROVAL WHERE ID = V_ID;
      SELECT COUNT(*) INTO V_COUNT FROM TD_M_BUYCARDPERINFO WHERE PAPERTYPE = V_PAPERTYPE AND PAPERNO = V_PAPERNO ;
        IF V_COUNT<1 THEN
         P_RETCODE := 'A001002103';
          P_RETMSG  := 'û���д˹���������Ϣ';
          ROLLBACK; RETURN;
         END IF;
         
         
      IF V_COUNT =1 THEN
      --���°�ȫֵ
        BEGIN 
          UPDATE   TD_M_BUYCARDPERINFO tmb
          SET       tmb.SECURITYVALUE=V_SECURITYVALUE,
                    tmb.operator  = p_curroper   ,
                    tmb.operdept  = p_currdept   ,
                    tmb.operatetime = v_today    
            WHERE   tmb.PAPERTYPE = V_PAPERTYPE
            AND     tmb.PAPERNO   = V_PAPERNO;
            IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE :=  'S004101003' ;
        P_RETMSG  := '���¹���������Ϣ��ʧ��' || SQLERRM;
        ROLLBACK; RETURN;
      
        END;
      END IF;
   END IF;
  
 

  END LOOP;

   P_RETCODE := '0000000000';
   P_RETMSG  := '';
   COMMIT; RETURN;
END;
/
show errors;