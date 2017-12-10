create or replace procedure SP_CG_SaleCard
(
    p_submit          char, -- 0 - ���ύ�ۿ�, 1 �ύ�ۿ�����
    p_cardNo          char, -- ����-����-16λ����
    p_wallet1         int , -- ����-����Ǯ�����1
    p_wallet2         int , -- ����-����Ǯ�����2
    p_startDate       char, -- ����-��ʼ��Ч��(yyyyMMdd)
    p_endDate         char, -- ����-������Ч��(yyyyMMdd)

    p_expiredDate     char, -- ����ʧЧ����(yyyyMMdd)
    p_saleMoney       int , -- ������Ԫ

    p_ID              char,
    p_cardTradeNo     char,
    p_asn             char,
    p_sellChannelCode char,
    p_terminalNo      char,
    p_cardPrice   out int,

    p_custName        varchar2,
    p_custSex         varchar2,
    p_custBirth       varchar2,
    p_paperType       varchar2,
    p_paperNo         varchar2,
    p_custAddr        varchar2,
    p_custPost        varchar2,
    p_custPhone       varchar2,
    p_custEmail       varchar2,
    p_remark          varchar2,


    p_seqNO       out char,

    p_currCardNo      char,
    p_writeCardScript out varchar2,

    p_currOper        char,
    p_currDept        char,
    p_retCode     out char,
    p_retMsg      out varchar2
)
as
    v_tradeTypeCode   char(2);
    v_today           date;
    v_rowid           urowid;

    v_cardType     tl_r_icuser.cardtypecode%type;    -- ��Ƭ����
    v_cardDept     tl_r_icuser.assigneddepartid%type;-- ��������
    v_reclaimtime  tl_r_icuser.reclaimtime%type;     -- ����ʱ��
    v_cardState    tl_r_icuser.resstatecode%type;    -- ��Ƭ״̬
    v_asn          tl_r_icuser.asn%type;
    v_ex           exception;
    V_TAGCOUNT           INT;
    V_DEPTCOUNT          INT;
    V_TAGMONEY           INT;
	v_ISNEWTAG       CHAR(1);
	V_COUNT         INT;
begin
    -- 0) ������Ǯ��1����Ƿ�Ϊ0
    if p_wallet1 <> 0 then
        raise_application_error(-20101, '����Ǯ�����Ϊ'
            || p_wallet1/100.0 || 'Ԫ, Ҫ��Ϊ0�����ۿ�' );
    end if;

    -- 1) ��鿨�����Ƿ�Ϊ���,��Ƭ�����Ƿ���ڵ���Ǯ��2
    begin
        select t.cardtypecode, t.cardprice, t.resstatecode, t.assigneddepartid,
               t.reclaimtime, t.asn
        into   v_cardType, p_cardPrice, v_cardState, v_cardDept,
               v_reclaimtime, v_asn
        from   tl_r_icuser t
        where  t.cardno = p_cardNo;
    exception when no_data_found then
        raise_application_error(-20102, '��Ƭ�������ڿ��֮��' );
    end;

    if v_cardType != '05' then
        raise_application_error(-20103, '��Ƭ�����������' );
    end if;

    if p_cardPrice <> p_wallet2 then
        raise_application_error(-20104, '��Ƭ���۸�Ϊ' || p_cardPrice/100.0
            || 'Ԫ, ����Ǯ��2Ϊ' || p_wallet2/100.0 || 'Ԫ, �޷��ۿ�');
    end if;

    -- 2) �����״̬
    if v_cardState in ('01', '05') then -- �������״̬
        v_tradeTypeCode := '50';
        -- ������������ǲ��ǵ�ǰ����
        if v_cardDept != p_currDept then
            raise_application_error(-20105, '��Ƭ�����ڵ�ǰ����');
        end if;
    elsif v_cardState = '04' then -- ����״̬
        v_tradeTypeCode := '51';
		
        select ISNEWTAG into v_ISNEWTAG
        from (
            select ISNEWTAG 
            from TF_B_TRADE_CASHGIFT 
            where cardno = p_cardNo 
            and TRADETYPECODE = '52' --����
            order by OPERATETIME desc
        )
		where rownum = 1;
        if v_ISNEWTAG is null then --��������»��յļ�¼
            -- ������ʱ���Ƿ񳬹�4����
            if add_months(v_reclaimtime, 4) > sysdate then
            raise_application_error(-20106, '��Ƭ����ʱ��Ϊ'
                || to_char(v_reclaimtime, 'yyyy-MM-dd')
                || ', ���ճ���4���º�������ۿ�');
            end if;		
		end if;
		
        if v_cardDept <> p_currDept then
            raise_application_error(-20210, '��Ƭ�������㲻�ǵ�ǰ����');
        end if;
    else
        raise_application_error(-20207, '��Ƭ���״̬���ǳ�����߻���״̬');
    end if;

    ---����Ӫҵ����ֵ�޶� add by liuhe20121113
    SELECT COUNT(*) INTO V_TAGCOUNT
    FROM TD_M_TAG  WHERE TAGCODE='PROXY_CHARGE_LIMIT' AND USETAG='1';

    IF V_TAGCOUNT = 1 THEN
            SELECT  COUNT(*) INTO V_DEPTCOUNT
            FROM     TF_DEPT_BALUNIT B , TD_DEPTBAL_RELATION R
            WHERE     B.DBALUNITNO = R.DBALUNITNO
                    AND B.DEPTTYPE = '1'
                    AND R.USETAG = '1'
                    AND B.USETAG = '1'
                    AND R.DEPARTNO = P_CURRDEPT;
            IF V_DEPTCOUNT = 1 THEN--����Ǵ���Ӫҵ��
                --��ѯ��ֵ�޶�
                SELECT TAGVALUE INTO V_TAGMONEY FROM TD_M_TAG WHERE TAGCODE='PROXY_CHARGE_LIMIT' AND USETAG='1';
                ---������մ����ֵ�ܶ�����õ���������ʾ����
                IF p_saleMoney > V_TAGMONEY THEN
                    P_RETCODE := 'A009010091';
                    P_RETMSG := '�ڴ���������ſ��ۿ����ܳ���'||V_TAGMONEY/100.00||'Ԫ';
                RETURN;
                END IF;
            END IF;
    END IF;

    if p_submit != '1' then
        p_retCode := '0000000000';
        p_retMsg  := '';
        return;
    end if;

    -- ��ʼ�ۿ�����
    -- ���������������Ǯ��2�Ľ��
    if p_saleMoney <= p_cardPrice then
        raise_application_error(-20208, '��Ƭ������������Ѻ����');
    end if;

    -- ��������������С��1000Ԫ��add by liuhe20110922Դ��20110920�����ֵ���޵ĵ���
    if p_saleMoney > 100000 then
        raise_application_error(-20209, '��Ƭ������ܳ���һǧԪ');
    end if;

    if v_cardState = '04' then
        -- ����״̬���ۿ�ʱ�������ۿ�������ر�
        -- ���ݿ����ϱ�
        insert into TB_F_CARDREC(
            CARDNO,REUSEDATE,ASN,CARDTYPECODE,CARDSURFACECODE,CARDMANUCODE,
            CARDCHIPTYPECODE,APPTYPECODE,APPVERNO,DEPOSIT,CARDCOST,PRESUPPLYMONEY,
            CUSTRECTYPECODE,SELLTIME,SELLCHANNELCODE,DEPARTNO,STAFFNO,CARDSTATE,
            USETAG,SERSTARTTIME,SERTAKETAG,SERVICEMONEY,UPDATESTAFFNO,UPDATETIME,
            RSRV1,RSRV2,RSRV3,REMARK)
        select
            CARDNO,sysdate,ASN,CARDTYPECODE,CARDSURFACECODE,CARDMANUCODE,
            CARDCHIPTYPECODE,APPTYPECODE,APPVERNO,DEPOSIT,CARDCOST,PRESUPPLYMONEY,
            CUSTRECTYPECODE,SELLTIME,SELLCHANNELCODE,DEPARTNO,STAFFNO,CARDSTATE,
            USETAG,SERSTARTTIME,SERSTAKETAG,SERVICEMONEY,UPDATESTAFFNO,UPDATETIME,
            RSRV1,RSRV2,RSRV3,REMARK
        from TF_F_CARDREC
        where CARDNO = p_cardNo;

        delete from TF_F_CARDREC
        where CARDNO = p_cardNo;

        -- ����Ǯ���˻���
        insert into TB_F_CARDEWALLETACC(
            CARDNO,REUSEDATE,CARDACCMONEY,USETAG,CREDITSTATECODE,
            CREDITSTACHANGETIME,CREDITCONTROLCODE,CREDITCOLCHANGETIME,
            ACCSTATECODE,CONSUMEREALMONEY,SUPPLYREALMONEY,
            TOTALCONSUMETIMES,TOTALSUPPLYTIMES,TOTALCONSUMEMONEY,
            TOTALSUPPLYMONEY,FIRSTCONSUMETIME,LASTCONSUMETIME,
            FIRSTSUPPLYTIME,LASTSUPPLYTIME,OFFLINECARDTRADENO,
            ONLINECARDTRADENO,RSRV1,RSRV2,RSRV3,REMARK)
        select
            CARDNO,sysdate,CARDACCMONEY,USETAG,CREDITSTATECODE,
            CREDITSTACHANGETIME,CREDITCONTROLCODE,CREDITCOLCHANGETIME,
            ACCSTATECODE,CONSUMEREALMONEY,SUPPLYREALMONEY,
            TOTALCONSUMETIMES,TOTALSUPPLYTIMES,TOTALCONSUMEMONEY,
            TOTALSUPPLYMONEY,FIRSTCONSUMETIME,LASTCONSUMETIME,
            FIRSTSUPPLYTIME,LASTSUPPLYTIME,OFFLINECARDTRADENO,
            ONLINECARDTRADENO,RSRV1,RSRV2,RSRV3,REMARK
        from TF_F_CARDEWALLETACC
        where CARDNO = p_cardNo;

        delete from TF_F_CARDEWALLETACC
        where CARDNO = p_cardNo;

        -- �ͻ����ϱ�ֱ��ɾ��
        delete from TF_F_CUSTOMERREC
        where CARDNO = p_cardNo;
        
        --������ۿ�ʱ�����ж�,����ۿ�ʱ���ָ���𿨴��ڶ���������ϵ,��ô���ù�����ϵ�Ƴ���һ�����ݱ��� add by youyue 20130925
        select count(*) INTO V_COUNT FROM TF_F_CASHGIFTRELATION T WHERE T.CARDNO=p_cardNo;
        IF V_COUNT>0 THEN 
		      --�������𿨶�����ϵ��
		      INSERT INTO TF_B_CASHGIFTRELATION(
		      ORDERNO   ,CARDNO   ,UPDATESTAFFNO   ,UPDATETIME)
		      SELECT 
		      ORDERNO   ,CARDNO  , p_currOper      ,v_today
		      FROM TF_F_CASHGIFTRELATION
		      WHERE CARDNO = p_cardNo;
		      
		      --ɾ�����𿨶�����ϵ��
		      delete from TF_F_CASHGIFTRELATION
		      where CARDNO = p_cardNo;
        
        END IF;

    end if;

    -- �������ȡ���serTakeTagΪ5
    -- �ͻ���������custRecTypeCodeΪ0
    SP_PB_SaleCard(p_ID,
        p_cardNo, p_cardPrice, 0, 0, p_cardTradeNo, v_cardType,
        0, p_sellChannelCode, '5', v_tradeTypeCode,p_custName,
        p_custSex, p_custBirth, p_paperType, p_paperNo, p_custAddr,
        p_custPost, p_custPhone, p_custEmail, p_remark,
        '0', p_terminalNo, p_currCardNo,
        v_today, p_seqNO, p_currOper, p_currDept, p_retCode, p_retMsg);

    if p_retCode != '0000000000' then
        rollback; return;
    end if;

    select 'startCashGiftCard(''' || to_char(v_today, 'yyyymmdd') || ''','''
        || p_expiredDate || ''', ' || (p_saleMoney - p_cardPrice) || ');'
    into p_writeCardScript
    from dual;

    -- ����д��̨��cardtradeno
    update TF_CARD_TRADE t
    set    t.cardtradeno     = p_cardTradeNo,
           t.lMoney          = p_saleMoney - p_cardPrice,
           t.writeCardScript = p_writeCardScript
    where  t.tradeid = p_seqNO;

    -- ������ƬʧЧ����
    update TF_F_CARDREC t
    set    t.VALIDENDDATE = p_expiredDate
    where  t.CARDNO       = p_cardNo;

    -- �����ֽ�̨�ʣ����ӳ�ֵ���
    update TF_B_TRADEFEE t
    set    t.SUPPLYMONEY = p_saleMoney - p_cardPrice
    where  t.TRADEID = p_seqNO;

    -- �������˻���Ϣ
    update TF_F_CARDEWALLETACC t
    set    t.CARDACCMONEY     = p_saleMoney,
           t.SUPPLYREALMONEY  = p_saleMoney,
           t.FIRSTCONSUMETIME = v_today,
           t.TOTALSUPPLYTIMES = 1,
           t.TOTALSUPPLYMONEY = p_saleMoney,
           t.LASTSUPPLYTIME   = v_today
    where  t.CARDNO           = p_cardNo;

    -- ����Ӫҵ���ֿ�Ԥ������ݱ�֤���޸Ŀ��쿨��ȣ�add by yin 20120104
      BEGIN
      SP_PB_DEPTBALFEE(p_seqNO, '3' ,--1Ԥ����,2��֤��,3Ԥ����ͱ�֤��
                     p_saleMoney,
                     v_today,p_currOper,p_currDept,p_retCode,p_retMsg);

     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000';
    p_retMsg  := '';
    commit; return;

exception when others then
    p_retcode := sqlcode;
    p_retmsg  := lpad(sqlerrm, 127);
    rollback; return;
end;



/
show errors

