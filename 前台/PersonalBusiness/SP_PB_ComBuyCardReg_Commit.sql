CREATE OR REPLACE PROCEDURE SP_PB_ComBuyCardReg_Commit
(
    P_FUNCCODE              VARCHAR2 ,
    P_ID                    CHAR     ,
    P_COMPANYNAME           VARCHAR2 ,
    P_COMPANYPAPERTYPE      CHAR     ,
    P_COMPANYPAPERNO        VARCHAR2 ,
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
    V_EX              EXCEPTION;
BEGIN
    BEGIN
        SP_PB_ComBuyCardReg(
            P_FUNCCODE         => P_FUNCCODE         ,
            P_ID               => P_ID               ,
            P_COMPANYNAME      => P_COMPANYNAME      ,
            P_COMPANYPAPERTYPE => P_COMPANYPAPERTYPE ,
            P_COMPANYPAPERNO   => P_COMPANYPAPERNO   ,
            P_COMPANYMANAGERNO => ''                 ,
            P_COMPANYENDTIME   => ''                 ,
            P_NAME             => P_NAME             ,
            P_PAPERTYPE        => P_PAPERTYPE        ,
            P_PAPERNO          => P_PAPERNO          ,
            P_PHONENO          => P_PHONENO          ,
            P_ADDRESS          => P_ADDRESS          ,
            P_EMAIL            => P_EMAIL            ,
            P_OUTBANK          => P_OUTBANK          ,
            P_OUTACCT          => P_OUTACCT          ,
            P_STARTCARDNO      => P_STARTCARDNO      ,
            P_ENDCARDNO        => P_ENDCARDNO        ,
            P_BUYCARDDATE      => P_BUYCARDDATE      ,
            P_BUYCARDNUM       => P_BUYCARDNUM       ,
            P_BUYCARDMONEY     => P_BUYCARDMONEY     ,
            P_CHARGEMONEY      => P_CHARGEMONEY      ,
            P_REMARK           => P_REMARK           ,
            P_CURROPER         => P_CURROPER         ,
            P_CURRDEPT         => P_CURRDEPT         ,
            P_RETCODE          => P_RETCODE          ,
            P_RETMSG           => P_RETMSG
        );
        IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;    
END;

/
show errors