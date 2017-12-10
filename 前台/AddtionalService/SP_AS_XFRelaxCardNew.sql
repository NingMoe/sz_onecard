/* ------------------------------------
Copyright (C) 2015-2016 linkage Software 
 All rights reserved.
<author>gl</author>
<createDate>2015-05-05</createDate>
<description>��ֵ�뷽ʽ��ͨ�����꿨</description>
------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_AS_XFRelaxCardNew
(
    p_ID                char,
    p_cardNo            char,
    p_cardTradeNo       char,
    p_asn               char,
    p_tradeFee          int,

    p_operCardNo        char,
    p_terminalNo        char,
    p_oldEndDateNum     char,
    p_endDateNum        char,

    p_ACCOUNTTYPE    CHAR,    --�˻�����
    p_PACKAGETPYECODE  CHAR,    --�ײ�����
    p_PASSWD           char,    ---��ֵ����
    p_custName          varchar2,
    p_custSex           varchar2,
    p_custBirth         varchar2,
    p_paperType         varchar2,
    p_paperNo           varchar2,
    p_custAddr          varchar2,
    p_custPost          varchar2,
    p_custPhone         varchar2,
    p_custEmail         varchar2,
    p_remark            varchar2,

    p_passPaperNo    varchar2,    --����֤������
    p_passCustName    varchar2,    --��������

    p_currOper          char,
    p_currDept          char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_TradeID char(16);
	v_CURRENTTIME   date;
    v_XFCARDNO      char(14);
    v_sMONEY        int;
	v_PACKAGEFEE    int;
    V_EX        EXCEPTION;
BEGIN
    -- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);

    -- 2) Execute procedure SP_PB_XFCommit
	SP_PB_XFCommit (p_CARDNO, p_PASSWD, v_XFCARDNO, v_sMONEY, v_CURRENTTIME,
		 v_TradeID, p_currOper, p_currDept, p_retCode, p_retMsg);

    IF p_retCode != '0000000000' THEN
		p_retCode := '0000000001';
		p_retMsg  := '��ѯ��ֵ����Ϣ����.';
        ROLLBACK; RETURN;
    END IF;
		
		--3����ѯ�ײͷ���
    SELECT t.packagefee INTO v_PACKAGEFEE from TD_M_PACKAGETYPE t WHERE t.packagetypecode= p_PACKAGETPYECODE;
    
		IF p_PACKAGETPYECODE!=v_sMONEY THEN
		p_retCode := '0000000002';
		p_retMsg  := '��ֵ�������ײͽ�һ��.';
		   ROLLBACK; RETURN;
		END IF;

  BEGIN
    SP_AS_RelaxCardNew( p_ID              =>  p_ID      ,
              p_cardNo          =>  p_cardNo    ,
              p_cardTradeNo     =>  p_cardTradeNo  ,
              p_asn             =>  p_asn      ,
              p_tradeFee        =>  p_tradeFee  ,
              p_operCardNo      =>  p_operCardNo  ,  --����Ա����
              p_terminalNo      =>  p_terminalNo  ,
              p_oldEndDateNum   =>  p_oldEndDateNum,  --�ϴ�д�����б�ʶ
              p_endDateNum      =>  p_endDateNum  ,  --���ڿ�ͨ���б�ʶ
              p_ACCOUNTTYPE    =>  p_ACCOUNTTYPE  ,
              p_PACKAGETPYECODE =>  p_PACKAGETPYECODE  ,
              p_custName        =>  p_custName  ,
              p_custSex         =>  p_custSex    ,
              p_custBirth       =>  p_custBirth  ,
              p_paperType       =>  p_paperType  ,
              p_paperNo         =>  p_paperNo    ,
              p_custAddr        =>  p_custAddr  ,
              p_custPost        =>  p_custPost  ,
              p_custPhone       =>  p_custPhone  ,
              p_custEmail       =>  p_custEmail  ,
              p_remark          =>  p_remark    ,
              p_passPaperNo    =>  p_passPaperNo  ,
              p_passCustName    =>  p_passCustName,
              p_currOper        =>  p_currOper  ,
              p_currDept        =>  p_currDept  ,
              p_retCode         =>  p_retCode    ,
              p_retMsg          =>  p_retMsg);
      IF  (P_RETCODE !='0000000000') THEN RAISE V_EX; END IF;
		EXCEPTION WHEN OTHERS THEN
      ROLLBACK;RETURN;
  END;

  p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT;RETURN;
END;
