create or replace procedure SP_WA_WarnCond
(
    p_funcCode     varchar2,
    p_oldCondCode  char    ,
    p_condCode     char    ,
    p_condName     varchar2,
    p_condRange    int     ,
    p_warnType     varchar2,
    p_warnLevel    int     ,
    p_condCate     int     ,
    p_condStr      varchar2,
    p_remark       varchar2,

    p_currOper     char    ,
    p_currDept     char    ,
    p_retCode  out char    ,
    p_retMsg   out varchar2
)
as
    v_int          int;
begin
    -- ����������Ƿ�Ϸ�
    if p_funcCode in ('Add', 'Mod') then
        begin
            if p_condCate = 0 then
                execute immediate '
                select 1
                from TF_F_CARDEWALLETACC t
                where 1 > 2 and ' || p_condStr
                into v_int;
            elsif p_condCate = 1 then
                execute immediate '
                select 1
                from TQ_TRADE_RIGHT t
                where 1 > 2 and ' || p_condStr
                into v_int;
            else
                raise_application_error(-20101, 
                    '�������ȡֵ' || p_condCate ||  '�Ƿ�');
            end if;
        exception when no_data_found then null;
        end;
    end if;

    if p_funcCode = 'Del' or 
        (p_funcCode = 'Mod' and p_oldCondCode != p_condCode)
    then
        begin
            select 1 into   v_int
            from   TF_B_WARN_MONITOR
            where  CONDCODE = p_oldCondCode;

            raise_application_error(-20102, 
                '�������뵱ǰ���ڼ��������ʹ�ã����ܱ�ɾ��');
        exception when no_data_found then null;
        end;
    end if;

    if p_funcCode = 'Add' then
        insert into TD_M_WARNCOND(CONDCODE, CONDNAME, CONDRANGE, WARNLEVEL, WARNTYPE,
            CONDCATE, CONDSTR, UPDATESTAFFNO, UPDATETIME, REMARK)
        values (p_condCode, p_condName, p_condRange, p_warnLevel, p_warnType,
            p_condCate, p_condStr, p_currOper, sysdate, p_remark);
    elsif p_funcCode = 'Mod' then
        update TD_M_WARNCOND
        set    CONDCODE     = p_condCode ,
               CONDNAME     = p_condName ,
               CONDRANGE    = p_condRange,
               WARNTYPE     = p_warnType ,
               WARNLEVEL    = p_warnLevel,
               CONDCATE     = p_condCate ,
               CONDSTR      = p_condStr ,
               UPDATESTAFFNO= p_currOper ,
               UPDATETIME   = sysdate    ,
               REMARK       = p_remark   
        where  CONDCODE     = p_oldCondCode;
        if SQL%ROWCOUNT != 1 then
            raise_application_error(-20103, 
                '���¼����������Ч��������1');
        end if;
    elsif p_funcCode = 'Del' then
        delete from TD_M_WARNCOND
        where  CONDCODE = p_oldCondCode;
        if SQL%ROWCOUNT != 1 then
            raise_application_error(-20104, 
                'ɾ�������������Ч��������1');
        end if;
    end if;


    p_retCode := '0000000000'; p_retMsg  := '';
    commit; return;

exception when others then
    p_retCode := sqlcode;
    p_retMsg  := sqlerrm;
    rollback; return;
end;

/

show errors

