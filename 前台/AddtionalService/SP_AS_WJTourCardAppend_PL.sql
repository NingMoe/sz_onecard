CREATE OR REPLACE PROCEDURE SP_AS_WJTourCardAppend
(
    p_cardNo             char,
    p_asn                char,

    p_operCardNo        char,
    p_terminalNo        char,
    p_endDateNum        char,

    p_currOper           char,
    p_currDept           char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_seqNo         char(16);
    v_cardType      CHAR(2);
    v_ex            exception;

BEGIN

    -- 2) Get trade id
    SP_GetSeq(seq => v_seqNo);

    SELECT CARDTYPECODE INTO v_cardType FROM TL_R_ICUSER WHERE CARDNO = p_cardNo;

    -- 3) Log the operation
    BEGIN
        INSERT INTO TF_B_TRADE
            (TRADEID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
            (v_seqNo, '6C',p_cardNo,p_asn,v_cardType,
            p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570026'; p_retMsg  := '新增吴江旅游年卡补写卡台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 4) Log card change
    BEGIN
        INSERT INTO TF_CARD_TRADE
            (TRADEID, TRADETYPECODE, strOperCardNo, strCardNo, strTermno, strEndDateNum, OPERATETIME)
        VALUES(v_seqNo, '6C', p_operCardNo, p_cardNo, p_terminalNo, p_endDateNum, v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570027'; p_retMsg  := '新增吴江旅游年卡补写卡卡片交易台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors
