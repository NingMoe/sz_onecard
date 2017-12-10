

CREATE OR REPLACE PROCEDURE SP_Bus_ChangeInfo
(
     p_CALLINGSTAFFNO     CHAR,
     p_CARDNO             VARCHAR2,
     p_CARNO              CHAR,
     p_STAFFNAME	        VARCHAR2,
     p_STAFFSEX	    			CHAR,
     p_STAFFPHONE	    		VARCHAR2,
     p_STAFFMOBILE	    	VARCHAR2,
     p_STAFFPAPERTYPECODE CHAR,
     p_STAFFPAPERNO      	VARCHAR2,
     p_STAFFPOST	    		VARCHAR2,
     p_STAFFADDR	    		VARCHAR2,
     p_STAFFEMAIL	    		VARCHAR2,
     p_POSID	            CHAR, 
     p_DIMISSIONTAG       CHAR,
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
						COLLECTCARDNO        =    p_CARDNO,
						OPERCARDNO           =    p_CARDNO,
						CARNO                =    p_CARNO
		 WHERE	STAFFNO              =    p_CALLINGSTAFFNO
		  AND   CALLINGNO            =    '01';
		  
	  IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003103001';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;  
		  
  --2) get the sequence number
  SP_GetSeq(seq => v_seqNo); 

  --3) add the main log info
  BEGIN
	  INSERT  INTO  TF_B_ASSOCIATETRADE
			 (TRADEID,  TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
	 	VALUES
	 	   (v_seqNo, '47', p_CALLINGSTAFFNO, p_currOper, p_currDept, v_currdate	);
	 	
	 	EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003103004';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END; 
	
  --4) add additional log info into TF_B_CALLINGSTAFFCHANGE
  BEGIN
		INSERT INTO TF_B_CALLINGSTAFFCHANGE
			(TRADEID      , CALLINGNO,
			 STAFFNO      , STAFFNAME    , STAFFPAPERTYPECODE    , STAFFPAPERNO ,
			 STAFFADDR    , STAFFPHONE   , STAFFMOBILE           , STAFFPOST    ,
			 STAFFEMAIL   , STAFFSEX     , OPERCARDNO            , COLLECTCARDNO,
			 POSID        , CARNO        , DIMISSIONTAG    				)
	
		VALUES
		  (v_seqNo          , '01',
		   p_CALLINGSTAFFNO , p_STAFFNAME    , p_STAFFPAPERTYPECODE , p_STAFFPAPERNO,
		   p_STAFFADDR      , p_STAFFPHONE	 , p_STAFFMOBILE	      , p_STAFFPOST   ,
		   p_STAFFEMAIL	    , p_STAFFSEX	   , p_CARDNO             , p_CARDNO      ,
		   p_POSID		      , p_CARNO			   , p_DIMISSIONTAG       );
		   
		EXCEPTION
	    WHEN OTHERS THEN
	      p_retCode := 'S003103006';
	      p_retMsg  := SQLERRM;
	      ROLLBACK; RETURN;
  END;     
		
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
END;


/
show errors  