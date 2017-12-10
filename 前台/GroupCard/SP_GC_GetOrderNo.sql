
create or replace procedure SP_GC_GETORDERNO
(
       p_orderDate    char,
       p_orderSeq      out char       -- Current Operator
)
AS
       v_count        int;
       v_seqNo         CHAR(4);
       v_ex            EXCEPTION;
BEGIN
   BEGIN
       select count(*) into v_count from tf_f_order t where t.orderdate =  p_orderDate;
       if v_count < 1 then
            p_orderSeq :=  '0001';
       else
          select max(t.orderseq) into v_seqNo from tf_f_order t where t.orderdate =  p_orderDate;
          if v_seqNo = '9999' then
            v_seqNo := '0000';
          end if;
          v_seqNo := LPAD(to_char(to_number(v_seqNo) + 1), 4, '0');
          p_orderSeq := v_seqNo;
       end if;     
       exception when others then 
            rollback;
            return;
    END;   
    COMMIT; RETURN;
END;

/ 
show errors;
