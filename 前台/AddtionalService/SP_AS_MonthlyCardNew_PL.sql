CREATE OR REPLACE PROCEDURE SP_AS_MonthlyCardNew
(
    p_ID                  char,
    p_cardNo              char,
    p_deposit             int,
    p_cardCost            int,
    p_otherFee            int,
    p_cardTradeNo         char,
    p_asn                 char,
    p_cardMoney           int,
    p_sellChannelCode     char,
    p_serTakeTag          char,
    p_tradeTypeCode       char,

    p_terminalNo          char,

    p_custName            varchar2,
    p_custSex             varchar2,
    p_custBirth           varchar2,
    p_paperType           varchar2,
    p_paperNo             varchar2,
    p_custAddr            varchar2,
    p_custPost            varchar2,
    p_custPhone           varchar2,
    p_custEmail           varchar2,
    p_remark              varchar2,

    p_custRecTypeCode     char,
    p_appType             char,
    p_assignedArea        char,
    p_currCardNo          char,
    p_currOper            char,
    p_currDept            char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_ex            exception;
    v_seqNo         char(16);
    v_cardType      CHAR(2);
    v_fnType        CHAR(2);

BEGIN

    SELECT CARDTYPECODE INTO v_cardType FROM TL_R_ICUSER WHERE CARDNO = p_cardNo;

    -- 1) Execute procedure SP_PB_SaleCard
    SP_PB_SaleCard
    (
        p_ID       , p_cardNo   , p_deposit        , p_cardCost  , p_otherFee     , p_cardTradeNo  ,
        v_cardType , p_cardMoney, p_sellChannelCode, p_serTakeTag, p_tradeTypeCode, p_custName     ,
        p_custSex  , p_custBirth, p_paperType      , p_paperNo   , p_custAddr     , p_custPost     ,
        p_custPhone, p_custEmail, p_remark         , p_custRecTypeCode, p_terminalNo, p_currCardNo ,
        v_today,v_seqNo,
        p_currOper , p_currDept , p_retCode        , p_retMsg
    );
    IF p_retCode != '0000000000' THEN
        ROLLBACK; RETURN;
    END IF;

    -- 2) Insert a row of monthly info
    BEGIN
        INSERT INTO TF_F_CARDCOUNTACC
            (CARDNO,APPTYPE,ASSIGNEDAREA,APPTIME,APPSTAFFNO,USETAG,
            UPDATESTAFFNO,UPDATETIME)
        VALUES
            (p_cardNo,p_appType,p_assignedArea,v_today,p_currOper,'1',
            p_currOper,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00509B001'; p_retMsg  := '新增月票卡资料失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 3) Log card change
    BEGIN
        UPDATE TF_CARD_TRADE
        SET    strFlag = p_assignedArea || decode(p_custSex, '0', 'C1', 'C0')
        WHERE  TRADEID = v_seqNo;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00509B002'; p_retMsg  := '更新月票卡售卡卡片交易台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 4) Setup the relation between cards and features.
    select decode(p_appType, '01', '03', '02', '04', '03', '05' , '04' , '09') into v_fnType from dual;

    BEGIN
        INSERT INTO TF_F_CARDUSEAREA
              (CARDNO , FUNCTIONTYPE, USETAG, UPDATESTAFFNO , UPDATETIME)
        VALUES(p_cardNo, v_fnType     , '1'   , p_currOper, v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00509B003'; p_retMsg  := '新增卡片与月票卡功能项关联关系失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
	
	-- 代理营业厅抵扣预付款，add by liuhe 20120104
	BEGIN
	  SP_PB_DEPTBALFEE(v_seqNo, '3' ,--1预付款,2保证金,3预付款和保证金
					 p_deposit + p_cardCost + p_otherFee,
	                 v_today,p_currOper,p_currDept,p_retCode,p_retMsg);
	
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
