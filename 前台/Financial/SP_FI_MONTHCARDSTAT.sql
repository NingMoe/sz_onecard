create or replace procedure SP_FI_MONTHCARDSTAT
(
    P_retCode            OUT INT ,
    P_retMsg             OUT VARCHAR2
)
AS
    v1             int := 0;
    v2             int := 0;
    v3             int := 0;
    v4             int := 0;
    v5             int := 0;
    v6             int := 0;
    v7             int := 0;
    v8             int := 0;
    v9             int := 0;
    temp           int := 0;
    V_DEPOSITMONEY int     ;
    v_count        number(2):=1;
    v_c            SYS_REFCURSOR;
    v_year         varchar2(4);
    v_month        varchar2(2);    
    v_sql          varchar2(2000);
    v_yearmonth    varchar2(6);
BEGIN
	v_yearmonth := TO_CHAR(TO_DATE(TO_CHAR(sysdate,'yyyyMM'),'yyyyMM')-1,'yyyyMM');

	v_year  := substr(v_yearmonth,1,4);
	v_month := substr(v_yearmonth,5,2);
	
	---------------------市民卡A卡-------------------
	--市民卡A卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC 
	where cardno like '215018%'
	and to_char(selltime,'yyyyMM') = v_yearmonth;

	--市民卡A卡有消费卡
	select count(*) into v2
	from TF_F_CARDEWALLETACC 
	where usetag ='1' 
	and (
		to_char(LASTCONSUMETIME,'yyyy') = v_year
		or
		(LASTCONSUMETIME is null and to_char(FIRSTCONSUMETIME,'yyyy') = v_year)
		)
	and cardno like '215018%';

	--市民卡A卡无消费新售卡
	select count(a.cardno) into v3
	from TF_F_CARDEWALLETACC a
	where a.usetag ='1' 
	and exists (select 1 from TF_F_CARDREC b where b.cardno =a.cardno and to_char(b.selltime,'yyyy') = v_year)
	and a.cardno like '215018%'
	and a.LASTCONSUMETIME is null;

	--市民卡A卡当月刷卡量
	v_sql := 'select sum(trademoney)
		 from tf_trade_right_'||v_month||'
		 where cardno like ''215018%''';
	execute immediate v_sql into v4;		

	--记录卡月统计汇总表
	insert into TF_PERMONTHCARDSTAT(
		STATTIME        , CARDID        , MONTHNUM      , MCONSUMENUM , 
		MUNCONSUNMENUM  , MONTHPAYMONEY
	)values(
		v_yearmonth     , '215010'      , v1            , v2          ,
		v3              , v4          
	);

	---------------------市民卡B卡-------------------
	
	--市民卡B卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC 
	where (cardno like '215007%' or cardno like '215008%' or cardno like '215009%') 
	and to_char(selltime,'yyyyMM') = v_yearmonth;

	--市民卡B卡有消费卡
	select count(*) into v2
	from TF_F_CARDEWALLETACC 
	where usetag ='1' 
	and (
		to_char(LASTCONSUMETIME,'yyyy') = v_year
		or
		(LASTCONSUMETIME is null and to_char(FIRSTCONSUMETIME,'yyyy') = v_year)
		)
	and (cardno like '215007%' or cardno like '215008%' or cardno like '215009%') ;

	--市民卡B卡无消费新售卡
	select count(a.cardno) into v3
	from TF_F_CARDEWALLETACC a
	where a.usetag ='1' 
	and exists (select 1 from TF_F_CARDREC b where a.cardno =b.cardno and to_char(b.selltime,'yyyy') = v_year)
	and (a.cardno like '215007%' or a.cardno like '215008%' or a.cardno like '215009%')
	and a.LASTCONSUMETIME is null;

	--市民卡B卡当月刷卡量
	v_sql := 'select sum(trademoney)
		 from tf_trade_right_'||v_month||'
		 where (cardno like ''215007%'' or cardno like ''215008%'' or cardno like ''215009%'')';
	execute immediate v_sql into v4;		

	--记录卡月统计汇总表
	insert into TF_PERMONTHCARDSTAT(
		STATTIME        , CARDID        , MONTHNUM      , MCONSUMENUM , 
		MUNCONSUNMENUM  , MONTHPAYMONEY
	)values(
		v_yearmonth     , '215003'      , v1            , v2          ,
		v3              , v4          
	);
		  
	---------------------礼金卡-------------------

	--利金卡当月发卡量
	select count(*) into temp
	from  tf_b_trade
	where cardno like '215005%'
	and   tradetypecode in ('50','51')
	and   CANCELTAG = '0'
	and   to_char(operatetime,'yyyyMM') = v_yearmonth;

	v1 := temp;

	--利金卡有消费卡
	select count(*) into v2
	from TF_F_CARDEWALLETACC
	where usetag ='1'
	and (
		to_char(LASTCONSUMETIME,'yyyy') = v_year
		or
		(LASTCONSUMETIME is null and to_char(FIRSTCONSUMETIME,'yyyy') = v_year)
		)
	and cardno like '215005%';

	--利金卡无消费新售卡
	select count(b.cardno) into v3
	from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
	where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy') = v_year
	and a.cardno like '215005%'and a.FIRSTCONSUMETIME is null;

	--利金卡当月刷卡量
	v_sql := 'select sum(trademoney)
		 from tf_trade_right_'||v_month||'
		 where cardno like ''215005%''';
	execute immediate v_sql into v4;

	--记录卡月统计汇总表
	insert into TF_PERMONTHCARDSTAT(
		STATTIME        , CARDID        , MONTHNUM      , MCONSUMENUM , 
		MUNCONSUNMENUM  , MONTHPAYMONEY
	)values(
		v_yearmonth         , '215005'      , v1            , v2          ,
		v3              , v4
	);	

	---------------------月票卡-------------------

	--月票卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC 
	where cardno in (select cardno from TF_F_CARDCOUNTACC)
	and to_char(selltime,'yyyyMM') = v_yearmonth;

	--月票卡有消费卡
	select count(*) into v2
	from TF_F_CARDEWALLETACC 
	where usetag ='1' 
	and (
		to_char(LASTCONSUMETIME,'yyyy') = v_year
		or
		(LASTCONSUMETIME is null and to_char(FIRSTCONSUMETIME,'yyyy') = v_year)
		)
	and cardno in (select cardno from TF_F_CARDCOUNTACC);

	--月票卡无消费新售卡
	select count(b.cardno) into v3
	from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
	where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
	and a.cardno in (select cardno from TF_F_CARDCOUNTACC)and a.FIRSTCONSUMETIME is null;

	--记录卡月统计汇总表
	insert into TF_PERMONTHCARDSTAT(
		STATTIME        , CARDID        , MONTHNUM      , MCONSUMENUM , 
		MUNCONSUNMENUM  
	)values(
		v_yearmonth         , '215006'      , v1            , v2          ,
		v3 
	);	

	-----------------吴江市民卡------------------

	--吴江市民卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC 
	where cardno like '215013%'
	and to_char(selltime,'yyyyMM') = v_yearmonth;

	--吴江市民卡有消费卡
	select count(*) into v2
	from TF_F_CARDEWALLETACC 
	where usetag ='1' 
	and (
		to_char(LASTCONSUMETIME,'yyyy') = v_year
		or
		(LASTCONSUMETIME is null and to_char(FIRSTCONSUMETIME,'yyyy') = v_year)
		)
	and cardno like '215013%';

	--吴江市民卡无消费新售卡
	select count(b.cardno) into v3
	from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
	where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
	and a.cardno like '215013%'and a.FIRSTCONSUMETIME is null;

	--吴江市民卡当月刷卡量
	v_sql := 'select sum(trademoney)
		 from tf_trade_right_'||v_month||'
		 where cardno like ''215013%''';
	execute immediate v_sql into v4;		

	--记录卡月统计汇总表
	insert into TF_PERMONTHCARDSTAT(
		STATTIME        , CARDID        , MONTHNUM      , MCONSUMENUM , 
		MUNCONSUNMENUM  , MONTHPAYMONEY
	)values(
		v_yearmonth     , '215013'      , v1            , v2          ,
		v3              , v4          
	);

	---------------张家港市民卡-----------------

	--张家港市民卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC 
	where cardno like '215016%'
	and to_char(selltime,'yyyyMM') = v_yearmonth;

	--张家港市民卡有消费卡
	select count(*) into v2
	from TF_F_CARDEWALLETACC 
	where usetag ='1' 
	and (
		to_char(LASTCONSUMETIME,'yyyy') = v_year
		or
		(LASTCONSUMETIME is null and to_char(FIRSTCONSUMETIME,'yyyy') = v_year)
		)
	and cardno like '215016%';

	--张家港市民卡无消费新售卡
	select count(b.cardno) into v3
	from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
	where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
	and a.cardno like '215016%'and a.FIRSTCONSUMETIME is null;

	--张家港市民卡当月刷卡量
	v_sql := 'select sum(trademoney)
		 from tf_trade_right_'||v_month||'
		 where cardno like ''215016%''';
	execute immediate v_sql into v4;

	--记录卡月统计汇总表
	insert into TF_PERMONTHCARDSTAT(
		STATTIME        , CARDID        , MONTHNUM      , MCONSUMENUM , 
		MUNCONSUNMENUM  , MONTHPAYMONEY
	)values(
		v_yearmonth         , '215016'      , v1            , v2          ,
		v3              , v4  
	);   

	-----------------SIMPASS卡-----------------

	--SIMPASS卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC 
	where cardno like '215021%'
	and to_char(selltime,'yyyyMM') = v_yearmonth;

	--SIMPASS卡有消费卡
	select count(*) into v2
	from TF_F_CARDEWALLETACC 
	where usetag ='1' 
	and (
		to_char(LASTCONSUMETIME,'yyyy') = v_year
		or
		(LASTCONSUMETIME is null and to_char(FIRSTCONSUMETIME,'yyyy') = v_year)
		)
	and cardno like '215021%';

	--SIMPASS卡无消费新售卡
	select count(b.cardno) into v3
	from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
	where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
	and a.cardno like '215021%'and a.FIRSTCONSUMETIME is null;

	--SIMPASS卡当月刷卡量
	v_sql := 'select sum(trademoney)
		 from tf_trade_right_'||v_month||'
		 where cardno like ''215021%''';
	execute immediate v_sql into v4;

	--记录卡月统计汇总表
	insert into TF_PERMONTHCARDSTAT(
		STATTIME        , CARDID        , MONTHNUM      , MCONSUMENUM , 
		MUNCONSUNMENUM  , MONTHPAYMONEY
	)values(
		v_yearmonth         , '215021'      , v1            , v2          ,
		v3              , v4
	);    

	-----------------UIMPASS卡-----------------	  

	--UIMPASS卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC 
	where cardno like '215022%'
	and to_char(selltime,'yyyyMM') = v_yearmonth;

	--UIMPASS卡有消费卡
	select count(*) into v2
	from TF_F_CARDEWALLETACC 
	where usetag ='1' 
	and (
		to_char(LASTCONSUMETIME,'yyyy') = v_year
		or
		(LASTCONSUMETIME is null and to_char(FIRSTCONSUMETIME,'yyyy') = v_year)
		)
	and cardno like '215022%';

	--UIMPASS卡无消费新售卡
	select count(b.cardno) into v3
	from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
	where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
	and a.cardno like '215022%'and a.FIRSTCONSUMETIME is null;

	--UIMPASS卡当月刷卡量
	v_sql := 'select sum(trademoney)
		 from tf_trade_right_'||v_month||'
		 where cardno like ''215022%''';
	execute immediate v_sql into v4;

	--记录卡月统计汇总表
	insert into TF_PERMONTHCARDSTAT(
		STATTIME        , CARDID        , MONTHNUM      , MCONSUMENUM , 
		MUNCONSUNMENUM  , MONTHPAYMONEY
	)values(
		v_yearmonth         , '215022'      , v1            , v2          ,
		v3              , v4
	); 

	-----------------吴江B卡------------------

	--吴江B卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC 
	where cardno like '215031%'
	and to_char(selltime,'yyyyMM') = v_yearmonth;

	--吴江B卡有消费卡
	select count(*) into v2
	from TF_F_CARDEWALLETACC 
	where usetag ='1' 
	and (
		to_char(LASTCONSUMETIME,'yyyy') = v_year
		or
		(LASTCONSUMETIME is null and to_char(FIRSTCONSUMETIME,'yyyy') = v_year)
		)
	and cardno like '215031%';

	--吴江B卡无消费新售卡
	select count(b.cardno) into v3
	from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
	where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
	and a.cardno like '215031%'and a.FIRSTCONSUMETIME is null;

	--吴江B卡当月刷卡量
	v_sql := 'select sum(trademoney)
		 from tf_trade_right_'||v_month||'
		 where cardno like ''215031%''';
	execute immediate v_sql into v4;		

	--记录卡月统计汇总表
	insert into TF_PERMONTHCARDSTAT(
		STATTIME        , CARDID        , MONTHNUM      , MCONSUMENUM , 
		MUNCONSUNMENUM  , MONTHPAYMONEY
	)values(
		v_yearmonth         , '215031'      , v1            , v2          ,
		v3              , v4          
	);

	--------------------合计-------------------		  

	--当月发卡量
	select count(*) into v1
	from TF_F_CARDREC 
	where to_char(selltime,'yyyyMM') = v_yearmonth;

	v1 := v1 + temp;

	--礼金卡当月发卡量
	select count(*) into temp
	from TF_F_CARDREC
	where cardno like '215005%'
	and to_char(selltime,'yyyyMM') = v_yearmonth;

	v1 := v1 - temp;
	--有消费卡
	select count(*) into v2
	from TF_F_CARDEWALLETACC 
	where usetag ='1' 
	and (
		to_char(LASTCONSUMETIME,'yyyy') = v_year
		or
		(LASTCONSUMETIME is null and to_char(FIRSTCONSUMETIME,'yyyy') = v_year)
	 );

	--无消费新售卡
	select count(b.cardno) into v3
	from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
	where a.usetag ='1' 
	and a.cardno =b.cardno 
	and to_char(b.selltime,'yyyy')=v_year
	and a.FIRSTCONSUMETIME is null;

	--当月刷卡量
	select sum(finfee) into v4
	from Tf_trade_outcomefin
	where to_char(ENDTIME,'yyyymm') = v_yearmonth
	and balunitno not in ('02A15001','02A16001')
	;
	select sum(finfee) into temp
	from Tf_taxi_outcomefin
	where to_char(ENDTIME,'yyyymm') = v_yearmonth
	;
	v4 := v4 + temp ;

	--记录卡月统计汇总表
	insert into TF_PERMONTHCARDSTAT(
		STATTIME        , CARDID        , MONTHNUM      , MCONSUMENUM , 
		MUNCONSUNMENUM  , MONTHPAYMONEY
	)values(
		v_yearmonth         , '215033'      , v1            , v2          ,
		v3              , v4     
	);  

	------------------园林年卡-----------------

	--园林年卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC 
	where cardno in (select cardno from TF_F_CARDPARKACC_SZ)
	and to_char(selltime,'yyyyMM') = v_yearmonth;

	--园林年卡有消费卡
	select count(*) into v2
	from TF_F_CARDEWALLETACC 
	where usetag ='1' 
	and (
	 to_char(LASTCONSUMETIME,'yyyy') = v_year
	 or
	 (LASTCONSUMETIME is null and to_char(FIRSTCONSUMETIME,'yyyy') = v_year)
	 )
	and cardno in (select cardno from TF_F_CARDPARKACC_SZ);

	--园林年卡无消费新售卡
	select count(b.cardno) into v3
	from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
	where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
	and a.cardno in (select cardno from TF_F_CARDPARKACC_SZ)and a.FIRSTCONSUMETIME is null;

	--记录卡月统计汇总表
	insert into TF_PERMONTHCARDSTAT(
		STATTIME        , CARDID        , MONTHNUM      , MCONSUMENUM , 
		MUNCONSUNMENUM  
	)values(
		v_yearmonth         , '215035'      , v1            , v2          ,
		v3
	);

	-------------------休闲年卡-----------------
	--休闲年卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC 
	where cardno in (select cardno from TF_F_CARDXXPARKACC_SZ)
	and to_char(selltime,'yyyyMM') = v_yearmonth;

	--休闲年卡有消费卡
	select count(*) into v2
	from TF_F_CARDEWALLETACC 
	where usetag ='1' 
	and (
	 to_char(LASTCONSUMETIME,'yyyy') = v_year
	 or
	 (LASTCONSUMETIME is null and to_char(FIRSTCONSUMETIME,'yyyy') = v_year)
	 )
	and cardno in (select cardno from TF_F_CARDXXPARKACC_SZ);

	--休闲年卡无消费新售卡
	select count(b.cardno) into v3
	from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
	where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
	and a.cardno in (select cardno from TF_F_CARDXXPARKACC_SZ)and a.FIRSTCONSUMETIME is null;

	--记录卡月统计汇总表
	insert into TF_PERMONTHCARDSTAT(
		STATTIME        , CARDID        , MONTHNUM      , MCONSUMENUM , 
		MUNCONSUNMENUM  
	)values(
		v_yearmonth         , '215040'      , v1            , v2          ,
		v3
	);

	for v_cur in (
		SELECT 
			  CARDID     , CARDTYPENAME  , TOTALNUM     , YEARNUM      , 
			  CONSUMENUM , UNCONSUNMENUM , YEARPAYMONEY ,TOTALPAYMONEY
		FROM  TF_MONTHCARDSTAT
		WHERE STATTIME = TO_CHAR(TO_DATE(v_yearmonth,'yyyyMM')-1,'yyyyMM')
	)
	LOOP
			--计算沉淀资金,以万元为单位
			if v_cur.CARDID = '215003' THEN 
			  --市民卡B卡沉淀资金总量
				select sum(cardaccmoney) into V_DEPOSITMONEY
				from TF_F_CARDEWALLETACC 
				where usetag ='1' 
				and (cardno like '215007%' or cardno like '215008%' or cardno like '215009%');
			elsif v_cur.CARDID = '215010' THEN 
			  --市民卡A卡沉淀资金总量
				select sum(cardaccmoney) into V_DEPOSITMONEY
				from TF_F_CARDEWALLETACC 
				where usetag ='1' 
				and cardno like '215018%' ;
			elsif v_cur.CARDID = '215005' THEN 
			  --利金卡沉淀资金总量
				select sum(cardaccmoney) into V_DEPOSITMONEY
				from TF_F_CARDEWALLETACC 
				where usetag ='1' 
				and cardno like '215005%' ;
			elsif v_cur.CARDID = '215006' THEN 
			  --月票卡沉淀资金总量
				select sum(cardaccmoney) into V_DEPOSITMONEY
				from TF_F_CARDEWALLETACC 
				where usetag ='1' 
				and cardno in (select cardno from TF_F_CARDCOUNTACC) ;
			elsif v_cur.CARDID = '215013' THEN 
			--吴江市民卡沉淀资金总量
			  select sum(cardaccmoney) into V_DEPOSITMONEY
			  from TF_F_CARDEWALLETACC 
			  where usetag ='1' 
			  and cardno like '215013%' ;
			elsif v_cur.CARDID = '215016' THEN 
			--张家港市民卡沉淀资金总量
			select sum(cardaccmoney) into V_DEPOSITMONEY
			  from TF_F_CARDEWALLETACC 
			  where usetag ='1' 
			  and cardno like '215016%' ;				
			elsif v_cur.CARDID = '215021' THEN 
			  --SIMPASS卡沉淀资金总量
			  select sum(cardaccmoney) into V_DEPOSITMONEY
			  from TF_F_CARDEWALLETACC 
			  where usetag ='1' 
			  and cardno like '215021%' ;
			elsif v_cur.CARDID = '215022' THEN 
			  --UIMPASS卡沉淀资金总量
			  select sum(cardaccmoney) into V_DEPOSITMONEY
			  from TF_F_CARDEWALLETACC 
			  where usetag ='1' 
			  and cardno like '215022%' ;
			elsif v_cur.CARDID = '215031' THEN 
			--吴江B卡沉淀资金总量
			  select sum(cardaccmoney) into V_DEPOSITMONEY
			  from TF_F_CARDEWALLETACC 
			  where usetag ='1' 
			  and cardno like '215031%' ;				
			elsif v_cur.CARDID = '215033' THEN 
			  --沉淀资金总量
			  select sum(cardaccmoney) into V_DEPOSITMONEY
			from TF_F_CARDEWALLETACC 
			  where usetag ='1' ;
	else
			  V_DEPOSITMONEY := null;
			end if;		  
			
	--记录财务每月上报汇总表
	IF v_month = '01' THEN --如果是1月，统计1-12月的数据时，不加上上月的统计结果
				INSERT INTO TF_MONTHCARDSTAT(
					STATTIME      , 
					CARDID        , 
					CARDTYPENAME  ,
					TOTALNUM      ,
					YEARNUM       , 
					MONTHNUM      , 
					CONSUMENUM    , 
					UNCONSUNMENUM ,
					DEPOSITMONEY  , 
					MONTHPAYMONEY , 
					YEARPAYMONEY  , 
					TOTALPAYMONEY
			   )SELECT 
					v_yearmonth                   , 
					A.CARDID                      , 
					v_cur.CARDTYPENAME            , 
					v_cur.TOTALNUM + A.MONTHNUM   ,
					A.MONTHNUM                    , 
					A.MONTHNUM                    , 
					A.MCONSUMENUM                 , 
					A.MUNCONSUNMENUM              ,
					V_DEPOSITMONEY                , 
					A.MONTHPAYMONEY               , 
					A.MONTHPAYMONEY               ,
					v_cur.TOTALPAYMONEY + A.MONTHPAYMONEY 
				FROM  TF_PERMONTHCARDSTAT A
				WHERE A.STATTIME = v_yearmonth
				AND   A.CARDID   = v_cur.CARDID;
	ELSE        
				INSERT INTO TF_MONTHCARDSTAT(
					STATTIME      , 
					CARDID        , 
					CARDTYPENAME  ,
					TOTALNUM      ,
					YEARNUM       , 
					MONTHNUM      , 
					CONSUMENUM    , 
					UNCONSUNMENUM ,
					DEPOSITMONEY  , 
					MONTHPAYMONEY , 
					YEARPAYMONEY  , 
					TOTALPAYMONEY
			   )SELECT 
					v_yearmonth                   , 
					A.CARDID                      , 
					v_cur.CARDTYPENAME            , 
					v_cur.TOTALNUM + A.MONTHNUM   ,
					v_cur.YEARNUM + A.MONTHNUM    , 
					A.MONTHNUM                    , 
					A.MCONSUMENUM                 , 
					A.MUNCONSUNMENUM              ,
					V_DEPOSITMONEY                         , 
					A.MONTHPAYMONEY                        , 
					v_cur.YEARPAYMONEY + A.MONTHPAYMONEY   ,
					v_cur.TOTALPAYMONEY + A.MONTHPAYMONEY 
				FROM  TF_PERMONTHCARDSTAT A
				WHERE A.STATTIME = v_yearmonth
				AND   A.CARDID   = v_cur.CARDID;		   
		END IF; 
	END LOOP;

	-------------------苏州通卡-----------------

	--除苏州通卡，各卡求和
	--215003市民卡B卡，215005苏州通卡，215010市民卡A卡，215013吴江市民卡，
	--215031吴江B卡，215016张家港市民卡，215021SIMPASS卡，215022UIMPASS卡
	select 
		sum(nvl(TOTALNUM,0)) , sum(nvl(YEARNUM,0)) , sum(nvl(MONTHNUM,0)) ,
		sum(nvl(CONSUMENUM,0)) , sum(nvl(UNCONSUNMENUM,0)) , sum(nvl(DEPOSITMONEY,0)) , 
		sum(nvl(MONTHPAYMONEY,0)) , sum(nvl(YEARPAYMONEY,0)) , sum(nvl(TOTALPAYMONEY,0))
	into
		v1,v2,v3,v4,v5,v6,v7,v8,v9
	from  TF_MONTHCARDSTAT
	where STATTIME = v_yearmonth
	and   CARDID in('215003','215005','215006','215010','215013','215031','215016','215021','215022');

	--记录财务每月上报汇总表
	insert into TF_MONTHCARDSTAT(
		CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , DEPOSITMONEY , 
		MONTHPAYMONEY , YEARPAYMONEY , TOTALPAYMONEY , STATTIME
	)SELECT
		'215001'         , '苏州通卡'      , TOTALNUM - v1    , YEARNUM - v2     ,
		MONTHNUM - v3    , CONSUMENUM-v4   , UNCONSUNMENUM-v5 , DEPOSITMONEY-v6  ,
		MONTHPAYMONEY-v7 , YEARPAYMONEY-v8 , TOTALPAYMONEY-v9 , v_yearmonth
	FROM TF_MONTHCARDSTAT
	WHERE STATTIME = v_yearmonth
	AND   CARDID = '215033' --合计
	;
    commit;
    p_retCode:=0;
    p_retMsg:='OK';
EXCEPTION WHEN OTHERS THEN
    p_retCode := SQLCODE;
    p_retMsg  := SQLERRM;
    ROLLBACK;RETURN;
END;		

/
show errors