CREATE OR REPLACE PROCEDURE SP_CG_TransitBalance
(
		p_SESSIONID	      varchar2,
		p_NEWCARDNO	      char,
		p_OLDCARDNO	      char,
		p_TRADETYPECODE		char,
		p_NEWCARDACCMONEY	int,
		p_CURRENTMONEY	  int,
		p_OLDCARDACCMONEY	int,
		p_PREMONEY	      int,
		p_ASN	            char,
		p_CARDTRADENO	    char,
		p_CARDTYPECODE	  char,
		p_CHANGERECORD    char,
		p_TERMNO					char,
		p_OPERCARDNO			char,
		p_TRADEID	        out char, -- Return Trade Id
		p_writeCardScript     varchar2,
		p_currOper	      char,
		p_currDept	      char,
		p_retCode	        out char, -- Return Code
		p_retMsg     	    out varchar2  -- Return Message
		  

)
AS
    v_ex              exception;
BEGIN
  BEGIN
		SP_PB_TransitBalance(p_SESSIONID, p_NEWCARDNO, p_OLDCARDNO, p_TRADETYPECODE, p_NEWCARDACCMONEY,
												p_CURRENTMONEY, p_OLDCARDACCMONEY, p_PREMONEY, p_ASN, p_CARDTRADENO,
												p_CARDTYPECODE, p_CHANGERECORD, p_TERMNO, p_OPERCARDNO,p_TRADEID,
												p_currOper, p_currDept, p_retCode, p_retMsg);
		
	 IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
	  EXCEPTION
	 WHEN OTHERS THEN
	      ROLLBACK; RETURN;
	 END;
	 
	 update tf_card_trade
	 set 	writeCardScript = p_writeCardScript	
	 where  tradeid = p_TRADEID;
												
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
	
exception when others then
    p_retcode := sqlcode;
    p_retmsg  := lpad(sqlerrm, 127);
    rollback; return;
END;
/

show errors