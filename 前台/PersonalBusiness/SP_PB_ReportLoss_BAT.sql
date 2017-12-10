create or replace procedure SP_PB_ReportLoss_BAT
(
    p_cardno                char,         --卡号
    p_cardnewstate          char,         --卡资料表新状态
    p_createtime            date,         --挂失时间/解挂时间，后台调用时传
    p_tradetypecode         char,         --业务类型编码
	p_TRADEID            out char, -- Return Trade Id
    p_curroper              char,       --当前操作者
    p_currdept              char,       --当前操作者部门
    p_retcode               out char,       --错误编码
    p_retmsg                out varchar2    --错误信息
)
as
    v_seq             char(16);    -- 业务流水号
    v_today           date := sysdate;
    v_ex              exception;
    v_blackstate      char;        --黑名单状态：0黑名单，1已锁定卡，2正常卡
    v_creditstatecode char(2);     --卡账户信用状态编码
    v_resstatecode      char(2);   --卡库存表状态
    v_destroytime     date := sysdate;
    v_usetag          char;        --卡资料表有效标识
    p_cardstate     char(2); --卡资料表原状态
    p_cardtype        char(1);--黑名单中的卡类型：0老公交IC卡，1新CPU卡
    v_createtime      date; ----挂失时间/解挂时间
    v_exists          int;--存在卡号数目
    V_TRADETYPECODE  char(2);--业务类型
    V_STATE          char(1);--专有账户类型
    V_COUNT          int:=0;--专有账户数量
begin
    --校验卡的有效性
    begin
          sp_pb_reportloss_checked(p_cardno,p_cardnewstate,p_retcode,p_retmsg);
    --非法则返回
          if(p_retcode!='0000000000')then
              return;
           end if;
    end;

    --判断挂失时间/解挂时间 是否为空，为空则赋当前时间为挂失时间
    if(p_createtime is null) then v_createtime :=v_today;
    else v_createtime :=p_createtime;
    end if;

    --卡原先状态
    select cardstate into p_cardstate from tf_f_cardrec where cardNo=p_cardno;

    --判断卡号长度： 大于8位 类型为1（cpu卡），否则为0（m1卡）
    if    length(p_cardno)>8 then p_cardtype :='1';
          else p_cardtype :='0';
    end if;

    --判断卡状态
    if p_cardstate not in ('10', '11','03','04')
    or  p_cardnewstate not in ('10', '11','03','04') then
        p_retcode := 'A099001100';
        p_retmsg  := '卡状态参数错误' ;
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

     ELSE p_retCode := 'A099001100'; p_retmsg  := '卡状态参数错误' ;
      return;
    END IF;

    IF p_cardstate = '03' THEN v_resstatecode := '06';v_destroytime :='';
    END IF;

    -- 更新卡库存表状态，书挂和书挂解挂时更新
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
              p_retMsg  := '更新卡库存表失败' || sqlerrm;
             rollback; return;
    end;

    -- 更新卡资料表中状态
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
              p_retmsg  := '更新卡资料表失败' || sqlerrm;
              rollback; return;
    end;

    --更新账户表状态
    begin
          update tf_f_cardewalletacc
          set creditstatecode = v_creditstatecode,
              creditstachangetime = v_today
          where cardno=p_cardno;
          if  sql%rowcount != 1 then raise v_ex; end if;
    exception
          when others then
              p_retcode := 'A099001102';
              p_retmsg  := '更新账户表表失败' || sqlerrm;
              rollback; return;
    end;
    -- 记录业务主台帐
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
              p_retmsg  := '记录业务台账失败' || sqlerrm;
              rollback; return;
    end;

    -- 写入或更新黑名单
    -- 挂失时间和解挂时间均为传递时间
    begin
          IF p_cardstate = '10' or p_cardstate = '11' THEN
                update TF_B_LOSS_BLACK set blackstate=v_blackstate ,
                   updatestaffno = p_curroper, updatetime = v_today,
                   createtime=v_createtime--如果是由正常状态改为口挂或书挂，则更新createtime
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
              p_retmsg  := '记录黑名单表失败' || sqlerrm;
              rollback; return;
    end;

   -- 写入黑名单明细
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
              p_retmsg  := '记录黑名单明细失败222' || sqlerrm;
              rollback; return;
    end;

	--挂失补卡之后，旧卡解挂，解除和新卡之间的补卡关系
	BEGIN
		UPDATE TF_F_CARDREC
		SET RSRV1=NULL,
		UPDATESTAFFNO = p_currOper,
        UPDATETIME    = v_today
		WHERE CARDNO=p_cardno;
		IF SQL%ROWCOUNT!=1 THEN RAISE V_EX; END IF;
		EXCEPTION WHEN OTHERS THEN
			P_RETCODE:='2015010700';
			P_RETMSG:='更新卡资料表，取消新旧卡之间关联关系失败';
			rollback;return;
	END;

  p_retcode := '0000000000';
  p_retmsg  := '';
  commit; return;
end;
/
show errors