-- =============================================
-- AUTHOR:		liuhe
-- CREATE DATE: 2013-09-23
-- DESCRIPTION:	旅游卡-回收存储过程
-- =============================================
CREATE OR REPLACE PROCEDURE SP_AS_SZTravelCardRecycle
(
	p_ID	          char,
	p_CARDNO	      char,
	p_ASN			  char,
	p_CARDTRADENO	  char,--读卡-交易序号
    p_STARTDATE       char,--读卡-起始有效期(yyyyMMdd)
    p_ENDDATE         char,--读卡-结束有效期(yyyyMMdd)
	p_REASONCODE	  char,--退卡类型
	p_CARDMONEY       int,  --卡内余额
	p_REFUNDMONEY	  int,--退充值,负数
	p_REFUNDDEPOSIT	  int,--退押金,负数
	p_TRADEPROCFEE    int,--收手续费，正数
	p_CUSTNAME	      varchar2,--客户姓名
	p_PAPERTYPECODE	  varchar2,--证件类型
	p_PAPERNO         varchar2,--证件号码
	p_CUSTPHONE	      varchar2,--联系电话
	p_BANKNAME	      varchar2,--开户银行
	p_BANKNAMESUB	  varchar2,--支行
	p_BANKACCNO	  	  varchar2,--银行账号
	p_PURPOSETYPE	  varchar2,--账户类型
	p_REMARK	      varchar2,--备注
	p_OPERCARDNO	  char,
	p_CHECKSTAFFNO	  char,
	p_CHECKDEPARTNO	  char,
	p_TRADEID         out char,
	p_currOper	      char,
	p_currDept	      char,
	p_retCode	      out char, -- Return Code
	p_retMsg     	  out varchar2  -- Return Message
)
AS
    v_CARDSTATE        char(2);
    v_TODAY            date := sysdate;
    v_CARDACCMONEY     int;
    v_ASSIGNEDSTAFFNO  char(6);
	v_RESSTATECODE	   char(2);
	v_DEPOSIT          int;
	v_DEPOSIT2       int; --转收入押金额
    v_EX               exception;
BEGIN

    BEGIN
        SELECT RESSTATECODE , ASSIGNEDSTAFFNO
		INTO   V_CARDSTATE  , V_ASSIGNEDSTAFFNO 
        FROM TL_R_ICUSER
        WHERE CARDNO = P_CARDNO;
		
		SELECT DEPOSIT INTO v_DEPOSIT FROM TF_F_CARDREC WHERE CARDNO = P_CARDNO; 
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        P_RETCODE := 'S094570355';
        P_RETMSG  := '未找到卡库存记录,'|| SQLERRM;
        RETURN;
    END;

    --只有售出的卡才能回收
    IF V_CARDSTATE != '06' THEN
        P_RETCODE := 'S094570356';
        P_RETMSG  := '不是售出状态的卡不能回收';
        RETURN;
    END IF;
	
	SP_GETSEQ(SEQ => p_TRADEID);
		
	IF p_REASONCODE = '11' OR p_REASONCODE = '12' OR p_REASONCODE = '13' THEN---可读卡回收
		
		v_RESSTATECODE := '04';

		--验证卡片账户余额和卡内余额是否相等
		SELECT CARDACCMONEY INTO V_CARDACCMONEY FROM TF_F_CARDEWALLETACC WHERE CARDNO = P_CARDNO;
		IF V_CARDACCMONEY - P_CARDMONEY < 0 THEN
			P_RETCODE := 'S094570357';
			P_RETMSG  := '库内余额小于卡内余额，暂时不能回收';
			RETURN;
		ELSE 
			--如果是可读卡回收，圈提卡片并且更新账户余额，以保证回收再售出的时候卡账持平
			BEGIN
				UPDATE TF_F_CARDEWALLETACC
				SET  CARDACCMONEY = CARDACCMONEY - P_CARDMONEY              
				WHERE  CARDNO = p_CARDNO
				AND USETAG='1' 
				AND V_CARDACCMONEY - P_CARDMONEY>=0;
				
				IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
			EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S001002113';
					p_retMsg  := 'S001002113:更新账户表失败';
					ROLLBACK; RETURN;
			END;
		END IF;
		
		---记录个人业务台帐，可读currentmoney不为0
		BEGIN
			INSERT INTO TF_B_TRADE
				(TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,REASONCODE,CURRENTMONEY,
				OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,CARDSTATE,SERSTAKETAG)
			SELECT
				p_TRADEID,p_ID,'7K',p_CARDNO,p_ASN,CARDTYPECODE,p_CARDTRADENO,p_REASONCODE,p_REFUNDMONEY + p_REFUNDDEPOSIT + p_TRADEPROCFEE,
				p_currOper,p_currDept,v_TODAY,CARDSTATE,SERSTAKETAG
			FROM TF_F_CARDREC
			WHERE CARDNO = p_CARDNO;
			 
			EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S001008106';
					p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
					ROLLBACK; RETURN;
		END;
		
		---现金台帐
		BEGIN
			INSERT INTO TF_B_TRADEFEE
				(ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,PREMONEY,CARDDEPOSITFEE,SUPPLYMONEY,
				TRADEPROCFEE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
			VAlUES
				(p_ID,p_TRADEID,'7K',p_CARDNO,p_CARDTRADENO,p_CARDMONEY,p_REFUNDDEPOSIT ,p_REFUNDMONEY,
				p_TRADEPROCFEE,p_currOper,p_currDept,v_TODAY);

		EXCEPTION
			WHEN OTHERS THEN
				p_retCode := 'S001007119';
				p_retMsg  := 'Fail to log the cash' || SQLERRM;
				ROLLBACK; RETURN;
		END;
		
		--写卡台帐
		BEGIN
					
			INSERT INTO TF_CARD_TRADE
                    (TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,lMoney,lOldMoney,strTermno,
                    Cardtradeno,OPERATETIME,SUCTAG)
            VALUES
                    (p_TRADEID,'7K',p_OPERCARDNO,p_CARDNO,p_CARDMONEY,p_CARDMONEY,'112233445566',
                    p_CARDTRADENO,v_TODAY,'0');
					
		EXCEPTION
			WHEN OTHERS THEN
				p_retCode := 'S001001139';
				p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
				ROLLBACK; RETURN;
		END;

	ELSE ---不可读卡回收
	
		v_RESSTATECODE := '03'; --不可读卡卡状态致为作废，避免再售出
		
		--记录财务转账台帐表
		BEGIN
		 INSERT INTO TF_B_TRADE_SZTRAVEL_RF
		   (TRADEID, CARDNO, ID, ASN, BANKNAME, BANKNAMESUB, BANKACCNO, BACKMONEY,
		   BACKDEPOSIT, 
		   CUSTNAME, PAPERTYPECODE, PAPERNO, CUSTPHONE,
		   PURPOSETYPE, ISUPDATED, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME, REMARK)
		 VALUES
		   (p_TRADEID, p_CARDNO, p_ID, p_ASN, p_BANKNAME, p_BANKNAMESUB,p_BANKACCNO,0,
       DECODE(p_REASONCODE,'15',v_DEPOSIT - p_TRADEPROCFEE,0),
	   p_CUSTNAME, p_PAPERTYPECODE, p_PAPERNO, p_CUSTPHONE,
		   p_PURPOSETYPE, 0, p_currOper, p_currDept, v_TODAY, p_REMARK);

		EXCEPTION
			WHEN OTHERS THEN
				p_retCode := 'S001001940';
				p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
				ROLLBACK; RETURN;
		END;
		
		---记录个人业务台帐， 不可读currentmoney为0
		BEGIN
			INSERT INTO TF_B_TRADE
				(TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,REASONCODE,CURRENTMONEY,
				OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,CHECKSTAFFNO,CHECKDEPARTNO,CHECKTIME,CARDSTATE,SERSTAKETAG)
			SELECT
				p_TRADEID,p_ID,'7K',p_CARDNO,p_ASN,CARDTYPECODE,p_CARDTRADENO,p_REASONCODE,0,
				p_currOper,p_currDept,v_TODAY,p_CHECKSTAFFNO,p_CHECKDEPARTNO,v_TODAY,CARDSTATE,SERSTAKETAG
			FROM TF_F_CARDREC
			WHERE CARDNO = p_CARDNO;
			 
			EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S001008106';
					p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
					ROLLBACK; RETURN;
		END;
		
	END IF;

	IF p_REASONCODE = '15' THEN-- 不可读p_REFUNDDEPOSIT传入参数为0，所以转收入押金不等于v_DEPOSIT + p_REFUNDDEPOSIT,应该等于0
		v_DEPOSIT2 := 0;
	ELSE v_DEPOSIT2 := v_DEPOSIT + p_REFUNDDEPOSIT;
	END IF;
    --记录旅游卡扩展业务台帐表
    BEGIN
        INSERT INTO TF_B_TRADE_SZTRAVEL(
            TRADEID            , CARDNO         , ID              , TRADETYPECODE ,
            ASN                , DEPOSIT        , TRADEPROCFEE    , CARDACCMONEY  ,
            CARDSTARTDATE      , CARDENDDATE    , DBSTARTDATE     , DBENDDATE     ,
            DELAYENDDATE       , OPERATESTAFFNO , OPERATEDEPARTID , OPERATETIME   ,
			OLDASSIGNEDSTAFFNO , ASSIGNEDSTAFFNO
       )VALUES(
            p_TRADEID         , P_CARDNO       , P_ID            , '7K'          ,
            P_ASN             , v_DEPOSIT2 , p_TRADEPROCFEE , P_CARDMONEY   ,
            P_STARTDATE       , P_ENDDATE      , NULL            , NULL          ,
            NULL              , P_CURROPER     , P_CURRDEPT      , V_TODAY       ,
			V_ASSIGNEDSTAFFNO , P_CURROPER
            );

        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE := 'S094570360';
        P_RETMSG  := '记录旅游卡扩展业务台帐表失败,'|| SQLERRM;
        ROLLBACK; RETURN;
    END;
	
    --更新卡库存表
    BEGIN
        UPDATE TL_R_ICUSER
        SET    RESSTATECODE     = v_RESSTATECODE,
               RECLAIMTIME      = V_TODAY   ,
               UPDATESTAFFNO    = P_CURROPER,
               UPDATETIME       = V_TODAY   ,
               ASSIGNEDDEPARTID = P_CURRDEPT,   --更改卡片归属部门
               ASSIGNEDSTAFFNO  = P_CURROPER    --更改卡片归属员工
        WHERE  CARDNO = P_CARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE := 'S094570358';
        P_RETMSG  := '更新卡库存表失败,'|| SQLERRM;
        ROLLBACK; RETURN;
    END;

    --修改卡资料表信息
    BEGIN
        UPDATE TF_F_CARDREC
        SET    CARDSTATE     = '31', --旅游卡回收
			   SERVICEMONEY  = DEPOSIT,
               UPDATESTAFFNO = P_CURROPER,
               UPDATETIME    = V_TODAY
        WHERE  CARDNO = P_CARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE := 'S094570359';
        P_RETMSG  := '更新卡资料表失败,'|| SQLERRM;
        ROLLBACK; RETURN;
    END;

    P_RETCODE := '0000000000';
    P_RETMSG  := '';
    COMMIT; RETURN;

END;


/

show errors
