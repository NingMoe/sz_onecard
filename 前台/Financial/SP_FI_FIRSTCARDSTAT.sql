/******************************************************/
-- Author  : shilei
-- Created : 2012-3-26 
-- Purpose : 对应需求变更单_20120202-001，只跑一次初始总量
/******************************************************/
create or replace procedure SP_FI_FIRSTCARDSTAT
(
    P_MONTH              CHAR    ,
    P_retCode            OUT INT ,
    P_retMsg             OUT VARCHAR2
)
AS
    v1        int := 0;
    v2        int := 0;
    v3        int := 0;
    v4        int := 0;
    v5        int := 0;
    v7        int := 0;
    v8        int := 0;
    v9        int := 0;
    temp      int := 0;
    v_count   number(2):=1;
    v_c       SYS_REFCURSOR;
    v_year    varchar2(4);
    v_month   varchar2(2);
    v_sql 		varchar2(2000);
BEGIN
    v_year  := substr(P_MONTH,1,4);
	  v_month := substr(P_MONTH,5,2);
		---------------------礼金卡-------------------
		
		--利金卡发卡总量
		select count(*) into v1
		from  tf_b_trade 
		where cardno like '215005%' 
		and   tradetypecode in ('50','51')
		and   CANCELTAG = '0'
		and   to_char(operatetime,'yyyyMM') <= P_MONTH;
		
		--利金卡1-12月发卡量
		select count(*) into v2
		from  tf_b_trade 
		where cardno like '215005%' 
		and   tradetypecode in ('50','51')
		and   to_char(operatetime,'yyyy') = v_year
		and   CANCELTAG = '0';		
		
		
		--利金卡当月发卡量
		select count(*) into v3
		from  tf_b_trade 
		where cardno like '215005%' 
		and   tradetypecode in ('50','51')
		and   to_char(operatetime,'yyyyMM') = P_MONTH
		and   CANCELTAG = '0';		
		
		
		--利金卡有消费卡
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy') = v_year
		and cardno like '215005%';
		
		--利金卡无消费新售卡
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy') = v_year
		and a.cardno like '215005%'and a.LASTCONSUMETIME is null;
		
		
		--利金卡当月刷卡量
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_month||'
		     where cardno like ''215005%''';
		execute immediate v_sql into v7;
		--利金卡1-12月刷卡量
		while v_count<=v_month
		loop			
		if v_count < 10 then 
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_0'||v_count||'
		     where cardno like ''215005%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		else
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_count||'
		     where cardno like ''215005%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		end if;
		execute immediate v_sql into temp;			
		v8 := v8 + nvl(temp,0);
		v_count := v_count+1;
		end loop;
		select sum(trademoney) into temp
		from TH_TRADE_RIGHT
		WHERE cardno like '215005%'
		AND  TO_CHAR(DEALTIME,'yyyy')=v_year ;
		v8 := v8 + nvl(temp,0);
		
		--利金卡刷卡额总量
		v_count := 1;
		while v_count <= 12
		loop
		if v_count < 10 then 
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_0'||v_count||'
		     where cardno like ''215005%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		else
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_count||'
		     where cardno like ''215005%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
	  end if;
		execute immediate v_sql into temp;			
		v9 := v9 + nvl(temp,0);
		v_count := v_count+1;
		end loop;
		select sum(trademoney) into temp
		from TH_TRADE_RIGHT
		WHERE cardno like '215005%';
		v9 := v9 + nvl(temp,0);

		--记录财务每月上报汇总表
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , 
		    MONTHPAYMONEY , YEARPAYMONEY , TOTALPAYMONEY , STATTIME
		)values(
		    '215005'      , '利金卡'     , v1            , v2           ,
		    v3            , v4           , v5            , 
		    v7            , v8           , v9            , P_MONTH
		);
commit;
		---------------------月票卡-------------------
		v8 := 0;
		v9 := 0;
		v_count := 1;
		--月票卡发卡总量
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDCOUNTACC)
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--月票卡1-12月发卡量
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDCOUNTACC)
		and to_char(selltime,'yyyy') = v_year;
		
		--月票卡当月发卡量
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDCOUNTACC)
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--月票卡有消费卡
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno in (select cardno from TF_F_CARDCOUNTACC);
		
		--月票卡无消费新售卡
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno in (select cardno from TF_F_CARDCOUNTACC)and a.LASTCONSUMETIME is null;
		

		--记录财务每月上报汇总表
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , 
		    STATTIME
		)values(
		    '215006'      , '月票卡'     , v1            , v2           ,
		    v3            , v4           , v5            , 
		    P_MONTH
		);
commit;
		-----------------吴江市民卡------------------
		v8 := 0;
		v9 := 0;
		v_count := 1;
		--吴江市民卡发卡总量
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno like '215013%'
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--吴江市民卡1-12月发卡量
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno like '215013%'
		and to_char(selltime,'yyyy') = v_year;
		
		--吴江市民卡当月发卡量
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno like '215013%'
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--吴江市民卡有消费卡
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno like '215013%';
		
		--吴江市民卡无消费新售卡
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno like '215013%'and a.LASTCONSUMETIME is null;
		
		
		--吴江市民卡当月刷卡量
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_month||'
		     where cardno like ''215013%''';
		execute immediate v_sql into v7;		
		
		--吴江市民卡1-12月刷卡量
		while v_count<=v_month
		loop
		if v_count < 10 then 
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_0'||v_count||'
		     where cardno like ''215013%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		else
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_count||'
		     where cardno like ''215013%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		end if;
		execute immediate v_sql into temp;		
		v8 := v8 + nvl(temp,0);
		v_count := v_count+1;
		end loop;
		select sum(trademoney) into temp
		from TH_TRADE_RIGHT
		WHERE cardno like '215013%'
		AND  TO_CHAR(DEALTIME,'yyyy')=v_year ;
		v8 := v8 + nvl(temp,0);
		
		--吴江市民卡刷卡额总量
		v_count := 1;
		while v_count <= 12
		loop			
		if v_count < 10 then 
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_0'||v_count||'
		     where cardno like ''215013%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		else
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_count||'
		     where cardno like ''215013%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		end if;	
		execute immediate v_sql into temp;
		v9 := v9 + nvl(temp,0);
		v_count := v_count+1;
		end loop;
		select sum(trademoney) into temp
		from TH_TRADE_RIGHT
		WHERE cardno like '215013%';
		v9 := v9 + nvl(temp,0);

		--记录财务每月上报汇总表
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME  , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM    , UNCONSUNMENUM , 
		    MONTHPAYMONEY , YEARPAYMONEY  , TOTALPAYMONEY , STATTIME
		)values(
		    '215013'      , '吴江市民卡'  , v1            , v2           ,
		    v3            , v4            , v5            , 
		    v7            , v8            , v9            , P_MONTH
		);
		commit;
		-----------------吴江B卡------------------
		v8 := 0;
		v9 := 0;
		v_count := 1;
		--吴江B卡发卡总量
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno like '215031%'
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--吴江B卡1-12月发卡量
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno like '215031%'
		and to_char(selltime,'yyyy') = v_year;
		
		--吴江B卡当月发卡量
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno like '215031%'
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--吴江B卡有消费卡
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno like '215031%';
		
		--吴江B卡无消费新售卡
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno like '215031%'and a.LASTCONSUMETIME is null;
		
		
		--吴江B卡当月刷卡量
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_month||'
		     where cardno like ''215031%''';
		execute immediate v_sql into v7;		
		
		--吴江B卡1-12月刷卡量
		while v_count<=v_month
		loop
		if v_count < 10 then 
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_0'||v_count||'
		     where cardno like ''215031%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		else
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_count||'
		     where cardno like ''215031%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		end if;
		execute immediate v_sql into temp;		
		v8 := v8 + nvl(temp,0);
		v_count := v_count+1;
		end loop;
		select sum(trademoney) into temp
		from TH_TRADE_RIGHT
		WHERE cardno like '215031%'
		AND  TO_CHAR(DEALTIME,'yyyy')=v_year ;
		v8 := v8 + nvl(temp,0);
		
		--吴江B卡刷卡额总量
		v_count := 1;
		while v_count <= 12
		loop			
		if v_count < 10 then 
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_0'||v_count||'
		     where cardno like ''215031%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		else
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_count||'
		     where cardno like ''215031%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		end if;	
		execute immediate v_sql into temp;
		v9 := v9 + nvl(temp,0);
		v_count := v_count+1;
		end loop;
		select sum(trademoney) into temp
		from TH_TRADE_RIGHT
		WHERE cardno like '215031%';
		v9 := v9 + nvl(temp,0);

		--记录财务每月上报汇总表
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME  , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM    , UNCONSUNMENUM ,  
		    MONTHPAYMONEY , YEARPAYMONEY  , TOTALPAYMONEY , STATTIME
		)values(
		    '215031'      , '吴江B卡'     , v1            , v2           ,
		    v3            , v4            , v5            , 
		    v7            , v8            , v9            , P_MONTH
		);
  commit;
		---------------张家港市民卡-----------------
	  v8 := 0;
		v9 := 0;
		v_count := 1;
		--张家港市民卡发卡总量
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno like '215016%'
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--张家港市民卡1-12月发卡量
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno like '215016%'
		and to_char(selltime,'yyyy') = v_year;
		
		--张家港市民卡当月发卡量
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno like '215016%'
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--张家港市民卡有消费卡
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno like '215016%';
		
		--张家港市民卡无消费新售卡
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno like '215016%'and a.LASTCONSUMETIME is null;
		

		--张家港市民卡当月刷卡量
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_month||'
		     where cardno like ''215016%''';
		execute immediate v_sql into v7;
		
		--张家港市民卡1-12月刷卡量
		while v_count<=v_month
		loop
		if v_count < 10 then 
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_0'||v_count||'
		     where cardno like ''215016%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		else
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_count||'
		     where cardno like ''215016%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
	  end if;
		execute immediate v_sql into temp;
		v8 := v8 + nvl(temp,0);
		v_count := v_count+1;
		end loop;
		select sum(trademoney) into temp
		from TH_TRADE_RIGHT
		WHERE cardno like '215016%'
		AND  TO_CHAR(DEALTIME,'yyyy')=v_year ;
		v8 := v8 + nvl(temp,0);
		
		--张家港市民卡刷卡额总量
		v_count := 1;
		while v_count <= 12
		loop
		if v_count < 10 then 
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_0'||v_count||'
		     where cardno like ''215016%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		else
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_count||'
		     where cardno like ''215016%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
	  end if;
		execute immediate v_sql into temp;
		v9 := v9 + nvl(temp,0);
		v_count := v_count+1;
		end loop;
		select sum(trademoney) into temp
		from TH_TRADE_RIGHT
		WHERE cardno like '215016%';
		v9 := v9 + nvl(temp,0);

		--记录财务每月上报汇总表
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME   , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM     , UNCONSUNMENUM , 
		    MONTHPAYMONEY , YEARPAYMONEY   , TOTALPAYMONEY , STATTIME
		)values(
		    '215016'      , '张家港市民卡' , v1            , v2           ,
		    v3            , v4             , v5            , 
		    v7            , v8             , v9            , P_MONTH
		);    
  commit;
		-----------------SIMPASS卡-----------------
	  v8 := 0;
		v9 := 0;
		v_count := 1;
		--SIMPASS卡发卡总量
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno like '215021%'
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--SIMPASS卡1-12月发卡量
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno like '215021%'
		and to_char(selltime,'yyyy') = v_year;
		
		--SIMPASS卡当月发卡量
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno like '215021%'
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--SIMPASS卡有消费卡
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno like '215021%';
		
		--SIMPASS卡无消费新售卡
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno like '215021%'and a.LASTCONSUMETIME is null;
		
		--SIMPASS卡当月刷卡量
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_month||'
		     where cardno like ''215021%''';
		execute immediate v_sql into v7;
		
		--SIMPASS卡1-12月刷卡量
		while v_count<=v_month
		loop
		if v_count < 10 then 
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_0'||v_count||'
		     where cardno like ''215021%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		else
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_count||'
		     where cardno like ''215021%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||''''; 
	  end if;
		execute immediate v_sql into temp;
		v8 := v8 + nvl(temp,0);
		v_count := v_count+1;
		end loop;
		select sum(trademoney) into temp
		from TH_TRADE_RIGHT
		WHERE cardno like '215021%'
		AND  TO_CHAR(DEALTIME,'yyyy')=v_year ;
		v8 := v8 + nvl(temp,0);
		
		--SIMPASS卡刷卡额总量
		v_count := 1;
		while v_count <= 12
		loop
		if v_count < 10 then 
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_0'||v_count||'
		     where cardno like ''215021%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		else
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_count||'
		     where cardno like ''215021%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
	  end if;
		execute immediate v_sql into temp;
		v9 := v9 + nvl(temp,0);
		v_count := v_count+1;
		end loop;
		select sum(trademoney) into temp
		from TH_TRADE_RIGHT
		WHERE cardno like '215021%';
		v9 := v9 + nvl(temp,0);

		--记录财务每月上报汇总表
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , 
		    MONTHPAYMONEY , YEARPAYMONEY , TOTALPAYMONEY , STATTIME
		)values(
		    '215021'      , 'SIMPASS卡'  , v1            , v2           ,
		    v3            , v4           , v5            , 
		    v7            , v8           , v9            , P_MONTH
		);    
commit;
		-----------------UIMPASS卡-----------------	  
		v8 := 0;
		v9 := 0;
		v_count := 1;
		--UIMPASS卡发卡总量
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno like '215022%'
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--UIMPASS卡1-12月发卡量
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno like '215022%'
		and to_char(selltime,'yyyy') = v_year;
		
		--UIMPASS卡当月发卡量
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno like '215022%'
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--UIMPASS卡有消费卡
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno like '215022%';
		
		--UIMPASS卡无消费新售卡
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno like '215022%'and a.LASTCONSUMETIME is null;
		
		
		--UIMPASS卡当月刷卡量
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_month||'
		     where cardno like ''215022%''';
		execute immediate v_sql into v7;
		
		--UIMPASS卡1-12月刷卡量
		while v_count<=v_month
		loop
		if v_count < 10 then 
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_0'||v_count||'
		     where cardno like ''215022%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		else
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_count||'
		     where cardno like ''215022%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
	  end if;
		execute immediate v_sql into temp;
		v8 := v8 + nvl(temp,0);
		v_count := v_count+1;
		end loop;
		select sum(trademoney) into temp
		from TH_TRADE_RIGHT
		WHERE cardno like '215022%'
		AND  TO_CHAR(DEALTIME,'yyyy')=v_year ;	
		v8 := v8 + nvl(temp,0);
		
		--UIMPASS卡刷卡额总量
		v_count := 1;
		while v_count <= 12
		loop
		if v_count < 10 then 
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_0'||v_count||'
		     where cardno like ''215022%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		else
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_count||'
		     where cardno like ''215022%''
		     AND  TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
	  end if;
		execute immediate v_sql into temp;
		v9 := v9 + nvl(temp,0);
		v_count := v_count+1;
		end loop;
		select sum(trademoney) into temp
		from TH_TRADE_RIGHT
		WHERE cardno like '215022%';
		v9 := v9 + nvl(temp,0);

		--记录财务每月上报汇总表
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , 
		    MONTHPAYMONEY , YEARPAYMONEY , TOTALPAYMONEY , STATTIME
		)values(
		    '215022'      , 'UIMPASS卡'  , v1            , v2           ,
		    v3            , v4           , v5            , 
		    v7            , v8           , v9            , P_MONTH
		);
		commit;
		--------------------合计-------------------		  
		v8 := 0;
		v9 := 0;
		v_count := 1;
		--发卡总量
		select count(*) into v1
		from TF_F_CARDREC 
		where to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--1-12月发卡量
		select count(*) into v2
		from TF_F_CARDREC 
		where to_char(selltime,'yyyy') = v_year;
		
		--当月发卡量
		select count(*) into v3
		from TF_F_CARDREC 
		where to_char(selltime,'yyyyMM') = P_MONTH;
		
		--有消费卡
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year;
		
		--无消费新售卡
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' 
		and a.cardno =b.cardno 
		and to_char(b.selltime,'yyyy')=v_year
		and a.LASTCONSUMETIME is null;
		
		
		--当月刷卡量
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_month;
		execute immediate v_sql into v7;			
		
		--1-12月刷卡量
		while v_count <= v_month
		loop
		if v_count < 10 then 
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_0'||v_count||'
		     where TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		else
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_count||'
		     where TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
	  end if;
		execute immediate v_sql into temp;			
		v8 := v8 + nvl(temp,0);
		v_count := v_count+1;
		end loop;
		select sum(trademoney) into temp
		from TH_TRADE_RIGHT
		WHERE TO_CHAR(DEALTIME,'yyyy')=v_year ;
		v8 := v8 + nvl(temp,0);
		
		--刷卡额总量
		v_count := 1;
		while v_count <= 12
		loop
		if v_count < 10 then 
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_0'||v_count||'
		     where TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
		else
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_count||'
		     where TO_CHAR(DEALTIME,''yyyy'')='''||v_year||'''';
	  end if;
		execute immediate v_sql into temp;
		v9 := v9 + nvl(temp,0);
		v_count := v_count+1;
		end loop;
		select sum(trademoney) into temp
		from TH_TRADE_RIGHT;
		v9 := v9 + nvl(temp,0);

		--记录财务每月上报汇总表
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , 
		    MONTHPAYMONEY , YEARPAYMONEY , TOTALPAYMONEY , STATTIME
		)values(
		    '215033'      , '合计'       , v1            , v2           ,
		    v3            , v4           , v5            , 
		    v7            , v8           , v9            , P_MONTH
		);  
commit;
		------------------园林年卡-----------------
		
		--园林年卡发卡总量
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDPARKACC_SZ)
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--园林年卡1-12月发卡量
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDPARKACC_SZ)
		and to_char(selltime,'yyyy') = v_year;
		
		--园林年卡当月发卡量
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDPARKACC_SZ)
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--园林年卡有消费卡
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno in (select cardno from TF_F_CARDPARKACC_SZ);
		
		--园林年卡无消费新售卡
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno in (select cardno from TF_F_CARDPARKACC_SZ)and a.LASTCONSUMETIME is null;

		--记录财务每月上报汇总表
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , STATTIME
		)values(
		    '215035'      , '园林年卡'   , v1            , v2           ,
		    v3            , v4           , v5            , P_MONTH
		);
commit;
		-------------------休闲年卡-----------------
		--休闲年卡发卡总量
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDXXPARKACC_SZ)
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--休闲年卡1-12月发卡量
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDXXPARKACC_SZ)
		and to_char(selltime,'yyyy') = v_year;
		
		--休闲年卡当月发卡量
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDXXPARKACC_SZ)
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--休闲年卡有消费卡
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno in (select cardno from TF_F_CARDXXPARKACC_SZ);
		
		--休闲年卡无消费新售卡
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno in (select cardno from TF_F_CARDXXPARKACC_SZ)and a.LASTCONSUMETIME is null;

		--记录财务每月上报汇总表
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , STATTIME
		)values(
		    '215040'      , '休闲年卡'   , v1            , v2           ,
		    v3            , v4           , v5            , P_MONTH
		);    
		commit;
	  -------------------苏州通卡-----------------

		--除苏州通卡，各卡求和
		select 
		    sum(nvl(CONSUMENUM,0)) , sum(nvl(UNCONSUNMENUM,0)) , 
		    sum(nvl(MONTHPAYMONEY,0)) , sum(nvl(YEARPAYMONEY,0)) , sum(nvl(TOTALPAYMONEY,0))
		into
		    v4,v5,v7,v8,v9
		from  TF_MONTHCARDSTAT
		where STATTIME = P_MONTH
		and   CARDID in('215005','215013','215031','215016','215021','215022');
		
		--苏州通卡发卡总量
		select count(*) into v1
    from TF_F_CARDREC 
    where cardno not like '215005%' 
    and   cardno not like '215013%' 
    and   cardno not like '215016%'
    and   cardno not like '215021%'
    and   cardno not like '215022%'
    and   cardno not like '215031%'
    and   to_char(selltime,'yyyyMM') <= P_MONTH;
    
    --苏州通卡1-12月发卡量
		select count(*) into v2
    from TF_F_CARDREC 
    where cardno not like '215005%' 
    and   cardno not like '215013%' 
    and   cardno not like '215016%'
    and   cardno not like '215021%'
    and   cardno not like '215022%'
    and   cardno not like '215031%'
    and   to_char(selltime,'yyyy') = v_year;
    
    --苏州通卡当月发卡量
		select count(*) into v3
    from TF_F_CARDREC 
    where cardno not like '215005%' 
    and   cardno not like '215013%' 
    and   cardno not like '215016%'
    and   cardno not like '215021%'
    and   cardno not like '215022%'
    and   cardno not like '215031%'
    and   to_char(selltime,'yyyyMM') = P_MONTH;
		
		--记录财务每月上报汇总表
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , 
		    MONTHPAYMONEY , YEARPAYMONEY , TOTALPAYMONEY , STATTIME
		)SELECT
		    '215001'         , '苏州通卡'      , v1               , v2              ,
		    v3               , CONSUMENUM-v4   , UNCONSUNMENUM-v5 , 
		    MONTHPAYMONEY-v7 , YEARPAYMONEY-v8 , TOTALPAYMONEY-v9 , P_MONTH
		FROM TF_MONTHCARDSTAT
		WHERE STATTIME = P_MONTH
		AND   CARDID = '215033'
		;
commit;
		P_retCode := 0;
    P_retMsg  := 'OK';
    
EXCEPTION WHEN OTHERS THEN    
    p_retCode := SQLCODE;
    p_retMsg  := SQLERRM;
    ROLLBACK;RETURN;   
END;

/
show errors