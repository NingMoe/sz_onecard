/**************************************/
--UPDATE:jiangbb 2015-12-17
--CONTENTS:增加库存已存在的卡片,再次开通休闲功能判断
/**************************************/
CREATE OR REPLACE PROCEDURE SP_WX_RELAXCARDOPEN
(
	P_CARDNO 	 CHAR, -- FROM CARD NO. 
	P_ASN		 CHAR, -- ASN号
	P_PACKAGETYPE CHAR,
	P_CUSTNAME	 CHAR, -- custname
	P_PAPERTYPE  CHAR,
	P_PAPERNO	 VARCHAR,
	P_ENCUSTNAME CHAR,
	P_ENPAPERNO	 VARCHAR,
	P_CITYCODE   CHAR, --城市代码
    P_CURROPER   CHAR, -- CURRENT OPERATOR 
    P_CURRDEPT   CHAR, -- CURRETN OPERATOR'S DEPARTMENT 
    P_RETCODE OUT CHAR, -- RETURN CODE 
    P_RETMSG  OUT VARCHAR2
)
-- RETURN MESSAGE
AS
	V_CARDNO   		CHAR(16);
	V_TODAY    		DATE := SYSDATE;
	V_SEQNO    		CHAR(16);
	V_SALETIME 		DATE;
	V_SALETRADEID	CHAR(16);
	V_RELAXTRADEID	CHAR(16);
	V_ROWS			INT;				--卡片库存数量
	V_PACKAGEFEE	INT;				--套餐金额
    v_ID				char(18); 		--记录流水号
	V_ENDDATE			CHAR(30);			--当期休闲年卡结束日期
	V_USABLETIMES		CHAR(30);			--当期休闲年卡开通次数
	V_XTIMES			CHAR(3);			--16进制次数
	V_ENDDATENUM		CHAR(12);			--本期开通休闲标识
	
	V_CARDTYPECODE CHAR(2);--卡类型
	V_CHIPTYPECODE CHAR(2);--卡面类型
BEGIN
  
   BEGIN
   --查询相应城市代码对应的卡类型、卡面类型
    SELECT T.CARDTYPECODE,T.CHIPTYPECODE INTO V_CARDTYPECODE,V_CHIPTYPECODE FROM TD_M_CITYPARAM T WHERE T.CITYCODE=P_CITYCODE AND T.USETAG='1';
     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        P_RETCODE := 'S001P00000';
        P_RETMSG  := '未找到相关的城市配置信息表';
        ROLLBACK;RETURN;
  END;
  
	BEGIN
		SELECT COUNT(1) INTO V_ROWS FROM TL_R_ICUSER T WHERE T.CARDNO = P_CARDNO;
		EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
	END;
	
	IF V_ROWS = 0 THEN
		--无锡卡入库
		BEGIN
			SP_UC_IL_STOCKIN(	P_CARDNO 	 =>	P_CARDNO	,
								P_ASN		 => P_ASN		,
								P_COSTYPE    =>	'01'		, --COSTYPE 01
								P_UNITPRICE  => 0			,
								P_FACETYPE   =>	'01'		,
								P_CARDTYPE   => V_CARDTYPECODE, --无锡卡默认卡类型为91，卡面类型为01
								P_CHIPTYPE   => V_CHIPTYPECODE, --芯片类型
								P_PRODUCER   => '01'		, --生产厂商
								P_APPVERSION =>	'01'		, --应用版本号 01
								P_EFFDATE    => '20010101'	, --起始有效期
								P_EXPDATE    =>	'20501231'	, --结束有效期
								P_CURROPER   => P_CURROPER	,
								P_CURRDEPT   => P_CURRDEPT	,
								P_RETCODE    => P_RETCODE	,
								P_RETMSG     => P_RETMSG);
			IF	(P_RETCODE !='0000000000') THEN
			ROLLBACK;RETURN;
			END IF;
		END;
		
		SP_GetSeq(seq => V_SALETRADEID);
		--无锡卡售卡
		BEGIN
			SP_PB_SALECARD(		p_ID	          => V_CARDTYPECODE||V_SALETRADEID,
								p_CARDNO	      => P_CARDNO	,
								p_DEPOSIT	      => 0			,
								p_CARDCOST	      => 0			,
								p_OTHERFEE		  => 0			,
								p_CARDTRADENO	  => '0000'		,
								p_CARDTYPECODE	  => V_CARDTYPECODE	,
								p_CARDMONEY	      => 0			,
								p_SELLCHANNELCODE => '01'		,
								p_SERSTAKETAG	  => '0'		,
								p_TRADETYPECODE	  => '01'		,
								p_CUSTNAME	      => P_CUSTNAME	,
								p_CUSTSEX	      => '1'		,
								p_CUSTBIRTH	      => ''			,
								p_PAPERTYPECODE	  => P_PAPERTYPE,
								p_PAPERNO         => p_PAPERNO	,
								p_CUSTADDR	      => ''			,
								p_CUSTPOST	      => ''			,
								p_CUSTPHONE	      => ''			,
								p_CUSTEMAIL       => ''			,
								p_REMARK	      => ''			,
								p_CUSTRECTYPECODE => '1'		,	--记名
								p_TERMNO		  => '112233445566',
								p_OPERCARDNO	  => ''			,
								p_CURRENTTIME	  => V_SALETIME	,
								p_TRADEID    	  => V_SALETRADEID,
								p_currOper	      => P_CURROPER	,
								p_currDept	      => p_currDept	,
								p_retCode	      => p_retCode	,
								p_retMsg     	  => p_retMsg);

			IF	(P_RETCODE !='0000000000') THEN
			ROLLBACK;RETURN;
			END IF;
		END;
	END IF;
	
	SP_GetSeq(seq => V_RELAXTRADEID);
	--无锡卡休闲开通
	
	--获取当期结束日期
	BEGIN
		SELECT TAGVALUE INTO V_ENDDATE FROM TD_M_TAG WHERE  TAGCODE = 'XXPARK_ENDDATE' AND USETAG = '1';
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			p_retCode := 'S00505B001';
			p_retMsg  := '缺少系统参数-惠民休闲年卡结束日期' || SQLERRM;
			ROLLBACK; RETURN;
	END;
	
	--当期休闲年卡开通次数
	BEGIN
		SELECT TAGVALUE INTO V_USABLETIMES FROM  TD_M_TAG WHERE TAGCODE = 'XXPARK_NUM' AND USETAG = '1';
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			p_retCode := 'S00505B002';
			p_retMsg  := '缺少系统参数-惠民休闲年卡总共次数' || SQLERRM;
			ROLLBACK; RETURN;
	END;
	
	--获取套餐对应金额
	BEGIN
		SELECT PACKAGEFEE INTO V_PACKAGEFEE FROM TD_M_PACKAGETYPE WHERE PACKAGETYPECODE = P_PACKAGETYPE AND USETAG = '1';
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			p_retCode := 'S00509B023';
			p_retMsg  := '缺少系统参数-惠民休闲年卡套餐金额' || SQLERRM;
			ROLLBACK; RETURN;
	END;
	
	--开通次数转16进制
	SELECT TO_CHAR(V_USABLETIMES,'XX') INTO V_XTIMES FROM DUAL;
	--本期开通休闲标识
	V_ENDDATENUM := SUBSTR(V_ENDDATE,1,8) || P_PACKAGETYPE || SUBSTR(V_XTIMES,-2);
	--获取记录流水号
	v_ID := TO_CHAR(SYSDATE, 'MMDDHH24MISS') || SUBSTR(P_CARDNO, -8);

	BEGIN
		SP_AS_RelaxCardNew( p_ID              =>  V_CARDTYPECODE||V_RELAXTRADEID,
							p_cardNo          =>  P_CARDNO		,
							p_cardTradeNo     =>  '0000'		,
							p_asn             =>  P_ASN			,
							p_tradeFee        =>  V_PACKAGEFEE	,
							p_operCardNo      =>  ''			,	--操作员卡号
							p_terminalNo      =>  '112233445566',	--默认
							p_oldEndDateNum   =>  'FFFFFFFFFFFF',	--上次写卡休闲标识
							p_endDateNum      =>  V_ENDDATENUM	,	--本期开通休闲标识
							p_ACCOUNTTYPE	  =>  '1'			,
							p_PACKAGETPYECODE =>  P_PACKAGETYPE	,
							p_XFCARDNO		  =>  ''			,
							p_custName        =>  P_ENCUSTNAME	,
							p_custSex         =>  '1'			,
							p_custBirth       =>  ''			,
							p_paperType       =>  P_PAPERTYPE	,
							p_paperNo         =>  P_ENPAPERNO	,
							p_custAddr        =>  ''			,
							p_custPost        =>  ''			,
							p_custPhone       =>  ''			,
							p_custEmail       =>  ''			,
							p_remark          =>  ''			,
							p_TradeID         =>  V_RELAXTRADEID,
							p_passPaperNo	  =>  P_PAPERNO		,
							p_passCustName	  =>  p_custName	,
							p_CITYCODE        =>  P_CITYCODE	,
							p_currOper        =>  p_currOper	,
							p_currDept        =>  p_currDept	,
							p_retCode         =>  p_retCode		,
							p_retMsg          =>  p_retMsg);
		IF	(P_RETCODE !='0000000000') THEN
		ROLLBACK;RETURN;
		END IF;
	END;
	
	IF P_RETCODE = '0000000000' THEN
	P_RETMSG := '';
	COMMIT; RETURN;
	END IF;
	
END;

/
SHOW ERRORS

