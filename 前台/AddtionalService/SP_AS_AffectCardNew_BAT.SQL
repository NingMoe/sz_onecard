/* ------------------------------------
COPYRIGHT (C) 2010-2015 LINKAGE SOFTWARE 
 ALL RIGHTS RESERVED.
<AUTHOR>JIANGBB</AUTHOR>
<CREATEDATE>2017-03-08</CREATEDATE>
<DESCRIPTION>亲子卡开通前台调用存储过程</DESCRIPTION>
------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_AS_AffectCardNew_BAT
(
    p_ID                char,
    p_cardNo            char,
    p_cardTradeNo       char,
    p_asn               char,
    p_tradeFee          int,
	P_discount			int,

    p_operCardNo        char,
    p_terminalNo        char,
    p_oldEndDateNum     char,
    p_endDateNum        char,

	p_ACCOUNTTYPE		CHAR,		--账户类型
	p_PACKAGETPYECODE	CHAR,		--套餐类型
	p_PASSWD			CHAR,		--充值密码

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

	p_passPaperNo		varchar2,		--明文证件号码
	p_passCustName		varchar2,		--明文姓名
	
	p_CITYCODE      CHAR,	 --城市代码

    p_currOper          char,
    p_currDept          char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_TradeID			char(16);		--流水号
	v_CURRENTTIME		date;			--操作时间
    v_XFCARDNO			char(14);		--充值卡号
    v_sMONEY			int;			--充值卡金额
	v_PACKAGEFEE    	int;			--套餐金额
	V_CHARGETYPE		CHAR(2);		--充值类型 01 现金 02 充值卡
    V_EX				EXCEPTION;
BEGIN

	-- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);
	V_CHARGETYPE := '01';

	IF p_PASSWD IS NOT NULL THEN
		BEGIN
		-- 2) Execute procedure SP_PB_XFCommit
			SP_AS_XFCommit (p_CARDNO, p_PASSWD, v_XFCARDNO, v_sMONEY, v_CURRENTTIME,
				v_TradeID, p_currOper, p_currDept, p_retCode, p_retMsg);

		IF p_retCode != '0000000000' THEN RAISE V_EX; END IF;
		EXCEPTION WHEN OTHERS THEN
			ROLLBACK;RETURN;
		END;
		V_CHARGETYPE := '02';
	END IF;

	BEGIN
		SP_AS_AffectCardNew( p_ID              =>  p_ID			,
							p_cardNo          =>  p_cardNo		,
							p_cardTradeNo     =>  p_cardTradeNo	,
							p_asn             =>  p_asn			,
							p_tradeFee        =>  p_tradeFee	,
							P_discount		  =>  P_discount	,
							p_operCardNo      =>  p_operCardNo	,	--操作员卡号
							p_terminalNo      =>  p_terminalNo	,
							p_oldEndDateNum   =>  p_oldEndDateNum,	--上次写卡休闲标识
							p_endDateNum      =>  p_endDateNum	,	--本期开通休闲标识
							p_ACCOUNTTYPE	  =>  p_ACCOUNTTYPE	,
							p_PACKAGETPYECODE =>  p_PACKAGETPYECODE	,
							p_XFCARDNO		  =>  v_XFCARDNO	,
							p_custName        =>  p_custName	,
							p_custSex         =>  p_custSex		,
							p_custBirth       =>  p_custBirth	,
							p_paperType       =>  p_paperType	,
							p_paperNo         =>  p_paperNo		,
							p_custAddr        =>  p_custAddr	,
							p_custPost        =>  p_custPost	,
							p_custPhone       =>  p_custPhone	,
							p_custEmail       =>  p_custEmail	,
							p_remark          =>  p_remark		,
							p_TradeID         =>  v_TradeID   	,
							p_passPaperNo	  =>  p_passPaperNo	,
							p_passCustName	  =>  p_passCustName,
							p_CITYCODE        => p_CITYCODE   ,
							p_currOper        =>  p_currOper	,
							p_currDept        =>  p_currDept	,
							p_retCode         =>  p_retCode		,
							p_retMsg          =>  p_retMsg);
			IF	(P_RETCODE !='0000000000') THEN RAISE V_EX; END IF;
		EXCEPTION WHEN OTHERS THEN
			ROLLBACK;RETURN;
	END;

	p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT;RETURN;
END;

/
SHOW ERRORS