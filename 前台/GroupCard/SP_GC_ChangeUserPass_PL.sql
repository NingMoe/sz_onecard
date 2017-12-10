CREATE OR REPLACE PROCEDURE SP_GC_ChangeUserPass
(
		p_CARDNO	  char,
		p_CORPNO	  char,                -- Group corpno
		p_OLDPASSWD char,
		p_NEWPASSWD	char,
		p_currOper	char,
		p_currDept	char,
		p_retCode	  out char, -- Return Code
		p_retMsg 	  out varchar2  -- Return Message

)
AS
    v_today    date := sysdate;
    v_DBPASSWD char(12);
    v_TRADEID char(16);
    v_ex       exception;
BEGIN
		

		-- 2) Get old password
		SELECT PASSWD INTO v_DBPASSWD
		FROM  TF_F_CARDOFFERACC
		WHERE  CARDNO = p_CARDNO AND USETAG = '1';
        
    IF v_DBPASSWD != p_OLDPASSWD THEN
       p_retCode := 'A001107119';
       p_retMsg  := 'Pwd input is wrong';
       RETURN;
    END IF;
    
    -- 3) Update the password of group account 
    BEGIN
		    UPDATE  TF_F_CARDOFFERACC         
		        SET  PASSWD = p_NEWPASSWD         
		        WHERE  CARDNO = p_CARDNO;
    
    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S004111010';
	            p_retMsg  := 'Error occurred while updating the password' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    -- 4) Get trade id
    SP_GetSeq(seq => v_TRADEID);
        
    -- 5) Log operation
    BEGIN
		    INSERT INTO TF_B_TRADE           
		        (TRADEID,TRADETYPECODE,CARDNO,CORPNO,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)         
		    VALUES           
		        (v_TRADEID,'30',p_CARDNO,p_CORPNO,p_currOper,p_currDept,v_today);
    
    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S004111011';
	            p_retMsg  := 'Fail to log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
        
    -- 6) Log the operation of information change
    BEGIN
		    INSERT INTO TF_B_CUSTOMERCHANGE           
		        (TRADEID,CARDNO,PASSWD,CHGTYPECODE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)         
		    VALUES           
		        (v_TRADEID,p_CARDNO,p_NEWPASSWD,'01',p_currOper,p_currDept,v_today);
        
    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S004111012';
	            p_retMsg  := 'Fail to log the operation of information change' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors

 

