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
    -- �̻�ת���ձ���ѯ
    if p_var3 = '1' then
      --��ת��
      open p_cursor for
        SELECT ������,
               �̻�����,
               �̻�����,
               �����˺�,
               SUM(ת�ʽ��) ת�ʽ��,
               Ӧ��Ӷ��,
               remark,
               purposetype,
               BankChannelCode,
               SUM(�˻����) �˻����,
               SUM(������) ������
          FROM (select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       a.COMFEE / 100.0 Ӧ��Ӷ��,
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
                                      0)) �˻����,
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
                                      0)) ������
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
                select c.BANK ������,
                       f.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       0 ת�ʽ��,
                       0 Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                       0 ������
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
         GROUP BY ������,
                  �̻�����,
                  �̻�����,
                  �����˺�,
                  remark,
                  purposetype,
                  BankChannelCode,
                  Ӧ��Ӷ��
         order by 1, 3, 5;
    elsif p_var3 = '2' then
      --�����Ϣͤ
      open p_cursor for
        SELECT ������,
               �̻�����,
               �̻�����,
               �����˺�,
               SUM(ת�ʽ��) ת�ʽ��,
               Ӧ��Ӷ��,
               remark,
               purposetype,
               BankChannelCode,
               SUM(�˻����) �˻����,
               SUM(������) ������
          FROM (select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       a.COMFEE / 100.0 Ӧ��Ӷ��,
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
                                      0)) �˻����,
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
                                      0)) ������
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
                select c.BANK ������,
                       f.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       0 ת�ʽ��,
                       0 Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                       0 ������
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
         GROUP BY ������,
                  �̻�����,
                  �̻�����,
                  �����˺�,
                  remark,
                  purposetype,
                  BankChannelCode,
                  Ӧ��Ӷ��
         order by 1, 3, 5;
    elsif p_var3 = '3' then
      --ũ����
      open p_cursor for
        SELECT ������,
               �̻�����,
               �̻�����,
               �����˺�,
               SUM(ת�ʽ��) ת�ʽ��,
               Ӧ��Ӷ��,
               remark,
               purposetype,
               BankChannelCode,
               SUM(�˻����) �˻����,
               SUM(������) ������
          FROM (select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       a.COMFEE / 100.0 Ӧ��Ӷ��,
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
                                      0)) �˻����,
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
                                      0)) ������
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
                select c.BANK ������,
                       f.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       0 ת�ʽ��,
                       0 Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                       0 ������
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
         GROUP BY ������,
                  �̻�����,
                  �̻�����,
                  �����˺�,
                  remark,
                  purposetype,
                  BankChannelCode
         order by 1, 3, 5;
    elsif p_var3 = '0' then
      --ũ��
      open p_cursor for
        SELECT ������,
               �̻�����,
               �̻�����,
               �����˺�,
               SUM(ת�ʽ��) ת�ʽ��,
               Ӧ��Ӷ��,
               remark,
               purposetype,
               BankChannelCode,
               SUM(�˻����) �˻����,
               SUM(������) ������
          FROM (select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
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
                                      0)) �˻����,
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
                                      0)) ������
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
                select c.BANK ������,
                       f.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       0 ת�ʽ��,
                       '0' Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                       0 ������
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
                select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.RENEWFINFEE / 100.0 ת�ʽ��,
                       '��������' Ӧ��Ӷ��,
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
                                      0)) �˻����,
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
                                      0)) ������
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
                select c.BANK ������,
                       f.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       0 ת�ʽ��,
                       '0' Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                       0 ������
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
                select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       posno || '��Ʒ' || to_char(dealtime, 'yyyymmdd') Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL(NVL(0, 0) / 100.0, 0) �˻����,
                       a.TRANSFEE / 100.0 ������
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
                select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       posno || '����Ʒ' || to_char(dealtime, 'yyyymmdd') Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL(NVL(0, 0) / 100.0, 0) �˻����,
                       a.TRANSFEE / 100.0 ������
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
         GROUP BY ������,
                  �̻�����,
                  �̻�����,
                  �����˺�,
                  remark,
                  purposetype,
                  BankChannelCode,
                  Ӧ��Ӷ��
         order by 1, 3, 5;
    elsif p_var3 = '4' then
      --����
      open p_cursor for
        SELECT ������,
               �̻�����,
               �̻�����,
               �����˺�,
               SUM(ת�ʽ��) ת�ʽ��,
               Ӧ��Ӷ��,
               remark,
               purposetype,
               BankChannelCode,
               SUM(�˻����) �˻����,
               SUM(������) ������
          FROM (select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
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
                                      0)) �˻����,
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
                                      0)) ������
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
                select c.BANK ������,
                       f.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       0 ת�ʽ��,
                       '0' Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                       0 ������
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
                union all -- add by liuhe20120427����ת����������ת���˵�
                select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
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
                                      0)) �˻����,
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
                                      0)) ������
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
                select c.BANK ������,
                       f.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       0 ת�ʽ��,
                       '0' Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                       0 ������
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
         GROUP BY ������,
                  �̻�����,
                  �̻�����,
                  �����˺�,
                  remark,
                  purposetype,
                  BankChannelCode,
                  Ӧ��Ӷ��
         order by 1, 3, 5;
    elsif p_var3 = '5' then
      --�żҸ�
      open p_cursor for
        SELECT ������,
               �̻�����,
               �̻�����,
               �����˺�,
               SUM(ת�ʽ��) ת�ʽ��,
               Ӧ��Ӷ��,
               remark,
               purposetype,
               BankChannelCode,
               SUM(�˻����) �˻����,
               SUM(������) ������
          FROM (select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
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
                                      0)) �˻����,
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
                                      0)) ������
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
                select c.BANK ������,
                       f.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       0 ת�ʽ��,
                       '0' Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                       0 ������
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
         GROUP BY ������,
                  �̻�����,
                  �̻�����,
                  �����˺�,
                  remark,
                  purposetype,
                  BankChannelCode,
                  Ӧ��Ӷ��
         order by 1, 3, 5;
    elsif p_var3 is null then
      --���е���ת������
    
      open p_cursor for
      --�����Ϣͤ
        SELECT ������,
               �̻�����,
               �̻�����,
               �����˺�,
               SUM(ת�ʽ��) ת�ʽ��,
               Ӧ��Ӷ��,
               remark,
               purposetype,
               BankChannelCode,
               SUM(�˻����) �˻����,
               SUM(������) ������
          FROM (select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
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
                                      0)) �˻����,
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
                                      0)) ������
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
                select c.BANK ������,
                       f.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       0 ת�ʽ��,
                       '0' Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                       0 ������
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
                --ũ����
                select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
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
                                      0)) �˻����,
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
                                      0)) ������
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
                select c.BANK ������,
                       f.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       0 ת�ʽ��,
                       '0' Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                       0 ������
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
                --ũ��
                select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
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
                                      0)) �˻����,
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
                                      0)) ������
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
                select c.BANK ������,
                       f.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       0 ת�ʽ��,
                       '0' Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                       0 ������
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
                select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.RENEWFINFEE / 100.0 ת�ʽ��,
                       '��������' Ӧ��Ӷ��,
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
                                      0)) �˻����,
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
                                      0)) ������
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
                select c.BANK ������,
                       f.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       0 ת�ʽ��,
                       '0 ' Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                       0 ������
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
                select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       posno || '��Ʒ' || to_char(dealtime, 'yyyymmdd') Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL(NVL(0, 0) / 100.0, 0) �˻����,
                       a.TRANSFEE / 100.0 ������
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
                select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       posno || '����Ʒ' || to_char(dealtime, 'yyyymmdd') Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL(NVL(0, 0) / 100.0, 0) �˻����,
                       a.TRANSFEE / 100.0 ������
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
                --����
                select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
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
                                      0)) �˻����,
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
                                      0)) ������
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
                select c.BANK ������,
                       f.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       0 ת�ʽ��,
                       '0' Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                       0 ������
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
                union all -- add by liuhe20120427����ת����������ת���˵�
                select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
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
                                      0)) �˻����,
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
                                      0)) ������
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
                select c.BANK ������,
                       f.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       0 ת�ʽ��,
                       '0' Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                       0 ������
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
                --�żҸ�
                select c.BANK ������,
                       a.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       a.TRANSFEE / 100.0 ת�ʽ��,
                       to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
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
                                      0)) �˻����,
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
                                      0)) ������
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
                select c.BANK ������,
                       f.BALUNITNO �̻�����,
                       b.BALUNIT �̻�����,
                       b.bankaccno �����˺�,
                       0 ת�ʽ��,
                       '0' Ӧ��Ӷ��,
                       b.remark,
                       b.purposetype,
                       b.BankChannelCode,
                       NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                       0 ������
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
         GROUP BY ������,
                  �̻�����,
                  �̻�����,
                  �����˺�,
                  remark,
                  purposetype,
                  BankChannelCode,
                  Ӧ��Ӷ��
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
    -- �̻�ת���ձ���ѯ����ת�ʱ��
    if p_var3 = '1' then
      --��ת��
      open p_cursor for
        select ROWNUM, T.*
          from (select �����˺� �տ��ʺ�,
                       �̻����� �տ��˻���,
                       ������ �տ��˿���������,
                       BANKNUMBER �տ����к�,
                       purposetype �տ����˻�����,
                       SUM(ת�ʽ��) - SUM(�˻����) ���,
                       �տ����Ƿ���,
                       �տ����Ƿ�ͬ��,
                       remark || 'Ӷ��' ||
                       decode(ltrim(Ӧ��Ӷ��), '.00', '0', ltrim(Ӧ��Ӷ��)) ������;
                  from (select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               a.COMFEE / 100.0 Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
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
                                    0)) �˻����,
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
                                    0)) ������
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
                        select c.BANK ������,
                               f.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               0 ת�ʽ��,
                               0 Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                               0 ������
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
                 GROUP BY �����˺�,
                          �̻�����,
                          �̻�����,
                          ������,
                          BANKNUMBER,
                          purposetype,
                          �տ����Ƿ���,
                          �տ����Ƿ�ͬ��,
                          remark,
                          Ӧ��Ӷ��
                 ORDER BY ������, �̻�����, SUM(ת�ʽ��)) T;
    elsif p_var3 = '2' then
      --�����Ϣͤ
      open p_cursor for
        select ROWNUM, T.*
          from (select �����˺� �տ��ʺ�,
                       �̻����� �տ��˻���,
                       ������ �տ��˿���������,
                       BANKNUMBER �տ����к�,
                       purposetype �տ����˻�����,
                       SUM(ת�ʽ��) - SUM(�˻����) ���,
                       �տ����Ƿ���,
                       �տ����Ƿ�ͬ��,
                       remark || 'Ӷ��' ||
                       decode(ltrim(Ӧ��Ӷ��), '.00', '0', ltrim(Ӧ��Ӷ��)) ������;
                  from (select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               a.COMFEE / 100.0 Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
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
                                    0)) �˻����,
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
                                    0)) ������
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
                        select c.BANK ������,
                               f.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               0 ת�ʽ��,
                               0 Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                               0 ������
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
                 GROUP BY �����˺�,
                          �̻�����,
                          �̻�����,
                          ������,
                          BANKNUMBER,
                          purposetype,
                          �տ����Ƿ���,
                          �տ����Ƿ�ͬ��,
                          remark,
                          Ӧ��Ӷ��
                 ORDER BY ������, �̻�����, SUM(ת�ʽ��)) T;
    elsif p_var3 = '3' then
      --ũ����
      open p_cursor for
        select ROWNUM, T.*
          from (select �����˺� �տ��ʺ�,
                       �̻����� �տ��˻���,
                       ������ �տ��˿���������,
                       BANKNUMBER �տ����к�,
                       purposetype �տ����˻�����,
                       SUM(ת�ʽ��) - SUM(�˻����) ���,
                       �տ����Ƿ���,
                       �տ����Ƿ�ͬ��,
                       remark || 'Ӷ��' ||
                       decode(ltrim(Ӧ��Ӷ��), '.00', '0', ltrim(Ӧ��Ӷ��)) ������;
                  from (select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               a.COMFEE / 100.0 Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
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
                                    0)) �˻����,
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
                                    0)) ������
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
                        select c.BANK ������,
                               f.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               0 ת�ʽ��,
                               0 Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                               0 ������
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
                 GROUP BY �����˺�,
                          �̻�����,
                          �̻�����,
                          ������,
                          BANKNUMBER,
                          purposetype,
                          �տ����Ƿ���,
                          �տ����Ƿ�ͬ��,
                          remark,
                          Ӧ��Ӷ��
                 ORDER BY ������, �̻�����, SUM(ת�ʽ��)) T;
    elsif p_var3 = '0' then
      --ũ��
      open p_cursor for
        select ROWNUM, T.*
          from (select �����˺� �տ��ʺ�,
                       �̻����� �տ��˻���,
                       ������ �տ��˿���������,
                       BANKNUMBER �տ����к�,
                       purposetype �տ����˻�����,
                       SUM(ת�ʽ��) - SUM(�˻����) ���,
                       �տ����Ƿ���,
                       �տ����Ƿ�ͬ��,
                       remark || 'Ӷ��' ||
                       decode(ltrim(Ӧ��Ӷ��), '.00', '0', ltrim(Ӧ��Ӷ��)) ������;
                  from (select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
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
                                    0)) �˻����,
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
                                    0)) ������
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
                        select c.BANK ������,
                               f.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               0 ת�ʽ��,
                               '0' Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                               0 ������
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
                        select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.RENEWFINFEE / 100.0 ת�ʽ��,
                               '��������' Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
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
                                    0)) �˻����,
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
                                    0)) ������
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
                        select c.BANK ������,
                               f.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               0 ת�ʽ��,
                               '0' Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                               0 ������
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
                        select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               posno || '��Ʒ' || to_char(dealtime, 'yyyymmdd') Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.DEALTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL(NVL(0, 0) / 100.0, 0) �˻����,
                               a.TRANSFEE / 100.0 ������
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
                        select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               posno || '����Ʒ' ||
                               to_char(dealtime, 'yyyymmdd') Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.DEALTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL(NVL(0, 0) / 100.0, 0) �˻����,
                               a.TRANSFEE / 100.0 ������
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
                 GROUP BY �����˺�,
                          �̻�����,
                          �̻�����,
                          ������,
                          BANKNUMBER,
                          purposetype,
                          �տ����Ƿ���,
                          �տ����Ƿ�ͬ��,
                          remark,
                          Ӧ��Ӷ��
                 ORDER BY ������, �̻�����, SUM(ת�ʽ��)) T;
    elsif p_var3 = '4' then
      --����
      open p_cursor for
        select ROWNUM, T.*
          from (select �����˺� �տ��ʺ�,
                       �̻����� �տ��˻���,
                       ������ �տ��˿���������,
                       BANKNUMBER �տ����к�,
                       purposetype �տ����˻�����,
                       SUM(ת�ʽ��) - SUM(�˻����) ���,
                       �տ����Ƿ���,
                       �տ����Ƿ�ͬ��,
                       remark || 'Ӷ��' ||
                       decode(ltrim(Ӧ��Ӷ��), '.00', '0', ltrim(Ӧ��Ӷ��)) ������;
                  from (select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
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
                                    0)) �˻����,
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
                                    0)) ������
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
                        select c.BANK ������,
                               f.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               0 ת�ʽ��,
                               '0' Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                               0 ������
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
                        union all -- add by liuhe20120427����ת����������ת���˵�
                        select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
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
                                    0)) �˻����,
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
                                    0)) ������
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
                        select c.BANK ������,
                               f.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               0 ת�ʽ��,
                               '0' Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                               0 ������
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
                 GROUP BY �����˺�,
                          �̻�����,
                          �̻�����,
                          ������,
                          BANKNUMBER,
                          purposetype,
                          �տ����Ƿ���,
                          �տ����Ƿ�ͬ��,
                          remark,
                          Ӧ��Ӷ��
                 ORDER BY ������, �̻�����, SUM(ת�ʽ��)) T;
    elsif p_var3 = '5' then
      --�żҸ�
      open p_cursor for
        select ROWNUM, T.*
          from (select �����˺� �տ��ʺ�,
                       �̻����� �տ��˻���,
                       ������ �տ��˿���������,
                       BANKNUMBER �տ����к�,
                       purposetype �տ����˻�����,
                       SUM(ת�ʽ��) - SUM(�˻����) ���,
                       �տ����Ƿ���,
                       �տ����Ƿ�ͬ��,
                       remark || 'Ӷ��' ||
                       decode(ltrim(Ӧ��Ӷ��), '.00', '0', ltrim(Ӧ��Ӷ��)) ������;
                  from (select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
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
                                    0)) �˻����,
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
                                    0)) ������
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
                        select c.BANK ������,
                               f.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               0 ת�ʽ��,
                               '0' Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                               0 ������
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
                 GROUP BY �����˺�,
                          �̻�����,
                          �̻�����,
                          ������,
                          BANKNUMBER,
                          purposetype,
                          �տ����Ƿ���,
                          �տ����Ƿ�ͬ��,
                          remark,
                          Ӧ��Ӷ��
                 ORDER BY ������, �̻�����, SUM(ת�ʽ��)) T;
    elsif p_var3 is null then
      --���е���ת������
    
      open p_cursor for
      --�����Ϣͤ
        select ROWNUM, T.*
          from (select �����˺� �տ��ʺ�,
                       �̻����� �տ��˻���,
                       ������ �տ��˿���������,
                       BANKNUMBER �տ����к�,
                       purposetype �տ����˻�����,
                       SUM(ת�ʽ��) - SUM(�˻����) ���,
                       �տ����Ƿ���,
                       �տ����Ƿ�ͬ��,
                       remark || 'Ӷ��' ||
                       decode(ltrim(Ӧ��Ӷ��), '.00', '0', ltrim(Ӧ��Ӷ��)) ������;
                  from (select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
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
                                    0)) �˻����,
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
                                    0)) ������
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
                        select c.BANK ������,
                               f.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               0 ת�ʽ��,
                               '0' Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                               0 ������
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
                        --ũ����
                        select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
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
                                    0)) �˻����,
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
                                    0)) ������
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
                        select c.BANK ������,
                               f.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               0 ת�ʽ��,
                               '0' Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                               0 ������
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
                        --ũ��
                        select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
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
                                    0)) �˻����,
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
                                    0)) ������
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
                        select c.BANK ������,
                               f.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               0 ת�ʽ��,
                               '0' Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                               0 ������
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
                        select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.RENEWFINFEE / 100.0 ת�ʽ��,
                               '��������' Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
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
                                    0)) �˻����,
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
                                    0)) ������
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
                        select c.BANK ������,
                               f.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               0 ת�ʽ��,
                               '0 ' Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                               0 ������
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
                        select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               posno || '��Ʒ' || to_char(dealtime, 'yyyymmdd') Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.DEALTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL(NVL(0, 0) / 100.0, 0) �˻����,
                               a.TRANSFEE / 100.0 ������
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
                        select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               posno || '����Ʒ' ||
                               to_char(dealtime, 'yyyymmdd') Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.DEALTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL(NVL(0, 0) / 100.0, 0) �˻����,
                               a.TRANSFEE / 100.0 ������
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
                        --����
                        select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
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
                                    0)) �˻����,
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
                                    0)) ������
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
                        select c.BANK ������,
                               f.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               0 ת�ʽ��,
                               '0' Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                               0 ������
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
                        union all -- add by liuhe20120427����ת����������ת���˵�
                        select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
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
                                    0)) �˻����,
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
                                    0)) ������
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
                        select c.BANK ������,
                               f.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               0 ת�ʽ��,
                               '0' Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                               0 ������
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
                        --�żҸ�
                        select c.BANK ������,
                               a.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               a.TRANSFEE / 100.0 ת�ʽ��,
                               to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
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
                                    0)) �˻����,
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
                                    0)) ������
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
                        select c.BANK ������,
                               f.BALUNITNO �̻�����,
                               b.BALUNIT �̻�����,
                               b.bankaccno �����˺�,
                               0 ת�ʽ��,
                               '0' Ӧ��Ӷ��,
                               DECODE(b.callingno,
                                      '19',
                                      '����' || to_char(a.ENDTIME, 'yyyymmdd'),
                                      '����' || b.BALUNITNO) remark,
                               DECODE(b.purposetype, '1', '0', '2', '1') purposetype,
                               b.BankChannelCode,
                               c.BANKNUMBER,
                               decode(c.ISSZBANK, '0', '��', '1', '��', '��') �տ����Ƿ���,
                               decode(c.ISLOCAL, '0', '��', '1', '��', '') �տ����Ƿ�ͬ��,
                               NVL((F.REFUNDMENT - F.REBROKERAGE), 0) / 100.0 �˻����,
                               0 ������
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
                 GROUP BY �����˺�,
                          �̻�����,
                          �̻�����,
                          ������,
                          BANKNUMBER,
                          purposetype,
                          �տ����Ƿ���,
                          �տ����Ƿ�ͬ��,
                          remark,
                          Ӧ��Ӷ��
                 ORDER BY ������, �̻�����, SUM(ת�ʽ��)) T;
    end if;
    --���� ���� 2012/11/30  ���������̻�ת�˱���
  elsif p_funcCode = 'TD_EOC_DAILY_REPORT_CA' then
    -- ���������̻�ת���ձ���ѯ
    if p_var3 = '1' then
      --��ת��
      open p_cursor for
        select c.BANK ������,
               a.BALUNITNO �̻�����,
               b.BALUNIT �̻�����,
               b.bankaccno �����˺�,
               a.TRANSFEE / 100.0 ת�ʽ��,
               a.COMFEE / 100.0 Ӧ��Ӷ��,
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
      --�����Ϣͤ
      open p_cursor for
        select c.BANK ������,
               a.BALUNITNO �̻�����,
               b.BALUNIT �̻�����,
               b.bankaccno �����˺�,
               a.TRANSFEE / 100.0 ת�ʽ��,
               a.COMFEE / 100.0 Ӧ��Ӷ��,
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
      --ũ����
      open p_cursor for
        select c.BANK ������,
               a.BALUNITNO �̻�����,
               b.BALUNIT �̻�����,
               b.bankaccno �����˺�,
               a.TRANSFEE / 100.0 ת�ʽ��,
               a.COMFEE / 100.0 Ӧ��Ӷ��,
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
      --ũ��
      open p_cursor for
        select c.BANK ������,
               a.BALUNITNO �̻�����,
               b.BALUNIT �̻�����,
               b.bankaccno �����˺�,
               a.TRANSFEE / 100.0 ת�ʽ��,
               to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
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
        select c.BANK ������,
               a.BALUNITNO �̻�����,
               b.BALUNIT �̻�����,
               b.bankaccno �����˺�,
               a.RENEWFINFEE / 100.0 ת�ʽ��,
               '��������' Ӧ��Ӷ��,
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
      --����
      open p_cursor for
        select c.BANK ������,
               a.BALUNITNO �̻�����,
               b.BALUNIT �̻�����,
               b.bankaccno �����˺�,
               a.TRANSFEE / 100.0 ת�ʽ��,
               to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
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
      --�żҸ�
      open p_cursor for
        select c.BANK ������,
               a.BALUNITNO �̻�����,
               b.BALUNIT �̻�����,
               b.bankaccno �����˺�,
               a.TRANSFEE / 100.0 ת�ʽ��,
               to_char(a.COMFEE / 100.0, '99999999.99') Ӧ��Ӷ��,
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
    -- �̻�ת������
    open p_cursor for
      select b.BALUNIT �̻�����,
             to_char(a.ENDTIME, 'yyyymmdd') ת��ʱ��,
             a.TRANSFEE / 100.0 ת�ʽ��
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
    -- ���⳵ת���ձ���ѯ
    if p_var2 = '0' then
      open p_cursor for
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') ת��ʱ��,
               b.BANKACCNO �����ʺ�,
               b.BALUNIT ˾������,
               a.TRANSFEE / 100.0 ת�ʽ��
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
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') ת��ʱ��,
               b.BANKACCNO �����ʺ�,
               b.BALUNIT ˾������,
               a.TRANSFEE / 100.0 ת�ʽ��
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
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') ת��ʱ��,
               b.BANKACCNO �����ʺ�,
               b.BALUNIT ˾������,
               a.TRANSFEE / 100.0 ת�ʽ��
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
      --�żҸ�
      open p_cursor for
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') ת��ʱ��,
               b.BANKACCNO �����ʺ�,
               b.BALUNIT ˾������,
               a.TRANSFEE / 100.0 ת�ʽ��
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
      --��ѯ����ת��
      open p_cursor for
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') ת��ʱ��,
               b.BANKACCNO �����ʺ�,
               b.BALUNIT ˾������,
               a.TRANSFEE / 100.0 ת�ʽ��
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
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') ת��ʱ��,
               b.BANKACCNO �����ʺ�,
               b.BALUNIT ˾������,
               a.TRANSFEE / 100.0 ת�ʽ��
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
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') ת��ʱ��,
               b.BANKACCNO �����ʺ�,
               b.BALUNIT ˾������,
               a.TRANSFEE / 100.0 ת�ʽ��
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
        select to_char(a.ENDTIME, 'yyyymmddhh24miss') ת��ʱ��,
               b.BANKACCNO �����ʺ�,
               b.BALUNIT ˾������,
               a.TRANSFEE / 100.0 ת�ʽ��
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
         order by �����ʺ�;
    
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
    -- ���⳵ת��������ѯ
    if p_var3 = '0' then
      open p_cursor for
        select to_char(endtime, 'yyyymmdd') ת������,
               sum(TRANSFEE) / 100.0 ת�ʽ��
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
        select to_char(endtime, 'yyyymmdd') ת������,
               sum(TRANSFEE) / 100.0 ת�ʽ��
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
        select to_char(endtime, 'yyyymmdd') ת������,
               sum(TRANSFEE) / 100.0 ת�ʽ��
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
    -- �̻�Ӷ��ƾ֤�����ձ���ѯ
    if p_var5 = '0' then
      --�ѻ����ѣ�������ר���˻����ѣ�
      open p_cursor for
        select b.CALLING ��ҵ,
               c.CORP ��λ,
               d.DEPART ����,
               f.SLOPE Ӷ�����,
               sum(a.FINFEE) / 100.0 ������,
               sum(a.transfee) / 100.0 ת�ʽ��,
               decode(m.COMFEETAKECODE, '1', sum(a.COMFEE) / 100.0, 0) �Զ���Ӷ��,
               decode(m.COMFEETAKECODE, '0', sum(a.COMFEE) / 100.0, 0) ���Զ���Ӷ��,
               (nvl(sp.rebrokerage, 0)) / 100.0 Ӧ��Ӷ��,
               a.BALUNITNO ���㵥Ԫ����,
               tmr.regionname ����
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
        select b.CALLING ��ҵ,
               c.CORP ��λ,
               '�޲���' ����,
               f.SLOPE Ӷ�����,
               sum(a.FINFEE) / 100.0 ������,
               sum(a.transfee) / 100.0 ת�ʽ��,
               decode(m.COMFEETAKECODE, '1', sum(a.COMFEE) / 100.0, 0) �Զ���Ӷ��,
               decode(m.COMFEETAKECODE, '0', sum(a.COMFEE) / 100.0, 0) ���Զ���Ӷ��,
               (nvl(sp.rebrokerage, 0)) / 100.0 Ӧ��Ӷ��,
               a.balunitno ���㵥Ԫ����,
               tmr.regionname ����
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
        select b.CALLING ��ҵ,
               c.CORP ��λ,
               '�޲���' ����,
               f.SLOPE Ӷ�����,
               sum(a.FINFEE) / 100.0 ������,
               sum(a.transfee) / 100.0 ת�ʽ��,
               decode(m.COMFEETAKECODE, '1', sum(a.COMFEE) / 100.0, 0) �Զ���Ӷ��,
               decode(m.COMFEETAKECODE, '0', sum(a.COMFEE) / 100.0, 0) ���Զ���Ӷ��,
               (nvl(sp.rebrokerage, 0)) / 100.0 Ӧ��Ӷ��,
               a.balunitno ���㵥Ԫ����,
               tmr.regionname ����
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
        select '��������' ��ҵ,
               '��ʯ��' ��λ,
               '' ����,
               0.005 Ӷ�����,
               sum(a.TRADEMONEY) / 100.0 ������,
               sum(a.smoney) / 100.0 ת�ʽ��,
               decode(m.COMFEETAKECODE,
                      '1',
                      sum(a.TRADEMONEY) * 0.005 / 100.0,
                      0) �Զ���Ӷ��,
               decode(m.COMFEETAKECODE,
                      '0',
                      sum(a.TRADEMONEY) * 0.005 / 100.0,
                      0) ���Զ���Ӷ��,
               (nvl(sp.rebrokerage, 0)) / 100.0 Ӧ��Ӷ��,
               a.balunitno ���㵥Ԫ����,
               tmr.regionname ����
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
           and c.corp = '��ʯ��'
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
      --ר���˻����ѣ�������
      open p_cursor for
        select ��ҵ,
               ��λ,
               ����,
               Ӷ�����,
               sum(������) ������,
               sum(ת�ʽ��) ת�ʽ��,
               sum(�Զ���Ӷ��) �Զ���Ӷ��,
               sum(���Զ���Ӷ��) ���Զ���Ӷ��,
               sum(Ӧ��Ӷ��) Ӧ��Ӷ��,
               ���㵥Ԫ����,
               ����
          from (select b.CALLING ��ҵ,
                       c.CORP ��λ,
                       d.DEPART ����,
                       f.SLOPE Ӷ�����,
                       sum(a.FINFEE) / 100.0 ������,
                       sum(a.transfee) / 100.0 ת�ʽ��,
                       decode(m.COMFEETAKECODE,
                              '1',
                              sum(a.COMFEE) / 100.0,
                              0) �Զ���Ӷ��,
                       decode(m.COMFEETAKECODE,
                              '0',
                              sum(a.COMFEE) / 100.0,
                              0) ���Զ���Ӷ��,
                       0 Ӧ��Ӷ��,
                       a.BALUNITNO ���㵥Ԫ����,
                       tmr.regionname ����
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
                select b.CALLING ��ҵ,
                       c.CORP ��λ,
                       d.DEPART ����,
                       f.SLOPE Ӷ�����,
                       sum(a.FINFEE) / 100.0 ������,
                       sum(a.transfee) / 100.0 ת�ʽ��,
                       0 �Զ���Ӷ��,
                       0 ���Զ���Ӷ��,
                       abs(sum(nvl(a.COMFEE, 0))) / 100.0 Ӧ��Ӷ��,
                       a.BALUNITNO ���㵥Ԫ����,
                       tmr.regionname ����
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
         GROUP BY ��ҵ, ��λ, ����, Ӷ�����, ���㵥Ԫ����, ����;
    elsif p_var5 is null then
      --���е�����
      open p_cursor for
        select ��ҵ,
               ��λ,
               ����,
               Ӷ�����,
               sum(������) ������,
               sum(ת�ʽ��) ת�ʽ��,
               sum(�Զ���Ӷ��) �Զ���Ӷ��,
               sum(���Զ���Ӷ��) ���Զ���Ӷ��,
               sum(Ӧ��Ӷ��) Ӧ��Ӷ��,
               ���㵥Ԫ����,
               ����
          from (select b.CALLING ��ҵ,
                       c.CORP ��λ,
                       d.DEPART ����,
                       f.SLOPE Ӷ�����,
                       sum(a.FINFEE) / 100.0 ������,
                       sum(a.transfee) / 100.0 ת�ʽ��,
                       decode(m.COMFEETAKECODE,
                              '1',
                              sum(a.COMFEE) / 100.0,
                              0) �Զ���Ӷ��,
                       decode(m.COMFEETAKECODE,
                              '0',
                              sum(a.COMFEE) / 100.0,
                              0) ���Զ���Ӷ��,
                       (nvl(sp.rebrokerage, 0)) / 100.0 Ӧ��Ӷ��,
                       a.BALUNITNO ���㵥Ԫ����,
                       tmr.regionname ����
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
                select b.CALLING ��ҵ,
                       c.CORP ��λ,
                       '�޲���' ����,
                       f.SLOPE Ӷ�����,
                       sum(a.FINFEE) / 100.0 ������,
                       sum(a.transfee) / 100.0 ת�ʽ��,
                       decode(m.COMFEETAKECODE,
                              '1',
                              sum(a.COMFEE) / 100.0,
                              0) �Զ���Ӷ��,
                       decode(m.COMFEETAKECODE,
                              '0',
                              sum(a.COMFEE) / 100.0,
                              0) ���Զ���Ӷ��,
                       (nvl(sp.rebrokerage, 0)) / 100.0 Ӧ��Ӷ��,
                       a.balunitno ���㵥Ԫ����,
                       tmr.regionname ����
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
                select b.CALLING ��ҵ,
                       c.CORP ��λ,
                       '�޲���' ����,
                       f.SLOPE Ӷ�����,
                       sum(a.FINFEE) / 100.0 ������,
                       sum(a.transfee) / 100.0 ת�ʽ��,
                       decode(m.COMFEETAKECODE,
                              '1',
                              sum(a.COMFEE) / 100.0,
                              0) �Զ���Ӷ��,
                       decode(m.COMFEETAKECODE,
                              '0',
                              sum(a.COMFEE) / 100.0,
                              0) ���Զ���Ӷ��,
                       (nvl(sp.rebrokerage, 0)) / 100.0 Ӧ��Ӷ��,
                       a.balunitno ���㵥Ԫ����,
                       tmr.regionname ����
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
                select '��������' ��ҵ,
                       '��ʯ��' ��λ,
                       '' ����,
                       0.005 Ӷ�����,
                       sum(a.TRADEMONEY) / 100.0 ������,
                       sum(a.smoney) / 100.0 ת�ʽ��,
                       decode(m.COMFEETAKECODE,
                              '1',
                              sum(a.TRADEMONEY) * 0.005 / 100.0,
                              0) �Զ���Ӷ��,
                       decode(m.COMFEETAKECODE,
                              '0',
                              sum(a.TRADEMONEY) * 0.005 / 100.0,
                              0) ���Զ���Ӷ��,
                       (nvl(sp.rebrokerage, 0)) / 100.0 Ӧ��Ӷ��,
                       a.balunitno ���㵥Ԫ����,
                       tmr.regionname ����
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
                   and c.corp = '��ʯ��'
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
                union --ר���˻�
                select b.CALLING ��ҵ,
                       c.CORP ��λ,
                       d.DEPART ����,
                       f.SLOPE Ӷ�����,
                       sum(a.FINFEE) / 100.0 ������,
                       sum(a.transfee) / 100.0 ת�ʽ��,
                       decode(m.COMFEETAKECODE,
                              '1',
                              sum(a.COMFEE) / 100.0,
                              0) �Զ���Ӷ��,
                       decode(m.COMFEETAKECODE,
                              '0',
                              sum(a.COMFEE) / 100.0,
                              0) ���Զ���Ӷ��,
                       0 Ӧ��Ӷ��,
                       a.BALUNITNO ���㵥Ԫ����,
                       tmr.regionname ����
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
                select b.CALLING ��ҵ,
                       c.CORP ��λ,
                       d.DEPART ����,
                       f.SLOPE Ӷ�����,
                       sum(a.FINFEE) / 100.0 ������,
                       sum(a.transfee) / 100.0 ת�ʽ��,
                       0 �Զ���Ӷ��,
                       0 ���Զ���Ӷ��,
                       abs(sum(nvl(a.COMFEE, 0))) / 100.0 Ӧ��Ӷ��,
                       a.BALUNITNO ���㵥Ԫ����,
                       tmr.regionname ����
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
         GROUP BY ��ҵ, ��λ, ����, Ӷ�����, ���㵥Ԫ����, ����;
    
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
               '�޲���',
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
               '�޲���',
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
               '��������',
               '��ʯ��',
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
               ��ҵ,
               ��λ,
               ����,
               Ӷ�����,
               sum(������),
               sum(Ӧ��Ӷ��),
               sum(Ӧ��Ӷ��)
          from (select b.CALLING ��ҵ,
                       c.CORP ��λ,
                       d.DEPART ����,
                       f.SLOPE Ӷ�����,
                       sum(a.FINFEE) / 100.0 ������,
                       sum(a.COMFEE) / 100.0 Ӧ��Ӷ��,
                       0 Ӧ��Ӷ��
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
                select b.CALLING ��ҵ,
                       c.CORP ��λ,
                       d.DEPART ����,
                       f.SLOPE Ӷ�����,
                       sum(a.FINFEE) / 100.0 ������,
                       0 Ӧ��Ӷ��,
                       abs(sum(nvl(a.COMFEE, 0))) Ӧ��Ӷ��
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
         GROUP BY ��ҵ, ��λ, ����, Ӷ�����;
    elsif p_var5 is null then
      insert into TF_TRADECF_SERIALNO_DETAIL
        select p_var9,
               p_var3,
               ��ҵ,
               ��λ,
               ����,
               Ӷ�����,
               sum(������),
               sum(Ӧ��Ӷ��),
               sum(Ӧ��Ӷ��)
          from (select b.CALLING ��ҵ,
                       c.CORP ��λ,
                       d.DEPART ����,
                       f.SLOPE Ӷ�����,
                       sum(a.FINFEE) / 100.0 ������,
                       sum(a.COMFEE) / 100.0 Ӧ��Ӷ��,
                       nvl(sp.rebrokerage, 0) Ӧ��Ӷ��
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
                select b.CALLING ��ҵ,
                       c.CORP ��λ,
                       '�޲���' ����,
                       f.SLOPE Ӷ�����,
                       sum(a.FINFEE) / 100.0 ������,
                       sum(a.COMFEE) / 100.0 Ӧ��Ӷ��,
                       nvl(sp.rebrokerage, 0) Ӧ��Ӷ��
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
                select b.CALLING ��ҵ,
                       c.CORP ��λ,
                       '�޲���' ����,
                       f.SLOPE Ӷ�����,
                       sum(a.FINFEE) / 100.0 ������,
                       sum(a.COMFEE) / 100.0 Ӧ��Ӷ��,
                       nvl(sp.rebrokerage, 0) Ӧ��Ӷ��
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
                select '��������' ��ҵ,
                       '��ʯ��' ��λ,
                       null,
                       0.005 Ӷ�����,
                       sum(a.TRADEMONEY) / 100.0 ������,
                       sum(a.TRADEMONEY) * 0.005 / 100.0 Ӧ��Ӷ��,
                       nvl(sp.rebrokerage, 0) Ӧ��Ӷ��
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
                union --ר���˻�
                select b.CALLING ��ҵ,
                       c.CORP ��λ,
                       d.DEPART ����,
                       f.SLOPE Ӷ�����,
                       sum(a.FINFEE) / 100.0 ������,
                       sum(a.COMFEE) / 100.0 Ӧ��Ӷ��,
                       0 Ӧ��Ӷ��
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
                select b.CALLING ��ҵ,
                       c.CORP ��λ,
                       d.DEPART ����,
                       f.SLOPE Ӷ�����,
                       sum(a.FINFEE) / 100.0 ������,
                       0 Ӧ��Ӷ��,
                       abs(sum(nvl(a.COMFEE, 0))) Ӧ��Ӷ��
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
         GROUP BY ��ҵ, ��λ, ����, Ӷ�����;
    end if;
    insert into TF_TRADECF_SERIALNO_STATUS values (p_var9, '0');
    commit;
  elsif p_funcCode = 'GET_AUDIT_DATA' then
    -- ��ȡƾ֤������ݺ�״̬
    open p_cursor for
      select b.STAFFNAME �̻�����,
             a.CALLING �̻���ҵ,
             a.CORP �̻���λ,
             a.DEPART �̻�����,
             a.SLOPE Ӷ�����,
             sum(a.COMFEE) ������,
             sum(a.FINFEE) Ӧ��Ӷ��,
             (sum(nvl(a.rebrokerage, 0))) / 100.0 Ӧ��Ӷ��
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
    -- ȷ�Ͽ�Ʊ
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
    -- ��˻���
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
    -- �����±�
    open p_cursor for
      select '��ʹ�÷�', USEDFEETIMES ����, USEDFEE ���
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4
      union
      select 'һ�����ۿ���', CARDCOSTTIMES ����, CARDCOST / 100.0 ���
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4
      union
      select '�˿�(�۳�һ����)',
             SERVICEMONEY1TIMES ����,
             SERVICEMONEY1 / 100.0 ���
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4
      union
      select '�˿�(�۳�һ����)',
             SERVICEMONEY2TIMES ����,
             SERVICEMONEY2 / 100.0 ���
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4;
  
    select 'KFYB' || to_char(sysdate, 'yyyymmdd') ||
           substr('00000000' ||
                  to_char(TF_TRADEOC_SERIALNO_DETAIL_SEQ.NEXTVAL),
                  -8)
      into p_var9
      from dual;
    insert into TF_CARDFEE_SERIALNO_DETAIL
      select p_var9, '��ʹ�÷�', USEDFEETIMES, USEDFEE
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4
      union
      select p_var9, 'һ�����ۿ���', CARDCOSTTIMES, CARDCOST
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4
      union
      select p_var9,
             '�˿����۳�һ���ڣ�',
             SERVICEMONEY1TIMES,
             SERVICEMONEY1
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4
      union
      select p_var9, '�˿�(�۳�һ���⣩', SERVICEMONEY2TIMES, SERVICEMONEY2
        from TF_CARDFEE_MONTH
       where COLLEXTDATE = p_var4;
    commit;
  
  elsif p_funcCode = 'REFUND_EOC_REPORT' then
    -- �˳�ֵת����ϸ��ѯ
    open p_cursor for
      select b.BANK ����,
             a.BANKACCNO �ʺ�,
             a.custname �տ���,
             a.CARDNO ����,
             a.factmoney / 100.0 Ӧ�˽��,
             (a.BACKMONEY - a.factmoney) / 100.0 �۳��Ѹ�Ӷ��,
             a.OPERATETIME ʱ��,
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
    -- �˳�ֵת����ϸ��ѯת�ʱ��
    open p_cursor for
      SELECT ROWNUM, C.*
        FROM (SELECT T.BANKACCNO,
                     T.CUSTNAME,
                     B.BANK,
                     B.BANKNUMBER,
                     DECODE(T.PURPOSETYPE, '1', '0', '2', '1') PURPOSETYPE,
                     T.FACTMONEY / 100.0 FACTMONEY,
                     DECODE(B.ISSZBANK, '0', '��', '1', '��', '��') ISSZBANK,
                     DECODE(B.ISLOCAL, '0', '��', '1', '��', '') ISLOCAL,
                     ''
                FROM TF_B_REFUND T, TD_M_BANK B
               WHERE T.BANKCODE = B.BANKCODE(+)
                 AND T.BANKCODE != '0000' --�ų��޿����е�����
                 AND (P_VAR1 IS NULL OR P_VAR1 = '' OR
                     TO_CHAR(T.OPERATETIME, 'YYYYMMDD') >= P_VAR1)
                 AND (P_VAR2 IS NULL OR P_VAR2 = '' OR
                     TO_CHAR(T.OPERATETIME, 'YYYYMMDD') <= P_VAR2)
               ORDER BY T.OPERATETIME, B.BANK, T.CUSTNAME) C;
  elsif p_funcCode = 'REFUND_COMPARE_REPORT' then
    -- ����Ա�˿����
    open p_cursor for
      select a.OPERATEDATE �˿�����,
             b.STAFFNAME ����Ա,
             '��ֵ' �˿�����,
             a.CARDDEPOSITFEE / 100.0 ���
        from TF_F_TRADEFEE_COLLECT a, TD_M_INSIDESTAFF b
       where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
         and (a.TRADETYPECODE = '05' OR a.TRADETYPECODE = '06')
         and a.OPERATESTAFFNO = p_var3
         and p_var3 = b.STAFFNO
      union
      select a.OPERATEDATE �˿�����,
             b.STAFFNAME ����Ա,
             'Ѻ��' �˿�����,
             a.SUPPLYMONEY / 100.0 ���
        from TF_F_TRADEFEE_COLLECT a, TD_M_INSIDESTAFF b
       where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
         and (a.TRADETYPECODE = '05' OR a.TRADETYPECODE = '06')
         and a.OPERATESTAFFNO = p_var3
         and p_var3 = b.STAFFNO
      union
      select a.OPERATEDATE �˿�����,
             b.STAFFNAME ����Ա,
             '����' �˿�����,
             a.SUPPLYMONEY / 100.0 ���
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
      select p_var9, a.OPERATEDATE, b.STAFFNAME, '��ֵ', a.CARDDEPOSITFEE
        from TF_F_TRADEFEE_COLLECT a, TD_M_INSIDESTAFF b
       where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
         and (a.TRADETYPECODE = '05' OR a.TRADETYPECODE = '06')
         and a.OPERATESTAFFNO = p_var3
         and p_var3 = b.STAFFNO
      union
      select p_var9, a.OPERATEDATE, b.STAFFNAME, 'Ѻ��', a.SUPPLYMONEY
        from TF_F_TRADEFEE_COLLECT a, TD_M_INSIDESTAFF b
       where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
         and (a.TRADETYPECODE = '05' OR a.TRADETYPECODE = '06')
         and a.OPERATESTAFFNO = p_var3
         and p_var3 = b.STAFFNO
      union
      select p_var9, a.OPERATEDATE, b.STAFFNAME, '����', a.SUPPLYMONEY
        from TF_F_TRADEFEE_COLLECT a, TD_M_INSIDESTAFF b
       where (p_var1 is null or p_var1 = '' or a.OPERATEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.OPERATEDATE <= p_var2)
         and (a.TRADETYPECODE = '05' OR a.TRADETYPECODE = '06')
         and a.OPERATESTAFFNO = p_var3
         and p_var3 = b.STAFFNO;
    commit;
  
  elsif p_funcCode = 'SUPPLY_INCOME_REPORT' then
    -- �����ֵ���ʣ�ԭ��
    if p_var7 = '00000000' then
      open p_cursor for
        select a.TRADEDATE ��ֵ����,
               b.BALUNIT �����ֵ��,
               sum(a.TRADEMONEY) / 100.0 �ܽ��
          from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
           and a.tradetypecode = '02'
           and substr(a.BALUNITNO, 1, 2) <> '0D'
           and a.BALUNITNO = b.BALUNITNO
         group by a.TRADEDATE, b.BALUNIT
        union
        select a.TRADEDATE ��ֵ����,
               b.BALUNIT �����ֵ��,
               sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 �ܽ��
          from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
           and a.tradetypecode = '02'
           and substr(a.BALUNITNO, 1, 2) = '0D'
           and a.BALUNITNO = b.BALUNITNO
         group by a.TRADEDATE, b.BALUNIT;
    else
      open p_cursor for
        select a.TRADEDATE ��ֵ����,
               b.BALUNIT �����ֵ��,
               sum(a.TRADEMONEY) / 100.0 �ܽ��
          from TQ_SUPPLY_RIGHT a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
           and a.tradetypecode = '02'
           and a.BALUNITNO = p_var7
           and substr(a.BALUNITNO, 1, 2) <> '0D'
           and a.BALUNITNO = b.BALUNITNO
         group by a.TRADEDATE, b.BALUNIT
        union
        select a.TRADEDATE ��ֵ����,
               b.BALUNIT �����ֵ��,
               sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 �ܽ��
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
    -- ������ʻ���ֵ����
    open p_cursor for
      select to_char(a.EXAMTIME, 'yyyymmdd') ��ֵ����,
             b.CORPname ��λ,
             c.departname ����,
             sum(a.SUPPLYMONEY) / 100.0 ���
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
    -- ��ֵ���ܲ�ֱ������
    /*open p_cursor for
    
    select CUSTNAME ������λ,CARDVALUE/100.0 ���浥��,TOTALMONEY/100.0 �������,to_char(OPERATETIME,'yyyymmdd') ��������,to_char(PAYTIME,'yyyymmdd') ��������,'3' ������״̬
      from TF_XFC_BATCHSELL
     where PAYTIME is null
       and ( p_var1 is null or p_var1 = '' or to_char(OPERATETIME,'yyyymmdd') >= p_var1)
       and ( p_var2 is null or p_var2 = '' or to_char(OPERATETIME,'yyyymmdd') <= p_var2)
       and ( p_var3 is null or p_var3 = '' or STAFFNO IN (SELECT B.STAFFNO FROM TD_M_INSIDESTAFF B WHERE B.DEPARTNO=P_VAR3))
    union
    select CUSTNAME ������λ,CARDVALUE/100.0 ���浥��,TOTALMONEY/100.0 �������,to_char(OPERATETIME,'yyyymmdd') ��������,to_char(PAYTIME,'yyyymmdd') ��������,'1' ������״̬
      from TF_XFC_BATCHSELL
     where PAYTIME is not null
       and ( p_var1 is null or p_var1 = '' or to_char(OPERATETIME,'yyyymmdd') >= p_var1)
       and ( p_var2 is null or p_var2 = '' or to_char(OPERATETIME,'yyyymmdd') <= p_var2)
       and ( p_var3 is null or p_var3 = '' or STAFFNO IN (SELECT B.STAFFNO FROM TD_M_INSIDESTAFF B WHERE B.DEPARTNO=P_VAR3))
       and to_char(OPERATETIME,'yyyymmdd')=to_char(PAYTIME,'yyyymmdd')
    union
    select CUSTNAME ������λ,CARDVALUE/100.0 ���浥��,TOTALMONEY/100.0 �������,to_char(OPERATETIME,'yyyymmdd') ��������,to_char(PAYTIME,'yyyymmdd') ��������,'2' ������״̬
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
    /*select CUSTNAME ������λ,CARDVALUE/100.0 ���浥��,TOTALMONEY/100.0 �������,BUYTIME ��������,PAYTIME ��������,
         decode(PAYTAG, '1', '���쵽��', '2', '��ʷ����','3','δ����') ������״̬
           from TF_XFC_SERIALNO_DETAIL
          where FIANCE_SERIALNO=p_var9
       order by BUYTIME,PAYTIME;
              commit;*/
      select A.CUSTNAME ������λ,
             N.DEPARTNAME �ƿ�����,
             A.CARDVALUE / 100.0 ���浥��,
             A.TOTALMONEY / 100.0 �������,
             to_char(A.OPERATETIME, 'yyyymmdd') ��������,
             to_char(A.PAYTIME, 'yyyymmdd') ��������,
             'δ����' ������״̬
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
      select A.CUSTNAME ������λ,
             N.DEPARTNAME �ƿ�����,
             A.CARDVALUE / 100.0 ���浥��,
             A.TOTALMONEY / 100.0 �������,
             to_char(A.OPERATETIME, 'yyyymmdd') ��������,
             to_char(A.PAYTIME, 'yyyymmdd') ��������,
             '���쵽��' ������״̬
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
      select A.CUSTNAME ������λ,
             N.DEPARTNAME �ƿ�����,
             A.CARDVALUE / 100.0 ���浥��,
             A.TOTALMONEY / 100.0 �������,
             to_char(A.OPERATETIME, 'yyyymmdd') ��������,
             to_char(A.PAYTIME, 'yyyymmdd') ��������,
             '��ʷ����' ������״̬
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
       order by ��������, ��������;
    commit;
  
  elsif p_funcCode = 'LIJININCOME__RENEW_REPORT' then
    -- ����ת����ͳ��
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
      select INCOMEDATE ת��������,
             MONEY / 100.0 ���,
             CARDCOUNT ������,
             decode(INCOMETYPE, '01', '����ת����', '02', '����ת����') ת��������
        from TF_LIJININCOME_SERIALNO_DETAIL
       where FIANCE_SERIALNO = p_var9;
    commit;
  
  elsif p_funcCode = 'SERVICE_INCOME_REPORT' then
    -- �ͷ��۳����
    if p_var7 = '00000000' then
      open p_cursor for
        select to_char(a.beginTIME, 'yyyymmdd') ��������,
               b.BALUNIT �ͷ�����,
               'Ѻ��' ��������,
               a.TRANSFEE / 100.0 ���
          from TF_SELL_INCOMEFIN a, TF_SELSUP_BALUNIT b
         where (p_var1 is null or p_var1 = '' or
               to_char(a.beginTIME, 'yyyymmdd') >=
               to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
           and (p_var2 is null or p_var2 = '' or
               to_char(a.beginTIME, 'yyyymmdd') <=
               to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
           and a.BALUNITNO = b.BALUNITNO
        union
        select to_char(a.OPERATETIME, 'yyyymmdd') ��������,
               b.staffname �ͷ�����,
               '��ֵ���ۿ�' ��������,
               sum(a.money) / 100.0 ���
          from tf_xfc_sell a, TD_M_INSIDESTAFF b
         where a.OPERATETIME >=
               to_date(p_var1 || '000000', 'yyyymmddhh24miss')
           and a.OPERATETIME <=
               to_date(p_var2 || '235959', 'yyyymmddhh24miss')
           and a.STAFFNO = b.STAFFNO
         group by to_char(a.OPERATETIME, 'yyyymmdd'), b.staffname
        union
        select a.OPERATEDATE ��������,
               b.STAFFNAME �ͷ�����,
               c.TRADETYPE ��������,
               sum(a.cardservfee + a.carddepositfee + a.supplymoney +
                   a.tradeprocfee + a.funcfee + a.otherfee) / 100.0 ���
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
        select a.OPERATEDATE ��������,
               b.STAFFNAME �ͷ�����,
               '��Ѻ��' ��������,
               sum(a.carddepositfee) / 100.0 ���
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
        select a.OPERATEDATE ��������,
               b.STAFFNAME �ͷ�����,
               '�˳�ֵ' ��������,
               sum(a.supplymoney) / 100.0 ���
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
        select to_char(a.beginTIME, 'yyyymmdd') ��������,
               b.BALUNIT �ͷ�����,
               'Ѻ��' ��������,
               a.TRANSFEE / 100.0 ���
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
               'Ѻ��',
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
               '��ֵ���ۿ�',
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
               '��Ѻ��',
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
               '�˳�ֵ',
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
               'Ѻ��',
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
    -- ��������ת���±�
    open p_cursor for
      select c.BANK ������,
             substr(a.BALUNITNO, 5, 4) �̻�����,
             b.BALUNIT �̻�����,
             b.bankaccno �����˺�,
             sum(a.TRANSFEE) / 100.0 ת�ʽ��,
             sum(a.COMFEE) / 100.0 Ӷ��
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
    -- �������Կ������±�
    open p_cursor for
      select c.BANK ������,
             substr(a.BALUNITNO, 5, 4) �̻�����,
             b.BALUNIT �̻�����,
             b.bankaccno �����˺�,
             sum(a.TRANSFEE) / 100.0 ���Կ�����
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
    -- ��ϢͤӶ���±�
    open p_cursor for
      select '����<=5,���>=100' Ӷ������,
             sum(times) �ܱ���,
             sum(times) * 1.0 Ӷ����
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
      select '����<=5,���<100' Ӷ������,
             sum(times) �ܱ���,
             sum(money) / 10000.0 Ӷ����
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
      select '����>5,(��ֵ���/100)>5' Ӷ������,
             count(*) �ܱ���,
             count(*) * 5.0 Ӷ����
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
      select '����>5,(��ֵ���/100)<=5' Ӷ������,
             count(*) �ܱ���,
             nvl(sum(money), 0) Ӷ����
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
             '����<=5,���>=100',
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
             '����<=5,���<100',
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
             '����>5,(��ֵ���/100)>5',
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
             '����>5,(��ֵ���/100)<=5',
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
    -- �ۻ����±�
    open p_cursor for
      SELECT /*+ rule */
       B.CARDSURFACENAME ��������,
       '�ۿ�' ��������,
       (A.DEPOSIT + A.CARDCOST) / 100.0 ���׽��,
       COUNT(*) ������
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
       B.CARDSURFACENAME ��������,
       '����' ��������,
       (A.DEPOSIT + A.CARDCOST) / 100.0 ���׽��,
       COUNT(*) ������
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
       B.CARDSURFACENAME ��������,
       '���ΰ쿨' ��������,
       A.CURRENTMONEY / 100.0 ���׽��,
       COUNT(*) ������
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
       '�ۿ�',
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
       '����',
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
       '���ΰ쿨',
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
    -- ӪҵԱ�ձ�
    open p_cursor for
      SELECT ����,
             ӪҵԱ,
             ��������,
             SUM(��������) ��������,
             SUM(NVL(�������, 0)) �������
        FROM (SELECT TB.DEPARTNAME ����,
                     TB.STAFFNAME ӪҵԱ,
                     TB.TRADETYPE ��������,
                     COUNT(*) ��������,
                     SUM(TB.OPMONEY) / 100.0 �������
                FROM (SELECT E.DEPARTNAME,
                             nvl(D.STAFFNAME, A.OPERATESTAFFNO) STAFFNAME,
                             (B.CARDSERVFEE + B.CARDDEPOSITFEE +
                             B.SUPPLYMONEY + B.TRADEPROCFEE + B.FUNCFEE +
                             B.OTHERFEE) OPMONEY,
                             (CASE
                               WHEN C.TRADETYPE = '�ۿ�' THEN
                                (CASE
                                  WHEN A.CARDNO NOT LIKE '215018%' AND B.CARDSERVFEE <> '0' THEN
                                   '�ۿ�(����' || NVL2(B.CARDSERVFEE, B.CARDSERVFEE / 100.0, 0) || ')'
                                  WHEN A.CARDNO NOT LIKE '215018%' AND B.CARDDEPOSITFEE <> '0' THEN
                                   '�ۿ�(Ѻ��' || NVL2(B.CARDDEPOSITFEE, B.CARDDEPOSITFEE / 100.0, 0) || ')'
                                  WHEN A.CARDNO LIKE '215018%' THEN
                                   '�ۿ�(A��)'
                                  ELSE
                                   '�ۿ�(����' || NVL2(B.CARDSERVFEE, B.CARDSERVFEE / 100.0, 0) || ')'
                                END)
                               WHEN C.TRADETYPE = '�ۿ�����' THEN
                                (CASE
                                  WHEN B.CARDSERVFEE <> '0' THEN
                                   '�ۿ�����(����' || NVL2(B.CARDSERVFEE, B.CARDSERVFEE / 100.0, 0) || ')'
                                  WHEN B.CARDDEPOSITFEE <> '0' THEN
                                   '�ۿ�����(Ѻ��' || NVL2(B.CARDDEPOSITFEE, B.CARDDEPOSITFEE / 100.0, 0) || ')'
                                  ELSE
                                   '�ۿ�����(����' || NVL2(B.CARDSERVFEE, B.CARDSERVFEE / 100.0, 0) || ')'
                                END)
                               WHEN C.TRADETYPE = '����' THEN
                                (CASE
                                  WHEN A.CARDNO NOT LIKE '215018%' AND EXISTS
                                   (SELECT 1
                                          FROM TL_R_ICUSER TR
                                         WHERE TR.CARDNO = B.CARDNO
                                           AND TR.SALETYPE = '02') THEN
                                   '����(Ѻ��)'
                                  WHEN A.CARDNO NOT LIKE '215018%' AND
                                       (B.CARDSERVFEE + B.CARDDEPOSITFEE + B.SUPPLYMONEY + B.TRADEPROCFEE +
                                       B.FUNCFEE + B.OTHERFEE) >= 0 AND EXISTS
                                   (SELECT 1
                                          FROM TL_R_ICUSER TL
                                         WHERE TL.CARDNO = B.CARDNO
                                           AND TL.SALETYPE = '01') THEN
                                   '����(����)'
                                  WHEN A.CARDNO NOT LIKE '215018%' AND
                                       (B.CARDSERVFEE + B.CARDDEPOSITFEE + B.SUPPLYMONEY + B.TRADEPROCFEE +
                                       B.FUNCFEE + B.OTHERFEE) < 0 THEN
                                   '����(�˻�)'
                                  WHEN A.CARDNO LIKE '215018%' THEN
                                   '����(A��)'
                                  ELSE
                                   '����(����)'
                                END) || decode(a.reasoncode,
                                               '12',
                                               ':�ɶ���Ϊ�𻵿�',
                                               '13',
                                               ':�ɶ���Ȼ�𻵿�',
                                               '14',
                                               ':���ɶ���Ϊ�𻵿�',
                                               '15',
                                               ':���ɶ���Ȼ�𻵿�',
                                               a.reasoncode)
                               WHEN C.TRADETYPE = '��������' THEN
                                (CASE
                                  WHEN A.CARDNO NOT LIKE '215018%' AND EXISTS
                                   (SELECT 1
                                          FROM TL_R_ICUSER TR
                                         WHERE TR.CARDNO = B.CARDNO
                                           AND TR.SALETYPE = '02') THEN
                                   '��������(Ѻ��)'
                                  WHEN A.CARDNO NOT LIKE '215018%' AND
                                       (B.CARDSERVFEE + B.CARDDEPOSITFEE + B.SUPPLYMONEY + B.TRADEPROCFEE +
                                       B.FUNCFEE + B.OTHERFEE) <= 0 AND EXISTS
                                   (SELECT 1
                                          FROM TL_R_ICUSER TL
                                         WHERE TL.CARDNO = B.CARDNO
                                           AND TL.SALETYPE = '01') THEN
                                   '��������(����)'
                                  WHEN A.CARDNO NOT LIKE '215018%' AND
                                       (B.CARDSERVFEE + B.CARDDEPOSITFEE + B.SUPPLYMONEY + B.TRADEPROCFEE +
                                       B.FUNCFEE + B.OTHERFEE) > 0 THEN
                                   '��������(�˻�)'
                                  WHEN A.CARDNO LIKE '215018%' THEN
                                   '��������(A��)'
                                  ELSE
                                   '��������(����)'
                                END) || decode(a.reasoncode,
                                               '12',
                                               ':�ɶ���Ϊ�𻵿�',
                                               '13',
                                               ':�ɶ���Ȼ�𻵿�',
                                               '14',
                                               ':���ɶ���Ϊ�𻵿�',
                                               '15',
                                               ':���ɶ���Ȼ�𻵿�',
                                               a.reasoncode)
                               WHEN c.TRADETYPE = '���񿨻���' THEN
                                '���񿨻���' || decode(a.reasoncode,
                                                  '12',
                                                  ':�ɶ���Ϊ�𻵿�',
                                                  '13',
                                                  ':�ɶ���Ȼ�𻵿�',
                                                  '14',
                                                  ':���ɶ���Ϊ�𻵿�',
                                                  '15',
                                                  ':���ɶ���Ȼ�𻵿�',
                                                  a.reasoncode)
                               WHEN C.TRADETYPE = '����' THEN
                                '���ɶ�������'
                               WHEN C.TRADETYPE = '��ֵ' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '��ֵ'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '��ֵ(' || FUN_QUERYCHARGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '��ֵ'
                                END)
                               WHEN C.TRADETYPE = 'Ĩ��' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   'Ĩ��'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   'Ĩ��(' || FUN_QUERYCHARGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   'Ĩ��'
                                END)
                               WHEN C.TRADETYPE = '̨�ʷ���' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '��ֵ'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '��ֵ(' || FUN_QUERYCHARGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '��ֵ'
                                END)
                               WHEN C.TRADETYPE = '���������꿨����' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '���������꿨����'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '���������꿨����(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '���������꿨����'
                                END)
                               WHEN C.TRADETYPE = '���������꿨����' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '���������꿨����'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '���������꿨����(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '���������꿨����'
                                END)
                               WHEN C.TRADETYPE = '���������꿨��д��' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '���������꿨��д��'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '���������꿨��д��(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '���������꿨��д��'
                                END)
                               WHEN C.TRADETYPE = '���������꿨��ͨ����' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '���������꿨��ͨ����'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '���������꿨��ͨ����(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '���������꿨��ͨ����'
                                END)
                               WHEN C.TRADETYPE = '���������꿨�ر�' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '���������꿨�ر�'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '���������꿨�ر�(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '���������꿨�ر�'
                                END)
                               WHEN C.TRADETYPE = '�������ӿ�����' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '�������ӿ�����'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '�������ӿ�����(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '�������ӿ�����'
                                END)
                               WHEN C.TRADETYPE = '�������ӿ�����' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '�������ӿ�����'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '�������ӿ�����(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '�������ӿ�����'
                                END)
                               WHEN C.TRADETYPE = '�������ӿ���������' THEN
                                (CASE
                                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                                   '�������ӿ���������'
                                  WHEN A.RSRV2 IS NOT NULL THEN
                                   '�������ӿ���������(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                                  ELSE
                                   '�������ӿ���������'
                                END)
                               WHEN C.TRADETYPE = '��Ʊ����ͨ' THEN
                                '��Ʊ����ͨ' || decode(A.RSRV2,
                                                  '01',
                                                  '-ѧ��',
                                                  '02',
                                                  '-����',
                                                  '03',
                                                  '-����',
                                                  '04',
                                                  '-���Ŀ�',
                                                  '05',
                                                  '-��ģ��',
                                                  '06',
                                                  '-������',
                                                  '07',
                                                  '-��Ѫ��',
												  '08',
                                                  '-�Ÿ���',
                                                  '')
                               WHEN C.TRADETYPE = '��Ʊ���ر�' THEN
                                '��Ʊ���ر�' || decode(A.RSRV2,
                                                  '01',
                                                  '-ѧ��',
                                                  '02',
                                                  '-����',
                                                  '03',
                                                  '-����',
                                                  '04',
                                                  '-���Ŀ�',
                                                  '05',
                                                  '-��ģ��',
                                                  '06',
                                                  '-������',
                                                  '07',
                                                  '-��Ѫ��',
												  '08',
                                                  '-�Ÿ���',
                                                  '')
                               WHEN C.TRADETYPE = '���ǳ�ֵ' THEN
                                '���ǳ�ֵ' || decode(a.RSRV1, '01', 'APP', a.RSRV1) ||
                                decode(a.RSRV2, '01', '֧����', '02', '΢��', '04', 'ר���˻�', a.RSRV2)
                               WHEN C.TRADETYPE = '���ǳ�ֵ����' THEN
                                '���ǳ�ֵ����' || decode(a.RSRV1, '01', 'APP', a.RSRV1) ||
                                decode(a.RSRV2, '01', '֧����', '02', '΢��', '04', 'ר���˻�', a.RSRV2) --add by youyue���Ӳ��ǳ�ֵҵ���ѯ
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
                             P_VAR4 = A.REASONCODE) /*���� BY ����*/
                         AND A.TRADETYPECODE <> '8L' --�ų�ר���˻�������ֵ ��������
                         AND (E.Regioncode IN
                             (select b.regioncode
                                 from td_m_regioncode b
                                where b.regionname =
                                      (select r.regionname
                                         from td_m_regioncode r
                                        where r.regioncode = F.REGIONCODE)) or
                             F.REGIONCODE is null)
                         AND a.TRADETYPECODE NOT in ('7H', '7I', '7K', 'K1') --add by liuhe20130913 �ų����ο�
                      ) TB
               WHERE (P_VAR7 = '1' OR (OPMONEY IS NOT NULL AND OPMONEY <> 0)) --add by youyue���Ӳ����޽��ҵ��
               GROUP BY TB.DEPARTNAME, TB.STAFFNAME, TB.TRADETYPE
              union all ---�����������ڰѿɶ����˿����˿������������ֿ�ͳ�� add by liuhe
              select e.departname ����,
                     d.staffname ӪҵԱ,
                     decode(c.TRADETYPE, '�˿�', '�˿�', '�˿�����') ��������,
                     count(*) ��������,
                     sum(b.CARDDEPOSITFEE) / 100.0 �������
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
                 AND (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = A.REASONCODE) /*���� BY ����*/
                 AND (E.Regioncode IN
                     (select b.regioncode
                         from td_m_regioncode b
                        where b.regionname =
                              (select r.regionname
                                 from td_m_regioncode r
                                where r.regioncode = F.REGIONCODE)) or
                     F.REGIONCODE is null)
                 AND (P_VAR7 = '1' OR (b.CARDDEPOSITFEE IS NOT NULL AND
                     b.CARDDEPOSITFEE <> 0)) --add by youyue���Ӳ����޽��ҵ��
               group by e.departname, d.staffname, c.TRADETYPE
              union all --����
              select e.departname ����,
                     d.staffname ӪҵԱ,
                     decode(c.TRADETYPE,
                            '�˿�',
                            '�ɶ�������',
                            '�ɶ�����������') ��������,
                     count(*) ��������,
                     sum(b.SUPPLYMONEY + b.TRADEPROCFEE + b.FUNCFEE +
                         b.OTHERFEE) / 100.0 �������
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
                 AND (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = A.REASONCODE) /*���� BY ����*/
                 AND (P_VAR7 = '1' OR
                     ((b.SUPPLYMONEY IS NOT NULL AND b.SUPPLYMONEY <> 0) OR
                     (b.TRADEPROCFEE IS NOT NULL AND b.TRADEPROCFEE <> 0) OR
                     (b.FUNCFEE IS NOT NULL AND b.FUNCFEE <> 0) OR
                     (b.OTHERFEE IS NOT NULL AND b.OTHERFEE <> 0))) --add by youyue���Ӳ����޽��ҵ��
               group by e.departname, d.staffname, c.TRADETYPE
              ------------���ο�
              union all
              select e.departname ����,
                     d.staffname ӪҵԱ,
                     c.TRADETYPE || '(Ѻ��)' ��������,
                     count(*) ��������,
                     sum(b.CARDDEPOSITFEE) / 100.0 �������
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
                     b.CARDDEPOSITFEE <> 0)) --add by youyue���Ӳ����޽��ҵ��
               group by e.departname, d.staffname, c.TRADETYPE
              union all
              select e.departname ����,
                     d.staffname ӪҵԱ,
                     c.TRADETYPE || '(��ֵ)' ��������,
                     count(*) ��������,
                     sum(b.SUPPLYMONEY) / 100.0 �������
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
                     (b.SUPPLYMONEY IS NOT NULL AND b.SUPPLYMONEY <> 0)) --add by youyue���Ӳ����޽��ҵ��
               group by e.departname, d.staffname, c.TRADETYPE
              union all
              select e.departname ����,
                     d.staffname ӪҵԱ,
                     c.TRADETYPE || '(������)' ��������,
                     count(*) ��������,
                     sum(b.TRADEPROCFEE) / 100.0 �������
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
                     (b.TRADEPROCFEE IS NOT NULL AND b.TRADEPROCFEE <> 0)) --add by youyue���Ӳ����޽��ҵ��
               group by e.departname, d.staffname, c.TRADETYPE
              ------------���ο�
              union all
              select c.departname ����,
                     b.staffname ӪҵԱ,
                     'ר���˻�������ֵ',
                     count(*) ��������,
                     sum(a.supplymoney) / 100.0 �������
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
                     (a.supplymoney IS NOT NULL AND a.supplymoney <> 0)) --add by youyue���Ӳ����޽��ҵ��
               group by c.departname, b.staffname
              union all
              select c.departname ����,
                     b.staffname ӪҵԱ,
                     '���𿨻���',
                     count(*) ��������,
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
                 AND (P_VAR7 = '1' OR (b.staffname IS NULL)) --add by youyue���Ӳ����޽��ҵ���ų����𿨻���ҵ��
               group by c.departname, b.staffname
              union all --���Ӷ��������۱����ѯ
              select c.departname ����,
                     b.staffname ӪҵԱ,
                     d.tradetype || '(' ||
                     a.MONEY / 100.0 / NVL(a.READERNUMBER, 1) || '*' ||
                     a.READERNUMBER || ')' AS ��������,
                     COUNT(*) ��������,
                     sum(a.MONEY) / 100.0 �������
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
                 and a.OPERATETYPECODE not in ('00', '01') --ȥ��������youyue20130922
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
                 AND (P_VAR7 = '1' OR (a.MONEY IS NOT NULL AND a.MONEY <> 0)) --add by youyue���Ӳ����޽��ҵ��
               group by c.departname,
                        b.staffname,
                        d.tradetype,
                        a.money,
                        a.READERNUMBER)
       group by ����, ӪҵԱ, ��������
       order by ����, ��������, ӪҵԱ;
  
  elsif p_funcCode = 'TRADE_LOG_LIST' then
    -- ӪҵԱ�ձ���ϸ
    open p_cursor for
      select e.departname ����,
             nvl(d.staffname, a.OPERATESTAFFNO) ӪҵԱ,
             a.CARDNO ����,
             (case
               when c.TRADETYPE = '��ֵ' then
                (CASE
                  WHEN (a.RSRV2 IS NULL OR a.RSRV2 = '') THEN
                   '��ֵ'
                  WHEN a.RSRV2 IS NOT NULL THEN
                   '��ֵ(' || FUN_QUERYCHARGETYPE(a.RSRV2) || ')'
                  ELSE
                   '��ֵ'
                END)
               WHEN c.TRADETYPE = 'Ĩ��' THEN
                (CASE
                  WHEN (a.RSRV2 IS NULL OR a.RSRV2 = '') THEN
                   'Ĩ��'
                  WHEN a.RSRV2 IS NOT NULL THEN
                   'Ĩ��(' || FUN_QUERYCHARGETYPE(a.RSRV2) || ')'
                  ELSE
                   'Ĩ��'
                END)
               WHEN c.TRADETYPE = '̨�ʷ���' THEN
                (CASE
                  WHEN (a.RSRV2 IS NULL OR a.RSRV2 = '') THEN
                   '��ֵ'
                  WHEN a.RSRV2 IS NOT NULL THEN
                   '��ֵ(' || FUN_QUERYCHARGETYPE(a.RSRV2) || ')'
                  ELSE
                   '��ֵ'
                END)
               WHEN C.TRADETYPE = '���������꿨����' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '���������꿨����'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '���������꿨����(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '���������꿨����'
                END)
               WHEN C.TRADETYPE = '���������꿨����' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '���������꿨����'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '���������꿨����(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '���������꿨����'
                END)
               WHEN C.TRADETYPE = '���������꿨��д��' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '���������꿨��д��'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '���������꿨��д��(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '���������꿨��д��'
                END)
               WHEN C.TRADETYPE = '���������꿨��ͨ����' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '���������꿨��ͨ����'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '���������꿨��ͨ����(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '���������꿨��ͨ����'
                END)
               WHEN C.TRADETYPE = '���������꿨�ر�' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '���������꿨�ر�'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '���������꿨�ر�(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '���������꿨�ر�'
                END)
               WHEN C.TRADETYPE = '�������ӿ�����' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '�������ӿ�����'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '�������ӿ�����(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '�������ӿ�����'
                END)
               WHEN C.TRADETYPE = '�������ӿ�����' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '�������ӿ�����'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '�������ӿ�����(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '�������ӿ�����'
                END)
               WHEN C.TRADETYPE = '�������ӿ���������' THEN
                (CASE
                  WHEN (A.RSRV2 IS NULL OR A.RSRV2 = '') THEN
                   '�������ӿ���������'
                  WHEN A.RSRV2 IS NOT NULL THEN
                   '�������ӿ���������(' || FUN_QUERYPACKAGETYPE(A.RSRV2) || ')'
                  ELSE
                   '�������ӿ���������'
                END)
               WHEN c.TRADETYPE = '����' THEN
                (CASE
                  WHEN A.CARDNO LIKE '215018%' THEN
                   '����(A��)'
                  ELSE
                   '����'
                END) || decode(a.reasoncode,
                               '12',
                               ':�ɶ���Ϊ�𻵿�',
                               '13',
                               ':�ɶ���Ȼ�𻵿�',
                               '14',
                               ':���ɶ���Ϊ�𻵿�',
                               '15',
                               ':���ɶ���Ȼ�𻵿�',
                               a.reasoncode)
               WHEN c.TRADETYPE = '���񿨻���' THEN
                '���񿨻���' || decode(a.reasoncode,
                                  '12',
                                  ':�ɶ���Ϊ�𻵿�',
                                  '13',
                                  ':�ɶ���Ȼ�𻵿�',
                                  '14',
                                  ':���ɶ���Ϊ�𻵿�',
                                  '15',
                                  ':���ɶ���Ȼ�𻵿�',
                                  a.reasoncode)
               WHEN c.TRADETYPE = '��������' THEN
                (CASE
                  WHEN A.CARDNO LIKE '215018%' THEN
                   '��������(A��)'
                  ELSE
                   '��������'
                END) || decode(a.reasoncode,
                               '12',
                               ':�ɶ���Ϊ�𻵿�',
                               '13',
                               ':�ɶ���Ȼ�𻵿�',
                               '14',
                               ':���ɶ���Ϊ�𻵿�',
                               '15',
                               ':���ɶ���Ȼ�𻵿�',
                               a.reasoncode)
               WHEN c.TRADETYPE = '�˿�' THEN
                c.TRADETYPE || decode(a.reasoncode,
                                      '11',
                                      ':�ɶ�������',
                                      '12',
                                      ':�ɶ���Ϊ�𻵿�',
                                      '13',
                                      ':�ɶ���Ȼ�𻵿�',
                                      '14',
                                      ':���ɶ���Ϊ�𻵿�',
                                      '15',
                                      ':���ɶ���Ȼ�𻵿�',
                                      a.reasoncode)
               WHEN c.TRADETYPE = '�ۿ�' THEN
                (CASE
                  WHEN A.CARDNO LIKE '215018%' THEN
                   '�ۿ�(A��)'
                  ELSE
                   '�ۿ�'
                END)
               WHEN c.TRADETYPE = '�ۿ�����' THEN
                (CASE
                  WHEN A.CARDNO LIKE '215018%' THEN
                   '�ۿ�����(A��)'
                  ELSE
                   '�ۿ�����'
                END)
               WHEN c.TRADETYPE = '��Ʊ����ͨ' THEN
                '��Ʊ����ͨ' || decode(a.RSRV2,
                                  '01',
                                  '-ѧ��',
                                  '02',
                                  '-����',
                                  '03',
                                  '-����',
                                  '04',
                                  '-���Ŀ�',
                                  '05',
                                  '-��ģ��',
                                  '06',
                                  '-������',
                                  '07',
                                  '-��Ѫ��',
								  '08',
                                  '-�Ÿ���',
                                  '')
               WHEN c.TRADETYPE = '��Ʊ���ر�' THEN
                '��Ʊ���ر�' || decode(a.RSRV2,
                                  '01',
                                  '-ѧ��',
                                  '02',
                                  '-����',
                                  '03',
                                  '-����',
                                  '04',
                                  '-���Ŀ�',
                                  '05',
                                  '-��ģ��',
                                  '06',
                                  '-������',
                                  '07',
                                  '-��Ѫ��',
								  '08',
                                  '-�Ÿ���',
                                  '')
               WHEN C.TRADETYPE = '���ǳ�ֵ' THEN
                '���ǳ�ֵ' || decode(a.RSRV1, '01', 'APP', a.RSRV1) ||
                decode(a.RSRV2, '01', '֧����', '02', '΢��', '04', 'ר���˻�', a.RSRV2)
               WHEN C.TRADETYPE = '���ǳ�ֵ����' THEN
                '���ǳ�ֵ����' || decode(a.RSRV1, '01', 'APP', a.RSRV1) ||
                decode(a.RSRV2, '01', '֧����', '02', '΢��', '04', 'ר���˻�', a.RSRV2) --add by youyue���Ӳ��ǳ�ֵҵ���ѯ
               else
                c.TRADETYPE
             END) AS ��������,
             NVL(b.CARDSERVFEE, 0) / 100.0 �������,
             NVL(b.CARDDEPOSITFEE, 0) / 100.0 ��Ѻ��,
             NVL(b.SUPPLYMONEY, 0) / 100.0 ��ֵ,
             NVL(b.TRADEPROCFEE, 0) / 100.0 ������,
             NVL(b.FUNCFEE, 0) / 100.0 ���ܷ�,
             NVL(b.OTHERFEE, 0) / 100.0 �ۿ۽��,
             a.OPERATETIME ����ʱ��
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
         AND A.TRADETYPECODE <> '8L' --�ų�ר���˻�������ֵ ���� ����
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
             (b.OTHERFEE IS NOT NULL AND b.OTHERFEE <> 0))) --add by youyue���Ӳ����޽��ҵ��
      union all
      select e.departname    ����,
             d.staffname     ӪҵԱ,
             a.ASSOCIATECODE ����,
             c.TRADETYPE     ��������,
             0               �������,
             0               ��Ѻ��,
             0               ��ֵ,
             0               ������,
             0               ���ܷ�,
             0               �ۿ۽��,
             a.OPERATETIME   ����ʱ��
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
         AND (P_VAR7 = '1' OR d.staffname IS NULL) --add by youyue���Ӳ����޽��ҵ��
      union all
      select c.departname ����,
             b.staffname ӪҵԱ,
             a.cardno ����,
             'ר���˻�������ֵ',
             0 �������,
             0 ��Ѻ��,
             a.supplymoney / 100.0 ��ֵ,
             0 ������,
             0 ���ܷ�,
             0 �ۿ۽��,
             s.SUPPLYTIME ����ʱ��
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
             (a.supplymoney IS NOT NULL AND a.supplymoney <> 0)) --add by youyue���Ӳ����޽��ҵ��
      union all --���Ӷ��������۱����ѯ
      select c.departname ����,
             b.staffname ӪҵԱ,
             a.BEGINSERIALNUMBER ����,
             d.tradetype ��������,
             0 �������,
             0 ��Ѻ��,
             a.MONEY / 100.0 ��ֵ,
             0 ������,
             0 ���ܷ�,
             0 �ۿ۽��,
             a.OPERATETIME ����ʱ��
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
         AND (P_VAR7 = '1' OR (a.MONEY IS NOT NULL AND a.MONEY <> 0)) --add by youyue���Ӳ����޽��ҵ��
      union all
      select c.departname  ����,
             b.staffname   ӪҵԱ,
             a.cardno      ����,
             '���𿨻���',
             0             �������,
             0             ��Ѻ��,
             0             ��ֵ,
             0             ������,
             0             ���ܷ�,
             0             �ۿ۽��,
             a.OPERATETIME ����ʱ��
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
         AND (P_VAR7 = '1' OR b.staffname IS NULL) --add by youyue���Ӳ����޽��ҵ��
       order by 4, 11;
  
  elsif p_funcCode = 'XFC_SELL_REPORT' then
    -- ��ֵ�������ձ�
    if p_var3 is null then
      if p_var10 is null then
        open p_cursor for
          select c.departname ����,
                 b.staffname ӪҵԱ,
                 a.money / 100.0 / a.amount ������,
                 a.amount ����,
                 a.money / 100.0 �ܽ��,
                 a.OPERATETIME ʱ��
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
          select c.departname ����,
                 b.staffname ӪҵԱ,
                 a.cardvalue / 100.0 ������,
                 a.amount ����,
                 a.totalmoney / 100.0 �ܽ��,
                 a.OPERATETIME ʱ��
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
             and (RSRV1 IS NULL OR RSRV1 <> '1') --ȥ��������
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
          select c.departname ����,
                 b.staffname ӪҵԱ,
                 a.money / 100.0 / a.amount ������,
                 a.amount ����,
                 a.money / 100.0 �ܽ��,
                 a.OPERATETIME ʱ��
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
          select c.departname ����,
                 b.staffname ӪҵԱ,
                 a.cardvalue / 100.0 ������,
                 a.amount ����,
                 a.totalmoney / 100.0 �ܽ��,
                 a.OPERATETIME ʱ��
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
             and (RSRV1 IS NULL OR RSRV1 <> '1') --ȥ��������
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
        select c.departname ����,
               b.staffname ӪҵԱ,
               a.money / 100.0 / a.amount ������,
               a.amount ����,
               a.money / 100.0 �ܽ��,
               a.OPERATETIME ʱ��
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
        select c.departname ����,
               b.staffname ӪҵԱ,
               a.cardvalue / 100.0 ������,
               a.amount ����,
               a.totalmoney / 100.0 �ܽ��,
               a.OPERATETIME ʱ��
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
           and (RSRV1 IS NULL OR RSRV1 <> '1') --ȥ��������
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
    -- ��ֵ�������ձ���ϸ
    if p_var3 is null then
      if p_var10 is null then
        open p_cursor for
          select a.startcardno ��ʼ����,
                 a.endcardno ��ֹ����,
                 a.money / a.amount / 100.0 ��ֵ,
                 a.amount ������,
                 a.money / 100.0 �ܽ��,
                 a.operatetime ����ʱ��,
                 c.departname ���۲���,
                 b.staffname ����Ա��,
                 a.remark ��ע
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
          select a.startcardno ��ʼ����,
                 a.endcardno ��ֹ����,
                 a.cardvalue / 100.0 ��ֵ,
                 a.amount ������,
                 a.totalmoney / 100.0 �ܽ��,
                 a.operatetime ����ʱ��,
                 c.departname ���۲���,
                 b.staffname ����Ա��,
                 a.remark ��ע
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
             and (RSRV1 IS NULL OR RSRV1 <> '1'); --ȥ��������
      else
        open p_cursor for
          select a.startcardno ��ʼ����,
                 a.endcardno ��ֹ����,
                 a.money / a.amount / 100.0 ��ֵ,
                 a.amount ������,
                 a.money / 100.0 �ܽ��,
                 a.operatetime ����ʱ��,
                 c.departname ���۲���,
                 b.staffname ����Ա��,
                 a.remark ��ע
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
          select a.startcardno ��ʼ����,
                 a.endcardno ��ֹ����,
                 a.cardvalue / 100.0 ��ֵ,
                 a.amount ������,
                 a.totalmoney / 100.0 �ܽ��,
                 a.operatetime ����ʱ��,
                 c.departname ���۲���,
                 b.staffname ����Ա��,
                 a.remark ��ע
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
        select a.startcardno ��ʼ����,
               a.endcardno ��ֹ����,
               a.money / a.amount / 100.0 ��ֵ,
               a.amount ������,
               a.money / 100.0 �ܽ��,
               a.operatetime ����ʱ��,
               c.departname ���۲���,
               b.staffname ����Ա��,
               a.remark ��ע
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
        select a.startcardno ��ʼ����,
               a.endcardno ��ֹ����,
               a.cardvalue / 100.0 ��ֵ,
               a.amount ������,
               a.totalmoney / 100.0 �ܽ��,
               a.operatetime ����ʱ��,
               c.departname ���۲���,
               b.staffname ����Ա��,
               a.remark ��ע
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
    -- �����ʽ����
    open p_cursor for
      select COLLECTMONTH ͳ���·�,
             YPDEPOSIT / 100.0 ��Ѻ��,
             DEPOSIT / 100.0 ��Ѻ��,
             SUPPLY / 100.0 ��ֵ��,
             NORMAL / 100.0 ��ͨ������Ǯ��,
             LIJIN / 100.0 ���𿨵���Ǯ��,
             ACCOUNT / 100.0 �������̨�ʻ�
        from TF_DEPOSIT_FUND_COLLECT
       where COLLECTMONTH >= cast(p_var1 as char(8))
         and COLLECTMONTH <= cast(p_var2 as char(8))
       order by COLLECTMONTH;
  
  elsif p_funcCode = 'FUNDS_COLLECT_TOTAL' then
    -- �����ʽ����ͳ�� add by shil 20130711
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
    -- �����ʽ���ϸ��Ϣ add by shil 20130711
    open p_cursor for
      select CATEGORY ��֧���,
             NAME ��֧��Ŀ,
             nvl(sum(MONEY) / 100.0, 0) ���
        from TF_FUNDSANALYSIS
       where substr(STATTIME, 0, 6) >= cast(p_var1 as char(6))
         and substr(STATTIME, 0, 6) <= cast(p_var2 as char(6))
       group by CATEGORY, NAME
       order by CATEGORY, NAME;
  
  elsif p_funcCode = 'POS_TRADE_RELATION' then
    -- POS�̻���Ӧ����
    open p_cursor for
      select '��Ͷ' ����,
             '����' �̻�����,
             2757 POS����,
             sum(b.TRANSFEE) / 100.0 ���ѽ��,
             round(sum(b.TRANSFEE) / 2757 / 100.0, 2) POSƽ�����Ѷ�,
             round(sum(b.COMFEE) / 2757 / 100.0, 2) POSƽ��Ӷ������
        from TF_TRADE_OUTCOMEFIN b
       where (p_var1 is null or p_var1 = '' or
             to_char(b.ENDTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
         and (p_var2 is null or p_var2 = '' or
             to_char(b.ENDTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
         and b.callingno = '01'
      union
      select '��Ͷ' ����,
             '����' �̻�����,
             3203 POS����,
             sum(b.TRANSFEE) / 100.0 ���ѽ��,
             round(sum(b.TRANSFEE) / 3203 / 100.0, 2) POSƽ�����Ѷ�,
             round(sum(b.COMFEE) / 3203 / 100.0, 2) POSƽ��Ӷ������
        from TF_TAXI_OUTCOMEFIN b
       where (p_var1 is null or p_var1 = '' or
             to_char(ENDTIME, 'yyyymmdd') >= p_var1)
         and (p_var2 is null or p_var2 = '' or
             to_char(ENDTIME, 'yyyymmdd') <= p_var2)
      union
      select '��Ͷ' ����,
             '��Ϣͤ' �̻�����,
             172 POS����,
             sum(b.TRANSFEE) / 100.0 ���ѽ��,
             round(sum(b.TRANSFEE) / 172 / 100.0, 2) POSƽ�����Ѷ�,
             round(sum(b.COMFEE) / 172 / 100.0, 2) POSƽ��Ӷ������
        from TF_TRADE_OUTCOMEFIN b
       where (p_var1 is null or p_var1 = '' or
             to_char(b.ENDTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
         and (p_var2 is null or p_var2 = '' or
             to_char(b.ENDTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
         and b.callingno = '0C'
      union
      select a.POSTYPE ����,
             a.BALUNIT �̻�����,
             sum(a.POSCOUNT) POS����,
             sum(b.TRANSFEE) / 100.0 ���ѽ��,
             round(sum(b.TRANSFEE) / sum(a.POSCOUNT) / 100.0, 2) POSƽ�����Ѷ�,
             round(sum(b.COMFEE) / sum(a.POSCOUNT) / 100.0, 2) POSƽ��Ӷ������
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
    -- �㽻��POS����
    open p_cursor for
      select SHOP �̻�, count(*) POS��, REASON ԭ��, ENDDATE Э�鵽������
        from TF_ZEROTRADEPOS_COLLECT
       group by SHOP, REASON, ENDDATE;
  
  elsif p_funcCode = 'SELLCARD_ROLLBACK' then
    -- �ۿ�����
    open p_cursor for
      select to_char(b.OPERATETIME, 'yyyymmdd') �ۿ�����,
             c.staffname ����Ա��,
             b.CARDDEPOSITFEE / 100.0 �ۿ�Ѻ��,
             b.CARDSERVFEE / 100.0 �ۿ�����,
             count(*) ����,
             d.staffname ����Ա��,
             to_char(a.OPERATETIME, 'yyyymmdd') ��������
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
    -- ������޸�
    open p_cursor for
      select a.CARDNO ����,
             a.PREBALANCE / 100.0 �޸�ǰ���,
             (a.NEWBALANCE - a.PREBALANCE) / 100.0 �޸Ľ��,
             b.staffname �ύԱ��,
             a.SUBMITTIME �ύʱ��,
             c.staffname ���Ա��,
             a.CHECKTIME ���ʱ��
        from TF_SPECIAL_CHNAGEBALANCE a,
             TD_M_INSIDESTAFF         b,
             TD_M_INSIDESTAFF         c
       where a.CHECKTIME >= to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and a.CHECKTIME <= to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         and a.CHECKSTATE = '2'
         and a.SUBMITSTAFF = b.STAFFNO
         and a.CHECKSTAFF = c.STAFFNO;
  
  elsif p_funcCode = 'LIJIN_RENEW_REPORT' then
    -- ���𿨻���ͳ��
    open p_cursor for
      select b.BALUNIT �̻�����,
             COUNT(A.CARDNO) ���տ�����,
             to_char(a.DEALTIME, 'yyyymm') ����ʱ��
        from TQ_TRADE_RIGHT a, TF_TRADE_BALUNIT b
       where a.ICTRADETYPECODE = '06'
         and a.BALUNITNO = b.BALUNITNO
         and a.callingno <> '01'
         and to_char(a.DEALTIME, 'yyyymm') = p_var1
       group by b.BALUNIT, a.dealtime;
  
  elsif p_funcCode = 'LIJIN_RENEW_DETAIL' then
    -- ���𿨻�����ϸ
    open p_cursor for
      select a.CARDNO   ����,
             a.POSNO    POS��,
             b.BALUNIT  �̻�����,
             a.DEALTIME ����ʱ��
        from TQ_TRADE_RIGHT a, TF_TRADE_BALUNIT b
       where a.DEALTIME >= to_date(p_var1 || '000000', 'yyyymmddhh24miss')
         and a.DEALTIME <= to_date(p_var2 || '235959', 'yyyymmddhh24miss')
         and a.ICTRADETYPECODE = '06'
         and a.callingno <> '01'
         and a.BALUNITNO = b.BALUNITNO;
  
  elsif p_funcCode = 'SPEADJUSTQUERY' then
    -- �������Ӷ���ѯ
    open p_cursor for
      select a.balunitno ���㵥Ԫ����,
             b.balunit ���㵥Ԫ����,
             count(*) �����ܴ���,
             sum(a.refundment) / 100 �����ܽ��,
             sum(a.refundment) / 100 * cl.slope Ӧ�˻�Ӷ���
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
    --��콻�ײ�¼����
    open p_cursor for
      select '���' �̻�����,
             to_char(a.CHECKTIME, 'yyyymmdd') ת��ʱ��,
             sum(a.TRADEMONEY / 100.0) ת�ʽ��
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
    -- �̻������ֵ����
    if p_var7 = '00000000' then
      open p_cursor for
        select TRADEDATE ��������,
               DBALUNIT ���㵥Ԫ,
               SUM(��ֵ) ��ֵ,
               SUM(����) ����,
               SUM(����) ����,
               SUM(�˿�) �˿�,
               SUM(�˿����) �˿����,
               SUM(��ֵ - ���� + ����) ת��,
               SUM(����) ����,
               SUM(��ֵ - ���� + ���� - �˿�) ת�ʿ��˿�
          from (select a.TRADEDATE,
                       b.DBALUNIT,
                       sum(a.TRADEMONEY) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����,
                       0 �˿����
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
                       sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����,
                       0 �˿����
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
                       sum(a.TRADEMONEY) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����,
                       0 �˿����
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
                       0 ��ֵ,
                       sum(a.TRADEMONEY) / 100.0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����,
                       0 �˿����
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
                       0 ��ֵ,
                       0 ����,
                       sum(a.TRADEMONEY) / 100.0 ����,
                       0 �˿�,
                       COUNT(*) ����,
                       0 �˿����
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
                       sum(a.factmoney) / 100.0 �˿�,
                       0,
                       COUNT(*) �˿����
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
        select TRADEDATE ��������,
               DBALUNIT ���㵥Ԫ,
               SUM(��ֵ) ��ֵ,
               SUM(����) ����,
               SUM(����) ����,
               SUM(�˿�) �˿�,
               SUM(�˿����) �˿����,
               SUM(��ֵ - ���� + ����) ת��,
               SUM(����) ����,
               SUM(��ֵ - ���� + ���� - �˿�) ת�ʿ��˿�
          from (select a.TRADEDATE,
                       b.DBALUNIT,
                       sum(a.TRADEMONEY) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����,
                       0 �˿����
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
                       sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����,
                       0 �˿����
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
                       sum(a.TRADEMONEY) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����,
                       0 �˿����
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
                       0 ��ֵ,
                       sum(a.TRADEMONEY) / 100.0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����,
                       0 �˿����
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
                       0 ��ֵ,
                       0 ����,
                       sum(a.TRADEMONEY) / 100.0 ����,
                       0 �˿�,
                       COUNT(*) ����,
                       0 �˿����
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
                       sum(a.factmoney) / 100.0 �˿�,
                       0 ����,
                       COUNT(*) �˿����
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
    -- �����ֵ����
    if p_var7 = '00000000' then
      open p_cursor for
        select TRADEDATE ��������,
               BALUNIT ���㵥Ԫ,
               SUM(��ֵ) ��ֵ,
               SUM(����) ����,
               SUM(����) ����,
               SUM(�˿�) �˿�,
               SUM(��ֵ - ���� + ���� - �˿�) ת��,
               SUM(����) ����
          from (select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����
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
                       sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����
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
                       sum(a.TRADEMONEY) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����
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
                       0 ��ֵ,
                       sum(a.TRADEMONEY) / 100.0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����
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
                       0 ��ֵ,
                       0 ����,
                       sum(a.TRADEMONEY) / 100.0 ����,
                       0 �˿�,
                       COUNT(*) ����
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
                       0 ��ֵ,
                       0 ����,
                       0 ����,
                       sum(a.TRADEMONEY) / 100.0 �˿�,
                       COUNT(*) ����
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
        select TRADEDATE ��������,
               BALUNIT ���㵥Ԫ,
               SUM(��ֵ) ��ֵ,
               SUM(����) ����,
               SUM(����) ����,
               SUM(�˿�) �˿�,
               SUM(��ֵ - ���� + ���� - �˿�) ת��,
               SUM(����) ����
          from (select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����
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
                       sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����
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
                       sum(a.TRADEMONEY) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����
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
                       0 ��ֵ,
                       sum(a.TRADEMONEY) / 100.0 ����,
                       0 ����,
                       0 �˿�,
                       COUNT(*) ����
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
                       0 ��ֵ,
                       0 ����,
                       sum(a.TRADEMONEY) / 100.0 ����,
                       0 �˿�,
                       COUNT(*) ����
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
                       0 ��ֵ,
                       0 ����,
                       0 ����,
                       sum(a.TRADEMONEY) / 100.0 �˿�,
                       COUNT(*) ����
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
               TRADEDATE ��������,
               BALUNIT ���㵥Ԫ,
               SUM(��ֵ - ���� + ���� - �˿�) ת��
          from (select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�
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
                       sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�
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
                       sum(a.TRADEMONEY) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�
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
                       0 ��ֵ,
                       sum(a.TRADEMONEY) / 100.0 ����,
                       0 ����,
                       0 �˿�
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
                       0 ��ֵ,
                       0 ����,
                       sum(a.TRADEMONEY) / 100.0 ����,
                       0 �˿�
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
                       0 ��ֵ,
                       0 ����,
                       0 ����,
                       sum(a.TRADEMONEY) / 100.0 �˿�
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
               TRADEDATE ��������,
               BALUNIT ���㵥Ԫ,
               SUM(��ֵ - ���� + ���� - �˿�) ת��
          from (select a.TRADEDATE,
                       b.BALUNIT,
                       sum(a.TRADEMONEY) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�
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
                       sum(a.TRADEMONEY) * (1 - 0.007) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�
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
                       sum(a.TRADEMONEY) / 100.0 ��ֵ,
                       0 ����,
                       0 ����,
                       0 �˿�
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
                       0 ��ֵ,
                       sum(a.TRADEMONEY) / 100.0 ����,
                       0 ����,
                       0 �˿�
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
                       0 ��ֵ,
                       0 ����,
                       sum(a.TRADEMONEY) / 100.0 ����,
                       0 �˿�
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
                       0 ��ֵ,
                       0 ����,
                       0 ����,
                       sum(a.TRADEMONEY) / 100.0 �˿�
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
    -- �����ֵ�澯
    open p_cursor for
      select a.TRADEDATE   ��������,
             b.BALUNIT     ���㵥Ԫ����,
             a.ID          ������ˮ��,
             a.CARDNO      ����,
             a.CARDTRADENO ���������,
             a.PREMONEY    ����ǰ���,
             a.TRADEMONEY  ���׽��,
             a.SAMNO       SAM���,
             a.supplylocno ��ֵ����
        from TF_OUTSUPPLY_ALARM a, TF_SELSUP_BALUNIT b
       where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
         and a.BALUNITNO = b.BALUNITNO
         and a.TRADETYPECODE <> '1S'
         and (p_var7 is null or p_var7 = '' or a.BALUNITNO = p_var7)
         and b.alarmstate = '1'
       order by a.TRADEDATE, b.BALUNIT;
  elsif p_funcCode = 'SUPPLY_Warn_REPORTDEPTBAL' then
    -- �����ֵ�澯
    open p_cursor for
      select a.TRADEDATE   ��������,
             b.DBALUNIT    ���㵥Ԫ����,
             a.ID          ������ˮ��,
             a.CARDNO      ����,
             a.CARDTRADENO ���������,
             a.PREMONEY    ����ǰ���,
             a.TRADEMONEY  ���׽��,
             a.SAMNO       SAM���,
             a.supplylocno ��ֵ����
        from TF_OUTSUPPLY_ALARM a, TF_DEPT_BALUNIT b
       where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
         and a.BALUNITNO = b.DBALUNITNO
         and a.TRADETYPECODE = '1S'
         and (p_var7 is null or p_var7 = '' or a.BALUNITNO = p_var7)
       order by a.TRADEDATE, b.DBALUNIT;
  
  elsif p_funcCode = 'WJTourReport' THEN
    --�⽭�����꿨���ܲ�ѯ
    if p_var3 = '1' then
      open p_cursor for
        SELECT POSNO POS, SUM(OPENNUM) ������, SUM(TRADENUM) ˢ����
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
        SELECT DEPARTNAME ����, STAFFNAME ����Ա��, SUM(OPENNUM) ������
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
                   and b.operatedepartid is not null --���˷����㿪����
                )
         group by DEPARTNAME, STAFFNAME
         order by DEPARTNAME;
    end if;
  
  elsif p_funcCode = 'WJTourReportOpenDetail' THEN
    --�⽭�����꿨������ϸ��ѯ
    if p_var3 = '1' then
      open p_cursor for
        select a.POSNO      POS���,
               a.CARDNO     ����,
               a.SAMNO      PSAM���,
               a.SELLTIME   �ۿ�ʱ��,
               a.ENDDATE    ��������,
               a.DEALTIME   ����ʱ��,
               a.INLISTTIME ���嵥ʱ��
          from TQ_TOUR_NEWCARD_RIGHT a
         where (p_var1 is null or p_var1 = '' or a.SELLTIME >= p_var1)
           and (p_var2 is null or p_var2 = '' or a.SELLTIME <= p_var2)
         order by a.SELLTIME;
    elsif p_var3 = '2' then
      open p_cursor for
        select b.CARDNO ����,
               to_char(b.operatetime, 'yyyy-mm-dd') ��ͨʱ��,
               to_char(add_months(b.operatetime, 12), 'yyyy-mm-dd') ��������,
               b.operatetime ����ʱ��,
               d.departname ����,
               c.staffname ����Ա��
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
    --�⽭�����꿨������ϸ��ѯ
    open p_cursor for
      select a.POSNO POS���,
             a.CARDNO ����,
             a.SAMNO PSAM���,
             a.TRADEDATE || a.TRADETIME ����ʱ��,
             a.SPARETIMES ʣ�����,
             a.ENDDATE ��������,
             a.DEALTIME ����ʱ��,
             a.INLISTTIME ���嵥ʱ��
        from TQ_TOUR_WJ_RIGHT a
       where (p_var1 is null or p_var1 = '' or a.TRADEDATE >= p_var1)
         and (p_var2 is null or p_var2 = '' or a.TRADEDATE <= p_var2)
       order by a.TRADEDATE, a.TRADETIME;
  elsif p_funcCode = 'ServiceDailyReport' THEN
    --�ͷ�����ҵ��ͳ���ձ�
    if p_var4 is null then
      if p_var3 is null then
        --all
        open p_cursor for
          select ������,
                 ����,
                 sum(�˿�ҵ�����) �˿�ҵ�����,
                 sum(����ҵ�����) ����ҵ�����,
                 sum(�м�����Ʊ��������) �м�����Ʊ��������,
                 sum(����B���ۿ�����) ����B���ۿ�����,
                 sum(��Ʊ���ۿ�����) ��Ʊ���ۿ�����,
                 sum(�����ۿ�����) �����ۿ�����,
                 sum(��ֵ���ۿ�����) ��ֵ���ۿ�����,
                 sum(�ܱ���) �ܱ���,
                 sum(��) Ӫҵ���ܶ���,
                 sum(��) Ӫҵ���ܶ��
            from (select e.departno ������,
                         e.departname ����,
                         count(*) �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '05' --�˿�
                     and b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         count(*) ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '03' --����
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         count(*) �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '7C' --�м�����Ʊ����
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         COUNT(*) ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '01' --�����ۿ�
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         count(*) ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE in ('31', '32', '23', '7A') --��Ʊ���ۿ�
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         count(*) �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '50' --�����ۿ�
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         count(*) ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_XFC_SELL       a,
                         TD_M_INSIDEDEPART e,
                         TD_M_INSIDESTAFF  f
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.tradetypecode = '80'
                     AND A.CANCELTAG = '0' --��ֵ���ۿ�
                     AND a.STAFFNO = f.STAFFNO
                     AND f.DEPARTNO = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         count(*) ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_XFC_BATCHSELL  a,
                         TD_M_INSIDEDEPART e,
                         TD_M_INSIDESTAFF  f
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = f.STAFFNO --��ֵ��ֱ���ۿ�
                     AND f.DEPARTNO = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         count(*) �ܱ���,
                         sum(case
                               when (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                    b.FUNCFEE + b.OTHERFEE) / 100.0 > 0 then
                                (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                b.FUNCFEE + b.OTHERFEE) / 100.0
                               else
                                0
                             end) ��,
                         sum(case
                               when (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                    b.FUNCFEE + b.OTHERFEE) / 100.0 < 0 then
                                (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                b.FUNCFEE + b.OTHERFEE) / 100.0
                               else
                                0
                             end) ��
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.TRADEID = b.TRADEID(+) --ӪҵԱ�ձ��ܱ���,�ܶ�
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                   GROUP BY e.departname, e.departno
                  union
                  SELECT b.departno ������,
                         b.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         count(*) �ܱ���,
                         sum(case
                               when (MONEY) / 100.0 > 0 then
                                (MONEY) / 100.0
                               else
                                0
                             end) ��,
                         sum(case
                               when (MONEY) / 100.0 < 0 then
                                (MONEY) / 100.0
                               else
                                0
                             end) ��
                    FROM TF_XFC_SELL       a,
                         TD_M_INSIDEDEPART b,
                         TD_M_INSIDESTAFF  e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = e.STAFFNO --��ֵ���ܱ���,�ܶ�
                     AND b.DEPARTNO = e.DEPARTNO
                   GROUP BY b.departname, b.departno
                  union
                  SELECT b.departno ������,
                         b.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         count(*) �ܱ���,
                         sum(case
                               when (TOTALMONEY) / 100.0 > 0 then
                                (TOTALMONEY) / 100.0
                               else
                                0
                             end) ��,
                         sum(case
                               when (TOTALMONEY) / 100.0 < 0 then
                                (TOTALMONEY) / 100.0
                               else
                                0
                             end) ��
                    FROM TF_XFC_BATCHSELL  a,
                         TD_M_INSIDEDEPART b,
                         TD_M_INSIDESTAFF  e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = e.STAFFNO --��ֵ��ֱ���ܱ���,�ܶ�
                     AND b.DEPARTNO = e.DEPARTNO
                   GROUP BY b.departname, b.departno)
           GROUP BY ����, ������
           ORDER BY ������;
      elsif p_var3 = '1' then
        --����
        open p_cursor for
          select ������,
                 ����,
                 sum(�˿�ҵ�����) �˿�ҵ�����,
                 sum(����ҵ�����) ����ҵ�����,
                 sum(�м�����Ʊ��������) �м�����Ʊ��������,
                 sum(����B���ۿ�����) ����B���ۿ�����,
                 sum(��Ʊ���ۿ�����) ��Ʊ���ۿ�����,
                 sum(�����ۿ�����) �����ۿ�����,
                 sum(��ֵ���ۿ�����) ��ֵ���ۿ�����,
                 sum(�ܱ���) �ܱ���,
                 sum(��) Ӫҵ���ܶ���,
                 sum(��) Ӫҵ���ܶ��
            from (select e.departno ������,
                         e.departname ����,
                         count(*) �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE          a,
                         TF_B_TRADEFEE       b,
                         TD_M_INSIDEDEPART   e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '05' --�˿�
                     and b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND R.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         count(*) ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE          a,
                         TF_B_TRADEFEE       b,
                         TD_M_INSIDEDEPART   e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '03' --����
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND R.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         count(*) �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE          a,
                         TF_B_TRADEFEE       b,
                         TD_M_INSIDEDEPART   e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '7C' --�м�����Ʊ����
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND R.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         COUNT(*) ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE          a,
                         TF_B_TRADEFEE       b,
                         TD_M_INSIDEDEPART   e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '01' --�����ۿ�
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND R.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         count(*) ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE          a,
                         TF_B_TRADEFEE       b,
                         TD_M_INSIDEDEPART   e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE in ('31', '32', '23', '7A') --��Ʊ���ۿ�
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND R.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         count(*) �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE          a,
                         TF_B_TRADEFEE       b,
                         TD_M_INSIDEDEPART   e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '50' --�����ۿ�
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND R.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         count(*) ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_XFC_SELL         a,
                         TD_M_INSIDEDEPART   e,
                         TD_M_INSIDESTAFF    f,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.tradetypecode = '80'
                     AND A.CANCELTAG = '0' --��ֵ���ۿ�
                     AND a.STAFFNO = f.STAFFNO
                     AND f.DEPARTNO = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND r.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         count(*) ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_XFC_BATCHSELL    a,
                         TD_M_INSIDEDEPART   e,
                         TD_M_INSIDESTAFF    f,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = f.STAFFNO --��ֵ��ֱ���ۿ�
                     AND f.DEPARTNO = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND r.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         count(*) �ܱ���,
                         sum(case
                               when (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                    b.FUNCFEE + b.OTHERFEE) / 100.0 > 0 then
                                (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                b.FUNCFEE + b.OTHERFEE) / 100.0
                               else
                                0
                             end) ��,
                         sum(case
                               when (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                    b.FUNCFEE + b.OTHERFEE) / 100.0 < 0 then
                                (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                b.FUNCFEE + b.OTHERFEE) / 100.0
                               else
                                0
                             end) ��
                    FROM TF_B_TRADE          a,
                         TF_B_TRADEFEE       b,
                         TD_M_INSIDEDEPART   e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.TRADEID = b.TRADEID(+) --ӪҵԱ�ձ��ܱ���,�ܶ�
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND e.DEPARTNO = r.DEPARTNO
                     AND r.USETAG = '1'
                   GROUP BY e.departname, e.departno
                  union
                  SELECT b.departno ������,
                         b.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         count(*) �ܱ���,
                         sum(case
                               when (MONEY) / 100.0 > 0 then
                                (MONEY) / 100.0
                               else
                                0
                             end) ��,
                         sum(case
                               when (MONEY) / 100.0 < 0 then
                                (MONEY) / 100.0
                               else
                                0
                             end) ��
                    FROM TF_XFC_SELL         a,
                         TD_M_INSIDEDEPART   b,
                         TD_M_INSIDESTAFF    e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = e.STAFFNO --��ֵ���ܱ���,�ܶ�
                     AND b.DEPARTNO = e.DEPARTNO
                     AND b.DEPARTNO = r.DEPARTNO
                     AND r.USETAG = '1'
                   GROUP BY b.departname, b.departno
                  union
                  SELECT b.departno ������,
                         b.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         count(*) �ܱ���,
                         sum(case
                               when (TOTALMONEY) / 100.0 > 0 then
                                (TOTALMONEY) / 100.0
                               else
                                0
                             end) ��,
                         sum(case
                               when (TOTALMONEY) / 100.0 < 0 then
                                (TOTALMONEY) / 100.0
                               else
                                0
                             end) ��
                    FROM TF_XFC_BATCHSELL    a,
                         TD_M_INSIDEDEPART   b,
                         TD_M_INSIDESTAFF    e,
                         TD_DEPTBAL_RELATION r
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = e.STAFFNO --��ֵ��ֱ���ܱ���,�ܶ�
                     AND b.DEPARTNO = e.DEPARTNO
                     AND b.DEPARTNO = r.DEPARTNO
                     AND r.USETAG = '1'
                   GROUP BY b.departname, b.departno)
           GROUP BY ����, ������
           ORDER BY ������;
      elsif p_var3 = '0' then
        --ֱӪ
        open p_cursor for
          select ������,
                 ����,
                 sum(�˿�ҵ�����) �˿�ҵ�����,
                 sum(����ҵ�����) ����ҵ�����,
                 sum(�м�����Ʊ��������) �м�����Ʊ��������,
                 sum(����B���ۿ�����) ����B���ۿ�����,
                 sum(��Ʊ���ۿ�����) ��Ʊ���ۿ�����,
                 sum(�����ۿ�����) �����ۿ�����,
                 sum(��ֵ���ۿ�����) ��ֵ���ۿ�����,
                 sum(�ܱ���) �ܱ���,
                 sum(��) Ӫҵ���ܶ���,
                 sum(��) Ӫҵ���ܶ��
            from (select e.departno ������,
                         e.departname ����,
                         count(*) �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '05' --�˿�
                     and b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND a.OPERATEDEPARTID NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         count(*) ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '03' --����
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND a.OPERATEDEPARTID NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         count(*) �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '7C' --�м�����Ʊ����
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND a.OPERATEDEPARTID NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         COUNT(*) ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '01' --�����ۿ�
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND a.OPERATEDEPARTID NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         count(*) ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE in ('31', '32', '23', '7A') --��Ʊ���ۿ�
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND a.OPERATEDEPARTID NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         count(*) �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.TRADETYPECODE = '50' --�����ۿ�
                     AND b.CANCELTAG = '0'
                     AND a.TRADEID = b.TRADEID(+)
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND a.OPERATEDEPARTID NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         count(*) ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_XFC_SELL       a,
                         TD_M_INSIDEDEPART e,
                         TD_M_INSIDESTAFF  f
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     and a.tradetypecode = '80'
                     AND A.CANCELTAG = '0' --��ֵ���ۿ�
                     AND a.STAFFNO = f.STAFFNO
                     AND f.DEPARTNO = e.DEPARTNO
                     AND e.DEPARTNO NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         count(*) ��ֵ���ۿ�����,
                         0 �ܱ���,
                         0 ��,
                         0 ��
                    FROM TF_XFC_BATCHSELL  a,
                         TD_M_INSIDEDEPART e,
                         TD_M_INSIDESTAFF  f
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = f.STAFFNO --��ֵ��ֱ���ۿ�
                     AND f.DEPARTNO = e.DEPARTNO
                     AND e.DEPARTNO NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT e.departno ������,
                         e.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         count(*) �ܱ���,
                         sum(case
                               when (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                    b.FUNCFEE + b.OTHERFEE) / 100.0 > 0 then
                                (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                b.FUNCFEE + b.OTHERFEE) / 100.0
                               else
                                0
                             end) ��,
                         sum(case
                               when (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                    b.FUNCFEE + b.OTHERFEE) / 100.0 < 0 then
                                (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY + b.TRADEPROCFEE +
                                b.FUNCFEE + b.OTHERFEE) / 100.0
                               else
                                0
                             end) ��
                    FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.TRADEID = b.TRADEID(+) --ӪҵԱ�ձ��ܱ���,�ܶ�
                     AND a.OPERATEDEPARTID = e.DEPARTNO
                     AND a.OPERATEDEPARTID NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY e.departname, e.departno
                  union
                  SELECT b.departno ������,
                         b.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         count(*) �ܱ���,
                         sum(case
                               when (MONEY) / 100.0 > 0 then
                                (MONEY) / 100.0
                               else
                                0
                             end) ��,
                         sum(case
                               when (MONEY) / 100.0 < 0 then
                                (MONEY) / 100.0
                               else
                                0
                             end) ��
                    FROM TF_XFC_SELL       a,
                         TD_M_INSIDEDEPART b,
                         TD_M_INSIDESTAFF  e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = e.STAFFNO --��ֵ���ܱ���,�ܶ�
                     AND b.DEPARTNO = e.DEPARTNO
                     AND b.DEPARTNO NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY b.departname, b.departno
                  union
                  SELECT b.departno ������,
                         b.departname ����,
                         0 �˿�ҵ�����,
                         0 ����ҵ�����,
                         0 �м�����Ʊ��������,
                         0 ����B���ۿ�����,
                         0 ��Ʊ���ۿ�����,
                         0 �����ۿ�����,
                         0 ��ֵ���ۿ�����,
                         count(*) �ܱ���,
                         sum(case
                               when (TOTALMONEY) / 100.0 > 0 then
                                (TOTALMONEY) / 100.0
                               else
                                0
                             end) ��,
                         sum(case
                               when (TOTALMONEY) / 100.0 < 0 then
                                (TOTALMONEY) / 100.0
                               else
                                0
                             end) ��
                    FROM TF_XFC_BATCHSELL  a,
                         TD_M_INSIDEDEPART b,
                         TD_M_INSIDESTAFF  e
                   WHERE a.OPERATETIME >=
                         to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                     and a.OPERATETIME <=
                         to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                     AND a.STAFFNO = e.STAFFNO --��ֵ��ֱ���ܱ���,�ܶ�
                     AND b.DEPARTNO = e.DEPARTNO
                     AND b.DEPARTNO NOT IN
                         (SELECT DEPARTNO
                            FROM TD_DEPTBAL_RELATION
                           WHERE USETAG = '1')
                   GROUP BY b.departname, b.departno)
           GROUP BY ����, ������
           ORDER BY ������;
      end if;
    else
      open p_cursor for
        select ������,
               ����,
               sum(�˿�ҵ�����) �˿�ҵ�����,
               sum(����ҵ�����) ����ҵ�����,
               sum(�м�����Ʊ��������) �м�����Ʊ��������,
               sum(����B���ۿ�����) ����B���ۿ�����,
               sum(��Ʊ���ۿ�����) ��Ʊ���ۿ�����,
               sum(�����ۿ�����) �����ۿ�����,
               sum(��ֵ���ۿ�����) ��ֵ���ۿ�����,
               sum(�ܱ���) �ܱ���,
               sum(��) Ӫҵ���ܶ���,
               sum(��) Ӫҵ���ܶ��
          from (select e.departno ������,
                       e.departname ����,
                       count(*) �˿�ҵ�����,
                       0 ����ҵ�����,
                       0 �м�����Ʊ��������,
                       0 ����B���ۿ�����,
                       0 ��Ʊ���ۿ�����,
                       0 �����ۿ�����,
                       0 ��ֵ���ۿ�����,
                       0 �ܱ���,
                       0 ��,
                       0 ��
                  FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   and a.TRADETYPECODE = '05' --�˿�
                   and b.CANCELTAG = '0'
                   AND a.TRADEID = b.TRADEID(+)
                   AND a.OPERATEDEPARTID = e.DEPARTNO
                   AND a.OPERATEDEPARTID = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno ������,
                       e.departname ����,
                       0 �˿�ҵ�����,
                       count(*) ����ҵ�����,
                       0 �м�����Ʊ��������,
                       0 ����B���ۿ�����,
                       0 ��Ʊ���ۿ�����,
                       0 �����ۿ�����,
                       0 ��ֵ���ۿ�����,
                       0 �ܱ���,
                       0 ��,
                       0 ��
                  FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   and a.TRADETYPECODE = '03' --����
                   AND b.CANCELTAG = '0'
                   AND a.TRADEID = b.TRADEID(+)
                   AND a.OPERATEDEPARTID = e.DEPARTNO
                   AND a.OPERATEDEPARTID = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno ������,
                       e.departname ����,
                       0 �˿�ҵ�����,
                       0 ����ҵ�����,
                       count(*) �м�����Ʊ��������,
                       0 ����B���ۿ�����,
                       0 ��Ʊ���ۿ�����,
                       0 �����ۿ�����,
                       0 ��ֵ���ۿ�����,
                       0 �ܱ���,
                       0 ��,
                       0 ��
                  FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   and a.TRADETYPECODE = '7C' --�м�����Ʊ����
                   AND b.CANCELTAG = '0'
                   AND a.TRADEID = b.TRADEID(+)
                   AND a.OPERATEDEPARTID = e.DEPARTNO
                   AND a.OPERATEDEPARTID = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno ������,
                       e.departname ����,
                       0 �˿�ҵ�����,
                       0 ����ҵ�����,
                       0 �м�����Ʊ��������,
                       COUNT(*) ����B���ۿ�����,
                       0 ��Ʊ���ۿ�����,
                       0 �����ۿ�����,
                       0 ��ֵ���ۿ�����,
                       0 �ܱ���,
                       0 ��,
                       0 ��
                  FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   and a.TRADETYPECODE = '01' --�����ۿ�
                   AND b.CANCELTAG = '0'
                   AND a.TRADEID = b.TRADEID(+)
                   AND a.OPERATEDEPARTID = e.DEPARTNO
                   AND a.OPERATEDEPARTID = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno ������,
                       e.departname ����,
                       0 �˿�ҵ�����,
                       0 ����ҵ�����,
                       0 �м�����Ʊ��������,
                       0 ����B���ۿ�����,
                       count(*) ��Ʊ���ۿ�����,
                       0 �����ۿ�����,
                       0 ��ֵ���ۿ�����,
                       0 �ܱ���,
                       0 ��,
                       0 ��
                  FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   and a.TRADETYPECODE in ('31', '32', '23', '7A') --��Ʊ���ۿ�
                   AND b.CANCELTAG = '0'
                   AND a.TRADEID = b.TRADEID(+)
                   AND a.OPERATEDEPARTID = e.DEPARTNO
                   AND a.OPERATEDEPARTID = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno ������,
                       e.departname ����,
                       0 �˿�ҵ�����,
                       0 ����ҵ�����,
                       0 �м�����Ʊ��������,
                       0 ����B���ۿ�����,
                       0 ��Ʊ���ۿ�����,
                       count(*) �����ۿ�����,
                       0 ��ֵ���ۿ�����,
                       0 �ܱ���,
                       0 ��,
                       0 ��
                  FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   and a.TRADETYPECODE = '50' --�����ۿ�
                   AND b.CANCELTAG = '0'
                   AND a.TRADEID = b.TRADEID(+)
                   AND a.OPERATEDEPARTID = e.DEPARTNO
                   AND a.OPERATEDEPARTID = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno ������,
                       e.departname ����,
                       0 �˿�ҵ�����,
                       0 ����ҵ�����,
                       0 �м�����Ʊ��������,
                       0 ����B���ۿ�����,
                       0 ��Ʊ���ۿ�����,
                       0 �����ۿ�����,
                       count(*) ��ֵ���ۿ�����,
                       0 �ܱ���,
                       0 ��,
                       0 ��
                  FROM TF_XFC_SELL       a,
                       TD_M_INSIDEDEPART e,
                       TD_M_INSIDESTAFF  f
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   and a.tradetypecode = '80'
                   AND A.CANCELTAG = '0' --��ֵ���ۿ�
                   AND a.STAFFNO = f.STAFFNO
                   AND f.DEPARTNO = e.DEPARTNO
                   AND e.DEPARTNO = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno ������,
                       e.departname ����,
                       0 �˿�ҵ�����,
                       0 ����ҵ�����,
                       0 �м�����Ʊ��������,
                       0 ����B���ۿ�����,
                       0 ��Ʊ���ۿ�����,
                       0 �����ۿ�����,
                       count(*) ��ֵ���ۿ�����,
                       0 �ܱ���,
                       0 ��,
                       0 ��
                  FROM TF_XFC_BATCHSELL  a,
                       TD_M_INSIDEDEPART e,
                       TD_M_INSIDESTAFF  f
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   AND a.STAFFNO = f.STAFFNO --��ֵ��ֱ���ۿ�
                   AND f.DEPARTNO = e.DEPARTNO
                   AND f.DEPARTNO = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT e.departno ������,
                       e.departname ����,
                       0 �˿�ҵ�����,
                       0 ����ҵ�����,
                       0 �м�����Ʊ��������,
                       0 ����B���ۿ�����,
                       0 ��Ʊ���ۿ�����,
                       0 �����ۿ�����,
                       0 ��ֵ���ۿ�����,
                       count(*) �ܱ���,
                       sum(case
                             when (b.CARDSERVFEE + b.CARDDEPOSITFEE +
                                  b.SUPPLYMONEY + b.TRADEPROCFEE + b.FUNCFEE +
                                  b.OTHERFEE) / 100.0 > 0 then
                              (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY +
                              b.TRADEPROCFEE + b.FUNCFEE + b.OTHERFEE) / 100.0
                             else
                              0
                           end) ��,
                       sum(case
                             when (b.CARDSERVFEE + b.CARDDEPOSITFEE +
                                  b.SUPPLYMONEY + b.TRADEPROCFEE + b.FUNCFEE +
                                  b.OTHERFEE) / 100.0 < 0 then
                              (b.CARDSERVFEE + b.CARDDEPOSITFEE + b.SUPPLYMONEY +
                              b.TRADEPROCFEE + b.FUNCFEE + b.OTHERFEE) / 100.0
                             else
                              0
                           end) ��
                  FROM TF_B_TRADE a, TF_B_TRADEFEE b, TD_M_INSIDEDEPART e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   AND a.TRADEID = b.TRADEID(+) --ӪҵԱ�ձ��ܱ���,�ܶ�
                   AND a.OPERATEDEPARTID = e.DEPARTNO
                   AND a.OPERATEDEPARTID = p_var4
                 GROUP BY e.departname, e.departno
                union
                SELECT b.departno ������,
                       b.departname ����,
                       0 �˿�ҵ�����,
                       0 ����ҵ�����,
                       0 �м�����Ʊ��������,
                       0 ����B���ۿ�����,
                       0 ��Ʊ���ۿ�����,
                       0 �����ۿ�����,
                       0 ��ֵ���ۿ�����,
                       count(*) �ܱ���,
                       sum(case
                             when (MONEY) / 100.0 > 0 then
                              (MONEY) / 100.0
                             else
                              0
                           end) ��,
                       sum(case
                             when (MONEY) / 100.0 < 0 then
                              (MONEY) / 100.0
                             else
                              0
                           end) ��
                  FROM TF_XFC_SELL       a,
                       TD_M_INSIDEDEPART b,
                       TD_M_INSIDESTAFF  e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   AND a.STAFFNO = e.STAFFNO --��ֵ���ܱ���,�ܶ�
                   AND b.DEPARTNO = e.DEPARTNO
                   AND b.DEPARTNO = p_var4
                 GROUP BY b.departname, b.departno
                union
                SELECT b.departno ������,
                       b.departname ����,
                       0 �˿�ҵ�����,
                       0 ����ҵ�����,
                       0 �м�����Ʊ��������,
                       0 ����B���ۿ�����,
                       0 ��Ʊ���ۿ�����,
                       0 �����ۿ�����,
                       0 ��ֵ���ۿ�����,
                       count(*) �ܱ���,
                       sum(case
                             when (TOTALMONEY) / 100.0 > 0 then
                              (TOTALMONEY) / 100.0
                             else
                              0
                           end) ��,
                       sum(case
                             when (TOTALMONEY) / 100.0 < 0 then
                              (TOTALMONEY) / 100.0
                             else
                              0
                           end) ��
                  FROM TF_XFC_BATCHSELL  a,
                       TD_M_INSIDEDEPART b,
                       TD_M_INSIDESTAFF  e
                 WHERE a.OPERATETIME >=
                       to_date(p_var1 || '000000', 'yyyymmddhh24miss')
                   and a.OPERATETIME <=
                       to_date(p_var2 || '235959', 'yyyymmddhh24miss')
                   AND a.STAFFNO = e.STAFFNO --��ֵ��ֱ���ܱ���,�ܶ�
                   AND b.DEPARTNO = e.DEPARTNO
                   AND b.DEPARTNO = p_var4
                 GROUP BY b.departname, b.departno)
         GROUP BY ����, ������
         ORDER BY ������;
    end if;
  elsif p_funcCode = 'ParkCardChangDetail' THEN
    --԰���꿨��������ϸ
    open p_cursor for
      SELECT e.departname ����,
             nvl(d.staffname, a.OPERATESTAFFNO) ӪҵԱ,
             c.CUSTNAME ����,
             c.PAPERNO ���֤��,
             a.OLDCARDNO �Ͽ���,
             a.CARDNO �¿���,
             b.ENDDATE ��Ч��,
             b.SPARETIMES ʣ�����,
             a.OPERATETIME ����ʱ��
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
         AND (a.RSRV1 IS NULL OR a.RSRV1 = '1') --��ʾ��ǰ��԰�ֻ������ݺ�δ���ڵ�԰�ֲ���������
         AND (p_var3 is null or p_var3 = '' or p_var3 = a.OPERATESTAFFNO)
         AND (p_var10 is null or p_var10 = '' or
             p_var10 = a.OPERATEDEPARTID);
  
  elsif p_funcCode = 'JIANGYIN_REPORT' then
    --�����˵�
    open p_cursor for
      select to_char(A.Begintime, 'yyyymmdd') ���ڿ�ʼ����,
             to_char(A.Endtime, 'yyyymmdd') ���ڽ�������,
             A.TRANSFEE / 100.0 ����Ӧ��,
             B.TRANSFEE / 100.0 ����Ӧ��
        from tf_trade_outcomefin A, tf_trade_outcomefin B
       where A.begintime = B.begintime
         and A.endTime = B.endtime
         and A.BALUNITNO = '01H00005' -- �������񿨹�˾
         and B.BALUNITNO = '01H00006' -- �żҸ۹�����˾
         and (p_var1 is null or p_var1 = '' or
             to_char(a.ENDTIME, 'yyyymmdd') >=
             to_char((to_date(p_var1, 'yyyymmdd') + 1), 'yyyymmdd'))
         and (p_var2 is null or p_var2 = '' or
             to_char(a.ENDTIME, 'yyyymmdd') <=
             to_char((to_date(p_var2, 'yyyymmdd') + 1), 'yyyymmdd'))
       order by A.endTime desc;
  
  elsif p_funcCode = 'JIANGYIN_FILE_REPORT' then
    --�����˵�  �ļ�������Ϣ
    open p_cursor for
      select tf.filename �ļ���,
             decode(tf.dealstatecode,
                    '0',
                    'δ����',
                    '1',
                    '�Ѵ���',
                    '2',
                    '����ʧ��',
                    '3',
                    '���ڴ���',
                    '4',
                    '�ļ�δ���',
                    tf.dealstatecode) ����״̬,
             Z.zcount �������ױ���,
             Z.zsum / 100.0 �������׽��,
             J.jcount �ܸ����ױ���,
             J.jsum / 100.0 �ܸ����׽��,
             T.tcount �������ױ���,
             T.tsum / 100.0 �������׽��,
             to_char(tf.inlisttime, 'yyyymmdd') ���ʱ��
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
    --���ο�ת����
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
    --���ο��ͻ��˿�
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
         AND a.ISUPDATED = '1' --�Ѹ����˿����
         AND a.PAPERTYPECODE = d.PAPERTYPECODE(+)
         AND (p_var1 = '' or p_var1 is null or
             p_var1 <= to_char(A.OPERATETIME, 'yyyymmdd'))
         AND (p_var2 = '' or p_var2 is null or
             p_var2 >= to_char(A.OPERATETIME, 'yyyymmdd'))
         AND (p_var3 = '' or p_var3 is null or p_var3 = a.OPERATEDEPARTID)
         AND (p_var4 = '' or p_var4 is null or p_var4 = a.OPERATESTAFFNO)
       ORDER BY 15, 1;
  elsif p_funcCode = 'queryEOCSpeAdjustAcc' THEN
    --��ѯ�����ʽ�������˼�¼
    open p_cursor for
      SELECT a.ID, a.STATTIME, a.CATEGORY, a.MONEY / 100.0 MONEY, a.REMARK
        FROM TF_FUNDSANALYSIS a
       WHERE a.NAME = '�������'
         AND a.STATTIME >= p_var1
         and a.STATTIME <= p_var2
         AND (p_var3 is null or p_var3 = '' or p_var3 = a.CATEGORY);
  elsif p_funcCode = 'queryBFJTradeRecord' THEN
    --��ѯϵͳҵ���˵���
    open p_cursor for
      SELECT a.TRADEID ID,
             a.TRADEDATE STATTIME,
             DECODE(a.AMOUNTTYPE, '0', '����', '1', '֧��') CATEGORY,
             a.TRADEMONEY / 100.0 MONEY,
             a.REMARK
        FROM TF_F_BFJ_TRADERECORD a
       WHERE a.NAME LIKE '%�������ֹ�¼��%'
         AND a.TRADEDATE >= to_date(p_var1, 'YYYYMMDD')
         and a.TRADEDATE <= to_date(p_var2, 'YYYYMMDD')
         AND (p_var3 is null or p_var3 = '' or
             DECODE(p_var3, '�����ʽ�����', '0', '�����ʽ�֧��', '1') = a.AMOUNTTYPE);
  
  elsif p_funcCode = 'AREAQUERY' then
    open p_cursor for
      SELECT A.REGIONNAME, A.REGIONCODE
        FROM TD_M_REGIONCODE A, td_m_insidedepart b
       WHERE A.ISUSETAG = '1'
         and b.departno = p_var1
         and (b.regioncode is null or b.regioncode = a.regioncode)
       ORDER BY A.REGIONCODE;
  elsif p_funcCode = 'DEPTEBALTRADE_SPE' then
    --����ת���ձ�
    open p_cursor for
      SELECT ������,
             ��������,
             sum(Ѻ���˻�) Ѻ���˻�,
             sum(���ο�Ѻ���˻�) ���ο�Ѻ���˻�,
             sum(�������) �������
        FROM (SELECT D.DEPARTNO ������,
                     D.DEPARTNAME ��������,
                     sum(B.CARDSERVFEE + B.CARDDEPOSITFEE + B.SUPPLYMONEY +
                         B.TRADEPROCFEE + B.FUNCFEE + B.OTHERFEE) / 100.0 Ѻ���˻�,
                     0 ���ο�Ѻ���˻�,
                     0 �������
                FROM TF_B_TRADE A, TF_B_TRADEFEE B, TD_M_INSIDEDEPART D
               WHERE ((A.TRADETYPECODE = '03' AND
                     A.CARDNO NOT LIKE '215018%' AND
                     (B.CARDSERVFEE + B.CARDDEPOSITFEE + B.SUPPLYMONEY +
                     B.TRADEPROCFEE + B.FUNCFEE + B.OTHERFEE) < 0) --�����˻�Ѻ��
                     OR A.TRADETYPECODE = '76' --��Ʊ�������˻�
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
              SELECT D.DEPARTNO ������,
                     D.DEPARTNAME ��������,
                     sum(B.CARDDEPOSITFEE) / 100.0 Ѻ���˻�,
                     0 ���ο�Ѻ���˻�,
                     0 �������
                FROM TF_B_TRADE A, TF_B_TRADEFEE B, TD_M_INSIDEDEPART D
               WHERE ((a.TRADETYPECODE = '05' AND
                     a.REASONCODE IN ('11', '12', '13', '15')) OR
                     a.TRADETYPECODE = 'A5' --�˿���Ѻ�� |||| modify by jiangbb ����15���ɶ���Ȼ�� from may 12 �ʼ�
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
              SELECT D.DEPARTNO ������,
                     D.DEPARTNAME ��������,
                     0 Ѻ���˻�,
                     SUM(DECODE(A.TRADETYPECODE, '7K', B.CARDDEPOSITFEE, 0)) /
                     100.0 ���ο�Ѻ���˻�,
                     sum(B.SUPPLYMONEY) / 100.0 �������
                FROM TF_B_TRADE A, TF_B_TRADEFEE B, TD_M_INSIDEDEPART D
               WHERE (A.TRADETYPECODE = '06' --����(���ɶ����˿���)
                     OR ((a.TRADETYPECODE = '05' AND
                     a.REASONCODE in ('11', '12', '13')) OR
                     a.TRADETYPECODE = 'A5') --(�ɶ����˿���)
                     OR A.TRADETYPECODE = '7K') --���ο����գ��ɶ�����
                 AND A.TRADEID = B.TRADEID(+)
                 AND A.OPERATEDEPARTID = D.DEPARTNO
                 AND A.OPERATETIME >=
                     TO_DATE(P_VAR1 || '000000', 'YYYYMMDDHH24MISS')
                 AND A.OPERATETIME <=
                     TO_DATE(P_VAR2 || '235959', 'YYYYMMDDHH24MISS')
                 AND (P_VAR3 IS NULL OR P_VAR3 = '' OR
                     P_VAR3 = A.OPERATEDEPARTID)
               GROUP BY D.DEPARTNO, D.DEPARTNAME)
       GROUP BY ������, ��������
       ORDER BY ������;
  elsif p_funcCode = 'QUERYTRADETYPE' then
    --��ѯ֧���Ź���ҵ������
    open p_cursor for
      SELECT b.TRADETYPE, b.TRADETYPECODE
        FROM TD_M_GROUPBUY_TRADETYPE a, TD_M_TRADETYPE b
       WHERE a.TRADETYPECODE = b.TRADETYPECODE
	   ORDER BY 2;
  elsif p_funcCode = 'QUERYTRADETYPESHOP' then
    --��ѯ֧���Ź����̼�
    open p_cursor for
      SELECT SHOPNAME, SHOPID FROM TD_M_GROUPBUY_SHOP;
  elsif p_funcCode = 'QUERYGROUPBUYEXIST' then
    --��ѯ�Ѿ������̼ҵ��Ź���
    open p_cursor for
      SELECT a.CODE
        FROM TF_F_GROUPBUY_RECORD a
       WHERE p_var1 = a.CODE
         AND p_var2 = a.SHOPID
         AND a.CANCELCODE = '0';
  
  elsif p_funcCode = 'QUERYGROUPBUYMARK' then
    --��ѯҵ��̨�˱���
    open p_cursor for
      select a.TRADEID,
             a.CARDNO ����,
             c.TRADETYPE ��������,
             b.CARDSERVFEE / 100.0 �������,
             b.CARDDEPOSITFEE / 100.0 ��Ѻ��,
             b.SUPPLYMONEY / 100.0 ��ֵ,
             b.TRADEPROCFEE / 100.0 ������,
             b.FUNCFEE / 100.0 ���ܷ�,
             b.OTHERFEE / 100.0 ������,
             a.OPERATETIME ����ʱ��
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
    --��ѯ�Ź�����
    open p_cursor for
      select a."ID",
             a.CODE       �Ź�����,
             b.SHOPNAME   �Ź��̼�,
             d.STAFFNAME  ������,
             e.DEPARTNAME ��������,
             a.UPDATETIME ����ʱ��,
             a.REMARK     ��ע
      
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
    --��ѯ�Ź����Ź���ҵ����Ϣ
    open p_cursor for
      select a.TRADEID,
             e.departname ����,
             nvl(d.staffname, a.OPERATESTAFFNO) ӪҵԱ,
             a.CARDNO ����,
             c.TRADETYPE ��������,
             b.CARDSERVFEE / 100.0 �������,
             b.CARDDEPOSITFEE / 100.0 ��Ѻ��,
             b.SUPPLYMONEY / 100.0 ��ֵ,
             b.TRADEPROCFEE / 100.0 ������,
             b.FUNCFEE / 100.0 ���ܷ�,
             b.OTHERFEE / 100.0 ������,
             a.OPERATETIME ����ʱ��
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
    --��ѯ�Ź�ҵ�񱨱���ϸ
    open p_cursor for
      select h.UPDATETIME ����ʱ��,
             h.CODE �Ź�����,
             I.SHOPNAME �Ź��̼�,
             e.departname ����,
             nvl(d.staffname, a.OPERATESTAFFNO) ӪҵԱ,
             a.CARDNO ����,
             c.TRADETYPE ��������,
             b.CARDSERVFEE / 100.0 + b.CARDDEPOSITFEE / 100.0 ����Ѻ�Ѻ��,
             b.SUPPLYMONEY / 100.0 ��ֵ,
             b.TRADEPROCFEE / 100.0 ������,
             b.FUNCFEE / 100.0 ���ܷ�,
             (CASE
               WHEN a.CANCELTAG = '1' THEN
                '��ҵ���ѻ���'
               ELSE
                ''
             END) ��ʾ
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
    --��ѯ�Ź�ҵ�񱨱�
    open p_cursor for
      select TO_CHAR(h.UPDATETIME, 'YYYYMMDD') ��������,
             I.SHOPNAME �Ź��̼�,
             SUM(b.CARDSERVFEE / 100.0 + b.CARDDEPOSITFEE / 100.0 +
                 b.SUPPLYMONEY / 100.0 + b.TRADEPROCFEE / 100.0 +
                 b.FUNCFEE / 100.0 + b.OTHERFEE / 100.0) ���,
             COUNT(g.TRADEID) ����,
             (CASE
               WHEN COUNT(f.tradeid) = '0' THEN
                ''
               ELSE
                '��ҵ���ѻ���'
             END) ��ʾ
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
    --����쳣���ջ���
    OPEN P_CURSOR FOR
      SELECT TO_CHAR(T.DEALTIME, 'YYYYMMDD') ����ʱ��,
             SUM(T.TRADEMONEY) / 100.0 ���׽��
        FROM TF_TRAIN_RENEW_ERROR T
       WHERE (P_VAR1 IS NULL OR P_VAR1 = '' OR
             T.DEALTIME >= TO_DATE(P_VAR1 || '000000', 'YYYYMMDDHH24MISS'))
         AND (P_VAR2 IS NULL OR P_VAR2 = '' OR
             T.DEALTIME <= TO_DATE(P_VAR2 || '235959', 'YYYYMMDDHH24MISS'))
         AND T.DEALSTATECODE = '3'
       GROUP BY TO_CHAR(T.DEALTIME, 'YYYYMMDD')
       order by 1;
  ELSIF P_FUNCCODE = 'QUERYLRTTRECOVERLIST' THEN
    --����쳣������ϸ
    OPEN P_CURSOR FOR
      SELECT TO_CHAR(T.DEALTIME, 'YYYYMMDD') ����ʱ��,
             T.CARDNO ����,
             T.CARDTRADENO �����к�,
             T.PREMONEY / 100.0 ����ǰ���,
             T.TRADEMONEY / 100.0 ���׽��,
             (T.PREMONEY - T.TRADEMONEY) / 100.0 ���׺���
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
                            '֧����',
                            '02',
                            '΢��',
                            '03',
                            '����',
                            '04',
                            '�һ���',
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
                 and f.CHARGENO is not null --�һ���
               GROUP BY M.PACKAGETYPENAME, T.PAYCANAL
              UNION ALL
              SELECT DECODE(PAYCANAL,
                            '01',
                            '֧����',
                            '02',
                            '΢��',
                            '03',
                            '����',
                            '04',
                            '�һ���',
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
                 and f.CHARGENO is null --���öһ���
               GROUP BY M.PACKAGETYPENAME, T.PAYCANAL
              UNION ALL
              SELECT DECODE(PAYCANAL,
                            '01',
                            '֧����',
                            '02',
                            '΢��',
                            '03',
                            '����',
                            '04',
                            '�һ���',
                            PAYCANAL) PAYCANAL,
                     '�޿���ͨ',
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
                 AND T.ORDERTYPE = '0' --�޿���ͨͳ���ʷ�
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
                            '֧����',
                            '02',
                            '΢��',
                            '03',
                            '����',
                            '04',
                            '�һ���',
                            PAYCANAL) PAYCANAL,
                    '԰����������' PACKAGETYPENAME,
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
      SELECT M.PACKAGETYPENAME �ײ�����,
             F.CARDNO ����,
             DECODE(PAYCANAL,
                    '01',
                    '֧����',
                    '02',
                    '΢��',
                    '03',
                    '����',
                    PAYCANAL) ֧������,
             F.CARDCOST / 100.0 ����,
             F.FUNCFEE / 100.0 ���ܷ�,
             -ABS(F.DISCOUNT / 100.0) �Żݽ��,
             NVL(F.CARDCOST / 100.0, 0) + NVL(F.FUNCFEE / 100.0, 0) -
             ABS(F.DISCOUNT / 100.0) ʵ�ʽ��
        FROM TF_F_XXOL_ORDER T, TF_F_XXOL_ORDERDETAIL F, TD_M_PACKAGETYPE M
       WHERE T.ORDERNO = F.ORDERNO
         AND '2015' || SUBSTR(T.ORDERNO, 6, 4) >= P_VAR1
         AND '2015' || SUBSTR(T.ORDERNO, 6, 4) <= P_VAR2
         AND (P_VAR3 IS NULL OR P_VAR3 = '' OR P_VAR3 = T.ORDERTYPE)
         AND (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = T.PAYCANAL)
         AND F.PACKAGETYPE = M.PACKAGETYPECODE(+)
       ORDER BY 1, 3;
   
  elsif p_funcCode = 'WALLET_ACC_TOTAL' THEN
    --��ѯ�����ʽ�������˼�¼
    open p_cursor for
      SELECT  a.STATTIME, a.chargecardmoney/ 100.0 CHARGECARDMONEY, a.custacctmoney / 100.0 CUSTACCTMONEY, 
      a.cardacctmoney/ 100.0 CARDACCTMONEY,a.totalmoney/ 100.0 TOTALMONEY
      FROM TF_WALLETACCALYSIS a
      WHERE  substr(a.stattime, 0, 6) = p_var1 ;
             
  ELSIF P_FUNCCODE = 'EXCELFORGARDENLIST' THEN
    OPEN P_CURSOR FOR
      SELECT '԰����������' �ײ�����,
             F.CARDNO ����,
             DECODE(PAYCANAL,
                    '01',
                    '֧����',
                    '02',
                    '΢��',
                    '03',
                    '����',
                    PAYCANAL) ֧������,
             F.CARDCOST / 100.0 ����,
             F.FUNCFEE / 100.0 ���ܷ�,
             -ABS(F.DISCOUNT / 100.0) �Żݽ��,
             NVL(F.CARDCOST / 100.0, 0) + NVL(F.FUNCFEE / 100.0, 0) -
             ABS(F.DISCOUNT / 100.0) ʵ�ʽ��
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
