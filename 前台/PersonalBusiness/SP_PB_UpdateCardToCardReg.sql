CREATE OR REPLACE PROCEDURE SP_PB_UpdateCardToCardReg
(
    p_TRADEID       char,
    p_currOper      char,
    p_currDept      char,
    p_retCode   out char,     -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_ex            exception;
BEGIN
    --写卡成功后，将卡卡转账记录台账表的转账状态由2、圈提待写卡，改为0、圈提待转账
    BEGIN
        UPDATE TF_B_CARDTOCARDREG
        SET    TRANSTATE = '0'
        WHERE  TRADEID = p_TRADEID
        AND    TRANSTATE = '2';
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570008';
            p_retMsg  := '更新卡卡转账记录台账表失败'|| SQLERRM;
            ROLLBACK; RETURN;
    END;

    --更新写卡台账
    BEGIN
        UPDATE TF_CARD_TRADE
        SET    SUCTAG = '1'
        WHERE  TRADEID = p_TRADEID;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S001026101';
            p_retMsg  := 'Unable to Updated card trade';
            ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;
END;  
/
show errors

