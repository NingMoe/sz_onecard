CREATE OR REPLACE PROCEDURE SP_AS_TravelCardClose
(
    p_ID                char,
    p_cardNo            char,
    p_cardTradeNo       char,
    p_asn               char,
    p_tradeFee          int,

    p_operCardNo        char,
    p_terminalNo        char,
    p_endDateNum        char,

    p_currOper          char,
    p_currDept          char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_cardType      CHAR(2);
    v_ex            exception;
    v_seqNo         char(16);

BEGIN

    -- 2) Update
    BEGIN
        UPDATE  TF_F_CARDTOURACC_WJ
        SET CURRENTPAYTIME  = v_today,
            CURRENTPAYFEE   = p_tradeFee,
            USETAG          = '0',
            UPDATESTAFFNO   = p_currOper,
            UPDATETIME      = v_today
        WHERE CARDNO = p_cardNo;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00601B002'; p_retMsg  := '设置吴江旅游年卡有效标识为无效时失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;


    SP_GetSeq(seq => v_seqNo);

    SELECT CARDTYPECODE INTO v_cardType FROM TL_R_ICUSER WHERE CARDNO = p_cardNo;

    -- 4) Log the operation
    BEGIN
        INSERT INTO TF_B_TRADE
            (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
            (v_seqNo,p_ID,'6D',p_cardNo,p_asn,v_cardType,
            p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00504B002'; p_retMsg  := '新增吴江旅游年卡关闭台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 5) Log the cash
    BEGIN
        INSERT INTO TF_B_TRADEFEE
            (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,FUNCFEE,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
            (p_ID,v_seqNo,'6D',p_cardNo,p_cardTradeNo,p_tradeFee,
            p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00504B003'; p_retMsg  := '新增吴江旅游年卡关闭现金台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 6) Log card change
    BEGIN
        INSERT INTO TF_CARD_TRADE
            (TRADEID, TRADETYPECODE, strOperCardNo, strCardNo, strTermno, strEndDateNum, OPERATETIME)
        VALUES(v_seqNo, '6D', p_operCardNo, p_cardNo, p_terminalNo, p_endDateNum, v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00504B004'; p_retMsg  := '新增吴江旅游年卡关闭卡片交易台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 7) breakup the relation between cards and features.
    BEGIN
        UPDATE TF_F_CARDUSEAREA
        SET    USETAG        = '0',
               UPDATESTAFFNO = p_currOper,
               UPDATETIME    = v_today
        WHERE  CARDNO        = p_cardNo
        AND    FUNCTIONTYPE  = '12';

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00504B005'; p_retMsg  := '更新卡片与吴江旅游年卡功能项关联关系失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/
show errors