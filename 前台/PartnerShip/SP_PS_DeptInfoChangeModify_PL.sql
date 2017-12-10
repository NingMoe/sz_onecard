CREATE OR REPLACE PROCEDURE SP_PS_DeptInfoChangeModify
( p_departNo    CHAR,
  p_depart	    VARCHAR2,        
  p_corpNo	    CHAR,            
  p_dpartMark	VARCHAR2,          
  p_linkMan	    VARCHAR2,          
  p_dpartPhone  VARCHAR2,        
  p_remark	    VARCHAR2,                        
  p_useTag      CHAR,             
                                      
  p_currOper    CHAR,                
  p_currDept    CHAR,                   
  p_retCode     OUT CHAR,     
  p_retMsg      OUT VARCHAR2 
)
AS  
  v_currdate    DATE := SYSDATE;
  v_seqNo       CHAR(16);
  v_quantity    INT;
  v_ex          EXCEPTION; 

BEGIN

  --1)  check the corp is useful
  BEGIN  
    SELECT 1 INTO v_quantity FROM TD_M_CORP 
      WHERE CORPNO = p_corpNo AND USETAG = '1';
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
       p_retCode := 'A008103005';
       p_retMsg  := '';
       RETURN;
  END;
  
  --2)  when useTag = '0', whether the depart has a balunit
  IF p_useTag = '0' THEN
  BEGIN
    SELECT COUNT(*) INTO v_quantity FROM TF_TRADE_BALUNIT 
	  WHERE DEPARTNO = p_departNo AND USETAG = '1';
	
    IF v_quantity >= 1 THEN
       p_retCode := 'A008103009';
       p_retMsg  := '';
       RETURN;
    END IF; 	
  END; 
  END IF;
 
  --3) update the depart info
  BEGIN
    UPDATE TD_M_DEPART																												
       SET DEPART        =  p_depart, 
       CORPNO 	     =  p_corpNo,	      			
		   DPARTMARK     =  p_dpartMark, 		
		   LINKMAN       =  p_linkMan,	    	  		
		   DEPARTPHONE   =  p_dpartPhone,				
		   UPDATESTAFFNO =  p_currOper ,			
		   UPDATETIME    =  v_currdate,												
		   REMARK        =  p_remark,	 						
		   USETAG        =  p_useTag 			       							
     WHERE DEPARTNO      =  p_departNo; 

     IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008103002';
         p_retMsg  := '';
         ROLLBACK; RETURN;
  END;
   
  --4)  get the sequence number 
  SP_GetSeq(seq => v_seqNo);
   
  --5)  add main log info , '59' means modify depart info
  BEGIN
    INSERT INTO TF_B_ASSOCIATETRADE  
      (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)  
    VALUES
      (v_seqNo, '59', p_departNo, p_currOper, p_currDept, v_currdate);
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008103004';
        p_retMsg  := '';
        ROLLBACK; RETURN;	 
  END;
   
  --6)  add additional log info 
  BEGIN
    INSERT INTO TF_B_DEPARTCHANGE																									
      (TRADEID, DEPARTNO, DEPART, CORPNO, DPARTMARK, REMARK, LINKMAN, DEPARTPHONE)																				
    VALUES	
      (v_seqNo, p_departNo, p_depart, p_corpNo, p_dpartMark, p_remark, p_linkMan, p_dpartPhone);

    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008103005';
        p_retMsg  := '';
        ROLLBACK; RETURN;	 
  END;
 
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
END;

/   
show errors

 
 
 
 
 
 
 