CREATE OR REPLACE PROCEDURE SP_GetOrderNO
(     
     p_orderNo    out varchar2
)
AS  
  v_seq  int;  
BEGIN  
  select orderno_seq.nextval into v_seq from dual;
  p_orderNo := to_char(sysdate, 'yymmdd') || lpad(to_char(v_seq), 6, '0') ;
END;
/
show errors