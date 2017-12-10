create or replace procedure SP_PR_Query
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
    v_sub varchar2(32);
    v_idx   pls_integer;
    v_last  pls_integer;

begin
if p_funcCode = 'ValidateMenu' then
    open p_cursor for
    select 1
    from TD_M_MENU m,TD_M_ROLEPOWER r, TD_M_INSIDESTAFFROLE sr
    where instr(lower(p_var1), lower(m.url)) > 0
    and   sr.STAFFNO = p_var2
    and   sr.ROLENO = r.ROLENO 
    and   r.POWERTYPE = '1' 
    and   r.POWERCODE = m.MENUNO
    ;    
elsif p_funcCode = 'QueryNewMsgNum' then
    open p_cursor for
    select count(*) from tf_b_msgto t 
    where t.msgstate = 0 
    and   t.msgdept= p_var1 and t.msggee = p_var2;
elsif p_funcCode = 'QueryDept' then
    open p_cursor for
    select t.departno, t.departname from td_m_insidedepart t order by t.departno;
elsif p_funcCode = 'QueryRole' then
    open p_cursor for
    select t.roleno, t.rolename from td_m_role t order by t.roleno;
elsif p_funcCode = 'QueryStaff' then
    open p_cursor for
    select t.staffno,t.staffname, d.departname
    from td_m_insidestaff t, td_m_insidedepart d
    where t.departno = d.departno 
    and   t.dimissiontag = '1'
    order by t.staffno;
elsif p_funcCode = 'QueryRecvMsg' then
    open p_cursor for
    select m.msgid, mt.msgstate, s.staffname as msgger, m.msgtitle, m.msglevel, m.msgtime
    from tf_b_msgto mt, tf_b_msg m, td_m_insidestaff s
    where mt.msgid = m.msgid and m.msgger = s.staffno
    and   mt.msgdept= p_var1 and mt.msggee = p_var2
    order by m.msgtime desc;
elsif p_funcCode = 'QuerySentMsg' then
    open p_cursor for
    select m.msgid, 1 as msgstate, s.staffname as msgger, m.msgtitle, m.msglevel, m.msgtime  
    from tf_b_msg m, td_m_insidestaff s
    where m.msgger = s.staffno
    and   m.msgger = p_var2 and m.msgdept = p_var1 and m.msgpos = 1
    order by m.msgtime desc;

elsif p_funcCode = 'QuerySingleMsg' then
    update tf_b_msgto set msgstate = 1 where msgid = p_var1 and msgstate = 0
    and   msgdept= p_var2 and msggee = p_var3;
    open p_cursor for
    select m.msgid, s.staffname, m.msgger, m.msgtitle, m.msglevel, m.msgtime, m.msgbody,m.msgfilename,m.msgfile
    from tf_b_msg m, td_m_insidestaff s
    where m.msgger = s.staffno
    and   m.msgid = p_var1;
elsif p_funcCode = 'DelMsgList' then
    v_last := 1;
    loop
        v_idx := instr(p_var1, ',', v_last);
        if v_idx = 0 then
           v_sub := substr(p_var1, v_last);
        else
           v_sub := substr(p_var1, v_last, v_idx - v_last);
        end if;

        v_last := v_idx + 1;
        
        delete from tf_b_msgto where msgid = v_sub
        and   msgdept= p_var2 and msggee = p_var3;
        
        exit when v_idx = 0;
    end loop;
    
    open p_cursor for select 'x' from dual;
elsif p_funcCode = 'DelSentList' then
    v_last := 1;
    loop
        v_idx := instr(p_var1, ',', v_last);
        if v_idx = 0 then
           v_sub := substr(p_var1, v_last);
        else
           v_sub := substr(p_var1, v_last, v_idx - v_last);
        end if;

        v_last := v_idx + 1;
        
        update tf_b_msg set msgpos = 2 where msgid = v_sub
        and   msgdept= p_var2 and msgger = p_var3;
        
        exit when v_idx = 0;
    end loop;
    
    open p_cursor for select 'x' from dual;
	
	ELSIF P_FUNCCODE = 'QureyStaffInOneCard' THEN --查询卡管中是否有同工号账户
    OPEN P_CURSOR FOR
      Select 1
      From TD_M_INSIDESTAFF1
      Where STAFFNO = P_VAR1; 
elsif p_funcCode = 'QueryLogonAdminpageConfig' then --查询admin页面登陆限制
    open p_cursor for
    select c.departno||':'||c.departname as departname,b.staffno||':'||b.staffname as staffname
	from td_m_adminlogconfig a,td_m_insidestaff b,td_m_insidedepart c
	where a.staffno(+)=b.staffno and b.departno=c.departno
		and ((p_var1=0 and a.staffno is null)or(p_var1=1 and a.staffno is not null))
		and (p_var2 is null or b.departno = p_var2)
		and (p_var3 is null or b.staffno = p_var3)
		order by b.departno,b.staffno;
elsif p_funcCode = 'QueryStaffPrintMode' then  --查询用户打印设置
    open p_cursor for
    select  c.departno||':'||c.departname  depart,b.staffno||':'||b.staffname staff,decode(a.printmode,'1','1:针式打印','2','2:热敏打印',a.printmode) printmode
    from td_m_insidestaffprint a,td_m_insidestaff b,td_m_insidedepart c
    where a.staffno=b.staffno
    and b.departno=c.departno
    and (p_var1 is null or b.departno = p_var1)
		and (p_var2 is null or b.staffno = p_var2)
    order by a.staffno;
elsif p_funcCode = 'QueryHasPowerMenu' then   --查询有权限的页面
    open p_cursor for
	   SELECT DISTINCT TM.MENUNO    MENUNO,
	       TM.MENUNAME  MENUNAME,
	       TPM.MENUNO   PMENUNO,
	       TPM.MENUNAME PMENUNAME,
	       TM.REMARK
	  FROM TD_M_MENU TM, TD_M_MENU TPM, TD_M_ROLEPOWER P,TD_M_INSIDESTAFFROLE IR,TD_M_ROLE R
	 WHERE TM.PMENUNO = TPM.MENUNO
	   AND TM.PMENUNO IS NOT NULL
	   AND P.POWERCODE = TM.MENUNO
	   AND P.POWERTYPE = '1'
	   AND P.ROLENO = IR.ROLENO
	   AND IR.ROLENO = R.ROLENO
	   AND IR.STAFFNO = p_var1
	 ORDER BY TM.MENUNO;
elsif p_funcCode = 'QueryQuickMenu' then   --查询快捷菜单
    open p_cursor for
	      SELECT DISTINCT   Q.MENUNO,
                Q.STAFFNO,
                TM.URL,
                MENUNAME,
                TIPS,
                TARGET,
                TM.CLICKFUC,
                Q.SORT
			  FROM TD_M_MENU TM , TD_M_ROLEPOWER P,TD_M_INSIDESTAFFROLE IR,TD_M_ROLE R,TD_M_QUICKMENU Q 
			   WHERE P.POWERCODE = TM.MENUNO
			     AND P.POWERTYPE = '1'
			     AND P.ROLENO = IR.ROLENO 
			     AND IR.ROLENO = R.ROLENO
			     AND Q.MENUNO = TM.MENUNO
			     AND Q.STAFFNO = IR.STAFFNO
			     AND IR.STAFFNO = p_var1
			 ORDER BY Q.SORT;
       
elsif p_funcCode = 'QueryLogonLog' then--登录日志
   open p_cursor for
   select departno,staffno,opercardno,ipaddr,logontime from TF_B_LOGONLOG  
    WHERE  (p_var1 IS NULL OR p_var1 = '' OR p_var1 = staffno)
    AND    (p_var2 IS NULL OR p_var2 = '' OR to_char(logontime,'yyyyMMdd')>= p_var2)
    AND    (p_var3 IS NULL OR p_var3 = '' OR to_char(logontime,'yyyyMMdd')<= p_var3)
    ORDER BY logontime DESC;
elsif p_funcCode = 'QueryLogonTrade' then--操作日志查询
   open p_cursor for
   SELECT * FROM(
	SELECT D.DEPARTNAME,S.STAFFNAME,M.TRADETYPE,'' IPADDR,T.OPERATETIME
	FROM TF_B_TRADE T,TD_M_TRADETYPE M,TD_M_INSIDEDEPART D,TD_M_INSIDESTAFF S 
	WHERE T.TRADETYPECODE = M.TRADETYPECODE
	AND T.OPERATEDEPARTID = D.DEPARTNO
	AND T.OPERATESTAFFNO = S.STAFFNO
	AND (P_VAR1 is null or P_VAR1 = '' or P_VAR1 = T.OPERATEDEPARTID)
	AND (P_VAR2 is null or P_VAR2 = '' or P_VAR2 = T.OPERATESTAFFNO)
	AND T.OPERATETIME >= TO_DATE(P_VAR3 || '000000', 'YYYYMMDDHH24MISS')
	AND T.OPERATETIME <= TO_DATE(P_VAR4 || '235959', 'YYYYMMDDHH24MISS')
	UNION
	SELECT D.DEPARTNAME,S.STAFFNAME,'登陆' TRADETYPE,G.IPADDR,LOGONTIME OPERATETIME
	FROM TF_B_LOGONLOG G,TD_M_INSIDEDEPART D,TD_M_INSIDESTAFF S 
	WHERE G.DEPARTNO = D.DEPARTNO
	AND G.STAFFNO = S.STAFFNO
	AND (P_VAR1 is null or P_VAR1 = '' or P_VAR1 = G.DEPARTNO)
	AND (P_VAR2 is null or P_VAR2 = '' or P_VAR2 = G.STAFFNO)
	AND G.LOGONTIME >= TO_DATE(P_VAR3 || '000000', 'YYYYMMDDHH24MISS')
	AND G.LOGONTIME <= TO_DATE(P_VAR4 || '235959', 'YYYYMMDDHH24MISS')
	)
	ORDER BY 5;
end if;
end;

/

show errors
