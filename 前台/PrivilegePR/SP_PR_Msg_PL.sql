create or replace procedure SP_PR_SendMsg
(
    p_msgid     int,
    p_msgtitle  varchar2,
    p_msgbody   varchar2,
    p_msglevel  int     ,
    p_msgattach varchar2,

    p_depts     varchar2,
    p_roles     varchar2,
    p_staffs    varchar2,
    p_msgpos    int,
    
    p_currOper            char,
    p_currDept            char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
as
    v_today date := sysdate;
    v_sub varchar2(32);
    v_msgid pls_integer;
    v_idx   pls_integer;
    v_last  pls_integer;
begin
    begin
        if p_msgid is null then
            insert into tf_b_msg(msgid               , msgtitle  , msgbody  , msglevel  ,
                msgtime, msgdept   , msgger    , msgattach  , msgpos)
                        values  (tf_b_msg_seq.nextval, p_msgtitle, p_msgbody, p_msglevel,
                v_today, p_currDept, p_currOper, p_msgattach, p_msgpos)
            returning msgid into v_msgid;
        else
            update tf_b_msg 
            set    msgtitle = p_msgtitle,
                   msgbody  = p_msgbody ,
                   msglevel = p_msglevel,
                   msgtime  = v_today   ,
                   msgdept  = p_currDept,
                   msgger   = p_currOper,
                   msgattach= p_msgattach,
                   msgpos   = p_msgpos
            where  msgid = p_msgid;
            
            v_msgid := p_msgid;
        end if;
    exception when others then
        p_retCode := 'S100001003';
        p_retMsg  := SQLERRM;
        ROLLBACK; RETURN;
    end;
    if p_msgpos = 1 then -- ÒÑ·¢ËÍ
        begin
            if p_depts is not null then
                -- split staffs
                v_last := 1;
                loop
                    v_idx := instr(p_depts, ',', v_last);
                    if v_idx = 0 then
                       v_sub := substr(p_depts, v_last);
                    else
                       v_sub := substr(p_depts, v_last, v_idx - v_last);
                    end if;

                    v_last := v_idx + 1;
                    
                    for v_cursor in 
                    (select t.staffno, t.departno from td_m_insidestaff t where t.departno = v_sub)
                    loop
                        insert into tf_b_msgto(msgid, msgstate, msggee, msgdept)
                        values(v_msgid, 0, v_cursor.staffno, v_cursor.departno);
                    end loop; 

                    exit when v_idx = 0;
                end loop;
            end if;
            
            if p_roles is not null then
                -- split roles
                v_last := 1;
                loop
                    v_idx := instr(p_roles, ',', v_last);
                    if v_idx = 0 then
                       v_sub := substr(p_roles, v_last);
                    else
                       v_sub := substr(p_roles, v_last, v_idx - v_last);
                    end if;

                    v_last := v_idx + 1;
                    
                    for v_cursor in 
                    (
                        select t.staffno, s.departno 
                        from td_m_insidestaffrole t, td_m_insidestaff s 
                        where t.staffno = s.staffno and t.roleno = v_sub
                    )
                    loop
                        merge into tf_b_msgto
                        using dual
                        on (msgid = v_msgid and msggee = v_cursor.staffno)
                        when not matched then
                            insert (msgid, msgstate, msggee, msgdept)
                            values(v_msgid, 0, v_cursor.staffno, v_cursor.departno);
                    end loop; 

                    exit when v_idx = 0;
                end loop;
            end if;
            
            if p_staffs is not null then
                -- split staffs;
                v_last := 1;
                loop
                    v_idx := instr(p_staffs, ',', v_last);
                    if v_idx = 0 then
                       v_sub := substr(p_staffs, v_last);
                    else
                       v_sub := substr(p_staffs, v_last, v_idx - v_last);
                    end if;

                    v_last := v_idx + 1;
                    
                    for v_cursor in 
                    (select t.staffno, t.departno from td_m_insidestaff t where t.staffno = v_sub)
                    loop
                        merge into tf_b_msgto
                        using dual
                        on (msgid = v_msgid and msggee = v_cursor.staffno)
                        when not matched then
                            insert (msgid, msgstate, msggee, msgdept)
                            values(v_msgid, 0, v_cursor.staffno, v_cursor.departno);
                    end loop; 

                    exit when v_idx = 0;
                end loop;
            end if;
            
        exception when others then
            p_retCode := 'S100001003';
            p_retMsg  := sqlerrm;
            ROLLBACK; RETURN;
        end;
    end if;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;

end;

/

show errors
