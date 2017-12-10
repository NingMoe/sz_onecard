CREATE OR REPLACE PROCEDURE SP_CC_DirectSale_ChargeCard
(
    p_fromCardNo char,
    p_toCardNo   char,

    p_totalValue out int,
    p_quantity   out int,
    p_today      out date,

    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_fromCard     numeric(8);
    v_toCard       numeric(8);
    v_ex           exception ;

BEGIN
    p_today    := sysdate;
    v_fromCard := TO_NUMBER(SUBSTR(p_fromCardNo, -8));
    v_toCard   := TO_NUMBER(SUBSTR(p_toCardNo  , -8));
    p_quantity := v_toCard - v_fromCard + 1;

    -- 1) Check the voucher cards' status
    BEGIN
        UPDATE TD_XFC_INITCARD
        SET    SALETIME      = p_today    ,
               SALESTAFFNO   = p_currOper
        WHERE  CARDSTATECODE in ('4', '5')
        AND    SALETIME is null
        AND    SALESTAFFNO is null
        AND    XFCARDNO BETWEEN p_fromCardNo AND p_toCardNo
        AND    ASSIGNDEPARTNO=p_currDept;
        IF  SQL%ROWCOUNT != p_quantity THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P02B01'; p_retMsg  := '更新充值卡直销信息失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 3) Log the sale log
    SELECT sum(v.MONEY) INTO p_totalValue
    FROM  TD_XFC_INITCARD t, TP_XFC_CARDVALUE v
    WHERE t.XFCARDNO BETWEEN  p_fromCardNo AND p_toCardNo
    AND   t.VALUECODE = v.VALUECODE;

    p_retCode := '0000000000'; p_retMsg := '';
END;
/

show errors

