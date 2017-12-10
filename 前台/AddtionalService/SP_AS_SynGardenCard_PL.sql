/* ------------------------------------
Copyright (C) 2012-2013 linkage Software 
 All rights reserved.
<author>jiangbb</author>
<createDate>2012-08-21</createDate>
<description>ͬ��԰�ִ洢����</description>
------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_AS_SynGardenCard
(
    p_cardNo            char,		--����
    p_asn               char,		--ASN��
    p_paperType         varchar2,	--֤������
    p_paperNo           varchar2,	--֤������
	p_custName          varchar2,	--�ֿ�������
	p_endDate			varchar2,	--԰���꿨��Ч��
    p_Times          	int,		--����ͨ��ʣ�����
	p_TradeType			char,		--�������� 1:��ͨ 2:������ 3:ȡ����ͨ
	p_CardTime			date,		--������ʱ��
	p_oldCardNo			char,		--������ҵ����Ͽ���
	p_Rsrv1				char,		--Ԥ��
	p_dealType			char,		--����״̬
	
	p_currOper          char,
    p_currDept          char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_ID		char(20);
	v_paperNo	char;
	v_ex		EXCEPTION;
BEGIN
    -- 2) ����ID
	SELECT to_char(sysdate,'yyMMddHH24miss')||substr(p_cardNo,-8) INTO v_ID FROM DUAL;
	--����ͬ��԰�����ݱ�
    BEGIN
		INSERT INTO TF_B_GARDENCARD
			(ID,CARDNO,ASN,PAPERTYPE,PAPERNO,CUSTNAME,ENDDATE,
			TIMES,TRADETYPE,CARDTIME,OLDCARDNO,RSRV1,DEALTYPE)
		VALUES(v_ID,p_cardNo,p_asn,p_paperType,p_paperNo,p_custName,p_endDate
		,p_Times,p_TradeType,p_CardTime,p_oldCardNo,p_Rsrv1,p_dealType);
		IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
					EXCEPTION
							  WHEN OTHERS THEN
								p_retCode :='S00601B008'; p_retMsg :='����ͬ��԰�����ݱ�ʧ��';
								RETURN; ROLLBACK;
	END;

    p_retCode := '0000000000'; p_retMsg := '';
    RETURN;
END;
/

show errors