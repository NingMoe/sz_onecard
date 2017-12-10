CREATE OR REPLACE PROCEDURE SP_TEST_OUTBANKCODE
(
	
    p_retInCode    	char,   	-- Return Code
    p_retOutCode    out char
)
as
	V_ASCII			INT;
	W_CHAR			char(1);
	
	
BEGIN
	
	
	BEGIN
		SELECT ASCII(SUBSTR(p_retInCode,-1)) INTO V_ASCII FROM DUAL;
		SELECT Chr(to_char(V_ASCII+1)) INTO W_CHAR FROM DUAL;
		
		IF V_ASCII<57 AND V_ASCII>47 THEN
			p_retOutCode := SUBSTR(p_retInCode,1,3) || W_CHAR; RETURN;
		ELSIF V_ASCII = 57 THEN
			p_retOutCode := SUBSTR(p_retInCode,1,3) || 'A'; RETURN;
		ELSIF V_ASCII<90 AND V_ASCII>64 THEN
			p_retOutCode := SUBSTR(p_retInCode,1,3) || W_CHAR; RETURN;
		ELSE
			--第四位为Z
			SELECT ASCII(SUBSTR(p_retInCode,3,1)) INTO V_ASCII FROM DUAL;
			SELECT Chr(to_char(V_ASCII+1)) INTO W_CHAR FROM DUAL;
			
			IF V_ASCII<57 AND V_ASCII>47 THEN
				p_retOutCode := SUBSTR(p_retInCode,1,2) || W_CHAR || '0'; RETURN;
			ELSIF V_ASCII = 57 THEN
				p_retOutCode := SUBSTR(p_retInCode,1,2) || 'A0'; RETURN;
			ELSIF V_ASCII<90 AND V_ASCII>64 THEN
				p_retOutCode := SUBSTR(p_retInCode,1,2) || W_CHAR || '0'; RETURN;
			ELSE
				--第三位为Z
				SELECT ASCII(SUBSTR(p_retInCode,2,1)) INTO V_ASCII FROM DUAL;
				SELECT Chr(to_char(V_ASCII+1)) INTO W_CHAR FROM DUAL;
				
				IF V_ASCII<57 AND V_ASCII>47 THEN
					p_retOutCode := SUBSTR(p_retInCode,1,1) || W_CHAR || '00'; RETURN;
				ELSIF V_ASCII = 57 THEN
					p_retOutCode := SUBSTR(p_retInCode,1,1) || 'A00'; RETURN;
				ELSIF V_ASCII<90 AND V_ASCII>64 THEN
					p_retOutCode := SUBSTR(p_retInCode,1,1) || W_CHAR || '00'; RETURN;
				ELSE
					p_retOutCode :='error';
				END IF;
				
			END IF;
		END IF;
		
		
	END;
	
END;
/
SHOW ERRORS