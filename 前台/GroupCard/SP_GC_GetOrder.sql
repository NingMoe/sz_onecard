CREATE OR REPLACE PROCEDURE SP_GC_GetOrder
(

   P_SESSIONID  CHAR,
   P_CURROPER CHAR, --��ǰ������
   P_CURRDEPT CHAR  ,
   P_RETCODE  OUT CHAR, --�������
   P_RETMSG   OUT VARCHAR2 --������Ϣ

)
AS
    v_seqNo        CHAR(16);    --��ˮ��
    V_ORDERNO  CHAR(16);        --�������
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
BEGIN




  FOR V_CUR IN (
      SELECT a.f0
      FROM TMP_ORDER a WHERE a.f1 = P_SESSIONID
    )
  LOOP
    V_ORDERNO := V_CUR.f0;


    --��ȡ��ˮ��
    SP_GetSeq(seq => v_seqNo);


    BEGIN
       UPDATE   TF_F_ORDERFORM
       SET      ORDERSTATE = '07' ,  
                UPDATEDEPARTNO = P_CURRDEPT,
                UPDATESTAFFNO= P_CURROPER,
                UPDATETIME = V_TODAY
       WHERE    ORDERNO = V_ORDERNO;
       IF SQL%ROWCOUNT != 1 THEN
         RAISE V_EX;
       END IF;
       EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002802';
            P_RETMSG := '���¶�����ʧ��' || SQLERRM;
          ROLLBACK;RETURN;
     END;


  --��¼����̨�ʱ�
    BEGIN
        INSERT INTO TF_F_ORDERTRADE(
        TRADEID           , ORDERNO                 , ORDERSTATE        , TRADECODE           ,
        OPERATEDEPARTNO   , OPERATESTAFFNO          ,OPERATETIME    
       
      )VALUES(
        v_seqNo           ,V_ORDERNO                  ,'05'             , '09'                ,
        P_CURRDEPT     , P_CURROPER      ,V_TODAY 
      );
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002803';
            P_RETMSG  := '��¼����̨�ʱ�ʧ��'||SQLERRM;
            ROLLBACK; RETURN;
    END;

  

  END LOOP;

   P_RETCODE := '0000000000';
   P_RETMSG  := '';
   COMMIT; RETURN;
END;

/
show errors;