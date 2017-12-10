create or replace procedure SP_UC_Query
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
    p_var11      varchar2,
    p_cursor out SYS_REFCURSOR 
) 
as
begin

if p_funcCode = 'InvoiceVolumnQuery' then
   open p_cursor for
   select t.VOLUMENO, f.staffname, t.updatetime
   from TD_M_VOLUMN t, TD_M_INSIDESTAFF f
   where t.departno = p_var1
   and   t.departno = f.departno (+);
elsif p_funcCode = 'InvoiceVolumnSave' then

     merge into TD_M_VOLUMN t
     using dual
     on (t.departno = p_var1)
     when matched then
          update set t.lastvolumeno = t.volumeno,
                     t.volumeno     = p_var2,
                     t.updatestaffno= p_var3,
                     t.updatetime   = sysdate
     when not matched then
          insert (departno, volumeno, updatestaffno, updatetime)
          values (p_var1, p_var2, p_var3, sysdate);
      
      commit;
      
      open p_cursor for select 1 from dual;

elsif p_funcCode = 'CardQuery' then
    open p_cursor for
    select a.CARDNO, f.CARDTYPENAME,
           a.VALIDBEGINDATE || '-' || a.VALIDENDDATE VALIDDATE,
           c.CARDSURFACENAME, e.MANUNAME,
           b.RESSTATE, g.COSType, d.CARDCHIPTYPENAME
    from   TL_R_ICUSER      a, TD_M_RESOURCESTATE b,
           TD_M_CARDSURFACE c, TD_M_CARDCHIPTYPE  d,
           TD_M_MANU        e, TD_M_CARDTYPE      f,
           TD_M_COSTYPE     g
    where (p_var1 is null or a.CARDNO >= p_var1)
    and   (p_var2 is null or a.CARDNO <= p_var2)
    and (   p_var3 = '01'   -- distribution
            and a.ASSIGNEDSTAFFNO  = p_var4
            and a.ASSIGNEDDEPARTID = p_var5
            and a.RESSTATECODE     = '01'
         OR p_var3 = '02' -- undistribution
            and a.RESSTATECODE = '05'
            and (p_var4 is null or to_char(a.ALLOCTIME, 'yyyymmdd') = p_var4)
            and a.ASSIGNEDSTAFFNO = p_var5
            and a.UPDATESTAFFNO   = p_var6
        )
    and    a.RESSTATECODE     = b.RESSTATECODE
    and    a.CARDSURFACECODE  = c.CARDSURFACECODE
    and    a.CARDCHIPTYPECODE = d.CARDCHIPTYPECODE
    and    a.MANUTYPECODE     = e.MANUCODE
    and    a.CARDTYPECODE     = f.CARDTYPECODE
    and    a.COSTYPECODE      = g.COSTYPECODE
    and rownum <= 100;
elsif p_funcCode = 'CardUseArea' then
    declare
           v_funcList varchar2(1024);
    begin
           for v_curosr in (select f.functionname
                from tf_f_cardusearea u, td_m_function f 
                where u.cardno = p_var1 
                and   u.usetag = '1'
                and   (u.endtime is null or u.endtime >= to_char(sysdate, 'YYYYMMDD'))
                and   u.functiontype = f.functiontype)
    
           loop 
                if (v_funcList is null) then v_funcList := v_curosr.functionname; 
                else v_funcList := v_funcList || ',' || v_curosr.functionname;
                end if;
           end loop;
           
           open p_cursor for
           select v_funcList from dual;
           -- dbms_output.put_line(v_funcList);
    end;
elsif p_funcCode = 'CardInfoQuery' then
    open p_cursor for
    select a.CARDNO, a.RESSTATECODE, h.STAFFNAME, i.DEPARTNAME, f.CARDTYPENAME,
           a.VALIDBEGINDATE || '-' || a.VALIDENDDATE VALIDDATE,
           c.CARDSURFACENAME, e.MANUNAME,a.CARDPRICE/100.0 CARDPRICE,
           b.RESSTATE, g.COSType, d.CARDCHIPTYPENAME
    from   TL_R_ICUSER      a, TD_M_RESOURCESTATE b,
           TD_M_CARDSURFACE c, TD_M_CARDCHIPTYPE  d,
           TD_M_MANU        e, TD_M_CARDTYPE      f,
           TD_M_COSTYPE     g, TD_M_INSIDESTAFF   h,
           TD_M_INSIDEDEPART i
    where (p_var1 is null or a.CARDNO >= p_var1)
    and   (p_var2 is null or a.CARDNO <= p_var2)
    and (       (p_var3 is null or a.ASSIGNEDSTAFFNO  = p_var3)
            and (p_var4 is null or a.RESSTATECODE     = p_var4)
            and (p_var5 is null or a.COSTYPECODE      = p_var5)
            and (p_var6 is null or a.MANUTYPECODE     = p_var6)
            and (p_var7 is null or a.CARDTYPECODE     = p_var7)
            and (p_var8 is null or a.CARDSURFACECODE  = p_var8)
            and (p_var9 is null or a.CARDCHIPTYPECODE = p_var9)
            and (p_var10 is null or a.ASSIGNEDDEPARTID = p_var10)
            and (p_var11 is null or a.CARDPRICE = to_number(p_var11)*100)
        )
    and    a.RESSTATECODE     = b.RESSTATECODE(+)
    and    a.CARDSURFACECODE  = c.CARDSURFACECODE(+)
    and    a.CARDCHIPTYPECODE = d.CARDCHIPTYPECODE(+)
    and    a.MANUTYPECODE     = e.MANUCODE(+)
    and    a.CARDTYPECODE     = f.CARDTYPECODE(+)
    and    a.COSTYPECODE      = g.COSTYPECODE(+)
	and    a.ASSIGNEDSTAFFNO  = h.STAFFNO(+)
    and    a.ASSIGNEDDEPARTID = i.DEPARTNO(+)
    and rownum <= 100;
elsif p_funcCode = 'TD_M_BANK' then
    open p_cursor for
    -- bank
    select BANK, BANKCODE from TD_M_BANK;
elsif p_funcCode = 'DistributableStaffs' then
    open p_cursor for
    -- DistStaff
    select STAFFNAME, STAFFNO from TD_M_INSIDESTAFF
    where DEPARTNO = p_var1 and DIMISSIONTAG = '1' order by STAFFNO;
elsif p_funcCode = 'TD_M_CARDCHIPTYPE' then
    open p_cursor for
    -- chip type
    select CARDCHIPTYPENAME, CARDCHIPTYPECODE from TD_M_CARDCHIPTYPE order by CARDCHIPTYPECODE;
elsif p_funcCode = 'TD_M_CARDSURFACE' then
    open p_cursor for
    -- card face
    select CARDSURFACENAME, CARDSURFACECODE from TD_M_CARDSURFACE order by CARDSURFACECODE;
elsif p_funcCode = 'TD_M_MANU' then
    open p_cursor for
    -- manufacture
    select MANUNAME, MANUCODE from TD_M_MANU order by MANUCODE;
elsif p_funcCode = 'TD_M_CARDTYPE' then
    open p_cursor for
    -- card type
    select CARDTYPENAME, CARDTYPECODE from TD_M_CARDTYPE order by CARDTYPECODE;
elsif p_funcCode = 'TD_M_COSTYPE' then
    open p_cursor for
    -- cos type
    select COSType, COSTYPECODE from TD_M_COSTYPE order by COSTYPECODE;
elsif p_funcCode = 'AllStaffs' then
    open p_cursor for
	select stff.STAFFNAME, stff.STAFFNO
    from   TD_M_INSIDESTAFF stff
	where   (p_var1 is null or p_var1 = stff.DEPARTNO)
	order by stff.STAFFNO;

elsif p_funcCode = 'OnlineStaffs' then
    open p_cursor for
	select stff.STAFFNAME, stff.STAFFNO
    from   TD_M_INSIDESTAFF stff
    where  stff.DIMISSIONTAG = '1'
	and   (p_var1 is null or p_var1 = stff.DEPARTNO)
	order by stff.STAFFNO;

elsif p_funcCode = 'OnlineDepts' then
    open p_cursor for
	select t.DEPARTNAME, t.DEPARTNO
	from TD_M_INSIDEDEPART t
	order by t.DEPARTNO;

elsif p_funcCode = 'AssignableStaffs' then
    open p_cursor for
    -- stockout assignable staffs
    select stff.STAFFNAME, stff.STAFFNO
    from   TD_M_INSIDESTAFF stff
    where  stff.DIMISSIONTAG = '1'
    and    stff.STAFFNO in 
    ( select rost.STAFFNO 
      from   TD_M_INSIDESTAFFROLE rost,
                TD_M_ROLE         roll, 
             TD_M_ROLEPOWER       powr
      where rost.ROLENO       = roll.ROLENO
      AND   roll.ROLENO       = powr.ROLENO
      AND   powr.POWERCODE    = '201001'
      AND   powr.POWERTYPE    = '2');

elsif p_funcCode = 'TD_M_RESOURCESTATE' then
    open p_cursor for
    -- resource state
    select RESSTATE, RESSTATECODE from TD_M_RESOURCESTATE order by RESSTATECODE;

elsif p_funcCode = 'CardStat'  then
    open p_cursor for
    --Card statistics
    SELECT e.CARDTYPENAME    ,    -- 卡片类型
           c.CARDSURFACENAME ,    -- 卡面类型
           d.CARDCHIPTYPENAME,    -- 卡芯片类型
           b.RESSTATE        ,    -- 卡片状态
           a.AMOUNT
    FROM (
         SELECT CARDTYPECODE   ,  CARDSURFACECODE,
                CARDCHIPTYPECODE, RESSTATECODE,
                COUNT(*)   AMOUNT
         FROM   TL_R_ICUSER
         GROUP BY CARDTYPECODE ,    CARDSURFACECODE,
                  CARDCHIPTYPECODE, RESSTATECODE
         )                  a,     -- 用户卡库存表
         TD_M_RESOURCESTATE b,     -- 资源状态编码表
         TD_M_CARDSURFACE   c,     -- IC卡卡面编码表
         TD_M_CARDCHIPTYPE  d,     -- IC卡芯片类型编码表
         TD_M_CARDTYPE      e      -- IC卡类型编码表

    WHERE a.RESSTATECODE     = b.RESSTATECODE(+)
    AND   a.CARDSURFACECODE  = c.CARDSURFACECODE(+)
    AND   a.CARDCHIPTYPECODE = d.CARDCHIPTYPECODE(+)
    AND   a.CARDTYPECODE     = e.CARDTYPECODE(+);
end if;

end;

/

show errors

