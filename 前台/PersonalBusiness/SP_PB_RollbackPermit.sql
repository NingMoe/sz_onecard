CREATE OR REPLACE PROCEDURE SP_PB_RollbackPermit
(
		p_CANCELTRADEID  char,
		p_TRADEID        out char,
		p_currOper	     char,
		p_currDept	     char,
		p_retCode        out char, -- Return Code
		p_retMsg         out varchar2  -- Return Message

)
AS
		v_Count	  int;
		v_CARDNO				char(16);
		v_SUPPLYMONEY	  int;
    v_TradeID 			char(16);
    v_today   			date := sysdate;
    v_ex      			exception;
	V_ISCANCELTAG		INT;
BEGIN
		SELECT COUNT(*) INTO v_Count FROM TF_B_FEEROLLBACK WHERE CANCELTRADEID = p_CANCELTRADEID;
		
		IF v_Count = 0 THEN
				SP_GetSeq(seq => v_TRADEID);
				p_TRADEID := v_TradeID;
				--判断流水号是否已返销，如果已返销，则不能做台帐返销。wdx 20130709,防止返销的同时做抹帐
				select count(*) INTO V_ISCANCELTAG from tf_b_trade
				where tradeid=p_CANCELTRADEID and CANCELTAG='1';
				if(V_ISCANCELTAG>0) then
					    p_retCode := 'A001024101';
			            p_retMsg  := '不能重复返销，请查验';
			            ROLLBACK; RETURN;
				end if;
				
				-- 1)
				BEGIN
			    INSERT INTO TF_B_FEEROLLBACK
			        (TRADEID,CANCELTRADEID,CANCELTAG,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
			    VALUES
			        (v_TradeID,p_CANCELTRADEID,'0',p_currOper,p_currDept,v_today);
			
			  EXCEPTION
			        WHEN OTHERS THEN
			            p_retCode := 'S001024101';
			            p_retMsg  := 'Error occurred while log into TF_B_FEEROLLBACK,' || SQLERRM;
			            ROLLBACK; RETURN;
		    END;
		    
		    -- 2)
		    BEGIN
		    	UPDATE TF_CARD_TRADE
		    	SET SUCTAG = '2'
		    	WHERE TRADEID = p_CANCELTRADEID AND SUCTAG not in ('2');
		    	IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		    	EXCEPTION
			        WHEN OTHERS THEN
			            p_retCode := 'S001026101';
			            p_retMsg  := 'Error occurred while update TF_CARD_TRADE,' || SQLERRM;
			            ROLLBACK; RETURN;
		    END;
		    
		    -- 3)
		    BEGIN
				    SELECT CARDNO,CURRENTMONEY INTO v_CARDNO,v_SUPPLYMONEY
				    FROM TF_B_TRADE WHERE TRADEID = p_CANCELTRADEID;
				    
				    EXCEPTION
						    WHEN NO_DATA_FOUND THEN
						    p_retCode := 'A001009101';
						    p_retMsg  := 'A001002112:Can not find the record or Error';
						    ROLLBACK; RETURN;
		    END;
		    
		    -- 4) Update cardacc
		    BEGIN
		    		UPDATE TF_F_CARDEWALLETACC
		    		SET CARDACCMONEY = CARDACCMONEY - v_SUPPLYMONEY,
		    				TOTALSUPPLYTIMES = TOTALSUPPLYTIMES - 1,
							TOTALSUPPLYMONEY=TOTALSUPPLYMONEY- v_SUPPLYMONEY
		    		WHERE CARDNO = v_CARDNO;
		    		
		    		IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
				EXCEPTION
			        WHEN OTHERS THEN
			            p_retCode := 'S001002113';
			            p_retMsg  := 'S001002113:Unable to Updated electronic wallet account information';
			            ROLLBACK; RETURN;
		    END;
		    
		ELSE
				-- 1)
				BEGIN
					DELETE FROM TF_B_FEEROLLBACK
					WHERE CANCELTRADEID = p_CANCELTRADEID;
					
					IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF; 
					EXCEPTION
			        WHEN OTHERS THEN
			            p_retCode := 'S001024103';
			            p_retMsg  := 'S001024103:Error occurred while delete from TF_B_FEEROLLBACK';
			            ROLLBACK; RETURN;
		    END; 
		    
		    -- 2)
		    BEGIN
		    	UPDATE TF_CARD_TRADE
		    	SET SUCTAG = '0'
		    	WHERE TRADEID = p_CANCELTRADEID;
		    	IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		    	EXCEPTION
			        WHEN OTHERS THEN
			            p_retCode := 'S001026101';
			            p_retMsg  := 'Error occurred while update TF_CARD_TRADE,' || SQLERRM;
			            ROLLBACK; RETURN;
		    END;
		    
		    -- 3)
		    BEGIN
				    SELECT CARDNO,CURRENTMONEY INTO v_CARDNO,v_SUPPLYMONEY
				    FROM TF_B_TRADE WHERE TRADEID = p_CANCELTRADEID;
				    
				    EXCEPTION
						    WHEN NO_DATA_FOUND THEN
						    p_retCode := 'A001009101';
						    p_retMsg  := 'A001002112:Can not find the record or Error';
						    ROLLBACK; RETURN;
		    END;
		    
		    -- 4)
		    BEGIN
		    		UPDATE TF_F_CARDEWALLETACC
		    		SET CARDACCMONEY = CARDACCMONEY + v_SUPPLYMONEY,
		    				TOTALSUPPLYTIMES = TOTALSUPPLYTIMES + 1,
							TOTALSUPPLYMONEY=TOTALSUPPLYMONEY+v_SUPPLYMONEY
		    		WHERE CARDNO = v_CARDNO;
		    		
		    		IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
				EXCEPTION
			        WHEN OTHERS THEN
			            p_retCode := 'S001002113';
			            p_retMsg  := 'S001002113:Unable to Updated electronic wallet account information';
			            ROLLBACK; RETURN;
		    END;
		     
		END IF;

	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors

 