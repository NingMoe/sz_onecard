CREATE OR REPLACE PROCEDURE SP_GC_AccLock
(
    p_lockType char, -- '0' Unlock '1' Lock
    p_cardNo   char,
    p_currOper char,
    p_currDept char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_newTag  char(1);
    v_oldTag  char(1);
    v_opType  char(2);
    v_today   date := sysdate;
    v_seqNo   char(16);
    v_ex      exception;
BEGIN

    -- 1) Check the lock type
    IF p_lockType = '0' THEN -- Unlock    
        v_newTag := '1';
        v_oldTag := '2';
        v_opType := '27';
    ELSIF p_lockType = '1' THEN-- Lock    
        v_newTag := '2';
        v_oldTag := '1';
        v_opType := '26';
    ELSE
        p_retCode := 'A004P09B01'; p_retMsg  := '不支持的锁定类型';
        RETURN;
    END IF;


    -- 2) Lock or unlock
    BEGIN
        UPDATE TF_F_CARDOFFERACC SET USETAG = v_newTag
        WHERE  CARDNO = p_cardNo  AND USETAG = v_oldTag;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P09B02'; p_retMsg  := '更新企服卡帐户状态失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    SP_GetSeq(seq => v_seqNo);

    -- 3) Log the operation
    BEGIN
        INSERT INTO TF_B_TRADE
               (TRADEID, TRADETYPECODE, CARDNO ,
                OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
        VALUES (v_seqNo , v_opType      , p_cardNo,
                p_currOper, p_currDept  , v_today  );
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P09B03'; p_retMsg  := '新增企服卡锁定解锁操作台帐失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
                
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors
