create or replace procedure SP_CG_SaleCardRollback
(
    p_ID              char,
    p_cardNo          char,
    p_cardTradeNo     char,
    p_cancelTradeId in out char,
    p_terminalNo      char,

    p_wallet1         int , -- ����-����Ǯ�����1
    p_wallet2         int , -- ����-����Ǯ�����2
    p_option          char, -- 0 - commit with check 1 - commit w/o check 2 - only check w/o commit

    p_currCardNo      char,
    p_writeCardScript varchar2,

    p_currOper        char,
    p_currDept        char,
    p_retCode     out char,
    p_retMsg      out varchar2
)
as
    v_seqNo           char(16);
    v_supplyMoney     int;
    v_deposit         int;

    v_opTime          date := null;
    v_chargeMoney     int;
    v_prevTradeNo     TF_CARD_TRADE.cardtradeno%type;
    v_nextTradeNo     TF_CARD_TRADE.nextcardtradeno%type;
    v_ex exception;
begin
    if p_option in ('0', '2') then
        p_cancelTradeId := null;

        for v_cur in 
        (
            SELECT * FROM TF_B_TRADE 
            WHERE  CARDNO = p_cardNo AND OPERATESTAFFNO = p_currOper
            AND    OPERATETIME BETWEEN TRUNC(SYSDATE, 'DD') AND SYSDATE
            AND    CANCELTAG = '0' AND CANCELTRADEID IS NULL
            ORDER BY OPERATETIME DESC
        )
        loop
            if v_opTime is null then
                v_opTime := v_cur.OPERATETIME;
            end if;
            
            exit when v_opTime <> v_cur.OPERATETIME;
            
            if v_cur.TRADETYPECODE in('50', '51') then
                p_cancelTradeId := v_cur.TRADEID;
                exit;
            end if;
        end loop;

        if p_cancelTradeId is null then
            raise_application_error(-20101, 'û�е��յ�����Է������ۿ�����' );
        end if;

        select supplymoney into v_chargeMoney
        from   tf_b_tradefee t
        where  t.tradeid = p_cancelTradeId;

        if p_wallet1 != v_chargeMoney then -- Ǯ��1������Ǯ��1��ֵ���
            if p_wallet1 != 0 then
                raise_application_error(-20102, 
                '��ǰǮ��1��Ϊ0��Ҳ�����ۿ�ʱӦ��ֵ�������ѱ�ʹ�ã���������' );
            end if;

            select cardtradeno, nextcardtradeno
            into   v_prevTradeNo, v_nextTradeNo
            from   TF_CARD_TRADE
            where  tradeid = p_cancelTradeId;

            if v_nextTradeNo is not null then
                raise_application_error(-20103, 
                '��ǰ��ƬǮ��1���Ϊ0�������ۿ�ʱд���ɹ�����������' );
            end if;

            if p_cardTradeNo != v_prevTradeNo then
                raise_application_error(-20104, 
                '��ǰ��ƬǮ��1���Ϊ0�����ǿ�Ƭ��������Ѿ������仯����������' );
            end if;
        end if;

    end if;

    if p_option in ('0', '1') then
        -- 1) Execute procedure SP_PB_SaleCard
        SP_PB_SaleCardRollback
        (
            p_ID, p_cardNo , p_cardTradeNo, 0, 0, 0,
            p_cancelTradeId, 0, 0, p_terminalNo, p_currCardNo, v_seqNo, 
            p_currOper, p_currDept, p_retCode, p_retMsg
        );
        IF p_retCode != '0000000000' THEN
            ROLLBACK; RETURN;
        END IF;

        -- ����д��̨��
        update tf_card_trade t
        set    t.writeCardScript = p_writeCardScript
        where  t.tradeid = v_seqNo;

        -- ��������
        select CARDDEPOSITFEE, SUPPLYMONEY
        into   v_deposit, v_supplyMoney
        from   TF_B_TRADEFEE
        where  TRADEID = p_cancelTradeId;

        update TF_B_TRADEFEE t
        set    t.SUPPLYMONEY = -v_supplyMoney,
               t.CARDDEPOSITFEE = -v_deposit
        where  t.TRADEID = v_seqNo;

        -- ����ǻ��տ����ۿ�����Ҫ�������״̬Ϊ����
        update TL_R_ICUSER set RESSTATECODE = '04'
        where  CARDNO = p_cardNo
        and    exists (
            select 1 from TF_B_TRADE
            where TRADEID = p_cancelTradeId 
            and   TRADETYPECODE = '51');
            
        -- ����Ӫҵ���ֿ�Ԥ������ݱ�֤���޸Ŀ��쿨��ȣ�add by liuhe 20111230
         BEGIN
           SP_PB_DEPTBALFEEROLLBACK(v_seqNo, p_cancelTradeId,
                '3' ,--1Ԥ����,2��֤��,3Ԥ����ͱ�֤��
                 - v_supplyMoney - v_deposit,
                         p_currOper,p_currDept,p_retCode,p_retMsg);
      		                 
           IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
              EXCEPTION
              WHEN OTHERS THEN
                  ROLLBACK; RETURN;
         END;
    end if;

    

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

