CREATE OR REPLACE PROCEDURE SP_AS_AffectCardNew
(
    p_ID                char,
    p_cardNo            char,
    p_cardTradeNo       char,
    p_asn               char,
    p_tradeFee          int,
	p_discount			int,

    p_operCardNo        char,
    p_terminalNo        char,
    p_oldEndDateNum     char,
    p_endDateNum        char,

  p_ACCOUNTTYPE    CHAR,    --账户类型
  p_PACKAGETPYECODE  CHAR,    --套餐类型
  p_XFCARDNO      varchar2,    --充值卡号

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
    p_TradeID           varchar2,

  p_passPaperNo    varchar2,    --明文证件号码
  p_passCustName    varchar2,    --明文姓名

  p_CITYCODE      CHAR,   --城市代码

    p_currOper          char,
    p_currDept          char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_endDate       CHAR(8);
    v_tagValue      TD_M_TAG.TAGVALUE%TYPE;
  v_tradefee    INT;
    v_totalTimes    INT;
  v_count      int;
  v_RSRV1      char(2);
  v_RSRV3      char(1);
  v_packageTypeCode char(4);
    v_openYearMonth CHAR(6);
    v_ex            exception;
    v_seqNo         char(16);
    v_cardType      CHAR(2);
    v_updateTime    date;
BEGIN

  --设置功能费
  IF p_XFCARDNO IS NOT NULL THEN  --充值卡号不为空，则为充值卡方式充值，现金台帐金额记为0
    v_tradefee := 0;
  ELSE
    v_tradefee := p_tradeFee;
  END IF;

    -- 2) Get enddate
    BEGIN
        SELECT TAGVALUE INTO v_tagValue FROM  TD_M_TAG
        WHERE   TAGCODE = 'AffectPARK_ENDDATE' AND USETAG = '1';
        v_endDate := substr(v_tagValue, 1, 8);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'A00505B001'; p_retMsg  := '缺少参数-惠民亲子卡结束日期';
        RETURN;
    END;

    -- 3) Get total times
    BEGIN
        SELECT CAST(TAGVALUE AS INT) INTO v_totalTimes FROM  TD_M_TAG
        WHERE  TAGCODE = 'AffectPARK_NUM' AND USETAG = '1';
    EXCEPTION WHEN NO_DATA_FOUND THEN
        p_retCode := 'S00505B002'; p_retMsg  := '缺少系统参数-惠民亲子卡总共次数';
        RETURN;
    END;

  -- 4) 获取上一次账户开通方式
  BEGIN
    SELECT ACCOUNTTYPE INTO v_RSRV3 FROM TF_F_CARDXXPARKACC_SZ WHERE CARDNO = p_cardNo;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      NULL;
  END;



    v_openYearMonth := to_char(v_today, 'yyyyMM');

    -- 5) New row, or Update
    BEGIN
        MERGE INTO TF_F_CARDXXPARKACC_SZ t USING DUAL
        ON (t.CARDNO = p_cardNo)
        WHEN MATCHED THEN
            UPDATE SET
        ACCOUNTTYPE    = p_ACCOUNTTYPE,
        PACKAGETYPECODE = p_PACKAGETPYECODE,
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
                RERVCHAR        = p_oldEndDateNum,
        CITYCODE    = p_CITYCODE
        WHEN NOT MATCHED THEN
            INSERT
                (CARDNO,ACCOUNTTYPE,PACKAGETYPECODE,CURRENTOPENYEAR,CARDTIMES,CURRENTPAYTIME,CURRENTPAYFEE,
                ENDDATE,USETAG,TOTALTIMES,SPARETIMES,UPDATESTAFFNO,UPDATETIME, RERVCHAR  ,CITYCODE)
            VALUES
                (p_cardNo,p_ACCOUNTTYPE,p_PACKAGETPYECODE,v_openYearMonth,1,v_today,
                p_tradeFee,v_endDate,'1',v_totalTimes,v_totalTimes,p_currOper,v_today, p_oldEndDateNum,p_CITYCODE);

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00505B005'; p_retMsg  := '新增或者更新惠民亲子卡信息失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    begin
        select operatetime INTO v_updateTime
        from (select t.operatetime
            from tf_b_trade t
            where t.cardno = p_cardNo
            and t.tradetypecode = '65'
            and t.canceltradeid is null
            order by t.operatetime desc)
        where rownum < 2;

        if trunc(v_updateTime, 'DD') = trunc(sysdate, 'DD') then
            p_retCode := 'S00501B000'; p_retMsg  := '惠民亲子卡当日开通，不允许再次开通';
            return;
        end if;
    exception when no_data_found then null;
    end;

    -- 6) Get trade id
    --SP_GetSeq(seq => v_seqNo);

    SELECT CARDTYPECODE INTO v_cardType FROM TL_R_ICUSER WHERE CARDNO = p_cardNo;
    -- 7) Log the operation
    BEGIN
        INSERT INTO TF_B_TRADE
            (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,RSRV1,RSRV2)
        VALUES
            (p_TradeID,p_ID,'65',p_cardNo,p_asn,v_cardType,
            p_currOper,p_currDept,v_today,p_XFCARDNO,p_PACKAGETPYECODE);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00505B006'; p_retMsg  := '新增惠民亲子卡开通台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 8) Update cust info
    BEGIN
        UPDATE TF_F_CUSTOMERREC
        SET    CUSTNAME      = nvl(p_custName,CUSTNAME)  ,
               CUSTSEX       = nvl(p_custSex,CUSTSEX)   ,
               CUSTBIRTH     = nvl(p_custBirth,CUSTBIRTH) ,
               PAPERTYPECODE = nvl(p_paperType,PAPERTYPECODE) ,
               PAPERNO       = nvl(p_paperNo,PAPERNO)   ,
               CUSTADDR      = nvl(p_custAddr,CUSTADDR)  ,
               CUSTPOST      = nvl(p_custPost,CUSTPOST)  ,
               CUSTPHONE     = nvl(p_custPhone,CUSTPHONE) ,
               CUSTEMAIL     = nvl(p_custEmail,CUSTEMAIL) ,
               REMARK        = nvl(p_remark,REMARK)    ,
               UPDATESTAFFNO = p_currOper  ,
               UPDATETIME    = v_today
        WHERE  CARDNO        = p_cardNo;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00505B007'; p_retMsg  := '更新客户资料失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    BEGIN
        INSERT INTO TF_B_CUSTOMERCHANGE
          (TRADEID,CARDNO,CUSTNAME,CUSTSEX,CUSTBIRTH,PAPERTYPECODE,
           PAPERNO,CUSTADDR,CUSTPOST,CUSTPHONE,CUSTEMAIL,REMARK,
           CHGTYPECODE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
          (p_TradeID,p_cardNo,p_custName,p_custSex,p_custBirth,p_paperType,
           p_paperNo,p_custAddr,p_custPost,p_custPhone,p_custEmail,p_remark,
           '01',p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00505B008'; p_retMsg  := '新增客户资料变更台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 9) Log the cash
    BEGIN
        INSERT INTO TF_B_TRADEFEE
            (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,FUNCFEE,OTHERFEE,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
            (p_ID,p_TradeID,'65',p_cardNo,p_cardTradeNo,v_tradefee,-p_discount,
            p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00505B009'; p_retMsg  := '新增惠民亲子卡开通现金台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 10) Log card change
    BEGIN
        INSERT INTO TF_CARD_TRADE
            (TRADEID, TRADETYPECODE, strOperCardNo, strCardNo, strTermno, strEndDateNum, OPERATETIME)
        VALUES(p_TradeID, '65', p_operCardNo, p_cardNo, p_terminalNo, p_endDateNum, v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00505B010'; p_retMsg  := '新增惠民亲子卡开通卡片交易台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

  --记录上一次开通时套餐类型
  BEGIN
  SELECT RSRV1 INTO v_RSRV1 FROM TF_F_CARDUSEAREA T
  WHERE T.CARDNO  = p_cardNo AND T.FUNCTIONTYPE  = '18';
  EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;
  END;

    -- 11) Setup the relation between cards and features.
    BEGIN
        MERGE INTO TF_F_CARDUSEAREA USING DUAL
        ON (CARDNO        = p_cardNo AND FUNCTIONTYPE  = '18')
        WHEN MATCHED THEN
            UPDATE
            SET    USETAG        = '1',
                   ENDTIME       = v_endDate ,
                   UPDATESTAFFNO = p_currOper,
                   UPDATETIME    = v_today,
           RSRV1     = p_PACKAGETPYECODE,
           RSRV2     = v_RSRV1,
           RSRV3     = v_RSRV3
        WHEN NOT MATCHED THEN
            INSERT
                  (CARDNO  , FUNCTIONTYPE, USETAG, ENDTIME  , UPDATESTAFFNO , UPDATETIME, RSRV1        ,RSRV2  ,RSRV3)
            VALUES(p_cardNo, '18'        , '1'   , v_endDate, p_currOper    , v_today  , p_PACKAGETPYECODE  ,v_RSRV1,v_RSRV3);

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00505B011'; p_retMsg  := '更新或新增卡片与惠民亲子卡功能项关联关系失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

  -- 代理营业厅抵扣预付款，add by liuhe 20120104
  BEGIN
    SP_PB_DEPTBALFEE(p_TradeID, '1' ,--1预付款,2保证金,3预付款和保证金
           v_tradeFee,
                   v_today,p_currOper,p_currDept,p_retCode,p_retMsg);

    IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
  END;

  --同步休闲接口
  BEGIN
    SP_AS_SynGardenXXCard(p_cardNo,p_asn,p_paperType,p_passPaperNo,p_passCustName,
            v_endDate,v_totalTimes,'1',v_today,'','',p_TradeID,
            p_PACKAGETPYECODE,p_ACCOUNTTYPE,p_CITYCODE,
            p_currOper,p_currDept,p_retCode,p_retMsg);

    IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
  END;

    p_retCode := '0000000000'; p_retMsg  := '';
    RETURN;
END;

/

show errors

