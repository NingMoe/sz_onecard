CREATE OR REPLACE PROCEDURE SP_RM_OTHER_STAFFSIGNIN
(
  P_CARDNO        CHAR, 		--����
	P_STAFFNAME 		varchar2,	--ǩ��Ա������
	P_CURROPER        CHAR,
  P_CURRDEPT        CHAR,
  p_retCode     out char, -- Return Code
  p_retMsg      out varchar2  -- Return Message
  
)
AS
  v_seqNo        CHAR(16);    --��ˮ��
  v_tradeid     CHAR(18);    --���󵥺�
  V_TODAY       DATE:=SYSDATE;
  V_EX          EXCEPTION;
BEGIN
  --��ȡ��ˮ��
  SP_GetSeq(seq => v_seqNo);
  --����ǩ������
  v_tradeid := 'QD'||v_seqNo;
  
  --��¼ǩ����¼��
  BEGIN
  INSERT INTO TF_F_STAFFSIGNINSHEET(                                  
     SIGNINSHEETID    ,CARDNO        ,STAFFNAME           ,SIGNINTIME,                                    
     STATE            ,OPERATEDEPT   ,OPERATESTAFFNO                                        
  )VALUES(                                    
   v_tradeid          ,P_CARDNO      ,P_STAFFNAME         ,v_today    ,                                    
  '0'                 ,P_CURRDEPT    ,P_CURROPER            );                                  

  IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002220';
            P_RETMSG  := '��¼ǩ����¼��ʧ��'||SQLERRM;
            ROLLBACK; RETURN;
  END;

  --��¼̨�ʱ�
  BEGIN
  INSERT INTO TF_B_RESOURCEORDERMANAGE(                                                      
        TRADEID           , ORDERTYPECODE           , ORDERID           , OPERATETYPECODE     ,                                                      
        ORDERDEMAND       , MAINTAINREASON          , RESOURCECODE      , ATTRIBUTE1          ,                                                      
        ATTRIBUTE2        , ATTRIBUTE3              , ATTRIBUTE4        , ATTRIBUTE5          ,                                                      
        ATTRIBUTE6        , RESOURCENUM             , REQUIREDATE       , LATELYDATE          ,                                                      
        ALREADYORDERNUM   , ALREADYARRIVENUM        , APPLYGETNUM       , AGREEGETNUM         ,                                                      
        ALREADYGETNUM     , LATELYGETDATE           , GETSTAFFNO        , OPERATETIME         ,                                                      
        OPERATESTAFFNO                                                      
    )  VALUES  (                                                      
        v_seqNo           ,  '05'                  , v_tradeid         , '16'                ,                                                      
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