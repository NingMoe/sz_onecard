CREATE OR REPLACE PROCEDURE SP_RM_OTHER_STAFFSIGNIN
(
  P_CARDNO        CHAR, 		--卡号
	P_STAFFNAME 		varchar2,	--签到员工姓名
	P_CURROPER        CHAR,
  P_CURRDEPT        CHAR,
  p_retCode     out char, -- Return Code
  p_retMsg      out varchar2  -- Return Message
  
)
AS
  v_seqNo        CHAR(16);    --流水号
  v_tradeid     CHAR(18);    --需求单号
  V_TODAY       DATE:=SYSDATE;
  V_EX          EXCEPTION;
BEGIN
  --获取流水号
  SP_GetSeq(seq => v_seqNo);
  --生成签到单号
  v_tradeid := 'QD'||v_seqNo;
  
  --记录签到记录表
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
            P_RETMSG  := '记录签到记录表失败'||SQLERRM;
            ROLLBACK; RETURN;
  END;

  --记录台帐表
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
            P_RETMSG  := '记录资源单据管理台帐表失败'||SQLERRM;
            ROLLBACK; RETURN;
  END;
  
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;   
END;


/
show errors