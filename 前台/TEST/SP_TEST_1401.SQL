CREATE OR REPLACE PROCEDURE SP_TEST_1401
(
    p_retCode    out char,   	-- Return Code
    p_retMsg     out varchar2,   -- Return Message
	p_retCount	 out varchar2
)
as
	v_1			int;
	v_2			int;
	V_COUNT		INT;
	v_bankcode  char(4);
BEGIN
	v_1 := 0;
	v_2 := 0;
	v_bankcode:='S000';
	
	BEGIN
		FOR v_cur IN (SELECT C1,C2,C3 FROM tb_test_1401)
		LOOP
			BEGIN
				SELECT COUNT(1) INTO V_COUNT FROM TD_M_BANK T WHERE T.BANK = v_cur.C2;
				IF V_COUNT = 1 THEN
					v_1 := v_1 + 1;
					UPDATE TD_M_BANK T 
						SET T.BANKNUMBER = v_cur.C1,
							T.ISLOCAL	 = DECODE(LENGTH(v_cur.C1),6,'1','0')
						WHERE T.BANK = v_cur.C2;
					
				ELSE
					v_2 := v_2 + 1;
					SP_TEST_OUTBANKCODE(p_retInCode => v_bankcode,p_retOutCode => v_bankcode);
					INSERT INTO TD_M_BANK
						(BANKCODE	,BANK		,ISLOCAL	,BANKNUMBER)
					VALUES
						(v_bankcode ,v_cur.C2	,DECODE(LENGTH(v_cur.C1),6,'1','0'),v_cur.C1);
				END IF;
			END;
		END LOOP;
	END;
	
	p_retCode := '0000000000';
    p_retMsg  := 'OK';
	p_retCount := v_1 || 'AAA' || v_2;
    COMMIT; 
    RETURN;  
END;

/
SHOW ERRORS