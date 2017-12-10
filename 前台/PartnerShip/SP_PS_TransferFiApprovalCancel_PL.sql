
CREATE OR REPLACE PROCEDURE SP_PS_TransferFiApprovalCancel
(
    p_tradeId    CHAR,
	
    p_currOper   CHAR,        
    p_currDept   CHAR, 
    p_retCode    OUT CHAR,
    p_retMsg     OUT VARCHAR2
)

AS
    v_currdate   DATE := SYSDATE;
    v_ex         EXCEPTION;

BEGIN 

   --1)update the exam log info
   BEGIN
	 UPDATE TF_B_ASSOCIATETRADE_EXAM																																										
		SET STATECODE        =       '3',																				
			EXAMSTAFFNO      =       p_currOper,																				
			EXAMDEPARTNO     =       p_currDept, 																				
			EXAMKTIME        =       v_currdate																				
																												
	  WHERE TRADEID          =       p_tradeId ; 																				
										
     IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008109010';
         p_retMsg  := '';
         ROLLBACK; RETURN;
   END;
										
   p_retCode := '0000000000';                
   p_retMsg  := '';  
   COMMIT; RETURN;	
END;
/
show errors
