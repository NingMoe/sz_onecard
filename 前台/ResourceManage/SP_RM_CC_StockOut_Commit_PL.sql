--��ֵ������ create by Yin
CREATE OR REPLACE PROCEDURE SP_RM_CC_StockOut_Commit
(
    p_fromCardNo char, --��ʼ����
    p_toCardNo   char, --��������
    p_assignDepartNo char, --���ò���
    
    p_getcardorderid char, --���õ���
    p_alreadygetnum int,  --����������
    p_getStaffNo    char, --����Ա��
    
    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    V_IsDepaBal     int;
    V_USABLEVALUE   int;
    V_DBALUNITNO    varchar(8);
    v_seqNo  char(16);
    v_ex         exception;
BEGIN

    SP_GetSeq(seq => v_seqNo);

    BEGIN
        SP_RM_StockOut_ChargeCard(p_fromCardNo, p_toCardNo,p_assignDepartNo,
             v_seqNo,p_getcardorderid,p_alreadygetnum,p_getStaffNo,
            p_currOper, p_currDept, p_retCode, p_retMsg);
        IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK; RETURN;
    END;
    
    p_retCode := '0000000000'; p_retMsg  := '';
END;
/
show errors
