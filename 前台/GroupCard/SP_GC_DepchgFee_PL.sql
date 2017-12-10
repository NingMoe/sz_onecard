CREATE OR REPLACE PROCEDURE SP_GC_DepchgFee
(
    p_BeginCardNo        char,
    p_EndCardNo          char,
    p_TRADETYPECODE      char,
    p_TRADEID            out char, -- Return Trade Id
    p_currOper           char,
    p_currDept           char,
    p_retCode            out char, -- Return Code
    p_retMsg             out varchar2 -- Return Message

) 
AS
    v_cardcost int;
    v_TradeID char(16);
    v_today    date := sysdate;
    v_amount   int;
    v_ex       exception;
BEGIN
    -- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;
    
    SELECT COUNT(*) INTO v_amount FROM TF_F_CARDREC 
    WHERE CARDNO BETWEEN p_BeginCardNo AND p_EndCardNo;
    
    /*for v_cursor in
    (SELECT SELLTIME FROM TF_F_CARDREC 
    WHERE CARDNO BETWEEN p_BeginCardNo AND p_EndCardNo)
    LOOP
            if v_cursor.SELLTIME < trunc(sysdate,'dd') then
                BEGIN
                        p_retCode := 'A004112111';
                        p_retMsg  := 'selltime is not today';
                        ROLLBACK; RETURN;
                END;
            END IF;
    END LOOP;*/
    
    SELECT SUM(CARDCOST) INTO v_cardcost FROM TF_F_CARDREC
    WHERE CARDNO BETWEEN p_BeginCardNo AND p_EndCardNo;
    
    IF v_cardcost != 0 THEN
    p_retCode := 'A004112110';
    p_retMsg  := 'cardcost is not 0';
    RETURN;
    END IF;
        
    -- 2) change deposit
    BEGIN
        UPDATE TF_F_CARDREC
        SET    CARDCOST = DEPOSIT,
               DEPOSIT = 0,
               SERSTAKETAG = '0'
        WHERE CARDNO BETWEEN p_BeginCardNo AND p_EndCardNo;
        
        IF  SQL%ROWCOUNT != v_amount THEN RAISE v_ex; END IF;            
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004112108';
            p_retMsg  := 'Fail to change deposit,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
	
    BEGIN
        UPDATE TL_R_ICUSER
        SET    SALETYPE = '01' --cardcost
        WHERE  CARDNO BETWEEN p_BeginCardNo AND p_EndCardNo;
        
        IF  SQL%ROWCOUNT != v_amount THEN RAISE v_ex; END IF;            
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570233';
            p_retMsg  := 'Fail to change saletype,' || SQLERRM;
            ROLLBACK; RETURN;
    END;	
        
    -- 3) Log operation
    BEGIN
        INSERT INTO TF_B_TRADE
           (TRADEID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CURRENTMONEY,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        SELECT
            v_TradeID,p_TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDCOST,p_currOper,p_currDept,v_today
        FROM TF_F_CARDREC
        WHERE CARDNO BETWEEN p_BeginCardNo AND p_EndCardNo;
                   
        IF  SQL%ROWCOUNT != v_amount THEN RAISE v_ex; END IF; 
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004112109';
            p_retMsg  := 'Fail to log the operation' || SQLERRM;
            ROLLBACK; RETURN;
    END;
            
    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;
END;

/

show errors

 