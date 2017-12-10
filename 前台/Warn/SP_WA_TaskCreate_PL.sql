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
        when not matched then
            insert(TASKDAY) values (to_char(v_beginDate, 'YYYYMMDD'))
        ;
		
		
		merge into TF_B_WARN_TASK_ANTI t
        using dual
        on (t.TASKDAY = to_char(v_beginDate, 'YYYYMMDD'))
        when not matched then
            insert(TASKDAY,TASKSTATE) values (to_char(v_beginDate, 'YYYYMMDD'),0);
		

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
