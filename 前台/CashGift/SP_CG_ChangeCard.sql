CREATE OR REPLACE PROCEDURE SP_CG_ChangeCard
(
		p_ID	              char,
		p_CUSTRECTYPECODE	  char,
		p_CARDCOST	        int,
		p_NEWCARDNO	        char,
		p_OLDCARDNO	        char,
		p_ONLINECARDTRADENO	char,
		p_CHECKSTAFFNO	    char,
		p_CHECKDEPARTNO	    char,
		p_CHANGECODE	      char,
		p_ASN	              char,
		p_CARDTYPECODE	    char,
		p_SELLCHANNELCODE	  char,
		p_TRADETYPECODE	    char,
		p_DEPOSIT	          int,
		p_SERSTARTTIME	    date,
		p_SERVICEMONE	      int,
		p_CARDACCMONEY	    int,
		p_NEWSERSTAKETAG	  char,
		p_SUPPLYREALMONEY	  int,
		p_TOTALSUPPLYMONEY	int,
		p_OLDDEPOSIT	      int,
		p_SERSTAKETAG	      char,
		p_PREMONEY	        int,
		p_NEXTMONEY	        int,
		p_CURRENTMONEY	    int,
		p_TERMNO						char,
		p_OPERCARDNO				char,
		p_CURRENTTIME	      out date, -- Return Operate Time
		p_TRADEID    	      out char, -- Return Trade Id
		p_TRADEID2				  out char,
		p_writeCardScript     varchar2,
		p_currOper	        char,
		p_currDept	        char,
		p_retCode	          out char, -- Return Code
		p_retMsg     	      out varchar2  -- Return Message
		  

)
AS
    v_ex                  exception;
    V_FEETYPE			  CHAR(1);
BEGIN
 BEGIN
		SP_PB_ChangeCard(p_ID,p_CUSTRECTYPECODE,p_CARDCOST,p_NEWCARDNO,p_OLDCARDNO,p_ONLINECARDTRADENO,
		                 p_CHECKSTAFFNO,p_CHECKDEPARTNO,p_CHANGECODE,p_ASN,p_CARDTYPECODE,
		                 p_SELLCHANNELCODE,p_TRADETYPECODE,p_DEPOSIT,p_SERSTARTTIME,p_SERVICEMONE,
		                 p_CARDACCMONEY,p_NEWSERSTAKETAG,p_SUPPLYREALMONEY,p_TOTALSUPPLYMONEY,
		                 p_OLDDEPOSIT,p_SERSTAKETAG,p_PREMONEY,p_NEXTMONEY,p_CURRENTMONEY,
		                 p_TERMNO,p_OPERCARDNO,p_CURRENTTIME,p_TRADEID,p_TRADEID2,p_currOper,p_currDept,
		                 p_retCode,p_retMsg);
		                 
     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;
   
   BEGIN
    --UPDATE TF_F_CARDREC
   	   --SET VALIDENDDATE = (SELECT VALIDENDDATE FROM TF_F_CARDREC WHERE CARDNO = p_OLDCARDNO)
   	 --WHERE CARDNO = p_NEWCARDNO;
   	 
   	 UPDATE TF_F_CARDREC
   	    SET VALIDENDDATE = '20501231'
   	  WHERE CARDNO = p_NEWCARDNO;
   	 
   	 EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001100100';
	            p_retMsg  := 'Fail to update tf_f_cardrec' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    IF p_CHANGECODE = '12' or p_CHANGECODE = '13' THEN
	    BEGIN
	    	UPDATE TF_B_TRADE
	    		SET  TRADETYPECODE = '55'
	    		WHERE TRADEID = p_TRADEID2;
	    		
			IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
			      WHEN OTHERS THEN
			          p_retCode := 'S001100105';
			          p_retMsg  := 'Error occurred while Updating TF_B_TRADE' || SQLERRM;
			      ROLLBACK; RETURN;
			END;
	 END IF;
	 
	 update tf_card_trade
	 set 	writeCardScript = p_writeCardScript	
	 where  tradeid = p_TRADEID;

-- 代理营业厅根据保证金修改可领卡额度，add by yin 20120104
   IF p_CHANGECODE = '12' OR p_CHANGECODE = '14' THEN V_FEETYPE := '3';
   ELSE  V_FEETYPE := '2';
   END IF;
	 BEGIN
			  SP_PB_DEPTBALFEE(p_TRADEID, V_FEETYPE ,--1预付款,2保证金,3预付款和保证金
							 p_CARDCOST + p_DEPOSIT,
							 p_CURRENTTIME,p_currOper,p_currDept,p_retCode,p_retMsg);
			
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
