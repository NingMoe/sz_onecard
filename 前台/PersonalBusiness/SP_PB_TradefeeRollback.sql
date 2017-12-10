CREATE OR REPLACE PROCEDURE SP_PB_TradefeeRollback
(
		p_CANCELTRADEID  char,
		p_ID	           char,
		p_TRADEID        out char,
		p_currOper	     char,
		p_currDept	     char,
		p_retCode        out char, -- Return Code
		p_retMsg         out varchar2  -- Return Message

)
AS
		v_TRADETYPECODE		char(2);
		v_SUPPLYMONEY	  	int;
    v_TradeID 				char(16);
    v_today   				date := sysdate;
    v_ex      				exception;
	v_tradeFee    int DEFAULT 0;
BEGIN

		SP_GetSeq(seq => v_TRADEID);
		p_TRADEID := v_TRADEID;
		
		-- 1)
		BEGIN
			UPDATE TF_B_FEEROLLBACK
			SET CANCELTAG = '1'
			WHERE CANCELTRADEID = p_CANCELTRADEID AND CANCELTAG='0';
			
			IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
	  EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001025102';
	            p_retMsg  := 'Error occurred while log into TF_B_FEEROLLBACK,' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    -- 2)
    BEGIN
    	UPDATE TF_B_TRADE
    	SET CANCELTAG = '1',
    	CANCELTRADEID = v_TRADEID
    	WHERE TRADEID = p_CANCELTRADEID AND CANCELTAG='0';--防止通过其他方式返销掉。或重复返销。
    	
    	IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001025103';
	            p_retMsg  := 'Error occurred while update TF_B_TRADE,' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    -- 4)
    SELECT TRADETYPECODE,0-CURRENTMONEY INTO v_TRADETYPECODE,v_SUPPLYMONEY
    FROM TF_B_TRADE WHERE TRADEID = p_CANCELTRADEID;
    
    SELECT DECODE(v_TRADETYPECODE, '02', '99','14','9A') 
    INTO v_TRADETYPECODE FROM DUAL;
    
    -- 3)
		BEGIN
	    INSERT INTO TF_B_TRADE
	        (TRADEID,ID,CARDNO,TRADETYPECODE,CURRENTMONEY,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,CANCELTRADEID,RSRV2)
	    SELECT
	        v_TRADEID,p_ID,CARDNO,v_TRADETYPECODE,v_SUPPLYMONEY,p_currOper,p_currDept,v_today,p_CANCELTRADEID,RSRV2
	     FROM TF_B_TRADE
	     WHERE TRADEID = p_CANCELTRADEID;

	  EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001025104';
	            p_retMsg  := 'Error occurred while log into TF_B_TRADE,' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 4)
    IF v_TRADETYPECODE = '99' THEN
		    BEGIN
			    INSERT INTO TF_B_TRADEFEE
			        (ID,TRADEID,TRADETYPECODE,CARDNO,SUPPLYMONEY,OTHERFEE,    
				        OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)  
			    SELECT
			        p_ID,v_TradeID,v_TRADETYPECODE,CARDNO,0-SUPPLYMONEY,0-OTHERFEE, p_currOper,p_currDept,v_today
			     FROM TF_B_TRADEFEE
			     WHERE TRADEID = p_CANCELTRADEID;
			
			  EXCEPTION
			        WHEN OTHERS THEN
			            p_retCode := 'S001025105';
			            p_retMsg  := 'Error occurred while log into TF_B_TRADEFEE,' || SQLERRM;
			            ROLLBACK; RETURN;
		    END;
			
			------ 代理营业厅抵扣预付款，add by liuhe 20111230
			BEGIN
				SELECT  - SUPPLYMONEY - OTHERFEE INTO v_tradeFee
				FROM TF_B_TRADEFEE
				WHERE TRADEID = p_CANCELTRADEID;

			EXCEPTION
			WHEN NO_DATA_FOUND THEN
				p_retCode := 'S001009101';
				p_retMsg  := '没有从现金台账表取到数据' || SQLERRM;
				ROLLBACK; RETURN;
			END;
			
			 BEGIN
					SP_PB_DEPTBALFEEROLLBACK(v_TradeID, p_CANCELTRADEID,
					'1' ,--1预付款,2保证金,3预付款和保证金
					 v_tradeFee,
	                 p_currOper,p_currDept,p_retCode,p_retMsg);
		                 
			 IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
				EXCEPTION
				WHEN OTHERS THEN
					ROLLBACK; RETURN;
			END;
	
	END IF;

	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors

 