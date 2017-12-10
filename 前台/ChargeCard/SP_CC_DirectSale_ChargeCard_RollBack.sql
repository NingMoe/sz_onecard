/*
充值卡批量直销返销
创建 殷华荣 2013-03-27
*/
CREATE OR REPLACE PROCEDURE SP_CC_SaleChargeCard_RollBack
(
    p_fromCardNo char,
    p_toCardNo   char,

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
        SET    SALETIME      = null    ,
               SALESTAFFNO   = null
        WHERE  CARDSTATECODE in ('4', '5')
        AND    SALETIME is not null
        AND    SALESTAFFNO is not null
        AND    XFCARDNO BETWEEN p_fromCardNo AND p_toCardNo
        AND    ASSIGNDEPARTNO = p_currDept;
        IF  SQL%ROWCOUNT != p_quantity THEN RAISE v_ex; END IF;
		    EXCEPTION WHEN OTHERS THEN
		        p_retCode := 'S007P02B01'; p_retMsg  := '更新充值卡直销信息失败,' || SQLERRM;
		        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg := '';
END;
/

show errors

