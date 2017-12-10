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
	   -- ��ӵǼ�
	   IF V_FUNCCODE = 'ADD' THEN
	   	 --�жϸ�����Ϣ�Ƿ����
       SELECT  COUNT(*) INTO V_QUANTITY
       FROM   TD_M_BUYCARDPERINFO 
       WHERE  PAPERTYPE = P_PAPERTYPE 
       AND    PAPERNO = P_PAPERNO;
       
       --��Ϣ������ʱ�����¸�����Ϣ
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
         P_RETMSG  := '���빺��������Ϣ��ʧ��'||SQLERRM ;
         ROLLBACK;RETURN;
       END;
       END IF;
       IF V_QUANTITY != 0 THEN
       --���¸�����Ϣ
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
        P_RETMSG  := '���¹���������Ϣ��ʧ��' || SQLERRM;
        ROLLBACK; RETURN;
       END;
       END IF;
       
       --��������¼������˹�����¼��
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
         P_RETMSG  := '������˹�����¼��ʧ��'||SQLERRM ;
         ROLLBACK;RETURN;
       END;
       
       --��¼���˹�������̨��
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
         P_RETMSG  := '��¼���˹���̨�˱�ʧ��' || SQLERRM;
         ROLLBACK; RETURN;
	     END;
     END IF;
     
     --�޸�
     IF V_FUNCCODE = 'MODIFY' THEN
     BEGIN
       	--���¸�����Ϣ
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
        P_RETMSG  := '���¹���������Ϣ��ʧ��' || SQLERRM;
        ROLLBACK; RETURN;
     END;
     --���¸��˹�����¼
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
        P_RETMSG  := '���¸��˹�����¼��ʧ��' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    --��¼���˹�������̨��
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
       P_RETMSG  := '��¼���˹���̨�˱�ʧ��'||SQLERRM ;
       ROLLBACK;RETURN;
   END;
   END IF;
     
     --ɾ��
     IF  V_FUNCCODE = 'DELETE' THEN
	   --��¼���˹�������̨��
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
         P_RETMSG  := '��¼���˹���̨�˱�ʧ��' || SQLERRM;
         ROLLBACK; RETURN;
     END;
     --ɾ�����˹�����¼
     BEGIN
	     DELETE  FROM  TF_F_PERBUYCARDREG WHERE ID = P_ID ;
     EXCEPTION WHEN OTHERS THEN
          P_RETCODE := 'S004102006' ;
          P_RETMSG  := 'ɾ�����˹�����¼��ʧ��'||SQLERRM ;
          ROLLBACK;RETURN;
	   END;
     END IF;
     
     p_retCode := '0000000000'; p_retMsg  := '�ɹ�';
     return;
END;

/
show errors