create or replace procedure SP_PB_ChangeDbBalance
(
    p_cardNo     char,
    p_newBalance int,

    p_currOper   char,
    p_currDept   char,
    p_retCode    out char, -- Return Code
    p_retMsg     out varchar2  -- Return Message

)
as
    v_now                    date    := sysdate;
    v_tradeTypeCode constant char(2) := '61';
    v_seqNo                  char(16);
    v_int                    int;
begin
    -- 查询卡号是否已经有正在提交审核中的申请
    begin
        select 1 into v_int
        from TF_SPECIAL_CHNAGEBALANCE
        where CARDNO = p_cardNo 
        and CHECKSTATE = '0';
        
        raise_application_error(-20101, '当前卡号已经存在等待审核的修改余额申请，不允许再次申请');
    exception when no_data_found then null;
    end;

    SP_GetSeq(seq => v_seqNo);

    insert into tf_b_trade(tradeid, tradetypecode, cardno, asn, cardtypecode,
        operatestaffno, operatedepartid, operatetime, STATECODE, PREMONEY, CURRENTMONEY)
    select v_seqno, v_tradetypecode, rec.cardno, rec.asn, rec.cardtypecode,
        p_curroper, p_currdept, v_now, '0', acc.CARDACCMONEY, p_newBalance
    from tf_f_cardrec rec, TF_F_CARDEWALLETACC acc
    where rec.cardno = p_cardNo
    and   acc.cardno = p_cardNo;

    insert into TF_SPECIAL_CHNAGEBALANCE
        (TRADEID, CARDNO, PREBALANCE, NEWBALANCE, SUBMITSTAFF, SUBMITTIME, CHECKSTATE)
    select v_seqno, p_cardNo, CARDACCMONEY, p_newBalance, p_curroper, v_now, '0'
    from TF_F_CARDEWALLETACC
    where cardno = p_cardNo;

    p_retCode := '0000000000'; p_retMsg  := '';
    commit; return;

exception when others then
    p_retcode := sqlcode;
    p_retMsg  := rpad(sqlerrm, 127);
    rollback; return;
end;
/

show errors

