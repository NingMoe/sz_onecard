create or replace procedure SP_GC_Fee2Deposit
(   -- ����ת�ɿ�Ѻ��
    -- ���ղ�����Ӧ��û������
    -- ���ղ������ֹ�������ۼ�Ѻ�����ϵͳ���пۼ�
    p_fromCardNo     char,  -- ��ʼ����
    p_toCardNo       char,  -- ��������
    p_deductionMoney int ,  -- �ۼ����

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

    -- ���Ŷε��ۿ������Ƿ���ͬ
    begin
        select distinct trunc(t.selltime, 'DD')
        into v_sellDate
        from tf_f_cardrec t
        where t.cardno between p_fromCardNo and p_toCardNo;
    exception
        when no_data_found then
            raise_application_error(-20101, '���Ŷβ������ڿ����ϱ���');
        when too_many_rows then
            raise_application_error(-20102, '���Ŷ��ۿ����ڲ�һ��');
    end;

    -- �ж�����"�ۼ����"�Ƿ�>0(�������ж����)����<=����
    begin
        select 1 into v_int
        from tf_f_cardrec t
        where t.cardno between p_fromCardNo and p_toCardNo
        and   (t.cardcost = 0 or t.cardcost < p_deductionMoney);

        raise_application_error(-20103, '����ĳ�ſ�Ƭ����Ϊ0�����߿��ѵ��ڿۼ����');
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
        t.servicemoney = p_deductionMoney, -- ʵ�շ����Ϊ�ۼ����
        -- ����ۼ����=0��serstaketag����
        -- ����ۼ����=���ѣ�����serstaketagΪ3,��ʾ�Ѿ����꣨������ȡ��
        -- �����Ϊ1����ʾ��������������ȡѺ��
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
