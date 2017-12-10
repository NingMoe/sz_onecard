/*
*验证卡片是否是市民卡
*/
CREATE OR REPLACE PROCEDURE SP_SmkCheck
(
		p_CARDNO	  char,
		p_currOper	char,
		p_currDept	char,
		p_retCode	  out char, -- Return Code
		p_retMsg 	  out varchar2  -- Return Message

)
AS
    v_ex                exception;
BEGIN


    IF SUBSTR(p_CARDNO,5,2) = '18' THEN
        p_retCode := 'A006010006';
        RETURN;
    END IF;

	p_retCode := '0000000000';
	p_retMsg  := '';

  END;  
/

show errors

