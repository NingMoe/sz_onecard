-- =============================================
-- AUTHOR:		liuhe
-- CREATE DATE: 2013-09-09
-- DESCRIPTION:	旅游卡-售卡返销存储过程
-- =============================================
CREATE OR REPLACE PROCEDURE SP_AS_SZTravelCardSaleRollback
(
		p_ID              char,
		p_CARDNO	      char,
		p_CARDTRADENO     char,
		p_SUPPLYMONEY	  int,
		p_DEPOSIT         int,
		p_TRADEPROCFEE    int,
		p_CANCELTRADEID   char,
		p_TERMNO		  char,
		p_OPERCARDNO	  char,
		p_currOper	      char,
		p_currDept	      char,
		p_retCode	        out char, -- Return Code
		p_retMsg     	    out varchar2  -- Return Message

)
AS
    v_TRADETYPECODE  char(2);
    v_TradeID char(16);
		v_CURRENTTIME   date := sysdate;
    v_ex            exception;
	v_CHARGEMONEY	int;
BEGIN

		SELECT SUPPLYMONEY INTO v_CHARGEMONEY
        FROM   TF_B_TRADEFEE T
        WHERE  T.TRADEID = p_CANCELTRADEID;
		

		-- 1) update resstate
		BEGIN
				UPDATE TL_R_ICUSER
				SET RESSTATECODE = '05',
				    SELLTIME = null,
				    UPDATESTAFFNO = p_currOper,
				    UPDATETIME = v_CURRENTTIME
				WHERE CARDNO = p_CARDNO;

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001105';
	            p_retMsg  := 'Fail to update resstatecode' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    -- 3) Get trade id
    SP_GetSeq(seq => v_TradeID);
    
    -- 4) Select tradetypecode
    BEGIN
		    SELECT b.CANCELCODE INTO v_TRADETYPECODE
		    FROM TF_B_TRADE a,TD_M_TRADETYPE b
		    WHERE a.TRADEID = p_CANCELTRADEID AND b.TRADETYPECODE = a.TRADETYPECODE;
	    
    EXCEPTION
	      WHEN NO_DATA_FOUND THEN
	          p_retCode := 'A001020101';
	          p_retMsg  := 'Can not find psam,' || SQLERRM;
	          ROLLBACK; RETURN;
	  END;
	  
    -- 5)update salerecord
    BEGIN
    	UPDATE TF_B_TRADE
    	SET CANCELTAG  = '1',
    	CANCELTRADEID = v_TradeID
    	WHERE TRADEID = p_CANCELTRADEID;
    
    		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001020102';
	            p_retMsg  := 'Fail to update salerecord' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    -- 5)log the tradefee
    BEGIN
		    INSERT INTO TF_B_TRADEFEE
		           (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,TRADEPROCFEE,CARDDEPOSITFEE,SUPPLYMONEY,
		           OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
		       SELECT
		             p_ID,v_TradeID,v_TRADETYPECODE,CARDNO,p_CARDTRADENO,p_TRADEPROCFEE,-DEPOSIT,p_SUPPLYMONEY,
		             p_currOper,p_currDept,v_CURRENTTIME
		       FROM TF_F_CARDREC
		       WHERE CARDNO = p_CARDNO;

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001020103';
	            p_retMsg  := 'Fail to log the tradefee' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    -- 6)log the operation
    BEGIN
		    INSERT INTO TF_B_TRADE
		           (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,CURRENTMONEY,
		           OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,CANCELTRADEID)
		       SELECT
		             v_TradeID,p_ID,v_TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,p_CARDTRADENO,
		             p_DEPOSIT + p_TRADEPROCFEE + p_SUPPLYMONEY,p_currOper,p_currDept,v_CURRENTTIME,p_CANCELTRADEID
		       FROM TF_F_CARDREC
		       WHERE CARDNO = p_CARDNO;

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001020104';
	            p_retMsg  := 'Fail to log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
	
	BEGIN
		INSERT INTO TF_SUPPLY_REALTIME
			(ID,CARDNO,ASN,CARDTRADENO,TRADETYPECODE,CARDTYPECODE,TRADEDATE,TRADETIME,TRADEMONEY,
			PREMONEY,SUPPLYLOCNO,SAMNO,OPERATESTAFFNO,OPERATETIME)
		SELECT 
			p_ID,p_CARDNO,ASN,p_CARDTRADENO,'B1',CARDTYPECODE,
			TO_CHAR(v_CURRENTTIME,'YYYYMMDD'),TO_CHAR(v_CURRENTTIME,'HH24MISS'),
			p_SUPPLYMONEY,-p_SUPPLYMONEY,p_currDept,p_TERMNO,p_currOper,v_CURRENTTIME
		FROM TF_F_CARDREC WHERE CARDNO = p_CARDNO;
		EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S001009106'; 
			p_retMsg  := 'Error occurred while insert a row of wallet recharge log' || SQLERRM;
			ROLLBACK; RETURN;
	END;
    
    -- 7)delete card info
    BEGIN
    		DELETE FROM TF_F_CARDREC WHERE CARDNO = p_CARDNO;

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001020105';
	            p_retMsg  := 'Fail to delete card info' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    -- 8)delete acc info
    BEGIN
    		DELETE FROM TF_F_CARDEWALLETACC WHERE CARDNO = p_CARDNO;

 		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001020106';
	            p_retMsg  := 'Fail to delete card info' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 9)delete customer info
    BEGIN
    		DELETE FROM TF_F_CUSTOMERREC WHERE CARDNO = p_CARDNO;

 		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001020107';
	            p_retMsg  := 'Fail to delete customer info' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
    
    -- 10) Log the writeCard
    BEGIN

		INSERT INTO TF_CARD_TRADE
				(TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,lMoney,lOldMoney,strTermno,OPERATETIME,SUCTAG)
		VALUES
				(v_TradeID,v_TRADETYPECODE,p_OPERCARDNO,p_CARDNO,p_SUPPLYMONEY,-p_SUPPLYMONEY,p_TERMNO,v_CURRENTTIME,'0');
	
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001139';
	            p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
	            ROLLBACK; RETURN;
    END;
	
	   -- 代理营业厅抵扣预付款，根据保证金修改可领卡额度，add by liuhe 20111230
   BEGIN
		 SP_PB_DEPTBALFEEROLLBACK(v_TradeID, p_CANCELTRADEID,
					'3' ,--1预付款,2保证金,3预付款和保证金
					 p_DEPOSIT + p_TRADEPROCFEE + p_SUPPLYMONEY,
	                 p_currOper,p_currDept,p_retCode,p_retMsg);
		                 
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

 