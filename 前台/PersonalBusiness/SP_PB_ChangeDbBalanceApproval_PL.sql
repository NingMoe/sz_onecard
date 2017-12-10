create or replace procedure SP_PB_ChangeDbBalanceApproval
(
    p_stateCode char, -- '2' Fi Approved, '3' Rejected

    p_currOper   char,
    p_currDept   char,
    p_retCode    out char, -- Return Code
    p_retMsg     out varchar2  -- Return Message

)
as
    v_now            date    := sysdate;
begin
    -- 1) Check the state code 
    if not (p_stateCode = '2' OR p_stateCode = '3') then
        raise_application_error(-20101, '状态码必须是''2'' (财务已审核) 或 ''3'' (作废)');
    end if;

    merge into TMP_COMMON tm
    using TF_SPECIAL_CHNAGEBALANCE tf
    on (tm.f0 = tf.tradeid)
    when matched then update set
        tm.f1 = tf.cardno,
        tm.f2 = tf.NEWBALANCE,
        tm.f3 = tf.PREBALANCE;

    merge into TF_SPECIAL_CHNAGEBALANCE tf
    using TMP_COMMON tm
    on (tf.tradeid = tm.f0)
    when matched then
        update set 
            tf.CHECKSTAFF = p_currOper,
            tf.CHECKTIME = v_now,
            tf.CHECKSTATE = p_stateCode,
            tf.CUSTNAME = tm.f4,
            tf.CONTACTWAY = tm.f5;

    if p_stateCode = '2' then
        merge into  TF_F_CARDEWALLETACC acc
        using TMP_COMMON tm
        on (acc.cardno = tm.f1)
        when matched then
            update set 
                acc.CARDACCMONEY = to_number(tm.f2);
    end if;

    merge into tf_b_trade tr
    using TMP_COMMON tm
    on (tr.tradeid = tm.f0)
    when matched then update
    set tr.STATECODE = p_stateCode,
        tr.CHECKSTAFFNO = p_currOper,
        tr.CHECKDEPARTNO = p_currDept,
        tr.CHECKTIME = v_now;

    p_retCode := '0000000000'; p_retMsg  := '';
    commit; return;

exception when others then
    p_retcode := sqlcode;
    p_retMsg  := rpad(sqlerrm, 127);
    rollback; return;
end;
/

show errors

