CREATE OR REPLACE PROCEDURE SP_RM_OTHER_GETRESAPPLYAPPROVE
(

   P_SESSIONID  CHAR,
   P_CURROPER CHAR, --��ǰ������
   P_CURRDEPT CHAR  ,
   P_RETCODE  OUT CHAR, --�������
   P_RETMSG   OUT VARCHAR2 --������Ϣ

)
AS
    v_seqNo        CHAR(16);    --��ˮ��
    V_GETORDERID  CHAR(18);    --���õ���
    V_AGREEGETNUM INT:=0;       --ͬ����������
    V_RESOURCECODE CHAR(6) ;     --��Դ����
    V_APPLYGETNUM INT;      --������������
    V_ATTRIBUTE1 VARCHAR2(50);
    V_ATTRIBUTE2 VARCHAR2(50);
    V_ATTRIBUTE3 VARCHAR2(50);
    V_ATTRIBUTE4 VARCHAR2(50);
    V_ATTRIBUTE5 VARCHAR2(50);
    V_ATTRIBUTE6 VARCHAR2(50);
    
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
BEGIN

  
  
  
  FOR V_CUR IN (
      SELECT a.f0, a.f1, a.f2
      FROM TMP_COMMON a WHERE a.f2 = P_SESSIONID 
    )
  LOOP
    V_GETORDERID := V_CUR.f0;            
    V_AGREEGETNUM := TO_NUMBER(V_CUR.f1);
 
    --��ȡ��ˮ��
    SP_GetSeq(seq => v_seqNo);
    BEGIN
      SELECT                                                    
         RESOURCECODE   , APPLYGETNUM  , ATTRIBUTE1 , ATTRIBUTE2 , ATTRIBUTE3 , ATTRIBUTE4 , ATTRIBUTE5 , ATTRIBUTE6                                                     
      INTO                                                    
          V_RESOURCECODE , V_APPLYGETNUM ,V_ATTRIBUTE1,V_ATTRIBUTE2,V_ATTRIBUTE3,V_ATTRIBUTE4,V_ATTRIBUTE5,V_ATTRIBUTE6                                                     
      FROM TF_F_GETRESOURCEORDER                                                    
      WHERE GETORDERID = V_GETORDERID;  
      EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'A001002801';
            P_RETMSG := '������ֵʧ��' || SQLERRM;
          ROLLBACK;RETURN;                                                  
    END;
    
    
  IF  V_AGREEGETNUM!=0 THEN
  
    BEGIN
       UPDATE   TF_F_GETRESOURCEORDER                    
       SET      ORDERSTATE = '1',    --���ͨ��              
                AGREEGETNUM = V_AGREEGETNUM,                    
                EXAMTIME = V_TODAY ,                    
                EXAMSTAFFNO = P_CURROPER                    
       WHERE    GETORDERID = V_GETORDERID; 
       IF SQL%ROWCOUNT != 1 THEN
         RAISE V_EX;
       END IF;
       EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002802';
            P_RETMSG := '������Դ���õ���ʧ��' || SQLERRM;
          ROLLBACK;RETURN;
     END;                      


  --��¼��Դ���ݹ���̨�ʱ�
    BEGIN
        INSERT INTO TF_B_RESOURCEORDERMANAGE(
        TRADEID           , ORDERTYPECODE           , ORDERID           , OPERATETYPECODE     ,
        ORDERDEMAND       , MAINTAINREASON          , RESOURCECODE      , ATTRIBUTE1          ,
        ATTRIBUTE2        , ATTRIBUTE3              , ATTRIBUTE4        , ATTRIBUTE5          ,
        ATTRIBUTE6        , RESOURCENUM             , REQUIREDATE       , LATELYDATE          ,
        ALREADYORDERNUM   ,ALREADYARRIVENUM         , APPLYGETNUM       , AGREEGETNUM         ,
        ALREADYGETNUM     , LATELYGETDATE           , GETSTAFFNO        , OPERATETIME         ,
        OPERATESTAFFNO
      )VALUES(
        v_seqNo           ,  '03'                    , V_GETORDERID      , '05'                ,
        NULL              , NULL                    , V_RESOURCECODE    , V_ATTRIBUTE1        ,
        V_ATTRIBUTE2      , V_ATTRIBUTE3            , V_ATTRIBUTE4      , V_ATTRIBUTE5        ,
        V_ATTRIBUTE6      , NULL                    , NULL              , NULL                ,
        0                 , 0                       , V_APPLYGETNUM     , V_AGREEGETNUM       ,
         0                , NULL                    , NULL              , V_TODAY             ,
        P_CURROPER
      );
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002803';
            P_RETMSG  := '��¼��Դ���ݹ���̨�ʱ�ʧ��'||SQLERRM;
            ROLLBACK; RETURN;
    END;
    
   ELSE
   
     BEGIN
       UPDATE   TF_F_GETRESOURCEORDER                    
       SET      ORDERSTATE = '2',    --�������                                 
                EXAMTIME = V_TODAY ,                    
                EXAMSTAFFNO = P_CURROPER                    
       WHERE    GETORDERID = V_GETORDERID; 
       IF SQL%ROWCOUNT != 1 THEN
         RAISE V_EX;
       END IF;
       EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002804';
            P_RETMSG := '������Դ���õ���ʧ��' || SQLERRM;
          ROLLBACK;RETURN;
     END;
     
     --��¼��Դ���ݹ���̨�ʱ�
    BEGIN
        INSERT INTO TF_B_RESOURCEORDERMANAGE(
        TRADEID           , ORDERTYPECODE           , ORDERID           , OPERATETYPECODE     ,
        ORDERDEMAND       , MAINTAINREASON          , RESOURCECODE      , ATTRIBUTE1          ,
        ATTRIBUTE2        , ATTRIBUTE3              , ATTRIBUTE4        , ATTRIBUTE5          ,
        ATTRIBUTE6        , RESOURCENUM             , REQUIREDATE       , LATELYDATE          ,
        ALREADYORDERNUM   ,ALREADYARRIVENUM         , APPLYGETNUM       , AGREEGETNUM         ,
        ALREADYGETNUM     , LATELYGETDATE           , GETSTAFFNO        , OPERATETIME         ,
        OPERATESTAFFNO
      )VALUES(
        v_seqNo           ,  '03'                    , V_GETORDERID      , '06'                ,
        NULL              , NULL                    , V_RESOURCECODE    , V_ATTRIBUTE1        ,
        V_ATTRIBUTE2      , V_ATTRIBUTE3            , V_ATTRIBUTE4      , V_ATTRIBUTE5        ,
        V_ATTRIBUTE6      , NULL                    , NULL              , NULL                ,
        0                 , 0                       , V_APPLYGETNUM     , V_AGREEGETNUM       ,
         0                , NULL                    , NULL              , V_TODAY             ,
        P_CURROPER
      );
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002805';
            P_RETMSG  := '��¼��Դ���ݹ���̨�ʱ�ʧ��'||SQLERRM;
            ROLLBACK; RETURN;
    END;
   
   END IF;
   
  END LOOP;

   P_RETCODE := '0000000000';
   P_RETMSG  := '';
   COMMIT; RETURN;
END;
/
SHOW ERROR;
