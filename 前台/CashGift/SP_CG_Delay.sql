create or replace procedure SP_CG_Delay
(
    p_cardNo          char, -- ����-����-16λ����
    p_wallet1         int , -- ����-����Ǯ�����1
    p_wallet2         int , -- ����-����Ǯ�����2
    p_startDate       char, -- ����-��ʼ��Ч��(yyyyMMdd)
    p_endDate         char, -- ����-������Ч��(yyyyMMdd)
    p_expiredDate     char, -- ����ʧЧ����(yyyyMMdd)

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
    -- ���˻���Ч�Լ��
    SP_CashGiftAccCheck(p_cardNo, p_currOper, p_currDept, p_retCode, p_retMsg);
    if p_retCode != '0000000000' then
        rollback; return;
    end if;

    if p_wallet1 <= 0 then
        raise_application_error(-20101, '����Ǯ��1����С������������' );
    end if;

    select CARDACCMONEY into v_dbmoney
    from   TF_F_CARDEWALLETACC
    where  CARDNO = p_cardNo;
    if v_dbmoney <= 0 then
        raise_application_error(-20101, '���˻�����С������������' );
    end if;

    -- ����
    update TF_F_CARDREC t
    set    t.VALIDENDDATE = p_expiredDate
    where  t.CARDNO       = p_cardNo;
    if sql%rowcount != 1 then
        raise_application_error(-20103, '���¿�Ƭ���ϱ�ʧ��' );
    end if;

    -- ��¼һ����𿨻���̨��
    SP_GetSeq(seq => v_seq);
    insert into TF_B_TRADE_CASHGIFT 
        (TRADEID, CARDNO, ID, TRADETYPECODE, ASN, wallet1, wallet2,
        cardstartdate, cardenddate, dbstartdate, dbenddate, delayenddate,
        OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
    values(v_seq, p_cardNo, p_ID, '53', p_asn, p_wallet1, p_wallet2,
        p_startDate, p_endDate, p_dbStartDate, p_dbEndDate, p_expiredDate,
        p_currOper, p_currDept, v_today);

    -- д��̨��
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

