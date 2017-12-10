create or replace procedure SP_SD_Query
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
    v_whereSql varchar2(1024);
    v_tablename varchar2(256);
    v_balUnitNo varchar2(8);
    v_tradetype varchar2(2);
begin
if p_funcCode = 'QueryBalUnit' then
    open p_cursor for
    select tf.balunit, tf.balunitno
    from   tf_trade_balunit tf
    where  tf.usetag = '1'
    and    tf.balunit like '%' || p_var1 || '%';

elsif p_funcCode = 'QueryXXBalUnit' then
    open p_cursor for
    select tf.balunit, tf.balunitno
    from   tf_trade_balunit tf
    where  tf.usetag = '1'
    and    tf.callingno = '06'
    and    tf.balunit like '%' || p_var1 || '%';

elsif p_funcCode = 'XXBalUnitList' then
    open p_cursor for
    select tf.balunit, tf.balunitno
    from   tf_trade_balunit tf
    where  tf.usetag = '1'
    and    tf.callingno = '06';

elsif p_funcCode = 'XXResultDisplay' then
    v_tablename := 'TF_XXPARK_ERROR_'  || substr(p_var1, 6, 2);

    open p_cursor for
    'SELECT tf.CARDNO,
            tf.TRADEDATE,tf.TRADETIME,
            tf.SPARETIMES,
            tf.POSNO,tf.SAMNO,
            nvl2(co.CODEVALUE, co.CODEVALUE || '':'' || co.CODENAME, tf.ERRORREASONCODE) ERRORREASON,
            tf.ID , tf.DEALTIME,
            decode(tf.DEALSTATECODE, ''0'', ''0:δ����'', ''2'', ''2:�ѻ���'',
                ''3'', ''3:������'', tf.DEALSTATECODE) RECYSTATE,
            nvl2(st.STAFFNO, st.STAFFNO || '':'' || st.STAFFNAME, tm.RENEWSTAFFNO) RECYSTAFF,
            tm.RENEWTIME, tm.RENEWREMARK,
            nvl2(tt.BALUNITNO, tt.BALUNITNO || '':'' || tt.BALUNIT, tf.BALUNITNO) BALUNIT,
            ''05'' ICTRADETYPECODE, 0 PREMONEY, 0 TRADEMONEY, null CARDTRADENO, null CALLINGNAME,
            null CORPNAME, null DEPARTNAME
    FROM ' || v_tablename || ' tf, TF_TRADE_BALUNIT tt,
        TF_B_XXPARK_MANUAL tm, TD_M_INSIDESTAFF st,
        (select CODEVALUE, CODENAME from TD_M_CODING coding where coding.codecate = ''CATE_SD_XXERR'')co
    where tf.ID in (SELECT f0 FROM TMP_COMMON)
    and tf.ID        = tm.ID(+)
    and tf.BALUNITNO = tt.BALUNITNO(+)
    and tm.RENEWSTAFFNO = st.STAFFNO(+)
    and tf.ERRORREASONCODE = co.CODEVALUE(+)
    ORDER BY tf.DEALTIME, tf.TRADEDATE
    ';

elsif p_funcCode = 'SubmitResultDisplay' then
    v_tablename := 'TF_TRADE_ERROR_'  || substr(p_var1, 6, 2);

    open p_cursor for
    'SELECT tf.ID , tf.CARDNO, tf.CALLINGNO,
            nvl2(tno.CALLINGNO, tno.CALLINGNO || '':'' || tno.CALLING, tf.CALLINGNO) CALLINGNAME,
            tf.CORPNO,
            nvl2(tp.CORPNO, tp.CORPNO || '':'' || tp.CORP, tf.CORPNO) CORPNAME,
            tf.DEPARTNO,
            nvl2(tt.DEPARTNO, tt.DEPARTNO || '':'' || tt.DEPART, tf.DEPARTNO) DEPARTNAME,
            tf.TRADEDATE,tf.TRADETIME,
            tf.PREMONEY/100.0 PREMONEY, tf.TRADEMONEY/100.0 TRADEMONEY,tf.ASN,
            tf.CARDTRADENO,tf.POSNO,tf.SAMNO,tf.TAC,

            decode(tf.ICTRADETYPECODE, ''05'', ''05:��ͨ����'',
                ''06'', ''06:Ѻ������'', tf.ICTRADETYPECODE) ICTRADETYPECODE,

            nvl2(co.CODEVALUE, co.CODEVALUE || '':'' || co.CODENAME, tf.ERRORREASONCODE) ERRORREASON,
            tf.DEALTIME,

            decode(tf.DEALSTATECODE, ''0'', ''0:δ����'', ''2'', ''2:�ѻ���'',
                ''3'', ''3:������'', tf.DEALSTATECODE) RECYSTATE,

            nvl2(st.STAFFNO, st.STAFFNO || '':'' || st.STAFFNAME, tm.RENEWSTAFFNO) RECYSTAFF,
            tm.RENEWTIME, tm.RENEWREMARK,
            nvl2(bu.BALUNITNO, bu.BALUNITNO || '':'' || bu.BALUNIT, tf.BALUNITNO) BALUNIT
    FROM ' || v_tablename || ' tf, TF_TRADE_BALUNIT bu,
        TD_M_CALLINGNO tno, TD_M_CORP tp, TD_M_DEPART tt,
        (select * from TF_B_TRADE_MANUAL where RENEWSTATECODE = ' || p_var2 || ')tm,
        TD_M_INSIDESTAFF st,
        (select CODEVALUE, CODENAME from TD_M_CODING coding where coding.codecate = ''CATE_SD_ERR'')co
    where tf.ID in (SELECT f0 FROM TMP_COMMON)
    and tf.BALUNITNO = bu.BALUNITNO(+)
    and tf.CALLINGNO = tno.CALLINGNO(+)
    and tf.CORPNO    = tp.CORPNO(+)
    and tf.DEPARTNO  = tt.DEPARTNO(+)
    and tf.ID        = tm.ID(+)
    and tm.RENEWSTAFFNO = st.STAFFNO(+)
    and tf.ERRORREASONCODE = co.CODEVALUE(+)
    ORDER BY tf.DEALTIME, tf.TRADEDATE, tf.CARDTRADENO ';

elsif p_funcCode = 'ConsumeErrorInfo' then

    -- ��ѯ�������׼�¼, p_var12���滹�н��㵥Ԫ����,��Ӣ�Ķ��ŷָ�
    v_balUnitNo := substr(p_var12, 3);
    -- �������º��渽�Ž�������
    v_tradetype := substr(p_var1, 9);
    v_whereSql := 'WHERE tf.DEALSTATECODE = ''' || substr(p_var12, 1, 1) || ''' '
    -- ��������ʼ���ڲ�Ϊ�յ����
    || (case when (p_var2 is not null) then ' and tf.TRADEDATE >='''|| p_var2 || ''' ' end)
    -- ��������ֹ���ڲ�Ϊ�յ����
    || (case when (p_var3 is not null) then ' and tf.TRADEDATE <='''|| p_var3 || ''' ' end)
    -- ���Ų�Ϊ�յ����
    || (case when (p_var4 is not null) then ' and tf.CARDNO ='''|| p_var4 || ''' ' end)
    || (case when (p_var5 is not null) then
        ' and tf.DEALTIME >= to_date('''|| p_var5 || ' 000000'', ''YYYYMMDD HH24MISS'')
          and tf.DEALTIME <= to_date('''|| p_var5 || ' 235959'', ''YYYYMMDD HH24MISS'') ' end)
    -- ��ҵ���Ʋ�Ϊ�յ����
    || (case when (p_var6 is not null) then ' and tf.CALLINGNO = ''' || p_var6 || ''' ' end)
    -- ��λ���Ʋ�Ϊ�յ����
    || (case when (p_var7 is not null) then ' and tf.CORPNO    = ''' || p_var7 || ''' ' end)
    -- �������Ʋ�Ϊ�յ����
    || (case when (p_var8 is not null) then ' and tf.DEPARTNO  = ''' || p_var8 || ''' ' end)
    -- PSAM��Ų�Ϊ�յ����
    || (case when (p_var9 is not null) then ' and tf.SAMNO     = ''' || p_var9 || ''' ' end)
    -- ����ԭ����벻Ϊ�յ����
    || (case when (p_var10 is not null) then ' and tf.ERRORREASONCODE = ''' || p_var10 || ''' ' end)
    -- POS��Ų�Ϊ�յ����
    || (case when (p_var11 is not null) then ' and tf.POSNO like ''' || p_var11 || '%'' ' end)
    -- ���㵥Ԫ���벻Ϊ�յ����
    || (case when (v_balUnitNo is not null) then ' and tf.BALUNITNO = ''' || v_balUnitNo || ''' ' end)
    -- ��ѯ���ռ�¼ʱ,�����������㵥Ԫ̨��
    || (case when (substr(p_var12, 1, 1) = '2') then
    ' and (tm.RENEWSTATECODE is  null or tm.RENEWSTATECODE not in (''3'',''4''))' end)
    || (case when (v_tradetype is not null) then ' and tf.ICTRADETYPECODE = ''' || v_tradetype || ''' ' end)
    ;

    v_tablename := case  p_var6
        when '01' then 'TF_BUS_ERROR'
        else 'TF_TRADE_ERROR_'  || substr(p_var1, 6, 2)
        end;

    execute immediate 'SELECT count(*), sum(tf.TRADEMONEY)/100.0
        FROM ' || v_tablename || ' tf, TF_B_TRADE_MANUAL tm ' || v_whereSql || '
        and tf.ID = tm.ID(+)'
        into p_var11, p_var12;

    open p_cursor for
    'SELECT tf.ID , tf.CARDNO, tf.CALLINGNO,
            nvl2(tno.CALLINGNO, tno.CALLINGNO || '':'' || tno.CALLING, tf.CALLINGNO) CALLINGNAME,
            tf.CORPNO,
            nvl2(tp.CORPNO, tp.CORPNO || '':'' || tp.CORP, tf.CORPNO) CORPNAME,
            tf.DEPARTNO,
            nvl2(tt.DEPARTNO, tt.DEPARTNO || '':'' || tt.DEPART, tf.DEPARTNO) DEPARTNAME,
            tf.TRADEDATE,tf.TRADETIME,
            tf.PREMONEY/100.0 PREMONEY, tf.TRADEMONEY/100.0 TRADEMONEY,tf.ASN,
            tf.CARDTRADENO,tf.POSNO,tf.SAMNO,tf.TAC,

            decode(tf.ICTRADETYPECODE, ''05'', ''05:��ͨ����'',
                ''06'', ''06:Ѻ������'', tf.ICTRADETYPECODE) ICTRADETYPECODE,

            nvl2(co.CODEVALUE, co.CODEVALUE || '':'' || co.CODENAME, tf.ERRORREASONCODE) ERRORREASON,
            tf.DEALTIME,

            decode(tf.DEALSTATECODE, ''0'', ''0:δ����'', ''2'', ''2:�ѻ���'',
                ''3'', ''3:������'', tf.DEALSTATECODE) RECYSTATE,

            nvl2(st.STAFFNO, st.STAFFNO || '':'' || st.STAFFNAME, tm.RENEWSTAFFNO) RECYSTAFF,
            tm.RENEWTIME, tm.RENEWREMARK,
            nvl2(bu.BALUNITNO, bu.BALUNITNO || '':'' || bu.BALUNIT, tf.BALUNITNO) BALUNIT
    FROM ' || v_tablename || ' tf, TF_TRADE_BALUNIT bu,
        TD_M_CALLINGNO tno, TD_M_CORP tp, TD_M_DEPART tt,
        TF_B_TRADE_MANUAL tm, TD_M_INSIDESTAFF st,
        (select CODEVALUE, CODENAME from TD_M_CODING coding where coding.codecate = ''CATE_SD_ERR'')co '
    || v_whereSql || '
    and tf.BALUNITNO = bu.BALUNITNO(+)
    and tf.CALLINGNO = tno.CALLINGNO(+)
    and tf.CORPNO    = tp.CORPNO(+)
    and tf.DEPARTNO  = tt.DEPARTNO(+)
    and tf.ID        = tm.ID(+)
    and tm.RENEWSTAFFNO = st.STAFFNO(+)
    and tf.ERRORREASONCODE = co.CODEVALUE(+)
    ORDER BY tf.DEALTIME, tf.TRADEDATE, tf.CARDTRADENO ';

elsif p_funcCode = 'ConsumeInfoQuery' then
    v_whereSql := 'WHERE tq.TRADEDATE >= ''' || p_var1 || ''''
        || ' and tq.TRADEDATE <= ''' || p_var2 || ''''
        || (case when (p_var3 is not null) then ' and tq.CARDNO ='''|| p_var3 || ''' ' end)
        || (case when (p_var4 is not null) then ' and tq.CALLINGNO ='''|| p_var4 || ''' ' end)
        || (case when (p_var5 is not null) then ' and tq.CORPNO ='''|| p_var5 || ''' ' end)
        || (case when (p_var6 is not null) then ' and tq.DEPARTNO ='''|| p_var6 || ''' ' end)
        || (case when (p_var7 is not null) then ' and tq.POSNO like '''|| p_var7 || '%'' ' end)
        || (case when (p_var8 is not null) then ' and tq.SAMNO ='''|| p_var8 || ''' ' end)
        || (case when (p_var9 is not null) then ' and tq.tq.DEALTIME >= to_date(''' || p_var9 || ''', ''YYYYMMDD'') ' end)
        || (case when (p_var9 is not null) then ' and tq.tq.DEALTIME <= to_date(''' || p_var9 || ''', ''YYYYMMDD'') + 1 ' end)
    ;

    execute immediate 'select /*+rule*/ count(rowid), sum(tq.TRADEMONEY)/100.0 from TQ_TRADE_RIGHT tq ' || v_whereSql
        into p_var11, p_var12;

    open p_cursor for
        'SELECT * FROM (
        SELECT tq.CARDNO, tq.CALLINGNO, tno.CALLING CALLINGNAME, tq.CORPNO,
               tp.CORP CORPNAME, tq.DEPARTNO, tt.DEPART DEPARTNAME,
               tq.TRADEDATE,tq.TRADETIME,tq.PREMONEY/100.0 PREMONEY,
               tq.TRADEMONEY/100.0 TRADEMONEY,tq.SAMNO,tq.ASN,tq.CARDTRADENO,
               tq.POSNO, tq.TAC, tq.DEALTIME DEALTIME
        FROM TQ_TRADE_RIGHT tq, TD_M_CALLINGNO tno, TD_M_CORP tp, TD_M_DEPART tt
        ' || v_whereSql || '
        AND tq.CALLINGNO = tno.CALLINGNO(+)
        AND tq.CORPNO = tp.CORPNO(+)
        AND tq.DEPARTNO = tt.DEPARTNO(+)
        AND rownum <= 1000)
    ORDER BY DEALTIME, TRADEDATE, CARDTRADENO';

elsif p_funcCode = 'SpeAdjustAccQuery' then
    open p_cursor for
    SELECT decode(tf.STATECODE, '0', '¼������', '1', '���ͨ��',
            '2', '�ѵ��ʳ�ֵ', '3', 'ȷ������', tf.STATECODE) ���״̬,
           tf.CARDNO IC����, tf.CALLINGNO || ':' || tno.CALLING ��ҵ,
           tf.CORPNO || ':' || tp.CORP ��λ, tf.DEPARTNO || ':' || tt.DEPART ����,
           tf.BALUNITNO ���㵥Ԫ����,
           tf.TRADEDATE ��������,tf.TRADEMONEY/100.0 ���ף�,tf.REFUNDMENT/100.0 �˿,
           tf.REBROKERAGE/100.0 Ӧ��Ӷ��,
           tf.STAFFNO || ':' || ti.STAFFNAME ¼��Ա��, tf.OPERATETIME ¼��ʱ��,
           decode(tf.REASONCODE, '1', '�����˻�', '2', '���׳ɹ�,ǩ����δ��ӡ',
                '3', '���ײ��ɹ�,�ۿ�', '4', '��ˢ���',
                '5', '����',  tf.REASONCODE) ����ԭ��,
           tj.STAFFNAME ��ֵԱ��, tf.SUPPTIME ��ֵʱ��,
           tf.CUSTPHONE �ֿ��˵绰, tf.CUSTNAME �ֿ���
    FROM   TF_B_SPEADJUSTACC tf, TD_M_CALLINGNO tno, TD_M_CORP tp,
           TD_M_DEPART tt, TD_M_INSIDESTAFF ti,  TD_M_INSIDESTAFF tj
    WHERE  tf.TRADETYPECODE = '97'
    AND   (p_var1 is null or p_var1 = tf.STATECODE)
    AND   (p_var2 is null or p_var2 = tf.STAFFNO  )
    AND   (p_var3 is null or tf.OPERATETIME >= TO_DATE(p_var3, 'YYYYMMDD')
                         AND tf.OPERATETIME < TO_DATE(p_var9, 'YYYYMMDD') + 1)
    AND   (p_var4 is null or p_var4 = tf.CARDNO  )
    AND   (p_var5 is null or p_var5 = tf.BALUNITNO)
    AND   (p_var6 is null or p_var6 = tf.CALLINGNO)
    AND   (p_var7 is null or p_var7 = tf.CORPNO)
    AND   (p_var8 is null or p_var8 = tf.DEPARTNO)
    
    AND   tf.CALLINGNO   = tno.CALLINGNO(+)
    AND   tf.CORPNO      = tp.CORPNO    (+)
    AND   tf.DEPARTNO    = tt.DEPARTNO  (+)
    AND   tf.STAFFNO     = ti.STAFFNO   (+)
    AND   tf.SUPPSTAFFNO = tj.STAFFNO   (+)
    AND   ROWNUM < 1000
    ;
elsif p_funcCode = 'SpeAdjustAcc' then
    open p_cursor for
    SELECT tf.CALLINGNO || ':' || tno.CALLING ��ҵ,
           tf.CORPNO || ':' || tp.CORP ��λ,
           tf.DEPARTNO || ':' || tt.DEPART ����,
           tf.TRADEDATE ��������, tf.TRADEMONEY/100.0 ���ף�,
           tf.REFUNDMENT/100.0 ���ˣ�,
           tf.CHECKSTAFFNO || ':' || ti.STAFFNAME �����,
           tf.CHECKTIME ���ʱ��,
           decode(tf.REASONCODE,
             '1', '�����˻�', '2', '���׳ɹ�,ǩ����δ��ӡ',
             '3', '���ײ��ɹ�,�ۿ�', '4', '��ˢ���',
             '5', '����', tf.REASONCODE) ����ԭ��
    FROM  TF_B_SPEADJUSTACC tf, TD_M_CALLINGNO tno, TD_M_CORP tp,
          TD_M_DEPART tt, TD_M_INSIDESTAFF ti
    WHERE tf.TRADETYPECODE = '97'
    AND   tf.STATECODE     = '1'
    AND   tf.CARDNO        = p_var1
    AND   tf.CALLINGNO     = tno.CALLINGNO(+)
    AND   tf.CORPNO        = tp.CORPNO(+)
    AND   tf.DEPARTNO      = tt.DEPARTNO(+)
    AND   tf.CHECKSTAFFNO  = ti.STAFFNO(+)
    ;
elsif p_funcCode = 'TaxiAppendQuery' then
    open p_cursor for

    SELECT  tl.CARDNO, tl.CORPNO, tp.CORP CORPNAME, tl.DEPARTNO,tt.DEPART DEPARTNAME,
            tl.CALLINGSTAFFNO, tcf.STAFFNAME TAXIDRINAME,  tl.TRADEDATE, tl.TRADETIME,
            tl.PREMONEY/100.0 PREMONEY,  tl.TRADEMONEY/100.0 TRADEMONEY,   tl.ASN,
            tl.CARDTRADENO, tl.POSTRADENO, tl.SAMNO,
            tl.TAC, tl.STAFFNO, ti.STAFFNAME APPSTAFF, tl.OPERATETIME,
            decode(tl.DEALSTATECODE, '0', 'δ�����ؽ��㴦��', '2', 'ֱ��ǰ̨��Ǯ', tl.DEALSTATECODE) DEALSTATECODE,
            tl.TRADEID

    FROM    TF_B_TRADE_ACPMANUAL tl, TD_M_CALLINGNO tno, TD_M_CORP tp, TD_M_DEPART tt,
            TD_M_CALLINGSTAFF tcf, TD_M_INSIDESTAFF ti

    WHERE   (p_var1 is null or p_var1 = tl.RENEWSTATECODE)
    AND     tl.CALLINGNO     = '02'
	AND		tcf.CALLINGNO     = '02'
    AND     tl.CALLINGNO      = tno.CALLINGNO(+)
    AND     tl.CORPNO         = tp.CORPNO    (+)
    AND     tl.DEPARTNO       = tt.DEPARTNO  (+)
    AND     tl.CALLINGSTAFFNO = tcf.STAFFNO  (+)
    AND     tl.STAFFNO        = ti.STAFFNO   (+)
    ;

elsif p_funcCode = 'XXPARKErrorInfo' then
    -- ��ѯ�������׼�¼, p_var12���滹�н��㵥Ԫ����,��Ӣ�Ķ��ŷָ�
    v_balUnitNo := substr(p_var12, 3);
    -- �������º��渽�Ž�������
    v_whereSql := 'WHERE tf.DEALSTATECODE = ''' || substr(p_var12, 1, 1) || ''' '
    -- ��������ʼ���ڲ�Ϊ�յ����
    || (case when (p_var2 is not null) then ' and tf.TRADEDATE >='''|| p_var2 || ''' ' end)
    -- ��������ֹ���ڲ�Ϊ�յ����
    || (case when (p_var3 is not null) then ' and tf.TRADEDATE <='''|| p_var3 || ''' ' end)
    -- ���Ų�Ϊ�յ����
    || (case when (p_var4 is not null) then ' and tf.CARDNO ='''|| p_var4 || ''' ' end)
    || (case when (p_var5 is not null) then
        ' and tf.DEALTIME >= to_date('''|| p_var5 || ' 000000'', ''YYYYMMDD HH24MISS'')
          and tf.DEALTIME <= to_date('''|| p_var5 || ' 235959'', ''YYYYMMDD HH24MISS'') ' end)
    -- ���㵥Ԫ��Ϊ�յ����
    || (case when (p_var6 is not null) then ' and tf.BALUNITNO = ''' || p_var6 || ''' ' end)
    || (case when (v_balUnitNo is not null) then ' and tf.BALUNITNO = ''' || v_balUnitNo || ''' ' end)
    -- ��λ���Ʋ�Ϊ�յ����
    --|| (case when (p_var7 is not null) then ' and tf.CORPNO    = ''' || p_var7 || ''' ' end)
    -- �������Ʋ�Ϊ�յ����
    --|| (case when (p_var8 is not null) then ' and tf.DEPARTNO  = ''' || p_var8 || ''' ' end)
    -- PSAM��Ų�Ϊ�յ����
    || (case when (p_var9 is not null) then ' and tf.SAMNO     = ''' || p_var9 || ''' ' end)
    -- ����ԭ����벻Ϊ�յ����
    || (case when (p_var10 is not null) then ' and tf.ERRORREASONCODE = ''' || p_var10 || ''' ' end)
    -- POS��Ų�Ϊ�յ����
    || (case when (p_var11 is not null) then ' and tf.POSNO like ''' || p_var11 || '%'' ' end);

    v_tablename := 'TF_XXPARK_ERROR_' || substr(p_var1, 6, 2);

    open p_cursor for
    'SELECT tf.CARDNO,
            tf.TRADEDATE,tf.TRADETIME,
            tf.SPARETIMES,
            tf.POSNO,tf.SAMNO,
            nvl2(co.CODEVALUE, co.CODEVALUE || '':'' || co.CODENAME, tf.ERRORREASONCODE) ERRORREASON,
            tf.ID , tf.DEALTIME,
            decode(tf.DEALSTATECODE, ''0'', ''δ����'', ''2'', ''�ѻ���'',
                ''3'', ''������'', tf.DEALSTATECODE) RECYSTATE,
            nvl2(st.STAFFNO, st.STAFFNO || '':'' || st.STAFFNAME, tm.RENEWSTAFFNO) RECYSTAFF,
            tm.RENEWTIME, tm.RENEWREMARK,
            nvl2(tt.BALUNITNO, tt.BALUNITNO || '':'' || tt.BALUNIT, tf.BALUNITNO) BALUNIT,
            ''05'' ICTRADETYPECODE, 0 PREMONEY, 0 TRADEMONEY, null CARDTRADENO, null CALLINGNAME,
            null CORPNAME, null DEPARTNAME
    FROM ' || v_tablename || ' tf, TF_TRADE_BALUNIT tt,
        TF_B_XXPARK_MANUAL tm, TD_M_INSIDESTAFF st,
        (select CODEVALUE, CODENAME from TD_M_CODING coding where coding.codecate = ''CATE_SD_XXERR'')co '
    || v_whereSql || '
    and tf.ID        = tm.ID(+)
    and tf.BALUNITNO = tt.BALUNITNO(+)
    and tm.RENEWSTAFFNO = st.STAFFNO(+)
    and tf.ERRORREASONCODE = co.CODEVALUE(+)
    ORDER BY tf.DEALTIME, tf.TRADEDATE
    ';

elsif p_funcCode = 'QrySupplyDiff' then
    -- TP_SUPPLY_DIFF�е��ֶ�PREMONEY,TRADEMONEY��
    -- COMPSTATE = '0' (�ѻ���  )ʱ����������ǰ���ͽ��׽��
    -- COMPSTATE = '1' (������  )ʱ���ѻ�����ǰ���ͽ��׽��
    -- COMPSTATE = '2' (����)ʱ���ѻ�����ǰ���ͽ��׽��
    -- COMPMONEY ������������ǣ��������-�ѻ���

    open p_cursor for
    select decode(tf.COMPSTATE, '0', '�ѻ���', '1', '������', '2', '����', tf.COMPSTATE) COMPSTATE,
        tf.CARDNO, tf.CALLINGNO, tno.CALLING CALLINGNAME,
        tf.CORPNO, tp.CORP CORPNAME,tf.DEPARTNO,tt.DEPART DEPARTNAME,tbal.BALUNIT BALUNIT,
        tf.TRADEDATE, tf.TRADETIME,
        tf.PREMONEY/100.0 PREMONEY, tf.TRADEMONEY/100.0 TRADEMONEY,
        tf.COMPMONEY/100.0 COMPMONEY, tf.COMPTTIME,
        tf.ASN,tf.CARDTRADENO,tf.POSNO,tf.SAMNO,tf.TAC,tf.ID
    from TP_SUPPLY_DIFF tf, TD_M_CALLINGNO tno, TD_M_CORP tp, TD_M_DEPART tt,TF_SELSUP_BALUNIT tbal
    where tf.RENEWTYPECODE = '0'
    and   (p_var1 is null or tf.TRADEDATE >= p_var1)
    and   (p_var2 is null or tf.TRADEDATE <= p_var2)
    and   (p_var3 is null or tf.CARDNO = p_var3)
    and   (p_var4 is null or tf.CALLINGNO = p_var4)
    and   (p_var5 is null or tf.CORPNO = p_var5)
    and   (p_var6 is null or tf.DEPARTNO = p_var6)
    and   (p_var7 is null or tf.SAMNO = p_var7)
    and   (p_var8 is null or tf.COMPSTATE = p_var8)
    and   (p_var9 is null or tf.POSNO = p_var9)
    and tf.CALLINGNO = tno.CALLINGNO(+)
    and     tf.BALUNITno = tbal.BALUNITNO(+)
    and tf.CORPNO = tp.CORPNO(+)
    and tf.DEPARTNO = tt.DEPARTNO(+)
    ;



elsif p_funcCode = 'QryAutoBalUnit' then

    open p_cursor for
    select bo.balunitno,tb.balunit,to_char(bo.effectivedate,'yyyy-MM-dd') effectivedate,bo.state
    from TD_BALUNIT_AUTORENEW bo,tf_trade_balunit tb
    where bo.balunitno=tb.balunitno(+)
    and   (p_var1 is null or bo.balunitno = p_var1)

    ;
elsif p_funcCode = 'AutoTraAppendQuery' then

    open p_cursor for
    SELECT  tl.ID,tl.CARDNO,tl.SAMNO,tl.POSNO,tl.TRADEDATE,tl.TRADETIME,
	          tl.PREMONEY/100.0 PREMONEY,tl.TRADEMONEY/100.0 TRADEMONEY,tl.SMONEY/100.0 SMONEY,tl.TRADECOMFEE/100.0 TRADECOMFEE,tl.BALUNITNO,
	          tl.CALLINGNO,tl.CORPNO,tl.DEPARTNO,tl.CARDTRADENO,
	          decode(tl.ERRORREASONCODE,'1','1���Ҽ�¼','2','2��TACУ�����ǻҼ�¼','6','6����������','7','7����������',
	          '8','8��PSAM���Ƿ�','9','9���ն˺ŷǷ�','A','A��POS��SAM��ƥ��','B','B��ȱ�ٽ��㵥Ԫ����','C','C��ȱ�ٿ���',
	          'Z','Z���Ѿ��˹���ȫ���㵥Ԫ',tl.ERRORREASONCODE) ERRORREASON,
	          tl.DEALTIME,tl.BALTIME,
	          decode(tl.RENEWTYPECODE,'0','0���쳣��¼ֱ�ӻ���','1','1���쳣��¼�޸ĺ����','2','2���˹����뽻�׼�¼',tl.RENEWTYPECODE) RENEWTYPE,
            tl.DEALSTATECODE,tl.INVENTORYSTATE,tl.SOURCESTATE,
            ttb.BALUNITNO,ttb.BALUNIT,
            tmo.CALLINGNO,tmo.CALLING,rp.CORPNO,rp.CORP,tt.DEPARTNO,tt.DEPART,
            tmo.CALLINGNO||':'||tmo.CALLING CALLNONAME,
            rp.CORPNO||':'||rp.CORP CORPNONAME,
            tt.DEPARTNO||':'||tt.DEPART DEPARTNONAME

    FROM    TI_TRADE_MANUAL tl,TD_M_CALLINGNO tmo,
            TD_M_CORP rp,TD_M_DEPART tt,tf_trade_balunit ttb
    where   tl.DEALSTATECODE='0'
    and     (tl.INVENTORYSTATE is  null or tl.INVENTORYSTATE <>2)
    and     tl.SOURCESTATE='1'
    and     ( p_var1 is null or p_var1 = '' or tl.CARDNO = p_var1)
    and     ( p_var2 is null or p_var2 = '' or tl.BALUNITNO = p_var2)
    and     ( p_var3 is null or p_var3 = '' or TRADEDATE>= p_var3)
    and     ( p_var4 is null or p_var4 = '' or TRADEDATE <= p_var4)
    and     ( p_var5 is null or p_var5 = '' or tl.CALLINGNO = p_var5)
    and     ( p_var6 is null or p_var6 = '' or tl.CORPNO = p_var6)
    and     ( p_var7 is null or p_var7 = '' or tl.DEPARTNO = p_var7)
    and     tmo.CALLINGNO(+)=tl.CALLINGNO
    and     rp.CORPNO(+)=tl.CORPNO
    and     tt.DEPARTNO(+)=tl.DEPARTNO
    and     ttb.BALUNITNO(+)=tl.BALUNITNO
    and     exists (select 1 from TD_BALUNIT_AUTORENEW bo where bo.balunitno=tl.balunitno and bo.state='0' )
    ORDER BY tl.DEALTIME,tl.CARDNO,tl.CARDTRADENO
    ;
elsif p_funcCode = 'QueryLRTTradeMendInfo' then
    open p_cursor for
    SELECT 
        a.TRADEID    , a.CARDNO      , a.TRADEDATE      ,
        DECODE(a.CHECKSTATECODE,'0','¼������','1','���ͨ��','2','ȷ������',a.CHECKSTATECODE) CHECKSTATECODE, 
        a.TRADETIME  , a.CARDTRADENO , a.ERRORREASON    , a.TRADEMONEY/100.0  TRADEMONEY  ,
        a.DEALRESULT , a.DEALSTAFFNO , a.DEALDATE       , b.STAFFNAME  RENEWSTAFF         ,
        a.RENEWTIME  , a.CHECKTIME   , a.REMARK         , c.STAFFNAME CHECKSTAFF   
    FROM  TF_B_LRTTRADE_MANUAL a , TD_M_INSIDESTAFF b ,TD_M_INSIDESTAFF c
    WHERE a.RENEWSTAFFNO = b.STAFFNO(+)
    AND   a.CHECKSTAFFNO = c.STAFFNO(+)
    AND  (P_VAR1 IS NULL OR P_VAR1 = '' OR a.CARDNO = P_VAR1)
    AND  (P_VAR2 IS NULL OR P_VAR2 = '' OR a.CHECKSTATECODE = P_VAR2)
    AND  (P_VAR3 IS NULL OR P_VAR3 = '' OR a.TRADEDATE >= P_VAR3)
    AND  (P_VAR4 IS NULL OR P_VAR4 = '' OR a.TRADEDATE <= P_VAR4)
    AND  (P_VAR5 IS NULL OR P_VAR5 = '' OR a.DEALDATE >= P_VAR5)
    AND  (P_VAR6 IS NULL OR P_VAR6 = '' OR a.DEALDATE <= P_VAR6)
    ORDER BY a.RENEWTIME DESC
    ;
elsif p_funcCode = 'QueryLRTTradeMendAudit' then
    open p_cursor for        
    SELECT 
        a.TRADEID     , a.CARDNO       , a.TRADEDATE    , a.TRADETIME    , 
        a.TRADEMONEY/100.0 TRADEMONEY  , a.CARDTRADENO  , a.ERRORREASON  , a.DEALRESULT , 
        a.DEALSTAFFNO , a.DEALDATE     , b.STAFFNAME    , a.RENEWTIME    , 
        a.REMARK
    FROM  TF_B_LRTTRADE_MANUAL a , TD_M_INSIDESTAFF b 
    WHERE a.RENEWSTAFFNO = b.STAFFNO(+)
    AND   a.CHECKSTATECODE = '0'
    ORDER BY a.RENEWTIME DESC
    ;    
elsif p_funcCode = 'QuerySupplyAutpReverse' then
    open p_cursor for    
    SELECT 
        a.ID          , a.CARDNO      , a.ASN     , a.CARDTRADENO ,
        a.TRADEDATE   , a.TRADETIME   , a.TRADEMONEY/100.0 TRADEMONEY , a.PREMONEY/100.0 PREMONEY,        
        a.SAMNO       , a.POSNO       , a.TAC     , a.BALUNITNO ||':'||b.BALUNIT BALUNIT ,
        decode(a.TRADESTATECODE,'1','�ɹ�','2','���ó�ʱ','3','д��ʧ��',a.TRADESTATECODE) TRADESTATECODE
    FROM TF_OUTSUPPLY_ADJUST a , TF_SELSUP_BALUNIT b 
    WHERE a.DEALSTATECODE = '1'
    AND   a.BALUNITNO = b.BALUNITNO(+)
	AND   a.RSRVCHAR IS NULL
    AND  (P_VAR1 IS NULL OR P_VAR1 = '' OR a.TRADEDATE >= P_VAR1)
    AND  (P_VAR2 IS NULL OR P_VAR2 = '' OR a.TRADEDATE <= P_VAR2)
    AND  (P_VAR3 IS NULL OR P_VAR3 = '' OR a.CARDNO = P_VAR3)
    AND  (P_VAR4 IS NULL OR P_VAR4 = '' OR a.BALUNITNO = P_VAR4)
    ORDER BY a.TRADEDATE DESC
    ;
elsif p_funcCode = 'QuerySupplyAutpReverseDeptBal' then
    open p_cursor for
    SELECT
        a.ID          , a.CARDNO      , a.ASN     , a.CARDTRADENO ,
        a.TRADEDATE   , a.TRADETIME   , a.TRADEMONEY/100.0 TRADEMONEY , a.PREMONEY/100.0 PREMONEY,
        a.SAMNO       , a.POSNO       , a.TAC     , a.BALUNITNO ||':'||b.DBALUNIT BALUNIT ,
        decode(a.TRADESTATECODE,'1','�ɹ�','2','���ó�ʱ','3','д��ʧ��',a.TRADESTATECODE) TRADESTATECODE
    FROM TF_OUTSUPPLY_ADJUST a , TF_DEPT_BALUNIT b
    WHERE a.DEALSTATECODE = '1'
    AND   a.BALUNITNO = b.DBALUNITNO(+)
	AND   a.RSRVCHAR = 'S1'
    AND  (P_VAR1 IS NULL OR P_VAR1 = '' OR a.TRADEDATE >= P_VAR1)
    AND  (P_VAR2 IS NULL OR P_VAR2 = '' OR a.TRADEDATE <= P_VAR2)
    AND  (P_VAR3 IS NULL OR P_VAR3 = '' OR a.CARDNO = P_VAR3)
    AND  (P_VAR4 IS NULL OR P_VAR4 = '' OR a.BALUNITNO = P_VAR4)
    ORDER BY a.TRADEDATE DESC
    ;
elsif p_funcCode = 'QueryDept' then
	open p_cursor for
	SELECT a.BALUNITNO,a.BALUNIT FROM TF_TRADE_BALUNIT a WHERE a.BALUNIT LIKE '%' || P_VAR1 || '%';
elsif p_funcCode = 'QueryCancel' then
	if p_VAR7 = '0' then
    open p_cursor for
    SELECT a.DEALTIME ����ʱ��,b.BALUNIT ���㵥Ԫ����,COUNT(*) �ܱ���,SUM(a.TRADEMONEY)/100.00 �ܽ��
    FROM TQ_TRADE_ERROR a,TF_TRADE_BALUNIT b
    WHERE a.DEALSTATECODE='3'	--����
    AND   a.BALUNITNO = b.BALUNITNO(+)
    AND  (P_VAR1 IS NULL OR P_VAR1 = '' OR a.BALUNITNO = P_VAR1) 
    AND  (P_VAR2 IS NULL OR P_VAR2 = '' OR a.DEALTIME >= to_date(P_VAR2,'yyyyMMdd'))
    AND  (P_VAR3 IS NULL OR P_VAR3 = '' OR a.DEALTIME <= to_date(P_VAR3,'yyyyMMdd'))
    GROUP BY a.DEALTIME,b.BALUNIT
    ORDER BY a.DEALTIME,b.BALUNIT
    ;
    else
    open p_cursor for
    SELECT a.TRADEDATE ��������,a.TRADETIME ����ʱ��,a.CARDNO ����,a.CARDTRADENO ���������к�,a.POSNO POS���,a.SAMNO PSAM���,
			a.TAC TAC��,decode(a.ICTRADETYPECODE, '05', '05:��ͨ����',
                '06', '06:Ѻ������', a.ICTRADETYPECODE) IC����������,
			a.PREMONEY/100.0 ����ǰ�������,a.TRADEMONEY/100.00 ���׽��,a.ASN ASN��,
			b.BALUNIT ���㵥Ԫ����,c.CALLING ��ҵ����,d.CORP ��λ����,e.DEPART ��������,
			decode(a.ERRORREASONCODE,'1','1���Ҽ�¼','2','2��TACУ�����ǻҼ�¼','6','6����������','7','7����������',
	        '8','8��PSAM���Ƿ�','9','9���ն˺ŷǷ�','A','A��POS��SAM��ƥ��','B','B��ȱ�ٽ��㵥Ԫ����','C','C��ȱ�ٿ���',
	        'Z','Z���Ѿ��˹���ȫ���㵥Ԫ',a.ERRORREASONCODE) ����ԭ��,a.DEALTIME ����ʱ��
    FROM TQ_TRADE_ERROR a,TF_TRADE_BALUNIT b,TD_M_CALLINGNO c,TD_M_CORP d,TD_M_DEPART e
    WHERE a.DEALSTATECODE='3'	--����
    AND   a.BALUNITNO = b.BALUNITNO(+)
	AND   a.CALLINGNO = c.CALLINGNO(+)
	AND   a.CORPNO    = d.CORPNO(+)
	AND   a.DEPARTNO  = e.DEPARTNO(+)
    AND  (P_VAR1 IS NULL OR P_VAR1 = '' OR a.BALUNITNO = P_VAR1)
    AND  (P_VAR2 IS NULL OR P_VAR2 = '' OR a.DEALTIME >= to_date(P_VAR2,'yyyyMMdd'))
    AND  (P_VAR3 IS NULL OR P_VAR3 = '' OR a.DEALTIME <= to_date(P_VAR3,'yyyyMMdd'))
    AND  (P_VAR4 IS NULL OR P_VAR4 = '' OR a.CARDNO = P_VAR4)
    AND  (P_VAR5 IS NULL OR P_VAR5 = '' OR a.TRADEDATE >= P_VAR5)
    AND  (P_VAR6 IS NULL OR P_VAR6 = '' OR a.TRADEDATE <= P_VAR6)
	ORDER BY a.TRADEDATE,a.BALUNITNO
    ;
    end if;
elsif p_funcCode = 'QueryTestBusCard' then
    open p_cursor for   
	SELECT A.CARDNO,A.ASN,B.STAFFNO || ':' || B.STAFFNAME STAFFNAME,C.DEPARTNO || ':' || C.DEPARTNAME DEPARTNAME,A.OPERATETIME
		FROM TF_BUS_TESTCARD A,TD_M_INSIDESTAFF B,TD_M_INSIDEDEPART C
		WHERE A.CARDNO LIKE '%' || p_var1 || '%'
		AND A.OPERATESTAFFNO = B.STAFFNO(+)
		AND A.OPERATEDEPARTID = C.DEPARTNO(+)
		ORDER BY A.OPERATETIME DESC
    ;	
end if;

end;
/
show errors
