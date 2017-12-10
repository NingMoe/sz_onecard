CREATE OR REPLACE PROCEDURE SP_PB_ComBuyCardReg
(
    P_FUNCCODE              VARCHAR2 ,
    P_ID                    CHAR     ,
    P_COMPANYNAME           VARCHAR2 ,
    P_COMPANYPAPERTYPE      CHAR     ,
    P_COMPANYPAPERNO        VARCHAR2 ,
    P_COMPANYMANAGERNO      VARCHAR2 ,
    P_COMPANYENDTIME        VARCHAR2 ,
    P_NAME                  VARCHAR2 ,
    P_PAPERTYPE             CHAR     ,
    P_PAPERNO               VARCHAR2 ,
    P_PHONENO               VARCHAR2 ,
    P_ADDRESS               VARCHAR2 ,
    P_EMAIL                 VARCHAR2 ,
    P_OUTBANK               VARCHAR2 ,
    P_OUTACCT               VARCHAR2 ,
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
    V_COMNO_SEQ       VARCHAR2(6)                ;
    V_EX              EXCEPTION                  ;
    V_COMPANYNAME     VARCHAR2(100)              ;
    V_COUNT           INT                        ;
BEGIN
        -- ��ӵǼ�
        IF V_FUNCCODE = 'ADD' THEN
        begin
         --�жϵ�λ��Ϣ
        SELECT COUNT(*) INTO V_COUNT
        FROM   TD_M_BUYCARDCOMINFO 
        WHERE  COMPANYPAPERTYPE = P_COMPANYPAPERTYPE 
        AND    COMPANYPAPERNO = P_COMPANYPAPERNO;
        
        IF V_COUNT <2  THEN
        BEGIN 
          SELECT COMPANYNO ,COMPANYNAME INTO V_COMNO_SEQ,V_COMPANYNAME
          FROM   TD_M_BUYCARDCOMINFO 
          WHERE  COMPANYPAPERTYPE = P_COMPANYPAPERTYPE 
          AND    COMPANYPAPERNO = P_COMPANYPAPERNO;
          EXCEPTION WHEN no_data_found THEN
              null;
         END;
         END IF;
        
        IF  V_COUNT>1 THEN
          P_RETCODE := 'S004101000';
          P_RETMSG  :='��ѯ������λ��Ϣ��ʧ��,'||SQLERRM ;
          ROLLBACK; RETURN;
        END IF;
        END;
        
        --��Ϣ������ʱ�����µ�λ��Ϣ
        IF V_COMNO_SEQ IS NULL THEN 
        BEGIN
            SELECT TD_M_BUYCARDCOM_SEQ.NEXTVAL INTO V_COMNO_SEQ FROM DUAL;
            INSERT INTO TD_M_BUYCARDCOMINFO(
            COMPANYNO        , COMPANYNAME    , COMPANYPAPERTYPE   , COMPANYPAPERNO   , COMPANYMANAGERNO  ,  COMPANYENDTIME ,
            NAME             ,PAPERTYPE       , PAPERNO            , PHONENO          , ADDRESS           ,  EMAIL          ,
            OPERATOR         ,OPERDEPT        , OPERATETIME
            )VALUES(
            V_COMNO_SEQ      , P_COMPANYNAME  , P_COMPANYPAPERTYPE , P_COMPANYPAPERNO , P_COMPANYMANAGERNO , P_COMPANYENDTIME,
            P_NAME           , P_PAPERTYPE    , P_PAPERNO          , P_PHONENO        , P_ADDRESS          , P_EMAIL         ,
            P_CURROPER       , P_CURRDEPT     , V_TODAY
            );
        EXCEPTION WHEN OTHERS THEN
            P_RETCODE := 'S004102001' ;
            P_RETMSG  := '���빺����λ��Ϣ��ʧ��,'||SQLERRM ;
        ROLLBACK;RETURN;
        END;
        END IF;
       
        IF V_COMNO_SEQ IS NOT NULL THEN
        BEGIN
            --���µ�λ��Ϣ��
            UPDATE TD_M_BUYCARDCOMINFO
            SET    COMPANYNAME = P_COMPANYNAME,
                   COMPANYMANAGERNO = P_COMPANYMANAGERNO,
                   COMPANYENDTIME = P_COMPANYENDTIME,
                   NAME = P_NAME,
                   PAPERTYPE = P_PAPERTYPE,
                   PAPERNO = P_PAPERNO,
                   PHONENO = P_PHONENO,
                   ADDRESS = P_ADDRESS,
                   EMAIL = P_EMAIL,
                   OPERATOR = P_CURROPER,
                   OPERDEPT = P_CURRDEPT,
                   OPERATETIME = V_TODAY          
            WHERE  COMPANYNO = V_COMNO_SEQ;
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION WHEN OTHERS THEN
            P_RETCODE := 'S004102001' ;
            P_RETMSG  := '���¹�����λ��Ϣ��ʧ��,'||SQLERRM ;
        ROLLBACK;RETURN;
        END;       
        END IF;
       
        --��������¼���뵥λ������¼��
        BEGIN 
        SP_GETSEQ(SEQ => V_SEQ);
        INSERT INTO TF_F_COMBUYCARDREG(
            ID              , COMPANYNO      , NAME              , PAPERTYPE          ,
            PAPERNO         , PHONENO        , ADDRESS           , EMAIL              ,
            OUTBANK         , OUTACCT        , STARTCARDNO       , ENDCARDNO          , 
            BUYCARDDATE     , BUYCARDNUM     , BUYCARDMONEY      , CHARGEMONEY        ,
            REMARK
        )VALUES(
            V_SEQ           , V_COMNO_SEQ    , P_NAME            , P_PAPERTYPE        , 
            P_PAPERNO       , P_PHONENO      , P_ADDRESS         , P_EMAIL            ,
            P_OUTBANK       , P_OUTACCT      , P_STARTCARDNO     , P_ENDCARDNO        ,
            P_BUYCARDDATE   , P_BUYCARDNUM   , P_BUYCARDMONEY    , P_CHARGEMONEY      ,
            P_REMARK);
        EXCEPTION WHEN OTHERS THEN
            P_RETCODE := 'S004102002' ;
            P_RETMSG  := '���뵥λ������¼��ʧ��'||SQLERRM ;
            ROLLBACK;RETURN;
        END;
       
        --��¼��λ��������̨��     
        BEGIN
        INSERT INTO TF_B_COMBUYCARD(
            TRADEID         , ID             , OPERATETYPECODE   , COMPANYNAME        , 
            COMPANYPAPERTYPE, COMPANYPAPERNO , NAME              , PAPERTYPE          ,
            PAPERNO         , PHONENO        , ADDRESS           , EMAIL              ,
            OUTBANK         , OUTACCT        , STARTCARDNO       , ENDCARDNO          ,
            BUYCARDDATE     , BUYCARDNUM     , BUYCARDMONEY      , CHARGEMONEY        ,
            STAFFNO         , CORPNO         , OPERATETIME       , REMARK             ,
            COMPANYMANAGERNO, COMPANYENDTIME
       )SELECT 
            V_SEQ              , V_SEQ           , '01'              , a.COMPANYNAME   , 
            a.COMPANYPAPERTYPE , a.COMPANYPAPERNO, P_NAME            , P_PAPERTYPE     ,
            P_PAPERNO          , P_PHONENO       , P_ADDRESS         , P_EMAIL         ,
            P_OUTBANK          , P_OUTACCT       , P_STARTCARDNO     , P_ENDCARDNO     ,
            P_BUYCARDDATE      , P_BUYCARDNUM    , P_BUYCARDMONEY    , P_CHARGEMONEY   ,
            P_CURROPER         , P_CURRDEPT      , V_TODAY           , P_REMARK        ,
            P_COMPANYMANAGERNO , p_COMPANYENDTIME
        FROM TD_M_BUYCARDCOMINFO a
        WHERE TRIM(a.COMPANYNO) = V_COMNO_SEQ;
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
            P_RETCODE :=  'S004102007';
            P_RETMSG  := '��¼��λ����̨�˱�ʧ��' || SQLERRM;
            ROLLBACK; RETURN;
        END;
     END IF;
     
     --�޸�
     IF V_FUNCCODE = 'MODIFY' THEN
     --���µ�λ��Ϣ
     BEGIN
         UPDATE  TD_M_BUYCARDCOMINFO tmb
        SET     tmb.COMPANYNAME      = P_COMPANYNAME       ,
                tmb.COMPANYPAPERTYPE = P_COMPANYPAPERTYPE  ,
                tmb.COMPANYPAPERNO   = P_COMPANYPAPERNO    ,
                tmb.COMPANYMANAGERNO = P_COMPANYMANAGERNO  ,
                tmb.COMPANYENDTIME   = P_COMPANYENDTIME    ,
                tmb.NAME             = P_NAME              ,
                tmb.PAPERTYPE        = P_PAPERTYPE         ,
                tmb.PAPERNO          = P_PAPERNO					 ,
                tmb.PHONENO          = P_PHONENO						,
                tmb.ADDRESS          = P_ADDRESS						,
                tmb.EMAIL            = P_EMAIL							
        WHERE   tmb.COMPANYNO        = (SELECT  tfc.COMPANYNO
                                        FROM TF_F_COMBUYCARDREG tfc 
                                        WHERE tfc.ID = P_ID)    ;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE :=  'S004102003';
        P_RETMSG  := '���µ�λ��Ϣ��ʧ��' || SQLERRM;
        ROLLBACK; RETURN;
     END;
     --���µ�λ������¼
     BEGIN
        UPDATE  TF_F_COMBUYCARDREG
        SET     NAME         = P_NAME         ,
                PAPERTYPE    = P_PAPERTYPE    ,
                PAPERNO      = P_PAPERNO      ,
                PHONENO      = P_PHONENO      ,
                ADDRESS      = P_ADDRESS      ,
                EMAIL        = P_EMAIL        ,
                OUTBANK      = P_OUTBANK      ,
                OUTACCT      = P_OUTACCT      ,
                STARTCARDNO  = P_STARTCARDNO  ,
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
        P_RETCODE :=  'S004102004';
        P_RETMSG  := '���µ�λ������¼��ʧ��' || SQLERRM;
        ROLLBACK; RETURN;
    END;
       --��¼��λ��������̨��
       BEGIN
       SP_GETSEQ(SEQ => V_SEQ);
       INSERT INTO TF_B_COMBUYCARD(
            TRADEID         , ID             , OPERATETYPECODE   , COMPANYNAME        , 
            COMPANYPAPERTYPE, COMPANYPAPERNO , NAME              , PAPERTYPE          ,
            PAPERNO         , PHONENO        , ADDRESS           , EMAIL              ,
            OUTBANK         , OUTACCT        , STARTCARDNO       , ENDCARDNO          ,
            BUYCARDDATE     , BUYCARDNUM     , BUYCARDMONEY      , CHARGEMONEY        ,
            STAFFNO         , CORPNO         , OPERATETIME       , REMARK             ,
            COMPANYMANAGERNO, COMPANYENDTIME
        )SELECT
            V_SEQ              , P_ID            , '02'              , a.COMPANYNAME      , 
            a.COMPANYPAPERTYPE , a.COMPANYPAPERNO, P_NAME            , P_PAPERTYPE        ,
            P_PAPERNO          , P_PHONENO       , P_ADDRESS         , P_EMAIL            ,
            P_OUTBANK          , P_OUTACCT       , P_STARTCARDNO     , P_ENDCARDNO        ,
            P_BUYCARDDATE      , P_BUYCARDNUM    , P_BUYCARDMONEY    , P_CHARGEMONEY      ,
            P_CURROPER         , P_CURRDEPT      , V_TODAY           , P_REMARK              ,
            P_COMPANYMANAGERNO , p_COMPANYENDTIME
         FROM TD_M_BUYCARDCOMINFO a,TF_F_COMBUYCARDREG b
         WHERE a.COMPANYNO = b.COMPANYNO
         AND   b.ID = P_ID;
         IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
       EXCEPTION
         WHEN OTHERS THEN
         P_RETCODE :=  'S004102007';
         P_RETMSG  := '��¼��λ����̨�˱�ʧ��' || SQLERRM;
         ROLLBACK; RETURN;
       END;

     END IF;
     
     --ɾ��
     IF  V_FUNCCODE = 'DELETE' THEN
         --��¼��λ��������̨��
         BEGIN
         SP_GETSEQ(SEQ => V_SEQ);
         INSERT INTO TF_B_COMBUYCARD(
            TRADEID         , ID             , OPERATETYPECODE   , COMPANYNAME        , 
            COMPANYPAPERTYPE, COMPANYPAPERNO , NAME              , PAPERTYPE          ,
            PAPERNO         , PHONENO        , ADDRESS           , EMAIL              ,
            OUTBANK         , OUTACCT        , STARTCARDNO       , ENDCARDNO          ,
            BUYCARDDATE     , BUYCARDNUM     , BUYCARDMONEY      , CHARGEMONEY        ,
            STAFFNO         , CORPNO         , OPERATETIME       , REMARK             ,
            COMPANYMANAGERNO, COMPANYENDTIME
        )SELECT
            V_SEQ              , P_ID            , '03'              , a.COMPANYNAME      , 
            a.COMPANYPAPERTYPE , a.COMPANYPAPERNO, b.NAME            , b.PAPERTYPE        ,
            b.PAPERNO          , b.PHONENO       , b.ADDRESS         , b.EMAIL            ,
            b.OUTBANK          , b.OUTACCT       , b.STARTCARDNO     , b.ENDCARDNO        ,
            b.BUYCARDDATE      , b.BUYCARDNUM    , b.BUYCARDMONEY    , b.CHARGEMONEY      ,
            P_CURROPER         , P_CURRDEPT      , V_TODAY           , b.REMARK              ,
            P_COMPANYMANAGERNO , p_COMPANYENDTIME
         FROM TD_M_BUYCARDCOMINFO a,TF_F_COMBUYCARDREG b
         WHERE a.COMPANYNO = b.COMPANYNO
         AND   b.ID = P_ID;
         IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
       EXCEPTION
         WHEN OTHERS THEN
         P_RETCODE :=  'S004102007';
         P_RETMSG  := '��¼��λ����̨�˱�ʧ��' || SQLERRM;
         ROLLBACK; RETURN;
       END;
       
       --ɾ����λ������¼
       BEGIN
         DELETE  FROM  TF_F_COMBUYCARDREG WHERE ID = P_ID ;

       EXCEPTION WHEN OTHERS THEN
            P_RETCODE := 'S004102005' ;
            P_RETMSG  := 'ɾ����λ������¼��ʧ��'||SQLERRM ;
            ROLLBACK;RETURN;
       END;
     END IF;
     
     p_retCode := '0000000000'; p_retMsg  := '�ɹ�';
     return;
END;

/
show errors