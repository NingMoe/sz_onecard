CREATE OR REPLACE PROCEDURE SP_CC_Activate_ChargeCard
(
    p_fromCardNo char,
    p_toCardNo   char,
    p_stateCode  char, -- 3 Stockout 4 Activate
    p_remark     varchar2,
    p_seqNo      char,
    p_currOper   char,
    p_currDept   char,
    p_retCode    out char,
    p_retMsg     out varchar2
)
AS
    v_fromCard     numeric(8);
    v_toCard       numeric(8);
    v_quantity     int       ;
    v_today        date      := sysdate;
    v_ex           exception ;
    v_operTypeCode char(2)   ;
BEGIN

    -- 1) Check the state code
    IF NOT (p_stateCode = '3' OR p_stateCode = '4') THEN
        p_retCode := 'A007P01B01'; p_retMsg := '状态码必须为''4'' (激活) 或 ''3'' (关闭)';
        RETURN;
    END IF;

    v_fromCard := TO_NUMBER(SUBSTR(p_fromCardNo, -8));
    v_toCard   := TO_NUMBER(SUBSTR(p_toCardNo  , -8));
    v_quantity := v_toCard - v_fromCard + 1;

    -- 2) Update the voucher card info
    BEGIN
        IF p_stateCode = '4' THEN
            UPDATE TD_XFC_INITCARD
            SET    CARDSTATECODE = '4',
                   ACTIVETIME    = v_today    ,
                   ACTIVESTAFFNO = p_currOper ,
                   SALETIME      = null,
                   SALESTAFFNO   = null
            WHERE  XFCARDNO BETWEEN p_fromCardNo AND p_toCardNo
            AND    CARDSTATECODE = '3';
        ELSE
            UPDATE TD_XFC_INITCARD
            SET    CARDSTATECODE = '3',
                   ACTIVETIME    = null,
                   ACTIVESTAFFNO = null,
                   SALETIME      = null,
                   SALESTAFFNO   = null
            WHERE  XFCARDNO BETWEEN p_fromCardNo AND p_toCardNo
            AND    CARDSTATECODE = '4';
        END IF;

        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
	    p_retCode := 'S007P01B02'; p_retMsg  := '更新充值卡状态失败,' || SQLERRM;
	    ROLLBACK; RETURN;
    END;

    IF p_stateCode = '3' THEN
        v_operTypeCode := '03';
    ELSE
        v_operTypeCode := '04';
    END IF;

    -- 3) Log the card sale
    BEGIN
        INSERT INTO TL_XFC_MANAGELOG
            (ID,STAFFNO,OPERTIME,OPERTYPECODE,STARTCARDNO,ENDCARDNO,REMARK)
        VALUES
            (p_seqNo,p_currOper,v_today,v_operTypeCode,p_fromCardNo,p_toCardNo,p_remark);
    EXCEPTION WHEN OTHERS THEN
	    p_retCode := 'S007P01B03'; p_retMsg  := '新增充值卡激活/关闭操作日志失败,' || SQLERRM;
	    ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg  := '';
END;
/

show errors

