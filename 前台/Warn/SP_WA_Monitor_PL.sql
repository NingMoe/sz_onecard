-- �澯�����¹���
create or replace procedure SP_WA_UpdateWarn
(
    p_sql      varchar2,  -- sql ���, Ҫ�����Ȱ��տ�����������
    p_condCate char    ,  -- �������, '1' �嵥�� '0' �˻���
    p_warnSrc  int     ,
    p_amount   in out int
)
as
    v_c             SYS_REFCURSOR;
    v_initialTime   DATE;

    v_cardNoTmp     TF_B_WARN_DETAIL.CARDNO%type;
    v_idTmp         TF_B_WARN_DETAIL.ID%type;
    v_preMoneyTmp   TF_B_WARN_DETAIL.PREMONEY%type;
    v_tradeMoneyTmp TF_B_WARN_DETAIL.TRADEMONEY%type;
    v_accBalanceTmp TF_B_WARN_DETAIL.ACCBALANCE%type;
    v_condCodeTmp   TF_B_WARN_DETAIL.CONDCODE%type;
    v_warnTypeTmp   TF_B_WARN_DETAIL.WARNTYPE%type;
    v_warnLevelTmp  TF_B_WARN_DETAIL.WARNLEVEL%type;
    v_remarkTmp     TF_B_WARN_DETAIL.REMARK%type;

    v_cardNo        TF_B_WARN_DETAIL.CARDNO%type;
    v_id            TF_B_WARN_DETAIL.ID%type;
    v_preMoney      TF_B_WARN_DETAIL.PREMONEY%type;
    v_tradeMoney    TF_B_WARN_DETAIL.TRADEMONEY%type;
    v_accBalance    TF_B_WARN_DETAIL.ACCBALANCE%type;
    v_condCode      TF_B_WARN_DETAIL.CONDCODE%type;
    v_warnType      TF_B_WARN_DETAIL.WARNTYPE%type;
    v_warnLevel     TF_B_WARN_DETAIL.WARNLEVEL%type;
    v_remark        TF_B_WARN_DETAIL.REMARK%type;
    v_amount        int;
begin
    open v_c for p_sql;
    v_cardNoTmp := null;
    v_amount := 0;

    loop
        fetch v_c into v_id, v_cardNo, v_preMoney, v_tradeMoney, v_accBalance,
            v_condCode, v_warnType, v_warnLevel, v_remark;

        exit when v_c%NOTFOUND and v_cardNoTmp is null;

        if v_c%NOTFOUND or v_cardNoTmp != v_cardNo then
            -- �ڿ��ű仯���߲�ѯ������ʱ������߸��¸澯����
            merge into TF_B_WARN t
            using dual on (t.CARDNO = v_cardNoTmp)
            when matched then
                update set
                t.LASTTIME  = sysdate, t.DETAILS = t.DETAILS + v_amount,
                t.CONDCODE  = v_condCodeTmp, t.WARNTYPE  = v_warnTypeTmp,
                t.WARNLEVEL = v_warnLevelTmp, t.WARNSRC   = p_warnSrc,
                t.PREMONEY  = v_preMoneyTmp, t.TRADEMONEY = v_tradeMoneyTmp,
                t.ACCBALANCE = v_accBalanceTmp, t.REMARK = v_remarkTmp
            when not matched then
                insert (CARDNO, INITIALTIME, LASTTIME, DETAILS,
                    CONDCODE, WARNTYPE, WARNLEVEL, WARNSRC,
                    PREMONEY, TRADEMONEY, ACCBALANCE,
                    REMARK)
                values (v_cardNoTmp, v_initialTime, sysdate, v_amount,
                    v_condCodeTmp, v_warnTypeTmp, v_warnLevelTmp, p_warnSrc,
                    v_preMoneyTmp, v_tradeMoneyTmp, v_accBalanceTmp,
                    v_remarkTmp);

            v_cardNoTmp := v_cardNo;
            v_amount := 0;
        end if;

        exit when v_c%NOTFOUND;

        -- ��һ�θ�ֵ����ʱ�����ֶ�
        if v_cardNoTmp is null then
            v_cardNoTmp := v_cardNo;
            v_initialTime := sysdate;
        end if;

        select v_id, v_cardNo, v_preMoney, v_tradeMoney,
            v_accBalance, v_condCode, v_warnType,
            v_warnLevel, v_remark
        into v_idTmp, v_cardNoTmp, v_preMoneyTmp, v_tradeMoneyTmp,
            v_accBalanceTmp, v_condCodeTmp, v_warnTypeTmp,
            v_warnLevelTmp, v_remarkTmp
        from dual;

        v_amount := v_amount + 1;
        p_amount := p_amount + 1;

        if p_condCate = '0' then -- �˻���ɾ����ͬ�澯���͵��굥
            delete from TF_B_WARN_DETAIL
            where  CARDNO   = v_cardNo
            and    WARNTYPE = v_warnType
            and    CONDCODE in 
                (select CONDCODE 
                 from   TD_M_WARNCOND
                 where  CONDCATE = '0');
        end if;

        -- ����澯�굥
        insert into TF_B_WARN_DETAIL
            (CARDNO, SEQNO, ID, LASTTIME, CONDCODE,
             WARNTYPE, WARNLEVEL, WARNSRC, PREMONEY, TRADEMONEY,
             ACCBALANCE, REMARK)
        values
            (v_cardNo, TF_B_WARN_DETAIL_SEQ.nextval, v_id, sysdate, v_condCode,
             v_warnType, v_warnLevel, p_warnSrc, v_preMoney, v_tradeMoney,
             v_accBalance, v_remark);

    end loop;

    close v_c;
end;
/
show errors

-- �����嵥���
create or replace procedure SP_WA_Monitor_Detail
(
    p_dealDate char,    -- YYYYMMDD, ��������
    p_amount   in out int -- ����澯������
)
as
    v_month     char(2) := substr(p_dealDate, 5, 2);
begin
    
    -- �Ե��������嵥���������(�ų�������ҵ01)
    SP_WA_UpdateWarn(
        'select t.ID, t.CARDNO, t.PREMONEY, t.TRADEMONEY, null, null,
                b.WARNTYPE, b.WARNLEVEL, b.REMARK
        from   TF_TRADE_RIGHT_' || v_month || ' t, TF_B_WARN_BLACK b
        where  t.DEALTIME >= to_date(''' || p_dealDate || ''', ''yyyymmdd'')
        and    t.DEALTIME <  to_date(''' || p_dealDate || ''', ''yyyymmdd'') + 1
        and    t.CALLINGNO <> ''01''
        and    t.CARDNO    = b.CARDNO
        order by t.CARDNO, t.CARDTRADENO',
        '1', 1, p_amount
    );

    -- �ӵ��տ�����ʱ����ɾ���Ѿ��ں������д�����ϵĿ���
    delete from TMP_WARN_TODAYCARDS1
    where CARDNO in (SELECT CARDNO from TF_B_WARN_BLACK);

    -- ��ʣ�µĵ��տ��Ž��м�������Ĵ���
    for v_c in
    (
        select distinct t.CONDCODE, w.CONDSTR
        from   TF_B_WARN_MONITOR t, TD_M_WARNCOND w
        where  t.CARDNO in (select CARDNO from TMP_WARN_TODAYCARDS1)
        and    t.CONDCODE = w.CONDCODE
        and    w.CONDCATE = '1'
    )
    loop
        SP_WA_UpdateWarn (
            'select t.ID, t.CARDNO, t.PREMONEY, t.TRADEMONEY, null, b.CONDCODE,
                    b.WARNTYPE, b.WARNLEVEL, b.REMARK
            from   TF_TRADE_RIGHT_' || v_month || ' t, TF_B_WARN_MONITOR b, TMP_WARN_TODAYCARDS1 c
            where  t.DEALTIME >= to_date(''' || p_dealDate || ''', ''yyyymmdd'')
            and    t.DEALTIME <  to_date(''' || p_dealDate || ''', ''yyyymmdd'') + 1
            and    b.CONDCODE = ''' || v_c.CONDCODE || '''
            and    t.CARDNO    = b.CARDNO
            and    t.CARDNO    = c.CARDNO
            and    ' || v_c.CONDSTR || '
            order by t.CARDNO, t.CARDTRADENO',
            '1', 2, p_amount
        );
    end loop;

    -- �ӵ����嵥��ʱ����ɾ���Ѿ��ڼ�������д�����ϵĿ���
    delete from TMP_WARN_TODAYCARDS1 where CARDNO in
        (select t.CARDNO from TF_B_WARN_MONITOR t, TD_M_WARNCOND c
         where t.CONDCODE = c.CONDCODE and c.CONDCATE = '1');

    -- ��ʣ�µĵ��տ��Ž���ȫ�������Ĵ���
    for v_c in
    (
        select w.CONDCODE, w.CONDSTR
        from   TD_M_WARNCOND w
        where  w.CONDRANGE = '0'
        and    w.CONDCATE  = '1'
    )
    loop
        SP_WA_UpdateWarn(
            'select t.ID, t.CARDNO, t.PREMONEY, t.TRADEMONEY, null, b.CONDCODE,
                    b.WARNTYPE, b.WARNLEVEL, b.REMARK
            from   TF_TRADE_RIGHT_' || v_month || ' t, TD_M_WARNCOND b, TMP_WARN_TODAYCARDS1 c
            where  t.DEALTIME >= to_date(''' || p_dealDate || ''', ''yyyymmdd'')
            and    t.DEALTIME <  to_date(''' || p_dealDate || ''', ''yyyymmdd'') + 1
            and    t.CARDNO    = c.CARDNO
            and    b.CONDCODE = ''' || v_c.CONDCODE || '''
            and    ' || v_c.CONDSTR || '
            order by t.CARDNO, t.CARDTRADENO',
            '1', 0, p_amount
        );
    end loop;
end;
/
show errors

-- �˻����
create or replace procedure SP_WA_Monitor_Accout
(
    p_amount   in out int    -- ����澯������
)
as
begin
    -- �˻���ز�ʹ�ú�����

    -- �ӵ��տ�����ʱ����ɾ���Ѿ��ں������д�����ϵĿ���
    delete from TMP_WARN_TODAYCARDS2
    where CARDNO in (SELECT CARDNO from TF_B_WARN_BLACK);

    -- �Ե��տ��Ž��м�������Ĵ���
    for v_c in
    (
        select distinct t.CONDCODE, w.CONDSTR
        from   TF_B_WARN_MONITOR t, TD_M_WARNCOND w
        where  t.CARDNO in (select CARDNO from TMP_WARN_TODAYCARDS2)
        and    t.CONDCODE = w.CONDCODE
        and    w.CONDCATE = '0'
    )
    loop
        SP_WA_UpdateWarn (
            'select null, t.CARDNO, null, null, t.CARDACCMONEY, b.CONDCODE,
                   b.WARNTYPE, b.WARNLEVEL, b.REMARK
            from   TF_F_CARDEWALLETACC t, TF_B_WARN_MONITOR b,
                   TMP_WARN_TODAYCARDS2 c
            where  b.CONDCODE = ''' || v_c.CONDCODE || '''
            and    t.CARDNO    = b.CARDNO
            and    t.CARDNO    = c.CARDNO
            and    ' || v_c.CONDSTR || '
            order by t.CARDNO',
            '0', 2, p_amount
        );
    end loop;

    -- �ӵ����嵥��ʱ����ɾ���Ѿ��ڼ�������д�����ϵĿ���
    delete from TMP_WARN_TODAYCARDS2 where CARDNO in
        (select t.CARDNO from TF_B_WARN_MONITOR t, TD_M_WARNCOND c
         where  t.CONDCODE = c.CONDCODE and c.CONDCATE = '0');

    -- ��ʣ�µĵ��տ��Ž���ȫ�������Ĵ���
    for v_c in
    (
        select w.CONDCODE, w.CONDSTR from TD_M_WARNCOND w
        where  w.CONDRANGE = '0' and  w.CONDCATE  = '0'
    )
    loop
        SP_WA_UpdateWarn(
            'select null, t.CARDNO, null, null, t.CARDACCMONEY, b.CONDCODE,
                    b.WARNTYPE, b.WARNLEVEL, b.REMARK
            from TF_F_CARDEWALLETACC t, TD_M_WARNCOND b, TMP_WARN_TODAYCARDS2 c
            where  t.CARDNO    = c.CARDNO
            and    b.CONDCODE = ''' || v_c.CONDCODE || '''
            and    ' || v_c.CONDSTR || '
            order by t.CARDNO',
            '0', 0, p_amount
        );
    end loop;
end;
/
show errors

-- �嵥��غ��˻����
create or replace procedure SP_WA_Monitor
(
    p_retCode        OUT INT,
    p_retMsg         OUT VARCHAR2
)
as
    v_taskState      TF_B_WARN_TASK.TASKSTATE%type;
    v_amount         int := 0;
    v_cardscnt       int;
begin
    -- �鿴���������Ƿ��Ѿ�����
    begin
        select TASKSTATE into v_taskState from TF_B_WARN_TASK
        where  TASKDAY = to_char(sysdate - 2, 'YYYYMMDD');
    exception
        when no_data_found then -- û�����ɣ�����֮
            insert into TF_B_WARN_TASK(TASKDAY)
            values (to_char(sysdate - 2, 'YYYYMMDD'));
        when others then
            p_retCode := sqlcode; p_retMsg  := lpad(sqlerrm, 120);
            rollback; return;
    end;

    for v_c in (select ROWID, TASKSTATE, TASKDAY
            from TF_B_WARN_TASK where TASKSTATE = 0)
    loop
        -- ���õ����嵥��ʱ��
        delete from TMP_WARN_TODAYCARDS1;
        
        execute immediate '
        insert into TMP_WARN_TODAYCARDS1
        select distinct CARDNO from TF_TRADE_RIGHT_' || substr(v_c.TASKDAY, 5, 2) || ' t
        where t.DEALTIME >= to_date(''' || v_c.TASKDAY  || ''', ''yyyymmdd'')
        and   t.DEALTIME <  to_date(''' || v_c.TASKDAY  || ''', ''yyyymmdd'') + 1';
        
        v_cardscnt := SQL%ROWCOUNT;

        delete from TMP_WARN_TODAYCARDS2;
        insert into TMP_WARN_TODAYCARDS2
        select CARDNO from TMP_WARN_TODAYCARDS1;

        update TF_B_WARN_TASK
        set    TASKSTATE      = 1      ,  -- ����ʼ����
               STARTTIME      = sysdate,  -- ��ʼ����ʱ��
               TRADESTARTTIME = sysdate   -- �����嵥��ؿ�ʼ����ʱ��
        where  rowid          = v_c.ROWID;

        commit;

        p_retCode := 0; p_retMsg  := '';

        begin
            v_amount := 0;
            -- �����嵥���
            SP_WA_Monitor_Detail(v_c.TASKDAY, v_amount);
        exception when others then
            rollback;
            p_retCode := sqlcode; p_retMsg  := lpad(sqlerrm, 120);
        end;

        update TF_B_WARN_TASK
        set    CARDSCNT     = v_cardscnt,
               TRADEENDTIME = sysdate  ,  -- �����嵥��ؽ�������
               TRADEWARNSCNT= v_amount ,
               TRADERETCODE = p_retCode,  -- �����嵥������з�����
               TRADERETMSG  = p_retMsg ,  -- ������Ϣ
               ACCSTARTTIME = sysdate     -- �˻���ؿ�ʼ����ʱ��
        where  rowid        = v_c.ROWID;
        commit;

        p_retCode := 0; p_retMsg  := '';

        begin
           v_amount := 0;
           -- �˻����
           SP_WA_Monitor_Accout(v_amount);
        exception when others then
            rollback;
            p_retCode := sqlcode; p_retMsg  := lpad(sqlerrm, 120);
        end;

        update TF_B_WARN_TASK
        set    ACCENDTIME = sysdate  ,    -- �˻�������н���ʱ��
               ACCWARNSCNT= v_amount ,
               ACCRETCODE = p_retCode,    -- �˻�������з�����
               ACCRETMSG  = p_retMsg ,    -- �˻�������з�����Ϣ
               ENDTIME    = sysdate  ,    -- ������н���ʱ��
               TASKSTATE  = 2             -- ��������״̬Ϊ�����
        where  rowid        = v_c.ROWID;

        commit;
    end loop;

    p_retCode := 0; p_retMsg  := 'OK';
end;
/
show errors

create or replace procedure SP_WA_TaskCreate
(
    p_beginDate    char    ,
    p_endDate      char    ,
    p_currOper     char    ,
    p_currDept     char    ,
    p_retCode  out char    ,
    p_retMsg   out varchar2
)
as
    v_beginDate  date := to_date(p_beginDate, 'YYYYMMDD');
    v_endDate    date := to_date(p_endDate, 'YYYYMMDD');
begin
    loop
        exit when v_beginDate > v_endDate;

        merge into TF_B_WARN_TASK t
        using dual
        on (t.TASKDAY = to_char(v_beginDate, 'YYYYMMDD'))
        when matched then
            update set
                t.TASKSTATE     = 0   , t.CARDSCNT      = 0   ,
                t.STARTTIME     = null, t.ENDTIME       = null,
                t.TRADESTARTTIME= null, t.TRADEENDTIME  = null,
                t.TRADEWARNSCNT = null, t.TRADERETCODE  = null,
                t.TRADERETMSG   = null, t.ACCSTARTTIME  = null,
                t.ACCENDTIME    = null, t.ACCWARNSCNT   = null,
                t.ACCRETCODE    = null, t.ACCRETMSG     = null
        when not matched then
            insert(TASKDAY) values (to_char(v_beginDate, 'YYYYMMDD'))
        ;

        v_beginDate := v_beginDate + 1;
    end loop;

    p_retCode := '0000000000'; p_retMsg  := '';
    commit; return;

exception when others then
    p_retCode := sqlcode;
    p_retMsg  := lpad(sqlerrm, 120);
    rollback; return;
end;
/
show errors

-- ��̬�˻����
create or replace procedure SP_WA_Monitor_Static_Accout
(
    p_amount   in out int  , -- ����澯������
    p_currOper     char    ,
    p_currDept     char    ,
    p_retCode  out char    ,
    p_retMsg   out varchar2
)
as
begin
    if p_amount is null then p_amount := 0; end if;

    -- �����п��Ž��м�������Ĵ���
    for v_c in
    (
        select distinct t.CONDCODE, w.CONDSTR
        from   TF_B_WARN_MONITOR t, TD_M_WARNCOND w
        where  t.CONDCODE = w.CONDCODE
        and    w.CONDCATE = '0'
    )
    loop
        SP_WA_UpdateWarn (
            'select null, t.CARDNO, null, null, t.CARDACCMONEY, b.CONDCODE,
                   b.WARNTYPE, b.WARNLEVEL, b.REMARK
            from   TF_F_CARDEWALLETACC t, TF_B_WARN_MONITOR b
            where  b.CONDCODE = ''' || v_c.CONDCODE || '''
            and    t.CARDNO    = b.CARDNO
            and    ' || v_c.CONDSTR || '
            order by t.CARDNO',
            '0', 2, p_amount
        );
    end loop;

    -- ��ʣ�µĿ��Ž���ȫ�������Ĵ���
    for v_c in
    (
        select w.CONDCODE, w.CONDSTR from TD_M_WARNCOND w
        where  w.CONDRANGE = '0' and  w.CONDCATE  = '0'
    )
    loop
        SP_WA_UpdateWarn(
            'select null, t.CARDNO, null, null, t.CARDACCMONEY, b.CONDCODE,
                    b.WARNTYPE, b.WARNLEVEL, b.REMARK
            from TF_F_CARDEWALLETACC t, TD_M_WARNCOND b
            where  t.CARDNO not in (
                select x.CARDNO
                from TF_B_WARN_MONITOR x, TD_M_WARNCOND y
                where x.CONDCODE = y.CONDCODE
                and   y.CONDCATE = ''0''
                )
            and    b.CONDCODE = ''' || v_c.CONDCODE || '''
            and    ' || v_c.CONDSTR || '
            order by t.CARDNO',
            '0', 0, p_amount
        );
    end loop;

    p_retCode := '0000000000'; p_retMsg  := '';
    commit; return;

exception when others then
    p_retCode := sqlcode;
    p_retMsg  := lpad(sqlerrm, 120);
    rollback; return;
end;
/
show errors
