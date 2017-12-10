CREATE OR REPLACE PROCEDURE SP_GC_FrontCharge
(
		p_ID	           char,
		p_CARDNO	       char,
		p_CARDTRADENO	   char,
		p_CARDMONEY	     int,
		p_CARDACCMONEY	 int,
		p_ASN	           char,
		p_CARDTYPECODE	 char,
		p_SUPPLYMONEY	   int,
		p_TRADETYPECODE	 char,
		p_CORPNO	       char,
		p_DBMONEY    	   int,
		p_TERMNO         char,
		p_OPERCARDNO     char,
		p_TRADEID	       out char, -- Return trade id
		p_currOper	     char,
		p_currDept	     char,
		p_retCode        out char, -- Return Code
		p_retMsg         out varchar2  -- Return Message

)
AS
    v_TradeID char(16);
    v_OFFERMONEY    int;
    v_today   date := sysdate;
    v_ex      exception;
BEGIN
	
		SP_GetSeq(seq => v_TradeID);
		p_TRADEID := v_TradeID;
		
		-- 2) Execute procedure SP_PB_UpdateAcc 
		SP_PB_UpdateAcc (p_ID, p_CARDNO, 
        p_CARDTRADENO, p_CARDMONEY, p_CARDACCMONEY, v_TradeID, 
        p_ASN, p_CARDTYPECODE, p_SUPPLYMONEY, p_TRADETYPECODE, p_TERMNO, v_today,
        p_currOper, p_currDept,p_retCode, p_retMsg);
		
		IF p_retCode != '0000000000' THEN
        ROLLBACK; RETURN;
    END IF;
    
		-- 3) Log the operate
		BEGIN
				INSERT INTO TF_B_TRADE
		        (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,CURRENTMONEY,PREMONEY,           
		        NEXTMONEY,CORPNO,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)           
		    VALUES             
		        (v_TradeID,p_ID,p_TRADETYPECODE,p_CARDNO,p_ASN,p_CARDTYPECODE,p_CARDTRADENO,p_SUPPLYMONEY,           
		        p_CARDMONEY,p_CARDMONEY+p_SUPPLYMONEY,p_CORPNO,p_currOper,p_currDept,v_today);
		 
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001107115';
	            p_retMsg  := 'Error occurred while log the operation,' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    -- 4) Update background account
    BEGIN
		    UPDATE TF_F_CARDOFFERACC             
		    SET  OFFERMONEY = OFFERMONEY - p_SUPPLYMONEY,
		    		 LASUPPLYMONEY = p_SUPPLYMONEY,
		    		 LASUPPLYTIME = v_today,
		    		 LASTSUPPLYSAMNO = p_TERMNO
		    WHERE  CARDNO = p_CARDNO;
		
				IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001107114';
	            p_retMsg  := 'Unable to Update background account' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    select OFFERMONEY into v_OFFERMONEY from TF_F_CARDOFFERACC where CARDNO = p_CARDNO;
    
    if v_OFFERMONEY < 0 then
        p_retCode := 'A001107101';
        p_retMsg  := 'money too large' || SQLERRM;
        ROLLBACK; RETURN;
    end if;
    
    -- 5) insert a row of group supply log
    BEGIN
		    INSERT INTO TF_GROUP_SELFSUPPLY             
		        (TRADEID,ID,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,TRADEMONEY,PREMONEY,DBPREMONEY,           
		        OPERATESTAFFNO,OPERATEDEPARTID,TRADETIME)           
		    VALUES             
		        (v_TradeID,p_ID,p_CARDNO,p_ASN,p_CARDTYPECODE,p_CARDTRADENO,p_SUPPLYMONEY,p_CARDMONEY,           
		        p_DBMONEY,p_currOper,p_currDept,v_today);
		        
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001107116';
	            p_retMsg  := 'Unable to insert a row of group supply log' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
		-- 6) Log the writeCard
		BEGIN
		    INSERT INTO TF_CARD_TRADE
		    		(TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,lMoney,lOldMoney,strTermno,
		    		Cardtradeno,OPERATETIME,SUCTAG)
		    VALUES
		    		(v_TradeID,p_TRADETYPECODE,p_OPERCARDNO,p_CARDNO,p_SUPPLYMONEY,p_CARDMONEY,
		    		p_TERMNO,p_CARDTRADENO,v_today,'0');
    		
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001139';
	            p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
        
  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors

 