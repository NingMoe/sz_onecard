create or replace procedure SP_PB_ReportLoss_BAT
(
    p_cardno                char,         --����
    p_cardnewstate          char,         --�����ϱ���״̬
    p_createtime            date,         --��ʧʱ��/���ʱ�䣬��̨����ʱ��
    p_tradetypecode         char,         --ҵ�����ͱ���
	p_TRADEID            out char, -- Return Trade Id
    p_curroper              char,       --��ǰ������
    p_currdept              char,       --��ǰ�����߲���
    p_retcode               out char,       --�������
    p_retmsg                out varchar2    --������Ϣ
)
as
    v_seq             char(16);    -- ҵ����ˮ��
    v_today           date := sysdate;
    v_ex              exception;
    v_blackstate      char;        --������״̬��0��������1����������2������
    v_creditstatecode char(2);     --���˻�����״̬����
    v_resstatecode      char(2);   --������״̬
    v_destroytime     date := sysdate;
    v_usetag          char;        --�����ϱ���Ч��ʶ
    p_cardstate     char(2); --�����ϱ�ԭ״̬
    p_cardtype        char(1);--�������еĿ����ͣ�0�Ϲ���IC����1��CPU��
    v_createtime      date; ----��ʧʱ��/���ʱ��
    v_exists          int;--���ڿ�����Ŀ
    V_TRADETYPECODE  char(2);--ҵ������
    V_STATE          char(1);--ר���˻�����
    V_COUNT          int:=0;--ר���˻�����
begin
    --У�鿨����Ч��
    begin
          sp_pb_reportloss_checked(p_cardno,p_cardnewstate,p_retcode,p_retmsg);
    --�Ƿ��򷵻�
          if(p_retcode!='0000000000')then
              return;
           end if;
    end;

    --�жϹ�ʧʱ��/���ʱ�� �Ƿ�Ϊ�գ�Ϊ���򸳵�ǰʱ��Ϊ��ʧʱ��
    if(p_createtime is null) then v_createtime :=v_today;
    else v_createtime :=p_createtime;
    end if;

    --��ԭ��״̬
    select cardstate into p_cardstate from tf_f_cardrec where cardNo=p_cardno;

    --�жϿ��ų��ȣ� ����8λ ����Ϊ1��cpu����������Ϊ0��m1����
    if    length(p_cardno)>8 then p_cardtype :='1';
          else p_cardtype :='0';
    end if;

    --�жϿ�״̬
    if p_cardstate not in ('10', '11','03','04')
    or  p_cardnewstate not in ('10', '11','03','04') then
        p_retcode := 'A099001100';
        p_retmsg  := '��״̬��������' ;
        return;
    end if;

    sp_getseq(seq => v_seq);
  p_TRADEID := v_seq;

     IF p_cardnewstate = '10' or p_cardnewstate = '11'
     THEN v_blackstate := '2'; v_creditstatecode:='00';v_usetag:='1';

     ELSIF p_cardnewstate = '03'
     THEN v_blackstate := '0';v_creditstatecode:='01';v_resstatecode := '03';v_usetag:='0';

     ELSIF p_cardnewstate = '04'
     THEN v_blackstate := '0';v_creditstatecode:='01';v_usetag:='0';

     ELSE p_retCode := 'A099001100'; p_retmsg  := '��״̬��������' ;
      return;
    END IF;

    IF p_cardstate = '03' THEN v_resstatecode := '06';v_destroytime :='';
    END IF;

    -- ���¿�����״̬����Һ���ҽ��ʱ����
    begin
        if p_cardstate = '03' or p_cardnewstate = '03' then
              update tl_r_icuser
              set  destroytime = v_destroytime,
                    resstatecode = v_resstatecode,
                    updatestaffno = p_curroper,
                    updatetime = v_today
                    where  cardno = p_cardno
                    and     resstatecode != v_resstatecode;
              if  sql%rowcount != 1 then raise v_ex; end if;
         end if;
    exception
          when others then
              p_retCode := 'A099001106';
              p_retMsg  := '���¿�����ʧ��' || sqlerrm;
             rollback; return;
    end;

    -- ���¿����ϱ���״̬
    begin
          update  tf_f_cardrec
          set  cardstate = p_cardnewstate,
              updatestaffno = p_curroper,
              updatetime = v_today,
              usetag = v_usetag
              where  cardno = p_cardno
              and cardstate=p_cardstate;
          if  sql%rowcount != 1 then raise v_ex; end if;
    exception
          when others then
              p_retcode := 'A099001101';
              p_retmsg  := '���¿����ϱ�ʧ��' || sqlerrm;
              rollback; return;
    end;

    --�����˻���״̬
    begin
          update tf_f_cardewalletacc
          set creditstatecode = v_creditstatecode,
              creditstachangetime = v_today
          where cardno=p_cardno;
          if  sql%rowcount != 1 then raise v_ex; end if;
    exception
          when others then
              p_retcode := 'A099001102';
              p_retmsg  := '�����˻����ʧ��' || sqlerrm;
              rollback; return;
    end;
    -- ��¼ҵ����̨��
    begin
          insert into tf_b_trade
                  (tradeid, cardno,tradetypecode,
                asn, cardtypecode,
                operatestaffno, operatedepartid, operatetime,  cardstate)
          select    v_seq,cardno,p_tradetypecode,
                  asn,cardtypecode,
                  p_curroper,p_currdept, v_today,p_cardstate
          from tf_f_cardrec
          where cardno = p_cardno;
    exception
          when others then
              p_retcode := 'A099001103';
              p_retmsg  := '��¼ҵ��̨��ʧ��' || sqlerrm;
              rollback; return;
    end;

    -- д�����º�����
    -- ��ʧʱ��ͽ��ʱ���Ϊ����ʱ��
    begin
          IF p_cardstate = '10' or p_cardstate = '11' THEN
                update TF_B_LOSS_BLACK set blackstate=v_blackstate ,
                   updatestaffno = p_curroper, updatetime = v_today,
                   createtime=v_createtime--�����������״̬��Ϊ�ڹһ���ң������createtime
                  where cardno=p_cardno;
                  if  sql%rowcount != 1 then
                      insert into TF_B_LOSS_BLACK
                          (cardno,blackstate,blacktype,cardtype,warntype,
                          createtime,WARNLEVEL, updatestaffno, updatetime)
                      values
                          (p_cardno,v_blackstate,'0',p_cardtype,'6',
                          v_createtime,'2',p_curroper,v_today)  ;

                  end if;
            ELSE
                 update TF_B_LOSS_BLACK set blackstate=v_blackstate ,
                   updatestaffno = p_curroper, updatetime = v_createtime
                  where cardno=p_cardno;
                  if  sql%rowcount != 1 then
                      insert into TF_B_LOSS_BLACK
                          (cardno,blackstate,blacktype,cardtype,warntype,
                          createtime,WARNLEVEL, updatestaffno, updatetime)
                      values
                          (p_cardno,v_blackstate,'0',p_cardtype,'6',
                          v_today,'2',p_curroper,v_createtime)  ;

                  end if;
          END IF;

    exception
          when others then
              p_retcode := 'A099001104';
              p_retmsg  := '��¼��������ʧ��' || sqlerrm;
              rollback; return;
    end;

   -- д���������ϸ
    begin
          update TF_B_LOSS_BLACK_DETAIL set enddate=v_today ,
              updatestaffno = p_curroper, updatetime = v_today
          where cardno=p_cardno
          and enddate = to_date('2050-12-31 00:00:00','yyyy-mm-dd hh24:mi:ss');

          insert into TF_B_LOSS_BLACK_DETAIL
            (cardno, blackstate, startdate, enddate,
            updatestaffno, updatetime)
          values
            (p_cardno, v_blackstate, v_today, to_date('2050/12/31','yyyy/MM/dd'),
             p_curroper, v_today);
    exception
          when others then
              p_retcode := 'A099001105';
              p_retmsg  := '��¼��������ϸʧ��222' || sqlerrm;
              rollback; return;
    end;

	--��ʧ����֮�󣬾ɿ���ң�������¿�֮��Ĳ�����ϵ
	BEGIN
		UPDATE TF_F_CARDREC
		SET RSRV1=NULL,
		UPDATESTAFFNO = p_currOper,
        UPDATETIME    = v_today
		WHERE CARDNO=p_cardno;
		IF SQL%ROWCOUNT!=1 THEN RAISE V_EX; END IF;
		EXCEPTION WHEN OTHERS THEN
			P_RETCODE:='2015010700';
			P_RETMSG:='���¿����ϱ�ȡ���¾ɿ�֮�������ϵʧ��';
			rollback;return;
	END;

  p_retcode := '0000000000';
  p_retmsg  := '';
  commit; return;
end;
/
show errors