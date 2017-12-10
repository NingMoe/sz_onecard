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
        p_retCode := 'A007P05B01'; p_retMsg := '�ӳ�ֵ���ۿ�̨���в�ѯ��������ʧ��,' || SQLERRM;
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
        p_retCode := 'S007P05B04'; p_retMsg := '�����ۿ�����̨��ʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 5) Update the old sale trade log
    BEGIN
        UPDATE TF_XFC_SELL SET CANCELTAG = '1', CANCELTRADEID = v_seqNo WHERE TRADEID = p_batchNo;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P05B05'; p_retMsg := '����ԭʼ�ۿ�̨����Ϣʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 6) Log the trade fee table
    BEGIN
        INSERT INTO TF_XFC_SELLFEE (TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO, MONEY, STAFFNO,OPERATETIME)
        VALUES(v_seqNo, 'I0', v_fromCardNo, v_toCardNo, -v_money, p_currOper, v_today);

    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S007P05B06'; p_retMsg := '�����ۿ������ֽ�̨��ʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    
    -- ����Ӫҵ���ֿ�Ԥ������ݱ�֤���޸Ŀ��쿨��ȣ�add by liuhe 20111230
   BEGIN
		 SP_PB_DEPTBALFEEROLLBACK(v_seqNo, p_batchNo, 
					'3' ,--1Ԥ����,2��֤��,3Ԥ����ͱ�֤��
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
