create or replace procedure SP_TS_Query
(
    p_funcCode   varchar2,
    p_var1   in out    varchar2,
    p_var2   in out    varchar2,
    p_var3   in out    varchar2,
    p_var4   in out    varchar2,
    p_var5   in out    varchar2,
    p_var6   in out    varchar2,
    p_var7   in out    varchar2,
    p_var8   in out    varchar2,
    p_var9   in out    varchar2,
    p_var10  in out    varchar2,
    p_var11  in out    varchar2,
    p_var12  in out    varchar2,
    p_cursor out SYS_REFCURSOR
)
as
begin
if p_funcCode = 'SettleDetail' then   
    open p_cursor for
    
    SELECT ROWNUM 序号, tcorp.CORPNO || ':' || tcorp.CORP 单位, tcalling.STAFFNAME 司机, 
           tright.CALLINGSTAFFNO 工号, tright.TRADEMONEY/100.0 金额, tright.TRADEDATE 刷卡日期,
           tright.TRADETIME 刷卡时间, tright.CARDTRADENO 卡交易序号, tright.SAMNO PSAM号,
           tright.POSTRADENO POS交易号, tright.DEALTIME 结算日期 
    
    FROM   TD_M_CORP tcorp, TQ_TAXI_RIGHT tright, TD_M_CALLINGSTAFF tcalling

    WHERE  tright.CALLINGNO = '02'
	AND	   tcalling.CALLINGNO = '02'
    AND   (p_var1 is null or p_var1 = tright.CORPNO)
    AND   (p_var4 is null or p_var4 = tright.CALLINGSTAFFNO)
    AND    tright.DEALTIME      >= TO_DATE(p_var2, 'YYYYMMDD')
    AND    tright.DEALTIME      <  TO_DATE(P_var3, 'YYYYMMDD') + 1
    AND    tright.CALLINGSTAFFNO = tcalling.STAFFNO(+)
    AND    tright.CORPNO         = tcorp.CORPNO    (+)
    AND    ROWNUM < 1000
    order by tcorp.CORPNO, tright.DEALTIME, tright.CALLINGSTAFFNO
    ;
elsif p_funcCode = 'SettleStat' then   
    open p_cursor for
    
    SELECT ta.CORPNO || ':' || co.CORP 单位, ca.STAFFNAME 司机, 
           ta.CALLINGSTAFFNO 工号, ta.DEALTIME 结算日期, ta.CNT 交易次数, ta.TOTAL 总金额
    FROM (
            SELECT CORPNO, CALLINGSTAFFNO, DEALTIME, COUNT(*) CNT, SUM(TRADEMONEY)/100.0 TOTAL
            FROM   TQ_TAXI_RIGHT
            WHERE  CALLINGNO = '02'
            AND   (p_var1 is null or p_var1 = CORPNO)
            AND   (p_var4 is null or p_var4 = CALLINGSTAFFNO)
            AND   DEALTIME >= TO_DATE(p_var2, 'YYYYMMDD')
            AND   DEALTIME <  TO_DATE(P_var3, 'YYYYMMDD') + 1
            GROUP BY CORPNO, CALLINGSTAFFNO, DEALTIME
         ) ta, TD_M_CORP co, TD_M_CALLINGSTAFF ca
    
    WHERE  ca.CALLINGNO = '02'
    AND    ta.CALLINGSTAFFNO = ca.STAFFNO(+)
    AND    ta.CORPNO         = co.CORPNO (+)
    ORDER BY ta.DEALTIME
    ;
elsif p_funcCode = 'TaxiAppendQuery' then
    open p_cursor for
    
    SELECT  tl.CARDNO, tl.CORPNO, tp.CORP CORPNAME, tl.DEPARTNO,tt.DEPART DEPARTNAME, 
            tl.CALLINGSTAFFNO, tcf.STAFFNAME TAXIDRINAME,  tl.TRADEDATE, tl.TRADETIME,
            tl.PREMONEY/100.0 PREMONEY,  tl.TRADEMONEY/100.0 TRADEMONEY,   tl.ASN, 
            tl.CARDTRADENO, tl.POSTRADENO, tl.SAMNO,
            tl.TAC, tl.STAFFNO, ti.STAFFNAME APPSTAFF, tl.OPERATETIME, 
            decode(tl.DEALSTATECODE, '0', '未进行重结算处理', '2', '直接前台付钱', tl.DEALSTATECODE) DEALSTATECODE
    
    FROM    TF_B_TRADE_ACPMANUAL tl, TD_M_CALLINGNO tno, TD_M_CORP tp, TD_M_DEPART tt,
            TD_M_CALLINGSTAFF tcf, TD_M_INSIDESTAFF ti
    
    WHERE  (p_var1 is null or  p_var1 = tl.CALLINGSTAFFNO)
    AND    (p_var2 is null or  tl.OPERATETIME   >= TO_DATE(p_var2, 'YYYYMMDD'))
    AND    (p_var3 is null or  tl.OPERATETIME   <  TO_DATE(P_var3, 'YYYYMMDD') + 1)
    AND    (p_var4 is null or  p_var4 = tl.STAFFNO)
    AND     tl.CALLINGNO      = '02'
	AND		tcf.CALLINGNO	  = '02'
    AND     tl.CALLINGNO      = tno.CALLINGNO(+) 
    AND     tl.CORPNO         = tp.CORPNO    (+) 
    AND     tl.DEPARTNO       = tt.DEPARTNO  (+) 
    AND     tl.CALLINGSTAFFNO = tcf.STAFFNO  (+) 
    AND     tl.STAFFNO        = ti.STAFFNO   (+) 
    ;
elsif p_funcCode = 'ConsumeInfoQuery' then
    open p_cursor for
    SELECT CALLINGSTAFFNO, TRADEDATE, TRADETIME, TRADEMONEY/100.0 TRADEMONEY, 
           PREMONEY/100.0 PREMONEY, SAMNO, PSAMVERNO, CARDNO 
    FROM   TQ_TAXI_RIGHT
    WHERE (p_var1 is null or p_var1 = CALLINGSTAFFNO)
    AND    CALLINGNO = '02'
    AND   (p_var2 is null or TRADEDATE >= p_var2)
    AND   (p_var3 is null or TRADEDATE <= p_var3)
    AND   ROWNUM < 1000
    ;
end if;

end;

/

show errors
