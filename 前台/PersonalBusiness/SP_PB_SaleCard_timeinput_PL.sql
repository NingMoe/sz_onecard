CREATE OR REPLACE PROCEDURE SP_PB_SaleCard_timeinput
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
		p_CURRENTTIME	   date,
		p_TRADEID    	    out char, -- Return Trade Id
		p_currOper	      char,
		p_currDept	      char,
		p_retCode	        out char, -- Return Code
		p_retMsg     	    out varchar2  -- Return Message

)
AS
    v_TradeID char(16);
    v_CARDSURFACECODE  char(4);
    v_MANUTYPECODE     char(2);
    v_CARDCHIPTYPECODE char(2);
    v_APPTYPECODE      char(2);
    v_APPVERNO         char(2);
    v_PRESUPPLYMONEY   int;
    v_VALIDENDDATE     char(8);
    v_ASN	             char(16);
    v_ex          exception;
BEGIN
	--card chuku 
	
    -- 1) Update card resource statecode
    BEGIN
		    UPDATE TL_R_ICUSER        
		    SET RESSTATECODE  = '06',
		        SELLTIME = p_CURRENTTIME,     
		        UPDATESTAFFNO = p_currOper,      
		        UPDATETIME = p_CURRENTTIME      
		    WHERE  CARDNO = p_CARDNO 
			AND RESSTATECODE in ('01','02','05');--卡必须为出库状态的卡wdx 20111228

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001105';
	            p_retMsg  := 'Error occurred while updating resource statecode' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    -- 2) Get initialize info    
    SELECT 
        ASN, CARDSURFACECODE, MANUTYPECODE, CARDCHIPTYPECODE, APPTYPECODE,
        APPVERNO,PRESUPPLYMONEY,VALIDENDDATE
    INTO v_ASN,v_CARDSURFACECODE,v_MANUTYPECODE,v_CARDCHIPTYPECODE,v_APPTYPECODE,
         v_APPVERNO,v_PRESUPPLYMONEY,v_VALIDENDDATE
    FROM TL_R_ICUSER       
    WHERE CARDNO = p_CARDNO;
    
    -- 3) Insert a row in CARDREC
    BEGIN
		    INSERT INTO TF_F_CARDREC        
		        (CARDNO,ASN,CARDTYPECODE,CARDSURFACECODE,CARDMANUCODE,CARDCHIPTYPECODE,APPTYPECODE,APPVERNO,      
		        DEPOSIT,CARDCOST,PRESUPPLYMONEY,CUSTRECTYPECODE,SELLTIME,SELLCHANNELCODE,DEPARTNO,STAFFNO,      
		        CARDSTATE,VALIDENDDATE,USETAG,SERSTARTTIME,SERSTAKETAG,SERVICEMONEY,UPDATESTAFFNO,UPDATETIME)
		    VALUES  
		        (p_CARDNO,v_ASN,p_CARDTYPECODE,v_CARDSURFACECODE,v_MANUTYPECODE,v_CARDCHIPTYPECODE,v_APPTYPECODE,v_APPVERNO,      
		        p_DEPOSIT,p_CARDCOST,v_PRESUPPLYMONEY,p_CUSTRECTYPECODE,p_CURRENTTIME,p_SELLCHANNELCODE,p_currDept,      
		        p_currOper,'10',v_VALIDENDDATE,'1',p_CURRENTTIME,p_SERSTAKETAG,0,p_currOper,p_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001102';
	            p_retMsg  := 'Error occurred while insert a row in cardrec' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    --4) insert a row of elec wallet
    BEGIN
		    INSERT INTO TF_F_CARDEWALLETACC    
		        (CARDNO,CARDACCMONEY,USETAG,CREDITSTATECODE,CREDITSTACHANGETIME,CREDITCONTROLCODE,      
		        CREDITCOLCHANGETIME,ACCSTATECODE,CONSUMEREALMONEY,SUPPLYREALMONEY,TOTALCONSUMETIMES,      
		        TOTALSUPPLYTIMES,TOTALCONSUMEMONEY,TOTALSUPPLYMONEY,OFFLINECARDTRADENO,ONLINECARDTRADENO)
		    VALUES        
		        (p_CARDNO,p_CARDMONEY,'1','00',p_CURRENTTIME,'00',p_CURRENTTIME,'01',0,0,0,0,0,0,'0000',p_CARDTRADENO);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001106';
	            p_retMsg  := 'Error occurred while insert a row of elec wallet' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    --5) insert a row of cust info
    BEGIN
		    INSERT INTO TF_F_CUSTOMERREC        
		        (CARDNO,CUSTNAME,CUSTSEX,CUSTBIRTH,PAPERTYPECODE,PAPERNO,     
		        CUSTADDR,CUSTPOST,CUSTPHONE,CUSTEMAIL,USETAG,UPDATESTAFFNO,UPDATETIME,REMARK)      
		    VALUES        
		        (p_CARDNO,p_CUSTNAME,p_CUSTSEX,p_CUSTBIRTH,p_PAPERTYPECODE,p_PAPERNO,p_CUSTADDR,p_CUSTPOST, 
		        p_CUSTPHONE,p_CUSTEMAIL,'1',p_currOper,p_CURRENTTIME,p_REMARK);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001103';
	            p_retMsg  := 'Error occurred while insert a row of cust info' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
     
     
    -- 6) Get trade id
    SP_GetSeq(seq => v_TradeID); 
    p_TRADEID := v_TradeID;

    -- 7) Log operation
    BEGIN
		    INSERT INTO TF_B_TRADE        
		        (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,CURRENTMONEY,PREMONEY,      
		        OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)      
		    VALUES        
		        (v_TradeID,p_ID,p_TRADETYPECODE,p_CARDNO,v_ASN,p_CARDTYPECODE,p_CARDTRADENO,
		        p_DEPOSIT+p_CARDCOST,p_CARDMONEY,      
		        p_currOper,p_currDept,p_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001107';
	            p_retMsg  := 'Fail to log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 8) Log the operation of cust info change
    BEGIN
		    INSERT INTO TF_B_CUSTOMERCHANGE        
		        (TRADEID,CARDNO,CUSTNAME,CUSTSEX,CUSTBIRTH,PAPERTYPECODE,PAPERNO,CUSTADDR,CUSTPOST,CUSTPHONE,      
		        CUSTEMAIL,CHGTYPECODE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)      
		    VALUES        
		        (v_TradeID,p_CARDNO,p_CUSTNAME,p_CUSTSEX,p_CUSTBIRTH,p_PAPERTYPECODE,p_PAPERNO,p_CUSTADDR,      
		        p_CUSTPOST,p_CUSTPHONE,p_CUSTEMAIL,'00',p_currOper,p_currDept,p_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001108';
	            p_retMsg  := 'Fail to log the operation of cust info change' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    -- 9) Log the cash
    BEGIN
		    INSERT INTO TF_B_TRADEFEE        
		        (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,CARDSERVFEE,CARDDEPOSITFEE,OTHERFEE,      
		        OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)      
		    VALUES        
		        (p_ID,v_TradeID,p_TRADETYPECODE,p_CARDNO,p_CARDTRADENO,p_CARDCOST,p_DEPOSIT, p_OTHERFEE ,    
		        p_currOper,p_currDept,p_CURRENTTIME);
        
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001109';
	            p_retMsg  := 'Fail to log the cash' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    -- 10) Log the writeCard
    BEGIN
		    INSERT INTO TF_CARD_TRADE
		    		(TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,strTermno,OPERATETIME,SUCTAG)
		    VALUES
		    		(v_TradeID,p_TRADETYPECODE,p_OPERCARDNO,p_CARDNO,p_TERMNO,p_CURRENTTIME,'0');
    		
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001139';
	            p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
  p_retCode := '0000000000';
	p_retMsg  := '';
  RETURN;
END;

/

show errors

 