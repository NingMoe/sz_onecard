CREATE OR REPLACE PROCEDURE SP_RM_OTHER_EDITSTAFFMAINTAIN
(
  P_SIGNINMAINTAINID     CHAR,    ---工单号
  P_RESUOURCETYPECODE    CHAR,     --资源类型编码
  P_RESOURCECODE          CHAR,    --资源名称编码
  P_EXPLANATION          varchar2,--故障情况说明
  P_USETIME              FLOAT,   --维护时长
  P_MAINTAINDEPT         CHAR,    --维护网点
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

  
  --更新工单表
  BEGIN
  UPDATE TF_F_STAFFMAINTAIN T                         
  SET    T.RESUOURCETYPECODE=P_RESUOURCETYPECODE,                        
         T.RESOURCECODE=P_RESOURCECODE,                        
         T.EXPLANATION=P_EXPLANATION,                        
         T.USETIME=P_USETIME,                        
         T.UPDATEDEPT=P_CURRDEPT,                        
         T.UPDATESTAFFNO=P_CURROPER,                        
         T.UPDATETIME=v_TODAY ,
         T.MAINTAINDEPT =P_MAINTAINDEPT                      
  WHERE  T.SIGNINMAINTAINID=P_SIGNINMAINTAINID;                        
                                                                   

  IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002220';
            P_RETMSG  := '更新工单表失败'||SQLERRM;
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
        v_seqNo           ,  '05'                  , P_SIGNINMAINTAINID , '18'               ,                                                  
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
            P_RETMSG  := '记录资源单据管理台帐表失败'||SQLERRM;
            ROLLBACK; RETURN;
  END;
  
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;   
END;





/
show errors