CREATE OR REPLACE PROCEDURE SP_GetSeq
(
	step SMALLINT DEFAULT 1, -- step length
	seq  OUT  	CHAR         -- output sequence number
)
AS
seq_num INT;
PRAGMA AUTONOMOUS_TRANSACTION;--自治事务 
BEGIN

    UPDATE TD_SEQ_ID SET TRADEID = TRADEID + step;

    -- if update row count is zero, we need to add a record
    -- (b'coz of it's an empty table when rowcount is zero)
    IF SQL%ROWCOUNT = 0 THEN
    BEGIN
        INSERT INTO TD_SEQ_ID VALUES (1);
        -- fail to insert(maybe another asyn process is also running this proc)
        -- just update it again
        IF SQLCODE != 0 THEN
            UPDATE  TD_SEQ_ID SET TRADEID = TRADEID + step;
        END IF;
    END;
    END IF;

    SELECT TRADEID - step + 1 INTO seq_num from TD_SEQ_ID where rownum < 2;

    /* 16 digits Sequence number includes two parts:
                  1) 8 digits date with format "YYYYMMDD"
                  2) 8 digits sequence number computed here*/
    SELECT  TO_CHAR(SYSDATE, 'YYYYMMDD') || SUBSTR('00000000' || TO_CHAR(seq_num), -8)
    INTO  seq  FROM DUAL;
    commit;
END;


/
show errors
