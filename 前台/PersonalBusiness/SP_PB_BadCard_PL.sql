CREATE OR REPLACE PROCEDURE SP_PB_BadCard
(
		p_CARDNO	        char,
		p_TRADETYPECODE	  char,
		p_TRADEID    	    out char, -- Return Trade Id
		p_currOper	      char,
		p_currDept	      char,
		p_retCode	        out char, -- Return Code
		p_retMsg     	    out varchar2  -- Return Message

)
AS
    v_TradeID char(16);
    v_CURRENTTIME   date := sysdate;
    v_RESSTATECODE	char(2);
    v_ex      exception;
BEGIN
		-- 1) Select card resource statecode
		BEGIN
				SELECT
		         RESSTATECODE INTO v_RESSTATECODE
		    FROM TL_R_ICUSER       
		    WHERE CARDNO = p_CARDNO AND  RESSTATECODE IN ( '01','05');
    
    EXCEPTION
				    WHEN NO_DATA_FOUND THEN
				    p_retCode := 'A001004132';
				    p_retMsg  := 'card resource statecode is wrong' || SQLERRM;
				    ROLLBACK; RETURN;
    END;
    
    -- 2) Update card resource statecode
    BEGIN
		    UPDATE TL_R_ICUSER        
		    SET RESSTATECODE  = '11', 
		        UPDATESTAFFNO = p_currOper,      
		        UPDATETIME = v_CURRENTTIME      
		    WHERE  CARDNO = p_CARDNO;
    
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
		EXCEPTION
			      WHEN OTHERS THEN
			          p_retCode := 'S001001105';
			          p_retMsg  := 'Update failure' || SQLERRM;
			      ROLLBACK; RETURN;
		END;
		
    -- 3) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;
    
    -- 4) Log operation
    BEGIN
		    INSERT INTO TF_B_TRADE        
		        (TRADEID,TRADETYPECODE,CARDNO,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
		    VALUES        
		        (v_TradeID,p_TRADETYPECODE,p_CARDNO,p_currOper,p_currDept,v_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001140';
	            p_retMsg  := 'Error occurred while log the operation,' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
	 -- 代理营业厅根据保证金修改可领卡额度，add by liuhe 20111230
	BEGIN
		  SP_PB_DEPTBALFEE(v_TradeID, 
					'2' ,--1预付款,2保证金,3预付款和保证金
					 null,
					 v_CURRENTTIME,p_currOper,p_currDept,p_retCode,p_retMsg);
					 
		 IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
			EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK; RETURN;
		
   END;
	
  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/

show errors

 