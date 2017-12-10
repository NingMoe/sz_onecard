CREATE OR REPLACE PROCEDURE SP_PS_GroupCustChange
(
    p_corpCode	      CHAR,
    p_corpName	      VARCHAR2,
    p_linkMan	        VARCHAR2,
    p_corpAdd	        VARCHAR2,
    p_corpPhone  	    VARCHAR2,
    p_serManagerCode  CHAR, 
    p_corpEmail	      VARCHAR2,

    p_remark	        VARCHAR2,
    p_useTag          CHAR,   -- only 1 or 0

    p_currOper        CHAR,      
    p_currDept        CHAR, 
    p_retCode         OUT CHAR,  
    p_retMsg          OUT VARCHAR2   
)
AS
    v_currdate        DATE := SYSDATE;
    v_seqNo           CHAR(16);
	  v_tradtypcd       CHAR(2);
	  v_quantity        INT;
    	
BEGIN 
	
  --1)  get the sequence number  
  SP_GetSeq(seq => v_seqNo); 
  
  --2)  set useTag 1 modify ,0 delete    
  IF p_useTag = '1' THEN
      v_tradtypcd := '51';
  ELSE 
      v_tradtypcd := '52';
  END IF;
  
  --3) add main log info  
  BEGIN  
    INSERT INTO TF_B_ASSOCIATETRADE  
      (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO,																  
       OPERATEDEPARTID, OPERATETIME, STATECODE)     
    VALUES(v_seqNo, v_tradtypcd, p_corpCode, p_currOper, p_currDept, v_currdate, '1');
  
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008111002';
        p_retMsg  := '';
        ROLLBACK; RETURN;	 
  END;
  
  -- 4)  add additional log info  
  BEGIN
    INSERT INTO TF_B_GROUP_CUSTOMERCHANGE																				
	  (TRADEID, CORPCODE, CORPNAME, LINKMAN, CORPADD, CORPPHONE, 
	   SERMANAGERCODE, CORPEMAIL, REMARK)		
    VALUES
      (v_seqNo, p_corpCode, p_corpName, p_linkMan, p_corpAdd, p_corpPhone, 
	     p_serManagerCode, p_corpEmail, p_remark);
		
	 EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008111003';
        p_retMsg  := '';
        ROLLBACK; RETURN;	 
  END;	
    		 	
  p_retCode := '0000000000'; 
  p_retMsg  := '';
  COMMIT; RETURN;

END;
/

show errors

