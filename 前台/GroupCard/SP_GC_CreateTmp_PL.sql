BEGIN
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE TMP_GC_GroupCardOpen';
    EXCEPTION WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
    END;
    
    BEGIN 
        EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE TMP_GC_GroupCardOpen'
        || '(SessionId   varchar2(32) NOT NULL,'
        || ' CardNo      char(16)    NOT NULL,'
        || ' CustName    varchar2(50)  NULL,'
        || ' CustSex     varchar2(2)   NULL,'
        || ' CustBirth   varchar2(8)   NULL,'
        || ' PaperType   varchar2(2)   NULL,'
        || ' PaperNo     varchar2(20)  NULL,'
        || ' CustAddr    varchar2(50)  NULL,'
        || ' CustPost    varchar2(6)   NULL,'
        || ' CustPhone   varchar2(40)  NULL,'        
        || ' CustEmail   varchar2(30)  NULL,'        
        || ' CONSTRAINT PK_TMP_GC_GroupCardOpen PRIMARY KEY(SessionId, CardNo)'
        || ')ON COMMIT PRESERVE ROWS';
    EXCEPTION WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
    END;

    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE TMP_GC_BatchNoList';
    EXCEPTION WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
    END;

    BEGIN 
        EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE TMP_GC_BatchNoList'
        || '(SessionId   varchar2(32) NOT NULL,'
        || ' BatchNo     char(16)    NOT NULL,'
        || ' CONSTRAINT PK_TMP_GC_BatchNoList PRIMARY KEY(SessionId, BatchNo)'
        || ')ON COMMIT PRESERVE ROWS';
    EXCEPTION WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
    END;

    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE TMP_GC_BatchChargeFile';
    EXCEPTION WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
    END;

    BEGIN 
        EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE TMP_GC_BatchChargeFile'
        || '(SessionId    varchar2(32) NOT NULL,'
        || ' CardNo       char(16)     NOT NULL,'
        || ' ChargeAmount INT          NOT NULL,'
        || ' CONSTRAINT PK_TMP_GC_BatchChargeFile PRIMARY KEY(SessionId, CardNo)'
        || ')ON COMMIT PRESERVE ROWS';
    EXCEPTION WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
    END;

END;

/

