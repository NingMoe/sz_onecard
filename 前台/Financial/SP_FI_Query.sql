create or replace procedure SP_FI_Query(p_funcCode varchar2,
                                        p_var1     varchar2,
                                        p_var2     varchar2,
                                        p_var3     varchar2,
                                        p_var4     varchar2,
                                        p_var5     varchar2,
                                        p_var6     varchar2,
                                        p_var7     varchar2,
                                        p_var8     in out varchar2,
                                        p_var9     in out varchar2,
                                        p_var10    varchar2,
                                        p_var11    varchar2,
                                        p_cursor   out SYS_REFCURSOR) as

begin

  if p_funcCode = 'TD_EOC_DAILY_REPORT' then
    -- 商户转账日报查询
    if p_var3 = '1' then
      --不转帐
      open p_cursor for
        SELECT 开户行,
               商户代码,
               商户名称,
               银行账号,
               SUM(转帐金额) 转帐金额,
               应收佣金,
               remark,
               purposetype,
               BankChannelCode,
               SUM(退货金额) 退货金额,
               SUM(结算金额) 结算金额
          FROM (select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       a.COMFEE / 100.0 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) - NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 退货金额,
                       (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                       NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) + NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '1'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and a.TRANSFEE > 0
                union all
                select c.BANK 开户行,
                       f.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       0 转帐金额,
                       0 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                       0 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c,
                       TF_B_SPEADJUSTACC   f
                 where (p_var1 is null or p_var1 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                       to_char(a.begintime(+), 'yyyymmdd')
                   AND f.balunitno = a.balunitno(+)
                   AND a.balunitno is null
                   and F.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '1'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE)
         GROUP BY 开户行,
                  商户代码,
                  商户名称,
                  银行账号,
                  remark,
                  purposetype,
                  BankChannelCode,
                  应收佣金
         order by 1, 3, 5;
    elsif p_var3 = '2' then
      --光大，信息亭
      open p_cursor for
        SELECT 开户行,
               商户代码,
               商户名称,
               银行账号,
               SUM(转帐金额) 转帐金额,
               应收佣金,
               remark,
               purposetype,
               BankChannelCode,
               SUM(退货金额) 退货金额,
               SUM(结算金额) 结算金额
          FROM (select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       a.COMFEE / 100.0 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) - NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 退货金额,
                       (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                       NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) + NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) = '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and b.FINBANKCODE != '000Z'
                   and a.TRANSFEE > 0
                union all
                select c.BANK 开户行,
                       f.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       0 转帐金额,
                       0 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                       0 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c,
                       TF_B_SPEADJUSTACC   f
                 where (p_var1 is null or p_var1 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                       to_char(a.begintime(+), 'yyyymmdd')
                   AND f.balunitno = a.balunitno(+)
                   AND a.balunitno is null
                   and F.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) = '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and b.FINBANKCODE != '000Z')
         GROUP BY 开户行,
                  商户代码,
                  商户名称,
                  银行账号,
                  remark,
                  purposetype,
                  BankChannelCode,
                  应收佣金
         order by 1, 3, 5;
    elsif p_var3 = '3' then
      --农商行
      open p_cursor for
        SELECT 开户行,
               商户代码,
               商户名称,
               银行账号,
               SUM(转帐金额) 转帐金额,
               应收佣金,
               remark,
               purposetype,
               BankChannelCode,
               SUM(退货金额) 退货金额,
               SUM(结算金额) 结算金额
          FROM (select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       a.COMFEE / 100.0 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) - NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 退货金额,
                       (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                       NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) + NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) <> '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and a.FINBANKCODE IN ('000L', 'L002')
                   and a.TRANSFEE > 0
                union all
                select c.BANK 开户行,
                       f.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       0 转帐金额,
                       0 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                       0 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c,
                       TF_B_SPEADJUSTACC   f
                 where (p_var1 is null or p_var1 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                       to_char(a.begintime(+), 'yyyymmdd')
                   AND f.balunitno = a.balunitno(+)
                   AND a.balunitno is null
                   and F.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) <> '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and a.FINBANKCODE IN ('000L', 'L002'))
         GROUP BY 开户行,
                  商户代码,
                  商户名称,
                  银行账号,
                  remark,
                  purposetype,
                  BankChannelCode
         order by 1, 3, 5;
    elsif p_var3 = '0' then
      --农行
      open p_cursor for
        SELECT 开户行,
               商户代码,
               商户名称,
               银行账号,
               SUM(转帐金额) 转帐金额,
               应收佣金,
               remark,
               purposetype,
               BankChannelCode,
               SUM(退货金额) 退货金额,
               SUM(结算金额) 结算金额
          FROM (select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) - NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 退货金额,
                       (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                       NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) + NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) <> '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and b.BANKCODE like '%A%'
                   and b.FINBANKCODE not in ('000L', '000Z')
                   and a.TRANSFEE > 0
                union all
                select c.BANK 开户行,
                       f.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       0 转帐金额,
                       '0' 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                       0 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c,
                       TF_B_SPEADJUSTACC   f
                 where (p_var1 is null or p_var1 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                       to_char(a.begintime(+), 'yyyymmdd')
                   AND f.balunitno = a.balunitno(+)
                   AND a.balunitno is null
                   and F.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) <> '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and b.BANKCODE like '%A%'
                   and b.FINBANKCODE not in ('000L', '000Z')
                union all
                select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.RENEWFINFEE / 100.0 转帐金额,
                       '重新清算' 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) - NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 退货金额,
                       (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                       NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) + NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.balunitno in ('0BX00011',
                                       '0BX00021',
                                       '0BX00022',
                                       '0BX00012',
                                       '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and a.RENEWFINFEE > 0
                union all
                select c.BANK 开户行,
                       f.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       0 转帐金额,
                       '0' 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                       0 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c,
                       TF_B_SPEADJUSTACC   f
                 where (p_var1 is null or p_var1 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                       to_char(a.begintime(+), 'yyyymmdd')
                   AND f.balunitno = a.balunitno(+)
                   AND a.balunitno is null
                   and F.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.balunitno in ('0BX00011',
                                       '0BX00021',
                                       '0BX00022',
                                       '0BX00012',
                                       '03000001')
                   and b.BANKCODE = c.BANKCODE
                union all
                select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       posno || '油品' || to_char(dealtime, 'yyyymmdd') 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL(NVL(0, 0) / 100.0, 0) 退货金额,
                       a.TRANSFEE / 100.0 结算金额
                  from TF_OUTCOMEFIN_SINOPEC a,
                       TF_TRADE_BALUNIT      b,
                       TD_M_BANK             c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.DEALTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.DEALTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.balunitno in ('0BX00011', '0BX00012', '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and a.TRANSFEE > 0
                union all
                select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       posno || '非油品' || to_char(dealtime, 'yyyymmdd') 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL(NVL(0, 0) / 100.0, 0) 退货金额,
                       a.TRANSFEE / 100.0 结算金额
                  from TF_OUTCOMEFIN_SINOPEC a,
                       TF_TRADE_BALUNIT      b,
                       TD_M_BANK             c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.DEALTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.DEALTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.balunitno in ('0BX00021', '0BX00022', '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and a.TRANSFEE > 0)
         GROUP BY 开户行,
                  商户代码,
                  商户名称,
                  银行账号,
                  remark,
                  purposetype,
                  BankChannelCode,
                  应收佣金
         order by 1, 3, 5;
    elsif p_var3 = '4' then
      --交行
      open p_cursor for
        SELECT 开户行,
               商户代码,
               商户名称,
               银行账号,
               SUM(转帐金额) 转帐金额,
               应收佣金,
               remark,
               purposetype,
               BankChannelCode,
               SUM(退货金额) 退货金额,
               SUM(结算金额) 结算金额
          FROM (select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) - NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 退货金额,
                       (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                       NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) + NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) <> '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and b.BANKCODE NOT like '%A%'
                   and b.FINBANKCODE not in ('000L', 'L002', '000Z')
                   and a.TRANSFEE > 0
                union all
                select c.BANK 开户行,
                       f.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       0 转帐金额,
                       '0' 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                       0 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c,
                       TF_B_SPEADJUSTACC   f
                 where (p_var1 is null or p_var1 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                       to_char(a.begintime(+), 'yyyymmdd')
                   AND f.balunitno = a.balunitno(+)
                   AND a.balunitno is null
                   and F.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) <> '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and b.BANKCODE NOT like '%A%'
                   and b.FINBANKCODE not in ('000L', 'L002', '000Z')
                union all -- add by liuhe20120427交行转账中添加轻轨转账账单
                select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) - NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 退货金额,
                       (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                       NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) + NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 结算金额
                  from TF_RAIL_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.BANKCODE = c.BANKCODE
                   and a.TRANSFEE > 0
                union all
                select c.BANK 开户行,
                       f.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       0 转帐金额,
                       '0' 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                       0 结算金额
                  from TF_RAIL_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT   b,
                       TD_M_BANK          c,
                       TF_B_SPEADJUSTACC  f
                 where (p_var1 is null or p_var1 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                       to_char(a.begintime(+), 'yyyymmdd')
                   AND f.balunitno = a.balunitno(+)
                   AND a.balunitno is null
                   and f.balunitno = '03000001'
                   and F.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.BANKCODE = c.BANKCODE)
         GROUP BY 开户行,
                  商户代码,
                  商户名称,
                  银行账号,
                  remark,
                  purposetype,
                  BankChannelCode,
                  应收佣金
         order by 1, 3, 5;
    elsif p_var3 = '5' then
      --张家港
      open p_cursor for
        SELECT 开户行,
               商户代码,
               商户名称,
               银行账号,
               SUM(转帐金额) 转帐金额,
               应收佣金,
               remark,
               purposetype,
               BankChannelCode,
               SUM(退货金额) 退货金额,
               SUM(结算金额) 结算金额
          FROM (select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) - NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 退货金额,
                       (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                       NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) + NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.BANKCODE = c.BANKCODE
                   and a.BALUNITNO <> '03000001'
                   and a.FINBANKCODE = '000Z'
                   and a.TRANSFEE > 0
                union all
                select c.BANK 开户行,
                       f.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       0 转帐金额,
                       '0' 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                       0 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c,
                       TF_B_SPEADJUSTACC   f
                 where (p_var1 is null or p_var1 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                       to_char(a.begintime(+), 'yyyymmdd')
                   AND f.balunitno = a.balunitno(+)
                   AND a.balunitno is null
                   and F.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.BANKCODE = c.BANKCODE
                   and a.BALUNITNO <> '03000001'
                   and a.FINBANKCODE = '000Z')
         GROUP BY 开户行,
                  商户代码,
                  商户名称,
                  银行账号,
                  remark,
                  purposetype,
                  BankChannelCode,
                  应收佣金
         order by 1, 3, 5;
    elsif p_var3 is null then
      --所有的需转账数据
    
      open p_cursor for
      --光大，信息亭
        SELECT 开户行,
               商户代码,
               商户名称,
               银行账号,
               SUM(转帐金额) 转帐金额,
               应收佣金,
               remark,
               purposetype,
               BankChannelCode,
               SUM(退货金额) 退货金额,
               SUM(结算金额) 结算金额
          FROM (select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) - NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 退货金额,
                       (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                       NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) + NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) = '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and b.FINBANKCODE != '000Z'
                   and a.TRANSFEE > 0
                union all
                select c.BANK 开户行,
                       f.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       0 转帐金额,
                       '0' 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                       0 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c,
                       TF_B_SPEADJUSTACC   f
                 where (p_var1 is null or p_var1 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                       to_char(a.begintime(+), 'yyyymmdd')
                   AND f.balunitno = a.balunitno(+)
                   AND a.balunitno is null
                   and F.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) = '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and b.FINBANKCODE != '000Z'
                union all
                --农商行
                select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) - NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 退货金额,
                       (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                       NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) + NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) <> '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and a.FINBANKCODE IN ('000L', 'L002')
                   and a.TRANSFEE > 0
                union all
                select c.BANK 开户行,
                       f.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       0 转帐金额,
                       '0' 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                       0 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c,
                       TF_B_SPEADJUSTACC   f
                 where (p_var1 is null or p_var1 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                       to_char(a.begintime(+), 'yyyymmdd')
                   AND f.balunitno = a.balunitno(+)
                   AND a.balunitno is null
                   and F.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) <> '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and a.FINBANKCODE IN ('000L', 'L002')
                union all
                --农行
                select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) - NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 退货金额,
                       (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                       NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) + NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) <> '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and b.BANKCODE like '%A%'
                   and b.FINBANKCODE not in ('000L', '000Z')
                   and a.TRANSFEE > 0
                union all
                select c.BANK 开户行,
                       f.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       0 转帐金额,
                       '0' 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                       0 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c,
                       TF_B_SPEADJUSTACC   f
                 where (p_var1 is null or p_var1 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                       to_char(a.begintime(+), 'yyyymmdd')
                   AND f.balunitno = a.balunitno(+)
                   AND a.balunitno is null
                   and F.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) <> '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and b.BANKCODE like '%A%'
                   and b.FINBANKCODE not in ('000L', '000Z')
                union all
                select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.RENEWFINFEE / 100.0 转帐金额,
                       '重新清算' 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) - NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 退货金额,
                       (NVL(NVL(a.RENEWFINFEE, 0) / 100.0, 0) -
                       NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) + NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.balunitno in ('0BX00011',
                                       '0BX00021',
                                       '0BX00022',
                                       '0BX00012',
                                       '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and a.RENEWFINFEE > 0
                union all
                select c.BANK 开户行,
                       f.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       0 转帐金额,
                       '0 ' 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                       0 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c,
                       TF_B_SPEADJUSTACC   f
                 where (p_var1 is null or p_var1 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                       to_char(a.begintime(+), 'yyyymmdd')
                   AND f.balunitno = a.balunitno(+)
                   AND a.balunitno is null
                   and F.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.balunitno in ('0BX00011',
                                       '0BX00021',
                                       '0BX00022',
                                       '0BX00012',
                                       '03000001')
                   and b.BANKCODE = c.BANKCODE
                union all
                select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       posno || '油品' || to_char(dealtime, 'yyyymmdd') 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL(NVL(0, 0) / 100.0, 0) 退货金额,
                       a.TRANSFEE / 100.0 结算金额
                  from TF_OUTCOMEFIN_SINOPEC a,
                       TF_TRADE_BALUNIT      b,
                       TD_M_BANK             c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.DEALTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.DEALTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.balunitno in ('0BX00011', '0BX00012', '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and a.TRANSFEE > 0
                union all
                select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       posno || '非油品' || to_char(dealtime, 'yyyymmdd') 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL(NVL(0, 0) / 100.0, 0) 退货金额,
                       a.TRANSFEE / 100.0 结算金额
                  from TF_OUTCOMEFIN_SINOPEC a,
                       TF_TRADE_BALUNIT      b,
                       TD_M_BANK             c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.DEALTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.DEALTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.balunitno in ('0BX00021', '0BX00022', '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and a.TRANSFEE > 0
                union all
                --交行
                select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) - NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 退货金额,
                       (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                       NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) + NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) <> '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and b.BANKCODE NOT like '%A%'
                   and b.FINBANKCODE not in ('000L', 'L002', '000Z')
                   and a.TRANSFEE > 0
                union all
                select c.BANK 开户行,
                       f.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       0 转帐金额,
                       '0' 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                       0 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c,
                       TF_B_SPEADJUSTACC   f
                 where (p_var1 is null or p_var1 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                       to_char(a.begintime(+), 'yyyymmdd')
                   AND f.balunitno = a.balunitno(+)
                   AND a.balunitno is null
                   and F.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and substr(b.balunitno, 1, 2) <> '0C'
                   and b.balunitno not in ('0BX00011',
                                           '0BX00021',
                                           '0BX00022',
                                           '0BX00012',
                                           '03000001')
                   and b.BANKCODE = c.BANKCODE
                   and b.BANKCODE NOT like '%A%'
                   and b.FINBANKCODE not in ('000L', 'L002', '000Z')
                union all -- add by liuhe20120427交行转账中添加轻轨转账账单
                select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) - NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 退货金额,
                       (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                       NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) + NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 结算金额
                  from TF_RAIL_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.BANKCODE = c.BANKCODE
                   and a.TRANSFEE > 0
                union all
                select c.BANK 开户行,
                       f.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       0 转帐金额,
                       '0' 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                       0 结算金额
                  from TF_RAIL_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT   b,
                       TD_M_BANK          c,
                       TF_B_SPEADJUSTACC  f
                 where (p_var1 is null or p_var1 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                       to_char(a.begintime(+), 'yyyymmdd')
                   AND f.balunitno = a.balunitno(+)
                   AND a.balunitno is null
                   AND F.balunitno = '03000001'
                   and F.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.BANKCODE = c.BANKCODE
                union all
                --张家港
                select c.BANK 开户行,
                       a.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       a.TRANSFEE / 100.0 转帐金额,
                       to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) - NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 退货金额,
                       (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                       NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                  from TF_B_SPEADJUSTACC d
                                 where d.BALUNITNO = a.BALUNITNO
                                   And d.STATECODE IN ('1', '2')
                                   And d.CHECKTIME IS NOT NULL
                                   And d.CHECKTIME >=
                                       TO_DATE(TO_CHAR(a.BEGINTIME,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd')
                                   And d.CHECKTIME <
                                       TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                       'yyyy/MM/dd'),
                                               'yyyy-MM-dd') + 1),
                                0) / 100.0,
                            0) + NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                            from TF_B_SPEADJUSTACC d
                                           where d.BALUNITNO = a.BALUNITNO
                                             And d.STATECODE IN ('1', '2')
                                             And D.CHECKTIME IS NOT NULL
                                             And d.CHECKTIME >=
                                                 TO_DATE(TO_CHAR(a.BEGINTIME,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd')
                                             And d.CHECKTIME <
                                                 TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                                 'yyyy/MM/dd'),
                                                         'yyyy-MM-dd') + 1),
                                          0) / 100.0,
                                      0)) 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.BANKCODE = c.BANKCODE
                   and a.BALUNITNO <> '03000001'
                   and a.FINBANKCODE = '000Z'
                   and a.TRANSFEE > 0
                union all
                select c.BANK 开户行,
                       f.BALUNITNO 商户代码,
                       b.BALUNIT 商户名称,
                       b.bankaccno 银行账号,
                       0 转帐金额,
                       '0' 应收佣金,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                       0 结算金额
                  from TF_TRADE_OUTCOMEFIN a,
                       TF_TRADE_BALUNIT    b,
                       TD_M_BANK           c,
                       TF_B_SPEADJUSTACC   f
                 where (p_var1 is null or p_var1 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(F.CHECKTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
                   and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                       to_char(a.begintime(+), 'yyyymmdd')
                   AND f.balunitno = a.balunitno(+)
                   AND a.balunitno is null
                   and F.BALUNITNO = b.BALUNITNO
                   and b.FINTYPECODE = '0'
                   and b.BANKCODE = c.BANKCODE
                   and a.BALUNITNO <> '03000001'
                   and a.FINBANKCODE = '000Z')
         GROUP BY 开户行,
                  商户代码,
                  商户名称,
                  银行账号,
                  remark,
                  purposetype,
                  BankChannelCode,
                  应收佣金
         order by 1, 3, 5;
    end if;
  
    select 'SHRB' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    if p_var3 = '1' then
      insert into TF_TRADEOC_SERIALNO_DETAIL
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               NULL
          from TF_TRADE_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '1'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and a.FINBANKCODE = c.BANKCODE
           and a.TRANSFEE > 0
         order by a.FINBANKCODE;
    elsif p_var3 = '2' then
      insert into TF_TRADEOC_SERIALNO_DETAIL
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               NULL
          from TF_TRADE_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) = '0C'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and a.FINBANKCODE = c.BANKCODE
           and a.TRANSFEE > 0
         order by a.FINBANKCODE;
    elsif p_var3 = '3' then
      insert into TF_TRADEOC_SERIALNO_DETAIL
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               NULL
          from TF_TRADE_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) <> '0C'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and a.FINBANKCODE = c.BANKCODE
           and a.FINBANKCODE IN ('000L', 'L002')
           and a.TRANSFEE > 0
         order by a.FINBANKCODE;
    elsif p_var3 = '0' then
      insert into TF_TRADEOC_SERIALNO_DETAIL
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               null
          from TF_TRADE_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) <> '0C'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and b.BANKCODE = c.BANKCODE
           AND B.BANKCODE LIKE '%A%'
           and a.FINBANKCODE <> '000L'
           and a.TRANSFEE > 0
        union all
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.RENEWFINFEE,
               null
          from TF_TRADE_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and b.balunitno in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and b.BANKCODE = c.BANKCODE
           and a.RENEWFINFEE > 0
        union all
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               null
          from TF_OUTCOMEFIN_SINOPEC a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.DEALTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.DEALTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and b.balunitno in ('0BX00011', '0BX00012')
           and b.BANKCODE = c.BANKCODE
           and a.TRANSFEE > 0
        union all
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               null
          from TF_OUTCOMEFIN_SINOPEC a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.DEALTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.DEALTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and b.balunitno in ('0BX00021', '0BX00022')
           and b.BANKCODE = c.BANKCODE
           and a.TRANSFEE > 0;
    elsif p_var3 = '4' then
      insert into TF_TRADEOC_SERIALNO_DETAIL
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               null
          from TF_TRADE_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) <> '0C'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and b.BANKCODE = c.BANKCODE
           and b.BANKCODE NOT like '%A%'
           and b.FINBANKCODE <> '000L'
           and a.TRANSFEE > 0;
    elsif p_var3 = '5' then
      insert into TF_TRADEOC_SERIALNO_DETAIL
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               null
          from TF_TRADE_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and b.BANKCODE = c.BANKCODE
           and a.BALUNITNO <> '03000001'
           and a.FINBANKCODE = '000Z'
           and a.TRANSFEE > 0;
    elsif p_var3 is null then
      insert into TF_TRADEOC_SERIALNO_DETAIL
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               NULL
          from TF_TRADE_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) = '0C'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and a.FINBANKCODE = c.BANKCODE
           and a.TRANSFEE > 0
        union all
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               NULL
          from TF_TRADE_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) <> '0C'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and a.FINBANKCODE = c.BANKCODE
           and a.FINBANKCODE = '000L'
           and a.TRANSFEE > 0
        union all
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               null
          from TF_TRADE_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) <> '0C'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and b.BANKCODE = c.BANKCODE
           AND B.BANKCODE LIKE '%A%'
           and a.FINBANKCODE <> '000L'
           and a.TRANSFEE > 0
        union all
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.RENEWFINFEE,
               null
          from TF_TRADE_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and b.balunitno in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and b.BANKCODE = c.BANKCODE
           and a.RENEWFINFEE > 0
        union all
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               null
          from TF_OUTCOMEFIN_SINOPEC a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.DEALTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.DEALTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and b.balunitno in ('0BX00011', '0BX00012')
           and b.BANKCODE = c.BANKCODE
           and a.TRANSFEE > 0
        union all
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               null
          from TF_OUTCOMEFIN_SINOPEC a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.DEALTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.DEALTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and b.balunitno in ('0BX00021', '0BX00022')
           and b.BANKCODE = c.BANKCODE
           and a.TRANSFEE > 0
        union all
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               null
          from TF_TRADE_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) <> '0C'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and b.BANKCODE = c.BANKCODE
           and b.BANKCODE NOT like '%A%'
           and b.FINBANKCODE <> '000L'
           and a.TRANSFEE > 0
        union all
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               null
          from TF_TRADE_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and b.BANKCODE = c.BANKCODE
           and a.BALUNITNO <> '03000001'
           and a.FINBANKCODE = '000Z'
           and a.TRANSFEE > 0;
    
    end if;
    commit;
  elsif p_funcCode = 'TD_EOC_DAILY_REPORTFiApprovalBank' then
    -- 商户转账日报查询导出转帐表格
    if p_var3 = '1' then
      --不转帐
      open p_cursor for
        select ROWNUM, T.*
          from (select 银行账号 收款帐号,
                       商户名称 收款人户名,
                       开户行 收款人开户行名称,
                       BANKNUMBER 收款人行号,
                       purposetype 收款人账户类型,
                       SUM(转帐金额) - SUM(退货金额) 金额,
                       收款人是否本行,
                       收款人是否同城,
                       remark || '佣金' ||
                       decode(ltrim(应收佣金), '.00', '0', ltrim(应收佣金)) 付款用途
                  from (select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               a.COMFEE / 100.0 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) -
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 退货金额,
                               (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                               NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) +
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '1'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and a.TRANSFEE > 0
                        union all
                        select c.BANK 开户行,
                               f.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               0 转帐金额,
                               0 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                               0 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c,
                               TF_B_SPEADJUSTACC   f
                         where (p_var1 is null or p_var1 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                               to_char(a.begintime(+), 'yyyymmdd')
                           AND f.balunitno = a.balunitno(+)
                           AND a.balunitno is null
                           and F.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '1'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE)
                 GROUP BY 银行账号,
                          商户代码,
                          商户名称,
                          开户行,
                          BANKNUMBER,
                          purposetype,
                          收款人是否本行,
                          收款人是否同城,
                          remark,
                          应收佣金
                 ORDER BY 开户行, 商户名称, SUM(转帐金额)) T;
    elsif p_var3 = '2' then
      --光大，信息亭
      open p_cursor for
        select ROWNUM, T.*
          from (select 银行账号 收款帐号,
                       商户名称 收款人户名,
                       开户行 收款人开户行名称,
                       BANKNUMBER 收款人行号,
                       purposetype 收款人账户类型,
                       SUM(转帐金额) - SUM(退货金额) 金额,
                       收款人是否本行,
                       收款人是否同城,
                       remark || '佣金' ||
                       decode(ltrim(应收佣金), '.00', '0', ltrim(应收佣金)) 付款用途
                  from (select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               a.COMFEE / 100.0 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) -
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 退货金额,
                               (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                               NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) +
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and substr(b.balunitno, 1, 2) = '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and b.FINBANKCODE != '000Z'
                           and a.TRANSFEE > 0
                        union all
                        select c.BANK 开户行,
                               f.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               0 转帐金额,
                               0 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                               0 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c,
                               TF_B_SPEADJUSTACC   f
                         where (p_var1 is null or p_var1 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                               to_char(a.begintime(+), 'yyyymmdd')
                           AND f.balunitno = a.balunitno(+)
                           AND a.balunitno is null
                           and F.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and substr(b.balunitno, 1, 2) = '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and b.FINBANKCODE != '000Z')
                 GROUP BY 银行账号,
                          商户代码,
                          商户名称,
                          开户行,
                          BANKNUMBER,
                          purposetype,
                          收款人是否本行,
                          收款人是否同城,
                          remark,
                          应收佣金
                 ORDER BY 开户行, 商户名称, SUM(转帐金额)) T;
    elsif p_var3 = '3' then
      --农商行
      open p_cursor for
        select ROWNUM, T.*
          from (select 银行账号 收款帐号,
                       商户名称 收款人户名,
                       开户行 收款人开户行名称,
                       BANKNUMBER 收款人行号,
                       purposetype 收款人账户类型,
                       SUM(转帐金额) - SUM(退货金额) 金额,
                       收款人是否本行,
                       收款人是否同城,
                       remark || '佣金' ||
                       decode(ltrim(应收佣金), '.00', '0', ltrim(应收佣金)) 付款用途
                  from (select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               a.COMFEE / 100.0 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) -
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 退货金额,
                               (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                               NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) +
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and substr(b.balunitno, 1, 2) <> '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and a.FINBANKCODE IN ('000L', 'L002')
                           and a.TRANSFEE > 0
                        union all
                        select c.BANK 开户行,
                               f.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               0 转帐金额,
                               0 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                               0 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c,
                               TF_B_SPEADJUSTACC   f
                         where (p_var1 is null or p_var1 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                               to_char(a.begintime(+), 'yyyymmdd')
                           AND f.balunitno = a.balunitno(+)
                           AND a.balunitno is null
                           and F.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and substr(b.balunitno, 1, 2) <> '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and a.FINBANKCODE IN ('000L', 'L002'))
                 GROUP BY 银行账号,
                          商户代码,
                          商户名称,
                          开户行,
                          BANKNUMBER,
                          purposetype,
                          收款人是否本行,
                          收款人是否同城,
                          remark,
                          应收佣金
                 ORDER BY 开户行, 商户名称, SUM(转帐金额)) T;
    elsif p_var3 = '0' then
      --农行
      open p_cursor for
        select ROWNUM, T.*
          from (select 银行账号 收款帐号,
                       商户名称 收款人户名,
                       开户行 收款人开户行名称,
                       BANKNUMBER 收款人行号,
                       purposetype 收款人账户类型,
                       SUM(转帐金额) - SUM(退货金额) 金额,
                       收款人是否本行,
                       收款人是否同城,
                       remark || '佣金' ||
                       decode(ltrim(应收佣金), '.00', '0', ltrim(应收佣金)) 付款用途
                  from (select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) -
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 退货金额,
                               (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                               NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) +
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and substr(b.balunitno, 1, 2) <> '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and b.BANKCODE like '%A%'
                           and b.FINBANKCODE not in ('000L', '000Z')
                           and a.TRANSFEE > 0
                        union all
                        select c.BANK 开户行,
                               f.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               0 转帐金额,
                               '0' 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                               0 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c,
                               TF_B_SPEADJUSTACC   f
                         where (p_var1 is null or p_var1 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                               to_char(a.begintime(+), 'yyyymmdd')
                           AND f.balunitno = a.balunitno(+)
                           AND a.balunitno is null
                           and F.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and substr(b.balunitno, 1, 2) <> '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and b.BANKCODE like '%A%'
                           and b.FINBANKCODE not in ('000L', '000Z')
                        union all
                        select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.RENEWFINFEE / 100.0 转帐金额,
                               '重新清算' 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) -
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 退货金额,
                               (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                               NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) +
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.balunitno in ('0BX00011',
                                               '0BX00021',
                                               '0BX00022',
                                               '0BX00012',
                                               '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and a.RENEWFINFEE > 0
                        union all
                        select c.BANK 开户行,
                               f.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               0 转帐金额,
                               '0' 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                               0 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c,
                               TF_B_SPEADJUSTACC   f
                         where (p_var1 is null or p_var1 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                               to_char(a.begintime(+), 'yyyymmdd')
                           AND f.balunitno = a.balunitno(+)
                           AND a.balunitno is null
                           and F.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.balunitno in ('0BX00011',
                                               '0BX00021',
                                               '0BX00022',
                                               '0BX00012',
                                               '03000001')
                           and b.BANKCODE = c.BANKCODE
                        union all
                        select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               posno || '油品' || to_char(dealtime, 'yyyymmdd') 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.DEALTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL(NVL(0, 0) / 100.0, 0) 退货金额,
                               a.TRANSFEE / 100.0 结算金额
                          from TF_OUTCOMEFIN_SINOPEC a,
                               TF_TRADE_BALUNIT      b,
                               TD_M_BANK             c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.DEALTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.DEALTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.balunitno in
                               ('0BX00011', '0BX00012', '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and a.TRANSFEE > 0
                        union all
                        select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               posno || '非油品' ||
                               to_char(dealtime, 'yyyymmdd') 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.DEALTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL(NVL(0, 0) / 100.0, 0) 退货金额,
                               a.TRANSFEE / 100.0 结算金额
                          from TF_OUTCOMEFIN_SINOPEC a,
                               TF_TRADE_BALUNIT      b,
                               TD_M_BANK             c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.DEALTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.DEALTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.balunitno in
                               ('0BX00021', '0BX00022', '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and a.TRANSFEE > 0)
                 GROUP BY 银行账号,
                          商户代码,
                          商户名称,
                          开户行,
                          BANKNUMBER,
                          purposetype,
                          收款人是否本行,
                          收款人是否同城,
                          remark,
                          应收佣金
                 ORDER BY 开户行, 商户名称, SUM(转帐金额)) T;
    elsif p_var3 = '4' then
      --交行
      open p_cursor for
        select ROWNUM, T.*
          from (select 银行账号 收款帐号,
                       商户名称 收款人户名,
                       开户行 收款人开户行名称,
                       BANKNUMBER 收款人行号,
                       purposetype 收款人账户类型,
                       SUM(转帐金额) - SUM(退货金额) 金额,
                       收款人是否本行,
                       收款人是否同城,
                       remark || '佣金' ||
                       decode(ltrim(应收佣金), '.00', '0', ltrim(应收佣金)) 付款用途
                  from (select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) -
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 退货金额,
                               (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                               NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) +
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and substr(b.balunitno, 1, 2) <> '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and b.BANKCODE NOT like '%A%'
                           and b.FINBANKCODE not in ('000L', 'L002', '000Z')
                           and a.TRANSFEE > 0
                        union all
                        select c.BANK 开户行,
                               f.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               0 转帐金额,
                               '0' 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                               0 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c,
                               TF_B_SPEADJUSTACC   f
                         where (p_var1 is null or p_var1 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                               to_char(a.begintime(+), 'yyyymmdd')
                           AND f.balunitno = a.balunitno(+)
                           AND a.balunitno is null
                           and b.FINTYPECODE = '0'
                           and F.BALUNITNO = b.BALUNITNO
                           and substr(b.balunitno, 1, 2) <> '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and b.BANKCODE NOT like '%A%'
                           and b.FINBANKCODE not in ('000L', 'L002', '000Z')
                        union all -- add by liuhe20120427交行转账中添加轻轨转账账单
                        select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) -
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 退货金额,
                               (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                               NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) +
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 结算金额
                          from TF_RAIL_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT   b,
                               TD_M_BANK          c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.BANKCODE = c.BANKCODE
                           and a.TRANSFEE > 0
                        union all
                        select c.BANK 开户行,
                               f.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               0 转帐金额,
                               '0' 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                               0 结算金额
                          from TF_RAIL_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT   b,
                               TD_M_BANK          c,
                               TF_B_SPEADJUSTACC  f
                         where (p_var1 is null or p_var1 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                               to_char(a.begintime(+), 'yyyymmdd')
                           AND f.balunitno = a.balunitno(+)
                           AND a.balunitno is null
                           and f.balunitno = '03000001'
                           and F.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.BANKCODE = c.BANKCODE)
                 GROUP BY 银行账号,
                          商户代码,
                          商户名称,
                          开户行,
                          BANKNUMBER,
                          purposetype,
                          收款人是否本行,
                          收款人是否同城,
                          remark,
                          应收佣金
                 ORDER BY 开户行, 商户名称, SUM(转帐金额)) T;
    elsif p_var3 = '5' then
      --张家港
      open p_cursor for
        select ROWNUM, T.*
          from (select 银行账号 收款帐号,
                       商户名称 收款人户名,
                       开户行 收款人开户行名称,
                       BANKNUMBER 收款人行号,
                       purposetype 收款人账户类型,
                       SUM(转帐金额) - SUM(退货金额) 金额,
                       收款人是否本行,
                       收款人是否同城,
                       remark || '佣金' ||
                       decode(ltrim(应收佣金), '.00', '0', ltrim(应收佣金)) 付款用途
                  from (select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) -
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 退货金额,
                               (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                               NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) +
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.BANKCODE = c.BANKCODE
                           and a.BALUNITNO <> '03000001'
                           and a.FINBANKCODE = '000Z'
                           and a.TRANSFEE > 0
                        union all
                        select c.BANK 开户行,
                               f.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               0 转帐金额,
                               '0' 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                               0 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c,
                               TF_B_SPEADJUSTACC   f
                         where (p_var1 is null or p_var1 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                               to_char(a.begintime(+), 'yyyymmdd')
                           AND f.balunitno = a.balunitno(+)
                           AND a.balunitno is null
                           and F.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.BANKCODE = c.BANKCODE
                           and a.BALUNITNO <> '03000001'
                           and a.FINBANKCODE = '000Z')
                 GROUP BY 银行账号,
                          商户代码,
                          商户名称,
                          开户行,
                          BANKNUMBER,
                          purposetype,
                          收款人是否本行,
                          收款人是否同城,
                          remark,
                          应收佣金
                 ORDER BY 开户行, 商户名称, SUM(转帐金额)) T;
    elsif p_var3 is null then
      --所有的需转账数据
    
      open p_cursor for
      --光大，信息亭
        select ROWNUM, T.*
          from (select 银行账号 收款帐号,
                       商户名称 收款人户名,
                       开户行 收款人开户行名称,
                       BANKNUMBER 收款人行号,
                       purposetype 收款人账户类型,
                       SUM(转帐金额) - SUM(退货金额) 金额,
                       收款人是否本行,
                       收款人是否同城,
                       remark || '佣金' ||
                       decode(ltrim(应收佣金), '.00', '0', ltrim(应收佣金)) 付款用途
                  from (select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) -
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 退货金额,
                               (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                               NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) +
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and substr(b.balunitno, 1, 2) = '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and b.FINBANKCODE != '000Z'
                           and a.TRANSFEE > 0
                        union all
                        select c.BANK 开户行,
                               f.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               0 转帐金额,
                               '0' 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                               0 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c,
                               TF_B_SPEADJUSTACC   f
                         where (p_var1 is null or p_var1 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                               to_char(a.begintime(+), 'yyyymmdd')
                           AND f.balunitno = a.balunitno(+)
                           AND a.balunitno is null
                           and F.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and substr(b.balunitno, 1, 2) = '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and b.FINBANKCODE != '000Z'
                        union all
                        --农商行
                        select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) -
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 退货金额,
                               (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                               NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) +
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and substr(b.balunitno, 1, 2) <> '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and a.FINBANKCODE IN ('000L', 'L002')
                           and a.TRANSFEE > 0
                        union all
                        select c.BANK 开户行,
                               f.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               0 转帐金额,
                               '0' 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                               0 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c,
                               TF_B_SPEADJUSTACC   f
                         where (p_var1 is null or p_var1 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                               to_char(a.begintime(+), 'yyyymmdd')
                           AND f.balunitno = a.balunitno(+)
                           AND a.balunitno is null
                           and F.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and substr(b.balunitno, 1, 2) <> '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and a.FINBANKCODE IN ('000L', 'L002')
                        union all
                        --农行
                        select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) -
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 退货金额,
                               (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                               NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) +
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and substr(b.balunitno, 1, 2) <> '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and b.BANKCODE like '%A%'
                           and b.FINBANKCODE not in ('000L', '000Z')
                           and a.TRANSFEE > 0
                        union all
                        select c.BANK 开户行,
                               f.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               0 转帐金额,
                               '0' 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                               0 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c,
                               TF_B_SPEADJUSTACC   f
                         where (p_var1 is null or p_var1 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                               to_char(a.begintime(+), 'yyyymmdd')
                           AND f.balunitno = a.balunitno(+)
                           AND a.balunitno is null
                           and F.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and substr(b.balunitno, 1, 2) <> '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and b.BANKCODE like '%A%'
                           and b.FINBANKCODE not in ('000L', '000Z')
                        union all
                        select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.RENEWFINFEE / 100.0 转帐金额,
                               '重新清算' 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) -
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 退货金额,
                               (NVL(NVL(a.RENEWFINFEE, 0) / 100.0, 0) -
                               NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) +
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.balunitno in ('0BX00011',
                                               '0BX00021',
                                               '0BX00022',
                                               '0BX00012',
                                               '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and a.RENEWFINFEE > 0
                        union all
                        select c.BANK 开户行,
                               f.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               0 转帐金额,
                               '0 ' 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                               0 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c,
                               TF_B_SPEADJUSTACC   f
                         where (p_var1 is null or p_var1 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                               to_char(a.begintime(+), 'yyyymmdd')
                           AND f.balunitno = a.balunitno(+)
                           AND a.balunitno is null
                           and F.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.balunitno in ('0BX00011',
                                               '0BX00021',
                                               '0BX00022',
                                               '0BX00012',
                                               '03000001')
                           and b.BANKCODE = c.BANKCODE
                        union all
                        select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               posno || '油品' || to_char(dealtime, 'yyyymmdd') 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.DEALTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL(NVL(0, 0) / 100.0, 0) 退货金额,
                               a.TRANSFEE / 100.0 结算金额
                          from TF_OUTCOMEFIN_SINOPEC a,
                               TF_TRADE_BALUNIT      b,
                               TD_M_BANK             c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.DEALTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.DEALTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.balunitno in
                               ('0BX00011', '0BX00012', '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and a.TRANSFEE > 0
                        union all
                        select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               posno || '非油品' ||
                               to_char(dealtime, 'yyyymmdd') 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.DEALTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL(NVL(0, 0) / 100.0, 0) 退货金额,
                               a.TRANSFEE / 100.0 结算金额
                          from TF_OUTCOMEFIN_SINOPEC a,
                               TF_TRADE_BALUNIT      b,
                               TD_M_BANK             c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.DEALTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.DEALTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.balunitno in
                               ('0BX00021', '0BX00022', '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and a.TRANSFEE > 0
                        union all
                        --交行
                        select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) -
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 退货金额,
                               (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                               NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) +
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and substr(b.balunitno, 1, 2) <> '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and b.BANKCODE NOT like '%A%'
                           and b.FINBANKCODE not in ('000L', 'L002', '000Z')
                           and a.TRANSFEE > 0
                        union all
                        select c.BANK 开户行,
                               f.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               0 转帐金额,
                               '0' 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                               0 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c,
                               TF_B_SPEADJUSTACC   f
                         where (p_var1 is null or p_var1 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                               to_char(a.begintime(+), 'yyyymmdd')
                           AND f.balunitno = a.balunitno(+)
                           AND a.balunitno is null
                           and F.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and substr(b.balunitno, 1, 2) <> '0C'
                           and b.balunitno not in
                               ('0BX00011',
                                '0BX00021',
                                '0BX00022',
                                '0BX00012',
                                '03000001')
                           and b.BANKCODE = c.BANKCODE
                           and b.BANKCODE NOT like '%A%'
                           and b.FINBANKCODE not in ('000L', 'L002', '000Z')
                        union all -- add by liuhe20120427交行转账中添加轻轨转账账单
                        select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) -
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 退货金额,
                               (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                               NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) +
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 结算金额
                          from TF_RAIL_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT   b,
                               TD_M_BANK          c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.BANKCODE = c.BANKCODE
                           and a.TRANSFEE > 0
                        union all
                        select c.BANK 开户行,
                               f.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               0 转帐金额,
                               '0' 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                               0 结算金额
                          from TF_RAIL_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT   b,
                               TD_M_BANK          c,
                               TF_B_SPEADJUSTACC  f
                         where (p_var1 is null or p_var1 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                               to_char(a.begintime(+), 'yyyymmdd')
                           AND f.balunitno = a.balunitno(+)
                           AND a.balunitno is null
                           AND F.balunitno = '03000001'
                           and F.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.BANKCODE = c.BANKCODE
                        union all
                        --张家港
                        select c.BANK 开户行,
                               a.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               a.TRANSFEE / 100.0 转帐金额,
                               to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               (NVL(NVL((select SUM(NVL(d.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) -
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 退货金额,
                               (NVL(NVL(a.TRANSFEE, 0) / 100.0, 0) -
                               NVL(NVL((select SUM(NVL(D.REFUNDMENT, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And d.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0) +
                               NVL(NVL((select SUM(NVL(d.REBROKERAGE, 0))
                                          from TF_B_SPEADJUSTACC d
                                         where d.BALUNITNO = a.BALUNITNO
                                           And d.STATECODE IN ('1', '2')
                                           And D.CHECKTIME IS NOT NULL
                                           And d.CHECKTIME >=
                                               TO_DATE(TO_CHAR(a.BEGINTIME,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd')
                                           And d.CHECKTIME <
                                               TO_DATE(TO_CHAR(a.ENDTIME - 1,
                                                               'yyyy/MM/dd'),
                                                       'yyyy-MM-dd') + 1),
                                        0) / 100.0,
                                    0)) 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c
                         where (p_var1 is null or p_var1 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(a.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and a.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.BANKCODE = c.BANKCODE
                           and a.BALUNITNO <> '03000001'
                           and a.FINBANKCODE = '000Z'
                           and a.TRANSFEE > 0
                        union all
                        select c.BANK 开户行,
                               f.BALUNITNO 商户代码,
                               b.BALUNIT 商户名称,
                               b.bankaccno 银行账号,
                               0 转帐金额,
                               '0' 应收佣金,
                               DECODE(b.callingno,
                                      '19',
                                      '日期' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '编码' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '否', '1', '是', '否') 收款人是否本行,
                               decode(c.ISLOCAL, '0', '否', '1', '是', '') 收款人是否同城,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 退货金额,
                               0 结算金额
                          from TF_TRADE_OUTCOMEFIN a,
                               TF_TRADE_BALUNIT    b,
                               TD_M_BANK           c,
                               TF_B_SPEADJUSTACC   f
                         where (p_var1 is null or p_var1 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(F.CHECKTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd')),
                                        'yyyymmdd'))
                           and TO_CHAR(F.CHECKTIME, 'yyyymmdd') =
                               to_char(a.begintime(+), 'yyyymmdd')
                           AND f.balunitno = a.balunitno(+)
                           AND a.balunitno is null
                           and F.BALUNITNO = b.BALUNITNO
                           and b.FINTYPECODE = '0'
                           and b.BANKCODE = c.BANKCODE
                           and a.BALUNITNO <> '03000001'
                           and a.FINBANKCODE = '000Z')
                 GROUP BY 银行账号,
                          商户代码,
                          商户名称,
                          开户行,
                          BANKNUMBER,
                          purposetype,
                          收款人是否本行,
                          收款人是否同城,
                          remark,
                          应收佣金
                 ORDER BY 开户行, 商户名称, SUM(转帐金额)) T;
    end if;
    --增加 殷华荣 2012/11/30  联机消费商户转账报表
  elsif p_funcCode = 'TD_EOC_DAILY_REPORT_CA' then
    -- 联机消费商户转账日报查询
    if p_var3 = '1' then
      --不转帐
      open p_cursor for
        select c.BANK 开户行,
               a.BALUNITNO 商户代码,
               b.BALUNIT 商户名称,
               b.bankaccno 银行账号,
               a.TRANSFEE / 100.0 转帐金额,
               a.COMFEE / 100.0 应收佣金,
               b.remark,
               b.purposetype
          from TF_TRADE_OUTCOMEFIN_ONLINE a,
               TF_TRADE_BALUNIT           b,
               TD_M_BANK                  c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '1'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012', '03000001')
           and b.BANKCODE = c.BANKCODE
           and a.TRANSFEE > 0
         order by c.BANK;
    elsif p_var3 = '2' then
      --光大，信息亭
      open p_cursor for
        select c.BANK 开户行,
               a.BALUNITNO 商户代码,
               b.BALUNIT 商户名称,
               b.bankaccno 银行账号,
               a.TRANSFEE / 100.0 转帐金额,
               a.COMFEE / 100.0 应收佣金,
               b.remark,
               b.purposetype
          from TF_TRADE_OUTCOMEFIN_ONLINE a,
               TF_TRADE_BALUNIT           b,
               TD_M_BANK                  c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) = '0C'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012', '03000001')
           and b.BANKCODE = c.BANKCODE
           and b.FINBANKCODE != '000Z'
           and a.TRANSFEE > 0
         order by c.BANK;
    elsif p_var3 = '3' then
      --农商行
      open p_cursor for
        select c.BANK 开户行,
               a.BALUNITNO 商户代码,
               b.BALUNIT 商户名称,
               b.bankaccno 银行账号,
               a.TRANSFEE / 100.0 转帐金额,
               a.COMFEE / 100.0 应收佣金,
               b.remark,
               b.purposetype
          from TF_TRADE_OUTCOMEFIN_ONLINE a,
               TF_TRADE_BALUNIT           b,
               TD_M_BANK                  c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) <> '0C'
           and substr(b.balunitno, 1, 2) <> '06'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012', '03000001')
           and b.BANKCODE = c.BANKCODE
           and a.FINBANKCODE = '000L'
           and a.TRANSFEE > 0
         order by c.BANK;
    elsif p_var3 = '0' then
      --农行
      open p_cursor for
        select c.BANK 开户行,
               a.BALUNITNO 商户代码,
               b.BALUNIT 商户名称,
               b.bankaccno 银行账号,
               a.TRANSFEE / 100.0 转帐金额,
               to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
               b.remark,
               b.purposetype
          from TF_TRADE_OUTCOMEFIN_ONLINE a,
               TF_TRADE_BALUNIT           b,
               TD_M_BANK                  c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) <> '06'
           and substr(b.balunitno, 1, 2) <> '0C'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012', '03000001')
           and b.BANKCODE = c.BANKCODE
           and b.BANKCODE like '%A%'
           and b.FINBANKCODE not in ('000L', '000Z')
           and a.TRANSFEE > 0
        union all
        select c.BANK 开户行,
               a.BALUNITNO 商户代码,
               b.BALUNIT 商户名称,
               b.bankaccno 银行账号,
               a.RENEWFINFEE / 100.0 转帐金额,
               '重新清算' 应收佣金,
               b.remark,
               b.purposetype
          from TF_TRADE_OUTCOMEFIN_ONLINE a,
               TF_TRADE_BALUNIT           b,
               TD_M_BANK                  c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and b.balunitno in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012', '03000001')
           and b.BANKCODE = c.BANKCODE
           and a.RENEWFINFEE > 0
         order by 1;
    elsif p_var3 = '4' then
      --交行
      open p_cursor for
        select c.BANK 开户行,
               a.BALUNITNO 商户代码,
               b.BALUNIT 商户名称,
               b.bankaccno 银行账号,
               a.TRANSFEE / 100.0 转帐金额,
               to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
               b.remark,
               b.purposetype
          from TF_TRADE_OUTCOMEFIN_ONLINE a,
               TF_TRADE_BALUNIT           b,
               TD_M_BANK                  c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) <> '06'
           and substr(b.balunitno, 1, 2) <> '0C'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012', '03000001')
           and b.BANKCODE = c.BANKCODE
           and b.BANKCODE NOT like '%A%'
           and b.FINBANKCODE not in ('000L', '000Z')
           and a.TRANSFEE > 0;
    elsif p_var3 = '5' then
      --张家港
      open p_cursor for
        select c.BANK 开户行,
               a.BALUNITNO 商户代码,
               b.BALUNIT 商户名称,
               b.bankaccno 银行账号,
               a.TRANSFEE / 100.0 转帐金额,
               to_char(a.COMFEE / 100.0, '99999999.99') 应收佣金,
               b.remark,
               b.purposetype
          from TF_TRADE_OUTCOMEFIN_ONLINE a,
               TF_TRADE_BALUNIT           b,
               TD_M_BANK                  c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and b.BANKCODE = c.BANKCODE
           and a.BALUNITNO <> '03000001'
           and a.FINBANKCODE = '000Z'
           and a.TRANSFEE > 0;
    end if;
    select 'SHRB' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    if p_var3 = '1' then
      insert into TF_TRADEOC_SERIALNO_DETAIL
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               NULL
          from TF_TRADE_OUTCOMEFIN_ONLINE a,
               TF_TRADE_BALUNIT           b,
               TD_M_BANK                  c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '1'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and a.FINBANKCODE = c.BANKCODE
           and a.TRANSFEE > 0
         order by a.FINBANKCODE;
    elsif p_var3 = '2' then
      insert into TF_TRADEOC_SERIALNO_DETAIL
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               NULL
          from TF_TRADE_OUTCOMEFIN_ONLINE a,
               TF_TRADE_BALUNIT           b,
               TD_M_BANK                  c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) = '0C'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and a.FINBANKCODE = c.BANKCODE
           and a.TRANSFEE > 0
         order by a.FINBANKCODE;
    elsif p_var3 = '3' then
      insert into TF_TRADEOC_SERIALNO_DETAIL
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               NULL
          from TF_TRADE_OUTCOMEFIN_ONLINE a,
               TF_TRADE_BALUNIT           b,
               TD_M_BANK                  c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) <> '0C'
           and substr(b.balunitno, 1, 2) <> '06'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and a.FINBANKCODE = c.BANKCODE
           and a.FINBANKCODE = '000L'
           and a.TRANSFEE > 0
         order by a.FINBANKCODE;
    elsif p_var3 = '0' then
      insert into TF_TRADEOC_SERIALNO_DETAIL
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               null
          from TF_TRADE_OUTCOMEFIN_ONLINE a,
               TF_TRADE_BALUNIT           b,
               TD_M_BANK                  c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) <> '06'
           and substr(b.balunitno, 1, 2) <> '0C'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and b.BANKCODE = c.BANKCODE
           AND B.BANKCODE LIKE '%A%'
           and a.FINBANKCODE <> '000L'
           and a.TRANSFEE > 0
        union all
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.RENEWFINFEE,
               null
          from TF_TRADE_OUTCOMEFIN_ONLINE a,
               TF_TRADE_BALUNIT           b,
               TD_M_BANK                  c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and b.balunitno in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and b.BANKCODE = c.BANKCODE
           and a.RENEWFINFEE > 0;
    elsif p_var3 = '4' then
      insert into TF_TRADEOC_SERIALNO_DETAIL
        select p_var9,
               c.BANK,
               substr(a.BALUNITNO, 5, 4),
               b.BALUNIT,
               a.TRANSFEE,
               null
          from TF_TRADE_OUTCOMEFIN_ONLINE a,
               TF_TRADE_BALUNIT           b,
               TD_M_BANK                  c
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
           and b.FINTYPECODE = '0'
           and substr(b.balunitno, 1, 2) <> '06'
           and substr(b.balunitno, 1, 2) <> '0C'
           and b.balunitno not in
               ('0BX00011', '0BX00021', '0BX00022', '0BX00012')
           and b.BANKCODE = c.BANKCODE
           and b.BANKCODE NOT like '%A%'
           and b.FINBANKCODE <> '000L'
           and a.TRANSFEE > 0;
    end if;
    commit;
  
  elsif p_funcCode = 'TRADE_LQ_REPORT' then
    -- 商户转帐清算
    open p_cursor for
      select b.BALUNIT 商户名称,
             to_char(a.ENDTIME, 'yyyymmdd') 转帐时间,
             a.TRANSFEE / 100.0 转帐金额
        from TF_TRADE_OUTCOMEFIN a, TF_TRADE_BALUNIT b
       where a.BALUNITNO = p_var7
         and a.BALUNITNO = b.BALUNITNO
         and (p_var1 is null or p_var1 = '' or
             to_char(a.ENDTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
         and (p_var2 is null or p_var2 = '' or
             to_char(a.ENDTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
         and a.TRANSFEE > 0
       order by to_char(a.ENDTIME, 'yyyymmdd');
  
    select 'SHQS' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    insert into TF_TRADELQ_SERIALNO_DETAIL
      select p_var9, b.BALUNIT, to_char(a.ENDTIME, 'yymmdd'), a.TRANSFEE
        from TF_TRADE_OUTCOMEFIN a, TF_TRADE_BALUNIT b
       where a.BALUNITNO = p_var7
         and a.BALUNITNO = b.BALUNITNO
         and (p_var1 is null or p_var1 = '' or
             to_char(a.ENDTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
         and (p_var2 is null or p_var2 = '' or
             to_char(a.ENDTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
         and a.TRANSFEE > 0
       order by to_char(a.ENDTIME, 'yymmdd');
    commit;
  
  elsif p_funcCode = 'TAXI_EOC_DAILY_REPORT' then
    -- 出租车转账日报查询
    if p_var2 = '0' then
      open p_cursor for
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') 转帐时间,
               b.BANKACCNO 银行帐号,
               b.BALUNIT 司机姓名,
               a.TRANSFEE / 100.0 转帐金额
          from TF_TAXI_OUTCOMEFIN a, TF_TRADE_BALUNIT b
         where a.BALUNITNO = b.BALUNITNO
           and a.finbankcode IN ('000A', 'A059')
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmddhh24miss') = p_var1)
           and a.TRANSFEE > 0
           and a.BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2'))
         order by b.bankaccno;
    elsif p_var2 = '1' then
      open p_cursor for
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') 转帐时间,
               b.BANKACCNO 银行帐号,
               b.BALUNIT 司机姓名,
               a.TRANSFEE / 100.0 转帐金额
          from TF_TAXI_OUTCOMEFIN a, TF_TRADE_BALUNIT b
         where a.BALUNITNO = b.BALUNITNO
           and a.finbankcode IN ('000L', 'L002')
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmddhh24miss') = p_var1)
           and a.TRANSFEE > 0
           and a.BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2'))
         order by b.bankaccno;
    elsif p_var2 = '2' then
      open p_cursor for
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') 转帐时间,
               b.BANKACCNO 银行帐号,
               b.BALUNIT 司机姓名,
               a.TRANSFEE / 100.0 转帐金额
          from TF_TAXI_OUTCOMEFIN a, TF_TRADE_BALUNIT b
         where a.BALUNITNO = b.BALUNITNO
           and a.finbankcode = '000E'
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmddhh24miss') = p_var1)
           and a.TRANSFEE > 0
           and a.BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2'))
         order by b.bankaccno;
    elsif p_var2 = '3' then
      --张家港
      open p_cursor for
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') 转帐时间,
               b.BANKACCNO 银行帐号,
               b.BALUNIT 司机姓名,
               a.TRANSFEE / 100.0 转帐金额
          from TF_TAXI_OUTCOMEFIN a, TF_TRADE_BALUNIT b
         where a.BALUNITNO = b.BALUNITNO
           and a.finbankcode = '000Z'
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmddhh24miss') = p_var1)
           and a.TRANSFEE > 0
           and a.BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2'))
         order by b.bankaccno;
    elsif p_var2 is null then
      --查询所有转账
      open p_cursor for
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') 转帐时间,
               b.BANKACCNO 银行帐号,
               b.BALUNIT 司机姓名,
               a.TRANSFEE / 100.0 转帐金额
          from TF_TAXI_OUTCOMEFIN a, TF_TRADE_BALUNIT b
         where a.BALUNITNO = b.BALUNITNO
           and a.finbankcode IN ('000A', 'A059')
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmddhh24miss') = p_var1)
           and a.TRANSFEE > 0
           and a.BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2'))
        union all
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') 转帐时间,
               b.BANKACCNO 银行帐号,
               b.BALUNIT 司机姓名,
               a.TRANSFEE / 100.0 转帐金额
          from TF_TAXI_OUTCOMEFIN a, TF_TRADE_BALUNIT b
         where a.BALUNITNO = b.BALUNITNO
           and a.finbankcode IN ('000L', 'L002')
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmddhh24miss') = p_var1)
           and a.TRANSFEE > 0
           and a.BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2'))
        union all
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') 转帐时间,
               b.BANKACCNO 银行帐号,
               b.BALUNIT 司机姓名,
               a.TRANSFEE / 100.0 转帐金额
          from TF_TAXI_OUTCOMEFIN a, TF_TRADE_BALUNIT b
         where a.BALUNITNO = b.BALUNITNO
           and a.finbankcode = '000E'
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmddhh24miss') = p_var1)
           and a.TRANSFEE > 0
           and a.BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2'))
        union all
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') 转帐时间,
               b.BANKACCNO 银行帐号,
               b.BALUNIT 司机姓名,
               a.TRANSFEE / 100.0 转帐金额
          from TF_TAXI_OUTCOMEFIN a, TF_TRADE_BALUNIT b
         where a.BALUNITNO = b.BALUNITNO
           and a.finbankcode = '000Z'
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmddhh24miss') = p_var1)
           and a.TRANSFEE > 0
           and a.BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2'))
         order by 银行帐号;
    
    end if;
  
    select 'CZRB' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    if p_var2 = '0' then
      insert into TF_TAXIOC_SERIALNO_DETAIL
        select p_var9,
               to_char(a.ENDTIME, 'yyyymmddhh24miss'),
               b.BANKACCNO,
               b.BALUNIT,
               a.TRANSFEE
          from TF_TAXI_OUTCOMEFIN a, TF_TRADE_BALUNIT b
         where a.BALUNITNO = b.BALUNITNO
           and a.finbankcode IN ('000A', 'A059')
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmddhh24miss') = p_var1)
           and a.TRANSFEE > 0
           and a.BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2'))
         order by b.bankaccno;
    elsif p_var2 = '1' then
      insert into TF_TAXIOC_SERIALNO_DETAIL
        select p_var9,
               to_char(a.ENDTIME, 'yyyymmddhh24miss'),
               b.BANKACCNO,
               b.BALUNIT,
               a.TRANSFEE
          from TF_TAXI_OUTCOMEFIN a, TF_TRADE_BALUNIT b
         where a.BALUNITNO = b.BALUNITNO
           and a.finbankcode IN ('000L', 'L002')
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmddhh24miss') = p_var1)
           and a.TRANSFEE > 0
           and a.BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2'))
         order by b.bankaccno;
    elsif p_var2 = '2' then
      insert into TF_TAXIOC_SERIALNO_DETAIL
        select p_var9,
               to_char(a.ENDTIME, 'yyyymmddhh24miss'),
               b.BANKACCNO,
               b.BALUNIT,
               a.TRANSFEE
          from TF_TAXI_OUTCOMEFIN a, TF_TRADE_BALUNIT b
         where a.BALUNITNO = b.BALUNITNO
           and a.finbankcode = '000E'
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmddhh24miss') = p_var1)
           and a.TRANSFEE > 0
           and a.BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2'))
         order by b.bankaccno;
    end if;
    commit;
  
  elsif p_funcCode = 'TAXI_LQ_REPORT' then
    -- 出租车转账清算表查询
    if p_var3 = '0' then
      open p_cursor for
        select to_char(endtime, 'yyyymmdd') 转帐日期,
               sum(TRANSFEE) / 100.0 转帐金额
          from TF_TAXI_OUTCOMEFIN
         where (p_var1 is null or p_var1 = '' or
               to_char(ENDTIME, 'yyyymmdd') >= p_var1)
           and (p_var2 is null or p_var2 = '' or
               to_char(ENDTIME, 'yyyymmdd') <= p_var2)
           and finbankcode IN ('000A', 'A059')
           and BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2')
                   and updatetime < to_date(p_var2, 'yyyymmdd'))
         group by to_char(endtime, 'yyyymmdd')
         order by to_char(endtime, 'yyyymmdd');
    
      select 'CZQS' || to_char(sysdate, 'yyyymmdd') ||
             substr('00000000' ||
                    to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                    -8)
        into p_var9
        from dual;
      insert into TF_TAXILQ_SERIALNO_DETAIL
        select p_var9, to_char(endtime, 'yyyymmdd'), sum(TRANSFEE)
          from TF_TAXI_OUTCOMEFIN
         where (p_var1 is null or p_var1 = '' or
               to_char(ENDTIME, 'yyyymmdd') >= p_var1)
           and (p_var2 is null or p_var2 = '' or
               to_char(ENDTIME, 'yyyymmdd') <= p_var2)
           and finbankcode IN ('000A', 'A059')
           and BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2'))
         group by to_char(endtime, 'yyyymmdd')
         order by to_char(endtime, 'yyyymmdd');
      commit;
    
    elsif p_var3 = '1' then
      open p_cursor for
        select to_char(endtime, 'yyyymmdd') 转帐日期,
               sum(TRANSFEE) / 100.0 转帐金额
          from TF_TAXI_OUTCOMEFIN
         where (p_var1 is null or p_var1 = '' or
               to_char(ENDTIME, 'yyyymmdd') >= p_var1)
           and (p_var2 is null or p_var2 = '' or
               to_char(ENDTIME, 'yyyymmdd') <= p_var2)
           and finbankcode IN ('000L', 'L002')
           and BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2')
                   and updatetime < to_date(p_var2, 'yyyymmdd'))
         group by to_char(endtime, 'yyyymmdd')
         order by to_char(endtime, 'yyyymmdd');
    
      select 'CZQS' || to_char(sysdate, 'yyyymmdd') ||
             substr('00000000' ||
                    to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                    -8)
        into p_var9
        from dual;
      insert into TF_TAXILQ_SERIALNO_DETAIL
        select p_var9, to_char(endtime, 'yyyymmdd'), sum(TRANSFEE)
          from TF_TAXI_OUTCOMEFIN
         where (p_var1 is null or p_var1 = '' or
               to_char(ENDTIME, 'yyyymmdd') >= p_var1)
           and (p_var2 is null or p_var2 = '' or
               to_char(ENDTIME, 'yyyymmdd') <= p_var2)
           and finbankcode IN ('000L', 'L002')
           and BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2'))
         group by to_char(endtime, 'yyyymmdd')
         order by to_char(endtime, 'yyyymmdd');
      commit;
    
    elsif p_var3 = '2' then
      open p_cursor for
        select to_char(endtime, 'yyyymmdd') 转帐日期,
               sum(TRANSFEE) / 100.0 转帐金额
          from TF_TAXI_OUTCOMEFIN
         where (p_var1 is null or p_var1 = '' or
               to_char(ENDTIME, 'yyyymmdd') >= p_var1)
           and (p_var2 is null or p_var2 = '' or
               to_char(ENDTIME, 'yyyymmdd') <= p_var2)
           and finbankcode = '000E'
           and BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2')
                   and updatetime < to_date(p_var2, 'yyyymmdd'))
         group by to_char(endtime, 'yyyymmdd')
         order by to_char(endtime, 'yyyymmdd');
    
      select 'CZQS' || to_char(sysdate, 'yyyymmdd') ||
             substr('00000000' ||
                    to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                    -8)
        into p_var9
        from dual;
      insert into TF_TAXILQ_SERIALNO_DETAIL
        select p_var9, to_char(endtime, 'yyyymmdd'), sum(TRANSFEE)
          from TF_TAXI_OUTCOMEFIN
         where (p_var1 is null or p_var1 = '' or
               to_char(ENDTIME, 'yyyymmdd') >= p_var1)
           and (p_var2 is null or p_var2 = '' or
               to_char(ENDTIME, 'yyyymmdd') <= p_var2)
           and finbankcode = '000E'
           and BALUNITNO not in
               (select DETAILNO
                  from TF_UNITE_BALUNIT
                 where STATECODE in ('1', '2'))
         group by to_char(endtime, 'yyyymmdd')
         order by to_char(endtime, 'yyyymmdd');
      commit;
    end if;
  
  elsif p_funcCode = 'TRADECF_SERIALNO_DAILY_REPORT' then
    -- 商户佣金凭证管理日报查询
    if p_var5 = '0' then
      --脱机消费（不包含专有账户消费）
      open p_cursor for
        select b.CALLING 行业,
               c.CORP 单位,
               d.DEPART 部门,
               f.SLOPE 佣金比例,
               sum(a.FINFEE) / 100.0 结算金额,
               sum(a.transfee) / 100.0 转帐金额,
               decode(m.COMFEETAKECODE, '1', sum(a.COMFEE) / 100.0, 0) 自动扣佣金,
               decode(m.COMFEETAKECODE, '0', sum(a.COMFEE) / 100.0, 0) 非自动扣佣金,
               (nvl(sp.rebrokerage, 0)) / 100.0 应退佣金,
               a.BALUNITNO 结算单元编码,
               tmr.regionname 区域
          from TF_TRADE_OUTCOMEFIN a,
               TD_M_CALLINGNO b,
               TD_M_CORP c,
               TD_M_DEPART d,
               TD_TCOMSCHEME_COMRULE e,
               TF_COMRULE f,
               TD_M_REGIONCODE tmr,
               TF_TRADE_BALUNIT m,
               (select tbs.BALUNITNO,
                       tbs.callingno,
                       tbs.corpno,
                       tbs.departno,
                       sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                  from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                 where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                   and tbs.BALUNITNO = ts.BALUNITNO
                   and (p_var1 is null or p_var1 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and tbs.Checktime >=
                       TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                               'yyyy-MM-dd')
                   and tbs.Checktime <
                       TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                               'yyyy-MM-dd') + 1
                 group by tbs.BALUNITNO,
                          tbs.callingno,
                          tbs.corpno,
                          tbs.departno) sp
         where a.BALUNITNO in (select g.BALUNITNO from TF_TRADE_BALUNIT g)
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.balunitno = m.balunitno(+)
           and a.CALLINGNO = b.CALLINGNO
           and a.CORPNO = c.CORPNO
           and a.DEPARTNO = d.DEPARTNO
           and a.COMSCHEMENO = e.COMSCHEMENO
           and e.COMRULENO = f.COMRULENO
           and a.balunitno = sp.balunitno(+)
           and a.CALLINGNO = sp.callingno(+)
           and a.CORPNO = sp.corpno(+)
           and a.DEPARTNO = sp.departno(+)
           and (tmr.regioncode IN
               (select rg1.regioncode
                   from td_m_regioncode rg1
                  where rg1.regionname =
                        (select rg2.regionname
                           from td_m_regioncode rg2
                          where rg2.regioncode = p_var4)) or
               p_var4 is null or p_var4 = '')
           and c.regioncode = tmr.regioncode(+)
         group by a.BALUNITNO,
                  b.CALLING,
                  c.CORP,
                  d.DEPART,
                  f.SLOPE,
                  sp.rebrokerage,
                  tmr.regionname,
                  m.COMFEETAKECODE
        union
        select b.CALLING 行业,
               c.CORP 单位,
               '无部门' 部门,
               f.SLOPE 佣金比例,
               sum(a.FINFEE) / 100.0 结算金额,
               sum(a.transfee) / 100.0 转帐金额,
               decode(m.COMFEETAKECODE, '1', sum(a.COMFEE) / 100.0, 0) 自动扣佣金,
               decode(m.COMFEETAKECODE, '0', sum(a.COMFEE) / 100.0, 0) 非自动扣佣金,
               (nvl(sp.rebrokerage, 0)) / 100.0 应退佣金,
               a.balunitno 结算单元编码,
               tmr.regionname 区域
          from TF_TRADE_OUTCOMEFIN a,
               TD_M_CALLINGNO b,
               TD_M_CORP c,
               TD_TCOMSCHEME_COMRULE e,
               TF_COMRULE f,
               TD_M_REGIONCODE tmr,
               TF_TRADE_BALUNIT m,
               (select tbs.BALUNITNO,
                       tbs.callingno,
                       tbs.corpno,
                       tbs.departno,
                       sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                  from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                 where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                   and tbs.BALUNITNO = ts.BALUNITNO
                   and (p_var1 is null or p_var1 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and tbs.Checktime >=
                       TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                               'yyyy-MM-dd')
                   and tbs.Checktime <
                       TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                               'yyyy-MM-dd') + 1
                 group by tbs.BALUNITNO,
                          tbs.callingno,
                          tbs.corpno,
                          tbs.departno) sp
         where a.BALUNITNO in (select g.BALUNITNO from TF_TRADE_BALUNIT g)
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.balunitno = m.balunitno(+)
           and a.balunitno <> '03000001'
           and a.CALLINGNO = b.CALLINGNO(+)
           and a.CORPNO = c.CORPNO(+)
           and a.DEPARTNO is null
           and a.COMSCHEMENO = e.COMSCHEMENO(+)
           and e.COMRULENO = f.COMRULENO(+)
           and a.balunitno = sp.balunitno(+)
           and a.CALLINGNO = sp.callingno(+)
           and a.CORPNO = sp.corpno(+)
           and (tmr.regioncode IN
               (select rg1.regioncode
                   from td_m_regioncode rg1
                  where rg1.regionname =
                        (select rg2.regionname
                           from td_m_regioncode rg2
                          where rg2.regioncode = p_var4)) or
               p_var4 is null or p_var4 = '')
           and c.regioncode = tmr.regioncode(+)
         group by a.BALUNITNO,
                  b.CALLING,
                  c.CORP,
                  f.SLOPE,
                  sp.rebrokerage,
                  tmr.regionname,
                  m.COMFEETAKECODE
        union
        select b.CALLING 行业,
               c.CORP 单位,
               '无部门' 部门,
               f.SLOPE 佣金比例,
               sum(a.FINFEE) / 100.0 结算金额,
               sum(a.transfee) / 100.0 转帐金额,
               decode(m.COMFEETAKECODE, '1', sum(a.COMFEE) / 100.0, 0) 自动扣佣金,
               decode(m.COMFEETAKECODE, '0', sum(a.COMFEE) / 100.0, 0) 非自动扣佣金,
               (nvl(sp.rebrokerage, 0)) / 100.0 应退佣金,
               a.balunitno 结算单元编码,
               tmr.regionname 区域
          from TF_RAIL_OUTCOMEFIN a,
               TD_M_CALLINGNO b,
               TD_M_CORP c,
               TD_TCOMSCHEME_COMRULE e,
               TF_COMRULE f,
               TD_M_REGIONCODE tmr,
               TF_TRADE_BALUNIT m,
               (select tbs.BALUNITNO,
                       tbs.callingno,
                       tbs.corpno,
                       tbs.departno,
                       sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                  from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                 where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                   and tbs.BALUNITNO = ts.BALUNITNO
                   and (p_var1 is null or p_var1 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and tbs.Checktime >=
                       TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                               'yyyy-MM-dd')
                   and tbs.Checktime <
                       TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                               'yyyy-MM-dd') + 1
                 group by tbs.BALUNITNO,
                          tbs.callingno,
                          tbs.corpno,
                          tbs.departno) sp
         where a.BALUNITNO in (select g.BALUNITNO from TF_TRADE_BALUNIT g)
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.balunitno = m.balunitno(+)
           and a.balunitno = '03000001'
           and a.CALLINGNO = b.CALLINGNO
           and a.CORPNO = c.CORPNO
           and a.DEPARTNO is null
           and a.COMSCHEMENO = e.COMSCHEMENO
           and e.COMRULENO = f.COMRULENO
           and a.balunitno = sp.balunitno(+)
           and a.CALLINGNO = sp.callingno(+)
           and a.CORPNO = sp.corpno(+)
           and (tmr.regioncode IN
               (select rg1.regioncode
                   from td_m_regioncode rg1
                  where rg1.regionname =
                        (select rg2.regionname
                           from td_m_regioncode rg2
                          where rg2.regioncode = p_var4)) or
               p_var4 is null or p_var4 = '')
           and c.regioncode = tmr.regioncode(+)
         group by a.BALUNITNO,
                  b.CALLING,
                  c.CORP,
                  f.SLOPE,
                  sp.rebrokerage,
                  tmr.regionname,
                  m.COMFEETAKECODE
        union
        select '集团消费' 行业,
               '中石油' 单位,
               '' 部门,
               0.005 佣金比例,
               sum(a.TRADEMONEY) / 100.0 结算金额,
               sum(a.smoney) / 100.0 转帐金额,
               decode(m.COMFEETAKECODE,
                      '1',
                      sum(a.TRADEMONEY) * 0.005 / 100.0,
                      0) 自动扣佣金,
               decode(m.COMFEETAKECODE,
                      '0',
                      sum(a.TRADEMONEY) * 0.005 / 100.0,
                      0) 非自动扣佣金,
               (nvl(sp.rebrokerage, 0)) / 100.0 应退佣金,
               a.balunitno 结算单元编码,
               tmr.regionname 区域
          from TF_TRADE_CNPC a,
               TD_M_CORP c,
               TD_M_REGIONCODE tmr,
               TF_TRADE_BALUNIT m,
               (select tbs.BALUNITNO,
                       tbs.callingno,
                       tbs.corpno,
                       tbs.departno,
                       sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                  from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                 where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                   and tbs.BALUNITNO = ts.BALUNITNO
                   and (p_var1 is null or p_var1 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and tbs.Checktime >=
                       TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                               'yyyy-MM-dd')
                   and tbs.Checktime <
                       TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                               'yyyy-MM-dd') + 1
                 group by tbs.BALUNITNO,
                          tbs.callingno,
                          tbs.corpno,
                          tbs.departno) sp
         where a.BALUNITNO in (select b.BALUNITNO from TF_TRADE_BALUNIT b)
           and (p_var1 is null or p_var1 = '' or
               to_char(a.DEALTIME, 'yyyymmdd') >= p_var1)
           and (p_var2 is null or p_var2 = '' or
               to_char(a.DEALTIME, 'yyyymmdd') <= p_var2)
           and TACSTATE = '1'
           and a.balunitno = sp.balunitno(+)
           and c.corp = '中石油'
           and (tmr.regioncode IN
               (select rg1.regioncode
                   from td_m_regioncode rg1
                  where rg1.regionname =
                        (select rg2.regionname
                           from td_m_regioncode rg2
                          where rg2.regioncode = p_var4)) or
               p_var4 is null or p_var4 = '')
           and c.regioncode = tmr.regioncode(+)
           and a.balunitno = m.balunitno(+)
         group by a.BALUNITNO,
                  sp.rebrokerage,
                  tmr.regionname,
                  m.COMFEETAKECODE;
    elsif p_var5 = '1' then
      --专有账户消费（联机）
      open p_cursor for
        select 行业,
               单位,
               部门,
               佣金比例,
               sum(结算金额) 结算金额,
               sum(转帐金额) 转帐金额,
               sum(自动扣佣金) 自动扣佣金,
               sum(非自动扣佣金) 非自动扣佣金,
               sum(应退佣金) 应退佣金,
               结算单元编码,
               区域
          from (select b.CALLING 行业,
                       c.CORP 单位,
                       d.DEPART 部门,
                       f.SLOPE 佣金比例,
                       sum(a.FINFEE) / 100.0 结算金额,
                       sum(a.transfee) / 100.0 转帐金额,
                       decode(m.COMFEETAKECODE,
                              '1',
                              sum(a.COMFEE) / 100.0,
                              0) 自动扣佣金,
                       decode(m.COMFEETAKECODE,
                              '0',
                              sum(a.COMFEE) / 100.0,
                              0) 非自动扣佣金,
                       0 应退佣金,
                       a.BALUNITNO 结算单元编码,
                       tmr.regionname 区域
                  from TF_TRADE_OUTCOMEFIN_ONLINE a,
                       TD_M_CALLINGNO             b,
                       TD_M_CORP                  c,
                       TD_M_DEPART                d,
                       TD_TCOMSCHEME_COMRULE      e,
                       TF_COMRULE                 f,
                       TD_M_REGIONCODE            tmr,
                       TF_TRADE_BALUNIT           m
                 where a.balunitno = m.balunitno(+)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.balunitno = m.balunitno(+)
                   and a.CALLINGNO = b.CALLINGNO
                   and a.CORPNO = c.CORPNO
                   and a.COMSCHEMENO = e.COMSCHEMENO
                   and e.COMRULENO = f.COMRULENO
                   and a.DEPARTNO = d.DEPARTNO(+)
                   and a.comfee >= 0
                   and (tmr.regioncode IN
                       (select rg1.regioncode
                           from td_m_regioncode rg1
                          where rg1.regionname =
                                (select rg2.regionname
                                   from td_m_regioncode rg2
                                  where rg2.regioncode = p_var4)) or
                       p_var4 is null or p_var4 = '')
                   and c.regioncode = tmr.regioncode(+)
                 group by a.BALUNITNO,
                          b.CALLING,
                          c.CORP,
                          d.DEPART,
                          f.SLOPE,
                          tmr.regionname,
                          m.COMFEETAKECODE
                union
                select b.CALLING 行业,
                       c.CORP 单位,
                       d.DEPART 部门,
                       f.SLOPE 佣金比例,
                       sum(a.FINFEE) / 100.0 结算金额,
                       sum(a.transfee) / 100.0 转帐金额,
                       0 自动扣佣金,
                       0 非自动扣佣金,
                       abs(sum(nvl(a.COMFEE, 0))) / 100.0 应退佣金,
                       a.BALUNITNO 结算单元编码,
                       tmr.regionname 区域
                  from TF_TRADE_OUTCOMEFIN_ONLINE a,
                       TD_M_CALLINGNO             b,
                       TD_M_CORP                  c,
                       TD_M_DEPART                d,
                       TD_TCOMSCHEME_COMRULE      e,
                       TF_COMRULE                 f,
                       TD_M_REGIONCODE            tmr,
                       TF_TRADE_BALUNIT           m
                 where a.balunitno = m.balunitno(+)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.balunitno = m.balunitno(+)
                   and a.CALLINGNO = b.CALLINGNO
                   and a.CORPNO = c.CORPNO
                   and a.COMSCHEMENO = e.COMSCHEMENO
                   and e.COMRULENO = f.COMRULENO
                   and a.DEPARTNO = d.DEPARTNO(+)
                   and a.comfee < 0
                   and (tmr.regioncode IN
                       (select rg1.regioncode
                           from td_m_regioncode rg1
                          where rg1.regionname =
                                (select rg2.regionname
                                   from td_m_regioncode rg2
                                  where rg2.regioncode = p_var4)) or
                       p_var4 is null or p_var4 = '')
                   and c.regioncode = tmr.regioncode(+)
                 group by a.BALUNITNO,
                          b.CALLING,
                          c.CORP,
                          d.DEPART,
                          f.SLOPE,
                          tmr.regionname,
                          m.COMFEETAKECODE)
         GROUP BY 行业, 单位, 部门, 佣金比例, 结算单元编码, 区域;
    elsif p_var5 is null then
      --所有的数据
      open p_cursor for
        select 行业,
               单位,
               部门,
               佣金比例,
               sum(结算金额) 结算金额,
               sum(转帐金额) 转帐金额,
               sum(自动扣佣金) 自动扣佣金,
               sum(非自动扣佣金) 非自动扣佣金,
               sum(应退佣金) 应退佣金,
               结算单元编码,
               区域
          from (select b.CALLING 行业,
                       c.CORP 单位,
                       d.DEPART 部门,
                       f.SLOPE 佣金比例,
                       sum(a.FINFEE) / 100.0 结算金额,
                       sum(a.transfee) / 100.0 转帐金额,
                       decode(m.COMFEETAKECODE,
                              '1',
                              sum(a.COMFEE) / 100.0,
                              0) 自动扣佣金,
                       decode(m.COMFEETAKECODE,
                              '0',
                              sum(a.COMFEE) / 100.0,
                              0) 非自动扣佣金,
                       (nvl(sp.rebrokerage, 0)) / 100.0 应退佣金,
                       a.BALUNITNO 结算单元编码,
                       tmr.regionname 区域
                  from TF_TRADE_OUTCOMEFIN a,
                       TD_M_CALLINGNO b,
                       TD_M_CORP c,
                       TD_M_DEPART d,
                       TD_TCOMSCHEME_COMRULE e,
                       TF_COMRULE f,
                       TD_M_REGIONCODE tmr,
                       TF_TRADE_BALUNIT m,
                       (select tbs.BALUNITNO,
                               tbs.callingno,
                               tbs.corpno,
                               tbs.departno,
                               sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                          from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                         where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                           and tbs.BALUNITNO = ts.BALUNITNO
                           and (p_var1 is null or p_var1 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and tbs.Checktime >=
                               TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd')
                           and tbs.Checktime <
                               TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd') + 1
                         group by tbs.BALUNITNO,
                                  tbs.callingno,
                                  tbs.corpno,
                                  tbs.departno) sp
                 where a.BALUNITNO in
                       (select g.BALUNITNO from TF_TRADE_BALUNIT g)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.balunitno = m.balunitno(+)
                   and a.CALLINGNO = b.CALLINGNO
                   and a.CORPNO = c.CORPNO
                   and a.DEPARTNO = d.DEPARTNO
                   and a.COMSCHEMENO = e.COMSCHEMENO
                   and e.COMRULENO = f.COMRULENO
                   and a.balunitno = sp.balunitno(+)
                   and a.CALLINGNO = sp.callingno(+)
                   and a.CORPNO = sp.corpno(+)
                   and a.DEPARTNO = sp.departno(+)
                   and (tmr.regioncode IN
                       (select rg1.regioncode
                           from td_m_regioncode rg1
                          where rg1.regionname =
                                (select rg2.regionname
                                   from td_m_regioncode rg2
                                  where rg2.regioncode = p_var4)) or
                       p_var4 is null or p_var4 = '')
                   and c.regioncode = tmr.regioncode(+)
                 group by a.BALUNITNO,
                          b.CALLING,
                          c.CORP,
                          d.DEPART,
                          f.SLOPE,
                          sp.rebrokerage,
                          tmr.regionname,
                          m.COMFEETAKECODE
                union
                select b.CALLING 行业,
                       c.CORP 单位,
                       '无部门' 部门,
                       f.SLOPE 佣金比例,
                       sum(a.FINFEE) / 100.0 结算金额,
                       sum(a.transfee) / 100.0 转帐金额,
                       decode(m.COMFEETAKECODE,
                              '1',
                              sum(a.COMFEE) / 100.0,
                              0) 自动扣佣金,
                       decode(m.COMFEETAKECODE,
                              '0',
                              sum(a.COMFEE) / 100.0,
                              0) 非自动扣佣金,
                       (nvl(sp.rebrokerage, 0)) / 100.0 应退佣金,
                       a.balunitno 结算单元编码,
                       tmr.regionname 区域
                  from TF_TRADE_OUTCOMEFIN a,
                       TD_M_CALLINGNO b,
                       TD_M_CORP c,
                       TD_TCOMSCHEME_COMRULE e,
                       TF_COMRULE f,
                       TD_M_REGIONCODE tmr,
                       TF_TRADE_BALUNIT m,
                       (select tbs.BALUNITNO,
                               tbs.callingno,
                               tbs.corpno,
                               tbs.departno,
                               sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                          from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                         where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                           and tbs.BALUNITNO = ts.BALUNITNO
                           and (p_var1 is null or p_var1 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and tbs.Checktime >=
                               TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd')
                           and tbs.Checktime <
                               TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd') + 1
                         group by tbs.BALUNITNO,
                                  tbs.callingno,
                                  tbs.corpno,
                                  tbs.departno) sp
                 where a.BALUNITNO in
                       (select g.BALUNITNO from TF_TRADE_BALUNIT g)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.balunitno = m.balunitno(+)
                   and a.balunitno <> '03000001'
                   and a.CALLINGNO = b.CALLINGNO(+)
                   and a.CORPNO = c.CORPNO(+)
                   and a.DEPARTNO is null
                   and a.COMSCHEMENO = e.COMSCHEMENO(+)
                   and e.COMRULENO = f.COMRULENO(+)
                   and a.balunitno = sp.balunitno(+)
                   and a.CALLINGNO = sp.callingno(+)
                   and a.CORPNO = sp.corpno(+)
                   and (tmr.regioncode IN
                       (select rg1.regioncode
                           from td_m_regioncode rg1
                          where rg1.regionname =
                                (select rg2.regionname
                                   from td_m_regioncode rg2
                                  where rg2.regioncode = p_var4)) or
                       p_var4 is null or p_var4 = '')
                   and c.regioncode = tmr.regioncode(+)
                 group by a.BALUNITNO,
                          b.CALLING,
                          c.CORP,
                          f.SLOPE,
                          sp.rebrokerage,
                          tmr.regionname,
                          m.COMFEETAKECODE
                union
                select b.CALLING 行业,
                       c.CORP 单位,
                       '无部门' 部门,
                       f.SLOPE 佣金比例,
                       sum(a.FINFEE) / 100.0 结算金额,
                       sum(a.transfee) / 100.0 转帐金额,
                       decode(m.COMFEETAKECODE,
                              '1',
                              sum(a.COMFEE) / 100.0,
                              0) 自动扣佣金,
                       decode(m.COMFEETAKECODE,
                              '0',
                              sum(a.COMFEE) / 100.0,
                              0) 非自动扣佣金,
                       (nvl(sp.rebrokerage, 0)) / 100.0 应退佣金,
                       a.balunitno 结算单元编码,
                       tmr.regionname 区域
                  from TF_RAIL_OUTCOMEFIN a,
                       TD_M_CALLINGNO b,
                       TD_M_CORP c,
                       TD_TCOMSCHEME_COMRULE e,
                       TF_COMRULE f,
                       TD_M_REGIONCODE tmr,
                       TF_TRADE_BALUNIT m,
                       (select tbs.BALUNITNO,
                               tbs.callingno,
                               tbs.corpno,
                               tbs.departno,
                               sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                          from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                         where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                           and tbs.BALUNITNO = ts.BALUNITNO
                           and (p_var1 is null or p_var1 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and tbs.Checktime >=
                               TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd')
                           and tbs.Checktime <
                               TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd') + 1
                         group by tbs.BALUNITNO,
                                  tbs.callingno,
                                  tbs.corpno,
                                  tbs.departno) sp
                 where a.BALUNITNO in
                       (select g.BALUNITNO from TF_TRADE_BALUNIT g)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.balunitno = m.balunitno(+)
                   and a.balunitno = '03000001'
                   and a.CALLINGNO = b.CALLINGNO
                   and a.CORPNO = c.CORPNO
                   and a.DEPARTNO is null
                   and a.COMSCHEMENO = e.COMSCHEMENO
                   and e.COMRULENO = f.COMRULENO
                   and a.balunitno = sp.balunitno(+)
                   and a.CALLINGNO = sp.callingno(+)
                   and a.CORPNO = sp.corpno(+)
                   and (tmr.regioncode IN
                       (select rg1.regioncode
                           from td_m_regioncode rg1
                          where rg1.regionname =
                                (select rg2.regionname
                                   from td_m_regioncode rg2
                                  where rg2.regioncode = p_var4)) or
                       p_var4 is null or p_var4 = '')
                   and c.regioncode = tmr.regioncode(+)
                 group by a.BALUNITNO,
                          b.CALLING,
                          c.CORP,
                          f.SLOPE,
                          sp.rebrokerage,
                          tmr.regionname,
                          m.COMFEETAKECODE
                union
                select '集团消费' 行业,
                       '中石油' 单位,
                       '' 部门,
                       0.005 佣金比例,
                       sum(a.TRADEMONEY) / 100.0 结算金额,
                       sum(a.smoney) / 100.0 转帐金额,
                       decode(m.COMFEETAKECODE,
                              '1',
                              sum(a.TRADEMONEY) * 0.005 / 100.0,
                              0) 自动扣佣金,
                       decode(m.COMFEETAKECODE,
                              '0',
                              sum(a.TRADEMONEY) * 0.005 / 100.0,
                              0) 非自动扣佣金,
                       (nvl(sp.rebrokerage, 0)) / 100.0 应退佣金,
                       a.balunitno 结算单元编码,
                       tmr.regionname 区域
                  from TF_TRADE_CNPC a,
                       TD_M_CORP c,
                       TD_M_REGIONCODE tmr,
                       TF_TRADE_BALUNIT m,
                       (select tbs.BALUNITNO,
                               tbs.callingno,
                               tbs.corpno,
                               tbs.departno,
                               sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                          from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                         where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                           and tbs.BALUNITNO = ts.BALUNITNO
                           and (p_var1 is null or p_var1 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and tbs.Checktime >=
                               TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd')
                           and tbs.Checktime <
                               TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd') + 1
                         group by tbs.BALUNITNO,
                                  tbs.callingno,
                                  tbs.corpno,
                                  tbs.departno) sp
                 where a.BALUNITNO in
                       (select b.BALUNITNO from TF_TRADE_BALUNIT b)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.DEALTIME, 'yyyymmdd') >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.DEALTIME, 'yyyymmdd') <= p_var2)
                   and TACSTATE = '1'
                   and a.balunitno = sp.balunitno(+)
                   and c.corp = '中石油'
                   and (tmr.regioncode IN
                       (select rg1.regioncode
                           from td_m_regioncode rg1
                          where rg1.regionname =
                                (select rg2.regionname
                                   from td_m_regioncode rg2
                                  where rg2.regioncode = p_var4)) or
                       p_var4 is null or p_var4 = '')
                   and c.regioncode = tmr.regioncode(+)
                   and a.balunitno = m.balunitno(+)
                 group by a.BALUNITNO,
                          sp.rebrokerage,
                          tmr.regionname,
                          m.COMFEETAKECODE
                union --专有账户
                select b.CALLING 行业,
                       c.CORP 单位,
                       d.DEPART 部门,
                       f.SLOPE 佣金比例,
                       sum(a.FINFEE) / 100.0 结算金额,
                       sum(a.transfee) / 100.0 转帐金额,
                       decode(m.COMFEETAKECODE,
                              '1',
                              sum(a.COMFEE) / 100.0,
                              0) 自动扣佣金,
                       decode(m.COMFEETAKECODE,
                              '0',
                              sum(a.COMFEE) / 100.0,
                              0) 非自动扣佣金,
                       0 应退佣金,
                       a.BALUNITNO 结算单元编码,
                       tmr.regionname 区域
                  from TF_TRADE_OUTCOMEFIN_ONLINE a,
                       TD_M_CALLINGNO             b,
                       TD_M_CORP                  c,
                       TD_M_DEPART                d,
                       TD_TCOMSCHEME_COMRULE      e,
                       TF_COMRULE                 f,
                       TD_M_REGIONCODE            tmr,
                       TF_TRADE_BALUNIT           m
                 where a.balunitno = m.balunitno(+)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.balunitno = m.balunitno(+)
                   and a.CALLINGNO = b.CALLINGNO
                   and a.CORPNO = c.CORPNO
                   and a.COMSCHEMENO = e.COMSCHEMENO
                   and e.COMRULENO = f.COMRULENO
                   and a.DEPARTNO = d.DEPARTNO(+)
                   and a.comfee >= 0
                   and (tmr.regioncode IN
                       (select rg1.regioncode
                           from td_m_regioncode rg1
                          where rg1.regionname =
                                (select rg2.regionname
                                   from td_m_regioncode rg2
                                  where rg2.regioncode = p_var4)) or
                       p_var4 is null or p_var4 = '')
                   and c.regioncode = tmr.regioncode(+)
                 group by a.BALUNITNO,
                          b.CALLING,
                          c.CORP,
                          d.DEPART,
                          f.SLOPE,
                          tmr.regionname,
                          m.COMFEETAKECODE
                union
                select b.CALLING 行业,
                       c.CORP 单位,
                       d.DEPART 部门,
                       f.SLOPE 佣金比例,
                       sum(a.FINFEE) / 100.0 结算金额,
                       sum(a.transfee) / 100.0 转帐金额,
                       0 自动扣佣金,
                       0 非自动扣佣金,
                       abs(sum(nvl(a.COMFEE, 0))) / 100.0 应退佣金,
                       a.BALUNITNO 结算单元编码,
                       tmr.regionname 区域
                  from TF_TRADE_OUTCOMEFIN_ONLINE a,
                       TD_M_CALLINGNO             b,
                       TD_M_CORP                  c,
                       TD_M_DEPART                d,
                       TD_TCOMSCHEME_COMRULE      e,
                       TF_COMRULE                 f,
                       TD_M_REGIONCODE            tmr,
                       TF_TRADE_BALUNIT           m
                 where a.balunitno = m.balunitno(+)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.balunitno = m.balunitno(+)
                   and a.CALLINGNO = b.CALLINGNO
                   and a.CORPNO = c.CORPNO
                   and a.COMSCHEMENO = e.COMSCHEMENO
                   and e.COMRULENO = f.COMRULENO
                   and a.DEPARTNO = d.DEPARTNO(+)
                   and a.comfee < 0
                   and (tmr.regioncode IN
                       (select rg1.regioncode
                           from td_m_regioncode rg1
                          where rg1.regionname =
                                (select rg2.regionname
                                   from td_m_regioncode rg2
                                  where rg2.regioncode = p_var4)) or
                       p_var4 is null or p_var4 = '')
                   and c.regioncode = tmr.regioncode(+)
                 group by a.BALUNITNO,
                          b.CALLING,
                          c.CORP,
                          d.DEPART,
                          f.SLOPE,
                          tmr.regionname,
                          m.COMFEETAKECODE)
         GROUP BY 行业, 单位, 部门, 佣金比例, 结算单元编码, 区域;
    
    end if;
  
    select 'YJRB' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    if p_var5 = '0' then
      insert into TF_TRADECF_SERIALNO_DETAIL
        select p_var9,
               p_var3,
               b.CALLING,
               c.CORP,
               d.DEPART,
               f.SLOPE,
               sum(a.FINFEE) / 100.0,
               sum(a.COMFEE) / 100.0,
               nvl(sp.rebrokerage, 0)
          from TF_TRADE_OUTCOMEFIN a,
               TD_M_CALLINGNO b,
               TD_M_CORP c,
               TD_M_DEPART d,
               TD_TCOMSCHEME_COMRULE e,
               TF_COMRULE f,
               (select tbs.BALUNITNO,
                       tbs.callingno,
                       tbs.corpno,
                       tbs.departno,
                       sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                  from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                 where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                   and tbs.BALUNITNO = ts.BALUNITNO
                   and (p_var1 is null or p_var1 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and tbs.Checktime >=
                       TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                               'yyyy-MM-dd')
                   and tbs.Checktime <
                       TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                               'yyyy-MM-dd') + 1
                 group by tbs.BALUNITNO,
                          tbs.callingno,
                          tbs.corpno,
                          tbs.departno) sp
         where a.BALUNITNO in (select g.BALUNITNO from TF_TRADE_BALUNIT g)
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.CALLINGNO = b.CALLINGNO
           and a.CORPNO = c.CORPNO
           and a.DEPARTNO = d.DEPARTNO
           and a.COMSCHEMENO = e.COMSCHEMENO
           and e.COMRULENO = f.COMRULENO
           and a.balunitno = sp.balunitno(+)
           and a.CALLINGNO = sp.callingno(+)
           and a.CORPNO = sp.corpno(+)
           and a.DEPARTNO = sp.departno(+)
         group by a.BALUNITNO,
                  b.CALLING,
                  c.CORP,
                  d.DEPART,
                  f.SLOPE,
                  sp.rebrokerage
        union
        select p_var9,
               p_var3,
               b.CALLING,
               c.CORP,
               '无部门',
               f.SLOPE,
               sum(a.FINFEE) / 100.0,
               sum(a.COMFEE) / 100.0,
               nvl(sp.rebrokerage, 0)
          from TF_TRADE_OUTCOMEFIN a,
               TD_M_CALLINGNO b,
               TD_M_CORP c,
               TD_TCOMSCHEME_COMRULE e,
               TF_COMRULE f,
               (select tbs.BALUNITNO,
                       tbs.callingno,
                       tbs.corpno,
                       tbs.departno,
                       sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                  from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                 where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                   and tbs.BALUNITNO = ts.BALUNITNO
                   and (p_var1 is null or p_var1 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and tbs.Checktime >=
                       TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                               'yyyy-MM-dd')
                   and tbs.Checktime <
                       TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                               'yyyy-MM-dd') + 1
                 group by tbs.BALUNITNO,
                          tbs.callingno,
                          tbs.corpno,
                          tbs.departno) sp
         where a.BALUNITNO in (select g.BALUNITNO from TF_TRADE_BALUNIT g)
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.balunitno <> '03000001'
           and a.CALLINGNO = b.CALLINGNO(+)
           and a.CORPNO = c.CORPNO(+)
           and a.DEPARTNO is null
           and a.COMSCHEMENO = e.COMSCHEMENO(+)
           and e.COMRULENO = f.COMRULENO(+)
           and a.balunitno = sp.balunitno(+)
           and a.CALLINGNO = sp.callingno(+)
           and a.CORPNO = sp.corpno(+)
         group by a.BALUNITNO, b.CALLING, c.CORP, f.SLOPE, sp.rebrokerage
        union
        select p_var9,
               p_var3,
               b.CALLING,
               c.CORP,
               '无部门',
               f.SLOPE,
               sum(a.FINFEE) / 100.0,
               sum(a.COMFEE) / 100.0,
               nvl(sp.rebrokerage, 0)
          from TF_RAIL_OUTCOMEFIN a,
               TD_M_CALLINGNO b,
               TD_M_CORP c,
               TD_TCOMSCHEME_COMRULE e,
               TF_COMRULE f,
               (select tbs.BALUNITNO,
                       tbs.callingno,
                       tbs.corpno,
                       tbs.departno,
                       sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                  from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                 where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                   and tbs.BALUNITNO = ts.BALUNITNO
                   and (p_var1 is null or p_var1 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and tbs.Checktime >=
                       TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                               'yyyy-MM-dd')
                   and tbs.Checktime <
                       TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                               'yyyy-MM-dd') + 1
                 group by tbs.BALUNITNO,
                          tbs.callingno,
                          tbs.corpno,
                          tbs.departno) sp
         where a.BALUNITNO in (select g.BALUNITNO from TF_TRADE_BALUNIT g)
           and (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.balunitno = '03000001'
           and a.CALLINGNO = b.CALLINGNO
           and a.CORPNO = c.CORPNO
           and a.DEPARTNO is null
           and a.COMSCHEMENO = e.COMSCHEMENO
           and e.COMRULENO = f.COMRULENO
           and a.balunitno = sp.balunitno(+)
           and a.CALLINGNO = sp.callingno(+)
           and a.CORPNO = sp.corpno(+)
         group by a.BALUNITNO, b.CALLING, c.CORP, f.SLOPE, sp.rebrokerage
        union
        select p_var9,
               p_var3,
               '集团消费',
               '中石油',
               null,
               0.005,
               sum(a.TRADEMONEY) / 100.0,
               sum(a.TRADEMONEY) * 0.005 / 100.0,
               nvl(sp.rebrokerage, 0)
          from TF_TRADE_CNPC a,
               (select tbs.BALUNITNO,
                       tbs.callingno,
                       tbs.corpno,
                       tbs.departno,
                       sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                  from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                 where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                   and tbs.BALUNITNO = ts.BALUNITNO
                   and (p_var1 is null or p_var1 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(ts.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and tbs.Checktime >=
                       TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                               'yyyy-MM-dd')
                   and tbs.Checktime <
                       TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                               'yyyy-MM-dd') + 1
                 group by tbs.BALUNITNO,
                          tbs.callingno,
                          tbs.corpno,
                          tbs.departno) sp
         where a.BALUNITNO in (select b.BALUNITNO from TF_TRADE_BALUNIT b)
           and (p_var1 is null or p_var1 = '' or
               to_char(a.DEALTIME, 'yyyymmdd') >= p_var1)
           and (p_var2 is null or p_var2 = '' or
               to_char(a.DEALTIME, 'yyyymmdd') <= p_var2)
           and TACSTATE = '1'
           and a.balunitno = sp.balunitno(+)
         group by a.BALUNITNO, sp.rebrokerage;
    elsif p_var5 = '1' then
      insert into TF_TRADECF_SERIALNO_DETAIL
        select p_var9,
               p_var3,
               行业,
               单位,
               部门,
               佣金比例,
               sum(结算金额),
               sum(应收佣金),
               sum(应退佣金)
          from (select b.CALLING 行业,
                       c.CORP 单位,
                       d.DEPART 部门,
                       f.SLOPE 佣金比例,
                       sum(a.FINFEE) / 100.0 结算金额,
                       sum(a.COMFEE) / 100.0 应收佣金,
                       0 应退佣金
                  from TF_TRADE_OUTCOMEFIN_ONLINE a,
                       TD_M_CALLINGNO             b,
                       TD_M_CORP                  c,
                       TD_M_DEPART                d,
                       TD_TCOMSCHEME_COMRULE      e,
                       TF_COMRULE                 f,
                       TD_M_REGIONCODE            tmr,
                       TF_TRADE_BALUNIT           m
                 where a.balunitno = m.balunitno(+)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.balunitno = m.balunitno(+)
                   and a.CALLINGNO = b.CALLINGNO
                   and a.CORPNO = c.CORPNO
                   and a.COMSCHEMENO = e.COMSCHEMENO
                   and e.COMRULENO = f.COMRULENO
                   and a.DEPARTNO = d.DEPARTNO(+)
                   and a.comfee >= 0
                   and (tmr.regioncode IN
                       (select rg1.regioncode
                           from td_m_regioncode rg1
                          where rg1.regionname =
                                (select rg2.regionname
                                   from td_m_regioncode rg2
                                  where rg2.regioncode = p_var4)) or
                       p_var4 is null or p_var4 = '')
                   and c.regioncode = tmr.regioncode(+)
                 group by a.BALUNITNO, b.CALLING, c.CORP, d.DEPART, f.SLOPE
                union
                select b.CALLING 行业,
                       c.CORP 单位,
                       d.DEPART 部门,
                       f.SLOPE 佣金比例,
                       sum(a.FINFEE) / 100.0 结算金额,
                       0 应收佣金,
                       abs(sum(nvl(a.COMFEE, 0))) 应退佣金
                  from TF_TRADE_OUTCOMEFIN_ONLINE a,
                       TD_M_CALLINGNO             b,
                       TD_M_CORP                  c,
                       TD_M_DEPART                d,
                       TD_TCOMSCHEME_COMRULE      e,
                       TF_COMRULE                 f,
                       TD_M_REGIONCODE            tmr,
                       TF_TRADE_BALUNIT           m
                 where a.balunitno = m.balunitno(+)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.balunitno = m.balunitno(+)
                   and a.CALLINGNO = b.CALLINGNO
                   and a.CORPNO = c.CORPNO
                   and a.COMSCHEMENO = e.COMSCHEMENO
                   and e.COMRULENO = f.COMRULENO
                   and a.DEPARTNO = d.DEPARTNO(+)
                   and a.comfee < 0
                   and (tmr.regioncode IN
                       (select rg1.regioncode
                           from td_m_regioncode rg1
                          where rg1.regionname =
                                (select rg2.regionname
                                   from td_m_regioncode rg2
                                  where rg2.regioncode = p_var4)) or
                       p_var4 is null or p_var4 = '')
                   and c.regioncode = tmr.regioncode(+)
                 group by a.BALUNITNO, b.CALLING, c.CORP, d.DEPART, f.SLOPE)
         GROUP BY 行业, 单位, 部门, 佣金比例;
    elsif p_var5 is null then
      insert into TF_TRADECF_SERIALNO_DETAIL
        select p_var9,
               p_var3,
               行业,
               单位,
               部门,
               佣金比例,
               sum(结算金额),
               sum(应收佣金),
               sum(应退佣金)
          from (select b.CALLING 行业,
                       c.CORP 单位,
                       d.DEPART 部门,
                       f.SLOPE 佣金比例,
                       sum(a.FINFEE) / 100.0 结算金额,
                       sum(a.COMFEE) / 100.0 应收佣金,
                       nvl(sp.rebrokerage, 0) 应退佣金
                  from TF_TRADE_OUTCOMEFIN a,
                       TD_M_CALLINGNO b,
                       TD_M_CORP c,
                       TD_M_DEPART d,
                       TD_TCOMSCHEME_COMRULE e,
                       TF_COMRULE f,
                       (select tbs.BALUNITNO,
                               tbs.callingno,
                               tbs.corpno,
                               tbs.departno,
                               sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                          from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                         where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                           and tbs.BALUNITNO = ts.BALUNITNO
                           and (p_var1 is null or p_var1 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and tbs.Checktime >=
                               TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd')
                           and tbs.Checktime <
                               TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd') + 1
                         group by tbs.BALUNITNO,
                                  tbs.callingno,
                                  tbs.corpno,
                                  tbs.departno) sp
                 where a.BALUNITNO in
                       (select g.BALUNITNO from TF_TRADE_BALUNIT g)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.CALLINGNO = b.CALLINGNO
                   and a.CORPNO = c.CORPNO
                   and a.DEPARTNO = d.DEPARTNO
                   and a.COMSCHEMENO = e.COMSCHEMENO
                   and e.COMRULENO = f.COMRULENO
                   and a.balunitno = sp.balunitno(+)
                   and a.CALLINGNO = sp.callingno(+)
                   and a.CORPNO = sp.corpno(+)
                   and a.DEPARTNO = sp.departno(+)
                 group by a.BALUNITNO,
                          b.CALLING,
                          c.CORP,
                          d.DEPART,
                          f.SLOPE,
                          sp.rebrokerage
                union
                select b.CALLING 行业,
                       c.CORP 单位,
                       '无部门' 部门,
                       f.SLOPE 佣金比例,
                       sum(a.FINFEE) / 100.0 结算金额,
                       sum(a.COMFEE) / 100.0 应收佣金,
                       nvl(sp.rebrokerage, 0) 应退佣金
                  from TF_TRADE_OUTCOMEFIN a,
                       TD_M_CALLINGNO b,
                       TD_M_CORP c,
                       TD_TCOMSCHEME_COMRULE e,
                       TF_COMRULE f,
                       (select tbs.BALUNITNO,
                               tbs.callingno,
                               tbs.corpno,
                               tbs.departno,
                               sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                          from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                         where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                           and tbs.BALUNITNO = ts.BALUNITNO
                           and (p_var1 is null or p_var1 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and tbs.Checktime >=
                               TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd')
                           and tbs.Checktime <
                               TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd') + 1
                         group by tbs.BALUNITNO,
                                  tbs.callingno,
                                  tbs.corpno,
                                  tbs.departno) sp
                 where a.BALUNITNO in
                       (select g.BALUNITNO from TF_TRADE_BALUNIT g)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.balunitno <> '03000001'
                   and a.CALLINGNO = b.CALLINGNO(+)
                   and a.CORPNO = c.CORPNO(+)
                   and a.DEPARTNO is null
                   and a.COMSCHEMENO = e.COMSCHEMENO(+)
                   and e.COMRULENO = f.COMRULENO(+)
                   and a.balunitno = sp.balunitno(+)
                   and a.CALLINGNO = sp.callingno(+)
                   and a.CORPNO = sp.corpno(+)
                 group by a.BALUNITNO,
                          b.CALLING,
                          c.CORP,
                          f.SLOPE,
                          sp.rebrokerage
                union
                select b.CALLING 行业,
                       c.CORP 单位,
                       '无部门' 部门,
                       f.SLOPE 佣金比例,
                       sum(a.FINFEE) / 100.0 结算金额,
                       sum(a.COMFEE) / 100.0 应收佣金,
                       nvl(sp.rebrokerage, 0) 应退佣金
                  from TF_RAIL_OUTCOMEFIN a,
                       TD_M_CALLINGNO b,
                       TD_M_CORP c,
                       TD_TCOMSCHEME_COMRULE e,
                       TF_COMRULE f,
                       (select tbs.BALUNITNO,
                               tbs.callingno,
                               tbs.corpno,
                               tbs.departno,
                               sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                          from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                         where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                           and tbs.BALUNITNO = ts.BALUNITNO
                           and (p_var1 is null or p_var1 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and tbs.Checktime >=
                               TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd')
                           and tbs.Checktime <
                               TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd') + 1
                         group by tbs.BALUNITNO,
                                  tbs.callingno,
                                  tbs.corpno,
                                  tbs.departno) sp
                 where a.BALUNITNO in
                       (select g.BALUNITNO from TF_TRADE_BALUNIT g)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.balunitno = '03000001'
                   and a.CALLINGNO = b.CALLINGNO
                   and a.CORPNO = c.CORPNO
                   and a.DEPARTNO is null
                   and a.COMSCHEMENO = e.COMSCHEMENO
                   and e.COMRULENO = f.COMRULENO
                   and a.balunitno = sp.balunitno(+)
                   and a.CALLINGNO = sp.callingno(+)
                   and a.CORPNO = sp.corpno(+)
                 group by a.BALUNITNO,
                          b.CALLING,
                          c.CORP,
                          f.SLOPE,
                          sp.rebrokerage
                union
                select '集团消费' 行业,
                       '中石油' 单位,
                       null,
                       0.005 佣金比例,
                       sum(a.TRADEMONEY) / 100.0 结算金额,
                       sum(a.TRADEMONEY) * 0.005 / 100.0 应收佣金,
                       nvl(sp.rebrokerage, 0) 应退佣金
                  from TF_TRADE_CNPC a,
                       (select tbs.BALUNITNO,
                               tbs.callingno,
                               tbs.corpno,
                               tbs.departno,
                               sum(nvl(tbs.rebrokerage, 0)) rebrokerage
                          from TF_B_SPEADJUSTACC tbs, TF_TRADE_OUTCOMEFIN ts
                         where (tbs.STATECODE = '1' or tbs.STATECODE = '2')
                           and tbs.BALUNITNO = ts.BALUNITNO
                           and (p_var1 is null or p_var1 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') >=
                               to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and (p_var2 is null or p_var2 = '' or
                               to_char(ts.ENDTIME, 'yyyymmdd') <=
                               to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                        'yyyymmdd'))
                           and tbs.Checktime >=
                               TO_DATE(TO_CHAR(ts.BEGINTIME, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd')
                           and tbs.Checktime <
                               TO_DATE(TO_CHAR(ts.ENDTIME - 1, 'yyyy/MM/dd'),
                                       'yyyy-MM-dd') + 1
                         group by tbs.BALUNITNO,
                                  tbs.callingno,
                                  tbs.corpno,
                                  tbs.departno) sp
                 where a.BALUNITNO in
                       (select b.BALUNITNO from TF_TRADE_BALUNIT b)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.DEALTIME, 'yyyymmdd') >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.DEALTIME, 'yyyymmdd') <= p_var2)
                   and TACSTATE = '1'
                   and a.balunitno = sp.balunitno(+)
                 group by a.BALUNITNO, sp.rebrokerage
                union --专有账户
                select b.CALLING 行业,
                       c.CORP 单位,
                       d.DEPART 部门,
                       f.SLOPE 佣金比例,
                       sum(a.FINFEE) / 100.0 结算金额,
                       sum(a.COMFEE) / 100.0 应收佣金,
                       0 应退佣金
                  from TF_TRADE_OUTCOMEFIN_ONLINE a,
                       TD_M_CALLINGNO             b,
                       TD_M_CORP                  c,
                       TD_M_DEPART                d,
                       TD_TCOMSCHEME_COMRULE      e,
                       TF_COMRULE                 f,
                       TD_M_REGIONCODE            tmr,
                       TF_TRADE_BALUNIT           m
                 where a.balunitno = m.balunitno(+)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.balunitno = m.balunitno(+)
                   and a.CALLINGNO = b.CALLINGNO
                   and a.CORPNO = c.CORPNO
                   and a.COMSCHEMENO = e.COMSCHEMENO
                   and e.COMRULENO = f.COMRULENO
                   and a.DEPARTNO = d.DEPARTNO(+)
                   and a.comfee >= 0
                   and (tmr.regioncode IN
                       (select rg1.regioncode
                           from td_m_regioncode rg1
                          where rg1.regionname =
                                (select rg2.regionname
                                   from td_m_regioncode rg2
                                  where rg2.regioncode = p_var4)) or
                       p_var4 is null or p_var4 = '')
                   and c.regioncode = tmr.regioncode(+)
                 group by a.BALUNITNO, b.CALLING, c.CORP, d.DEPART, f.SLOPE
                union
                select b.CALLING 行业,
                       c.CORP 单位,
                       d.DEPART 部门,
                       f.SLOPE 佣金比例,
                       sum(a.FINFEE) / 100.0 结算金额,
                       0 应收佣金,
                       abs(sum(nvl(a.COMFEE, 0))) 应退佣金
                  from TF_TRADE_OUTCOMEFIN_ONLINE a,
                       TD_M_CALLINGNO             b,
                       TD_M_CORP                  c,
                       TD_M_DEPART                d,
                       TD_TCOMSCHEME_COMRULE      e,
                       TF_COMRULE                 f,
                       TD_M_REGIONCODE            tmr,
                       TF_TRADE_BALUNIT           m
                 where a.balunitno = m.balunitno(+)
                   and (p_var1 is null or p_var1 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') >=
                       to_char((to_date(p_var1, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.ENDTIME, 'yyyymmdd') <=
                       to_char((to_date(p_var2, 'yyyymmdd') + 1),
                                'yyyymmdd'))
                   and a.balunitno = m.balunitno(+)
                   and a.CALLINGNO = b.CALLINGNO
                   and a.CORPNO = c.CORPNO
                   and a.COMSCHEMENO = e.COMSCHEMENO
                   and e.COMRULENO = f.COMRULENO
                   and a.DEPARTNO = d.DEPARTNO(+)
                   and a.comfee < 0
                   and (tmr.regioncode IN
                       (select rg1.regioncode
                           from td_m_regioncode rg1
                          where rg1.regionname =
                                (select rg2.regionname
                                   from td_m_regioncode rg2
                                  where rg2.regioncode = p_var4)) or
                       p_var4 is null or p_var4 = '')
                   and c.regioncode = tmr.regioncode(+)
                 group by a.BALUNITNO, b.CALLING, c.CORP, d.DEPART, f.SLOPE)
         GROUP BY 行业, 单位, 部门, 佣金比例;
    end if;
    insert into TF_TRADECF_SERIALNO_STATUS values (p_var9, '0');
    commit;
  elsif p_funcCode = 'GET_AUDIT_DATA' then
    -- 获取凭证审核数据和状态
    open p_cursor for
      select b.STAFFNAME 商户经理,
             a.CALLING 商户行业,
             a.CORP 商户单位,
             a.DEPART 商户部门,
             a.SLOPE 佣金比例,
             sum(a.COMFEE) 结算金额,
             sum(a.FINFEE) 应收佣金,
             (sum(nvl(a.rebrokerage, 0))) / 100.0 应退佣金
        from TF_TRADECF_SERIALNO_DETAIL a, TD_M_INSIDESTAFF b
       where a.FIANCE_SERIALNO = p_var4
         and a.SERMANAGERCODE = b.STAFFNO
       group by b.STAFFNAME, a.CALLING, a.CORP, a.DEPART, a.SLOPE;
  
    begin
      select dealstatecode
        into p_var8
        from tf_tradecf_serialno_status
       where fiance_serialno = p_var4;
    exception
      when no_data_found then
        p_var8 := '';
    end;
  
    insert into TF_F_OPERATIONLOG
      (OPERATION_TIME, OPERATESTAFFNO, OPERATION_TYPE)
    values
      (sysdate, p_var3, '11');
    commit;
  
  elsif p_funcCode = 'AUDIT_CONFIRM' then
    -- 确认开票
    update TF_TRADECF_SERIALNO_STATUS
       set DEALSTATECODE = '1'
     where FIANCE_SERIALNO = p_var4
       and DEALSTATECODE = '0';
  
    open p_cursor for
      select 1 from dual;
  
    insert into TF_F_OPERATIONLOG
      (OPERATION_TIME, OPERATESTAFFNO, OPERATION_TYPE)
    values
      (sysdate, p_var3, '17');
    commit;
  
  elsif p_funcCode = 'AUDIT_FEEDBACK' then
    -- 审核回退
    update TF_TRADECF_SERIALNO_STATUS
       set DEALSTATECODE = '2'
     where FIANCE_SERIALNO = p_var4
       and DEALSTATECODE = '0';
  
    open p_cursor for
      select 1 from dual;
  
    insert into TF_F_OPERATIONLOG
      (OPERATION_TIME, OPERATESTAFFNO, OPERATION_TYPE)
    values
      (sysdate, p_var3, '21');
    commit;
  
  elsif p_funcCode = 'CARDFEE_MONTH_COLLECT' then
    -- 卡费月报
    open p_cursor for
      select '卡使用费', USEDFEETIMES 笔数, USEDFEE 金额
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4
      union
      select '一次性售卡费', CARDCOSTTIMES 笔数, CARDCOST / 100.0 金额
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4
      union
      select '退卡(售出一年内)',
             SERVICEMONEY1TIMES 笔数,
             SERVICEMONEY1 / 100.0 金额
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4
      union
      select '退卡(售出一年外)',
             SERVICEMONEY2TIMES 笔数,
             SERVICEMONEY2 / 100.0 金额
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4;
  
    select 'KFYB' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    insert into TF_CARDFEE_SERIALNO_DETAIL
      select p_var9, '卡使用费', USEDFEETIMES, USEDFEE
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4
      union
      select p_var9, '一次性售卡费', CARDCOSTTIMES, CARDCOST
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4
      union
      select p_var9,
             '退卡（售出一年内）',
             SERVICEMONEY1TIMES,
             SERVICEMONEY1
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4
      union
      select p_var9, '退卡(售出一年外）', SERVICEMONEY2TIMES, SERVICEMONEY2
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4;
    commit;
  
  elsif p_funcCode = 'REFUND_EOC_REPORT' then
    -- 退充值转帐明细查询
    open p_cursor for
      select b.BANK 银行,
             a.BANKACCNO 帐号,
             a.custname 收款人,
             a.CARDNO 卡号,
             a.factmoney / 100.0 应退金额,
             (a.BACKMONEY - a.factmoney) / 100.0 扣除已付佣金,
             a.OPERATETIME 时间,
             a.purposetype
        from TF_B_REFUND a, TD_M_BANK b
       where (p_var1 is null or p_var1 = '' or
             to_char(a.OPERATETIME, 'yyyymmdd') >= p_var1)
         and (p_var2 is null or p_var2 = '' or
             to_char(a.OPERATETIME, 'yyyymmdd') <= p_var2)
         and a.BANKCODE = b.BANKCODE
       order by a.OPERATETIME, b.bank, a.custname;
  
    select 'TCZZ' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    insert into TF_REFUND_SERIALNO_DETAIL
      select p_var9,
             b.BANK,
             a.BANKACCNO,
             a.CARDNO,
             a.BACKMONEY,
             a.OPERATETIME
        from TF_B_REFUND a, TD_M_BANK b
       where (p_var1 is null or p_var1 = '' or
             to_char(a.OPERATETIME, 'yyyymmdd') >= p_var1)
         and (p_var2 is null or p_var2 = '' or
             to_char(a.OPERATETIME, 'yyyymmdd') <= p_var2)
         and a.BANKCODE = b.BANKCODE
       order by b.bank;
    commit;
  elsif p_funcCode = 'REFUND_EOC_REPORT_OUT' then
    -- 退充值转帐明细查询转帐表格
    open p_cursor for
      SELECT ROWNUM, C.*
        FROM (SELECT T.BANKACCNO,
                     T.CUSTNAME,
                     B.BANK,
                     B.BANKNUMBER,
                     DECODE(T.PURPOSETYPE, '1', '0', '2', '1') PURPOSETYPE,
                     T.FACTMONEY / 100.0 FACTMONEY,
                     DECODE(B.ISSZBANK, '0', '否', '1', '是', '否') ISSZBANK,
                     DECODE(B.ISLOCAL, '0', '否', '1', '是', '') ISLOCAL,
                     ''
                FROM TF_B_REFUND T, TD_M_BANK B
               WHERE T.BANKCODE = B.BANKCODE(+)
                 AND T.BANKCODE != '0000' --排除无开户行的数据
                 AND (P_VAR1 IS NULL OR P_VAR1 = '' OR
                     TO_CHAR(T.OPERATETIME, 'YYYYMMDD') >= P_VAR1)
                 AND (P_VAR2 IS NULL OR P_VAR2 = '' OR
                     TO_CHAR(T.OPERATETIME, 'YYYYMMDD') <= P_VAR2)
               ORDER BY T.OPERATETIME, B.BANK, T.CUSTNAME) C;
  elsif p_funcCode = 'REFUND_COMPARE_REPORT' then
    -- 操作员退款对帐
    open p_cursor for
      select a.OPERATEDATE 退款日期,
             b.STAFFNAME 操作员,
             '充值' 退款类型,
             a.CARDDEPOSITFEE / 100.0 金额
        from TF_F_TRADEFEE_COLLECT a, TD_M_INSIDESTAFF b
       where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
         and (a.TRADETYPECODE = '05' OR a.TRADETYPECODE = '06')
         and a.OPERATESTAFFNO = p_var3
         and p_var3 = b.STAFFNO
      union
      select a.OPERATEDATE 退款日期,
             b.STAFFNAME 操作员,
             '押金' 退款类型,
             a.SUPPLYMONEY / 100.0 金额
        from TF_F_TRADEFEE_COLLECT a, TD_M_INSIDESTAFF b
       where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
         and (a.TRADETYPECODE = '05' OR a.TRADETYPECODE = '06')
         and a.OPERATESTAFFNO = p_var3
         and p_var3 = b.STAFFNO
      union
      select a.OPERATEDATE 退款日期,
             b.STAFFNAME 操作员,
             '其它' 退款类型,
             a.SUPPLYMONEY / 100.0 金额
        from TF_F_TRADEFEE_COLLECT a, TD_M_INSIDESTAFF b
       where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
         and (a.TRADETYPECODE = '05' OR a.TRADETYPECODE = '06')
         and a.OPERATESTAFFNO = p_var3
         and p_var3 = b.STAFFNO;
  
    select 'TKDZ' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    insert into TF_OPERREFUND_SERIALNO_DETAIL
      select p_var9, a.OPERATEDATE, b.STAFFNAME, '充值', a.CARDDEPOSITFEE
        from TF_F_TRADEFEE_COLLECT a, TD_M_INSIDESTAFF b
       where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
         and (a.TRADETYPECODE = '05' OR a.TRADETYPECODE = '06')
         and a.OPERATESTAFFNO = p_var3
         and p_var3 = b.STAFFNO
      union
      select p_var9, a.OPERATEDATE, b.STAFFNAME, '押金', a.SUPPLYMONEY
        from TF_F_TRADEFEE_COLLECT a, TD_M_INSIDESTAFF b
       where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
         and (a.TRADETYPECODE = '05' OR a.TRADETYPECODE = '06')
         and a.OPERATESTAFFNO = p_var3
         and p_var3 = b.STAFFNO
      union
      select p_var9, a.OPERATEDATE, b.STAFFNAME, '其它', a.SUPPLYMONEY
        from TF_F_TRADEFEE_COLLECT a, TD_M_INSIDESTAFF b
       where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
         and (a.TRADETYPECODE = '05' OR a.TRADETYPECODE = '06')
         and a.OPERATESTAFFNO = p_var3
         and p_var3 = b.STAFFNO;
    commit;
  
  elsif p_funcCode = 'SUPPLY_INCOME_REPORT' then
    -- 代理充值对帐（原）
    if p_var7 = '00000000' then
      open p_cursor for
        select a.TRADEDATE 充值日期,
               b.BALUNIT 代理充值点,
               sum(a.TRADEMONEY) / 100.0 总金额
          from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
           and a.tradetypecode = '02'
           and substr(a.BALUNITNO, 1, 2) <> '0D'
           and a.BALUNITNO = b.BALUNITNO
         group by a.TRADEDATE, b.BALUNIT
        union
        select a.TRADEDATE 充值日期,
               b.BALUNIT 代理充值点,
               sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 总金额
          from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
           and a.tradetypecode = '02'
           and substr(a.BALUNITNO, 1, 2) = '0D'
           and a.BALUNITNO = b.BALUNITNO
         group by a.TRADEDATE, b.BALUNIT;
    else
      open p_cursor for
        select a.TRADEDATE 充值日期,
               b.BALUNIT 代理充值点,
               sum(a.TRADEMONEY) / 100.0 总金额
          from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
           and a.tradetypecode = '02'
           and a.BALUNITNO = p_var7
           and substr(a.BALUNITNO, 1, 2) <> '0D'
           and a.BALUNITNO = b.BALUNITNO
         group by a.TRADEDATE, b.BALUNIT
        union
        select a.TRADEDATE 充值日期,
               b.BALUNIT 代理充值点,
               sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 总金额
          from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
           and a.tradetypecode = '02'
           and a.BALUNITNO = p_var7
           and substr(a.BALUNITNO, 1, 2) = '0D'
           and a.BALUNITNO = b.BALUNITNO
         group by a.TRADEDATE, b.BALUNIT;
    end if;
  
    select 'DCDZ' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    if p_var7 = '00000000' then
      insert into TF_SUPPLY_SERIALNO_DETAIL
        select p_var9, a.TRADEDATE, b.BALUNIT, sum(a.TRADEMONEY)
          from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
           and a.tradetypecode = '02'
           and substr(a.BALUNITNO, 1, 2) <> '0D'
           and a.BALUNITNO = b.BALUNITNO
         group by a.TRADEDATE, b.BALUNIT
        union
        select p_var9,
               a.TRADEDATE,
               b.BALUNIT,
               sum(a.TRADEMONEY) * (1 - 0.007)
          from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
           and a.tradetypecode = '02'
           and substr(a.BALUNITNO, 1, 2) = '0D'
           and a.BALUNITNO = b.BALUNITNO
         group by a.TRADEDATE, b.BALUNIT;
    else
      insert into TF_SUPPLY_SERIALNO_DETAIL
        select p_var9, a.TRADEDATE, b.BALUNIT, sum(a.TRADEMONEY)
          from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
           and a.tradetypecode = '02'
           and a.BALUNITNO = p_var7
           and substr(a.BALUNITNO, 1, 2) <> '0D'
           and a.BALUNITNO = b.BALUNITNO
         group by a.TRADEDATE, b.BALUNIT
        union
        select p_var9,
               a.TRADEDATE,
               b.BALUNIT,
               sum(a.TRADEMONEY) * (1 - 0.007)
          from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
           and a.tradetypecode = '02'
           and a.BALUNITNO = p_var7
           and substr(a.BALUNITNO, 1, 2) = '0D'
           and a.BALUNITNO = b.BALUNITNO
         group by a.TRADEDATE, b.BALUNIT;
    end if;
    commit;
  
  elsif p_funcCode = 'GROUP_INCOME_REPORT' then
    -- 企服卡帐户充值对帐
    open p_cursor for
      select to_char(a.EXAMTIME, 'yyyymmdd') 充值日期,
             b.CORPname 单位,
             c.departname 部门,
             sum(a.SUPPLYMONEY) / 100.0 金额
        from TF_F_SUPPLYSUM a, TD_GROUP_customer b, TD_M_INSIDEDEPART c
       where (p_var1 is null or p_var1 = '' or
             to_char(a.EXAMTIME, 'yyyymmdd') >= p_var1)
         and (p_var2 is null or p_var2 = '' or
             to_char(a.EXAMTIME, 'yyyymmdd') <= p_var2)
         and (p_var3 is null or p_var3 = '' or a.supplydepartno = p_var3)
         and a.STATECODE = '2'
         and a.CORPNO = b.CORPcode
         and a.supplydepartno = c.departno
       group by to_char(a.EXAMTIME, 'yyyymmdd'), b.CORPname, c.departname
       order by to_char(a.EXAMTIME, 'yyyymmdd');
  
    select 'QCDZ' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    insert into TF_GROUP_SERIALNO_DETAIL
      select p_var9,
             to_char(a.EXAMTIME, 'yyyymmdd'),
             b.CORPname,
             sum(a.SUPPLYMONEY)
        from TF_F_SUPPLYSUM a, TD_GROUP_customer b
       where (p_var1 is null or p_var1 = '' or
             to_char(a.EXAMTIME, 'yyyymmdd') >= p_var1)
         and (p_var2 is null or p_var2 = '' or
             to_char(a.EXAMTIME, 'yyyymmdd') <= p_var2)
         and a.STATECODE = '2'
         and a.CORPNO = b.CORPcode
       group by to_char(a.EXAMTIME, 'yyyymmdd'), b.CORPname
       order by to_char(a.EXAMTIME, 'yyyymmdd');
    commit;
  
  elsif p_funcCode = 'XFC_BATCH_REPORT' then
    -- 充值卡总部直销对帐
    /*open p_cursor for
    
    select CUSTNAME 购卡单位,CARDVALUE/100.0 卡面单价,TOTALMONEY/100.0 购卡金额,to_char(OPERATETIME,'yyyymmdd') 购卡日期,to_char(PAYTIME,'yyyymmdd') 到帐日期,'3' 购卡款状态
      from TF_XFC_BATCHSELL
     where PAYTIME is null
       and ( p_var1 is null or p_var1 = '' or to_char(OPERATETIME,'yyyymmdd') >= p_var1)
       and ( p_var2 is null or p_var2 = '' or to_char(OPERATETIME,'yyyymmdd') <= p_var2)
       and ( p_var3 is null or p_var3 = '' or STAFFNO IN (SELECT B.STAFFNO FROM TD_M_INSIDESTAFF B WHERE B.DEPARTNO=P_VAR3))
    union
    select CUSTNAME 购卡单位,CARDVALUE/100.0 卡面单价,TOTALMONEY/100.0 购卡金额,to_char(OPERATETIME,'yyyymmdd') 购卡日期,to_char(PAYTIME,'yyyymmdd') 到帐日期,'1' 购卡款状态
      from TF_XFC_BATCHSELL
     where PAYTIME is not null
       and ( p_var1 is null or p_var1 = '' or to_char(OPERATETIME,'yyyymmdd') >= p_var1)
       and ( p_var2 is null or p_var2 = '' or to_char(OPERATETIME,'yyyymmdd') <= p_var2)
       and ( p_var3 is null or p_var3 = '' or STAFFNO IN (SELECT B.STAFFNO FROM TD_M_INSIDESTAFF B WHERE B.DEPARTNO=P_VAR3))
       and to_char(OPERATETIME,'yyyymmdd')=to_char(PAYTIME,'yyyymmdd')
    union
    select CUSTNAME 购卡单位,CARDVALUE/100.0 卡面单价,TOTALMONEY/100.0 购卡金额,to_char(OPERATETIME,'yyyymmdd') 购卡日期,to_char(PAYTIME,'yyyymmdd') 到帐日期,'2' 购卡款状态
      from TF_XFC_BATCHSELL
     where PAYTIME is not null
       and ( p_var1 is null or p_var1 = '' or to_char(OPERATETIME,'yyyymmdd') >= p_var1)
       and ( p_var2 is null or p_var2 = '' or to_char(OPERATETIME,'yyyymmdd') <= p_var2)
       and ( p_var3 is null or p_var3 = '' or STAFFNO IN (SELECT B.STAFFNO FROM TD_M_INSIDESTAFF B WHERE B.DEPARTNO=P_VAR3))
       and to_char(OPERATETIME,'yyyymmdd')<>to_char(PAYTIME,'yyyymmdd');*/
  
    select 'CZDZ' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    insert into TF_XFC_SERIALNO_DETAIL
      select p_var9,
             CUSTNAME,
             CARDVALUE,
             TOTALMONEY,
             to_char(OPERATETIME, 'yyyymmdd'),
             to_char(PAYTIME, 'yyyymmdd'),
             '3'
        from TF_XFC_BATCHSELL
       where PAYTIME is null
         and (p_var1 is null or p_var1 = '' or
             to_char(OPERATETIME, 'yyyymmdd') >= p_var1)
         and (p_var2 is null or p_var2 = '' or
             to_char(OPERATETIME, 'yyyymmdd') <= p_var2)
         and (p_var3 is null or p_var3 = '' or
             STAFFNO IN (SELECT B.STAFFNO
                            FROM TD_M_INSIDESTAFF B
                           WHERE B.DEPARTNO = P_VAR3));
  
    insert into TF_XFC_SERIALNO_DETAIL
      select p_var9,
             CUSTNAME,
             CARDVALUE,
             TOTALMONEY,
             to_char(OPERATETIME, 'yyyymmdd'),
             to_char(PAYTIME, 'yyyymmdd'),
             '1'
        from TF_XFC_BATCHSELL
       where PAYTIME is not null
         and (p_var1 is null or p_var1 = '' or
             to_char(OPERATETIME, 'yyyymmdd') >= p_var1)
         and (p_var2 is null or p_var2 = '' or
             to_char(OPERATETIME, 'yyyymmdd') <= p_var2)
         and to_char(OPERATETIME, 'yyyymmdd') =
             to_char(PAYTIME, 'yyyymmdd')
         and (p_var3 is null or p_var3 = '' or
             STAFFNO IN (SELECT B.STAFFNO
                            FROM TD_M_INSIDESTAFF B
                           WHERE B.DEPARTNO = P_VAR3));
  
    insert into TF_XFC_SERIALNO_DETAIL
      select p_var9,
             CUSTNAME,
             CARDVALUE,
             TOTALMONEY,
             to_char(OPERATETIME, 'yyyymmdd'),
             to_char(PAYTIME, 'yyyymmdd'),
             '2'
        from TF_XFC_BATCHSELL
       where PAYTIME is not null
         and (p_var1 is null or p_var1 = '' or
             to_char(OPERATETIME, 'yyyymmdd') >= p_var1)
         and (p_var2 is null or p_var2 = '' or
             to_char(OPERATETIME, 'yyyymmdd') <= p_var2)
         and (p_var3 is null or p_var3 = '' or
             STAFFNO IN (SELECT B.STAFFNO
                            FROM TD_M_INSIDESTAFF B
                           WHERE B.DEPARTNO = P_VAR3))
         and to_char(OPERATETIME, 'yyyymmdd') <>
             to_char(PAYTIME, 'yyyymmdd');
  
    open p_cursor for
    /*select CUSTNAME 购卡单位,CARDVALUE/100.0 卡面单价,TOTALMONEY/100.0 购卡金额,BUYTIME 购卡日期,PAYTIME 到帐日期,
         decode(PAYTAG, '1', '当天到帐', '2', '历史到帐','3','未到帐') 购卡款状态
           from TF_XFC_SERIALNO_DETAIL
          where FIANCE_SERIALNO=p_var9
       order by BUYTIME,PAYTIME;
              commit;*/
      select A.CUSTNAME 购卡单位,
             N.DEPARTNAME 制卡部门,
             A.CARDVALUE / 100.0 卡面单价,
             A.TOTALMONEY / 100.0 购卡金额,
             to_char(A.OPERATETIME, 'yyyymmdd') 购卡日期,
             to_char(A.PAYTIME, 'yyyymmdd') 到帐日期,
             '未到帐' 购卡款状态
        from TF_XFC_BATCHSELL A, td_m_insidestaff M, TD_M_INSIDEDEPART N
       where PAYTIME is null
         AND A.STAFFNO = M.STAFFNO(+)
         AND M.DEPARTNO = N.DEPARTNO(+)
         and (p_var1 is null or p_var1 = '' or
             to_char(A.OPERATETIME, 'yyyymmdd') >= p_var1)
         and (p_var2 is null or p_var2 = '' or
             to_char(A.OPERATETIME, 'yyyymmdd') <= p_var2)
         and (p_var3 is null or p_var3 = '' or
             A.STAFFNO IN (SELECT B.STAFFNO
                              FROM TD_M_INSIDESTAFF B
                             WHERE B.DEPARTNO = P_VAR3))
      union all
      select A.CUSTNAME 购卡单位,
             N.DEPARTNAME 制卡部门,
             A.CARDVALUE / 100.0 卡面单价,
             A.TOTALMONEY / 100.0 购卡金额,
             to_char(A.OPERATETIME, 'yyyymmdd') 购卡日期,
             to_char(A.PAYTIME, 'yyyymmdd') 到帐日期,
             '当天到帐' 购卡款状态
        from TF_XFC_BATCHSELL A, td_m_insidestaff M, TD_M_INSIDEDEPART N
       where PAYTIME is not null
         AND A.STAFFNO = M.STAFFNO(+)
         AND M.DEPARTNO = N.DEPARTNO(+)
         and (p_var1 is null or p_var1 = '' or
             to_char(A.OPERATETIME, 'yyyymmdd') >= p_var1)
         and (p_var2 is null or p_var2 = '' or
             to_char(A.OPERATETIME, 'yyyymmdd') <= p_var2)
         and to_char(A.OPERATETIME, 'yyyymmdd') =
             to_char(A.PAYTIME, 'yyyymmdd')
         and (p_var3 is null or p_var3 = '' or
             A.STAFFNO IN (SELECT B.STAFFNO
                              FROM TD_M_INSIDESTAFF B
                             WHERE B.DEPARTNO = P_VAR3))
      union all
      select A.CUSTNAME 购卡单位,
             N.DEPARTNAME 制卡部门,
             A.CARDVALUE / 100.0 卡面单价,
             A.TOTALMONEY / 100.0 购卡金额,
             to_char(A.OPERATETIME, 'yyyymmdd') 购卡日期,
             to_char(A.PAYTIME, 'yyyymmdd') 到帐日期,
             '历史到帐' 购卡款状态
        from TF_XFC_BATCHSELL A, td_m_insidestaff M, TD_M_INSIDEDEPART N
       where PAYTIME is not null
         AND A.STAFFNO = M.STAFFNO(+)
         AND M.DEPARTNO = N.DEPARTNO(+)
         and (p_var1 is null or p_var1 = '' or
             to_char(A.OPERATETIME, 'yyyymmdd') >= p_var1)
         and (p_var2 is null or p_var2 = '' or
             to_char(A.OPERATETIME, 'yyyymmdd') <= p_var2)
         and (p_var3 is null or p_var3 = '' or
             A.STAFFNO IN (SELECT B.STAFFNO
                              FROM TD_M_INSIDESTAFF B
                             WHERE B.DEPARTNO = P_VAR3))
         and to_char(A.OPERATETIME, 'yyyymmdd') <>
             to_char(A.PAYTIME, 'yyyymmdd')
       order by 购卡日期, 到帐日期;
    commit;
  
  elsif p_funcCode = 'LIJININCOME__RENEW_REPORT' then
    -- 利金卡转收入统计
    select 'LJDZ' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    insert into TF_LIJININCOME_SERIALNO_DETAIL
      select p_var9,
             to_date(to_char(INCOMEDATE, 'yyyymmdd'), 'yyyyMMdd'),
             INCOMETYPE,
             sum(DEPOSIT + CARDMONEY),
             count(cardno)
        from TF_B_LIJININCOME
       where to_char(INCOMEDATE, 'yyyymm') = p_var1
         and DEPOSIT + CARDMONEY > 0
       group by to_date(to_char(INCOMEDATE, 'yyyymmdd'), 'yyyyMMdd'),
                INCOMETYPE;
  
    open p_cursor for
      select INCOMEDATE 转收入日期,
             MONEY / 100.0 金额,
             CARDCOUNT 卡张数,
             decode(INCOMETYPE, '01', '过期转收入', '02', '回收转收入') 转收入类型
        from TF_LIJININCOME_SERIALNO_DETAIL
       where FIANCE_SERIALNO = p_var9;
    commit;
  
  elsif p_funcCode = 'SERVICE_INCOME_REPORT' then
    -- 客服售充对帐
    if p_var7 = '00000000' then
      open p_cursor for
        select to_char(a.beginTIME, 'yyyymmdd') 交易日期,
               b.BALUNIT 客服网点,
               '押金' 费用类型,
               a.TRANSFEE / 100.0 金额
          from TF_SELL_INCOMEFIN a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or
               to_char(a.beginTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.beginTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
        union
        select to_char(a.OPERATETIME, 'yyyymmdd') 交易日期,
               b.staffname 客服网点,
               '充值卡售卡' 费用类型,
               sum(a.money) / 100.0 金额
          from tf_xfc_sell a, TD_M_INSIDESTAFF b
         where a.OPERATETIME >=
               to_date(p_var1 || '000000', 'yyyymmddhh24miss')
           and a.OPERATETIME <=
               to_date(p_var2 || '235959', 'yyyymmddhh24miss')
           and a.STAFFNO = b.STAFFNO
         group by to_char(a.OPERATETIME, 'yyyymmdd'), b.staffname
        union
        select a.OPERATEDATE 交易日期,
               b.STAFFNAME 客服网点,
               c.TRADETYPE 费用类型,
               sum(a.cardservfee + a.carddepositfee + a.supplymoney +
                   a.tradeprocfee + a.funcfee + a.otherfee) / 100.0 金额
          from TF_F_TRADEFEE_COLLECT a,
               TD_M_INSIDESTAFF      b,
               TD_M_TRADETYPE        c
         where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
           and a.tradetypecode <> '05'
           and a.TRADETYPECODE = c.TRADETYPECODE
           and a.OPERATESTAFFNO = b.STAFFNO
         group by a.OPERATEDATE, b.staffname, c.TRADETYPE
        union
        select a.OPERATEDATE 交易日期,
               b.STAFFNAME 客服网点,
               '退押金' 费用类型,
               sum(a.carddepositfee) / 100.0 金额
          from TF_F_TRADEFEE_COLLECT a,
               TD_M_INSIDESTAFF      b,
               TD_M_TRADETYPE        c
         where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
           and a.tradetypecode = '05'
           and a.TRADETYPECODE = c.TRADETYPECODE
           and a.OPERATESTAFFNO = b.STAFFNO
         group by a.OPERATEDATE, b.staffname
        union
        select a.OPERATEDATE 交易日期,
               b.STAFFNAME 客服网点,
               '退充值' 费用类型,
               sum(a.supplymoney) / 100.0 金额
          from TF_F_TRADEFEE_COLLECT a,
               TD_M_INSIDESTAFF      b,
               TD_M_TRADETYPE        c
         where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
           and a.tradetypecode = '05'
           and a.TRADETYPECODE = c.TRADETYPECODE
           and a.OPERATESTAFFNO = b.STAFFNO
         group by a.OPERATEDATE, b.staffname
         order by 1, 2, 3;
    else
      open p_cursor for
        select to_char(a.beginTIME, 'yyyymmdd') 交易日期,
               b.BALUNIT 客服网点,
               '押金' 费用类型,
               a.TRANSFEE / 100.0 金额
          from TF_SELL_INCOMEFIN a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.ENDTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = p_var7
           and a.BALUNITNO = b.BALUNITNO
         order by to_char(a.beginTIME, 'yyyymmdd');
    end if;
  
    select 'KFDZ' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    if p_var7 = '00000000' then
      insert into TF_SERVICE_SERIALNO_DETAIL
        select p_var9,
               to_char(a.beginTIME, 'yyyymmdd'),
               b.BALUNIT,
               '押金',
               a.TRANSFEE
          from TF_SELL_INCOMEFIN a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or
               to_char(a.beginTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.beginTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
        union
        select p_var9,
               to_char(a.OPERATETIME, 'yyyymmdd'),
               b.staffname,
               '充值卡售卡',
               sum(a.money)
          from tf_xfc_sell a, TD_M_INSIDESTAFF b
         where a.OPERATETIME >=
               to_date(p_var1 || '000000', 'yyyymmddhh24miss')
           and a.OPERATETIME <=
               to_date(p_var2 || '235959', 'yyyymmddhh24miss')
           and a.STAFFNO = b.STAFFNO
         group by to_char(a.OPERATETIME, 'yyyymmdd'), b.staffname
        union
        select p_var9,
               a.OPERATEDATE,
               b.STAFFNAME,
               c.TRADETYPE,
               sum(a.cardservfee + a.carddepositfee + a.supplymoney +
                   a.tradeprocfee + a.funcfee + a.otherfee)
          from TF_F_TRADEFEE_COLLECT a,
               TD_M_INSIDESTAFF      b,
               TD_M_TRADETYPE        c
         where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
           and a.tradetypecode <> '05'
           and a.TRADETYPECODE = c.TRADETYPECODE
           and a.OPERATESTAFFNO = b.STAFFNO
         group by a.OPERATEDATE, b.staffname, c.TRADETYPE
        union
        select p_var9,
               a.OPERATEDATE,
               b.STAFFNAME,
               '退押金',
               sum(a.carddepositfee)
          from TF_F_TRADEFEE_COLLECT a,
               TD_M_INSIDESTAFF      b,
               TD_M_TRADETYPE        c
         where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
           and a.tradetypecode = '05'
           and a.TRADETYPECODE = c.TRADETYPECODE
           and a.OPERATESTAFFNO = b.STAFFNO
         group by a.OPERATEDATE, b.staffname
        union
        select p_var9,
               a.OPERATEDATE,
               b.STAFFNAME,
               '退充值',
               sum(a.supplymoney)
          from TF_F_TRADEFEE_COLLECT a,
               TD_M_INSIDESTAFF      b,
               TD_M_TRADETYPE        c
         where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
           and a.tradetypecode = '05'
           and a.TRADETYPECODE = c.TRADETYPECODE
           and a.OPERATESTAFFNO = b.STAFFNO
         group by a.OPERATEDATE, b.staffname
         order by 1, 2, 3;
    else
      insert into TF_SERVICE_SERIALNO_DETAIL
        select p_var9,
               to_char(a.beginTIME, 'yyyymmdd'),
               b.BALUNIT,
               '押金',
               a.TRANSFEE
          from TF_SELL_INCOMEFIN a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or
               to_char(a.beginTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.beginTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = p_var7
           and a.BALUNITNO = b.BALUNITNO
         order by to_char(a.beginTIME, 'yyyymmdd');
    end if;
    commit;
  
  elsif p_funcCode = 'TF_BUSRENEW_MONTHLY' then
    -- 公交回收转帐月报
    open p_cursor for
      select c.BANK 开户行,
             substr(a.BALUNITNO, 5, 4) 商户代码,
             b.BALUNIT 商户名称,
             b.bankaccno 银行账号,
             sum(a.TRANSFEE) / 100.0 转帐金额,
             sum(a.COMFEE) / 100.0 佣金
        from TF_BUSRENEW_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
       where (p_var1 is null or p_var1 = '' or
             to_char(a.BEGINTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
         and (p_var2 is null or p_var2 = '' or
             to_char(a.BEGINTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
         and a.BALUNITNO = b.BALUNITNO
         and b.BANKCODE = c.BANKCODE
       group by c.BANK, substr(a.BALUNITNO, 5, 4), b.BALUNIT, b.bankaccno;
  
    select 'GJHS' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    insert into TF_TRADEOC_SERIALNO_DETAIL
      select p_var9,
             c.BANK,
             substr(a.BALUNITNO, 5, 4),
             b.BALUNIT,
             sum(a.TRANSFEE),
             sum(a.COMFEE)
        from TF_BUSRENEW_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
       where (p_var1 is null or p_var1 = '' or
             to_char(a.BEGINTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
         and (p_var2 is null or p_var2 = '' or
             to_char(a.BEGINTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
         and a.BALUNITNO = b.BALUNITNO
         and a.FINBANKCODE = c.BANKCODE
       group by c.BANK, substr(a.BALUNITNO, 5, 4), b.BALUNIT;
    commit;
  
  elsif p_funcCode = 'TF_BUS_TEST_MONTHLY' then
    -- 公交测试卡费用月报
    open p_cursor for
      select c.BANK 开户行,
             substr(a.BALUNITNO, 5, 4) 商户代码,
             b.BALUNIT 商户名称,
             b.bankaccno 银行账号,
             sum(a.TRANSFEE) / 100.0 测试卡费用
        from TF_BUSRENEW_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
       where (p_var1 is null or p_var1 = '' or
             to_char(a.BEGINTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
         and (p_var2 is null or p_var2 = '' or
             to_char(a.BEGINTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
         and a.BALUNITNO = b.BALUNITNO
         and b.BANKCODE = c.BANKCODE
         and a.ERRORREASONCODE = 'C'
       group by c.BANK, substr(a.BALUNITNO, 5, 4), b.BALUNIT, b.bankaccno;
  
    select 'GJCS' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    insert into TF_TRADEOC_SERIALNO_DETAIL
      select p_var9,
             c.BANK,
             substr(a.BALUNITNO, 5, 4),
             b.BALUNIT,
             sum(a.TRANSFEE),
             NULL
        from TF_BUSRENEW_OUTCOMEFIN a, TF_TRADE_BALUNIT b, TD_M_BANK c
       where (p_var1 is null or p_var1 = '' or
             to_char(a.BEGINTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
         and (p_var2 is null or p_var2 = '' or
             to_char(a.BEGINTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
         and a.BALUNITNO = b.BALUNITNO
         and a.FINBANKCODE = c.BANKCODE
         and a.ERRORREASONCODE = 'C'
       group by c.BANK, substr(a.BALUNITNO, 5, 4), b.BALUNIT;
    commit;
  
  elsif p_funcCode = 'COM_MONTHLY_REPORT' then
    -- 信息亭佣金月报
    open p_cursor for
      select '笔数<=5,金额>=100' 佣金类型,
             sum(times) 总笔数,
             sum(times) * 1.0 佣金金额
        from (select count(*) times, cardno, samno
                from tq_supply_right
               where tradetypecode = '02'
                 and substr(balunitno, 1, 2) = '0C'
                 and trademoney >= 10000
                 and (p_var1 is null or p_var1 = '' or tradedate >= p_var1)
                 and (p_var2 is null or p_var2 = '' or tradedate <= p_var2)
               group by cardno, samno)
       where times <= 5
      union
      select '笔数<=5,金额<100' 佣金类型,
             sum(times) 总笔数,
             sum(money) / 10000.0 佣金金额
        from (select count(*) times, sum(trademoney) money, cardno, samno
                from tq_supply_right
               where tradetypecode = '02'
                 and substr(balunitno, 1, 2) = '0C'
                 and trademoney < 10000
                 and (p_var1 is null or p_var1 = '' or tradedate >= p_var1)
                 and (p_var2 is null or p_var2 = '' or tradedate <= p_var2)
               group by cardno, samno)
       where times <= 5
      union
      select '笔数>5,(充值金额/100)>5' 佣金类型,
             count(*) 总笔数,
             count(*) * 5.0 佣金金额
        from (select cardno, samno, sum(trademoney) / 10000.0 money
                from TQ_SUPPLY_RIGHT
               where substr(BALUNITNO, 1, 2) = '0C'
                 and (cardno, samno) in
                     (select cardno, samno
                        from (select count(*) times, cardno, samno
                                from tq_supply_right
                               where tradetypecode = '02'
                                 and substr(balunitno, 1, 2) = '0C'
                                 and (p_var1 is null or p_var1 = '' or
                                     tradedate >= p_var1)
                                 and (p_var2 is null or p_var2 = '' or
                                     tradedate <= p_var2)
                               group by cardno, samno)
                       where times > 5)
               group by cardno, samno)
       where money > 5
      union
      select '笔数>5,(充值金额/100)<=5' 佣金类型,
             count(*) 总笔数,
             nvl(sum(money), 0) 佣金金额
        from (select cardno, samno, sum(trademoney) / 10000.0 money
                from TQ_SUPPLY_RIGHT
               where substr(BALUNITNO, 1, 2) = '0C'
                 and (cardno, samno) in
                     (select cardno, samno
                        from (select count(*) times, cardno, samno
                                from tq_supply_right
                               where tradetypecode = '02'
                                 and substr(balunitno, 1, 2) = '0C'
                                 and (p_var1 is null or p_var1 = '' or
                                     tradedate >= p_var1)
                                 and (p_var2 is null or p_var2 = '' or
                                     tradedate <= p_var2)
                               group by cardno, samno)
                       where times > 5)
               group by cardno, samno)
       where money <= 5;
  
    select 'XXYJ' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    insert into TF_XFC_SERIALNO_DETAIL
      select p_var9,
             '笔数<=5,金额>=100',
             sum(times),
             sum(times) * 1.0,
             null,
             null,
             null
        from (select count(*) times, cardno, samno
                from tq_supply_right
               where tradetypecode = '02'
                 and substr(balunitno, 1, 2) = '0C'
                 and trademoney >= 10000
                 and (p_var1 is null or p_var1 = '' or tradedate >= p_var1)
                 and (p_var2 is null or p_var2 = '' or tradedate <= p_var2)
               group by cardno, samno)
       where times <= 5
      union
      select p_var9,
             '笔数<=5,金额<100',
             sum(times),
             sum(money) / 10000.0,
             null,
             null,
             null
        from (select count(*) times, sum(trademoney) money, cardno, samno
                from tq_supply_right
               where tradetypecode = '02'
                 and substr(balunitno, 1, 2) = '0C'
                 and trademoney < 10000
                 and (p_var1 is null or p_var1 = '' or tradedate >= p_var1)
                 and (p_var2 is null or p_var2 = '' or tradedate <= p_var2)
               group by cardno, samno)
       where times <= 5
      union
      select p_var9,
             '笔数>5,(充值金额/100)>5',
             count(*),
             count(*) * 5.0,
             null,
             null,
             null
        from (select cardno, samno, sum(trademoney) / 10000.0 money
                from TQ_SUPPLY_RIGHT
               where substr(BALUNITNO, 1, 2) = '0C'
                 and (cardno, samno) in
                     (select cardno, samno
                        from (select count(*) times, cardno, samno
                                from tq_supply_right
                               where tradetypecode = '02'
                                 and substr(balunitno, 1, 2) = '0C'
                                 and (p_var1 is null or p_var1 = '' or
                                     tradedate >= p_var1)
                                 and (p_var2 is null or p_var2 = '' or
                                     tradedate <= p_var2)
                               group by cardno, samno)
                       where times > 5)
               group by cardno, samno)
       where money > 5
      union
      select p_var9,
             '笔数>5,(充值金额/100)<=5',
             count(*),
             nvl(sum(money), 0),
             null,
             null,
             null
        from (select cardno, samno, sum(trademoney) / 10000.0 money
                from TQ_SUPPLY_RIGHT
               where substr(BALUNITNO, 1, 2) = '0C'
                 and (cardno, samno) in
                     (select cardno, samno
                        from (select count(*) times, cardno, samno
                                from tq_supply_right
                               where tradetypecode = '02'
                                 and substr(balunitno, 1, 2) = '0C'
                                 and (p_var1 is null or p_var1 = '' or
                                     tradedate >= p_var1)
                                 and (p_var2 is null or p_var2 = '' or
                                     tradedate <= p_var2)
                               group by cardno, samno)
                       where times > 5)
               group by cardno, samno)
       where money <= 5;
    commit;
  
  elsif p_funcCode = 'SELLCHANGE_MONTHLY_REPORT' then
    -- 售换卡月报
    open p_cursor for
      SELECT /*+ rule */
       B.CARDSURFACENAME 卡面名称,
       '售卡' 交易类型,
       (A.DEPOSIT + A.CARDCOST) / 100.0 交易金额,
       COUNT(*) 卡张数
        FROM TF_F_CARDREC A, TD_M_CARDSURFACE B
       WHERE (p_var1 is null or p_var1 = '' or
             to_char(A.SELLTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
         AND (p_var2 is null or p_var2 = '' or
             to_char(A.SELLTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
         AND A.CARDSTATE = '10'
         AND A.CARDSURFACECODE = B.CARDSURFACECODE
         AND A.CARDNO NOT IN
             (SELECT C.CARDNO
                FROM TF_B_TRADE C
               WHERE (C.TRADETYPECODE = '70' OR C.TRADETYPECODE = '71' OR
                     C.TRADETYPECODE = '72'))
         AND SUBSTR(A.CARDNO, 5, 4) NOT IN
             ('0403', '0404', '0406', '0407', '1601', '2101', '2201')
       GROUP BY B.CARDSURFACENAME, (A.DEPOSIT + A.CARDCOST)
      union
      SELECT /*+ rule */
       B.CARDSURFACENAME 卡面名称,
       '换卡' 交易类型,
       (A.DEPOSIT + A.CARDCOST) / 100.0 交易金额,
       COUNT(*) 卡张数
        FROM TF_F_CARDREC A, TD_M_CARDSURFACE B
       WHERE (p_var1 is null or p_var1 = '' or
             to_char(A.SELLTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
         AND (p_var2 is null or p_var2 = '' or
             to_char(A.SELLTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
         AND A.CARDSTATE = '11'
         AND A.CARDSURFACECODE = B.CARDSURFACECODE
         AND SUBSTR(A.CARDNO, 5, 4) NOT IN
             ('0403', '0404', '0406', '0407', '1601', '2101', '2201')
       GROUP BY B.CARDSURFACENAME, (A.DEPOSIT + A.CARDCOST)
      union
      SELECT /*+ rule */
       B.CARDSURFACENAME 卡面名称,
       '二次办卡' 交易类型,
       A.CURRENTMONEY / 100.0 交易金额,
       COUNT(*) 卡张数
        FROM TF_B_TRADE A, TD_M_CARDSURFACE B
       WHERE (p_var1 is null or p_var1 = '' or
             A.OPERATETIME >= to_date(p_var1, 'yyyymmdd'))
         AND (p_var2 is null or p_var2 = '' or
             A.OPERATETIME <= to_date(p_var2, 'yyyymmdd'))
         AND (A.TRADETYPECODE = '70' OR A.TRADETYPECODE = '71' OR
             A.TRADETYPECODE = '72')
         AND SUBSTR(A.CARDNO, 5, 4) = B.CARDSURFACECODE
         AND SUBSTR(A.CARDNO, 5, 4) NOT IN
             ('0403', '0404', '0406', '0407', '1601', '2101', '2201')
       GROUP BY B.CARDSURFACENAME, A.CURRENTMONEY
       ORDER BY 1, 2, 3;
  
    select 'SHYB' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    insert into TF_TRADEOC_SERIALNO_DETAIL
      SELECT /*+ rule */
       p_var9,
       B.CARDSURFACENAME,
       null,
       '售卡',
       A.DEPOSIT + A.CARDCOST,
       COUNT(*)
        FROM TF_F_CARDREC A, TD_M_CARDSURFACE B
       WHERE (p_var1 is null or p_var1 = '' or
             to_char(A.SELLTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
         AND (p_var2 is null or p_var2 = '' or
             to_char(A.SELLTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
         AND A.CARDSTATE = '10'
         AND A.CARDSURFACECODE = B.CARDSURFACECODE
         AND A.CARDNO NOT IN
             (SELECT C.CARDNO
                FROM TF_B_TRADE C
               WHERE (C.TRADETYPECODE = '70' OR C.TRADETYPECODE = '71' OR
                     C.TRADETYPECODE = '72'))
         AND SUBSTR(A.CARDNO, 5, 4) NOT IN
             ('0403', '0404', '0406', '0407', '1601', '2101', '2201')
       GROUP BY B.CARDSURFACENAME, (A.DEPOSIT + A.CARDCOST)
      union
      SELECT /*+ rule */
       p_var9,
       B.CARDSURFACENAME,
       null,
       '换卡',
       A.DEPOSIT + A.CARDCOST,
       COUNT(*)
        FROM TF_F_CARDREC A, TD_M_CARDSURFACE B
       WHERE (p_var1 is null or p_var1 = '' or
             to_char(A.SELLTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
         AND (p_var2 is null or p_var2 = '' or
             to_char(A.SELLTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
         AND A.CARDSTATE = '11'
         AND A.CARDSURFACECODE = B.CARDSURFACECODE
         AND SUBSTR(A.CARDNO, 5, 4) NOT IN
             ('0403', '0404', '0406', '0407', '1601', '2101', '2201')
       GROUP BY B.CARDSURFACENAME, (A.DEPOSIT + A.CARDCOST)
      union
      SELECT /*+ rule */
       p_var9,
       B.CARDSURFACENAME,
       null,
       '二次办卡',
       A.CURRENTMONEY,
       COUNT(*)
        FROM TF_B_TRADE A, TD_M_CARDSURFACE B
       WHERE (p_var1 is null or p_var1 = '' or
             A.OPERATETIME >= to_date(p_var1, 'yyyymmdd'))
         AND (p_var2 is null or p_var2 = '' or
             A.OPERATETIME <= to_date(p_var2, 'yyyymmdd'))
         AND (A.TRADETYPECODE = '70' OR A.TRADETYPECODE = '71' OR
             A.TRADETYPECODE = '72')
         AND SUBSTR(A.CARDNO, 5, 4) = B.CARDSURFACECODE
         AND SUBSTR(A.CARDNO, 5, 4) NOT IN
             ('0403', '0404', '0406', '0407', '1601', '2101', '2201')
       GROUP BY B.CARDSURFACENAME, A.CURRENTMONEY
       ORDER BY 1, 2, 3;
    commit;
  
  elsif p_funcCode = 'TRADE_LOG_REPORT' then
    -- 营业员日报
    open p_cursor for
      SELECT 部门,
             营业员,
             交易类型,
             SUM(操作次数) 操作次数,
             SUM(NVL(操作金额, 0)) 操作金额
        FROM (SELECT TB.DEPARTNAME 部门,
                     TB.STAFFNAME 营业员,
                     TB.TRADETYPE 交易类型,
                     COUNT(*) 操作次数,
                     SUM(TB.OPMONEY) / 100.0 操作金额
                FROM (SELECT E.DEPARTNAME,
                             nvl(D.STAFFNAME, A.OPERATESTAFFNO) STAFFNAME,
                             (B.CARDSERVFEE + B.CARDDEPOSITFEE +
                             B.SUPPLYMONEY + B.TRADEPROCFEE + B.FUNCFEE +
                             B.OTHERFEE) OPMONEY,
                             (CASE
                               WHEN C.TRADETYPE = '售卡' THEN
                                (CASE
                                  WHEN A.CARDNO NOT LIKE '215018%' AND B.CARDSERVFEE <> '0' THEN
                                   '售卡(卡费' || NVL2(B.CARDSERVFEE, B.CARDSERVFEE / 100.0, 0) || ')'
                                  WHEN A.CARDNO NOT LIKE '215018%' AND B.CARDDEPOSITFEE <> '0' THEN
                                   '售卡(押金' || NVL2(B.CARDDEPOSITFEE, B.CARDDEPOSITFEE / 100.0, 0) || ')'
                                  WHEN A.CARDNO LIKE '215018%' THEN
                                   '售卡(A卡)'
                                  ELSE
                                   '售卡(卡费' || NVL2(B.CARDSERVFEE, B.CARDSERVFEE / 100.0, 0) || ')'
                                END)
                               WHEN C.TRADETYPE = '售卡返销' THEN
                                (CASE
                                  WHEN B.CARDSERVFEE <> '0' THEN
                                   '售卡返销(卡费' || NVL2(B.CARDSERVFEE, B.CARDSERVFEE / 100.0, 0) || ')'
                                  WHEN B.CARDDEPOSITFEE <> '0' THEN
                                   '售卡返销(押金' || NVL2(B.CARDDEPOSITFEE, B.CARDDEPOSITFEE / 100.0, 0) || ')'
                                  ELSE
                                   '售卡返销(卡费' || NVL2(B.CARDSERVFEE, B.CARDSERVFEE / 100.0, 0) || ')'
                                END)
                               WHEN C.TRADETYPE = '换卡' THEN
                                (CASE
                                  WHEN A.CARDNO NOT LIKE '215018%' AND EXISTS
                                   (SELECT 1
                                          FROM TL_R_ICUSER TR
                                         WHERE TR.CARDNO = B.CARDNO
                                           AND TR.SALETYPE = '02') THEN
                                   '换卡(押金)'
                                  WHEN A.CARDNO NOT LIKE '215018%' AND
                                       (B.CARDSERVFEE + B.CARDDEPOSITFEE + B.SUPPLYMONEY + B.TRADEPROCFEE +
                                       B.FUNCFEE + B.OTHERFEE) >= 0 AND EXISTS
                                   (SELECT 1
                                          FROM TL_R_ICUSER TL
                                         WHERE TL.CARDNO = B.CARDNO
                                           AND TL.SALETYPE = '01') THEN
                                   '换卡(卡费)'
                                  WHEN A.CARDNO NOT LIKE '215018%' AND
                                       (B.CARDSERVFEE + B.CARDDEPOSITFEE + B.SUPPLYMONEY + B.TRADEPROCFEE +
                                       B.FUNCFEE + B.OTHERFEE) < 0 THEN
                                   '换卡(退还)'
                                  WHEN A.CARDNO LIKE '215018%' THEN
                                   '换卡(A卡)'
                                  ELSE
                                   '换卡(卡费)'
                                END) || decode(a.reasoncode,
                                               '12',
                                               ':可读人为损坏卡',
                                               '13',
                                               ':可读自然损坏卡',
                                               '14',
                                               ':不可读人为损坏卡',
                                               '15',
                                               ':不可读自然损坏卡',
                                               a.reasoncode)
                               WHEN C.TRADETYPE = '换卡返销' THEN
                                (CASE
                                  WHEN A.CARDNO NOT LIKE '215018%' AND EXISTS
                                   (SELECT 1
                                          FROM TL_R_ICUSER TR
                                         WHERE TR.CARDNO = B.CARDNO
                                           AND TR.SALETYPE = '02') THEN
                                   '换卡返销(押金)'
                                  WHEN A.CARDNO NOT LIKE '215018%' AND
                                       (B.CARDSERVFEE + B.CARDDEPOSITFEE + B.SUPPLYMONEY + B.TRADEPROCFEE +
                                       B.FUNCFEE + B.OTHERFEE) <= 0 AND EXISTS
                                   (SELECT 1
                                          FROM TL_R_ICUSER TL
                                         WHERE TL.CARDNO = B.CARDNO
                                           AND TL.SALETYPE = '01') THEN
                                   '换卡返销(卡费)'
                                  WHEN A.CARDNO NOT LIKE '215018%' AND
                                       (B.CARDSERVFEE + B.CARDDEPOSITFEE + B.SUPPLYMONEY + B.TRADEPROCFEE +
                                       B.FUNCFEE + B.OTHERFEE) > 0 THEN
                                   '换卡返销(退还)'
                                  WHEN A.CARDNO LIKE '215018%' THEN
                                   '换卡返销(A卡)'
                                  ELSE
                                   '换卡返销(卡费)'
                                END) || decode(a.reasoncode,
                                               '12',
                                               ':可读人为损坏卡',
                                               '13',
                                               ':可读自然损坏卡',
                                               '14',
                                               ':不可读人为损坏卡',
                                               '15',
                                               ':不可读自然损坏卡',
                                               a.reasoncode)
                               WHEN c.TRADETYPE = '市民卡换卡' THEN
                                '市民卡换卡' || decode(a.reasoncode,
                                                  '12',
                                                  ':可读人为损坏卡',
                                                  '13',
                                                  ':可读自然损坏卡',
                                                  '14',
                                                  ':不可读人为损坏卡',
                                                  '15',
                                                  ':不可读自然损坏卡',
                                                  a.reasoncode)
                               WHEN C.TRADETYPE = '销户' THEN
                                '不可读卡销户'
                               WHEN C.TRADETYPE = '充值' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '充值'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '充值(' || FUN_QUERYCHARGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '充值'
                                END)
                               WHEN C.TRADETYPE = '抹帐' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '抹帐'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '抹帐(' || FUN_QUERYCHARGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '抹帐'
                                END)
                               WHEN C.TRADETYPE = '台帐返销' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '充值'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '充值(' || FUN_QUERYCHARGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '充值'
                                END)
                               WHEN C.TRADETYPE = '惠民休闲年卡开卡' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '惠民休闲年卡开卡'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '惠民休闲年卡开卡(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '惠民休闲年卡开卡'
                                END)
                               WHEN C.TRADETYPE = '惠民休闲年卡换卡' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '惠民休闲年卡换卡'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '惠民休闲年卡换卡(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '惠民休闲年卡换卡'
                                END)
                               WHEN C.TRADETYPE = '惠民休闲年卡补写卡' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '惠民休闲年卡补写卡'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '惠民休闲年卡补写卡(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '惠民休闲年卡补写卡'
                                END)
                               WHEN C.TRADETYPE = '惠民休闲年卡开通返销' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '惠民休闲年卡开通返销'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '惠民休闲年卡开通返销(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '惠民休闲年卡开通返销'
                                END)
                               WHEN C.TRADETYPE = '惠民休闲年卡关闭' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '惠民休闲年卡关闭'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '惠民休闲年卡关闭(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '惠民休闲年卡关闭'
                                END)
                               WHEN C.TRADETYPE = '惠民亲子卡开卡' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '惠民亲子卡开卡'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '惠民亲子卡开卡(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '惠民亲子卡开卡'
                                END)
                               WHEN C.TRADETYPE = '惠民亲子卡换卡' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '惠民亲子卡换卡'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '惠民亲子卡换卡(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '惠民亲子卡换卡'
                                END)
                               WHEN C.TRADETYPE = '惠民亲子卡开卡返销' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '惠民亲子卡开卡返销'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '惠民亲子卡开卡返销(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '惠民亲子卡开卡返销'
                                END)
                               WHEN C.TRADETYPE = '月票卡开通' THEN
                                '月票卡开通' || decode(A.RSRV2,
                                                  '01',
                                                  '-学生',
                                                  '02',
                                                  '-老人',
                                                  '03',
                                                  '-高龄',
                                                  '04',
                                                  '-爱心卡',
                                                  '05',
                                                  '-劳模卡',
                                                  '06',
                                                  '-教育卡',
                                                  '07',
                                                  '-献血卡',
												  '08',
                                                  '-优抚卡',
                                                  '')
                               WHEN C.TRADETYPE = '月票卡关闭' THEN
                                '月票卡关闭' || decode(A.RSRV2,
                                                  '01',
                                                  '-学生',
                                                  '02',
                                                  '-老人',
                                                  '03',
                                                  '-高龄',
                                                  '04',
                                                  '-爱心卡',
                                                  '05',
                                                  '-劳模卡',
                                                  '06',
                                                  '-教育卡',
                                                  '07',
                                                  '-献血卡',
												  '08',
                                                  '-优抚卡',
                                                  '')
                               WHEN C.TRADETYPE = '补登充值' THEN
                                '补登充值' || decode(a.RSRV1, '01', 'APP', a.RSRV1) ||
                                decode(a.RSRV2, '01', '支付宝', '02', '微信', '04', '专有账户', a.RSRV2)
                               WHEN C.TRADETYPE = '补登充值返销' THEN
                                '补登充值返销' || decode(a.RSRV1, '01', 'APP', a.RSRV1) ||
                                decode(a.RSRV2, '01', '支付宝', '02', '微信', '04', '专有账户', a.RSRV2) --add by youyue增加补登充值业务查询
                               ELSE
                                C.TRADETYPE
                             END) AS TRADETYPE
                        FROM TF_B_TRADE A,
                             TF_B_TRADEFEE B,
                             TD_M_TRADETYPE C,
                             TD_M_INSIDESTAFF D,
                             TD_M_INSIDEDEPART E,
                             (select Regioncode
                                from td_m_insidedepart
                               where departno = p_var11) F
                       WHERE A.OPERATETIME >=
                             TO_DATE(P_VAR1 || '000000', 'YYYYMMDDHH24MISS')
                         AND A.OPERATETIME <=
                             TO_DATE(P_VAR2 || '235959', 'YYYYMMDDHH24MISS')
                         AND (P_VAR6 is null or P_VAR6 = '' or
                             (p_var6 IN ('0001', '0003') AND
                             A.CARDNO NOT LIKE '215018%' AND
                             A.TRADETYPECODE IN
                             (SELECT F.TRADETYPENO
                                  FROM TD_TRADETYPE_SHOW F
                                 WHERE F.SHOWNO = P_VAR6)) or
                             (p_var6 = '0031' AND A.CARDNO LIKE '215018%' AND
                             A.TRADETYPECODE IN ('01', 'A1')) or
                             (p_var6 = '0032' AND A.CARDNO LIKE '215018%' AND
                             A.TRADETYPECODE IN ('03', 'A3', '5C', '5E')) or
                             (p_var6 = '0002' AND
                             A.TRADETYPECODE IN ('02', '99')) or
                             (p_var6 NOT IN ('0001', '0003', '0031', '0032') AND
                             A.TRADETYPECODE IN
                             (SELECT F.TRADETYPENO
                                  FROM TD_TRADETYPE_SHOW F
                                 WHERE F.SHOWNO = P_VAR6)))
                         AND A.TRADETYPECODE = C.TRADETYPECODE
                         AND A.TRADEID = B.TRADEID(+)
                         AND (P_VAR10 is null or P_VAR10 = '' or
                             A.OPERATESTAFFNO IN
                             (SELECT D.STAFFNO
                                 FROM TD_M_INSIDESTAFF D
                                WHERE D.DEPARTNO = P_VAR10) OR
                             (P_VAR10 = '9002' AND
                             A.OPERATEDEPARTID = P_VAR10))
                         AND A.OPERATESTAFFNO = D.STAFFNO(+)
                         AND (P_VAR3 is null or P_VAR3 = '' or
                             A.OPERATESTAFFNO = P_VAR3)
                         AND E.DEPARTNO = A.OPERATEDEPARTID
                         AND NOT (A.TRADETYPECODE in ('05', 'A5') and
                              A.REASONCODE in ('11', '12', '13'))
                         AND NOT
                              (A.TRADETYPECODE = '06' AND B.TRADEID IS NULL)
                         AND (P_VAR4 IS NULL OR P_VAR4 = '' OR
                             P_VAR4 = A.REASONCODE) /*新增 BY 殷华荣*/
                         AND A.TRADETYPECODE <> '8L' --排除专有账户批量充值 新增殷华荣
                         AND (E.Regioncode IN
                             (select b.regioncode
                                 from td_m_regioncode b
                                where b.regionname =
                                      (select r.regionname
                                         from td_m_regioncode r
                                        where r.regioncode = F.REGIONCODE)) or
                             F.REGIONCODE is null)
                         AND a.TRADETYPECODE NOT in ('7H', '7I', '7K', 'K1') --add by liuhe20130913 排除旅游卡
                      ) TB
               WHERE (P_VAR7 = '1' OR (OPMONEY IS NOT NULL AND OPMONEY <> 0)) --add by youyue增加不含无金额业务
               GROUP BY TB.DEPARTNAME, TB.STAFFNAME, TB.TRADETYPE
              union all ---下面两句用于把可读卡退卡的退卡金额和销户金额分开统计 add by liuhe
              select e.departname 部门,
                     d.staffname 营业员,
                     decode(c.TRADETYPE, '退卡', '退卡', '退卡返销') 交易类型,
                     count(*) 操作次数,
                     sum(b.CARDDEPOSITFEE) / 100.0 操作金额
                FROM TF_B_TRADE a,
                     TF_B_TRADEFEE b,
                     TD_M_TRADETYPE c,
                     TD_M_INSIDESTAFF d,
                     TD_M_INSIDEDEPART e,
                     (select Regioncode
                        from td_m_insidedepart
                       where departno = p_var11) f
               WHERE a.OPERATETIME >=
                     to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                 and a.OPERATETIME <=
                     to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                 AND (P_VAR6 is null or P_VAR6 = '' or
                     A.TRADETYPECODE IN
                     (SELECT F.TRADETYPENO
                         FROM TD_TRADETYPE_SHOW F
                        WHERE F.SHOWNO = P_VAR6))
                 and a.TRADETYPECODE = c.TRADETYPECODE
                 AND a.TRADEID = b.TRADEID(+)
                 AND (P_VAR10 is null or P_VAR10 = '' or
                     A.OPERATESTAFFNO IN
                     (SELECT D.STAFFNO
                         FROM TD_M_INSIDESTAFF D
                        WHERE D.DEPARTNO = P_VAR10) OR
                     (P_VAR10 = '9002' AND A.OPERATEDEPARTID = P_VAR10))
                 AND e.DEPARTNO = a.OPERATEDEPARTID
                 AND a.OPERATESTAFFNO = d.STAFFNO(+)
                 AND (P_VAR3 is null or P_VAR3 = '' or
                     A.OPERATESTAFFNO = P_VAR3)
                 AND ((a.TRADETYPECODE = '05' AND
                     a.REASONCODE in ('11', '12', '13')) OR
                     a.TRADETYPECODE = 'A5')
                 AND (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = A.REASONCODE) /*新增 BY 殷华荣*/
                 AND (E.Regioncode IN
                     (select b.regioncode
                         from td_m_regioncode b
                        where b.regionname =
                              (select r.regionname
                                 from td_m_regioncode r
                                where r.regioncode = F.REGIONCODE)) or
                     F.REGIONCODE is null)
                 AND (P_VAR7 = '1' OR (b.CARDDEPOSITFEE IS NOT NULL AND
                     b.CARDDEPOSITFEE <> 0)) --add by youyue增加不含无金额业务
               group by e.departname, d.staffname, c.TRADETYPE
              union all --销户
              select e.departname 部门,
                     d.staffname 营业员,
                     decode(c.TRADETYPE,
                            '退卡',
                            '可读卡销户',
                            '可读卡销户返销') 交易类型,
                     count(*) 操作次数,
                     sum(b.SUPPLYMONEY + b.TRADEPROCFEE + b.FUNCFEE +
                         b.OTHERFEE) / 100.0 操作金额
                FROM TF_B_TRADE a,
                     TF_B_TRADEFEE b,
                     TD_M_TRADETYPE c,
                     TD_M_INSIDESTAFF d,
                     TD_M_INSIDEDEPART e,
                     (select Regioncode
                        from td_m_insidedepart
                       where departno = p_var11) F
               WHERE a.OPERATETIME >=
                     to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                 and a.OPERATETIME <=
                     to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                 and a.TRADETYPECODE = c.TRADETYPECODE
                 AND a.TRADEID = b.TRADEID(+)
                 AND (P_VAR10 is null or P_VAR10 = '' or
                     A.OPERATESTAFFNO IN
                     (SELECT D.STAFFNO
                         FROM TD_M_INSIDESTAFF D
                        WHERE D.DEPARTNO = P_VAR10) OR
                     (P_VAR10 = '9002' AND A.OPERATEDEPARTID = P_VAR10))
                 AND e.DEPARTNO = a.OPERATEDEPARTID
                 AND a.OPERATESTAFFNO = d.STAFFNO
                 AND (P_VAR3 is null or P_VAR3 = '' or
                     A.OPERATESTAFFNO = P_VAR3)
                 AND ((a.TRADETYPECODE = '05' AND
                     a.REASONCODE in ('11', '12', '13')) OR
                     a.TRADETYPECODE = 'A5')
                 AND (P_VAR6 is null or P_VAR6 = '' or P_VAR6 = '0006')
                 AND (E.Regioncode IN
                     (select b.regioncode
                         from td_m_regioncode b
                        where b.regionname =
                              (select r.regionname
                                 from td_m_regioncode r
                                where r.regioncode = F.REGIONCODE)) or
                     F.REGIONCODE is null)
                 AND (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = A.REASONCODE) /*新增 BY 殷华荣*/
                 AND (P_VAR7 = '1' OR
                     ((b.SUPPLYMONEY IS NOT NULL AND b.SUPPLYMONEY <> 0) OR
                     (b.TRADEPROCFEE IS NOT NULL AND b.TRADEPROCFEE <> 0) OR
                     (b.FUNCFEE IS NOT NULL AND b.FUNCFEE <> 0) OR
                     (b.OTHERFEE IS NOT NULL AND b.OTHERFEE <> 0))) --add by youyue增加不含无金额业务
               group by e.departname, d.staffname, c.TRADETYPE
              ------------旅游卡
              union all
              select e.departname 部门,
                     d.staffname 营业员,
                     c.TRADETYPE || '(押金)' 交易类型,
                     count(*) 操作次数,
                     sum(b.CARDDEPOSITFEE) / 100.0 操作金额
                FROM TF_B_TRADE a,
                     TF_B_TRADEFEE b,
                     TD_M_TRADETYPE c,
                     TD_M_INSIDESTAFF d,
                     TD_M_INSIDEDEPART e,
                     (select Regioncode
                        from td_m_insidedepart
                       where departno = p_var11) F
               WHERE a.OPERATETIME >=
                     to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                 and a.OPERATETIME <=
                     to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                 and a.TRADETYPECODE = c.TRADETYPECODE
                 AND a.TRADEID = b.TRADEID(+)
                 AND (P_VAR10 is null or P_VAR10 = '' or
                     A.OPERATESTAFFNO IN
                     (SELECT D.STAFFNO
                         FROM TD_M_INSIDESTAFF D
                        WHERE D.DEPARTNO = P_VAR10) OR
                     (P_VAR10 = '9002' AND A.OPERATEDEPARTID = P_VAR10))
                 AND e.DEPARTNO = a.OPERATEDEPARTID
                 AND a.OPERATESTAFFNO = d.STAFFNO
                 AND (P_VAR3 is null or P_VAR3 = '' or
                     A.OPERATESTAFFNO = P_VAR3)
                 AND a.TRADETYPECODE in ('7H', '7I', '7K', 'K1')
                 AND b.carddepositfee is not null
                 AND (P_VAR6 is null or P_VAR6 = '' or
                     A.TRADETYPECODE IN
                     (SELECT F.TRADETYPENO
                         FROM TD_TRADETYPE_SHOW F
                        WHERE F.SHOWNO = P_VAR6))
                 AND (E.Regioncode IN
                     (select b.regioncode
                         from td_m_regioncode b
                        where b.regionname =
                              (select r.regionname
                                 from td_m_regioncode r
                                where r.regioncode = F.REGIONCODE)) or
                     F.REGIONCODE is null)
                 AND (P_VAR7 = '1' OR (b.CARDDEPOSITFEE IS NOT NULL AND
                     b.CARDDEPOSITFEE <> 0)) --add by youyue增加不含无金额业务
               group by e.departname, d.staffname, c.TRADETYPE
              union all
              select e.departname 部门,
                     d.staffname 营业员,
                     c.TRADETYPE || '(充值)' 交易类型,
                     count(*) 操作次数,
                     sum(b.SUPPLYMONEY) / 100.0 操作金额
                FROM TF_B_TRADE a,
                     TF_B_TRADEFEE b,
                     TD_M_TRADETYPE c,
                     TD_M_INSIDESTAFF d,
                     TD_M_INSIDEDEPART e,
                     (select Regioncode
                        from td_m_insidedepart
                       where departno = p_var11) F
               WHERE a.OPERATETIME >=
                     to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                 and a.OPERATETIME <=
                     to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                 and a.TRADETYPECODE = c.TRADETYPECODE
                 AND a.TRADEID = b.TRADEID(+)
                 AND (P_VAR10 is null or P_VAR10 = '' or
                     A.OPERATESTAFFNO IN
                     (SELECT D.STAFFNO
                         FROM TD_M_INSIDESTAFF D
                        WHERE D.DEPARTNO = P_VAR10) OR
                     (P_VAR10 = '9002' AND A.OPERATEDEPARTID = P_VAR10))
                 AND e.DEPARTNO = a.OPERATEDEPARTID
                 AND a.OPERATESTAFFNO = d.STAFFNO
                 AND (P_VAR3 is null or P_VAR3 = '' or
                     A.OPERATESTAFFNO = P_VAR3)
                 AND a.TRADETYPECODE in ('7H', '7I', '7K', 'K1')
                 AND b.SUPPLYMONEY is not null
                 AND (P_VAR6 is null or P_VAR6 = '' or
                     A.TRADETYPECODE IN
                     (SELECT F.TRADETYPENO
                         FROM TD_TRADETYPE_SHOW F
                        WHERE F.SHOWNO = P_VAR6))
                 AND (E.Regioncode IN
                     (select b.regioncode
                         from td_m_regioncode b
                        where b.regionname =
                              (select r.regionname
                                 from td_m_regioncode r
                                where r.regioncode = F.REGIONCODE)) or
                     F.REGIONCODE is null)
                 AND (P_VAR7 = '1' OR
                     (b.SUPPLYMONEY IS NOT NULL AND b.SUPPLYMONEY <> 0)) --add by youyue增加不含无金额业务
               group by e.departname, d.staffname, c.TRADETYPE
              union all
              select e.departname 部门,
                     d.staffname 营业员,
                     c.TRADETYPE || '(手续费)' 交易类型,
                     count(*) 操作次数,
                     sum(b.TRADEPROCFEE) / 100.0 操作金额
                FROM TF_B_TRADE a,
                     TF_B_TRADEFEE b,
                     TD_M_TRADETYPE c,
                     TD_M_INSIDESTAFF d,
                     TD_M_INSIDEDEPART e,
                     (select Regioncode
                        from td_m_insidedepart
                       where departno = p_var11) f
               WHERE a.OPERATETIME >=
                     to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                 and a.OPERATETIME <=
                     to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                 and a.TRADETYPECODE = c.TRADETYPECODE
                 AND a.TRADEID = b.TRADEID(+)
                 AND (P_VAR10 is null or P_VAR10 = '' or
                     A.OPERATESTAFFNO IN
                     (SELECT D.STAFFNO
                         FROM TD_M_INSIDESTAFF D
                        WHERE D.DEPARTNO = P_VAR10) OR
                     (P_VAR10 = '9002' AND A.OPERATEDEPARTID = P_VAR10))
                 AND e.DEPARTNO = a.OPERATEDEPARTID
                 AND a.OPERATESTAFFNO = d.STAFFNO
                 AND (P_VAR3 is null or P_VAR3 = '' or
                     A.OPERATESTAFFNO = P_VAR3)
                 AND a.TRADETYPECODE in ('7H', '7I', '7K', 'K1')
                 AND b.TRADEPROCFEE is not null
                 AND (P_VAR6 is null or P_VAR6 = '' or
                     A.TRADETYPECODE IN
                     (SELECT F.TRADETYPENO
                         FROM TD_TRADETYPE_SHOW F
                        WHERE F.SHOWNO = P_VAR6))
                 AND (E.Regioncode IN
                     (select b.regioncode
                         from td_m_regioncode b
                        where b.regionname =
                              (select r.regionname
                                 from td_m_regioncode r
                                where r.regioncode = F.REGIONCODE)) or
                     F.REGIONCODE is null)
                 AND (P_VAR7 = '1' OR
                     (b.TRADEPROCFEE IS NOT NULL AND b.TRADEPROCFEE <> 0)) --add by youyue增加不含无金额业务
               group by e.departname, d.staffname, c.TRADETYPE
              ------------旅游卡
              union all
              select c.departname 部门,
                     b.staffname 营业员,
                     '专有账户批量充值',
                     count(*) 操作次数,
                     sum(a.supplymoney) / 100.0 操作金额
                from TF_F_SUPPLYCHECK a,
                     TD_M_INSIDESTAFF b,
                     TD_M_INSIDEDEPART c,
                     TF_F_SUPPLYSUM s,
                     (select Regioncode
                        from td_m_insidedepart
                       where departno = p_var11) f
               where a.OPERATETIME >=
                     to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                 and a.OPERATETIME <=
                     to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                 and (P_VAR6 is null or P_VAR6 = '' or p_var6 = '0012')
                 and a.STATECODE = '2'
                 AND (P_VAR10 is null or P_VAR10 = '' or
                     s.SUPPLYSTAFFNO in
                     (select b.staffno
                         from TD_M_INSIDESTAFF b
                        where b.departno = p_var10))
                 AND (P_VAR3 is null or P_VAR3 = '' or b.STAFFNO = P_VAR3)
                 AND s.SUPPLYSTAFFNO = b.STAFFNO
                 AND c.DEPARTNO = s.SUPPLYDEPARTNO
                 and a.ID = s.ID
                 AND (C.Regioncode IN
                     (select b.regioncode
                         from td_m_regioncode b
                        where b.regionname =
                              (select r.regionname
                                 from td_m_regioncode r
                                where r.regioncode = F.REGIONCODE)) or
                     F.REGIONCODE is null)
                 AND (P_VAR7 = '1' OR
                     (a.supplymoney IS NOT NULL AND a.supplymoney <> 0)) --add by youyue增加不含无金额业务
               group by c.departname, b.staffname
              union all
              select c.departname 部门,
                     b.staffname 营业员,
                     '利金卡回收',
                     count(*) 操作次数,
                     0
                from TF_B_TRADE_CASHGIFT a,
                     TD_M_INSIDESTAFF b,
                     TD_M_INSIDEDEPART c,
                     (select Regioncode
                        from td_m_insidedepart
                       where departno = p_var11) F
               where a.OPERATETIME >=
                     to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                 and a.OPERATETIME <=
                     to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                 and (P_VAR10 is null or P_VAR10 = '' or
                     a.OPERATESTAFFNO in
                     (select d.staffno
                         from TD_M_INSIDESTAFF d
                        where d.departno = p_var10))
                 and (P_VAR6 is null or P_VAR6 = '' or p_var6 = '0019')
                 and a.TRADETYPECODE = '52'
                 and a.OPERATESTAFFNO = b.STAFFNO
                 AND (P_VAR3 is null or P_VAR3 = '' or
                     a.OPERATESTAFFNO = P_VAR3)
                 and c.DEPARTNO = a.OPERATEDEPARTID
                 AND (C.Regioncode IN
                     (select b.regioncode
                         from td_m_regioncode b
                        where b.regionname =
                              (select r.regionname
                                 from td_m_regioncode r
                                where r.regioncode = F.REGIONCODE)) or
                     F.REGIONCODE is null)
                 AND (P_VAR7 = '1' OR (b.staffname IS NULL)) --add by youyue增加不含无金额业务排除利金卡回收业务
               group by c.departname, b.staffname
              union all --增加读卡器销售报表查询
              select c.departname 部门,
                     b.staffname 营业员,
                     d.tradetype || '(' ||
                     a.MONEY / 100.0 / NVL(a.READERNUMBER, 1) || '*' ||
                     a.READERNUMBER || ')' AS 交易类型,
                     COUNT(*) 操作次数,
                     sum(a.MONEY) / 100.0 操作金额
                FROM TF_B_READER a,
                     TD_M_INSIDESTAFF b,
                     TD_M_INSIDEDEPART c,
                     TD_M_TRADETYPE d,
                     (select Regioncode
                        from td_m_insidedepart
                       where departno = p_var11) F
               where a.OPERATETIME >=
                     to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                 and a.OPERATETIME <=
                     to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                 and a.OPERATESTAFFNO = b.STAFFNO
                 and b.DEPARTNO = c.DEPARTNO
                 and a.OPERATETYPECODE = d.tradetypecode
                 and a.OPERATETYPECODE not in ('00', '01') --去除入库出库youyue20130922
                 AND (P_VAR6 is null or P_VAR6 = '' or P_VAR6 = '0040')
                 and (P_VAR10 is null or P_VAR10 = '' or
                     a.OPERATESTAFFNO in
                     (select b.staffno
                         from TD_M_INSIDESTAFF b
                        where b.departno = p_var10))
                 and (P_VAR3 is null or P_VAR3 = '' or
                     a.OPERATESTAFFNO = P_VAR3)
                 AND (C.Regioncode IN
                     (select b.regioncode
                         from td_m_regioncode b
                        where b.regionname =
                              (select r.regionname
                                 from td_m_regioncode r
                                where r.regioncode = F.REGIONCODE)) or
                     F.REGIONCODE is null)
                 AND (P_VAR7 = '1' OR (a.MONEY IS NOT NULL AND a.MONEY <> 0)) --add by youyue增加不含无金额业务
               group by c.departname,
                        b.staffname,
                        d.tradetype,
                        a.money,
                        a.READERNUMBER)
       group by 部门, 营业员, 交易类型
       order by 部门, 交易类型, 营业员;
  
  elsif p_funcCode = 'TRADE_LOG_LIST' then
    -- 营业员日报明细
    open p_cursor for
      select e.departname 部门,
             nvl(d.staffname, a.OPERATESTAFFNO) 营业员,
             a.CARDNO 卡号,
             (case
               when c.TRADETYPE = '充值' then
                (CASE
                  WHEN (a.RSRV2 IS NULL OR a.RSRV2 = '') THEN
                   '充值'
                  WHEN a.RSRV2 IS NOT NULL THEN
                   '充值(' || FUN_QUERYCHARGETYPE(a.RSRV2) || ')'
                  ELSE
                   '充值'
                END)
               WHEN c.TRADETYPE = '抹帐' THEN
                (CASE
                  WHEN (a.RSRV2 IS NULL OR a.RSRV2 = '') THEN
                   '抹帐'
                  WHEN a.RSRV2 IS NOT NULL THEN
                   '抹帐(' || FUN_QUERYCHARGETYPE(a.RSRV2) || ')'
                  ELSE
                   '抹帐'
                END)
               WHEN c.TRADETYPE = '台帐返销' THEN
                (CASE
                  WHEN (a.RSRV2 IS NULL OR a.RSRV2 = '') THEN
                   '充值'
                  WHEN a.RSRV2 IS NOT NULL THEN
                   '充值(' || FUN_QUERYCHARGETYPE(a.RSRV2) || ')'
                  ELSE
                   '充值'
                END)
               WHEN C.TRADETYPE = '惠民休闲年卡开卡' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '惠民休闲年卡开卡'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '惠民休闲年卡开卡(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '惠民休闲年卡开卡'
                END)
               WHEN C.TRADETYPE = '惠民休闲年卡换卡' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '惠民休闲年卡换卡'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '惠民休闲年卡换卡(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '惠民休闲年卡换卡'
                END)
               WHEN C.TRADETYPE = '惠民休闲年卡补写卡' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '惠民休闲年卡补写卡'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '惠民休闲年卡补写卡(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '惠民休闲年卡补写卡'
                END)
               WHEN C.TRADETYPE = '惠民休闲年卡开通返销' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '惠民休闲年卡开通返销'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '惠民休闲年卡开通返销(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '惠民休闲年卡开通返销'
                END)
               WHEN C.TRADETYPE = '惠民休闲年卡关闭' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '惠民休闲年卡关闭'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '惠民休闲年卡关闭(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '惠民休闲年卡关闭'
                END)
               WHEN C.TRADETYPE = '惠民亲子卡开卡' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '惠民亲子卡开卡'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '惠民亲子卡开卡(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '惠民亲子卡开卡'
                END)
               WHEN C.TRADETYPE = '惠民亲子卡换卡' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '惠民亲子卡换卡'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '惠民亲子卡换卡(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '惠民亲子卡换卡'
                END)
               WHEN C.TRADETYPE = '惠民亲子卡开卡返销' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '惠民亲子卡开卡返销'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '惠民亲子卡开卡返销(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '惠民亲子卡开卡返销'
                END)
               WHEN c.TRADETYPE = '换卡' THEN
                (CASE
                  WHEN A.CARDNO LIKE '215018%' THEN
                   '换卡(A卡)'
                  ELSE
                   '换卡'
                END) || decode(a.reasoncode,
                               '12',
                               ':可读人为损坏卡',
                               '13',
                               ':可读自然损坏卡',
                               '14',
                               ':不可读人为损坏卡',
                               '15',
                               ':不可读自然损坏卡',
                               a.reasoncode)
               WHEN c.TRADETYPE = '市民卡换卡' THEN
                '市民卡换卡' || decode(a.reasoncode,
                                  '12',
                                  ':可读人为损坏卡',
                                  '13',
                                  ':可读自然损坏卡',
                                  '14',
                                  ':不可读人为损坏卡',
                                  '15',
                                  ':不可读自然损坏卡',
                                  a.reasoncode)
               WHEN c.TRADETYPE = '换卡返销' THEN
                (CASE
                  WHEN A.CARDNO LIKE '215018%' THEN
                   '换卡返销(A卡)'
                  ELSE
                   '换卡返销'
                END) || decode(a.reasoncode,
                               '12',
                               ':可读人为损坏卡',
                               '13',
                               ':可读自然损坏卡',
                               '14',
                               ':不可读人为损坏卡',
                               '15',
                               ':不可读自然损坏卡',
                               a.reasoncode)
               WHEN c.TRADETYPE = '退卡' THEN
                c.TRADETYPE || decode(a.reasoncode,
                                      '11',
                                      ':可读正常卡',
                                      '12',
                                      ':可读人为损坏卡',
                                      '13',
                                      ':可读自然损坏卡',
                                      '14',
                                      ':不可读人为损坏卡',
                                      '15',
                                      ':不可读自然损坏卡',
                                      a.reasoncode)
               WHEN c.TRADETYPE = '售卡' THEN
                (CASE
                  WHEN A.CARDNO LIKE '215018%' THEN
                   '售卡(A卡)'
                  ELSE
                   '售卡'
                END)
               WHEN c.TRADETYPE = '售卡返销' THEN
                (CASE
                  WHEN A.CARDNO LIKE '215018%' THEN
                   '售卡返销(A卡)'
                  ELSE
                   '售卡返销'
                END)
               WHEN c.TRADETYPE = '月票卡开通' THEN
                '月票卡开通' || decode(a.RSRV2,
                                  '01',
                                  '-学生',
                                  '02',
                                  '-老人',
                                  '03',
                                  '-高龄',
                                  '04',
                                  '-爱心卡',
                                  '05',
                                  '-劳模卡',
                                  '06',
                                  '-教育卡',
                                  '07',
                                  '-献血卡',
								  '08',
                                  '-优抚卡',
                                  '')
               WHEN c.TRADETYPE = '月票卡关闭' THEN
                '月票卡关闭' || decode(a.RSRV2,
                                  '01',
                                  '-学生',
                                  '02',
                                  '-老人',
                                  '03',
                                  '-高龄',
                                  '04',
                                  '-爱心卡',
                                  '05',
                                  '-劳模卡',
                                  '06',
                                  '-教育卡',
                                  '07',
                                  '-献血卡',
								  '08',
                                  '-优抚卡',
                                  '')
               WHEN C.TRADETYPE = '补登充值' THEN
                '补登充值' || decode(a.RSRV1, '01', 'APP', a.RSRV1) ||
                decode(a.RSRV2, '01', '支付宝', '02', '微信', '04', '专有账户', a.RSRV2)
               WHEN C.TRADETYPE = '补登充值返销' THEN
                '补登充值返销' || decode(a.RSRV1, '01', 'APP', a.RSRV1) ||
                decode(a.RSRV2, '01', '支付宝', '02', '微信', '04', '专有账户', a.RSRV2) --add by youyue增加补登充值业务查询
               else
                c.TRADETYPE
             END) AS 交易类型,
             NVL(b.CARDSERVFEE, 0) / 100.0 卡服务费,
             NVL(b.CARDDEPOSITFEE, 0) / 100.0 卡押金,
             NVL(b.SUPPLYMONEY, 0) / 100.0 充值,
             NVL(b.TRADEPROCFEE, 0) / 100.0 手续费,
             NVL(b.FUNCFEE, 0) / 100.0 功能费,
             NVL(b.OTHERFEE, 0) / 100.0 折扣金额,
             a.OPERATETIME 交易时间
        FROM TF_B_TRADE a,
             TF_B_TRADEFEE b,
             TD_M_TRADETYPE c,
             TD_M_INSIDESTAFF d,
             TD_M_INSIDEDEPART e,
             (select Regioncode
                from td_m_insidedepart
               where departno = p_var11) F
       WHERE a.OPERATETIME >=
             to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and a.OPERATETIME <=
             to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         AND (P_VAR6 is null or P_VAR6 = '' or
             (p_var6 IN ('0001', '0003') AND A.CARDNO NOT LIKE '215018%' AND
             A.TRADETYPECODE IN
             (SELECT F.TRADETYPENO
                  FROM TD_TRADETYPE_SHOW F
                 WHERE F.SHOWNO = P_VAR6)) or
             (p_var6 = '0031' AND A.CARDNO LIKE '215018%' AND
             A.TRADETYPECODE IN ('01', 'A1')) or
             (p_var6 = '0032' AND A.CARDNO LIKE '215018%' AND
             A.TRADETYPECODE IN ('03', 'A3', '5C', '5E')) or
             (p_var6 = '0002' AND A.TRADETYPECODE IN ('02', '99')) or
             (p_var6 NOT IN ('0001', '0003', '0031', '0032') AND
             A.TRADETYPECODE IN
             (SELECT F.TRADETYPENO
                  FROM TD_TRADETYPE_SHOW F
                 WHERE F.SHOWNO = P_VAR6)))
         and a.TRADETYPECODE = c.TRADETYPECODE
         AND a.TRADEID = b.TRADEID(+)
         AND (p_var10 is null or p_var10 = '' or
             a.OPERATESTAFFNO in
             (select d.staffno
                 from TD_M_INSIDESTAFF d
                where d.departno = p_var10) OR
             (P_VAR10 = '9002' AND a.OPERATEDEPARTID = P_VAR10))
         AND a.OPERATESTAFFNO = d.STAFFNO(+)
         AND (p_var3 is null or p_var3 = '' or p_var3 = d.STAFFNO)
         AND e.DEPARTNO = a.OPERATEDEPARTID
         AND A.TRADETYPECODE <> '8L' --排除专有账户批量充值 新增 殷华荣
         AND (E.Regioncode IN
             (select b.regioncode
                 from td_m_regioncode b
                where b.regionname =
                      (select r.regionname
                         from td_m_regioncode r
                        where r.regioncode = F.REGIONCODE)) or
             F.REGIONCODE is null)
         AND (P_VAR7 = '1' OR
             ((b.CARDSERVFEE IS NOT NULL AND b.CARDSERVFEE <> 0) OR
             (b.CARDDEPOSITFEE IS NOT NULL AND b.CARDDEPOSITFEE <> 0) OR
             (b.SUPPLYMONEY IS NOT NULL AND b.SUPPLYMONEY <> 0) OR
             (b.TRADEPROCFEE IS NOT NULL AND b.TRADEPROCFEE <> 0) OR
             (b.FUNCFEE IS NOT NULL AND b.FUNCFEE <> 0) OR
             (b.OTHERFEE IS NOT NULL AND b.OTHERFEE <> 0))) --add by youyue增加不含无金额业务
      union all
      select e.departname    部门,
             d.staffname     营业员,
             a.ASSOCIATECODE 卡号,
             c.TRADETYPE     交易类型,
             0               卡服务费,
             0               卡押金,
             0               充值,
             0               手续费,
             0               功能费,
             0               折扣金额,
             a.OPERATETIME   交易时间
        FROM TF_B_ASSOCIATETRADE a,
             TD_M_TRADETYPE c,
             TD_M_INSIDESTAFF d,
             TD_M_INSIDEDEPART e,
             (select Regioncode
                from td_m_insidedepart
               where departno = p_var11) F
       WHERE a.OPERATETIME >=
             to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and a.OPERATETIME <=
             to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         and (p_var6 is null or p_var6 = '' or
             a.TRADETYPECODE in
             (select f.TRADETYPENO
                 from TD_TRADETYPE_SHOW f
                where f.SHOWNO = p_var6))
         and a.TRADETYPECODE = c.TRADETYPECODE
         AND (p_var10 is null or p_var10 = '' or
             a.OPERATESTAFFNO in
             (select d.staffno
                 from TD_M_INSIDESTAFF d
                where d.departno = p_var10))
         AND a.OPERATESTAFFNO = d.STAFFNO
         AND (p_var3 is null or p_var3 = '' or p_var3 = d.STAFFNO)
         AND e.DEPARTNO = a.OPERATEDEPARTID
         AND (E.Regioncode IN
             (select b.regioncode
                 from td_m_regioncode b
                where b.regionname =
                      (select r.regionname
                         from td_m_regioncode r
                        where r.regioncode = F.REGIONCODE)) or
             F.REGIONCODE is null)
         AND (P_VAR7 = '1' OR d.staffname IS NULL) --add by youyue增加不含无金额业务
      union all
      select c.departname 部门,
             b.staffname 营业员,
             a.cardno 卡号,
             '专有账户批量充值',
             0 卡服务费,
             0 卡押金,
             a.supplymoney / 100.0 充值,
             0 手续费,
             0 功能费,
             0 折扣金额,
             s.SUPPLYTIME 交易时间
        from TF_F_SUPPLYCHECK a,
             TD_M_INSIDESTAFF b,
             TD_M_INSIDEDEPART c,
             TF_F_SUPPLYSUM s,
             (select Regioncode
                from td_m_insidedepart
               where departno = p_var11) F
       where a.OPERATETIME >=
             to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and a.OPERATETIME <=
             to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         and (p_var6 is null or p_var6 = '' or p_var6 = '0012')
         and a.STATECODE = '2'
         AND (p_var10 is null or p_var10 = '' or
             s.SUPPLYSTAFFNO in
             (select b.staffno
                 from TD_M_INSIDESTAFF b
                where b.departno = p_var10))
         AND s.SUPPLYSTAFFNO = b.STAFFNO
         AND (p_var10 is null or p_var10 = '' or c.DEPARTNO = p_var10)
         and s.SUPPLYDEPARTNO = c.departno
         AND (p_var3 is null or p_var3 = '' or p_var3 = b.STAFFNO)
         and s.ID = a.ID
         AND (C.Regioncode IN
             (select b.regioncode
                 from td_m_regioncode b
                where b.regionname =
                      (select r.regionname
                         from td_m_regioncode r
                        where r.regioncode = F.REGIONCODE)) or
             F.REGIONCODE is null)
         AND (P_VAR7 = '1' OR
             (a.supplymoney IS NOT NULL AND a.supplymoney <> 0)) --add by youyue增加不含无金额业务
      union all --增加读卡器销售报表查询
      select c.departname 部门,
             b.staffname 营业员,
             a.BEGINSERIALNUMBER 卡号,
             d.tradetype 交易类型,
             0 卡服务费,
             0 卡押金,
             a.MONEY / 100.0 充值,
             0 手续费,
             0 功能费,
             0 折扣金额,
             a.OPERATETIME 交易时间
        FROM TF_B_READER a,
             TD_M_INSIDESTAFF b,
             TD_M_INSIDEDEPART c,
             TD_M_TRADETYPE d,
             (select Regioncode
                from td_m_insidedepart
               where departno = p_var11) F
       where a.OPERATETIME >=
             to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and a.OPERATETIME <=
             to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         and a.OPERATESTAFFNO = b.STAFFNO
         and b.DEPARTNO = c.DEPARTNO
         and a.OPERATETYPECODE = d.tradetypecode
         AND (P_VAR6 is null or P_VAR6 = '' or P_VAR6 = '0040')
         and (P_VAR10 is null or P_VAR10 = '' or
             a.OPERATESTAFFNO in
             (select b.staffno
                 from TD_M_INSIDESTAFF b
                where b.departno = p_var10))
         and (P_VAR3 is null or P_VAR3 = '' or a.OPERATESTAFFNO = P_VAR3)
         AND (c.Regioncode IN
             (select b.regioncode
                 from td_m_regioncode b
                where b.regionname =
                      (select r.regionname
                         from td_m_regioncode r
                        where r.regioncode = F.REGIONCODE)) or
             F.REGIONCODE is null)
         AND (P_VAR7 = '1' OR (a.MONEY IS NOT NULL AND a.MONEY <> 0)) --add by youyue增加不含无金额业务
      union all
      select c.departname  部门,
             b.staffname   营业员,
             a.cardno      卡号,
             '利金卡回收',
             0             卡服务费,
             0             卡押金,
             0             充值,
             0             手续费,
             0             功能费,
             0             折扣金额,
             a.OPERATETIME 交易时间
        from TF_B_TRADE_CASHGIFT a,
             TD_M_INSIDESTAFF b,
             TD_M_INSIDEDEPART c,
             (select Regioncode
                from td_m_insidedepart
               where departno = p_var11) F
       where a.OPERATETIME >=
             to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and a.OPERATETIME <=
             to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         and (p_var6 is null or p_var6 = '' or p_var6 = '0019')
         and a.TRADETYPECODE = '52'
         and (p_var10 is null or p_var10 = '' or
             a.OPERATESTAFFNO in
             (select b.staffno
                 from TD_M_INSIDESTAFF b
                where b.departno = p_var10))
         AND (p_var3 is null or p_var3 = '' or p_var3 = b.STAFFNO)
         and a.OPERATESTAFFNO = b.STAFFNO
         and a.OPERATEDEPARTID = c.departno
         AND (C.Regioncode IN
             (select b.regioncode
                 from td_m_regioncode b
                where b.regionname =
                      (select r.regionname
                         from td_m_regioncode r
                        where r.regioncode = F.REGIONCODE)) or
             F.REGIONCODE is null)
         AND (P_VAR7 = '1' OR b.staffname IS NULL) --add by youyue增加不含无金额业务
       order by 4, 11;
  
  elsif p_funcCode = 'XFC_SELL_REPORT' then
    -- 充值卡销售日报
    if p_var3 is null then
      if p_var10 is null then
        open p_cursor for
          select c.departname 部门,
                 b.staffname 营业员,
                 a.money / 100.0 / a.amount 卡面金额,
                 a.amount 数量,
                 a.money / 100.0 总金额,
                 a.OPERATETIME 时间
            from tf_xfc_sell a,
                 TD_M_INSIDESTAFF b,
                 TD_M_INSIDEDEPART c,
                 (select Regioncode
                    from td_m_insidedepart
                   where departno = p_var11) f
           where a.OPERATETIME >=
                 to_date(p_var1 || '000000', 'yyyymmddhh24miss')
             and a.OPERATETIME <=
                 to_date(p_var2 || '235959', 'yyyymmddhh24miss')
             and (p_var6 is null or p_var6 = '' or
                 P_var6 = a.money / 100.0 / a.amount)
             and a.STAFFNO = b.STAFFNO
             and b.departno = c.DEPARTNO
             and a.tradetypecode = '80'
             and a.canceltag = '0'
             AND (C.Regioncode IN
                 (select b.regioncode
                     from td_m_regioncode b
                    where b.regionname =
                          (select r.regionname
                             from td_m_regioncode r
                            where r.regioncode = F.REGIONCODE)) or
                 F.REGIONCODE is null)
          union all
          select c.departname 部门,
                 b.staffname 营业员,
                 a.cardvalue / 100.0 卡面金额,
                 a.amount 数量,
                 a.totalmoney / 100.0 总金额,
                 a.OPERATETIME 时间
            from TF_XFC_BATCHSELL a,
                 TD_M_INSIDESTAFF b,
                 TD_M_INSIDEDEPART c,
                 (select Regioncode
                    from td_m_insidedepart
                   where departno = p_var11) F
           where a.OPERATETIME >=
                 to_date(p_var1 || '000000', 'yyyymmddhh24miss')
             and a.OPERATETIME <=
                 to_date(p_var2 || '235959', 'yyyymmddhh24miss')
             and (P_var6 is null or p_var6 = '' or
                 P_var6 = a.cardvalue / 100.0)
             and a.STAFFNO = b.STAFFNO
             and b.departno = c.DEPARTNO
             and (RSRV1 IS NULL OR RSRV1 <> '1') --去除返销的
             AND (C.Regioncode IN
                 (select b.regioncode
                     from td_m_regioncode b
                    where b.regionname =
                          (select r.regionname
                             from td_m_regioncode r
                            where r.regioncode = F.REGIONCODE)) or
                 F.REGIONCODE is null);
      else
        open p_cursor for
          select c.departname 部门,
                 b.staffname 营业员,
                 a.money / 100.0 / a.amount 卡面金额,
                 a.amount 数量,
                 a.money / 100.0 总金额,
                 a.OPERATETIME 时间
            from tf_xfc_sell a,
                 TD_M_INSIDEDEPART c,
                 TD_M_INSIDESTAFF b,
                 TD_M_INSIDEDEPART d,
                 TD_M_INSIDESTAFF e,
                 (select Regioncode
                    from td_m_insidedepart
                   where departno = p_var11) F
           where a.OPERATETIME >=
                 to_date(p_var1 || '000000', 'yyyymmddhh24miss')
             and a.OPERATETIME <=
                 to_date(p_var2 || '235959', 'yyyymmddhh24miss')
             and (p_var6 is null or p_var6 = '' or
                 P_var6 = a.money / 100.0 / a.amount)
             and a.STAFFNO in (select b.staffno
                                 from TD_M_INSIDESTAFF b
                                where b.departno = p_var10)
             and a.STAFFNO = b.staffno
             and p_var10 = c.DEPARTNO
             and a.tradetypecode = '80'
             and a.canceltag = '0'
             and a.STAFFNO = e.staffno
             and e.departno = d.departno
             AND (d.Regioncode IN
                 (select b.regioncode
                     from td_m_regioncode b
                    where b.regionname =
                          (select r.regionname
                             from td_m_regioncode r
                            where r.regioncode = F.REGIONCODE)) or
                 F.REGIONCODE is null)
          union all
          select c.departname 部门,
                 b.staffname 营业员,
                 a.cardvalue / 100.0 卡面金额,
                 a.amount 数量,
                 a.totalmoney / 100.0 总金额,
                 a.OPERATETIME 时间
            from TF_XFC_BATCHSELL a,
                 TD_M_INSIDESTAFF b,
                 TD_M_INSIDEDEPART c,
                 TD_M_INSIDEDEPART d,
                 TD_M_INSIDESTAFF e,
                 (select Regioncode
                    from td_m_insidedepart
                   where departno = p_var11) F
           where a.OPERATETIME >=
                 to_date(p_var1 || '000000', 'yyyymmddhh24miss')
             and a.OPERATETIME <=
                 to_date(p_var2 || '235959', 'yyyymmddhh24miss')
             and (P_var6 is null or p_var6 = '' or
                 P_var6 = a.cardvalue / 100.0)
             and a.STAFFNO in (select b.staffno
                                 from TD_M_INSIDESTAFF b
                                where b.departno = p_var10)
             and a.STAFFNO = b.staffno
             and p_var10 = c.DEPARTNO
             and (RSRV1 IS NULL OR RSRV1 <> '1') --去除返销的
             and a.STAFFNO = e.staffno
             and e.departno = d.departno
             AND (d.Regioncode IN
                 (select b.regioncode
                     from td_m_regioncode b
                    where b.regionname =
                          (select r.regionname
                             from td_m_regioncode r
                            where r.regioncode = F.REGIONCODE)) or
                 F.REGIONCODE is null);
      end if;
    else
      open p_cursor for
        select c.departname 部门,
               b.staffname 营业员,
               a.money / 100.0 / a.amount 卡面金额,
               a.amount 数量,
               a.money / 100.0 总金额,
               a.OPERATETIME 时间
          from tf_xfc_sell a,
               TD_M_INSIDESTAFF b,
               TD_M_INSIDEDEPART c,
               (select Regioncode
                  from td_m_insidedepart
                 where departno = p_var11) F
         where a.OPERATETIME >=
               to_date(p_var1 || '000000', 'yyyymmddhh24miss')
           and a.OPERATETIME <=
               to_date(p_var2 || '235959', 'yyyymmddhh24miss')
           and (p_var6 is null or p_var6 = '' or
               P_var6 = a.money / 100.0 / a.amount)
           and a.STAFFNO = p_var3
           and p_var3 = b.staffno
           and b.departno = c.DEPARTNO
           and a.tradetypecode = '80'
           and a.canceltag = '0'
           AND (C.Regioncode IN
               (select b.regioncode
                   from td_m_regioncode b
                  where b.regionname =
                        (select r.regionname
                           from td_m_regioncode r
                          where r.regioncode = F.REGIONCODE)) or
               F.REGIONCODE is null)
        union all
        select c.departname 部门,
               b.staffname 营业员,
               a.cardvalue / 100.0 卡面金额,
               a.amount 数量,
               a.totalmoney / 100.0 总金额,
               a.OPERATETIME 时间
          from TF_XFC_BATCHSELL a,
               TD_M_INSIDESTAFF b,
               TD_M_INSIDEDEPART c,
               (select Regioncode
                  from td_m_insidedepart
                 where departno = p_var11) F
         where a.OPERATETIME >=
               to_date(p_var1 || '000000', 'yyyymmddhh24miss')
           and a.OPERATETIME <=
               to_date(p_var2 || '235959', 'yyyymmddhh24miss')
           and (P_var6 is null or p_var6 = '' or
               P_var6 = a.cardvalue / 100.0)
           and a.STAFFNO = p_var3
           and p_var3 = b.staffno
           and b.departno = c.DEPARTNO
           and (RSRV1 IS NULL OR RSRV1 <> '1') --去除返销的
           AND (C.Regioncode IN
               (select b.regioncode
                   from td_m_regioncode b
                  where b.regionname =
                        (select r.regionname
                           from td_m_regioncode r
                          where r.regioncode = F.REGIONCODE)) or
               F.REGIONCODE is null);
    end if;
  
  elsif p_funcCode = 'XFC_SELLDETAIL_REPORT' then
    -- 充值卡销售日报明细
    if p_var3 is null then
      if p_var10 is null then
        open p_cursor for
          select a.startcardno 起始卡号,
                 a.endcardno 终止卡号,
                 a.money / a.amount / 100.0 面值,
                 a.amount 卡数量,
                 a.money / 100.0 总金额,
                 a.operatetime 销售时间,
                 c.departname 销售部门,
                 b.staffname 销售员工,
                 a.remark 备注
            from tf_xfc_sell a,
                 TD_M_INSIDESTAFF b,
                 TD_M_INSIDEDEPART c,
                 (select Regioncode
                    from td_m_insidedepart
                   where departno = p_var11) F
           where a.OPERATETIME >=
                 to_date(p_var1 || '000000', 'yyyymmddhh24miss')
             and a.OPERATETIME <=
                 to_date(p_var2 || '235959', 'yyyymmddhh24miss')
             and (p_var6 is null or p_var6 = '' or
                 P_var6 = a.money / 100.0 / a.amount)
             and a.STAFFNO = b.STAFFNO
             and b.departno = c.DEPARTNO
             and a.tradetypecode = '80'
             and a.canceltag = '0'
             AND (C.Regioncode IN
                 (select b.regioncode
                     from td_m_regioncode b
                    where b.regionname =
                          (select r.regionname
                             from td_m_regioncode r
                            where r.regioncode = F.REGIONCODE)) or
                 F.REGIONCODE is null)
          union
          select a.startcardno 起始卡号,
                 a.endcardno 终止卡号,
                 a.cardvalue / 100.0 面值,
                 a.amount 卡数量,
                 a.totalmoney / 100.0 总金额,
                 a.operatetime 销售时间,
                 c.departname 销售部门,
                 b.staffname 销售员工,
                 a.remark 备注
            from TF_XFC_BATCHSELL a,
                 TD_M_INSIDESTAFF b,
                 TD_M_INSIDEDEPART c,
                 (select Regioncode
                    from td_m_insidedepart
                   where departno = p_var11) F
           where a.OPERATETIME >=
                 to_date(p_var1 || '000000', 'yyyymmddhh24miss')
             and a.OPERATETIME <=
                 to_date(p_var2 || '235959', 'yyyymmddhh24miss')
             and (P_var6 is null or p_var6 = '' or
                 P_var6 = a.cardvalue / 100.0)
             and a.STAFFNO = b.STAFFNO
             and b.departno = c.DEPARTNO
             AND (C.Regioncode IN
                 (select b.regioncode
                     from td_m_regioncode b
                    where b.regionname =
                          (select r.regionname
                             from td_m_regioncode r
                            where r.regioncode = F.REGIONCODE)) or
                 F.REGIONCODE is null)
             and (RSRV1 IS NULL OR RSRV1 <> '1'); --去除返销的
      else
        open p_cursor for
          select a.startcardno 起始卡号,
                 a.endcardno 终止卡号,
                 a.money / a.amount / 100.0 面值,
                 a.amount 卡数量,
                 a.money / 100.0 总金额,
                 a.operatetime 销售时间,
                 c.departname 销售部门,
                 b.staffname 销售员工,
                 a.remark 备注
            from tf_xfc_sell a,
                 TD_M_INSIDEDEPART c,
                 TD_M_INSIDESTAFF b,
                 TD_M_INSIDEDEPART d,
                 TD_M_INSIDESTAFF e,
                 (select Regioncode
                    from td_m_insidedepart
                   where departno = p_var11) F
           where a.OPERATETIME >=
                 to_date(p_var1 || '000000', 'yyyymmddhh24miss')
             and a.OPERATETIME <=
                 to_date(p_var2 || '235959', 'yyyymmddhh24miss')
             and (p_var6 is null or p_var6 = '' or
                 P_var6 = a.money / 100.0 / a.amount)
             and a.STAFFNO in (select b.staffno
                                 from TD_M_INSIDESTAFF b
                                where b.departno = p_var10)
             and a.STAFFNO = b.staffno
             and p_var10 = c.DEPARTNO
             and a.tradetypecode = '80'
             and a.canceltag = '0'
             and a.STAFFNO = e.staffno
             and e.departno = d.departno
             AND (d.Regioncode IN
                 (select b.regioncode
                     from td_m_regioncode b
                    where b.regionname =
                          (select r.regionname
                             from td_m_regioncode r
                            where r.regioncode = F.REGIONCODE)) or
                 F.REGIONCODE is null)
          union
          select a.startcardno 起始卡号,
                 a.endcardno 终止卡号,
                 a.cardvalue / 100.0 面值,
                 a.amount 卡数量,
                 a.totalmoney / 100.0 总金额,
                 a.operatetime 销售时间,
                 c.departname 销售部门,
                 b.staffname 销售员工,
                 a.remark 备注
            from TF_XFC_BATCHSELL a,
                 TD_M_INSIDESTAFF b,
                 TD_M_INSIDEDEPART c,
                 TD_M_INSIDEDEPART d,
                 TD_M_INSIDESTAFF e,
                 (select Regioncode
                    from td_m_insidedepart
                   where departno = p_var11) F
           where a.OPERATETIME >=
                 to_date(p_var1 || '000000', 'yyyymmddhh24miss')
             and a.OPERATETIME <=
                 to_date(p_var2 || '235959', 'yyyymmddhh24miss')
             and (P_var6 is null or p_var6 = '' or
                 P_var6 = a.cardvalue / 100.0)
             and a.STAFFNO in (select b.staffno
                                 from TD_M_INSIDESTAFF b
                                where b.departno = p_var10)
             and a.STAFFNO = b.staffno
             and p_var10 = c.DEPARTNO
             and a.STAFFNO = e.staffno
             and e.departno = d.departno
             AND (d.Regioncode IN
                 (select b.regioncode
                     from td_m_regioncode b
                    where b.regionname =
                          (select r.regionname
                             from td_m_regioncode r
                            where r.regioncode = F.REGIONCODE)) or
                 F.REGIONCODE is null)
             and (RSRV1 IS NULL OR RSRV1 <> '1');
      end if;
    else
      open p_cursor for
        select a.startcardno 起始卡号,
               a.endcardno 终止卡号,
               a.money / a.amount / 100.0 面值,
               a.amount 卡数量,
               a.money / 100.0 总金额,
               a.operatetime 销售时间,
               c.departname 销售部门,
               b.staffname 销售员工,
               a.remark 备注
          from tf_xfc_sell a,
               TD_M_INSIDESTAFF b,
               TD_M_INSIDEDEPART c,
               (select Regioncode
                  from td_m_insidedepart
                 where departno = p_var11) F
         where a.OPERATETIME >=
               to_date(p_var1 || '000000', 'yyyymmddhh24miss')
           and a.OPERATETIME <=
               to_date(p_var2 || '235959', 'yyyymmddhh24miss')
           and (p_var6 is null or p_var6 = '' or
               P_var6 = a.money / 100.0 / a.amount)
           and a.STAFFNO = p_var3
           and p_var3 = b.STAFFNO
           and b.departno = c.DEPARTNO
           and a.tradetypecode = '80'
           and a.canceltag = '0'
           AND (C.Regioncode IN
               (select b.regioncode
                   from td_m_regioncode b
                  where b.regionname =
                        (select r.regionname
                           from td_m_regioncode r
                          where r.regioncode = F.REGIONCODE)) or
               F.REGIONCODE is null)
        union
        select a.startcardno 起始卡号,
               a.endcardno 终止卡号,
               a.cardvalue / 100.0 面值,
               a.amount 卡数量,
               a.totalmoney / 100.0 总金额,
               a.operatetime 销售时间,
               c.departname 销售部门,
               b.staffname 销售员工,
               a.remark 备注
          from TF_XFC_BATCHSELL a,
               TD_M_INSIDESTAFF b,
               TD_M_INSIDEDEPART c,
               (select Regioncode
                  from td_m_insidedepart
                 where departno = p_var11) F
         where a.OPERATETIME >=
               to_date(p_var1 || '000000', 'yyyymmddhh24miss')
           and a.STAFFNO = p_var3
           and p_var3 = b.STAFFNO
           and (P_var6 is null or p_var6 = '' or
               P_var6 = a.cardvalue / 100.0)
           and b.departno = c.DEPARTNO
           AND (C.Regioncode IN
               (select b.regioncode
                   from td_m_regioncode b
                  where b.regionname =
                        (select r.regionname
                           from td_m_regioncode r
                          where r.regioncode = F.REGIONCODE)) or
               F.REGIONCODE is null)
           and (RSRV1 IS NULL OR RSRV1 <> '1');
    end if;
    commit;
  
  elsif p_funcCode = 'DEPOSIT_FUND_COLLECT' then
    -- 沉淀资金分析
    open p_cursor for
      select COLLECTMONTH 统计月份,
             YPDEPOSIT / 100.0 卡押金,
             DEPOSIT / 100.0 卡押金,
             SUPPLY / 100.0 充值卡,
             NORMAL / 100.0 普通卡电子钱包,
             LIJIN / 100.0 利金卡电子钱包,
             ACCOUNT / 100.0 企服卡后台帐户
        from TF_DEPOSIT_FUND_COLLECT
       where COLLECTMONTH >= cast(p_var1 as char(8))
         and COLLECTMONTH <= cast(p_var2 as char(8))
       order by COLLECTMONTH;
  
  elsif p_funcCode = 'FUNDS_COLLECT_TOTAL' then
    -- 沉淀资金汇总统计 add by shil 20130711
    open p_cursor for
      select *
        from (select xx.stattime,
                     xx.money,
                     sum(xx.money) over(order by xx.stattime) as totlemoney
                from (select substr(stattime, 0, 6) as stattime,
                             nvl(sum(money) / 100.0, 0) money
                        from tf_fundsanalysis
                       group by substr(stattime, 0, 6)) xx)
       where stattime >= cast(p_var1 as char(6))
         and stattime <= cast(p_var2 as char(6))
       order by stattime;
  
  elsif p_funcCode = 'FUNDS_COLLECT_DETAIL' then
    -- 沉淀资金详细信息 add by shil 20130711
    open p_cursor for
      select CATEGORY 收支类别,
             NAME 收支项目,
             nvl(sum(MONEY) / 100.0, 0) 金额
        from TF_FUNDSANALYSIS
       where substr(STATTIME, 0, 6) >= cast(p_var1 as char(6))
         and substr(STATTIME, 0, 6) <= cast(p_var2 as char(6))
       group by CATEGORY, NAME
       order by CATEGORY, NAME;
  
  elsif p_funcCode = 'POS_TRADE_RELATION' then
    -- POS商户对应分析
    open p_cursor for
      select '他投' 类型,
             '公交' 商户名称,
             2757 POS数量,
             sum(b.TRANSFEE) / 100.0 消费金额,
             round(sum(b.TRANSFEE) / 2757 / 100.0, 2) POS平均消费额,
             round(sum(b.COMFEE) / 2757 / 100.0, 2) POS平均佣金收入
        from TF_TRADE_OUTCOMEFIN b
       where (p_var1 is null or p_var1 = '' or
             to_char(b.ENDTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
         and (p_var2 is null or p_var2 = '' or
             to_char(b.ENDTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
         and b.callingno = '01'
      union
      select '他投' 类型,
             '出租' 商户名称,
             3203 POS数量,
             sum(b.TRANSFEE) / 100.0 消费金额,
             round(sum(b.TRANSFEE) / 3203 / 100.0, 2) POS平均消费额,
             round(sum(b.COMFEE) / 3203 / 100.0, 2) POS平均佣金收入
        from TF_TAXI_OUTCOMEFIN b
       where (p_var1 is null or p_var1 = '' or
             to_char(ENDTIME, 'yyyymmdd') >= p_var1)
         and (p_var2 is null or p_var2 = '' or
             to_char(ENDTIME, 'yyyymmdd') <= p_var2)
      union
      select '他投' 类型,
             '信息亭' 商户名称,
             172 POS数量,
             sum(b.TRANSFEE) / 100.0 消费金额,
             round(sum(b.TRANSFEE) / 172 / 100.0, 2) POS平均消费额,
             round(sum(b.COMFEE) / 172 / 100.0, 2) POS平均佣金收入
        from TF_TRADE_OUTCOMEFIN b
       where (p_var1 is null or p_var1 = '' or
             to_char(b.ENDTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
         and (p_var2 is null or p_var2 = '' or
             to_char(b.ENDTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
         and b.callingno = '0C'
      union
      select a.POSTYPE 类型,
             a.BALUNIT 商户名称,
             sum(a.POSCOUNT) POS数量,
             sum(b.TRANSFEE) / 100.0 消费金额,
             round(sum(b.TRANSFEE) / sum(a.POSCOUNT) / 100.0, 2) POS平均消费额,
             round(sum(b.COMFEE) / sum(a.POSCOUNT) / 100.0, 2) POS平均佣金收入
        from TF_POS_TRADE_RELATION a, TF_TRADE_OUTCOMEFIN b
       where (p_var1 is null or p_var1 = '' or
             to_char(b.ENDTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
         and (p_var2 is null or p_var2 = '' or
             to_char(b.ENDTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
         and a.BALUNITNO = b.BALUNITNO
       group by a.POSTYPE, a.BALUNIT
       order by 1;
  
  elsif p_funcCode = 'ZEROTRADEPOS_COLLECT' then
    -- 零交易POS分析
    open p_cursor for
      select SHOP 商户, count(*) POS数, REASON 原因, ENDDATE 协议到期日期
        from TF_ZEROTRADEPOS_COLLECT
       group by SHOP, REASON, ENDDATE;
  
  elsif p_funcCode = 'SELLCARD_ROLLBACK' then
    -- 售卡返销
    open p_cursor for
      select to_char(b.OPERATETIME, 'yyyymmdd') 售卡日期,
             c.staffname 销售员工,
             b.CARDDEPOSITFEE / 100.0 售卡押金,
             b.CARDSERVFEE / 100.0 售卡卡费,
             count(*) 张数,
             d.staffname 返销员工,
             to_char(a.OPERATETIME, 'yyyymmdd') 返销日期
        from TF_B_TRADE       a,
             TF_B_TRADEFEE    b,
             TD_M_INSIDESTAFF c,
             TD_M_INSIDESTAFF d
       where a.OPERATETIME >=
             to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and a.OPERATETIME <=
             to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         and a.TRADETYPECODE = 'A1'
         and a.CANCELTAG = '0'
         and a.CANCELTRADEID = b.TRADEID
         and b.OPERATESTAFFNO = c.STAFFNO
         and a.OPERATESTAFFNO = d.STAFFNO
       group by to_char(b.OPERATETIME, 'yyyymmdd'),
                c.staffname,
                b.CARDDEPOSITFEE,
                b.CARDSERVFEE,
                d.staffname,
                to_char(a.OPERATETIME, 'yyyymmdd');
  
  elsif p_funcCode = 'CARDMONEY_CHANGE' then
    -- 卡余额修改
    open p_cursor for
      select a.CARDNO 卡号,
             a.PREBALANCE / 100.0 修改前余额,
             (a.NEWBALANCE - a.PREBALANCE) / 100.0 修改金额,
             b.staffname 提交员工,
             a.SUBMITTIME 提交时间,
             c.staffname 审核员工,
             a.CHECKTIME 审核时间
        from TF_SPECIAL_CHNAGEBALANCE a,
             TD_M_INSIDESTAFF         b,
             TD_M_INSIDESTAFF         c
       where a.CHECKTIME >= to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and a.CHECKTIME <= to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         and a.CHECKSTATE = '2'
         and a.SUBMITSTAFF = b.STAFFNO
         and a.CHECKSTAFF = c.STAFFNO;
  
  elsif p_funcCode = 'LIJIN_RENEW_REPORT' then
    -- 利金卡回收统计
    open p_cursor for
      select b.BALUNIT 商户名称,
             COUNT(A.CARDNO) 回收卡张数,
             to_char(a.DEALTIME, 'yyyymm') 回收时间
        from TQ_TRADE_RIGHT a, TF_TRADE_BALUNIT b
       where a.ICTRADETYPECODE = '06'
         and a.BALUNITNO = b.BALUNITNO
         and a.callingno <> '01'
         and to_char(a.DEALTIME, 'yyyymm') = p_var1
       group by b.BALUNIT, a.dealtime;
  
  elsif p_funcCode = 'LIJIN_RENEW_DETAIL' then
    -- 利金卡回收明细
    open p_cursor for
      select a.CARDNO   卡号,
             a.POSNO    POS号,
             b.BALUNIT  商户名称,
             a.DEALTIME 回收时间
        from TQ_TRADE_RIGHT a, TF_TRADE_BALUNIT b
       where a.DEALTIME >= to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and a.DEALTIME <= to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         and a.ICTRADETYPECODE = '06'
         and a.callingno <> '01'
         and a.BALUNITNO = b.BALUNITNO;
  
  elsif p_funcCode = 'SPEADJUSTQUERY' then
    -- 特殊调账佣金查询
    open p_cursor for
      select a.balunitno 结算单元编码,
             b.balunit 结算单元名称,
             count(*) 调账总次数,
             sum(a.refundment) / 100 调账总金额,
             sum(a.refundment) / 100 * cl.slope 应退还佣金额
        from TF_B_SPEADJUSTACC     a,
             TF_TRADE_BALUNIT      b,
             TD_TBALUNIT_COMSCHEME c,
             TD_TCOMSCHEME_COMRULE t,
             TF_COMRULE            cl
       where a.SUPPTIME >= to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and a.SUPPTIME <= to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         and c.balunitno = b.balunitno
         and c.comschemeno = t.comschemeno
         and cl.comruleno = t.comruleno
         and a.BALUNITNO = b.BALUNITNO
       group by a.balunitno, cl.slope, b.balunit;
  elsif p_funcCode = 'TRADE_LIGHTRAIL_S_REPORT' THEN
    --轻轨交易补录清算
    open p_cursor for
      select '轻轨' 商户名称,
             to_char(a.CHECKTIME, 'yyyymmdd') 转账时间,
             sum(a.TRADEMONEY / 100.0) 转帐金额
        from TF_B_LRTTRADE_MANUAL a
       where (p_var1 is null or p_var1 = '' or
             to_char(a.CHECKTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd')), 'yyyymmdd'))
         and (p_var2 is null or p_var2 = '' or
             to_char(a.CHECKTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd')), 'yyyymmdd'))
         and a.CHECKSTATECODE = '1'
       group by to_char(a.CHECKTIME, 'yyyymmdd')
       order by to_char(a.CHECKTIME, 'yyyymmdd');
  
  elsif p_funcCode = 'SUPPLY_DEPTBAL_REPORT' then
    -- 商户代理充值对帐
    if p_var7 = '00000000' then
      open p_cursor for
        select TRADEDATE 交易日期,
               DBALUNIT 结算单元,
               SUM(充值) 充值,
               SUM(冲正) 冲正,
               SUM(回收) 回收,
               SUM(退款) 退款,
               SUM(退款笔数) 退款笔数,
               SUM(充值 - 冲正 + 回收) 转帐,
               SUM(笔数) 笔数,
               SUM(充值 - 冲正 + 回收 - 退款) 转帐扣退款
          from (select a.TRADEDATE,
                       b.DBALUNIT,
                       sum(a.TRADEMONEY) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数,
                       0 退款笔数
                  from TQ_SUPPLY_RIGHT a, TF_DEPT_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.tradetypecode = '1S'
                   and substr(a.BALUNITNO, 1, 2) <> '0D'
                   and a.BALUNITNO = b.DBALUNITNO
                   and b.DEPTTYPE = '2'
                 group by a.TRADEDATE, b.DBALUNIT
                union all
                select a.TRADEDATE,
                       b.DBALUNIT,
                       sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数,
                       0 退款笔数
                  from TQ_SUPPLY_RIGHT a, TF_DEPT_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.tradetypecode = '1S'
                   and substr(a.BALUNITNO, 1, 2) = '0D'
                   and a.BALUNITNO = b.DBALUNITNO
                   and b.DEPTTYPE = '2'
                 group by a.TRADEDATE, b.DBALUNIT
                union all
                select a.TRADEDATE,
                       b.DBALUNIT,
                       sum(a.TRADEMONEY) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数,
                       0 退款笔数
                  from TF_OUTSUPPLY_ADJUST a, TF_DEPT_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.rsrvchar = 'S1'
                   and a.BALUNITNO = b.DBALUNITNO
                   and b.DEPTTYPE = '2'
                   and a.DEALSTATECODE = '1'
                 group by a.TRADEDATE, b.DBALUNIT
                union all
                select to_char(a.INLISTTIME, 'yyyyMMdd'),
                       b.DBALUNIT,
                       0 充值,
                       sum(a.TRADEMONEY) / 100.0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数,
                       0 退款笔数
                  from TF_B_OUTSUPPLY_ADJUST a, TF_DEPT_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.INLISTTIME >=
                       TO_DATE(p_var1 || '000000', 'YYYYMMDDHH24MISS'))
                   and (p_var2 is null or p_var2 = '' or
                       a.INLISTTIME <=
                       TO_DATE(p_var2 || '235959', 'YYYYMMDDHH24MISS'))
                   and a.BALUNITNO = b.DBALUNITNO
                   and b.DEPTTYPE = '2'
                   and a.DEALSTATECODE = '1'
                 group by to_char(a.INLISTTIME, 'yyyyMMdd'), b.DBALUNIT
                union all
                select to_char(a.DEALTIME, 'yyyyMMdd'),
                       b.DBALUNIT,
                       0 充值,
                       0 冲正,
                       sum(a.TRADEMONEY) / 100.0 回收,
                       0 退款,
                       COUNT(*) 笔数,
                       0 退款笔数
                  from TF_B_OUTSUPPLY_ADJUST a, TF_DEPT_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.DEALTIME >= TO_DATE(p_var1, 'yyyy-MM-dd'))
                   and (p_var2 is null or p_var2 = '' or
                       a.DEALTIME <= TO_DATE(p_var2, 'yyyy-MM-dd'))
                   and a.BALUNITNO = b.DBALUNITNO
                   and b.DEPTTYPE = '2'
                   and a.DEALSTATECODE = '2'
                 group by to_char(a.DEALTIME, 'yyyyMMdd'), b.DBALUNIT
                union all
                select to_char(a.operatetime, 'yyyyMMdd'),
                       c.DBALUNIT,
                       0,
                       0,
                       0,
                       sum(a.factmoney) / 100.0 退款,
                       0,
                       COUNT(*) 退款笔数
                  from tf_b_refund a, tq_supply_right b, TF_DEPT_BALUNIT c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.operatetime, 'yyyyMMdd') >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.operatetime, 'yyyyMMdd') <= p_var2)
                   and a.id = b.id
                   and b.BALUNITNO = c.DBALUNITNO
                   and c.DEPTTYPE = '2'
                   and a.TRADETYPECODE = '91'
                 group by to_char(a.operatetime, 'yyyyMMdd'), c.DBALUNIT)
         group by TRADEDATE, DBALUNIT
         ORDER BY TRADEDATE, DBALUNIT;
    else
      open p_cursor for
        select TRADEDATE 交易日期,
               DBALUNIT 结算单元,
               SUM(充值) 充值,
               SUM(冲正) 冲正,
               SUM(回收) 回收,
               SUM(退款) 退款,
               SUM(退款笔数) 退款笔数,
               SUM(充值 - 冲正 + 回收) 转帐,
               SUM(笔数) 笔数,
               SUM(充值 - 冲正 + 回收 - 退款) 转帐扣退款
          from (select a.TRADEDATE,
                       b.DBALUNIT,
                       sum(a.TRADEMONEY) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数,
                       0 退款笔数
                  from TQ_SUPPLY_RIGHT a, TF_DEPT_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.tradetypecode = '1S'
                   and substr(a.BALUNITNO, 1, 2) <> '0D'
                   and a.BALUNITNO = p_var7
                   and a.BALUNITNO = b.DBALUNITNO
                   and b.DEPTTYPE = '2'
                 group by a.TRADEDATE, b.DBALUNIT
                union all
                select a.TRADEDATE,
                       b.DBALUNIT,
                       sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数,
                       0 退款笔数
                  from TQ_SUPPLY_RIGHT a, TF_DEPT_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.tradetypecode = '1S'
                   and substr(a.BALUNITNO, 1, 2) = '0D'
                   and a.BALUNITNO = p_var7
                   and a.BALUNITNO = b.DBALUNITNO
                   and b.DEPTTYPE = '2'
                 group by a.TRADEDATE, b.DBALUNIT
                union all
                select a.TRADEDATE,
                       b.DBALUNIT,
                       sum(a.TRADEMONEY) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数,
                       0 退款笔数
                  from TF_OUTSUPPLY_ADJUST a, TF_DEPT_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.rsrvchar = 'S1'
                   and a.BALUNITNO = b.DBALUNITNO
                   and b.DEPTTYPE = '2'
                   and a.BALUNITNO = p_var7
                   and a.DEALSTATECODE = '1'
                 group by a.TRADEDATE, b.DBALUNIT
                union all
                select to_char(a.INLISTTIME, 'yyyyMMdd'),
                       b.DBALUNIT,
                       0 充值,
                       sum(a.TRADEMONEY) / 100.0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数,
                       0 退款笔数
                  from TF_B_OUTSUPPLY_ADJUST a, TF_DEPT_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.INLISTTIME >=
                       TO_DATE(p_var1 || '000000', 'YYYYMMDDHH24MISS'))
                   and (p_var2 is null or p_var2 = '' or
                       a.INLISTTIME <=
                       TO_DATE(p_var2 || '235959', 'YYYYMMDDHH24MISS'))
                   and a.BALUNITNO = b.DBALUNITNO
                   and b.DEPTTYPE = '2'
                   and a.BALUNITNO = p_var7
                   and a.DEALSTATECODE = '1'
                 group by to_char(a.INLISTTIME, 'yyyyMMdd'), b.DBALUNIT
                union all
                select to_char(a.DEALTIME, 'yyyyMMdd'),
                       b.DBALUNIT,
                       0 充值,
                       0 冲正,
                       sum(a.TRADEMONEY) / 100.0 回收,
                       0 退款,
                       COUNT(*) 笔数,
                       0 退款笔数
                  from TF_B_OUTSUPPLY_ADJUST a, TF_DEPT_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.DEALTIME >= TO_DATE(p_var1, 'yyyy-MM-dd'))
                   and (p_var2 is null or p_var2 = '' or
                       a.DEALTIME <= TO_DATE(p_var2, 'yyyy-MM-dd'))
                   and a.BALUNITNO = b.DBALUNITNO
                   and b.DEPTTYPE = '2'
                   and a.BALUNITNO = p_var7
                   and a.DEALSTATECODE = '2'
                 group by to_char(a.DEALTIME, 'yyyyMMdd'), b.DBALUNIT
                union all
                select to_char(a.operatetime, 'yyyyMMdd'),
                       c.DBALUNIT,
                       0,
                       0,
                       0,
                       sum(a.factmoney) / 100.0 退款,
                       0 笔数,
                       COUNT(*) 退款笔数
                  from tf_b_refund a, tq_supply_right b, TF_DEPT_BALUNIT c
                 where (p_var1 is null or p_var1 = '' or
                       to_char(a.operatetime, 'yyyyMMdd') >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       to_char(a.operatetime, 'yyyyMMdd') <= p_var2)
                   and a.id = b.id
                   and b.BALUNITNO = c.DBALUNITNO
                   and c.DEPTTYPE = '2'
                   and a.TRADETYPECODE = '91'
                   and b.BALUNITNO = p_var7
                 group by to_char(a.operatetime, 'yyyyMMdd'), c.DBALUNIT)
         group by TRADEDATE, DBALUNIT
         ORDER BY TRADEDATE, DBALUNIT;
    end if;
  
  elsif p_funcCode = 'SUPPLY_ADJUST_REPORT' then
    -- 代理充值对帐
    if p_var7 = '00000000' then
      open p_cursor for
        select TRADEDATE 交易日期,
               BALUNIT 结算单元,
               SUM(充值) 充值,
               SUM(冲正) 冲正,
               SUM(回收) 回收,
               SUM(退款) 退款,
               SUM(充值 - 冲正 + 回收 - 退款) 转帐,
               SUM(笔数) 笔数
          from (select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数
                  from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.tradetypecode = '02'
                   and substr(a.BALUNITNO, 1, 2) <> '0D'
                   and substr(b.BALUNITNO, 1, 2) <> 'SH'
                   and a.BALUNITNO = b.BALUNITNO
                 group by a.TRADEDATE, b.BALUNIT
                union all
                select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数
                  from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.tradetypecode = '02'
                   and substr(a.BALUNITNO, 1, 2) = '0D'
                   and substr(b.BALUNITNO, 1, 2) <> 'SH'
                   and a.BALUNITNO = b.BALUNITNO
                 group by a.TRADEDATE, b.BALUNIT
                union all
                select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数
                  from TF_OUTSUPPLY_ADJUST a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.BALUNITNO = b.BALUNITNO
                   and substr(b.BALUNITNO, 1, 2) <> 'SH'
                   and a.DEALSTATECODE = '1'
                 group by a.TRADEDATE, b.BALUNIT
                union all
                select to_char(a.dealtime, 'yyyyMMdd'),
                       b.BALUNIT,
                       0 充值,
                       sum(a.TRADEMONEY) / 100.0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数
                  from TF_B_OUTSUPPLY_ADJUST a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.dealtime >= TO_DATE(p_var1, 'yyyy-MM-dd'))
                   and (p_var2 is null or p_var2 = '' or
                       a.dealtime <= TO_DATE(p_var2, 'yyyy-MM-dd'))    
                   and a.BALUNITNO = b.BALUNITNO
                   and substr(b.BALUNITNO, 1, 2) <> 'SH'
                   and a.DEALSTATECODE = '1'
                 group by to_char(a.dealtime, 'yyyyMMdd'), b.BALUNIT
                union all
                select to_char(a.dealtime, 'yyyyMMdd'),
                       b.BALUNIT,
                       0 充值,
                       0 冲正,
                       sum(a.TRADEMONEY) / 100.0 回收,
                       0 退款,
                       COUNT(*) 笔数
                  from TF_B_OUTSUPPLY_ADJUST a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.dealtime >= TO_DATE(p_var1, 'yyyy-MM-dd'))
                   and (p_var2 is null or p_var2 = '' or
                       a.dealtime <= TO_DATE(p_var2, 'yyyy-MM-dd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and substr(b.BALUNITNO, 1, 2) <> 'SH'
                   and a.DEALSTATECODE = '2'
                 group by to_char(a.dealtime, 'yyyyMMdd'), b.BALUNIT
                union all
                select a.cfttradedate,
                       b.BALUNIT,
                       0 充值,
                       0 冲正,
                       0 回收,
                       sum(a.TRADEMONEY) / 100.0 退款,
                       COUNT(*) 笔数
                  from tq_nfcrunfundback a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.cfttradedate >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.cfttradedate <= p_var2)
                   and (a.errorinfo = '' or a.errorinfo is null)
                   and a.BALUNITNO = b.BALUNITNO
                   and substr(b.BALUNITNO, 1, 2) <> 'SH'
                   and a.Runfundstate = '1'
                 group by a.cfttradedate, b.BALUNIT)
         group by TRADEDATE, BALUNIT
         ORDER BY TRADEDATE, BALUNIT;
    
    else
      open p_cursor for
        select TRADEDATE 交易日期,
               BALUNIT 结算单元,
               SUM(充值) 充值,
               SUM(冲正) 冲正,
               SUM(回收) 回收,
               SUM(退款) 退款,
               SUM(充值 - 冲正 + 回收 - 退款) 转帐,
               SUM(笔数) 笔数
          from (select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数
                  from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.tradetypecode = '02'
                   and substr(a.BALUNITNO, 1, 2) <> '0D'
                   and a.BALUNITNO = p_var7
                   and a.BALUNITNO = b.BALUNITNO
                 group by a.TRADEDATE, b.BALUNIT
                union all
                select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数
                  from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.tradetypecode = '02'
                   and substr(a.BALUNITNO, 1, 2) = '0D'
                   and a.BALUNITNO = p_var7
                   and a.BALUNITNO = b.BALUNITNO
                 group by a.TRADEDATE, b.BALUNIT
                union all
                select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数
                  from TF_OUTSUPPLY_ADJUST a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.BALUNITNO = b.BALUNITNO
                   and a.BALUNITNO = p_var7
                   and a.DEALSTATECODE = '1'
                 group by a.TRADEDATE, b.BALUNIT
                union all
                select to_char(a.dealtime, 'yyyyMMdd'),
                       b.BALUNIT,
                       0 充值,
                       sum(a.TRADEMONEY) / 100.0 冲正,
                       0 回收,
                       0 退款,
                       COUNT(*) 笔数
                  from TF_B_OUTSUPPLY_ADJUST a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.dealtime >= TO_DATE(p_var1, 'yyyy-MM-dd'))
                   and (p_var2 is null or p_var2 = '' or
                       a.dealtime <= TO_DATE(p_var2, 'yyyy-MM-dd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and a.BALUNITNO = p_var7
                   and a.DEALSTATECODE = '1'
                 group by to_char(a.dealtime, 'yyyyMMdd'), b.BALUNIT
                union all
                select to_char(a.dealtime, 'yyyyMMdd'),
                       b.BALUNIT,
                       0 充值,
                       0 冲正,
                       sum(a.TRADEMONEY) / 100.0 回收,
                       0 退款,
                       COUNT(*) 笔数
                  from TF_B_OUTSUPPLY_ADJUST a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.dealtime >= TO_DATE(p_var1, 'yyyy-MM-dd'))
                   and (p_var2 is null or p_var2 = '' or
                       a.dealtime <= TO_DATE(p_var2, 'yyyy-MM-dd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and a.BALUNITNO = p_var7
                   and a.DEALSTATECODE = '2'
                 group by to_char(a.dealtime, 'yyyyMMdd'), b.BALUNIT
                union all
                select a.cfttradedate,
                       b.balunit,
                       0 充值,
                       0 冲正,
                       0 回收,
                       sum(a.TRADEMONEY) / 100.0 退款,
                       COUNT(*) 笔数
                  from tq_nfcrunfundback a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.cfttradedate >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.cfttradedate <= p_var2)
                   and a.balunitno = b.balunitno
                   and (a.errorinfo = '' or a.errorinfo is null)
                   and a.Runfundstate = '1'
                   and a.BALUNITNO = p_var7
                 group by a.cfttradedate, b.BALUNIT)
         group by TRADEDATE, BALUNIT
         ORDER BY TRADEDATE, BALUNIT;
    
    end if;
  
    select 'DCDZ' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    if p_var7 = '00000000' then
      insert into TF_SUPPLY_SERIALNO_DETAIL
        select p_var9,
               TRADEDATE 交易日期,
               BALUNIT 结算单元,
               SUM(充值 - 冲正 + 回收 - 退款) 转帐
          from (select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款
                  from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.tradetypecode = '02'
                   and substr(a.BALUNITNO, 1, 2) <> '0D'
                   and a.BALUNITNO = b.BALUNITNO
                 group by a.TRADEDATE, b.BALUNIT
                union all
                select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款
                  from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.tradetypecode = '02'
                   and substr(a.BALUNITNO, 1, 2) = '0D'
                   and a.BALUNITNO = b.BALUNITNO
                 group by a.TRADEDATE, b.BALUNIT
                union all
                select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款
                  from TF_OUTSUPPLY_ADJUST a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.BALUNITNO = b.BALUNITNO
                   and a.DEALSTATECODE = '1'
                 group by a.TRADEDATE, b.BALUNIT
                union all
                select to_char(a.dealtime, 'yyyyMMdd'),
                       b.BALUNIT,
                       0 充值,
                       sum(a.TRADEMONEY) / 100.0 冲正,
                       0 回收,
                       0 退款
                  from TF_B_OUTSUPPLY_ADJUST a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.dealtime >= TO_DATE(p_var1, 'yyyy-MM-dd'))
                   and (p_var2 is null or p_var2 = '' or
                       a.dealtime <= TO_DATE(p_var2, 'yyyy-MM-dd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and a.DEALSTATECODE = '1'
                 group by to_char(a.dealtime, 'yyyyMMdd'), b.BALUNIT
                union all
                select to_char(a.dealtime, 'yyyyMMdd'),
                       b.BALUNIT,
                       0 充值,
                       0 冲正,
                       sum(a.TRADEMONEY) / 100.0 回收,
                       0 退款
                  from TF_B_OUTSUPPLY_ADJUST a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.dealtime >= TO_DATE(p_var1, 'yyyy-MM-dd'))
                   and (p_var2 is null or p_var2 = '' or
                       a.dealtime <= TO_DATE(p_var2, 'yyyy-MM-dd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and a.DEALSTATECODE = '2'
                 group by to_char(a.dealtime, 'yyyyMMdd'), b.BALUNIT
                union all
                select a.cfttradedate,
                       b.BALUNIT,
                       0 充值,
                       0 冲正,
                       0 回收,
                       sum(a.TRADEMONEY) / 100.0 退款
                  from tq_nfcrunfundback a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.cfttradedate >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.cfttradedate <= p_var2)
                   and (a.errorinfo = '' or a.errorinfo is null)
                   and a.BALUNITNO = b.BALUNITNO
                   and a.runfundstate = '1'
                 group by a.cfttradedate, b.BALUNIT)
         group by TRADEDATE, BALUNIT
         ORDER BY TRADEDATE, BALUNIT;
    else
      insert into TF_SUPPLY_SERIALNO_DETAIL
        select p_var9,
               TRADEDATE 交易日期,
               BALUNIT 结算单元,
               SUM(充值 - 冲正 + 回收 - 退款) 转帐
          from (select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款
                  from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.tradetypecode = '02'
                   and substr(a.BALUNITNO, 1, 2) <> '0D'
                   and a.BALUNITNO = p_var7
                   and a.BALUNITNO = b.BALUNITNO
                 group by a.TRADEDATE, b.BALUNIT
                union all
                select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款
                  from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.tradetypecode = '02'
                   and substr(a.BALUNITNO, 1, 2) = '0D'
                   and a.BALUNITNO = p_var7
                   and a.BALUNITNO = b.BALUNITNO
                 group by a.TRADEDATE, b.BALUNIT
                union all
                select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) / 100.0 充值,
                       0 冲正,
                       0 回收,
                       0 退款
                  from TF_OUTSUPPLY_ADJUST a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.TRADEDATE <= p_var2)
                   and a.BALUNITNO = b.BALUNITNO
                   and a.BALUNITNO = p_var7
                   and a.DEALSTATECODE = '1'
                 group by a.TRADEDATE, b.BALUNIT
                union all
                select to_char(a.dealtime, 'yyyyMMdd'),
                       b.BALUNIT,
                       0 充值,
                       sum(a.TRADEMONEY) / 100.0 冲正,
                       0 回收,
                       0 退款
                  from TF_B_OUTSUPPLY_ADJUST a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.dealtime >= TO_DATE(p_var1, 'yyyy-MM-dd'))
                   and (p_var2 is null or p_var2 = '' or
                       a.dealtime <= TO_DATE(p_var2, 'yyyy-MM-dd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and a.BALUNITNO = p_var7
                   and a.DEALSTATECODE = '1'
                 group by to_char(a.dealtime, 'yyyyMMdd'), b.BALUNIT
                union all
                select to_char(a.dealtime, 'yyyyMMdd'),
                       b.BALUNIT,
                       0 充值,
                       0 冲正,
                       sum(a.TRADEMONEY) / 100.0 回收,
                       0 退款
                  from TF_B_OUTSUPPLY_ADJUST a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.dealtime >= TO_DATE(p_var1, 'yyyy-MM-dd'))
                   and (p_var2 is null or p_var2 = '' or
                       a.dealtime <= TO_DATE(p_var2, 'yyyy-MM-dd'))
                   and a.BALUNITNO = b.BALUNITNO
                   and a.BALUNITNO = p_var7
                   and a.DEALSTATECODE = '2'
                 group by to_char(a.dealtime, 'yyyyMMdd'), b.BALUNIT
                union all
                select a.cfttradedate,
                       b.balunit,
                       0 充值,
                       0 冲正,
                       0 回收,
                       sum(a.TRADEMONEY) / 100.0 退款
                  from tq_nfcrunfundback a, TF_SELSUP_BALUNIT b
                 where (p_var1 is null or p_var1 = '' or
                       a.cfttradedate >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.cfttradedate <= p_var2)
                   and a.balunitno = b.balunitno
                   and (a.errorinfo = '' or a.errorinfo is null)
                   and a.Runfundstate = '1'
                   and a.BALUNITNO = p_var7
                 group by a.cfttradedate, b.BALUNIT)
         group by TRADEDATE, BALUNIT
         ORDER BY TRADEDATE, BALUNIT;
    end if;
    commit;
  elsif p_funcCode = 'SUPPLY_Warn_REPORT' then
    -- 代理充值告警
    open p_cursor for
      select a.TRADEDATE   交易日期,
             b.BALUNIT     结算单元名称,
             a.ID          交易流水号,
             a.CARDNO      卡号,
             a.CARDTRADENO 卡交易序号,
             a.PREMONEY    交易前余额,
             a.TRADEMONEY  交易金额,
             a.SAMNO       SAM编号,
             a.supplylocno 充值点编号
        from TF_OUTSUPPLY_ALARM a, TF_SELSUP_BALUNIT b
       where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
         and a.BALUNITNO = b.BALUNITNO
         and a.TRADETYPECODE <> '1S'
         and (p_var7 is null or p_var7 = '' or a.BALUNITNO = p_var7)
         and b.alarmstate = '1'
       order by a.TRADEDATE, b.BALUNIT;
  elsif p_funcCode = 'SUPPLY_Warn_REPORTDEPTBAL' then
    -- 代理充值告警
    open p_cursor for
      select a.TRADEDATE   交易日期,
             b.DBALUNIT    结算单元名称,
             a.ID          交易流水号,
             a.CARDNO      卡号,
             a.CARDTRADENO 卡交易序号,
             a.PREMONEY    交易前余额,
             a.TRADEMONEY  交易金额,
             a.SAMNO       SAM编号,
             a.supplylocno 充值点编号
        from TF_OUTSUPPLY_ALARM a, TF_DEPT_BALUNIT b
       where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
         and a.BALUNITNO = b.DBALUNITNO
         and a.TRADETYPECODE = '1S'
         and (p_var7 is null or p_var7 = '' or a.BALUNITNO = p_var7)
       order by a.TRADEDATE, b.DBALUNIT;
  
  elsif p_funcCode = 'WJTourReport' THEN
    --吴江旅游年卡汇总查询
    if p_var3 = '1' then
      open p_cursor for
        SELECT POSNO POS, SUM(OPENNUM) 开卡量, SUM(TRADENUM) 刷卡量
          FROM (select a.POSNO, 1 OPENNUM, 0 TRADENUM, a.SELLTIME TRADETIME
                  from TQ_TOUR_NEWCARD_RIGHT a
                 where (p_var1 is null or p_var1 = '' or
                       a.SELLTIME >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       a.SELLTIME <= p_var2)
                union all
                select b.POSNO, 0 OPENNUM, 1 TRADENUM, b.TRADEDATE TRADETIME
                  from TQ_TOUR_WJ_RIGHT b
                 where (p_var1 is null or p_var1 = '' or
                       b.TRADEDATE >= p_var1)
                   and (p_var2 is null or p_var2 = '' or
                       b.TRADEDATE <= p_var2))
         group by POSNO, TRADETIME
         order by TRADETIME, POSNO;
    elsif p_var3 = '2' then
      open p_cursor for
        SELECT DEPARTNAME 网点, STAFFNAME 操作员工, SUM(OPENNUM) 开卡量
          FROM (select d.departname  DEPARTNAME,
                       c.staffname   STAFFNAME,
                       1             OPENNUM,
                       b.operatetime OPERATETIME
                  from TF_B_TRADE b, TD_M_INSIDESTAFF c, TD_M_INSIDEDEPART d
                 where (p_var1 is null or p_var1 = '' or
                       b.operatetime >= TO_DATE(p_var1, 'yyyy-MM-dd'))
                   and (p_var2 is null or p_var2 = '' or
                       b.operatetime <= TO_DATE(p_var2, 'yyyy-MM-dd'))
                   and b.tradetypecode = '6A'
                   and b.operatedepartid = d.departno(+)
                   and b.operatestaffno = c.staffno(+)
                   and b.operatedepartid is not null --过滤非网点开卡的
                )
         group by DEPARTNAME, STAFFNAME
         order by DEPARTNAME;
    end if;
  
  elsif p_funcCode = 'WJTourReportOpenDetail' THEN
    --吴江旅游年卡开卡明细查询
    if p_var3 = '1' then
      open p_cursor for
        select a.POSNO      POS编号,
               a.CARDNO     卡号,
               a.SAMNO      PSAM编号,
               a.SELLTIME   售卡时间,
               a.ENDDATE    结束日期,
               a.DEALTIME   处理时间,
               a.INLISTTIME 入清单时间
          from TQ_TOUR_NEWCARD_RIGHT a
         where (p_var1 is null or p_var1 = '' or a.SELLTIME >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.SELLTIME <= p_var2)
         order by a.SELLTIME;
    elsif p_var3 = '2' then
      open p_cursor for
        select b.CARDNO 卡号,
               to_char(b.operatetime, 'yyyy-mm-dd') 开通时间,
               to_char(add_months(b.operatetime, 12), 'yyyy-mm-dd') 结束日期,
               b.operatetime 操作时间,
               d.departname 网点,
               c.staffname 操作员工
          from TF_B_TRADE b, TD_M_INSIDESTAFF c, TD_M_INSIDEDEPART d
         where (p_var1 is null or p_var1 = '' or
               b.operatetime >= TO_DATE(p_var1, 'yyyy-MM-dd'))
           and (p_var2 is null or p_var2 = '' or
               b.operatetime <= TO_DATE(p_var2, 'yyyy-MM-dd'))
           and b.tradetypecode = '6A'
           and b.operatedepartid = d.departno(+)
           and b.operatestaffno = c.staffno(+)
           and b.operatedepartid is not null
         order by b.operatetime;
    end if;
  
  elsif p_funcCode = 'WJTourReportConsumeDetail' THEN
    --吴江旅游年卡消费明细查询
    open p_cursor for
      select a.POSNO POS编号,
             a.CARDNO 卡号,
             a.SAMNO PSAM编号,
             a.TRADEDATE || a.TRADETIME 交易时间,
             a.SPARETIMES 剩余次数,
             a.ENDDATE 结束日期,
             a.DEALTIME 处理时间,
             a.INLISTTIME 入清单时间
        from TQ_TOUR_WJ_RIGHT a
       where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
       order by a.TRADEDATE, a.TRADETIME;
  elsif p_funcCode = 'ServiceDailyReport' THEN
    --客服网点业务统计日报
    if p_var4 is null then
      if p_var3 is null then
        --all
        open p_cursor for
          select 网点编号,
                 网点,
                 sum(退卡业务笔数) 退卡业务笔数,
                 sum(换卡业务笔数) 换卡业务笔数,
                 sum(残疾人月票换卡笔数) 残疾人月票换卡笔数,
                 sum(市民卡B卡售卡笔数) 市民卡B卡售卡笔数,
                 sum(月票卡售卡笔数) 月票卡售卡笔数,
                 sum(利金卡售卡笔数) 利金卡售卡笔数,
                 sum(充值卡售卡笔数) 充值卡售卡笔数,
                 sum(总笔数) 总笔数,
                 sum(销) 营业款总额销,
                 sum(进) 营业款总额进
            from (select e.departno 网点编号,
                         e.departname 网点,
                         count(*) 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '05' --退卡
                     and b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         count(*) 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '03' --换卡
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         count(*) 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '7C' --残疾人月票换卡
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         COUNT(*) 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '01' --市民卡售卡
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         count(*) 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE in ('31', '32', '23', '7A') --月票卡售卡
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         count(*) 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '50' --利金卡售卡
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         count(*) 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_XFC_SELL       a,
                         TD_M_INSIDEDEPART e,
                         TD_M_INSIDESTAFF  f
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.tradetypecode = '80'
                     AND A.CANCELTAG = '0' --充值卡售卡
                     AND a.STAFFNO = f.STAFFNO
                     AND f.DEPARTNO = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         count(*) 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_XFC_BATCHSELL  a,
                         TD_M_INSIDEDEPART e,
                         TD_M_INSIDESTAFF  f
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = f.STAFFNO --充值卡直销售卡
                     AND f.DEPARTNO = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         count(*) 总笔数,
                         sum(case
                               when (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                    b.FUNCFEE + b.OTHERFEE) / 100.0 > 0 then
                                (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                b.FUNCFEE + b.OTHERFEE) / 100.0
                               else
                                0
                             end) 进,
                         sum(case
                               when (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                    b.FUNCFEE + b.OTHERFEE) / 100.0 < 0 then
                                (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                b.FUNCFEE + b.OTHERFEE) / 100.0
                               else
                                0
                             end) 销
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.TRADEID = b.TRADEID(+) --营业员日报总笔数,总额
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT b.departno 网点编号,
                         b.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         count(*) 总笔数,
                         sum(case
                               when (MONEY) / 100.0 > 0 then
                                (MONEY) / 100.0
                               else
                                0
                             end) 进,
                         sum(case
                               when (MONEY) / 100.0 < 0 then
                                (MONEY) / 100.0
                               else
                                0
                             end) 销
                    FROM TF_XFC_SELL       a,
                         TD_M_INSIDEDEPART b,
                         TD_M_INSIDESTAFF  e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = e.STAFFNO --充值卡总笔数,总额
                     AND b.DEPARTNO = e.DEPARTNO
                   GROUP BY b.departname, b.departno
                  union
                  SELECT b.departno 网点编号,
                         b.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         count(*) 总笔数,
                         sum(case
                               when (TOTALMONEY) / 100.0 > 0 then
                                (TOTALMONEY) / 100.0
                               else
                                0
                             end) 进,
                         sum(case
                               when (TOTALMONEY) / 100.0 < 0 then
                                (TOTALMONEY) / 100.0
                               else
                                0
                             end) 销
                    FROM TF_XFC_BATCHSELL  a,
                         TD_M_INSIDEDEPART b,
                         TD_M_INSIDESTAFF  e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = e.STAFFNO --充值卡直销总笔数,总额
                     AND b.DEPARTNO = e.DEPARTNO
                   GROUP BY b.departname, b.departno)
           GROUP BY 网点, 网点编号
           ORDER BY 网点编号;
      elsif p_var3 = '1' then
        --代理
        open p_cursor for
          select 网点编号,
                 网点,
                 sum(退卡业务笔数) 退卡业务笔数,
                 sum(换卡业务笔数) 换卡业务笔数,
                 sum(残疾人月票换卡笔数) 残疾人月票换卡笔数,
                 sum(市民卡B卡售卡笔数) 市民卡B卡售卡笔数,
                 sum(月票卡售卡笔数) 月票卡售卡笔数,
                 sum(利金卡售卡笔数) 利金卡售卡笔数,
                 sum(充值卡售卡笔数) 充值卡售卡笔数,
                 sum(总笔数) 总笔数,
                 sum(销) 营业款总额销,
                 sum(进) 营业款总额进
            from (select e.departno 网点编号,
                         e.departname 网点,
                         count(*) 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE          a,
                         TF_B_TRADEFEE       b,
                         TD_M_INSIDEDEPART   e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '05' --退卡
                     and b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND R.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         count(*) 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE          a,
                         TF_B_TRADEFEE       b,
                         TD_M_INSIDEDEPART   e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '03' --换卡
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND R.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         count(*) 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE          a,
                         TF_B_TRADEFEE       b,
                         TD_M_INSIDEDEPART   e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '7C' --残疾人月票换卡
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND R.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         COUNT(*) 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE          a,
                         TF_B_TRADEFEE       b,
                         TD_M_INSIDEDEPART   e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '01' --市民卡售卡
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND R.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         count(*) 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE          a,
                         TF_B_TRADEFEE       b,
                         TD_M_INSIDEDEPART   e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE in ('31', '32', '23', '7A') --月票卡售卡
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND R.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         count(*) 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE          a,
                         TF_B_TRADEFEE       b,
                         TD_M_INSIDEDEPART   e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '50' --利金卡售卡
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND R.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         count(*) 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_XFC_SELL         a,
                         TD_M_INSIDEDEPART   e,
                         TD_M_INSIDESTAFF    f,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.tradetypecode = '80'
                     AND A.CANCELTAG = '0' --充值卡售卡
                     AND a.STAFFNO = f.STAFFNO
                     AND f.DEPARTNO = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND r.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         count(*) 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_XFC_BATCHSELL    a,
                         TD_M_INSIDEDEPART   e,
                         TD_M_INSIDESTAFF    f,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = f.STAFFNO --充值卡直销售卡
                     AND f.DEPARTNO = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND r.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         count(*) 总笔数,
                         sum(case
                               when (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                    b.FUNCFEE + b.OTHERFEE) / 100.0 > 0 then
                                (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                b.FUNCFEE + b.OTHERFEE) / 100.0
                               else
                                0
                             end) 进,
                         sum(case
                               when (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                    b.FUNCFEE + b.OTHERFEE) / 100.0 < 0 then
                                (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                b.FUNCFEE + b.OTHERFEE) / 100.0
                               else
                                0
                             end) 销
                    FROM TF_B_TRADE          a,
                         TF_B_TRADEFEE       b,
                         TD_M_INSIDEDEPART   e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.TRADEID = b.TRADEID(+) --营业员日报总笔数,总额
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND r.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT b.departno 网点编号,
                         b.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         count(*) 总笔数,
                         sum(case
                               when (MONEY) / 100.0 > 0 then
                                (MONEY) / 100.0
                               else
                                0
                             end) 进,
                         sum(case
                               when (MONEY) / 100.0 < 0 then
                                (MONEY) / 100.0
                               else
                                0
                             end) 销
                    FROM TF_XFC_SELL         a,
                         TD_M_INSIDEDEPART   b,
                         TD_M_INSIDESTAFF    e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = e.STAFFNO --充值卡总笔数,总额
                     AND b.DEPARTNO = e.DEPARTNO
                     AND b.DEPARTNO = r.DEPARTNO
                     AND r.USETAG = '1'
                   GROUP BY b.departname, b.departno
                  union
                  SELECT b.departno 网点编号,
                         b.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         count(*) 总笔数,
                         sum(case
                               when (TOTALMONEY) / 100.0 > 0 then
                                (TOTALMONEY) / 100.0
                               else
                                0
                             end) 进,
                         sum(case
                               when (TOTALMONEY) / 100.0 < 0 then
                                (TOTALMONEY) / 100.0
                               else
                                0
                             end) 销
                    FROM TF_XFC_BATCHSELL    a,
                         TD_M_INSIDEDEPART   b,
                         TD_M_INSIDESTAFF    e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = e.STAFFNO --充值卡直销总笔数,总额
                     AND b.DEPARTNO = e.DEPARTNO
                     AND b.DEPARTNO = r.DEPARTNO
                     AND r.USETAG = '1'
                   GROUP BY b.departname, b.departno)
           GROUP BY 网点, 网点编号
           ORDER BY 网点编号;
      elsif p_var3 = '0' then
        --直营
        open p_cursor for
          select 网点编号,
                 网点,
                 sum(退卡业务笔数) 退卡业务笔数,
                 sum(换卡业务笔数) 换卡业务笔数,
                 sum(残疾人月票换卡笔数) 残疾人月票换卡笔数,
                 sum(市民卡B卡售卡笔数) 市民卡B卡售卡笔数,
                 sum(月票卡售卡笔数) 月票卡售卡笔数,
                 sum(利金卡售卡笔数) 利金卡售卡笔数,
                 sum(充值卡售卡笔数) 充值卡售卡笔数,
                 sum(总笔数) 总笔数,
                 sum(销) 营业款总额销,
                 sum(进) 营业款总额进
            from (select e.departno 网点编号,
                         e.departname 网点,
                         count(*) 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '05' --退卡
                     and b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND a.OPERATEDEPARTID NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         count(*) 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '03' --换卡
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND a.OPERATEDEPARTID NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         count(*) 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '7C' --残疾人月票换卡
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND a.OPERATEDEPARTID NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         COUNT(*) 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '01' --市民卡售卡
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND a.OPERATEDEPARTID NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         count(*) 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE in ('31', '32', '23', '7A') --月票卡售卡
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND a.OPERATEDEPARTID NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         count(*) 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '50' --利金卡售卡
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND a.OPERATEDEPARTID NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         count(*) 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_XFC_SELL       a,
                         TD_M_INSIDEDEPART e,
                         TD_M_INSIDESTAFF  f
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.tradetypecode = '80'
                     AND A.CANCELTAG = '0' --充值卡售卡
                     AND a.STAFFNO = f.STAFFNO
                     AND f.DEPARTNO = e.DEPARTNO
                     AND e.DEPARTNO NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         count(*) 充值卡售卡笔数,
                         0 总笔数,
                         0 进,
                         0 销
                    FROM TF_XFC_BATCHSELL  a,
                         TD_M_INSIDEDEPART e,
                         TD_M_INSIDESTAFF  f
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = f.STAFFNO --充值卡直销售卡
                     AND f.DEPARTNO = e.DEPARTNO
                     AND e.DEPARTNO NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno 网点编号,
                         e.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         count(*) 总笔数,
                         sum(case
                               when (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                    b.FUNCFEE + b.OTHERFEE) / 100.0 > 0 then
                                (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                b.FUNCFEE + b.OTHERFEE) / 100.0
                               else
                                0
                             end) 进,
                         sum(case
                               when (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                    b.FUNCFEE + b.OTHERFEE) / 100.0 < 0 then
                                (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                b.FUNCFEE + b.OTHERFEE) / 100.0
                               else
                                0
                             end) 销
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.TRADEID = b.TRADEID(+) --营业员日报总笔数,总额
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND a.OPERATEDEPARTID NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT b.departno 网点编号,
                         b.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         count(*) 总笔数,
                         sum(case
                               when (MONEY) / 100.0 > 0 then
                                (MONEY) / 100.0
                               else
                                0
                             end) 进,
                         sum(case
                               when (MONEY) / 100.0 < 0 then
                                (MONEY) / 100.0
                               else
                                0
                             end) 销
                    FROM TF_XFC_SELL       a,
                         TD_M_INSIDEDEPART b,
                         TD_M_INSIDESTAFF  e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = e.STAFFNO --充值卡总笔数,总额
                     AND b.DEPARTNO = e.DEPARTNO
                     AND b.DEPARTNO NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY b.departname, b.departno
                  union
                  SELECT b.departno 网点编号,
                         b.departname 网点,
                         0 退卡业务笔数,
                         0 换卡业务笔数,
                         0 残疾人月票换卡笔数,
                         0 市民卡B卡售卡笔数,
                         0 月票卡售卡笔数,
                         0 利金卡售卡笔数,
                         0 充值卡售卡笔数,
                         count(*) 总笔数,
                         sum(case
                               when (TOTALMONEY) / 100.0 > 0 then
                                (TOTALMONEY) / 100.0
                               else
                                0
                             end) 进,
                         sum(case
                               when (TOTALMONEY) / 100.0 < 0 then
                                (TOTALMONEY) / 100.0
                               else
                                0
                             end) 销
                    FROM TF_XFC_BATCHSELL  a,
                         TD_M_INSIDEDEPART b,
                         TD_M_INSIDESTAFF  e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = e.STAFFNO --充值卡直销总笔数,总额
                     AND b.DEPARTNO = e.DEPARTNO
                     AND b.DEPARTNO NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY b.departname, b.departno)
           GROUP BY 网点, 网点编号
           ORDER BY 网点编号;
      end if;
    else
      open p_cursor for
        select 网点编号,
               网点,
               sum(退卡业务笔数) 退卡业务笔数,
               sum(换卡业务笔数) 换卡业务笔数,
               sum(残疾人月票换卡笔数) 残疾人月票换卡笔数,
               sum(市民卡B卡售卡笔数) 市民卡B卡售卡笔数,
               sum(月票卡售卡笔数) 月票卡售卡笔数,
               sum(利金卡售卡笔数) 利金卡售卡笔数,
               sum(充值卡售卡笔数) 充值卡售卡笔数,
               sum(总笔数) 总笔数,
               sum(销) 营业款总额销,
               sum(进) 营业款总额进
          from (select e.departno 网点编号,
                       e.departname 网点,
                       count(*) 退卡业务笔数,
                       0 换卡业务笔数,
                       0 残疾人月票换卡笔数,
                       0 市民卡B卡售卡笔数,
                       0 月票卡售卡笔数,
                       0 利金卡售卡笔数,
                       0 充值卡售卡笔数,
                       0 总笔数,
                       0 进,
                       0 销
                  FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   and a.TRADETYPECODE = '05' --退卡
                   and b.CANCELTAG = '0'
                   AND a.TRADEID = b.TRADEID(+)
                   AND a.OPERATEDEPARTID = e.DEPARTNO
                   AND a.OPERATEDEPARTID = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno 网点编号,
                       e.departname 网点,
                       0 退卡业务笔数,
                       count(*) 换卡业务笔数,
                       0 残疾人月票换卡笔数,
                       0 市民卡B卡售卡笔数,
                       0 月票卡售卡笔数,
                       0 利金卡售卡笔数,
                       0 充值卡售卡笔数,
                       0 总笔数,
                       0 进,
                       0 销
                  FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   and a.TRADETYPECODE = '03' --换卡
                   AND b.CANCELTAG = '0'
                   AND a.TRADEID = b.TRADEID(+)
                   AND a.OPERATEDEPARTID = e.DEPARTNO
                   AND a.OPERATEDEPARTID = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno 网点编号,
                       e.departname 网点,
                       0 退卡业务笔数,
                       0 换卡业务笔数,
                       count(*) 残疾人月票换卡笔数,
                       0 市民卡B卡售卡笔数,
                       0 月票卡售卡笔数,
                       0 利金卡售卡笔数,
                       0 充值卡售卡笔数,
                       0 总笔数,
                       0 进,
                       0 销
                  FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   and a.TRADETYPECODE = '7C' --残疾人月票换卡
                   AND b.CANCELTAG = '0'
                   AND a.TRADEID = b.TRADEID(+)
                   AND a.OPERATEDEPARTID = e.DEPARTNO
                   AND a.OPERATEDEPARTID = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno 网点编号,
                       e.departname 网点,
                       0 退卡业务笔数,
                       0 换卡业务笔数,
                       0 残疾人月票换卡笔数,
                       COUNT(*) 市民卡B卡售卡笔数,
                       0 月票卡售卡笔数,
                       0 利金卡售卡笔数,
                       0 充值卡售卡笔数,
                       0 总笔数,
                       0 进,
                       0 销
                  FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   and a.TRADETYPECODE = '01' --市民卡售卡
                   AND b.CANCELTAG = '0'
                   AND a.TRADEID = b.TRADEID(+)
                   AND a.OPERATEDEPARTID = e.DEPARTNO
                   AND a.OPERATEDEPARTID = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno 网点编号,
                       e.departname 网点,
                       0 退卡业务笔数,
                       0 换卡业务笔数,
                       0 残疾人月票换卡笔数,
                       0 市民卡B卡售卡笔数,
                       count(*) 月票卡售卡笔数,
                       0 利金卡售卡笔数,
                       0 充值卡售卡笔数,
                       0 总笔数,
                       0 进,
                       0 销
                  FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   and a.TRADETYPECODE in ('31', '32', '23', '7A') --月票卡售卡
                   AND b.CANCELTAG = '0'
                   AND a.TRADEID = b.TRADEID(+)
                   AND a.OPERATEDEPARTID = e.DEPARTNO
                   AND a.OPERATEDEPARTID = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno 网点编号,
                       e.departname 网点,
                       0 退卡业务笔数,
                       0 换卡业务笔数,
                       0 残疾人月票换卡笔数,
                       0 市民卡B卡售卡笔数,
                       0 月票卡售卡笔数,
                       count(*) 利金卡售卡笔数,
                       0 充值卡售卡笔数,
                       0 总笔数,
                       0 进,
                       0 销
                  FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   and a.TRADETYPECODE = '50' --利金卡售卡
                   AND b.CANCELTAG = '0'
                   AND a.TRADEID = b.TRADEID(+)
                   AND a.OPERATEDEPARTID = e.DEPARTNO
                   AND a.OPERATEDEPARTID = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno 网点编号,
                       e.departname 网点,
                       0 退卡业务笔数,
                       0 换卡业务笔数,
                       0 残疾人月票换卡笔数,
                       0 市民卡B卡售卡笔数,
                       0 月票卡售卡笔数,
                       0 利金卡售卡笔数,
                       count(*) 充值卡售卡笔数,
                       0 总笔数,
                       0 进,
                       0 销
                  FROM TF_XFC_SELL       a,
                       TD_M_INSIDEDEPART e,
                       TD_M_INSIDESTAFF  f
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   and a.tradetypecode = '80'
                   AND A.CANCELTAG = '0' --充值卡售卡
                   AND a.STAFFNO = f.STAFFNO
                   AND f.DEPARTNO = e.DEPARTNO
                   AND e.DEPARTNO = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno 网点编号,
                       e.departname 网点,
                       0 退卡业务笔数,
                       0 换卡业务笔数,
                       0 残疾人月票换卡笔数,
                       0 市民卡B卡售卡笔数,
                       0 月票卡售卡笔数,
                       0 利金卡售卡笔数,
                       count(*) 充值卡售卡笔数,
                       0 总笔数,
                       0 进,
                       0 销
                  FROM TF_XFC_BATCHSELL  a,
                       TD_M_INSIDEDEPART e,
                       TD_M_INSIDESTAFF  f
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   AND a.STAFFNO = f.STAFFNO --充值卡直销售卡
                   AND f.DEPARTNO = e.DEPARTNO
                   AND f.DEPARTNO = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno 网点编号,
                       e.departname 网点,
                       0 退卡业务笔数,
                       0 换卡业务笔数,
                       0 残疾人月票换卡笔数,
                       0 市民卡B卡售卡笔数,
                       0 月票卡售卡笔数,
                       0 利金卡售卡笔数,
                       0 充值卡售卡笔数,
                       count(*) 总笔数,
                       sum(case
                             when (b.CARDSERVFEE + b.CARDDEPOSITFEE +
                                  b.SUPPLYMONEY + b.TRADEPROCFEE + b.FUNCFEE +
                                  b.OTHERFEE) / 100.0 > 0 then
                              (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY +
                              b.TRADEPROCFEE + b.FUNCFEE + b.OTHERFEE) / 100.0
                             else
                              0
                           end) 进,
                       sum(case
                             when (b.CARDSERVFEE + b.CARDDEPOSITFEE +
                                  b.SUPPLYMONEY + b.TRADEPROCFEE + b.FUNCFEE +
                                  b.OTHERFEE) / 100.0 < 0 then
                              (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY +
                              b.TRADEPROCFEE + b.FUNCFEE + b.OTHERFEE) / 100.0
                             else
                              0
                           end) 销
                  FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   AND a.TRADEID = b.TRADEID(+) --营业员日报总笔数,总额
                   AND a.OPERATEDEPARTID = e.DEPARTNO
                   AND a.OPERATEDEPARTID = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT b.departno 网点编号,
                       b.departname 网点,
                       0 退卡业务笔数,
                       0 换卡业务笔数,
                       0 残疾人月票换卡笔数,
                       0 市民卡B卡售卡笔数,
                       0 月票卡售卡笔数,
                       0 利金卡售卡笔数,
                       0 充值卡售卡笔数,
                       count(*) 总笔数,
                       sum(case
                             when (MONEY) / 100.0 > 0 then
                              (MONEY) / 100.0
                             else
                              0
                           end) 进,
                       sum(case
                             when (MONEY) / 100.0 < 0 then
                              (MONEY) / 100.0
                             else
                              0
                           end) 销
                  FROM TF_XFC_SELL       a,
                       TD_M_INSIDEDEPART b,
                       TD_M_INSIDESTAFF  e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   AND a.STAFFNO = e.STAFFNO --充值卡总笔数,总额
                   AND b.DEPARTNO = e.DEPARTNO
                   AND b.DEPARTNO = p_var4
                 GROUP BY b.departname, b.departno
                union
                SELECT b.departno 网点编号,
                       b.departname 网点,
                       0 退卡业务笔数,
                       0 换卡业务笔数,
                       0 残疾人月票换卡笔数,
                       0 市民卡B卡售卡笔数,
                       0 月票卡售卡笔数,
                       0 利金卡售卡笔数,
                       0 充值卡售卡笔数,
                       count(*) 总笔数,
                       sum(case
                             when (TOTALMONEY) / 100.0 > 0 then
                              (TOTALMONEY) / 100.0
                             else
                              0
                           end) 进,
                       sum(case
                             when (TOTALMONEY) / 100.0 < 0 then
                              (TOTALMONEY) / 100.0
                             else
                              0
                           end) 销
                  FROM TF_XFC_BATCHSELL  a,
                       TD_M_INSIDEDEPART b,
                       TD_M_INSIDESTAFF  e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   AND a.STAFFNO = e.STAFFNO --充值卡直销总笔数,总额
                   AND b.DEPARTNO = e.DEPARTNO
                   AND b.DEPARTNO = p_var4
                 GROUP BY b.departname, b.departno)
         GROUP BY 网点, 网点编号
         ORDER BY 网点编号;
    end if;
  elsif p_funcCode = 'ParkCardChangDetail' THEN
    --园林年卡补换卡明细
    open p_cursor for
      SELECT e.departname 部门,
             nvl(d.staffname, a.OPERATESTAFFNO) 营业员,
             c.CUSTNAME 姓名,
             c.PAPERNO 身份证号,
             a.OLDCARDNO 老卡号,
             a.CARDNO 新卡号,
             b.ENDDATE 有效期,
             b.SPARETIMES 剩余次数,
             a.OPERATETIME 交易时间
        FROM tf_b_trade          a,
             TF_F_CARDPARKACC_SZ b,
             TF_F_CUSTOMERREC    c,
             TD_M_INSIDESTAFF    d,
             TD_M_INSIDEDEPART   e
       WHERE a.CARDNO = b.CARDNO
         AND a.CARDNO = c.CARDNO
         AND a.OPERATETIME >=
             to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and a.OPERATETIME <=
             to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         AND a.OPERATESTAFFNO = d.STAFFNO(+)
         AND e.DEPARTNO = a.OPERATEDEPARTID
         AND a.TRADETYPECODE = '36'
         AND (a.RSRV1 IS NULL OR a.RSRV1 = '1') --表示以前的园林换卡数据和未过期的园林补换卡数据
         AND (p_var3 is null or p_var3 = '' or p_var3 = a.OPERATESTAFFNO)
         AND (p_var10 is null or p_var10 = '' or
             p_var10 = a.OPERATEDEPARTID);
  
  elsif p_funcCode = 'JIANGYIN_REPORT' then
    --江阴账单
    open p_cursor for
      select to_char(A.Begintime, 'yyyymmdd') 账期开始日期,
             to_char(A.Endtime, 'yyyymmdd') 账期结束日期,
             A.TRANSFEE / 100.0 苏信应付,
             B.TRANSFEE / 100.0 苏信应收
        from tf_trade_outcomefin A, tf_trade_outcomefin B
       where A.begintime = B.begintime
         and A.endTime = B.endtime
         and A.BALUNITNO = '01H00005' -- 江阴市民卡公司
         and B.BALUNITNO = '01H00006' -- 张家港公交公司
         and (p_var1 is null or p_var1 = '' or
             to_char(a.ENDTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
         and (p_var2 is null or p_var2 = '' or
             to_char(a.ENDTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
       order by A.endTime desc;
  
  elsif p_funcCode = 'JIANGYIN_FILE_REPORT' then
    --江阴账单  文件处理信息
    open p_cursor for
      select tf.filename 文件名,
             decode(tf.dealstatecode,
                    '0',
                    '未处理',
                    '1',
                    '已处理',
                    '2',
                    '处理失败',
                    '3',
                    '正在处理',
                    '4',
                    '文件未入库',
                    tf.dealstatecode) 处理状态,
             Z.zcount 正常交易笔数,
             Z.zsum / 100.0 正常交易金额,
             J.jcount 拒付交易笔数,
             J.jsum / 100.0 拒付交易金额,
             T.tcount 调整交易笔数,
             T.tsum / 100.0 调整交易金额,
             to_char(tf.inlisttime, 'yyyymmdd') 入库时间
        from TF_SWAP_FILE_JY tf
        left join (select r.SOURCEFILENAME filename,
                          count(r.sourcefilename) zcount,
                          sum(r.trademoney) zsum
                     from TF_SWAP_RIGHT_JY r
                    where (p_var1 is null or p_var1 = '' or
                          to_char(r.inlisttime, 'yyyymmdd') >=
                          to_char(to_date(p_var1, 'yyyymmdd'), 'yyyymmdd'))
                      and (p_var2 is null or p_var2 = '' or
                          to_char(r.inlisttime, 'yyyymmdd') <=
                          to_char(to_date(p_var2, 'yyyymmdd'), 'yyyymmdd'))
                    group by r.sourcefilename) Z
          on tf.filename = Z.filename
      
        left join (select s.sourcefilename filename,
                          count(s.sourcefilename) jcount,
                          sum(s.trademoney) jsum
                     from TF_SWAP_REFUSE_JY s
                    where s.REFUSECAUSE != '00'
                      and (p_var1 is null or p_var1 = '' or
                          to_char(s.inlisttime, 'yyyymmdd') >=
                          to_char(to_date(p_var1, 'yyyymmdd'), 'yyyymmdd'))
                      and (p_var2 is null or p_var2 = '' or
                          to_char(s.inlisttime, 'yyyymmdd') <=
                          to_char(to_date(p_var2, 'yyyymmdd'), 'yyyymmdd'))
                    group by s.sourcefilename) J
          on tf.filename = J.filename
      
        left join (select s.sourcefilename filename,
                          count(s.sourcefilename) tcount,
                          sum(s.trademoney) tsum
                     from TF_SWAP_REFUSE_JY s
                    where s.REFUSECAUSE = '00'
                      and (p_var1 is null or p_var1 = '' or
                          to_char(s.inlisttime, 'yyyymmdd') >=
                          to_char(to_date(p_var1, 'yyyymmdd'), 'yyyymmdd'))
                      and (p_var2 is null or p_var2 = '' or
                          to_char(s.inlisttime, 'yyyymmdd') <=
                          to_char(to_date(p_var2, 'yyyymmdd'), 'yyyymmdd'))
                    group by s.sourcefilename) T
          on tf.filename = T.filename
       where (p_var1 is null or p_var1 = '' or
             to_char(tf.inlisttime, 'yyyymmdd') >=
             to_char(to_date(p_var1, 'yyyymmdd'), 'yyyymmdd'))
         and (p_var2 is null or p_var2 = '' or
             to_char(tf.inlisttime, 'yyyymmdd') <=
             to_char(to_date(p_var2, 'yyyymmdd'), 'yyyymmdd'))
       order by tf.inlisttime desc, tf.filename;
  elsif p_funcCode = 'SZTC_COMERENEWREPORT' then
    --旅游卡转收入
    open p_cursor for
      SELECT to_char(A.OPERATETIME, 'yyyymmdd') OPERATETIME,
             b.DEPARTNAME,
             COUNT(a.TRADEID) COUNTNUM,
             SUM(a.TRADEPROCFEE / 100.0) TRADEPROCFEE,
             SUM(a.DEPOSIT / 100.0) DEPOSIT,
             SUM(a.TRADEPROCFEE / 100.0) + SUM(a.DEPOSIT / 100.0) SUMMONEY
        FROM TF_B_TRADE_SZTRAVEL a, TD_M_INSIDEDEPART b
       WHERE a.OPERATEDEPARTID = b.DEPARTNO
         AND (p_var1 = '' or p_var1 is null or
             p_var1 <= to_char(A.OPERATETIME, 'yyyymmdd'))
         AND (p_var2 = '' or p_var2 is null or
             p_var2 >= to_char(A.OPERATETIME, 'yyyymmdd'))
         AND (p_var3 = '' or p_var3 is null or p_var3 = a.OPERATEDEPARTID)
       GROUP BY to_char(A.OPERATETIME, 'yyyymmdd'), b.DEPARTNAME
       ORDER BY 1, 2;
  elsif p_funcCode = 'SZTC_REFUNDTRANSFERREPORT' then
    --旅游卡客户退款
    select 'SZTC' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
  
    open p_cursor for
      SELECT BANKNAME,
             BANKNAME || BANKNAMESUB BANKLIST,
             BANKACCNO,
             CUSTNAME,
             BACKMONEY / 100.0 BACKMONEY,
             BACKDEPOSIT / 100.0 BACKDEPOSIT,
             BACKMONEY / 100.0 + BACKDEPOSIT / 100.0 BACKALL,
             CARDNO,
             d.PAPERTYPENAME,
             PAPERNO,
             CUSTPHONE,
             c.STAFFNAME,
             b.DEPARTNAME,
             to_char(OPERATETIME, 'yyyymmdd') OPERATETIME,
             a.REMARK,
             PURPOSETYPE
        FROM TF_B_TRADE_SZTRAVEL_RF a,
             TD_M_INSIDEDEPART      b,
             TD_M_INSIDESTAFF       c,
             TD_M_PAPERTYPE         d
       WHERE a.OPERATEDEPARTID = b.DEPARTNO
         AND a.OPERATESTAFFNO = c.STAFFNO
         AND a.ISUPDATED = '1' --已更新退卡金额
         AND a.PAPERTYPECODE = d.PAPERTYPECODE(+)
         AND (p_var1 = '' or p_var1 is null or
             p_var1 <= to_char(A.OPERATETIME, 'yyyymmdd'))
         AND (p_var2 = '' or p_var2 is null or
             p_var2 >= to_char(A.OPERATETIME, 'yyyymmdd'))
         AND (p_var3 = '' or p_var3 is null or p_var3 = a.OPERATEDEPARTID)
         AND (p_var4 = '' or p_var4 is null or p_var4 = a.OPERATESTAFFNO)
       ORDER BY 15, 1;
  elsif p_funcCode = 'queryEOCSpeAdjustAcc' THEN
    --查询沉淀资金特殊调账记录
    open p_cursor for
      SELECT a.ID, a.STATTIME, a.CATEGORY, a.MONEY / 100.0 MONEY, a.REMARK
        FROM TF_FUNDSANALYSIS a
       WHERE a.NAME = '财务调账'
         AND a.STATTIME >= p_var1
         and a.STATTIME <= p_var2
         AND (p_var3 is null or p_var3 = '' or p_var3 = a.CATEGORY);
  elsif p_funcCode = 'queryBFJTradeRecord' THEN
    --查询系统业务账单表
    open p_cursor for
      SELECT a.TRADEID ID,
             a.TRADEDATE STATTIME,
             DECODE(a.AMOUNTTYPE, '0', '收入', '1', '支出') CATEGORY,
             a.TRADEMONEY / 100.0 MONEY,
             a.REMARK
        FROM TF_F_BFJ_TRADERECORD a
       WHERE a.NAME LIKE '%备付金手工录入%'
         AND a.TRADEDATE >= to_date(p_var1, 'YYYYMMDD')
         and a.TRADEDATE <= to_date(p_var2, 'YYYYMMDD')
         AND (p_var3 is null or p_var3 = '' or
             DECODE(p_var3, '沉淀资金收入', '0', '沉淀资金支出', '1') = a.AMOUNTTYPE);
  
  elsif p_funcCode = 'AREAQUERY' then
    open p_cursor for
      SELECT A.REGIONNAME, A.REGIONCODE
        FROM TD_M_REGIONCODE A, td_m_insidedepart b
       WHERE A.ISUSETAG = '1'
         and b.departno = p_var1
         and (b.regioncode is null or b.regioncode = a.regioncode)
       ORDER BY A.REGIONCODE;
  elsif p_funcCode = 'DEPTEBALTRADE_SPE' then
    --网点转帐日报
    open p_cursor for
      SELECT 网点编号,
             网点名称,
             sum(押金退还) 押金退还,
             sum(旅游卡押金退还) 旅游卡押金退还,
             sum(销户金额) 销户金额
        FROM (SELECT D.DEPARTNO 网点编号,
                     D.DEPARTNAME 网点名称,
                     sum(B.CARDSERVFEE + B.CARDDEPOSITFEE + B.SUPPLYMONEY +
                         B.TRADEPROCFEE + B.FUNCFEE + B.OTHERFEE) / 100.0 押金退还,
                     0 旅游卡押金退还,
                     0 销户金额
                FROM TF_B_TRADE A, TF_B_TRADEFEE B, TD_M_INSIDEDEPART D
               WHERE ((A.TRADETYPECODE = '03' AND
                     A.CARDNO NOT LIKE '215018%' AND
                     (B.CARDSERVFEE + B.CARDDEPOSITFEE + B.SUPPLYMONEY +
                     B.TRADEPROCFEE + B.FUNCFEE + B.OTHERFEE) < 0) --换卡退还押金
                     OR A.TRADETYPECODE = '76' --月票升高龄退还
                     )
                 AND A.TRADEID = B.TRADEID(+)
                 AND A.OPERATEDEPARTID = D.DEPARTNO
                 AND A.OPERATETIME >=
                     TO_DATE(P_VAR1 || '000000', 'YYYYMMDDHH24MISS')
                 AND A.OPERATETIME <=
                     TO_DATE(P_VAR2 || '235959', 'YYYYMMDDHH24MISS')
                 AND (P_VAR3 IS NULL OR P_VAR3 = '' OR
                     P_VAR3 = A.OPERATEDEPARTID)
               GROUP BY D.DEPARTNO, D.DEPARTNAME
              UNION ALL
              SELECT D.DEPARTNO 网点编号,
                     D.DEPARTNAME 网点名称,
                     sum(B.CARDDEPOSITFEE) / 100.0 押金退还,
                     0 旅游卡押金退还,
                     0 销户金额
                FROM TF_B_TRADE A, TF_B_TRADEFEE B, TD_M_INSIDEDEPART D
               WHERE ((a.TRADETYPECODE = '05' AND
                     a.REASONCODE IN ('11', '12', '13', '15')) OR
                     a.TRADETYPECODE = 'A5' --退卡退押金 |||| modify by jiangbb 增加15不可读自然损 from may 12 邮件
                     )
                 AND A.TRADEID = B.TRADEID(+)
                 AND A.OPERATEDEPARTID = D.DEPARTNO
                 AND A.OPERATETIME >=
                     TO_DATE(P_VAR1 || '000000', 'YYYYMMDDHH24MISS')
                 AND A.OPERATETIME <=
                     TO_DATE(P_VAR2 || '235959', 'YYYYMMDDHH24MISS')
                 AND (P_VAR3 IS NULL OR P_VAR3 = '' OR
                     P_VAR3 = A.OPERATEDEPARTID)
               GROUP BY D.DEPARTNO, D.DEPARTNAME
              UNION ALL
              SELECT D.DEPARTNO 网点编号,
                     D.DEPARTNAME 网点名称,
                     0 押金退还,
                     SUM(DECODE(A.TRADETYPECODE, '7K', B.CARDDEPOSITFEE, 0)) /
                     100.0 旅游卡押金退还,
                     sum(B.SUPPLYMONEY) / 100.0 销户金额
                FROM TF_B_TRADE A, TF_B_TRADEFEE B, TD_M_INSIDEDEPART D
               WHERE (A.TRADETYPECODE = '06' --销户(不可读卡退卡的)
                     OR ((a.TRADETYPECODE = '05' AND
                     a.REASONCODE in ('11', '12', '13')) OR
                     a.TRADETYPECODE = 'A5') --(可读卡退卡的)
                     OR A.TRADETYPECODE = '7K') --旅游卡回收（可读卡）
                 AND A.TRADEID = B.TRADEID(+)
                 AND A.OPERATEDEPARTID = D.DEPARTNO
                 AND A.OPERATETIME >=
                     TO_DATE(P_VAR1 || '000000', 'YYYYMMDDHH24MISS')
                 AND A.OPERATETIME <=
                     TO_DATE(P_VAR2 || '235959', 'YYYYMMDDHH24MISS')
                 AND (P_VAR3 IS NULL OR P_VAR3 = '' OR
                     P_VAR3 = A.OPERATEDEPARTID)
               GROUP BY D.DEPARTNO, D.DEPARTNAME)
       GROUP BY 网点编号, 网点名称
       ORDER BY 网点编号;
  elsif p_funcCode = 'QUERYTRADETYPE' then
    --查询支持团购的业务类型
    open p_cursor for
      SELECT b.TRADETYPE, b.TRADETYPECODE
        FROM TD_M_GROUPBUY_TRADETYPE a, TD_M_TRADETYPE b
       WHERE a.TRADETYPECODE = b.TRADETYPECODE
	   ORDER BY 2;
  elsif p_funcCode = 'QUERYTRADETYPESHOP' then
    --查询支持团购的商家
    open p_cursor for
      SELECT SHOPNAME, SHOPID FROM TD_M_GROUPBUY_SHOP;
  elsif p_funcCode = 'QUERYGROUPBUYEXIST' then
    --查询已经存在商家的团购劵
    open p_cursor for
      SELECT a.CODE
        FROM TF_F_GROUPBUY_RECORD a
       WHERE p_var1 = a.CODE
         AND p_var2 = a.SHOPID
         AND a.CANCELCODE = '0';
  
  elsif p_funcCode = 'QUERYGROUPBUYMARK' then
    --查询业务台账报表
    open p_cursor for
      select a.TRADEID,
             a.CARDNO 卡号,
             c.TRADETYPE 交易类型,
             b.CARDSERVFEE / 100.0 卡服务费,
             b.CARDDEPOSITFEE / 100.0 卡押金,
             b.SUPPLYMONEY / 100.0 充值,
             b.TRADEPROCFEE / 100.0 手续费,
             b.FUNCFEE / 100.0 功能费,
             b.OTHERFEE / 100.0 其它费,
             a.OPERATETIME 交易时间
        FROM TF_B_TRADE        a,
             TF_B_TRADEFEE     b,
             TD_M_TRADETYPE    c,
             TD_M_INSIDESTAFF  d,
             TD_M_INSIDEDEPART e
       WHERE a.OPERATETIME >=
             to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and a.OPERATETIME <=
             to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         AND (A.TRADETYPECODE IN
             (SELECT DISTINCT F.TRADETYPECODE
                 FROM TD_M_GROUPBUY_TRADETYPE F))
         AND (P_VAR6 is null or P_VAR6 = '' OR
             (P_VAR6 IN ('01', '02') AND A.CARDTYPECODE = '51' AND
             A.TRADETYPECODE = P_VAR6) OR (A.TRADETYPECODE = P_VAR6))
         and a.TRADETYPECODE = c.TRADETYPECODE
         AND a.TRADEID = b.TRADEID(+)
         AND a.OPERATESTAFFNO = d.STAFFNO(+)
         AND (p_var3 is null or p_var3 = '' or p_var3 = d.STAFFNO)
         AND e.DEPARTNO = a.OPERATEDEPARTID
         AND (p_var5 is null or p_var5 = '' or p_var5 = e.DEPARTNO)
         AND (A.TRADEID not IN
             (SELECT DISTINCT g.TRADEID
                 FROM TF_F_GROUPBUY_TRADE g
                WHERE g.CANCELCODE = '0'))
         AND (P_VAR7 is null or P_VAR7 = '' OR A.CARDNO = P_VAR7)
       ORDER BY a.cardno, a.OPERATETIME DESC;
  elsif p_funcCode = 'QUERYGROUPBUYNOS' then
    --查询团购劵号
    open p_cursor for
      select a."ID",
             a.CODE       团购劵号,
             b.SHOPNAME   团购商家,
             d.STAFFNAME  操作人,
             e.DEPARTNAME 操作部门,
             a.UPDATETIME 操作时间,
             a.REMARK     备注
      
        FROM TF_F_GROUPBUY_RECORD a,
             TD_M_GROUPBUY_SHOP   b,
             TD_M_INSIDESTAFF     d,
             TD_M_INSIDEDEPART    e
       WHERE a.UPDATETIME >=
             to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and a.UPDATETIME <=
             to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         AND a.SHOPID = b.SHOPID
         AND a.UPDATESTAFFNO = d.STAFFNO(+)
         AND (p_var3 is null or p_var3 = '' or p_var3 = d.STAFFNO)
         AND e.DEPARTNO = a.UPDATEDEPARTID
         AND (p_var4 is null or p_var4 = '' or p_var4 = e.DEPARTNO)
         AND (p_var5 is null or p_var5 = '' or p_var5 = b.SHOPID)
         AND (p_var6 is null or p_var6 = '' or p_var6 = a.CODE)
         AND a.CANCELCODE = '0';
  
  elsif p_funcCode = 'QUERYGROUPBUYNOLINKTRADES' then
    --查询团购劵号关联业务信息
    open p_cursor for
      select a.TRADEID,
             e.departname 部门,
             nvl(d.staffname, a.OPERATESTAFFNO) 营业员,
             a.CARDNO 卡号,
             c.TRADETYPE 交易类型,
             b.CARDSERVFEE / 100.0 卡服务费,
             b.CARDDEPOSITFEE / 100.0 卡押金,
             b.SUPPLYMONEY / 100.0 充值,
             b.TRADEPROCFEE / 100.0 手续费,
             b.FUNCFEE / 100.0 功能费,
             b.OTHERFEE / 100.0 其它费,
             a.OPERATETIME 交易时间
        FROM TF_B_TRADE           a,
             TF_B_TRADEFEE        b,
             TD_M_TRADETYPE       c,
             TD_M_INSIDESTAFF     d,
             TD_M_INSIDEDEPART    e,
             TF_F_GROUPBUY_RECORD f,
             TF_F_GROUPBUY_TRADE  g,
             TD_M_GROUPBUY_SHOP   h
       WHERE a.TRADETYPECODE = c.TRADETYPECODE
         AND a.TRADEID = b.TRADEID(+)
         AND a.OPERATESTAFFNO = d.STAFFNO(+)
         AND e.DEPARTNO = a.OPERATEDEPARTID
         AND a.TRADEID = g.TRADEID
         AND g.GROUPID = f."ID"
         AND f.SHOPID = h.SHOPID
         AND (p_var1 = f.CODE)
         AND (p_var2 = h.SHOPNAME)
         AND g.CANCELCODE = '0'
       ORDER BY a.OPERATETIME DESC;
  elsif p_funcCode = 'QUERYGROUPBUYDETAILREPORTS' then
    --查询团购业务报表明细
    open p_cursor for
      select h.UPDATETIME 操作时间,
             h.CODE 团购劵号,
             I.SHOPNAME 团购商家,
             e.departname 部门,
             nvl(d.staffname, a.OPERATESTAFFNO) 营业员,
             a.CARDNO 卡号,
             c.TRADETYPE 交易类型,
             b.CARDSERVFEE / 100.0 + b.CARDDEPOSITFEE / 100.0 服务费和押金,
             b.SUPPLYMONEY / 100.0 充值,
             b.TRADEPROCFEE / 100.0 手续费,
             b.FUNCFEE / 100.0 功能费,
             (CASE
               WHEN a.CANCELTAG = '1' THEN
                '该业务已回退'
               ELSE
                ''
             END) 提示
        FROM TF_B_TRADE           a,
             TF_B_TRADEFEE        b,
             TD_M_TRADETYPE       c,
             TD_M_INSIDESTAFF     d,
             TD_M_INSIDEDEPART    e,
             TF_F_GROUPBUY_TRADE  g,
             TF_F_GROUPBUY_RECORD h,
             TD_M_GROUPBUY_SHOP   I
       WHERE h.UPDATETIME >=
             to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and h.UPDATETIME <=
             to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         AND h.SHOPID = I.SHOPID
         AND h."ID" = g.GROUPID
         AND g.TRADEID = a.TRADEID
         AND a.TRADETYPECODE = c.TRADETYPECODE
         AND a.TRADEID = b.TRADEID(+)
         AND a.OPERATESTAFFNO = d.STAFFNO(+)
         AND e.DEPARTNO = a.OPERATEDEPARTID
         AND (p_var3 is null or p_var3 = '' or p_var3 = h.UPDATESTAFFNO)
         AND (p_var4 is null or p_var4 = '' or p_var4 = h.UPDATEDEPARTID)
         AND (p_var5 is null or p_var5 = '' or p_var5 = I.SHOPID)
         AND g.CANCELCODE = '0'
       order by h.UPDATETIME DESC;
  elsif p_funcCode = 'QUERYGROUPBUYREPORTS' then
    --查询团购业务报表
    open p_cursor for
      select TO_CHAR(h.UPDATETIME, 'YYYYMMDD') 操作日期,
             I.SHOPNAME 团购商家,
             SUM(b.CARDSERVFEE / 100.0 + b.CARDDEPOSITFEE / 100.0 +
                 b.SUPPLYMONEY / 100.0 + b.TRADEPROCFEE / 100.0 +
                 b.FUNCFEE / 100.0 + b.OTHERFEE / 100.0) 金额,
             COUNT(g.TRADEID) 笔数,
             (CASE
               WHEN COUNT(f.tradeid) = '0' THEN
                ''
               ELSE
                '该业务已回退'
             END) 提示
        FROM TF_F_GROUPBUY_TRADE g,
             TF_F_GROUPBUY_RECORD h,
             TD_M_GROUPBUY_SHOP I,
             TF_B_TRADE a,
             TF_B_TRADEFEE b,
             TD_M_INSIDESTAFF d,
             TD_M_INSIDEDEPART e,
             (select t.tradeid
                from TF_F_GROUPBUY_TRADE g
               inner join tf_b_trade t
                  on g.TRADEID = t.TRADEID
                 and t.CANCELTAG = '1') f
       WHERE h.UPDATETIME >=
             to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and h.UPDATETIME <=
             to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         AND h.SHOPID = I.SHOPID
         AND h."ID" = g.GROUPID
         AND g.TRADEID = a.TRADEID
         AND a.tradeid = f.tradeid(+)
         AND a.TRADEID = b.TRADEID(+)
         AND a.OPERATESTAFFNO = d.STAFFNO(+)
         AND e.DEPARTNO = a.OPERATEDEPARTID
         AND (p_var3 is null or p_var3 = '' or p_var3 = h.UPDATESTAFFNO)
         AND (p_var4 is null or p_var4 = '' or p_var4 = h.UPDATEDEPARTID)
         AND (p_var5 is null or p_var5 = '' or p_var5 = I.SHOPID)
         AND g.CANCELCODE = '0'
       GROUP BY TO_CHAR(h.UPDATETIME, 'YYYYMMDD'), I.SHOPNAME
       order by TO_CHAR(h.UPDATETIME, 'YYYYMMDD') DESC;
  ELSIF P_FUNCCODE = 'QUERYLRTTRECOVERCOUNT' THEN
    --轻轨异常回收汇总
    OPEN P_CURSOR FOR
      SELECT TO_CHAR(T.DEALTIME, 'YYYYMMDD') 交易时间,
             SUM(T.TRADEMONEY) / 100.0 交易金额
        FROM TF_TRAIN_RENEW_ERROR T
       WHERE (P_VAR1 IS NULL OR P_VAR1 = '' OR
             T.DEALTIME >= TO_DATE(P_VAR1 || '000000', 'YYYYMMDDHH24MISS'))
         AND (P_VAR2 IS NULL OR P_VAR2 = '' OR
             T.DEALTIME <= TO_DATE(P_VAR2 || '235959', 'YYYYMMDDHH24MISS'))
         AND T.DEALSTATECODE = '3'
       GROUP BY TO_CHAR(T.DEALTIME, 'YYYYMMDD')
       order by 1;
  ELSIF P_FUNCCODE = 'QUERYLRTTRECOVERLIST' THEN
    --轻轨异常回收明细
    OPEN P_CURSOR FOR
      SELECT TO_CHAR(T.DEALTIME, 'YYYYMMDD') 交易时间,
             T.CARDNO 卡号,
             T.CARDTRADENO 卡序列号,
             T.PREMONEY / 100.0 交易前金额,
             T.TRADEMONEY / 100.0 交易金额,
             (T.PREMONEY - T.TRADEMONEY) / 100.0 交易后金额
        FROM TF_TRAIN_RENEW_ERROR T
       WHERE (P_VAR1 IS NULL OR P_VAR1 = '' OR
             T.DEALTIME >= TO_DATE(P_VAR1 || '000000', 'YYYYMMDDHH24MISS'))
         AND (P_VAR2 IS NULL OR P_VAR2 = '' OR
             T.DEALTIME <= TO_DATE(P_VAR2 || '235959', 'YYYYMMDDHH24MISS'))
         AND T.DEALSTATECODE = '3'
       order by 1;
  
  ELSIF P_FUNCCODE = 'QUERYRELAXNEWREPORT' THEN
    OPEN P_CURSOR FOR
      SELECT PAYCANAL,
             PACKAGETYPENAME,
             SUM(opentimes) opentimes,
             SUM(CARDCOST) CARDCOST,
             SUM(FUNCFEE) FUNCFEE,
             SUM(ptdiscount) ptdiscount,
             SUM(dhDISCOUNT) dhDISCOUNT,
             SUM(POSTAGE) POSTAGE,
             SUM(ORDERFEE) ORDERFEE
        FROM (SELECT DECODE(PAYCANAL,
                            '01',
                            '支付宝',
                            '02',
                            '微信',
                            '03',
                            '银联',
                            '04',
                            '兑换码',
                            PAYCANAL) PAYCANAL,
                     M.PACKAGETYPENAME,
                     COUNT(1) opentimes,
                     SUM(F.CARDCOST / 100.0) CARDCOST,
                     SUM(F.FUNCFEE / 100.0) FUNCFEE,
                     0 ptdiscount,
                     -ABS(SUM(F.DISCOUNT / 100.0)) dhDISCOUNT,
                     0 POSTAGE,
                     NVL(SUM(F.CARDCOST / 100.0), 0) +
                     NVL(SUM(F.FUNCFEE / 100.0), 0) -
                     ABS(NVL(SUM(F.DISCOUNT / 100.0), 0)) ORDERFEE
                FROM TF_F_XXOL_ORDER       T,
                     TF_F_XXOL_ORDERDETAIL F,
                     TD_M_PACKAGETYPE      M
               WHERE T.ORDERNO = F.ORDERNO
                 AND (P_VAR1 IS NULL OR P_VAR1 = '' OR
                     T.INSTIME >=
                     TO_DATE(P_VAR1 || '000000', 'YYYYMMDDHH24MISS'))
                 AND (P_VAR2 IS NULL OR P_VAR2 = '' OR
                     T.INSTIME <=
                     TO_DATE(P_VAR2 || '235959', 'YYYYMMDDHH24MISS'))
                 AND (P_VAR3 IS NULL OR P_VAR3 = '' OR P_VAR3 = T.ORDERTYPE)
                 AND (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = T.PAYCANAL)
                 AND F.PACKAGETYPE = M.PACKAGETYPECODE(+)
                 and f.CHARGENO is not null --兑换码
               GROUP BY M.PACKAGETYPENAME, T.PAYCANAL
              UNION ALL
              SELECT DECODE(PAYCANAL,
                            '01',
                            '支付宝',
                            '02',
                            '微信',
                            '03',
                            '银联',
                            '04',
                            '兑换码',
                            PAYCANAL) PAYCANAL,
                     M.PACKAGETYPENAME,
                     COUNT(1) opentimes,
                     SUM(F.CARDCOST / 100.0) CARDCOST,
                     SUM(F.FUNCFEE / 100.0) FUNCFEE,
                     -ABS(SUM(F.DISCOUNT / 100.0)) ptDISCOUNT,
                     0 dhDISCOUNT,
                     0 POSTAGE,
                     NVL(SUM(F.CARDCOST / 100.0), 0) +
                     NVL(SUM(F.FUNCFEE / 100.0), 0) -
                     ABS(NVL(SUM(F.DISCOUNT / 100.0), 0)) ORDERFEE
                FROM TF_F_XXOL_ORDER       T,
                     TF_F_XXOL_ORDERDETAIL F,
                     TD_M_PACKAGETYPE      M
               WHERE T.ORDERNO = F.ORDERNO
                 AND (P_VAR1 IS NULL OR P_VAR1 = '' OR
                     T.INSTIME >=
                     TO_DATE(P_VAR1 || '000000', 'YYYYMMDDHH24MISS'))
                 AND (P_VAR2 IS NULL OR P_VAR2 = '' OR
                     T.INSTIME <=
                     TO_DATE(P_VAR2 || '235959', 'YYYYMMDDHH24MISS'))
                 AND (P_VAR3 IS NULL OR P_VAR3 = '' OR P_VAR3 = T.ORDERTYPE)
                 AND (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = T.PAYCANAL)
                 AND F.PACKAGETYPE = M.PACKAGETYPECODE(+)
                 and f.CHARGENO is null --不用兑换码
               GROUP BY M.PACKAGETYPENAME, T.PAYCANAL
              UNION ALL
              SELECT DECODE(PAYCANAL,
                            '01',
                            '支付宝',
                            '02',
                            '微信',
                            '03',
                            '银联',
                            '04',
                            '兑换码',
                            PAYCANAL) PAYCANAL,
                     '无卡开通',
                     0,
                     0,
                     0,
                     0,
                     0,
                     NVL(SUM(T.POSTAGE / 100.0), 0) POSTAGE,
                     NVL(SUM(T.POSTAGE / 100.0), 0) ORDERFEE
                FROM TF_F_XXOL_ORDER T
               WHERE (P_VAR1 IS NULL OR P_VAR1 = '' OR
                     T.INSTIME >=
                     TO_DATE(P_VAR1 || '000000', 'YYYYMMDDHH24MISS'))
                 AND (P_VAR2 IS NULL OR P_VAR2 = '' OR
                     T.INSTIME <=
                     TO_DATE(P_VAR2 || '235959', 'YYYYMMDDHH24MISS'))
                 AND (P_VAR3 IS NULL OR P_VAR3 = '' OR P_VAR3 = T.ORDERTYPE)
                 AND (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = T.PAYCANAL)
                 AND T.ORDERTYPE = '0' --无卡开通统计邮费
               GROUP BY T.PAYCANAL)
       GROUP BY PAYCANAL, PACKAGETYPENAME
       ORDER BY 1, 2;
       
  ELSIF P_FUNCCODE = 'QUERYGARDENNEWREPORT' THEN
  OPEN P_CURSOR FOR
    SELECT PAYCANAL,
             PACKAGETYPENAME,
             SUM(opentimes) opentimes,
             SUM(CARDCOST) CARDCOST,
             SUM(FUNCFEE) FUNCFEE,
             SUM(ptdiscount) ptdiscount,
             SUM(dhDISCOUNT) dhDISCOUNT,
             SUM(POSTAGE) POSTAGE,
             SUM(ORDERFEE) ORDERFEE
        FROM (SELECT DECODE(PAYCANAL,
                            '01',
                            '支付宝',
                            '02',
                            '微信',
                            '03',
                            '银联',
                            '04',
                            '兑换码',
                            PAYCANAL) PAYCANAL,
                    '园林线上续费' PACKAGETYPENAME,
                     COUNT(1) opentimes,
                     SUM(F.CARDCOST / 100.0) CARDCOST,
                     SUM(F.FUNCFEE / 100.0) FUNCFEE,
                     0 ptdiscount,
                     0 dhDISCOUNT,
                     0 POSTAGE,
                     NVL(SUM(F.CARDCOST / 100.0), 0) +
                     NVL(SUM(F.FUNCFEE / 100.0), 0) -
                     ABS(NVL(SUM(F.DISCOUNT / 100.0), 0)) ORDERFEE
                FROM TF_F_YLOL_ORDER       T,
                     TF_F_YLOL_ORDERDETAIL F 
               WHERE T.ORDERNO = F.ORDERNO
                 AND (P_VAR1 IS NULL OR P_VAR1 = '' OR
                     T.INSTIME >=
                     TO_DATE(P_VAR1 || '000000', 'YYYYMMDDHH24MISS'))
                 AND (P_VAR2 IS NULL OR P_VAR2 = '' OR
                     T.INSTIME <=
                     TO_DATE(P_VAR2 || '235959', 'YYYYMMDDHH24MISS'))
                 AND (P_VAR3 IS NULL OR P_VAR3 = '' OR P_VAR3 = T.ORDERTYPE)
                 AND (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = T.PAYCANAL)
               GROUP BY T.PAYCANAL
             )
       GROUP BY PAYCANAL, PACKAGETYPENAME
       ORDER BY 1, 2;
    
  ELSIF P_FUNCCODE = 'EXCELFORRELAXLIST' THEN
    OPEN P_CURSOR FOR
      SELECT M.PACKAGETYPENAME 套餐类型,
             F.CARDNO 卡号,
             DECODE(PAYCANAL,
                    '01',
                    '支付宝',
                    '02',
                    '微信',
                    '03',
                    '银联',
                    PAYCANAL) 支付渠道,
             F.CARDCOST / 100.0 卡费,
             F.FUNCFEE / 100.0 功能费,
             -ABS(F.DISCOUNT / 100.0) 优惠金额,
             NVL(F.CARDCOST / 100.0, 0) + NVL(F.FUNCFEE / 100.0, 0) -
             ABS(F.DISCOUNT / 100.0) 实际金额
        FROM TF_F_XXOL_ORDER T, TF_F_XXOL_ORDERDETAIL F, TD_M_PACKAGETYPE M
       WHERE T.ORDERNO = F.ORDERNO
         AND '2015' || SUBSTR(T.ORDERNO, 6, 4) >= P_VAR1
         AND '2015' || SUBSTR(T.ORDERNO, 6, 4) <= P_VAR2
         AND (P_VAR3 IS NULL OR P_VAR3 = '' OR P_VAR3 = T.ORDERTYPE)
         AND (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = T.PAYCANAL)
         AND F.PACKAGETYPE = M.PACKAGETYPECODE(+)
       ORDER BY 1, 3;
   
  elsif p_funcCode = 'WALLET_ACC_TOTAL' THEN
    --查询沉淀资金特殊调账记录
    open p_cursor for
      SELECT  a.STATTIME, a.chargecardmoney/ 100.0 CHARGECARDMONEY, a.custacctmoney / 100.0 CUSTACCTMONEY, 
      a.cardacctmoney/ 100.0 CARDACCTMONEY,a.totalmoney/ 100.0 TOTALMONEY
      FROM TF_WALLETACCALYSIS a
      WHERE  substr(a.stattime, 0, 6) = p_var1 ;
             
  ELSIF P_FUNCCODE = 'EXCELFORGARDENLIST' THEN
    OPEN P_CURSOR FOR
      SELECT '园林线上续费' 套餐类型,
             F.CARDNO 卡号,
             DECODE(PAYCANAL,
                    '01',
                    '支付宝',
                    '02',
                    '微信',
                    '03',
                    '银联',
                    PAYCANAL) 支付渠道,
             F.CARDCOST / 100.0 卡费,
             F.FUNCFEE / 100.0 功能费,
             -ABS(F.DISCOUNT / 100.0) 优惠金额,
             NVL(F.CARDCOST / 100.0, 0) + NVL(F.FUNCFEE / 100.0, 0) -
             ABS(F.DISCOUNT / 100.0) 实际金额
        FROM TF_F_YLOL_ORDER T, TF_F_YLOL_ORDERDETAIL F
       WHERE T.ORDERNO = F.ORDERNO
         AND SUBSTR(T.ORDERNO, 1, 8) >= P_VAR1
         AND SUBSTR(T.ORDERNO, 1, 8) <= P_VAR2
         AND (P_VAR3 IS NULL OR P_VAR3 = '' OR P_VAR3 = T.ORDERTYPE)
         AND (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = T.PAYCANAL)     
       ORDER BY 1, 3;
  end if;
end;
/
