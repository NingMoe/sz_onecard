CREATE OR REPLACE PROCEDURE SP_RM_OTHER_EDITSTAFFCONFIRM
(
  P_CONFIRMID            CHAR,    ---确认单号
  P_ISFINISHED           CHAR,     --完成情况
  P_SATISFATION          CHAR,     --满意度
  P_CONFIRMATION         varchar2,--确认说明
  P_CURROPER             CHAR,
  P_CURRDEPT             CHAR,
  p_retCode              out char, -- Return Code
  p_retMsg               out varchar2  -- Return Message
  
)
AS
  v_seqNo        CHAR(16);    --流水号
  V_TODAY       DATE:=SYSDATE;
  V_EX          EXCEPTION;
BEGIN
  --获取流水号
  SP_GetSeq(seq => v_seqNo);

  
  --更新工单确认表
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
            P_RETMSG  := '更新工单确认表失败'||SQLERRM;
            ROLLBACK; RETURN;
  END;

  --记录台帐表
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
            P_RETMSG  := '记录资源单据管理台帐表失败'||SQLERRM;
            ROLLBACK; RETURN;
  END;
  
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;   
END;




/
show errors