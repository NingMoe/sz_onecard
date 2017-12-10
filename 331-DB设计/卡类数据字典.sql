--IC卡类型编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_CARDTYPE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_CARDTYPE (
    CARDTYPECODE            CHAR(2)                         NOT NULL,
    CARDTYPENAME            VARCHAR2(20)                    NOT NULL,
    CARDTYPENOTE            VARCHAR2(150)                       NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    CARDRETURN              CHAR(1)                             NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_M_CARDTYPE PRIMARY KEY(CARDTYPECODE)
)tablespace TBSdata_B_SZ
/


grant Select on TD_M_CARDTYPE to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TD_M_CARDTYPE to Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Update on TD_M_CARDTYPE to Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Delete on TD_M_CARDTYPE to Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;


--IC卡资料表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDREC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDREC (
    CARDNO                  CHAR(16)                        NOT NULL,
    ASN                     CHAR(16)                        NOT NULL,
    CARDTYPECODE            CHAR(2)                             NULL,
    CARDSURFACECODE         CHAR(4)                             NULL,
    CARDMANUCODE            CHAR(2)                             NULL,
    CARDCHIPTYPECODE        CHAR(2)                             NULL,
    APPTYPECODE             CHAR(2)                             NULL,
    APPVERNO                CHAR(2)                             NULL,
    DEPOSIT                 INT                                 NULL,
    CARDCOST                INT                                 NULL,
    PRESUPPLYMONEY          INT                                 NULL,
    CUSTRECTYPECODE         CHAR(1)                             NULL,
    SELLTIME                DATE                                NULL,
    SELLCHANNELCODE         CHAR(2)                             NULL,
    DEPARTNO                CHAR(4)                             NULL,
    STAFFNO                 CHAR(6)                             NULL,
    CARDSTATE               CHAR(2)                         NOT NULL,
    VALIDENDDATE            CHAR(8)                             NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    SERSTARTTIME            DATE                                NULL,
    SERSTAKETAG             CHAR(1)                             NULL,
    SERVICEMONEY            INT              DEFAULT 0          NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_CARDREC PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CARDREC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CARDREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CARDREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CARDREC to Uopsett_B_SZ,Ucrapp_B_SZ;


--中石油IC卡资料表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDREC_CNPC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDREC_CNPC (
    CARDNO                  CHAR(16)                        NOT NULL,
    ASN                     CHAR(16)                        NOT NULL,
    CARDTYPECODE            CHAR(2)                             NULL,
    CARDSURFACECODE         CHAR(4)                             NULL,
    CARDMANUCODE            CHAR(2)                             NULL,
    CARDCHIPTYPECODE        CHAR(2)                             NULL,
    APPTYPECODE             CHAR(2)                             NULL,
    APPVERNO                CHAR(2)                             NULL,
    DEPOSIT                 INT                                 NULL,
    CARDCOST                INT                                 NULL,
    PRESUPPLYMONEY          INT                                 NULL,
    CUSTRECTYPECODE         CHAR(1)                             NULL,
    SELLTIME                DATE                                NULL,
    SELLCHANNELCODE         CHAR(2)                             NULL,
    DEPARTNO                CHAR(4)                             NULL,
    STAFFNO                 CHAR(6)                             NULL,
    CARDSTATE               CHAR(2)                         NOT NULL,
    VALIDENDDATE            CHAR(8)                             NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    SERSTARTTIME            DATE                                NULL,
    SERSTAKETAG             CHAR(1)                             NULL,
    SERVICEMONEY            INT                                 NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_CARDREC_CNPC PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CARDREC_CNPC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CARDREC_CNPC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CARDREC_CNPC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CARDREC_CNPC to Uopsett_B_SZ,Ucrapp_B_SZ;


--IC卡芯片类型编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_CARDCHIPTYPE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_CARDCHIPTYPE (
    CARDCHIPTYPECODE        CHAR(2)                         NOT NULL,
    CARDCHIPTYPENAME        VARCHAR2(40)                    NOT NULL,
    CARDCHIPTYPENOTE        VARCHAR2(150)                       NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_M_CARDCHIPTYPE PRIMARY KEY(CARDCHIPTYPECODE)
)tablespace TBSdata_B_SZ
/


grant Select on TD_M_CARDCHIPTYPE to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TD_M_CARDCHIPTYPE to Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Update on TD_M_CARDCHIPTYPE to Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Delete on TD_M_CARDCHIPTYPE to Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;


--IC卡卡面编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_CARDSURFACE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_CARDSURFACE (
    CARDSURFACECODE         CHAR(4)                         NOT NULL,
    CARDSURFACENAME         VARCHAR2(40)                    NOT NULL,
    CARDSURFACENOTE         VARCHAR2(150)                       NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    CARDSAMPLECODE          CHAR(6)                             NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_M_CARDSURFACE PRIMARY KEY(CARDSURFACECODE)
)tablespace TBSdata_B_SZ
/


grant Select on TD_M_CARDSURFACE to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TD_M_CARDSURFACE to Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Update on TD_M_CARDSURFACE to Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Delete on TD_M_CARDSURFACE to Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;


--厂商编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_MANU CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_MANU (
    MANUCODE                CHAR(2)                         NOT NULL,
    MANUNAME                VARCHAR2(50)                    NOT NULL,
    MANUNOTE                VARCHAR2(150)                       NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_M_MANU PRIMARY KEY(MANUCODE)
)tablespace TBSdata_B_SZ
/


grant Select on TD_M_MANU to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TD_M_MANU to Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Update on TD_M_MANU to Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Delete on TD_M_MANU to Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;


--IC卡电子钱包退值表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDEWALLETACC_BACK CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDEWALLETACC_BACK (
    CARDNO                  CHAR(16)                        NOT NULL,
    JUDGEMONEY              INT                             NOT NULL,
    JUDGEMODE               CHAR(1)                         NOT NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_CARDEWALLETACC_BACK PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CARDEWALLETACC_BACK to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CARDEWALLETACC_BACK to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CARDEWALLETACC_BACK to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CARDEWALLETACC_BACK to Uopsett_B_SZ,Ucrapp_B_SZ;


--IC卡电子钱包账户表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDEWALLETACC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDEWALLETACC (
    CARDNO                  CHAR(16)                        NOT NULL,
    CARDACCMONEY            INT                             NOT NULL,
    USETAG                  CHAR(1)                             NULL,
    CREDITSTATECODE         CHAR(2)                             NULL,
    CREDITSTACHANGETIME     DATE                                NULL,
    CREDITCONTROLCODE       CHAR(2)                             NULL,
    CREDITCOLCHANGETIME     DATE                                NULL,
    ACCSTATECODE            CHAR(2)                         NOT NULL,
    CONSUMEREALMONEY        INT              DEFAULT 0          NULL,
    SUPPLYREALMONEY         INT              DEFAULT 0          NULL,
    TOTALCONSUMETIMES       INT              DEFAULT 0          NULL,
    TOTALSUPPLYTIMES        INT              DEFAULT 0          NULL,
    TOTALCONSUMEMONEY       INT              DEFAULT 0          NULL,
    TOTALSUPPLYMONEY        INT              DEFAULT 0          NULL,
    FIRSTCONSUMETIME        DATE                                NULL,
    LASTCONSUMETIME         DATE                                NULL,
    FIRSTSUPPLYTIME         DATE                                NULL,
    LASTSUPPLYTIME          DATE                                NULL,
    OFFLINECARDTRADENO      CHAR(4)                             NULL,
    ONLINECARDTRADENO       CHAR(4)                             NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_CARDEWALLETACC PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CARDEWALLETACC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CARDEWALLETACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CARDEWALLETACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CARDEWALLETACC to Uopsett_B_SZ,Ucrapp_B_SZ;


--中石油IC卡电子钱包账户表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDEWALLETACC_CNPC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDEWALLETACC_CNPC (
    CARDNO                  CHAR(16)                        NOT NULL,
    CARDACCMONEY            INT                             NOT NULL,
    USETAG                  CHAR(1)                             NULL,
    CREDITSTATECODE         CHAR(2)                             NULL,
    CREDITSTACHANGETIME     DATE                                NULL,
    CREDITCONTROLCODE       CHAR(2)                             NULL,
    CREDITCOLCHANGETIME     DATE                                NULL,
    ACCSTATECODE            CHAR(2)                         NOT NULL,
    CONSUMEREALMONEY        INT              DEFAULT 0          NULL,
    SUPPLYREALMONEY         INT              DEFAULT 0          NULL,
    TOTALCONSUMETIMES       INT              DEFAULT 0          NULL,
    TOTALSUPPLYTIMES        INT              DEFAULT 0          NULL,
    TOTALCONSUMEMONEY       INT              DEFAULT 0          NULL,
    TOTALSUPPLYMONEY        INT              DEFAULT 0          NULL,
    FIRSTCONSUMETIME        DATE                                NULL,
    LASTCONSUMETIME         DATE                                NULL,
    FIRSTSUPPLYTIME         DATE                                NULL,
    LASTSUPPLYTIME          DATE                                NULL,
    OFFLINECARDTRADENO      CHAR(4)                             NULL,
    ONLINECARDTRADENO       CHAR(4)                             NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_CARDEWALLETACC_CNPC PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CARDEWALLETACC_CNPC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CARDEWALLETACC_CNPC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CARDEWALLETACC_CNPC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CARDEWALLETACC_CNPC to Uopsett_B_SZ,Ucrapp_B_SZ;


--IC卡月票计次账户表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDCOUNTACC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDCOUNTACC (
    CARDNO                  CHAR(16)                        NOT NULL,
    APPTYPE                 CHAR(2)                             NULL,
    ASSIGNEDAREA            CHAR(2)                             NULL,
    APPTIME                 DATE                                NULL,
    APPSTAFFNO              CHAR(6)                             NULL,
    LASTAUDIT               CHAR(8)                             NULL,
    LASTAUDITTIME           DATE                                NULL,
    LASTAUDITSTAFFNO        CHAR(6)                             NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    ENDTIME                 CHAR(8)                             NULL,
    TOTALPAYTIMES           INT                                 NULL,
    TOTALTIMES              INT                                 NULL,
    SPARETIMES              INT                                 NULL,
    TOTALCOUNT              INT                                 NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    RSRV1                   INT                                 NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_CARDCOUNTACC PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CARDCOUNTACC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CARDCOUNTACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CARDCOUNTACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CARDCOUNTACC to Uopsett_B_SZ,Ucrapp_B_SZ;


--苏州园林年卡账户表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDPARKACC_SZ CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDPARKACC_SZ (
    CARDNO                  CHAR(16)                        NOT NULL,
    CURRENTOPENYEAR         CHAR(6)                             NULL,
    CARDTIMES               INT                                 NULL,
    ENDDATE                 CHAR(8)                             NULL,
    CURRENTPAYTIME          DATE                                NULL,
    CURRENTPAYFEE           INT                                 NULL,
    TOTALTIMES              INT                                 NULL,
    SPARETIMES              INT                                 NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    RERVINT                 INT                                 NULL,
    RERVCHAR                VARCHAR2(20)                        NULL,
    RERVSTRING              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_CARDPARKACC_SZ PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CARDPARKACC_SZ to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CARDPARKACC_SZ to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CARDPARKACC_SZ to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CARDPARKACC_SZ to Uopsett_B_SZ,Ucrapp_B_SZ;


--苏州休闲年卡账户表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDXXPARKACC_SZ CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDXXPARKACC_SZ (
    CARDNO                  CHAR(16)                        NOT NULL,
    PACKAGETYPECODE         CHAR(2)                             NULL,
    CURRENTOPENYEAR         CHAR(6)                             NULL,
    CARDTIMES               INT                                 NULL,
    ENDDATE                 CHAR(8)                             NULL,
    CURRENTPAYTIME          DATE                                NULL,
    CURRENTPAYFEE           INT                                 NULL,
    TOTALTIMES              INT                                 NULL,
    SPARETIMES              INT                                 NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    ACCOUNTTYPE             CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    RERVINT                 INT                                 NULL,
    RERVCHAR                VARCHAR2(20)                        NULL,
    RERVSTRING              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_CARDXXPARKACC_SZ PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CARDXXPARKACC_SZ to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CARDXXPARKACC_SZ to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CARDXXPARKACC_SZ to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CARDXXPARKACC_SZ to Uopsett_B_SZ,Ucrapp_B_SZ;


--IC卡资金返还账户表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDRETURNACC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDRETURNACC (
    CARDNO                  CHAR(16)                        NOT NULL,
    TETURNMONEY             INT                             NOT NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    PASSWD                  CHAR(6)                             NULL,
    BEGINTIME               DATE                                NULL,
    ENDTIME                 DATE                                NULL,
    LASUPPLYMONEY           INT                                 NULL,
    LASUPPLYTIME            DATE                                NULL,
    TOTALRETURNTIMES        INT              DEFAULT 0          NULL,
    TOTALRETURNMONEY        INT              DEFAULT 0          NULL,
    LASTSUPPLYPOSNO         CHAR(6)                             NULL,
    LASTSUPPLYSAMNO         CHAR(12)                            NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_CARDRETURNACC PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CARDRETURNACC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CARDRETURNACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CARDRETURNACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CARDRETURNACC to Uopsett_B_SZ,Ucrapp_B_SZ;


--企服卡可充值账户表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDOFFERACC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDOFFERACC (
    CARDNO                  CHAR(16)                        NOT NULL,
    OFFERMONEY              INT                             NOT NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    PASSWD                  CHAR(12)                            NULL,
    BEGINTIME               DATE                                NULL,
    ENDTIME                 DATE                                NULL,
    LASUPPLYMONEY           INT                                 NULL,
    LASUPPLYTIME            DATE                                NULL,
    TOTALSUPPLYTIMES        INT              DEFAULT 0          NULL,
    TOTALSUPPLYMONEY        INT              DEFAULT 0          NULL,
    LASTSUPPLYPOSNO         CHAR(6)                             NULL,
    LASTSUPPLYSAMNO         CHAR(12)                            NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_CARDOFFERACC PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CARDOFFERACC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CARDOFFERACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CARDOFFERACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CARDOFFERACC to Uopsett_B_SZ,Ucrapp_B_SZ;


--持卡人资料表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CUSTOMERREC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CUSTOMERREC (
    CARDNO                  CHAR(16)                        NOT NULL,
    CUSTNAME                VARCHAR2(200)                       NULL,
    CUSTSEX                 VARCHAR2(2)                         NULL,
    CUSTBIRTH               VARCHAR2(8)                         NULL,
    PAPERTYPECODE           VARCHAR2(2)                         NULL,
    PAPERNO                 VARCHAR2(200)                       NULL,
    CUSTADDR                VARCHAR2(600)                       NULL,
    CUSTPOST                VARCHAR2(6)                         NULL,
    CUSTPHONE               VARCHAR2(200)                       NULL,
    CUSTEMAIL               VARCHAR2(30)                        NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_CUSTOMERREC PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CUSTOMERREC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CUSTOMERREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CUSTOMERREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CUSTOMERREC to Uopsett_B_SZ,Ucrapp_B_SZ;


--持卡人资料历史表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TH_F_CUSTOMERREC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TH_F_CUSTOMERREC (
    CARDNO                  CHAR(16)                        NOT NULL,
    UPDATETIME              DATE                            NOT NULL,
    CUSTNAME                VARCHAR2(50)                        NULL,
    CUSTSEX                 VARCHAR2(2)                         NULL,
    CUSTBIRTH               VARCHAR2(8)                         NULL,
    PAPERTYPECODE           VARCHAR2(2)                         NULL,
    PAPERNO                 VARCHAR2(20)                        NULL,
    CUSTADDR                VARCHAR2(50)                        NULL,
    CUSTPOST                VARCHAR2(6)                         NULL,
    CUSTPHONE               VARCHAR2(40)                        NULL,
    CUSTEMAIL               VARCHAR2(30)                        NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TH_F_CUSTOMERREC PRIMARY KEY(CARDNO, UPDATETIME)
)tablespace TBSdata_B_SZ
/


grant Select on TH_F_CUSTOMERREC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TH_F_CUSTOMERREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TH_F_CUSTOMERREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TH_F_CUSTOMERREC to Uopsett_B_SZ,Ucrapp_B_SZ;


--市民卡资料表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CITIZENREC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CITIZENREC (
    CARDNO                  CHAR(16)                        NOT NULL,
    CARDSFZ                 VARCHAR2(18)                        NULL,
    CARDXM                  VARCHAR2(30)                        NULL,
    XB                      CHAR(1)                             NULL,
    YHHM                    VARCHAR2(20)                        NULL,
    SBHM                    VARCHAR2(20)                        NULL,
    YBGRZH                  VARCHAR2(24)                        NULL,
    MAKEDATE                DATE                                NULL,
    ZTBM                    CHAR(2)                             NULL,
    STSJ                    DATE                                NULL,
    CARDDW                  VARCHAR2(64)                        NULL,
    LSTATUS                 CHAR(1)                         NOT NULL,
    LDNO                    NUMERIC                             NULL,
    LDDATE                  DATE                                NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    RSRV1                   VARCHAR2(30)                        NULL,
    RSRV2                   VARCHAR2(30)                        NULL,
    RSRV3                   DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_CITIZENREC PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CITIZENREC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CITIZENREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CITIZENREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CITIZENREC to Uopsett_B_SZ,Ucrapp_B_SZ;


--市民卡资料历史表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TH_F_CITIZENREC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TH_F_CITIZENREC (
    CARDNO                  CHAR(16)                        NOT NULL,
    UPDATETIME              DATE                            NOT NULL,
    CARDSFZ                 VARCHAR2(18)                        NULL,
    CARDXM                  VARCHAR2(30)                        NULL,
    XB                      CHAR(1)                             NULL,
    YHHM                    VARCHAR2(20)                        NULL,
    SBHM                    VARCHAR2(20)                        NULL,
    YBGRZH                  VARCHAR2(24)                        NULL,
    MAKEDATE                DATE                                NULL,
    ZTBM                    CHAR(2)                             NULL,
    STSJ                    DATE                                NULL,
    CARDDW                  VARCHAR2(64)                        NULL,
    LDNO                    NUMERIC                             NULL,
    LDDATE                  DATE                                NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    RSRV1                   VARCHAR2(30)                        NULL,
    RSRV2                   VARCHAR2(30)                        NULL,
    RSRV3                   DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TH_F_CITIZENREC PRIMARY KEY(CARDNO, UPDATETIME)
)tablespace TBSdata_B_SZ
/


grant Select on TH_F_CITIZENREC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TH_F_CITIZENREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TH_F_CITIZENREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TH_F_CITIZENREC to Uopsett_B_SZ,Ucrapp_B_SZ;


--集团客户-企服卡对应关系表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_GROUP_CARD CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_GROUP_CARD (
    CARDNO                  CHAR(16)                        NOT NULL,
    CORPNO                  CHAR(4)                         NOT NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_GROUP_CARD PRIMARY KEY(CARDNO, CORPNO)
)tablespace TBSdata_B_SZ
/


grant Select on TD_GROUP_CARD to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TD_GROUP_CARD to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TD_GROUP_CARD to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TD_GROUP_CARD to Uopsett_B_SZ,Ucrapp_B_SZ;


--集团客户资料表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_GROUP_CUSTOMER CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_GROUP_CUSTOMER (
    CORPCODE                CHAR(4)                         NOT NULL,
    CORPNAME                VARCHAR2(50)                    NOT NULL,
    LINKMAN                 VARCHAR2(10)                        NULL,
    CORPADD                 VARCHAR2(100)                       NULL,
    CORPPHONE               VARCHAR2(40)                        NULL,
    CORPEMAIL               VARCHAR2(50)                        NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    SERMANAGERCODE          CHAR(6)                             NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_GROUP_CUSTOMER PRIMARY KEY(CORPCODE)
)tablespace TBSdata_B_SZ
/


grant Select on TD_GROUP_CUSTOMER to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TD_GROUP_CUSTOMER to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TD_GROUP_CUSTOMER to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TD_GROUP_CUSTOMER to Uopsett_B_SZ,Ucrapp_B_SZ;


--业务功能关联表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDUSEAREA CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDUSEAREA (
    CARDNO                  CHAR(16)                        NOT NULL,
    FUNCTIONTYPE            CHAR(2)                         NOT NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    ENDTIME                 CHAR(8)                             NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    CONSTRAINT PK_TF_F_CARDUSEAREA PRIMARY KEY(CARDNO, FUNCTIONTYPE)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CARDUSEAREA to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CARDUSEAREA to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CARDUSEAREA to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CARDUSEAREA to Uopsett_B_SZ,Ucrapp_B_SZ;


--IC卡月票计次账户备份表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TB_F_CARDCOUNTACC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TB_F_CARDCOUNTACC (
    CARDNO                  CHAR(16)                        NOT NULL,
    REUSEDATE               DATE                            NOT NULL,
    APPTYPE                 CHAR(2)                             NULL,
    ASSIGNEDAREA            CHAR(2)                             NULL,
    APPTIME                 DATE                                NULL,
    APPSTAFFNO              CHAR(6)                             NULL,
    LASTAUDIT               CHAR(8)                             NULL,
    LASTAUDITTIME           DATE                                NULL,
    LASTAUDITSTAFFNO        CHAR(6)                             NULL,
    USETAG                  CHAR(1)                             NULL,
    ENDTIME                 CHAR(8)                             NULL,
    TOTALTIMES              INT                                 NULL,
    SPARETIMES              INT                                 NULL,
    TOTALCOUNT              INT                                 NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TB_F_CARDCOUNTACC PRIMARY KEY(CARDNO, REUSEDATE)
)tablespace TBSdata_B_SZ
/


grant Select on TB_F_CARDCOUNTACC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TB_F_CARDCOUNTACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TB_F_CARDCOUNTACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TB_F_CARDCOUNTACC to Uopsett_B_SZ,Ucrapp_B_SZ;


--IC卡资料备份表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TB_F_CARDREC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TB_F_CARDREC (
    CARDNO                  CHAR(16)                        NOT NULL,
    REUSEDATE               DATE                            NOT NULL,
    ASN                     CHAR(16)                            NULL,
    CARDTYPECODE            CHAR(2)                             NULL,
    CARDSURFACECODE         CHAR(4)                             NULL,
    CARDMANUCODE            CHAR(2)                             NULL,
    CARDCHIPTYPECODE        CHAR(2)                             NULL,
    APPTYPECODE             CHAR(2)                             NULL,
    APPVERNO                CHAR(2)                             NULL,
    DEPOSIT                 INT                                 NULL,
    CARDCOST                INT                                 NULL,
    PRESUPPLYMONEY          INT                                 NULL,
    CUSTRECTYPECODE         CHAR(1)                             NULL,
    SELLTIME                DATE                                NULL,
    SELLCHANNELCODE         CHAR(2)                             NULL,
    DEPARTNO                CHAR(4)                             NULL,
    STAFFNO                 CHAR(6)                             NULL,
    CARDSTATE               CHAR(2)                         NOT NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    SERSTARTTIME            DATE                                NULL,
    SERTAKETAG              CHAR(1)                             NULL,
    SERVICEMONEY            INT                                 NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TB_F_CARDREC PRIMARY KEY(CARDNO, REUSEDATE)
)tablespace TBSdata_B_SZ
/


grant Select on TB_F_CARDREC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TB_F_CARDREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TB_F_CARDREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TB_F_CARDREC to Uopsett_B_SZ,Ucrapp_B_SZ;


--IC卡电子钱包账户备份表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TB_F_CARDEWALLETACC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TB_F_CARDEWALLETACC (
    CARDNO                  CHAR(16)                        NOT NULL,
    REUSEDATE               DATE                            NOT NULL,
    CARDACCMONEY            INT                                 NULL,
    USETAG                  CHAR(1)                             NULL,
    CREDITSTATECODE         CHAR(2)                             NULL,
    CREDITSTACHANGETIME     DATE                                NULL,
    CREDITCONTROLCODE       CHAR(2)                             NULL,
    CREDITCOLCHANGETIME     DATE                                NULL,
    ACCSTATECODE            CHAR(2)                             NULL,
    CONSUMEREALMONEY        INT                                 NULL,
    SUPPLYREALMONEY         INT                                 NULL,
    TOTALCONSUMETIMES       INT              DEFAULT 0          NULL,
    TOTALSUPPLYTIMES        INT              DEFAULT 0          NULL,
    TOTALCONSUMEMONEY       INT              DEFAULT 0          NULL,
    TOTALSUPPLYMONEY        INT              DEFAULT 0          NULL,
    FIRSTCONSUMETIME        DATE                                NULL,
    LASTCONSUMETIME         DATE                                NULL,
    FIRSTSUPPLYTIME         DATE                                NULL,
    LASTSUPPLYTIME          DATE                                NULL,
    OFFLINECARDTRADENO      CHAR(4)                             NULL,
    ONLINECARDTRADENO       CHAR(4)                             NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TB_F_CARDEWALLETACC PRIMARY KEY(CARDNO, REUSEDATE)
)tablespace TBSdata_B_SZ
/


grant Select on TB_F_CARDEWALLETACC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TB_F_CARDEWALLETACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TB_F_CARDEWALLETACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TB_F_CARDEWALLETACC to Uopsett_B_SZ,Ucrapp_B_SZ;


--苏州园林年卡账户表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TB_F_CARDPARKACC_SZ CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TB_F_CARDPARKACC_SZ (
    CARDNO                  CHAR(16)                        NOT NULL,
    REUSEDATE               DATE                            NOT NULL,
    CURRENTOPENYEAR         CHAR(6)                             NULL,
    CARDTIMES               INT                                 NULL,
    ENDDATE                 CHAR(8)                             NULL,
    CURRENTPAYTIME          DATE                                NULL,
    CURRENTPAYFEE           INT                                 NULL,
    TOTALTIMES              INT                                 NULL,
    SPARETIMES              INT                                 NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    RERVINT                 INT                                 NULL,
    RERVCHAR                VARCHAR2(20)                        NULL,
    RERVSTRING              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TB_F_CARDPARKACC_SZ PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TB_F_CARDPARKACC_SZ to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TB_F_CARDPARKACC_SZ to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TB_F_CARDPARKACC_SZ to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TB_F_CARDPARKACC_SZ to Uopsett_B_SZ,Ucrapp_B_SZ;


--苏州休闲年卡账户备份表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TB_F_CARDXXPARKACC_SZ CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TB_F_CARDXXPARKACC_SZ (
    CARDNO                  CHAR(16)                        NOT NULL,
    REUSEDATE               DATE                            NOT NULL,
    PACKAGETYPECODE         CHAR(2)                             NULL,
    CURRENTOPENYEAR         CHAR(6)                             NULL,
    CARDTIMES               INT                                 NULL,
    ENDDATE                 CHAR(8)                             NULL,
    CURRENTPAYTIME          DATE                                NULL,
    CURRENTPAYFEE           INT                                 NULL,
    TOTALTIMES              INT                                 NULL,
    SPARETIMES              INT                                 NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    RERVINT                 INT                                 NULL,
    RERVCHAR                VARCHAR2(20)                        NULL,
    RERVSTRING              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TB_F_CARDXXPARKACC_SZ PRIMARY KEY(CARDNO, REUSEDATE)
)tablespace TBSdata_B_SZ
/


grant Select on TB_F_CARDXXPARKACC_SZ to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TB_F_CARDXXPARKACC_SZ to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TB_F_CARDXXPARKACC_SZ to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TB_F_CARDXXPARKACC_SZ to Uopsett_B_SZ,Ucrapp_B_SZ;


--IC卡资金返还账户备份表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TB_F_CARDRETURNACC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TB_F_CARDRETURNACC (
    CARDNO                  CHAR(16)                        NOT NULL,
    REUSEDATE               DATE                            NOT NULL,
    TETURNMONEY             INT                             NOT NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    PASSWD                  CHAR(6)                             NULL,
    BEGINTIME               DATE                                NULL,
    ENDTIME                 DATE                                NULL,
    LASUPPLYMONEY           INT                                 NULL,
    LASUPPLYTIME            DATE                                NULL,
    TOTALRETURNTIMES        INT              DEFAULT 0          NULL,
    TOTALRETURNMONEY        INT              DEFAULT 0          NULL,
    LASTSUPPLYPOSNO         CHAR(6)                             NULL,
    LASTSUPPLYSAMNO         CHAR(12)                            NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TB_F_CARDRETURNACC PRIMARY KEY(CARDNO, REUSEDATE)
)tablespace TBSdata_B_SZ
/


grant Select on TB_F_CARDRETURNACC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TB_F_CARDRETURNACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TB_F_CARDRETURNACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TB_F_CARDRETURNACC to Uopsett_B_SZ,Ucrapp_B_SZ;


--企服卡可充值账户备份表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TB_F_CARDOFFERACC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TB_F_CARDOFFERACC (
    CARDNO                  CHAR(16)                        NOT NULL,
    REUSEDATE               DATE                            NOT NULL,
    OFFERMONEY              INT                             NOT NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    PASSWD                  CHAR(12)                            NULL,
    BEGINTIME               DATE                                NULL,
    ENDTIME                 DATE                                NULL,
    LASUPPLYMONEY           INT                                 NULL,
    LASUPPLYTIME            DATE                                NULL,
    TOTALSUPPLYTIMES        INT              DEFAULT 0          NULL,
    TOTALSUPPLYMONEY        INT              DEFAULT 0          NULL,
    LASTSUPPLYPOSNO         CHAR(6)                             NULL,
    LASTSUPPLYSAMNO         CHAR(12)                            NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TB_F_CARDOFFERACC PRIMARY KEY(CARDNO, REUSEDATE)
)tablespace TBSdata_B_SZ
/


grant Select on TB_F_CARDOFFERACC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TB_F_CARDOFFERACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TB_F_CARDOFFERACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TB_F_CARDOFFERACC to Uopsett_B_SZ,Ucrapp_B_SZ;


--持卡人资料备份表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TB_F_CUSTOMERREC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TB_F_CUSTOMERREC (
    CARDNO                  CHAR(16)                        NOT NULL,
    REUSEDATE               DATE                            NOT NULL,
    CUSTNAME                VARCHAR2(50)                        NULL,
    CUSTSEX                 VARCHAR2(2)                         NULL,
    CUSTBIRTH               VARCHAR2(8)                         NULL,
    PAPERTYPECODE           VARCHAR2(2)                         NULL,
    PAPERNO                 VARCHAR2(20)                        NULL,
    CUSTADDR                VARCHAR2(50)                        NULL,
    CUSTPOST                VARCHAR2(6)                         NULL,
    CUSTPHONE               VARCHAR2(40)                        NULL,
    CUSTEMAIL               VARCHAR2(30)                        NULL,
    USETAG                  CHAR(1)                             NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TB_F_CUSTOMERREC PRIMARY KEY(CARDNO, REUSEDATE)
)tablespace TBSdata_B_SZ
/


grant Select on TB_F_CUSTOMERREC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TB_F_CUSTOMERREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TB_F_CUSTOMERREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TB_F_CUSTOMERREC to Uopsett_B_SZ,Ucrapp_B_SZ;


--市民卡资料备份表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TB_F_CITIZENREC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TB_F_CITIZENREC (
    CARDNO                  CHAR(16)                        NOT NULL,
    REUSEDATE               DATE                            NOT NULL,
    CARDSFZ                 VARCHAR2(18)                        NULL,
    CARDXM                  VARCHAR2(30)                        NULL,
    XB                      CHAR(1)                             NULL,
    YHHM                    VARCHAR2(20)                        NULL,
    SBHM                    VARCHAR2(20)                        NULL,
    YBGRZH                  VARCHAR2(24)                        NULL,
    MAKEDATE                DATE                                NULL,
    ZTBM                    CHAR(2)                             NULL,
    STSJ                    DATE                                NULL,
    CARDDW                  VARCHAR2(64)                        NULL,
    LSTATUS                 CHAR(1)                             NULL,
    LDNO                    NUMERIC                             NULL,
    LDDATE                  DATE                                NULL,
    USETAG                  CHAR(1)                             NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    RSRV1                   VARCHAR2(30)                        NULL,
    RSRV2                   VARCHAR2(30)                        NULL,
    RSRV3                   DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TB_F_CITIZENREC PRIMARY KEY(CARDNO, REUSEDATE)
)tablespace TBSdata_B_SZ
/


grant Select on TB_F_CITIZENREC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TB_F_CITIZENREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TB_F_CITIZENREC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TB_F_CITIZENREC to Uopsett_B_SZ,Ucrapp_B_SZ;


--特殊调帐可充值账户表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_SPEADJUSTOFFERACC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_SPEADJUSTOFFERACC (
    CARDNO                  CHAR(16)                        NOT NULL,
    OFFERMONEY              INT                             NOT NULL,
    TOTALSUPPLYTIMES        INT              DEFAULT 0          NULL,
    TOTALSUPPLYMONEY        INT              DEFAULT 0          NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    CONSTRAINT PK_TF_SPEADJUSTOFFERACC PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_SPEADJUSTOFFERACC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_SPEADJUSTOFFERACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_SPEADJUSTOFFERACC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_SPEADJUSTOFFERACC to Uopsett_B_SZ,Ucrapp_B_SZ;


--卡号照片对应关系表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDPARKPHOTO_SZ CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDPARKPHOTO_SZ (
    CARDNO                  CHAR(16)                        NOT NULL,
    PICTURE                 BLOB                                NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    CONSTRAINT PK_TF_F_CARDPARKPHOTO_SZ PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CARDPARKPHOTO_SZ to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CARDPARKPHOTO_SZ to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CARDPARKPHOTO_SZ to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CARDPARKPHOTO_SZ to Uopsett_B_SZ,Ucrapp_B_SZ;


--卡号照片对应关系历史表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TB_F_CARDPARKPHOTO_SZ CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TB_F_CARDPARKPHOTO_SZ (
    CARDNO                  CHAR(16)                        NOT NULL,
    PICTURE                 BLOB                            NOT NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL
)tablespace TBSdata_B_SZ
/


grant Select on TB_F_CARDPARKPHOTO_SZ to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TB_F_CARDPARKPHOTO_SZ to Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Update on TB_F_CARDPARKPHOTO_SZ to Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Delete on TB_F_CARDPARKPHOTO_SZ to Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;


--休闲卡号照片对应关系表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDXXPARKPHOTO_SZ CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDXXPARKPHOTO_SZ (
    CARDNO                  CHAR(16)                        NOT NULL,
    PICTURE                 BLOB                                NULL,
    CONSTRAINT PK_TF_F_CARDXXPARKPHOTO_SZ PRIMARY KEY(CARDNO)
)
/




--苏州园林年卡黑名单表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDPARKBLACKLIST CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDPARKBLACKLIST (
    PAPERNO                 VARCHAR2(200)                   NOT NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_CARDPARKBLACKLIST PRIMARY KEY(PAPERNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CARDPARKBLACKLIST to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CARDPARKBLACKLIST to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CARDPARKBLACKLIST to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CARDPARKBLACKLIST to Uopsett_B_SZ,Ucrapp_B_SZ;


--苏州园林年卡白名单表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDPARKWHITELIST CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDPARKWHITELIST (
    PAPERNO                 VARCHAR2(200)                   NOT NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_CARDPARKWHITELIST PRIMARY KEY(PAPERNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_CARDPARKWHITELIST to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_CARDPARKWHITELIST to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_CARDPARKWHITELIST to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_CARDPARKWHITELIST to Uopsett_B_SZ,Ucrapp_B_SZ;



