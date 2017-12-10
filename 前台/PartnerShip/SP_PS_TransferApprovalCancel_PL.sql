																														
CREATE OR REPLACE PROCEDURE SP_PS_TransferApprovalCancel 
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
	 
   --1)update the log info 
   BEGIN
     UPDATE TF_B_ASSOCIATETRADE																																				 
	    SET STATECODE        =   '3',																																	 
		      CHECKSTAFFNO     =   p_currOper,																																	 
		      CHECKDEPARTNO    =   p_currDept, 																																	 
		      CHECKTIME        =   v_currdate   																						 
      WHERE TRADEID        =   p_tradeId;																																	 
				
      IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_retCode := 'S008108003';
          p_retMsg  := '';
          ROLLBACK; RETURN;
    END;
   
    p_retCode := '0000000000';                 
    p_retMsg  := '';                  
    COMMIT; RETURN;
END;

/
show errors

