CREATE OR REPLACE PROCEDURE SP_PB_RefundInput
(
	p_ID              char,		--��ֵID
	p_CARDNO          char,		--����
	p_TRADETYPECODE   char,		--��������
	p_TRADEDATE		  char,		--��ֵ����
	p_PURPOSETYPE	  char,		--�Թ���˽��ʶ
	p_BACKMONEY       int,		--���׽��
	P_BACKSLOPE		  char,		--�˿���� 0:100% 1:99.3%
	p_BANKCODE        char,		--���б���
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

	--����ֵ��¼ID�Ƿ����
	select count(*) INTO v_quantity from tq_supply_right where id=p_ID;
	IF v_quantity IS NULL OR v_quantity <= 0 THEN
	p_retCode := 'A00PP01BX1'; 
	p_retMsg  := '��ֵ��¼ID:'||p_ID||'������';
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