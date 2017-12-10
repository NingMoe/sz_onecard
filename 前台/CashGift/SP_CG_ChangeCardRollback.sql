CREATE OR REPLACE PROCEDURE SP_CG_ChangeCardRollback
(
	p_ID              char,
	p_OLDCARDNO       char,
	p_NEWCARDNO       char,
	p_TRADETYPECODE	  char,
	p_CANCELTRADEID   char,
	p_REASONCODE      char,
	p_CARDTRADENO     char,
	p_TRADEPROCFEE    int,
	p_OTHERFEE        int,
	p_CARDSTATE       char,
	p_SERSTAKETAG     char,
	p_TERMNO		  char,
	p_OPERCARDNO	  char,
	p_TRADEID    	  out char, -- Return Trade Id
	p_writeCardScript     varchar2,
	p_currOper	      char,
	p_currDept	      char,
	p_retCode	      out char, -- Return Code
	p_retMsg     	  out varchar2  -- Return Message
	  

) 
AS
    v_ex          exception;
    v_tradeFee    int DEFAULT 0;
	  V_FEETYPE	  CHAR(1);
BEGIN
	BEGIN
		SP_PB_ChangeCardRollback(p_ID,p_OLDCARDNO,p_NEWCARDNO,p_TRADETYPECODE,p_CANCELTRADEID,
								p_REASONCODE,p_CARDTRADENO,p_TRADEPROCFEE,p_OTHERFEE,p_CARDSTATE,
								p_SERSTAKETAG,p_TERMNO,p_OPERCARDNO,p_TRADEID,p_currOper,p_currDept,
		                 		p_retCode,p_retMsg);
		                 
     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
   EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;
   
   update tf_card_trade
	 set 	writeCardScript = p_writeCardScript	
	 where  tradeid = p_TRADEID;
    
    -- 代理营业厅根据保证金修改可领卡额度，add by yin 20120104
	IF p_REASONCODE = '12' OR p_REASONCODE = '14'  THEN V_FEETYPE := '3';
		
		BEGIN
			SELECT  -CARDDEPOSITFEE - CARDSERVFEE INTO v_tradeFee
			FROM TF_B_TRADEFEE
			WHERE TRADEID = p_CANCELTRADEID;

		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			p_retCode := 'S001009101';
			p_retMsg  := '没有从现金台账表取到数据' || SQLERRM;
			ROLLBACK; RETURN;
		END;
		
	ELSE  V_FEETYPE := '2';
	END IF;
		BEGIN
			  SP_PB_DEPTBALFEEROLLBACK(p_TRADEID, p_CANCELTRADEID,
						V_FEETYPE ,--1预付款,2保证金,3预付款和保证金
						 v_tradeFee,
						 p_currOper,p_currDept,p_retCode,p_retMsg);
			
			 IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
				EXCEPTION
				WHEN OTHERS THEN
					ROLLBACK; RETURN;
			
	   END;
    
    
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
