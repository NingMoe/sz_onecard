CREATE OR REPLACE PROCEDURE SP_GetBizAppCodeCommit
(
    p_step  SMALLINT DEFAULT 1, -- step length
    p_type  CHAR,               -- code type
	p_Len   INT,                -- code length max  = 8
    p_code  OUT CHAR
)
AS
BEGIN
	SP_GetBizAppCode(p_step, p_type, p_Len, p_code);

	COMMIT; RETURN;
END;

/

show errors