create or replace procedure SP_AS_Query(p_funcCode varchar2,
                                        p_var1     varchar2,
                                        p_var2     varchar2,
                                        p_var3     varchar2,
                                        p_var4     varchar2,
                                        p_var5     varchar2,
                                        p_var6     varchar2,
                                        p_var7     varchar2,
                                        p_var8     varchar2,
                                        p_var9     varchar2,
                                        p_cursor   out SYS_REFCURSOR) as
begin
  if p_funcCode = 'CheckParkNew' then
    -- 园林和休闲开通时,需要增加判断:
    -- 此卡是否换卡售出?
    -- 如果是换卡售出,判断当前卡片是否已开通过园林或休闲功能.
    -- 如果已开通过休闲或园林功能,则返回正常;
    -- 如果未开通过园林或休闲功能,需要判断老卡是否有园林或休闲功能.如果老卡有园林或休闲功能,则提示是否要做园林或休闲的补换卡.
  
    declare
      v_test      int := 0;
      v_oldcardno char(16);
    begin
      select 1
        into v_test
        from tf_f_cardrec t
       where t.cardno = p_var1
         and t.cardstate = '11'; -- 换卡售出
    
      select 1
        into v_test
        from dual
       where not exists
       (select 1
                from tf_f_cardparkacc_sz t
               where t.cardno = p_var1
                 and t.usetag = '1'
                 and t.enddate >= to_char(sysdate, 'yyyyMMdd')); -- 是否开通园林
    
      select tmp.oldcardno
        into v_oldcardno
        from (select t.oldcardno
                from tf_b_trade t
               where t.cardno = p_var1
                 and t.tradetypecode in ('03', -- 普通换卡
                      '73', -- 学生卡换卡
                      '74', -- 老人卡换卡
                      '75', -- 高龄月票原卡
                      '7C' --残疾人月票换卡
                     )
               order by t.operatetime desc) tmp
       where rownum <= 1;
    
      select 1
        into v_test
        from tf_f_cardparkacc_sz t
       where t.cardno = v_oldcardno
         and t.usetag = '1'
         and t.enddate >= to_char(sysdate, 'yyyyMMdd'); -- 是否开通园林
    
      open p_cursor for
        select v_oldcardno from dual; -- 提示做园林换卡
      return;
    exception
      when no_data_found then
        null;
    end;
  
    open p_cursor for
      select 1 from dual where 0 > 1;
  elsif p_funcCode = 'XXParkStatistics' then
    --这边查询出来之后，在代码里面还要再处理一下
    open p_cursor for
      select *
        from (select to_char(TF_F_YLOL_ORDER.CREATETIME, 'yyyy-MM') sMonth,
                     count(1) sNum,
                     '1' AS sTag
                from TF_F_YLOL_ORDER
               inner join TF_B_TRADE
                  on TF_B_TRADE.tradeid = TF_F_YLOL_ORDER.Orderno
                 and TF_B_TRADE.tradetypecode = '3H'
               where TF_F_YLOL_ORDER.ORDERTYPE = '1'
                 and to_char(TF_F_YLOL_ORDER.CREATETIME, 'yyyy') = p_var1
               group by to_char(TF_F_YLOL_ORDER.CREATETIME, 'yyyy-MM')
              union all
              select to_char(TF_B_TRADE.OPERATETIME, 'yyyy-MM') sMonth,
                     count(1) sNum,
                     '2' AS sTag
                from TF_B_TRADE
                left join TF_F_YLOL_ORDER
                  on TF_B_TRADE.tradeid = TF_F_YLOL_ORDER.Orderno
               where TF_B_TRADE.Tradetypecode in ('10', '3H')
                 and (TF_B_TRADE.CANCELTAG is null or
                     TF_B_TRADE.CANCELTAG = '0')
                 and TF_F_YLOL_ORDER.Orderno is null
                 and to_char(TF_B_TRADE.OPERATETIME, 'yyyy') = p_var1
               group by to_char(TF_B_TRADE.OPERATETIME, 'yyyy-MM')
              union ALL
              select sMonth, sum(sNum) sNum, '3' AS sTag --苏州休闲线上  
                from (SELECT sMonth, COUNT(1) sNum
                        FROM (SELECT to_char(A.OPERATETIME, 'yyyy-MM') sMonth
                                FROM TF_B_TRADE       A,
                                     TD_M_PACKAGETYPE C,
                                     TL_XFC_TRADELOG  B
                               WHERE 1 = 1
                                 and A.Tradeid = b.tradeid(+)
                                 and A.RSRV2 = C.PACKAGETYPECODE(+)
                                 and to_char(A.OPERATETIME, 'yyyy') = p_var1
                                 and A.OPERATEDEPARTID = '0029'
                                 AND A.TRADETYPECODE IN ('25')
                                 and C.PACKAGETYPECODE in
                                     ('0E', '03', '04', '05', '06', '0D')
                                 and b.tradeid is null) TB
                       WHERE 1 = 1
                       group by sMonth
                      union all
                      SELECT sMonth, -COUNT(1) sNum
                        FROM (SELECT to_char(A.OPERATETIME, 'yyyy-MM') sMonth
                                FROM TF_B_TRADE A, TD_M_PACKAGETYPE C
                               WHERE 1 = 1
                                 and A.RSRV2 = C.PACKAGETYPECODE(+)
                                 and to_char(A.OPERATETIME, 'yyyy') = p_var1
                                 and A.OPERATEDEPARTID = '0029'
                                 AND A.TRADETYPECODE IN ('B5')
                                 and C.PACKAGETYPECODE in
                                     ('0E', '03', '04', '05', '06', '0D')) TB
                       WHERE 1 = 1
                       group by sMonth
                      union all
                      select sMonth, sum(amount) sNum
                        from (select a.amount,
                                     to_char(a.OPERATETIME, 'yyyy-MM') sMonth
                                from tf_xfc_sell       a,
                                     TD_M_INSIDESTAFF  b,
                                     TD_M_INSIDEDEPART c
                               where 1 = 1
                                 and a.money / 100.0 / a.amount in (298, 180)
                                 and a.STAFFNO = b.STAFFNO
                                 and b.departno = c.DEPARTNO
                                 and a.tradetypecode = '80'
                                 and a.canceltag = '0'
                                 and c.departno = '0029'
                                 and to_char(a.OPERATETIME, 'yyyy') = p_var1
                              union all
                              select a.amount,
                                     to_char(a.OPERATETIME, 'yyyy-MM') sMonth
                                from TF_XFC_BATCHSELL  a,
                                     TD_M_INSIDESTAFF  b,
                                     TD_M_INSIDEDEPART c
                               where 1 = 1
                                 and a.cardvalue / 100.0 in (298, 180)
                                 and a.STAFFNO = b.STAFFNO
                                 and b.departno = c.DEPARTNO
                                 and (RSRV1 IS NULL OR RSRV1 <> '1') --去除返销的
                                 and c.departno = '0029'
                                 and to_char(a.OPERATETIME, 'yyyy') = p_var1)
                       group by sMonth)
               group by sMonth
              union all
              select sMonth, sum(sNum) sNum, '4' AS sTag --苏州休闲线下 
                from (SELECT sMonth, COUNT(1) sNum
                        FROM (SELECT to_char(A.OPERATETIME, 'yyyy-MM') sMonth
                                FROM TF_B_TRADE       A,
                                     TD_M_PACKAGETYPE C,
                                     TL_XFC_TRADELOG  B
                               WHERE 1 = 1
                                 and A.Tradeid = b.tradeid(+)
                                 and A.RSRV2 = C.PACKAGETYPECODE(+)
                                 and to_char(A.OPERATETIME, 'yyyy') = p_var1
                                 and A.OPERATEDEPARTID <> '0029'
                                 AND A.TRADETYPECODE IN ('25')
                                 and C.PACKAGETYPECODE in
                                     ('0E', '03', '04', '05', '06', '0D')
                                 and b.tradeid is null) TB
                       WHERE 1 = 1
                       group by sMonth
                      union all
                      SELECT sMonth, -COUNT(1) sNum
                        FROM (SELECT to_char(A.OPERATETIME, 'yyyy-MM') sMonth
                                FROM TF_B_TRADE A, TD_M_PACKAGETYPE C
                               WHERE 1 = 1
                                 and A.RSRV2 = C.PACKAGETYPECODE(+)
                                 and to_char(A.OPERATETIME, 'yyyy') = p_var1
                                 and A.OPERATEDEPARTID <> '0029'
                                 AND A.TRADETYPECODE IN ('B5')
                                 and C.PACKAGETYPECODE in
                                     ('0E', '03', '04', '05', '06', '0D')) TB
                       WHERE 1 = 1
                       group by sMonth
                      union all
                      select sMonth, sum(amount) sNum
                        from (select a.amount,
                                     to_char(a.OPERATETIME, 'yyyy-MM') sMonth
                                from tf_xfc_sell       a,
                                     TD_M_INSIDESTAFF  b,
                                     TD_M_INSIDEDEPART c
                               where 1 = 1
                                 and a.money / 100.0 / a.amount in (298, 180)
                                 and a.STAFFNO = b.STAFFNO
                                 and b.departno = c.DEPARTNO
                                 and a.tradetypecode = '80'
                                 and a.canceltag = '0'
                                 and c.departno <> '0029'
                                 and to_char(a.OPERATETIME, 'yyyy') = p_var1
                              union all
                              select a.amount,
                                     to_char(a.OPERATETIME, 'yyyy-MM') sMonth
                                from TF_XFC_BATCHSELL  a,
                                     TD_M_INSIDESTAFF  b,
                                     TD_M_INSIDEDEPART c
                               where 1 = 1
                                 and a.cardvalue / 100.0 in (298, 180)
                                 and a.STAFFNO = b.STAFFNO
                                 and b.departno = c.DEPARTNO
                                 and (RSRV1 IS NULL OR RSRV1 <> '1') --去除返销的
                                 and c.departno <> '0029'
                                 and to_char(a.OPERATETIME, 'yyyy') = p_var1)
                       group by sMonth)
               group by sMonth
              union all
              select sMonth, sum(sNum) sNum, '5' AS sTag --无锡休闲线下
                from (SELECT sMonth, COUNT(1) sNum
                        FROM (SELECT to_char(A.OPERATETIME, 'yyyy-MM') sMonth
                                FROM TF_B_TRADE A, TD_M_PACKAGETYPE C
                               WHERE 1 = 1
                                 and A.RSRV2 = C.PACKAGETYPECODE(+)
                                 and to_char(A.OPERATETIME, 'yyyy') = p_var1
                                 and A.OPERATEDEPARTID <> '0029'
                                 AND A.TRADETYPECODE IN ('25')
                                 and C.PACKAGETYPECODE in ('09', '07', '08')) TB
                       WHERE 1 = 1
                       group by sMonth
                      union all
                      SELECT sMonth, -COUNT(1) sNum
                        FROM (SELECT to_char(A.OPERATETIME, 'yyyy-MM') sMonth
                                FROM TF_B_TRADE A, TD_M_PACKAGETYPE C
                               WHERE 1 = 1
                                 and A.RSRV2 = C.PACKAGETYPECODE(+)
                                 and to_char(A.OPERATETIME, 'yyyy') = p_var1
                                 and A.OPERATEDEPARTID <> '0029'
                                 AND A.TRADETYPECODE IN ('B5')
                                 and C.PACKAGETYPECODE in ('09', '07', '08')) TB
                       WHERE 1 = 1
                       group by sMonth)
               group by sMonth
              union all
              select sMonth, sum(sNum) sNum, '6' AS sTag --常州休闲线下
                from (SELECT sMonth, COUNT(1) sNum
                        FROM (SELECT to_char(A.OPERATETIME, 'yyyy-MM') sMonth
                                FROM TF_B_TRADE A, TD_M_PACKAGETYPE C
                               WHERE 1 = 1
                                 and A.RSRV2 = C.PACKAGETYPECODE(+)
                                 and to_char(A.OPERATETIME, 'yyyy') = p_var1
                                 and A.OPERATEDEPARTID <> '0029'
                                 AND A.TRADETYPECODE IN ('25')
                                 and C.PACKAGETYPECODE in ('0C')) TB
                       WHERE 1 = 1
                       group by sMonth
                      union all
                      SELECT sMonth, -COUNT(1) sNum
                        FROM (SELECT to_char(A.OPERATETIME, 'yyyy-MM') sMonth
                                FROM TF_B_TRADE A, TD_M_PACKAGETYPE C
                               WHERE 1 = 1
                                 and A.RSRV2 = C.PACKAGETYPECODE(+)
                                 and to_char(A.OPERATETIME, 'yyyy') = p_var1
                                 and A.OPERATEDEPARTID <> '0029'
                                 AND A.TRADETYPECODE IN ('B5')
                                 and C.PACKAGETYPECODE in ('0C')) TB
                       WHERE 1 = 1
                       group by sMonth)
               group by sMonth
              union all
              select sMonth, sum(sNum) sNum, '7' AS sTag --常熟休闲线下
                from (SELECT sMonth, COUNT(1) sNum
                        FROM (SELECT to_char(A.OPERATETIME, 'yyyy-MM') sMonth
                                FROM TF_B_TRADE A, TD_M_PACKAGETYPE C
                               WHERE 1 = 1
                                 and A.RSRV2 = C.PACKAGETYPECODE(+)
                                 and to_char(A.OPERATETIME, 'yyyy') = p_var1
                                 and A.OPERATEDEPARTID <> '0029'
                                 AND A.TRADETYPECODE IN ('25')
                                 and C.PACKAGETYPECODE in ('0A', '0B')) TB
                       WHERE 1 = 1
                       group by sMonth
                      union all
                      SELECT sMonth, -COUNT(1) sNum
                        FROM (SELECT to_char(A.OPERATETIME, 'yyyy-MM') sMonth
                                FROM TF_B_TRADE A, TD_M_PACKAGETYPE C
                               WHERE 1 = 1
                                 and A.RSRV2 = C.PACKAGETYPECODE(+)
                                 and to_char(A.OPERATETIME, 'yyyy') = p_var1
                                 and A.OPERATEDEPARTID <> '0029'
                                 AND A.TRADETYPECODE IN ('B5')
                                 and C.PACKAGETYPECODE in ('0A', '0B')) TB
                       WHERE 1 = 1
                       group by sMonth)
               group by sMonth
              union all (select '9999-12' sMonth,
                               count(1) sNum,
                               '1_ALL' AS sTag
                          from TF_F_YLOL_ORDER
                         inner join TF_B_TRADE
                            on TF_B_TRADE.tradeid = TF_F_YLOL_ORDER.Orderno
                           and TF_B_TRADE.tradetypecode = '3H'
                         where TF_F_YLOL_ORDER.ORDERTYPE = '1'
                        union all
                        select '9999-12' sMonth,
                               count(1) sNum,
                               '2_ALL' AS sTag
                          from TF_B_TRADE
                          left join TF_F_YLOL_ORDER
                            on TF_B_TRADE.tradeid = TF_F_YLOL_ORDER.Orderno
                         where TF_B_TRADE.Tradetypecode in ('10', '3H')
                           and (TF_B_TRADE.CANCELTAG is null or
                               TF_B_TRADE.CANCELTAG = '0')
                           and TF_F_YLOL_ORDER.Orderno is null
                        union ALL
                        select '9999-12' sMonth,
                               sum(sNum) sNum,
                               '3_ALL' AS sTag --苏州休闲线上合计 
                          from (SELECT COUNT(1) sNum
                                  FROM (SELECT 1
                                          FROM TF_B_TRADE       A,
                                               TD_M_PACKAGETYPE C,
                                               TL_XFC_TRADELOG  B
                                         WHERE 1 = 1
                                           and A.Tradeid = b.tradeid(+)
                                           and A.RSRV2 = C.PACKAGETYPECODE(+)
                                           and A.OPERATEDEPARTID = '0029'
                                           AND A.TRADETYPECODE IN ('25')
                                           and C.PACKAGETYPECODE in
                                               ('0E',
                                                '03',
                                                '04',
                                                '05',
                                                '06',
                                                '0D')
                                           and b.tradeid is null) TB
                                 WHERE 1 = 1
                                union all
                                SELECT -COUNT(1) sNum
                                  FROM (SELECT 1
                                          FROM TF_B_TRADE       A,
                                               TD_M_PACKAGETYPE C
                                         WHERE 1 = 1
                                           and A.RSRV2 = C.PACKAGETYPECODE(+)
                                           and A.OPERATEDEPARTID = '0029'
                                           AND A.TRADETYPECODE IN ('B5')
                                           and C.PACKAGETYPECODE in
                                               ('0E',
                                                '03',
                                                '04',
                                                '05',
                                                '06',
                                                '0D')) TB
                                 WHERE 1 = 1
                                
                                union all
                                select sum(amount) sNum
                                  from (select a.amount
                                          from tf_xfc_sell       a,
                                               TD_M_INSIDESTAFF  b,
                                               TD_M_INSIDEDEPART c
                                         where 1 = 1
                                           and a.money / 100.0 / a.amount in
                                               (298, 180)
                                           and a.STAFFNO = b.STAFFNO
                                           and b.departno = c.DEPARTNO
                                           and a.tradetypecode = '80'
                                           and a.canceltag = '0'
                                           and c.departno = '0029'
                                        union all
                                        select a.amount
                                          from TF_XFC_BATCHSELL  a,
                                               TD_M_INSIDESTAFF  b,
                                               TD_M_INSIDEDEPART c
                                         where 1 = 1
                                           and a.cardvalue / 100.0 in
                                               (298, 180)
                                           and a.STAFFNO = b.STAFFNO
                                           and b.departno = c.DEPARTNO
                                           and (RSRV1 IS NULL OR RSRV1 <> '1') --去除返销的
                                           and c.departno = '0029'))
                        union all
                        select '9999-12' sMonth,
                               sum(sNum) sNum,
                               '4_ALL' AS sTag --苏州休闲线下合计 
                          from (SELECT COUNT(1) sNum
                                  FROM (SELECT 1
                                          FROM TF_B_TRADE       A,
                                               TD_M_PACKAGETYPE C,
                                               TL_XFC_TRADELOG  B
                                         WHERE 1 = 1
                                           and A.Tradeid = b.tradeid(+)
                                           and A.RSRV2 = C.PACKAGETYPECODE(+)
                                           and A.OPERATEDEPARTID <> '0029'
                                           AND A.TRADETYPECODE IN ('25')
                                           and C.PACKAGETYPECODE in
                                               ('0E',
                                                '03',
                                                '04',
                                                '05',
                                                '06',
                                                '0D')
                                           and b.tradeid is null) TB
                                 WHERE 1 = 1
                                union all
                                SELECT -COUNT(1) sNum
                                  FROM (SELECT 1
                                          FROM TF_B_TRADE       A,
                                               TD_M_PACKAGETYPE C
                                         WHERE 1 = 1
                                           and A.RSRV2 = C.PACKAGETYPECODE(+)
                                           and A.OPERATEDEPARTID <> '0029'
                                           AND A.TRADETYPECODE IN ('B5')
                                           and C.PACKAGETYPECODE in
                                               ('0E',
                                                '03',
                                                '04',
                                                '05',
                                                '06',
                                                '0D')) TB
                                 WHERE 1 = 1
                                
                                union all
                                select sum(amount) sNum
                                  from (select a.amount
                                          from tf_xfc_sell       a,
                                               TD_M_INSIDESTAFF  b,
                                               TD_M_INSIDEDEPART c
                                         where 1 = 1
                                           and a.money / 100.0 / a.amount in
                                               (298, 180)
                                           and a.STAFFNO = b.STAFFNO
                                           and b.departno = c.DEPARTNO
                                           and a.tradetypecode = '80'
                                           and a.canceltag = '0'
                                           and c.departno = '0029'
                                        union all
                                        select a.amount
                                          from TF_XFC_BATCHSELL  a,
                                               TD_M_INSIDESTAFF  b,
                                               TD_M_INSIDEDEPART c
                                         where 1 = 1
                                           and a.cardvalue / 100.0 in
                                               (298, 180)
                                           and a.STAFFNO = b.STAFFNO
                                           and b.departno = c.DEPARTNO
                                           and (RSRV1 IS NULL OR RSRV1 <> '1') --去除返销的
                                           and c.departno <> '0029'))
                        union all
                        select '9999-12' sMonth,
                               sum(sNum) sNum,
                               '5_ALL' AS sTag --无锡休闲线下合计
                          from (SELECT COUNT(1) sNum
                                  FROM (SELECT 1
                                          FROM TF_B_TRADE       A,
                                               TD_M_PACKAGETYPE C
                                         WHERE 1 = 1
                                           and A.RSRV2 = C.PACKAGETYPECODE(+)
                                           and A.OPERATEDEPARTID <> '0029'
                                           AND A.TRADETYPECODE IN ('25')
                                           and C.PACKAGETYPECODE in
                                               ('09', '07', '08')) TB
                                 WHERE 1 = 1
                                union all
                                SELECT -COUNT(1) sNum
                                  FROM (SELECT 1
                                          FROM TF_B_TRADE       A,
                                               TD_M_PACKAGETYPE C
                                         WHERE 1 = 1
                                           and A.RSRV2 = C.PACKAGETYPECODE(+)
                                           and A.OPERATEDEPARTID <> '0029'
                                           AND A.TRADETYPECODE IN ('B5')
                                           and C.PACKAGETYPECODE in
                                               ('09', '07', '08')) TB
                                 WHERE 1 = 1)
                        union all
                        select '9999-12' sMonth,
                               sum(sNum) sNum,
                               '6_ALL' AS sTag --常州休闲线下合计
                          from (SELECT COUNT(1) sNum
                                  FROM (SELECT 1
                                          FROM TF_B_TRADE       A,
                                               TD_M_PACKAGETYPE C
                                         WHERE 1 = 1
                                           and A.RSRV2 = C.PACKAGETYPECODE(+)
                                           and A.OPERATEDEPARTID <> '0029'
                                           AND A.TRADETYPECODE IN ('25')
                                           and C.PACKAGETYPECODE in ('0C')) TB
                                 WHERE 1 = 1
                                union all
                                SELECT -COUNT(1) sNum
                                  FROM (SELECT 1
                                          FROM TF_B_TRADE       A,
                                               TD_M_PACKAGETYPE C
                                         WHERE 1 = 1
                                           and A.RSRV2 = C.PACKAGETYPECODE(+)
                                           and to_char(A.OPERATETIME, 'yyyy') =
                                               p_var1
                                           and A.OPERATEDEPARTID <> '0029'
                                           AND A.TRADETYPECODE IN ('B5')
                                           and C.PACKAGETYPECODE in ('0C')) TB
                                 WHERE 1 = 1)
                        union all
                        select '9999-12' sMonth,
                               sum(sNum) sNum,
                               '7_ALL' AS sTag --常熟休闲线下合计
                          from (SELECT COUNT(1) sNum
                                  FROM (SELECT 1
                                          FROM TF_B_TRADE       A,
                                               TD_M_PACKAGETYPE C
                                         WHERE 1 = 1
                                           and A.RSRV2 = C.PACKAGETYPECODE(+)
                                           and A.OPERATEDEPARTID <> '0029'
                                           AND A.TRADETYPECODE IN ('25')
                                           and C.PACKAGETYPECODE in
                                               ('0A', '0B')) TB
                                 WHERE 1 = 1
                                union all
                                SELECT -COUNT(1) sNum
                                  FROM (SELECT 1
                                          FROM TF_B_TRADE       A,
                                               TD_M_PACKAGETYPE C
                                         WHERE 1 = 1
                                           and A.RSRV2 = C.PACKAGETYPECODE(+)
                                           and A.OPERATEDEPARTID <> '0029'
                                           AND A.TRADETYPECODE IN ('B5')
                                           and C.PACKAGETYPECODE in
                                               ('0A', '0B')) TB
                                 WHERE 1 = 1)));
  elsif p_funcCode = 'QueryFIPunchSale' then
    open p_cursor for
      SELECT nvl(CARDTYPENAME, 0) CARDTYPENAME,
             nvl(TOTALNUM, 0) TOTALNUM,
             nvl(YEARNUM, 0) YEARNUM,
             nvl(MONTHNUM, 0) MONTHNUM,
             nvl(CONSUMENUM, 0) CONSUMENUM,
             nvl(UNCONSUNMENUM, 0) UNCONSUNMENUM,
             nvl(DEPOSITMONEY, 0) / 1000000.0 DEPOSITMONEY,
             nvl(SUPPLYMONEY, 0) / 1000000.0 SUPPLYMONEY,
             nvl(YEARSUPPLYMONEY, 0) / 1000000.0 YEARSUPPLYMONEY,
             nvl(MONTHPAYMONEY, 0) / 1000000.0 MONTHPAYMONEY,
             nvl(YEARPAYMONEY, 0) / 1000000.0 YEARPAYMONEY,
             nvl(TOTALPAYMONEY, 0) / 1000000.0 TOTALPAYMONEY
        FROM TF_MONTHCARD_PUNCHSALE
       WHERE STATTIME = p_var1
       ORDER BY SORTNUM asc;
  elsif p_funcCode = 'CheckXXParkNew' then
    declare
      v_test      int := 0;
      v_oldcardno char(16);
    begin
      select 1
        into v_test
        from tf_f_cardrec t
       where t.cardno = p_var1
         and t.cardstate = '11'; -- 换卡售出
    
      select 1
        into v_test
        from dual
       where not exists
       (select 1
                from tf_f_cardxxparkacc_sz t
               where t.cardno = p_var1
                 and t.usetag = '1'
                 and t.enddate >= to_char(sysdate, 'yyyyMMdd')); -- 是否开通休闲
    
      select tmp.oldcardno
        into v_oldcardno
        from (select t.oldcardno
                from tf_b_trade t
               where t.cardno = p_var1
                 and t.tradetypecode in ('03', -- 普通换卡
                      '73', -- 学生卡换卡
                      '74', -- 老人卡换卡
                      '75', -- 高龄月票原卡
                      '7C' --残疾人月票换卡
                     )
               order by t.operatetime desc) tmp
       where rownum <= 1;
    
      select 1
        into v_test
        from tf_f_cardxxparkacc_sz t
       where t.cardno = v_oldcardno
         and t.usetag = '1'
         and t.enddate >= to_char(sysdate, 'yyyyMMdd'); -- 是否开通休闲
    
      open p_cursor for
        select v_oldcardno from dual; -- 提示做休闲换卡
      return;
    exception
      when no_data_found then
        null;
    end;
  
    open p_cursor for
      select 1 from dual where 0 > 1;
  
  elsif p_funcCode = 'QueryCheckStaff' then
    open p_cursor for
      SELECT T.STAFFNO, T.DEPARTNO
        FROM TD_M_INSIDESTAFF T
       WHERE T.OPERCARDNO = p_var1
         AND T.DIMISSIONTAG = '1'
         AND ROWNUM <= 1;
  
  elsif p_funcCode = 'ParkBlackList' then
    open p_cursor for
      SELECT LEVELFLAG FROM TF_F_BLACKACC_PARK WHERE CARDNO = p_var1;
  
  elsif p_funcCode = 'PaperNoBlackList' then
    open p_cursor for
      SELECT USETAG FROM TF_F_CARDPARKBLACKLIST WHERE PAPERNO = p_var1;
  
  elsif p_funcCode = 'XXParkBlackList' then
    open p_cursor for
      SELECT LEVELFLAG FROM TF_F_BLACKACC_XXPARK WHERE CARDNO = p_var1;
  
  elsif p_funcCode = 'ParkCardUseTag' then
    open p_cursor for
      SELECT USETAG
        FROM TF_F_CARDPARKACC_SZ
       WHERE CARDNO = p_var1
         AND USETAG = '1';
  
  elsif p_funcCode = 'XXParkCardUseTag' then
    open p_cursor for
      SELECT USETAG
        FROM TF_F_CARDXXPARKACC_SZ
       WHERE CARDNO = p_var1
         AND USETAG = '1';
  
  elsif p_funcCode = 'ParkCardInfo' then
    open p_cursor for
      SELECT PACKAGETYPECODE, ENDDATE
        FROM TF_F_CARDXXPARKACC_SZ
       WHERE CARDNO = p_var1
         AND USETAG = '1';
  
  elsif p_funcCode = 'ParkNum' then
    open p_cursor for
      SELECT TAGVALUE
        FROM TD_M_TAG
       WHERE TAGCODE = 'PARK_NUM'
         AND USETAG = '1';
  
    --吴江旅游年卡开卡次数
  elsif p_funcCode = 'TravelWJTimes' then
    open p_cursor for
      SELECT TAGVALUE
        FROM TD_M_TAG
       WHERE TAGCODE = 'TRAVEL_NUM'
         AND USETAG = '1';
  
  elsif p_funcCode = 'XXParkNum' then
    open p_cursor for
      SELECT TAGVALUE
        FROM TD_M_TAG
       WHERE TAGCODE = 'XXPARK_NUM'
         AND USETAG = '1';
  
  elsif p_funcCode = 'AffectParkNum' then
    open p_cursor for
      SELECT TAGVALUE
        FROM TD_M_TAG
       WHERE TAGCODE = 'AffectPARK_NUM'
         AND USETAG = '1';
  
  elsif p_funcCode = 'ParkTagEndDate' then
    open p_cursor for
      SELECT TAGVALUE
        FROM TD_M_TAG
       WHERE TAGCODE = 'PARK_ENDDATE'
         AND USETAG = '1';
  
  elsif p_funcCode = 'XXParkTagEndDate' then
    open p_cursor for
      SELECT TAGVALUE
        FROM TD_M_TAG
       WHERE TAGCODE = 'XXPARK_ENDDATE'
         AND USETAG = '1';
	 
 elsif p_funcCode = 'AffectParkTagEndDate' then
    open p_cursor for
      SELECT TAGVALUE
        FROM TD_M_TAG
       WHERE TAGCODE = 'AffectPARK_ENDDATE'
         AND USETAG = '1';
	 
  elsif p_funcCode = 'QueryOldCards' then
    open p_cursor for
      SELECT C.CARDNO,
             C.ENDDATE,
             C.TOTALTIMES,
             C.SPARETIMES,
             B.CUSTNAME,
             B.PAPERNO,
             B.CUSTPHONE
        FROM TF_F_CUSTOMERREC B, TF_F_CARDPARKACC_SZ C
       WHERE B.CARDNO = C.CARDNO
         AND C.USETAG = '1' --AND C.ENDDATE >= to_char(sysdate, 'yyyymmdd') mod by liuhe20121127
         AND (p_var1 = '01' and B.CARDNO = p_var2 or
             p_var1 = '02' and B.PAPERNO = p_var2 or
             p_var1 = '03' and B.CUSTNAME = p_var2 or
             p_var1 = '04' and B.CUSTPHONE = p_var2);
  
  elsif p_funcCode = 'XXQueryOldCards' then
    open p_cursor for
      SELECT C.CARDNO,
             C.ENDDATE,
             C.TOTALTIMES,
             C.SPARETIMES,
             B.CUSTNAME,
             B.PAPERNO,
             B.CUSTPHONE
        FROM TF_F_CUSTOMERREC B, TF_F_CARDXXPARKACC_SZ C
       WHERE B.CARDNO = C.CARDNO
         AND C.USETAG = '1'
         AND C.ENDDATE >= to_char(sysdate, 'yyyymmdd')
         AND (p_var1 = '01' and B.CARDNO = p_var2 or
             p_var1 = '02' and B.PAPERNO = p_var2 or
             p_var1 = '03' and B.CUSTNAME = p_var2 or
             p_var1 = '04' and B.CUSTPHONE = p_var2);
  
  elsif p_funcCode = 'ParkTradesRight' then
    open p_cursor for
      SELECT r.POSNO, r.SAMNO, r.TRADEDATE, r.TRADETIME, c.CORP, r.DEALTIME
        FROM TQ_PARK_RIGHT r, TD_M_CORP c, TF_TRADE_BALUNIT b
       WHERE r.CARDNO = p_var1
         AND c.CORPNO(+) = b.CORPNO
         AND b.BALUNITNO(+) = r.BALUNITNO
         AND (p_var2 is null or p_var2 = '' or r.TRADEDATE >= p_var2)
         AND (p_var3 is null or p_var3 = '' or r.TRADEDATE <= p_var3)
       ORDER BY r.TRADEDATE desc;
  
  elsif p_funcCode = 'ParkTradesError' then
    open p_cursor for
      SELECT r.POSNO, r.SAMNO, r.TRADEDATE, r.TRADETIME, c.CORP, r.DEALTIME
        FROM TQ_PARK_ERROR r, TD_M_CORP c, TF_TRADE_BALUNIT b
       WHERE r.CARDNO = p_var1
         AND c.CORPNO(+) = b.CORPNO
         AND b.BALUNITNO(+) = r.BALUNITNO
         AND (p_var2 is null or p_var2 = '' or r.TRADEDATE >= p_var2)
         AND (p_var3 is null or p_var3 = '' or r.TRADEDATE <= p_var3)
       ORDER BY r.TRADEDATE desc;
  
  elsif p_funcCode = 'QueryPackage' then
    --查询开通功能项
    open p_cursor for
      SELECT NVL(F.FUNCTIONNAME, C.FUNCTIONTYPE) ||
             FUN_QUERYPACKAGETYPE(DECODE(C.RSRV1, '', '02', C.RSRV1)) FUNCNAME,
             DECODE(C.RSRV1, '', '02', C.RSRV1) RSRV1
        FROM TD_M_FUNCTION F, TF_F_CARDUSEAREA C
       WHERE C.CARDNO = p_var1
         AND C.USETAG = '1'
         AND C.FUNCTIONTYPE IN ('08','18')
         AND (C.ENDTIME IS NULL OR
             C.ENDTIME >= TO_CHAR(SYSDATE, 'YYYYMMDD'))
         AND C.FUNCTIONTYPE = F.FUNCTIONTYPE(+);
		 
  elsif p_funcCode = 'QueryAffectPackageInfo' then
    --查询亲子卡开通功能项
    open p_cursor for
      SELECT NVL(F.FUNCTIONNAME, C.FUNCTIONTYPE) ||
             FUN_QUERYPACKAGETYPE(C.RSRV1) FUNCNAME,
             C.RSRV1
        FROM TD_M_FUNCTION F, TF_F_CARDUSEAREA C
       WHERE C.CARDNO = p_var1
         AND C.USETAG = '1'
         AND C.FUNCTIONTYPE = '18'
         AND (C.ENDTIME IS NULL OR
             C.ENDTIME >= TO_CHAR(SYSDATE, 'YYYYMMDD'))
         AND C.FUNCTIONTYPE = F.FUNCTIONTYPE(+);		 
  
  elsif p_funcCode = 'QueryXXPackage' then
    open p_cursor for
      SELECT DECODE(C.RSRV1, '', '02', C.RSRV1)
        FROM TF_F_CARDUSEAREA C
       WHERE C.CARDNO = p_var1
         AND C.USETAG = '1'
         AND C.FUNCTIONTYPE = '08'
         AND (C.ENDTIME IS NULL OR
             C.ENDTIME >= TO_CHAR(SYSDATE, 'YYYYMMDD'));

  elsif p_funcCode = 'QueryAffectPackage' then
    open p_cursor for
      SELECT C.RSRV1
        FROM TF_F_CARDUSEAREA C
       WHERE C.CARDNO = p_var1
         AND C.USETAG = '1'
         AND C.FUNCTIONTYPE = '18'
         AND (C.ENDTIME IS NULL OR
             C.ENDTIME >= TO_CHAR(SYSDATE, 'YYYYMMDD'));			 
  
  elsif p_funcCode = 'XXParkTradesRight' then
    open p_cursor for
      SELECT r.POSNO, r.SAMNO, r.TRADEDATE, r.TRADETIME, c.CORP, r.DEALTIME
        FROM TQ_XXPARK_RIGHT r, TD_M_CORP c, TF_TRADE_BALUNIT b
       WHERE r.CARDNO = p_var1
         AND c.CORPNO(+) = b.CORPNO
         AND b.BALUNITNO(+) = r.BALUNITNO
         AND (p_var2 is null or p_var2 = '' or r.TRADEDATE >= p_var2)
         AND (p_var3 is null or p_var3 = '' or r.TRADEDATE <= p_var3)
       ORDER BY r.TRADEDATE desc;
  
  elsif p_funcCode = 'XXParkTradesError' then
    open p_cursor for
      SELECT r.POSNO, r.SAMNO, r.TRADEDATE, r.TRADETIME, c.CORP, r.DEALTIME
        FROM TQ_XXPARK_ERROR r, TD_M_CORP c, TF_TRADE_BALUNIT b
       WHERE r.CARDNO = p_var1
         AND c.CORPNO(+) = b.CORPNO
         AND b.BALUNITNO(+) = r.BALUNITNO
         AND (p_var2 is null or p_var2 = '' or r.TRADEDATE >= p_var2)
         AND (p_var3 is null or p_var3 = '' or r.TRADEDATE <= p_var3)
       ORDER BY r.TRADEDATE desc;
  
  elsif p_funcCode = 'CardDeposit' then
    open p_cursor for
      SELECT DEPOSIT FROM TF_F_CARDREC WHERE CARDNO = p_var1;
  
  elsif p_funcCode = 'OldCardDeposit' then
    open p_cursor for
      SELECT BASEFEE
        FROM TD_M_TRADEFEE
       WHERE TRADETYPECODE = '23'
         AND FEETYPECODE = '00';
  
  elsif p_funcCode = 'CardAppType' then
    open p_cursor for
      SELECT APPTYPE
        FROM TF_F_CARDCOUNTACC
       WHERE CARDNO = p_var1
         AND USETAG = '1';
  
  elsif p_funcCode = 'CardAppInfo' then
    open p_cursor for
      SELECT C.APPTYPE, A.AREANAME, A.AREACODE
        FROM TF_F_CARDCOUNTACC C, TD_M_APPAREA A
       WHERE C.CARDNO = p_var1
         AND C.USETAG = '1'
         AND C.ASSIGNEDAREA = A.AREACODE(+)
         AND C.APPTYPE = A.APPTYPE(+);
  
  elsif p_funcCode = 'CardServInfo' then
    open p_cursor for
      SELECT DEPOSIT / 100.0, SERSTARTTIME, SERVICEMONEY, SERSTAKETAG
        FROM TF_F_CARDREC
       WHERE CARDNO = p_var1;
  
  elsif p_funcCode = 'QueryCustInfo' then
    open p_cursor for
      SELECT c.CUSTNAME,
             c.CUSTBIRTH,
             c.PAPERTYPECODE,
             c.PAPERNO,
             c.CUSTSEX,
             c.CUSTPHONE,
             c.CUSTPOST,
             c.CUSTADDR,
             c.REMARK,
             c.CUSTEMAIL
        FROM TF_F_CUSTOMERREC c
       WHERE c.CARDNO = p_var1;
  
  elsif p_funcCode = 'ReadCardType' then
    open p_cursor for
      SELECT c.CARDTYPECODE, c.CARDTYPENAME
        FROM TD_M_CARDTYPE c
       WHERE c.CARDTYPECODE = p_var1;
  
  elsif p_funcCode = 'ReadCardTypeByCardNo' then
    open p_cursor for
      SELECT c.CARDTYPECODE, c.CARDTYPENAME
        FROM TL_R_ICUSER i, TD_M_CARDTYPE c
       WHERE i.CARDNO = p_var1
         AND i.CARDTYPECODE = c.CARDTYPECODE(+);
  
  elsif p_funcCode = 'ReadCardAcc' then
    open p_cursor for
      SELECT A.CARDACCMONEY / 100.0, C.DEPOSIT / 100.0, C.SERSTARTTIME
        FROM TF_F_CARDREC C, TF_F_CARDEWALLETACC A
       WHERE C.CARDNO = A.CARDNO
         AND C.CARDNO = p_var1;
  
  elsif p_funcCode = 'ReadAppArea' then
    open p_cursor for
      SELECT AREANAME, AREACODE
        FROM TD_M_APPAREA
       WHERE APPTYPE = p_var1
         AND (FLAG IS NULL OR FLAG = '1');
  
  elsif p_funcCode = 'CheckParkOpenDay' then
    open p_cursor for
      select operatetime
        from (select t.operatetime
                from tf_b_trade t
               where t.cardno = p_var1
                 and t.tradetypecode = '10'
                 and t.canceltradeid is null
               order by t.operatetime desc)
       where rownum < 2;
  
  elsif p_funcCode = 'CheckTravelOpenDay' then
    open p_cursor for
      select operatetime
        from (select t.operatetime
                from tf_b_trade t
               where t.cardno = p_var1
                 and t.tradetypecode = '6A'
                 and t.canceltradeid is null
               order by t.operatetime desc)
       where rownum < 2;
  
  elsif p_funcCode = 'CheckXXParkOpenDay' then
    open p_cursor for
      select operatetime
        from (select t.operatetime
                from tf_b_trade t
               where t.cardno = p_var1
                 and t.tradetypecode = '25'
                 and t.canceltradeid is null
               order by t.operatetime desc)
       where rownum < 2;
	   
elsif p_funcCode = 'CheckAffectParkOpenDay' then
    open p_cursor for
      select operatetime
        from (select t.operatetime
                from tf_b_trade t
               where t.cardno = p_var1
                 and t.tradetypecode = '65'
                 and t.canceltradeid is null
               order by t.operatetime desc)
       where rownum < 2;	   
  
  elsif p_funcCode in ('ParkCardEndDate', 'ReadParkInfo') then
    --    open p_cursor for
    --    SELECT ENDDATE FROM TF_F_CARDPARKACC_SZ  WHERE CARDNO = p_var1 AND USETAG = '1';
    --
    --elsif p_funcCode = 'ReadParkInfo' then
    open p_cursor for
      SELECT T.ENDDATE,
             T.SPARETIMES,
             T.CARDTIMES,
             T.UPDATESTAFFNO || ':' || S.STAFFNAME,
             T.UPDATETIME
        FROM TF_F_CARDPARKACC_SZ T, TD_M_INSIDESTAFF S
       WHERE T.CARDNO = p_var1
         AND T.USETAG = '1'
         AND T.UPDATESTAFFNO = S.STAFFNO(+);
  
    --吴江旅游年卡读卡信息
  elsif p_funcCode in ('ReadTravelInfo') then
    open p_cursor for
      SELECT T.ENDDATE,
             T.SPARETIMES,
             T.CARDTIMES,
             T.UPDATESTAFFNO || ':' || S.STAFFNAME,
             T.UPDATETIME
        FROM TF_F_CARDTOURACC_WJ T, TD_M_INSIDESTAFF S
       WHERE T.CARDNO = p_var1
         AND T.USETAG = '1'
         AND T.UPDATESTAFFNO = S.STAFFNO(+);
  
  elsif p_funcCode in ('XXParkCardEndDate', 'ReadXXParkInfo') then
    --    open p_cursor for
    --    SELECT ENDDATE FROM TF_F_CARDXXPARKACC_SZ WHERE CARDNO = p_var1 AND USETAG = '1';
    --
    --elsif p_funcCode = 'ReadXXParkInfo' then
    open p_cursor for
      SELECT T.ENDDATE,
             T.SPARETIMES,
             T.CARDTIMES,
             T.UPDATESTAFFNO || ':' || S.STAFFNAME,
             T.UPDATETIME,
             DECODE(T.ACCOUNTTYPE, '1', '线上开通', '线下开通') ACCOUNTTYPE
        FROM TF_F_CARDXXPARKACC_SZ T, TD_M_INSIDESTAFF S
       WHERE T.CARDNO = p_var1
         AND T.USETAG = '1'
         AND T.UPDATESTAFFNO = S.STAFFNO(+);
  
  elsif p_funcCode = 'ReadPaperName' then
    open p_cursor for
      SELECT t.PAPERTYPENAME
        FROM TD_M_PAPERTYPE t
       WHERE t.PAPERTYPECODE = p_var1;
  elsif p_funcCode = 'ReadPaperCode' then
    open p_cursor for
      SELECT t.PAPERTYPECODE
        FROM TD_M_PAPERTYPE t
       WHERE t.PAPERTYPENAME = p_var1;
  
  elsif p_funcCode = 'ReadPaperCodeName' then
    open p_cursor for
      SELECT t.PAPERTYPENAME, t.PAPERTYPECODE
        FROM TD_M_PAPERTYPE t
       where t.usetag = '1'
       order by t.papertypecode;
  
  elsif p_funcCode = 'ReadBlackListCodeName' then
    open p_cursor for
      SELECT t.listtypename, t.listtypecode
        FROM TD_M_BLACKLISTTYPE t
       where t.usetag = '1'
       order by t.listtypecode;
  elsif p_funcCode = 'ReadPackageCodeName' then
    open p_cursor for
      SELECT t.PACKAGETYPENAME, t.PACKAGETYPECODE
        FROM TD_M_PACKAGETYPE t
       order by t.PACKAGETYPECODE;
  
  elsif p_funcCode = 'ReadFeeItems' then
    open p_cursor for
      SELECT f.FEETYPECODE, f.BASEFEE / 100.0, t.FEETYPENAME
        FROM TD_M_TRADEFEE f, TD_M_FEETYPE t
       WHERE f.TRADETYPECODE = p_var1
         AND f.FEETYPECODE = t.FEETYPECODE;
  
  elsif p_funcCode = 'ReadNewTradeBySeqNo' then
    open p_cursor for
      SELECT TRADEID, TRADETYPECODE, OPERATETIME, RSRV1
        FROM TF_B_TRADE
       WHERE TRADEID = p_var1;
  
  elsif p_funcCode = 'ReadNewTrades' then
    declare
      v_opTime  date := null;
      v_tradeId char(16) := null;
    begin
      for v_cur in (SELECT *
                      FROM TF_B_TRADE
                     WHERE CARDNO = p_var1
                       AND OPERATESTAFFNO = p_var2
                       AND OPERATETIME BETWEEN TRUNC(SYSDATE, 'DD') AND
                           SYSDATE
                       AND CANCELTAG = '0'
                       AND CANCELTRADEID IS NULL
                     ORDER BY OPERATETIME DESC) loop
        if v_opTime is null then
          v_opTime := v_cur.OPERATETIME;
        end if;
      
        exit when v_opTime <> v_cur.OPERATETIME;
      
        if v_cur.TRADETYPECODE in
           ('31', '32', '23', '70', '71', '72', '7A', '7B') then
          v_tradeId := v_cur.TRADEID;
          exit;
        end if;
      end loop;
    
      open p_cursor for
        SELECT TRADEID, TRADETYPECODE, OPERATETIME
          FROM TF_B_TRADE
         WHERE TRADEID = v_tradeId;
    end;
  elsif p_funcCode = 'ReadChangeTrades' then
    declare
      v_opTime  date := null;
      v_tradeId char(16) := null;
    begin
      for v_cur in (SELECT *
                      FROM TF_B_TRADE
                     WHERE CARDNO = p_var1
                       AND OPERATESTAFFNO = p_var2
                       AND OPERATETIME BETWEEN TRUNC(SYSDATE, 'DD') AND
                           SYSDATE
                       AND CANCELTAG = '0'
                       AND CANCELTRADEID IS NULL
                     ORDER BY OPERATETIME DESC) loop
        if v_opTime is null then
          v_opTime := v_cur.OPERATETIME;
        end if;
      
        exit when v_opTime <> v_cur.OPERATETIME;
      
        if v_cur.TRADETYPECODE in ('73', '74', '75', '7C') then
          v_tradeId := v_cur.TRADEID;
          exit;
        end if;
      end loop;
    
      open p_cursor for
        SELECT TRADEID, TRADETYPECODE, OPERATETIME, REASONCODE
          FROM TF_B_TRADE
         WHERE TRADEID = v_tradeId;
    end;
  
  elsif p_funcCode = 'ReadTradeFee' then
    open p_cursor for
      SELECT CARDDEPOSITFEE / 100.0,
             CARDSERVFEE / 100.0,
             OTHERFEE / 100.0,
             FUNCFEE / 100.0
        FROM TF_B_TRADEFEE
       WHERE TRADEID = p_var1;
  
  elsif p_funcCode = 'ReadTradeTypeName' then
    open p_cursor for
      SELECT TRADETYPE FROM TD_M_TRADETYPE WHERE TRADETYPECODE = p_var1;
  
  elsif p_funcCode = 'ReadGardenTimes' then
    open p_cursor for
      SELECT SPARETIMES
        FROM TF_F_CARDPARKACC_SZ
       WHERE CARDNO = p_var1
         AND USETAG = '1';
  elsif p_funcCode = 'ReadRelaxTimes' then
    open p_cursor for
      SELECT SPARETIMES
        FROM TF_F_CARDXXPARKACC_SZ
       WHERE CARDNO = p_var1
         AND USETAG = '1';
  elsif p_funcCode = 'ReadWjLvyouTimes' then
    open p_cursor for
      SELECT SPARETIMES
        FROM TF_F_CARDTOURACC_WJ
       WHERE CARDNO = p_var1
         AND USETAG = '1';
  
  elsif p_funcCode = 'QueryCardState' then
    open p_cursor for
      SELECT T.RESSTATECODE, NVL(R.RESSTATE, T.RESSTATECODE)
        FROM TL_R_ICUSER T, TD_M_RESOURCESTATE R
       WHERE T.CARDNO = p_var1
         AND T.RESSTATECODE = R.RESSTATECODE(+);
  elsif p_funcCode = 'QueryAccountType' then
    open p_cursor for
      SELECT DECODE(T.ACCOUNTTYPE, '1', '线上开通', '线下开通') ACCOUNTTYPE
        FROM TF_F_CARDXXPARKACC_SZ T
       WHERE T.CARDNO = p_var1
         AND T.USETAG = '1';
  elsif p_funcCode = 'QueryPaperIsPark' then
    --wdx 20111106查询身份证是否开通过园林功能
    open p_cursor for
      select tm.CARDNO, ENDDATE, CUSTNAME, PAPERNO, EXEMPTION, sz.PICTURE
        from (select c.CARDNO,
                     c.ENDDATE,
                     t.CUSTNAME,
                     t.PAPERNO,
                     nvl((select '是'
                           from TF_F_CARDPARKWHITELIST d
                          where d.paperno = p_var1
                            and usetag = '1'),
                         '否') EXEMPTION
                from TF_F_CARDPARKACC_SZ c, tf_f_customerrec t
               where t.paperno = p_var1
                 and c.cardno = t.cardno
                 and c.enddate >= to_char(sysdate, 'yyyyMMdd')
                 and c.usetag = '1') tm
        left join TF_F_CARDPARKPHOTO_SZ sz
          on tm.cardno = sz.cardno;
  elsif p_funcCode = 'QueryPaperIsWhiteList' then
    --shil 20121015 判断身份证号是否免检
    open p_cursor for
      select t.CARDNO,
             '' ENDDATE,
             t.CUSTNAME,
             p_var1 PAPERNO,
             nvl((select '是'
                   from TF_F_CARDPARKWHITELIST d
                  where d.paperno = p_var1
                    and usetag = '1'),
                 '否') EXEMPTION,
             sz.PICTURE PICTURE
        from tf_f_customerrec t, TF_F_CARDPARKPHOTO_SZ sz
       where t.paperno = p_var1
         and t.cardno = sz.cardno(+)
         and t.usetag = '1';
  elsif p_funcCode = 'QueryPaperIsTravel' then
    --jiangbb 2012-05-03查询身份证是否开通过吴江旅游年卡
    open p_cursor for
      select c.CARDNO, c.ENDDATE, t.CUSTNAME
        from TF_F_CARDTOURACC_WJ c
       inner join tf_f_customerrec t
          on c.cardno = t.cardno
       where t.paperno = p_var1
         and c.enddate > to_char(sysdate + 31, 'yyyyMMdd')
         and c.usetag = '1';
  
  elsif p_funcCode = 'QueryZJGOldCardMonth' then
    --wdx 20111117查询张家港公交月票旧卡的月票功能和有效期
    open p_cursor for
      select c.CARDNO, c.APPTYPE, c.ENDTIME
        from TF_F_CARDCOUNTACC c
       where c.CARDNO = p_var1
         and c.usetag = '1';
  
  elsif p_funcCode = 'WJTourCardUseTag' then
    --by shil 20120502 校验吴江旅游年卡USETAG值
    open p_cursor for
      SELECT USETAG
        FROM TF_F_CARDTOURACC_WJ
       WHERE CARDNO = p_var1
         AND USETAG = '1';
  elsif p_funcCode = 'QueryOldWJTourCards' then
    --by shil 20120502 查询旧吴江旅游年卡信息
    open p_cursor for
      SELECT C.CARDNO,
             C.ENDDATE,
             C.TOTALTIMES,
             C.SPARETIMES,
             B.CUSTNAME,
             B.PAPERNO,
             B.CUSTPHONE
        FROM TF_F_CUSTOMERREC B, TF_F_CARDTOURACC_WJ C
       WHERE B.CARDNO = C.CARDNO
         AND C.USETAG = '1'
         AND C.ENDDATE >= to_char(sysdate, 'yyyymmdd')
         AND (p_var1 = '01' and B.CARDNO = p_var2 or
             p_var1 = '02' and B.PAPERNO = p_var2 or
             p_var1 = '03' and B.CUSTNAME = p_var2 or
             p_var1 = '04' and B.CUSTPHONE = p_var2);
  elsif p_funcCode = 'WJTourTradesRight' then
    --by shil 20120502 查询吴江旅游年卡正常交际记录
    open p_cursor for
      SELECT r.POSNO, r.SAMNO, r.TRADEDATE, r.TRADETIME, c.CORP, r.DEALTIME
        FROM TQ_TOUR_WJ_RIGHT r, TD_M_CORP c, TF_TRADE_BALUNIT b
       WHERE r.CARDNO = p_var1
         AND c.CORPNO(+) = b.CORPNO
         AND b.BALUNITNO(+) = r.BALUNITNO
         AND (p_var2 is null or p_var2 = '' or r.TRADEDATE >= p_var2)
         AND (p_var3 is null or p_var3 = '' or r.TRADEDATE <= p_var3)
       ORDER BY r.TRADEDATE desc;
  elsif p_funcCode = 'WJTourTradesError' then
    --by shil 20120502 查询吴江旅游年卡异常交际记录
    open p_cursor for
      SELECT r.POSNO, r.SAMNO, r.TRADEDATE, r.TRADETIME, c.CORP, r.DEALTIME
        FROM TQ_TOUR_WJ_ERROR r, TD_M_CORP c, TF_TRADE_BALUNIT b
       WHERE r.CARDNO = p_var1
         AND c.CORPNO(+) = b.CORPNO
         AND b.BALUNITNO(+) = r.BALUNITNO
         AND (p_var2 is null or p_var2 = '' or r.TRADEDATE >= p_var2)
         AND (p_var3 is null or p_var3 = '' or r.TRADEDATE <= p_var3)
       ORDER BY r.TRADEDATE desc;
  elsif p_funcCode = 'LatestRCTradeByPaperNo' then
    --查询同一证件号最近一张惠民休闲年卡的业务情况
    open p_cursor for
      SELECT C.CARDNO, C.OPERATETIME, C.OPERATEDEPARTID, D.DEPARTNAME
        FROM TF_B_TRADE C
       INNER JOIN TF_F_CUSTOMERREC A
          ON C.CARDNO = A.CARDNO
       INNER JOIN TF_F_CARDXXPARKACC_SZ B
          ON C.CARDNO = B.CARDNO
       INNER JOIN TD_M_INSIDEDEPART D
          ON C.OPERATEDEPARTID = D.DEPARTNO
       WHERE B.ENDDATE = (SELECT substr(TAGVALUE, 1, 8) ENDDATE
                            FROM TD_M_TAG
                           WHERE TAGCODE = 'XXPARK_ENDDATE'
                             AND USETAG = '1')
            
         AND C.TRADETYPECODE IN ('25', '33')
         AND A.USETAG = '1'
         AND B.USETAG = '1'
         AND C.CANCELTAG = '0'
         AND A.PAPERNO = p_var1
       ORDER BY C.OPERATETIME DESC;
  elsif p_funcCode = 'RCCustomerRecReport' then
    --查询惠民休闲年卡客户资料
    open p_cursor for
      SELECT E.TRADETYPE || FUN_QUERYPACKAGETYPE(C.RSRV2) 业务类型,
             to_char(C.OPERATETIME, 'yyyyMMdd') 操作日期,
             to_char(C.Operatetime, 'HH24MISS') 操作时间,
             A.CARDNO 卡号,
             C.OLDCARDNO 旧卡号,
             A.CUSTNAME 姓名,
             D.PAPERTYPENAME 证件类型,
             A.PAPERNO 证件号码,
             A.CUSTPHONE 联系电话,
             A.CUSTADDR 地址
        FROM TF_F_CUSTOMERREC A
       INNER join TF_F_CARDXXPARKACC_SZ S
          on A.CARDNO = S.CARDNO
       inner join TF_B_TRADE C
          ON A.CARDNO = C.CARDNO
        left join TD_M_PAPERTYPE D
          ON A.PAPERTYPECODE = D.PAPERTYPECODE
        left join TD_M_TRADETYPE E
          ON C.Tradetypecode = E.tradetypecode
       where TO_CHAR(C.OPERATETIME, 'yyyyMMdd') = p_var1
         AND C.CANCELTAG = '0'
         AND C.TRADETYPECODE IN ('25', '33','65','66')
         AND (p_var2 is null or p_var2 = '' or p_var2 = S.PACKAGETYPECODE)
       order by tradetype desc, C.OPERATETIME desc;
  elsif p_funcCode = 'TravelRecycleHistory' then
    ---旅游卡回收历史统计查询
    open p_cursor for
      select a.OLDASSIGNEDSTAFFNO || ':' || d.STAFFNAME STAFFNAMEOLD,
             a.ASSIGNEDSTAFFNO || ':' || c.STAFFNAME STAFFNAMENow,
             e.Departno || ':' || e.DEPARTNAME DEPARTNAMEOLD,
             f.Departno || ':' || f.DEPARTNAME DEPARTNAMENOW,
             COUNT(*) NUM
        from TF_B_TRADE_SZTRAVEL a,
             TD_M_INSIDESTAFF    c,
             TD_M_INSIDESTAFF    d,
             TD_M_INSIDEDEPART   e,
             TD_M_INSIDEDEPART   f,
             TD_M_INSIDESTAFF    h
       where a.TRADETYPECODE = '7K' --旅游卡回收
         and a.ASSIGNEDSTAFFNO = c.STAFFNO
         and a.OLDASSIGNEDSTAFFNO = d.STAFFNO
         and c.departno = f.departno
         and d.departno = e.departno
         and a.operatestaffno = h.staffno
         and (p_var1 IS NULL OR p_var1 = '' OR p_var1 = e.departno)
         and (p_var2 IS NULL OR p_var2 = '' OR p_var2 = d.staffno)
         and (p_var3 IS NULL OR p_var3 = '' OR p_var3 = f.departno)
         and (p_var4 IS NULL OR p_var4 = '' OR p_var4 = c.staffno)
         and (p_var5 IS NULL OR p_var5 = '' OR
             a.operatetime >=
             TO_DATE(p_var5 || '000000', 'YYYYMMDDHH24MISS'))
         and (p_var6 IS NULL OR p_var6 = '' OR
             a.operatetime <=
             TO_DATE(p_var6 || '235959', 'YYYYMMDDHH24MISS'))
         and (p_var7 IS NULL OR p_var7 = '' OR p_var7 = a.operatestaffno)
       group by a.oldassignedstaffno,
                d.staffname,
                a.assignedstaffno,
                c.staffname,
                e.departno,
                e.departname,
                f.departno,
                f.departname;
  elsif p_funcCode = 'TravelRecycleHistoryDetail' then
    ---旅游卡回收历史明细查询
    open p_cursor for
      select a.CARDNO,
             a.OLDASSIGNEDSTAFFNO || ':' || d.STAFFNAME STAFFNAMEOLD,
             a.ASSIGNEDSTAFFNO || ':' || c.STAFFNAME STAFFNAMENow,
             e.Departno || ':' || e.DEPARTNAME DEPARTNAMEOLD,
             f.Departno || ':' || f.DEPARTNAME DEPARTNAMENOW,
             a.operatetime OPERATETIME,
             a.operatestaffno || ':' || h.staffname OPERATESTAFF
        from TF_B_TRADE_SZTRAVEL a,
             TD_M_INSIDESTAFF    c,
             TD_M_INSIDESTAFF    d,
             TD_M_INSIDEDEPART   e,
             TD_M_INSIDEDEPART   f,
             TD_M_INSIDESTAFF    h
       where a.TRADETYPECODE = '7K' --旅游卡回收
         and a.ASSIGNEDSTAFFNO = c.STAFFNO
         and a.OLDASSIGNEDSTAFFNO = d.STAFFNO
         and c.departno = f.departno
         and d.departno = e.departno
         and a.operatestaffno = h.staffno
         and (p_var1 IS NULL OR p_var1 = '' OR p_var1 = e.departno)
         and (p_var2 IS NULL OR p_var2 = '' OR p_var2 = d.staffno)
         and (p_var3 IS NULL OR p_var3 = '' OR p_var3 = f.departno)
         and (p_var4 IS NULL OR p_var4 = '' OR p_var4 = c.staffno)
       order by a.operatetime desc;
  elsif p_funcCode = 'XXCARDFORAPPROVAL' then
    --查询休闲POS开通的数据
    open p_cursor for
      SELECT NVL2(C.CUSTNAME, '1', '0') VALIDTYPE,
             A.ID,
             A.POSNO,
             A.SAMNO,
             A.CARDNO,
             A.STARTDATE,
             B.ENDDATE CARDXXENDDATE,
             B.CARDTIMES,
             C.CUSTNAME,
             C.PAPERTYPECODE,
             C.PAPERNO,
             C.CUSTPHONE,
             C.CUSTADDR
        FROM TF_XXPARK_NEW_LOAD    A,
             TF_F_CARDXXPARKACC_SZ B,
             TF_F_CUSTOMERREC      C
       WHERE A.CARDNO = B.CARDNO
         AND A.CARDNO = C.CARDNO(+)
         AND A.ERRORREASONCODE = '0' --表示正常数据
         AND A.DEALCODE = '0' --表示未处理数据
         AND (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.POSNO)
         AND (P_VAR2 IS NULL OR P_VAR2 = '' OR A.UPDATETIME >= P_VAR2)
         AND (P_VAR3 IS NULL OR P_VAR3 = '' OR A.UPDATETIME <= P_VAR3);
  elsif p_funcCode = 'ParkCardUseIsInvalid' then
    --查询当前卡是否是园林账户表中无效的卡
    open p_cursor for
      SELECT TRADEID
        FROM TF_B_TRADE
       WHERE OLDCARDNO = p_var1
         AND TRADETYPECODE = '36'
         AND CANCELTAG = '0'
      union all
         SELECT TRADEID
        FROM TF_B_TRADE_bak
       WHERE OLDCARDNO = p_var1
         AND TRADETYPECODE = '36'
         AND CANCELTAG = '0';
  elsif p_funcCode = 'RelaxCardUseIsInvalid' then
    --查询当前卡是否是休闲账户表中无效的卡
    open p_cursor for
      SELECT TRADEID
        FROM TF_B_TRADE
       WHERE OLDCARDNO = p_var1
         AND TRADETYPECODE = '33'
         AND CANCELTAG = '0'
     union all
     SELECT TRADEID
        FROM TF_B_TRADE
       WHERE OLDCARDNO = p_var1
         AND TRADETYPECODE = '33'
         AND CANCELTAG = '0';
  elsif p_funcCode = 'QUERYLIBRARYFILEDETAIL' then
    --查询图书馆对账文件明细
    open p_cursor for
      SELECT F.FILENAME,
             F.TRADEDATE,
             d.CARDNO,
             decode(d.TRADETYPECODE,
                    '01',
                    '01:发卡',
                    '02',
                    '02:挂失',
                    '03',
                    '03:解挂',
                    '04',
                    '04:补换',
                    '10',
                    '10:开通',
                    '11',
                    '11:普通关闭',
                    '12',
                    '12:挂失关闭') TRADETYPECODE,
             decode(d.STATES, '0', '0:成功', '1', '1:失败') STATES,
             d.ERRINFO,
             F.FILEDATE,
             S.STAFFNAME,
             F.OPERATETIME
        FROM TF_B_LIB_FILE F, TF_B_LIB_FILE_DETAIL D, TD_M_INSIDESTAFF S
       WHERE F.TRADEID = D.FILEID
         AND F.OPERATESTAFFNO = s.STAFFNO(+)
         and (p_var1 IS NULL OR p_var1 = '' OR d.TRADETYPECODE = p_var1)
         and (p_var2 IS NULL OR p_var2 = '' OR d.STATES = p_var2)
         and (p_var3 IS NULL OR p_var3 = '' OR
             TO_CHAR(F.OPERATETIME, 'yyyyMMdd') >= p_var3)
         and (p_var4 IS NULL OR p_var4 = '' OR
             TO_CHAR(F.OPERATETIME, 'yyyyMMdd') <= p_var4)
       Order by F.OPERATETIME Desc;
  elsif p_funcCode = 'QUERYLIBRARYSYNC' then
    --查询图书馆同步明细
    open p_cursor for
      SELECT decode(L.SYNCTYPECODE,
                    '0001',
                    '0001:A卡开通',
                    '0002',
                    '0002:A卡挂失',
                    '0003',
                    '0003:市民卡补换卡',
                    '0004',
                    '0004:卡注销校验',
                    '0005',
                    '0005:欠费查询',
                    '1001',
                    '1001:开通校验',
                    '1002',
                    '1002:开通关闭') SYNCTYPECODE,
             decode(L.SYNCCODE,
                    '0',
                    '0:未同步',
                    '1',
                    '1:同步成功',
                    '2',
                    '2:同步失败') SYNCCODE,
             decode(L.SYNCTYPECODE,
                    '0002',
                    decode(L.TRADETYPECODE, '01', '01:挂失', '02', '02:解挂'),
                    '1002',
                    decode(L.TRADETYPECODE,
                           '01',
                           '01:开通',
                           '02',
                           '02:普通关闭',
                           '03',
                           '03:挂失关闭')) TRADETYPECODE,
             decode(L.PROCEDURESYNCCODE,
                    '0',
                    '0:未处理',
                    '1',
                    '1:处理成功',
                    '2',
                    '2:处理失败') PROCEDURESYNCCODE,
             decode(L.SYNCHOME, '01', '01:市民卡公司', 'L1', 'L1:图书馆') SYNCHOME,
             decode(L.SYNCCLIENT, '01', '01:市民卡公司', 'L1', 'L1:图书馆') SYNCCLIENT,
             L.CARDNO,
             L.SOCLSECNO,
             L.NAME,
             decode(L.PAPERTYPECODE,
                    '01',
                    '01:身份证',
                    '02',
                    '02:护照',
                    '03',
                    '03:港澳通行证',
                    '99',
                    '99:其他') PAPERTYPECODE,
             L.PAPERNO,
             L.BIRTH,
             decode(L.SEX, '0', '男', '1', '女') SEX,
             L.PHONE,
             L.CUSTPOST,
             L.ADDR,
             L.EMAIL,
             LASTSYNCTIME
        FROM TF_B_LIB_SYNC L
       WHERE (p_var1 IS NULL OR p_var1 = '' OR L.CARDNO = p_var1)
         AND (p_var2 IS NULL OR p_var2 = '' OR L.SYNCTYPECODE = p_var2)
         AND (p_var3 IS NULL OR p_var3 = '' OR L.SYNCCODE = p_var3)
         AND (p_var4 IS NULL OR p_var4 = '' OR L.SYNCHOME = p_var4)
         AND (p_var5 IS NULL OR p_var5 = '' OR L.PROCEDURESYNCCODE = p_var5)
         AND (p_var6 IS NULL OR p_var6 = '' OR
             TO_CHAR(L.UPDATETIME, 'yyyyMMdd') >= p_var6)
         AND (p_var7 IS NULL OR p_var7 = '' OR
             TO_CHAR(L.UPDATETIME, 'yyyyMMdd') <= p_var7)
       Order by UPDATETIME Desc, LASTSYNCTIME DESC;
  
  elsif p_funcCode = 'QUERYCARDOPENLIB' then
    --查询卡是否开通图书馆功能
    open p_cursor for
      SELECT CARDNO
        FROM TF_F_CARDUSEAREA
       WHERE CARDNO = p_var1
         AND FUNCTIONTYPE = '17';
  elsif p_funcCode = 'SPTRAVELCARDLINES' then
    --查询世乒卡套餐功能费
    open p_cursor for
      SELECT PACKAGETYPECODE, PACKAGEFEE FROM TD_M_SPPACKAGETYPE;
  elsif p_funcCode = 'QUERYSPTRAVELCARDINFOS' then
    --根据卡号查询卡号对应套餐
    open p_cursor for
      SELECT s.PACKAGETYPECODE,
             s.PACKAGEFEE,
             s.PACKAGETYPENAME,
             s.ENDDATE,
             f.departname,
             h.staffname,
             t.UPDATETIME
        FROM TF_F_SPPACKAGETYPEATION t,
             TD_M_SPPACKAGETYPE      s,
             TD_M_INSIDEDEPART       f,
             TD_M_INSIDESTAFF        h
       WHERE t.PACKAGETYPECODE = s.PACKAGETYPECODE
         AND t.updatestaffno = h.staffno
         AND t.updatedepartid = f.departno
         AND (p_var1 IS NULL OR p_var1 = '' OR t.CARDNO = p_var1);
  elsif p_funcCode = 'SPTravelTradesRight' then
    --查询世乒旅游卡号正常清单表
    open p_cursor for
      SELECT r.POSNO,
             r.SAMNO,
             r.TRADEDATE,
             r.TRADETIME,
             c.CORP,
             r.DEALTIME,
             r.TRAVELSIGN
        FROM TQ_SP_TRAVEL_RIGHT r, TD_M_CORP c, TF_TRADE_BALUNIT b
       WHERE r.CARDNO = p_var1
         AND c.CORPNO(+) = b.CORPNO
         AND b.BALUNITNO(+) = r.BALUNITNO
         AND (p_var2 is null or p_var2 = '' or r.TRADEDATE >= p_var2)
         AND (p_var3 is null or p_var3 = '' or r.TRADEDATE <= p_var3)
       ORDER BY r.TRADEDATE, r.TRADETIME desc;
  elsif p_funcCode = 'SPTravelTradesError' then
    --查询世乒旅游卡号异常清单表
    open p_cursor for
      SELECT r.POSNO,
             r.SAMNO,
             r.TRADEDATE,
             r.TRADETIME,
             c.CORP,
             r.DEALTIME,
             r.TRAVELSIGN
        FROM TQ_SP_TRAVEL_ERROR r, TD_M_CORP c, TF_TRADE_BALUNIT b
       WHERE r.CARDNO = p_var1
         AND c.CORPNO(+) = b.CORPNO
         AND b.BALUNITNO(+) = r.BALUNITNO
         AND (p_var2 is null or p_var2 = '' or r.TRADEDATE >= p_var2)
         AND (p_var3 is null or p_var3 = '' or r.TRADEDATE <= p_var3)
       ORDER BY r.TRADEDATE, r.TRADETIME desc;
  elsif p_funcCode = 'QueryRelaxCardChangeUserInfo' then
    --查询休闲资料变更信息
    open p_cursor for
      select *
        from (
              ---)照片和资料都修改
              SELECT '3' CHANGECODE,
                      s.picture,
                      t.CARDNO,
                      t.CUSTNAME,
                      decode(t.CUSTSEX, '0', '男', '1', '女') CUSTSEX,
                      t.CUSTBIRTH,
                      decode(t.PAPERTYPECODE,
                             '00',
                             '身份证',
                             '01',
                             '军官证',
                             '05',
                             '护照',
                             '06',
                             '港澳台通行证',
                             '07',
                             '户口簿',
                             '08',
                             '武警证',
                             '09',
                             '台胞证',
                             '99',
                             '其他') PAPERTYPECODE,
                      t.PAPERNO,
                      t.CUSTADDR,
                      t.CUSTPOST,
                      t.CUSTPHONE,
                      t.CUSTEMAIL,
                      d.staffname UPDATESTAFFNO,
                      t.UPDATETIME
                FROM TF_F_CARDPARKCUSTOMERREC_SZ t,
                      TF_F_CARDPARKPHOTOCHANGE_SZ s,
                      TD_M_INSIDESTAFF            d,
                      TD_M_INSIDEDEPART           e
               WHERE t.STATE = '0'
                 AND s.STATE = '0'
                 AND t.CARDNO = s.Cardno
                 AND t.updatestaffno = d.staffno
                 AND d.departno = e.departno
                 AND (p_var1 is null or p_var1 = '' or
                     t.updatetime >=
                     to_date(p_var1 || '000000', 'yyyymmddhh24miss'))
                 AND (p_var2 is null or p_var2 = '' or
                     t.updatetime <=
                     to_date(p_var2 || '235959', 'yyyymmddhh24miss'))
                 AND (p_var3 IS NULL OR p_var3 = '' OR e.departno = p_var3)
                 AND (p_var4 IS NULL OR p_var4 = '' OR
                     t.updatestaffno = p_var4)
                 AND (p_var5 IS NULL OR p_var5 = '' OR t.CARDNO = p_var5)
                 AND (p_var6 IS NULL OR p_var6 = '' OR
                     t.PAPERTYPECODE = p_var6)
                 AND (p_var7 IS NULL OR p_var7 = '' OR t.PAPERNO = p_var7)
              union all
              --）只修改资料
              SELECT '1' CHANGECODE,
                     s.picture,
                     t.CARDNO,
                     t.CUSTNAME,
                     decode(t.CUSTSEX, '0', '男', '1', '女') CUSTSEX,
                     t.CUSTBIRTH,
                     decode(t.PAPERTYPECODE,
                            '00',
                            '身份证',
                            '01',
                            '军官证',
                            '05',
                            '护照',
                            '06',
                            '港澳台通行证',
                            '07',
                            '户口簿',
                            '08',
                            '武警证',
                            '09',
                            '台胞证',
                            '99',
                            '其他') PAPERTYPECODE,
                     t.PAPERNO,
                     t.CUSTADDR,
                     t.CUSTPOST,
                     t.CUSTPHONE,
                     t.CUSTEMAIL,
                     d.staffname UPDATESTAFFNO,
                     t.UPDATETIME
                FROM TF_F_CARDPARKCUSTOMERREC_SZ t,
                     TF_F_CARDPARKPHOTO_SZ       s,
                     TD_M_INSIDESTAFF            d,
                     TD_M_INSIDEDEPART           e
               WHERE t.STATE = '0'
                 AND t.CARDNO = s.Cardno(+)
                 AND t.CARDNO NOT IN (SELECT DISTINCT s.CARDNO
                                        FROM TF_F_CARDPARKPHOTOCHANGE_SZ s
                                       WHERE s.state = '0')
                 AND t.updatestaffno = d.staffno
                 AND d.departno = e.departno
                 AND (p_var1 is null or p_var1 = '' or
                     t.updatetime >=
                     to_date(p_var1 || '000000', 'yyyymmddhh24miss'))
                 AND (p_var2 is null or p_var2 = '' or
                     t.updatetime <=
                     to_date(p_var2 || '235959', 'yyyymmddhh24miss'))
                 AND (p_var3 IS NULL OR p_var3 = '' OR e.departno = p_var3)
                 AND (p_var4 IS NULL OR p_var4 = '' OR
                     t.updatestaffno = p_var4)
                 AND (p_var5 IS NULL OR p_var5 = '' OR t.CARDNO = p_var5)
                 AND (p_var6 IS NULL OR p_var6 = '' OR
                     t.PAPERTYPECODE = p_var6)
                 AND (p_var7 IS NULL OR p_var7 = '' OR t.PAPERNO = p_var7)
              union all
              ---）只修改照片
              SELECT '2' CHANGECODE,
                     s.picture,
                     t.CARDNO,
                     t.CUSTNAME,
                     decode(t.CUSTSEX, '0', '男', '1', '女') CUSTSEX,
                     t.CUSTBIRTH,
                     decode(t.PAPERTYPECODE,
                            '00',
                            '身份证',
                            '01',
                            '军官证',
                            '05',
                            '护照',
                            '06',
                            '港澳台通行证',
                            '07',
                            '户口簿',
                            '08',
                            '武警证',
                            '09',
                            '台胞证',
                            '99',
                            '其他') PAPERTYPECODE,
                     t.PAPERNO,
                     t.CUSTADDR,
                     t.CUSTPOST,
                     t.CUSTPHONE,
                     t.CUSTEMAIL,
                     d.staffname UPDATESTAFFNO,
                     t.UPDATETIME
                FROM TF_F_CUSTOMERREC            t,
                     TF_F_CARDPARKPHOTOCHANGE_SZ s,
                     TD_M_INSIDESTAFF            d,
                     TD_M_INSIDEDEPART           e
               WHERE s.STATE = '0'
                 AND t.CARDNO = s.Cardno
                 AND t.CARDNO NOT IN (SELECT DISTINCT t.CARDNO
                                        FROM TF_F_CARDPARKCUSTOMERREC_SZ t
                                       WHERE t.state = '0')
                 AND t.updatestaffno = d.staffno
                 AND d.departno = e.departno
                 AND (p_var1 is null or p_var1 = '' or
                     t.updatetime >=
                     to_date(p_var1 || '000000', 'yyyymmddhh24miss'))
                 AND (p_var2 is null or p_var2 = '' or
                     t.updatetime <=
                     to_date(p_var2 || '235959', 'yyyymmddhh24miss'))
                 AND (p_var3 IS NULL OR p_var3 = '' OR e.departno = p_var3)
                 AND (p_var4 IS NULL OR p_var4 = '' OR
                     t.updatestaffno = p_var4)
                 AND (p_var5 IS NULL OR p_var5 = '' OR t.CARDNO = p_var5)
                 AND (p_var6 IS NULL OR p_var6 = '' OR
                     t.PAPERTYPECODE = p_var6)
                 AND (p_var7 IS NULL OR p_var7 = '' OR t.PAPERNO = p_var7)
              union all
              ---）原始资料
              SELECT '0' CHANGECODE,
                     s.picture,
                     t.CARDNO,
                     t.CUSTNAME,
                     decode(t.CUSTSEX, '0', '男', '1', '女') CUSTSEX,
                     t.CUSTBIRTH,
                     decode(t.PAPERTYPECODE,
                            '00',
                            '身份证',
                            '01',
                            '军官证',
                            '05',
                            '护照',
                            '06',
                            '港澳台通行证',
                            '07',
                            '户口簿',
                            '08',
                            '武警证',
                            '09',
                            '台胞证',
                            '99',
                            '其他') PAPERTYPECODE,
                     t.PAPERNO,
                     t.CUSTADDR,
                     
                     t.CUSTPOST,
                     t.CUSTPHONE,
                     t.CUSTEMAIL,
                     d.staffname UPDATESTAFFNO,
                     t.UPDATETIME
                FROM TF_F_CUSTOMERREC t,
                     TF_F_CARDPARKPHOTO_SZ s,
                     TD_M_INSIDESTAFF d,
                     TD_M_INSIDEDEPART e,
                     (SELECT '3' CHANGECODE,
                             s.picture,
                             t.CARDNO,
                             t.CUSTNAME,
                             decode(t.CUSTSEX, '0', '男', '1', '女') CUSTSEX,
                             t.CUSTBIRTH,
                             decode(t.PAPERTYPECODE,
                                    '00',
                                    '身份证',
                                    '01',
                                    '军官证',
                                    '05',
                                    '护照',
                                    '06',
                                    '港澳台通行证',
                                    '07',
                                    '户口簿',
                                    '08',
                                    '武警证',
                                    '09',
                                    '台胞证',
                                    '99',
                                    '其他') PAPERTYPECODE,
                             t.PAPERNO,
                             t.CUSTADDR,
                             t.CUSTPOST,
                             t.CUSTPHONE,
                             t.CUSTEMAIL,
                             d.staffname UPDATESTAFFNO,
                             t.UPDATETIME
                        FROM TF_F_CARDPARKCUSTOMERREC_SZ t,
                             TF_F_CARDPARKPHOTOCHANGE_SZ s,
                             TD_M_INSIDESTAFF            d,
                             TD_M_INSIDEDEPART           e
                       WHERE t.STATE = '0'
                         AND s.STATE = '0'
                         AND t.CARDNO = s.Cardno
                         AND t.updatestaffno = d.staffno
                         AND d.departno = e.departno
                         AND (p_var1 is null or p_var1 = '' or
                             t.updatetime >=
                             to_date(p_var1 || '000000', 'yyyymmddhh24miss'))
                         AND (p_var2 is null or p_var2 = '' or
                             t.updatetime <=
                             to_date(p_var2 || '235959', 'yyyymmddhh24miss'))
                         AND (p_var3 IS NULL OR p_var3 = '' OR
                             e.departno = p_var3)
                         AND (p_var4 IS NULL OR p_var4 = '' OR
                             t.updatestaffno = p_var4)
                         AND (p_var5 IS NULL OR p_var5 = '' OR
                             t.CARDNO = p_var5)
                         AND (p_var6 IS NULL OR p_var6 = '' OR
                             t.PAPERTYPECODE = p_var6)
                         AND (p_var7 IS NULL OR p_var7 = '' OR
                             t.PAPERNO = p_var7)
                      union all
                      --）只修改资料
                      SELECT '1' CHANGECODE,
                             s.picture,
                             t.CARDNO,
                             t.CUSTNAME,
                             decode(t.CUSTSEX, '0', '男', '1', '女') CUSTSEX,
                             t.CUSTBIRTH,
                             decode(t.PAPERTYPECODE,
                                    '00',
                                    '身份证',
                                    '01',
                                    '军官证',
                                    '05',
                                    '护照',
                                    '06',
                                    '港澳台通行证',
                                    '07',
                                    '户口簿',
                                    '08',
                                    '武警证',
                                    '09',
                                    '台胞证',
                                    '99',
                                    '其他') PAPERTYPECODE,
                             t.PAPERNO,
                             t.CUSTADDR,
                             t.CUSTPOST,
                             t.CUSTPHONE,
                             t.CUSTEMAIL,
                             d.staffname UPDATESTAFFNO,
                             t.UPDATETIME
                        FROM TF_F_CARDPARKCUSTOMERREC_SZ t,
                             TF_F_CARDPARKPHOTO_SZ       s,
                             TD_M_INSIDESTAFF            d,
                             TD_M_INSIDEDEPART           e
                       WHERE t.STATE = '0'
                         AND t.CARDNO = s.Cardno(+)
                         AND t.CARDNO NOT IN
                             (SELECT DISTINCT s.CARDNO
                                FROM TF_F_CARDPARKPHOTOCHANGE_SZ s
                               WHERE s.state = '0')
                         AND t.updatestaffno = d.staffno
                         AND d.departno = e.departno
                         AND (p_var1 is null or p_var1 = '' or
                             t.updatetime >=
                             to_date(p_var1 || '000000', 'yyyymmddhh24miss'))
                         AND (p_var2 is null or p_var2 = '' or
                             t.updatetime <=
                             to_date(p_var2 || '235959', 'yyyymmddhh24miss'))
                         AND (p_var3 IS NULL OR p_var3 = '' OR
                             e.departno = p_var3)
                         AND (p_var4 IS NULL OR p_var4 = '' OR
                             t.updatestaffno = p_var4)
                         AND (p_var5 IS NULL OR p_var5 = '' OR
                             t.CARDNO = p_var5)
                         AND (p_var6 IS NULL OR p_var6 = '' OR
                             t.PAPERTYPECODE = p_var6)
                         AND (p_var7 IS NULL OR p_var7 = '' OR
                             t.PAPERNO = p_var7)
                      union all
                      ---）只修改照片
                      SELECT '2' CHANGECODE,
                             s.picture,
                             t.CARDNO,
                             t.CUSTNAME,
                             decode(t.CUSTSEX, '0', '男', '1', '女') CUSTSEX,
                             t.CUSTBIRTH,
                             decode(t.PAPERTYPECODE,
                                    '00',
                                    '身份证',
                                    '01',
                                    '军官证',
                                    '05',
                                    '护照',
                                    '06',
                                    '港澳台通行证',
                                    '07',
                                    '户口簿',
                                    '08',
                                    '武警证',
                                    '09',
                                    '台胞证',
                                    '99',
                                    '其他') PAPERTYPECODE,
                             t.PAPERNO,
                             t.CUSTADDR,
                             t.CUSTPOST,
                             t.CUSTPHONE,
                             t.CUSTEMAIL,
                             d.staffname UPDATESTAFFNO,
                             t.UPDATETIME
                        FROM TF_F_CUSTOMERREC            t,
                             TF_F_CARDPARKPHOTOCHANGE_SZ s,
                             TD_M_INSIDESTAFF            d,
                             TD_M_INSIDEDEPART           e
                       WHERE s.STATE = '0'
                         AND t.CARDNO = s.Cardno
                         AND t.CARDNO NOT IN
                             (SELECT DISTINCT t.CARDNO
                                FROM TF_F_CARDPARKCUSTOMERREC_SZ t
                               WHERE t.state = '0')
                         AND t.updatestaffno = d.staffno
                         AND d.departno = e.departno
                         AND (p_var1 is null or p_var1 = '' or
                             t.updatetime >=
                             to_date(p_var1 || '000000', 'yyyymmddhh24miss'))
                         AND (p_var2 is null or p_var2 = '' or
                             t.updatetime <=
                             to_date(p_var2 || '235959', 'yyyymmddhh24miss'))
                         AND (p_var3 IS NULL OR p_var3 = '' OR
                             e.departno = p_var3)
                         AND (p_var4 IS NULL OR p_var4 = '' OR
                             t.updatestaffno = p_var4)
                         AND (p_var5 IS NULL OR p_var5 = '' OR
                             t.CARDNO = p_var5)
                         AND (p_var6 IS NULL OR p_var6 = '' OR
                             t.PAPERTYPECODE = p_var6)
                         AND (p_var7 IS NULL OR p_var7 = '' OR
                             t.PAPERNO = p_var7)) f
               WHERE t.CARDNO = s.Cardno(+)
                 AND t.CARDNO = f.CARDNO
                 AND t.updatestaffno = d.staffno(+)
                 AND d.departno = e.departno(+)
                 AND (p_var5 IS NULL OR p_var5 = '' OR t.CARDNO = p_var5)) t
       order by t.cardno, t.CHANGECODE desc;
  elsif p_funcCode = 'QueryRelaxCardOldUserInfo' then
    --查询休闲资料原始信息
    open p_cursor for
      SELECT s.picture,
             t.CARDNO,
             t.CUSTNAME,
             decode(t.CUSTSEX, '0', '男', '1', '女') CUSTSEX,
             t.CUSTBIRTH,
             decode(t.PAPERTYPECODE,
                    '00',
                    '身份证',
                    '01',
                    '军官证',
                    '05',
                    '护照',
                    '06',
                    '港澳台通行证',
                    '07',
                    '户口簿',
                    '08',
                    '武警证',
                    '09',
                    '台胞证',
                    '99',
                    '其他') PAPERTYPECODE,
             t.PAPERNO,
             t.CUSTADDR,
             t.CUSTPOST,
             t.CUSTPHONE,
             t.CUSTEMAIL,
             d.staffname UPDATESTAFFNO,
             t.UPDATETIME
        FROM TF_F_CUSTOMERREC      t,
             TF_F_CARDPARKPHOTO_SZ s,
             TD_M_INSIDESTAFF      d
       WHERE t.CARDNO = s.Cardno
         AND t.updatestaffno = d.staffno
         AND (p_var1 IS NULL OR p_var1 = '' OR t.CARDNO = p_var1);
  elsif p_funcCode = 'QueryRelaxCardChangeOldInfo' then
    --查询修改资料是否在审核中
    open p_cursor for
      SELECT d.staffname, t.updatetime
        FROM TF_F_CARDPARKCUSTOMERREC_SZ t, TD_M_INSIDESTAFF d
       WHERE t.updatestaffno = d.staffno
         AND t.state = '0'
         AND (p_var1 IS NULL OR p_var1 = '' OR t.CARDNO = p_var1);
  elsif p_funcCode = 'QueryRelaxCardChangeOldImage' then
    --查询修改照片是否在审核中
    open p_cursor for
      SELECT d.staffname, t.operatetime
        FROM TF_F_CARDPARKPHOTOCHANGE_SZ t, TD_M_INSIDESTAFF d
       WHERE t.operatestaffno = d.staffno
         AND t.state = '0'
         AND (p_var1 IS NULL OR p_var1 = '' OR t.CARDNO = p_var1);
  elsif p_funcCode = 'QueryXFCardMoney' then
    --查询充值卡信息
    open p_cursor for
    /*
                            SELECT P_VAR1 FROM DUAL;
                            */
      SELECT F.XFCARDNO, T.MONEY, F.CARDSTATECODE, F.ENDDATE
        FROM TP_XFC_CARDVALUE T, TD_XFC_INITCARD F
       WHERE T.VALUECODE = F.VALUECODE
         AND F.NEW_PASSWD = P_VAR1
         AND F.CARDTYPE = '01';
  elsif p_funcCode = 'QUERYLIBRARYSYNCFAIL' then
    --查询图书馆同步失败数据
    open p_cursor for
      SELECT L.TRADEID,
             decode(L.SYNCTYPECODE,
                    '0001',
                    '0001:A卡开通',
                    '0002',
                    '0002:A卡挂失',
                    '0003',
                    '0003:市民卡补换卡',
                    '0004',
                    '0004:卡注销校验',
                    '0005',
                    '0005:欠费查询',
                    '1001',
                    '1001:开通校验',
                    '1002',
                    '1002:开通关闭') SYNCTYPECODE,
             decode(L.SYNCCODE,
                    '0',
                    '0:未同步',
                    '1',
                    '1:同步成功',
                    '2',
                    '2:同步失败') SYNCCODE,
             decode(L.SYNCTYPECODE,
                    '0002',
                    decode(L.TRADETYPECODE, '01', '01:挂失', '02', '02:解挂'),
                    '1002',
                    decode(L.TRADETYPECODE,
                           '01',
                           '01:开通',
                           '02',
                           '02:普通关闭',
                           '03',
                           '03:挂失关闭')) TRADETYPECODE,
             decode(L.PROCEDURESYNCCODE,
                    '0',
                    '0:未处理',
                    '1',
                    '1:处理成功',
                    '2',
                    '2:处理失败') PROCEDURESYNCCODE,
             decode(L.SYNCHOME, '01', '01:市民卡公司', 'L1', 'L1:图书馆') SYNCHOME,
             decode(L.SYNCCLIENT, '01', '01:市民卡公司', 'L1', 'L1:图书馆') SYNCCLIENT,
             L.CARDNO,
             L.SOCLSECNO,
             L.NAME,
             decode(L.PAPERTYPECODE,
                    '01',
                    '01:身份证',
                    '02',
                    '02:护照',
                    '03',
                    '03:港澳通行证',
                    '99',
                    '99:其他') PAPERTYPECODE,
             L.PAPERNO,
             L.BIRTH,
             decode(L.SEX, '0', '男', '1', '女') SEX,
             L.PHONE,
             L.CUSTPOST,
             L.ADDR,
             L.EMAIL,
             LASTSYNCTIME,
             L.SYNERRINFO
        FROM TF_B_LIB_SYNC L
       WHERE L.Synccode = '2'
       Order by UPDATETIME Desc, LASTSYNCTIME DESC;
  elsif p_funcCode = 'QUERYGARDENXXSYNCFAIL' then
    --查询休闲同步失败数据
    open p_cursor for
      SELECT t.tradeid,
             t.CARDNO,
             t.custname,
             decode(t.dealtype,
                    '0',
                    '0:未处理',
                    '1',
                    '1:处理成功',
                    '2',
                    '2:处理失败',
                    '3',
                    '3:临时状态') DEALTYPE,
             decode(t.PAPERTYPE,
                    '00',
                    '身份证',
                    '01',
                    '军官证',
                    '05',
                    '护照',
                    '06',
                    '港澳台通行证',
                    '07',
                    '户口簿',
                    '08',
                    '武警证',
                    '09',
                    '台胞证',
                    '99',
                    '其他') PAPERTYPE,
             t.PAPERNO,
             t.cardtime,
             t.enddate,
             t.times,
             decode(t.tradetype,
                    '1',
                    '1:开通',
                    '2',
                    '2:补换卡',
                    '3',
                    '3:取消开通') tradetype
        FROM TF_B_GARDENXXCARD t
       WHERE t.dealtype = '2'
       Order by t.cardtime DESC;
  elsif p_funcCode = 'QUERYGARDENSYNCFAIL' then
    --查询园林同步失败数据
    open p_cursor for
      SELECT t.tradeid,
             t.CARDNO,
             t.custname,
             decode(t.dealtype,
                    '0',
                    '0:未处理',
                    '1',
                    '1:处理成功',
                    '2',
                    '2:处理失败',
                    '3',
                    '3:临时状态') DEALTYPE,
             decode(t.PAPERTYPE,
                    '00',
                    '身份证',
                    '01',
                    '军官证',
                    '05',
                    '护照',
                    '06',
                    '港澳台通行证',
                    '07',
                    '户口簿',
                    '08',
                    '武警证',
                    '09',
                    '台胞证',
                    '99',
                    '其他') PAPERTYPE,
             t.PAPERNO,
             t.cardtime,
             t.enddate,
             t.times,
             decode(t.tradetype,
                    '1',
                    '1:开通',
                    '2',
                    '2:补换卡',
                    '3',
                    '3:取消开通') tradetype
        FROM TF_B_GARDENCARD t
       WHERE t.dealtype = '2'
       Order by t.cardtime DESC;
  end if;
end;
/
show errors
