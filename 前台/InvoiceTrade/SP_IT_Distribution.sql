create or replace procedure SP_IT_Distribution
(
    p_beginNo            char,
    p_endNo              char,
    p_allotDept          char,
    p_allotStaff         char,
    p_currOper           char,
    p_currDept           char,
    p_retCode        out char,
    p_retMsg         out varchar2,
    p_volumeno           char
)
as
    v_today   date  := sysdate;
    v_ex      exception;
    v_TradeID char(16);
begin

    -- 1) 获取业务流水号
    SP_GetSeq(seq => v_TradeID);

    --2)分配
    begin
        update TL_R_INVOICE
        set ALLOTSTATECODE  = '05',
            ALLOTSTAFFNO    = p_allotStaff,
            ALLOTDEPARTNO   = p_allotDept,
            ALLOTTIME       = v_today
        where INVOICENO between p_beginNo and p_endNo
        and VOLUMENO = p_volumeno and USESTATECODE = '00' and ALLOTSTATECODE = '01';

        if SQL%ROWCOUNT != to_number(p_endNo) - to_number(p_beginNo) + 1 then
             p_retCode := 'S200002093';
           p_retMsg    := '库存中从'|| p_beginNo || '开始不足'|| to_char(to_number(p_endNo) - to_number(p_beginNo) + 1)  || '份发票或不连续' ;
            rollback; return;
        end if;
    exception when others then
        p_retCode := 'S200002003';
        p_retMsg    := '';
        rollback; return;
    end;

 --3)记台账
    begin
        insert into tf_r_invoicetrade
               (tradeid, opetypecode, volumeno, invoicebeginno,
               invoiceendno, invoicenum, assignedstaffno, assigneddepartid,
               operatestaffno,operatedepartid, operatetime)
        values
               (v_TradeID, 'KA', p_volumeno, p_beginNo,
               p_endNo, to_number(p_endNo-p_beginNo)+1, p_currOper, p_currDept,
               p_currOper, p_currDept, v_today);
      exception when others then
            p_retCode := 'S200001092';
            p_retMsg  := '';
            rollback; return;
    end;

    p_retCode := '0000000000';
    p_retMsg  := '';

    commit; return;

end;
/
show errors