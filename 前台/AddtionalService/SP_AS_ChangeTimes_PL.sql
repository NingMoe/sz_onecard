CREATE OR REPLACE PROCEDURE SP_AS_ChangeTimes
(
    p_cardNo              char,
    p_gardenTimes         int ,
    p_relaxTimes          int ,

    p_currOper            char,
    p_currDept            char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_ex            exception;
    v_today         date := sysdate;
BEGIN
    IF p_gardenTimes > 0 THEN
        BEGIN
            UPDATE  TF_F_CARDPARKACC_SZ
            SET SPARETIMES      = p_gardenTimes,
                UPDATESTAFFNO   = p_currOper,
                UPDATETIME      = v_today
            WHERE CARDNO = p_cardNo;
            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S00501B004'; p_retMsg  := '更新园林年卡信息失败,' || SQLERRM;
            ROLLBACK; RETURN;
        END;
    END IF;
    
    IF p_relaxTimes > 0 THEN
        BEGIN
            UPDATE  TF_F_CARDXXPARKACC_SZ
            SET SPARETIMES      = p_relaxTimes,
                UPDATESTAFFNO   = p_currOper,
                UPDATETIME      = v_today
            WHERE CARDNO = p_cardNo;
            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S00505B004'; p_retMsg  := '更新休闲年卡信息失败,' || SQLERRM;
            ROLLBACK; RETURN;
        END;
    END IF;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors
