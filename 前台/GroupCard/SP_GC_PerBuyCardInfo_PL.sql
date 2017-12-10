CREATE OR REPLACE PROCEDURE SP_GC_PerBuyCardInfo
(
    P_FUNCCODE              VARCHAR2 ,
    P_NAME                  VARCHAR2 ,
    P_BIRTHDAY              VARCHAR2 ,
    P_PAPERTYPE             CHAR     ,
    P_PAPERNO               VARCHAR2 ,
    P_PAPERENDDATE          CHAR     ,
    P_SEX                   CHAR     ,
    p_NATIONALITY           VARCHAR2 ,
    P_JOB                   VARCHAR2 ,
    P_PHONENO               VARCHAR2 ,
    P_ADDRESS               VARCHAR2 ,
    P_EMAIL                 VARCHAR2 ,
    P_REGISTEREDCAPITAL     int      ,
    P_CALLINGNO             CHAR     ,
    P_CURROPER              CHAR     ,
    P_CURRDEPT              CHAR     ,
    P_RETCODE           OUT CHAR     ,
    P_RETMSG            OUT VARCHAR2
)
AS
    V_FUNCCODE        VARCHAR2(16) := P_FUNCCODE ;
    V_TODAY           DATE         := SYSDATE    ;
    V_QUANTITY        INT                        ;
    V_EX              EXCEPTION                  ;

BEGIN
     -- ��ӵǼ�
     IF V_FUNCCODE = 'ADD' THEN
        --�жϸ�����Ϣ�Ƿ����
       SELECT  COUNT(*) INTO V_QUANTITY
       FROM   TD_M_BUYCARDPERINFO
       WHERE  PAPERTYPE = P_PAPERTYPE
       AND    PAPERNO = P_PAPERNO;
     IF V_QUANTITY > 0 THEN
      P_RETCODE := 'A001002103';
      P_RETMSG  := '���д˹���������Ϣ�����ڿ���';
      ROLLBACK; RETURN;
     END IF;
       --��Ϣ������ʱ�����¸�����Ϣ
       
       BEGIN
         INSERT INTO TD_M_BUYCARDPERINFO(
         PAPERTYPE     , PAPERNO      , PAPERENDDATE , NAME       , BIRTHDAY     ,
          SEX           ,NATIONALITY   , JOB          , PHONENO      , ADDRESS      ,
          EMAIL         ,OPERATOR      ,OPERDEPT      ,OPERATETIME    ,REGISTEREDCAPITAL,CALLINGNO
         )VALUES(
         P_PAPERTYPE   , P_PAPERNO    , P_PAPERENDDATE ,P_NAME     , P_BIRTHDAY   ,
         P_SEX         , P_NATIONALITY , P_JOB      ,P_PHONENO    , P_ADDRESS  ,
         P_EMAIL       , P_CURROPER    ,P_CURRDEPT  ,V_TODAY       ,P_REGISTEREDCAPITAL,P_CALLINGNO
         );
       EXCEPTION WHEN OTHERS THEN
         P_RETCODE := 'S004101001' ;
         P_RETMSG  := '���빺��������Ϣ��ʧ��'||SQLERRM ;
         ROLLBACK;RETURN;
       END;
       
       END IF;
       
       --�޸�
       IF V_FUNCCODE = 'MODIFY' THEN
       --���¸�����Ϣ
       BEGIN
         UPDATE  TD_M_BUYCARDPERINFO tmb
        SET     tmb.PAPERENDDATE=P_PAPERENDDATE,
                tmb.NAME      = P_NAME       ,
                tmb.BIRTHDAY  = P_BIRTHDAY   ,
                tmb.SEX       = P_SEX        ,
                tmb.NATIONALITY=P_NATIONALITY,
                tmb.JOB       = P_JOB        ,
                tmb.PHONENO   = P_PHONENO    ,
                tmb.ADDRESS   = P_ADDRESS    ,
                tmb.EMAIL     = P_EMAIL      ,
                tmb.operator  = p_curroper   ,
                tmb.operdept  = p_currdept   ,
                tmb.operatetime = v_today    ,
                tmb.registeredcapital=P_REGISTEREDCAPITAL,
                tmb.callingno = P_CALLINGNO
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


     p_retCode := '0000000000'; p_retMsg  := '�ɹ�';
     commit; return;
END;
/
show errors;
