create or replace procedure SP_IT_StockInRollBack
(
    p_volumeno           char,
    p_beginNo            char,
    p_endNo              char,
    p_currOper           char,
    p_currDept           char,
    p_retCode        out char,
    p_retMsg         out varchar2
)
as
    v_today   date  := sysdate;
    v_TradeID char(16);

begin

    
    --3)ɾ��
    begin
       delete from TL_R_INVOICE t 
    where t.INVOICENO between p_beginNo and p_endNo
    and   t.VOLUMENO = p_volumeno and (t.allotstatecode='00' or t.usestatecode='04');
    if SQL%ROWCOUNT != to_number(p_endNo) - to_number(p_beginNo) + 1 then
             p_retCode := 'S200002093';
             p_retMsg    := '����д�'|| p_beginNo || '��ʼ����'|| to_char(to_number(p_endNo) - to_number(p_beginNo) + 1)  || '�ݷ�Ʊ������' ;
            rollback; return;
        end if;
    exception when others then
        p_retCode := 'IE0D001002';
        p_retMsg  := '�����˳ɹ�';
        rollback; return;
    end;
-- 1) ��ȡҵ����ˮ��
    SP_GetSeq(seq => v_TradeID);
    --4)��̨��
    begin
        insert into tf_r_invoicetrade
               (tradeid, opetypecode, volumeno, invoicebeginno, 
               invoiceendno, invoicenum, assignedstaffno, assigneddepartid,
               operatestaffno,operatedepartid, operatetime)
        values
               (v_TradeID, 'M2', p_volumeno, p_beginNo, 
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