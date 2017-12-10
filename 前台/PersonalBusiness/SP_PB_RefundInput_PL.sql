CREATE OR REPLACE PROCEDURE SP_PB_RefundInput
(
	p_ID              char,		--充值ID
	p_CARDNO          char,		--卡号
	p_TRADETYPECODE   char,		--交易类型
	p_TRADEDATE		  char,		--充值日期
	p_PURPOSETYPE	  char,		--对公对私标识
	p_BACKMONEY       int,		--交易金额
	P_BACKSLOPE		  char,		--退款比例 0:100% 1:99.3%
	p_BANKCODE        char,		--银行编码
	p_BANKACCNO       varchar2,
	p_CUSTNAME        varchar2,
	p_STATE			  char,
	p_TRADEID         out char, -- Return Trade Id
	p_currOper   char,  -- Current Operator
    p_currDept   char,  -- Current Operator's Department
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message
)
AS
    v_TradeID char(16);
    v_CURRENTTIME date := sysdate;
    v_ex          exception;
    v_quantity    int;
BEGIN

	--检查充值记录ID是否存在
	select count(*) INTO v_quantity from tq_supply_right where id=p_ID;
	IF v_quantity IS NULL OR v_quantity <= 0 THEN
	p_retCode := 'A00PP01BX1'; 
	p_retMsg  := '充值记录ID:'||p_ID||'不存在';
	rollback;
	RETURN;
	END IF;
	BEGIN
		SP_AccCheck(p_CARDNO, p_currOper, p_currDept, p_retCode, p_retMsg);
		IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
		EXCEPTION WHEN OTHERS THEN
		ROLLBACK;RETURN;
	END;
		 -- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);

    -- 3) Log the refund
    BEGIN
        INSERT INTO TF_B_REFUNDPL
              (TRADEID,ID,TRADETYPECODE,CARDNO,BANKCODE,BANKACCNO,BACKMONEY,BACKSLOPE,FACTMONEY,
              CUSTNAME,OPERATESTAFFNO,OPERATETIME,REMARK,STATE,tradedate,PURPOSETYPE)
         VALUES
               (v_TradeID,p_ID,p_TRADETYPECODE,p_CARDNO,p_BANKCODE,p_BANKACCNO,p_BACKMONEY,decode(P_BACKSLOPE,'0',1,'1',0.993),p_BACKMONEY*to_number(decode(P_BACKSLOPE,'0',1,'1',0.993)),
               p_CUSTNAME,p_currOper,v_CURRENTTIME,'',p_STATE,p_TRADEDATE,p_PURPOSETYPE);

    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001014102';
              p_retMsg  := 'Fail to log the refund' || SQLERRM;
              ROLLBACK; RETURN;
    END;

  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
END;
/
show errors