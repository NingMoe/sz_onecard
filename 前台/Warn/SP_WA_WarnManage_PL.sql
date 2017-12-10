/******************************************************/
-- Author  : 
-- Created :
-- Updated : 2010-8-18 上午 09:34:44  James Liang
-- Purpose : 财务监控 -告警单 存储过程
/******************************************************/
create or replace procedure SP_WA_WarnManage
(
    p_funcCode     varchar2,
    p_backWhy      char    ,
    p_condCode     varchar2,
    p_warnType     char    , -- depreciated
    p_warnLevel    char    ,

    p_currOper     char    ,
    p_currDept     char    ,
    p_retCode  out char    ,
    p_retMsg   out varchar2
)
as
    v_funcCode varchar2(16) := p_funcCode;
    v_today    date         := sysdate;
    v_int      int;
    v_rowid    UROWID;
    v_warnType TD_M_WARNCOND.WARNTYPE%type;
begin

    -- 入黑名单
    if v_funcCode = 'Black' then
        begin
            -- 删除监控名单之前备份
            insert into th_b_warn_monitor(HSEQNO, BACKTIME, BACKSTAFF, BACKWHY, BACKREMARK,
                    SEQNO, CARDNO, CREATETIME, CONDCODE, WARNTYPE,
                WARNLEVEL, UPDATESTAFFNO, UPDATETIME, REMARK)
            select th_b_warn_monitor_seq.nextval, v_today, p_currOper, 0, null,
                    SEQNO, CARDNO, CREATETIME, CONDCODE, WARNTYPE,
                WARNLEVEL, UPDATESTAFFNO, UPDATETIME, REMARK
            from  tf_b_warn_monitor
            where  cardno in (select cardno from TMP_WARN_TODAYCARDS1);

            -- 从监控名单中删除
            delete from tf_b_warn_monitor
            where  cardno in (select cardno from TMP_WARN_TODAYCARDS1);

            -- 插入黑名单
            for v_cursor in (select cardno from TMP_WARN_TODAYCARDS1)
            loop
                update tf_b_warn_black t set
                    t.createtime    = v_today,
                    t.warntype      = '3',
                    t.warnlevel     = '3',
                    t.updatestaffno = p_currOper,
                    t.updatetime    = v_today
                where t.cardno = v_cursor.cardno;

                v_int := sql%rowcount;
                if v_int = 0 then
                    insert into tf_b_warn_black(
                        cardno,createtime,warntype, warnlevel,updatestaffno,updatetime
                    ) values (
                        v_cursor.cardno, v_today, '3', '3', p_currOper, v_today
                    );
                end if;

                insert into th_b_warn_black(HSEQNO, BACKTIME, BACKSTAFF, BACKWHY,
                    BACKREMARK, CARDNO, CREATETIME, WARNTYPE, WARNLEVEL, UPDATESTAFFNO,
                    UPDATETIME, DOWNTIME, REMARK)
                select th_b_warn_black_seq.nextval, v_today, p_currOper, decode(v_int, 0, 2, 1),
                    null,  CARDNO, CREATETIME, WARNTYPE, WARNLEVEL, UPDATESTAFFNO,
                    UPDATETIME, DOWNTIME, REMARK
                from tf_b_warn_black
                where cardno = v_cursor.cardno;
            end loop;
        exception when others then
            p_retCode := sqlcode;
            p_retMsg  := sqlerrm;
            rollback; return;
        end;

        -- 入完黑名单继续把告警关闭了
        v_funcCode := 'Close';

    end if;

    -- 关闭告警
    if v_funcCode = 'Close' then
        begin
            -- 入告警主单备份表
            insert into TH_B_WARN (
                BACKTIME    , BACKSTAFF   ,   BACKWHY     , BACKREMARK  ,
                CARDNO      , CONDCODE    ,   INITIALTIME , LASTTIME    ,
                DETAILS     , WARNTYPE    ,   WARNLEVEL   , WARNSRC     ,
                PREMONEY    , TRADEMONEY  ,   ACCBALANCE  , REMARK      ,
                HSEQNO
            ) select
                v_today     , p_currOper  ,   p_backWhy   , ''          ,
                CARDNO      , CONDCODE    ,   INITIALTIME , LASTTIME    ,
                DETAILS     , WARNTYPE    ,   WARNLEVEL   , WARNSRC     ,
                PREMONEY    , TRADEMONEY  ,   ACCBALANCE  , REMARK      ,
                TH_B_WARN_seq.nextval
            from TF_B_WARN
            where cardno in (select cardno from TMP_WARN_TODAYCARDS1);

            -- 入告警详单备份表
            insert into TH_B_WARN_DETAIL (
                BACKTIME    , BACKSTAFF   ,   BACKWHY     , BACKREMARK  ,
                CARDNO      , SEQNO       ,   ID          , LASTTIME    ,
                CONDCODE    , WARNTYPE    ,   WARNLEVEL   , WARNSRC     ,
                PREMONEY    , TRADEMONEY  ,   ACCBALANCE  , REMARK      ,
                HSEQNO
            ) select 
                v_today     , p_currOper  ,   p_backWhy   , ''          ,
                CARDNO      , SEQNO       ,   ID          , LASTTIME    ,
                CONDCODE    , WARNTYPE    ,   WARNLEVEL   , WARNSRC     ,
                PREMONEY    , TRADEMONEY  ,   ACCBALANCE  , REMARK      ,
                TH_B_WARN_DETAIL_seq.nextval
            from TF_B_WARN_DETAIL
            where cardno in (select cardno from TMP_WARN_TODAYCARDS1);

            -- 删除告警主单
            delete from TF_B_WARN where cardno in (select cardno from TMP_WARN_TODAYCARDS1);
            -- 删除告警详单
            delete from TF_B_WARN_DETAIL where cardno in (select cardno from TMP_WARN_TODAYCARDS1);

        exception when others then
            p_retCode := sqlcode;
            p_retMsg  := sqlerrm;
            rollback; return;
        end;

    elsif v_funcCode = 'Monitor' then
        begin
            -- 删除前备份内容
            insert into th_b_warn_black(HSEQNO, BACKTIME, BACKSTAFF, BACKWHY,
                BACKREMARK, CARDNO, CREATETIME, WARNTYPE, WARNLEVEL, UPDATESTAFFNO,
                UPDATETIME, DOWNTIME, REMARK)
            select th_b_warn_black_seq.nextval, v_today, p_currOper, 0,
                null, CARDNO, CREATETIME, WARNTYPE, WARNLEVEL, UPDATESTAFFNO,
                UPDATETIME, DOWNTIME, REMARK
            from tf_b_warn_black
            where  cardno in (select cardno from TMP_WARN_TODAYCARDS1);

            -- 从黑名单中删除
            delete from tf_b_warn_black
            where  cardno in (select cardno from TMP_WARN_TODAYCARDS1);

            -- 插入监控名单
            select WARNTYPE into v_warnType from TD_M_WARNCOND
            where CONDCODE = p_condCode;

            for v_cursor in (select cardno from TMP_WARN_TODAYCARDS1)
            loop
                insert into tf_b_warn_monitor (
                    seqno, cardno, createtime, condcode, warntype, warnlevel, updatestaffno, updatetime
                )
                values(tf_b_warn_monitor_seq.nextval, v_cursor.cardno, v_today,
                    p_condCode, v_warnType, p_warnLevel, p_currOper, v_today)
                returning rowid into v_rowid;

                insert into TH_B_WARN_MONITOR(HSEQNO, BACKTIME, BACKSTAFF, BACKWHY,
                    BACKREMARK, SEQNO, CARDNO, CREATETIME, CONDCODE, WARNTYPE,
                    WARNLEVEL, UPDATESTAFFNO, UPDATETIME, REMARK)
                select TH_B_WARN_MONITOR_SEQ.nextval, v_today, p_currOper, 2,
                    null, SEQNO, CARDNO, CREATETIME, CONDCODE, WARNTYPE,
                    WARNLEVEL, UPDATESTAFFNO, UPDATETIME, REMARK
                from TF_B_WARN_MONITOR
                where rowid = v_rowid;

            end loop;
            
        exception when others then
            p_retCode := sqlcode;
            p_retMsg  := sqlerrm;
            rollback; return;
        end;
    
	elsif v_funcCode='ANTICLOSE' then
		begin
            
			-- 插入主体表
      insert into TH_B_WARN_ANTI
        (ID,CONDCODE,INITIALTIME,LASTTIME,
        TRADENUM,NAME,SUBJECTCODE,ADDR,
        PHONE,EMAIL,CALLINGNO,PAPERTYPE,PAPERNAME,
        RISKGRADE,SUBJECTTYPE,LIMITTYPE,REMARK,BACKTIME,TASKDAY,CLOSEREASON)
		select ID,CONDCODE,INITIALTIME,LASTTIME,
        TRADENUM,NAME,SUBJECTCODE,ADDR,
        PHONE,EMAIL,CALLINGNO,PAPERTYPE,PAPERNAME,
        RISKGRADE,SUBJECTTYPE,LIMITTYPE,REMARK,sysdate,TASKDAY,b.f1
		from TF_B_WARN_ANTI a,TMP_COMMON_ANTI1 b
		where a.id = b.f0;
			
			
			-- 插入主体交易表
				insert into TH_B_WARN_DETAIL_ANTI
					(ID,SUBJECTID,NAME,PAPERTYPE,PAPERNAME
					,PAYMODE,TRADEMONEY,TRADETIME,SPNAME,CARDNO
				  ,TRADEID,BANKNAME,BANKACCOUNT,REMARK,PARTNERNO,PARTNERNAME,PAYMENTTAG,BACKTIME)
				select ID,SUBJECTID,NAME,PAPERTYPE,PAPERNAME
					,PAYMODE,TRADEMONEY,TRADETIME,SPNAME,CARDNO
				  ,TRADEID,BANKNAME,BANKACCOUNT,REMARK,PARTNERNO,PARTNERNAME,PAYMENTTAG,sysdate
				from TF_B_WARN_DETAIL_ANTI where subjectid in (select f0  from TMP_COMMON_ANTI1);
            
            
            -- 删除告警主单
            delete from TF_B_WARN_ANTI where  id in (select f0  from TMP_COMMON_ANTI1);
            -- 删除告警详单
            delete from TF_B_WARN_DETAIL_ANTI where  subjectid in (select f0  from TMP_COMMON_ANTI1);

        exception when others then
            p_retCode := sqlcode;
            p_retMsg  := sqlerrm;
            rollback; return;
        end;
	elsif v_funcCode='ANTICLOSERETURN' then
		begin

			-- 插入主体表
      insert into TF_B_WARN_ANTI
        (ID,CONDCODE,INITIALTIME,LASTTIME,
        TRADENUM,NAME,SUBJECTCODE,ADDR,
        PHONE,EMAIL,CALLINGNO,PAPERTYPE,PAPERNAME,
        RISKGRADE,SUBJECTTYPE,LIMITTYPE,REMARK,TASKDAY)
		select ID,CONDCODE,INITIALTIME,LASTTIME,
        TRADENUM,NAME,SUBJECTCODE,ADDR,
        PHONE,EMAIL,CALLINGNO,PAPERTYPE,PAPERNAME,
        RISKGRADE,SUBJECTTYPE,LIMITTYPE,REMARK,TASKDAY
		from TH_B_WARN_ANTI where id in (select f0 from TMP_COMMON_ANTI1);


			-- 插入主体交易表
				insert into TF_B_WARN_DETAIL_ANTI
					(ID,SUBJECTID,NAME,PAPERTYPE,PAPERNAME
					,PAYMODE,TRADEMONEY,TRADETIME,SPNAME,CARDNO
				  ,TRADEID,BANKNAME,BANKACCOUNT,REMARK,PARTNERNO,PARTNERNAME,PAYMENTTAG)
				select ID,SUBJECTID,NAME,PAPERTYPE,PAPERNAME
					,PAYMODE,TRADEMONEY,TRADETIME,SPNAME,CARDNO
				  ,TRADEID,BANKNAME,BANKACCOUNT,REMARK,PARTNERNO,PARTNERNAME,PAYMENTTAG
				from TH_B_WARN_DETAIL_ANTI where subjectid in (select f0  from TMP_COMMON_ANTI1);


            -- 删除告警主单
            delete from TH_B_WARN_ANTI where  id in (select f0  from TMP_COMMON_ANTI1);
            -- 删除告警详单
            delete from TH_B_WARN_DETAIL_ANTI where  subjectid in (select f0  from TMP_COMMON_ANTI1);

        exception when others then
            p_retCode := sqlcode;
            p_retMsg  := sqlerrm;
            rollback; return;
        end;
	end if;
        
    p_retCode := '0000000000'; p_retMsg  := '成功';
    commit; return;

end;

/

show errors

