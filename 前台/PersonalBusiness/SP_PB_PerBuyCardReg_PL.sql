CREATE OR REPLACE PROCEDURE SP_PB_PerBuyCardReg
(
    P_FUNCCODE              VARCHAR2 ,
    P_ID                    CHAR     ,
    P_NAME                  VARCHAR2 ,
    P_BIRTHDAY              VARCHAR2 ,
    P_PAPERTYPE             CHAR     ,
    P_PAPERNO               VARCHAR2 ,
    P_SEX                   CHAR     ,
    P_PHONENO               VARCHAR2 ,
    P_ADDRESS               VARCHAR2 ,
    P_EMAIL                 VARCHAR2 ,
    P_STARTCARDNO           CHAR     ,
    P_ENDCARDNO             CHAR     ,
    P_BUYCARDDATE           CHAR     ,
    P_BUYCARDNUM            INT      ,
    P_BUYCARDMONEY          INT      ,
    P_CHARGEMONEY           INT      ,
    P_REMARK                VARCHAR2 ,
    P_CURROPER              CHAR     ,
    P_CURRDEPT              CHAR     ,
    P_RETCODE           OUT CHAR     ,
    P_RETMSG            OUT VARCHAR2
)
AS
    V_FUNCCODE        VARCHAR2(16) := P_FUNCCODE ;
    V_TODAY           DATE         := SYSDATE    ;
    V_QUANTITY        INT                        ;
    V_SEQ             VARCHAR2(16)               ;
    V_EX              EXCEPTION                  ;
    
BEGIN
	   -- 添加登记
	   IF V_FUNCCODE = 'ADD' THEN
	   	 --判断个人信息是否存在
       SELECT  COUNT(*) INTO V_QUANTITY
       FROM   TD_M_BUYCARDPERINFO 
       WHERE  PAPERTYPE = P_PAPERTYPE 
       AND    PAPERNO = P_PAPERNO;
       
       --信息不存在时插入新个人信息
       IF V_QUANTITY = 0 THEN 
       BEGIN
      	 INSERT INTO TD_M_BUYCARDPERINFO(
      	 PAPERTYPE     , PAPERNO      , NAME       , BIRTHDAY     ,
     	   SEX           , PHONENO      , ADDRESS    , EMAIL        ,
     	   OPERATOR      ,OPERDEPT      ,OPERATETIME
    	   )VALUES(
    	   P_PAPERTYPE   , P_PAPERNO    , P_NAME     , P_BIRTHDAY   ,
    	   P_SEX         , P_PHONENO    , P_ADDRESS  , P_EMAIL      ,
    	   P_CURROPER    ,P_CURRDEPT    , V_TODAY
    	   );
       EXCEPTION WHEN OTHERS THEN
         P_RETCODE := 'S004101001' ;
         P_RETMSG  := '插入购卡个人信息表失败'||SQLERRM ;
         ROLLBACK;RETURN;
       END;
       END IF;
       IF V_QUANTITY != 0 THEN
       --更新个人信息
       BEGIN
     	  UPDATE  TD_M_BUYCARDPERINFO tmb
        SET     tmb.NAME      = P_NAME       ,
                tmb.BIRTHDAY  = P_BIRTHDAY   ,
                tmb.SEX       = P_SEX        ,
                tmb.PHONENO   = P_PHONENO    ,
                tmb.ADDRESS   = P_ADDRESS    ,
                tmb.EMAIL     = P_EMAIL      ,
                tmb.OPERATOR  = P_CURROPER   ,
                tmb.OPERDEPT  = P_CURRDEPT   ,
                tmb.OPERATETIME=V_TODAY
        WHERE   tmb.PAPERTYPE = P_PAPERTYPE
        AND     tmb.PAPERNO   = P_PAPERNO;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE :=  'S004101002' ;
        P_RETMSG  := '更新购卡个人信息表失败' || SQLERRM;
        ROLLBACK; RETURN;
       END;
       END IF;
       
       --将购卡记录插入个人购卡记录表
       BEGIN
       SP_GETSEQ(SEQ => V_SEQ);
       INSERT INTO TF_F_PERBUYCARDREG(
            ID              , PAPERTYPE       , PAPERNO         , STARTCARDNO       , 
            ENDCARDNO       , BUYCARDDATE     , BUYCARDNUM      , BUYCARDMONEY      , 
            CHARGEMONEY     , REMARK
       )VALUES(
            V_SEQ           , P_PAPERTYPE    , P_PAPERNO        , P_STARTCARDNO     , 
            P_ENDCARDNO     , P_BUYCARDDATE  , P_BUYCARDNUM     , P_BUYCARDMONEY    ,
            P_CHARGEMONEY   , P_REMARK);
       EXCEPTION WHEN OTHERS THEN
         P_RETCODE := 'S004101003' ;
         P_RETMSG  := '插入个人购卡记录表失败'||SQLERRM ;
         ROLLBACK;RETURN;
       END;
       
       --记录个人购卡操作台账
       BEGIN
    	   INSERT INTO TF_B_PERBUYCARD(
   	         TRADEID         , ID             , OPERATETYPECODE   , NAME               , 
   	         BIRTHDAY        , PAPERTYPE      , PAPERNO           , SEX                , 
   	         PHONENO         , ADDRESS        , EMAIL             , STARTCARDNO        , 
  	         ENDCARDNO       , BUYCARDDATE    , BUYCARDNUM        , BUYCARDMONEY       , 
  	         CHARGEMONEY     , STAFFNO        , CORPNO            , OPERATETIME        , 
  	         REMARK
  	     )SELECT
   	         V_SEQ              , V_SEQ           , '01'              , a.NAME          , 
  	         a.BIRTHDAY         , a.PAPERTYPE     , a.PAPERNO         , a.SEX           ,
 	           a.PHONENO          , a.ADDRESS       , a.EMAIL           , P_STARTCARDNO   , 
 	           P_ENDCARDNO        , P_BUYCARDDATE   , P_BUYCARDNUM      , P_BUYCARDMONEY  , 
 	           P_CHARGEMONEY      , P_CURROPER      , P_CURRDEPT        , V_TODAY         , 
 	           P_REMARK
 	       FROM TD_M_BUYCARDPERINFO a
         WHERE  a.PAPERTYPE = P_PAPERTYPE 
         AND    a.PAPERNO = P_PAPERNO;
         IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
       EXCEPTION
         WHEN OTHERS THEN
         P_RETCODE :=  'S004101007';
         P_RETMSG  := '记录个人购卡台账表失败' || SQLERRM;
         ROLLBACK; RETURN;
	     END;
     END IF;
     
     --修改
     IF V_FUNCCODE = 'MODIFY' THEN
     BEGIN
       	--更新个人信息
     	  UPDATE  TD_M_BUYCARDPERINFO tmb
        SET     tmb.NAME      = P_NAME       ,
                tmb.BIRTHDAY  = P_BIRTHDAY   ,
                tmb.SEX       = P_SEX        ,
                tmb.PHONENO   = P_PHONENO    ,
                tmb.ADDRESS   = P_ADDRESS    ,
                tmb.EMAIL     = P_EMAIL      ,
                tmb.OPERATOR  = P_CURROPER   ,
                tmb.OPERDEPT  = P_CURRDEPT   ,
                tmb.OPERATETIME=V_TODAY
        WHERE   tmb.PAPERTYPE = P_PAPERTYPE
        AND     tmb.PAPERNO   = P_PAPERNO;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE :=  'S004101004';
        P_RETMSG  := '更新购卡个人信息表失败' || SQLERRM;
        ROLLBACK; RETURN;
     END;
     --更新个人购卡记录
     BEGIN
        UPDATE  TF_F_PERBUYCARDREG
        SET     STARTCARDNO  = P_STARTCARDNO  ,
                ENDCARDNO    = P_ENDCARDNO    ,
                BUYCARDDATE  = P_BUYCARDDATE  ,
                BUYCARDNUM   = P_BUYCARDNUM   ,
                BUYCARDMONEY = P_BUYCARDMONEY ,
                CHARGEMONEY  = P_CHARGEMONEY  ,
                REMARK       = P_REMARK
        WHERE   ID = P_ID ;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE :=  'S004101005';
        P_RETMSG  := '更新个人购卡记录表失败' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    --记录个人购卡操作台账
    BEGIN
       SP_GETSEQ(SEQ => V_SEQ);
       INSERT INTO TF_B_PERBUYCARD(
            TRADEID         , ID             , OPERATETYPECODE   , NAME               , 
            BIRTHDAY        , PAPERTYPE      , PAPERNO           , SEX                , 
            PHONENO         , ADDRESS        , EMAIL             , STARTCARDNO        , 
            ENDCARDNO       , BUYCARDDATE    , BUYCARDNUM        , BUYCARDMONEY       , 
            CHARGEMONEY     , STAFFNO        , CORPNO            , OPERATETIME        , 
            REMARK
  	     )SELECT
   	         V_SEQ              , b.ID            , '02'              , a.NAME          , 
  	         a.BIRTHDAY         , a.PAPERTYPE     , a.PAPERNO         , a.SEX           ,
 	           a.PHONENO          , a.ADDRESS       , a.EMAIL           , P_STARTCARDNO   , 
 	           P_ENDCARDNO        , P_BUYCARDDATE   , P_BUYCARDNUM      , P_BUYCARDMONEY  , 
 	           P_CHARGEMONEY      , P_CURROPER      , P_CURRDEPT        , V_TODAY         , 
 	           P_REMARK
 	       FROM TD_M_BUYCARDPERINFO a,TF_F_PERBUYCARDREG b
         WHERE  a.PAPERTYPE = b.PAPERTYPE 
         AND    a.PAPERNO = b.PAPERNO
         AND    b.ID = P_ID;
       IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
   EXCEPTION WHEN OTHERS THEN
       P_RETCODE := 'S004101007' ;
       P_RETMSG  := '记录个人购卡台账表失败'||SQLERRM ;
       ROLLBACK;RETURN;
   END;
   END IF;
     
     --删除
     IF  V_FUNCCODE = 'DELETE' THEN
	   --记录个人购卡操作台账
     BEGIN
	     SP_GETSEQ(SEQ => V_SEQ);
       INSERT INTO TF_B_PERBUYCARD(
            TRADEID         , ID             , OPERATETYPECODE   , NAME               , 
            BIRTHDAY        , PAPERTYPE      , PAPERNO           , SEX                , 
            PHONENO         , ADDRESS        , EMAIL             , STARTCARDNO        , 
            ENDCARDNO       , BUYCARDDATE    , BUYCARDNUM        , BUYCARDMONEY       , 
            CHARGEMONEY     , STAFFNO        , CORPNO            , OPERATETIME        , 
            REMARK
  	     )SELECT
   	         V_SEQ              , b.ID            , '03'              , a.NAME          , 
  	         a.BIRTHDAY         , a.PAPERTYPE     , a.PAPERNO         , a.SEX           ,
 	           a.PHONENO          , a.ADDRESS       , a.EMAIL           , P_STARTCARDNO   , 
 	           P_ENDCARDNO        , P_BUYCARDDATE   , P_BUYCARDNUM      , P_BUYCARDMONEY  , 
 	           P_CHARGEMONEY      , P_CURROPER      , P_CURRDEPT        , V_TODAY         , 
 	           P_REMARK
 	       FROM TD_M_BUYCARDPERINFO a,TF_F_PERBUYCARDREG b
         WHERE  a.PAPERTYPE = b.PAPERTYPE 
         AND    a.PAPERNO = b.PAPERNO
         AND    b.ID = P_ID;
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION WHEN OTHERS THEN
         P_RETCODE :=  'S004101007';
         P_RETMSG  := '记录个人购卡台账表失败' || SQLERRM;
         ROLLBACK; RETURN;
     END;
     --删除个人购卡记录
     BEGIN
	     DELETE  FROM  TF_F_PERBUYCARDREG WHERE ID = P_ID ;
     EXCEPTION WHEN OTHERS THEN
          P_RETCODE := 'S004102006' ;
          P_RETMSG  := '删除个人购卡记录表失败'||SQLERRM ;
          ROLLBACK;RETURN;
	   END;
     END IF;
     
     p_retCode := '0000000000'; p_retMsg  := '成功';
     return;
END;

/
show errors