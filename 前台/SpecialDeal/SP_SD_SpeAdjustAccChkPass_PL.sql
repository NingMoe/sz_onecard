
CREATE OR REPLACE PROCEDURE SP_SD_SpeAdjustAccChkPass
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
  	
    v_cardno	     CHAR(16);
    v_refundMoney  INT;
    

BEGIN 
	
  --1) get total records from TMP_ADJUSTACC_IMP 
  SELECT COUNT(*) INTO v_quantity FROM TMP_ADJUSTACC_IMP WHERE SessionId = p_sessionID;
   		
  
  --2) update TF_B_SPEADJUSTACC info
  BEGIN
		UPDATE TF_B_SPEADJUSTACC																																																
	    SET	 STATECODE = '1',																			
		       CHECKSTAFFNO = p_currOper	,
		       CHECKTIME	  = v_currdate																																		
	  WHERE	STATECODE not in ( '1') and  TRADEID IN ( SELECT TRADEID FROM TMP_ADJUSTACC_IMP Where SessionId = p_sessionID );
	  
	  IF SQL%ROWCOUNT = 0 OR SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009111002';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END; 	
	  	
	  
  --3) get the current recycle one by one records from TMP_ADJUSTACC_IMP
  BEGIN
    FOR cur_AdjAcc IN ( SELECT CARDNO, REFUNDMENT 
      FROM	TMP_ADJUSTACC_IMP WHERE SessionId = p_sessionID) LOOP
     
        v_cardno      := cur_AdjAcc.CARDNO;
        v_refundMoney := cur_AdjAcc.REFUNDMENT;
      
      
        SELECT COUNT(*) INTO v_quantity FROM TF_SPEADJUSTOFFERACC WHERE CARDNO = v_cardno;
        
        --when the cardno has existed
        IF v_quantity >= 1 THEN
          
           BEGIN
		      	--update the TF_SPEADJUSTOFFERACC info
		        UPDATE TF_SPEADJUSTOFFERACC																													
			         SET OFFERMONEY = OFFERMONEY + v_refundMoney																											
			       WHERE CARDNO = v_cardno;
			       
			       IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
             EXCEPTION
               WHEN OTHERS THEN
                 p_retCode := 'S009111003';
                 p_retMsg  := '';
                 ROLLBACK; RETURN;
           END;				
        ELSE 
        	
        	BEGIN
    		   --add the TF_SPEADJUSTOFFERACC info
    		   INSERT INTO TF_SPEADJUSTOFFERACC(CARDNO,OFFERMONEY) VALUES(v_cardno, v_refundMoney);
			      
			     IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
             EXCEPTION
               WHEN OTHERS THEN
                 p_retCode := 'S009111004';
                 p_retMsg  := '';
                 ROLLBACK; RETURN;
           END;		
           
        END IF;   
      
      
    END LOOP;
  END;
  
  																																																	
   p_retCode := '0000000000';
   p_retMsg  := '';
   COMMIT;RETURN;						
END;

/
show errors
