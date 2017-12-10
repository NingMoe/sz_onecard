create or replace procedure SP_PB_Query
(
    p_funcCode   varchar2,
    p_var1       varchar2,
    p_var2       varchar2,
    p_var3       varchar2,
    p_var4       varchar2,
    p_var5       varchar2,
    p_var6       varchar2,
    p_var7       varchar2,
    p_var8       varchar2,
    p_var9       varchar2,
    p_cursor out SYS_REFCURSOR
)
as
    v_idx       pls_integer;
    v_mon       pls_integer;
    v_tradeType char(2);
    v_tmp       varchar2(128);
    v_sellTime  date;
    v_toCardNo  char(16);
    v_badCardNo varchar2(1024);
begin
if p_funcCode = 'ChkAdvSaleCardRollback' then -- 高级售卡返销判断是否跨月返销（自然月）
    v_badCardNo := null;
    for v_c in (select f0, f1 from tmp_common)
    loop
        select nvl(v_c.f1, v_c.f0) into v_toCardNo from dual;
        for v_c2 in (select cardno, selltime from tf_f_cardrec where cardno between v_c.f0 and v_toCardNo)
        loop
            if trunc(sysdate, 'MM') != trunc(v_c2.selltime, 'MM') then
                if v_badCardNo is null then
                    v_badCardNo := v_c2.cardno;
                else
                    v_badCardNo := v_badCardNo || ',' || v_c2.cardno;
                end if;
            end if;
        end loop;
    end loop;

    open p_cursor for
    select v_badCardNo from dual where v_badCardNo is not null;

elsif p_funcCode = 'QryCardBalanceChange' then
    open p_cursor for
    select tf.TRADEID, tf.CARDNO,
        tf.PREBALANCE/100.0 PREBALANCE, tf.NEWBALANCE/100.0 NEWBALANCE,
        nvl2(s.staffname, tf.SUBMITSTAFF || ':' || s.staffname, tf.SUBMITSTAFF) SUBMITSTAFF,
        tf.SUBMITTIME, tf.CHECKSTATE
    from TF_SPECIAL_CHNAGEBALANCE tf, td_m_insidestaff s
    where CHECKSTATE = '0'
    and tf.SUBMITSTAFF = s.staffno(+);

elsif p_funcCode = 'ChkCardBalanceChange' then
    open p_cursor for
        select 1
        from tf_b_trade t
        where t.oldcardno = p_var1
        and   t.canceltag = '0'
        and   trunc(t.OPERATETIME, 'DD') <= sysdate -7    -- 7日后
        and   t.tradetypecode in ('03') -- 03 换卡
        and   t.REASONCODE in ('14', '15') -- 不可读
    union all
        select 1
        from tf_b_trade t
        where t.cardno = p_var1
        and   t.canceltag = '0'
        and   trunc(t.OPERATETIME, 'DD') <= sysdate -7    -- 7日后
        and   t.tradetypecode in ('05') -- 05 退卡
        and   t.REASONCODE in ('14', '15') -- 不可读
    union all
        select 1
        from tf_b_trade t
        where t.cardno = p_var1
        and   t.canceltag = '0'
        and   trunc(t.OPERATETIME, 'DD') <= sysdate -7    -- 7日后
        and   t.tradetypecode in ('7K') -- 7K 旅游卡回收（退卡）
        and   t.REASONCODE in ('14', '15') -- 不可读
    ;
elsif p_funcCode = 'ChkSMKCardBalanceChange' then
    open p_cursor for
        select 1
        from tf_b_trade t
        where t.cardno = p_var1
        and   t.canceltag = '0'
        and   trunc(t.OPERATETIME, 'DD') <= sysdate -7    -- 7日后
        and   t.tradetypecode in ('5C') -- 5C 市民卡换卡
        and   t.REASONCODE in ('14', '15') -- 不可读
    union all
        select 1
        from tf_b_trade t
        where t.cardno = p_var1
        and   t.canceltag = '0'
        and   trunc(t.OPERATETIME, 'DD') <= sysdate -7    -- 7日后
        and   t.tradetypecode in ('05') -- 05 退卡
        and   t.REASONCODE in ('14', '15') -- 不可读
    union all
        select 1
        from tf_b_trade t
        where t.cardno = p_var1
        and   t.canceltag = '0'
        and   trunc(t.OPERATETIME, 'DD') <= sysdate -7    -- 7日后
        and   t.tradetypecode in ('7K') -- 7K 旅游卡回收（退卡）
        and   t.REASONCODE in ('14', '15') -- 不可读
    ;

elsif p_funcCode = 'QryAccInfo' then
    open p_cursor for
    select cardaccmoney/100.0
    from TF_F_CARDEWALLETACC
    where cardno = p_var1;

elsif p_funcCode = 'QryLastConsumeTrades' then
    -- 查询最近三笔消费，三笔充值记录
    open p_cursor for
    select * from (
        SELECT a.CARDTRADENO 卡交易号, to_date(a.TRADEDATE|| a.TRADETIME, 'yyyymmddhh24miss') 消费时间,
               a.PREMONEY/100.0 消费前￥, a.TRADEMONEY/100.0 消费￥,
               (a.PREMONEY - a.TRADEMONEY)/100.0  消费后￥
        FROM TQ_TRADE_RIGHT a
        WHERE a.CARDNO = p_var1
        ORDER BY a.CARDTRADENO DESC
    )
    where rownum <= 3;

elsif p_funcCode = 'QryLastSupplyTrades' then

    open p_cursor for
    select * from (
        SELECT a.CARDTRADENO 卡交易号, to_date(a.TRADEDATE|| a.TRADETIME, 'yyyymmddhh24miss') 充值时间,
            a.PREMONEY/100.0 充值钱￥, a.TRADEMONEY/100.0 充值￥,
            (a.PREMONEY + a.TRADEMONEY)/100.0 充值后￥
        FROM TQ_SUPPLY_RIGHT a
        WHERE a.CARDNO = p_var1
        ORDER BY a.CARDTRADENO DESC
    )
    where rownum <= 3;

elsif p_funcCode = 'CheckParkInfoWhenSale' then
    begin
        select t.selltime into v_sellTime
        from TF_F_CARDREC t where t.cardno = p_var1;

        if v_sellTime is not null and
          v_sellTime >= to_date('2008-11-01', 'yyyy-mm-dd') then
            open p_cursor for
            select 1 from dual
            where exists(
                select 1 from tf_f_cardparkacc_sz
                where cardno = p_var1 and enddate <> 'FFFFFFFF')
            or exists (
                select 1 from tf_f_cardxxparkacc_sz
                where cardno = p_var1 and enddate <> 'FFFFFFFF');
            return;
        end if;
    exception when others then null;
    end;

    open p_cursor for
    select 1 from dual where 1 < 0;

elsif p_funcCode = 'QueryCardRecords' then
    open p_cursor for
    SELECT b.CARDNO 卡号, to_char(a.SEQ) 序号,a.CARDTRADENO 卡交易号,
    decode(a.ICTRADETYPECODE, '01', '圈存', '03', '圈提', '04', '取款', '05', '消费', a.ICTRADETYPECODE) 类型,
    cast(a.TRADEMONEY as int)/100.0 交易金额, cast(a.PREMONEY as int)/100.0 交易前金额, a.SAMNO 终端,
    substr(a.TRADEDATE, 1, 4) || '-' || substr(a.TRADEDATE, 5, 2) || '-' || substr(a.TRADEDATE, 7, 2) || ' ' ||
    substr(a.TRADETIME, 1, 2) || ':' || substr(a.TRADETIME, 3, 2) || ':' || substr(a.TRADETIME, 5, 2) 交易时间,
    b.OPERATETIME 保存时间
    FROM TF_CARD_RECLIST a,TF_CARD_RECQUY b
    WHERE a.TRADEID = b.TRADEID
    --AND   b.OPERATETIME between trunc(sysdate, 'dd') and sysdate
    AND  (p_var1 is null or p_var1 = ''
        or length(p_var1) = 16 and p_var1 = b.CARDNO
        or b.CARDNO like '%' || p_var1
         )
    ORDER BY b.OPERATETIME desc, a.SEQ desc;

elsif p_funcCode = 'SaveTempRecords' then
    v_idx := 0;
    v_mon := cast(p_var9 as int);

    delete from TMP_PB_ReadRecord where SessionId = p_var1;
    loop
        v_tradeType := substr(p_var5, 2 * v_idx + 1, 2);
        if v_tradeType = '01' then --圈存
            v_mon := v_mon - cast(substr(p_var4, 8 * v_idx + 1, 8) as int);
        else
            v_mon := v_mon + cast(substr(p_var4, 8 * v_idx + 1, 8) as int);
        end if;

        insert into TMP_PB_ReadRecord(SESSIONID, ID, CARDTRADENO,
            TRADEMONEY, ICTRADETYPECODE, SAMNO,
            TRADEDATE, TRADETIME, PREMONEY) values
            (
             p_var1,                            -- SESSIONID
             v_idx ,                            -- ID
             substr(p_var3, 4 * v_idx + 1, 4),      -- CARDTRADENO
             substr(p_var4, 8 * v_idx + 1, 8),      -- TRADEMONEY
             v_tradeType,                           -- ICTRADETYPECODE
             substr(p_var6, 12 * v_idx + 1, 12),    -- SAMNO
             substr(p_var7, 8 * v_idx + 1, 8),      -- TRADEDATE
             substr(p_var8, 6 * v_idx + 1, 6),      -- TRADETIME
             v_mon                                  -- PREMONEY
            );

        v_idx := v_idx + 1;
        exit when v_idx = 10;
    end loop;

    open p_cursor for
    SELECT p_var2 卡号, to_char(ID) 序号,CARDTRADENO 卡交易号,
        decode(ICTRADETYPECODE, '01', '圈存', '03', '圈提', '04', '取款', '05', '消费', ICTRADETYPECODE) 类型,
        cast(TRADEMONEY as int)/100.0 交易金额, cast(PREMONEY as int)/100.0 交易前金额, SAMNO 终端,
        substr(TRADEDATE, 1, 4) || '-' || substr(TRADEDATE, 5, 2) || '-' || substr(TRADEDATE, 7, 2) || ' ' ||
        substr(TRADETIME, 1, 2) || ':' || substr(TRADETIME, 3, 2) || ':' || substr(TRADETIME, 5, 2) 交易时间
    FROM TMP_PB_ReadRecord
    where SessionId = p_var1
    ORDER BY ID;

elsif p_funcCode = 'QueryCardNo' then
    open p_cursor for
    select CARDNO FROM TF_F_CARDREC
    WHERE CARDNO like '%' || p_var1;

elsif p_funcCode = 'QueryCustBiz' then
    --查询客户业务
    open p_cursor for
    SELECT a.TRADEID 流水号, a.OPERATETIME 操作时间,
    b.TRADETYPE 类型,
    (case
     when a.TRADETYPECODE = '14' then s.CZCARDNO
     when a.TRADETYPECODE = '02' then a.CARDTRADENO
     when a.TRADETYPECODE = '5A' then a.RSRV2
     when a.TRADETYPECODE = '5B' then a.RSRV2
     else a.OLDCARDNO
     end) PS,
        a.PREMONEY/100.0 交易前￥,
        a.CURRENTMONEY/100.0 交易￥,
        (a.PREMONEY + a.CURRENTMONEY)/100.0 交易后￥,
        c.DEPARTNAME 部门
    FROM TF_B_TRADE a,TD_M_TRADETYPE b,TD_M_INSIDEDEPART c, TF_CZC_SELFSUPPLY s
    WHERE a.CARDNO = p_var1
    AND a.OPERATETIME BETWEEN TO_DATE(p_var2,'YYYYMMDD') AND TO_DATE(p_var3,'YYYYMMDD') + 1
    AND a.TRADETYPECODE = b.TRADETYPECODE
    AND a.OPERATEDEPARTID = c.DEPARTNO(+)
    AND a.TRADEID = s.TRADEID(+)
    ORDER BY a.OPERATETIME DESC, a.ID DESC
    ;

elsif p_funcCode = 'QueryConsumeInfo' then
    --查询消费信息
    open p_cursor for
    select * from (SELECT a.CARDTRADENO 卡交易号, to_date(a.TRADEDATE|| a.TRADETIME, 'yyyymmddhh24miss') 交易时间,
           a.PREMONEY/100.0 交易前￥,
           a.TRADEMONEY/100.0 交易￥,
           (a.PREMONEY - a.TRADEMONEY)/100.0 交易后￥,
           b.CALLING 行业,c.CORP 单位,a.POSNO POS号, a.SAMNO SAM号,'' 备注
    FROM TQ_TRADE_RIGHT a,TD_M_CALLINGNO b,TD_M_CORP c,TD_M_DEPART d
    WHERE a.CARDNO = p_var1
    AND a.TRADEDATE BETWEEN p_var2 AND p_var3
    AND a.CALLINGNO = b.CALLINGNO(+) AND a.CORPNO = c.CORPNO(+)
    AND a.DEPARTNO = d.DEPARTNO(+)
  union all
    SELECT a.CARDTRADENO 卡交易号, to_date(a.TRADEDATE|| a.TRADETIME, 'yyyymmddhh24miss') 交易时间,
           0 交易前￥,
           a.TRADEMONEY/100.0 交易￥,
           0 交易后￥,
           b.CALLING 行业,c.CORP 单位,'' POS号, '' SAM号,'轻轨补录' 备注
    FROM TF_B_LRTTRADE_MANUAL a,TD_M_CALLINGNO b,TD_M_CORP c,TD_M_DEPART d
    WHERE a.CARDNO = p_var1
    AND a.TRADEDATE BETWEEN p_var2 AND p_var3
    AND a.CALLINGNO = b.CALLINGNO(+) AND a.CORPNO = c.CORPNO(+)
    AND a.DEPARTNO = d.DEPARTNO(+)
    AND a.CHECKSTATECODE = '1') temp
    order by temp.卡交易号 desc

   ;

elsif p_funcCode = 'QuerySpeloadConsumeInfo' then
    --查询消费信息
    open p_cursor for
    SELECT a.CARDTRADENO 卡交易号, to_date(a.TRADEDATE|| a.TRADETIME, 'yyyymmddhh24miss') 交易时间,
           a.PREMONEY/100.0 交易前￥,
           a.TRADEMONEY/100.0 交易￥,
           (a.PREMONEY - a.TRADEMONEY)/100.0 交易后￥,
           b.CALLING 行业,c.CORP 单位,a.POSNO POS号, a.SAMNO SAM号,'' 备注
    FROM TQ_TRADE_RIGHT a,TD_M_CALLINGNO b,TD_M_CORP c,TD_M_DEPART d
    WHERE a.CARDNO = p_var1
    AND a.TRADEDATE BETWEEN p_var2 AND p_var3
    AND a.CALLINGNO = b.CALLINGNO(+) AND a.CORPNO = c.CORPNO(+)
    AND a.DEPARTNO = d.DEPARTNO(+)
    ORDER BY a.CARDTRADENO DESC;


elsif p_funcCode = 'QueryChargeInfo' then
    --查询充值信息
    open p_cursor for
    SELECT a.ID 流水号,a.CARDTRADENO 卡交易号,
        to_date(a.TRADEDATE|| a.TRADETIME, 'yyyymmddhh24miss') 交易时间,
        e.TRADETYPE 类型 ,
        (case
         when a.TRADETYPECODE = '14' then s.CZCARDNO
         else ''
         end) PS,
        a.PREMONEY/100.0 交易前￥,
        a.TRADEMONEY/100.0 交易￥,
        (a.PREMONEY + a.TRADEMONEY)/100.0 交易后￥,
        ( case when a.balunitno is not null then a.balunitno
          else
               case when a.departno is not null then d.depart
               else a.staffno
               end
          end) 部门,
         (select TF_B_REFUND.Factmoney/100.0 from TF_B_REFUND where TF_B_REFUND.id = a.id) 退款金额
    FROM TQ_SUPPLY_RIGHT a,TD_M_CALLINGNO b,TD_M_CORP c,TD_M_DEPART d,TD_M_TRADETYPE e, TF_CZC_SELFSUPPLY s
    WHERE a.CARDNO = p_var1
    AND a.TRADEDATE BETWEEN p_var2 AND p_var3
    AND a.CALLINGNO = b.CALLINGNO(+) AND a.CORPNO = c.CORPNO(+)
    AND a.DEPARTNO = d.DEPARTNO(+)
    AND a.TRADETYPECODE = e.TRADETYPECODE(+)
    AND a.ID = s.ID(+)
    ORDER BY a.CARDTRADENO DESC,a.ID DESC;

elsif p_funcCode = 'QueryChargeCardValue' then
    --查询充值信息
    open p_cursor for
    SELECT V.MONEY/100.0
    FROM TD_XFC_INITCARD T, TP_XFC_CARDVALUE V
    WHERE T.NEW_PASSWD = p_var1
    AND   T.VALUECODE = V.VALUECODE;

elsif p_funcCode = 'QueryOpenFuncs' then
    --查询开通功能项
    open p_cursor for
    SELECT NVL(F.FUNCTIONNAME, C.FUNCTIONTYPE) || FUN_QUERYPACKAGETYPE(C.RSRV1) FUNCNAME
    FROM TD_M_FUNCTION F, TF_F_CARDUSEAREA C
    WHERE C.CARDNO = p_var1
    AND   C.USETAG = '1'
    AND   (C.ENDTIME IS NULL OR C.ENDTIME >= TO_CHAR(SYSDATE, 'YYYYMMDD'))
    AND   C.FUNCTIONTYPE = F.FUNCTIONTYPE(+);
elsif p_funcCode = 'QueryChangeCardHistory' then
    --查询换卡历史
    open p_cursor for
    select distinct tradeid 流水号, tradetypecode || ':' || tradetype 业务类型,
           CARDNO 新卡号, OLDCARDNO 旧卡号,
           decode(reasoncode, '11', '11:可读正常卡', '12', '12:可读人为损坏卡',
                              '13', '13:可读自然损坏卡', '14', '14:不可读人为损坏卡',
                              '15', '15:不可读自然损坏卡', reasoncode) 换卡类型,
           CARDSERVFEE/100.0 新卡卡费, CARDDEPOSITFEE/100.0 新卡押金,
           decode(CARDSTATE, '02', '02:已转值', CARDSTATE || ':未转值') 转值状态,
           operatetime 换卡时间, operatestaffno || ':' ||  staffname 换卡员工
    from (select t.tradeid, t.tradetypecode, nvl(r.tradetype, '') tradetype, t.CARDNO, t.OLDCARDNO,
           t.operatetime, t.operatestaffno, nvl(s.staffname, '') staffname,
           t.reasoncode, f.CARDSERVFEE, f.CARDDEPOSITFEE, c.CARDSTATE
          from   TF_B_TRADE t, td_m_insidestaff s, td_m_tradetype r, TF_B_TRADEFEE f, TF_F_CARDREC c
          where  t.tradetypecode <> '04' -- 剔除转值业务
          and    t.cardno is not null and  t.OLDCARDNO is not null
          and    t.canceltag = '0' and t.canceltradeid is null
          and    t.tradetypecode  = r.tradetypecode(+)
          and    t.operatestaffno = s.staffno(+)
          and    t.tradeid        = f.tradeid(+)
          and    t.OLDCARDNO      = c.cardno (+)
         )
    start with (cardno = p_var1 or oldcardno = p_var1)
    CONNECT BY NOCYCLE (PRIOR oldcardno  = cardno or PRIOR cardno = oldcardno  )
    order by 1 desc;

elsif p_funcCode = 'QueryReturnCardHistory' then
    --查询退卡/销户历史
    open p_cursor for
    select decode(t.tradetypecode, '05', '退卡', '06', '销户') 操作类型,
           t.operatestaffno || ':' || s.staffname 操作员工, t.operatetime 操作时间,
           decode(reasoncode, '11', '11:可读正常卡', '12', '12:可读人为损坏卡',
                              '13', '13:可读自然损坏卡', '14', '14:不可读人为损坏卡',
                              '15', '15:不可读自然损坏卡', reasoncode) 退卡类型,
           f.CARDDEPOSITFEE/100.0 退还押金, f.SUPPLYMONEY/100.0 退值
    from   TF_B_TRADE t, td_m_insidestaff s, TF_B_TRADEFEE f
    where  t.cardno = p_var1
    and    t.tradetypecode in ('05', '06')
    and    t.canceltag = '0' and t.canceltradeid is null
    and    t.operatestaffno = s.staffno(+)
    and    t.tradeid        = f.tradeid(+)
    order by t.tradeid
    ;

elsif p_funcCode = 'RollbackPermit' then
    --返销授权查询
    open p_cursor for
        SELECT * FROM (
        Select a.TRADEID ID, a.CARDNO, a.CURRENTMONEY/100.0 SUPPLYMONEY,
               c.CZCARDNO XFCARDNO, b.STAFFNAME STAFFNO,a.OPERATETIME,
               decode(d.canceltag, '0', '已授权', '1', '已返销') CANCELTAG,
               e.staffname CANCELSTAFF, d.OPERATETIME CANCELTIME
        FROM TF_B_TRADE a, TD_M_INSIDESTAFF b, TF_CZC_SELFSUPPLY c,TF_B_FEEROLLBACK d,TD_M_INSIDESTAFF e
        where a.TRADETYPECODE = p_var1
        AND a.OPERATESTAFFNO = b.STAFFNO(+)
        AND d.operatestaffno = e.staffno(+)
        AND a.tradeid = d.canceltradeid(+)
        AND a.TRADEID = c.TRADEID(+)
        and (p_var2 is null or a.CARDNO = p_var2)
        and (p_var3 is null or a.OPERATESTAFFNO = p_var3)
        and (p_var4 is null or a.OPERATETIME
            BETWEEN TO_DATE(p_var4, 'YYYY-MM-DD') AND TO_DATE(p_var4, 'YYYY-MM-DD') + 1)
        and (p_var5 is null or d.canceltag = p_var5)
    and a.OPERATETIME >= add_months(SYSDATE,-6)--add by liuhe20150630 为了加快查询速度修改为只查近半年的数据
        ORDER BY a.OPERATETIME DESC)
        WHERE ROWNUM <= 200;

elsif p_funcCode = 'QueryDepositChange' then
    --修改卡押金查询
    open p_cursor for
        SELECT a.CARDNO 卡号,a.ASN 卡序列号,b.RESSTATE 库存状态,a.CARDPRICE/100.0 卡片单价
        FROM TL_R_ICUSER a,TD_M_RESOURCESTATE b
        WHERE a.CARDNO BETWEEN p_var1 AND p_var2
        AND b.RESSTATECODE = a.RESSTATECODE
        ORDER BY a.CARDNO;

elsif p_funcCode = 'QueryCardNoBySim' then
    -- 根据SIM串号查询卡号
    open p_cursor for
    select CARDNO from TF_R_SIMCARD where SIMNO = p_var1;

elsif p_funcCode = 'QuerySimByCardNo' then
    -- 根据卡号查询SIM串号
    open p_cursor for
    select SIMNO from TF_R_SIMCARD where CARDNO = p_var1;

elsif p_funcCode = 'QuerySimCardNo' then
    open p_cursor for
    select CARDNO IC卡号, SIMNO SIM串号
    from TF_R_SIMCARD
    where (p_var1 is null or p_var1 = CARDNO)
    and   (p_var2 is null or p_var2 = SIMNO);

elsif p_funccode = 'QueryInvalidLines' then
    for v_cur in (select cardno, simno from tmp_simcard_imp where sessionid=p_var1)
    loop
        select count(1) into v_idx from tmp_simcard_imp where cardno = v_cur.cardno and simno = v_cur.simno and  sessionid=p_var1;
        if v_idx > 1 then
            update tmp_simcard_imp set checkmsg = '卡号和sim号在文件中重复' where cardno = v_cur.cardno  and  sessionid=p_var1;
        else
            select count(1) into v_idx from tmp_simcard_imp where cardno = v_cur.cardno and  sessionid=p_var1;
            if v_idx > 1 then
                update tmp_simcard_imp set checkmsg = '卡号在文件中重复' where cardno = v_cur.cardno and  sessionid=p_var1;
            else
                select count(1) into v_idx from tmp_simcard_imp where simno = v_cur.simno and  sessionid=p_var1;
                if v_idx > 1 then
                    update tmp_simcard_imp set checkmsg = 'sim号在文件中重复' where cardno = v_cur.cardno and  sessionid=p_var1;
                else
                    select count(1) into v_idx from tf_r_simcard where cardno = v_cur.cardno and simno = v_cur.simno;
                    if v_idx > 0 then
                        update tmp_simcard_imp set checkmsg = '卡号和sim号对应关系已经存在' where cardno = v_cur.cardno and  sessionid=p_var1;
                    else
                        select count(1) into v_idx from tf_r_simcard where cardno = v_cur.cardno;
                        if v_idx > 0 then
                            select simno into v_tmp from tf_r_simcard where cardno = v_cur.cardno;
                            update tmp_simcard_imp set checkmsg = '卡号已经对应到sim号:' || v_tmp where cardno = v_cur.cardno;
                        else
                            select count(1) into v_idx from tf_r_simcard where simno = v_cur.simno;
                            if v_idx > 0 then
                                select cardno into v_tmp from tf_r_simcard where simno = v_cur.simno;
                                update tmp_simcard_imp set checkmsg = 'sim号已经对应到卡号:' || v_tmp where cardno = v_cur.cardno;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end loop;
    -- 查询对应中有多少不合法
    open p_cursor for
    select rownum 文件行号, cardno 卡号, simno SIM串号, nvl(checkmsg , 'OK') 检查结果
    from tmp_simcard_imp
    where checkmsg is not null and  sessionid=p_var1;

elsif p_funccode = 'QuerySimCard' then
    -- 查询对应关系
    open p_cursor for
    select rownum 文件行号,cardno 卡号, simno SIM串号, nvl(checkmsg , 'OK') 检查结果
    from tmp_simcard_imp where sessionid = p_var1;

elsif p_funcCode = 'QureyRefundInput' then

  delete from TMP_COMMON;
    --待审核的批量退款信息
  IF p_var1 = '0' THEN
    open p_cursor for
    select '可退' tradetype,t.tradeid,t.CardNo,t.tradedate,b.bank,t.bankaccno, backmoney/100.0 backmoney,t.custname,t.remark,DECODE(t.purPoseType,'1','对公','2','对私') purposetype,t.ID,t.BACKSLOPE
    from TF_B_REFUNDPL  t  inner join td_m_bank b on t.bankcode=b.bankcode
    where t.state=p_var1 order by t.id,t.tradedate desc;
  ELSIF P_VAR1 = '1' THEN
  insert into TMP_COMMON (f0,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11,f12)
  select '待查',t.tradeid,t.CardNo,t.tradedate,b.bank,t.bankaccno, backmoney/100.0 backmoney,t.custname,t.remark,DECODE(t.purPoseType,'1','对公','2','对私') purposetype,t.ID,s.TRADETIME,t.BACKSLOPE
    from TF_B_REFUNDPL  t  inner join td_m_bank b on t.bankcode=b.bankcode inner join tq_supply_right s on t.ID = s.ID
    where t.state=p_var1;

  FOR v_cur in (select f1,f2,f3,f11 from TMP_COMMON)
  loop
    select count(1) into v_idx from tq_supply_right where cardno = v_cur.f2 and ((tradedate > v_cur.f3) or (tradedate = v_cur.f3 and tradetime > v_cur.f11));
    if v_idx > 0 then
      update TMP_COMMON set f0 = '可查' where f1 = v_cur.f1;
    else
      select count(1) into v_idx from tq_trade_right where cardno = v_cur.f2 and ((tradedate > v_cur.f3) or (tradedate = v_cur.f3 and tradetime > v_cur.f11));
      if v_idx > 0 then
      update TMP_COMMON set f0 = '可查' where f1 = v_cur.f1;
      end if;
    end if;
  end loop;

  open p_cursor for
  select f0 tradetype,f1 tradeid,f2 CardNo,f3 tradedate,f4 bank,f5 bankaccno,f6 backmoney,f7 custname,f8 remark,f9 purposetype,f10 ID,f12 backslope from TMP_COMMON order by f10,f3 desc;
  END IF;
elsif p_funcCode = 'QureyRefundAll' then
    --所有相关退款信息
    open p_cursor for
    select t.tradeid,CardNo,t.tradedate,b.bank,t.bankaccno, backmoney,t.custname,t.remark ,t.backslope,
    decode(t.state ,'1','待审核','2''审核通过','3','作废') state
    from  TF_B_REFUNDPL  t   inner join td_m_bank b on t.bankcode=b.bankcode;
elsif p_funcCode = 'QureyStaffPERBUYCARD' then
    --所有个人购卡信息
    open p_cursor for
    Select DECODE(a.PAPERTYPE,'00','身份证','01','学生证','02','军官证','03','驾驶证','04','教师证') PAPERTYPE,a.PAPERNO,  a.NAME,a.BIRTHDAY,DECODE(a.SEX,'0','男','1','女') SEX,a.PHONENO,a.ADDRESS,  a.EMAIL,
            b.STARTCARDNO, b.ENDCARDNO,  b.BUYCARDDATE,b.BUYCARDNUM,b.CHARGEMONEY/100.0 CHARGEMONEY,b.BUYCARDMONEY/100.0 BUYCARDMONEY,b.REMARK,c.STAFFNO,c.OPERATETIME
    From TD_M_BUYCARDPERINFO a,tf_f_perbuycardreg b,TF_B_PERBUYCARD c
    Where a.PAPERTYPE=b.PAPERTYPE
          And a.PAPERNO=b.PAPERNO
          And b.ID=c.ID
          And (p_var3 is null or TO_DATE(b.BUYCARDDATE, 'YYYY-MM-DD') >= TO_DATE(p_var3, 'YYYY-MM-DD'))
          And (p_var4 is null or TO_DATE(b.BUYCARDDATE, 'YYYY-MM-DD') < TO_DATE(p_var4, 'YYYY-MM-DD'))
          And (p_var1 is null or a.NAME like '%'||p_var1||'%')
          And (p_var2 is null or a.PAPERNO like '%'||p_var2||'%')
          AND (p_var5 IS NULL OR c.STAFFNO = p_var5)
          AND  c.OPERATETYPECODE='01'
          ;
elsif p_funcCode = 'QureyUnitPERBUYCARD' then
    --所有个人购卡信息
    open p_cursor for
    Select DECODE(a.PAPERTYPE,'00','身份证','01','学生证','02','军官证','03','驾驶证','04','教师证') PAPERTYPE,a.PAPERNO,  a.NAME,a.BIRTHDAY,DECODE(a.SEX,'0','男','1','女') SEX,a.PHONENO,a.ADDRESS,  a.EMAIL,
            b.STARTCARDNO, b.ENDCARDNO,  b.BUYCARDDATE,b.BUYCARDNUM,b.CHARGEMONEY/100.0 CHARGEMONEY,b.BUYCARDMONEY/100.0 BUYCARDMONEY,b.REMARK,c.STAFFNO,c.OPERATETIME
    From TD_M_BUYCARDPERINFO a,tf_f_perbuycardreg b,TF_B_PERBUYCARD c,TD_DEPTBAL_RELATION t
    Where a.PAPERTYPE=b.PAPERTYPE
          And a.PAPERNO=b.PAPERNO
          And b.ID=c.ID
          AND t.DEPARTNO = c.CORPNO
          And (p_var3 is null or TO_DATE(b.BUYCARDDATE, 'YYYY-MM-DD') >= TO_DATE(p_var3, 'YYYY-MM-DD'))
          And (p_var4 is null or TO_DATE(b.BUYCARDDATE, 'YYYY-MM-DD') < TO_DATE(p_var4, 'YYYY-MM-DD'))
          And (p_var1 is null or a.NAME like '%'||p_var1||'%')
          And (p_var2 is null or a.PAPERNO like '%'||p_var2||'%')
          AND  t.DBALUNITNO = p_var5
          AND  c.OPERATETYPECODE='01'
          ;
elsif p_funcCode = 'QureyDeptPERBUYCARD' then
    --所有个人购卡信息
    open p_cursor for
    Select DECODE(a.PAPERTYPE,'00','身份证','01','学生证','02','军官证','03','驾驶证','04','教师证') PAPERTYPE,a.PAPERNO,  a.NAME,a.BIRTHDAY,DECODE(a.SEX,'0','男','1','女') SEX,a.PHONENO,a.ADDRESS,  a.EMAIL,
            b.STARTCARDNO, b.ENDCARDNO,  b.BUYCARDDATE,b.BUYCARDNUM,b.CHARGEMONEY/100.0 CHARGEMONEY,b.BUYCARDMONEY/100.0 BUYCARDMONEY,b.REMARK,c.STAFFNO,c.OPERATETIME
    From TD_M_BUYCARDPERINFO a,tf_f_perbuycardreg b,TF_B_PERBUYCARD c
    Where a.PAPERTYPE=b.PAPERTYPE
          And a.PAPERNO=b.PAPERNO
          And b.ID=c.ID
          And (p_var3 is null or TO_DATE(b.BUYCARDDATE, 'YYYY-MM-DD') >= TO_DATE(p_var3, 'YYYY-MM-DD'))
          And (p_var4 is null or TO_DATE(b.BUYCARDDATE, 'YYYY-MM-DD') < TO_DATE(p_var4, 'YYYY-MM-DD'))
          And (p_var1 is null or a.NAME like '%'||p_var1||'%')
          And (p_var2 is null or a.PAPERNO like '%'||p_var2||'%')
          AND  c.CORPNO = p_var5
          AND  c.OPERATETYPECODE='01'
          ;
elsif p_funcCode = 'QureyStaffCOMBUYCARD' then
    --所有单位购卡信息
    open p_cursor for
    Select a.COMPANYNAME,DECODE(a.COMPANYPAPERTYPE,'01','组织机构代码证','02','企业营业执照') COMPANYPAPERTYPE,a.COMPANYPAPERNO,
           b.NAME,DECODE(b.PAPERTYPE,'00','身份证','01','学生证','02','军官证','03','驾驶证','04','教师证') PAPERTYPE,b.PAPERNO,b.PHONENO,b.ADDRESS,b.EMAIL,b.OUTBANK,
           b.OUTACCT,b.STARTCARDNO,b.ENDCARDNO,b.BUYCARDDATE,b.BUYCARDNUM,
           b.BUYCARDMONEY/100.0 BUYCARDMONEY,b.CHARGEMONEY/100.0 CHARGEMONEY,b.REMARK,c.STAFFNO,c.OPERATETIME
    From TD_M_BUYCARDCOMINFO a,TF_F_COMBUYCARDREG b,TF_B_COMBUYCARD c
    Where a.COMPANYNO=b.COMPANYNO And c.ID=b.ID
          And (p_var1 is null or a.COMPANYNAME like '%'||p_var1||'%')
          And (p_var2 is null or a.COMPANYPAPERNO like '%'||p_var2||'%')
          And (p_var3 is null or b.NAME like '%'||p_var3||'%')
          And (p_var4 is null or b.PAPERNO like '%'||p_var4||'%')
          And (p_var5 is null or b.BUYCARDDATE >= p_var5)
          And (p_var6 is null or b.BUYCARDDATE < p_var6)
          AND (p_var7 IS NULL OR c.STAFFNO = p_var7)
          AND  c.OPERATETYPECODE='01'
          ;
elsif p_funcCode = 'QureyUnitCOMBUYCARD' then
    --所有单位购卡信息
    open p_cursor for
    Select a.COMPANYNAME,DECODE(a.COMPANYPAPERTYPE,'01','组织机构代码证','02','企业营业执照') COMPANYPAPERTYPE,a.COMPANYPAPERNO,
           b.NAME,DECODE(b.PAPERTYPE,'00','身份证','01','学生证','02','军官证','03','驾驶证','04','教师证') PAPERTYPE,b.PAPERNO,b.PHONENO,b.ADDRESS,b.EMAIL,b.OUTBANK,
           b.OUTACCT,b.STARTCARDNO,b.ENDCARDNO,b.BUYCARDDATE,b.BUYCARDNUM,
           b.BUYCARDMONEY/100.0 BUYCARDMONEY,b.CHARGEMONEY/100.0 CHARGEMONEY,b.REMARK,c.STAFFNO,c.OPERATETIME
    From TD_M_BUYCARDCOMINFO a,TF_F_COMBUYCARDREG b,TF_B_COMBUYCARD c,TD_DEPTBAL_RELATION t
    Where a.COMPANYNO=b.COMPANYNO And c.ID=b.ID
          AND t.DEPARTNO = c.CORPNO
          And (p_var1 is null or a.COMPANYNAME like '%'||p_var1||'%')
          And (p_var2 is null or a.COMPANYPAPERNO like '%'||p_var2||'%')
          And (p_var3 is null or b.NAME like '%'||p_var3||'%')
          And (p_var4 is null or b.PAPERNO like '%'||p_var4||'%')
          And (p_var5 is null or b.BUYCARDDATE >= p_var5)
          And (p_var6 is null or b.BUYCARDDATE < p_var6)
          AND  t.DBALUNITNO = p_var7
          AND  c.OPERATETYPECODE='01'
          ;
elsif p_funcCode = 'QureyDeptCOMBUYCARD' then
    --所有单位购卡信息
    open p_cursor for
    Select a.COMPANYNAME,DECODE(a.COMPANYPAPERTYPE,'01','组织机构代码证','02','企业营业执照') COMPANYPAPERTYPE,a.COMPANYPAPERNO,
           b.NAME,DECODE(b.PAPERTYPE,'00','身份证','01','学生证','02','军官证','03','驾驶证','04','教师证') PAPERTYPE,b.PAPERNO,b.PHONENO,b.ADDRESS,b.EMAIL,b.OUTBANK,
           b.OUTACCT,b.STARTCARDNO,b.ENDCARDNO,b.BUYCARDDATE,b.BUYCARDNUM,
           b.BUYCARDMONEY/100.0 BUYCARDMONEY,b.CHARGEMONEY/100.0 CHARGEMONEY,b.REMARK,c.STAFFNO,c.OPERATETIME
    From TD_M_BUYCARDCOMINFO a,TF_F_COMBUYCARDREG b,TF_B_COMBUYCARD c
    Where a.COMPANYNO=b.COMPANYNO And c.ID=b.ID
          And (p_var1 is null or a.COMPANYNAME like '%'||p_var1||'%')
          And (p_var2 is null or a.COMPANYPAPERNO like '%'||p_var2||'%')
          And (p_var3 is null or b.NAME like '%'||p_var3||'%')
          And (p_var4 is null or b.PAPERNO like '%'||p_var4||'%')
          And (p_var5 is null or b.BUYCARDDATE >= p_var5)
          And (p_var6 is null or b.BUYCARDDATE < p_var6)
          AND  c.CORPNO = p_var7
          AND  c.OPERATETYPECODE='01'
          ;
elsif p_funcCode = 'QueryStaffComBuyCardReg' then
        --查询单位购卡记录
        open p_cursor for
        SELECT
            tmb.COMPANYNAME   , tmb.COMPANYPAPERTYPE     , tmb.COMPANYPAPERNO    , tfc.NAME         ,
            tfc.PAPERTYPE     , tfc.PAPERNO              , tfc.PHONENO           , tfc.ADDRESS      ,
            tfc.EMAIL         , tfc.OUTBANK              , tfc.OUTACCT           , tfc.STARTCARDNO  ,
            tfc.ENDCARDNO     , tfc.BUYCARDDATE          , tfc.BUYCARDNUM        , tfc.BUYCARDMONEY/100.0  BUYCARDMONEY,
            tfc.CHARGEMONEY/100.0  CHARGEMONEY  , tfc.REMARK               , tfc.ID
        FROM    TF_F_COMBUYCARDREG tfc,TD_M_BUYCARDCOMINFO tmb,TF_B_COMBUYCARD tbc
        WHERE   tfc.COMPANYNO = tmb.COMPANYNO
        AND     tbc.ID = tfc.ID
        AND     (p_var1 IS NULL OR tfc.NAME = p_var1)
        AND     (p_var2 IS NULL OR tfc.PAPERTYPE = p_var2)
        AND     (p_var3 IS NULL OR tfc.PAPERNO = p_var3)
        AND     (p_var4 IS NULL OR tmb.COMPANYNAME = p_var4)
        AND     (p_var5 IS NULL OR tbc.STAFFNO = p_var5)
        AND     tbc.OPERATETYPECODE='01'
        ;
elsif p_funcCode = 'QueryUnitComBuyCardReg' then
        --查询单位购卡记录
        open p_cursor for
        SELECT
            tmb.COMPANYNAME   , tmb.COMPANYPAPERTYPE     , tmb.COMPANYPAPERNO    , tfc.NAME         ,
            tfc.PAPERTYPE     , tfc.PAPERNO              , tfc.PHONENO           , tfc.ADDRESS      ,
            tfc.EMAIL         , tfc.OUTBANK              , tfc.OUTACCT           , tfc.STARTCARDNO  ,
            tfc.ENDCARDNO     , tfc.BUYCARDDATE          , tfc.BUYCARDNUM        , tfc.BUYCARDMONEY/100.0  BUYCARDMONEY,
            tfc.CHARGEMONEY/100.0  CHARGEMONEY  , tfc.REMARK               , tfc.ID
        FROM    TF_F_COMBUYCARDREG tfc,TD_M_BUYCARDCOMINFO tmb,TF_B_COMBUYCARD tbc,TD_DEPTBAL_RELATION t
        WHERE   tfc.COMPANYNO = tmb.COMPANYNO
        AND     tbc.ID = tfc.ID
        AND     t.DEPARTNO = tbc.CORPNO
        AND     (p_var1 IS NULL OR tfc.NAME = p_var1)
        AND     (p_var2 IS NULL OR tfc.PAPERTYPE = p_var2)
        AND     (p_var3 IS NULL OR tfc.PAPERNO = p_var3)
        AND     (p_var4 IS NULL OR tmb.COMPANYNAME = p_var4)
        AND     t.DBALUNITNO = p_var5
        AND     tbc.OPERATETYPECODE='01'
        ;
elsif p_funcCode = 'QueryDeptComBuyCardReg' then
        --查询单位购卡记录
        open p_cursor for
        SELECT
            tmb.COMPANYNAME   , tmb.COMPANYPAPERTYPE     , tmb.COMPANYPAPERNO    , tfc.NAME         ,
            tfc.PAPERTYPE     , tfc.PAPERNO              , tfc.PHONENO           , tfc.ADDRESS      ,
            tfc.EMAIL         , tfc.OUTBANK              , tfc.OUTACCT           , tfc.STARTCARDNO  ,
            tfc.ENDCARDNO     , tfc.BUYCARDDATE          , tfc.BUYCARDNUM        , tfc.BUYCARDMONEY/100.0  BUYCARDMONEY,
            tfc.CHARGEMONEY/100.0  CHARGEMONEY  , tfc.REMARK               , tfc.ID
        FROM    TF_F_COMBUYCARDREG tfc,TD_M_BUYCARDCOMINFO tmb,TF_B_COMBUYCARD tbc
        WHERE   tfc.COMPANYNO = tmb.COMPANYNO
        AND     tbc.ID = tfc.ID
        AND     (p_var1 IS NULL OR tfc.NAME = p_var1)
        AND     (p_var2 IS NULL OR tfc.PAPERTYPE = p_var2)
        AND     (p_var3 IS NULL OR tfc.PAPERNO = p_var3)
        AND     (p_var4 IS NULL OR tmb.COMPANYNAME = p_var4)
        AND     tbc.CORPNO = p_var5
        AND     tbc.OPERATETYPECODE='01'
        ;
elsif p_funcCode = 'QueryStaffPerBuyCardReg' then
        --查询个人购卡记录
        open p_cursor for
        SELECT
            tfc.ID            , tmb.NAME                 , tmb.BIRTHDAY          , tmb.PAPERTYPE     ,
            tmb.PAPERNO       , tmb.SEX                  , tmb.PHONENO           , tmb.ADDRESS       ,
            tmb.EMAIL         , tfc.STARTCARDNO          , tfc.ENDCARDNO         , tfc.BUYCARDDATE   ,
            tfc.BUYCARDNUM    , tfc.BUYCARDMONEY/100.0 BUYCARDMONEY  , tfc.CHARGEMONEY/100.0   CHARGEMONEY  , tfc.REMARK
        FROM    TF_F_PERBUYCARDREG tfc,TD_M_BUYCARDPERINFO tmb ,TF_B_PERBUYCARD tbc
        WHERE   tfc.PAPERTYPE = tmb.PAPERTYPE
        AND     tfc.PAPERNO   = tmb.PAPERNO
        AND     tbc.ID = tfc.ID
        AND     (p_var1 IS NULL OR tmb.NAME = p_var1)
        AND     (p_var2 IS NULL OR tfc.PAPERTYPE = p_var2)
        AND     (p_var3 IS NULL OR tfc.PAPERNO = p_var3)
        AND     (p_var4 IS NULL OR tbc.STAFFNO = p_var4)
        AND     tbc.OPERATETYPECODE='01'
        ;
elsif p_funcCode = 'QueryUnitPerBuyCardReg' then
        --查询个人购卡记录
        open p_cursor for
        SELECT
            tfc.ID            , tmb.NAME                 , tmb.BIRTHDAY          , tmb.PAPERTYPE     ,
            tmb.PAPERNO       , tmb.SEX                  , tmb.PHONENO           , tmb.ADDRESS       ,
            tmb.EMAIL         , tfc.STARTCARDNO          , tfc.ENDCARDNO         , tfc.BUYCARDDATE   ,
            tfc.BUYCARDNUM    , tfc.BUYCARDMONEY/100.0 BUYCARDMONEY  , tfc.CHARGEMONEY/100.0   CHARGEMONEY  , tfc.REMARK
        FROM    TF_F_PERBUYCARDREG tfc,TD_M_BUYCARDPERINFO tmb ,TF_B_PERBUYCARD tbc,TD_DEPTBAL_RELATION t
        WHERE   tfc.PAPERTYPE = tmb.PAPERTYPE
        AND     tfc.PAPERNO   = tmb.PAPERNO
        AND     tbc.ID = tfc.ID
        AND     t.DEPARTNO = tbc.CORPNO
        AND     (p_var1 IS NULL OR tmb.NAME = p_var1)
        AND     (p_var2 IS NULL OR tfc.PAPERTYPE = p_var2)
        AND     (p_var3 IS NULL OR tfc.PAPERNO = p_var3)
        AND     t.DBALUNITNO = p_var4
        AND     tbc.OPERATETYPECODE='01'
        ;
elsif p_funcCode = 'QueryDeptPerBuyCardReg' then
        --查询个人购卡记录
        open p_cursor for
        SELECT
            tfc.ID            , tmb.NAME                 , tmb.BIRTHDAY          , tmb.PAPERTYPE     ,
            tmb.PAPERNO       , tmb.SEX                  , tmb.PHONENO           , tmb.ADDRESS       ,
            tmb.EMAIL         , tfc.STARTCARDNO          , tfc.ENDCARDNO         , tfc.BUYCARDDATE   ,
            tfc.BUYCARDNUM    , tfc.BUYCARDMONEY/100.0 BUYCARDMONEY  , tfc.CHARGEMONEY/100.0   CHARGEMONEY  , tfc.REMARK
        FROM    TF_F_PERBUYCARDREG tfc,TD_M_BUYCARDPERINFO tmb ,TF_B_PERBUYCARD tbc
        WHERE   tfc.PAPERTYPE = tmb.PAPERTYPE
        AND     tfc.PAPERNO   = tmb.PAPERNO
        AND     tbc.ID = tfc.ID
        AND     (p_var1 IS NULL OR tmb.NAME = p_var1)
        AND     (p_var2 IS NULL OR tfc.PAPERTYPE = p_var2)
        AND     (p_var3 IS NULL OR tfc.PAPERNO = p_var3)
        AND     tbc.CORPNO = p_var4
        AND     tbc.OPERATETYPECODE='01'
        ;
elsif p_funcCode = 'QueryCardToCardOutReg' then
        --查询卡卡转账待圈提记录
        open p_cursor for
        SELECT
        a.TRADEID    , a.OUTCARDNO     , a.MONEY/100.0 MONEY             ,
        a.OUTSTAFFNO||':'||c.staffname OUTSTAFFNO ,
        a.OUTDEPTNO||':'||b.departname OUTDEPTNO  ,
        a.OUTTIME    , a.REMARK
        FROM TF_B_CARDTOCARDREG a , TD_M_INSIDEDEPART b, TD_M_INSIDESTAFF c
        WHERE a.OUTCARDNO = P_VAR1
        AND   a.TRANSTATE = '0'
        AND   a.OUTSTAFFNO = c.STAFFNO(+)
        AND   a.OUTDEPTNO  = b.DEPARTNO(+)
        ORDER BY a.OUTTIME DESC
        ;
elsif p_funcCode = 'QueryCardToCardOut' then
        --查询卡卡转账待圈提业务记录
        open p_cursor for
        SELECT
            a.OUTCARDNO  , a.INCARDNO      , a.MONEY/100.0 MONEY                ,
            a.OUTSTAFFNO||':'||e.staffname OUTSTAFFNO ,
            a.OUTDEPTNO||':'||d.departname OUTDEPTNO  ,
            a.OUTTIME    ,
            a.INSTAFFNO||':'||c.staffname INSTAFFNO  ,
            a.INDEPTNO||':'||b.departname INDEPTNO   ,
            a.INTIME , a.REMARK  ,
            decode(a.TRANSTATE,'0','圈提待转账','1','已圈存',a.TRANSTATE) TRANSTATE
        FROM TF_B_CARDTOCARDREG a , TD_M_INSIDEDEPART b, TD_M_INSIDESTAFF c,TD_M_INSIDEDEPART d, TD_M_INSIDESTAFF e
        WHERE (P_VAR1 IS NULL OR P_VAR1 = '' OR a.OUTCARDNO = P_VAR1)
        AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR a.TRANSTATE = P_VAR2)
        AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_CHAR(a.OUTTIME,'yyyyMMdd') >= P_VAR3)
        AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR TO_CHAR(a.OUTTIME,'yyyyMMdd') <= P_VAR4)
        --AND   a.TRANSTATE = '1'
        AND   a.OUTSTAFFNO = e.STAFFNO(+)
        AND   a.OUTDEPTNO  = d.DEPARTNO(+)
        AND   a.INSTAFFNO = c.STAFFNO(+)
        AND   a.INDEPTNO  = b.DEPARTNO(+)
        ORDER BY a.OUTTIME DESC
        ;
elsif p_funcCode = 'QueryCardToCardIn' then
        --查询卡卡转账待圈存业务记录
        open p_cursor for
        SELECT
            a.OUTCARDNO  , a.INCARDNO     , a.MONEY/100.0 MONEY             ,
            a.INSTAFFNO||':'||c.staffname INSTAFFNO ,
            a.INDEPTNO||':'||b.departname INDEPTNO  ,
            a.INTIME     , a.REMARK       ,
            decode(a.TRANSTATE,'0','圈提待转账','1','已圈存',a.TRANSTATE) TRANSTATE
        FROM TF_B_CARDTOCARDREG a , TD_M_INSIDEDEPART b, TD_M_INSIDESTAFF c
        WHERE (P_VAR1 IS NULL OR P_VAR1 = '' OR a.INCARDNO = P_VAR1)
        AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_CHAR(a.INTIME,'yyyyMMdd') >= P_VAR2)
        AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_CHAR(a.INTIME,'yyyyMMdd') <= P_VAR3)
        AND   a.TRANSTATE = '1'
        AND   a.INSTAFFNO = c.STAFFNO(+)
        AND   a.INDEPTNO  = b.DEPARTNO(+)
        ORDER BY a.INTIME DESC
        ;
elsif p_funcCode = 'QueryTransitLimit' then
        --查询卡卡转账待圈存业务记录
        open p_cursor for
        SELECT
            a.TRADEID , a.CARDNO , decode(a.STATE,'0','添加','1','删除',a.STATE) STATE ,
            a.ADDTIME , a.DELETETIME ,
            (CASE WHEN a.ADDSTAFFNO IS NOT NULL THEN a.ADDSTAFFNO||':'||b.staffname ELSE NULL END )AS ADDSTAFFNO ,
            (CASE WHEN a.DELETESTAFFNO IS NOT NULL THEN a.DELETESTAFFNO||':'||c.staffname ELSE NULL END)AS DELETESTAFFNO ,
            a.REMARK
        FROM TF_B_TRANSITLIMIT a , TD_M_INSIDESTAFF b, TD_M_INSIDESTAFF c
        WHERE (P_VAR1 IS NULL OR P_VAR1 = '' OR a.CARDNO = P_VAR1)
        AND   a.STATE = P_VAR2
        AND   a.ADDSTAFFNO = b.STAFFNO(+)
        AND   a.DELETESTAFFNO = c.STAFFNO(+)
        ORDER BY a.ADDTIME DESC
        ;
elsif p_funcCode = 'QueryBatchSaleCard' then
        --查询批量售卡待审核记录
        open p_cursor for
        SELECT a.TRADEID   ,  a.BEGINCARDNO   ,   a.ENDCARDNO   ,   a.CARDDEPOSIT/100.00 CARDDEPOSIT,
               a.CARDCOST/100.00 CARDCOST,  a.SELLTIME      , a.OPERATESTAFFNO,  a.OPERATEDEPARTID,
               a.OPERATETIME, a.ENDCARDNO-a.BEGINCARDNO+1 SELLTIMES,
               (a.ENDCARDNO-a.BEGINCARDNO+1)*(a.CARDDEPOSIT+a.CARDCOST)/100.00 SELLMONEY,
               a.REMARK,b.staffname,c.departname
        FROM TF_B_BATCHSALECARD  a,TD_M_INSIDESTAFF b,TD_M_INSIDEDEPART c
        WHERE STATECODE='1'
              and a.operatestaffno=b.staffno
              and a.operatedepartid=c.departno;
elsif p_funcCode = 'Query_RefundNFC' then--NFC退款审核页面查询
    open p_cursor for
    SELECT  T.TRADEID,A.BALUNIT,T.CARDNO,T.ASN,T.CARDTRADENO,T.CARDOLDBAL/100.0 CARDOLDBAL,T.TRADEMONEY/100.0 TRADEMONEY,
    to_date(T.TRADEDATE|| T.TRADETIME, 'yyyymmddhh24miss') TRADEDATE,T.CUSTNAME,T.CUSTPHONE,T.REMARK,
    T.REFUNDSTATUS
    FROM TF_SUPPLY_REFUND T ,TD_BALUNITNO_TERMNO A
    WHERE  T.CHANNELNO=A.CHANNELNO
    AND (p_var1 IS NULL OR p_var1 = '' OR p_var1 = T.CARDNO)
    AND    T.REFUNDSTATUS=p_var2
    AND    (p_var3 IS NULL OR p_var3 = '' OR to_char(t.inlisttime,'yyyyMMdd')>= p_var3)
    AND    (p_var4 IS NULL OR p_var4 = '' OR to_char(t.inlisttime,'yyyyMMdd') <= p_var4)
    ORDER BY T.TRADEID DESC;
elsif p_funcCode = 'Query_RefundAPP' then--充值补登退款查询
    open p_cursor for
    SELECT  T.TRADEID,T.CARDNO,DECODE(T.CHANNELNO,'01','APP',t.channelno) CHANNELNO,T.TRADEMONEY/100.0 TRADEMONEY,DECODE(T.PAYMENTTYPE,'01','支付宝','02','微信','03','银联','04','专有账户',T.PAYMENTTYPE) PAYMENTTYPE,
    T.ACCOUNTNO,T.PAYMENTTRADEID,to_date(T.TRADETIME  ,'yyyymmddhh24miss') TRADETIME,
    T.PHONE,T.INLISTTIME,DECODE(T.ISREFUND,'0','否','1','是',T.ISREFUND) ISREFUND,T.REFUNDTIME,A.STAFFNAME
    FROM TF_OUT_ADDTRADE T ,TD_M_INSIDESTAFF A
    WHERE  T.REFUNDSTAFF=A.STAFFNO(+)
    AND (p_var1 IS NULL OR p_var1 = '' OR p_var1 = T.CARDNO)
    AND    ORDERSTATUS='0'
    AND    (p_var2 IS NULL OR p_var2 = '' OR substr(t.TRADETIME,0,8)>=p_var2)
    AND    (p_var3 IS NULL OR p_var3 = '' OR substr(t.TRADETIME,0,8)<=p_var3)
    ORDER BY T.TRADEID DESC;
elsif p_funcCode= 'QueryLossCard' then
    -- 查询对应挂失卡信息
    if p_var1='01' then
        --根据卡号
        open p_cursor for
        select tf_f_cardrec.cardno ,
               tf_f_cardewalletacc.cardaccmoney /100.0 cardaccmoney,
               tf_f_cardrec.cardtypecode,
               td_m_cardtype.cardtypename ,
               tf_f_customerrec.custname ,
               tf_f_customerrec.paperno ,
               tf_f_customerrec.custphone  ,
               to_char(tf_f_cardrec.updatetime,'yyyy-MM-dd')lossdate
        FROM TF_F_CARDREC, TF_F_CUSTOMERREC , TF_F_CARDEWALLETACC  , TD_M_CARDTYPE
        where tf_f_cardrec.cardno = tf_f_customerrec.cardno
        and tf_f_cardrec.cardno = tf_f_cardewalletacc.cardno
        and tf_f_cardrec.cardtypecode=td_m_cardtype.cardtypecode
        and tf_f_cardrec.cardstate ='03'
        and tf_f_customerrec.cardno = p_var2 and SUBSTR(tf_f_cardrec.cardno,0,6)!='215018';--市民卡在个人业务中不能做挂失卡转值
    elsif p_var1='02' then
       --根据身份证号
        open p_cursor for
        select tf_f_cardrec.cardno ,
               tf_f_cardewalletacc.cardaccmoney /100.0 cardaccmoney,
               tf_f_cardrec.cardtypecode,
               td_m_cardtype.cardtypename ,
               tf_f_customerrec.custname ,
               tf_f_customerrec.paperno ,
               tf_f_customerrec.custphone  ,
               to_char(tf_f_cardrec.updatetime,'yyyy-MM-dd')lossdate
        FROM TF_F_CARDREC, TF_F_CUSTOMERREC , TF_F_CARDEWALLETACC  , TD_M_CARDTYPE
        where tf_f_cardrec.cardno = tf_f_customerrec.cardno
        and tf_f_cardrec.cardno = tf_f_cardewalletacc.cardno
        and tf_f_cardrec.cardtypecode=td_m_cardtype.cardtypecode
        and tf_f_cardrec.cardstate ='03'
        and tf_f_customerrec.paperno =p_var2
        and length(tf_f_cardrec.cardno)!=8 and SUBSTR(tf_f_cardrec.cardno,0,6)!='215018';--市民卡在个人业务中不能做挂失卡转值
    end if;	
end if;
end;
/
