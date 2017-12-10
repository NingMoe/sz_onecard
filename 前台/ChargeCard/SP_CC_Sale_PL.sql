CREATE OR REPLACE PROCEDURE SP_CC_Sale
(
    p_fromCardNo char,
    p_toCardNo   char,

	p_remark     varchar2,
	
    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message

)
AS
    v_today      date     := sysdate;
    v_quantity   int      ;
    v_seqNo      char(16) ;
    v_totalValue int      ;
    v_ex         exception;
BEGIN

    SP_GetSeq(seq => v_seqNo);

    BEGIN
        SP_CC_Sale_ChargeCard(p_fromCardNo, p_toCardNo,
            v_totalValue, v_quantity, v_today, v_seqNo,
            p_currOper, p_currDept, p_retCode, p_retMsg);

        IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK; RETURN;
    END;

    BEGIN
        INSERT INTO TF_XFC_SELL
            (TRADEID, TRADETYPECODE, AMOUNT, STARTCARDNO, ENDCARDNO,
                MONEY , STAFFNO  , OPERATETIME, REMARK)
        VALUES(v_seqNo , '80'    , v_quantity, p_fromCardNo, p_toCardNo,
            v_totalValue, p_currOper, v_today,  p_remark);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P04B03'; p_retMsg  := '记录充值卡售卡操作台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    --4) Log the trade fee
    BEGIN
        INSERT INTO TF_XFC_SELLFEE (TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO, MONEY, STAFFNO,OPERATETIME)
        VALUES(v_seqNo, '80', p_fromCardNo, p_toCardNo, v_totalValue, p_currOper, v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P04B04'; p_retMsg  := '记录售卡现金台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 代理营业厅抵扣预付款，根据保证金修改可领卡额度，add by yin 20120104
	 BEGIN
	  SP_PB_DEPTBALFEE(v_seqNo, '3' ,--1预付款,2保证金,3预付款和保证金
					 v_totalValue,
	                 v_today,p_currOper,p_currDept,p_retCode,p_retMsg);
     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors
