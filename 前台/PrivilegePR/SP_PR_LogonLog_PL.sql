
CREATE OR REPLACE PROCEDURE SP_PR_LogonLog
(
    --opercardno pwd
    p_OPERCARDNO         CHAR,
    p_IPADDR           	 VARCHAR2,
    p_LOGONPAGE	         VARCHAR2,
    p_currOper           CHAR ,  
    p_currDept           CHAR ,  
    p_retCode   				 OUT CHAR,
    p_retMsg     				 OUT VARCHAR2
)
AS

BEGIN 
	
	 --5) add TF_B_LOGONLOG info
	 BEGIN 
	  INSERT INTO TF_B_LOGONLOG																											
	   (DEPARTNO				,	STAFFNO				,	OPERCARDNO		,	  IPADDR,						
		  LOGONTIME		,	LOGONPAGE	)	
	  VALUES(p_currDept , p_currOper     ,	p_OPERCARDNO, p_IPADDR ,
           sysdate, p_LOGONPAGE );
			
	  EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S100001003';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END; 
     	
   p_retCode := '0000000000';
   p_retMsg  := '';
   COMMIT; RETURN;
END;

/

show errors   
