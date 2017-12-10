CREATE OR REPLACE PROCEDURE SP_CC_Query
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
begin

if p_funcCode = 'NEXTBALUNITNO' then
    open p_cursor for
    SELECT TO_NUMBER(NVL(MAX(SUBSTR(T.BALUNITNO, -4)), '0')) + 1 NEXTNO
    FROM TF_TRADE_BALUNIT T;

elsif p_funcCode = 'F00' then
    open p_cursor for
    select t.TRADEID, t.STARTCARDNO || ' - ' || t.ENDCARDNO CARDNO, t.AMOUNT,
        t.MONEY/t.AMOUNT/100.0 MONEY, t.MONEY/100.0 TOTAL, t.OPERATETIME, t.REMARK
    from TF_XFC_SELL t
    where t.CANCELTAG = '0'
    and t.TRADETYPECODE = '80' and t.STAFFNO = p_var1
    and (p_var2 is null or p_var2 = '' or t.STARTCARDNO <= p_var2 and t.ENDCARDNO >= p_var2)
    and (p_var3 is null or p_var3 = '' or to_char(t.OPERATETIME, 'YYYYMMDD') >= p_var3)
    and (p_var4 is null or p_var4 = '' or to_char(t.OPERATETIME, 'YYYYMMDD') <= p_var4);

elsif p_funcCode = 'F01' then
    open p_cursor for
    select decode(PAYTYPE, '0', '转账', '1', '现金','2', '报销') PAYTYPE,
            PAYTIME, TRADEID, STARTCARDNO || '-' || ENDCARDNO CardNoRange,
            CARDVALUE/100.0 CARDVALUE, AMOUNT, TOTALMONEY/100.0 TOTALMONEY, CUSTNAME
    from   TF_XFC_BATCHSELL
    where  PAYTYPE <> '1' and PAYTAG= p_var1
    and    (p_var2 is null or p_var2 ='' or p_var2 between  STARTCARDNO and ENDCARDNO );

elsif p_funcCode = 'F0' then
    open p_cursor for
    select count(*) from TD_XFC_INITCARD
    where  XFCARDNO between p_var1 and p_var2
    and    SALETIME is not null
    and    SALESTAFFNO is not null;

elsif p_funcCode = 'F1' then -- hasSameFaceValue
    open p_cursor for
    select distinct t.VALUECODE from TD_XFC_INITCARD t
        where t.XFCARDNO between p_var1 and p_var2;

elsif p_funcCode = 'F2'  then -- queryCountByState
    open p_cursor for
    select count(*) from TD_XFC_INITCARD t
    where t.XFCARDNO between p_var1 and p_var2
    and t.CARDSTATECODE = p_var3;


elsif p_funcCode = 'F20'  then -- queryCount of salable cards （2入库）
    open p_cursor for
    select count(*) from TD_XFC_INITCARD t
    where t.XFCARDNO between p_var1 and p_var2
    and t.CARDSTATECODE in ('2') and t.SALETIME is null and t.SALESTAFFNO is null;

elsif p_funcCode = 'F21'  then -- queryCount of salable cards （3出库）
    open p_cursor for
    select count(*) from TD_XFC_INITCARD t
    where t.XFCARDNO between p_var1 and p_var2
    and t.CARDSTATECODE in ('3') and t.SALETIME is null and t.SALESTAFFNO is null;

elsif p_funcCode = 'F22'  then -- queryCount of batch salable cards (4 激活 5使用）
    open p_cursor for
    select count(*) from TD_XFC_INITCARD t
    where t.XFCARDNO between p_var1 and p_var2
    and t.CARDSTATECODE in ('4','5') and t.SALETIME is null and t.SALESTAFFNO is null;

elsif p_funcCode = 'F3'  then -- queryTotalValue
    open p_cursor for
    select sum(v.MONEY)/100.0 from TD_XFC_INITCARD t, TP_XFC_CARDVALUE v
    where t.XFCARDNO between p_var1 and p_var2
    and   t.VALUECODE = v.VALUECODE;

elsif p_funcCode = 'F4'  then -- queryUnitValue
    open p_cursor for
    select v.MONEY/100.0 from TD_XFC_INITCARD t, TP_XFC_CARDVALUE v
    where t.XFCARDNO = p_var1
    and  t.VALUECODE = v.VALUECODE;

elsif p_funcCode = 'F6' then -- query cards
    open p_cursor for
    select * from (
        select t.XFCARDNO 充值卡卡号, c.CARDSTATE 状态, v.MONEY/100.0 面值, t.enddate 有效期,
               s.STAFFNAME 售出员工, t.SALETIME 售出时间,
               p.CARDNO 充值IC卡号, p.UPDATETIME 充值时间,d.departno 领用部门
        from   TD_XFC_INITCARD t, TP_XFC_CARDVALUE v, TP_XFC_CARDSTATE c, TD_M_INSIDESTAFF s,TD_M_INSIDEDEPART d,
               TF_CZC_SELFSUPPLY p
        where  t.CARDSTATECODE = c.CARDSTATECODE(+) and t.VALUECODE = v.VALUECODE(+) and t.salestaffno = s.staffno(+) and t.ASSIGNDEPARTNO=d.departno(+)
        and    (p_var1 is null or p_var1 = '' or t.XFCARDNO >= p_var1)
        and    (p_var2 is null or p_var2 = '' or t.XFCARDNO <= p_var2)
        and    (p_var3 is null or p_var3 = '' or t.CARDSTATECODE = p_var3)
        and    t.XFCARDNO = p.CZCARDNO(+)
        order by t.XFCARDNO)
    where   rownum <= 100;

elsif p_funcCode = 'F7' then -- query cards
    open p_cursor for
    select * from (
        select t.XFCARDNO 充值卡卡号, c.CARDSTATE 状态, v.MONEY/100.0 面值,  to_char(t.enddate,'yyyymmdd') 有效期

        from   TD_XFC_INITCARD t, TP_XFC_CARDVALUE v, TP_XFC_CARDSTATE c

        where  t.CARDSTATECODE = c.CARDSTATECODE(+) and t.VALUECODE = v.VALUECODE(+)
        and    (p_var1 is null or p_var1 = '' or t.XFCARDNO >= p_var1)
        and    (p_var2 is null or p_var2 = '' or t.XFCARDNO <= p_var2)
        order by t.XFCARDNO);

elsif p_funcCode = 'F8' then -- query card states
    open p_cursor for
    select CARDSTATE, CARDSTATECODE from TP_XFC_CARDSTATE;

elsif p_funcCode = 'F9' then -- query cardcorp
    open p_cursor for
    select CORPNAME,CORPCODE  from TP_XFC_CORP;
    
 elsif p_funcCode='F10' then --query 现有库内各个厂家、各个批次、各个状态的数量汇总
    open p_cursor for
    select c.corpname 厂家,a.year 年份, a.batchno 批次, b.cardstate 卡状态, count(*) 数量
    from td_xfc_initcard a,tp_xfc_cardstate b,tp_xfc_corp c 
    where a.corpcode=c.corpcode
    and a.cardstatecode=b.cardstatecode
    and    (p_var1 is null or p_var1 = '' or a.corpcode = p_var1)
    and    (p_var2 is null or p_var2 = '' or a.year = p_var2)
    and    (p_var3 is null or p_var3 = '' or a.batchno = p_var3)
    and   (p_var4 is null or p_var4 = '' or a.cardstatecode = p_var4)
    group by c.corpname,a.year,a.batchno,b.cardstate;
    
elsif p_funcCode = 'F24'  then -- queryCount of salable cards （3出库）
    open p_cursor for
    select count(*) from TD_XFC_INITCARD t
    where t.XFCARDNO between p_var1 and p_var2
    and t.ASSIGNDEPARTNO=p_var3 and t.SALETIME is null and t.SALESTAFFNO is null;
    
elsif p_funcCode='ServiceSet' then   -- 读取服务配置参数表 add by hzl
open p_cursor for
select TASKDESC,RECYCELTIME,ISSTART
FROM TD_M_SERVICESET;

elsif p_funcCode='ChargeCardAdjustAcc' then
open p_cursor for
select a.XFCARDNO,b.VALUE,c.cardstate,a.SALESTAFFNO,a.SALETIME
FROM TD_XFC_INITCARD a, tp_xfc_cardvalue b , tp_xfc_cardstate c
where a.valuecode=b.valuecode 
      and a.cardstatecode=c.cardstatecode
      and a.cardstatecode='4'
      and a.xfcardno=p_var1;
elsif p_funcCode = 'hasSameTypeValue' then -- hasSameTypeValue
    open p_cursor for
    select distinct t.CARDTYPE from TD_XFC_INITCARD t
        where t.XFCARDNO between p_var1 and p_var2;
elsif p_funcCode = 'cardTypeValue' then -- cardTypeValue
    open p_cursor for
    select  decode(t.CARDTYPE,'00','普通充值卡','01','休闲充值卡') from TD_XFC_INITCARD t
        where t.XFCARDNO = p_var1;   
end if;

end;
/
show errors