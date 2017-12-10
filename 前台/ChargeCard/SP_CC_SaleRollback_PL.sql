CREATE OR REPLACE PROCEDURE SP_CC_SaleRollback
(
    p_batchNo   char,
    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today      date    := sysdate;
    v_seqNo      char(16);
    v_amount     int     ;
    v_money      INT     ;
    v_fromCardNo CHAR(14);
    v_toCardNo   CHAR(14);
    v_ex         exception;
BEGIN
    -- 1) Get the Card No of Voucher
    BEGIN
        SELECT STARTCARDNO,  ENDCARDNO
        INTO   v_fromCardNo, v_toCardNo
        FROM   TF_XFC_SELL WHERE TRADEID = p_batchNo;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'A007P05B01'; p_retMsg := '从充值卡售卡台帐中查询起讫卡号失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    SP_GetSeq(seq => v_seqNo);

    BEGIN
        SP_CC_SaleRollback_ChargeCard(p_batchNo,
            v_today, v_seqNo, v_amount, v_money, v_fromCardNo, v_toCardNo,
            p_currOper, p_currDept, p_retCode, p_retMsg);

        IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK; RETURN;
    END;

    BEGIN
        INSERT INTO TF_XFC_SELL
            (TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO,
                AMOUNT , MONEY , STAFFNO  , OPERATETIME, CANCELTRADEID)
        VALUES(v_seqNo , 'I0'         , v_fromCardNo, v_toCardNo,
            v_amount, v_money, p_currOper, v_today    , p_batchNo );
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P05B04'; p_retMsg := '新增售卡返销台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 5) Update the old sale trade log
    BEGIN
        UPDATE TF_XFC_SELL SET CANCELTAG = '1', CANCELTRADEID = v_seqNo WHERE TRADEID = p_batchNo;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P05B05'; p_retMsg := '更新原始售卡台帐信息失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 6) Log the trade fee table
    BEGIN
        INSERT INTO TF_XFC_SELLFEE (TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO, MONEY, STAFFNO,OPERATETIME)
        VALUES(v_seqNo, 'I0', v_fromCardNo, v_toCardNo, -v_money, p_currOper, v_today);

    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P05B06'; p_retMsg := '新增售卡返销现金台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    
    -- 代理营业厅抵扣预付款，根据保证金修改可领卡额度，add by liuhe 20111230
   BEGIN
		 SP_PB_DEPTBALFEEROLLBACK(v_seqNo, p_batchNo, 
					'3' ,--1预付款,2保证金,3预付款和保证金
					- v_money,p_currOper,p_currDept,p_retCode,p_retMsg);
		                 
     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;
    
    p_retCode := '0000000000'; p_retMsg := '';
    COMMIT; RETURN;
END;
/

show errors
