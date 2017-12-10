create or replace procedure SP_CG_SaleCard
(
    p_submit          char, -- 0 - 不提交售卡, 1 提交售卡处理
    p_cardNo          char, -- 读卡-卡号-16位卡号
    p_wallet1         int , -- 读卡-电子钱包余额1
    p_wallet2         int , -- 读卡-电子钱包余额2
    p_startDate       char, -- 读卡-起始有效期(yyyyMMdd)
    p_endDate         char, -- 读卡-结束有效期(yyyyMMdd)

    p_expiredDate     char, -- 输入失效日期(yyyyMMdd)
    p_saleMoney       int , -- 输入金额元

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

    v_cardType     tl_r_icuser.cardtypecode%type;    -- 卡片类型
    v_cardDept     tl_r_icuser.assigneddepartid%type;-- 所属部门
    v_reclaimtime  tl_r_icuser.reclaimtime%type;     -- 回收时间
    v_cardState    tl_r_icuser.resstatecode%type;    -- 卡片状态
    v_asn          tl_r_icuser.asn%type;
    v_ex           exception;
    V_TAGCOUNT           INT;
    V_DEPTCOUNT          INT;
    V_TAGMONEY           INT;
	v_ISNEWTAG       CHAR(1);
	V_COUNT         INT;
begin
    -- 0) 检查电子钱包1余额是否为0
    if p_wallet1 <> 0 then
        raise_application_error(-20101, '电子钱包余额为'
            || p_wallet1/100.0 || '元, 要求为0才能售卡' );
    end if;

    -- 1) 检查卡类型是否为礼金卡,卡片单价是否等于电子钱包2
    begin
        select t.cardtypecode, t.cardprice, t.resstatecode, t.assigneddepartid,
               t.reclaimtime, t.asn
        into   v_cardType, p_cardPrice, v_cardState, v_cardDept,
               v_reclaimtime, v_asn
        from   tl_r_icuser t
        where  t.cardno = p_cardNo;
    exception when no_data_found then
        raise_application_error(-20102, '卡片不存在于库存之中' );
    end;

    if v_cardType != '05' then
        raise_application_error(-20103, '卡片不是礼金卡类型' );
    end if;

    if p_cardPrice <> p_wallet2 then
        raise_application_error(-20104, '卡片库存价格为' || p_cardPrice/100.0
            || '元, 卡内钱包2为' || p_wallet2/100.0 || '元, 无法售卡');
    end if;

    -- 2) 检查库存状态
    if v_cardState in ('01', '05') then -- 出库分配状态
        v_tradeTypeCode := '50';
        -- 检查所属部门是不是当前部门
        if v_cardDept != p_currDept then
            raise_application_error(-20105, '卡片不属于当前部门');
        end if;
    elsif v_cardState = '04' then -- 回收状态
        v_tradeTypeCode := '51';
		
        select ISNEWTAG into v_ISNEWTAG
        from (
            select ISNEWTAG 
            from TF_B_TRADE_CASHGIFT 
            where cardno = p_cardNo 
            and TRADETYPECODE = '52' --回收
            order by OPERATETIME desc
        )
		where rownum = 1;
        if v_ISNEWTAG is null then --如果不是新回收的记录
            -- 检查回收时间是否超过4个月
            if add_months(v_reclaimtime, 4) > sysdate then
            raise_application_error(-20106, '卡片回收时间为'
                || to_char(v_reclaimtime, 'yyyy-MM-dd')
                || ', 回收超过4个月后才能再售卡');
            end if;		
		end if;
		
        if v_cardDept <> p_currDept then
            raise_application_error(-20210, '卡片归属网点不是当前网点');
        end if;
    else
        raise_application_error(-20207, '卡片库存状态不是出库或者回收状态');
    end if;

    ---代理营业厅充值限额 add by liuhe20121113
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
            IF V_DEPTCOUNT = 1 THEN--如果是代理营业厅
                --查询充值限额
                SELECT TAGVALUE INTO V_TAGMONEY FROM TD_M_TAG WHERE TAGCODE='PROXY_CHARGE_LIMIT' AND USETAG='1';
                ---如果当日代理充值总额超过配置的上限则提示错误
                IF p_saleMoney > V_TAGMONEY THEN
                    P_RETCODE := 'A009010091';
                    P_RETMSG := '在代理机构单张卡售卡金额不能超过'||V_TAGMONEY/100.00||'元';
                RETURN;
                END IF;
            END IF;
    END IF;

    if p_submit != '1' then
        p_retCode := '0000000000';
        p_retMsg  := '';
        return;
    end if;

    -- 开始售卡处理
    -- 检查输入金额，必须大于钱包2的金额
    if p_saleMoney <= p_cardPrice then
        raise_application_error(-20208, '卡片输入金额必须大于押金金额');
    end if;

    -- 检查输入金额，金额必须小于1000元，add by liuhe20110922源于20110920需求充值上限的调整
    if p_saleMoney > 100000 then
        raise_application_error(-20209, '卡片输入金额不能超过一千元');
    end if;

    if v_cardState = '04' then
        -- 回收状态再售卡时，备份售卡处理相关表
        -- 备份卡资料表
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

        -- 电子钱包账户表
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

        -- 客户资料表直接删除
        delete from TF_F_CUSTOMERREC
        where CARDNO = p_cardNo;
        
        --对礼金卡售卡时加以判断,如果售卡时发现该礼金卡存在订单关联关系,那么将该关联关系移出到一个备份表中 add by youyue 20130925
        select count(*) INTO V_COUNT FROM TF_F_CASHGIFTRELATION T WHERE T.CARDNO=p_cardNo;
        IF V_COUNT>0 THEN 
		      --备份利金卡订单关系表
		      INSERT INTO TF_B_CASHGIFTRELATION(
		      ORDERNO   ,CARDNO   ,UPDATESTAFFNO   ,UPDATETIME)
		      SELECT 
		      ORDERNO   ,CARDNO  , p_currOper      ,v_today
		      FROM TF_F_CASHGIFTRELATION
		      WHERE CARDNO = p_cardNo;
		      
		      --删除利金卡订单关系表
		      delete from TF_F_CASHGIFTRELATION
		      where CARDNO = p_cardNo;
        
        END IF;

    end if;

    -- 服务费收取标记serTakeTag为5
    -- 客户资料类型custRecTypeCode为0
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

    -- 修正写卡台帐cardtradeno
    update TF_CARD_TRADE t
    set    t.cardtradeno     = p_cardTradeNo,
           t.lMoney          = p_saleMoney - p_cardPrice,
           t.writeCardScript = p_writeCardScript
    where  t.tradeid = p_seqNO;

    -- 修正卡片失效日期
    update TF_F_CARDREC t
    set    t.VALIDENDDATE = p_expiredDate
    where  t.CARDNO       = p_cardNo;

    -- 修正现金台帐，增加充值金额
    update TF_B_TRADEFEE t
    set    t.SUPPLYMONEY = p_saleMoney - p_cardPrice
    where  t.TRADEID = p_seqNO;

    -- 修正卡账户信息
    update TF_F_CARDEWALLETACC t
    set    t.CARDACCMONEY     = p_saleMoney,
           t.SUPPLYREALMONEY  = p_saleMoney,
           t.FIRSTCONSUMETIME = v_today,
           t.TOTALSUPPLYTIMES = 1,
           t.TOTALSUPPLYMONEY = p_saleMoney,
           t.LASTSUPPLYTIME   = v_today
    where  t.CARDNO           = p_cardNo;

    -- 代理营业厅抵扣预付款，根据保证金修改可领卡额度，add by yin 20120104
      BEGIN
      SP_PB_DEPTBALFEE(p_seqNO, '3' ,--1预付款,2保证金,3预付款和保证金
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

