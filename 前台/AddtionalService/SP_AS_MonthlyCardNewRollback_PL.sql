CREATE OR REPLACE PROCEDURE SP_AS_MonthlyCardNewRollback
(
    p_ID                  char,
    p_cardNo              char,
    p_cardTradeNo         char,

    p_cardMoney           int,

    p_cancelTradeId       char,

    p_terminalNo          char,

    p_currCardNo          char,
    p_currOper            char,
    p_currDept            char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_ex            exception;
    v_seqNo         char(16);
    v_deposit             int;
    v_cardCost            int;
    v_otherFee            int;

BEGIN
	BEGIN
	    SELECT CARDDEPOSITFEE, CARDSERVFEE, OTHERFEE
	    INTO   v_deposit     , v_cardCost , v_otherFee
	    FROM   TF_B_TRADEFEE
	    WHERE  TRADEID = p_cancelTradeId;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00514B000'; p_retMsg  := '��ѯ������Ϣʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
	
    
    -- 1) Execute procedure SP_PB_SaleCard
    SP_PB_SaleCardRollback
    (
        p_ID           , p_cardNo  , p_cardTradeNo, p_cardMoney , v_deposit   , v_cardCost, 
        p_cancelTradeId, 0         , v_otherFee   , p_terminalNo, p_currCardNo, v_seqNo   , 
        p_currOper     , p_currDept, p_retCode    , p_retMsg
    );
    IF p_retCode != '0000000000' THEN
        ROLLBACK; RETURN;
    END IF;

    -- 2) delete a row of monthly info
    BEGIN
        DELETE FROM TF_F_CARDCOUNTACC WHERE CARDNO = p_cardNo;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00514B001'; p_retMsg  := 'ɾ����Ʊ������ʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 3) Log card change
    BEGIN
        UPDATE TF_CARD_TRADE
        SET    strFlag = '02FF'
        WHERE  TRADEID = v_seqNo;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00514B002'; p_retMsg  := '������Ʊ���ۿ���Ƭ����̨��ʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 4) Setup the relation between cards and features.
    BEGIN
        DELETE FROM TF_F_CARDUSEAREA WHERE CARDNO = p_cardNo;
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00514B003'; p_retMsg  := 'ɾ����Ƭҵ���ܹ�����ϵʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

	------ ����Ӫҵ���ֿ�Ԥ���add by liuhe 20120104
	BEGIN

		 SP_PB_DEPTBALFEEROLLBACK(V_SEQNO, P_CANCELTRADEID,
					'3' ,--1Ԥ����,2��֤��,3Ԥ����ͱ�֤��
					 - v_deposit - v_cardCost - v_otherFee,
					 P_CURROPER,P_CURRDEPT,P_RETCODE,P_RETMSG);
					 
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
