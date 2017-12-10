
CREATE OR REPLACE PROCEDURE SP_PS_GroupCustBatchInput  
(  
    p_sessionId  VARCHAR2,
    p_currOper   CHAR,              
    p_currDept   CHAR,  

    p_retCode    OUT CHAR,  
    p_retMsg     OUT VARCHAR2  
)  
AS  
	  v_currdate   DATE := SYSDATE;
    v_seqNo      CHAR(16);
	  v_seqNum     NUMBER(16);
    v_quantity   INT;
	  v_ex         EXCEPTION;

BEGIN
    
    --1) check the  Group Cust Code has existed in check log 
	BEGIN
	  SELECT COUNT(*) INTO v_quantity FROM TF_B_ASSOCIATETRADE tass, 
	    TF_B_GROUP_CUSTOMERCHANGE tcus																																								
        WHERE tass.TRADEID = tcus.TRADEID AND tass.STATECODE = '1' AND tcus.CORPCODE IN 
		  (SELECT CORPCODE FROM TMP_GROUP_CUSTOMERIMP WHERE SessionId = p_sessionId);
	  
	  IF v_quantity >= 1 THEN
        p_retCode := 'A008110104';
        p_retMsg  := '';
        RETURN;
      END IF; 
	END; 
	
	--2) check the Group Cust Code has existed in TD_GROUP_CUSTOMER
    BEGIN
      SELECT COUNT(*) INTO v_quantity FROM TD_GROUP_CUSTOMER WHERE CORPCODE IN 
		(SELECT CORPCODE FROM TMP_GROUP_CUSTOMERIMP WHERE SessionId = p_sessionId );
		
	  IF v_quantity >= 1 THEN
        p_retCode := 'A008110104';
        p_retMsg  := '';
        RETURN;
      END IF;  
	END;
	
	--3) check the Group Cust Name has existed in check log
	BEGIN
	  SELECT COUNT(*) INTO v_quantity FROM TF_B_ASSOCIATETRADE tass,
  	    TF_B_GROUP_CUSTOMERCHANGE tcus																																								
        WHERE tass.TRADEID = tcus.TRADEID AND tass.STATECODE = '1' AND tcus.CORPNAME IN 
		  (SELECT CORPNAME FROM TMP_GROUP_CUSTOMERIMP WHERE SessionId = p_sessionId);																		
	
	  IF v_quantity >= 1 THEN
        p_retCode := 'A008110004';
        p_retMsg  := '';
        RETURN;
      END IF;  
	END;
	
	--4) check the Group Cust Name in TD_GROUP_CUSTOMER
	BEGIN
	  SELECT COUNT(*) INTO v_quantity FROM	TD_GROUP_CUSTOMER WHERE CORPNAME IN 	
	    (SELECT CORPNAME FROM TMP_GROUP_CUSTOMERIMP WHERE SessionId = p_sessionId );
	            
      IF v_quantity >= 1 THEN
        p_retCode := 'A008110004';
        p_retMsg  := '';
        RETURN;
      END IF;  
	END;
			 
	--5) check the SERMANAGERCODE is exist in TD_M_INSIDESTAFF
	BEGIN
	  SELECT COUNT(*) INTO v_quantity FROM TMP_GROUP_CUSTOMERIMP 
	    WHERE SessionId = p_sessionId AND SERMANAGERCODE IS NOT NULL AND SERMANAGERCODE NOT IN 
	      ( SELECT t.STAFFNO from TD_M_INSIDESTAFFROLE t, TD_M_ROLEPOWER r 
	         WHERE t.ROLENO = r.ROLENO AND r.POWERCODE = '201005' and r.POWERTYPE = '2'
	      );
	  IF v_quantity >= 1 THEN
        p_retCode := 'A008110005';
        p_retMsg  := '';
        RETURN;
      END IF;   
   END; 
   
   --6) get total records from  TMP_GROUP_CUSTOMERIMP
   SELECT COUNT(*) INTO v_quantity FROM TMP_GROUP_CUSTOMERIMP WHERE SessionId = p_sessionId;
   IF v_quantity <= 0 THEN
        p_retCode := 'A008110105';
        p_retMsg  := '';
        RETURN;
   END IF;
   
   --7) get the sequence number  
   SP_GetSeq(v_quantity, v_seqNo);   
   v_seqNum := TO_NUMBER(v_seqNo);

   --8) add main log info , TRADETYPECODE = '50' means batch imp corp info ,  STATECODE = '1'  the corp info wait for checking  
   BEGIN
	 INSERT INTO TF_B_ASSOCIATETRADE
	    (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO, 
		   OPERATEDEPARTID, OPERATETIME, STATECODE )     
	     SELECT SUBSTR('0000000000000000'|| TO_CHAR(v_seqNum + SEQ), -16), '50',   
	       CORPCODE, p_currOper, p_currDept, v_currdate, '1'	   
	       FROM TMP_GROUP_CUSTOMERIMP WHERE SessionId = p_sessionId;
	     
     IF SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008110003';
         p_retMsg  := '';
         ROLLBACK; RETURN;
   END;
   
   --9) add additional log info
   BEGIN   
     INSERT INTO TF_B_GROUP_CUSTOMERCHANGE																				
	   (TRADEID, CORPNAME, CORPCODE, LINKMAN, CORPADD, CORPPHONE, SERMANAGERCODE, CORPEMAIL, REMARK)
        SELECT SUBSTR('0000000000000000'|| TO_CHAR(v_seqNum + SEQ), -16), CORPNAME,  
            CORPCODE, LINKMAN, CORPADD, CORPPHONE, SERMANAGERCODE, CORPEMAIL , REMARK          
     FROM TMP_GROUP_CUSTOMERIMP WHERE SessionId = p_sessionId;     
     	     
     IF SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008110004';
         p_retMsg  := '';
         ROLLBACK; RETURN;   
   END; 
     
   p_retCode := '0000000000';
   p_retMsg  := '';
   COMMIT; RETURN;
END;

/   
show errors

 