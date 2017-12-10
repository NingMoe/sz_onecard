CREATE OR REPLACE PROCEDURE SP_PB_UpdateAcc
(
		p_ID	           char,
		p_CARDNO	       char,
		p_CARDTRADENO    char,
		p_CARDMONEY      int,
		p_CARDACCMONEY	 int,
		p_TRADEID        char,
		p_ASN	           char,
		p_CARDTYPECODE	 char,
		p_SUPPLYMONEY	   int,
		p_TRADETYPECODE	 char,
		p_TERMNO         char,
		p_CURRENTTIME	   out date, -- Return Operate Time
		p_currOper       char,
		p_currDept	     char,
		p_retCode	       out char, -- Return Code
		p_retMsg     	   out varchar2  -- Return Message	

)
AS
		v_TOTALSUPPLYTIMES int;
    v_ex      exception;
BEGIN
		-- 1) Get system time
		p_CURRENTTIME := sysdate;
		
    -- 2) Updated electronic wallet account information
    BEGIN
		    UPDATE TF_F_CARDEWALLETACC
		    SET  CARDACCMONEY = CARDACCMONEY + p_SUPPLYMONEY,         
		        SUPPLYREALMONEY = p_CARDMONEY,
		        TOTALSUPPLYTIMES = TOTALSUPPLYTIMES + 1,         
		        TOTALSUPPLYMONEY = TOTALSUPPLYMONEY + p_SUPPLYMONEY,         
		        LASTSUPPLYTIME = p_CURRENTTIME,         
		        ONLINECARDTRADENO = p_CARDTRADENO         
		    WHERE  CARDNO = p_CARDNO
			AND USETAG='1';
		    
		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001002113';
	            p_retMsg  := 'S001002113:Unable to Updated electronic wallet account information';
	            ROLLBACK; RETURN;
    END;
    
    -- 3) Determine whether the recharge is the first time
		BEGIN
		    SELECT            
							 TOTALSUPPLYTIMES INTO v_TOTALSUPPLYTIMES        
		    FROM  TF_F_CARDEWALLETACC         
		    WHERE  CARDNO = p_CARDNO;
    
    EXCEPTION
				    WHEN NO_DATA_FOUND THEN
				    p_retCode := 'A001002112';
				    p_retMsg  := 'A001002112:Can not find the record or Error';
				    ROLLBACK; RETURN;
    END;
    
    -- 4) for the first time
    IF v_TOTALSUPPLYTIMES = 1 THEN
		    BEGIN   
		        UPDATE TF_F_CARDEWALLETACC          
		        SET  FIRSTSUPPLYTIME = p_CURRENTTIME        
		        WHERE  CARDNO = p_CARDNO;
		        
		        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
				EXCEPTION
			        WHEN OTHERS THEN
			            p_retCode := 'S001002113';
			            p_retMsg  := 'S001002113:Update failure';
			            ROLLBACK; RETURN;
		    END;
    END IF;
    
    -- 5) Record an electronic wallet recharge log
    BEGIN
			  INSERT INTO TF_SUPPLY_REALTIME
			      (ID,CARDNO,ASN,CARDTRADENO,TRADETYPECODE,CARDTYPECODE,TRADEDATE,TRADETIME,         
			      TRADEMONEY,PREMONEY,SUPPLYLOCNO,SAMNO,OPERATESTAFFNO,OPERATETIME)         
			  VALUES
			      (p_ID,p_CARDNO,p_ASN,p_CARDTRADENO,p_TRADETYPECODE,p_CARDTYPECODE,         
			      TO_CHAR(p_CURRENTTIME,'YYYYMMDD'),TO_CHAR(p_CURRENTTIME,'HH24MISS'),
			      p_SUPPLYMONEY,p_CARDMONEY,p_currDept,p_TERMNO,p_currOper,p_CURRENTTIME);
        
    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001002115';
	            p_retMsg  := 'S001002115:Unable to insert a row of group supply log';
	            ROLLBACK; RETURN;
    END;          		
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	RETURN;
END;

/

show errors

 