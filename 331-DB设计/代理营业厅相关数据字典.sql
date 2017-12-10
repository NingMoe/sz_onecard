--网点结算单元编码表

/

CREATE TABLE TF_DEPT_BALUNIT (
    DBALUNITNO              CHAR(8)                         NOT NULL,
    DBALUNIT                VARCHAR2(50)                    NOT NULL,
    BANKCODE                CHAR(4)                         NOT NULL,
    BANKACCNO               VARCHAR2(30)                        NULL,
    CREATETIME              DATE                            NOT NULL,
    BALCYCLETYPECODE        CHAR(2)                         NOT NULL,
    BALINTERVAL             INT                             NOT NULL,
    FINCYCLETYPECODE        CHAR(2)                         NOT NULL,
    FININTERVAL             INT                             NOT NULL,
    FINTYPECODE             CHAR(1)                         NOT NULL,
    FINBANKCODE             CHAR(4)                             NULL,
    LINKMAN                 VARCHAR2(20)                        NULL,
    UNITPHONE               VARCHAR2(20)                        NULL,
    UNITADD                 VARCHAR2(50)                        NULL,
    UNITEMAIL               VARCHAR2(50)                        NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    DEPTTYPE                CHAR(1)                         NOT NULL,
    PREPAYWARNLINE          INT                             NOT NULL,
    PREPAYLIMITLINE         INT                             NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_DEPT_BALUNIT PRIMARY KEY(DBALUNITNO)
)tablespace TBSdata_B_CZ
/


grant Select on TF_DEPT_BALUNIT to Ucrapp_B_CZ;
grant Insert on TF_DEPT_BALUNIT to Ucrapp_B_CZ;
grant Update on TF_DEPT_BALUNIT to Ucrapp_B_CZ;
grant Delete on TF_DEPT_BALUNIT to Ucrapp_B_CZ;


--网点佣金方案编码表

/

CREATE TABLE TF_DEPT_COMSCHEME (
    DCOMSCHEMENO            CHAR(8)                         NOT NULL,
    NAME                    VARCHAR2(12)                    NOT NULL,
    TYPECODE                CHAR(1)                         NOT NULL,
    DATACODE                CHAR(1)                         NOT NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_DEPT_COMSCHEME PRIMARY KEY(DCOMSCHEMENO)
)tablespace TBSdata_B_CZ
/


grant Select on TF_DEPT_COMSCHEME to Ucrapp_B_CZ;
grant Insert on TF_DEPT_COMSCHEME to Ucrapp_B_CZ;
grant Update on TF_DEPT_COMSCHEME to Ucrapp_B_CZ;
grant Delete on TF_DEPT_COMSCHEME to Ucrapp_B_CZ;


--网点结算单元-佣金方案对应关系表

/

CREATE TABLE TD_DEPTBAL_COMSCHEME (
    ID                      CHAR(8)                         NOT NULL,
    DBALUNITNO              CHAR(8)                         NOT NULL,
    DCOMSCHEMENO            CHAR(8)                         NOT NULL,
    TRADETYPECODE           CHAR(2)                         NOT NULL,
    CANCELTRADE             CHAR(2)                             NULL,
    BEGINTIME               DATE                                NULL,
    ENDTIME                 DATE                                NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                            NOT NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_DEPTBAL_COMSCHEME PRIMARY KEY(ID)
)tablespace TBSdata_B_CZ
/


grant Select on TD_DEPTBAL_COMSCHEME to Ucrapp_B_CZ;
grant Insert on TD_DEPTBAL_COMSCHEME to Ucrapp_B_CZ;
grant Update on TD_DEPTBAL_COMSCHEME to Ucrapp_B_CZ;
grant Delete on TD_DEPTBAL_COMSCHEME to Ucrapp_B_CZ;


--网点佣金方案-佣金规则对应关系表

/

CREATE TABLE TD_DEPTCOMSCH_COMRULE (
    DCOMSCHEMENO            CHAR(8)                         NOT NULL,
    COMRULENO               CHAR(8)                         NOT NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                            NOT NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_DEPTCOMSCH_COMRULE PRIMARY KEY(DCOMSCHEMENO, COMRULENO)
)tablespace TBSdata_B_CZ
/


grant Select on TD_DEPTCOMSCH_COMRULE to Ucrapp_B_CZ;
grant Insert on TD_DEPTCOMSCH_COMRULE to Ucrapp_B_CZ;
grant Update on TD_DEPTCOMSCH_COMRULE to Ucrapp_B_CZ;
grant Delete on TD_DEPTCOMSCH_COMRULE to Ucrapp_B_CZ;


--内部部门-网点结算单元关系表

/

CREATE TABLE TD_DEPTBAL_RELATION (
    DEPARTNO                CHAR(4)                         NOT NULL,
    DBALUNITNO              CHAR(8)                         NOT NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                            NOT NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_DEPTBAL_RELATION PRIMARY KEY(DEPARTNO, DBALUNITNO)
)tablespace TBSdata_B_CZ
/


grant Select on TD_DEPTBAL_RELATION to Ucrapp_B_CZ;
grant Insert on TD_DEPTBAL_RELATION to Ucrapp_B_CZ;
grant Update on TD_DEPTBAL_RELATION to Ucrapp_B_CZ;
grant Delete on TD_DEPTBAL_RELATION to Ucrapp_B_CZ;


--网点结算信息变更事件表

/

CREATE TABLE TD_DEPT_BALEVENT (
    ID                      CHAR(16)                        NOT NULL,
    DEVENTTYPECODE          CHAR(4)                         NOT NULL,
    DBALUNITNO              CHAR(8)                             NULL,
    PARAM1                  VARCHAR2(32)                        NULL,
    PARAM2                  VARCHAR2(64)                        NULL,
    DEALSTATECODE1          CHAR(1)                             NULL,
    DEALSTATECODE2          CHAR(1)                             NULL,
    OCCURTIME               DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_DEPT_BALEVENT PRIMARY KEY(ID)
)tablespace TBSdata_B_CZ
/


grant Select on TD_DEPT_BALEVENT to Ucrapp_B_CZ;
grant Insert on TD_DEPT_BALEVENT to Ucrapp_B_CZ;
grant Update on TD_DEPT_BALEVENT to Ucrapp_B_CZ;
grant Delete on TD_DEPT_BALEVENT to Ucrapp_B_CZ;


--网点结算单元业务台帐主表

/

CREATE TABLE TF_B_DEPTBALTRADE (
    TRADEID                 CHAR(16)                        NOT NULL,
    DTRADETYPECODE          CHAR(2)                             NULL,
    ASSOCIATECODE           VARCHAR2(8)                         NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    CHECKSTAFFNO            CHAR(6)                             NULL,
    CHECKDEPARTNO           CHAR(4)                             NULL,
    CHECKTIME               DATE                                NULL,
    STATECODE               CHAR(1)                             NULL,
    CANCELTAG               CHAR(1)                             NULL,
    CONSTRAINT PK_TF_B_DEPTBALTRADE PRIMARY KEY(TRADEID)
)tablespace TBSapp_B_CZ
/


grant Select on TF_B_DEPTBALTRADE to Ucrapp_B_CZ;
grant Insert on TF_B_DEPTBALTRADE to Ucrapp_B_CZ;
grant Update on TF_B_DEPTBALTRADE to Ucrapp_B_CZ;
grant Delete on TF_B_DEPTBALTRADE to Ucrapp_B_CZ;


--网点结算单元业务台帐审核表

/

CREATE TABLE TF_B_DEPTBALTRADE_EXAM (
    TRADEID                 CHAR(16)                        NOT NULL,
    DTRADETYPECODE          CHAR(2)                             NULL,
    ASSOCIATECODE           VARCHAR2(8)                         NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    EXAMSTAFFNO             CHAR(6)                             NULL,
    EXAMDEPARTNO            CHAR(4)                             NULL,
    EXAMKTIME               DATE                                NULL,
    STATECODE               CHAR(1)                             NULL,
    CANCELTAG               CHAR(1)                             NULL,
    CONSTRAINT PK_TF_B_DEPTBALTRADE_EXAM PRIMARY KEY(TRADEID)
)tablespace TBSapp_B_CZ
/


grant Select on TF_B_DEPTBALTRADE_EXAM to Ucrapp_B_CZ;
grant Insert on TF_B_DEPTBALTRADE_EXAM to Ucrapp_B_CZ;
grant Update on TF_B_DEPTBALTRADE_EXAM to Ucrapp_B_CZ;
grant Delete on TF_B_DEPTBALTRADE_EXAM to Ucrapp_B_CZ;


--网点结算单元编码历史表

/

CREATE TABLE TH_DEPT_BALUNIT (
    TRADEID                 CHAR(16)                        NOT NULL,
    DBALUNITNO              CHAR(8)                         NOT NULL,
    DBALUNIT                VARCHAR2(50)                    NOT NULL,
    BANKCODE                CHAR(4)                         NOT NULL,
    BANKACCNO               VARCHAR2(30)                        NULL,
    CREATETIME              DATE                            NOT NULL,
    BALCYCLETYPECODE        CHAR(2)                         NOT NULL,
    BALINTERVAL             INT                             NOT NULL,
    FINCYCLETYPECODE        CHAR(2)                         NOT NULL,
    FININTERVAL             INT                             NOT NULL,
    FINTYPECODE             CHAR(1)                         NOT NULL,
    FINBANKCODE             CHAR(4)                             NULL,
    LINKMAN                 VARCHAR2(20)                        NULL,
    UNITPHONE               VARCHAR2(20)                        NULL,
    UNITADD                 VARCHAR2(50)                        NULL,
    UNITEMAIL               VARCHAR2(200)                       NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    DEPTTYPE                CHAR(1)                         NOT NULL,
    PREPAYWARNLINE          INT                             NOT NULL,
    PREPAYLIMITLINE         INT                             NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TH_DEPT_BALUNIT PRIMARY KEY(TRADEID)
)tablespace TBSapp_B_CZ
/


grant Select on TH_DEPT_BALUNIT to Ucrapp_B_CZ;
grant Insert on TH_DEPT_BALUNIT to Ucrapp_B_CZ;
grant Update on TH_DEPT_BALUNIT to Ucrapp_B_CZ;
grant Delete on TH_DEPT_BALUNIT to Ucrapp_B_CZ;


--网点结算单元-佣金方案对应关系历史表

/

CREATE TABLE TH_DEPTBAL_COMSCHEME (
    TRADEID                 CHAR(16)                        NOT NULL,
    ID                      CHAR(8)                             NULL,
    DCOMSCHEMENO            CHAR(8)                             NULL,
    DBALUNITNO              CHAR(8)                             NULL,
    TRADETYPECODE           CHAR(2)                         NOT NULL,
    CANCELTRADE             CHAR(2)                             NULL,
    BEGINTIME               DATE                                NULL,
    ENDTIME                 DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TH_DEPTBAL_COMSCHEME PRIMARY KEY(TRADEID)
)tablespace TBSapp_B_CZ
/


grant Select on TH_DEPTBAL_COMSCHEME to Ucrapp_B_CZ;
grant Insert on TH_DEPTBAL_COMSCHEME to Ucrapp_B_CZ;
grant Update on TH_DEPTBAL_COMSCHEME to Ucrapp_B_CZ;
grant Delete on TH_DEPTBAL_COMSCHEME to Ucrapp_B_CZ;


--内部部门-网点结算单元关系历史表

/

CREATE TABLE TH_DEPTBAL_RELATION (
    TRADEID                 CHAR(16)                        NOT NULL,
    DEPARTNO                CHAR(4)                         NOT NULL,
    DBALUNITNO              CHAR(8)                         NOT NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                            NOT NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TH_DEPTBAL_RELATION PRIMARY KEY(TRADEID)
)tablespace TBSapp_B_CZ
/


grant Select on TH_DEPTBAL_RELATION to Ucrapp_B_CZ;
grant Insert on TH_DEPTBAL_RELATION to Ucrapp_B_CZ;
grant Update on TH_DEPTBAL_RELATION to Ucrapp_B_CZ;
grant Delete on TH_DEPTBAL_RELATION to Ucrapp_B_CZ;


--网点结算单元预付款账户表

/

CREATE TABLE TF_F_DEPTBAL_PREPAY (
    DBALUNITNO              CHAR(8)                         NOT NULL,
    PREPAY                  INT                             NOT NULL,
    ACCSTATECODE            CHAR(2)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_DEPTBAL_PREPAY PRIMARY KEY(DBALUNITNO)
)tablespace TBSapp_B_CZ
/


grant Select on TF_F_DEPTBAL_PREPAY to Ucrapp_B_CZ;
grant Insert on TF_F_DEPTBAL_PREPAY to Ucrapp_B_CZ;
grant Update on TF_F_DEPTBAL_PREPAY to Ucrapp_B_CZ;
grant Delete on TF_F_DEPTBAL_PREPAY to Ucrapp_B_CZ;


--网点结算单元保证金账户表

/

CREATE TABLE TF_F_DEPTBAL_DEPOSIT (
    DBALUNITNO              CHAR(8)                         NOT NULL,
    DEPOSIT                 INT                             NOT NULL,
    USABLEVALUE             INT                             NOT NULL,
    STOCKVALUE              INT                             NOT NULL,
    ACCSTATECODE            CHAR(2)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_F_DEPTBAL_DEPOSIT PRIMARY KEY(DBALUNITNO)
)tablespace TBSapp_B_CZ
/


grant Select on TF_F_DEPTBAL_DEPOSIT to Ucrapp_B_CZ;
grant Insert on TF_F_DEPTBAL_DEPOSIT to Ucrapp_B_CZ;
grant Update on TF_F_DEPTBAL_DEPOSIT to Ucrapp_B_CZ;
grant Delete on TF_F_DEPTBAL_DEPOSIT to Ucrapp_B_CZ;


--网点结算单元资金管理台账表

/

CREATE TABLE TF_B_DEPTACCTRADE (
    TRADEID                 CHAR(16)                        NOT NULL,
    TRADETYPECODE           CHAR(2)                         NOT NULL,
    DBALUNITNO              CHAR(8)                             NULL,
    CURRENTMONEY            INT              DEFAULT 0          NULL,
    PREMONEY                INT              DEFAULT 0          NULL,
    NEXTMONEY               INT              DEFAULT 0          NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    CANCELTAG               CHAR(1)          DEFAULT '0'        NULL,
    CANCELTRADEID           CHAR(16)                            NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    FINDATE                 DATE                                NULL,
    FINTRADENO              VARCHAR2(30)                        NULL,
    FINBANK                 VARCHAR2(50)                        NULL,
    USEWAY                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_B_DEPTACCTRADE PRIMARY KEY(TRADEID)
)tablespace TBSapp_B_CZ
/


grant Select on TF_B_DEPTACCTRADE to Ucrapp_B_CZ;
grant Insert on TF_B_DEPTACCTRADE to Ucrapp_B_CZ;
grant Update on TF_B_DEPTACCTRADE to Ucrapp_B_CZ;
grant Delete on TF_B_DEPTACCTRADE to Ucrapp_B_CZ;


--网点结算单元业务汇总账单表

/

CREATE TABLE TF_DEPTBALTRADE_BAL (
    ID                      NUMERIC(10,0)                   NOT NULL,
    DBALUNITNO              CHAR(8)                         NOT NULL,
    TRADETYPECODE           CHAR(2)                         NOT NULL,
    TOTALTIMES              INT                             NOT NULL,
    TOTALBALFEE             INT                             NOT NULL,
    BEGINTIME               DATE                                NULL,
    ENDTIME                 DATE                                NULL,
    BALANCETIME             DATE                                NULL,
    DEALSTATECODE           CHAR(1)                         NOT NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_DEPTBALTRADE_BAL PRIMARY KEY(ID)
)tablespace TBSapp_B_CZ
/


grant Select on TF_DEPTBALTRADE_BAL to Ucrapp_B_CZ;
grant Insert on TF_DEPTBALTRADE_BAL to Uopsett_B_SZ;
grant Update on TF_DEPTBALTRADE_BAL to Uopsett_B_SZ;
grant Delete on TF_DEPTBALTRADE_BAL to Uopsett_B_SZ;


/

CREATE  SEQUENCE  TF_DEPTBALTRADE_BAL_SEQ
    START WITH 1
    INCREMENT BY 1
/

grant select on TF_DEPTBALTRADE_BAL_SEQ to Ucrapp_B_CZ;


--网点结算单元佣金转账汇总账单表

/

CREATE TABLE TF_DEPTBALTRADE_AllFIN (
    ID                      NUMERIC(10,0)                   NOT NULL,
    DBALUNITNO              CHAR(8)                         NOT NULL,
    FINTYPECODE             CHAR(1)                         NOT NULL,
    FINBANKCODE             CHAR(4)                             NULL,
    TRANSTIMES              INT                             NOT NULL,
    TRANSFEE                INT                             NOT NULL,
    COMFEE                  INT                             NOT NULL,
    TOTALTIMES              INT                             NOT NULL,
    TOTALBALFEE             INT                             NOT NULL,
    CANCELTOTALTIMES        INT                                 NULL,
    CANCELTOTALBALFEE       INT                                 NULL,
    BEGINTIME               DATE                                NULL,
    ENDTIME                 DATE                                NULL,
    FINTIME                 DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_DEPTBALTRADE_AllFIN PRIMARY KEY(ID)
)tablespace TBSapp_B_CZ
/


grant Select on TF_DEPTBALTRADE_AllFIN to Ucrapp_B_CZ;
grant Insert on TF_DEPTBALTRADE_AllFIN to Uopsett_B_SZ;
grant Update on TF_DEPTBALTRADE_AllFIN to Uopsett_B_SZ;
grant Delete on TF_DEPTBALTRADE_AllFIN to Uopsett_B_SZ;


/

CREATE  SEQUENCE  TF_DEPTBALTRADE_AllFIN_SEQ
    START WITH 1
    INCREMENT BY 1
/

grant select on TF_DEPTBALTRADE_AllFIN_SEQ to Ucrapp_B_CZ;


--网点结算单元佣金转账账单表

/

CREATE TABLE TF_DEPTBALTRADE_OUTFIN (
    ID                      NUMERIC(10,0)                   NOT NULL,
    DBALUNITNO              CHAR(8)                         NOT NULL,
    FINTYPECODE             CHAR(1)                         NOT NULL,
    COMSCHEMENO             CHAR(8)                             NULL,
    FINBANKCODE             CHAR(4)                             NULL,
    TRANSFEE                INT                             NOT NULL,
    COMFEE                  INT                             NOT NULL,
    TRADETYPECODE           CHAR(2)                         NOT NULL,
    TOTALTIMES              INT                             NOT NULL,
    TOTALBALFEE             INT                             NOT NULL,
    CANCELTYPECODE          CHAR(2)                             NULL,
    CANCELTOTALTIMES        INT                                 NULL,
    CANCELTOTALBALFEE       INT                                 NULL,
    BEGINTIME               DATE                                NULL,
    ENDTIME                 DATE                                NULL,
    FINTIME                 DATE                                NULL,
    DEALSTATECODE           CHAR(1)                         NOT NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_DEPTBALTRADE_OUTFIN PRIMARY KEY(ID)
)tablespace TBSapp_B_CZ
/


grant Select on TF_DEPTBALTRADE_OUTFIN to Ucrapp_B_CZ;
grant Insert on TF_DEPTBALTRADE_OUTFIN to Uopsett_B_SZ;
grant Update on TF_DEPTBALTRADE_OUTFIN to Uopsett_B_SZ;
grant Delete on TF_DEPTBALTRADE_OUTFIN to Uopsett_B_SZ;


/

CREATE  SEQUENCE  TF_DEPTBALTRADE_OUTFIN_SEQ
    START WITH 1
    INCREMENT BY 1
/

grant select on TF_DEPTBALTRADE_OUTFIN_SEQ to Ucrapp_B_CZ;


--网点结算单元资金账户汇总账单表

/

CREATE TABLE TF_DEPTBALACC_BALANCE (
    ID                      NUMERIC(10,0)                   NOT NULL,
    DBALUNITNO              CHAR(8)                         NOT NULL,
    DEPOSIT                 INT                             NOT NULL,
    DEPOSITIN               INT                             NOT NULL,
    DEPOSITOUT              INT                             NOT NULL,
    PREPAY                  INT                             NOT NULL,
    PREPAYIN                INT                             NOT NULL,
    PREPAYOUT               INT                             NOT NULL,
    PREPAYCHARGEOUT         INT                             NOT NULL,
    PREPAYCOMFEE            INT                             NOT NULL,
    BEGINTIME               DATE                                NULL,
    ENDTIME                 DATE                                NULL,
    FINTIME                 DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_DEPTBALACC_BALANCE PRIMARY KEY(ID)
)tablespace TBSapp_B_CZ
/


grant Select on TF_DEPTBALACC_BALANCE to Ucrapp_B_CZ;
grant Insert on TF_DEPTBALACC_BALANCE to Uopsett_B_SZ;
grant Update on TF_DEPTBALACC_BALANCE to Uopsett_B_SZ;
grant Delete on TF_DEPTBALACC_BALANCE to Uopsett_B_SZ;


/

CREATE  SEQUENCE  TF_DEPTBALACC_BALANCE_SEQ
    START WITH 1
    INCREMENT BY 1
/

grant select on TF_DEPTBALACC_BALANCE_SEQ to Ucrapp_B_CZ;


--结算工作表

/

CREATE TABLE TP_DEPTBALANCE (
    ID                      NUMERIC(10,0)                   NOT NULL,
    DBALUNITNO              CHAR(8)                         NOT NULL,
    BALTIMES                INT              DEFAULT 0      NOT NULL,
    BEGINTIME               DATE                            NOT NULL,
    ENDTIME                 DATE                            NOT NULL,
    DEALSTATECODE           CHAR(1)                         NOT NULL,
    REMARK                  VARCHAR2(256)                       NULL,
    CONSTRAINT PK_TP_DEPTBALANCE PRIMARY KEY(ID)
)tablespace TBSdata_B_CZ
/


grant Select on TP_DEPTBALANCE to Uopsett_B_SZ;
grant Insert on TP_DEPTBALANCE to Uopsett_B_SZ;
grant Update on TP_DEPTBALANCE to Uopsett_B_SZ;
grant Delete on TP_DEPTBALANCE to Uopsett_B_SZ;


/

CREATE  SEQUENCE  TP_DEPTBALANCE_SEQ
    START WITH 1
    INCREMENT BY 1
/

grant select on TP_DEPTBALANCE_SEQ to Uopsett_B_SZ;


--佣金工作表

/

CREATE TABLE TP_DEPTFINANCE (
    ID                      NUMERIC(10,0)                   NOT NULL,
    DBALUNITNO              CHAR(8)                         NOT NULL,
    FINTIMES                INT              DEFAULT 0      NOT NULL,
    BEGINTIME               DATE                            NOT NULL,
    ENDTIME                 DATE                            NOT NULL,
    DEALSTATECODE           CHAR(1)                         NOT NULL,
    REMARK                  VARCHAR2(256)                       NULL,
    CONSTRAINT PK_TP_DEPTFINANCE PRIMARY KEY(ID)
)tablespace TBSdata_B_CZ
/


grant Select on TP_DEPTFINANCE to Uopsett_B_SZ;
grant Insert on TP_DEPTFINANCE to Uopsett_B_SZ;
grant Update on TP_DEPTFINANCE to Uopsett_B_SZ;
grant Delete on TP_DEPTFINANCE to Uopsett_B_SZ;


/

CREATE  SEQUENCE  TP_DEPTFINANCE_SEQ
    START WITH 1
    INCREMENT BY 1
/

grant select on TP_DEPTFINANCE_SEQ to Uopsett_B_SZ;


--资金账户工作表

/

CREATE TABLE TP_DEPTACCOUNT (
    ID                      NUMERIC(10,0)                   NOT NULL,
    DBALUNITNO              CHAR(8)                         NOT NULL,
    BALTIMES                INT              DEFAULT 0      NOT NULL,
    BEGINTIME               DATE                            NOT NULL,
    ENDTIME                 DATE                            NOT NULL,
    DEALSTATECODE           CHAR(1)                         NOT NULL,
    REMARK                  VARCHAR2(256)                       NULL,
    CONSTRAINT PK_TP_DEPTACCOUNT PRIMARY KEY(ID)
)tablespace TBSdata_B_CZ
/


grant Select on TP_DEPTACCOUNT to Uopsett_B_SZ;
grant Insert on TP_DEPTACCOUNT to Uopsett_B_SZ;
grant Update on TP_DEPTACCOUNT to Uopsett_B_SZ;
grant Delete on TP_DEPTACCOUNT to Uopsett_B_SZ;


/

CREATE  SEQUENCE  TP_DEPTACCOUNT_SEQ
    START WITH 1
    INCREMENT BY 1
/

grant select on TP_DEPTACCOUNT_SEQ to Uopsett_B_SZ;


--预付款保证金业务台账审核表

/

CREATE TABLE TF_B_DEPTACC_EXAM (
    ID                      CHAR(16)                        NOT NULL,
    TRADEID                 CHAR(16)                            NULL,
    TRADETYPECODE           CHAR(2)                         NOT NULL,
    DBALUNITNO              CHAR(8)                         NOT NULL,
    CURRENTMONEY            INT              DEFAULT 0          NULL,
    CHINESEMONEY            VARCHAR2(50)                        NULL,
    OPERATESTAFFNO          CHAR(6)                             NULL,
    OPERATEDEPARTID         CHAR(4)                             NULL,
    OPERATETIME             DATE                                NULL,
    EXAMSTAFFNO             CHAR(6)                             NULL,
    EXAMDEPARTNO            CHAR(4)                             NULL,
    EXAMKTIME               DATE                                NULL,
    STATECODE               CHAR(1)                             NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    FINDATE                 DATE                                NULL,
    FINTRADENO              VARCHAR2(30)                        NULL,
    FINBANK                 VARCHAR2(50)                        NULL,
    USEWAY                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_B_DEPTACC_EXAM PRIMARY KEY(ID)
)tablespace TBSapp_B_CZ
/


grant Select on TF_B_DEPTACC_EXAM to Ucrapp_B_CZ;
grant Insert on TF_B_DEPTACC_EXAM to Uopapp_B_SZ,Ucrapp_B_CZ;
grant Update on TF_B_DEPTACC_EXAM to Uopapp_B_SZ,Ucrapp_B_CZ;
grant Delete on TF_B_DEPTACC_EXAM to Uopapp_B_SZ,Ucrapp_B_CZ;


--佣金计算规则编码表

/

CREATE TABLE TF_DEPT_COMRULE (
    COMRULENO               CHAR(8)                         NOT NULL,
    SLOPE                   FLOAT                           NOT NULL,
    OFFSET                  FLOAT                           NOT NULL,
    LOWERBOUND              INT                             NOT NULL,
    UPPERBOUND              INT                             NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TF_DEPT_COMRULE PRIMARY KEY(COMRULENO)
)tablespace TBSdata_B_CZ
/


grant Select on TF_DEPT_COMRULE to Ucrapp_B_CZ;
grant Insert on TF_DEPT_COMRULE to Ucrapp_B_CZ;
grant Update on TF_DEPT_COMRULE to Ucrapp_B_CZ;
grant Delete on TF_DEPT_COMRULE to Ucrapp_B_CZ;


--充值营销模式编码表

/

CREATE TABLE TD_M_CHARGETYPE (
    CHARGETYPECODE          VARCHAR2(20)                    NOT NULL,
    CHARGETYPENAME          VARCHAR2(40)                        NULL,
    CHARGETYPESTATE         VARCHAR2(400)                       NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_M_CHARGETYPE PRIMARY KEY(CHARGETYPECODE)
)tablespace TBSdata_B_CZ
/


grant Select on TD_M_CHARGETYPE to Ucrapp_B_CZ;
grant Insert on TD_M_CHARGETYPE to Ucrapp_B_CZ;
grant Update on TD_M_CHARGETYPE to Ucrapp_B_CZ;
grant Delete on TD_M_CHARGETYPE to Ucrapp_B_CZ;


--部门与充值营销模式关系表

/

CREATE TABLE TD_DEPT_CHARGETYPE (
    CHARGETYPECODE          VARCHAR2(20)                    NOT NULL,
    DEPTNO                  CHAR(4)                         NOT NULL,
    USETAG                  CHAR(1)                         NOT NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    REMARK                  VARCHAR2(100)                       NULL,
    CONSTRAINT PK_TD_DEPT_CHARGETYPE PRIMARY KEY(CHARGETYPECODE, DEPTNO)
)tablespace TBSdata_B_CZ
/


grant Select on TD_DEPT_CHARGETYPE to Ucrapp_B_CZ;
grant Insert on TD_DEPT_CHARGETYPE to Ucrapp_B_CZ;
grant Update on TD_DEPT_CHARGETYPE to Ucrapp_B_CZ;
grant Delete on TD_DEPT_CHARGETYPE to Ucrapp_B_CZ;



grant Select,Insert,Update,Delete on TD_M_CARDCHIPTYPE to Ucrapp_Y_QS;
grant Select,Insert,Update,Delete on TD_M_COSTYPE to Ucrapp_Y_QS;
grant Select,Insert,Update,Delete on TP_DEALTIME to Ucrapp_Y_QS;


