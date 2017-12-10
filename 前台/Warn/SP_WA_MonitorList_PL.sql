create or replace procedure SP_WA_MonitorList
(
    p_funcCode     varchar2,
    p_seqNo        char    ,
    p_cardNo       char    ,
    p_condCode     char    ,
    p_warnType     char    ,
    p_warnLevel    int     ,
    
    p_remark       varchar2,

    p_currOper     char    ,
    p_currDept     char    ,
    p_retCode  out char    ,
    p_retMsg   out varchar2
)
as
    v_int          numeric;
    v_today        date := sysdate;
begin
    -- ����ʻ���Ч��
    -- if p_funcCode != 'Del' then
    --     begin
    --         SP_AccCheck(p_cardNo, p_currOper, p_currDept, p_retCode, p_retMsg);
    --         if p_retCode != '0000000000' then raise v_ex; end if;
    --     exception when others then
    --         rollback; return;
    --     end;
    -- end if;
    
    if p_funcCode in ('Add', 'Mod') then
        begin
            select 1 into v_int from TF_B_WARN_BLACK t where t.CARDNO = p_cardNo;
            raise_application_error(-20101, 
                '�����Ѿ������ں�����֮�У��������ټӵ����������' );
        exception when no_data_found then null;
        end;
    end if;

    v_int := p_seqNo;
    -- ����������
    if p_funcCode = 'Add' then
        insert into TF_B_WARN_MONITOR(SEQNO, CARDNO, CREATETIME, CONDCODE, WARNTYPE, 
            WARNLEVEL, UPDATESTAFFNO, UPDATETIME, REMARK)
        values (TF_B_WARN_MONITOR_SEQ.nextval, p_cardNo, v_today, p_condCode, p_warnType,
            p_warnLevel, p_currOper, v_today, p_remark)
        returning SEQNO into v_int;
    end if;

    -- ���ɱ���̨��
    insert into TH_B_WARN_MONITOR(HSEQNO, BACKTIME, BACKSTAFF, 
        BACKWHY, 
        BACKREMARK, SEQNO, CARDNO, CREATETIME, CONDCODE, WARNTYPE, 
            WARNLEVEL, UPDATESTAFFNO, UPDATETIME, REMARK)
    select TH_B_WARN_MONITOR_SEQ.nextval, v_today, p_currOper, 
        decode(p_funcCode, 'Del', 3, 'Mod', 4, 'Add', 5),
        null, SEQNO, CARDNO, CREATETIME, CONDCODE, WARNTYPE, 
            WARNLEVEL, UPDATESTAFFNO, UPDATETIME, REMARK 
    from TF_B_WARN_MONITOR
    where SEQNO = v_int;
        
    
    -- �޸ĺ�����
    if p_funcCode = 'Mod' then
        update TF_B_WARN_MONITOR
        set    CONDCODE     = p_condCode,
               WARNTYPE     = p_warnType,
               WARNLEVEL    = p_warnLevel,
               UPDATESTAFFNO= p_currOper ,
               UPDATETIME   = v_today    ,
               REMARK       = p_remark   
        where  SEQNO        = p_seqNo;
            
        if SQL%ROWCOUNT != 1 then 
            raise_application_error(-20102, 
                '��Ч�޸�������Ϊ1' );
        end if;
        
    -- ɾ��������
    elsif p_funcCode = 'Del' then
        delete from TF_B_WARN_MONITOR
        where  SEQNO = p_seqNo;
        if SQL%ROWCOUNT != 1 then
            raise_application_error(-20103, 
                '��Чɾ��������Ϊ1' );
        end if;
    end if;
    
    p_retCode := '0000000000';
    p_retMsg  := '';
    commit; return;

exception when others then
    p_retcode := sqlcode;
    p_retmsg  := sqlerrm;
    rollback; return;
end;

/
show errors

