
CREATE OR REPLACE PROCEDURE SP_TS_ChangeCardInfo
(
    p_CALLINGSTAFFNO CHAR, 
    p_CARDNO         VARCHAR2,
    p_CARNO          CHAR,
    p_strState       CHAR,
    p_operCardNo     VARCHAR2,

    p_currOper       CHAR, 
    p_currDept       CHAR,
    p_retCode        OUT CHAR,
    p_retMsg         OUT VARCHAR2
)
AS
    v_currdate      DATE := SYSDATE;
    v_seqNo         CHAR(16);

BEGIN
	 
   --1) get the sequence number
   SP_GetSeq(seq => v_seqNo); 
   
   
   --2) add the main log info
   BEGIN
     INSERT INTO TF_B_ASSOCIATETRADE
      (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
     VALUES
      (v_seqNo, '45', p_CALLINGSTAFFNO, p_currOper, p_currDept, v_currdate);
      
     	EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003107002';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END;  

  
   --2) add the card writing trade log
   BEGIN
    INSERT INTO TF_CARD_TRADE 																								
	    (	TRADEID, TRADETYPECODE, strOperCardNo,	strCardNo, strStaffno, strState,
	      strTaxino, OPERATETIME, SUCTAG	)
    VALUES																								
	    (	v_seqNo, '45', p_operCardNo, p_CARDNO, p_CALLINGSTAFFNO, p_strState,
	 	    p_CARNO, v_currdate	,	'0' );
	 	
	 	EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008100020';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END;     
	 	    
   p_retCode := '0000000000';
   p_retMsg  := '';
   COMMIT; RETURN;
END;
/

show errors
