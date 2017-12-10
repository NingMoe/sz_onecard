CREATE OR REPLACE PROCEDURE SP_TS_NewCard
(
    --opercardno pwd
    p_CALLINGSTAFFNO     CHAR,
    p_CARDNO             VARCHAR2,
    p_CARNO	             CHAR,
    p_strState           CHAR,
    p_BANKCODE	         CHAR,
    p_BANKACCNO	         VARCHAR2,
    p_STAFFNAME	         VARCHAR2,
    p_STAFFSEX	    		 CHAR,
    p_STAFFPHONE	    	 VARCHAR2,
    p_STAFFMOBILE	    	 VARCHAR2,
    p_STAFFPAPERTYPECODE CHAR,
    p_STAFFPAPERNO	     VARCHAR2,
    p_STAFFPOST	    		 VARCHAR2,
    p_STAFFADDR	    		 VARCHAR2,
    p_STAFFEMAIL	    	 VARCHAR2,
    p_CORPNO	           CHAR,
    p_DEPARTNO	    		 CHAR,
    p_POSID	             CHAR,
    p_COLLECTCARDNO	     VARCHAR2,
    p_COLLECTCARDPWD	   VARCHAR2,
    p_operCardNo         VARCHAR2,
    p_SERMANAGERCODE     CHAR ,
	p_PURPOSETYPE		 CHAR ,
    p_currOper           CHAR ,  
    p_currDept           CHAR ,  
    p_retCode   				 OUT CHAR,
    p_retMsg     				 OUT VARCHAR2
)
AS
   v_balunitCode        CHAR(8);
   v_currdate           DATE := SYSDATE;
   v_seqNo              CHAR(16);
   v_quantity           INT;
   v_balComsID          CHAR(8);

BEGIN 
	 
	--1) the p_CALLINGSTAFFNO has existed
	BEGIN
	 SELECT COUNT(*) INTO v_quantity FROM TD_M_CALLINGSTAFF 
	   WHERE STAFFNO = p_CALLINGSTAFFNO AND CALLINGNO = '02' ;
	  
	  IF v_quantity >= 1 THEN
       p_retCode := 'A003100033';
       p_retMsg  := '';
       RETURN;
    END IF; 
  END;
	
   --2) get bulunitno
   v_balunitCode :=  '02' || p_CALLINGSTAFFNO;
   
   BEGIN
	   SELECT COUNT(*) INTO v_quantity FROM TF_TRADE_BALUNIT
	     WHERE BALUNITNO = v_balunitCode ;
	    
	       IF v_quantity >= 1 THEN
         p_retCode := 'A003100133';
         p_retMsg  := '';
         RETURN;
       END IF; 
   END;   
   
   --3) add the trade balunit info
   BEGIN 
	   INSERT INTO TF_TRADE_BALUNIT
			 (BALUNITNO  , BALUNIT    , BALUNITTYPECODE ,   SOURCETYPECODE,   CALLINGNO       ,
			  CORPNO     , DEPARTNO   , CALLINGSTAFFNO  ,   BANKCODE      ,   BANKACCNO       ,
			  CREATETIME , BALLEVEL   , BALCYCLETYPECODE,   BALINTERVAL   ,   FINCYCLETYPECODE,
			  FININTERVAL, FINTYPECODE, COMFEETAKECODE  ,   LINKMAN       ,   UNITPHONE       ,
			  UNITADD    , UPDATETIME	, USETAG          ,   SERMANAGERCODE,	  FINBANKCODE     ,	
			  UPDATESTAFFNO,CHANNELNO , UNITEMAIL		,	PURPOSETYPE)
	   VALUES
		   (v_balunitCode, p_STAFFNAME, '03'             , '02'       ,      '02'   ,
	      p_CORPNO     , p_DEPARTNO , p_CALLINGSTAFFNO , p_BANKCODE , p_BANKACCNO ,
	      v_currdate   , '2'        , '00'             ,  12         ,      '00'   ,
		    12           , '0'        , '0'              , p_STAFFNAME, p_STAFFPHONE,
	      p_STAFFADDR  , v_currdate , '1'  			       , p_SERMANAGERCODE,p_BANKCODE,
	      p_currOper   , 'D001'	    ,p_STAFFEMAIL		,	 p_PURPOSETYPE);
	      
	    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003100002';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END; 
   
   
	 --4) add the taxi com fee scheme 
   -- get one comscheme Code, A5  means get coms scheme code, len = 8 
   SP_GetBizAppCode(1, 'A5', 8, v_balComsID);

	 --5) add TD_TBALUNIT_COMSCHEME info
	 BEGIN 
	  INSERT INTO TD_TBALUNIT_COMSCHEME																											
	   (BALUNITNO				,	COMSCHEMENO				,	BEGINTIME		,	  ENDTIME,						
		  UPDATESTAFFNO		,	UPDATETIME			  ,	ID					,   USETAG				)	
	  VALUES(v_balunitCode , 'TAXI0001'     ,	TRUNC(SYSDATE,'month'), 
           TO_DATE('20501231235959','YYYYMMDDHH24MISS'),
		       p_currOper, v_currdate, v_balComsID, '1' );
			
	  EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008109002';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END; 
   
   
   --6) add the callingstaff info
   BEGIN
	   INSERT INTO TD_M_CALLINGSTAFF
			 (STAFFNO, CALLINGNO,
			  STAFFNAME, STAFFPAPERTYPECODE, STAFFPAPERNO, STAFFADDR,
				STAFFPHONE, STAFFMOBILE, STAFFPOST , STAFFEMAIL, STAFFSEX ,
			  OPERCARDNO, COLLECTCARDNO, COLLECTCARDPWD, POSID, CARNO,
				DIMISSIONTAG, UPDATESTAFFNO, UPDATETIME)
	
	   VALUES
	     (p_CALLINGSTAFFNO, '02', 
	      p_STAFFNAME, p_STAFFPAPERTYPECODE, p_STAFFPAPERNO, p_STAFFADDR ,
	      p_STAFFPHONE, p_STAFFMOBILE, p_STAFFPOST, p_STAFFEMAIL, p_STAFFSEX,
	     	p_CARDNO, p_COLLECTCARDNO, p_COLLECTCARDPWD, p_POSID, p_CARNO,
				'1', p_currOper, v_currdate);
				
	    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003100003';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END; 
	
	  

   --7) add the balunit soruce info
   BEGIN
	   INSERT INTO TD_M_TRADE_SOURCE
			 (SOURCECODE,  BALUNITNO, USETAG, UPDATESTAFFNO, UPDATETIME)
	   VALUES
	     (v_balunitCode, v_balunitCode, '1', p_currOper, v_currdate);
	    		
	    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003100004';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END;  
	   
   --8) get the sequence number
   SP_GetSeq(seq => v_seqNo); 
   
  
   --9) add the balevent info
   BEGIN
    INSERT INTO  TD_TRADE_BALEVENT
		 (ID, EVENTTYPECODE,	BALUNITNO,	DEALSTATECODE1,	DEALSTATECODE2,	OCCURTIME	)
	  VALUES
		 (v_seqNo, '0039',	v_balunitCode,	'0', '0',	v_currdate);
		
		EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003100011';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END;
   
    
   --10) add main log info
   BEGIN
	   INSERT INTO TF_B_ASSOCIATETRADE
			 (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
	 	 VALUES
	 	   (v_seqNo, '39',  p_CALLINGSTAFFNO,  p_currOper, p_currDept , v_currdate);
	 	 
	 	 EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003100008';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END;   
	 	  
	 --11) add additional log info  into TF_B_TRADE_BALUNITCHANGE
   BEGIN
		 INSERT INTO TF_B_TRADE_BALUNITCHANGE
			 (TRADEID, BALUNITNO, BALUNIT, BALUNITTYPECODE, SOURCETYPECODE ,
			  CALLINGNO, CORPNO, DEPARTNO, CALLINGSTAFFNO, BANKCODE,
			  BANKACCNO, CREATETIME, BALLEVEL, BALCYCLETYPECODE , BALINTERVAL,
			  FINCYCLETYPECODE, FININTERVAL, FINTYPECODE , COMFEETAKECODE, LINKMAN,
			  UNITPHONE, UNITADD, SERMANAGERCODE,	FINBANKCODE, CHANNELNO ,UNITEMAIL ,PURPOSETYPE)
	
	   VALUES
		   (v_seqNo, v_balunitCode, p_STAFFNAME, '03' ,  '02',
		    '02' , p_CORPNO, p_DEPARTNO, p_CALLINGSTAFFNO, p_BANKCODE ,
	      p_BANKACCNO, v_currdate, '2', '00', 12 ,
	      '00', 12 , '0' , '0', p_STAFFNAME,
		    p_STAFFPHONE, p_STAFFADDR, p_SERMANAGERCODE,'' , 'D001', p_STAFFEMAIL,p_PURPOSETYPE);
		 
		  EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003100009';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END;      
		    
	 --12) add additional log info  into TF_B_CALLINGSTAFFCHANGE
	 BEGIN 
		 INSERT INTO TF_B_CALLINGSTAFFCHANGE
			 (TRADEID, CALLINGNO, 
			  STAFFNO, STAFFNAME , STAFFPAPERTYPECODE, STAFFPAPERNO,
			  STAFFADDR, STAFFPHONE, STAFFMOBILE, STAFFPOST, STAFFEMAIL,
			  STAFFSEX, OPERCARDNO, COLLECTCARDNO, COLLECTCARDPWD, POSID,
			  CARNO, DIMISSIONTAG )
	
	   VALUES
	     (v_seqNo, '02', 
	      p_CALLINGSTAFFNO, p_STAFFNAME, p_STAFFPAPERTYPECODE, p_STAFFPAPERNO,
	      p_STAFFADDR, p_STAFFPHONE, p_STAFFMOBILE, p_STAFFPOST, p_STAFFEMAIL,
	      p_STAFFSEX, p_CARDNO , p_COLLECTCARDNO, p_COLLECTCARDPWD, p_POSID,
	      p_CARNO,  '1'  );
	      
	    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003100010';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END;    
	     
	 --13) add additional log info into TF_TBALUNIT_COMSCHEMECHANGE   
   BEGIN 
	   -- add comscheme info
	   INSERT INTO TF_TBALUNIT_COMSCHEMECHANGE
	      (TRADEID,  COMSCHEMENO, BALUNITNO, ID, BEGINTIME, ENDTIME)
	      
	   VALUES
	      (v_seqNo, 'TAXI0001', v_balunitCode,v_balComsID,
	       TRUNC(SYSDATE,'month'), TO_DATE('20501231235959','YYYYMMDDHH24MISS') );
           
      EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008104007';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END; 
	
	 
   --14) add the card writing trade log
   BEGIN
	   INSERT INTO TF_CARD_TRADE 																								
		      (	TRADEID	,	  TRADETYPECODE	,	strOperCardNo	,	strCardNo, strStaffno,strState,
		        strTaxino,	OPERATETIME		,	SUCTAG	)
	   VALUES																								
		      (	v_seqNo,	'39'  				,	p_operCardNo  ,	p_CARDNO , p_CALLINGSTAFFNO, p_strState,
		 	    	p_CARNO,	v_currdate  	,	'0'     );
		 	    	
		   EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008100020';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END; 	    	
		 	    	
   p_retCode := '0000000000';
   p_retMsg  := '';
   COMMIT; RETURN;
END;

/

show errors   
