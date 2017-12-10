CREATE OR REPLACE PROCEDURE SP_RM_OTHER_ADDSTAFFCONFIRM
(
  P_SIGNINMAINTAINID    CHAR,     --维护单号
  P_ISFINISHED          CHAR,     --完成情况
  P_SATISFATION         CHAR,     --满意度
  P_CONFIRMATION         varchar2,--确认说明
  P_CURROPER             CHAR,
  P_CURRDEPT             CHAR,
  p_retCode              out char, -- Return Code
  p_retMsg               out varchar2  -- Return Message
  
)
AS
  v_seqNo       CHAR(16);      --流水号
  v_CONFIRMID   CHAR(18);    --确认单号
  V_COUNT       INT;
  V_TODAY       DATE:=SYSDATE;
  V_EX          EXCEPTION;
BEGIN
  --获取流水号
  SP_GetSeq(seq => v_seqNo);
  --生成确认单号
  v_CONFIRMID := 'QR'||v_seqNo;
  
  
  
   --判断工单确认表是否已经存在此维护单号
        SELECT COUNT(*) INTO V_COUNT FROM TF_F_CONFIRMSTAFFMAINTAIN WHERE SIGNINMAINTAINID=P_SIGNINMAINTAINID;                                                      

        IF V_COUNT>0 THEN
         p_retCode := 'S094570300';
                    p_retMsg := '维护单号为'||P_SIGNINMAINTAINID||'已经确认,不可重复提交';
                   ROLLBACK;  RETURN; 
        END IF;
  --插入工单确认表
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
            P_RETMSG  := '插入工单确认表失败'||SQLERRM;
            ROLLBACK; RETURN;
  END;
  
  BEGIN
    --更新工单表
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
            P_RETMSG  := '记录资源单据管理台帐表失败'||SQLERRM;
            ROLLBACK; RETURN;
  END;
  
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;   
END;





/
show errors