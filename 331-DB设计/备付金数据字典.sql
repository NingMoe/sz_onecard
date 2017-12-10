--备付金任务表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_TASK CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_TASK (
    BFJDATE                 CHAR(8)                         NOT NULL,
    TASKSTATE               CHAR(1)                             NULL,
    ISOUTMATCH              CHAR(1)                             NULL,
    OUTMATCHSTAFFNO         CHAR(6)                             NULL,
    OUTMATCHDATE            DATE                                NULL,
    ISINMATCH               CHAR(1)                             NULL,
    INMATCHSTAFFNO          CHAR(6)                             NULL,
    INMATCHDATE             DATE                                NULL,
    ISREPORT                CHAR(1)                             NULL,
    REPORTDATE              DATE                                NULL,
    BANKLESS                INTEGER                             NULL,
    BUSINESSLESS            INTEGER                             NULL,
    CONSTRAINT PK_TF_F_BFJ_TASK PRIMARY KEY(BFJDATE)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_TASK to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_TASK to Uopsett_B_SZ;
grant Update on TF_F_BFJ_TASK to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_TASK to Uopsett_B_SZ;


--备付金银行编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_BFJ_BANK CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_BFJ_BANK (
    SYSTEMCODE              CHAR(4)                         NOT NULL,
    SYSTEMNAME              VARCHAR2(100)                   NOT NULL,
    FTPUSERNAME             VARCHAR2(100)                       NULL,
    FTPPASSWORD             VARCHAR2(100)                       NULL,
    FTPUPLOADIP             VARCHAR2(100)                       NULL,
    FTPUPLOADPATH           VARCHAR2(100)                       NULL,
    FTPDOWNLOADPATH         VARCHAR2(100)                       NULL,
    ISCOOPERATIVE           CHAR(1)                             NULL,
    ISCUSTODYBANK           CHAR(1)                             NULL,
    ACCOUNTNAME             VARCHAR2(100)                       NULL,
    ACCOUNT                 VARCHAR2(100)                       NULL,
    BANKCODE                CHAR(1)                             NULL,
    CONSTRAINT PK_TD_M_BFJ_BANK PRIMARY KEY(SYSTEMCODE)
)tablespace TBSsett_B_SZ
/


grant Select on TD_M_BFJ_BANK to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TD_M_BFJ_BANK to Uopsett_B_SZ;
grant Update on TD_M_BFJ_BANK to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TD_M_BFJ_BANK to Uopsett_B_SZ;


--备付金同步记录表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_BFJ_SYNC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_BFJ_SYNC (
    TRADEID                 CHAR(16)                        NOT NULL,
    SYNCTYPECODE            CHAR(4)                         NOT NULL,
    SYNCCODE                CHAR(1)                             NULL,
    SYNCHOME                CHAR(4)                             NULL,
    SYNCCLIENT              CHAR(4)                             NULL,
    SYNERRINFO              VARCHAR2(512)                       NULL,
    SYNCTIME                DATE                                NULL,
    FILEPATH                VARCHAR2(512)                       NULL,
    ISUPLOAD                CHAR(1)                             NULL,
    FILECODE                CHAR(1)                             NULL,
    FILETIME                DATE                                NULL,
    FILEERRORINFO           VARCHAR2(512)                       NULL,
    FILETYPE                CHAR(1)                             NULL,
    RSRV1                   VARCHAR2(120)                       NULL,
    RSRV2                   VARCHAR2(120)                       NULL,
    CONSTRAINT PK_TF_B_BFJ_SYNC PRIMARY KEY(TRADEID)
)tablespace TBSsett_B_SZ
/


grant Select on TF_B_BFJ_SYNC to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_B_BFJ_SYNC to Uopsett_B_SZ;
grant Update on TF_B_BFJ_SYNC to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_B_BFJ_SYNC to Uopsett_B_SZ;


--银行备付金信息明细表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_OBAB CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_OBAB (
    TRADEID                 VARCHAR2(30)                    NOT NULL,
    FILEDATE                CHAR(8)                         NOT NULL,
    BANKCODE                CHAR(4)                         NOT NULL,
    BANKNO                  VARCHAR2(14)                        NULL,
    BANKACCOUNT             VARCHAR2(120)                       NULL,
    BFJBALANCE              INTEGER                             NULL,
    FEE                     INTEGER                             NULL,
    BANKLESS                INTEGER                             NULL,
    BUSINESSLESS            INTEGER                             NULL,
    CLEARDATE               CHAR(8)                             NULL,
    ISREPEAT                CHAR(1)                             NULL,
    UPDATETIME              DATE                                NULL,
    BANKLESSCURRENT         INTEGER                             NULL,
    BUSINESSLESSCURRENT     INTEGER                             NULL,
    SYNCSTATES              CHAR(1)                             NULL,
    RSRV1                   VARCHAR2(120)                       NULL,
    CONSTRAINT PK_TF_F_BFJ_OBAB PRIMARY KEY(TRADEID, FILEDATE)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_OBAB to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_OBAB to Uopsett_B_SZ;
grant Update on TF_F_BFJ_OBAB to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_OBAB to Uopsett_B_SZ,Ucrapp_B_SZ;


--银行备付金交易明细表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_OCAB CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_OCAB (
    TRADEID                 VARCHAR2(30)                    NOT NULL,
    FILEDATE                CHAR(8)                         NOT NULL,
    BANKNAME                CHAR(4)                         NOT NULL,
    AGENCYID                VARCHAR2(20)                        NULL,
    BANKNO                  VARCHAR2(14)                        NULL,
    BANKACCOUNT             VARCHAR2(120)                       NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    OTHERBANK               VARCHAR2(50)                        NULL,
    OTHERUSERNAME           VARCHAR2(120)                       NULL,
    OTHERBANKACCOUNT        VARCHAR2(120)                       NULL,
    TRADECHARGE             INTEGER                             NULL,
    CURRENCY                CHAR(3)                             NULL,
    CLEARDATE               CHAR(8)                             NULL,
    TRADEMEG                VARCHAR2(120)                       NULL,
    AMOUNTTYPE              CHAR(1)                             NULL,
    RSRV1                   VARCHAR2(120)                       NULL,
    RSRV2                   VARCHAR2(120)                       NULL,
    RSRV3                   VARCHAR2(120)                       NULL,
    USEDMONEY               INTEGER                             NULL,
    LEFTMONEY               INTEGER                             NULL,
    ISNEEDMATCH             CHAR(1)                             NULL,
    CONSTRAINT PK_TF_F_BFJ_OCAB PRIMARY KEY(TRADEID, FILEDATE)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_BFJ_OCAB to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_OCAB to Uopsett_B_SZ;
grant Update on TF_F_BFJ_OCAB to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_OCAB to Uopsett_B_SZ,Ucrapp_B_SZ;


--银行备付金交易类型表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_BFJ_BANKTRADETYPE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_BFJ_BANKTRADETYPE (
    TRADETYPECODE           CHAR(2)                         NOT NULL,
    TRADENAME               VARCHAR2(50)                        NULL,
    TRADETYPECODE           CHAR(1)                         NOT NULL,
    CONSTRAINT PK_TD_M_BFJ_BANKTRADETYPE PRIMARY KEY(TRADETYPECODE)
)tablespace TBSdata_B_SZ
/


grant Select on TD_M_BFJ_BANKTRADETYPE to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TD_M_BFJ_BANKTRADETYPE to Uopsett_B_SZ;
grant Update on TD_M_BFJ_BANKTRADETYPE to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TD_M_BFJ_BANKTRADETYPE to Uopsett_B_SZ,Ucrapp_B_SZ;


--分分核对结果表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_ACT_CHK CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_ACT_CHK (
    TRADEID                 VARCHAR2(30)                    NOT NULL,
    FILEDATE                CHAR(8)                         NOT NULL,
    AGENCYID                VARCHAR2(20)                        NULL,
    BANKNO                  VARCHAR2(14)                        NULL,
    BANKACCOUNT             VARCHAR2(120)                       NULL,
    DEPOSITORYACCOUNT       VARCHAR2(32)                        NULL,
    CLEARDATE               CHAR(8)                             NULL,
    CURRENCY                CHAR(3)                             NULL,
    BALANCE                 INTEGER                             NULL,
    DEPOSITORYBALANCE       INTEGER                             NULL,
    CONSTRAINT PK_TF_F_BFJ_ACT_CHK PRIMARY KEY(TRADEID, FILEDATE)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_BFJ_ACT_CHK to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_ACT_CHK to Uopsett_B_SZ;
grant Update on TF_F_BFJ_ACT_CHK to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_ACT_CHK to Uopsett_B_SZ,Ucrapp_B_SZ;


--总分核对结果表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_TOL_CHK CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_TOL_CHK (
    TRADEID                 VARCHAR2(30)                    NOT NULL,
    FILEDATE                CHAR(8)                         NOT NULL,
    AGENCYID                VARCHAR2(20)                        NULL,
    CLEARDATE               CHAR(8)                             NULL,
    CURRENCY                CHAR(3)                             NULL,
    TOTALBALANCE            INTEGER                             NULL,
    ESCROWBALANCE           INTEGER                             NULL,
    ISCHECK                 CHAR(1)                             NULL,
    CONSTRAINT PK_TF_F_BFJ_TOL_CHK PRIMARY KEY(TRADEID, FILEDATE)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_BFJ_TOL_CHK to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_TOL_CHK to Uopsett_B_SZ;
grant Update on TF_F_BFJ_TOL_CHK to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_TOL_CHK to Uopsett_B_SZ,Ucrapp_B_SZ;


--系统业务账单表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_TRADERECORD CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_TRADERECORD (
    TRADEID                 CHAR(16)                        NOT NULL,
    TRADEDATE               DATE                            NOT NULL,
    SYSTRADEID              CHAR(16)                            NULL,
    NAME                    VARCHAR2(100)                       NULL,
    CUSTOMERCODE            VARCHAR2(30)                        NULL,
    AMOUNTTYPE              CHAR(1)                         NOT NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    TRADEMONEY              INTEGER                             NULL,
    FEE                     INTEGER                             NULL,
    BFJTRADETYPECODE        CHAR(2)                             NULL,
    OTHERBANK               CHAR(4)                             NULL,
    OTHERUSERNAME           VARCHAR2(120)                       NULL,
    OTHERBANKACCOUNT        VARCHAR2(120)                       NULL,
    ISCASH                  CHAR(1)                             NULL,
    STAFFNO                 CHAR(6)                             NULL,
    DEPARTID                CHAR(4)                             NULL,
    USEDMONEY               INTEGER                             NULL,
    LEFTMONEY               INTEGER                             NULL,
    ISNEEDMATCH             CHAR(1)                             NULL,
    ACCOUNT                 VARCHAR2(120)                       NULL,
    SYNCSTATES              CHAR(1)                             NULL,
    REMARK                  VARCHAR2(200)                       NULL,
    ISFINANCEIN             CHAR(1)          DEFAULT '0'        NULL,
    CONSTRAINT PK_TF_F_BFJ_TRADERECORD PRIMARY KEY(TRADEID)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_BFJ_TRADERECORD to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_BFJ_TRADERECORD to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_BFJ_TRADERECORD to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_TRADERECORD to Uopsett_B_SZ,Ucrapp_B_SZ;


--系统业务交易类型表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_TRADETYPE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_TRADETYPE (
    TRADETYPECODE           CHAR(2)                         NOT NULL,
    TRADETYPE               VARCHAR2(50)                        NULL,
    SLOPE                   FLOAT                               NULL,
    OFFSET                  FLOAT                               NULL,
    CONSTRAINT PK_TF_F_BFJ_TRADETYPE PRIMARY KEY(TRADETYPECODE)
)tablespace TBSdata_B_SZ
/


grant Select on TF_F_BFJ_TRADETYPE to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_F_BFJ_TRADETYPE to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_BFJ_TRADETYPE to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_TRADETYPE to Uopsett_B_SZ,Ucrapp_B_SZ;


--系统业务账单调账台账表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_BFJ_ADJUSTTRADE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_BFJ_ADJUSTTRADE (
    TRADEID                 CHAR(16)                        NOT NULL,
    OPERATEDATE             DATE                            NOT NULL,
    OPERATESTAFFNO          CHAR(6)          DEFAULT 'CHAR(6)'    NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    CONSTRAINT PK_TF_B_BFJ_ADJUSTTRADE PRIMARY KEY(TRADEID)
)tablespace TBSsett_B_SZ
/


grant Select on TF_B_BFJ_ADJUSTTRADE to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_B_BFJ_ADJUSTTRADE to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_B_BFJ_ADJUSTTRADE to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_B_BFJ_ADJUSTTRADE to Uopsett_B_SZ,Ucrapp_B_SZ;


--业务数据修改台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_BFJ_TRADEAMEND CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_BFJ_TRADEAMEND (
    TRADEID                 CHAR(16)                        NOT NULL,
    SYSTEMTRADEID           CHAR(16)                            NULL,
    PREMONEY                INT                                 NULL,
    NEXTMONEY               INT                                 NULL,
    UPDATETIME              DATE                                NULL,
    STAFFNO                 CHAR(6)                             NULL,
    CONSTRAINT PK_TF_B_BFJ_TRADEAMEND PRIMARY KEY(TRADEID)
)tablespace TBSsett_B_SZ
/


grant Select on TF_B_BFJ_TRADEAMEND to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_B_BFJ_TRADEAMEND to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_B_BFJ_TRADEAMEND to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_B_BFJ_TRADEAMEND to Uopsett_B_SZ,Ucrapp_B_SZ;


--账单关联表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_BANKRELATION CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_BANKRELATION (
    TRADEID                 CHAR(16)                        NOT NULL,
    BANKTRADEID             CHAR(16)                            NULL,
    SYSTEMTRADEID           CHAR(16)                            NULL,
    MONEY                   INT                                 NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    ORDERNO                 CHAR(16)                            NULL,
    CONSTRAINT PK_TF_F_BFJ_BANKRELATION PRIMARY KEY(TRADEID)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_BANKRELATION to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_BANKRELATION to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_BFJ_BANKRELATION to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_BANKRELATION to Uopsett_B_SZ,Ucrapp_B_SZ;


--账单关联台账表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_BFJ_CHECK CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_BFJ_CHECK (
    TRADEID                 CHAR(16)                        NOT NULL,
    BANKTRADEID             VARCHAR2(30)                        NULL,
    SYSTEMTRADEID           CHAR(16)                            NULL,
    TRADECODE               CHAR(1)                             NULL,
    MONEY                   INT                             NOT NULL,
    BANKUSEDMONEY           INT              DEFAULT 0      NOT NULL,
    BANKLEFTMONEY           INT                             NOT NULL,
    TRADEUSEDMONEY          INT              DEFAULT 0      NOT NULL,
    TRADELEFTMONEY          INT                             NOT NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATETIME             DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   VARCHAR2(20)                        NULL,
    CONSTRAINT PK_TF_B_BFJ_CHECK PRIMARY KEY(TRADEID)
)tablespace TBSsett_B_SZ
/


grant Select on TF_B_BFJ_CHECK to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_B_BFJ_CHECK to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_B_BFJ_CHECK to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_B_BFJ_CHECK to Uopsett_B_SZ,Ucrapp_B_SZ;


--不匹配账单关联表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_UNBANKRELATION CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_UNBANKRELATION (
    TRADEID                 CHAR(16)                        NOT NULL,
    POSBANKTRADEID          VARCHAR2(30)                        NULL,
    NETABANKTRADEID         VARCHAR2(30)                        NULL,
    MONEY                   INT                                 NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    CONSTRAINT PK_TF_F_BFJ_UNBANKRELATION PRIMARY KEY(TRADEID)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_UNBANKRELATION to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_UNBANKRELATION to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_BFJ_UNBANKRELATION to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_UNBANKRELATION to Uopsett_B_SZ,Ucrapp_B_SZ;


--不匹配账单关联台账表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_BFJ_UNCHECK CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_BFJ_UNCHECK (
    TRADEID                 CHAR(16)                        NOT NULL,
    POSBANKTRADEID          VARCHAR2(30)                        NULL,
    NETABANKTRADEID         VARCHAR2(30)                        NULL,
    TRADECODE               CHAR(1)                             NULL,
    MONEY                   INT                             NOT NULL,
    POSBANKUSEDMONEY        INT              DEFAULT 0      NOT NULL,
    POSBANKLEFTMONEY        INT                             NOT NULL,
    NETATRADEUSEDMONEY      INT              DEFAULT 0      NOT NULL,
    NETATRADELEFTMONEY      INT                             NOT NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATETIME             DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   VARCHAR2(20)                        NULL,
    CONSTRAINT PK_TF_B_BFJ_UNCHECK PRIMARY KEY(TRADEID)
)tablespace TBSsett_B_SZ
/


grant Select on TF_B_BFJ_UNCHECK to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_B_BFJ_UNCHECK to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_B_BFJ_UNCHECK to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_B_BFJ_UNCHECK to Uopsett_B_SZ,Ucrapp_B_SZ;


--网店代办业务登记表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_STAFFAGENTTRADE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_STAFFAGENTTRADE (
    TRADEID                 CHAR(16)                        NOT NULL,
    TRADETYPECODE           CHAR(2)                         NOT NULL,
    TRADEMONEY              INT                                 NULL,
    OPERATEDEPTNO           CHAR(4)                         NOT NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATETIME             DATE                                NULL,
    CONSTRAINT PK_TF_F_BFJ_STAFFAGENTTRADE PRIMARY KEY(TRADEID)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_STAFFAGENTTRADE to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_STAFFAGENTTRADE to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_BFJ_STAFFAGENTTRADE to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_STAFFAGENTTRADE to Uopsett_B_SZ,Ucrapp_B_SZ;


--网店解款确认表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_STAFFCONFIRM CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_STAFFCONFIRM (
    TRADEID                 CHAR(16)                        NOT NULL,
    CONFIRMDATE             CHAR(8)                         NOT NULL,
    DEPTID                  CHAR(4)                         NOT NULL,
    CONFIRMMONEY            INT                             NOT NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATETIME             DATE                                NULL,
    CONSTRAINT PK_TF_F_BFJ_STAFFCONFIRM PRIMARY KEY(TRADEID)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_STAFFCONFIRM to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_STAFFCONFIRM to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_BFJ_STAFFCONFIRM to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_STAFFCONFIRM to Uopsett_B_SZ,Ucrapp_B_SZ;


--网点银行关联表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_STAFFRELATION CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_STAFFRELATION (
    DEPTID                  CHAR(4)                         NOT NULL,
    BFJBANKCODE             CHAR(4)                         NOT NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATETIME             DATE                                NULL,
    CONSTRAINT PK_TF_F_BFJ_STAFFRELATION PRIMARY KEY(DEPTID)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_STAFFRELATION to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_STAFFRELATION to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_BFJ_STAFFRELATION to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_STAFFRELATION to Uopsett_B_SZ,Ucrapp_B_SZ;


--代理充值-银行手续费对应关系表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_DLBALUNIT_FEESCHEME CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_DLBALUNIT_FEESCHEME (
    ID                      CHAR(8)                         NOT NULL,
    BALUNITNO               CHAR(8)                         NOT NULL,
    COMSCHEMENO             CHAR(8)                         NOT NULL,
    BEGINTIME               DATE                                NULL,
    ENDTIME                 DATE                                NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                            NOT NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_DLBALUNIT_FEESCHEME PRIMARY KEY(ID)
)tablespace TBSsett_B_SZ
/


grant Select on TD_DLBALUNIT_FEESCHEME to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TD_DLBALUNIT_FEESCHEME to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TD_DLBALUNIT_FEESCHEME to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TD_DLBALUNIT_FEESCHEME to Uopsett_B_SZ,Ucrapp_B_SZ;


--手续费编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_FEE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_FEE (
    FEERULENO               CHAR(8)                         NOT NULL,
    SLOPE                   FLOAT                           NOT NULL,
    OFFSET                  FLOAT                           NOT NULL,
    LOWERBOUND              INT                             NOT NULL,
    UPPERBOUND              INT                             NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_FEE PRIMARY KEY(FEERULENO)
)tablespace TBSsett_B_SZ
/


grant Select on TF_FEE to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_FEE to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_FEE to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_FEE to Uopsett_B_SZ,Ucrapp_B_SZ;


--备付金入金业务明细表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_REPORT1 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_REPORT1 (
    BFJDATE                 CHAR(8)                         NOT NULL,
    BANKCODE                CHAR(4)                         NOT NULL,
    C1                      NUMBER(12,6)                        NULL,
    C2                      NUMBER(12,6)                        NULL,
    C3                      NUMBER(12,6)                        NULL,
    C4                      NUMBER(12,6)                        NULL,
    C5                      NUMBER(12,6)                        NULL,
    C6                      NUMBER(12,6)                        NULL,
    C7                      NUMBER(12,6)                        NULL,
    C8                      NUMBER(12,6)                        NULL,
    C9                      NUMBER(12,6)                        NULL,
    C10                     NUMBER(12,6)                        NULL,
    C11                     NUMBER(12,6)                        NULL,
    C12                     NUMBER(12,6)                        NULL,
    C13                     NUMBER(12,6)                        NULL,
    C14                     NUMBER(12,6)                        NULL,
    CONSTRAINT PK_TF_F_BFJ_REPORT1 PRIMARY KEY(BFJDATE, BANKCODE)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_REPORT1 to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_REPORT1 to Ucrapp_B_SZ;
grant Update on TF_F_BFJ_REPORT1 to Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_REPORT1 to Ucrapp_B_SZ;


--备付金出金业务明细表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_REPORT2 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_REPORT2 (
    BFJDATE                 CHAR(8)                         NOT NULL,
    C1                      NUMBER(12,6)                        NULL,
    C2                      NUMBER(12,6)                        NULL,
    C3                      NUMBER(12,6)                        NULL,
    C4                      NUMBER(12,6)                        NULL,
    C5                      NUMBER(12,6)                        NULL,
    C6                      NUMBER(12,6)                        NULL,
    C7                      NUMBER(12,6)                        NULL,
    C8                      NUMBER(12,6)                        NULL,
    C9                      NUMBER(12,6)                        NULL,
    CONSTRAINT PK_TF_F_BFJ_REPORT2 PRIMARY KEY(BFJDATE)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_REPORT2 to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_REPORT2 to Ucrapp_B_SZ;
grant Update on TF_F_BFJ_REPORT2 to Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_REPORT2 to Ucrapp_B_SZ;


--备付金业务实际出金明细表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_REPORT3 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_REPORT3 (
    BFJDATE                 CHAR(8)                         NOT NULL,
    BANKCODE                CHAR(4)                         NOT NULL,
    C1                      VARCHAR2(50)                        NULL,
    C2                      VARCHAR2(50)                        NULL,
    C3                      VARCHAR2(50)                        NULL,
    C4                      NUMBER(12,6)                        NULL,
    CONSTRAINT PK_TF_F_BFJ_REPORT3 PRIMARY KEY(BFJDATE, BANKCODE)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_REPORT3 to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_REPORT3 to Ucrapp_B_SZ;
grant Update on TF_F_BFJ_REPORT3 to Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_REPORT3 to Ucrapp_B_SZ;


--资金账户转账业务统计表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_REPORT4 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_REPORT4 (
    BFJDATE                 CHAR(8)                         NOT NULL,
    C1                      NUMBER(12,6)                        NULL,
    C2                      NUMBER(12,6)                        NULL,
    C3                      NUMBER(12,6)                        NULL,
    CONSTRAINT PK_TF_F_BFJ_REPORT4 PRIMARY KEY(BFJDATE)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_REPORT4 to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_REPORT4 to Ucrapp_B_SZ;
grant Update on TF_F_BFJ_REPORT4 to Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_REPORT4 to Ucrapp_B_SZ;


--客户资金账户余额统计表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_REPORT5 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_REPORT5 (
    BFJDATE                 CHAR(8)                         NOT NULL,
    BANKCODE                CHAR(4)                         NOT NULL,
    C1                      NUMBER(12,6)                        NULL,
    C2                      NUMBER(12,6)                        NULL,
    C3                      NUMBER(12,6)                        NULL,
    C4                      NUMBER(12,6)                        NULL,
    C5                      NUMBER(12,6)                        NULL,
    C6                      NUMBER(12,6)                        NULL,
    CONSTRAINT PK_TF_F_BFJ_REPORT5 PRIMARY KEY(BFJDATE, BANKCODE)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_REPORT5 to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_REPORT5 to Ucrapp_B_SZ;
grant Update on TF_F_BFJ_REPORT5 to Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_REPORT5 to Ucrapp_B_SZ;


--备付金银行特殊业务明细表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_REPORT6 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_REPORT6 (
    BFJDATE                 CHAR(8)                         NOT NULL,
    BANKCODE                CHAR(4)                         NOT NULL,
    C1                      NUMBER(12,6)                        NULL,
    C2                      NUMBER(12,6)                        NULL,
    C3                      NUMBER(12,6)                        NULL,
    C4                      NUMBER(12,6)                        NULL,
    C5                      NUMBER(12,6)                        NULL,
    C6                      NUMBER(12,6)                        NULL,
    C7                      NUMBER(12,6)                        NULL,
    C8                      NUMBER(12,6)                        NULL,
    C9                      NUMBER(12,6)                        NULL,
    C10                     NUMBER(12,6)                        NULL,
    C11                     NUMBER(12,6)                        NULL,
    C12                     NUMBER(12,6)                        NULL,
    C13                     NUMBER(12,6)                        NULL,
    C14                     NUMBER(12,6)                        NULL,
    C15                     NUMBER(12,6)                        NULL,
    C16                     NUMBER(12,6)                        NULL,
    C17                     NUMBER(12,6)                        NULL,
    C18                     NUMBER(12,6)                        NULL,
    C19                     NUMBER(12,6)                        NULL,
    C20                     NUMBER(12,6)                        NULL,
    C21                     NUMBER(12,6)                        NULL,
    C22                     NUMBER(12,6)                        NULL,
    C23                     NUMBER(12,6)                        NULL,
    C24                     NUMBER(12,6)                        NULL,
    C25                     NUMBER(12,6)                        NULL,
    C26                     NUMBER(12,6)                        NULL,
    C27                     NUMBER(12,6)                        NULL,
    C28                     NUMBER(12,6)                        NULL,
    CONSTRAINT PK_TF_F_BFJ_REPORT6 PRIMARY KEY(BFJDATE, BANKCODE)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_REPORT6 to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_REPORT6 to Ucrapp_B_SZ;
grant Update on TF_F_BFJ_REPORT6 to Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_REPORT6 to Ucrapp_B_SZ;


--现金购卡业务统计表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_REPORT7 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_REPORT7 (
    BFJDATE                 CHAR(8)                         NOT NULL,
    C1                      NUMBER(12,6)                        NULL,
    C2                      NUMBER(12,6)                        NULL,
    C3                      NUMBER(12,6)                        NULL,
    C4                      NUMBER(12,6)                        NULL,
    CONSTRAINT PK_TF_F_BFJ_REPORT7 PRIMARY KEY(BFJDATE)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_REPORT7 to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_REPORT7 to Ucrapp_B_SZ;
grant Update on TF_F_BFJ_REPORT7 to Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_REPORT7 to Ucrapp_B_SZ;


--预付卡现金赎回业务统计表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_REPORT8 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_REPORT8 (
    BFJDATE                 CHAR(8)                         NOT NULL,
    C1                      NUMBER(12,6)                        NULL,
    C2                      NUMBER(12,6)                        NULL,
    C3                      NUMBER(12,6)                        NULL,
    C4                      NUMBER(12,6)                        NULL,
    CONSTRAINT PK_TF_F_BFJ_REPORT8 PRIMARY KEY(BFJDATE)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_REPORT8 to Uqry_B_SZ,Uopsett_B_SZ;
grant Insert on TF_F_BFJ_REPORT8 to Ucrapp_B_SZ;
grant Update on TF_F_BFJ_REPORT8 to Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_REPORT8 to Ucrapp_B_SZ;


--备付金业务未达账项统计表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_REPORT9 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_REPORT9 (
    BFJDATE                 CHAR(8)                         NOT NULL,
    BANKCODE                CHAR(4)                         NOT NULL,
    C1                      NUMBER(12,6)                        NULL,
    C2                      NUMBER(12,6)                        NULL,
    C3                      NUMBER(12,6)                        NULL,
    C4                      NUMBER(12,6)                        NULL,
    CONSTRAINT PK_TF_F_BFJ_REPORT9 PRIMARY KEY(BFJDATE, BANKCODE)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_REPORT9 to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_REPORT9 to Ucrapp_B_SZ;
grant Update on TF_F_BFJ_REPORT9 to Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_REPORT9 to Ucrapp_B_SZ;


--备付金业务未达账项分析表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_REPORT10 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_REPORT10 (
    BFJDATE                 CHAR(8)                         NOT NULL,
    BANKCODE                CHAR(4)                         NOT NULL,
    C1                      INT                                 NULL,
    C2                      NUMBER(12,6)                        NULL,
    C3                      INT                                 NULL,
    C4                      NUMBER(12,6)                        NULL,
    C5                      INT                                 NULL,
    C6                      NUMBER(12,6)                        NULL,
    C7                      INT                                 NULL,
    C8                      NUMBER(12,6)                        NULL,
    C9                      INT                                 NULL,
    C10                     NUMBER(12,6)                        NULL,
    C11                     INT                                 NULL,
    C12                     NUMBER(12,6)                        NULL,
    C13                     INT                                 NULL,
    C14                     NUMBER(12,6)                        NULL,
    C15                     INT                                 NULL,
    C16                     NUMBER(12,6)                        NULL,
    C17                     INT                                 NULL,
    C18                     NUMBER(12,6)                        NULL,
    C19                     INT                                 NULL,
    C20                     NUMBER(12,6)                        NULL,
    C21                     INT                                 NULL,
    C22                     NUMBER(12,6)                        NULL,
    C23                     INT                                 NULL,
    C24                     NUMBER(12,6)                        NULL,
    C25                     INT                                 NULL,
    C26                     NUMBER(12,6)                        NULL,
    C27                     INT                                 NULL,
    C28                     NUMBER(12,6)                        NULL,
    C29                     INT                                 NULL,
    C30                     NUMBER(12,6)                        NULL,
    C31                     INT                                 NULL,
    C32                     NUMBER(12,6)                        NULL,
    CONSTRAINT PK_TF_F_BFJ_REPORT10 PRIMARY KEY(BFJDATE, BANKCODE)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_REPORT10 to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_REPORT10 to Ucrapp_B_SZ;
grant Update on TF_F_BFJ_REPORT10 to Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_REPORT10 to Ucrapp_B_SZ;


--客户资金账户余额变动调节表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_REPORT11 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_REPORT11 (
    BFJDATE                 CHAR(8)                         NOT NULL,
    C1                      NUMBER(12,6)                        NULL,
    C2                      NUMBER(12,6)                        NULL,
    C3                      NUMBER(12,6)                        NULL,
    C4                      NUMBER(12,6)                        NULL,
    C5                      NUMBER(12,6)                        NULL,
    C6                      NUMBER(12,6)                        NULL,
    C7                      NUMBER(12,6)                        NULL,
    C8                      NUMBER(12,6)                        NULL,
    C9                      NUMBER(12,6)                        NULL,
    C10                     NUMBER(12,6)                        NULL,
    C11                     NUMBER(12,6)                        NULL,
    C12                     NUMBER(12,6)                        NULL,
    C13                     NUMBER(12,6)                        NULL,
    C14                     NUMBER(12,6)                        NULL,
    C15                     NUMBER(12,6)                        NULL,
    C16                     NUMBER(12,6)                        NULL,
    C17                     NUMBER(12,6)                        NULL,
    C18                     NUMBER(12,6)                        NULL,
    C19                     NUMBER(12,6)                        NULL,
    C20                     NUMBER(12,6)                        NULL,
    C21                     NUMBER(12,6)                        NULL,
    C22                     NUMBER(12,6)                        NULL,
    C23                     NUMBER(12,6)                        NULL,
    C24                     NUMBER(12,6)                        NULL,
    C25                     NUMBER(12,6)                        NULL,
    C26                     NUMBER(12,6)                        NULL,
    C27                     NUMBER(12,6)                        NULL,
    C28                     NUMBER(12,6)                        NULL,
    CONSTRAINT PK_TF_F_BFJ_REPORT11 PRIMARY KEY(BFJDATE)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_REPORT11 to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_REPORT11 to Ucrapp_B_SZ;
grant Update on TF_F_BFJ_REPORT11 to Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_REPORT11 to Ucrapp_B_SZ;


--客户资金账户余额试算表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_REPORT12 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_REPORT12 (
    BFJDATE                 CHAR(8)                         NOT NULL,
    C1                      NUMBER(12,6)                        NULL,
    C2                      NUMBER(12,6)                        NULL,
    C3                      NUMBER(12,6)                        NULL,
    C4                      NUMBER(12,6)                        NULL,
    C5                      NUMBER(12,6)                        NULL,
    C6                      NUMBER(12,6)                        NULL,
    C7                      NUMBER(12,6)                        NULL,
    C8                      NUMBER(12,6)                        NULL,
    C9                      NUMBER(12,6)                        NULL,
    C10                     NUMBER(12,6)                        NULL,
    C11                     NUMBER(12,6)                        NULL,
    C12                     NUMBER(12,6)                        NULL,
    C13                     NUMBER(12,6)                        NULL,
    C14                     NUMBER(12,6)                        NULL,
    C15                     NUMBER(12,6)                        NULL,
    C16                     NUMBER(12,6)                        NULL,
    C17                     NUMBER(12,6)                        NULL,
    C18                     NUMBER(12,6)                        NULL,
    C19                     NUMBER(12,6)                        NULL,
    CONSTRAINT PK_TF_F_BFJ_REPORT12 PRIMARY KEY(BFJDATE)
)tablespace TBSsett_B_SZ
/


grant Select on TF_F_BFJ_REPORT12 to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_REPORT12 to Ucrapp_B_SZ;
grant Update on TF_F_BFJ_REPORT12 to Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_REPORT12 to Ucrapp_B_SZ;


--售卡押金统计表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_REPORT13 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_REPORT13 (
    BFJDATE                 CHAR(8)                         NOT NULL,
    C1                      NUMBER(12,6)                        NULL,
    C2                      NUMBER(12,6)                        NULL,
    C3                      NUMBER(12,6)                        NULL,
    C4                      NUMBER(12,6)                        NULL,
    C5                      NUMBER(12,6)                        NULL,
    C6                      NUMBER(12,6)                        NULL,
    CONSTRAINT PK_TF_F_BFJ_REPORT13 PRIMARY KEY(BFJDATE)
)tablespace TBSsett_B_SZ+J33F33F33:J33
/


grant Select on TF_F_BFJ_REPORT13 to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_REPORT13 to Ucrapp_B_SZ;
grant Update on TF_F_BFJ_REPORT13 to Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_REPORT13 to Ucrapp_B_SZ;


--备付金银行账户余额统计表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_REPORT2_1 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_REPORT2_1 (
    BFJDATE                 CHAR(8)                         NOT NULL,
    C1                      VARCHAR2(50)                        NULL,
    C2                      NUMBER(12,6)                        NULL,
    C3                      VARCHAR2(50)                        NULL,
    C4                      VARCHAR2(50)                        NULL,
    C5                      NUMBER(12,6)                        NULL,
    C6                      VARCHAR2(50)                        NULL,
    C7                      VARCHAR2(50)                        NULL,
    C8                      NUMBER(12,6)                        NULL,
    C9                      VARCHAR2(50)                        NULL,
    C10                     VARCHAR2(50)                        NULL,
    C11                     NUMBER(12,6)                        NULL,
    C12                     VARCHAR2(50)                        NULL,
    C13                     VARCHAR2(50)                        NULL,
    C14                     NUMBER(12,6)                        NULL,
    C15                     VARCHAR2(50)                        NULL,
    C16                     VARCHAR2(50)                        NULL,
    C17                     NUMBER(12,6)                        NULL,
    C18                     VARCHAR2(50)                        NULL,
    C19                     NUMBER(12,6)                        NULL,
    C20                     VARCHAR2(50)                        NULL,
    C21                     VARCHAR2(50)                        NULL,
    C22                     NUMBER(12,6)                        NULL,
    C23                     VARCHAR2(50)                        NULL,
    C24                     VARCHAR2(50)                        NULL,
    C25                     NUMBER(12,6)                        NULL,
    C26                     VARCHAR2(50)                        NULL,
    C27                     VARCHAR2(50)                        NULL,
    C28                     NUMBER(12,6)                        NULL,
    C29                     VARCHAR2(50)                        NULL,
    C30                     VARCHAR2(50)                        NULL,
    C31                     NUMBER(12,6)                        NULL,
    C32                     VARCHAR2(50)                        NULL,
    C33                     VARCHAR2(50)                        NULL,
    C34                     NUMBER(12,6)                        NULL,
    C35                     VARCHAR2(50)                        NULL,
    C36                     VARCHAR2(50)                        NULL,
    C37                     NUMBER(12,6)                        NULL,
    C38                     VARCHAR2(50)                        NULL,
    C39                     VARCHAR2(50)                        NULL,
    C40                     NUMBER(12,6)                        NULL,
    C41                     VARCHAR2(50)                        NULL,
    C42                     VARCHAR2(50)                        NULL,
    C43                     NUMBER(12,6)                        NULL,
    C44                     NUMBER(12,6)                        NULL,
    CONSTRAINT PK_TF_F_BFJ_REPORT2_1 PRIMARY KEY(BFJDATE)
)tablespace TBSsett_B_SZ+J33F33F33:J33
/


grant Select on TF_F_BFJ_REPORT2_1 to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_REPORT2_1 to Ucrapp_B_SZ;
grant Update on TF_F_BFJ_REPORT2_1 to Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_REPORT2_1 to Ucrapp_B_SZ;


--备付金商户白名单表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_BFJ_MERCHENT CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_BFJ_MERCHENT (
    MERCHENTID              VARCHAR2(30)                    NOT NULL,
    BANKCODE                CHAR(1)                             NULL,
    TRADETYPECODE           CHAR(1)                             NULL,
    ACCOUNT                 VARCHAR2(120)                       NULL,
    CURRENCY                CHAR(3)                             NULL,
    CUSTOMERTYPE            CHAR(1)                             NULL,
    CUSTOMERNAME            VARCHAR2(120)                       NULL,
    ENGLISHNAME             VARCHAR2(120)                       NULL,
    PINYIN                  VARCHAR2(60)                        NULL,
    PAPERTYPECODE           CHAR(2)                             NULL,
    PAPERNO                 VARCHAR2(30)                        NULL,
    PHONE                   VARCHAR2(20)                        NULL,
    MOBILEPHONE             VARCHAR2(20)                        NULL,
    FAX                     VARCHAR2(20)                        NULL,
    EMAIL                   VARCHAR2(60)                        NULL,
    ADDRESS                 VARCHAR2(60)                        NULL,
    ZIPCODE                 CHAR(6)                             NULL,
    LEGALNAME               VARCHAR2(30)                        NULL,
    BANKNO                  VARCHAR2(14)                        NULL,
    BANKNAME                VARCHAR2(60)                        NULL,
    RSRV1                   VARCHAR2(200)                       NULL,
    RSRV2                   VARCHAR2(200)                       NULL,
    UPDATEDATE              CHAR(8)                             NULL,
    CONSTRAINT PK_TF_F_BFJ_MERCHENT PRIMARY KEY(MERCHENTID)
)tablespace TBSsett_B_SZ+J33F33F33:J33
/


grant Select on TF_F_BFJ_MERCHENT to Uqry_B_SZ,Uopsett_B_SZ,Ucrapp_B_SZ;
grant Insert on TF_F_BFJ_MERCHENT to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Update on TF_F_BFJ_MERCHENT to Uopsett_B_SZ,Ucrapp_B_SZ;
grant Delete on TF_F_BFJ_MERCHENT to Uopsett_B_SZ,Ucrapp_B_SZ;



