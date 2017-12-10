create or replace procedure SP_IT_Freeze
(
    p_beginNo            char,
    p_endNo              char,
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

    begin
        update TL_R_INVOICE t
        set USESTATECODE  = '04'
        where INVOICENO  between p_beginNo and p_endNo
        and VOLUMENO = p_volumeno and USESTATECODE = '00' and t.allotstatecode<>'03';

        if SQL%ROWCOUNT != to_number(p_endNo) - to_number(p_beginNo) + 1 then
             p_retCode := 'S200002093';
             p_retMsg    := '����д�'|| p_beginNo || '��ʼ����'|| to_char(to_number(p_endNo) - to_number(p_beginNo) + 1)  || '�ݷ�Ʊ������' ;
            rollback; return;
        end if;
    exception when others then
        p_retCode := 'S200002003';
        p_retMsg    := '';
        rollback; return;
    end;
    
     -- 1) ��ȡҵ����ˮ��
    SP_GetSeq(seq => v_TradeID);

 --3)��̨��
    begin
        insert into tf_r_invoicetrade
               (tradeid, opetypecode, volumeno, invoicebeginno, 
               invoiceendno, invoicenum, assignedstaffno, assigneddepartid,
               operatestaffno,operatedepartid, operatetime)
        values
               (v_TradeID, 'M3', p_volumeno, p_beginNo, 
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