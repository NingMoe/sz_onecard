create or replace procedure sp_pb_lockblackcard
(
    p_cardno          char,       --卡号
    p_retcode     out char,       --错误编码
    p_curroper        char,       --当前操作者
    p_currDept        char,       --当前操作者部门
    p_retmsg      out varchar2    --错误信息
)
is
    v_today           date := sysdate;
    v_ex              exception;
 begin

--更新黑名单表
begin
      update  tf_b_warn_black
      set     blackstate='1' , updatestaffno = p_curroper, updatetime = v_today
      where    cardno = p_cardno;
        
      if  sql%rowcount != 1 then raise v_ex; end if;
exception
      when others then
          p_retcode := 'A099001301';
          p_retmsg  := '更新黑名单表失败' || sqlerrm;
          rollback; return;
end;

--写锁卡记录表
begin
      insert into tf_b_lock
        (cardno, locktype, posno, samno, 
        locktime, updatetime)
      values
        (p_cardno, '2', '', '', 
        v_today, v_today);
exception
      when others then
          p_retcode := 'A099001303';
          p_retmsg  := '写入锁卡记录表失败' || sqlerrm;
          rollback; return;
end;

  p_retcode := '0000000000';
  p_retmsg  := '';
  commit; return;
 end;

/

show errors
