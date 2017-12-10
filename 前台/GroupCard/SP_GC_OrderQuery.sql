create or replace procedure SP_GC_OrderQuery
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
    p_var10      varchar2,
    p_var11       varchar2,
    p_var12       varchar2,
    p_var13       varchar2,
    p_var14       varchar2,
    p_var15       varchar2,
    p_cursor out SYS_REFCURSOR
)
as
    v_int        int;
    v_f0         varchar2(256);
    v_funcList   varchar2(1024);
    v_count      int;
    v_msg        varchar2(100);
begin

if p_funcCode = 'RejectOrderSelect' then
   open p_cursor for
      select t.orderno from tf_f_order t   where t.result = '2' order by t.orderno;
   
elsif  p_funcCode = 'OrderInfo' then
    open p_cursor for
       select 
       tm.CODEVALUE||':'||tm.CODEDESC ORDERSTATE , t.ORDERTYPE  , 
       t.GROUPNAME         , t.NAME          , t.PHONE          ,
       t.IDCARDNO          , t.TOTALMONEY    , t.TRANSACTOR||':'||tdi.STAFFNAME  TRANSACTOR  , 
       t.INPUTTIME         , t.REMARK        , t.CASHGIFTMONEY  , 
       t.CHARGECARDMONEY   , t.SZTCARDMONEY  , t.CUSTOMERACCMONEY , 
       t.INVOICETOTALMONEY , t.GETDEPARTMENT , t.GETDATE         , t.managerdept,t.manager
       from tf_f_orderform t ,td_m_rmcoding tm,td_m_insidestaff tdi
       where t.orderno =  p_var1
       and   t.USETAG = '1' --��Ч
       and   tm.TABLENAME = 'TF_F_ORDERFORM'
       and   tm.COLNAME = 'ORDERSTATE'
       and   tm.CODEVALUE = t.ORDERSTATE
       and   t.TRANSACTOR = tdi.staffno(+)
       ;
elsif  p_funcCode = 'OrderInfoForExport' then
    open p_cursor for
       select 
       tm.CODEVALUE||':'||tm.CODEDESC ORDERSTATE , t.ORDERTYPE  , 
       t.GROUPNAME         , t.NAME          , t.PHONE          ,
       t.IDCARDNO          , t.TOTALMONEY    , t.manager||':'||tdi.STAFFNAME  TRANSACTOR  , 
       t.INPUTTIME         , t.REMARK        , t.CASHGIFTMONEY  , 
       t.CHARGECARDMONEY   , t.SZTCARDMONEY  , t.CUSTOMERACCMONEY , 
       t.INVOICETOTALMONEY , t.GETDEPARTMENT , t.GETDATE
       from tf_f_orderform t ,td_m_rmcoding tm,td_m_insidestaff tdi
       where t.orderno =  p_var1
       and   tm.TABLENAME = 'TF_F_ORDERFORM'
       and   tm.COLNAME = 'ORDERSTATE'
       and   tm.CODEVALUE = t.ORDERSTATE
       and   t.manager = tdi.staffno(+)
       ;      
elsif p_funcCode = 'ResidentCardInfo' then
    open p_cursor for
    select B.CARDSURFACENAME,A.COUNT,A.UNITPRICE/100.0 UNITPRICE,A.TOTALCHARGEMONEY/100.0 TOTALCHARGEMONEY,
    A.TOTALMONEY/100.0 TOTALMONEY,A.LEFTQTY
    from TF_F_SZTCARDORDER A , td_m_cardsurface B where A.ORDERNO = p_var1 and A.CARDTYPECODE = B.CARDSURFACECODE;

elsif p_funcCode = 'CashOrderInfo' then --��ѯ��𿨶�����ϸ��
    open p_cursor for
    select t.ORDERNO,t.VALUE,t.COUNT,t.SUM,t.LEFTQTY from tf_f_cashgiftorder t where t.orderno = p_var1;

elsif p_funcCode = 'ChargeCardOrderInfo' then --��ѯ��ֵ��������ϸ��
    open p_cursor for
    select t.ORDERNO,t.VALUE,t.VALUECODE,tx.VALUE VALUENAME,t.COUNT,t.SUM,t.FROMCARDNO,t.TOCARDNO,t.LEFTQTY 
    from tf_f_chargecardorder t ,TP_XFC_CARDVALUE tx
    where t.orderno = p_var1
    AND   t.VALUECODE = tx.VALUECODE(+);

elsif p_funcCode = 'SZTCardOrderInfo' then --��ѯ����B����ֵ��ϸ��
    open p_cursor for
    select t.ORDERNO,t.CARDTYPE,t.CARDTYPECODE,tm.CARDSURFACENAME,t.COUNT,t.UNITPRICE,t.TOTALCHARGEMONEY,t.TOTALMONEY,t.LEFTQTY 
    from tf_f_sztcardorder t ,TD_M_CARDSURFACE tm 
    where t.orderno = p_var1 
    and t.CARDTYPECODE  != '5101'
    and t.CARDTYPECODE = tm.CARDSURFACECODE(+);
    
elsif p_funcCode = 'SZTCardOrderAllInfo' then --��ѯ����B����(�������ο�)ֵ��ϸ��
    open p_cursor for
    select t.ORDERNO,t.CARDTYPE,t.CARDTYPECODE,tm.CARDSURFACENAME,t.COUNT,t.UNITPRICE,t.TOTALCHARGEMONEY,t.TOTALMONEY,t.LEFTQTY 
    from tf_f_sztcardorder t ,TD_M_CARDSURFACE tm 
    where t.orderno = p_var1 
    and t.CARDTYPECODE = tm.CARDSURFACECODE(+);

elsif p_funcCode = 'LvYouOrderInfo' then --��ѯ���ο���ϸ��
    open p_cursor for
    select t.ORDERNO,t.CARDTYPE,t.CARDTYPECODE,tm.CARDSURFACENAME,t.COUNT,t.UNITPRICE,t.TOTALCHARGEMONEY,t.TOTALMONEY,t.LEFTQTY 
    from tf_f_sztcardorder t ,TD_M_CARDSURFACE tm 
    where t.orderno = p_var1 
    and t.CARDTYPECODE = '5101'
    and t.CARDTYPECODE = tm.CARDSURFACECODE(+);
    
elsif p_funcCode = 'CustomerAccOrderInfo' then --��ѯר���˻�
    open p_cursor for
    select t.ORDERNO,t.CUSTOMERACCMONEY,t.CUSTOMERACCHASMONEY
    from TF_F_ORDERFORM t 
    where t.orderno = p_var1
    and CUSTOMERACCMONEY > 0;    
    
elsif p_funcCode = 'ReaderOrderInfo' then --��ѯ��������ϸ��
    open p_cursor for
    select t.ORDERNO,t.VALUE,t.COUNT,t.SUM,t.LEFTQTY
    from TF_F_READERORDER t 
    where t.orderno = p_var1;
    
elsif p_funcCode = 'GardenCardOrderInfo' then --��ѯ԰���꿨��ϸ��
    open p_cursor for
    select t.ORDERNO,t.VALUE,t.COUNT,t.SUM
    from TF_F_GARDENCARDORDER t 
    where t.orderno = p_var1;    

elsif p_funcCode = 'RelaxCardOrderInfo' then --��ѯ�����꿨��ϸ��
    open p_cursor for
    select t.ORDERNO,t.VALUE,t.COUNT,t.SUM
    from TF_F_RELAXCARDORDER t 
    where t.orderno = p_var1;        

elsif p_funcCode = 'InvoiceOrderInfo' then --��ѯ��Ʊ��ϸ��
       open p_cursor for
       select decode(INVOICETYPECODE,0,'����ͨ��ֵ',1,'��ͨ��',2,'�д���',3,'������',INVOICETYPECODE) INVOICETYPENAME,
       INVOICENUM,INVOICEMONEY/100.0 INVOICEMONEY,INVOICETYPECODE from tf_f_orderinvoice t where  t.orderno = p_var1;
       
elsif p_funcCode = 'PayTypeOrderInfo' then
     open p_cursor for
     select * from tf_f_paytype t where  t.orderno = p_var1;

elsif p_funcCode = 'OrderInfoSelect' then --ֻ��ѯδ��˵Ķ���
      open p_cursor for
      select 
      t.orderno,
      t.groupname,
      t.name,
      t.idcardno, 
      t.phone,
      t.totalmoney/100.0 totalmoney,
      t.cashgiftmoney/100.0 cashgiftmoney,
      t.customeraccmoney/100.0 customeraccmoney,
      t.transactor || ':' || m.staffname transactor,
      to_char(t.inputtime,'yyyymmdd') inputtime,
      t.remark,
      t.invoicetotalmoney/100.0 invoicetotalmoney
      from TF_F_ORDERFORM t
      inner join td_m_insidestaff m on t.transactor = m.staffno
       where
      (p_var1 is null or t.groupname = p_var1) and
      (p_var2 is null or t.name = p_var2) and
      (p_var3 is null or t.transactor = p_var3) and
      (p_var4 is null or t.totalmoney = p_var4) and
      (p_var5 is null or to_char(t.inputtime,'yyyymmdd') >= p_var5) and
      (p_var6 is null or to_char(t.inputtime,'yyyymmdd') <= p_var6) and 
      (p_var7 is null or m.departno = p_var7) and 
      (p_var8 is null or t.managerdept = p_var8) and
      (p_var9 is null or t.manager = p_var9) and 
      t.ORDERSTATE = '01' order by t.orderno desc;
      
elsif p_funcCode = 'OrderInfoSelectForApproveCheck' then --��ѯ��������Ϊ�������Ķ���
      open p_cursor for
      select 
      t.orderno,
      t.groupname,
      t.name,
      t.idcardno, 
      t.phone,
      t.totalmoney/100.0 totalmoney,
      t.cashgiftmoney/100.0 cashgiftmoney,
      t.customeraccmoney/100.0 customeraccmoney,
      t.transactor || ':' || m.staffname transactor,
      to_char(t.inputtime,'yyyymmdd') inputtime,
      t.remark,
      t.invoicetotalmoney/100.0 invoicetotalmoney
      from TF_F_ORDERFORM t
      inner join td_m_insidestaff m on t.transactor = m.staffno
       where
      (p_var1 is null or t.groupname = p_var1) and
      (p_var2 is null or t.name = p_var2) and
      (p_var3 is null or t.transactor = p_var3) and
      (p_var4 is null or t.totalmoney = p_var4) and
      (p_var5 is null or to_char(t.inputtime,'yyyymmdd') >= p_var5) and
      (p_var6 is null or to_char(t.inputtime,'yyyymmdd') <= p_var6) and 
      (p_var7 is null or m.departno = p_var7) and 
       t.orderno in (select orderno from tf_f_paytype a 
       where not exists (select b.orderno from tf_f_paytype b where b.paytypecode in ('0','1','2','3') and a.orderno = b.orderno)
       and paytypecode = '4') and
       not exists(select 1 from TF_F_ORDERCHECKRELATION c where t.orderno = c.orderno) and 
       t.ORDERSTATE not in ('00','01','09') and
       substr(t.orderno,1,2) = '20'
      order by t.orderno desc;      
      
  elsif p_funcCode = 'AllOrderInfoSelect' then --����������ѯ���еĶ�����Ϣ
 if p_var11 is null and  p_var12 is null then
      open p_cursor for
      select
        t.ORDERNO,
        t.GROUPNAME,
        t.NAME,    --��ϵ��
        t.IDCARDNO,
        t.PHONE,
        t.totalmoney/100.0 totalmoney,
        t.TRANSACTOR || ':' || m.staffname transactor,   --¼��Ա��
        to_char(t.INPUTTIME,'yyyymmdd') inputtime,  --¼��ʱ��
        t.REMARK, --��ע
        nvl(t.cashgiftmoney/100.0,0) CASHGIFTMONEY,
        (nvl(t.sztcardmoney/100.0,0) + nvl(t.lvyoumoney/100.0,0)) sztcardmoney,
        nvl(t.chargecardmoney/100.0,0) chargecardmoney,
        nvl(t.customeracchasmoney/100.0,0) customeracchasmoney,
        nvl(t.readermoney/100.0,0) readermoney,
        decode(t.Financeapproverno,null,'',t.FINANCEAPPROVERNO|| ':' || n.staffname)   financeapproverno,
        t.financeapprovertime,
        t.financeremark, --����������                                                                                                        
        decode(t.ORDERSTATE,'00','00:�޸���','01','01:¼������','02','02:�������ͨ��','03','03:��ɷ���','04','04:�ƿ���','05','05:�ƿ����','06','06:������ȷ�����','07','07:�������','08','08:ȷ�����','09','09:����',t.ORDERSTATE) orderstate,
        t.CUSTOMERACCMONEY/100.0 CUSTOMERACCMONEY,
        t.getdepartment || ':' || de.departname getdepartment,
        t.getdate,
        t.isrelated
        from TF_F_ORDERFORM t,td_m_insidestaff m,td_m_insidestaff n ,td_m_insidedepart de 
        where t.transactor = m.staffno
        and t.getdepartment = de.departno(+)
        and t. financeapproverno = n.staffno(+)
        and t.USETAG = '1'
        and t.orderstate in ('00','01','02','03','04','05','06','07','08','09')
        and (p_var1 IS NULL OR p_var1 = '' OR t.groupname like '%'||p_var1||'%')
        and (p_var2 IS NULL OR p_var2 = '' OR p_var2 =t.name)
        and (p_var3 IS NULL OR p_var3 = '' OR p_var3 =t.transactor)  --¼��Ա��
        and (p_var4 IS NULL OR p_var4 = '' OR p_var4 =t.totalmoney)  --���
        and (p_var5 IS NULL OR p_var5 = '' OR to_char(t.inputtime,'yyyymmdd')>= p_var5)--¼��ʱ��
        and (p_var6 IS NULL OR p_var6 = '' OR to_char(t.inputtime,'yyyymmdd')<= p_var6)
        and (p_var7 IS NULL OR p_var7 = '' OR p_var7 =t.orderstate)  --����״̬
        and (p_var8 IS NULL OR p_var8 = '' OR p_var8 =t.FINANCEAPPROVERNO)  --���Ա��
        and (p_var9 IS NULL OR p_var9 = '' OR p_var9 = m.departno)--¼�벿��
        and (p_var13 IS NULL OR p_var13 = '' OR p_var13 =t.manager)  --�ͻ�����
        and (p_var14 IS NULL OR p_var14 = '' OR p_var14 = t.managerdept)--�ͻ��������ڲ���
        and (p_var15 IS NULL OR p_var15 = '' OR t.orderno in(select pa.orderno from tf_f_paytype pa where p_var15 =pa.paytypecode)) --���ʽ
        and (p_var10 IS NULL OR p_var10 = '' 
        OR (p_var10 = '1' and t.cashgiftmoney<>0) 
        OR (p_var10 = '2'and t.chargecardmoney<>0) 
        OR (p_var10 = '3' and t.sztcardmoney<>0) 
        OR(p_var10 = '4' and t.CUSTOMERACCMONEY<>0) 
        OR(p_var10 = '5' and t.READERMONEY<>0)
        OR(p_var10 = '6' and t.GARDENCARDMONEY<>0)
        OR(p_var10 = '7' and t.RELAXCARDMONEY<>0))
        and (p_var11 IS NULL OR p_var11 = '' )
        and (p_var12 IS NULL OR p_var12 = '' )
        order by t.orderno desc;
   elsif p_var11 is not null or p_var12 is not null then  --ѡ���ƿ����Ż��ƿ�Ա��
   open p_cursor for
      select
        t.ORDERNO,
        t.GROUPNAME,
        t.NAME,    --��ϵ��
        t.IDCARDNO,
        t.PHONE,
        t.totalmoney/100.0 totalmoney,
        t.TRANSACTOR || ':' || m.staffname transactor,   --¼��Ա��
        to_char(t.INPUTTIME,'yyyymmdd') inputtime,  --¼��ʱ��
        t.REMARK, --��ע
        nvl(t.cashgiftmoney/100.0,0) CASHGIFTMONEY,
         (nvl(t.sztcardmoney/100.0,0) + nvl(t.lvyoumoney/100.0,0)) sztcardmoney,
        nvl(t.chargecardmoney/100.0,0) chargecardmoney,
        nvl(t.customeracchasmoney/100.0,0) customeracchasmoney,
        nvl(t.readermoney/100.0,0) readermoney,
        decode(t.Financeapproverno,null,'',t.FINANCEAPPROVERNO|| ':' || n.staffname)   financeapproverno,
        t.financeapprovertime,
        t.financeremark, --����������                                                                                                        
        decode(t.ORDERSTATE,'05','05:�ƿ����','06','06:������ȷ�����','07','07:�������','08','08:ȷ�����',t.ORDERSTATE) orderstate,
        t.CUSTOMERACCMONEY/100.0 CUSTOMERACCMONEY,
        t.getdepartment || ':' || de.departname getdepartment,
        t.getdate,
        t.isrelated
        from TF_F_ORDERFORM t,td_m_insidestaff m,td_m_insidestaff n ,td_m_insidedepart de,(select Max(Tradeid) tradeid,orderno from TF_F_ORDERTRADE h where h.tradecode='07' group by orderno)q, TF_F_ORDERTRADE p,td_m_insidestaff j,td_m_insidedepart k
        where t.transactor = m.staffno
        and t.getdepartment = de.departno(+)
        and t. financeapproverno = n.staffno(+)
        and t.USETAG = '1'
        and t.orderstate in ('05','06','07','08')
        and t.orderno =p.orderno
        and q.tradeid = p.tradeid
        and p.OPERATEDEPARTNO = k.departno
        and p.OPERATESTAFFNO = j.staffno
        and (p_var1 IS NULL OR p_var1 = '' OR t.groupname like '%'||p_var1||'%')
        and (p_var2 IS NULL OR p_var2 = '' OR p_var2 =t.name)
        and (p_var3 IS NULL OR p_var3 = '' OR p_var3 =t.transactor)  --¼��Ա��
        and (p_var4 IS NULL OR p_var4 = '' OR p_var4 =t.totalmoney)  --���
        and (p_var5 IS NULL OR p_var5 = '' OR to_char(t.inputtime,'yyyymmdd')>= p_var5)--¼��ʱ��
        and (p_var6 IS NULL OR p_var6 = '' OR to_char(t.inputtime,'yyyymmdd')<= p_var6)
        and (p_var7 IS NULL OR p_var7 = '' OR p_var7 =t.orderstate)  --����״̬
        and (p_var8 IS NULL OR p_var8 = '' OR p_var8 =t.FINANCEAPPROVERNO)  --���Ա��
        and (p_var9 IS NULL OR p_var9 = '' OR p_var9 = m.departno)--¼�벿��
        and (p_var13 IS NULL OR p_var13 = '' OR p_var13 =t.manager)  --�ͻ�����
        and (p_var14 IS NULL OR p_var14 = '' OR p_var14 = t.managerdept)--�ͻ��������ڲ���
       and (p_var15 IS NULL OR p_var15 = '' OR t.orderno in(select pa.orderno from tf_f_paytype pa where p_var15 =pa.paytypecode)) --���ʽ
        and (p_var10 IS NULL OR p_var10 = '' 
        OR (p_var10 = '1' and t.cashgiftmoney<>0) 
        OR (p_var10 = '2'and t.chargecardmoney<>0) 
        OR (p_var10 = '3' and t.sztcardmoney<>0) 
        OR(p_var10 = '4' and t.CUSTOMERACCMONEY<>0) 
        OR(p_var10 = '5' and t.READERMONEY<>0)
        OR(p_var10 = '6' and t.GARDENCARDMONEY<>0)
        OR(p_var10 = '7' and t.RELAXCARDMONEY<>0))
        and (p_var11 is null or p_var11 = '' OR p_var11 = p.OPERATEDEPARTNO)
        and (p_var12 is null or p_var12 = '' OR p_var12 = p.OPERATESTAFFNO)
        order by t.orderno desc;
  end if;
 elsif p_funcCode = 'AllOrderInfoSelectForReturn' then --����������ѯ���п��Ի��˵Ķ�����Ϣ
      open p_cursor for
      select
        t.ORDERNO,
        t.GROUPNAME,
        t.NAME,    --��ϵ��
        t.IDCARDNO,
        t.PHONE,
        t.totalmoney/100.0 totalmoney,
        t.TRANSACTOR || ':' || m.staffname transactor,   --¼��Ա��
        to_char(t.INPUTTIME,'yyyymmdd') inputtime,  --¼��ʱ��
        t.REMARK, --��ע
        nvl(t.cashgiftmoney/100.0,0) CASHGIFTMONEY,
        nvl(t.sztcardmoney/100.0,0) sztcardmoney,
        nvl(t.chargecardmoney/100.0,0) chargecardmoney,
        nvl(t.customeracchasmoney/100.0,0) customeracchasmoney,
        nvl(t.readermoney/100.0,0) readermoney,
        decode(t.Financeapproverno,null,'',t.FINANCEAPPROVERNO|| ':' || n.staffname)   financeapproverno,
        t.financeapprovertime,
        t.financeremark, --����������                                                                                                        
        decode(t.ORDERSTATE,'00','00:�޸���','01','01:¼������','02','02:�������ͨ��','03','03:��ɷ���','04','04:�ƿ���','05','05:�ƿ����','06','06:������ȷ�����','07','07:�������','08','08:ȷ�����','09','09:����',t.ORDERSTATE) orderstate,
        t.CUSTOMERACCMONEY/100.0 CUSTOMERACCMONEY,
        t.getdepartment || ':' || de.departname getdepartment,
        t.getdate,
        t.isrelated
        from TF_F_ORDERFORM t,td_m_insidestaff m,td_m_insidestaff n ,td_m_insidedepart de
        where t.transactor = m.staffno
        and t.getdepartment = de.departno(+)
        and t. financeapproverno = n.staffno(+)
        and t.USETAG = '1'
        and t.orderstate in ('02','03','04','05','06')
        and (p_var1 IS NULL OR p_var1 = '' OR t.groupname like '%'||p_var1||'%')
        and (p_var2 IS NULL OR p_var2 = '' OR p_var2 =t.name)
        and (p_var3 IS NULL OR p_var3 = '' OR p_var3 =t.transactor)  --¼��Ա��
        and (p_var4 IS NULL OR p_var4 = '' OR p_var4 =t.totalmoney)  --���
        and (p_var5 IS NULL OR p_var5 = '' OR to_char(t.inputtime,'yyyymmdd')>= p_var5)--¼��ʱ��
        and (p_var6 IS NULL OR p_var6 = '' OR to_char(t.inputtime,'yyyymmdd')<= p_var6)
        and (p_var7 IS NULL OR p_var7 = '' OR p_var7 =t.orderstate)  --����״̬
        and (p_var8 IS NULL OR p_var8 = '' OR p_var8 =t.FINANCEAPPROVERNO)  --���Ա��
        and (p_var9 IS NULL OR p_var9 = '' OR p_var9 = m.departno)--¼�벿��
        and (p_var10 IS NULL OR p_var10 = '' 
        OR (p_var10 = '1' and t.cashgiftmoney<>0) 
        OR (p_var10 = '2'and t.chargecardmoney<>0) 
        OR (p_var10 = '3' and t.sztcardmoney<>0) 
        OR(p_var10 = '4' and t.CUSTOMERACCMONEY<>0) 
        OR(p_var10 = '5' and t.READERMONEY<>0)
        OR(p_var10 = '6' and t.GARDENCARDMONEY<>0)
        OR(p_var10 = '7' and t.RELAXCARDMONEY<>0))
        order by t.orderno desc;  		
 elsif p_funcCode = 'AllOrderInfoForExport' then --����������ѯ���еĶ�����Ϣ
      open p_cursor for
      select
        t.ORDERNO,
        t.GROUPNAME,
        t.NAME,    --��ϵ��
        t.IDCARDNO,
        t.PHONE,
        t.totalmoney/100.0 totalmoney,
        nvl2(t.manager,t.manager|| ':' || m.staffname,null) transactor,   --�ͻ�������ʾΪ������
        to_char(t.INPUTTIME,'yyyymmdd') inputtime,  --¼��ʱ��
        t.REMARK, --��ע
        t.cashgiftmoney/100.0 cashgiftmoney,
        decode(t.Financeapproverno,null,'',t.FINANCEAPPROVERNO|| ':' || n.staffname)   financeapproverno,
        t.financeapprovertime,
        t.financeremark, --����������                                                                                                        
        decode(t.ORDERSTATE,'00','00:�޸���','01','01:¼������','02','02:�������ͨ��','03','03:��ɷ���','04','04:�ƿ���','05','05:�ƿ����','06','06:������ȷ�����','07','07:�������','08','08:ȷ�����','09','09:����',t.ORDERSTATE) orderstate,
        t.CUSTOMERACCMONEY/100.0 CUSTOMERACCMONEY,
        t.getdepartment || ':' || de.departname getdepartment,
        t.getdate
        from TF_F_ORDERFORM t,td_m_insidestaff m,td_m_insidestaff n ,td_m_insidedepart de ,td_m_insidestaff k,
        (select distinct(ORDERNO) ORDERNO from TF_F_ORDERTRADE a where TRADECODE in ('00','01','03','13')
         and (p_var5 IS NULL OR p_var5 = '' OR to_char(a.operatetime,'yyyymmdd')>= p_var5)--¼��ʱ��
         and (p_var6 IS NULL OR p_var6 = '' OR to_char(a.operatetime,'yyyymmdd')<= p_var6)) tb
        where t.manager = m.staffno(+)  
        and t.orderno = tb.orderno
        and t.getdepartment = de.departno(+)
        and t. financeapproverno = n.staffno(+)
        and t.transactor = k.staffno(+)
        and (p_var1 IS NULL OR p_var1 = '' OR p_var1 =t.groupname)
        and (p_var2 IS NULL OR p_var2 = '' OR p_var2 =t.name)
        and (p_var3 IS NULL OR p_var3 = '' OR p_var3 =t.transactor)  --¼��Ա��
        and (p_var4 IS NULL OR p_var4 = '' OR p_var4 =t.totalmoney)  --���
        and (p_var7 IS NULL OR p_var7 = '' OR p_var7 =t.orderstate)  --����״̬
        and (p_var8 IS NULL OR p_var8 = '' OR p_var8 =t.FINANCEAPPROVERNO)  --���Ա��
        and (p_var9 IS NULL OR p_var9 = '' OR p_var9 = k.departno)--¼�벿��
        order by t.orderno desc;
elsif p_funcCode = 'QueryOrderApproved' then--����������ѯ���ͨ���Ķ�����Ϣ����������ҳ�棩
       open p_cursor for
        select  
        distinct t.ORDERNO,                                                      
        t.GROUPNAME,                                                      
        t.NAME,    --��ϵ��                                                      
        t.IDCARDNO,                                                      
        t.PHONE,                                                      
        t.totalmoney/100.0 totalmoney,                                                      
        t.TRANSACTOR || ':' || m.staffname transactor,   --������                                                      
        to_char(t.INPUTTIME,'yyyymmdd') inputtime ,--¼��ʱ�� 
        t.getdate ,
        t.getdepartment,
        t.isrelated,
        t.remark   ,
        t.cashgiftmoney/100.0   cashgiftmoney ,
        t.customeraccmoney/100.0   customeraccmoney ,
        n.staffno || ':'|| n.staffname approver,
        t.financeremark
        from TF_F_ORDERFORM t,td_m_insidestaff m  , td_m_insidestaff n,td_m_insidedepart h,td_m_regioncode r1,td_m_regioncode r2,
        (select regioncode from td_m_insidedepart where departno = p_var8) l
        where t.transactor = m.staffno
        and t.financeapproverno = n.staffno
        and t.USETAG = '1'
        and t.orderstate ='02'
        and (p_var1 IS NULL OR p_var1 = '' OR p_var1 =t.groupname)
        and (p_var2 IS NULL OR p_var2 = '' OR p_var2 =t.name)
        and (p_var3 IS NULL OR p_var3 = '' OR p_var3 =t.transactor)  --������
        and (p_var4 IS NULL OR p_var4 = '' OR p_var4 =t.totalmoney)  --���
        and (p_var5 IS NULL OR p_var5 = '' OR to_char(t.inputtime,'yyyymmdd')>= p_var5)--¼��ʱ��
        and (p_var6 IS NULL OR p_var6 = '' OR to_char(t.inputtime,'yyyymmdd')<= p_var6)
        and (p_var7 IS NULL OR p_var7 = '' OR p_var7 = m.departno)
        and (m.departno = h.departno)   
        and ((h.regioncode = r1.regioncode and r1.regionname = r2.regionname and r2.regioncode = l.regioncode)or l.regioncode is null)       
        order by t.orderno desc;

elsif  p_funcCode = 'AllOrderInfoSelectByOrderNo' then --�������õ��Ų�ѯ��������Ϣ
       open p_cursor for
       select
        t.ORDERNO,
        t.GROUPNAME,
        t.NAME,    --��ϵ��
        t.IDCARDNO,
        t.PHONE,
        t.totalmoney/100.0 totalmoney,
        t.TRANSACTOR || ':' || m.staffname transactor,   --¼��Ա��
        to_char(t.INPUTTIME,'yyyymmdd') inputtime,  --¼��ʱ��
        t.REMARK, --��ע
        t.cashgiftmoney/100.0 cashgiftmoney,
        decode(t.Financeapproverno,null,'',t.FINANCEAPPROVERNO|| ':' || n.staffname)   financeapproverno,
        t.financeapprovertime,
        t.financeremark, --����������                                                                                                        
        decode(t.ORDERSTATE,'00','00:�޸���','01','01:¼������','02','02:�������ͨ��','03','03:��ɷ���','04','04:�ƿ���','05','05:�ƿ����','06','06:������ȷ�����','07','07:�������','08','08:ȷ�����','09','09:����',t.ORDERSTATE) orderstate,
        t.CUSTOMERACCMONEY/100.0 CUSTOMERACCMONEY,
        t.getdepartment || ':' || de.departname getdepartment,
        t.getdate
        from TF_F_ORDERFORM t,td_m_insidestaff m,td_m_insidestaff n ,td_m_insidedepart de
        where t.transactor = m.staffno  
        and t.getdepartment = de.departno(+)
        and t. financeapproverno = n.staffno(+)
        and t.USETAG = '1'
        and t.ORDERNO = p_var1
        order by t.orderno desc;
     
 elsif p_funcCode = 'OrderNoSelect' then -- ���ݵ�λ���ƺ���ϵ�� ģ����ѯ��������ż���λ
       open p_cursor for
       select t.orderno ,t.groupname from TF_F_ORDERFORM t where
       (p_var1 is null or p_var1 = '' or t.groupname like '%' || p_var1 ||'%') and
       (p_var2 is null or p_var2 = '' or t.name like '%' || p_var2 || '%') and
       (p_var3 is null or p_var3 = '' or t.ORDERSTATE = p_var3)
       and usetag = '1'
       order by t.orderno desc;
        /*
        select t.orderno ,t.groupname from tf_f_order t where
        (p_var1 is null or t.groupname like '%' || p_var1 ||'%') and
        (p_var2 is null or t.name like '%' || p_var2 || '%') and
        t.result = p_var3
        order by t.orderno desc;
        */
 elsif p_funcCode = 'OrderContactPersonSelect' then --���ݵ�λ���Ʋ������µ���ϵ����Ϣ
      open p_cursor for
        select t.name,t.phoneno,t.paperno,max(t.buycarddate) from TF_F_COMBUYCARDREG t where t.companyno = p_var1 
        group by t.name,t.phoneno,t.paperno;
 elsif p_funcCode = 'QueryOrderContactPerson' then --���ݵ�λ���Ʋ������µĶ�����ϵ����Ϣ
      open p_cursor for
        select a.COMPANYPAPERTYPE,a.COMPANYPAPERNO,a.NAME,a.PAPERTYPE,a.PAPERNO IDCARDNO,a.PHONENO PHONE,a.ADDRESS,a.EMAIL,a.OUTBANK,a.OUTACCT,a.COMPANYMANAGERNO,a.COMPANYENDTIME,a.COMPANYNO,a.securityvalue
        from
       (
        select n.COMPANYPAPERTYPE,n.COMPANYPAPERNO,n.NAME,n.PAPERTYPE,n.PAPERNO,n.PHONENO,n.ADDRESS,n.EMAIL,m.OUTBANK,m.OUTACCT,n.COMPANYMANAGERNO,n.COMPANYENDTIME,n.COMPANYNO,n.securityvalue/100.0 securityvalue
        from TF_B_COMBUYCARD t,TF_F_COMBUYCARDREG m,TD_M_BUYCARDCOMINFO n
        where t.COMPANYNAME    = p_var1 
        and   t.ID = m.ID
        and   m.COMPANYNO = n.COMPANYNO
        and   t.OPERATETYPECODE in ('01','02')--01������02�޸�
        order by t.OPERATETIME desc
        ) a
        where rownum = 1
        ;        
 elsif p_funcCode = 'UnActivateChargeCardSelect' then --����δ����ĳ�ֵ����Ϣ
         for V_CUR in 
           ( select t.ORDERNO,t.FROMCARDNO,t.TOCARDNO ,t.VALUE/100.0 VALUE,
             t.COUNT,t.SUM/100.0 SUM,o.groupname,o.TRANSACTOR || ':' || staff.staffname TRANSACTOR, 
             to_char(o.INPUTTIME,'yyyyMMdd') INPUTTIME 
             from TF_F_CHARGECARDORDER t ,TF_F_ORDER o , td_m_insidestaff staff
             where t.orderno = o.orderno 
             and o.RESULT = '1' 
             and o.TRANSACTOR = staff.staffno
             and (o.rsrv1 is null or o.rsrv1 != '1'))
           loop
             
             select count(*) into v_count from TD_XFC_INITCARD A 
             where  A.XFCARDNO between  V_CUR.fromcardno and V_CUR.tocardno and A.CARDSTATECODE = '3';  --����״̬
             if (v_count > 0 and  v_count != V_CUR.COUNT) then --���ڿ����ǳ���״̬�����������п��Ŷ��ǳ���״̬
                   insert into TMP_UnActivateChargeCard (F0,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11) values
                   (
                       '0',
                       '�п��Ų��ǳ���״̬',
                       V_CUR.ORDERNO,
                       V_CUR.FROMCARDNO,
                       V_CUR.TOCARDNO,
                       V_CUR.VALUE,
                       V_CUR.COUNT,
                       V_CUR.SUM,
                       V_CUR.GROUPNAME,
                       V_CUR.TRANSACTOR,
                       V_CUR.INPUTTIME,
                       p_var1
                   );
             elsif (v_count = V_CUR.COUNT)  then  -- ���п��Ŷ��ǳ���״̬
                  insert into TMP_UnActivateChargeCard (F0,f1,f2,f3,f4,f5,f6,f7,f8,f9,f10,f11) values
                   (
                       '1',
                       'OK',
                       V_CUR.ORDERNO,
                       V_CUR.FROMCARDNO,
                       V_CUR.TOCARDNO,
                       V_CUR.VALUE,
                       V_CUR.COUNT,
                       V_CUR.SUM,
                       V_CUR.GROUPNAME,
                       V_CUR.TRANSACTOR,
                       V_CUR.INPUTTIME,
                       p_var1
                   );
             end if;             
           end loop;
        open p_cursor for
        select F0 ValidResult,  F2 ORDERNO, F3 FROMCARDNO, F4 TOCARDNO , F5 VALUE,
        F6 COUNT,F7 SUM,F8 groupname,F9 TRANSACTOR, F10 INPUTTIME
        from TMP_UnActivateChargeCard where f11 = p_var1 order by F10 desc;
 elsif  p_funcCode = 'InitOrderState' then -- ��ʼ������״̬ add by shil
    open p_cursor for
    select CODEDESC,CODEVALUE
    from   TD_M_RMCODING
    where  TABLENAME = 'TF_F_ORDERFORM'
    and    COLNAME   = 'ORDERSTATE';        
    
    
elsif p_funcCode = 'AccountQueryAndMaintainQuery' then  --�˵���ѯ
    open p_cursor for
    SELECT a.checkid,a.tradedate,a.money/100.0 money,a.openbank,a.accountname,a.accountnumber,a.explain,a.summary,a.postscript,a.toaccountbank,a.toaccountnumber,a.usedmoney/100.0 usedmoney,a.leftmoney/100.0  leftmoney FROM TF_F_CHECK a
    WHERE  (p_var1 IS NULL OR p_var1 = '' OR p_var1 = a.ACCOUNTNAME)  --����
    AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.MONEY)       --���
    AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.CHECKSTATE)   --�˵�״̬
    AND    (p_var4 IS NULL OR p_var4 = '' OR p_var4 = a.UPDATESTAFFNO)--¼��Ա��
    AND    (p_var5 IS NULL OR p_var5 = '' OR a.TRADEDATE >= p_var5)
    AND    (p_var6 IS NULL OR p_var6 = '' OR a.TRADEDATE <= p_var6)
    AND    (p_var7 IS NULL OR p_var7 = '' OR p_var7 = a.ACCOUNTNUMBER)--�Է��˺�
    AND    (p_var8 IS NULL OR p_var8 = '' OR a.TOACCOUNTBANK like '%'||p_var8||'%' )--��������
     AND    (p_var9 IS NULL OR p_var9 = '' OR (p_var9 ='1' AND a.leftmoney>0) OR (p_var9 ='2' AND a.leftmoney=0))--ʣ����
    AND     a.usetag='1'
    ORDER BY a.checkid desc;
elsif p_funcCode = 'AccountHasLeftQuery' then  --��ѯ�˵����������ҳ�棩
    open p_cursor for
    SELECT a.checkid         , a.tradedate , a.money/100.0 money, a.openbank   , a.accountname   ,
           a.accountnumber   , a.explain   , a.summary          , a.postscript , a.toaccountbank ,
           a.toaccountnumber , a.usedmoney/100.0 usedmoney, a.leftmoney/100.0 leftmoney
    FROM TF_F_CHECK a
    WHERE  (p_var1 IS NULL OR p_var1 = '' OR a.ACCOUNTNAME like '%'||p_var1||'%')  --����
    AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.MONEY)       --���
    AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.CHECKSTATE)   --�˵�״̬
    AND    (p_var4 IS NULL OR p_var4 = '' OR p_var4 = a.UPDATESTAFFNO)--¼��Ա��
    AND    (p_var5 IS NULL OR p_var5 = '' OR a.TRADEDATE >= p_var5)
    AND    (p_var6 IS NULL OR p_var6 = '' OR a.TRADEDATE <= p_var6)
    AND    (p_var7 IS NULL OR p_var7 = '' OR p_var7 = a.ACCOUNTNUMBER)--�Է��˺�
    AND     a.usetag='1'
    AND    LEFTMONEY <> 0
    ORDER BY a.checkid desc
    ; 
elsif p_funcCode = 'QueryOrderForMakeOrComfirm' then  --��ѯ�����������ƿ�/ȷ��ҳ�棩
    open p_cursor for
    SELECT a.ORDERNO   , 
           a.GROUPNAME , 
           a.NAME      , 
           a.IDCARDNO  ,
           a.PHONE     , 
           a.TOTALMONEY/100.0  TOTALMONEY ,
           a.TRANSACTOR||':'||b.STAFFNAME TRANSACTOR , 
           a.INPUTTIME , 
           a.FINANCEAPPROVERNO||':'||c.STAFFNAME FINANCEAPPROVERNO , 
           a.FINANCEAPPROVERTIME , 
           nvl(a.CASHGIFTMONEY,0) CASHGIFTMONEY,
           nvl(a.CHARGECARDMONEY,0) CHARGECARDMONEY,
           nvl(a.SZTCARDMONEY,0) SZTCARDMONEY,
           nvl(a.LVYOUMONEY,0) LVYOUMONEY,
           nvl(a.CUSTOMERACCMONEY,0) CUSTOMERACCMONEY,
           nvl(a.CUSTOMERACCHASMONEY,0) CUSTOMERACCHASMONEY,
           nvl(a.READERMONEY,0) READERMONEY,
           nvl(a.GARDENCARDMONEY,0) GARDENCARDMONEY,
           nvl(a.RELAXCARDMONEY,0) RELAXCARDMONEY,
           DECODE(a.ISRELATED,'0','0:�쿨����','1','1:�ƿ�����',a.ISRELATED) ISRELATED ,
           DECODE(a.ORDERSTATE,'03','03:��ɷ���','04','04:�ƿ���', a.ORDERSTATE) ORDERSTATE
    FROM TF_F_ORDERFORM a,TD_M_INSIDESTAFF b,TD_M_INSIDESTAFF c
    WHERE  (p_var1 IS NULL OR p_var1 = '' OR p_var1 = a.GROUPNAME)
    AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.NAME)
    AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.TOTALMONEY)
    AND    (p_var4 IS NULL OR p_var4 = '' OR a.TRANSACTOR IN (SELECT STAFFNO FROM TD_M_INSIDESTAFF WHERE DEPARTNO = p_var4))
    AND    (p_var5 IS NULL OR p_var5 = '' OR a.TRANSACTOR = p_var5)
    AND    (p_var6 IS NULL OR p_var6 = '' OR TO_CHAR(a.INPUTTIME,'yyyymmdd') >= p_var6)
    AND    (p_var7 IS NULL OR p_var7 = '' OR TO_CHAR(a.INPUTTIME,'yyyymmdd') <= p_var7)
    AND    (p_var8 IS NULL OR p_var8 = '' OR p_var8 = a.FINANCEAPPROVERNO)
    AND    (p_var9 IS NULL OR p_var9 = '' OR p_var9 = a.ISRELATED)
    AND     p_var10 = a.GETDEPARTMENT
    AND     a.TRANSACTOR = b.STAFFNO(+)
    AND     a.FINANCEAPPROVERNO = c.STAFFNO(+)
    AND     a.usetag='1'
    AND     a.ORDERSTATE in('03','04')
    ORDER BY a.ORDERNO desc
    ; 
elsif p_funcCode = 'QueryOrderForCardChange' then  --��ѯ������������������
    open p_cursor for
    SELECT a.ORDERNO   , 
           a.GROUPNAME , 
           a.NAME      , 
           a.IDCARDNO  ,
           a.PHONE     , 
           a.TOTALMONEY/100.0  TOTALMONEY ,
           a.TRANSACTOR||':'||b.STAFFNAME TRANSACTOR , 
           a.INPUTTIME , 
           a.FINANCEAPPROVERNO||':'||c.STAFFNAME FINANCEAPPROVERNO , 
           a.FINANCEAPPROVERTIME , 
           nvl(a.CASHGIFTMONEY,0) CASHGIFTMONEY,
           nvl(a.CHARGECARDMONEY,0) CHARGECARDMONEY,
           nvl(a.SZTCARDMONEY,0) SZTCARDMONEY,
           nvl(a.LVYOUMONEY,0) LVYOUMONEY,
           nvl(a.CUSTOMERACCMONEY,0) CUSTOMERACCMONEY,
           nvl(a.CUSTOMERACCHASMONEY,0) CUSTOMERACCHASMONEY,
           nvl(a.READERMONEY,0) READERMONEY,
           nvl(a.GARDENCARDMONEY,0) GARDENCARDMONEY,
           nvl(a.RELAXCARDMONEY,0) RELAXCARDMONEY,
           DECODE(a.ISRELATED,'0','0:�쿨����','1','1:�ƿ�����',a.ISRELATED) ISRELATED ,
           '�������' ORDERSTATE
    FROM TF_F_ORDERFORM a,TD_M_INSIDESTAFF b,TD_M_INSIDESTAFF c
    WHERE  (p_var1 IS NULL OR p_var1 = '' OR p_var1 = a.GROUPNAME)
    AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.NAME)
    AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.TOTALMONEY)
    AND    (p_var4 IS NULL OR p_var4 = '' OR a.TRANSACTOR IN (SELECT STAFFNO FROM TD_M_INSIDESTAFF WHERE DEPARTNO = p_var4))
    AND    (p_var5 IS NULL OR p_var5 = '' OR a.TRANSACTOR = p_var5)
    AND    (p_var6 IS NULL OR p_var6 = '' OR TO_CHAR(a.INPUTTIME,'yyyymmdd') >= p_var6)
    AND    (p_var7 IS NULL OR p_var7 = '' OR TO_CHAR(a.INPUTTIME,'yyyymmdd') <= p_var7)
    AND     p_var8 = a.GETDEPARTMENT
    AND     a.TRANSACTOR = b.STAFFNO(+)
    AND     a.FINANCEAPPROVERNO = c.STAFFNO(+)
    AND     a.usetag='1'
    AND     a.ORDERSTATE = '07'
    ORDER BY a.ORDERNO desc
    ;     
elsif p_funcCode = 'GotCardOrderQuery' then --����������ѯ������ɵĶ���
    open p_cursor for
    select 
      t.orderno,
      t.groupname,
      t.name,
      t.idcardno, 
      t.phone,
      t.totalmoney/100.0 totalmoney,
      t.transactor || ':' || m.staffname transactor,
      n.staffno || ':' || n.staffname FINANCEAPPROVERNO,
      t.financeremark,
      t.cashgiftmoney/100.0 cashgiftmoney,
      NVL(t.CHARGECARDMONEY,0)/100.0 CHARGECARDMONEY,
      t.customeraccmoney/100.0 customeraccmoney,
      to_char(t.inputtime,'yyyymmdd') inputtime,
      t.remark,
      t.isrelated,
      DECODE(t.ORDERSTATE,'07','07:�������','10','10:�쿨������',t.ORDERSTATE)  ORDERSTATE 
      from TF_F_ORDERFORM t
      inner join td_m_insidestaff m on t.transactor = m.staffno
      inner join td_m_insidestaff n on t.financeapproverno = n.staffno
      where
      (p_var1 is null or t.groupname = p_var1) and
      (p_var2 is null or t.name = p_var2) and
      (p_var3 is null or t.transactor = p_var3) and
      (p_var4 is null or t.totalmoney = p_var4) and
      (p_var5 is null or to_char(t.inputtime,'yyyymmdd') >= p_var5) and
      (p_var6 is null or to_char(t.inputtime,'yyyymmdd') <= p_var6) and
      (p_var7 is null or m.departno = p_var7) and
      t.GETDEPARTMENT = p_var8 and
      t.ORDERSTATE in( '07','10') order by t.orderno desc;
elsif p_funcCode = 'ConfirmOrderQuery' then --����������ѯ�������ȷ�ϵĶ���
    open p_cursor for
    select 
    t.orderno,
    t.groupname,
    t.name,
    t.idcardno, 
    t.phone,t.totalmoney/100.0 totalmoney,
      t.transactor || ':' || m.staffname transactor,
       n.staffno || ':' || n.staffname FINANCEAPPROVERNO,
       t.financeremark,
      to_char(t.inputtime,'yyyymmdd') inputtime,
      t.cashgiftmoney/100.0 cashgiftmoney,
      t.customeraccmoney/100.0 customeraccmoney,
      t.remark,
      'ȷ�����' ORDERSTATE 
      from TF_F_ORDERFORM t
      inner join td_m_insidestaff m on t.transactor = m.staffno
       inner join td_m_insidestaff n on t.financeapproverno = n.staffno
       where
      (p_var1 is null or t.groupname = p_var1) and
      (p_var2 is null or t.name = p_var2) and
      (p_var3 is null or t.transactor = p_var3) and
      (p_var4 is null or t.totalmoney = p_var4) and
      (p_var5 is null or to_char(t.inputtime,'yyyymmdd') >= p_var5) and
      (p_var6 is null or to_char(t.inputtime,'yyyymmdd') <= p_var6) and
      (p_var7 is null or m.departno = p_var7) and
      t.GETDEPARTMENT = p_var8 and
      t.ORDERSTATE = '08' order by t.orderno desc;    
elsif p_funcCode = 'QueryOrderMadeCard' then--����������ѯ�ƿ���ɵĶ�����Ϣ�������쿨ҳ�棩
       open p_cursor for
       select  t.ORDERNO,
        t.GROUPNAME,
        t.NAME,    --��ϵ��
        t.IDCARDNO,
        t.PHONE,
        t.totalmoney/100.0 totalmoney,
        t.TRANSACTOR || ':' || m.staffname transactor,   --������
        to_char(t.INPUTTIME,'yyyymmdd') inputtime ,--¼��ʱ��
        '�ƿ����' ORDERSTATE,
        n.staffno || ':' || n.staffname FINANCEAPPROVERNO,
        t.financeremark,
        t.remark,
        t.cashgiftmoney/100.0 cashgiftmoney,
        t.customeraccmoney/100.0 customeraccmoney,
        k.outbank,
        k.outacct,
        DECODE(t.isrelated,'0','0:�쿨����','1','1:�ƿ�����',t.ISRELATED) ISRELATED 
        from TF_F_ORDERFORM t,td_m_insidestaff m,td_m_insidestaff n,TF_F_COMBUYCARDREG k
        where t.transactor = m.staffno
        and t.financeapproverno = n.staffno
        and t.orderno = k.remark(+)
        and t.USETAG = '1'
        and t.orderstate IN ('05','06')
        and (p_var1 IS NULL OR p_var1 = '' OR p_var1 =t.groupname)
        and (p_var2 IS NULL OR p_var2 = '' OR p_var2 =t.name)
        and (p_var3 IS NULL OR p_var3 = '' OR p_var3 =t.transactor)  --������
        and (p_var4 IS NULL OR p_var4 = '' OR p_var4 =t.totalmoney)  --���
        and (p_var5 IS NULL OR p_var5 = '' OR to_char(t.inputtime,'yyyymmdd')>= p_var5)--¼��ʱ��
        and (p_var6 IS NULL OR p_var6 = '' OR to_char(t.inputtime,'yyyymmdd')<= p_var6)
        and (p_var7 IS NULL OR p_var7 = '' OR p_var7 = m.departno)
        and p_var8 = t.GETDEPARTMENT
        and (p_var9 IS NULL OR p_var9 = '' OR p_var9 = k.outbank)
        and (p_var10 IS NULL OR p_var10 = '' OR p_var10 = k.outacct)
        order by t.orderno desc;   
elsif p_funcCode = 'QueryOrderDailyReport' then--����������ѯ�����ձ��������ձ�ҳ�棩
       open p_cursor for
       select CARDTYPE,OPERATEDEPARTNO,STAFF,ORDERNO,GROUPNAME,OPERATETIME,INPUTSTAFF,ORDERCOUNT,SUM(MONEY) MONEY, sum(COUNTS) CARDNUM
       from(
       select t.orderno,
       '����('||to_char(i.VALUE/100.0)||'Ԫ)' CARDTYPE,--��Ƭ����
        l.departname OPERATEDEPARTNO,--����
        m.staffname STAFF, --ӪҵԱ
        t.GROUPNAME,--��λ����
        to_char(t.OPERATETIME,'yyyymmdd') OPERATETIME,--�ƿ�����
        n.staffname INPUTSTAFF,--������
        i.COUNT ||'��' AS ORDERCOUNT ,--��������
        MONEY/100.0 MONEY,--���
        1 COUNTS
        from TF_F_ORDERTRADE t,TF_F_ORDERFORM s,td_m_insidestaff m,td_m_insidestaff n,td_m_insidedepart l,TF_F_CASHGIFTORDER i,
             (select regioncode from td_m_insidedepart where departno = p_var11) F
        where t.OPERATESTAFFNO = m.staffno
        and   t.makecardtype = i.VALUE
        and s.transactor = n.staffno
        and t.operatedepartno = l.departno
        and t.ORDERNO = s.ORDERNO
        and t.ORDERNO = i.ORDERNO(+)
        and t.TRADECODE ='07'
        and t.canceltag = '0'
        and t.Maketype='1'--����
        and (p_var1 IS NULL OR p_var1 = '' OR p_var1 =t.groupname)
        and (p_var2 IS NULL OR p_var2 = '' OR p_var2 =t.name)
        and (p_var3 IS NULL OR p_var3 = '' OR p_var3 =s.transactor)  --������
        and (p_var4 IS NULL OR p_var4 = '' OR p_var4 = t.orderno) --������
        and (p_var5 IS NULL OR p_var5 = '' OR to_char(s.inputtime,'yyyymmdd')>= p_var5)--ȷ��ʱ��
        and (p_var6 IS NULL OR p_var6 = '' OR to_char(s.inputtime,'yyyymmdd')<= p_var6)
        and (p_var7 IS NULL OR p_var7 = '' OR p_var7 = l.departno) --�ƿ�����
        and (p_var8 IS NULL OR p_var8 = '' OR p_var8 = t.OPERATESTAFFNO) --�ƿ�Ա��
        and (p_var9 IS NULL OR p_var9 = '' OR p_var9 = s.managerdept) --�ͻ�������
        and (p_var10 IS NULL OR p_var10 = '' OR p_var10 = s.manager) --�ͻ�����
       AND (L.Regioncode IN (select b.regioncode from td_m_regioncode b where b.regionname =(select r.regionname from td_m_regioncode r where r.regioncode = F.REGIONCODE)) or F.REGIONCODE is null)
        union all
        select t.ORDERNO ,
        'B��('||cc.CARDSURFACENAME||')'  CARDTYPE,--��Ƭ����
        l.departname OPERATEDEPARTNO,--����
        m.staffname STAFF, --ӪҵԱ
        t.GROUPNAME,--��λ����
        to_char(t.OPERATETIME,'yyyymmdd') OPERATETIME,--�ƿ�����
        n.staffname INPUTSTAFF,--¼��Ա��
        k.Count ||'��' AS ORDERCOUNT ,--��������
        MONEY/100.0 MONEY,--���
        1 COUNTS
        from TF_F_ORDERTRADE t,TF_F_ORDERFORM s,td_m_insidestaff m,td_m_insidestaff n,td_m_insidedepart l,TF_F_SZTCARDORDER k,
        (select c.CARDSURFACENAME,CARDSURFACECODE from TD_M_CARDSURFACE c  )cc,
        (select regioncode from td_m_insidedepart where departno = p_var11) F
        where t.OPERATESTAFFNO = m.staffno
        and s.transactor = n.staffno
        and t.operatedepartno = l.departno
        and t.ORDERNO = s.ORDERNO
        and t.makecardtype = k.CARDTYPECODE
        and k.CARDTYPECODE = cc.CARDSURFACECODE
        and t.ORDERNO = k.ORDERNO(+)
        and t.TRADECODE ='07'
        and t.canceltag = '0'
        and t.Maketype='2'--����B��
        and (p_var1 IS NULL OR p_var1 = '' OR p_var1 =t.groupname)
        and (p_var2 IS NULL OR p_var2 = '' OR p_var2 =t.name)
        and (p_var3 IS NULL OR p_var3 = '' OR p_var3 =s.transactor)  --������
        and (p_var4 IS NULL OR p_var4 = '' OR p_var4 = t.orderno) --������
        and (p_var5 IS NULL OR p_var5 = '' OR to_char(s.inputtime,'yyyymmdd')>= p_var5)--ȷ��ʱ��
        and (p_var6 IS NULL OR p_var6 = '' OR to_char(s.inputtime,'yyyymmdd')<= p_var6)
        and (p_var7 IS NULL OR p_var7 = '' OR p_var7 = l.departno) --�ƿ�����
        and (p_var8 IS NULL OR p_var8 = '' OR p_var8 = t.OPERATESTAFFNO) --�ƿ�Ա��
        and (p_var9 IS NULL OR p_var9 = '' OR p_var9 = s.managerdept) --�ͻ�������
        and (p_var10 IS NULL OR p_var10 = '' OR p_var10 = s.manager) --�ͻ�����
        AND (L.Regioncode IN (select b.regioncode from td_m_regioncode b where b.regionname =(select r.regionname from td_m_regioncode r where r.regioncode = F.REGIONCODE)) or F.REGIONCODE is null)
        union all
        select t.ORDERNO ,
        tt.value  CARDTYPE,--��Ƭ����
        l.departname OPERATEDEPARTNO,--����
        m.staffname STAFF, --ӪҵԱ
        t.GROUPNAME,--��λ����
        to_char(t.OPERATETIME,'yyyymmdd') OPERATETIME,--�ƿ�����
        n.staffname INPUTSTAFF,--¼��Ա��
        j.count ||'��' AS ORDERCOUNT ,--��������
        MONEY/100.0 MONEY,--���
        to_number(nvl(t.RSRV3,0)) COUNTS
        from TF_F_ORDERTRADE t,TF_F_ORDERFORM s,td_m_insidestaff m,td_m_insidestaff n,td_m_insidedepart l,TF_F_CHARGECARDORDER j,
        (select '��ֵ��('||to_char(e.MONEY/100.0)||')Ԫ' value ,valuecode from TP_XFC_CARDVALUE e ) tt,
        (select regioncode from td_m_insidedepart where departno = p_var11) F
        where t.OPERATESTAFFNO = m.staffno
        and tt.valuecode=t.makecardtype
        and s.transactor = n.staffno
        and t.operatedepartno = l.departno
        and t.ORDERNO = s.ORDERNO
        and t.ORDERNO = j.ORDERNO(+)
        and j.valuecode=tt.valuecode
        and t.TRADECODE ='07'
        and t.canceltag = '0'
        and t.Maketype='3'--��ֵ��
        and (p_var1 IS NULL OR p_var1 = '' OR p_var1 =t.groupname)
        and (p_var2 IS NULL OR p_var2 = '' OR p_var2 =t.name)
        and (p_var3 IS NULL OR p_var3 = '' OR p_var3 =s.transactor)  --������
        and (p_var4 IS NULL OR p_var4 = '' OR p_var4 = t.orderno) --������
        and (p_var5 IS NULL OR p_var5 = '' OR to_char(s.inputtime,'yyyymmdd')>= p_var5)--ȷ��ʱ��
        and (p_var6 IS NULL OR p_var6 = '' OR to_char(s.inputtime,'yyyymmdd')<= p_var6)
        and (p_var7 IS NULL OR p_var7 = '' OR p_var7 = l.departno) --�ƿ�����
        and (p_var8 IS NULL OR p_var8 = '' OR p_var8 = t.OPERATESTAFFNO) --�ƿ�Ա��
        and (p_var9 IS NULL OR p_var9 = '' OR p_var9 = s.managerdept) --�ͻ�������
        and (p_var10 IS NULL OR p_var10 = '' OR p_var10 = s.manager) --�ͻ�����
        AND (L.Regioncode IN (select b.regioncode from td_m_regioncode b where b.regionname =(select r.regionname from td_m_regioncode r where r.regioncode = F.REGIONCODE)) or F.REGIONCODE is null)
        union all
        select t.ORDERNO ,
       'ר���˻�' AS CARDTYPE,--��Ƭ����
        l.departname OPERATEDEPARTNO,--����
        m.staffname STAFF, --ӪҵԱ
        t.GROUPNAME,--��λ����
        to_char(t.OPERATETIME,'yyyymmdd') OPERATETIME,--�ƿ�����
        n.staffname INPUTSTAFF,--¼��Ա��
        t.CUSTOMERACCMONEY/100.0 ||'Ԫ' AS ORDERCOUNT ,--��������
        MONEY/100.0 MONEY,--���
        1 COUNTS
        from TF_F_ORDERTRADE t,TF_F_ORDERFORM s,td_m_insidestaff m,td_m_insidestaff n,td_m_insidedepart l,
             (select regioncode from td_m_insidedepart where departno = p_var11) F
        where t.OPERATESTAFFNO = m.staffno
        and s.transactor = n.staffno
        and t.operatedepartno = l.departno
        and t.ORDERNO = s.ORDERNO
        and t.TRADECODE ='07'
        and t.canceltag = '0'
        and t.Maketype='4'--ר���˻�
        and (p_var1 IS NULL OR p_var1 = '' OR p_var1 =t.groupname)
        and (p_var2 IS NULL OR p_var2 = '' OR p_var2 =t.name)
        and (p_var3 IS NULL OR p_var3 = '' OR p_var3 =s.transactor)  --������
        and (p_var4 IS NULL OR p_var4 = '' OR p_var4 = t.orderno) --������
        and (p_var5 IS NULL OR p_var5 = '' OR to_char(s.inputtime,'yyyymmdd')>= p_var5)--ȷ��ʱ��
        and (p_var6 IS NULL OR p_var6 = '' OR to_char(s.inputtime,'yyyymmdd')<= p_var6)
        and (p_var7 IS NULL OR p_var7 = '' OR p_var7 = l.departno) --�ƿ�����
        and (p_var8 IS NULL OR p_var8 = '' OR p_var8 = t.OPERATESTAFFNO) --�ƿ�Ա��
        and (p_var9 IS NULL OR p_var9 = '' OR p_var9 = s.managerdept) --�ͻ�������
        and (p_var10 IS NULL OR p_var10 = '' OR p_var10 = s.manager) --�ͻ�����
        AND (L.Regioncode IN (select b.regioncode from td_m_regioncode b where b.regionname =(select r.regionname from td_m_regioncode r where r.regioncode = F.REGIONCODE)) or F.REGIONCODE is null)
        union all
        select t.ORDERNO ,
        '������'  CARDTYPE,--��Ƭ����
        l.departname OPERATEDEPARTNO,--����
        m.staffname STAFF, --ӪҵԱ
        t.GROUPNAME,--��λ����
        to_char(t.OPERATETIME,'yyyymmdd') OPERATETIME,--�ƿ�����
        n.staffname INPUTSTAFF,--¼��Ա��
        j.count ||'��' AS ORDERCOUNT ,--��������
        MONEY/100.0 MONEY,--���
        to_number(nvl(t.RSRV3,0)) COUNTS
        from TF_F_ORDERTRADE t,TF_F_ORDERFORM s,td_m_insidestaff m,td_m_insidestaff n,td_m_insidedepart l,TF_F_READERORDER j,
             (select regioncode from td_m_insidedepart where departno = p_var11) F
        where t.OPERATESTAFFNO = m.staffno
        and s.transactor = n.staffno
        and t.operatedepartno = l.departno
        and t.ORDERNO = s.ORDERNO
        and t.ORDERNO = j.ORDERNO(+)
        and t.TRADECODE ='07'
        and t.canceltag = '0'
        and t.Maketype='5'--������
        and (p_var1 IS NULL OR p_var1 = '' OR p_var1 =t.groupname)
        and (p_var2 IS NULL OR p_var2 = '' OR p_var2 =t.name)
        and (p_var3 IS NULL OR p_var3 = '' OR p_var3 =s.transactor)  --������
        and (p_var4 IS NULL OR p_var4 = '' OR p_var4 = t.orderno) --������
        and (p_var5 IS NULL OR p_var5 = '' OR to_char(s.inputtime,'yyyymmdd')>= p_var5)--ȷ��ʱ��
        and (p_var6 IS NULL OR p_var6 = '' OR to_char(s.inputtime,'yyyymmdd')<= p_var6)
        and (p_var7 IS NULL OR p_var7 = '' OR p_var7 = l.departno) --�ƿ�����
        and (p_var8 IS NULL OR p_var8 = '' OR p_var8 = t.OPERATESTAFFNO) --�ƿ�Ա��
        and (p_var9 IS NULL OR p_var9 = '' OR p_var9 = s.managerdept) --�ͻ�������
        and (p_var10 IS NULL OR p_var10 = '' OR p_var10 = s.manager) --�ͻ�����
        AND (L.Regioncode IN (select b.regioncode from td_m_regioncode b where b.regionname =(select r.regionname from td_m_regioncode r where r.regioncode = F.REGIONCODE)) or F.REGIONCODE is null)
        )
        group by CARDTYPE,OPERATEDEPARTNO,STAFF,ORDERNO,GROUPNAME,OPERATETIME,INPUTSTAFF,ORDERCOUNT
        order by ORDERNO desc; 
        
elsif p_funcCode = 'QueryBillImport' then
      BEGIN
      for v_c in (SELECT f0 ,f1 ,f2 ,f3 ,f4 ,f5 ,f6 ,f7 ,f8 ,f9 ,f11 from TMP_COMMON where f10 = p_var1) loop
        select count(*) INTO V_COUNT 
        from  TF_F_CHECK 
        where TRADEDATE       = v_c.f0 --��������
        and   MONEY           = v_c.f1 --������
        and  (OPENBANK        = v_c.f2 OR (OPENBANK        IS NULL AND v_c.f2 IS NULL))--�Է�������
        and  (ACCOUNTNAME     = v_c.f3 OR (ACCOUNTNAME     IS NULL AND v_c.f3 IS NULL))--�Է�����
        and  (ACCOUNTNUMBER   = v_c.f4 OR (ACCOUNTNUMBER   IS NULL AND v_c.f4 IS NULL))--�Է��ʺ�
        and  (EXPLAIN         = v_c.f5 OR (EXPLAIN         IS NULL AND v_c.f5 IS NULL))--����˵��
        and  (SUMMARY         = v_c.f6 OR (SUMMARY         IS NULL AND v_c.f6 IS NULL))--����ժҪ
        and  (POSTSCRIPT      = v_c.f7 OR (POSTSCRIPT      IS NULL AND v_c.f7 IS NULL))--���׸���
        and  (TOACCOUNTBANK   = v_c.f8 OR (TOACCOUNTBANK   IS NULL AND v_c.f8 IS NULL))--��������
        and  (TOACCOUNTNUMBER = v_c.f9 OR (TOACCOUNTNUMBER IS NULL AND v_c.f9 IS NULL))--�����ʺ�
        and   USETAG          = '1';
        
        IF V_COUNT > 0 THEN
            UPDATE TMP_COMMON SET f12 = '������ͬ��¼' WHERE f10 = p_var1 AND f11 = V_C.f11 ;
        ELSE    
            UPDATE TMP_COMMON SET f12 = 'OK' WHERE f10 = p_var1 AND f11 = V_C.f11;
        END IF;
      end loop;
      END;
      open p_cursor for
      select f0, to_number(f1)/100.0 f1 ,f2 ,f3 ,f4 ,f5 ,f6 ,f7 ,f8 ,f9 ,f12 VALIDRET
      from TMP_COMMON where f10 = p_var1;
      
elsif p_funcCode = 'AccountSelectByOrderNo' then --���ݶ����Ų�ѯ�������˵���Ϣ
      open p_cursor for
      select A.Toaccountbank, substr(A.TOACCOUNTNUMBER,length(A.TOACCOUNTNUMBER)-3,4) TOACCOUNTNUMBER, 
      to_char(B.UPDATETIME,'yyyymmdd') UPDATETIME, B.MONEY/100.0 MONEY ,TRADEDATE 
      from TF_F_CHECK A, TF_F_ORDERCHECKRELATION B where A.CHECKID = B.CHECKID and B.ORDERNO = p_var1;

 elsif p_funcCode = 'AllOrderInfoSelectOld' then --����������ѯ���еĶ�����Ϣ
      open p_cursor for
        select t.orderno,
        t.groupname,
        t.name,
        t.idcardno, 
        t.phone,
        t.totalmoney/100.0 totalmoney,
        t.TOTALCHARGECASHGIFT/100.0 TOTALCHARGECASHGIFT,
        t.financeapproverno || ' ' || t.financeapprovername approver,
        t.transactor || ':' || m.staffname transactor,
        to_char(t.inputtime,'yyyymmdd') inputtime,
        t.remark,t.financeremark,
        t.invoicecount,
        t.invoicetotalmoney/100.0 invoicetotalmoney,
        decode(t.result,'0','δ����','1','����ͨ��','2','��������',t.result) result 
        from tf_f_order t
        inner join td_m_insidestaff m on t.transactor = m.staffno
        where
        (p_var1 is null or t.groupname = p_var1) and
        (p_var2 is null or t.name = p_var2) and
        (p_var3 is null or t.transactor = p_var3) and
        (p_var4 is null or t.totalmoney = p_var4) and
        (p_var5 is null or to_char(t.inputtime,'yyyymmdd') >= p_var5) and
        (p_var6 is null or to_char(t.inputtime,'yyyymmdd') <= p_var6) and
        (p_var7 is null or t.result = p_var7) and
        (p_var8 is null or m.departno = p_var8) 
        order by t.orderno desc ;      

elsif  p_funcCode = 'AllOrderInfoSelectByOrderNoOld' then --�������õ��Ų�ѯ��������Ϣ
       open p_cursor for
          select t.orderno,
          t.groupname,
          t.name,
          t.idcardno, 
          t.phone,
          t.totalmoney/100.0 totalmoney,
          t.TOTALCHARGECASHGIFT/100.0 TOTALCHARGECASHGIFT,
          t.financeapproverno || ' ' || t.financeapprovername approver,
          t.transactor || ':' || m.staffname transactor,
          to_char(t.inputtime,'yyyymmdd') inputtime,
          t.remark,
          t.financeremark,
          t.invoicecount,
          t.invoicetotalmoney/100.0 invoicetotalmoney,
          decode(t.result,'0','δ����','1','����ͨ��','2','��������',t.result) result
          from tf_f_order t
          inner join td_m_insidestaff m on t.transactor = m.staffno
          where  orderno = p_var1;        
          
elsif  p_funcCode = 'OrderInfoOld' then
    open p_cursor for
       select * from tf_f_order t where t.orderno =  p_var1;	
elsif p_funcCode = 'ValidCompany' then
	open p_cursor for
	   SELECT nvl(COMPANYNO,'') valiCompany,COMPANYNAME 
	   FROM TD_M_BUYCARDCOMINFO 
	   WHERE COMPANYPAPERTYPE =  p_var1 AND COMPANYPAPERNO = p_var2;
elsif  p_funcCode = 'CashCardSectionNo' then--��ѯ���𿨿��Ŷ�
   open p_cursor for
   SELECT CARDNO ���� FROM TF_F_CASHGIFTRELATION WHERE ORDERNO = P_VAR1
   union 
   SELECT CARDNO ���� FROM TF_B_CASHGIFTRELATION WHERE ORDERNO = P_VAR1;
   
elsif  p_funcCode = 'ChargeCardSectionNo' then --��ѯ��ֵ�����Ŷ�
   open p_cursor for
   SELECT FROMCARDNO ��ʼ����,TOCARDNO �������� FROM TF_F_CHARGECARDRELATION WHERE ORDERNO = P_VAR1;
elsif  p_funcCode = 'SZTCardSectionNo' then --��ѯ����B�����Ŷ�
   open p_cursor for
   SELECT CARDNO ���� FROM TF_F_SZTCARDRELATION WHERE ORDERNO = P_VAR1;
elsif  p_funcCode = 'ReaderCardSectionNo' then --��ѯ���������Ŷ�
   open p_cursor for
   SELECT BEGINSERIALNUMBER ��ʼ����,ENDSERIALNUMBER �������� FROM TF_F_READERRELATION WHERE ORDERNO = P_VAR1;

elsif 	 p_funcCode = 'QueryUnitComBuyCardInfo' then  ---��λ������Ϣ��ѯ
    open p_cursor for
    select a.companyno,a.companyname,a.companypapertype,a.companypaperno,a.companymanagerno,a.companyendtime,
           a.name,a.papertype,a.paperno,a.paperenddate,a.phoneno,a.address,a.email,nvl2(c.appcallingcode,c.appcallingcode||':'||c.appcalling,null) appcalling,a.securityvalue/100.0 securityvalue,a.registeredcapital/100.0  registeredcapital
            from TD_M_BUYCARDCOMINFO a,TD_DEPTBAL_RELATION b,TD_M_APPCALLINGCODE c
    WHERE  a.operdept = B.DEPARTNO
    and    a.callingno = c.appcallingcode(+)
    AND    (p_var1 IS NULL OR p_var1 = '' OR p_var1 = a.name)
	  AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.companypapertype)
	  AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.paperno)
	  AND    (p_var4 IS NULL OR p_var4 = '' OR a.companyname like '%' ||p_var4||'%')
    AND    (p_var5 IS NULL OR p_var5 = '' OR  p_var5 = a.companypaperno)
    AND    P_VAR6 = B.DBALUNITNO
     order by a.companyno desc;
elsif 	 p_funcCode = 'QueryDeptComBuyCardInfo' then  ---��λ������Ϣ��ѯ
    open p_cursor for
    select a.companyno,a.companyname,a.companypapertype,a.companypaperno,a.companymanagerno,a.companyendtime,
           a.name,a.papertype,a.paperno,a.paperenddate,a.phoneno,a.address,a.email,nvl2(c.appcallingcode,c.appcallingcode||':'||c.appcalling,null) appcalling,a.securityvalue/100.0 securityvalue,a.registeredcapital/100.0  registeredcapital
            from TD_M_BUYCARDCOMINFO a,TD_M_APPCALLINGCODE c
    WHERE  (p_var1 IS NULL OR p_var1 = '' OR p_var1 = a.name)
	  AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.companypapertype)
	  AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.paperno)
	  AND    (p_var4 IS NULL OR p_var4 = '' OR a.companyname like '%' ||p_var4||'%')
    AND    (p_var5 IS NULL OR p_var5 = '' OR  p_var5 = a.companypaperno)
    AND    A.OPERDEPT = P_VAR6
    and    a.callingno = c.appcallingcode(+)
     order by a.companyno desc;
elsif 	 p_funcCode = 'QueryStaffComBuyCardInfo' then  ---��λ������Ϣ��ѯ
    open p_cursor for
    select a.companyno,a.companyname,a.companypapertype,a.companypaperno,a.companymanagerno,a.companyendtime,
           a.name,a.papertype,a.paperno,a.paperenddate,a.phoneno,a.address,a.email,nvl2(c.appcallingcode,c.appcallingcode||':'||c.appcalling,null) appcalling,a.securityvalue/100.0 securityvalue,a.registeredcapital/100.0  registeredcapital
            from TD_M_BUYCARDCOMINFO a,TD_M_APPCALLINGCODE c
    WHERE  (p_var1 IS NULL OR p_var1 = '' OR p_var1 = a.name)
	  AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.companypapertype)
	  AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.paperno)
	  AND    (p_var4 IS NULL OR p_var4 = '' OR a.companyname like '%' ||p_var4||'%')
    AND    (p_var5 IS NULL OR p_var5 = '' OR  p_var5 = a.companypaperno)
    AND    (P_VAR6 IS NULL OR P_VAR6 = '' OR P_VAR6 = A.OPERATOR)
    and    a.callingno = c.appcallingcode(+)
     order by a.companyno desc;

elsif 	 p_funcCode = 'QueryUnitPerBuyCardInfo' then  ---���˹�����Ϣ��ѯ
    open p_cursor for
    select a.papertype,a.paperno,a.name,a.birthday,a.sex,a.phoneno,a.address,a.email,a.paperenddate,
           a.nationality,a.job,a.securityvalue/100.0 securityvalue,a.registeredcapital/100.0 registeredcapital,nvl2(c.appcallingcode,c.appcallingcode||':'||c.appcalling,null) appcalling
    from TD_M_BUYCARDPERINFO a,TD_DEPTBAL_RELATION b,TD_M_APPCALLINGCODE c
    WHERE  a.operdept = B.DEPARTNO
    and    a.callingno = c.appcallingcode(+)
    AND    (p_var1 IS NULL OR p_var1 = '' OR a.name like '%'|| p_var1 ||'%')
	  AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.papertype)
	  AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.paperno)
    AND    p_var4 = B.DBALUNITNO
     order by a.operatetime;
elsif p_funcCode = 'QueryDeptPerBuyCardInfo' then
        --��ѯ���˹�����¼
    open p_cursor for
    select a.papertype,a.paperno,a.name,a.birthday,a.sex,a.phoneno,a.address,a.email,a.paperenddate,
           a.nationality,a.job,a.securityvalue/100.0 securityvalue,a.registeredcapital/100.0 registeredcapital,nvl2(c.appcallingcode,c.appcallingcode||':'||c.appcalling,null) appcalling
    from TD_M_BUYCARDPERINFO a,TD_M_APPCALLINGCODE c
    WHERE   (p_var1 IS NULL OR p_var1 = '' OR a.name like '%'|| p_var1 ||'%')
	  AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.papertype)
	  AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.paperno)
    AND    A.OPERDEPT = P_var4
    and    a.callingno = c.appcallingcode(+)
     order by a.operatetime;
elsif p_funcCode = 'QueryStaffPerBuyCardInfo' then
        --��ѯ���˹�����¼
    open p_cursor for
    select a.papertype,a.paperno,a.name,a.birthday,a.sex,a.phoneno,a.address,a.email,a.paperenddate,
           a.nationality,a.job,a.securityvalue/100.0 securityvalue,a.registeredcapital/100.0 registeredcapital,nvl2(c.appcallingcode,c.appcallingcode||':'||c.appcalling,null) appcalling
    from TD_M_BUYCARDPERINFO a,TD_M_APPCALLINGCODE c
    WHERE   (p_var1 IS NULL OR p_var1 = '' OR a.name like '%'|| p_var1 ||'%')
	  AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.papertype)
	  AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.paperno)
    AND    (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = A.OPERATOR)
    and    a.callingno = c.appcallingcode(+)
     order by a.operatetime;
elsif p_funcCode = 'QueryCheckRelationInfo' then --��ѯ����������Ϣ
    open p_cursor for
    select  b.checkid �˵���,b.openbank �Է�������,b.accountname �Է�����,b.accountnumber �Է��˺�,b.toaccountbank ��������,b.toaccountnumber �����ʺ�,a.money/100.0 ���,c.staffno||':'||c.staffname ���Ա��,a.updatetime ���ʱ��
    from TF_F_ORDERCHECKRELATION a,TF_F_CHECK b ,td_m_insidestaff c
    where a.checkid =b.checkid
    and a.updatestaffno = c.staffno(+)
    and p_var1 = a.orderno
    order by a.updatetime;
elsif p_funcCode = 'QueryCardRelationInfo' then --������Ҫ���������Ķ����Լ��Ѿ�������״̬�Ķ���
    open p_cursor for
select  t.ORDERNO,
        t.GROUPNAME,
        t.NAME,    --��ϵ��
        t.IDCARDNO,
        t.PHONE,
        t.totalmoney/100.0 totalmoney,
        t.TRANSACTOR || ':' || m.staffname transactor,   --¼��Ա��
        to_char(t.INPUTTIME,'yyyymmdd') inputtime,  --¼��ʱ��
        t.REMARK, --��ע
        nvl(t.cashgiftmoney/100.0,0) CASHGIFTMONEY,
        (nvl(t.sztcardmoney/100.0,0) + nvl(t.lvyoumoney/100.0,0))sztcardmoney,
        nvl(t.chargecardmoney/100.0,0) chargecardmoney,
        nvl(t.customeracchasmoney/100.0,0) customeracchasmoney,
        nvl(t.readermoney/100.0,0) readermoney,
        t.financeremark, --����������                                                                                                        
        decode(t.ORDERSTATE,'07','07:�������','10','10:�쿨������',t.ORDERSTATE) orderstate,
        t.CUSTOMERACCMONEY/100.0 CUSTOMERACCMONEY,
        t.getdate,
        t.isrelated
        from TF_F_ORDERFORM t,td_m_insidestaff m,(select Max(Tradeid) tradeid,orderno from TF_F_ORDERTRADE h where h.tradecode='07' group by orderno)q, TF_F_ORDERTRADE p,td_m_insidestaff j,td_m_insidedepart k
        where t.transactor = m.staffno
        and t.USETAG = '1'
        and t.orderstate in ('07','10')--�쿨״̬���쿨������״̬
        and t.isrelated = '0' --�쿨������
        and t.orderno =q.orderno(+)
        and q.tradeid = p.tradeid(+)
        and p.OPERATEDEPARTNO = k.departno(+)
        and p.OPERATESTAFFNO = j.staffno(+)
        and (p_var1 IS NULL OR p_var1 = '' OR p_var1 = t.orderno)
        and (p_var2 IS NULL OR p_var2 = '' OR t.groupname like '%'||p_var2||'%')
        and (p_var3 IS NULL OR p_var3 = '' OR to_char(t.inputtime,'yyyymmdd')>= p_var3)--¼��ʱ��
        and (p_var4 IS NULL OR p_var4 = '' OR to_char(t.inputtime,'yyyymmdd')<= p_var4)
        and (p_var5 is null or p_var5 = '' OR p_var5 = p.OPERATEDEPARTNO)
        and (p_var6 is null or p_var6 = '' OR p_var6 = p.OPERATESTAFFNO)
        order by t.orderno desc;
elsif p_funcCode = 'QuerySaleCashGiftCard' then --�����Ѿ����۵�����
    open p_cursor for
    select  t.cardno,t.operatetime selltime,t.operatestaffno|| ':' || m.staffname updatestaffno,
    nvl((t.CARDDEPOSITFEE+t.SUPPLYMONEY)/100.0,0) salemoney,--������
    nvl(t.CARDDEPOSITFEE/100.0,0) CARDDEPOSITFEE,--��Ѻ��
    nvl(t.SUPPLYMONEY/100.0,0) SUPPLYMONEY--��ֵ���
    from tf_b_tradefee t,(select Max(k.tradeid) tradeid ,Max(k.operatetime) operatetime,k.cardno from tf_b_tradefee k where k.tradetypecode = '50' or k.tradetypecode = '51' group by k.cardno)q,td_m_insidestaff m,tf_f_cashgiftrelation n,tl_r_icuser p
    where t.cardno =n.cardno(+)
    and n.cardno is null
    and t.tradeid = q.tradeid
    and t.cardno = q.cardno
    and (t.tradetypecode = '50' or t.tradetypecode = '51')
    and t.operatestaffno = m.staffno(+)
    and (p_var1 IS NULL OR p_var1 = '' OR p_var1= t.OPERATEDEPARTID )
    and (p_var2 IS NULL OR p_var2 = '' OR p_var2 = t.operatestaffno)
    and (p_var3 IS NULL OR p_var3 = '' OR t.operatetime >=TO_DATE(p_var3,'yyyyMMdd'))
    and (p_var4 IS NULL OR p_var4 = '' OR t.operatetime <TO_DATE(p_var4 ,'yyyyMMdd')+1)
    and (p_var5 IS NULL OR p_var5 = '' OR p_var5 = nvl((t.CARDDEPOSITFEE+t.SUPPLYMONEY)/100.0,0))
    and p.cardtypecode='05'--��������
    and p.resstatecode = '06' --����״̬
    and t.cardno = p.cardno
    order by t.operatetime;
elsif 	 p_funcCode = 'QueryUnitComBuyCardApprovalInfo' then  ---��λ������ȫֵ����˼�¼��ѯ
    open p_cursor for
    select t.id,a.companyno,a.companyname,a.companypapertype,a.companypaperno,a.companymanagerno,a.companyendtime,
           a.name,a.papertype,a.paperno,a.paperenddate,a.phoneno,a.address,a.email,nvl2(c.appcallingcode,c.appcallingcode||':'||c.appcalling,null) appcalling,t.securityvalue/100.0 securityvalue,t.registeredcapital/100.0  registeredcapital
            from TF_F_COMBUYCARDAPPROVAL t,TD_M_BUYCARDCOMINFO a,TD_DEPTBAL_RELATION b,TD_M_APPCALLINGCODE c
    WHERE  t.companyno=a.companyno
    and    a.operdept = B.DEPARTNO
    and    a.callingno = c.appcallingcode(+)
    AND    (p_var1 IS NULL OR p_var1 = '' OR p_var1 = a.name)
	  AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.companypapertype)
	  AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.paperno)
	  AND    (p_var4 IS NULL OR p_var4 = '' OR a.companyname like '%' ||p_var4||'%')
    AND    (p_var5 IS NULL OR p_var5 = '' OR  p_var5 = a.companypaperno)
    AND    P_VAR6 = B.DBALUNITNO
    and    t.approvestate='0'
    and    t.isvalid='1'
     order by t.operatetime desc;
elsif 	 p_funcCode = 'QueryDeptComBuyCardApprovalInfo' then  ---��λ������ȫֵ����˼�¼��ѯ
    open p_cursor for
    select t.id,a.companyno,a.companyname,a.companypapertype,a.companypaperno,a.companymanagerno,a.companyendtime,
           a.name,a.papertype,a.paperno,a.paperenddate,a.phoneno,a.address,a.email,nvl2(c.appcallingcode,c.appcallingcode||':'||c.appcalling,null) appcalling,t.securityvalue/100.0 securityvalue,t.registeredcapital/100.0  registeredcapital
            from TF_F_COMBUYCARDAPPROVAL t,TD_M_BUYCARDCOMINFO a,TD_M_APPCALLINGCODE c
    WHERE  (p_var1 IS NULL OR p_var1 = '' OR p_var1 = a.name)
	  AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.companypapertype)
	  AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.paperno)
	  AND    (p_var4 IS NULL OR p_var4 = '' OR a.companyname like '%' ||p_var4||'%')
    AND    (p_var5 IS NULL OR p_var5 = '' OR  p_var5 = a.companypaperno)
    AND    A.OPERDEPT = P_VAR6
    and    a.callingno = c.appcallingcode(+)
    and    t.companyno=a.companyno
    and    t.approvestate='0'
    and    t.isvalid='1'
     order by t.operatetime desc;
elsif 	 p_funcCode = 'QueryStaffComBuyCardApprovalInfo' then  ---��λ������ȫֵ����˼�¼��ѯ
    open p_cursor for
    select t.id,a.companyno,a.companyname,a.companypapertype,a.companypaperno,a.companymanagerno,a.companyendtime,
           a.name,a.papertype,a.paperno,a.paperenddate,a.phoneno,a.address,a.email,nvl2(c.appcallingcode,c.appcallingcode||':'||c.appcalling,null) appcalling,t.securityvalue/100.0 securityvalue,t.registeredcapital/100.0  registeredcapital
            from TF_F_COMBUYCARDAPPROVAL t,TD_M_BUYCARDCOMINFO a,TD_M_APPCALLINGCODE c
    WHERE  (p_var1 IS NULL OR p_var1 = '' OR p_var1 = a.name)
	  AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.companypapertype)
	  AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.paperno)
	  AND    (p_var4 IS NULL OR p_var4 = '' OR a.companyname like '%' ||p_var4||'%')
    AND    (p_var5 IS NULL OR p_var5 = '' OR  p_var5 = a.companypaperno)
    AND    (P_VAR6 IS NULL OR P_VAR6 = '' OR P_VAR6 = A.OPERATOR)
    and    a.callingno = c.appcallingcode(+)
    and    t.companyno=a.companyno
    and    t.approvestate='0'
    and    t.isvalid='1'
     order by t.operatetime desc;
elsif 	 p_funcCode = 'QueryUnitPerBuyCardApprovalInfo' then  ---���˹�����ȫֵ����˼�¼��ѯ
    open p_cursor for
    select t.id,a.papertype,a.paperno,a.name,a.birthday,a.sex,a.phoneno,a.address,a.email,a.paperenddate,
           a.nationality,a.job,t.securityvalue/100.0 securityvalue,t.registeredcapital/100.0 registeredcapital,nvl2(c.appcallingcode,c.appcallingcode||':'||c.appcalling,null) appcalling
    from TF_F_PERBUYCARDAPPROVAL t,TD_M_BUYCARDPERINFO a,TD_DEPTBAL_RELATION b,TD_M_APPCALLINGCODE c
    WHERE  a.operdept = B.DEPARTNO
    and    a.callingno = c.appcallingcode(+)
    AND    (p_var1 IS NULL OR p_var1 = '' OR a.name like '%'|| p_var1 ||'%')
	  AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.papertype)
	  AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.paperno)
    AND    p_var4 = B.DBALUNITNO
    and    t.papertype = a.papertype
    and    t.paperno=a.paperno
    and    t.approvestate='0'
    and    t.isvalid='1'
     order by t.operatetime desc;
elsif p_funcCode = 'QueryDeptPerBuyCardApprovalInfo' then
        ---���˹�����ȫֵ����˼�¼��ѯ
    open p_cursor for
    select t.id,a.papertype,a.paperno,a.name,a.birthday,a.sex,a.phoneno,a.address,a.email,a.paperenddate,
           a.nationality,a.job,t.securityvalue/100.0 securityvalue,t.registeredcapital/100.0 registeredcapital,nvl2(c.appcallingcode,c.appcallingcode||':'||c.appcalling,null) appcalling
    from TF_F_PERBUYCARDAPPROVAL t,TD_M_BUYCARDPERINFO a,TD_M_APPCALLINGCODE c
    WHERE   (p_var1 IS NULL OR p_var1 = '' OR a.name like '%'|| p_var1 ||'%')
	  AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.papertype)
	  AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.paperno)
    AND    A.OPERDEPT = P_var4
    and    a.callingno = c.appcallingcode(+)
    and    t.papertype = a.papertype
    and    t.paperno=a.paperno
    and    t.approvestate='0'
    and    t.isvalid='1'
     order by t.operatetime desc;
elsif p_funcCode = 'QueryStaffPerBuyCardApprovalInfo' then
        ---���˹�����ȫֵ����˼�¼��ѯ
    open p_cursor for
    select t.id,a.papertype,a.paperno,a.name,a.birthday,a.sex,a.phoneno,a.address,a.email,a.paperenddate,
           a.nationality,a.job,t.securityvalue/100.0 securityvalue,t.registeredcapital/100.0 registeredcapital,nvl2(c.appcallingcode,c.appcallingcode||':'||c.appcalling,null) appcalling
    from TF_F_PERBUYCARDAPPROVAL t,TD_M_BUYCARDPERINFO a,TD_M_APPCALLINGCODE c
    WHERE   (p_var1 IS NULL OR p_var1 = '' OR a.name like '%'|| p_var1 ||'%')
	  AND    (p_var2 IS NULL OR p_var2 = '' OR p_var2 = a.papertype)
	  AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 = a.paperno)
    AND    (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = A.OPERATOR)
    and    a.callingno = c.appcallingcode(+)
    and    t.papertype = a.papertype
    and    t.paperno=a.paperno
    and    t.approvestate='0'
    and    t.isvalid='1'
     order by t.operatetime desc;
end if;
end;
/
show errors
