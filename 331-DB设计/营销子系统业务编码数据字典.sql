--费用类型编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_FEETYPE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_FEETYPE (
    FEETYPECODE             CHAR(2)                         NOT NULL,
    FEETYPENAME             VARCHAR2(20)                        NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    CONSTRAINT PK_TD_M_FEETYPE PRIMARY KEY(FEETYPECODE)
)
/




--退换卡原因编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_REASONTYPE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_REASONTYPE (
    REASONCODE              CHAR(2)                         NOT NULL,
    REASON                  VARCHAR2(20)                        NULL,
    DEPOSITTAG              CHAR(1)                             NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    CONSTRAINT PK_TD_M_REASONTYPE PRIMARY KEY(REASONCODE)
)
/




--业务类型编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_TRADETYPE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_TRADETYPE (
    TRADETYPECODE           CHAR(2)                         NOT NULL,
    TRADETYPE               VARCHAR2(20)                        NULL,
    CANCELCODE              CHAR(2)                             NULL,
    CANCANCELTAG            CHAR(1)          DEFAULT '0'        NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    CONSTRAINT PK_TD_M_TRADETYPE PRIMARY KEY(TRADETYPECODE)
)
/




--功能类型编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_FUNCTIONTYPE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_FUNCTIONTYPE (
    FUNCTIONTYPECODE        CHAR(2)                         NOT NULL,
    FUNCTIONTYPE            VARCHAR2(20)                        NULL,
    CANCANCELTAG            CHAR(1)                             NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    CONSTRAINT PK_TD_M_FUNCTIONTYPE PRIMARY KEY(FUNCTIONTYPECODE)
)
/




--证件类型编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_PAPERTYPE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_PAPERTYPE (
    PAPERTYPECODE           CHAR(2)                         NOT NULL,
    PAPERTYPENAME           VARCHAR2(20)                        NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    CONSTRAINT PK_TD_M_PAPERTYPE PRIMARY KEY(PAPERTYPECODE)
)
/




--前台业务交易费用表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_TRADEFEE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_TRADEFEE (
    TRADETYPECODE           CHAR(2)                         NOT NULL,
    FEETYPECODE             CHAR(2)                         NOT NULL,
    BASEFEE                 INT                             NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    CONSTRAINT PK_TD_M_TRADEFEE PRIMARY KEY(TRADETYPECODE, FEETYPECODE)
)
/




--业务功能名称编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_FUNCTION CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_FUNCTION (
    FUNCTIONTYPE            CHAR(2)                         NOT NULL,
    FUNCTIONNAME            VARCHAR2(20)                        NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    CONSTRAINT PK_TD_M_FUNCTION PRIMARY KEY(FUNCTIONTYPE)
)
/




--卡片锁定类型编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_LOCKTYPE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_LOCKTYPE (
    LOCKTYPECODE            CHAR(1)                         NOT NULL,
    LOCKTYPE                VARCHAR2(20)                        NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    CONSTRAINT PK_TD_M_LOCKTYPE PRIMARY KEY(LOCKTYPECODE)
)
/




--IC交易类型编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_ICTRADETYPE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_ICTRADETYPE (
    ICTRADETYPECODE         CHAR(2)                         NOT NULL,
    ICTRADETYPE             VARCHAR2(20)                        NULL,
    EDOREPTAG               CHAR(1)                             NULL,
    LINEORONLINETAG         CHAR(1)                             NULL,
    ISOPENTAG               CHAR(1)                             NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    CONSTRAINT PK_TD_M_ICTRADETYPE PRIMARY KEY(ICTRADETYPECODE)
)
/




--月票类型和行政区域对应关系编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_APPAREA CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_APPAREA (
    APPTYPE                 CHAR(2)                         NOT NULL,
    AREACODE                CHAR(2)                         NOT NULL,
    FLAG                    CHAR(1)                             NULL,
    AREANAME                VARCHAR2(40)                        NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    CONSTRAINT PK_TD_M_APPAREA PRIMARY KEY(APPTYPE, AREACODE)
)
/




--开通功能套餐编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_PACKAGETYPE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_PACKAGETYPE (
    PACKAGETYPECODE         CHAR(2)                         NOT NULL,
    PACKAGEFEE              INT                             NOT NULL,
    PACKAGETYPENAME         VARCHAR2(40)                        NULL,
    PACKAGETYPEMSG          VARCHAR2(400)                       NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_M_PACKAGETYPE PRIMARY KEY(PACKAGETYPECODE)
)
/




--休闲年卡同步景点编码表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_XXCHANNELTYPE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_XXCHANNELTYPE (
    CHANNELTYPECODE         CHAR(2)                         NOT NULL,
    CHANNELTYPENAME         VARCHAR2(40)                        NULL,
    CHANNELTYPEMSG          VARCHAR2(400)                       NULL,
    LOCALPATH               VARCHAR2(100)                       NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_M_XXCHANNELTYPE PRIMARY KEY(CHANNELTYPECODE)
)
/





