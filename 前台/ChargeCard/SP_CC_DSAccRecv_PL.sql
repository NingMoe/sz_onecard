CREATE OR REPLACE PROCEDURE SP_CC_DSAccRecv
(
    p_sessionId  varchar2, -- Session ID
    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today        date := sysdate;
    v_count        int  := 0;
    v_quantity     int  ;
    v_ex       exception;
BEGIN

    SELECT COUNT(*) INTO v_quantity FROM TMP_CC_AccRecvList
    WHERE   SessionId = p_sessionId;

    BEGIN
        FOR v_cursor IN (
            SELECT a.BatchNo,  a.RecvDate payTime
            FROM   TMP_CC_AccRecvList a
            WHERE  a.SessionId = p_sessionId
        )         
        LOOP
            UPDATE  TF_XFC_BATCHSELL  t 
            SET	    t.PAYTAG  = '1',
                    t.PAYTIME = to_date(v_cursor.payTime, 'YYYYMMDD') 
            WHERE   t.TRADEID = v_cursor.BatchNo
            AND     t.PAYTAG  = '0';
                
            v_count := v_count + SQL%ROWCOUNT;
        END LOOP; 
                
        IF  v_count != v_quantity THEN RAISE v_ex; END IF;

    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P03B01'; p_retMsg := '更新充值卡直销到账信息失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg := '';
    COMMIT; RETURN;
END;
/

show errors
