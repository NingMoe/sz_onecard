CREATE OR REPLACE PROCEDURE SP_PB_XFCommit
(
		p_CARDNO      char,
		p_PASSWD	    char,
		p_XFCARDNO	  out char, -- Return xfcard number
		p_sMONEY	    out int, -- Return xfcard money
		p_CURRENTTIME	out date, -- Return Operate Time
		p_TRADEID	    char,
		p_currOper	  char,
		p_currDept	  char,
		p_retCode     out char, -- Return Code
		p_retMsg      out varchar2  -- Return Message

)
AS
		v_enddate date;
    v_CARDSTATECODE CHAR(1);
    v_ex          exception;
BEGIN
    -- 1) Get system time
    p_CURRENTTIME := sysdate;
    
    -- 2) Get card information
    BEGIN
		    SELECT   
		         TD_XFC_INITCARD.XFCARDNO,
		         TP_XFC_CARDVALUE.MONEY, 
		         TD_XFC_INITCARD.CARDSTATECODE,
		         TD_XFC_INITCARD.ENDDATE
		    INTO p_XFCARDNO,p_sMONEY,v_CARDSTATECODE,v_enddate
		    FROM  TP_XFC_CARDVALUE, TD_XFC_INITCARD 
		    WHERE  TP_XFC_CARDVALUE.VALUECODE = TD_XFC_INITCARD.VALUECODE 
		    AND TD_XFC_INITCARD.NEW_PASSWD = p_PASSWD;
			AND TD_XFC_INITCARD.Cardtype='00';

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_retCode := 'A001002116';
        p_retMsg  := 'A001002116:Can not find the record or Error';
        ROLLBACK; RETURN;
    END;
    
    IF v_CARDSTATECODE != '4' THEN
        p_retCode := 'A001002117';
        p_retMsg  := 'A001002117:State is not activated';
        ROLLBACK; RETURN;
    END IF;
    
    IF v_enddate < p_CURRENTTIME THEN
    		p_retCode := 'A001002132';
        p_retMsg  := 'A001002132:Enddate is past';
        ROLLBACK; RETURN;
    END IF;

    -- 3) Updated card status
    BEGIN
		    UPDATE TD_XFC_INITCARD   
		    SET  CARDSTATECODE = '5'
		    WHERE  NEW_PASSWD = p_PASSWD AND TD_XFC_INITCARD.Cardtype='00';
    
		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001002118';
	            p_retMsg  := 'S001002118:Update failure';
	            ROLLBACK; RETURN;
    END;
    
    -- 4) Log xfcard use
    BEGIN
		    INSERT INTO TL_XFC_TRADELOG   
		        (TRADEID,XFCARDNO,PASSWD,CARDFEE,CARDNO,UPDATETIME,UPDATESTAFFNO,DEPARTNO,CANCELTAG) 
		    VALUES   
		        (p_TRADEID,p_XFCARDNO,p_PASSWD,p_sMONEY,p_CARDNO,p_CURRENTTIME,p_currOper,p_currDept,'0');

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001002131';
	            p_retMsg  := 'S001002131:Error occurred while log the operation';
	            ROLLBACK; RETURN;
    END;
  p_retCode := '0000000000';
	p_retMsg  := '';
	RETURN;
  END;
  
/

show errors

