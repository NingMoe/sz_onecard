create or replace procedure sp_pb_lockblackcard
(
    p_cardno          char,       --����
    p_retcode     out char,       --�������
    p_curroper        char,       --��ǰ������
    p_currDept        char,       --��ǰ�����߲���
    p_retmsg      out varchar2    --������Ϣ
)
is
    v_today           date := sysdate;
    v_ex              exception;
 begin

--���º�������
begin
      update  tf_b_warn_black
      set     blackstate='1' , updatestaffno = p_curroper, updatetime = v_today
      where    cardno = p_cardno;
        
      if  sql%rowcount != 1 then raise v_ex; end if;
exception
      when others then
          p_retcode := 'A099001301';
          p_retmsg  := '���º�������ʧ��' || sqlerrm;
          rollback; return;
end;

--д������¼��
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
          p_retmsg  := 'д��������¼��ʧ��' || sqlerrm;
          rollback; return;
end;

  p_retcode := '0000000000';
  p_retmsg  := '';
  commit; return;
 end;

/

show errors
