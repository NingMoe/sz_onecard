CREATE OR REPLACE PROCEDURE SP_PB_Speload
(
		p_TRADEID	       char,
		p_CARDNO	       char,
		p_TRADETYPECODE  char,
		p_CARDTRADENO    char,
		p_CURRENTMONEY   int,
		p_CARDMONEY      int,
		p_TERMNO         char,
		p_OPERCARDNO     char,
		p_currOper	     char,
		p_currDept	     char,
		p_retCode        out char, -- Return Code
		p_retMsg         out varchar2  -- Return Message
)
AS
		v_CURRENTTIME date := sysdate;
    v_ex          exception;
BEGIN
    -- 1) Log the operate
    BEGIN
		    INSERT INTO TF_B_TRADE
		        (TRADEID,CARDNO,TRADETYPECODE,ASN,CARDTYPECODE,CARDTRADENO,CURRENTMONEY,OPERATESTAFFNO,
		        OPERATEDEPARTID,OPERATETIME)
		      SELECT
		        p_TRADEID,CARDNO,p_TRADETYPECODE,ASN,CARDTYPECODE,p_CARDTRADENO,p_CURRENTMONEY,
		        p_currOper,p_currDept,v_CURRENTTIME
		      FROM TF_F_CARDREC
		      WHERE CARDNO = p_CARDNO;

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001019100';
	            p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 2) update the operate
    BEGIN
		    UPDATE TF_B_SPELOAD
		    SET STATECODE = '1',
		        OPERATESTAFFNO = p_currOper,
		        OPERATETIME = v_CURRENTTIME
		    WHERE TRADEID = p_TRADEID;

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001019101';
	            p_retMsg  := 'Error occurred while update the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 3) Log the writeCard
    BEGIN
		    INSERT INTO TF_CARD_TRADE
		    		(TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,lMoney,lOldMoney,strTermno,
		    		Cardtradeno,OPERATETIME,SUCTAG)
		    VALUES
		    		(p_TRADEID,p_TRADETYPECODE,p_OPERCARDNO,p_CARDNO,p_CURRENTMONEY,p_CARDMONEY,
		    		p_TERMNO,p_CARDTRADENO,v_CURRENTTIME,'0');

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