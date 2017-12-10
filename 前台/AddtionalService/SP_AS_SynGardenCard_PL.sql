/* ------------------------------------
Copyright (C) 2012-2013 linkage Software 
 All rights reserved.
<author>jiangbb</author>
<createDate>2012-08-21</createDate>
<description>同步园林存储过程</description>
------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_AS_SynGardenCard
(
    p_cardNo            char,		--卡号
    p_asn               char,		--ASN号
    p_paperType         varchar2,	--证件类型
    p_paperNo           varchar2,	--证件号码
	p_custName          varchar2,	--持卡人姓名
	p_endDate			varchar2,	--园林年卡有效期
    p_Times          	int,		--苏州通库剩余次数
	p_TradeType			char,		--操作类型 1:开通 2:补换卡 3:取消开通
	p_CardTime			date,		--卡操作时间
	p_oldCardNo			char,		--补换卡业务的老卡号
	p_Rsrv1				char,		--预留
	p_dealType			char,		--处理状态
	
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
    -- 2) 生成ID
	SELECT to_char(sysdate,'yyMMddHH24miss')||substr(p_cardNo,-8) INTO v_ID FROM DUAL;
	--插入同步园林数据表
    BEGIN
		INSERT INTO TF_B_GARDENCARD
			(ID,CARDNO,ASN,PAPERTYPE,PAPERNO,CUSTNAME,ENDDATE,
			TIMES,TRADETYPE,CARDTIME,OLDCARDNO,RSRV1,DEALTYPE)
		VALUES(v_ID,p_cardNo,p_asn,p_paperType,p_paperNo,p_custName,p_endDate
		,p_Times,p_TradeType,p_CardTime,p_oldCardNo,p_Rsrv1,p_dealType);
		IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
					EXCEPTION
							  WHEN OTHERS THEN
								p_retCode :='S00601B008'; p_retMsg :='新增同步园林数据表失败';
								RETURN; ROLLBACK;
	END;

    p_retCode := '0000000000'; p_retMsg := '';
    RETURN;
END;
/

show errors