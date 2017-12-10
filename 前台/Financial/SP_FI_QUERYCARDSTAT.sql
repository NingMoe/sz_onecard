create or replace procedure SP_FI_QUERYCARDSTAT
(
    p_funcCode        varchar2 ,
    P_MONTH           CHAR     ,
    p_cursor      out SYS_REFCURSOR
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
    V_DEPOSITMONEY int     ;
    temp           int := 0;
    v_count        number(2):=1;
    v_c            SYS_REFCURSOR;
    v_year         varchar2(4);
    v_month        varchar2(2);
    v_sql 		     varchar2(2000);
BEGIN
	v_year  := substr(P_MONTH,1,4);
	v_month := substr(P_MONTH,5,2);

	if p_funcCode = 'QUERYHISTORYSTAT' then
	--查询历史统计信息
	open p_cursor for
	SELECT
		  nvl(CARDTYPENAME,0) CARDTYPENAME  , nvl(TOTALNUM,0)      TOTALNUM         ,
		  nvl(YEARNUM,0)      YEARNUM       , nvl(MONTHNUM,0)      MONTHNUM         ,
		  nvl(CONSUMENUM,0)   CONSUMENUM    , nvl(UNCONSUNMENUM,0) UNCONSUNMENUM    ,
		  POSNUM              POSNUM        ,
		  nvl(DEPOSITMONEY,0)/1000000.0   DEPOSITMONEY   ,
		  nvl(MONTHPAYMONEY,0)/1000000.0  MONTHPAYMONEY  ,
		  nvl(YEARPAYMONEY,0)/1000000.0   YEARPAYMONEY   ,
		  nvl(TOTALPAYMONEY,0)/1000000.0  TOTALPAYMONEY
	FROM  TF_MONTHCARDSTAT
	WHERE STATTIME= P_MONTH
	ORDER BY CARDID
	;
	elsif  p_funcCode = 'QUERYNOWSTAT' then
	DELETE FROM TMP_FI_STAT;
	---------------------市民卡A卡-------------------
	--市民卡A卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC 
	where cardno like '215018%'
	and to_char(selltime,'yyyyMM') = P_MONTH;

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
	
	--记录临时表
	insert into TMP_FI_STAT(
		F0        , F1       , F2           , F3        ,
		F4
	)values(
		'215010'  , v1        , v2          , v3        ,
		v4
	);

	---------------------市民卡B卡-------------------
	
	--市民卡B卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC 
	where (cardno like '215007%' or cardno like '215008%' or cardno like '215009%') 
	and to_char(selltime,'yyyyMM') = P_MONTH;

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

	--记录临时表
	insert into TMP_FI_STAT(
		F0        , F1       , F2           , F3        ,
		F4
	)values(
		'215003'  , v1        , v2          , v3        ,
		v4
	);
	
	---------------------利金卡-------------------

	--利金卡当月发卡量
	select count(*) into temp
	from  tf_b_trade
	where cardno like '215005%'
	and   tradetypecode in ('50','51')
	and   CANCELTAG = '0'
	and   to_char(operatetime,'yyyyMM') = P_MONTH;

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

	--记录临时表
	insert into TMP_FI_STAT(
		F0        , F1       , F2           , F3        ,
		F4
	)values(
		'215005'  , v1        , v2          , v3        ,
		v4
	);

	---------------------月票卡-------------------

	--月票卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC
	where cardno in (select cardno from TF_F_CARDCOUNTACC)
	and to_char(selltime,'yyyyMM') = P_MONTH;

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

	--记录临时表
	insert into TMP_FI_STAT(
		F0        , F1       , F2           , F3
	)values(
		'215006'  , v1        , v2          , v3
	);


	-----------------吴江市民卡------------------

	--吴江市民卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC
	where cardno like '215013%'
	and to_char(selltime,'yyyyMM') = P_MONTH;

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

	--记录临时表
	insert into TMP_FI_STAT(
		F0        , F1       , F2           , F3        ,
		F4
	)values(
		'215013'  , v1        , v2          , v3        ,
		v4
	);

	---------------张家港市民卡-----------------

	--张家港市民卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC
	where cardno like '215016%'
	and to_char(selltime,'yyyyMM') = P_MONTH;

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

	--记录临时表
	insert into TMP_FI_STAT(
		F0        , F1       , F2           , F3        ,
		F4
	)values(
		'215016'  , v1        , v2          , v3        ,
		v4
	);

	-----------------SIMPASS卡-----------------

	--SIMPASS卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC
	where cardno like '215021%'
	and to_char(selltime,'yyyyMM') = P_MONTH;

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

	--记录临时表
	insert into TMP_FI_STAT(
		F0        , F1       , F2           , F3        ,
		F4
	)values(
		'215021'  , v1        , v2          , v3        ,
		v4
	);

	----------------UIMPASS卡-----------------

	--UIMPASS卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC
	where cardno like '215022%'
	and to_char(selltime,'yyyyMM') = P_MONTH;

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

	--记录临时表
	insert into TMP_FI_STAT(
		F0        , F1       , F2           , F3        ,
		F4
	)values(
		'215022'  , v1        , v2          , v3        ,
		v4
	);
	-----------------吴江B卡------------------

	--吴江B卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC
	where cardno like '215031%'
	and to_char(selltime,'yyyyMM') = P_MONTH;

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

	--记录临时表
	insert into TMP_FI_STAT(
		F0        , F1       , F2           , F3        ,
		F4
	)values(
		'215031'  , v1        , v2          , v3        ,
		v4
	);

	--------------------合计-------------------

	--当月发卡量
	select count(*) into v1
	from TF_F_CARDREC
	where to_char(selltime,'yyyyMM') = P_MONTH;

	v1 := v1 + temp;

	--礼金卡当月发卡量
	select count(*) into temp
	from TF_F_CARDREC
	where cardno like '215005%'
	and to_char(selltime,'yyyyMM') = P_MONTH;

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
	where to_char(ENDTIME,'yyyymm') = P_MONTH
	and balunitno not in ('02A15001','02A16001')
	;
	select sum(finfee) into temp
	from Tf_taxi_outcomefin
	where to_char(ENDTIME,'yyyymm') = P_MONTH
	;
	v4 := v4 + temp ;

	--记录临时表
	insert into TMP_FI_STAT(
		F0        , F1       , F2           , F3        ,
		F4
	)values(
		'215033'  , v1        , v2          , v3        ,
		v4
	);

	------------------园林年卡-----------------

	--园林年卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC
	where cardno in (select cardno from TF_F_CARDPARKACC_SZ)
	and to_char(selltime,'yyyyMM') = P_MONTH;

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

	--记录临时表
	insert into TMP_FI_STAT(
		F0        , F1        , F2          , F3
	)values(
		'215035'  , v1        , v2          , v3
	);

	-------------------休闲年卡-----------------
	--休闲年卡当月发卡量
	select count(*) into v1
	from TF_F_CARDREC
	where cardno in (select cardno from TF_F_CARDXXPARKACC_SZ)
	and to_char(selltime,'yyyyMM') = P_MONTH;

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

	--记录临时表
	insert into TMP_FI_STAT(
		F0        , F1       , F2           , F3
	)values(
		'215040'  , v1        , v2          , v3
	);

	for v_cur in (
		SELECT
			  CARDID     , CARDTYPENAME  , TOTALNUM     , YEARNUM      ,
			  CONSUMENUM , UNCONSUNMENUM , YEARPAYMONEY ,TOTALPAYMONEY
		FROM  TF_MONTHCARDSTAT
		WHERE STATTIME = TO_CHAR(TO_DATE(P_MONTH,'yyyyMM')-1,'yyyyMM')
	)
	LOOP
		--计算沉淀资金
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

	--记录当月查询结果入临时表
	IF v_month = '01' THEN --如果是1月，统计1-12月的数据是，不加上上月的统计结果
		INSERT INTO TMP_FI_STAT(
			F0      ,
			F1      ,
			F2      ,
			F3      ,
			F4      ,
			F5      ,
			F6      ,
			F8      ,
			F9      ,
			F10     ,
			F11     ,
			F12
	   )SELECT
			P_MONTH                     ,
			v_cur.CARDTYPENAME          ,
			v_cur.TOTALNUM + A.F1       ,
			A.F1                        ,
			A.F1                        ,
			A.F2                        ,
			A.F3                        ,
			V_DEPOSITMONEY              ,
			A.F4                        ,
			A.F4                        ,
			v_cur.TOTALPAYMONEY + A.F4  ,
			v_cur.CARDID
		FROM  TMP_FI_STAT A
		WHERE A.F0 = v_cur.CARDID;
	ELSE
		INSERT INTO TMP_FI_STAT(
			F0      ,
			F1      ,
			F2      ,
			F3      ,
			F4      ,
			F5      ,
			F6      ,
			F8      ,
			F9      ,
			F10     ,
			F11     ,
			F12
	   )SELECT
			P_MONTH                     ,
			v_cur.CARDTYPENAME          ,
			v_cur.TOTALNUM + A.F1       ,
			v_cur.YEARNUM + A.F1        ,
			A.F1                        ,
			A.F2                        ,
			A.F3                        ,
			V_DEPOSITMONEY              ,
			A.F4                        ,
			v_cur.YEARPAYMONEY + A.F4   ,
			v_cur.TOTALPAYMONEY + A.F4  ,
			v_cur.CARDID
		FROM  TMP_FI_STAT A
		WHERE A.F0 = v_cur.CARDID;
		END IF;
	END LOOP;

	-------------------苏州通卡-----------------

	--除苏州通卡，各卡求和
	--215003市民卡B卡，215005苏州通卡，215010市民卡A卡，215013吴江市民卡，
	--215031吴江B卡，215016张家港市民卡，215021SIMPASS卡，215022UIMPASS卡
	select
		sum(nvl(F2,0))  , sum(nvl(F3,0))   , sum(nvl(F4,0))  ,
		sum(nvl(F5,0))  , sum(nvl(F6,0))   , sum(nvl(F8,0))  ,
		sum(nvl(F9,0))  , sum(nvl(F10,0))  , sum(nvl(F11,0))
	into
		v1,v2,v3,v4,v5,v6,v7,v8,v9
	from  TMP_FI_STAT
	where F0 = P_MONTH
	and   F12 in('215003','215005','215006','215010','215013','215031','215016','215021','215022');


	--记录财务每月上报汇总表
	insert into TMP_FI_STAT(
		F12     , F1     , F2      , F3    ,
		F4      , F5     , F6      , F8    ,
		F9      , F10    , F11     , F0
	)SELECT
		'215001' , '苏州通卡' , F2-v1  , F3-v1    ,
		F4-v1    , F5-v4      , F6-v5  , F8-v6    ,
		F9-v7    , F10-v8     , F11-v9 , P_MONTH
	FROM TMP_FI_STAT
	WHERE F0 = P_MONTH
	AND   F12 = '215033'
	;

	--查询当前月汇总结果
	open p_cursor for
	SELECT
		nvl(F1,0) CARDTYPENAME  , nvl(F2,0)  TOTALNUM      , nvl(F3,0)  YEARNUM   , nvl(F4,0) MONTHNUM      ,
		nvl(F5,0) CONSUMENUM    , nvl(F6,0)  UNCONSUNMENUM , F7         POSNUM    , nvl(F8,0)/1000000.0 DEPOSITMONEY  ,
		nvl(F9,0)/1000000.0 MONTHPAYMONEY , nvl(F10,0)/1000000.0 YEARPAYMONEY  , nvl(F11,0)/1000000.0 TOTALPAYMONEY
	FROM TMP_FI_STAT
	WHERE F0 = P_MONTH
	ORDER BY F12;
	end if;
END;
/
show errors