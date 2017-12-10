create or replace procedure SP_PS_ZEROTRADEPOS_COLLECT
(
    p_BALUNITNO     char,
    p_BALUNIT       varchar2,
    p_POSNO         char,
    p_SHOP          varchar2,
    p_ENDDATE       char,
    p_REASON        varchar2,
    p_currOper      char,      
    p_currDept      char, 
    p_retCode	    out char, -- Return Code
	p_retMsg     	out varchar2  -- Return Message
    
)
as
BEGIN
    BEGIN
        merge into TF_ZEROTRADEPOS_COLLECT USING DUAL
        ON (BALUNITNO = p_BALUNITNO and POSNO = p_POSNO)
        WHEN MATCHED THEN
            UPDATE
            SET SHOP    = p_SHOP,
                ENDDATE = p_ENDDATE,
                REASON  = p_REASON
        WHEN NOT MATCHED THEN
            INSERT
                (BALUNITNO, BALUNIT, SHOP, POSNO, ENDDATE, REASON)
            VALUES
                (p_BALUNITNO, p_BALUNIT, p_SHOP, p_POSNO, p_ENDDATE, p_REASON);
                
     EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S006001003'; 
        p_retMsg  := '记录零POS交易分析失败' ;
        ROLLBACK; RETURN;
    END;
    
    p_retcode := '0000000000';
    p_retMsg  := '';
    COMMIT; return;
end;
/

show errors