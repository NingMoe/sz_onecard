create or replace procedure SP_SD_FillBalUnit
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
    
    v_row             TF_TRADE_ERROR_01%rowtype;
    v_sourceidlast    td_m_trade_source.sourcecode%type := null;
    v_posnolast       tf_trade_error_01.posno%type := null;

    v_balunitno       tf_trade_balunit.balunitno%type;
    v_callingno       tf_trade_balunit.callingno%type;
    v_corpno          tf_trade_balunit.corpno%type;
    v_departno        tf_trade_balunit.departno%type;

begin
    -- 从清单表中查询出POS号，来源识别号以及ROWID
    v_sqlstr1 := '
        select te.*
        from   ' || p_errtablename || ' te, TMP_COMMON tm
        where  tm.f0 = te.ID
        and    (te.BALUNITNO is null or te.BALUNITNO = ''NOTFOUND'')
    ';
    -- 更新异常消费清单表字段
    v_sqlstr2 := '
        update ' || p_errtablename || '
        set   balunitno = :1, callingno = :2, 
              corpno    = :3, departno  = :4
        where id        = :5
    ';

    -- 首先以SOURCEID号排序
    open v_cur for v_sqlstr1 || ' order by SOURCEID';
    loop
        fetch v_cur into v_row;
        exit when v_cur%NOTFOUND;

        if (v_sourceidlast is null or v_sourceidlast != v_row.sourceid) then
            begin
                if (p_balUnitNo is null) then -- 自动补结算单元
                    -- 从来源识别表中根据来源识别号来反查出BalUnitNO
                    select tf.balunitno, tf.callingno, tf.corpno, tf.departno
                    into   v_balunitno, v_callingno, v_corpno, v_departno
                    from   tf_trade_balunit tf, td_m_trade_source tm
                    where  tm.balunitno  = tf.balunitno
                    and    tm.usetag     = '1'
                    and    tm.sourcecode = v_row.sourceid;
                else-- 手工补结算单元
                    -- 从“资源库存操作台账表”中查找可能存在过的来源识别与指定的BalUnitNo
                    select tf.balunitno, tf.callingno, tf.corpno, tf.departno
                    into   v_balunitno, v_callingno, v_corpno, v_departno
                    from   tf_trade_balunit tf, TF_R_STOCKRESOURCESTRADE tr
                    where  tr.SAMNO     = v_row.sourceid
                    and    tr.BALUNITNO = p_balUnitNo
                    and    tf.BALUNITNO = p_balUnitNo
                    and    rownum      <= 1;
                end if;
            exception
                when too_many_rows or no_data_found then 
                    v_balunitno := null; -- 没有找到对应的结算单元
            end;

            v_sourceidlast := v_row.sourceid;
        end if;

        if v_balunitno is not null then 
            --找到对应的BalUnitNo，更新当前记录
            execute immediate v_sqlstr2 
            using v_balunitno, v_callingno, v_corpno, v_departno, v_row.id;

            v_updNum :=  v_updNum + SQL%ROWCOUNT;
            
            if sql%rowcount > 0 then
                SP_GetSeq(seq => v_seqNo);

                INSERT INTO TF_B_TRADE_MANUAL( --记录补结算单元台帐
                    TRADEID, ID, CARDNO, RECTYPE, ICTRADETYPECODE, ASN, CARDTRADENO,
                    SAMNO, PSAMVERNO, POSNO, POSTRADENO, TRADEDATE, TRADETIME,
                    PREMONEY, TRADEMONEY, SMONEY, BALUNITNO,TRADECOMFEE,
                    CALLINGNO, CORPNO, DEPARTNO, CALLINGSTAFFNO, CITYNO, TAC,
                    TACSTATE, MAC, SOURCEID, BATCHNO, DEALTIME, ERRORREASONCODE,
                    RENEWTIME, RENEWSTAFFNO,
                    DEALSTATECODE, RENEWTYPECODE, RENEWSTATECODE)
                VALUES(v_seqNo, v_row.ID, v_row.CARDNO, v_row.RECTYPE, v_row.ICTRADETYPECODE, v_row.ASN, v_row.CARDTRADENO,
                    v_row.SAMNO, v_row.PSAMVERNO, v_row.POSNO, v_row.POSTRADENO, v_row.TRADEDATE, v_row.TRADETIME,
                    v_row.PREMONEY, v_row.TRADEMONEY, v_row.SMONEY, v_balunitno, 0,
                    v_callingno, v_corpno, v_departno, v_row.CALLINGSTAFFNO, v_row.CITYNO, v_row.TAC,
                    v_row.TACSTATE, v_row.MAC, v_row.sourceid, v_row.BATCHNO, v_row.DEALTIME, v_row.ERRORREASONCODE,
                    v_today, p_currOper,
                    '0', '1', nvl2(p_balUnitNo, '3', '4'));
            end if;
        end if;
    end loop;
    close v_cur;

	--相关变量置为空，自动补全结算单元时，没有找到结算单元的，会被找到结算单元的赋值，导致补全错误 wdx 20130308。
	v_balunitno:=null;
	v_callingno:=null;
	v_corpno:=null;
	v_departno:=null;
	
	
	
    -- 根据PosNo排序，查询剩下的还没有找到BalUnitNo的记录
    open v_cur for v_sqlstr1 || ' order by POSNO';
    loop
        fetch v_cur 
        into  v_row;

        exit when v_cur%NOTFOUND;

        if (v_posnolast is null or v_posnolast != v_row.posno) then
            begin
                -- 自动补充结算单元只到来源识别表，不再到PSAM,POS,BALUNIT三方关系表去找
                -- 因为PSAM可能对应到多个结算单元（如 中石化PSAM共用），但是在设备关系表中
                -- 一个PSAM只对应到其中的一个结算单元
                
                if (p_balUnitNo is  not null) then -- 手工补结算单元
                    -- 根据PosNo到设备结算关系表中找对应的SamNo，然后再根据SamNo在
                    -- 来源识别表中去找对应的结算单元
                    select tf.balunitno, tf.callingno, tf.corpno, tf.departno
                    into   v_balunitno, v_callingno, v_corpno, v_departno
                    from   tf_trade_balunit tf, TF_R_PSAMPOSREC tp
                    where  tp.POSNO     = v_row.posno
                    and    tp.balunitno = tf.balunitno
                    and    rownum      <= 1;
                end if;
            exception when no_data_found then v_balunitno :=null;
            end;
            
            begin
                if (p_balUnitNo is  not null and v_balunitno is null) then -- 手工补结算单元 
                    -- 在资源库存操作台账表中查找可能存在过的PosNo和BalUnitNo
                    select tf.balunitno, tf.callingno, tf.corpno, tf.departno
                    into   v_balunitno, v_callingno, v_corpno, v_departno
                    from   tf_trade_balunit tf, TF_R_STOCKRESOURCESTRADE tr
                    where  tr.POSNO     = v_row.posno
                    and    tr.BALUNITNO = p_balUnitNo
                    and    tf.BALUNITNO = p_balUnitNo
                    and    rownum      <= 1;
                end if;
            exception when no_data_found then v_balunitno := null; -- 没有找到结算单元
            end;


            v_posnolast := v_row.posno;
        end if;

        if v_balunitno is not null then 
            --找到对应的BalUnitNo，更新当前记录
            execute immediate v_sqlstr2 
            using v_balunitno, v_callingno, v_corpno, v_departno, v_row.id;

            v_updNum :=  v_updNum + SQL%ROWCOUNT;
            if sql%rowcount > 0 then
                SP_GetSeq(seq => v_seqNo);

                INSERT INTO TF_B_TRADE_MANUAL( --记录补结算单元台帐
                    TRADEID, ID, CARDNO, RECTYPE, ICTRADETYPECODE, ASN, CARDTRADENO,
                    SAMNO, PSAMVERNO, POSNO, POSTRADENO, TRADEDATE, TRADETIME,
                    PREMONEY, TRADEMONEY, SMONEY, BALUNITNO,TRADECOMFEE,
                    CALLINGNO, CORPNO, DEPARTNO, CALLINGSTAFFNO, CITYNO, TAC,
                    TACSTATE, MAC, SOURCEID, BATCHNO, DEALTIME, ERRORREASONCODE,
                    RENEWTIME, RENEWSTAFFNO,
                    DEALSTATECODE, RENEWTYPECODE, RENEWSTATECODE)
                VALUES(v_seqNo, v_row.ID, v_row.CARDNO, v_row.RECTYPE, v_row.ICTRADETYPECODE, v_row.ASN, v_row.CARDTRADENO,
                    v_row.SAMNO, v_row.PSAMVERNO, v_row.POSNO, v_row.POSTRADENO, v_row.TRADEDATE, v_row.TRADETIME,
                    v_row.PREMONEY, v_row.TRADEMONEY, v_row.SMONEY, v_balunitno, 0,
                    v_callingno, v_corpno, v_departno, v_row.CALLINGSTAFFNO, v_row.CITYNO, v_row.TAC,
                    v_row.TACSTATE, v_row.MAC, v_row.sourceid, v_row.BATCHNO, v_row.DEALTIME, v_row.ERRORREASONCODE,
                    v_today, p_currOper,
                    '0', '1', nvl2(p_balUnitNo, '3', '4'));
            end if;        end if;
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
