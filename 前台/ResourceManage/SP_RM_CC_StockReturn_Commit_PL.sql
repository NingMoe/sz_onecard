
--��ֵ���˿� 
--create by: Yin 

CREATE OR REPLACE PROCEDURE SP_RM_CC_StockReturn_Commit
(
    p_fromCardNo char, --��ʼ����
    p_toCardNo   char, --��������
    p_returnReason varchar2, --�˿�ԭ��
    p_seqNo     out  char,
    p_currOper  char, 
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_seqNo  char(16);       --��ˮ��
    v_ex         exception;
BEGIN

    SP_GetSeq(seq => v_seqNo);

    BEGIN
        SP_RM_StockReturn_ChargeCard(p_fromCardNo, p_toCardNo,
             p_returnReason,v_seqNo,p_currOper, p_currDept, p_retCode, p_retMsg);
        IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK; RETURN;
    END;
    p_seqNo := v_seqNo;
    p_retCode := '0000000000'; p_retMsg  := '';
END;
/
show errors
