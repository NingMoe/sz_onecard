create or replace procedure SP_SD_SupplyDiffRec
(
    p_remark        varchar2,
    p_currOper      char,
    p_currDept      char,
    p_retCode   out char,
    p_retMsg    out varchar2
)
as
    v_currdate      date := sysdate;
    v_cardNo        char(16);
    v_tradetime     date;
    v_seqNo         char(16);
    v_seqNum        number(16);
    v_quantity      int;

begin
    -- 因为处理以脱机为准，当COMPSTATE = '0'(联机有脱机无)时，加入排重表
    insert into TF_SUPPLY_EXCLUDE (IDENTIFYNO)
    select ID from TP_SUPPLY_DIFF
    where  ID in (select f0 from tmp_common)
    and    COMPSTATE = '0';

    -- 更新回收代码
    update TP_SUPPLY_DIFF
    set    RENEWTYPECODE = decode(COMPSTATE,
                                '0', '1', -- 联机有脱机无时 全额回收
                                '2', '2' -- 金额不符    时 全额回收
                                )
    where  ID in (select f0 from tmp_common);

    -- 更新电子钱包账户信息
    for v_c in
    (
        select CARDNO, CARDTRADENO, TRADEDATE, TRADETIME, COMPMONEY, PREMONEY
        from TP_SUPPLY_DIFF
        where ID in (select f0 from tmp_common)
    )
    loop
        v_cardNo    := v_c.CARDNO;
        v_tradetime := to_date(v_c.TRADEDATE || v_c.TRADETIME, 'YYYYMMDDHH24MISS');

        begin -- 如果卡状态CARDSTATE = '02'(回收状态), 取得新卡号
            select RSRV1 into v_cardNo
            from   TF_F_CARDREC
            where  CARDNO = v_cardNo and CARDSTATE = '02'
            and    RSRV1 is not null;
        exception when others then null;
        end;

        -- 更新电子钱包账户表中的首次充值时间，总充值次数，总充值金额，卡账户金额
         update TF_F_CARDEWALLETACC
         set    FIRSTSUPPLYTIME  = nvl(FIRSTSUPPLYTIME, v_tradetime),
                TOTALSUPPLYTIMES = TOTALSUPPLYTIMES + 1,
                TOTALSUPPLYMONEY = TOTALSUPPLYMONEY + v_c.COMPMONEY,
                CARDACCMONEY     = CARDACCMONEY     + v_c.COMPMONEY
         where  CARDNO           = v_cardno;

        -- 更新电子钱包账户表中的最后充值时间，最后联机充值交易号，最后充值金额
        update  TF_F_CARDEWALLETACC
        set     LASTSUPPLYTIME    = v_tradetime,
                ONLINECARDTRADENO = v_c.CARDTRADENO,
                SUPPLYREALMONEY   = v_c.PREMONEY
        where   CARDNO            = v_cardno
        and    (ONLINECARDTRADENO is null or ONLINECARDTRADENO < v_c.CARDTRADENO);

    end loop;

    -- 备份回收数据到历史表
    insert into TH_SUPPLY_DIFF(
        ID, CARDNO, ASN, CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
        TRADEDATE,  TRADETIME,    TRADEMONEY,  PREMONEY,  SUPPLYLOCNO,
        SAMNO,  POSNO,   STAFFNO, TAC,  TRADEID, TACSTATE,    BATCHNO,
        SUPPLYCOMFEE,  BALUNITNO, CALLINGNO,  CORPNO,   DEPARTNO,
        DEALTIME,   COMPTTIME,   COMPMONEY,    COMPSTATE ,RENEWTYPECODE )
    select  ID, CARDNO, ASN, CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
        TRADEDATE,  TRADETIME,    TRADEMONEY,  PREMONEY,  SUPPLYLOCNO,
        SAMNO,  POSNO,   STAFFNO, TAC,  TRADEID, TACSTATE,    BATCHNO,
        SUPPLYCOMFEE,  BALUNITNO, CALLINGNO,  CORPNO,   DEPARTNO,
        DEALTIME,   COMPTTIME,   COMPMONEY,    COMPSTATE, RENEWTYPECODE
    from TP_SUPPLY_DIFF
    where ID in (select f0 from tmp_common);

    v_quantity := SQL%ROWCOUNT;
    SP_GetSeq(v_quantity, v_seqNo);   
    v_seqNum := to_number(v_seqNo);  

    -- 加入人工充值回收台账表
    insert into TF_B_SUPPLY_MANUAL(
        BUSINESSID,CARDNO,ASN,CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
        TRADEDATE,TRADETIME  ,TRADEMONEY, PREMONEY,SUPPLYLOCNO,
        SAMNO,POSNO,  STAFFNO,      TAC,TRADEID,TACSTATE,
        BATCHNO   ,SUPPLYCOMFEE ,BALUNITNO     ,CALLINGNO,CORPNO,DEPARTNO,
        DEALTIME  ,COMPTTIME,COMPMONEY,COMPSTATE,RENEWMONEY,
        RENEWTIME,RENEWSTAFFNO,RENEWTYPECODE,RENEWREMARK)
    select substr('0000000000000000'|| to_char(v_seqNum + rownum), -16),
        CARDNO,ASN,CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
        TRADEDATE,TRADETIME  ,TRADEMONEY, PREMONEY,SUPPLYLOCNO,
        SAMNO,POSNO,  STAFFNO,      TAC,TRADEID,TACSTATE,
        BATCHNO   ,SUPPLYCOMFEE ,BALUNITNO     ,CALLINGNO,CORPNO,DEPARTNO,
        DEALTIME  ,COMPTTIME,COMPMONEY,COMPSTATE,COMPMONEY,
        v_currdate, p_currOper,  RENEWTYPECODE, p_remark
    from TP_SUPPLY_DIFF
    where ID in (select f0 from tmp_common);

    -- 加入充值回收接口表
    INSERT INTO TI_SUPPLY_MANUAL(
       ID,CARDNO,ASN,CARDTRADENO,TRADETYPECODE,CARDTYPECODE,
       TRADEDATE,TRADETIME,TRADEMONEY,PREMONEY,SUPPLYLOCNO,
       SAMNO,POSNO,STAFFNO,TAC,TRADEID,TACSTATE,BATCHNO,SUPPLYCOMFEE,
       BALUNITNO,CALLINGNO,CORPNO,DEPARTNO,DEALTIME,
       COMPTTIME,COMPMONEY,COMPSTATE,
       RENEWMONEY,RENEWTIME,RENEWSTAFFNO,RENEWTYPECODE,
       RENEWREMARK,DEALSTATECODE)
    SELECT  
       ID,CARDNO,ASN,CARDTRADENO,TRADETYPECODE,CARDTYPECODE,
       TRADEDATE,TRADETIME,TRADEMONEY,PREMONEY,SUPPLYLOCNO,
       SAMNO,POSNO,STAFFNO,TAC,TRADEID,TACSTATE,BATCHNO,SUPPLYCOMFEE,
       BALUNITNO,CALLINGNO,CORPNO,DEPARTNO,DEALTIME,
       COMPTTIME,COMPMONEY,COMPSTATE,
       COMPMONEY, v_currdate, p_currOper, RENEWTYPECODE,
       p_remark, '0' 
    from  TP_SUPPLY_DIFF
    where ID in (select f0 from tmp_common)
    and   COMPSTATE in('0', '2');

    -- 清除充值差异表已经回收的记录
    delete from TP_SUPPLY_DIFF
    where ID in (select f0 from tmp_common);

    p_retCode := '0000000000';
    p_retMsg  := '' || v_quantity;
    commit; return;
exception when others then
    p_retCode := sqlcode;
    p_retMsg  := sqlerrm;
    rollback; return;
end;

/
show errors

