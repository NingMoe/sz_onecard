CREATE OR REPLACE PROCEDURE SP_GC_ComBuyCardInfo
(
    P_FUNCCODE              VARCHAR2 ,
    P_COMPANYNO             CHAR     ,
    P_COMPANYNAME           VARCHAR2 ,
    P_COMPANYPAPERTYPE      CHAR     ,
    P_COMPANYPAPERNO        VARCHAR2 ,
    P_COMPANYMANAGERNO      VARCHAR2 ,
    P_COMPANYENDTIME        VARCHAR2 ,
    P_NAME                  VARCHAR2 ,
    P_PAPERTYPE             CHAR     ,
    P_PAPERNO               VARCHAR2 ,
    P_PAPERENDDATE          CHAR     ,
    P_PHONENO               VARCHAR2 ,
    P_ADDRESS               VARCHAR2 ,
    P_EMAIL                 VARCHAR2 ,
    P_CALLINGNO             CHAR     ,
    P_REGISTEREDCAPITAL     int      ,
    P_OUTCOMPANYNO             out char,
    P_CURROPER              CHAR     ,
    P_CURRDEPT              CHAR     ,
    P_RETCODE           OUT CHAR     ,
    P_RETMSG            OUT VARCHAR2 
)
AS
    V_FUNCCODE        VARCHAR2(16) := P_FUNCCODE ;
    V_TODAY           DATE         := SYSDATE    ;
    V_QUANTITY        INT                        ;
   V_COMNO_SEQ       VARCHAR2(6)                ;
    V_EX              EXCEPTION                  ;
    V_COUNT           INT;
BEGIN
        -- ��ӵǼ�
        IF V_FUNCCODE = 'ADD' THEN
        
        --�жϵ�λ��Ϣ�Ƿ����
       SELECT  COUNT(*) INTO V_QUANTITY
       FROM   TD_M_BUYCARDCOMINFO
       WHERE  COMPANYPAPERTYPE = P_COMPANYPAPERTYPE 
        AND    COMPANYPAPERNO = P_COMPANYPAPERNO;
     IF V_QUANTITY > 0 THEN
      P_RETCODE := 'A001002100';
      P_RETMSG  := '���д˹�����λ��Ϣ�����ڿ���';
      ROLLBACK; RETURN;
     END IF;        
        
        --��Ϣ������ʱ�����µ�λ��Ϣ
        
        BEGIN
            SELECT TD_M_BUYCARDCOM_SEQ.NEXTVAL INTO V_COMNO_SEQ FROM DUAL;
            P_OUTCOMPANYNO:=V_COMNO_SEQ;
            
            INSERT INTO TD_M_BUYCARDCOMINFO(
            COMPANYNO        , COMPANYNAME    , COMPANYPAPERTYPE   , COMPANYPAPERNO   , COMPANYMANAGERNO  ,  COMPANYENDTIME,
            NAME             ,PAPERTYPE       , PAPERNO            ,PAPERENDDATE      ,PHONENO            ,ADDRESS       ,
            EMAIL            ,OPERATOR        ,OPERDEPT            ,OPERATETIME             ,REGISTEREDCAPITAL ,CALLINGNO
            )VALUES(
            V_COMNO_SEQ      , P_COMPANYNAME  , P_COMPANYPAPERTYPE , P_COMPANYPAPERNO , P_COMPANYMANAGERNO , P_COMPANYENDTIME,
            P_NAME           ,P_PAPERTYPE     , P_PAPERNO          ,P_PAPERENDDATE      ,P_PHONENO         ,P_ADDRESS       ,
            P_EMAIL          , P_CURROPER    ,P_CURRDEPT           ,V_TODAY               ,P_REGISTEREDCAPITAL,P_CALLINGNO
            );
        EXCEPTION WHEN OTHERS THEN
            P_RETCODE := 'S004102001' ;
            P_RETMSG  := '���빺����λ��Ϣ��ʧ��,'||SQLERRM ;
        ROLLBACK;RETURN;
        END;
        END IF;
       

     
     --�޸�
     IF V_FUNCCODE = 'MODIFY' THEN
     --���µ�λ��Ϣ
     BEGIN
     
       --�жϵ�λ��Ϣ�Ƿ����
       SELECT  COUNT(*) INTO V_COUNT
       FROM   TD_M_BUYCARDCOMINFO
       WHERE  COMPANYPAPERTYPE = P_COMPANYPAPERTYPE 
        AND    COMPANYPAPERNO = P_COMPANYPAPERNO
        AND   COMPANYNO!=P_COMPANYNO;
     IF V_COUNT > 0 THEN
      P_RETCODE := 'A001002104';
      P_RETMSG  := '���д˵�λ֤�����ͺ͵�λ֤����������ڿ���';
      ROLLBACK; RETURN;
     END IF;     
     
     
     P_OUTCOMPANYNO:=P_COMPANYNO;
         UPDATE  TD_M_BUYCARDCOMINFO tmb
        SET     tmb.COMPANYNAME      = P_COMPANYNAME       ,
                tmb.companypapertype = P_COMPANYPAPERTYPE  ,
                tmb.companypaperno   = P_companypaperno    ,
                tmb.COMPANYMANAGERNO = P_COMPANYMANAGERNO  ,
                tmb.COMPANYENDTIME   = P_COMPANYENDTIME    ,
                tmb.NAME             = P_NAME              ,
                tmb.PAPERTYPE        = P_PAPERTYPE         ,
                tmb.PAPERNO          = P_PAPERNO           ,
                tmb.PAPERENDDATE     = P_PAPERENDDATE      ,
                tmb.PHONENO          = P_PHONENO           ,
                tmb.ADDRESS          = P_ADDRESS           ,
                tmb.EMAIL            = P_EMAIL              ,
                tmb.operator         = p_curroper           ,
                tmb.operdept         = p_currdept           ,
                tmb.operatetime      = v_today              ,
                tmb.registeredcapital= P_REGISTEREDCAPITAL  ,
                tmb.callingno        = P_CALLINGNO
        WHERE   tmb.COMPANYNO        = P_COMPANYNO   ;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE :=  'S004102002';
        P_RETMSG  := '���¹�����λ��Ϣ��ʧ��' || SQLERRM;
        ROLLBACK; RETURN;
     END;
     END IF;
     
      
     
     
     
     p_retCode := '0000000000'; p_retMsg  := '�ɹ�';
     COMMIT; RETURN;   
END;
/
show errors;
