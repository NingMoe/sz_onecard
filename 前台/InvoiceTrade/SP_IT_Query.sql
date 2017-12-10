create or replace procedure SP_IT_Query
(
    p_funcCode   varchar2,
    p_var1       varchar2,
    p_var2       varchar2,
    p_var3       varchar2,
    p_var4       varchar2,
    p_var5       varchar2,
    p_var6       varchar2,
    p_var7       varchar2,
    p_var8       varchar2,
    p_var9       varchar2,
    p_cursor out SYS_REFCURSOR
)
as
	v1       	varchar2(16);
    v2       	varchar2(16);
    v3       	varchar2(16);
    v4 			varchar2(16);
    v5 			varchar2(16);
    v6 			varchar2(16);
    v7 			varchar2(16);
    v8 			varchar2(16);
    v9 			varchar2(16);
    v10 		varchar2(16);
    v11 		varchar2(16);
begin

if p_funcCode = 'invoicenoSegmentSel' then
    open p_cursor for
      select xx.volumeno ��Ʊ����,min(xx.invoiceno) ��Ʊ��ʼ����,
             max(xx.invoiceno) ��Ʊ��ֹ����,count(1) ����
      from (select volumeno,invoiceno 
           from tl_r_invoice 
           where allotstatecode=p_var1  
            and (p_var2 is null or allotstaffno = p_var2)
            and (p_var3 is null or volumeno = p_var3)
            and ((p_var4 is null or p_var5 is null) or (invoiceno between p_var4 and p_var5))
          order by volumeno ,invoiceno) xx
      group by xx.volumeno,xx.invoiceno-rownum 
      order by xx.volumeno ,min(xx.invoiceno); 
      
      
     elsif p_funcCode = 'Freeze' then
     open p_cursor for
      select xx.volumeno ��Ʊ����,min(xx.invoiceno) ��Ʊ��ʼ����,
             max(xx.invoiceno) ��Ʊ��ֹ����,count(1) ����
      from (select volumeno,invoiceno 
           from tl_r_invoice 
           where usestatecode=p_var1  
            and (p_var2 is null or allotstaffno = p_var2)
            and (p_var3 is null or volumeno = p_var3)
            and ((p_var4 is null or p_var5 is null) or (invoiceno between p_var4 and p_var5))
          order by volumeno ,invoiceno) xx
      group by xx.volumeno,xx.invoiceno-rownum 
      order by xx.volumeno ,min(xx.invoiceno); 
      
      
       elsif p_funcCode = 'StockOut' then
       open p_cursor for
      select xx.volumeno ��Ʊ����,min(xx.invoiceno) ��Ʊ��ʼ����,
             max(xx.invoiceno) ��Ʊ��ֹ����,count(1) ����,intime ���ʱ��
      from (select volumeno,invoiceno ,intime
           from tl_r_invoice 
           where allotstatecode=p_var1  
            and (p_var2 is null or allotstaffno = p_var2)
            and (p_var3 is null or volumeno = p_var3)
            and ((p_var4 is null or p_var5 is null) or (invoiceno between p_var4 and p_var5))
          order by  volumeno ,invoiceno) xx
      group by xx.volumeno,xx.invoiceno-rownum,xx.intime
      order by xx.intime ,xx.volumeno ,min(xx.invoiceno); 
      
      
       elsif p_funcCode = 'Distribution' then
       open p_cursor for
      select xx.volumeno ��Ʊ����,min(xx.invoiceno) ��Ʊ��ʼ����,
             max(xx.invoiceno) ��Ʊ��ֹ����,count(1) ����,ALLOTTIME ����ʱ��
      from (select volumeno,invoiceno ,ALLOTTIME
           from tl_r_invoice 
           where allotstatecode=p_var1  
            and (p_var2 is null or allotstaffno = p_var2)
            and (p_var3 is null or volumeno = p_var3)
            and ((p_var4 is null or p_var5 is null) or (invoiceno between p_var4 and p_var5))
          order by  volumeno ,invoiceno) xx
      group by xx.volumeno,xx.invoiceno-rownum,xx.allottime
      order by xx.allottime ,xx.volumeno ,min(xx.invoiceno); 
	elsif p_funcCode = 'StockQuery' then
	DELETE FROM tmp_it_stat;
    
  --�������ơ�������������Ч��Ʊ�������������������ʣ����������������δ���õġ�������δʹ�õģ�
  if(p_var1 is null) then 
    -- �������㷢Ʊ����ͳ��
    for v_cur in (
      select t.departno, t.departname
      from TD_M_INSIDEDEPART t
      order by t.departno
    )
    loop
      --��������
      SELECT count(*) into v1 
      FROM TL_R_INVOICE l 
      where l.ALLOTSTATECODE not in ('00')
	  and l.USESTATECODE not in ('04')
      and l.ALLOTDEPARTNO=v_cur.departno;

      --��Ч��Ʊ��
      SELECT count(*) into v2 
      FROM TL_R_INVOICE l 
      where (l.USESTATECODE='01')
	  and l.ALLOTSTATECODE='02'--����
      and  l.ALLOTDEPARTNO=v_cur.departno;

      --������
      SELECT count(*) into v3 
      FROM TL_R_INVOICE l 
      where (l.ALLOTSTATECODE='03')--�����ķ�ƱҲ��������wdx20120706
      and  l.ALLOTDEPARTNO=v_cur.departno;
      --�����
      SELECT count(*) into v4 
      FROM TL_R_INVOICE l 
      inner join tf_f_invoice f 
      on l.invoiceno=f.invoiceno and l.volumeno=f.volumeno
      where l.USESTATECODE='01'
      and f.OLDINVOICENO is not null
	  and l.ALLOTSTATECODE='02'--����
      and   l.ALLOTDEPARTNO=v_cur.departno;
	  v5:=v1-v2-v3-v4;
      --ʣ����������������δ���õġ�������δʹ�õ�,�����
      /*SELECT count(*) into v5 FROM TL_R_INVOICE l 
      where ((l.ALLOTSTATECODE in ('02','05') 
      and l.usestatecode ='00') 
	  or (l.usestatecode ='04' and l.ALLOTSTATECODE not in ('00')))
      and l.ALLOTDEPARTNO=v_cur.departno;*/

      insert into tmp_it_stat(f0,f1,f2,f3,f4,f5)
      values(v_cur.departname,v1,v2,v3,v4,v5);
      
    END LOOP;
    open p_cursor for 
    select f0 "����" ,f1 "��������",f2 "��Ч��Ʊ��" , f3   "������" ,f4 "�����" ,f5 "ʣ����"  
    from tmp_it_stat;
  else
    -- ĳ����ӪҵԱ��Ʊ����ͳ��
    for v_cur in (
      select t.staffno,t.staffname
      from td_m_insidestaff t
      where t.departno=p_var1
    )
    loop
		begin
      
      --����δ����
      SELECT count(*) into v1 FROM TL_R_INVOICE l 
      where l.ALLOTSTATECODE ='05' 
      and l.usestatecode='00'
      and l.ALLOTDEPARTNO=p_var1 
      and l.ALLOTSTAFFNO =v_cur.staffno;
      --����δʹ��
      SELECT count(*) into v2 FROM TL_R_INVOICE l 
      where l.ALLOTSTATECODE ='02' 
      and l.usestatecode='00'
      and l.ALLOTDEPARTNO=p_var1 
      and l.ALLOTSTAFFNO =v_cur.staffno;
      --��Ч��Ʊ��
      SELECT count(*) into v3 FROM TL_R_INVOICE l 
      where (l.USESTATECODE='01')
	  and l.ALLOTSTATECODE='02'--����
      and  l.ALLOTDEPARTNO=p_var1
      and l.ALLOTSTAFFNO =v_cur.staffno;

      --������
      SELECT count(*) into v4 FROM TL_R_INVOICE l 
      where (l.ALLOTSTATECODE='03')--�����ķ�ƱҲ��������wdx20120706
      and  l.ALLOTDEPARTNO=p_var1
      and l.ALLOTSTAFFNO =v_cur.staffno;
      --�����
      SELECT count(*) into v5 FROM TL_R_INVOICE l 
      inner join tf_f_invoice f on l.invoiceno=f.invoiceno and l.volumeno=f.volumeno
      where l.USESTATECODE='01'
      and f.OLDINVOICENO is not null
	  and l.ALLOTSTATECODE='02'--����
      and   l.ALLOTDEPARTNO=p_var1 
      and l.ALLOTSTAFFNO =v_cur.staffno;
      
      insert into tmp_it_stat(f0,f1,f2,f3,f4,f5)
      values(v_cur.staffname,v1,v2,v3,v4,v5);
      end;
    END LOOP;
    open p_cursor for 
    select f0 "����Ա" ,f1 "����δ����",f2 "����δʹ��" , f3  "��Ч��Ʊ��" ,f4 "������" ,f5 "�����" from tmp_it_stat;
	end if; 
end if;
end;
/
show errors