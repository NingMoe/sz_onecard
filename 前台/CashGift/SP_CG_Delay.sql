create or replace procedure SP_CG_Delay
(
    p_cardNo          char, -- 读卡-卡号-16位卡号
    p_wallet1         int , -- 读卡-电子钱包余额1
    p_wallet2         int , -- 读卡-电子钱包余额2
    p_startDate       char, -- 读卡-起始有效期(yyyyMMdd)
    p_endDate         char, -- 读卡-结束有效期(yyyyMMdd)
    p_expiredDate     char, -- 输入失效日期(yyyyMMdd)

    p_dbStartDate     char,
    p_dbEndDate       char,

    p_writeCardScript varchar2,

    p_ID              char,
    p_cardTradeNo     char,
    p_asn             char,

    p_currOper        char,
    p_currDept        char,
    p_retCode     out char,
    p_retMsg      out varchar2
)
as
    v_today           date := sysdate;
    v_seq             char(16);
    v_dbmoney         int;
begin
    -- 卡账户有效性检查
    SP_CashGiftAccCheck(p_cardNo, p_currOper, p_currDept, p_retCode, p_retMsg);
    if p_retCode != '0000000000' then
        rollback; return;
    end if;

    if p_wallet1 <= 0 then
        raise_application_error(-20101, '电子钱包1余额过小，不允许延期' );
    end if;

    select CARDACCMONEY into v_dbmoney
    from   TF_F_CARDEWALLETACC
    where  CARDNO = p_cardNo;
    if v_dbmoney <= 0 then
        raise_application_error(-20101, '卡账户余额过小，不允许延期' );
    end if;

    -- 延期
    update TF_F_CARDREC t
    set    t.VALIDENDDATE = p_expiredDate
    where  t.CARDNO       = p_cardNo;
    if sql%rowcount != 1 then
        raise_application_error(-20103, '更新卡片资料表失败' );
    end if;

    -- 记录一条礼金卡回收台帐
    SP_GetSeq(seq => v_seq);
    insert into TF_B_TRADE_CASHGIFT 
        (TRADEID, CARDNO, ID, TRADETYPECODE, ASN, wallet1, wallet2,
        cardstartdate, cardenddate, dbstartdate, dbenddate, delayenddate,
        OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
    values(v_seq, p_cardNo, p_ID, '53', p_asn, p_wallet1, p_wallet2,
        p_startDate, p_endDate, p_dbStartDate, p_dbEndDate, p_expiredDate,
        p_currOper, p_currDept, v_today);

    -- 写卡台账
    insert into tf_card_trade(TRADEID, STRCARDNO, TRADETYPECODE, WRITECARDSCRIPT)
    values(v_seq, p_cardNo, '53', p_writeCardScript);

    p_retCode := '0000000000';
    p_retMsg  := '';
    commit; return;

exception when others then
    p_retcode := sqlcode;
    p_retmsg  := sqlerrm;
    rollback; return;
end;

/
show errors

