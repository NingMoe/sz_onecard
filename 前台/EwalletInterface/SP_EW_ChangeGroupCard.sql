CREATE OR REPLACE PROCEDURE SP_EW_ChangeGroupCard
(
	p_OLDCARDNO	        char, --旧卡卡号
	p_NEWCARDNO	        char, --旧卡卡号
	p_TRADEORIGIN       varchar2, --业务来源
	p_currOper	        char, --员工编码
	p_currDept	        char, --部门编码
	p_TRADEID           out char, -- Return Trade Id
	p_retCode	          out char, -- Return Code
	p_retMsg            out varchar2  -- Return Message
)
AS
    v_today     date := sysdate;
    v_OFFERMONEY int;
    v_groupCode char(4);
    v_quantity  int;
    v_ex        exception;
    v_seqNo     char(16);
BEGIN
    
    --换卡补账户并转值
    BEGIN
        SP_CA_CHANGECARDTRANSITBALANCE(p_OLDCARDNO,p_NEWCARDNO,p_TRADEORIGIN,p_currOper,p_currDept,p_retCode,p_retMsg,p_TRADEID,'0.0-000*0/0.');
        IF (p_retCode = 'A004P08B04') THEN  --包容旧卡未开账户的情况
              p_retCode := '0000000000' ; p_retMsg  := '';
              return; 
        ELSIF (p_retCode != '0000000000') THEN
            RAISE v_ex;
        END IF;
        EXCEPTION
            WHEN OTHERS THEN
            RETURN;
    END;
    
    p_retCode := '0000000000'; p_retMsg  := '';
    RETURN;
   
END;	

/
show errors
