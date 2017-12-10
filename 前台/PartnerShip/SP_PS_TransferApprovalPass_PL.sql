
CREATE OR REPLACE PROCEDURE SP_PS_TransferApprovalPass
(
    p_tradeId        CHAR,
    p_tradeTypeCode  CHAR,
    p_balUnitNo      CHAR, 
    p_channelNo      CHAR, 
    p_currOper       CHAR,  
    p_currDept       CHAR, 
    p_retCode        OUT CHAR,
    p_retMsg         OUT VARCHAR2 
)
AS
    v_currdate       DATE := SYSDATE;
    v_ex             EXCEPTION;

BEGIN
	
	--1)update the TF_B_TRADE_BALUNITCHANGE info
	BEGIN
		UPDATE TF_B_TRADE_BALUNITCHANGE											
		   SET CHANNELNO = p_channelNo										
		 WHERE TRADEID =   p_tradeId;  	
	  	 
	   IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008108008';
         p_retMsg  := '';
         ROLLBACK; RETURN;
   END;						
											
   --2) update main log info
   BEGIN
     UPDATE TF_B_ASSOCIATETRADE																																				
	      SET STATECODE      =  '2',																																	
		        CHECKSTAFFNO   =   p_currOper,																																	
		        CHECKDEPARTNO  =   p_currDept, 																																	
		        CHECKTIME      =   v_currdate        																																	
		     																							
	   WHERE  TRADEID        =   p_tradeId;  																																	
						
     IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008108001';
         p_retMsg  := '';
         ROLLBACK; RETURN;
   END;
   
   --3)add the exam log
   BEGIN
     INSERT INTO TF_B_ASSOCIATETRADE_EXAM																								
	   (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO, OPERATEDEPARTID, 
	    OPERATETIME, STATECODE)																																			
	 VALUES(p_tradeId, p_tradeTypeCode, p_balUnitNo, p_currOper, p_currDept, v_currdate, '1');
	 
	 EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008108002';
         p_retMsg  := '';
         ROLLBACK; RETURN;
   END;  
	 
   p_retCode := '0000000000';                
   p_retMsg  := '';                        
   COMMIT; RETURN;																																															

END;
/
show errors

