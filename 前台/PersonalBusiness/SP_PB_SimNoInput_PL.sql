CREATE OR REPLACE PROCEDURE SP_PB_SimNoInput
(
	p_sessionID	 char,
    p_currOper   char,
    p_currDept   char,
    p_retCode    out char, -- Return Code
    p_retMsg     out varchar2  -- Return Message

)
AS
BEGIN
    begin
        insert into TF_R_SIMCARD(CARDNO, SIMNO)
        select CARDNO,SIMNO
        from tmp_simcard_imp where sessionid= p_sessionID;
        
        delete from tmp_simcard_imp where sessionid = p_sessionID;
    exception when others then
        p_retCode := sqlcode;
        p_retMsg := lpad(sqlerrm, 127);
        rollback; return;
    end;
    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;
END;

/

show errors

 