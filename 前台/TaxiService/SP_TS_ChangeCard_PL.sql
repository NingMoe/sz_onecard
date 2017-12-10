

CREATE OR REPLACE PROCEDURE SP_TS_ChangeCard
(
    p_CALLINGSTAFFNO      CHAR,
    p_NewCardNo           VARCHAR2,
    p_OldCardNo           VARCHAR2,
    p_CARNO               CHAR,
    p_strState            CHAR,
    p_BANKCODE	          CHAR,
    p_BANKACCNO	          VARCHAR2,
    p_STAFFNAME	          VARCHAR2,
    p_STAFFSEX	    			CHAR,
    p_STAFFPHONE	    		VARCHAR2,
    p_STAFFMOBILE	    	  VARCHAR2,
    p_STAFFPAPERTYPECODE  CHAR,
    p_STAFFPAPERNO	     	VARCHAR2,
    p_STAFFPOST	    		  VARCHAR2,
    p_STAFFADDR	    		  VARCHAR2,
    p_STAFFEMAIL	    		VARCHAR2,
    p_CORPNO	            CHAR,
    p_DEPARTNO	    			CHAR,
    p_POSID	              CHAR,
    p_COLLECTCARDNO	      VARCHAR2,
    p_COLLECTCARDPWD	    VARCHAR2,
    
    p_DIMISSIONTAG        CHAR,
    p_REMARK              VARCHAR2,
    p_operCardNo          VARCHAR2,
    
    p_currOper            CHAR ,  
    p_currDept            CHAR ,  
    p_retCode   				  OUT CHAR,
    p_retMsg     				  OUT VARCHAR2
)

AS
    v_currdate      DATE := SYSDATE;
    v_seqNo         CHAR(16);
    v_balunitCode   CHAR(8);
    v_ex            EXCEPTION;
BEGIN
	
	
  --1) update CALLINGSTAFF info
  BEGIN
	  UPDATE  TD_M_CALLINGSTAFF
		   SET  COLLECTCARDNO     =   p_COLLECTCARDNO,
	     	    OPERCARDNO        =   p_NewCardNo,
				    UPDATESTAFFNO     =   p_currOper,
				    UPDATETIME        =   v_currdate,
				    REMARK            =   p_REMARK
		 WHERE  STAFFNO           =   p_CALLINGSTAFFNO 
		   AND  CALLINGNO         =   '02';
		
		IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003101001';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END; 
		 
  
  --2) get bulunitno
  v_balunitCode  := '02' || p_CALLINGSTAFFNO;   
  
  --3) update BALNUIT info
  BEGIN
	  UPDATE  TF_TRADE_BALUNIT
		   SET	BANKCODE          =   p_BANKCODE,
				    BANKACCNO         =   p_BANKACCNO,
				    UPDATESTAFFNO     =   p_currOper,
				    UPDATETIME        =   v_currdate ,
				    REMARK            =   p_REMARK
		WHERE   BALUNITNO         =   v_balunitCode;   
		 
	  IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003101002';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;  
	  
  --4) get the sequence number
  SP_GetSeq(seq => v_seqNo); 
   

  --5) add the main log info
  BEGIN
	  INSERT  INTO  TF_B_ASSOCIATETRADE
			 (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
	 	VALUES
	 	   (v_seqNo, '40', p_CALLINGSTAFFNO, p_currOper, p_currDept,  v_currdate);
	 	   
	  EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003101004';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END; 
		 
	--6) add additional log info into TF_B_TRADE_BALUNITCHANGE
	BEGIN
	  INSERT  INTO   TF_B_TRADE_BALUNITCHANGE
			(TRADEID          , BALUNITNO   , BALUNIT     , BALUNITTYPECODE  , SOURCETYPECODE ,
			 CALLINGNO        , CORPNO      , DEPARTNO    , CALLINGSTAFFNO   , BANKCODE       ,
			 BANKACCNO        , CREATETIME  , BALLEVEL    , BALCYCLETYPECODE , BALINTERVAL    ,
			 FINCYCLETYPECODE , FININTERVAL , FINTYPECODE , COMFEETAKECODE   , LINKMAN        ,
			 UNITPHONE        , UNITADD     , REMARK			, SERMANAGERCODE   , FINBANKCODE    ,
			 CHANNELNO        , UNITEMAIL  	)
		VALUES
		  (v_seqNo          , v_balunitCode, p_STAFFNAME, '03'            ,       '02' ,
		   '02'             , p_CORPNO     , p_DEPARTNO , p_CALLINGSTAFFNO, p_BANKCODE ,
		   p_BANKACCNO      , v_currdate   , '2'        , '00'            ,     12     ,
		   '00'             , 12           , '0'        , '0'             , p_STAFFNAME,
		   p_STAFFPHONE     , p_STAFFADDR  , p_REMARK   , ''              ,  ''		     ,
		   'D001'           , p_STAFFEMAIL );
		
		EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003101005';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;   
		   
  --7) add additional log info into TF_B_CALLINGSTAFFCHANGE
  BEGIN
		INSERT INTO TF_B_CALLINGSTAFFCHANGE
			(TRADEID      , CALLINGNO    ,
			 STAFFNO      , STAFFNAME    , STAFFPAPERTYPECODE    , STAFFPAPERNO      ,
			 STAFFADDR    , STAFFPHONE   , STAFFMOBILE           , STAFFPOST         , STAFFEMAIL        ,
			 STAFFSEX     , OPERCARDNO   , OLDCARDNO              , COLLECTCARDNO    , COLLECTCARDPWD    ,
			 POSID        , CARNO        , DIMISSIONTAG    				)
	
		VALUES
		  (v_seqNo       , '02',
		   p_CALLINGSTAFFNO  , p_STAFFNAME     , p_STAFFPAPERTYPECODE  , p_STAFFPAPERNO	 ,
		   p_STAFFADDR   , p_STAFFPHONE	     , p_STAFFMOBILE	 , p_STAFFPOST           , p_STAFFEMAIL	   ,
		   p_STAFFSEX	   , p_NewCardNo       , p_OldCardNo     , p_COLLECTCARDNO       , p_COLLECTCARDPWD,
		   p_POSID		   , p_CARNO			     , p_DIMISSIONTAG       );
	  
	  EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003101006';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END; 
	
	
  --8) add the card writing trade log
  BEGIN
    INSERT INTO TF_CARD_TRADE 																								
	   (TRADEID	,	  TRADETYPECODE	,	strOperCardNo	,	strCardNo, strStaffno,strState,
	    strTaxino,	OPERATETIME		,	SUCTAG	)
    VALUES																								
	   (v_seqNo,	'40'  				,	p_operCardNo		,	p_NewCardNo,p_CALLINGSTAFFNO,p_strState,
	 	  p_CARNO,	v_currdate	,	'0'     );
	  
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