create or replace procedure SP_FI_CARDSTAT
(
    p_funcCode   varchar2,
    p_var1   in out    varchar2,
    p_var2   in out    varchar2,
    p_var3   in out    varchar2,
    p_var4   in out    varchar2,
    p_var5   in out    varchar2,
    p_var6   in out    varchar2,
    p_var7   in out    varchar2,
    p_var8   in out    varchar2,
    p_var9   in out    varchar2,
    p_cursor out SYS_REFCURSOR
)
as
    --v_frDate date := to_date(p_var1||'000000', 'yyyymmddhh24miss');
    --v_toDate date := to_date(p_var2||'235959', 'yyyymmddhh24miss');

begin
    if p_funcCode = 'SELLCHANGEMONTHLYREPORT' then --�ۻ����±�
        IF p_var2 is null then 
            if p_var3 = '1' then
                open p_cursor for
                select 
                    a.CARDSURFACECODE   ������� , 
                    b.CARDSURFACENAME   ��Ƭ���� , 
                    a.LASTMONTHSTOCK    ���½��� , 
                    a.THISMONTHSTOCK    ������� , 
                    a.SELLNUM           �ۿ����� , 
                    a.SELLMONEY/100.0   �ۿ���� ,
                    a.CHANGENUM         �������� , 
                    a.CHANGEMONEY/100.0 ������� , 
                    a.SPEADJUSTACC      ������� , 
                    a.BADCARD           ����     , 
                    a.SURPLUSSTOCK      ��ĩ���
                from TF_SELLCHANGEMONTHLYREPORT a , td_m_cardsurface b 
                where a.CARDSURFACECODE = b.CARDSURFACECODE
                and   a.STATMONTH = p_var1 
                and   a.DEPTNO = 'alld'
                order by a.CARDSURFACECODE
                ;
            else
                open p_cursor for
                select 
                    a.CARDSURFACECODE   ������� , 
                    b.CARDSURFACENAME   ��Ƭ���� , 
                    a.LASTMONTHSTOCK    ���½��� , 
                    a.THISMONTHSTOCK    ������� , 
                    a.SELLNUM           �ۿ����� , 
                    a.SELLMONEY/100.0   �ۿ���� ,
                    a.CHANGENUM         �������� , 
                    a.CHANGEMONEY/100.0 ������� , 
                    a.SPEADJUSTACC      ������� , 
                    a.BADCARD           ����     , 
                    a.SURPLUSSTOCK      ��ĩ���
                from TF_SELLCHANGEMONTHLYREPORT a , td_m_cardsurface b 
                where a.CARDSURFACECODE = b.CARDSURFACECODE
                and   a.STATMONTH = p_var1 
                and   a.DEPTNO = 'alld'
                and  (a.LASTMONTHSTOCK <> a.SURPLUSSTOCK or (a.THISMONTHSTOCK != 0 or a.THISMONTHSTOCK is not null))
                order by a.CARDSURFACECODE
                ;
            end if;
        else  
            if p_var4 = '1' then
                open p_cursor for
                select 
                    a.CARDSURFACECODE   ������� , 
                    b.CARDSURFACENAME   ��Ƭ���� , 
                    a.LASTMONTHSTOCK    ���½��� , 
                    a.THISMONTHSTOCK    ������� , 
                    a.SELLNUM           �ۿ����� , 
                    a.SELLMONEY/100.0   �ۿ���� ,
                    a.CHANGENUM         �������� , 
                    a.CHANGEMONEY/100.0 ������� , 
                    a.SPEADJUSTACC      ������� , 
                    a.BADCARD           ����     , 
                    a.SURPLUSSTOCK      ��ĩ���
                from TF_SELLCHANGEMONTHLYREPORT a , td_m_cardsurface b 
                where a.CARDSURFACECODE = b.CARDSURFACECODE
                and   a.STATMONTH = p_var1 
                and   a.DEPTNO = p_var2
                order by a.CARDSURFACECODE
                ;
            else
                open p_cursor for
                select 
                    a.CARDSURFACECODE   ������� , 
                    b.CARDSURFACENAME   ��Ƭ���� , 
                    a.LASTMONTHSTOCK    ���½��� , 
                    a.THISMONTHSTOCK    ������� , 
                    a.SELLNUM           �ۿ����� , 
                    a.SELLMONEY/100.0   �ۿ���� ,
                    a.CHANGENUM         �������� , 
                    a.CHANGEMONEY/100.0 ������� , 
                    a.SPEADJUSTACC      ������� , 
                    a.BADCARD           ����     , 
                    a.SURPLUSSTOCK      ��ĩ���
                from TF_SELLCHANGEMONTHLYREPORT a , td_m_cardsurface b 
                where a.CARDSURFACECODE = b.CARDSURFACECODE
                and   a.STATMONTH = p_var1 
                and   a.DEPTNO = p_var2
                and  (a.LASTMONTHSTOCK <> a.SURPLUSSTOCK or (a.THISMONTHSTOCK != 0 or a.THISMONTHSTOCK is not null))
                order by a.CARDSURFACECODE
                ;
            end if;
        end if;
        
    elsif p_funcCode = 'SELLCHANGE_MONTHLY_REPORT' then
        IF p_var3 is null then 
            if p_var4 = '1' then
                open p_cursor for
                select 
                    a.CARDSURFACECODE �������, b.CARDSURFACENAME ��Ƭ���� , c.YDAYSTOCK ���½���   , sum(nvl(a.TODAYSTOCK,0)) �������   , 
                    (sum(nvl(a.SELLFORTY,0)) + sum(nvl(a.SELLEIGHTEEN,0)) + sum(nvl(a.SELLTEN,0)) + sum(nvl(a.MONTHTHIRTY,0)) + sum(nvl(a.OLDTEN,0))) �ۿ����� , 
                    (sum(nvl(a.SELLFORTY,0))*40 + sum(nvl(a.SELLEIGHTEEN,0))*18 + sum(nvl(a.SELLTEN,0))*10 + sum(nvl(a.MONTHTHIRTY,0))*30 + sum(nvl(a.OLDTEN,0))*10) �ۿ���� ,
                    (sum(nvl(a.CHANGEZERO,0)) + sum(nvl(a.CHANGEEIGHTEEN,0)) + sum(nvl(a.CHANGEFORTY,0)) + sum(nvl(a.CHANGETHIRTY,0))) �������� , 
                    (sum(nvl(a.CHANGEEIGHTEEN,0))*18 + sum(nvl(a.CHANGEFORTY,0))*40 + sum(nvl(a.CHANGETHIRTY,0))*30) �������, 
                    sum(nvl(a.SPEADJUSTACC,0)) ������� , sum(nvl(a.BADCARD,0)) ���� , 
                    d.SURPLUSSTOCK ��ĩ���
                from TF_SELLCHANGEREPORT a , td_m_cardsurface b ,
                    (select CARDSURFACECODE,YDAYSTOCK from TF_SELLCHANGEREPORT where DEPTNO = 'alld' and STATDATE = p_var1) c,
                    (select CARDSURFACECODE,SURPLUSSTOCK from TF_SELLCHANGEREPORT where DEPTNO = 'alld' and STATDATE = p_var2) d
                where a.CARDSURFACECODE = b.CARDSURFACECODE
                and  (a.STATDATE between p_var1 and p_var2)
                and   a.DEPTNO = 'alld'
                and   a.CARDSURFACECODE = c.CARDSURFACECODE(+)
                and   a.CARDSURFACECODE = d.CARDSURFACECODE(+)
                group by a.CARDSURFACECODE ,b.CARDSURFACENAME , c.YDAYSTOCK , d.SURPLUSSTOCK
                order by a.CARDSURFACECODE
                ;
            else
                open p_cursor for
                select 
                    a.CARDSURFACECODE �������, b.CARDSURFACENAME ��Ƭ���� , c.YDAYSTOCK ���½���   , sum(nvl(a.TODAYSTOCK,0)) �������   , 
                    (sum(nvl(a.SELLFORTY,0)) + sum(nvl(a.SELLEIGHTEEN,0)) + sum(nvl(a.SELLTEN,0)) + sum(nvl(a.MONTHTHIRTY,0)) + sum(nvl(a.OLDTEN,0))) �ۿ����� , 
                    (sum(nvl(a.SELLFORTY,0))*40 + sum(nvl(a.SELLEIGHTEEN,0))*18 + sum(nvl(a.SELLTEN,0))*10 + sum(nvl(a.MONTHTHIRTY,0))*30 + sum(nvl(a.OLDTEN,0))*10) �ۿ���� ,
                    (sum(nvl(a.CHANGEZERO,0)) + sum(nvl(a.CHANGEEIGHTEEN,0)) + sum(nvl(a.CHANGEFORTY,0)) + sum(nvl(a.CHANGETHIRTY,0))) �������� , 
                    (sum(nvl(a.CHANGEEIGHTEEN,0))*18 + sum(nvl(a.CHANGEFORTY,0))*40 + sum(nvl(a.CHANGETHIRTY,0))*30) �������, 
                    sum(nvl(a.SPEADJUSTACC,0)) ������� , sum(nvl(a.BADCARD,0)) ���� , 
                    d.SURPLUSSTOCK ��ĩ���
                from TF_SELLCHANGEREPORT a , td_m_cardsurface b ,
                    (select CARDSURFACECODE,YDAYSTOCK from TF_SELLCHANGEREPORT where DEPTNO = 'alld' and STATDATE = p_var1) c,
                    (select CARDSURFACECODE,SURPLUSSTOCK from TF_SELLCHANGEREPORT where DEPTNO = 'alld' and STATDATE = p_var2) d
                where a.CARDSURFACECODE = b.CARDSURFACECODE
                and  (a.STATDATE between p_var1 and p_var2)
                and   a.DEPTNO = 'alld'
                and   a.CARDSURFACECODE = c.CARDSURFACECODE(+)
                and   a.CARDSURFACECODE = d.CARDSURFACECODE(+)
                and  (c.YDAYSTOCK <> d.SURPLUSSTOCK or (a.TODAYSTOCK != 0 or a.TODAYSTOCK is not null))
                group by a.CARDSURFACECODE ,b.CARDSURFACENAME , c.YDAYSTOCK , d.SURPLUSSTOCK
                order by a.CARDSURFACECODE
                ;
            end if;
        else  
            if p_var4 = '1' then
                open p_cursor for
                select 
                    a.CARDSURFACECODE �������, b.CARDSURFACENAME ��Ƭ���� , c.YDAYSTOCK ���½���   , sum(nvl(a.TODAYSTOCK,0)) �������   , 
                    (sum(nvl(a.SELLFORTY,0)) + sum(nvl(a.SELLEIGHTEEN,0)) + sum(nvl(a.SELLTEN,0)) + sum(nvl(a.MONTHTHIRTY,0)) + sum(nvl(a.OLDTEN,0))) �ۿ����� , 
                    (sum(nvl(a.SELLFORTY,0))*40 + sum(nvl(a.SELLEIGHTEEN,0))*18 + sum(nvl(a.SELLTEN,0))*10 + sum(nvl(a.MONTHTHIRTY,0))*30 + sum(nvl(a.OLDTEN,0))*10) �ۿ���� ,
                    (sum(nvl(a.CHANGEZERO,0)) + sum(nvl(a.CHANGEEIGHTEEN,0)) + sum(nvl(a.CHANGEFORTY,0)) + sum(nvl(a.CHANGETHIRTY,0))) �������� , 
                    (sum(nvl(a.CHANGEEIGHTEEN,0))*18 + sum(nvl(a.CHANGEFORTY,0))*40 + sum(nvl(a.CHANGETHIRTY,0))*30) �������, 
                    sum(nvl(a.SPEADJUSTACC,0)) ������� , sum(nvl(a.BADCARD,0)) ���� , 
                    d.SURPLUSSTOCK ��ĩ���
                from TF_SELLCHANGEREPORT a , td_m_cardsurface b ,
                    (select CARDSURFACECODE,DEPTNO,YDAYSTOCK from TF_SELLCHANGEREPORT where STATDATE = p_var1) c,
                    (select CARDSURFACECODE,DEPTNO,SURPLUSSTOCK from TF_SELLCHANGEREPORT where STATDATE = p_var2) d
                where a.CARDSURFACECODE = b.CARDSURFACECODE
                and  (a.STATDATE between p_var1 and p_var2)
                and   a.DEPTNO = p_var3
                and   a.CARDSURFACECODE = c.CARDSURFACECODE(+)
                and   a.DEPTNO = c.DEPTNO(+)
                and   a.CARDSURFACECODE = d.CARDSURFACECODE(+)
                and   a.DEPTNO = d.DEPTNO(+)
                group by a.CARDSURFACECODE ,b.CARDSURFACENAME , c.YDAYSTOCK , d.SURPLUSSTOCK
                order by a.CARDSURFACECODE
                ;
            else
                open p_cursor for
                select 
                    a.CARDSURFACECODE �������, b.CARDSURFACENAME ��Ƭ���� , c.YDAYSTOCK ���½���   , sum(nvl(a.TODAYSTOCK,0)) �������   , 
                    (sum(nvl(a.SELLFORTY,0)) + sum(nvl(a.SELLEIGHTEEN,0)) + sum(nvl(a.SELLTEN,0)) + sum(nvl(a.MONTHTHIRTY,0)) + sum(nvl(a.OLDTEN,0))) �ۿ����� , 
                    (sum(nvl(a.SELLFORTY,0))*40 + sum(nvl(a.SELLEIGHTEEN,0))*18 + sum(nvl(a.SELLTEN,0))*10 + sum(nvl(a.MONTHTHIRTY,0))*30 + sum(nvl(a.OLDTEN,0))*10) �ۿ���� ,
                    (sum(nvl(a.CHANGEZERO,0)) + sum(nvl(a.CHANGEEIGHTEEN,0)) + sum(nvl(a.CHANGEFORTY,0)) + sum(nvl(a.CHANGETHIRTY,0))) �������� , 
                    (sum(nvl(a.CHANGEEIGHTEEN,0))*18 + sum(nvl(a.CHANGEFORTY,0))*40 + sum(nvl(a.CHANGETHIRTY,0))*30) �������, 
                    sum(nvl(a.SPEADJUSTACC,0)) ������� , sum(nvl(a.BADCARD,0)) ���� , 
                    d.SURPLUSSTOCK ��ĩ���
                from TF_SELLCHANGEREPORT a , td_m_cardsurface b ,
                    (select CARDSURFACECODE,DEPTNO,YDAYSTOCK from TF_SELLCHANGEREPORT where STATDATE = p_var1) c,
                    (select CARDSURFACECODE,DEPTNO,SURPLUSSTOCK from TF_SELLCHANGEREPORT where STATDATE = p_var2) d
                where a.CARDSURFACECODE = b.CARDSURFACECODE
                and  (a.STATDATE between p_var1 and p_var2)
                and   a.DEPTNO = p_var3
                and   a.CARDSURFACECODE = c.CARDSURFACECODE(+)
                and   a.DEPTNO = c.DEPTNO(+)
                and   a.CARDSURFACECODE = d.CARDSURFACECODE(+)
                and   a.DEPTNO = d.DEPTNO(+)
                and  (c.YDAYSTOCK <> d.SURPLUSSTOCK or (a.TODAYSTOCK != 0 or a.TODAYSTOCK is not null))
                group by a.CARDSURFACECODE ,b.CARDSURFACENAME , c.YDAYSTOCK , d.SURPLUSSTOCK
                order by a.CARDSURFACECODE
                ;
            end if;
        end if;
        
    elsif p_funcCode='CardRESOURCE' then -- �����ͳ��
        delete from tmp_common;

        insert into tmp_common(f0, f1)
        select t.cardsurfacecode, t.cardsurfacename from td_m_cardsurface t;
        
        merge into tmp_common tmp -- ���ڿ��
        using (
            select b.cardsurfacecode, count(a.rowid) cnt
            from tl_r_icuser a, td_m_cardsurface b
            where INSTIME <= to_date(p_var1||'000000','yyyymmddhh24miss') 
            and (OUTTIME is null or OUTTIME >= to_date(p_var1||'000000','yyyymmddhh24miss'))
            and a.CARDSURFACECODE = b.cardsurfacecode
            group by b.cardsurfacecode) fc
        on (tmp.f0 = fc.cardsurfacecode)
        when matched then
            update set tmp.f2 = fc.cnt;
            
        merge into tmp_common tmp -- �������
        using (
            select b.cardsurfacecode, count(a.rowid) cnt
            from tl_r_icuser a, td_m_cardsurface b
            where INSTIME between to_date(p_var1||'000000','yyyymmddhh24miss') and to_date(p_var2||'235959','yyyymmddhh24miss')
            and a.CARDSURFACECODE = b.cardsurfacecode
            group by b.cardsurfacecode) fc
        on (tmp.f0 = fc.cardsurfacecode)
        when matched then
            update set tmp.f3 = fc.cnt;
            
        merge into tmp_common tmp -- ��������
        using (
            select b.cardsurfacecode, count(a.rowid) cnt
            from tl_r_icuser a, td_m_cardsurface b
            where OUTTIME between to_date(p_var1||'000000','yyyymmddhh24miss') and to_date(p_var2||'235959','yyyymmddhh24miss')
            and a.CARDSURFACECODE = b.cardsurfacecode
            group by b.cardsurfacecode) fc
        on (tmp.f0 = fc.cardsurfacecode)
        when matched then
            update set tmp.f4 = fc.cnt;
            
        merge into tmp_common tmp -- ��ĩ���
        using (
            select b.cardsurfacecode, count(a.rowid) cnt
            from tl_r_icuser a, td_m_cardsurface b
            where INSTIME <= to_date(p_var2||'000000','yyyymmddhh24miss')
            and (OUTTIME is null or outtime >= to_date(p_var2||'000000','yyyymmddhh24miss'))
            and a.CARDSURFACECODE = b.cardsurfacecode
            group by b.cardsurfacecode) fc
        on (tmp.f0 = fc.cardsurfacecode)
        when matched then
            update set tmp.f5 = fc.cnt;
            
        open p_cursor for
        select nvl(f1, 0) ��Ƭ����, nvl(f2, 0) �ڳ����, nvl(f3, 0) �������, nvl(f4, 0) ���ڳ���, nvl(f5, 0) ��ĩ���
        from tmp_common;
        
    end if;
end;
/

show errors