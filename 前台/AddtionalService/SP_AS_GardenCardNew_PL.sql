CREATE OR REPLACE PROCEDURE SP_AS_GardenCardNew
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

	p_passPaperNo		varchar2,		--加*的证件号码
	p_passCustName		varchar2,		--加*的姓名

	p_rsrv1				varchar2,		--园林同步接口预留字段

    p_currOper          char,
    p_currDept          char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_endDate       char(8);
    v_tagValue      TD_M_TAG.TAGVALUE%TYPE;
    v_totalTimes    INT;
    v_openYearMonth char(6);
    v_ex            exception;
    v_seqNo         char(16);
    v_cardType      CHAR(2);
    v_updateTime    date;
		v_countImage    INT;
		v_Picture       BLOB;
BEGIN
    -- 2) Get enddate
	v_endDate := substr(trim(p_endDateNum), 1, 8);

    -- 3) Get total times
    BEGIN
        SELECT CAST(TAGVALUE AS INT) INTO v_totalTimes FROM  TD_M_TAG
        WHERE  TAGCODE = 'PARK_NUM' AND USETAG = '1';
    EXCEPTION  WHEN NO_DATA_FOUND THEN
        p_retCode := 'S00501B002'; p_retMsg  := '缺少系统参数-园林年卡总共次数';
        RETURN;
    END;

    v_openYearMonth := to_char(v_today, 'yyyyMM');

    -- 5) New row, or Update
    BEGIN
        MERGE INTO TF_F_CARDPARKACC_SZ USING DUAL
        ON (CARDNO = p_cardNo)
        WHEN MATCHED THEN
            UPDATE SET
                CURRENTOPENYEAR = v_openYearMonth,
                CARDTIMES       = CARDTIMES + 1,
                CURRENTPAYTIME  = v_today,
                CURRENTPAYFEE   = p_tradeFee,
                ENDDATE         = v_endDate,
                USETAG          = '1',
                TOTALTIMES      = v_totalTimes,
                SPARETIMES      = v_totalTimes,
                UPDATESTAFFNO   = p_currOper,
                UPDATETIME      = v_today,
                RERVCHAR        = p_oldEndDateNum
        WHEN NOT MATCHED THEN
               INSERT (CARDNO,CURRENTOPENYEAR,CARDTIMES,CURRENTPAYTIME,CURRENTPAYFEE,
                    ENDDATE,USETAG,TOTALTIMES,SPARETIMES,UPDATESTAFFNO,UPDATETIME, RERVCHAR)
                VALUES
                    (p_cardNo,v_openYearMonth,1,v_today,
                    p_tradeFee,v_endDate,'1',v_totalTimes,v_totalTimes,p_currOper,v_today, p_oldEndDateNum);

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00501B004'; p_retMsg  := '新增或更新园林年卡信息失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    begin
        select operatetime INTO v_updateTime
        from (select t.operatetime
            from tf_b_trade t
            where t.cardno = p_cardNo
            and t.tradetypecode in('10','3H')
            and t.canceltradeid is null
            order by t.operatetime desc)
        where rownum < 2;

        if trunc(v_updateTime, 'DD') = trunc(sysdate, 'DD') then
            p_retCode := 'S00501B000'; p_retMsg  := '园林年卡当日开通，不允许再次开通';
            return;
        end if;
    exception when no_data_found then null;
    end;

    -- 6) Get trade id
    SP_GetSeq(seq => v_seqNo);

    SELECT CARDTYPECODE INTO v_cardType FROM TL_R_ICUSER WHERE CARDNO = p_cardNo;
    -- 7) Log the operation
    BEGIN
        INSERT INTO TF_B_TRADE
            (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
            (v_seqNo,p_ID,'10',p_cardNo,p_asn,v_cardType,
            p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00501B006'; p_retMsg  := '新增园林年卡开通台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 8) Update cust info 不是市民卡才允许修改客户资料
	IF SUBSTR(p_cardNo,5,2) != '18' THEN
		BEGIN
			UPDATE TF_F_CUSTOMERREC
			SET    CUSTNAME      = nvl(p_custName,CUSTNAME)  ,
				   CUSTSEX       = nvl(p_custSex,CUSTSEX)   ,
				   CUSTBIRTH     = nvl(p_custBirth,CUSTBIRTH) ,
				   PAPERTYPECODE = nvl(p_paperType,PAPERTYPECODE) ,
				   PAPERNO       = nvl(p_paperNo,PAPERNO)   ,
				   CUSTADDR      = nvl(p_custAddr,CUSTADDR) ,
				   CUSTPOST      = nvl(p_custPost,CUSTPOST)  ,
				   CUSTPHONE     = nvl(p_custPhone,CUSTPHONE) ,
				   CUSTEMAIL     = nvl(p_custEmail,CUSTEMAIL) ,
				   REMARK        = nvl(p_remark ,REMARK)   ,
				   UPDATESTAFFNO = p_currOper  ,
				   UPDATETIME    = v_today
			WHERE  CARDNO        = p_cardNo;

			IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION WHEN OTHERS THEN
			p_retCode := 'S00501B007'; p_retMsg  := '更新客户资料失败,' || SQLERRM;
			ROLLBACK; RETURN;
		END;
	END IF;

    BEGIN
        INSERT INTO TF_B_CUSTOMERCHANGE
          (TRADEID,CARDNO,CUSTNAME,CUSTSEX,CUSTBIRTH,PAPERTYPECODE,
           PAPERNO,CUSTADDR,CUSTPOST,CUSTPHONE,CUSTEMAIL,REMARK,
           CHGTYPECODE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
          (v_seqNo,p_cardNo,p_custName,p_custSex,p_custBirth,p_paperType,
           p_paperNo,p_custAddr,p_custPost,p_custPhone,p_custEmail,p_remark,
           '01',p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00501B008'; p_retMsg  := '新增客户资料变更台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 9) Log the cash
    BEGIN
        INSERT INTO TF_B_TRADEFEE
            (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,FUNCFEE,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
            (p_ID,v_seqNo,'10',p_cardNo,p_cardTradeNo,p_tradeFee,
            p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00501B009'; p_retMsg  := '新增园林年卡开通现金台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 10) Log card change
    BEGIN
        INSERT INTO TF_CARD_TRADE
            (TRADEID, TRADETYPECODE, strOperCardNo, strCardNo, strTermno, strEndDateNum, OPERATETIME)
        VALUES(v_seqNo, '10', p_operCardNo, p_cardNo, p_terminalNo, p_endDateNum, v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00501B010'; p_retMsg  := '新增园林年卡开通卡片交易台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 11) Setup the relation between cards and features.
    BEGIN
        MERGE INTO TF_F_CARDUSEAREA  USING DUAL
        ON ( CARDNO = p_cardNo AND FUNCTIONTYPE  = '02')
        WHEN MATCHED THEN
            UPDATE
            SET    USETAG        = '1',
                   ENDTIME       = v_endDate ,
                   UPDATESTAFFNO = p_currOper,
                   UPDATETIME    = v_today
        WHEN NOT MATCHED THEN
            INSERT
                  (CARDNO  , FUNCTIONTYPE, USETAG, ENDTIME  , UPDATESTAFFNO , UPDATETIME)
            VALUES(p_cardNo, '02'        , '1'   , v_endDate, p_currOper    , v_today);

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00501B011'; p_retMsg  := '更新或新增卡片与园林年卡功能项关联关系失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
		
		BEGIN 
		    SELECT count(*) INTO v_countImage FROM TF_F_GARDENPHOTO_SZ t WHERE  t.STATE = '0' AND t.CARDNO=p_cardNo;
		END;
		
		 --12）如果修改照片
    IF v_COUNTIMAGE = '1' THEN
		  --）记录照片历史表
			BEGIN
				INSERT INTO TB_F_CARDPARKPHOTO_SZ(CARDNO,PICTURE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
				SELECT p_cardNo,t.PICTURE,p_currOper,p_currDept,v_today
				FROM TF_F_GARDENPHOTO_SZ t WHERE t.cardno=p_cardNo ;
				IF SQL%ROWCOUNT != 1 THEN
				  RAISE v_EX;
				END IF;
				EXCEPTION
				WHEN OTHERS THEN
				p_retCode := 'S001011144';
				p_retMsg  := 'Error occurred while insert TB_F_CARDPARKPHOTO_SZ info' ||SQLERRM;
				ROLLBACK;
				RETURN;
			END;
		
		
		   SELECT picture INTO v_Picture FROM TF_F_GARDENPHOTO_SZ t WHERE  t.STATE = '0' AND t.CARDNO=p_cardNo;
		 ---更新卡片照片对应关系表
          BEGIN
					    MERGE INTO TF_F_CARDPARKPHOTO_SZ t USING DUAL
              ON (t.CARDNO = P_CARDNO)
            WHEN MATCHED THEN
              UPDATE
                 SET t.PICTURE         = v_Picture,
                     t.OPERATETIME     = v_today,
                     t.OPERATEDEPARTID = p_currDept,
                     t.OPERATESTAFFNO  = p_currOper
            WHEN NOT MATCHED THEN
              INSERT
                (CARDNO,
                 PICTURE,
                 OPERATETIME,
                 OPERATEDEPARTID,
                 OPERATESTAFFNO)
              VALUES
                (P_CARDNO,
                 v_Picture,
                 v_today,
                 p_currDept,
                 p_currOper);
          END;
 
         BEGIN
            update TF_F_GARDENPHOTO_SZ t
               set t.STATE = '1'
             where t.CARDNO = p_cardNo;

            IF SQL%ROWCOUNT != 1 THEN
              RAISE v_EX;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S001011136';
              p_retMsg  := 'Error occurred while updating TF_F_CARDPARKPHOTOCHANGE_SZ info' ||SQLERRM;
              ROLLBACK;
              RETURN;
          END;
       
        END IF;
		
		
		
		
        

	-- 代理营业厅抵扣预付款，add by liuhe 20120104
	BEGIN
	  SP_PB_DEPTBALFEE(v_seqNo, '1' ,--1预付款,2保证金,3预付款和保证金
					 p_tradeFee,
	                 v_today,p_currOper,p_currDept,p_retCode,p_retMsg);

    IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
	END;

	--同步园林接口
	BEGIN
	  SP_AS_SynGardenCard(p_cardNo,p_asn,p_paperType,p_passPaperNo,p_passCustName,
						v_endDate,v_totalTimes,'1',v_today,'',p_rsrv1,v_seqNo,
						p_currOper,p_currDept,p_retCode,p_retMsg);

    IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
	END;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;

/

show errors