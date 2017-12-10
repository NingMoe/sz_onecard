BEGIN
    BEGIN 
        EXECUTE IMMEDIATE 'DROP TABLE TMP_UC_CardNoList';
    EXCEPTION WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
    END;
    
    BEGIN 
        EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE TMP_UC_CardNoList'
        || '(SessionId   varchar2(32) NOT NULL,'
        || ' CardNo      char(16)    NOT NULL,'
        || ' CONSTRAINT PK_TMP_UC_CardNoList PRIMARY KEY(SessionId, CardNo)'
        || ')ON COMMIT PRESERVE ROWS';
    EXCEPTION WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
    END;

END;

/
