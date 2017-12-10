create or replace procedure SP_SD_XXFillBalUnit
(
    p_errtablename  char,
    p_balUnitNo     CHAR,
    p_currOper	    CHAR,
    p_currDept	    CHAR,
    p_retCode       OUT CHAR,
    p_retMsg        OUT VARCHAR2
)
as
    v_sqlstr1         varchar2(256);
    v_sqlstr2         varchar2(256);
    v_seqNo           CHAR(16);
    v_updNum          int := 0;
    v_cur             SYS_REFCURSOR;
    v_today           date := sysdate;
    
    v_row             TF_XXPARK_ERROR_01%rowtype;
    v_sourceidlast    td_m_trade_source.sourcecode%type := null;
    v_posnolast       tf_trade_error_01.posno%type := null;

    v_balunitno       tf_trade_balunit.balunitno%type;
    v_callingno       tf_trade_balunit.callingno%type;
    v_corpno          tf_trade_balunit.corpno%type;
    v_departno        tf_trade_balunit.departno%type;

begin
    -- ���嵥���в�ѯ��POS�ţ���Դʶ����Լ�ROWID
    v_sqlstr1 := '
        select te.*
        from   ' || p_errtablename || ' te, TMP_COMMON tm
        where  tm.f0 = te.ID
        and    (te.BALUNITNO is null or te.BALUNITNO = ''NOTFOUND'')
    ';
    -- �����쳣�����嵥���ֶ�
    v_sqlstr2 := '
        update ' || p_errtablename || '
        set   balunitno = :1, callingno = :2, 
              corpno    = :3, departno  = :4
        where id        = :5
    ';

    -- ������SAM������
    open v_cur for v_sqlstr1 || ' order by SAMNO';
    loop
        fetch v_cur into v_row;
        exit when v_cur%NOTFOUND;

        if (v_sourceidlast is null or v_sourceidlast != v_row.samno) then
            begin
                if (p_balUnitNo is null) then -- �Զ������㵥Ԫ
                    -- ����Դʶ����и�����Դʶ����������BalUnitNO
                    select tf.balunitno, tf.callingno, tf.corpno, tf.departno
                    into   v_balunitno, v_callingno, v_corpno, v_departno
                    from   tf_trade_balunit tf, td_m_trade_source tm
                    where  tm.balunitno  = tf.balunitno
                    and    tm.usetag     = '1'
                    and    tm.sourcecode = v_row.samno;
                else-- �ֹ������㵥Ԫ
                    -- �ӡ���Դ������̨�˱��в��ҿ��ܴ��ڹ�����Դʶ����ָ����BalUnitNo
                    select tf.balunitno, tf.callingno, tf.corpno, tf.departno
                    into   v_balunitno, v_callingno, v_corpno, v_departno
                    from   tf_trade_balunit tf, TF_R_STOCKRESOURCESTRADE tr
                    where  tr.SAMNO     = v_row.samno
                    and    tr.BALUNITNO = p_balUnitNo
                    and    tf.BALUNITNO = p_balUnitNo
                    and    rownum      <= 1;
                end if;
            exception when no_data_found then 
                v_balunitno := null; -- û���ҵ���Ӧ�Ľ��㵥Ԫ
            end;

            v_sourceidlast := v_row.samno;
        end if;

        if v_balunitno is not null then 
            --�ҵ���Ӧ��BalUnitNo�����µ�ǰ��¼
            execute immediate v_sqlstr2 
            using v_balunitno, v_callingno, v_corpno, v_departno, v_row.id;

            v_updNum :=  v_updNum + SQL%ROWCOUNT;
        end if;
    end loop;
    close v_cur;

    -- ����PosNo���򣬲�ѯʣ�µĻ�û���ҵ�BalUnitNo�ļ�¼
    open v_cur for v_sqlstr1 || ' order by POSNO';
    loop
        fetch v_cur 
        into  v_row;

        exit when v_cur%NOTFOUND;

        if (v_posnolast is null or v_posnolast != v_row.posno) then
            begin
                if (p_balUnitNo is null) then -- �Զ������㵥Ԫ
                    -- ����PosNo���豸�����ϵ�����Ҷ�Ӧ��SamNo��Ȼ���ٸ���SamNo��
                    -- ��Դʶ�����ȥ�Ҷ�Ӧ�Ľ��㵥Ԫ
                    select tf.balunitno, tf.callingno, tf.corpno, tf.departno
                    into   v_balunitno, v_callingno, v_corpno, v_departno
                    from   tf_trade_balunit tf, TF_R_PSAMPOSREC tp, td_m_trade_source tm
                    where  tp.POSNO     = v_row.posno
                    and    tp.SAMNO     = tm.sourcecode
                    and    tm.USETAG    = '1'
                    and    tm.balunitno = tf.balunitno;
                else-- �ֹ������㵥Ԫ
                    -- ����Դ������̨�˱��в��ҿ��ܴ��ڹ���PosNo��BalUnitNo
                    select tf.balunitno, tf.callingno, tf.corpno, tf.departno
                    into   v_balunitno, v_callingno, v_corpno, v_departno
                    from   tf_trade_balunit tf, TF_R_STOCKRESOURCESTRADE tr
                    where  tr.POSNO     = v_row.posno
                    and    tr.BALUNITNO = p_balUnitNo
                    and    tf.BALUNITNO = p_balUnitNo
                    and    rownum      <= 1;
                end if;
            exception when no_data_found then
                v_balunitno := null; -- û���ҵ����㵥Ԫ
            end;

            v_posnolast := v_row.posno;
        end if;

        if v_balunitno is not null then 
            --�ҵ���Ӧ��BalUnitNo�����µ�ǰ��¼
            execute immediate v_sqlstr2 
            using v_balunitno, v_callingno, v_corpno, v_departno, v_row.id;

            v_updNum :=  v_updNum + SQL%ROWCOUNT;
        end if;
    end loop;
    close v_cur;

    p_retCode := '0000000000';
    p_retMsg  := '' || v_updNum;
    COMMIT; RETURN;

EXCEPTION WHEN OTHERS THEN
    IF v_cur%ISOPEN THEN CLOSE v_cur; END IF;

    p_retCode := SQLCODE;
    p_retMsg  := SQLERRM;
    ROLLBACK; RETURN;

end;


/
show errors
