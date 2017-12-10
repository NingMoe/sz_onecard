CREATE OR REPLACE PROCEDURE SP_EW_LossCard
(
		p_CARDNO	          char,     --卡号
		p_TRADETYPECODE     char,     --业务类型编码
		p_CARDCOST	        int ,     --卡费
		p_TRADEORIGIN       varchar2, --业务来源
		p_currOper	        char,		  --员工编码
		p_TRADEID    	      out char, -- Return Trade Id
		p_retCode	          out char, -- Return Code
		p_retMsg     	      out varchar2  -- Return Message
)
AS
    v_ID	              char(18); --记录流水号
    v_CARDTRADENO     	char(4) := '0000';  --联机交易序号
    v_today             date := sysdate;
    v_TradeID           char(16);
    v_currDept	        char(4) ;
    v_ex                exception;
BEGIN
		-- 1) Get ID
		v_ID := TO_CHAR(SYSDATE, 'MMDDHHMMSS') || SUBSTR(p_CARDNO, -8);
		
    -- 2) Get DEPARTNO
    BEGIN
      SELECT DEPARTNO 
      INTO   v_currDept
      FROM   TD_M_INSIDESTAFF
      WHERE  STAFFNO = p_currOper;
    EXCEPTION WHEN NO_DATA_FOUND THEN 
      v_currDept := '9002';
    END;		

    -- 3) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;				    		        
    
    -- 4) Log the cash
    BEGIN
        INSERT INTO TF_B_TRADEFEE(
            ID                  , TRADEID     , TRADETYPECODE   , CARDNO         ,
            CARDTRADENO         , CARDSERVFEE , CARDDEPOSITFEE  , OPERATESTAFFNO ,
            OPERATEDEPARTID     , OPERATETIME , TRADEORIGIN
       )VALUES(
            v_ID                , v_TradeID   , p_TRADETYPECODE , p_CARDNO       ,
            v_CARDTRADENO       , p_CARDCOST  , 0               , p_currOper     ,
            v_currDept          , v_today     , p_TRADEORIGIN
            );

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001004112';
	            p_retMsg  := 'Fail to log the cash' || SQLERRM;
	            RETURN;
    END;    
		
    -- 5) Log operation
    BEGIN
		    INSERT INTO TF_B_TRADE(
		        TRADEID         , ID             , TRADETYPECODE   , CARDNO         ,
		        ASN             , CARDTYPECODE   , CARDTRADENO     , OPERATESTAFFNO , 
		        OPERATEDEPARTID , OPERATETIME    , CARDSTATE       , SERSTAKETAG    , 
		        TRADEORIGIN
		   )SELECT
		        v_TradeID       , v_ID           , p_TRADETYPECODE , p_CARDNO       ,
		        t.ASN           , t.CARDTYPECODE , v_CARDTRADENO   , p_currOper     , 
		        v_currDept      , v_today        , t.CARDSTATE     , t.SERSTAKETAG  , 
		        p_TRADEORIGIN
		    FROM TF_F_CARDREC t
		    WHERE CARDNO = p_CARDNO;
    
    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001004108';
	            p_retMsg  := 'Fail to log the operation' || SQLERRM;
	            RETURN;
    END;    		
    
  p_retCode := '0000000000';
	p_retMsg  := '';
	RETURN;
END;    		     

/
show errors               		    