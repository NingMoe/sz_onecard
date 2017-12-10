CREATE OR REPLACE PROCEDURE SP_RM_OTHER_ADDSTAFFMAINTAIN
(
  P_RESUOURCETYPECODE    CHAR,     --��Դ���ͱ���
  P_RESOURCECODE          CHAR,    --��Դ���Ʊ���
  P_EXPLANATION          varchar2,--�������˵��
  P_USETIME              FLOAT,   --ά��ʱ��
  P_MAINTAINDEPT         CHAR,    --ά������
  P_CURROPER             CHAR,
  P_CURRDEPT             CHAR,
  p_retCode              out char, -- Return Code
  p_retMsg               out varchar2  -- Return Message
  
)
AS
  v_seqNo        CHAR(16);    --��ˮ��
  v_SIGNINMAINTAINID     CHAR(18);    --ά������
  V_TODAY       DATE:=SYSDATE;
  V_EX          EXCEPTION;
BEGIN
  --��ȡ��ˮ��
  SP_GetSeq(seq => v_seqNo);
  --����ά������
  v_SIGNINMAINTAINID := 'WH'||v_seqNo;
  
  --���빤����
  BEGIN
  INSERT INTO TF_F_STAFFMAINTAIN(                                                      
         SIGNINMAINTAINID      , STATE             ,RELATEDSTATE       ,RESUOURCETYPECODE  ,RESOURCECODE      ,EXPLANATION        ,                                                    
         USETIME               ,UPDATEDEPT         ,UPDATESTAFFNO      ,UPDATETIME         ,MAINTAINDEPT                                                      
  )VALUES(                                                    
         v_SIGNINMAINTAINID    ,'0'               ,'0'               , P_RESUOURCETYPECODE ,P_RESOURCECODE    ,P_EXPLANATION      ,                                                    
         P_USETIME             ,P_CURRDEPT       ,P_CURROPER         ,v_TODAY               ,P_MAINTAINDEPT);                                                    
                   

  IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002220';
            P_RETMSG  := '���빤����ʧ��'||SQLERRM;
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
        v_seqNo           ,  '05'                  , v_SIGNINMAINTAINID , '17'               ,                                                  
        NULL              , NULL                   , P_RESOURCECODE    , NULL                ,                                                  
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