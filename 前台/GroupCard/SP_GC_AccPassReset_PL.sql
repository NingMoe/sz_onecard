CREATE OR REPLACE PROCEDURE SP_GC_AccPassReset
(
		p_cardNo     char,
		p_currOper   char,
		p_currDept   char,
		p_retCode    out char,
		p_retMsg     out varchar2

) 
AS
    v_resetPass   char(12);
    v_seqNo       char(16);
		v_CURRENTTIME date := sysdate;
    v_ex          exception;
BEGIN
		v_resetPass := '0.0-000*0/0.'; -- temporarily used here, to be changed
		
		-- 1) Update the password of group account
		BEGIN
				UPDATE  TF_F_CARDOFFERACC
				    SET  PASSWD = v_resetPass
				    WHERE  CARDNO = p_cardNo;

				IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S004111102';
	            p_retMsg  := 'Error occurred while updating the password' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
		
		-- 2) Get trade id
		SP_GetSeq(seq => v_seqNo);

		-- 3) Log operation
		BEGIN
				INSERT INTO TF_B_TRADE
				    (TRADEID,TRADETYPECODE,CARDNO,CORPNO,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
				SELECT v_seqNo,'38',p_cardNo, CORPNO,p_currOper,p_currDept,v_CURRENTTIME
				FROM   TD_GROUP_CARD
				WHERE  CARDNO = p_cardNo;
		
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S004112109';
	            p_retMsg  := 'Fail to log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

		-- 4) Log the operation of information change
		BEGIN
				INSERT INTO TF_B_CUSTOMERCHANGE
				    (TRADEID,CARDNO,PASSWD,CHGTYPECODE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
				VALUES
				    (v_seqNo,p_cardNo,v_resetPass,'01',p_currOper,p_currDept,v_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S004111104';
	            p_retMsg  := 'Fail to log the operation of information change' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors

 