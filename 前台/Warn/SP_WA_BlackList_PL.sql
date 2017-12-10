create or replace procedure SP_WA_BlackList
(
    p_funcCode     varchar2,
    p_oldCardNo    char    ,
    p_cardNo       char    ,
    p_warnType     char    ,
    p_warnLevel    int     ,
    
    p_remark       varchar2,

    p_currOper     char    ,
    p_currDept     char    ,
    p_retCode  out char    ,
    p_retMsg   out varchar2
)
as
    v_int          int;
    v_today        date := sysdate;
begin
    -- ����ʻ���Ч��
    -- begin
    --     SP_AccCheck(p_cardNo, p_currOper, p_currDept, p_retCode, p_retMsg);
    --     if p_retCode != '0000000000' then raise v_ex; end if;
    -- exception when others then
    --     rollback; return;
    -- end;
    if p_funcCode in ('Add', 'Mod') then
        begin
            select 1 into v_int from TF_B_WARN_MONITOR t where t.CARDNO = p_cardNo;
            raise_application_error(-20101, 
                '�����Ѿ������ڼ������֮�У����������ں�������' );
        exception when no_data_found then null;
        end;
    end if;

    -- ����������
    if p_funcCode = 'Add' then
        insert into TF_B_WARN_BLACK(CARDNO, CREATETIME, WARNTYPE, 
            WARNLEVEL, UPDATESTAFFNO, UPDATETIME, DOWNTIME, REMARK)
        values (p_cardNo, v_today, p_warnType,
            p_warnLevel, p_currOper, v_today, null, p_remark);
    end if;

    -- ���ɱ���̨��
    insert into TH_B_WARN_BLACK(HSEQNO, BACKTIME, BACKSTAFF, 
        BACKWHY, 
        BACKREMARK, CARDNO, CREATETIME, WARNTYPE, WARNLEVEL, UPDATESTAFFNO,
        UPDATETIME, DOWNTIME, REMARK)
    select TH_B_WARN_BLACK_SEQ.nextval, v_today, p_currOper, 
        decode(p_funcCode, 'Del', 3, 'Mod', 4, 'Add', 5),
        null, CARDNO,CREATETIME, WARNTYPE, WARNLEVEL, UPDATESTAFFNO,
        UPDATETIME, DOWNTIME, REMARK 
    from TF_B_WARN_BLACK
    where CARDNO = p_cardNo;

    -- �޸ĺ�����
    if p_funcCode = 'Mod' then
        update TF_B_WARN_BLACK
        set    WARNTYPE     = p_warnType ,
               WARNLEVEL    = p_warnLevel,
               UPDATESTAFFNO= p_currOper ,
               UPDATETIME   = v_today    ,
               REMARK       = p_remark   ,
               CARDNO       = p_cardNo
        where  CARDNO       = p_oldCardNo;

        if SQL%ROWCOUNT != 1 then 
            raise_application_error(-20102, 
                '��Ч�޸�������Ϊ1' );
        end if;
    -- ɾ��������
    elsif p_funcCode = 'Del' then
        delete from TF_B_WARN_BLACK
        where  CARDNO = p_oldCardNo;
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

