CREATE OR REPLACE PROCEDURE SP_RM_OTHER_EDITSTAFFCONFIRM
(
  P_CONFIRMID            CHAR,    ---ȷ�ϵ���
  P_ISFINISHED           CHAR,     --������
  P_SATISFATION          CHAR,     --�����
  P_CONFIRMATION         varchar2,--ȷ��˵��
  P_CURROPER             CHAR,
  P_CURRDEPT             CHAR,
  p_retCode              out char, -- Return Code
  p_retMsg               out varchar2  -- Return Message
  
)
AS
  v_seqNo        CHAR(16);    --��ˮ��
  V_TODAY       DATE:=SYSDATE;
  V_EX          EXCEPTION;
BEGIN
  --��ȡ��ˮ��
  SP_GetSeq(seq => v_seqNo);

  
  --���¹���ȷ�ϱ�
  BEGIN
  UPDATE TF_F_CONFIRMSTAFFMAINTAIN T                  
  SET    T.ISFINISHED=P_ISFINISHED,                  
         T.SATISFATION=P_SATISFATION,                  
         T.CONFIRMATION=P_CONFIRMATION,                  
         T.UPDATEDEPT=P_CURRDEPT,                  
         T.UPDATESTAFFNO= P_CURROPER,                  
         T.UPDATETIME=V_TODAY                  
  WHERE  T.CONFIRMID=P_CONFIRMID;                  
                       
                                                                   

  IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002220';
            P_RETMSG  := '���¹���ȷ�ϱ�ʧ��'||SQLERRM;
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
        v_seqNo           ,  '05'                  , P_CONFIRMID        , '20'               ,                                                  
        NULL              , NULL                   , NULL              , NULL                ,                                                  
        NULL              , NULL                   , NULL              , NULL                ,                                                  
        NULL              , NULL                   , NULL              , NULL                ,                                                  
        NULL              , NULL                   , NULL              , NULL                ,                                                  
        NULL              , NULL                   , NULL              , V_TODAY             ,                                                  
        P_CURROPER )   ;                                                  
                        

  IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002221';
            P_RETMSG  := '��¼��Դ���ݹ���̨�ʱ�ʧ��'||SQLERRM;
            ROLLBACK; RETURN;
  END;
  
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;   
END;




/
show errors