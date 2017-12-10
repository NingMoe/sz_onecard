CREATE OR REPLACE PROCEDURE SP_TS_ChangeInfo
(
     p_CALLINGSTAFFNO     CHAR,
     p_CARDNO             VARCHAR2,
     p_CARNO              CHAR,
     p_strState           CHAR,
     p_BANKCODE	          CHAR,
     p_BANKACCNO	        VARCHAR2,
     p_STAFFNAME	        VARCHAR2,
     p_STAFFSEX	    			CHAR,
     p_STAFFPHONE	    		VARCHAR2,
     p_STAFFMOBILE	    	VARCHAR2,
     p_STAFFPAPERTYPECODE CHAR,
     p_STAFFPAPERNO      	VARCHAR2,
     
     p_STAFFPOST	    		VARCHAR2,
     p_STAFFADDR	    		VARCHAR2,
     p_STAFFEMAIL	    		VARCHAR2,
     
     p_CORPNO	            CHAR,
     p_DEPARTNO	    			CHAR,
     p_POSID	            CHAR,
     p_COLLECTCARDNO	    VARCHAR2,
     p_COLLECTCARDPWD	    VARCHAR2,
     
     p_DIMISSIONTAG       CHAR,
     p_TradeTypeCode      CHAR,
     p_operCardNo         VARCHAR2,
     p_writeCardUseTag    CHAR,
     p_SERMANAGERCODE     CHAR,
	 p_PURPOSETYPE		  CHAR,
	 
     p_currOper           CHAR ,  
     p_currDept           CHAR ,  
     
     p_retCode   				  OUT CHAR ,
     p_retMsg     				OUT VARCHAR2
)

AS
     v_currdate      DATE := SYSDATE;
     v_seqNo         CHAR(16);
     v_ex            EXCEPTION;
     v_balunitCode   CHAR(8);

BEGIN 
	
  BEGIN
	  --1) update CALLINGSTAFF info
	  UPDATE  TD_M_CALLINGSTAFF
		   SET  STAFFNAME            =    p_STAFFNAME,
				    STAFFSEX             =    p_STAFFSEX ,
						STAFFPHONE           =    p_STAFFPHONE,
						STAFFMOBILE          =    p_STAFFMOBILE,
						STAFFPAPERTYPECODE   =    p_STAFFPAPERTYPECODE,
						STAFFPAPERNO         =    p_STAFFPAPERNO,
						STAFFPOST            =    p_STAFFPOST,
						STAFFADDR            =    p_STAFFADDR,
						STAFFEMAIL           =    p_STAFFEMAIL,
						POSID                =    p_POSID,
						DIMISSIONTAG         =    p_DIMISSIONTAG,
						UPDATESTAFFNO        =    p_currOper,
		 				UPDATETIME           =    v_currdate,
						COLLECTCARDNO        =    p_COLLECTCARDNO,
						OPERCARDNO           =    p_CARDNO,
						COLLECTCARDPWD       =    p_COLLECTCARDPWD,
						CARNO                =    p_CARNO
		 WHERE	STAFFNO              =    p_CALLINGSTAFFNO
		  AND   CALLINGNO            =    '02';
		  
	  IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003103001';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;  
		  
  --2) get bulunitno
  v_balunitCode := '02' || p_CALLINGSTAFFNO;
  
  --3) update BALUNIT info
  BEGIN		
	  UPDATE  TF_TRADE_BALUNIT
		   SET	BALUNIT                =   p_STAFFNAME,           
		        BANKCODE               =   p_BANKCODE,
				    BANKACCNO              =   p_BANKACCNO,
				    CORPNO                 =   p_CORPNO,
				    DEPARTNO               =   p_DEPARTNO,
				    LINKMAN                =   p_STAFFNAME,
				    UNITPHONE              =   p_STAFFPHONE, 
				    UNITADD                =   p_STAFFADDR,
				    UNITEMAIL              =   p_STAFFEMAIL,
				    UPDATESTAFFNO          =   p_currOper,
				    UPDATETIME             =   v_currdate,
				    SERMANAGERCODE         =   p_SERMANAGERCODE,
					PURPOSETYPE			   =   p_PURPOSETYPE,
            FINBANKCODE            =   p_BANKCODE

		 WHERE	BALUNITNO              =   v_balunitCode;
	  
	  IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003103002';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END; 	 


  
  --4) get the sequence number
  SP_GetSeq(seq => v_seqNo); 

  --5) add the main log info
  BEGIN
	  INSERT  INTO  TF_B_ASSOCIATETRADE
			 (TRADEID,  TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
	 	VALUES
	 	   (v_seqNo, p_TradeTypeCode, p_CALLINGSTAFFNO, p_currOper, p_currDept, v_currdate	);
	 	
	 	EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003103004';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END; 
	
  --6) add additional log info into TF_B_TRADE_BALUNITCHANGE
  BEGIN
	  INSERT  INTO   TF_B_TRADE_BALUNITCHANGE
			(TRADEID          , BALUNITNO   , BALUNIT       , BALUNITTYPECODE  , SOURCETYPECODE ,
			 CALLINGNO        , CORPNO      , DEPARTNO      , CALLINGSTAFFNO   , BANKCODE       ,
			 BANKACCNO        , CREATETIME  , BALLEVEL      , BALCYCLETYPECODE , BALINTERVAL    ,
			 FINCYCLETYPECODE , FININTERVAL , FINTYPECODE   , COMFEETAKECODE   , LINKMAN        ,
			 UNITPHONE        , UNITADD     , SERMANAGERCODE,	FINBANKCODE    ,
			 CHANNELNO        , UNITEMAIL   , PURPOSETYPE )
	
		VALUES
		  (v_seqNo          , v_balunitCode, p_STAFFNAME, '03'             ,       '02' ,
		   '02'             , p_CORPNO     , p_DEPARTNO , p_CALLINGSTAFFNO , p_BANKCODE ,
		   p_BANKACCNO      , v_currdate   , '2'        , '00'             ,     12      ,
		   '00'             , 12           , '0'        , '0'              , p_STAFFNAME,
		   p_STAFFPHONE     , p_STAFFADDR  , p_SERMANAGERCODE, '',
		   'D001'           , p_STAFFEMAIL , p_PURPOSETYPE);
		   
		EXCEPTION
	    WHEN OTHERS THEN
	      p_retCode := 'S003103005';
	      p_retMsg  := '';
	      ROLLBACK; RETURN;
  END;  

  --7) add additional log info into TF_B_CALLINGSTAFFCHANGE
  BEGIN
		INSERT INTO TF_B_CALLINGSTAFFCHANGE
			(TRADEID      , CALLINGNO,
			 STAFFNO      , STAFFNAME    , STAFFPAPERTYPECODE  , STAFFPAPERNO  ,
			 STAFFADDR    , STAFFPHONE   , STAFFMOBILE         , STAFFPOST     , STAFFEMAIL ,
			 STAFFSEX     , OPERCARDNO   , COLLECTCARDNO       , COLLECTCARDPWD, POSID      ,
			 CARNO        , DIMISSIONTAG    				)
	
		VALUES
		  (v_seqNo       , '02',
		   p_CALLINGSTAFFNO , p_STAFFNAME   , p_STAFFPAPERTYPECODE , p_STAFFPAPERNO	 ,
		   p_STAFFADDR   , p_STAFFPHONE	    , p_STAFFMOBILE	  , p_STAFFPOST          , p_STAFFEMAIL	,
		   p_STAFFSEX	   , p_CARDNO         , p_COLLECTCARDNO , p_COLLECTCARDPWD     , p_POSID		  ,
		   p_CARNO			 , p_DIMISSIONTAG       );
		   
		EXCEPTION
	    WHEN OTHERS THEN
	      p_retCode := 'S003103006';
	      p_retMsg  := SQLERRM;
	      ROLLBACK; RETURN;
  END;     
		

  IF p_writeCardUseTag = '1' THEN
	  BEGIN
	  	 -- add the card writing trade log
	     INSERT INTO TF_CARD_TRADE 																								
		      (	TRADEID, TRADETYPECODE,	strOperCardNo, strCardNo, strStaffno, strState,
		        strTaxino, OPERATETIME,	SUCTAG	)
	     VALUES																								
		      (	v_seqNo, p_TradeTypeCode, p_operCardNo, p_CARDNO, p_CALLINGSTAFFNO, p_strState,
		 	    	p_CARNO, v_currdate,	'0'     );
		 	    	
		   EXCEPTION
	     WHEN OTHERS THEN
	      p_retCode := 'S008100020';
	      p_retMsg  := '';
	      ROLLBACK; RETURN;
    END;     
  END IF;
  

  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
END;


/
show errors  