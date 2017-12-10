--联机休闲年卡订单表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_XXOL_ORDER CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_XXOL_ORDER (
    ORDERNO                 VARCHAR2(32)                    NOT NULL,
    ORDERTYPE               CHAR(1)                             NULL,
    ORDERSTATES             CHAR(1)                             NULL,
    ISREJECT                CHAR(1)                             NULL,
    ORDERTOTAL              INT                                 NULL,
    POSTAGE                 INT                                 NULL,
    CARDCOST                INT                                 NULL,
    FUNCFEE                 INT                                 NULL,
    DISCOUNT                INT                                 NULL,
    PAYCANAL                CHAR(2)                             NULL,
    PAYTRADEID              VARCHAR2(32)                        NULL,
    CUSTNAME                VARCHAR2(100)                       NULL,
    ADDRESS                 VARCHAR2(500)                       NULL,
    CUSTPHONE               VARCHAR2(100)                       NULL,
    CUSTPOST                VARCHAR2(6)                         NULL,
    REMARK                  VARCHAR2(200)                       NULL,
    TRACKINGCOPCODE         CHAR(2)                             NULL,
    TRACKINGNO              VARCHAR2(32)                        NULL,
    ISDISTRABUTION          CHAR(1)          DEFAULT '0'        NULL,
    DISTRABUTIONMSG         VARCHAR2(200)                       NULL,
    CREATETIME              DATE                                NULL,
    INSTIME                 DATE                                NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATEDEPARTID          CHAR(4)                             NULL,
    UPDATETIME              DATE                                NULL,
    CONSTRAINT PK_TF_F_XXOL_ORDER PRIMARY KEY(ORDERNO)
)tablespace TBSapp_B_SZ
/


grant Select on TF_F_XXOL_ORDER to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Insert on TF_F_XXOL_ORDER to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Update on TF_F_XXOL_ORDER to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Delete on TF_F_XXOL_ORDER to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;


--联机休闲年卡订单明细表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_XXOL_ORDERDETAIL CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_XXOL_ORDERDETAIL (
    ORDERDETAILID           VARCHAR2(32)                    NOT NULL,
    ORDERNO                 VARCHAR2(32)                        NULL,
    DETAILSTATES            CHAR(1)                             NULL,
    CARDNO                  VARCHAR2(20)                        NULL,
    CARDCOST                INT                                 NULL,
    FUNCFEE                 INT                                 NULL,
    DISCOUNT                INT                                 NULL,
    PACKAGETYPE             CHAR(2)                             NULL,
    ISREJECT                CHAR(1)                             NULL,
    CUSTNAME                VARCHAR2(100)                       NULL,
    PAPERTYPE               CHAR(2)                             NULL,
    PAPERNO                 VARCHAR2(100)                       NULL,
    CUSTPHONE               VARCHAR2(100)                       NULL,
    ADDRESS                 VARCHAR2(200)                       NULL,
    CUSTPOST                VARCHAR2(200)                       NULL,
    CUSTSEX                 VARCHAR2(2)                         NULL,
    CUSTBIRTH               VARCHAR2(8)                         NULL,
    CUSTEMAIL               VARCHAR2(30)                        NULL,
    PHTOT                   BLOB                                NULL,
    PAPERPHTOT              BLOB                                NULL,
    REMARK                  VARCHAR2(200)                       NULL,
    ENCRYPTCUSTNAME         VARCHAR2(250)                       NULL,
    ENCRYPTPAPERNO          VARCHAR2(200)                       NULL,
    ENCRYPTCUSTPHONE        VARCHAR2(100)                       NULL,
    ENCRYPTADDRESS          VARCHAR2(600)                       NULL,
    AUDITNOTE               VARCHAR2(200)                       NULL,
    CREATETIME              DATE                                NULL,
    INSTIME                 DATE                                NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATEDEPARTID          CHAR(4)                             NULL,
    UPDATETIME              DATE                                NULL,
    DISCOUNTTRADEID         CHAR(16)                            NULL,
    CONSTRAINT PK_TF_F_XXOL_ORDERDETAIL PRIMARY KEY(ORDERDETAILID)
)tablespace TBSapp_B_SZ
/


grant Select on TF_F_XXOL_ORDERDETAIL to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Insert on TF_F_XXOL_ORDERDETAIL to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Update on TF_F_XXOL_ORDERDETAIL to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Delete on TF_F_XXOL_ORDERDETAIL to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;


--订单操作台账表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_XXOL_TRADE CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_XXOL_TRADE (
    TRADEID                 VARCHAR2(32)                    NOT NULL,
    ORDERNO                 VARCHAR2(32)                        NULL,
    ORDERDETAILID           VARCHAR2(32)                        NULL,
    TRADETYPECODE           CHAR(2)                             NULL,
    CARDNO                  VARCHAR2(32)                        NULL,
    TRACKINGNO              VARCHAR2(30)                        NULL,
    AUDITNOTE               VARCHAR2(200)                       NULL,
    OPERATETIME             DATE                                NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATEDEPARTID          CHAR(4)                             NULL,
    CONSTRAINT PK_TF_B_XXOL_TRADE PRIMARY KEY(TRADEID)
)tablespace TBSapp_B_SZ
/


grant Select on TF_B_XXOL_TRADE to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Insert on TF_B_XXOL_TRADE to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Update on TF_B_XXOL_TRADE to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Delete on TF_B_XXOL_TRADE to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;


--联机同步接口表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_B_XXOL_SYNC CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_B_XXOL_SYNC (
    TRADEID                 VARCHAR2(32)                    NOT NULL,
    SYNCTRADETYPE           CHAR(4)                             NULL,
    ORDERNO                 VARCHAR2(32)                        NULL,
    TRADETYPECODE           CHAR(1)                             NULL,
    SYNCCODE                CHAR(1)                             NULL,
    OPERATETIME             DATE                                NULL,
    RESPCODE                CHAR(4)                             NULL,
    RESPDESC                VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_B_XXOL_SYNC PRIMARY KEY(TRADEID)
)tablespace TBSapp_B_SZ
/


grant Select on TF_B_XXOL_SYNC to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Insert on TF_B_XXOL_SYNC to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Update on TF_B_XXOL_SYNC to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Delete on TF_B_XXOL_SYNC to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;


--联机休闲年卡订单临时表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_TMP_XXOL_ORDERDETAIL CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_TMP_XXOL_ORDERDETAIL (
    DETAILID                VARCHAR2(32)                        NULL,
    ORDERNO                 VARCHAR2(32)                        NULL,
    CARDNO                  VARCHAR2(20)                        NULL,
    CARDCOST                INT                                 NULL,
    FUNCFEE                 INT                                 NULL,
    DISCOUNT                INT                                 NULL,
    PACKAGETYPE             CHAR(2)                             NULL,
    CUSTNAME                VARCHAR2(100)                       NULL,
    PAPERTYPE               CHAR(2)                             NULL,
    PAPERNO                 VARCHAR2(100)                       NULL,
    CUSTPHONE               VARCHAR2(100)                       NULL,
    ADDRESS                 VARCHAR2(200)                       NULL,
    CUSTPOST                VARCHAR2(6)                         NULL,
    CUSTSEX                 VARCHAR2(2)                         NULL,
    CUSTBIRTH               VARCHAR2(8)                         NULL,
    CUSTEMAIL               VARCHAR2(30)                        NULL,
    ENCRYPTCUSTNAME         VARCHAR2(250)                       NULL,
    ENCRYPTPAPERNO          VARCHAR2(200)                       NULL,
    ENCRYPTCUSTPHONE        VARCHAR2(100)                       NULL,
    ENCRYPTADDRESS          VARCHAR2(600)                       NULL,
    REMARK                  VARCHAR2(200)                       NULL,
    UPDATETIME              DATE                                NULL,
    DISCOUNTTRADEID         CHAR(16)                            NULL
)tablespace TBSapp_B_SZ
/


grant Select on TF_TMP_XXOL_ORDERDETAIL to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Insert on TF_TMP_XXOL_ORDERDETAIL to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Update on TF_TMP_XXOL_ORDERDETAIL to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Delete on TF_TMP_XXOL_ORDERDETAIL to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;


--休闲持卡人信息变更表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDPARKCUSTOMERREC_SZ CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDPARKCUSTOMERREC_SZ (
    CARDNO                  CHAR(16)                        NOT NULL,
    TRADEDATE               CHAR(8)                             NULL,
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
    STATE                   CHAR(1)                             NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_CARDPARKCUSTOMERREC_SZ PRIMARY KEY(CARDNO)
)tablespace TBSapp_B_SZ
/


grant Select on TF_F_CARDPARKCUSTOMERREC_SZ to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Insert on TF_F_CARDPARKCUSTOMERREC_SZ to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Update on TF_F_CARDPARKCUSTOMERREC_SZ to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Delete on TF_F_CARDPARKCUSTOMERREC_SZ to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;


--休闲卡号照片对应关系变更表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_F_CARDPARKPHOTOCHANGE_SZ CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_F_CARDPARKPHOTOCHANGE_SZ (
    CARDNO                  CHAR(16)                        NOT NULL,
    PICTURE                 BLOB                                NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    STATE                   CHAR(1)                             NULL,
    CONSTRAINT PK_TF_F_CARDPARKPHOTOCHANGE_SZ PRIMARY KEY(CARDNO)
)tablespace TBSapp_B_SZ
/


grant Select on TF_F_CARDPARKPHOTOCHANGE_SZ to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Insert on TF_F_CARDPARKPHOTOCHANGE_SZ to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Update on TF_F_CARDPARKPHOTOCHANGE_SZ to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Delete on TF_F_CARDPARKPHOTOCHANGE_SZ to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;


--物流公司配置表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TD_M_TRACKINGCOP CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TD_M_TRACKINGCOP (
    TRACKINGCOPCODE         CHAR(2)                         NOT NULL,
    TRACKINGCOPNAME         VARCHAR2(32)                        NULL,
    USETAG                  CHAR(1)                             NULL,
    UPDATEDEPARTID          CHAR(4)                             NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    CONSTRAINT PK_TD_M_TRACKINGCOP PRIMARY KEY(TRACKINGCOPCODE)
)tablespace TBSapp_B_SZ
/


grant Select on TD_M_TRACKINGCOP to Uqry_B_SZ,Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Insert on TD_M_TRACKINGCOP to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Update on TD_M_TRACKINGCOP to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;
grant Delete on TD_M_TRACKINGCOP to Ucrapp_B_SZ,Uopapp_B_SZ,Uopsett_B_SZ;



