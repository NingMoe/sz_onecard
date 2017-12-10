create or replace procedure SP_CG_Query
(
    p_funcCode    varchar2,
    p_var1        varchar2,
    p_var2        varchar2,
    p_var3        varchar2,
    p_var4        varchar2,
    p_var5        varchar2,
    p_var6        varchar2,
    p_var7        varchar2,
    p_var8 in out varchar2,
    p_var9 in out varchar2,
    p_cursor  out SYS_REFCURSOR
)
as

begin
if p_funcCode = 'QryCashGiftCardPrice' then
    open p_cursor for
    select t.cardprice
    from   tl_r_icuser t
    where  t.cardno = p_var1;

elsif p_funcCode = 'QryGashInfo' then
    -- 查询礼金卡的库内启用日期，结束日期，库内金额，售卡金额
    open p_cursor for
    select to_char(t.LASTSUPPLYTIME, 'yyyyMMdd'), r.VALIDENDDATE,
           t.CARDACCMONEY/100.0, t.TOTALSUPPLYMONEY/100.0,d.DEPARTNAME,c.RESSTATECODE,c.RECLAIMTIME
    from   TF_F_CARDEWALLETACC t, TF_F_CARDREC r,tl_r_icuser c,TD_M_INSIDEDEPART d
    where  t.CARDNO = p_var1
    and    r.cardno = c.cardno
    and    c.ASSIGNEDDEPARTID = d.DEPARTNO
    and    r.CARDNO = p_var1
    ;
elsif p_funcCode = 'ReadNewTrades' then
    open p_cursor for
    SELECT  trade.TRADEID, trade.TRADETYPECODE,
            nvl(type.tradetype, trade.TRADETYPECODE), trade.OPERATETIME,
            (fee.SUPPLYMONEY + fee.CARDDEPOSITFEE)/100.0
    FROM TF_B_TRADE trade, TF_B_TRADEFEE fee, TD_M_TRADETYPE type
    WHERE trade.TRADEID  = p_var1 and fee.TRADEID = p_var1
    and   trade.tradetypecode = type.tradetypecode(+);
elsif p_funcCode = 'QryStateType' then
    open p_cursor for
    select resstatecode, cardtypecode
    from   tl_r_icuser
    where  cardno = p_var1;
elsif p_funcCode = 'BatchSaleCardErrTrade' then
    open p_cursor for
    select rownum seq, t.*
    from (select a.batchid,a.cardno,a.operatetime,a.errmsg||b.errmsg||b.remark as msg
    from tf_b_trade_batchlist a,tf_b_trade_batchlist b
    where a.batchid=b.batchid(+) and a.cardno=b.cardno(+)
    and a.batchid = p_var1
    and a.operatetypecode='01'
    and b.operatetypecode='02'
    and a.tradetypecode='50'
    and b.successtag='1'
    order by a.cardno) t;
elsif p_funcCode = 'FindBatchTradeOperateuser' then
    open p_cursor for
    select a.batchid,a.operatestaffno,a.operatedepartid,a.opercardno
    from tf_b_trade_batch a
    where a.batchid = p_var1
    and to_char(a.operatetime,'yyyymmdd') = to_char(sysdate,'yyyymmdd')
    and a.operatetypecode='01'
    and  not exists(select 1 from tf_b_trade_batch b where b.operatetypecode='02' and a.batchid=b.batchid);
elsif p_funcCode = 'AssignedChange' then
    open p_cursor for
    select a.CARDNO, a.ASSIGNEDSTAFFNO||':'||c.STAFFNAME STAFFNAME,a.ASSIGNEDDEPARTID||':'||d.DEPARTNAME DEPARTNAME,a.RECLAIMTIME,e.cardsurfacecode||':'||e.CARDSURFACENAME CARDTYPENAME
    from TL_R_ICUSER a,TD_M_INSIDESTAFF c,TD_M_INSIDEDEPART d,TD_M_CARDSURFACE e,TD_M_INSIDESTAFF f,TD_M_INSIDEDEPART g,(select regioncode from td_m_insidedepart where departno = p_var7) h
    where a.RESSTATECODE = '04' --礼金卡回收
    and   a.ASSIGNEDSTAFFNO = c.STAFFNO
    and   a.ASSIGNEDDEPARTID = d.DEPARTNO
    and   a.CARDTYPECODE = '05' --礼金卡
    and   a.CARDSURFACECODE = e.cardsurfacecode(+)
    and  (p_var1 IS NULL OR p_var1 = '' OR p_var1 = a.ASSIGNEDDEPARTID)
    and  (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.ASSIGNEDSTAFFNO)
    and  (p_var3 IS NULL OR p_var3 = '' OR a.RECLAIMTIME >= TO_DATE(p_var3||'000000','YYYYMMDDHH24MISS'))
    and  (p_var4 IS NULL OR p_var4 = '' OR a.RECLAIMTIME <= TO_DATE(p_var4||'235959','YYYYMMDDHH24MISS'))
    and  (p_var5 IS NULL OR p_var5 = '' OR rownum < p_var5+1)
    and  (p_var6 IS NULL OR p_var6 = '' Or p_var6 = a.CARDSURFACECODE)
    and  (a.updatestaffno = f.staffno)
    and  (f.departno = g.departno)
    AND (g.Regioncode IN (select b.regioncode from td_m_regioncode b where b.regionname =(select r.regionname from td_m_regioncode r where r.regioncode = h.REGIONCODE)) or h.REGIONCODE is null)
    order by a.RECLAIMTIME;
elsif p_funcCode = 'CashGiftHistory' then  ---礼金卡回收历史统计查询
    open p_cursor for
    select  a.OLDASSIGNEDSTAFFNO||':'||d.STAFFNAME STAFFNAMEOLD,a.ASSIGNEDSTAFFNO||':'||c.STAFFNAME STAFFNAMENow,e.Departno||':'||e.DEPARTNAME DEPARTNAMEOLD,f.Departno||':'||f.DEPARTNAME DEPARTNAMENOW,g.cardsurfacecode||':'||g.CARDSURFACENAME CARDTYPENAME,COUNT(*) NUM
    from TF_B_TRADE_CASHGIFT a,TD_M_INSIDESTAFF c,TD_M_INSIDESTAFF d,TD_M_INSIDEDEPART e,TD_M_INSIDEDEPART f,TD_M_CARDSURFACE g,TD_M_INSIDESTAFF h,td_m_insidedepart i,
         (select regioncode from td_m_insidedepart where departno = p_var9) l
    where a.TRADETYPECODE = '57' --礼金卡回收
    and   a.ASSIGNEDSTAFFNO = c.STAFFNO
    and   a.OLDASSIGNEDSTAFFNO = d.STAFFNO
    and   c.departno = f.departno
    and   d.departno = e.departno 
    and   a.operatestaffno = h.staffno
    and   Substr(a.CARDNO,5,2) = '05' --礼金卡
    and   Substr(a.CARDNO,5,4) = g.cardsurfacecode(+)
    and  (p_var1 IS NULL OR p_var1 = '' OR p_var1 = e.departno)
    and  (p_var2 IS NULL OR p_var2 = '' OR p_var2 = d.staffno)
    and  (p_var3 IS NULL OR p_var3 = '' OR p_var3 = f.departno)
    and  (p_var4 IS NULL OR p_var4 = '' OR p_var4 = c.staffno)
    and  (p_var5 IS NULL OR p_var5 = '' OR a.operatetime >= TO_DATE(p_var5||'000000','YYYYMMDDHH24MISS'))
    and  (p_var6 IS NULL OR p_var6 = '' OR a.operatetime <= TO_DATE(p_var6||'235959','YYYYMMDDHH24MISS'))
    and  (p_var7 IS NULL OR p_var7 = '' OR p_var7 = a.operatestaffno)
    and  (p_var8 IS NULL OR p_var8 = '' OR p_var8 = g.cardsurfacecode)
    and  (a.operatedepartid = i.departno )
    AND (i.Regioncode IN (select b.regioncode from td_m_regioncode b where b.regionname =(select r.regionname from td_m_regioncode r where r.regioncode = l.REGIONCODE)) or l.REGIONCODE is null)
    group by a.oldassignedstaffno,d.staffname,a.assignedstaffno,c.staffname,e.departno,e.departname,f.departno,f.departname,g.cardsurfacecode,g.cardsurfacename;
elsif p_funcCode = 'CashGiftHistoryDetail' then  ---礼金卡回收历史明细查询
    open p_cursor for
    select a.CARDNO, a.OLDASSIGNEDSTAFFNO||':'||d.STAFFNAME STAFFNAMEOLD,a.ASSIGNEDSTAFFNO||':'||c.STAFFNAME STAFFNAMENow,e.Departno||':'||e.DEPARTNAME DEPARTNAMEOLD,f.Departno||':'||f.DEPARTNAME DEPARTNAMENOW,g.cardsurfacecode||':'||g.CARDSURFACENAME CARDTYPENAME,a.operatetime OPERATETIME,a.operatestaffno||':'||h.staffname  OPERATESTAFF
    from TF_B_TRADE_CASHGIFT a,TD_M_INSIDESTAFF c,TD_M_INSIDESTAFF d,TD_M_INSIDEDEPART e,TD_M_INSIDEDEPART f,TD_M_CARDSURFACE g,TD_M_INSIDESTAFF h
    where a.TRADETYPECODE = '57' --礼金卡回收
    and   a.ASSIGNEDSTAFFNO = c.STAFFNO
    and   a.OLDASSIGNEDSTAFFNO = d.STAFFNO
    and   c.departno = f.departno
    and   d.departno = e.departno 
    and   a.operatestaffno = h.staffno
    and   Substr(a.CARDNO,5,2) = '05' --礼金卡
    and   Substr(a.CARDNO,5,4) = g.cardsurfacecode(+)
    and  (p_var1 IS NULL OR p_var1 = '' OR p_var1 = g.cardsurfacecode)
    and  (p_var2 IS NULL OR p_var2 = '' OR p_var2 = e.departno)
    and  (p_var3 IS NULL OR p_var3 = '' OR p_var3 = d.staffno)
    and  (p_var4 IS NULL OR p_var4 = '' OR p_var4 = f.departno)
    and  (p_var5 IS NULL OR p_var5 = '' OR p_var5 = c.staffno)
    order by a.operatetime desc;
elsif p_funcCode = 'SELECTDEPTBYAREA' then
    open p_cursor for
      SELECT TMI.DEPARTNAME, TMI.Departno, TMI.REGIONCODE
        FROM TD_M_INSIDEDEPART TMI,
             (SELECT TMI.REGIONCODE
                FROM TD_M_INSIDEDEPART TMI
               where TMI.DEPARTNO = p_var1) m
       WHERE (((TMI.REGIONCODE = m.regioncode or m.regioncode is null) and
             p_var2 is null)
          or (p_var2 = 'OK' and m.regioncode = TMI.REGIONCODE))
          AND TMI.USETAG = '1'
       ORDER BY TMI.DEPARTNO; 
end if;


end;
/
SHOW ERRORS