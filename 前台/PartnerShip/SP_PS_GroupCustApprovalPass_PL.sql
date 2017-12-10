CREATE OR REPLACE PROCEDURE SP_PS_GroupCustApprovalPass
(
    p_currOper   CHAR,             
    p_currDept   CHAR,
    p_retCode    OUT CHAR,  
    p_retMsg     OUT VARCHAR2  
)
AS 
    v_currdate   DATE := SYSDATE;
   	v_addCust    INT;
    v_updCust    INT;
	  v_allCust    INT;
  	v_ex         EXCEPTION; 
  	v_USETAG     CHAR(1);
  	
  
BEGIN

   --1) get total counts from TMP_GROUP_CUSTOMERCHKPAS, including 50 add new
   SELECT COUNT(*) INTO v_addCust 
     FROM TMP_GROUP_CUSTOMERCHKPAS WHERE TRADETYPECODE  = '50';

   --2) batch imp  GROUP CUST INFO into TD_GROUP_CUSTOMER
   BEGIN
     INSERT INTO TD_GROUP_CUSTOMER																									
	   (CORPCODE, CORPNAME, LINKMAN, CORPADD, CORPPHONE, USETAG,	
	    UPDATESTAFFNO, UPDATETIME, REMARK, SERMANAGERCODE, CORPEMAIL )																																				
        SELECT tchange.CORPCODE, tchange.CORPNAME, tchange.LINKMAN, tchange.CORPADD,
               tchange.CORPPHONE, '1', tmp.UPDATESTAFFNO, v_currdate, 
               tchange.REMARK, tchange.SERMANAGERCODE, tchange.CORPEMAIL                   
        FROM TMP_GROUP_CUSTOMERCHKPAS tmp,  TF_B_GROUP_CUSTOMERCHANGE tchange
         WHERE  tmp.TRADEID = tchange.TRADEID AND tmp.TRADETYPECODE  = '50'; 
      
	 IF SQL%ROWCOUNT != v_addCust THEN RAISE v_ex; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008112001';
         p_retMsg  := '';
         ROLLBACK; RETURN;
   END;
   
   --3) get the total  counts from TMP_GROUP_CUSTOMERCHKPAS, including 51 modify old 52 delete old 
   SELECT COUNT(*) INTO v_updCust FROM TMP_GROUP_CUSTOMERCHKPAS  
     WHERE TRADETYPECODE = '51' OR TRADETYPECODE = '52';
	     
   --4) modify the group customer info
   BEGIN
    FOR cur_custdata IN (  
      SELECT tchange.CORPCODE CORPCODE, tchange.CORPNAME CORPNAME, 
             tchange.LINKMAN LINKMAN,  tchange.CORPADD CORPADD, 
             tchange.CORPPHONE CORPPHONE,  tchange.CORPEMAIL CORPEMAIL,
             tmp.UPDATESTAFFNO UPDATESTAFFNO,  tchange.REMARK REMARK,  
             tchange.SERMANAGERCODE SERMANAGERCODE, tmp.TRADETYPECODE TRADETYPECODE
      FROM TMP_GROUP_CUSTOMERCHKPAS tmp,  TF_B_GROUP_CUSTOMERCHANGE tchange
        WHERE tmp.TRADEID = tchange.TRADEID AND 
         (tmp.TRADETYPECODE = '51' OR tmp.TRADETYPECODE = '52') ) LOOP
     
        IF cur_custdata.TRADETYPECODE = '51' THEN
          v_USETAG := '1';
        ELSE
        	v_USETAG := '0';
        END IF; 
     
      BEGIN 
      	
	      UPDATE TD_GROUP_CUSTOMER 
	      SET
	          CORPNAME       = cur_custdata.CORPNAME,                                              
	          LINKMAN        = cur_custdata.LINKMAN,                 
	          CORPADD        = cur_custdata.CORPADD,                 
	          CORPPHONE      = cur_custdata.CORPPHONE,               
	          CORPEMAIL      = cur_custdata.CORPEMAIL,               
	          USETAG         = v_USETAG,                  
	          UPDATESTAFFNO  = cur_custdata.UPDATESTAFFNO,         
		        UPDATETIME     = v_currdate,         
		        REMARK         = cur_custdata.REMARK,                  
		        SERMANAGERCODE = cur_custdata.SERMANAGERCODE
	      WHERE CORPCODE     = cur_custdata.CORPCODE;
	      
	      IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
	        EXCEPTION
	          WHEN OTHERS THEN
	            p_retCode := 'S008112002';
	            p_retMsg  := '';
	            ROLLBACK; RETURN;
      END;
      
    END LOOP;
   END;
   
   --5) get total counts from TMP_GROUP_CUSTOMERCHKPAS
   v_allCust := v_addCust + v_updCust;
	 
   --6) update the main log
   BEGIN
     UPDATE TF_B_ASSOCIATETRADE
        SET STATECODE        =    '2', 																				
            CHECKSTAFFNO     =    p_currOper,																
            CHECKDEPARTNO    =    p_currDept, 		   																					
            CHECKTIME        =    v_currdate        																					
           									
      WHERE TRADEID IN (SELECT TRADEID FROM TMP_GROUP_CUSTOMERCHKPAS);

     IF SQL%ROWCOUNT = 0 OR SQL%ROWCOUNT != v_allCust THEN RAISE v_ex; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008112003';
         p_retMsg  := '';
         ROLLBACK; RETURN;
   END;	  
   
   p_retCode := '0000000000';
   p_retMsg  := '';
   COMMIT; RETURN;

END;

/
show errors






