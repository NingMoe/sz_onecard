	
	CREATE OR REPLACE PROCEDURE SP_TS_ConsumeAppend
	(
	    p_IDENTIFYNO      CHAR,                       
	    p_ASN             CHAR,            
	    p_CARDTRADENO	    CHAR,            
	    p_SAMNO	          CHAR,            
	    p_POSTRADENO      CHAR,            
	    p_TRADEDATE	      CHAR,
	    p_TRADETIME       CHAR,       
	    p_PREMONEY	      INT,            
	    p_TRADEMONEY	    INT,            
	    p_BALUNITNO	      CHAR,            
	    p_CALLINGNO	      CHAR,            
	    p_CORPNO	        CHAR,            
	    p_DEPARTNO	      CHAR,            
	    p_CALLINGSTAFFNO  CHAR,            
	    p_TAC	            CHAR,            
	    p_DEALSTATECODE	  CHAR,            
	                
	    p_currOper        CHAR , 
	    p_currDept        CHAR , 
	    p_retCode   			OUT CHAR,               
	    p_retMsg     		  OUT VARCHAR2            
	)
	AS
	    v_currdate      DATE := SYSDATE;
	    v_seqNo         CHAR(16);
	    v_cardNo        CHAR(16);
		v_int			int;
	
BEGIN 
		
	  --1) add TF_TRADE_EXCLUDE info
	BEGIN
		merge into TF_TRADE_EXCLUDE t
            using dual on (t.IDENTIFYNO = p_IDENTIFYNO)
		when not matched then
			INSERT(IDENTIFYNO) VALUES( p_IDENTIFYNO );
	
	EXCEPTION
	      WHEN OTHERS THEN
	        p_retCode := 'A003106026';
	        p_retMsg  := '';
	        ROLLBACK; RETURN;
	END; 										
	  
	begin
		select count(*) into v_int
		from TF_B_TRADE_ACPMANUAL
		where id=p_IDENTIFYNO;
		if(v_int>0) then
			p_retCode := 'A003106026';
			p_retMsg  := '';
			ROLLBACK; RETURN;
		end if;
	end;
	begin
		select count(*) into v_int
		from TH_B_TRADE_ACPMANUAL
		where id=p_IDENTIFYNO;
		if(v_int>0) then
			p_retCode := 'A003106026';
			p_retMsg  := '';
			ROLLBACK; RETURN;
		end if;
	end;
	  --2) get the sequence number
	  SP_GetSeq(seq => v_seqNo); 
	  
	  
	  --3) get the cardno from asn
	  BEGIN
		  SELECT CARDNO INTO v_cardNo FROM TF_F_CARDREC WHERE ASN = p_ASN AND SUBSTR(CARDNO, 1, 6) <> '215031';

		  EXCEPTION
		  WHEN NO_DATA_FOUND THEN
			  p_retCode := 'A003106004';
			  p_retMsg  := '';
			  ROLLBACK; RETURN;
	  END;
	
	 
		--4) add TF_B_TRADE_ACPMANUAL info	
		BEGIN																		
		  INSERT  INTO   TF_B_TRADE_ACPMANUAL																																																								
				(TRADEID  	,	ID			    ,	CARDNO 				  , RECTYPE         , ICTRADETYPECODE,
				 ASN			  ,	CARDTRADENO ,				
				 SAMNO			,	POSTRADENO	,	TRADEDATE				, TRADETIME       ,
				 PREMONEY		,	TRADEMONEY  ,				
				 BALUNITNO	,	CALLINGNO		,	CORPNO				  ,	DEPARTNO				,	CALLINGSTAFFNO,				
				 TAC			  ,	DEALTIME		,	RENEWTYPECODE		,	DEALSTATECODE		,	RENEWSTATECODE,				
				 STAFFNO		,	OPERATETIME					)																	
																															
		  VALUES		
		    (v_seqNo	  ,	p_IDENTIFYNO  ,	v_cardNo			,'0'              , '05', 	
		     p_ASN 				  ,	p_CARDTRADENO	 ,	
				 p_SAMNO    ,	p_POSTRADENO	,	p_TRADEDATE	 	,	p_TRADETIME     ,
				 p_PREMONEY	,	p_TRADEMONEY	,						
				 p_BALUNITNO,	p_CALLINGNO	  ,	p_CORPNO		  , p_DEPARTNO			,	p_CALLINGSTAFFNO,						
				 p_TAC			,	v_currdate    ,	 '2'		      ,	p_DEALSTATECODE ,	'0' ,						
				 p_currOper ,	v_currdate				)	;
				 
		  EXCEPTION
	      WHEN OTHERS THEN
	        p_retCode := 'S003106002';
	        p_retMsg  := '';
	        ROLLBACK; RETURN;
	    END; 
			 		 
				 																
	    p_retCode := '0000000000';
	    p_retMsg  := '';
	    COMMIT; RETURN;
	END;
	
	
	/
	
	show errors         
	         	    	       