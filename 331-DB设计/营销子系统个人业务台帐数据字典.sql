--业务台帐主表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_TRADE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_TRADE (
    TRADEID                 CHAR(16)                        NOT NULL,
    CARDNO                  CHAR(16)                        NOT NULL,
    ID                      CHAR(18)                            NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    ASN                     CHAR(16)                            NULL,
    CARDTYPECODE            CHAR(2)                             NULL,
    CARDTRADENO             CHAR(4)                             NULL,
    REASONCODE              CHAR(2)                             NULL,
    OLDCARDNO               CHAR(16)                            NULL,
    DEPOSIT                 INT              DEFAULT 0          NULL,
    OLDCARDMONEY            INT              DEFAULT 0          NULL,
    CURRENTMONEY            INT              DEFAULT 0          NULL,
    PREMONEY                INT              DEFAULT 0          NULL,
    NEXTMONEY               INT              DEFAULT 0          NULL,
    CORPNO                  CHAR(4)                             NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    CHECKSTAFFNO            CHAR(6)                             NULL,
    CHECKDEPARTNO           CHAR(4)                             NULL,
    CHECKTIME               DATE                                NULL,
    STATECODE               CHAR(1)                             NULL,
    CANCELTAG               CHAR(1)          DEFAULT '0'        NULL,
    CANCELTRADEID           CHAR(16)                            NULL,
    CARDSTATE               CHAR(2)                             NULL,
    SERSTAKETAG             CHAR(1)                             NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    TRADEORIGIN             CHAR(2)                             NULL,
    CONSTRAINT PK_TF_B_TRADE PRIMARY KEY(TRADEID, CARDNO)
)
/




--客户资料变更子表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_CUSTOMERCHANGE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_CUSTOMERCHANGE (
    TRADEID                 CHAR(16)                        NOT NULL,
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
    PASSWD                  CHAR(12)                            NULL,
    CHGTYPECODE             CHAR(2)                         NOT NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_B_CUSTOMERCHANGE PRIMARY KEY(TRADEID, CARDNO)
)
/




--现金台帐主表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_TRADEFEE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_TRADEFEE (
    ID                      CHAR(18)                        NOT NULL,
    TRADEID                 CHAR(16)                            NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    CARDNO                  CHAR(16)                            NULL,
    CARDTRADENO             CHAR(4)                             NULL,
    PREMONEY                INT              DEFAULT 0          NULL,
    CARDSERVFEE             INT              DEFAULT 0          NULL,
    CARDDEPOSITFEE          INT              DEFAULT 0          NULL,
    SUPPLYMONEY             INT              DEFAULT 0          NULL,
    TRADEPROCFEE            INT              DEFAULT 0          NULL,
    FUNCFEE                 INT              DEFAULT 0          NULL,
    OTHERFEE                INT              DEFAULT 0          NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    CANCELTAG               CHAR(1)          DEFAULT '0'        NULL,
    COLLECTTAG              CHAR(2)          DEFAULT '01'       NULL,
    RSRV1                   INT                                 NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   VARCHAR2(20)                        NULL,
    TRADEORIGIN             CHAR(2)                             NULL,
    CONSTRAINT PK_TF_B_TRADEFEE PRIMARY KEY(ID)
)
/




--可充金额向电子钱包充值台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_GROUP_SELFSUPPLY CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_GROUP_SELFSUPPLY (
    TRADEID                 CHAR(16)                        NOT NULL,
    ID                      CHAR(18)                            NULL,
    CARDNO                  CHAR(16)                            NULL,
    ASN                     CHAR(16)                            NULL,
    CARDTYPECODE            CHAR(2)                             NULL,
    CARDTRADENO             CHAR(4)                             NULL,
    TRADEMONEY              INT              DEFAULT 0          NULL,
    PREMONEY                INT              DEFAULT 0          NULL,
    DBPREMONEY              INT              DEFAULT 0          NULL,
    TERMNO                  CHAR(12)                            NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    TRADETIME               DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    CONSTRAINT PK_TF_GROUP_SELFSUPPLY PRIMARY KEY(TRADEID)
)
/




--充值卡向电子钱包充值台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_CZC_SELFSUPPLY CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_CZC_SELFSUPPLY (
    TRADEID                 CHAR(16)                        NOT NULL,
    ID                      CHAR(18)                            NULL,
    CZCARDNO                CHAR(14)                            NULL,
    PASSWD                  CHAR(32)                            NULL,
    CARDNO                  CHAR(16)                            NULL,
    CARDTRADENO             CHAR(4)                             NULL,
    PREMONEY                INT              DEFAULT 0          NULL,
    TERMNO                  CHAR(12)                            NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    UPDATETIME              DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    CONSTRAINT PK_TF_CZC_SELFSUPPLY PRIMARY KEY(TRADEID)
)
/




--卡内资料变更流水表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_CARDUSEAREA CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_CARDUSEAREA (
    TRADEID                 CHAR(16)                        NOT NULL,
    CARDNO                  CHAR(16)                            NULL,
    ASN                     CHAR(16)                            NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    REASONCODE              CHAR(2)                             NULL,
    CHANGECON               CHAR(50)                            NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    CANCELTAG               CHAR(1)                             NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    CONSTRAINT PK_TF_B_CARDUSEAREA PRIMARY KEY(TRADEID)
)
/




--电子钱包充值流水表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_SUPPLY_REALTIME CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_SUPPLY_REALTIME (
    ID                      CHAR(18)                        NOT NULL,
    CARDNO                  CHAR(16)                            NULL,
    ASN                     CHAR(16)                            NULL,
    CARDTRADENO             CHAR(4)                             NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    CARDTYPECODE            CHAR(2)                             NULL,
    TRADEDATE               CHAR(8)                             NULL,
    TRADETIME               CHAR(6)                             NULL,
    TRADEMONEY              INT              DEFAULT 0          NULL,
    PREMONEY                INT              DEFAULT 0          NULL,
    SUPPLYLOCNO             CHAR(4)                             NULL,
    SAMNO                   CHAR(12)                            NULL,
    POSNO                   CHAR(6)                             NULL,
    TAC                     CHAR(4)                             NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATETIME             DATE                                NULL,
    MOVESTATE               CHAR(1)          DEFAULT '0'        NULL,
    RSRVCHAR                CHAR(2)                             NULL,
    CONSTRAINT PK_TF_SUPPLY_REALTIME PRIMARY KEY(ID)
)
/




--电子钱包其他变更流水表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_EWALLETCHANGE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_EWALLETCHANGE (
    TRADEID                 CHAR(16)                        NOT NULL,
    ID                      CHAR(18)                            NULL,
    CARDNO                  CHAR(16)                            NULL,
    ASN                     CHAR(16)                            NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    REASONCODE              CHAR(2)                             NULL,
    PSAMNO                  CHAR(12)                            NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    CANCELTAG               CHAR(1)                             NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    CONSTRAINT PK_TF_B_EWALLETCHANGE PRIMARY KEY(TRADEID)
)
/




--业务流水号取值表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_SEQ_ID CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_SEQ_ID (
    TRADEID                 INT                             NOT NULL,
    CONSTRAINT PK_TD_SEQ_ID PRIMARY KEY(TRADEID)
)
/




--充值对外认证随机数表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_B_RANDOM CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_B_RANDOM (
    RANDOM                  CHAR(16)                        NOT NULL,
    STATUS                  CHAR(1)                             NULL,
    RSRVSTRING1             CHAR(1)                             NULL,
    RSRVSTRING2             CHAR(2)                             NULL,
    RSRVSTRING3             CHAR(6)                             NULL,
    RSRVSTRING4             CHAR(8)                             NULL,
    CONSTRAINT PK_TD_B_RANDOM PRIMARY KEY(RANDOM)
)
/




--前台充值卡售卡台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_XFC_SELL CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_XFC_SELL (
    TRADEID                 CHAR(16)                        NOT NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    STARTCARDNO             CHAR(14)                            NULL,
    ENDCARDNO               CHAR(14)                            NULL,
    AMOUNT                  INT              DEFAULT 0          NULL,
    MONEY                   INT              DEFAULT 0          NULL,
    STAFFNO                 CHAR(6)                             NULL,
    OPERATETIME             DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CANCELTAG               CHAR(1)          DEFAULT '0'        NULL,
    CANCELTRADEID           CHAR(16)                            NULL,
    RSRV1                   CHAR(1)                             NULL,
    RSRV2                   CHAR(8)                             NULL,
    RSRV3                   INT                                 NULL,
    CONSTRAINT PK_TF_XFC_SELL PRIMARY KEY(TRADEID)
)
/




--充值卡直销台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_XFC_BATCHSELL CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_XFC_BATCHSELL (
    TRADEID                 CHAR(16)                        NOT NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    STARTCARDNO             CHAR(14)                            NULL,
    ENDCARDNO               CHAR(14)                            NULL,
    CARDVALUE               INT                                 NULL,
    AMOUNT                  INT                                 NULL,
    TOTALMONEY              INT                                 NULL,
    CUSTNAME                VARCHAR2(100)                       NULL,
    PAYTYPE                 CHAR(1)                             NULL,
    PAYTAG                  CHAR(1)                             NULL,
    PAYTIME                 DATE                                NULL,
    STAFFNO                 CHAR(6)                             NULL,
    OPERATETIME             DATE                                NULL,
    REMARK                  VARCHAR2(50)                        NULL,
    RSRV1                   CHAR(1)                             NULL,
    RSRV2                   CHAR(8)                             NULL,
    RSRV3                   INT                                 NULL,
    CONSTRAINT PK_TF_XFC_BATCHSELL PRIMARY KEY(TRADEID)
)
/




--充值卡现金台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_XFC_SELLFEE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_XFC_SELLFEE (
    TRADEID                 CHAR(16)                        NOT NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    STARTCARDNO             CHAR(14)                            NULL,
    ENDCARDNO               CHAR(14)                            NULL,
    MONEY                   INT                                 NULL,
    STAFFNO                 CHAR(6)                             NULL,
    OPERATETIME             DATE                                NULL,
    REMARK                  VARCHAR2(50)                        NULL,
    RSRV1                   CHAR(1)                             NULL,
    RSRV2                   CHAR(8)                             NULL,
    RSRV3                   INT                                 NULL,
    CONSTRAINT PK_TF_XFC_SELLFEE PRIMARY KEY(TRADEID)
)
/




--业务写卡台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_CARD_TRADE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_CARD_TRADE (
    TRADEID                 CHAR(16)                        NOT NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    strOperCardNo           CHAR(16)                            NULL,
    strCardNo               CHAR(16)                            NULL,
    lMoney                  INT              DEFAULT 0          NULL,
    lOldMoney               INT              DEFAULT 0          NULL,
    strTermno               CHAR(12)                            NULL,
    strEndDateNum           CHAR(12)                            NULL,
    strFlag                 CHAR(4)                             NULL,
    strStaffno              CHAR(6)                             NULL,
    strTaxino               CHAR(8)                             NULL,
    strState                CHAR(2)                             NULL,
    Cardtradeno             CHAR(4)                             NULL,
    NextCardtradeno         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    SUCTAG                  CHAR(1)          DEFAULT '0'        NULL,
    strErrInfo              VARCHAR2(150)                       NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   DATE                                NULL,
    writeCardScript         VARCHAR2(1024)                      NULL,
    CONSTRAINT PK_TF_CARD_TRADE PRIMARY KEY(TRADEID)
)
/




--业务补写卡台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_CARD_RETRADE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_CARD_RETRADE (
    TRADEID                 CHAR(16)                        NOT NULL,
    ID                      CHAR(16)                            NULL,
    CARDNO                  CHAR(16)                            NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATETIME             DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   DATE                                NULL,
    CONSTRAINT PK_TF_CARD_RETRADE PRIMARY KEY(TRADEID)
)
/




--退款业务台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_REFUND CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_REFUND (
    TRADEID                 CHAR(16)                        NOT NULL,
    ID                      CHAR(18)                            NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    CARDNO                  CHAR(16)                            NULL,
    BANKCODE                CHAR(4)                             NULL,
    BANKACCNO               VARCHAR2(30)                        NULL,
    BACKMONEY               INT                                 NULL,
    CUSTNAME                VARCHAR2(50)                        NULL,
    BACKSLOPE               NUMERIC(10,8)                       NULL,
    FACTMONEY               INT                                 NULL,
    COLLECTTAG              CHAR(2)          DEFAULT '01'       NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATETIME             DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   DATE                                NULL,
    PURPOSETYPE             CHAR(1)                         NOT NULL,
    CONSTRAINT PK_TF_B_REFUND PRIMARY KEY(TRADEID)
)
/




--退款业务台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_REFUND CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_REFUND (
    TRADEID                 CHAR(16)                        NOT NULL,
    ID                      CHAR(18)                            NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    CARDNO                  CHAR(16)                            NULL,
    BANKCODE                CHAR(4)                             NULL,
    BANKACCNO               VARCHAR2(30)                        NULL,
    BACKMONEY               INT                                 NULL,
    CUSTNAME                VARCHAR2(50)                        NULL,
    BACKSLOPE               NUMERIC(10,8)                       NULL,
    FACTMONEY               INT                                 NULL,
    COLLECTTAG              CHAR(2)          DEFAULT '01'       NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATETIME             DATE                                NULL,
    REMARK                  VARCHAR2(50)                        NULL,
    STATE                   CHAR(1)                             NULL,
    TRADEDATE               CHAR(8)                             NULL,
    PURPOSETYPE             CHAR(1)                         NOT NULL,
    CONSTRAINT PK_TF_B_REFUND PRIMARY KEY(TRADEID)
)
/




--特殊圈存台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_SPELOAD CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_SPELOAD (
    TRADEID                 CHAR(16)                        NOT NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    CARDNO                  CHAR(16)                            NULL,
    TRADEMONEY              INT                                 NULL,
    TRADEDATE               DATE                                NULL,
    TRADETIMES              INT                                 NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    STATECODE               CHAR(1)                             NULL,
    INPUTSTAFFNO            CHAR(6)                             NULL,
    INPUTTIME               DATE                                NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATETIME             DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   DATE                                NULL,
    RSRV4                   INT                                 NULL,
    CONSTRAINT PK_TF_B_SPELOAD PRIMARY KEY(TRADEID)
)
/




--特殊调帐台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_SPEADJUSTACC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_SPEADJUSTACC (
    TRADEID                 CHAR(16)                        NOT NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    ID                      CHAR(30)                        NOT NULL,
    CARDNO                  CHAR(16)                        NOT NULL,
    CARDTRADENO             CHAR(4)                             NULL,
    TRADEDATE               CHAR(8)                             NULL,
    TRADETIME               CHAR(6)                             NULL,
    PREMONEY                INT                                 NULL,
    TRADEMONEY              INT                                 NULL,
    REFUNDMENT              INT                                 NULL,
    CUSTPHONE               VARCHAR2(40)                        NULL,
    CUSTNAME                VARCHAR2(50)                        NULL,
    CALLINGNO               CHAR(2)                             NULL,
    CORPNO                  CHAR(4)                             NULL,
    DEPARTNO                CHAR(4)                             NULL,
    BALUNITNO               CHAR(8)                             NULL,
    REASONCODE              CHAR(1)                             NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    STATECODE               CHAR(1)                         NOT NULL,
    STAFFNO                 CHAR(6)                             NULL,
    OPERATETIME             DATE                                NULL,
    CHECKSTAFFNO            CHAR(6)                             NULL,
    CHECKTIME               DATE                                NULL,
    SUPPTRADEID             CHAR(16)                            NULL,
    SUPPSTAFFNO             CHAR(6)                             NULL,
    SUPPTIME                DATE                                NULL,
    RSRVCHAR                CHAR(2)                             NULL,
    REBROKERAGE             INT                                 NULL,
    CONSTRAINT PK_TF_B_SPEADJUSTACC PRIMARY KEY(TRADEID)
)
/




--特殊调帐金额向电子钱包充值台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_SPEADJUST_SUPPLY CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_SPEADJUST_SUPPLY (
    TRADEID                 CHAR(16)                        NOT NULL,
    ID                      CHAR(18)                            NULL,
    CARDNO                  CHAR(16)                            NULL,
    ASN                     CHAR(16)                            NULL,
    CARDTYPECODE            CHAR(2)                             NULL,
    CARDTRADENO             CHAR(4)                             NULL,
    TRADEMONEY              INT              DEFAULT 0          NULL,
    PREMONEY                INT              DEFAULT 0          NULL,
    TERMNO                  CHAR(12)                            NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    CONSTRAINT PK_TF_SPEADJUST_SUPPLY PRIMARY KEY(TRADEID)
)
/




--卡内交易记录台帐主表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_CARD_RECQUY CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_CARD_RECQUY (
    TRADEID                 CHAR(16)                        NOT NULL,
    CARDNO                  CHAR(16)                            NULL,
    AMOUNT                  INT                                 NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    CARDMONEY               INT                                 NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   DATE                                NULL,
    CONSTRAINT PK_TF_CARD_RECQUY PRIMARY KEY(TRADEID)
)
/




--卡内交易记录台帐子表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_CARD_RECLIST CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_CARD_RECLIST (
    TRADEID                 CHAR(16)                        NOT NULL,
    SEQ                     INT                             NOT NULL,
    CARDTRADENO             CHAR(4)                             NULL,
    PREMONEY                VARCHAR2(8)                         NULL,
    TRADEMONEY              VARCHAR2(8)                         NULL,
    ICTRADETYPECODE         CHAR(2)                             NULL,
    SAMNO                   CHAR(12)                            NULL,
    TRADEDATE               CHAR(8)                             NULL,
    TRADETIME               CHAR(6)                             NULL,
    CONSTRAINT PK_TF_CARD_RECLIST PRIMARY KEY(TRADEID, SEQ)
)
/




--现金返销授权台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_FEEROLLBACK CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_FEEROLLBACK (
    TRADEID                 CHAR(16)                        NOT NULL,
    CANCELTRADEID           CHAR(16)                        NOT NULL,
    CANCELTAG               CHAR(1)                             NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    RSRV1                   INT                                 NULL,
    RSRV2                   VARCHAR2(20)                        NULL,
    RSRV3                   VARCHAR2(20)                        NULL,
    CONSTRAINT PK_TF_B_FEEROLLBACK PRIMARY KEY(TRADEID)
)
/




--礼金卡扩展业务台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_TRADE_CASHGIFT CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_TRADE_CASHGIFT (
    TRADEID                 CHAR(16)                        NOT NULL,
    CARDNO                  CHAR(16)                        NOT NULL,
    ID                      CHAR(18)                            NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    ASN                     CHAR(16)                            NULL,
    WALLET1                 INTEGER          DEFAULT 0          NULL,
    WALLET2                 INTEGER          DEFAULT 0          NULL,
    CARDSTARTDATE           CHAR(8)                             NULL,
    CARDENDDATE             CHAR(8)                             NULL,
    DBSTARTDATE             CHAR(8)                             NULL,
    DBENDDATE               CHAR(8)                             NULL,
    DELAYENDDATE            CHAR(8)                             NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    CONSTRAINT PK_TF_B_TRADE_CASHGIFT PRIMARY KEY(TRADEID, CARDNO)
)
/




--卡卡转账记录台账表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_CARDTOCARDREG CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_CARDTOCARDREG (
    TRADEID                 CHAR(16)                        NOT NULL,
    OUTCARDNO               CHAR(16)                        NOT NULL,
    INCARDNO                CHAR(16)                            NULL,
    MONEY                   INT                                 NULL,
    OUTSTAFFNO              CHAR(6)                             NULL,
    OUTDEPTNO               CHAR(4)                             NULL,
    OUTTIME                 DATE                                NULL,
    INSTAFFNO               CHAR(6)                             NULL,
    INDEPTNO                CHAR(4)                             NULL,
    INTIME                  DATE                                NULL,
    TRANSTATE               CHAR(1)                             NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_B_CARDTOCARDREG PRIMARY KEY(TRADEID)
)
/




--批量售卡审批台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_BATCHSALECARD CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_BATCHSALECARD (
    TRADEID                 CHAR(16)                        NOT NULL,
    BEGINCARDNO             CHAR(16)                            NULL,
    ENDCARDNO               CHAR(16)                            NULL,
    CARDDEPOSIT             INT                                 NULL,
    CARDCOST                INT                                 NULL,
    SELLTIME                DATE                                NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    CHECKSTAFFNO            CHAR(6)                             NULL,
    CHECKDEPARTID           CHAR(4)                             NULL,
    CHECKTIME               DATE                                NULL,
    STATECODE               CHAR(1)                             NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_B_BATCHSALECARD PRIMARY KEY(TRADEID)
)
/




--换卡转值限制台账表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_TRANSITLIMIT CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_TRANSITLIMIT (
    TRADEID                 CHAR(16)                        NOT NULL,
    CARDNO                  CHAR(16)                        NOT NULL,
    STATE                   CHAR(1)                             NULL,
    ADDTIME                 DATE                                NULL,
    ADDSTAFFNO              CHAR(6)                             NULL,
    DELETETIME              DATE                                NULL,
    DELETESTAFFNO           CHAR(6)                             NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_B_TRANSITLIMIT PRIMARY KEY(TRADEID)
)
/




--服务日志表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_XXSERVICELOG CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_XXSERVICELOG (
    ID                      CHAR(20)                        NOT NULL,
    GARDENXXCARDID          CHAR(20)                            NULL,
    CARDNO                  CHAR(16)                            NULL,
    TRANSTIME               DATE                                NULL,
    RETCODE                 VARCHAR2(10)                        NULL,
    RETMSG                  VARCHAR2(100)                       NULL,
    UPDATETIME              DATE                                NULL,
    RSVR                    VARCHAR2(255)                       NULL,
    CONSTRAINT PK_TF_B_XXSERVICELOG PRIMARY KEY(ID)
)
/




--服务日志表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_SERVICELOG CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_SERVICELOG (
    ID                      CHAR(20)                        NOT NULL,
    GARDENCARDID            CHAR(20)                            NULL,
    CARDNO                  CHAR(16)                            NULL,
    TRANSTIME               DATE                                NULL,
    RETCODE                 VARCHAR2(10)                        NULL,
    RETMSG                  VARCHAR2(100)                       NULL,
    UPDATETIME              DATE                                NULL,
    RSVR                    VARCHAR2(255)                       NULL,
    CONSTRAINT PK_TF_B_SERVICELOG PRIMARY KEY(ID)
)
/




--同步园林数据表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_GARDENCARD CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_GARDENCARD (
    ID                      CHAR(20)                        NOT NULL,
    CARDNO                  CHAR(16)                        NOT NULL,
    ASN                     CHAR(16)                        NOT NULL,
    PAPERTYPE               VARCHAR2(2)                         NULL,
    PAPERNO                 VARCHAR2(20)                        NULL,
    CUSTNAME                VARCHAR2(200)                       NULL,
    CARDTIME                DATE                                NULL,
    ENDDATE                 VARCHAR2(8)                         NULL,
    TIMES                   INT                                 NULL,
    TRADETYPE               CHAR(1)                         NOT NULL,
    OLDCARDNO               CHAR(16)                            NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    DEALTYPE                CHAR(1)                             NULL,
    RETMSG                  VARCHAR2(512)                       NULL,
    ATTEMPTTIMES            INT              DEFAULT 0          NULL,
    DEPARTID                CHAR(4)                             NULL,
    TRADEID                 CHAR(16)                            NULL,
    CONSTRAINT PK_TF_B_GARDENCARD PRIMARY KEY(ID)
)
/




--同步休闲数据表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_GARDENXXCARD CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_GARDENXXCARD (
    XXTRADEID               CHAR(16)                        NOT NULL,
    ID                      CHAR(20)                        NOT NULL,
    CARDNO                  CHAR(16)                        NOT NULL,
    ASN                     CHAR(16)                        NOT NULL,
    PAPERTYPE               VARCHAR2(2)                         NULL,
    PAPERNO                 VARCHAR2(200)                       NULL,
    CUSTNAME                VARCHAR2(200)                       NULL,
    CARDTIME                DATE                                NULL,
    ENDDATE                 VARCHAR2(8)                         NULL,
    TIMES                   INT                                 NULL,
    TRADETYPE               CHAR(1)                         NOT NULL,
    OLDCARDNO               CHAR(16)                            NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    DEALTYPE                CHAR(1)                             NULL,
    RETMSG                  VARCHAR2(512)                       NULL,
    ATTEMPTTIMES            INT              DEFAULT 0          NULL,
    PACKAGETYPE             CHAR(2)                             NULL,
    USETAG                  CHAR(1)                             NULL,
    HOTSPRING               CHAR(1)                             NULL,
    ISOFFLINE               CHAR(1)                             NULL,
    SYNTELDEALTYPE          CHAR(1)                             NULL,
    SYNTELRETMSG            VARCHAR2(512)                       NULL,
    SYNTELATTEMPTTIMES      INT              DEFAULT 0          NULL,
    DEPARTID                CHAR(4)                             NULL,
    TRADEID                 CHAR(16)                            NULL,
    CHANNELTYPECODE         CHAR(2)                             NULL,
    CONSTRAINT PK_TF_B_GARDENXXCARD PRIMARY KEY(XXTRADEID)
)
/




--批量业务台账表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_TRADE_BATCH CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_TRADE_BATCH (
    TRADEID                 CHAR(16)                        NOT NULL,
    BATCHID                 CHAR(20)                        NOT NULL,
    OPERATETYPECODE         CHAR(2)                         NOT NULL,
    TRADETYPECODE           CHAR(2)                         NOT NULL,
    OPERATESTAFFNO          CHAR(6)                         NOT NULL,
    OPERATEDEPARTID         CHAR(4)                         NOT NULL,
    OPERATETIME             DATE                            NOT NULL,
    OPERCARDNO              CHAR(16)                        NOT NULL,
    NEEDCOUNT               INT                                 NULL,
    CURRNETMONEY            INT                                 NULL,
    SUCCOUNT                INT                                 NULL,
    ERRCOUNT                INT                                 NULL,
    SUCCARDNO               VARCHAR2(2000)                      NULL,
    ERRCARDNO               VARCHAR2(2000)                      NULL,
    ERRMSG                  VARCHAR2(100)                       NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_B_TRADE_BATCH PRIMARY KEY(TRADEID)
)
/




--批量业务台账子表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_TRADE_BATCHLIST CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_TRADE_BATCHLIST (
    TRADEID                 CHAR(16)                        NOT NULL,
    BATCHID                 CHAR(20)                            NULL,
    CARDNO                  CHAR(16)                            NULL,
    OPERATETYPECODE         CHAR(2)                             NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATETIME             DATE                                NULL,
    ASN                     CHAR(16)                            NULL,
    WALLET1                 INT                                 NULL,
    WALLET2                 INT                                 NULL,
    VALIDBEGINDATE          CHAR(8)                             NULL,
    VALIDENDDATE            CHAR(8)                             NULL,
    ONLINETRADENO           CHAR(4)                             NULL,
    OFFLINETRADENO          CHAR(4)                             NULL,
    SUCCESSTAG              CHAR(1)                             NULL,
    ERRMSG                  VARCHAR2(200)                       NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_B_TRADE_BATCHLIST PRIMARY KEY(TRADEID)
)
/




--休闲卡开卡及业务类型台帐汇总表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_OPENGARDENXXCARD_TOTAL CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_OPENGARDENXXCARD_TOTAL (
    ID                      CHAR(20)                        NOT NULL,
    TRADEDATE               CHAR(10)                        NOT NULL,
    DEPTNAME                CHAR(4)                         NOT NULL,
    OPENTYPECODE            CHAR(2)                         NOT NULL,
    TRADETYPECODE           CHAR(2)                         NOT NULL,
    CARDCOUNT               INT              DEFAULT 0          NULL,
    TOTLEMONEY              INT                                 NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    INISTIME                DATE                                NULL,
    DEALCODE                CHAR(1)                             NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    ATTEMPTTIMES            INT                                 NULL,
    CONSTRAINT PK_TF_B_OPENGARDENXXCARD_TOTAL PRIMARY KEY(ID)
)
/




--园林卡开卡及业务类型台帐表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_OPENGARDENCARD_TOTAL CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_OPENGARDENCARD_TOTAL (
    ID                      CHAR(20)                        NOT NULL,
    TRADEDATE               CHAR(10)                        NOT NULL,
    DEPTNAME                CHAR(4)                         NOT NULL,
    OPENTYPECODE            CHAR(2)                         NOT NULL,
    TRADETYPECODE           CHAR(2)                         NOT NULL,
    CARDCOUNT               INT              DEFAULT 0          NULL,
    TOTLEMONEY              INT                                 NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    INISTIME                DATE                                NULL,
    DEALCODE                CHAR(1)                             NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    ATTEMPTTIMES            INT                                 NULL,
    CONSTRAINT PK_TF_B_OPENGARDENCARD_TOTAL PRIMARY KEY(ID)
)
/





