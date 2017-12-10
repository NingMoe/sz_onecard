CREATE OR REPLACE PROCEDURE SP_PB_ReturnCard
(
		p_ID     	      char,
		p_CARDNO	      char,
		p_ASN	          char,
		p_CARDTYPECODE	char,
		p_REASONCODE	  char,
		p_CARDMONEY	    int,
		p_CARDTRADENO	  char,
		p_REFUNDMONEY	  int,
		p_SERSTAKETAG 	char,
		p_REFUNDDEPOSIT	int,
		p_CHECKSTAFFNO	char,
		p_CHECKDEPARTNO	char,
		p_TRADEPROCFEE	int,
		p_OTHERFEE			int,
		p_TERMNO				char,
		p_OPERCARDNO		char,
		p_TRADEID    	  out char, -- Return Trade Id
		p_currOper	    char,
		p_currDept	    char,
		p_retCode	      out char, -- Return Code
		p_retMsg     	  out varchar2  -- Return Message   
)
AS
    v_TradeID      char(16);
    v_TAGVALUE     CHAR(30);
    v_TRADEID_1    CHAR(16);
    v_CUSTNAME      varchar2(250);
    v_PAPERTYPE     varchar2(2);
    v_PAPERNO       varchar2(250);  
		v_CURRENTTIME date := sysdate;
    v_ex          exception;
BEGIN

-- 1) Select CUSTNAME PAPERTYPECODE PAPERNO
		BEGIN
     IF SUBSTR(p_CARDNO,0,6)='215061' THEN
				SELECT
        A.CUSTNAME,A.PAPERTYPECODE,A.PAPERNO into v_CUSTNAME,v_PAPERTYPE,v_PAPERNO
		    FROM TF_F_CUSTOMERREC A
		    WHERE A.CARDNO = p_CARDNO ;
     END IF;
    EXCEPTION
				    WHEN NO_DATA_FOUND THEN
				    p_retCode := 'A001004132';
				    p_retMsg  := 'Fail to find the card' || SQLERRM;
				    ROLLBACK; RETURN;
    END;
    
-- 2) Update resource statecode
    BEGIN
		    UPDATE TL_R_ICUSER
		    SET  DESTROYTIME = v_CURRENTTIME,
		        RESSTATECODE = '03',
		        UPDATESTAFFNO = p_currOper,
		        UPDATETIME = v_CURRENTTIME
		        WHERE  CARDNO = p_CARDNO
		        AND     RESSTATECODE != '03';

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001007114';
	            p_retMsg  := 'Error occurred while updating resource statecode' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 3) Update wallet statecode
    BEGIN
		    UPDATE TF_F_CARDEWALLETACC
		    SET USETAG ='0'
		        WHERE  CARDNO = p_CARDNO;

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001007118';
	            p_retMsg  := 'Error occurred while updating wallet statecode' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 4) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;

    -- 5) Log the operation
    BEGIN
		    INSERT INTO TF_B_TRADE
		        (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,REASONCODE,CURRENTMONEY,OPERATESTAFFNO,
		        OPERATEDEPARTID,OPERATETIME,CHECKSTAFFNO,CHECKDEPARTNO,CHECKTIME,CARDSTATE,SERSTAKETAG)
		     SELECT
		        v_TradeID,p_ID,'05',p_CARDNO,p_ASN,p_CARDTYPECODE,p_REASONCODE,p_REFUNDDEPOSIT,p_currOper,
		        p_currDept,v_CURRENTTIME,p_CHECKSTAFFNO,p_CHECKDEPARTNO,v_CURRENTTIME,CARDSTATE,SERSTAKETAG
		     FROM TF_F_CARDREC
		     WHERE CARDNO = p_CARDNO;

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001007115';
	            p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 6) Update card statecode
    BEGIN
		    UPDATE TF_F_CARDREC
		    SET  CARDSTATE ='21',
		        USETAG ='0',
		        SERSTAKETAG = p_SERSTAKETAG,
		        UPDATESTAFFNO = p_currOper,
		        UPDATETIME = v_CURRENTTIME
		        WHERE  CARDNO = p_CARDNO;

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001007113';
	            p_retMsg  := 'Error occurred while updating statecode' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 7) Judge the condition
    SELECT TO_NUMBER(TAGVALUE) INTO v_TAGVALUE FROM TD_M_TAG WHERE TAGCODE = 'MONEY_BACK';

    IF p_CARDMONEY > v_TAGVALUE THEN
    			p_retCode := 'A001007128';
	        p_retMsg  := 'Much money left in card' || SQLERRM;
	        ROLLBACK; RETURN;
    END IF;

    -- 8) Log the cash
    BEGIN
		    INSERT INTO TF_B_TRADEFEE
		        (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,PREMONEY,CARDDEPOSITFEE,SUPPLYMONEY,
		        TRADEPROCFEE,OTHERFEE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
		    VAlUES
		        (p_ID,v_TradeID,'05',p_CARDNO,p_CARDTRADENO,p_CARDMONEY,p_REFUNDDEPOSIT,
		        p_REFUNDMONEY,p_TRADEPROCFEE,p_OTHERFEE,p_currOper,p_currDept,v_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001007119';
	            p_retMsg  := 'Fail to log the cash' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

		-- 9) Get trade id
    SP_GetSeq(seq => v_TRADEID_1);

		-- 10) Log the operate
		IF p_REASONCODE = '11' OR p_REASONCODE = '12' OR p_REASONCODE = '13' THEN
			BEGIN
			    INSERT INTO TF_B_TRADE
			        (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CURRENTMONEY,OPERATESTAFFNO,
			        OPERATEDEPARTID,OPERATETIME)
			    VALUES
			        (v_TRADEID_1,p_ID,'06',p_CARDNO,p_ASN,p_CARDTYPECODE,p_REFUNDMONEY,
			         p_currOper,p_currDept,v_CURRENTTIME);

			EXCEPTION
		        WHEN OTHERS THEN
		            p_retCode := 'S001008106';
		            p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
		            ROLLBACK; RETURN;
	    END;
	  END IF;

	  -- 11) Log the operate
		IF p_REASONCODE = '11' OR p_REASONCODE = '12' OR p_REASONCODE = '13' THEN
			BEGIN
				UPDATE TF_F_CARDREC
				SET  CARDSTATE ='01'
				WHERE CARDNO = p_CARDNO;

				IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
			EXCEPTION
		        WHEN OTHERS THEN
		            p_retCode := 'S001007113';
		            p_retMsg  := 'Error occurred while updating statecode' || SQLERRM;
		            ROLLBACK; RETURN;
	    END;
	  END IF;

	  -- 12) Log the writeCard
	  IF p_REASONCODE = '11' OR p_REASONCODE = '12' OR p_REASONCODE = '13' THEN
	    BEGIN
			    INSERT INTO TF_CARD_TRADE
			    		(TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,strTermno,OPERATETIME,SUCTAG)
			    VALUES
			    		(v_TradeID,'05',p_OPERCARDNO,p_CARDNO,p_TERMNO,v_CURRENTTIME,'0');

			EXCEPTION
		        WHEN OTHERS THEN
		            p_retCode := 'S001001139';
		            p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
		            ROLLBACK; RETURN;
	    END;
    END IF;
    
      -- 13) Log the sync information while CARD_TYPE is 61
 BEGIN
  IF SUBSTR(p_CARDNO,0,6)='215061' THEN
    INSERT INTO TF_B_SYNC(TRADEID,CITIZEN_CARD_NO,Trans_Code,Name,Paper_Type,Paper_No,OPERATESTAFFNO,OPERATEDEPARTNO,OPERATETIME)
    VALUES(v_TradeID,p_CARDNO,'9507',v_CUSTNAME,v_PAPERTYPE,v_PAPERNO,p_currOper,p_currDept,v_CURRENTTIME);
  END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001001114';
              p_retMsg  := 'Fail to log the sync information while CARD_TYPE is 61' || SQLERRM;
              ROLLBACK; RETURN;
END;

  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;
/
show errors