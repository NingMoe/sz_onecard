CREATE OR REPLACE PROCEDURE SP_CC_DirectSale
(
    p_fromCardNo char,
    p_toCardNo   char,
    p_custName   varchar2,
    p_payMode    char,  -- 0 Transfer 1 Cash 2 报销
    p_accRecv    char,  -- 1 Received 0 Receivable
    p_recvDate   char,
    p_remark     varchar2,
    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_totalValue int      ;
    v_quantity   int      ;
    v_today      date     ;
    v_ex         exception;
    v_seqNo      char(16) ;
BEGIN

    BEGIN
        SP_CC_DirectSale_ChargeCard(p_fromCardNo, p_toCardNo,
            v_totalValue, v_quantity, v_today,
            p_currOper, p_currDept, p_retCode, p_retMsg);

        IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK; RETURN;
    END;


    SP_GetSeq(seq => v_seqNo);

    BEGIN
        INSERT INTO TF_XFC_BATCHSELL(TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO,
            CARDVALUE, AMOUNT, TOTALMONEY, CUSTNAME, PAYTYPE, PAYTAG,
            PAYTIME,  STAFFNO, OPERATETIME, REMARK)
        VALUES(v_seqNo, '84', p_fromCardNo, p_toCardNo,
            v_totalValue/v_quantity, v_quantity, v_totalValue, p_custName, p_payMode, p_accRecv,
            to_date(p_recvDate, 'YYYYMMDD'),  p_currOper, v_today, p_remark);
    EXCEPTION WHEN OTHERS THEN
          p_retCode := 'S007P02B02'; p_retMsg := '新增批量直销操作台帐失败,' || SQLERRM;
          ROLLBACK; RETURN;
    END;

    IF p_payMode = '1' THEN
        --4) Log the trade fee when paid by cash
        BEGIN
            INSERT INTO TF_XFC_SELLFEE(TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO, MONEY, STAFFNO,OPERATETIME)
            VALUES(v_seqNo, '84', p_fromCardNo, p_toCardNo, v_totalValue, p_currOper, v_today);
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S007P02B03'; p_retMsg  := '新增批量直销现金台帐失败,' || SQLERRM;
            ROLLBACK; RETURN;
        END;
    END IF;


    p_retCode := '0000000000'; p_retMsg := '';
    COMMIT; RETURN;
END;
/

show errors
