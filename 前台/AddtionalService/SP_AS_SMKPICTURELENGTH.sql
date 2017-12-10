CREATE OR REPLACE PROCEDURE SP_AS_SMKPICTURELENGTH
(
    P_CARDNO           CHAR   , --¿¨ºÅ
    P_LENGTH        out char    ,
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS 
    V_NUM          INT:=0;

BEGIN

   SELECT  COUNT(*) INTO V_NUM   from  tf_f_residentcard  where  cardno=P_CARDNO AND length(PICTURE)>0;
   IF V_NUM > 0 THEN
      P_LENGTH:='1';
   ELSE
      P_LENGTH:='0';
   END IF;


END;
/
show errors