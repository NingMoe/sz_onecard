CREATE OR REPLACE PROCEDURE SP_WX_NEWCARDSELL
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
	--鏃犻敗鍗″敭鍗?
	BEGIN
		SP_PB_SALECARD(		p_ID	          => V_CARDTYPECODE||V_SALETRADEID,
							p_CARDNO	      => P_CARDNO	,
							p_DEPOSIT	      => 0			,
							p_CARDCOST	      => 0			,
							p_OTHERFEE		  => 0			,
							p_CARDTRADENO	  => '0000'		,
							p_CARDTYPECODE	  =>V_CARDTYPECODE,
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

	IF P_RETCODE = '0000000000' THEN
	P_RETMSG := '';
	COMMIT; RETURN;
	END IF;

END;

/
SHOW ERRORS
