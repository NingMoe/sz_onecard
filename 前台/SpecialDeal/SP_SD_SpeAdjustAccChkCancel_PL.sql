
--check cancel for special adjust account 

CREATE OR REPLACE PROCEDURE SP_SD_SpeAdjustAccChkCancel
(
    p_sessionID          VARCHAR2, 
    p_currOper	         CHAR,      
    p_currDept	         CHAR,         
    p_retCode            OUT CHAR,
    p_retMsg             OUT VARCHAR2
)
AS
    v_currdate   DATE := SYSDATE;
    v_quantity   INT;
  	v_ex         EXCEPTION;

BEGIN
	
  --1) get total records from TMP_ADJUSTACC_IMP 
  SELECT COUNT(*) INTO v_quantity FROM TMP_ADJUSTACC_IMP WHERE SessionId = p_sessionID;
  	
  --2) update TF_B_SPEADJUSTACC info
  BEGIN
		UPDATE TF_B_SPEADJUSTACC																																																
	    SET	 STATECODE = '3',																			
		       CHECKSTAFFNO = p_currOper,
		       CHECKTIME	  = v_currdate																																		
	  WHERE	 TRADEID IN ( SELECT TRADEID FROM TMP_ADJUSTACC_IMP Where SessionId = p_sessionID );
	 
	  IF SQL%ROWCOUNT = 0 OR SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009111002';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END; 	
  
  																																												
   p_retCode := '0000000000';
   p_retMsg  := '';
   COMMIT;RETURN;						
END;

/
show errors
