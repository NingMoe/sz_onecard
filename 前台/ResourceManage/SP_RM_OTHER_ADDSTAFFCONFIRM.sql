CREATE OR REPLACE PROCEDURE SP_RM_OTHER_ADDSTAFFCONFIRM
(
  P_SIGNINMAINTAINID    CHAR,     --ά������
  P_ISFINISHED          CHAR,     --������
  P_SATISFATION         CHAR,     --�����
  P_CONFIRMATION         varchar2,--ȷ��˵��
  P_CURROPER             CHAR,
  P_CURRDEPT             CHAR,
  p_retCode              out char, -- Return Code
  p_retMsg               out varchar2  -- Return Message
  
)
AS
  v_seqNo       CHAR(16);      --��ˮ��
  v_CONFIRMID   CHAR(18);    --ȷ�ϵ���
  V_COUNT       INT;
  V_TODAY       DATE:=SYSDATE;
  V_EX          EXCEPTION;
BEGIN
  --��ȡ��ˮ��
  SP_GetSeq(seq => v_seqNo);
  --����ȷ�ϵ���
  v_CONFIRMID := 'QR'||v_seqNo;
  
  
  
   --�жϹ���ȷ�ϱ��Ƿ��Ѿ����ڴ�ά������
        SELECT COUNT(*) INTO V_COUNT FROM TF_F_CONFIRMSTAFFMAINTAIN WHERE SIGNINMAINTAINID=P_SIGNINMAINTAINID;                                                      

        IF V_COUNT>0 THEN
         p_retCode := 'S094570300';
                    p_retMsg := 'ά������Ϊ'||P_SIGNINMAINTAINID||'�Ѿ�ȷ��,�����ظ��ύ';
                   ROLLBACK;  RETURN; 
        END IF;
  --���빤��ȷ�ϱ�
  BEGIN
      INSERT INTO TF_F_CONFIRMSTAFFMAINTAIN (                                          
          CONFIRMID     ,SIGNINMAINTAINID      ,ISFINISHED        ,SATISFATION        ,                                        
          CONFIRMATION  ,UPDATEDEPT            ,UPDATESTAFFNO     ,UPDATETIME                                            
      )VALUES(                                          
          v_CONFIRMID    ,P_SIGNINMAINTAINID    ,P_ISFINISHED     ,P_SATISFATION       ,                                        
          P_CONFIRMATION ,P_CURRDEPT            ,P_CURROPER       ,v_TODAY);                                        
                                      
                   

  IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002220';
            P_RETMSG  := '���빤��ȷ�ϱ�ʧ��'||SQLERRM;
            ROLLBACK; RETURN;
  END;
  
  BEGIN
    --���¹�����
    UPDATE TF_F_STAFFMAINTAIN 
    SET    STATE='1',
           UPDATEDEPT=P_CURRDEPT,
           UPDATESTAFFNO=P_CURROPER,
           UPDATETIME= v_TODAY
    WHERE SIGNINMAINTAINID=P_SIGNINMAINTAINID;
    
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002221';
            P_RETMSG  := '���¹�����ʧ��'||SQLERRM;
            ROLLBACK; RETURN;
  END;

  --��¼̨�ʱ�
  BEGIN
  INSERT INTO TF_B_RESOURCEORDERMANAGE(                                                  
        TRADEID           , ORDERTYPECODE           , ORDERID           , OPERATETYPECODE     ,                                                  
        ORDERDEMAND       , MAINTAINREASON          , RESOURCECODE      , ATTRIBUTE1          ,                                                  
        ATTRIBUTE2        , ATTRIBUTE3              , ATTRIBUTE4        , ATTRIBUTE5          ,                                                  
        ATTRIBUTE6        , RESOURCENUM             , REQUIREDATE       , LATELYDATE          ,                                                  
        ALREADYORDERNUM   ,ALREADYARRIVENUM         , APPLYGETNUM       , AGREEGETNUM         ,                                                  
        ALREADYGETNUM     , LATELYGETDATE           , GETSTAFFNO        , OPERATETIME         ,                                                  
        OPERATESTAFFNO                                                  
    )  VALUES  (                                                  
        v_seqNo           ,  '05'                  , v_CONFIRMID       , '19'               ,                                                  
        NULL              , NULL                   , NULL              , NULL                ,                                                  
        NULL              , NULL                   , NULL              , NULL                ,                                                  
        NULL              , NULL                   , NULL              , NULL                ,                                                  
        NULL              , NULL                   , NULL              , NULL                ,                                                  
        NULL              , NULL                   , NULL              , V_TODAY             ,                                                  
        P_CURROPER )   ;                                                  
                        

  IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002222';
            P_RETMSG  := '��¼��Դ���ݹ���̨�ʱ�ʧ��'||SQLERRM;
            ROLLBACK; RETURN;
  END;
  
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;   
END;





/
show errors