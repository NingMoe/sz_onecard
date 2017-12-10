CREATE OR REPLACE PROCEDURE SP_PB_SaleCard_COMMIT
(
		p_ID	            char,
		p_CARDNO	        char,
		p_DEPOSIT	        int,
		p_CARDCOST	      int,
		p_OTHERFEE				int,
		p_CARDTRADENO	    char,
		p_CARDTYPECODE	  char,
		p_CARDMONEY	      int,
		p_SELLCHANNELCODE	char,
		p_SERSTAKETAG	    char,
		p_TRADETYPECODE	  char,
		p_CUSTNAME	      varchar2,
		p_CUSTSEX	        varchar2,
		p_CUSTBIRTH	      varchar2,
		p_PAPERTYPECODE	  varchar2,
		p_PAPERNO        	varchar2,
		p_CUSTADDR	      varchar2,
		p_CUSTPOST	      varchar2,
		p_CUSTPHONE	      varchar2,
		p_CUSTEMAIL       varchar2,
		p_REMARK	        varchar2,
		p_CUSTRECTYPECODE	char,
		p_TERMNO					char,
		p_OPERCARDNO			char,
		p_CURRENTTIME	    out date, -- Return Operate Time
		p_TRADEID    	    out char, -- Return Trade Id
		p_currOper	      char,
		p_currDept	      char,
		p_retCode	        out char, -- Return Code
		p_retMsg     	    out varchar2  -- Return Message

)
AS
    v_ex          exception;
BEGIN
	BEGIN
	  SP_PB_SaleCard(p_ID,p_CARDNO,p_DEPOSIT,p_CARDCOST,p_OTHERFEE,p_CARDTRADENO,p_CARDTYPECODE,
	                 p_CARDMONEY,p_SELLCHANNELCODE,p_SERSTAKETAG,p_TRADETYPECODE,p_CUSTNAME,
	                 p_CUSTSEX,p_CUSTBIRTH,p_PAPERTYPECODE,p_PAPERNO,p_CUSTADDR,p_CUSTPOST,
	                 p_CUSTPHONE,p_CUSTEMAIL,p_REMARK,p_CUSTRECTYPECODE,p_TERMNO,p_OPERCARDNO,
	                 p_CURRENTTIME,p_TRADEID,p_currOper,p_currDept,p_retCode,p_retMsg);
	
     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;
    
	-- 代理营业厅抵扣预付款，根据保证金修改可领卡额度，add by liuhe 20111230
	BEGIN
	  SP_PB_DEPTBALFEE(p_TRADEID, '3' ,--1预付款,2保证金,3预付款和保证金
					 p_DEPOSIT + p_CARDCOST + p_OTHERFEE + p_CARDMONEY,
	                 p_CURRENTTIME,p_currOper,p_currDept,p_retCode,p_retMsg);
	
     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;
   
  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors

 