CREATE OR REPLACE PROCEDURE SP_PS_DeptInfoChangeAdd
(
	p_departNo      CHAR,
	p_depart	    VARCHAR2,
	p_corpNo	    CHAR,
	p_dpartMark	    VARCHAR2,
	p_linkMan	    VARCHAR2,
	p_dpartPhone	VARCHAR2,
	p_remark	    VARCHAR2,
	
	p_currOper      CHAR,       
	p_currDept      CHAR,  
	p_retCode       OUT CHAR,  
	p_retMsg        OUT VARCHAR2 
)  
AS
	v_currdate      DATE := SYSDATE;
    v_seqNo         CHAR(16);
    v_quantity      INT;
  
BEGIN
	--1) check the corp is useful
  BEGIN
    SELECT 1 INTO v_quantity FROM TD_M_CORP 
      WHERE CORPNO = p_corpNo AND USETAG = '1';
   
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       p_retCode := 'A008103005';
       p_retMsg  := '';
       ROLLBACK; RETURN;
  END;   
     
  --2) add depart info
  BEGIN
    INSERT INTO TD_M_DEPART																									
		  (DEPARTNO,	DEPART,	CORPNO, DPARTMARK, REMARK, USETAG,
		   UPDATESTAFFNO, UPDATETIME, LINKMAN, DEPARTPHONE )		
    VALUES
      (p_departNo, p_depart, p_corpNo,	p_dpartMark, p_remark, '1',           
       p_currOper, v_currdate, p_linkMan, p_dpartPhone );
   
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008103008';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;   
  
  --3) get the sequence number 
  SP_GetSeq(seq => v_seqNo);
  
  --4) add main log info,'58' means add depart info  
  BEGIN
    INSERT INTO TF_B_ASSOCIATETRADE  
      (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO,OPERATEDEPARTID, OPERATETIME)  
    VALUES
      (v_seqNo, '58', p_departNo, p_currOper, p_currDept, v_currdate );  

    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008103004';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;
  
  --5) add additional log info 
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


