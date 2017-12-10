--反洗钱监控存储过程
--每天凌晨1：00跑

--执行方案，先把之前所有的数据监控一遍。找出可疑或大额的数据，然后从第2天开始，只监控2天前或2个月前的数据。
create or replace procedure SP_WA_Monitor_ANTI
(
    p_retCode        OUT INT,
    p_retMsg         OUT VARCHAR2
)
as
    v_taskState      TF_B_WARN_TASK_ANTI.TASKSTATE%type;
    v_taskday     	char(8)				;
	v_taskmonth		char(6)				;

	V_CONDCODE  	CHAR(4)             ;
	V_INITIALTIME  	DATE        		;
	V_LASTTIME  	DATE           		;
	V_TRADENUM  	INT                 ;
	V_SUBJECTCODE	VARCHAR2(20)		;
	V_NAME    		VARCHAR2(200)       ;
	V_PAPERTYPE  	CHAR(2)             ;
	V_PAPERNAME  	VARCHAR2(200)        ;
	V_ADDR    		VARCHAR2(200)       ;
	V_PHONE    		VARCHAR2(100)        ;
	V_EMAIL    		VARCHAR2(100)        ;
	V_CALLINGNO  	CHAR(2)             ;
	
	V_RISKGRADE  	CHAR(2)             ;
	V_SUBJECTTYPE  	CHAR(2)         	;
	V_LIMITTYPE  	CHAR(2)             ;
	V_REMARK    	VARCHAR(100)    	;


	V_SUBJECTID  	NUMERIC        		;
	V_PAYMODE  		VARCHAR2(4)         ;
	V_TRADEMONEY  	INT             	;
	V_TRADETIME  	CHAR(14)           	;
	V_SPNAME  		VARCHAR2(200)       ;
	V_CARDNO  		VARCHAR2(16)        ;
	V_TRADEID  		VARCHAR2(30)        ;
	V_BANKNAME  	VARCHAR2(100)       ;
	V_BANKACCOUNT  	VARCHAR2(30)    	;
	V_CARDNO_DE  	VARCHAR2(16)        ;
	V_PAYMENTTAG	VARCHAR2(2)        	;
	
	
	
	V_SUBJECTCNT  	INT          		;
	V_DETAILCNT  	INT                 ;
	
	V_TRADEDATE  	varchar2(8)			;
	
	V_COUNT    		int					;
	V_TOTALMONEY 	int					;
	V_PARTNERNO		VARCHAR2(20)		;
	V_PARTNERNAME	VARCHAR2(200)		;

	V_SAMNO			VARCHAR2(20)		;
	V_TODAY			date:=sysdate		;
	V_SQL			VARCHAR2(2000)		;
	v_c_detail      SYS_REFCURSOR		;
	V_GROUPNAME     varchar2(50)		;--中文的情况下，varchar2(50)往varchar2(200)赋值时会莫名带空格或不匹配
	

begin
	v_taskday:=to_char(V_TODAY-2, 'YYYYMMDD');
	
		-- 查看今日任务是否已经生成
		begin
			select TASKSTATE into v_taskState from TF_B_WARN_TASK_ANTI
			where  TASKDAY = v_taskday;

			--delete from TF_B_WARN_ANTI where to_char(LASTTIME,'yyyyMMdd')=v_taskday and CONDCODE=V_CONDCODE;
			--delete from TF_B_WARN_DETAIL_ANTI where subjectid in (
			--select id from TF_B_WARN_ANTI where to_char(LASTTIME,'yyyyMMdd')=v_taskday and CONDCODE=V_CONDCODE);
		exception
			when no_data_found then -- 没有生成，生成之
				insert into TF_B_WARN_TASK_ANTI(TASKDAY,TASKSTATE)
				values (v_taskday,0);
			when others then
				p_retCode := sqlcode; p_retMsg  := lpad(sqlerrm, 120);
				rollback; return;
		end;
	
	--没有执行完的任务也要顺序执行完
	for v_c_task in (select ROWID, TASKSTATE, TASKDAY
            from TF_B_WARN_TASK_ANTI where TASKSTATE = 0 order by TASKDAY asc)
    loop
		
		v_taskmonth:=to_char(add_months(to_date(v_c_task.TASKDAY,'yyyyMMdd'),-2), 'YYYYMM');
		V_SUBJECTCNT:=0;--主体总数量
		V_DETAILCNT:=0;--主体交易总量
		FOR v_cond IN 
		(
			select w.CONDCODE, w.CONDCONTENT,w.CONDCATE,w.SUBJECTTYPE,w.CONDWHERE,w.RISKGRADE,w.LIMITTYPE,w.DATETYPE
			from   TD_M_WARNCOND_ANTI w
			where  w.usetag='1'
			and w.CONDCODE not in ('0104','0105','0109','0110','0111')
			and ((w.DATETYPE='02' and  not exists (select 1 from TF_B_WARN_TASK_ANTI 
			where substr(TASKDAY,1,6)=substr(v_c_task.TASKDAY,1,6) and TASKSTATE != 0)) 
				or w.DATETYPE='01')--判断按月监控的条件是否已监控过
			order by w.CONDCODE asc
		)
		loop
			--判断按月监控的条件是否已监控过
			V_CONDCODE:=v_cond.CONDCODE;
			v_RISKGRADE:=v_cond.RISKGRADE;
			v_SUBJECTTYPE:=v_cond.SUBJECTTYPE;
			v_LIMITTYPE:=v_cond.LIMITTYPE;
			
			
			update TF_B_WARN_TASK_ANTI
			set    TASKSTATE      = 1      ,  -- 任务开始运行
				   STARTTIME      = sysdate  -- 开始运行时间   
			where  rowid        = v_c_task.ROWID;
				
			-- 重置当日清单临时表
			delete from TMP_WARN_TODAYCARDS_ANTI1;
			execute immediate 'insert into TMP_WARN_TODAYCARDS_ANTI1(CARDNO,BYDAY,BYMONTH,BALUNTINO,SAMNO,ANTICOUNT,ANTIMONEY,GROUPNAME
			) '|| replace(replace(v_cond.CONDCONTENT,'{day}',v_c_task.TASKDAY),'{month}',v_taskmonth);	--保证每天监控的数据不重复

			--开始
			p_retCode := 0; 
			p_retMsg  := '';
			--去除公交，出租，轻轨，信息亭
			
			for v_c in (
				select CARDNO,BYDAY,BYMONTH,BALUNTINO,SAMNO,ANTICOUNT,ANTIMONEY,GROUPNAME
				from TMP_WARN_TODAYCARDS_ANTI1
			)
			loop
				V_CARDNO:=v_c.CARDNO;
				V_TRADEDATE:=nvl(v_c.BYDAY,'')||nvl(v_c.BYMONTH,'');
				V_COUNT:=v_c.ANTICOUNT;
				V_TOTALMONEY:=v_c.ANTIMONEY;
				V_SUBJECTCODE:=v_c.BALUNTINO;
				V_SAMNO:=v_c.SAMNO;
				V_GROUPNAME:=v_c.GROUPNAME;
				--01客户，02账户，03商户,04商户终端
				if(v_cond.SUBJECTTYPE='01') then --订单
					begin
						select m1,m2,m3,m4,m5,m6 into V_NAME,V_PAPERTYPE,V_PAPERNAME,V_ADDR,V_PHONE,V_EMAIL from 
						(select t.GROUPNAME m1,'11' m2,t.IDCARDNO m3,'' m4,t.PHONE m5,'' m6
						from TF_F_ORDERFORM t 
						where t.GROUPNAME=V_GROUPNAME order by ORDERDATE desc) where rownum=1;
					EXCEPTION when no_data_found THEN
						null;
					end;
				elsif(v_cond.SUBJECTTYPE='02') then --持卡人信息
					--主体信息
					begin
						select t.custname,decode(t.PAPERTYPECODE,'00','11','21'),decode(t.PAPERTYPECODE,'11',t.PAPERNO,'000000000'),t.CUSTADDR,t.CUSTPHONE,t.CUSTEMAIL 
						into V_NAME,V_PAPERTYPE,V_PAPERNAME,V_ADDR,V_PHONE,V_EMAIL
						from Tf_f_Customerrec t 
						where t.cardno=V_CARDNO;
					EXCEPTION when no_data_found THEN
						null;
					end;
				elsif(v_cond.SUBJECTTYPE='03' or v_cond.SUBJECTTYPE='04') then--商户或终端信息
					begin
						select t.balunit,'21','000000000',t.UNITADD,t.UNITPHONE,t.UNITEMAIL
						into V_NAME,V_PAPERTYPE,V_PAPERNAME,V_ADDR,V_PHONE,V_EMAIL
						from tf_trade_balunit t 
						where t.balunitno=V_SUBJECTCODE;
						V_NAME:=V_NAME||':'||NVL(V_SAMNO,'');
					EXCEPTION when no_data_found THEN
						null;
					end;
				end if;
				--解决直接赋值编译报错的问题
				select  TF_B_WARN_ANTI_SEQ.nextval
				into V_SUBJECTID
				from dual;
				
				V_INITIALTIME:=sysdate;
				V_LASTTIME:=sysdate;
				V_CALLINGNO:='';
				
				V_REMARK:='';

				V_TRADENUM:=0;
				--condcate01消费清单表，02充值清单表，03订单表
				--01订单客户，02卡账户，03商户,04商户终端,05商户和卡账户
				if(v_cond.condcate='01' and v_cond.subjecttype='02') THEN--从消费清单中监控账户
					v_sql:='select a.tradedate||a.tradetime,a.trademoney,a.ID,c.bank,b.BANKACCNO,b.balunitno,b.balunit,'''' spname,''0600'' PAYMODE,a.cardno,''02'' paymenttag
						from tq_trade_right a, tf_trade_balunit b,td_m_bank c
						where a.balunitno=b.balunitno and b.bankcode=c.bankcode 
						and a.cardno='''||V_CARDNO||'''';
				elsif(v_cond.condcate='01' and v_cond.subjecttype='03') THEN--从消费清单中监控商户
					v_sql:='select a.tradedate||a.tradetime,a.trademoney,a.ID,c.bank,b.BANKACCNO,b.balunitno,b.balunit,'''' spname,''06000'' PAYMODE,a.cardno,''02'' paymenttag
						from tq_trade_right a, tf_trade_balunit b,td_m_bank c
						where a.balunitno=b.balunitno and b.bankcode=c.bankcode
						and a.balunitno='''||V_SUBJECTCODE||'''';
				elsif(v_cond.condcate='01' and v_cond.subjecttype='04') THEN--从消费清单中监控终端
					v_sql:='select a.tradedate||a.tradetime,a.trademoney,a.ID,c.bank,b.BANKACCNO,b.balunitno,b.balunit,'''' spname,''0600'' PAYMODE,a.cardno,''02'' paymenttag
						from tq_trade_right a, tf_trade_balunit b,td_m_bank c
						where a.balunitno=b.balunitno and b.bankcode=c.bankcode
						and a.samno='''||V_SAMNO||'''
						and a.balunitno='''||V_SUBJECTCODE||'''';
				elsif(v_cond.condcate='02' and v_cond.subjecttype='02') THEN--从充值清单中监控账户
					v_sql:='select a.tradedate||a.tradetime,a.trademoney,a.ID,'''','''','''','''','''' spname,''0400'' PAYMODE,a.cardno,''01'' paymenttag
						from tq_supply_right a
						where a.cardno='''||V_CARDNO||'''';
				elsif(v_cond.condcate='01' and v_cond.subjecttype='05') THEN--从消费清单中监控商户和卡账户
					v_sql:='select a.tradedate||a.tradetime,a.trademoney,a.ID,c.bank,b.BANKACCNO,b.balunitno,b.balunit,'''' spname,''0600'' PAYMODE,a.cardno,''02'' paymenttag
						from tq_trade_right a, tf_trade_balunit b,td_m_bank c
						where a.balunitno=b.balunitno and b.bankcode=c.bankcode
						and a.balunitno='''||V_SUBJECTCODE||''' and a.cardno='''||V_CARDNO||'''';
				elsif(v_cond.condcate='03' and v_cond.subjecttype='01') THEN--从订单表中监控客户
					v_sql:='select a.ORDERDATE||''000000'',a.TOTALMONEY,a.ORDERNO,'''','''','''','''','''' spname,''0401'' PAYMODE,'''' CARDNO,''01'' paymenttag
						from TF_F_ORDERFORM a
						where a.groupname='''||V_GROUPNAME||'''';
				end if;
		  
				if(v_cond.CONDWHERE is not null) THEN
				  v_sql:=v_sql||' and '|| v_cond.CONDWHERE;
				end if;
				v_sql:=replace(replace(v_sql,'{day}',v_c_task.TASKDAY),'{month}',v_taskmonth);
				open v_c_detail for v_sql;
				loop
					fetch v_c_detail into V_TRADETIME,V_TRADEMONEY,V_TRADEID,V_BANKNAME,V_BANKACCOUNT,V_PARTNERNO,V_PARTNERNAME,V_SPNAME,V_PAYMODE,V_CARDNO_DE,V_PAYMENTTAG;
					exit when v_c_detail%NOTFOUND;
					-- 插入主体交易表
					insert into TF_B_WARN_DETAIL_ANTI
						(ID,SUBJECTID,NAME,PAPERTYPE,PAPERNAME
						,PAYMODE,TRADEMONEY,TRADETIME,SPNAME,CARDNO
					  ,TRADEID,BANKNAME,BANKACCOUNT,REMARK,PARTNERNO,PARTNERNAME,PAYMENTTAG)
					values
					  (TF_B_WARN_DETAIL_ANTI_SEQ.nextval,V_SUBJECTID,V_NAME,V_PAPERTYPE,V_PAPERNAME
					  ,V_PAYMODE,V_TRADEMONEY,to_date(V_TRADETIME,'yyyyMMddHH24miss'),V_SPNAME,V_CARDNO_DE
					  ,V_TRADEID,V_BANKNAME,V_BANKACCOUNT,V_REMARK,V_PARTNERNO,V_PARTNERNAME,V_PAYMENTTAG);
				  
					  V_TRADENUM:=V_TRADENUM+1;
					  V_DETAILCNT:=V_DETAILCNT+1;		  
		
				end loop;
				close v_c_detail;
		  
				  -- 插入主体表
				  insert into TF_B_WARN_ANTI
					(ID,CONDCODE,INITIALTIME,LASTTIME,
					TRADENUM,NAME,SUBJECTCODE,ADDR,
					PHONE,EMAIL,CALLINGNO,PAPERTYPE,PAPERNAME,
					RISKGRADE,SUBJECTTYPE,LIMITTYPE,REMARK,TASKDAY)
				  values
					(V_SUBJECTID,V_CONDCODE,V_INITIALTIME,V_LASTTIME
					,V_TRADENUM,V_NAME,V_SUBJECTCODE,V_ADDR,
					V_PHONE,V_EMAIL,V_CALLINGNO,V_PAPERTYPE,V_PAPERNAME,
					V_RISKGRADE,V_SUBJECTTYPE,V_LIMITTYPE,V_REMARK,v_c_task.TASKDAY);
				  V_SUBJECTCNT:=V_SUBJECTCNT+1;
		
		
		  
			end loop; 
		
	    end loop;
		  --结束
		
		update TF_B_WARN_TASK_ANTI
		set SUBJECTCNT = V_SUBJECTCNT  ,    -- 账户监控运行结束时间
			DETAILCNT= V_DETAILCNT ,
			TRADERETCODE = p_retCode,    -- 账户监控运行返回码
			TRADERETMSG  = p_retMsg ,    -- 账户监控运行返回消息
			ENDTIME    = sysdate  ,    -- 监控运行结束时间
			TASKSTATE  = 2             -- 当日任务状态为已完成
		where  rowid   = v_c_task.ROWID;
		commit;
	end loop;
  COMMIT;
    p_retCode := 0; p_retMsg  := 'OK';
exception when others then
    p_retCode := 0; p_retMsg  := lpad(sqlerrm, 120);
    rollback; return;
end;
/
show errors