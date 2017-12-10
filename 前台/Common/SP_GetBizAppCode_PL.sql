 
CREATE OR REPLACE PROCEDURE SP_GetBizAppCode
(
    p_step  SMALLINT DEFAULT 1, -- step length
    p_type  CHAR,               -- code type
	  p_Len   INT,                -- code length max  = 8 
    p_code  OUT CHAR            
)
AS
    v_code  INT; 
	  v_len   INT;
BEGIN 

    -- first update CODEID  = CODEID + 1
    UPDATE TD_SEQ_TID SET CODEID = CODEID + p_step WHERE TRADETYPECODE = p_type;

    -- if update row count is zero, we need to add a record
    -- (b'coz of it's an empty table when rowcount is zero)
    IF SQL%ROWCOUNT = 0 THEN
    BEGIN
        INSERT INTO TD_SEQ_TID VALUES (p_type, 1);
        -- fail to insert(maybe another asyn process is also running this proc)
        -- just update it again
        IF SQLCODE != 0 THEN
            UPDATE TD_SEQ_TID SET CODEID = CODEID + p_step WHERE TRADETYPECODE = p_type; 
        END IF;
    END;
    END IF;

    SELECT CODEID - p_step + 1 INTO v_code FROM TD_SEQ_TID WHERE TRADETYPECODE = p_type;
    
    --A5 get TD_TBALUNIT_COMSCHEME id value
    IF p_type = 'A5' THEN
      v_code := v_code + rpad(1, p_Len, 0);
    END IF;

    --  2) 8 digits sequence number computed here
	  v_len := 0 - p_Len;
    SELECT SUBSTR('00000000' || TO_CHAR(v_code), v_len) INTO p_code FROM DUAL;
	   
END;

/
show errors


