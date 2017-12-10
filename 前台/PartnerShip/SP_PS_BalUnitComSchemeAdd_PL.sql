
CREATE OR REPLACE PROCEDURE SP_PS_BalUnitComSchemeAdd
(
    p_balUnitNo      CHAR,
    p_comSchemeNo    CHAR,
    p_beginTime      CHAR, --YYYY-MM-DD HH24:MI:SS
    p_endTime        CHAR,
	
    p_currOper       CHAR,  
    p_currDept       CHAR, 
    p_retCode        OUT CHAR,
    p_retMsg         OUT VARCHAR2 
)
AS
    v_currdate    DATE := SYSDATE;
    v_seqNo       CHAR(16);
    v_balComsID   CHAR(8);

BEGIN 
	
   -- 1) get one comscheme Code, A5  means get coms scheme code, len = 8 
   SP_GetBizAppCode(1, 'A5', 8, v_balComsID);

   --2) get the sequence number
   SP_GetSeq(seq => v_seqNo); 
   
   --3) add main log info
   BEGIN
     INSERT INTO TF_B_ASSOCIATETRADE
       (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO,
	    OPERATEDEPARTID, OPERATETIME ,STATECODE)
     VALUES(v_seqNo, '66', p_balUnitNo, p_currOper,  p_currDept, v_currdate, '1' );
     
	 EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008104003';
         p_retMsg  := '';
         ROLLBACK; RETURN;	 
   END;
	 
   --4) add additional log info  into TF_TBALUNIT_COMSCHEMECHANGE
   BEGIN
     INSERT INTO TF_TBALUNIT_COMSCHEMECHANGE
       (TRADEID, COMSCHEMENO, BALUNITNO, ID, BEGINTIME, ENDTIME)
     VALUES(v_seqNo, p_comSchemeNo, p_balUnitNo, v_balComsID,
	        TO_DATE(p_beginTime, 'YYYY-MM-DD HH24:MI:SS'),
			TO_DATE(p_endTime, 'YYYY-MM-DD HH24:MI:SS') );
			
     EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008104007';
         p_retMsg  := '';
         ROLLBACK; RETURN;	 
   END;

   --5) add additional log info  into TF_B_TRADE_BALUNITCHANGE
   BEGIN
     INSERT INTO TF_B_TRADE_BALUNITCHANGE
       (TRADEID, BALUNITNO, BALUNIT, BALUNITTYPECODE, SOURCETYPECODE, 
	    CALLINGNO, CORPNO, DEPARTNO, BANKCODE, BANKACCNO, SERMANAGERCODE, CREATETIME, 
		BALLEVEL, BALCYCLETYPECODE, BALINTERVAL, FINCYCLETYPECODE, FININTERVAL, 
		FINTYPECODE, COMFEETAKECODE, FINBANKCODE, LINKMAN, UNITPHONE, UNITADD, REMARK,
		UNITEMAIL,CHANNELNO)
     SELECT v_seqNo, p_balUnitNo, BALUNIT, BALUNITTYPECODE, SOURCETYPECODE,  
        CALLINGNO, CORPNO, DEPARTNO, BANKCODE, BANKACCNO, SERMANAGERCODE, CREATETIME,   
	    	BALLEVEL, BALCYCLETYPECODE, BALINTERVAL, FINCYCLETYPECODE, FININTERVAL,
        FINTYPECODE, COMFEETAKECODE, FINBANKCODE, LINKMAN, UNITPHONE, UNITADD, REMARK,
        UNITEMAIL,CHANNELNO
     FROM TF_TRADE_BALUNIT WHERE BALUNITNO = p_balUnitNo;
	 
	EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008104009';
         p_retMsg  := '';
         ROLLBACK; RETURN;          
   END;

   p_retCode := '0000000000';
   p_retMsg  := '';
   COMMIT; RETURN;
END;
/

show errors


