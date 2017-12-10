CREATE OR REPLACE PROCEDURE SP_EW_ChangeCard
(
		p_OLDCARDNO	        char,     --旧卡卡号
		p_TRADETYPECODE     char,     --业务类型编码
		p_CHANGECODE	      char,     --换卡类型
		p_CARDCOST	        int ,     --卡费					
		p_CARDACCMONEY	    int ,     --账户余额			
		p_TRADEORIGIN       varchar2, --业务来源
		p_currOper	        char,		  --员工编码
		p_TRADEID    	      out char, -- Return Trade Id
		p_retCode	          out char, -- Return Code
		p_retMsg     	      out varchar2  -- Return Message
)
AS
    v_ID	              char(18); --记录流水号
    v_CARDTRADENO     	char(4) := '0000';  --联机交易序号
    v_today             date := sysdate;
    v_TradeID           char(16);
    v_currDept	        char(4) ;
    v_SERSTAKETAG       char(1) := '3'; --不收取
    v_ex                exception;
BEGIN
		-- 1) Get ID
		v_ID := TO_CHAR(SYSDATE, 'MMDDHHMMSS') || SUBSTR(p_OLDCARDNO, -8);
		
		-- *) Set v_SERSTAKETAG
		--IF p_CHANGECODE = '13' or p_CHANGECODE = '15' THEN --自然损
		--	v_SERSTAKETAG := '3'; --不收取
    --ELSE --人为损
    --  v_SERSTAKETAG := '2'; --一次扣完
		--END IF;
		
    -- 2) Get DEPARTNO
    BEGIN
      SELECT DEPARTNO 
      INTO   v_currDept
      FROM   TD_M_INSIDESTAFF
      WHERE  STAFFNO = p_currOper
      AND    DIMISSIONTAG = '1';
    EXCEPTION WHEN NO_DATA_FOUND THEN 
      v_currDept := '9002';
    END;		
		
    -- 3) Update old card's resource statecode
    BEGIN
		    UPDATE TL_R_ICUSER
		    SET    DESTROYTIME   = v_today,
		           RESSTATECODE  = '03',
		           UPDATESTAFFNO = p_currOper,
		           UPDATETIME    = v_today
		    WHERE  CARDNO        = p_OLDCARDNO;

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001004106';
	            p_retMsg  := 'Error occurred while updating resource statecode of old card' || SQLERRM;
	            RETURN;
    END;		        
    
    -- 4) Update old card's wallet usetag
    BEGIN
		    UPDATE TF_F_CARDEWALLETACC
		    SET    USETAG = '0'
		    WHERE  CARDNO = p_OLDCARDNO
		    AND    USETAG = '1';

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
			      WHEN OTHERS THEN
			          p_retCode := 'S001004102';
			          p_retMsg  := 'Error occurred while Updating wallet usetag of old card' || SQLERRM;
			      RETURN;
		END;	
    
    -- 5) update old card's cust info
    BEGIN
		    UPDATE TF_F_CUSTOMERREC
		    SET    USETAG = '0'
		    WHERE  CARDNO = p_OLDCARDNO
		    AND    USETAG = '1';

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
			      WHEN OTHERS THEN
			          p_retCode := 'S001004129';
			          p_retMsg  := 'Error occurred while updating cust info of old card' || SQLERRM;
			      RETURN;
		END;
		
		-- 6) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;		
    
    -- 7) Log operation
    BEGIN
		    INSERT INTO TF_B_TRADE(
		        TRADEID         , ID             , TRADETYPECODE       , CARDNO         ,
		        ASN             , CARDTYPECODE   , CARDTRADENO         , REASONCODE     ,
		        OLDCARDNO       , DEPOSIT        , OLDCARDMONEY        , CURRENTMONEY   ,
		        OPERATESTAFFNO  , OPERATEDEPARTID, OPERATETIME         , CARDSTATE      , 
		        SERSTAKETAG     , TRADEORIGIN
		   )SELECT
		        v_TradeID       , v_ID           , p_TRADETYPECODE     , p_OLDCARDNO    ,
		        t.ASN           , t.CARDTYPECODE , v_CARDTRADENO       , p_CHANGECODE   ,
		        ''              , 0              , p_CARDACCMONEY      , 0              ,
		        p_currOper      , v_currDept     , v_today             , t.CARDSTATE    , 
		        t.SERSTAKETAG   , p_TRADEORIGIN
		    FROM TF_F_CARDREC t
		    WHERE CARDNO = p_OLDCARDNO;
		    
    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001004108';
	            p_retMsg  := 'Fail to log the operation' || SQLERRM;
	            RETURN;	            
    END; 		
		
		-- 8) Update old card's info
		BEGIN
		    UPDATE TF_F_CARDREC
		    SET    CARDSTATE     = '22'          ,
		           USETAG        = '0'           ,
		           SERSTAKETAG   = v_SERSTAKETAG ,
		           UPDATESTAFFNO = p_currOper    ,
		           UPDATETIME    = v_today 
		    WHERE  CARDNO        = p_OLDCARDNO
		    AND    USETAG        = '1';

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
			      WHEN OTHERS THEN
			          p_retCode := 'S001004103';
			          p_retMsg  := 'Error occurred while updating rec info of old card' || SQLERRM;
			      RETURN;
		END;			    		        
		
    -- 9) Log the operation of cust info change
    BEGIN
		    INSERT INTO TF_B_CUSTOMERCHANGE(
		        TRADEID         , CARDNO       , CHGTYPECODE , OPERATESTAFFNO ,
		        OPERATEDEPARTID , OPERATETIME
		   )VALUES(
		        v_TradeID       , p_OLDCARDNO  , '11'        , p_currOper     ,
		        v_currDept      , v_today
		        );

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001004131';
	            p_retMsg  := 'Fail to log the operation of cust info change' || SQLERRM;
	            RETURN;
    END;		
    
    -- 10) Log the cash
    IF p_CHANGECODE = '12' OR p_CHANGECODE = '14' THEN
		    BEGIN
		        INSERT INTO TF_B_TRADEFEE(
		            ID                  , TRADEID     , TRADETYPECODE   , CARDNO         ,
		            CARDTRADENO         , CARDSERVFEE , CARDDEPOSITFEE  , OPERATESTAFFNO ,
		            OPERATEDEPARTID     , OPERATETIME , TRADEORIGIN
		       )VALUES(
		            v_ID                , v_TradeID   , p_TRADETYPECODE , p_OLDCARDNO    ,
		            v_CARDTRADENO       , p_CARDCOST  , 0               , p_currOper     ,
		            v_currDept          , v_today     , P_TRADEORIGIN
		            );

            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
				EXCEPTION
			        WHEN OTHERS THEN
			            p_retCode := 'S001004112';
			            p_retMsg  := 'Fail to log the cash' || SQLERRM;
			            RETURN;
		    END;
    END IF;    
    
  p_retCode := '0000000000';
	p_retMsg  := '';
	RETURN;
END;    		     

/
show errors               		    