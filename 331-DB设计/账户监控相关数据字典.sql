--告警条件表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_WARNCOND CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_WARNCOND (
    CONDCODE                CHAR(4)                         NOT NULL,
    CONDNAME                VARCHAR2(256)                   NOT NULL,
    WARNTYPE                VARCHAR2(16)                    NOT NULL,
    CONDRANGE               CHAR(1)                         NOT NULL,
    WARNLEVEL               CHAR(1)                         NOT NULL,
    CONDCATE                CHAR(1)                         NOT NULL,
    CONDSTR                 VARCHAR2(256)                       NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_M_WARNCOND PRIMARY KEY(CONDCODE)
)tablespace TBSdata_B_SZ
/


grant Select on TD_M_WARNCOND to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TD_M_WARNCOND to Ucrapp_B_SZ;
grant Update on TD_M_WARNCOND to Ucrapp_B_SZ;
grant Delete on TD_M_WARNCOND to Ucrapp_B_SZ;


--通用编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_CODING CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_CODING (
    CODECATE                VARCHAR2(16)                    NOT NULL,
    CODEVALUE               VARCHAR2(16)                    NOT NULL,
    CODENAME                VARCHAR2(32)                    NOT NULL,
    CODEDESC                VARCHAR2(256)                       NULL,
    CONSTRAINT PK_TD_M_CODING PRIMARY KEY(CODECATE, CODEVALUE)
)tablespace TBSdata_B_SZ
/


grant Select on TD_M_CODING to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TD_M_CODING to Ucrapp_B_SZ;
grant Update on TD_M_CODING to Ucrapp_B_SZ;
grant Delete on TD_M_CODING to Ucrapp_B_SZ;


--告警单主表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_WARN CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_WARN (
    CARDNO                  CHAR(16)                        NOT NULL,
    CONDCODE                CHAR(4)                             NULL,
    INITIALTIME             DATE                            NOT NULL,
    LASTTIME                DATE                            NOT NULL,
    DETAILS                 INT                             NOT NULL,
    WARNTYPE                VARCHAR2(16)                    NOT NULL,
    WARNLEVEL               CHAR(1)                         NOT NULL,
    WARNSRC                 CHAR(1)                         NOT NULL,
    PREMONEY                INT                                 NULL,
    TRADEMONEY              INT                                 NULL,
    ACCBALANCE              INT                                 NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_B_WARN PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_B_WARN to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_B_WARN to Ucrapp_B_SZ;
grant Update on TF_B_WARN to Ucrapp_B_SZ;
grant Delete on TF_B_WARN to Ucrapp_B_SZ;


--告警单主表备份表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TH_B_WARN CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TH_B_WARN (
    HSEQNO                  NUMERIC                         NOT NULL,
    BACKTIME                DATE                                NULL,
    BACKSTAFF               CHAR(6)                             NULL,
    BACKWHY                 CHAR(1)                             NULL,
    BACKREMARK              VARCHAR2(100)                       NULL,
    CARDNO                  CHAR(16)                            NULL,
    CONDCODE                CHAR(4)                             NULL,
    INITIALTIME             DATE                                NULL,
    LASTTIME                DATE                                NULL,
    DETAILS                 INT                                 NULL,
    WARNTYPE                VARCHAR2(16)                        NULL,
    WARNLEVEL               CHAR(1)                             NULL,
    WARNSRC                 CHAR(1)                             NULL,
    PREMONEY                INT                                 NULL,
    TRADEMONEY              INT                                 NULL,
    ACCBALANCE              INT                                 NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TH_B_WARN PRIMARY KEY(HSEQNO)
)tablespace TBSdata_B_SZ
/


grant Select on TH_B_WARN to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TH_B_WARN to Ucrapp_B_SZ;
grant Update on TH_B_WARN to Ucrapp_B_SZ;
grant Delete on TH_B_WARN to Ucrapp_B_SZ;

;
BEGIN
EXECUTE IMMEDIATE 'DROP SEQUENCE TH_B_WARN_SEQ';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE  SEQUENCE  TH_B_WARN_SEQ
    START WITH 1
    INCREMENT BY 1
/

grant select on TH_B_WARN_SEQ to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;


--告警详单表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_WARN_DETAIL CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_WARN_DETAIL (
    CARDNO                  CHAR(16)                        NOT NULL,
    SEQNO                   NUMERIC                         NOT NULL,
    ID                      CHAR(30)                            NULL,
    CONDCODE                CHAR(4)                             NULL,
    LASTTIME                DATE                            NOT NULL,
    WARNTYPE                VARCHAR2(16)                    NOT NULL,
    WARNLEVEL               CHAR(1)                         NOT NULL,
    WARNSRC                 CHAR(1)                             NULL,
    PREMONEY                INT                                 NULL,
    TRADEMONEY              INT                                 NULL,
    ACCBALANCE              INT                                 NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_B_WARN_DETAIL PRIMARY KEY(CARDNO, SEQNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_B_WARN_DETAIL to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_B_WARN_DETAIL to Ucrapp_B_SZ;
grant Update on TF_B_WARN_DETAIL to Ucrapp_B_SZ;
grant Delete on TF_B_WARN_DETAIL to Ucrapp_B_SZ;

;
BEGIN
EXECUTE IMMEDIATE 'DROP SEQUENCE TF_B_WARN_DETAIL_SEQ';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE  SEQUENCE  TF_B_WARN_DETAIL_SEQ
    START WITH 1
    INCREMENT BY 1
/

grant select on TF_B_WARN_DETAIL_SEQ to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;


--告警详单备份表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TH_B_WARN_DETAIL CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TH_B_WARN_DETAIL (
    HSEQNO                  NUMERIC                         NOT NULL,
    BACKTIME                DATE                                NULL,
    BACKSTAFF               CHAR(6)                             NULL,
    BACKWHY                 CHAR(1)                             NULL,
    BACKREMARK              VARCHAR2(100)                       NULL,
    CARDNO                  CHAR(16)                            NULL,
    SEQNO                   NUMERIC                             NULL,
    ID                      CHAR(30)                            NULL,
    CONDCODE                CHAR(4)                             NULL,
    LASTTIME                DATE                                NULL,
    WARNTYPE                VARCHAR2(16)                        NULL,
    WARNLEVEL               CHAR(1)                             NULL,
    WARNSRC                 CHAR(1)                             NULL,
    PREMONEY                INT                                 NULL,
    TRADEMONEY              INT                                 NULL,
    ACCBALANCE              INT                                 NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TH_B_WARN_DETAIL PRIMARY KEY(HSEQNO)
)tablespace TBSdata_B_SZ
/


grant Select on TH_B_WARN_DETAIL to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TH_B_WARN_DETAIL to Ucrapp_B_SZ;
grant Update on TH_B_WARN_DETAIL to Ucrapp_B_SZ;
grant Delete on TH_B_WARN_DETAIL to Ucrapp_B_SZ;

;
BEGIN
EXECUTE IMMEDIATE 'DROP SEQUENCE TH_B_WARN_DETAIL_SEQ';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE  SEQUENCE  TH_B_WARN_DETAIL_SEQ
    START WITH 1
    INCREMENT BY 1
/

grant select on TH_B_WARN_DETAIL_SEQ to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;


--告警黑名单表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_WARN_BLACK CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_WARN_BLACK (
    CARDNO                  CHAR(16)                        NOT NULL,
    CREATETIME              DATE                            NOT NULL,
    WARNTYPE                VARCHAR2(16)                        NULL,
    WARNLEVEL               CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    DOWNTIME                DATE                                NULL,
    BLACKSTATE              CHAR(1)                             NULL,
    BLACKTYPE               CHAR(1)                             NULL,
    BLACKLEVEL              CHAR(1)                             NULL,
    OVERTIMEMONEY           INT                                 NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    LISTTYPECODE            CHAR(2)                             NULL,
    CONSTRAINT PK_TF_B_WARN_BLACK PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_B_WARN_BLACK to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_B_WARN_BLACK to Ucrapp_B_SZ;
grant Update on TF_B_WARN_BLACK to Ucrapp_B_SZ;
grant Delete on TF_B_WARN_BLACK to Ucrapp_B_SZ;


--告警黑名单备份表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TH_B_WARN_BLACK CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TH_B_WARN_BLACK (
    HSEQNO                  NUMERIC                         NOT NULL,
    BACKTIME                DATE                                NULL,
    BACKSTAFF               CHAR(6)                             NULL,
    BACKWHY                 CHAR(1)                             NULL,
    BACKREMARK              VARCHAR2(100)                       NULL,
    CARDNO                  CHAR(16)                            NULL,
    CREATETIME              DATE                            NOT NULL,
    WARNTYPE                VARCHAR2(16)                        NULL,
    WARNLEVEL               CHAR(1)                             NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    DOWNTIME                DATE                                NULL,
    BLACKSTATE              CHAR(1)                             NULL,
    BLACKTYPE               CHAR(1)                             NULL,
    BLACKLEVEL              CHAR(1)                             NULL,
    OVERTIMEMONEY           INT                                 NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TH_B_WARN_BLACK PRIMARY KEY(HSEQNO)
)tablespace TBSdata_B_SZ
/


grant Select on TH_B_WARN_BLACK to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TH_B_WARN_BLACK to Ucrapp_B_SZ;
grant Update on TH_B_WARN_BLACK to Ucrapp_B_SZ;
grant Delete on TH_B_WARN_BLACK to Ucrapp_B_SZ;

;
BEGIN
EXECUTE IMMEDIATE 'DROP SEQUENCE TH_B_WARN_BLACK_SEQ';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE  SEQUENCE  TH_B_WARN_BLACK_SEQ
    START WITH 1
    INCREMENT BY 1
/

grant select on TH_B_WARN_BLACK_SEQ to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;


--告警灰名单表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_WARN_GRAY CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_WARN_GRAY (
    CARDNO                  CHAR(16)                        NOT NULL,
    CREATETIME              DATE                            NOT NULL,
    WARNTYPE                VARCHAR2(16)                        NULL,
    WARNLEVEL               CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    DOWNTIME                DATE                                NULL,
    GRAYSTATE               CHAR(1)          DEFAULT '0'        NULL,
    GRAYTYPE                CHAR(1)                             NULL,
    GRAYLEVEL               CHAR(1)                             NULL,
    OVERTIMEMONEY           INT                                 NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CITYCODE                CHAR(4)          DEFAULT '2150'     NULL,
    CONSTRAINT PK_TF_B_WARN_GRAY PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_B_WARN_GRAY to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_B_WARN_GRAY to Ucrapp_B_SZ;
grant Update on TF_B_WARN_GRAY to Ucrapp_B_SZ;
grant Delete on TF_B_WARN_GRAY to Ucrapp_B_SZ;


--告警灰名单备份表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TH_B_WARN_GRAY CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TH_B_WARN_GRAY (
    HSEQNO                  NUMERIC                         NOT NULL,
    BACKTIME                DATE                                NULL,
    BACKSTAFF               CHAR(6)                             NULL,
    BACKWHY                 CHAR(1)                             NULL,
    BACKREMARK              VARCHAR2(100)                       NULL,
    CARDNO                  CHAR(16)                            NULL,
    CREATETIME              DATE                            NOT NULL,
    WARNTYPE                VARCHAR2(16)                        NULL,
    WARNLEVEL               CHAR(1)                             NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    DOWNTIME                DATE                                NULL,
    GRAYSTATE               CHAR(1)          DEFAULT '0'        NULL,
    GRAYTYPE                CHAR(1)                             NULL,
    GRAYLEVEL               CHAR(1)                             NULL,
    OVERTIMEMONEY           INT                                 NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CITYCODE                CHAR(4)          DEFAULT '2150'     NULL,
    CONSTRAINT PK_TH_B_WARN_GRAY PRIMARY KEY(HSEQNO)
)
/



;
BEGIN
EXECUTE IMMEDIATE 'DROP SEQUENCE TH_B_WARN_GRAY_SEQ';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE  SEQUENCE  TH_B_WARN_GRAY_SEQ
    START WITH 1
    INCREMENT BY 1
/




--告警监控名单表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_WARN_MONITOR CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_WARN_MONITOR (
    SEQNO                   NUMERIC                         NOT NULL,
    CARDNO                  CHAR(16)                        NOT NULL,
    CREATETIME              DATE                            NOT NULL,
    CONDCODE                CHAR(4)                         NOT NULL,
    WARNTYPE                VARCHAR2(16)                    NOT NULL,
    WARNLEVEL               CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_B_WARN_MONITOR PRIMARY KEY(SEQNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_B_WARN_MONITOR to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_B_WARN_MONITOR to Ucrapp_B_SZ;
grant Update on TF_B_WARN_MONITOR to Ucrapp_B_SZ;
grant Delete on TF_B_WARN_MONITOR to Ucrapp_B_SZ;

;
BEGIN
EXECUTE IMMEDIATE 'DROP SEQUENCE TF_B_WARN_MONITOR_SEQ';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE  SEQUENCE  TF_B_WARN_MONITOR_SEQ
    START WITH 1
    INCREMENT BY 1
/

grant select on TF_B_WARN_MONITOR_SEQ to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;


--告警监控名单表备份表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TH_B_WARN_MONITOR CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TH_B_WARN_MONITOR (
    HSEQNO                  NUMERIC                         NOT NULL,
    BACKTIME                DATE                                NULL,
    BACKSTAFF               CHAR(6)                             NULL,
    BACKWHY                 CHAR(1)                             NULL,
    BACKREMARK              VARCHAR2(100)                       NULL,
    SEQNO                   NUMERIC                             NULL,
    CARDNO                  CHAR(16)                            NULL,
    CREATETIME              DATE                                NULL,
    CONDCODE                CHAR(4)                             NULL,
    WARNTYPE                VARCHAR2(16)                        NULL,
    WARNLEVEL               CHAR(1)                             NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TH_B_WARN_MONITOR PRIMARY KEY(HSEQNO)
)tablespace TBSdata_B_SZ
/


grant Select on TH_B_WARN_MONITOR to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TH_B_WARN_MONITOR to Ucrapp_B_SZ;
grant Update on TH_B_WARN_MONITOR to Ucrapp_B_SZ;
grant Delete on TH_B_WARN_MONITOR to Ucrapp_B_SZ;

;
BEGIN
EXECUTE IMMEDIATE 'DROP SEQUENCE TH_B_WARN_MONITOR_SEQ';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE  SEQUENCE  TH_B_WARN_MONITOR_SEQ
    START WITH 1
    INCREMENT BY 1
/

grant select on TH_B_WARN_MONITOR_SEQ to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;


--当日消费IC卡临时列表1
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TMP_WARN_TODAYCARDS1 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE GLOBAL TEMPORARY TABLE TMP_WARN_TODAYCARDS1 (
    CARDNO                  CHAR(16)                        NOT NULL,
    CONSTRAINT PK_TMP_WARN_TODAYCARDS1 PRIMARY KEY(CARDNO)
)ON COMMIT PRESERVE ROWS
/


grant Select on TMP_WARN_TODAYCARDS1 to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TMP_WARN_TODAYCARDS1 to Ucrapp_B_SZ,Uopapp_B_SZ;
grant Update on TMP_WARN_TODAYCARDS1 to Ucrapp_B_SZ,Uopapp_B_SZ;
grant Delete on TMP_WARN_TODAYCARDS1 to Ucrapp_B_SZ,Uopapp_B_SZ;


--当日消费IC卡临时列表2
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TMP_WARN_TODAYCARDS2 CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE GLOBAL TEMPORARY TABLE TMP_WARN_TODAYCARDS2 (
    CARDNO                  CHAR(16)                        NOT NULL,
    CONSTRAINT PK_TMP_WARN_TODAYCARDS2 PRIMARY KEY(CARDNO)
)ON COMMIT PRESERVE ROWS
/


grant Select on TMP_WARN_TODAYCARDS2 to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TMP_WARN_TODAYCARDS2 to Ucrapp_B_SZ,Uopapp_B_SZ;
grant Update on TMP_WARN_TODAYCARDS2 to Ucrapp_B_SZ,Uopapp_B_SZ;
grant Delete on TMP_WARN_TODAYCARDS2 to Ucrapp_B_SZ,Uopapp_B_SZ;


--告警任务表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_WARN_TASK CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_WARN_TASK (
    TASKDAY                 CHAR(8)                         NOT NULL,
    TASKSTATE               INT              DEFAULT 0          NULL,
    CARDSCNT                INT              DEFAULT 0          NULL,
    STARTTIME               DATE                                NULL,
    ENDTIME                 DATE                                NULL,
    TRADESTARTTIME          DATE                                NULL,
    TRADEENDTIME            DATE                                NULL,
    TRADEWARNSCNT           INT                                 NULL,
    TRADERETCODE            INT                                 NULL,
    TRADERETMSG             VARCHAR2(256)                       NULL,
    ACCSTARTTIME            DATE                                NULL,
    ACCENDTIME              DATE                                NULL,
    ACCWARNSCNT             INT                                 NULL,
    ACCRETCODE              INT                                 NULL,
    ACCRETMSG               VARCHAR2(256)                       NULL,
    CONSTRAINT PK_TF_B_WARN_TASK PRIMARY KEY(TASKDAY)
)tablespace TBSdata_B_SZ
/


grant Select on TF_B_WARN_TASK to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_B_WARN_TASK to Ucrapp_B_SZ;
grant Update on TF_B_WARN_TASK to Ucrapp_B_SZ;
grant Delete on TF_B_WARN_TASK to Ucrapp_B_SZ;


--轨交黑灰名单类型表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_BLACKLISTTYPE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_BLACKLISTTYPE (
    LISTTYPECODE            CHAR(2)                         NOT NULL,
    LISTTYPENAME            VARCHAR2(20)                        NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    USETAG                  CHAR(1)                             NULL,
    CONSTRAINT PK_TD_M_BLACKLISTTYPE PRIMARY KEY(LISTTYPECODE)
)tablespace TBSdata_B_SZ
/


grant Select on TD_M_BLACKLISTTYPE to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TD_M_BLACKLISTTYPE to Ucrapp_B_SZ;
grant Update on TD_M_BLACKLISTTYPE to Ucrapp_B_SZ;
grant Delete on TD_M_BLACKLISTTYPE to Ucrapp_B_SZ;


--轻轨回收表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_TRAIN_RENEW_ERROR CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_TRAIN_RENEW_ERROR (
    ID                      CHAR(30)                        NOT NULL,
    CARDNO                  CHAR(16)                            NULL,
    RECTYPE                 CHAR(1)                             NULL,
    ICTRADETYPECODE         CHAR(2)                             NULL,
    ASN                     CHAR(16)                            NULL,
    CARDTRADENO             CHAR(4)                             NULL,
    SAMNO                   CHAR(12)                            NULL,
    PSAMVERNO               CHAR(2)                             NULL,
    POSNO                   CHAR(6)                             NULL,
    POSTRADENO              CHAR(8)                             NULL,
    TRADEDATE               CHAR(8)                             NULL,
    TRADETIME               CHAR(6)                             NULL,
    PREMONEY                INT                                 NULL,
    TRADEMONEY              INT                                 NULL,
    SMONEY                  INT                                 NULL,
    TRADECOMFEE             INT                                 NULL,
    BALUNITNO               CHAR(8)                             NULL,
    CALLINGNO               CHAR(2)                             NULL,
    CORPNO                  CHAR(4)                             NULL,
    DEPARTNO                CHAR(4)                             NULL,
    CALLINGSTAFFNO          CHAR(6)                             NULL,
    CITYNO                  CHAR(4)                             NULL,
    TAC                     CHAR(8)                             NULL,
    TACSTATE                CHAR(1)                             NULL,
    MAC                     CHAR(8)                             NULL,
    SOURCEID                VARCHAR2(16)                        NULL,
    BATCHNO                 CHAR(14)                            NULL,
    DEALTIME                DATE                                NULL,
    INLISTTIME              DATE                                NULL,
    RSRVCHAR                CHAR(2)                             NULL,
    DEALSTATECODE           CHAR(1)          DEFAULT '0'        NULL,
    CONSTRAINT PK_TF_TRAIN_RENEW_ERROR PRIMARY KEY(ID)
)tablespace TBSdata_B_SZ
/


grant Select on TF_TRAIN_RENEW_ERROR to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_TRAIN_RENEW_ERROR to Ucrapp_B_SZ;
grant Update on TF_TRAIN_RENEW_ERROR to Ucrapp_B_SZ;
grant Delete on TF_TRAIN_RENEW_ERROR to Ucrapp_B_SZ;


--挂失黑名单表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_LOSS_BLACK CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_LOSS_BLACK (
    CARDNO                  CHAR(16)                        NOT NULL,
    CREATETIME              DATE                            NOT NULL,
    WARNTYPE                VARCHAR2(16)                        NULL,
    WARNLEVEL               CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    DOWNTIME                DATE                                NULL,
    BLACKSTATE              CHAR(1)                             NULL,
    BLACKTYPE               CHAR(1)                             NULL,
    BLACKLEVEL              CHAR(1)                             NULL,
    OVERTIMEMONEY           INT                                 NULL,
    LISTTYPECODE            CHAR(2)                             NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_B_LOSS_BLACK PRIMARY KEY(CARDNO)
)tablespace TBSdata_B_SZ
/


grant Select on TF_B_LOSS_BLACK to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_B_LOSS_BLACK to Ucrapp_B_SZ;
grant Update on TF_B_LOSS_BLACK to Ucrapp_B_SZ;
grant Delete on TF_B_LOSS_BLACK to Ucrapp_B_SZ;


--挂失黑名单备份表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TH_B_LOSS_BLACK CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TH_B_LOSS_BLACK (
    HSEQNO                  NUMERIC                         NOT NULL,
    BACKTIME                DATE                                NULL,
    BACKSTAFF               CHAR(6)                             NULL,
    BACKWHY                 CHAR(1)                             NULL,
    BACKREMARK              VARCHAR2(100)                       NULL,
    CARDNO                  CHAR(16)                            NULL,
    CREATETIME              DATE                            NOT NULL,
    WARNTYPE                VARCHAR2(16)                        NULL,
    WARNLEVEL               CHAR(1)                             NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    DOWNTIME                DATE                                NULL,
    BLACKSTATE              CHAR(1)                             NULL,
    BLACKTYPE               CHAR(1)                             NULL,
    BLACKLEVEL              CHAR(1)                             NULL,
    OVERTIMEMONEY           INT                                 NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TH_B_LOSS_BLACK PRIMARY KEY(HSEQNO)
)tablespace TBSdata_B_SZ
/


grant Select on TH_B_LOSS_BLACK to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TH_B_LOSS_BLACK to Ucrapp_B_SZ;
grant Update on TH_B_LOSS_BLACK to Ucrapp_B_SZ;
grant Delete on TH_B_LOSS_BLACK to Ucrapp_B_SZ;

;
BEGIN
EXECUTE IMMEDIATE 'DROP SEQUENCE TH_B_LOSS_BLACK_SEQ';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE  SEQUENCE  TH_B_LOSS_BLACK_SEQ
    START WITH 1
    INCREMENT BY 1
/

grant select on TH_B_LOSS_BLACK_SEQ to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;


--挂失黑名单明细表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_LOSS_BLACK_DETAIL CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_LOSS_BLACK_DETAIL (
    CARDNO                  CHAR(16)                        NOT NULL,
    BLACKSTATE              DATE                            NOT NULL,
    STARTDATE               VARCHAR2(16)                    NOT NULL,
    ENDDATE                 CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
)tablespace TBSdata_B_SZ
/


grant Select on TF_B_LOSS_BLACK_DETAIL to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ;
grant Insert on TF_B_LOSS_BLACK_DETAIL to Ucrapp_B_SZ;
grant Update on TF_B_LOSS_BLACK_DETAIL to Ucrapp_B_SZ;
grant Delete on TF_B_LOSS_BLACK_DETAIL to Ucrapp_B_SZ;



