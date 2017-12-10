CREATE OR REPLACE PROCEDURE SP_RM_ResourceMaintainApply
(
	P_RESOURCECODE         VARCHAR2  ,
	P_MAINTAINREASON			 VARCHAR2  ,
	P_REMARK							 VARCHAR2  ,
	P_MAINTAINDEPT         CHAR      ,
	P_MAINTAINREQUEST      VARCHAR2  ,
	P_TIMELIMIT            CHAR      ,
	P_TEL                  VARCHAR2  ,
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode              out char     ,  -- Return Code
  p_retMsg               out varchar2    -- Return Message
)
AS
    v_seqNo             CHAR(16)       ;
    V_TODAY             DATE := SYSDATE;
BEGIN
  --获取流水号
  SP_GetSeq(seq => v_seqNo);
  --记录资源维护单表
  BEGIN
     INSERT INTO  TF_F_RESOURCEMAINTAINORDER(
        MAINTAINORDERID   ,ORDERSTATE           , USETAG                ,RESOURCECODE          , MAINTAINREASON  ,
        ORDERTIME         , ORDERSTAFFNO        ,  REMARK                ,CHECKNOTE            , MAINTAINDEPT    ,
        MAINTAINREQUEST   , TIMELIMIT           , FEEDBACK,             TEL                                                       )
     VALUES(
        'WX'||v_seqNo           , '0'           ,'1'                , P_RESOURCECODE        , P_MAINTAINREASON  ,
        V_TODAY           , P_CURROPER          , P_REMARK              ,NULL               ,  P_MAINTAINDEPT   ,
        P_MAINTAINREQUEST , TO_DATE(P_TIMELIMIT,'YYYYMMDD')        , NULL                   ,P_TEL )  ;

     EXCEPTION
      WHEN OTHERS THEN
          p_retCode := 'SR00120001';
          p_retMsg  := '记录资源维护单表失败'|| SQLERRM;
          ROLLBACK; RETURN;
  END;

  --记录资源单据台帐表
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
        v_seqNo           ,  '04'                  , 'WX'||v_seqNo      , '13'               ,
        NULL              , P_MAINTAINREASON       , P_RESOURCECODE    , NULL                ,
        NULL              , NULL                   , NULL              , NULL                ,
        NULL              , NULL                   , NULL              , TO_CHAR(V_TODAY,'YYYYMMDD') ,
        NULL              , NULL                   , NULL              , NULL                ,
        NULL              , NULL                   , NULL              , V_TODAY             ,
        P_CURROPER )   ;
    EXCEPTION
      WHEN OTHERS THEN
          p_retCode := 'SR00120002';
          p_retMsg  := '记录资源单据管理台账表'|| SQLERRM;
          ROLLBACK; RETURN;
  END;


  p_retCode := '0000000000';
  p_retMsg  := '成功';
  COMMIT; RETURN;
END;
/
SHOW ERROR;