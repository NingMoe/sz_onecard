CREATE OR REPLACE PROCEDURE SP_PB_ReturnCardRollback
(
		p_ID              char,
		p_CANCELTRADEID   char,
		p_CARDNO	        char,
		p_REASONCODE      char,
		p_TRADETYPECODE	  char,
		p_CARDTRADENO     char,
		p_REFUNDMONEY     int,
		p_REFUNDDEPOSIT   int,
		p_TRADEPROCFEE    int,
		p_OTHERFEE        int,
		p_CARDSTATE       char,
		p_SERSTAKETAG     char,
		p_TERMNO					char,
		p_OPERCARDNO			char,
		p_TRADEID    	    out char, -- Return Trade Id
		p_currOper        char,
		p_currDept        char,
		p_retCode	        out char, -- Return Code
		p_retMsg     	    out varchar2  -- Return Message

)
AS
    v_TradeID char(16);
    v_CUSTNAME            varchar2(200);
    v_PAPERTYPECODE       varchar2(2);
    v_PAPERNO             varchar2(200);
		v_CURRENTTIME date := sysdate;
    v_ex          exception;
    
BEGIN
   -- 0) Get old card's cust info add by hzl 20130905
    BEGIN
     IF SUBSTR(p_CARDNO,0,6)='215061' THEN
      SELECT CUSTNAME, PAPERTYPECODE, PAPERNO
      INTO v_CUSTNAME, v_PAPERTYPECODE, v_PAPERNO
      FROM TF_F_CUSTOMERREC
      WHERE CARDNO = p_CARDNO;
    END IF;
    EXCEPTION
				    WHEN NO_DATA_FOUND THEN
				    p_retCode := 'A001004132';
				    p_retMsg  := 'Fail to find the card' || SQLERRM;
				    ROLLBACK; RETURN;
    END;

		-- 1) update card info
		BEGIN
				UPDATE TF_F_CARDREC
				SET CARDSTATE = p_CARDSTATE,
				    USETAG = '1',
				    SERSTAKETAG = p_SERSTAKETAG,
				    UPDATESTAFFNO = p_currOper,
				    UPDATETIME = v_CURRENTTIME
				WHERE CARDNO = p_CARDNO;

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001021102';
	            p_retMsg  := 'Fail to update card info' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

   	-- 2) update resstate
   	BEGIN
		   	UPDATE TL_R_ICUSER
		   	SET DESTROYTIME = null,
		   	    RESSTATECODE = '06',
		   	    UPDATESTAFFNO = p_currOper,
				    UPDATETIME = v_CURRENTTIME
				WHERE CARDNO = p_CARDNO;

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001021103';
	            p_retMsg  := 'Fail to update resstate' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

   	-- 3) update acc info
   	BEGIN
		   	UPDATE TF_F_CARDEWALLETACC SET USETAG = '1'
		   	WHERE CARDNO = p_CARDNO;

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001021104';
	            p_retMsg  := 'Fail to update acc info' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

   	-- 6) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;

   	-- 4) update operation
   	BEGIN
		   	UPDATE TF_B_TRADE
		   	SET CANCELTAG = '1',
		   	CANCELTRADEID = v_TradeID
		   	WHERE TRADEID = p_CANCELTRADEID;

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001021105';
	            p_retMsg  := 'Fail to update operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 5) update destroy operation
    IF p_REASONCODE = '11' OR p_REASONCODE = '12' OR p_REASONCODE = '13' THEN
	    BEGIN
	    	 UPDATE TF_B_TRADE
	    	 SET CANCELTAG = '1',
	    	 CANCELTRADEID = v_TradeID
	    	 WHERE CARDNO = p_CARDNO AND TRADETYPECODE = '06' AND CANCELTAG = '0';

		    	IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
			EXCEPTION
		        WHEN OTHERS THEN
		            p_retCode := 'S001021106';
		            p_retMsg  := 'Fail to update destroy operation' || SQLERRM;
		            ROLLBACK; RETURN;
	    END;
   	END IF;



    -- 7) log tradefee
    BEGIN
		    INSERT INTO TF_B_TRADEFEE
		           (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,CARDDEPOSITFEE,SUPPLYMONEY,TRADEPROCFEE,
		           OTHERFEE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
		    VALUES
		          (p_ID,v_TradeID,p_TRADETYPECODE,p_CARDNO,p_CARDTRADENO,p_REFUNDDEPOSIT,p_REFUNDMONEY,
		          p_TRADEPROCFEE,p_OTHERFEE,p_currOper,p_currDept,V_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001021107';
	            p_retMsg  := 'Fail to log tradefee' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

   	-- 8) log operation
   	BEGIN
		   	INSERT INTO TF_B_TRADE
		   	       (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CURRENTMONEY,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,CANCELTRADEID)
		   	  SELECT
		   	        v_TradeID,p_ID,p_TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,p_REFUNDDEPOSIT+p_REFUNDMONEY,
		   	        p_currOper,p_currDept,v_CURRENTTIME,p_CANCELTRADEID
		   	  FROM TF_F_CARDREC
		   	  WHERE CARDNO = p_CARDNO;

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001021108';
	            p_retMsg  := 'Fail to log operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 9) Log the writeCard
    BEGIN
		    INSERT INTO TF_CARD_TRADE
		    		(TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,strTermno,OPERATETIME,SUCTAG)
		    VALUES
		    		(v_TradeID,p_TRADETYPECODE,p_OPERCARDNO,p_CARDNO,p_TERMNO,v_CURRENTTIME,'0');

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001139';
	            p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    

     -- 10) Log the sync information while CARD_TYPE is 61
   BEGIN
      IF SUBSTR(p_CARDNO,0,6)='215061' THEN   
       INSERT INTO TF_B_SYNC(TRADEID,CITIZEN_CARD_NO,Trans_Code,Name,Paper_Type,Paper_No,CARD_TYPE,OPERATESTAFFNO,OPERATEDEPARTNO,OPERATETIME)
       VALUES(v_TradeID,p_CARDNO,'9511',v_CUSTNAME,v_PAPERTYPECODE,v_PAPERNO,'61',p_currOper,p_currDept,v_CURRENTTIME);
  END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001001140';
              p_retMsg  := 'Fail to log the sync information while CARD_TYPE is 61' || SQLERRM;
              ROLLBACK; RETURN;

END;

  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;
/
show errors
