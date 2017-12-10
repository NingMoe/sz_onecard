CREATE OR REPLACE PROCEDURE SP_CC_SaleRollback_ChargeCard
(
    p_batchNo    char,

    p_today      date ,
    p_seqNo      char,
    p_quantity   out int  ,
    p_money      out INT  ,
    p_fromCardNo CHAR ,
    p_toCardNo   CHAR ,

    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_fromCard     numeric(8);
    v_toCard       numeric(8);
    v_realQuantity int       ;
    v_ex           exception ;
BEGIN

    v_fromCard := TO_NUMBER(SUBSTR(p_fromCardNo, -8));
    v_toCard   := TO_NUMBER(SUBSTR(p_toCardNo  , -8));
    p_quantity := v_toCard - v_fromCard + 1;

    SELECT COUNT(*) INTO v_realQuantity FROM TD_XFC_INITCARD
    WHERE  CARDSTATECODE = '4' AND XFCARDNO between p_fromCardNo and p_toCardNo;

    IF v_realQuantity != p_quantity THEN
        p_retCode := 'A007P05B11'; p_retMsg := '该批次充值卡在售出后已有卡片状态发生变更，无法整批返销';
        ROLLBACK; RETURN;
    END IF;

    -- 2) Update the voucher card info
    BEGIN
        UPDATE TD_XFC_INITCARD
        SET    CARDSTATECODE = '3'  ,
               ACTIVETIME    = null ,
               ACTIVESTAFFNO = null ,
               SALETIME      = null ,
               SALESTAFFNO   = null
        WHERE  CARDSTATECODE = '4' AND XFCARDNO between p_fromCardNo and p_toCardNo;

        IF  SQL%ROWCOUNT != p_quantity THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P05B02'; p_retMsg := '更新充值卡状态（从激活到出库）失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 3) Log the card sale
    BEGIN
        INSERT INTO TL_XFC_MANAGELOG
            (ID,STAFFNO,OPERTIME,OPERTYPECODE,STARTCARDNO,ENDCARDNO)
        VALUES
            (p_seqNo,p_currOper,p_today,'I0',p_fromCardNo,p_toCardNo);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P05B03'; p_retMsg := '记录充值卡售卡返销操作日志失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 4) Log the sale rollback log
    SELECT  sum(v.MONEY) INTO p_money
    FROM  TD_XFC_INITCARD t, TP_XFC_CARDVALUE v
    WHERE t.XFCARDNO between p_fromCardNo and p_toCardNo
    AND   t.VALUECODE = v.VALUECODE;

    p_retCode := '0000000000'; p_retMsg := '';
END;
/

show errors
