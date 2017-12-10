create or replace procedure SP_GC_Fee2Deposit
(   -- 卡费转成卡押金
    -- 当日操作，应该没有问题
    -- 往日操作，手工输入需扣减押金金额，由系统进行扣减
    p_fromCardNo     char,  -- 开始卡号
    p_toCardNo       char,  -- 结束卡号
    p_deductionMoney int ,  -- 扣减金额

    p_currOper       char,
    p_currDept       char,
    p_retCode    out char,    -- Return Code
    p_retMsg     out varchar2 -- Return Message
)
as
    v_sellDate       date;
    v_today          date := trunc(sysdate, 'DD');
    v_now            date := sysdate;
    v_int            int;
    v_tradeTypeCode constant char(2) := '60';
    v_seqNo          char(16);
begin

    -- 检查号段的售卡日期是否相同
    begin
        select distinct trunc(t.selltime, 'DD')
        into v_sellDate
        from tf_f_cardrec t
        where t.cardno between p_fromCardNo and p_toCardNo;
    exception
        when no_data_found then
            raise_application_error(-20101, '卡号段不存在于卡资料表中');
        when too_many_rows then
            raise_application_error(-20102, '卡号段售卡日期不一致');
    end;

    -- 判断输入"扣减金额"是否>0(界面上判断完毕)并且<=卡费
    begin
        select 1 into v_int
        from tf_f_cardrec t
        where t.cardno between p_fromCardNo and p_toCardNo
        and   (t.cardcost = 0 or t.cardcost < p_deductionMoney);

        raise_application_error(-20103, '存在某张卡片卡费为0，或者卡费低于扣减金额');
    exception when no_data_found then null;
    end;

    SP_GetSeq(seq => v_seqNo);
	
    begin
    insert into tf_b_trade(tradeid, tradetypecode, cardno, asn, cardtypecode,
        deposit, currentmoney, operatestaffno, operatedepartid, operatetime)
    select v_seqno, v_tradetypecode, cardno, asn, cardtypecode,
        cardcost, p_deductionMoney, p_curroper, p_currdept, v_now
    from tf_f_cardrec
    where cardno between p_fromCardNo and p_toCardNo;
	exception 
	    when others then
		    p_retCode := 'S094570235';
            p_retMsg  := 'Fail to log the operation,' || SQLERRM;
            ROLLBACK; RETURN;
	end;

	begin
    update tf_f_cardrec t
    set t.deposit = t.cardcost,
        t.servicemoney = p_deductionMoney, -- 实收服务费为扣减金额
        -- 如果扣减金额=0，serstaketag不变
        -- 如果扣减金额=卡费，设置serstaketag为3,表示已经扣完（不再收取）
        -- 否则改为1，表示”继续周期性收取押金“
        t.serstaketag = decode(p_deductionMoney, 0, t.serstaketag, t.cardcost, '3', '1'),
        t.cardcost = 0,
        t.updatestaffno = p_currOper,
        t.updatetime = v_now
    where t.cardno between p_fromCardNo and p_toCardNo;
	exception 
	    when others then
		    p_retCode := 'S094570236';
            p_retMsg  := 'Fail to change cardcost,' || SQLERRM;
            ROLLBACK; RETURN;
    end;			
	
    BEGIN
        UPDATE TL_R_ICUSER
        SET    SALETYPE = '02' --deposit
        WHERE  CARDNO BETWEEN p_fromCardNo AND p_toCardNo;
               
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570234';
            p_retMsg  := 'Fail to change saletype,' || SQLERRM;
            ROLLBACK; RETURN;
    END;		

    p_retCode := '0000000000'; p_retMsg  := '';
    commit; return;

exception when others then
    p_retcode := sqlcode;
    p_retMsg  := rpad(sqlerrm, 127);
    rollback; return;
end;
/

show errors
