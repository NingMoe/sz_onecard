CREATE OR REPLACE PROCEDURE SP_PB_CardStart
(
		p_CARDNO	       char,
		p_ASN	           char,
		p_CARDTYPECODE	 char,
		p_CHECKSTAFFNO	 char,
		p_CHECKDEPARTNO	 char,
		p_OPERCARDNO		 char,
		p_TRADEID    	   out char, -- Return Trade Id
		p_currOper	     char,
		p_currDept	     char,
		p_retCode        out char, -- Return Code
		p_retMsg         out varchar2  -- Return Message

)
AS
    v_TradeID char(16);
		v_CURRENTTIME date := sysdate;
    v_ex          exception;
BEGIN
    -- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;

    -- 2) Log the operate
    BEGIN
		    INSERT INTO TF_B_TRADE
		        (TRADEID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,REASONCODE,OPERATESTAFFNO,OPERATEDEPARTID,
		        OPERATETIME,CHECKSTAFFNO,CHECKDEPARTNO,CHECKTIME)
		    VALUES
		        (v_TradeID,'Q1',p_CARDNO,p_ASN,p_CARDTYPECODE,'31',p_currOper,p_currDept,
		        v_CURRENTTIME,p_CHECKSTAFFNO,p_CHECKDEPARTNO,v_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001008106';
	            p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 3) Log card change
    BEGIN
		    INSERT INTO TF_B_CARDUSEAREA
		        (TRADEID,CARDNO,ASN,TRADETYPECODE,REASONCODE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
		    VALUES
		        (v_TradeID,p_CARDNO,p_ASN,'Q1','31',p_currOper,p_currDept,v_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001010105';
	            p_retMsg  := 'Error occurred while log card change' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

		-- 4) Log the writeCard
		BEGIN
		    INSERT INTO TF_CARD_TRADE
		    		(TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,OPERATETIME,SUCTAG)
		    VALUES
		    		(v_TradeID,'Q1',p_OPERCARDNO,p_CARDNO,v_CURRENTTIME,'0');

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001139';
	            p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;
/
show errors