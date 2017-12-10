--休闲年卡入库临时表
;
BEGIN
EXECUTE IMMEDIATE 'DROP TABLE TF_XXPARK_NEW_LOAD CASCADE CONSTRAINTS';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE TF_XXPARK_NEW_LOAD (
    ID                      CHAR(24)                            NULL,
    CARDNO                  CHAR(16)                            NULL,
    POSNO                   CHAR(6)                             NULL,
    SAMNO                   CHAR(12)                            NULL,
    STARTDATE               CHAR(8)                             NULL,
    ENDDATE                 CHAR(8)                             NULL,
    RANDOM                  CHAR(16)                            NULL,
    DATAENCRYPTION          CHAR(16)                            NULL,
    BATCHNO                 CHAR(14)                            NULL,
    ERRORREASONCODE         CHAR(1)                             NULL,
    DEALCODE                CHAR(1)                             NULL,
    UPDATESTAFFNO           CHAR(6)                             NULL,
    UPDATETIME              DATE                                NULL,
    RSRV1                   VARCHAR2(20)                        NULL,
    RSRV2                   VARCHAR2(20)                        NULL
)
/





