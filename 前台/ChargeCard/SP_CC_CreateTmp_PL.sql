DECLARE
    tableExists int := 0;
BEGIN
    BEGIN
        SELECT 1 INTO tableExists FROM user_tables t WHERE t.table_name = 'TMP_CC_AccRecvList';
        EXECUTE IMMEDIATE 'DROP TABLE TMP_CC_AccRecvList';
    EXCEPTION WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
    END;

    BEGIN
        EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE TMP_CC_AccRecvList'
        || '(SessionId   varchar2(32) NOT NULL,'
        || ' BatchNo     char(16)    NOT NULL,'
        || ' RecvDate     char(8) NOT NULL,'
        || ' CONSTRAINT PK_TMP_CC_AccRecvList PRIMARY KEY(SessionId, BatchNo)'
        || ')ON COMMIT PRESERVE ROWS';
    EXCEPTION WHEN OTHERS THEN dbms_output.put_line(SQLERRM);
    END;

END;

/




