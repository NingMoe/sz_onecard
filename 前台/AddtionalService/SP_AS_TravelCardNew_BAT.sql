CREATE OR REPLACE PROCEDURE SP_AS_TravelCardNew_BAT
(
    p_ID                char,  --��¼��ˮ��
    p_cardNo            char,  --����
    p_cardTradeNo       char,  --�����������
    p_asn               char,  --Ӧ�����к�
    p_tradeFee          int,  --�������ܷ�
	p_openTime      char,  --��������
	P_endTime      char,  --����Ч��

    p_operCardNo        char,  --����Ա����    û�����ֵ
    p_terminalNo        char,  --�ն˱���      Ĭ��ֵ 112233445566
    p_oldEndDateNum     char,  --��Ƭ���ϱ��  û�����ֵ
    p_endDateNum        char,  --��Ƭ���ϱ��  û�����ֵ

    p_custName          varchar2,  --����    û�����ֵ
    p_custSex           varchar2,  --�Ա�    û�����ֵ
    p_custBirth         varchar2,  --��������  û�����ֵ
    p_paperType         varchar2,  --֤�����ͱ���  û�����ֵ
    p_paperNo           varchar2,  --֤������  û�����ֵ
    p_custAddr          varchar2,  --��ϵ��ַ  û�����ֵ
    p_custPost          varchar2,  --��������  û�����ֵ
    p_custPhone         varchar2,  --��ϵ�绰  û�����ֵ
    p_custEmail         varchar2,  --�����ʼ�  û�����ֵ
    p_remark            varchar2,  --��ע  û�����ֵ
    p_currOper          char,    --����Ա����
    p_currDept          char,    --�������ź�

	p_usetag      varchar2,  --ǰ��̨���������ʶ(ǰ̨����1����̨����2)

    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_ex                exception;
BEGIN
  BEGIN
  SP_AS_TravelCardNew(p_ID,p_cardNo,p_cardTradeNo,p_asn,p_tradeFee,p_openTime,P_endTime,
            p_operCardNo,p_terminalNo,p_oldEndDateNum,p_endDateNum,
            p_custName,p_custSex,p_custBirth,p_paperType,p_paperNo,p_custAddr,
            p_custPost,p_custPhone,p_custEmail,p_remark,p_currOper,p_currDept,
            p_usetag,p_retCode,p_retMsg);
  IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
  EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK; RETURN;
  END;
  p_retCode := '0000000000'; p_retMsg  := 'OK';
  COMMIT; RETURN;
END;
/
show errors