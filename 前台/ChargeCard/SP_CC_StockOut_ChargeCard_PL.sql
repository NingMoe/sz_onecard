CREATE OR REPLACE PROCEDURE SP_CC_StockOut_ChargeCard
(
    p_fromCardNo char,
    p_toCardNo   char,
    p_assignDepartNo char,
    p_seqNo          char,
    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_fromCard     numeric(8);
    v_toCard       numeric(8);
    v_ex           exception ;
    v_quantity     int;
    v_today        date:=sysdate;
BEGIN

    v_fromCard := TO_NUMBER(SUBSTR(p_fromCardNo, -8));
    v_toCard   := TO_NUMBER(SUBSTR(p_toCardNo  , -8));
    v_quantity := v_toCard - v_fromCard + 1;

    -- 1) Update the voucher card info
    BEGIN
        UPDATE TD_XFC_INITCARD			
        SET    OUTTIME    = v_today    ,			
               OUTSTAFFNO = p_currOper ,			
               ASSIGNDEPARTNO   = p_assignDepartNo,			
               CARDSTATECODE='3'  --出库状态			
        WHERE  CARDSTATECODE = '2' -- 入库状态			
        AND    XFCARDNO BETWEEN p_fromCardNo AND p_toCardNo;			


        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P04C01'; p_retMsg := '更新充值卡状态失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    -- 2) Log the card operation
    BEGIN
        INSERT INTO TL_XFC_MANAGELOG
            (ID,STAFFNO,OPERTIME,OPERTYPECODE,STARTCARDNO,ENDCARDNO)
        VALUES
            (p_seqNo,p_currOper,v_today,'03',p_fromCardNo,p_toCardNo);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P04C02'; p_retMsg := '更新充值卡出库操作日志失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;


    p_retCode := '0000000000'; p_retMsg  := '';
END;
/