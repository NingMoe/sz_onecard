CREATE OR REPLACE PROCEDURE SP_PS_GroupCustApprovalCancel
(
    p_currOper   CHAR,            
    p_currDept   CHAR, 
    p_retCode    OUT CHAR,  
    p_retMsg     OUT VARCHAR2
)
AS
    v_currdate   DATE := SYSDATE;
	  v_quantity   INT;
	  v_ex         EXCEPTION;

BEGIN 
   
    --1) get total counts from TMP_GROUP_CUSTOMERCHKCEL
    SELECT COUNT(*) INTO v_quantity FROM TMP_GROUP_CUSTOMERCHKCEL;
   
    --2) update the main log
	BEGIN
      UPDATE TF_B_ASSOCIATETRADE
         SET STATECODE        =    '3',																			
             CHECKSTAFFNO     =    p_currOper,																
             CHECKDEPARTNO    =    p_currDept, 		   																					
             CHECKTIME        =    v_currdate         																					
             												
       WHERE TRADEID IN (SELECT TRADEID FROM TMP_GROUP_CUSTOMERCHKCEL);
     
	 IF SQL%ROWCOUNT = 0 OR SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008112005';
         p_retMsg  := '';
         ROLLBACK; RETURN;
     END;
	
	 p_retCode := '0000000000'; 
	 p_retMsg  := ''; 
     COMMIT; RETURN;
END;

/   
show errors



