CREATE OR REPLACE PROCEDURE SP_PB_SaleCardRollback
(
		p_ID              char,
		p_CARDNO	        char,
		p_CARDTRADENO     char,
		p_CARDMONEY	      int,
		p_DEPOSIT         int,
		p_CARDCOST        int,
		p_CANCELTRADEID   char,
		p_TRADEPROCFEE    int,
		p_OTHERFEE        int,
		p_TERMNO					char,
		p_OPERCARDNO			char,
		p_TRADEID    	    out char, -- Return Trade Id
		p_currOper	      char,
		p_currDept	      char,
		p_retCode	        out char, -- Return Code
		p_retMsg     	    out varchar2  -- Return Message

)
AS
    v_TRADETYPECODE  char(2);
    v_TradeID char(16);
    v_CUSTNAME        varchar2(250);
    v_PAPERTYPECODE   varchar2(2);
    v_PAPERNO         varchar2(250);
		v_CURRENTTIME   date := sysdate;
    v_ex            exception;
BEGIN

-- 1) Select CUSTNAME PAPERTYPECODE PAPERNO
   BEGIN
	SELECT
        A.CUSTNAME,A.PAPERTYPECODE,A.PAPERNO into v_CUSTNAME,v_PAPERTYPECODE,v_PAPERNO
        FROM TF_F_CUSTOMERREC A
        WHERE A.CARDNO = p_CARDNO ;
    EXCEPTION
				    WHEN NO_DATA_FOUND THEN
				    p_retCode := 'A001004132';
				    p_retMsg  := 'Fail to find the card' || SQLERRM;
				    ROLLBACK; RETURN;
    END;
    
		-- 2) update resstate
		BEGIN
				UPDATE TL_R_ICUSER
				SET RESSTATECODE = '05',
				    SELLTIME = null,
				    UPDATESTAFFNO = p_currOper,
				    UPDATETIME = v_CURRENTTIME
				WHERE CARDNO = p_CARDNO;

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001105';
	            p_retMsg  := 'Fail to update resstatecode' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 3) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;

    -- 4) Select tradetypecode
    BEGIN
		    SELECT b.CANCELCODE INTO v_TRADETYPECODE
		    FROM TF_B_TRADE a,TD_M_TRADETYPE b
		    WHERE a.TRADEID = p_CANCELTRADEID AND b.TRADETYPECODE = a.TRADETYPECODE;

    EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	          p_retCode := 'A001020101';
	          p_retMsg  := 'Can not find psam,' || SQLERRM;
	          ROLLBACK; RETURN;
	  END;

    -- 5)update salerecord
    BEGIN
    	UPDATE TF_B_TRADE
    	SET CANCELTAG  = '1',
    	CANCELTRADEID = v_TradeID
    	WHERE TRADEID = p_CANCELTRADEID;

    		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001020102';
	            p_retMsg  := 'Fail to update salerecord' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 5)log the tradefee
    BEGIN
		    INSERT INTO TF_B_TRADEFEE
		           (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,CARDSERVFEE,CARDDEPOSITFEE,TRADEPROCFEE,
		           OTHERFEE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
		       SELECT
		             p_ID,v_TradeID,v_TRADETYPECODE,CARDNO,p_CARDTRADENO,-CARDCOST,-DEPOSIT,p_TRADEPROCFEE,
		             p_OTHERFEE,p_currOper,p_currDept,v_CURRENTTIME
		       FROM TF_F_CARDREC
		       WHERE CARDNO = p_CARDNO;

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001020103';
	            p_retMsg  := 'Fail to log the tradefee' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 6)log the operation
    BEGIN
		    INSERT INTO TF_B_TRADE
		           (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,CURRENTMONEY,
		           OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,CANCELTRADEID)
		       SELECT
		             v_TradeID,p_ID,v_TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,p_CARDTRADENO,
		             p_DEPOSIT+p_CARDCOST,p_currOper,p_currDept,v_CURRENTTIME,p_CANCELTRADEID
		       FROM TF_F_CARDREC
		       WHERE CARDNO = p_CARDNO;

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001020104';
	            p_retMsg  := 'Fail to log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 7)delete card info
    BEGIN
    		DELETE FROM TF_F_CARDREC WHERE CARDNO = p_CARDNO;

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001020105';
	            p_retMsg  := 'Fail to delete card info' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 8)delete acc info
    BEGIN
    		DELETE FROM TF_F_CARDEWALLETACC WHERE CARDNO = p_CARDNO;

 		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001020106';
	            p_retMsg  := 'Fail to delete card info' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 9)delete customer info
    BEGIN
    		DELETE FROM TF_F_CUSTOMERREC WHERE CARDNO = p_CARDNO;

 		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001020107';
	            p_retMsg  := 'Fail to delete customer info' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 10) Log the writeCard
    BEGIN
		    INSERT INTO TF_CARD_TRADE
		    		(TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,strTermno,OPERATETIME,SUCTAG)
		    VALUES
		    		(v_TradeID,v_TRADETYPECODE,p_OPERCARDNO,p_CARDNO,p_TERMNO,v_CURRENTTIME,'0');

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001139';
	            p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
      -- 11) Log the sync information while CARD_TYPE is 61
  BEGIN
  IF SUBSTR(p_CARDNO,0,6)='215061' THEN
    INSERT INTO TF_B_SYNC(TRADEID,CITIZEN_CARD_NO,Trans_Code,Name,Paper_Type,Paper_No,Card_Type,OPERATESTAFFNO,OPERATEDEPARTNO,OPERATETIME)
    VALUES(v_TradeID,p_CARDNO,'9508',v_CUSTNAME,v_PAPERTYPECODE,v_PAPERNO,'61',p_currOper,p_currDept,v_CURRENTTIME);
  END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001001140';
              p_retMsg  := 'Fail to log the sync information while CARD_TYPE is 61' || SQLERRM;
              ROLLBACK; RETURN;
END;

  p_retCode := '0000000000';
	p_retMsg  := '';
	RETURN;
END;
/
show errors
