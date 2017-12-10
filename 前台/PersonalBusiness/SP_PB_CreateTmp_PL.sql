BEGIN
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE TMP_PB_TransitBalance';
    EXCEPTION WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
    END;
    
    BEGIN 
        EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE TMP_PB_TransitBalance'
        || '(SESSIONID   VARCHAR2(32) NOT NULL,'
        || ' Id          INT         NOT NULL,'
        || ' TRADEID     CHAR(16)  NULL,'
        || ' CONSTRAINT PK_TMP_PB_TransitBalance PRIMARY KEY(SESSIONID, Id)'
        || ')ON COMMIT PRESERVE ROWS';
    EXCEPTION WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
    END;
    
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE TMP_PB_ReadRecord';
    EXCEPTION WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
    END;
    
    BEGIN 
        EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE TMP_PB_ReadRecord'
        || '(SESSIONID   VARCHAR2(32) NOT NULL,'
        || ' ID          INT         NOT NULL,'
        || ' CARDTRADENO     CHAR(4)  NULL,'
        || ' TRADEMONEY		VARCHAR2(8) NULL,'
        || ' ICTRADETYPECODE  CHAR(2)  NULL,'
        || ' SAMNO  CHAR(12)  NULL,'
        || ' TRADEDATE  CHAR(8)  NULL,'
        || ' TRADETIME  CHAR(6)  NULL,'
        || ' CONSTRAINT TMP_PB_ReadRecord PRIMARY KEY(SESSIONID, ID)'
        || ')ON COMMIT PRESERVE ROWS';
    EXCEPTION WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
    END;
END;

/

show errors

 