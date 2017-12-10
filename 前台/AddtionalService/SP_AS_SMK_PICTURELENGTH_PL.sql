CREATE OR REPLACE PROCEDURE SP_AS_SMK_PICTURELENGTH
(
    P_CARDNO           CHAR   , --¿¨ºÅ
    P_LENGTH        out char    ,
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS 
    V_EX              EXCEPTION;

BEGIN


  SP_AS_SMKPICTURELENGTH(P_CARDNO,P_LENGTH,p_currOper,p_currDept,p_retCode,p_retMsg);
  IF p_retCode != '0000000000' THEN
        ROLLBACK; RETURN;
    END IF;
  
  p_retCode := '0000000000';
	p_retMsg  := '';

END;
/

show errors
