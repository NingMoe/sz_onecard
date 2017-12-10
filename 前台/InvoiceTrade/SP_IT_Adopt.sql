create or replace procedure SP_IT_Adopt
(
    p_currOper           char,
    p_currDept           char,
    p_retCode        out char,
    p_retMsg         out varchar2
)
as
    v_quantity           int;
    v_ex            exception;
    v_seqNo         TF_B_INVOICE.TRADEID%TYPE;
    v_volno              char(12);
    v_invoiceno          char(8);
    CURSOR mycur(v1 char) is
     select volumeno,invoiceno from TL_R_INVOICE t where
      t.allotstatecode='05' and t.allotstaffno=v1;
begin

select count(*) into v_quantity from  TL_R_INVOICE t where
 t.allotstatecode='05' and t.allotstaffno=p_currOper;
 if v_quantity=0 then
        p_retCode   := 'IEM0003001';
        p_retMsg    := '无可领用的发票';
        return;
 end if;
 
  
    --4)记台账
   
    
        begin
        open mycur(p_currOper);
        fetch mycur into v_volno,v_invoiceno;
        while mycur%found 
loop
SP_GetSeq(seq => v_seqNo);
 begin
        insert into tf_r_invoicetrade
               (tradeid, opetypecode, volumeno, invoicebeginno, 
               invoiceendno, invoicenum, assignedstaffno, assigneddepartid,
               operatestaffno,operatedepartid, operatetime)
           values(v_seqNo,'KB',v_volno,v_invoiceno,v_invoiceno,1,p_currOper, p_currDept, 
               p_currOper, p_currDept, sysdate);
        exception when others then
            p_retCode := 'S200001092';
            p_retMsg  := '插入发票库存台帐表失败';
            rollback; return;
            end;
fetch mycur into v_volno,v_invoiceno;
end loop;

close mycur;
          end;
     
    
 
 begin
    update  TL_R_INVOICE t set 
    t.allotstatecode='02' ,
    t.allottime=sysdate
    where
     t.allotstatecode='05' and t.allotstaffno=p_currOper;
    if  SQL%ROWCOUNT <1 then raise v_ex; end if;
        exception when others then
           p_retCode := 'IE20003003';
           p_retMsg  := '更新领用状态失败';
           rollback; return;
 end;
        
            p_retCode := '0000000000';
            p_retMsg  := '';
            commit; return;
end;
/
show errors