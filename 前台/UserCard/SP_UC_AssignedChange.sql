CREATE OR REPLACE PROCEDURE SP_UC_AssignedChange
(
    p_ASSIGNEDSTAFFNO   char,
    p_ASSIGNEDDEPARTID  char,
	p_CURRENTTIME	    in out date, -- Return Operate Time
	p_TRADEID    	    out char, -- Return Trade Id
	p_currOper	        char,
	p_currDept	        char,
	p_retCode	        out char, -- Return Code
	p_retMsg     	    out varchar2  -- Return Message

)
AS
    v_TradeID           char(16);
    v_amount            int;

BEGIN
    p_CURRENTTIME := sysdate;

	FOR cur_renewdata IN (
		SELECT f0, f1 FROM TMP_COMMON
		) 
    LOOP
	    IF cur_renewdata.f1 is null THEN
		    UPDATE TL_R_ICUSER SET ASSIGNEDSTAFFNO = p_ASSIGNEDSTAFFNO, ASSIGNEDDEPARTID = p_ASSIGNEDDEPARTID 
		    WHERE cardno = cur_renewdata.f0 ;
		    
		    IF  SQL%ROWCOUNT != 1 THEN
                raise_application_error(-20101, '¸üÐÂ¿¨¹éÊôÊ§°Ü' );
		    END IF;
		ELSE
			SELECT COUNT(*) INTO v_amount FROM TL_R_ICUSER 
		    WHERE CARDNO BETWEEN cur_renewdata.f0 and cur_renewdata.f1;

		    UPDATE TL_R_ICUSER SET ASSIGNEDSTAFFNO = p_ASSIGNEDSTAFFNO, ASSIGNEDDEPARTID = p_ASSIGNEDDEPARTID 
		    WHERE CARDNO BETWEEN cur_renewdata.f0 and cur_renewdata.f1 ;
		    
		    IF  SQL%ROWCOUNT != v_amount THEN
                raise_application_error(-20101, '¸üÐÂ¿¨¹éÊôÊ§°Ü' );
		    END IF;

	        SP_GetSeq(seq => v_TradeID);
	        p_TRADEID := v_TradeID;
	        
            INSERT INTO TF_R_ICUSERTRADE
            (TRADEID, OPETYPECODE, BEGINCARDNO, ENDCARDNO, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
            VALUES
            (v_TradeID, '15', cur_renewdata.f0, cur_renewdata.f1, p_currOper, p_currDept, p_CURRENTTIME);
    	END IF;			
	END LOOP;

	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;

EXCEPTION WHEN OTHERS THEN
    p_retCode := SQLCODE;
    p_retMsg  := SQLERRM;
END;
/

show errors