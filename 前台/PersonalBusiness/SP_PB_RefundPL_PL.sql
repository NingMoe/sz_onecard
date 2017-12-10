CREATE OR REPLACE PROCEDURE SP_PB_RefundPL
(
		p_currOper   char,  -- Current Operator
    p_currDept   char,  -- Current Operator's Department
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message
)
AS
    v_TradeID char(16);
    v_CURRENTTIME date := sysdate;
    v_ex          exception;
    v_bankcode    char(4);
    v_quantity    int;
BEGIN

--判断是否有退款记录需要处理

SELECT COUNT(*) INTO v_quantity
    FROM TMP_COMMON;
    
    IF v_quantity IS NULL OR v_quantity <= 0 THEN
        p_retCode := 'A00PP01BX1'; p_retMsg  := '没有任何退款记录数据需要处理';
        RETURN;
    END IF;

--检查卡号是否存在
    BEGIN
        FOR v_cur in (SELECT f1, f2, f3, f4, f5, f6, f7,f8,f9 FROM TMP_COMMON)
        LOOP
        --检查充值记录ID是否存在
        select count(*) INTO v_quantity from tq_supply_right where id=v_cur.f1;
        IF v_quantity IS NULL OR v_quantity <= 0 THEN
        p_retCode := 'A00PP01BX1'; 
        p_retMsg  := '充值记录ID:'||v_cur.f1||'不存在';
        rollback;
        RETURN;
        END IF;
            SP_AccCheck(v_cur.f2, p_currOper, p_currDept, p_retCode, p_retMsg);
            IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
             -- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);
    
    select t.bankcode into v_bankcode from td_m_bank t where t.bank=v_cur.f5;

     
    -- 3) Log the refund
    BEGIN
        INSERT INTO TF_B_REFUNDPL
              (TRADEID,ID,TRADETYPECODE,CARDNO,BANKCODE,BANKACCNO,BACKMONEY,CUSTNAME,
              OPERATESTAFFNO,OPERATETIME,REMARK,STATE,tradedate,PURPOSETYPE)
         VALUES
               (v_TradeID,v_cur.f1,'91',v_cur.f2,v_bankcode,v_cur.f6,v_cur.f4,
               v_cur.f7,p_currOper,v_CURRENTTIME,v_cur.f8,'1',v_cur.f3,v_cur.f9);

    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001014102';
              p_retMsg  := 'Fail to log the refund' || SQLERRM;
              ROLLBACK; RETURN;
    END;

        END LOOP;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK; RETURN;
    END;

  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
END;
/
show errors