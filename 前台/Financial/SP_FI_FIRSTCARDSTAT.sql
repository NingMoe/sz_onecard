/******************************************************/
-- Author  : shilei
-- Created : 2012-3-26 
-- Purpose : ��Ӧ��������_20120202-001��ֻ��һ�γ�ʼ����
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
		---------------------���-------------------
		
		--���𿨷�������
		select count(*) into v1
		from  tf_b_trade 
		where cardno like '215005%' 
		and   tradetypecode in ('50','51')
		and   CANCELTAG = '0'
		and   to_char(operatetime,'yyyyMM') <= P_MONTH;
		
		--����1-12�·�����
		select count(*) into v2
		from  tf_b_trade 
		where cardno like '215005%' 
		and   tradetypecode in ('50','51')
		and   to_char(operatetime,'yyyy') = v_year
		and   CANCELTAG = '0';		
		
		
		--���𿨵��·�����
		select count(*) into v3
		from  tf_b_trade 
		where cardno like '215005%' 
		and   tradetypecode in ('50','51')
		and   to_char(operatetime,'yyyyMM') = P_MONTH
		and   CANCELTAG = '0';		
		
		
		--���������ѿ�
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy') = v_year
		and cardno like '215005%';
		
		--�������������ۿ�
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy') = v_year
		and a.cardno like '215005%'and a.LASTCONSUMETIME is null;
		
		
		--���𿨵���ˢ����
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_month||'
		     where cardno like ''215005%''';
		execute immediate v_sql into v7;
		--����1-12��ˢ����
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
		
		--����ˢ��������
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

		--��¼����ÿ���ϱ����ܱ�
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , 
		    MONTHPAYMONEY , YEARPAYMONEY , TOTALPAYMONEY , STATTIME
		)values(
		    '215005'      , '����'     , v1            , v2           ,
		    v3            , v4           , v5            , 
		    v7            , v8           , v9            , P_MONTH
		);
commit;
		---------------------��Ʊ��-------------------
		v8 := 0;
		v9 := 0;
		v_count := 1;
		--��Ʊ����������
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDCOUNTACC)
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--��Ʊ��1-12�·�����
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDCOUNTACC)
		and to_char(selltime,'yyyy') = v_year;
		
		--��Ʊ�����·�����
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDCOUNTACC)
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--��Ʊ�������ѿ�
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno in (select cardno from TF_F_CARDCOUNTACC);
		
		--��Ʊ�����������ۿ�
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno in (select cardno from TF_F_CARDCOUNTACC)and a.LASTCONSUMETIME is null;
		

		--��¼����ÿ���ϱ����ܱ�
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , 
		    STATTIME
		)values(
		    '215006'      , '��Ʊ��'     , v1            , v2           ,
		    v3            , v4           , v5            , 
		    P_MONTH
		);
commit;
		-----------------�⽭����------------------
		v8 := 0;
		v9 := 0;
		v_count := 1;
		--�⽭���񿨷�������
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno like '215013%'
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--�⽭����1-12�·�����
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno like '215013%'
		and to_char(selltime,'yyyy') = v_year;
		
		--�⽭���񿨵��·�����
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno like '215013%'
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--�⽭���������ѿ�
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno like '215013%';
		
		--�⽭�������������ۿ�
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno like '215013%'and a.LASTCONSUMETIME is null;
		
		
		--�⽭���񿨵���ˢ����
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_month||'
		     where cardno like ''215013%''';
		execute immediate v_sql into v7;		
		
		--�⽭����1-12��ˢ����
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
		
		--�⽭����ˢ��������
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

		--��¼����ÿ���ϱ����ܱ�
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME  , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM    , UNCONSUNMENUM , 
		    MONTHPAYMONEY , YEARPAYMONEY  , TOTALPAYMONEY , STATTIME
		)values(
		    '215013'      , '�⽭����'  , v1            , v2           ,
		    v3            , v4            , v5            , 
		    v7            , v8            , v9            , P_MONTH
		);
		commit;
		-----------------�⽭B��------------------
		v8 := 0;
		v9 := 0;
		v_count := 1;
		--�⽭B����������
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno like '215031%'
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--�⽭B��1-12�·�����
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno like '215031%'
		and to_char(selltime,'yyyy') = v_year;
		
		--�⽭B�����·�����
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno like '215031%'
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--�⽭B�������ѿ�
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno like '215031%';
		
		--�⽭B�����������ۿ�
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno like '215031%'and a.LASTCONSUMETIME is null;
		
		
		--�⽭B������ˢ����
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_month||'
		     where cardno like ''215031%''';
		execute immediate v_sql into v7;		
		
		--�⽭B��1-12��ˢ����
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
		
		--�⽭B��ˢ��������
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

		--��¼����ÿ���ϱ����ܱ�
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME  , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM    , UNCONSUNMENUM ,  
		    MONTHPAYMONEY , YEARPAYMONEY  , TOTALPAYMONEY , STATTIME
		)values(
		    '215031'      , '�⽭B��'     , v1            , v2           ,
		    v3            , v4            , v5            , 
		    v7            , v8            , v9            , P_MONTH
		);
  commit;
		---------------�żҸ�����-----------------
	  v8 := 0;
		v9 := 0;
		v_count := 1;
		--�żҸ����񿨷�������
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno like '215016%'
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--�żҸ�����1-12�·�����
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno like '215016%'
		and to_char(selltime,'yyyy') = v_year;
		
		--�żҸ����񿨵��·�����
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno like '215016%'
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--�żҸ����������ѿ�
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno like '215016%';
		
		--�żҸ��������������ۿ�
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno like '215016%'and a.LASTCONSUMETIME is null;
		

		--�żҸ����񿨵���ˢ����
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_month||'
		     where cardno like ''215016%''';
		execute immediate v_sql into v7;
		
		--�żҸ�����1-12��ˢ����
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
		
		--�żҸ�����ˢ��������
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

		--��¼����ÿ���ϱ����ܱ�
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME   , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM     , UNCONSUNMENUM , 
		    MONTHPAYMONEY , YEARPAYMONEY   , TOTALPAYMONEY , STATTIME
		)values(
		    '215016'      , '�żҸ�����' , v1            , v2           ,
		    v3            , v4             , v5            , 
		    v7            , v8             , v9            , P_MONTH
		);    
  commit;
		-----------------SIMPASS��-----------------
	  v8 := 0;
		v9 := 0;
		v_count := 1;
		--SIMPASS����������
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno like '215021%'
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--SIMPASS��1-12�·�����
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno like '215021%'
		and to_char(selltime,'yyyy') = v_year;
		
		--SIMPASS�����·�����
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno like '215021%'
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--SIMPASS�������ѿ�
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno like '215021%';
		
		--SIMPASS�����������ۿ�
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno like '215021%'and a.LASTCONSUMETIME is null;
		
		--SIMPASS������ˢ����
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_month||'
		     where cardno like ''215021%''';
		execute immediate v_sql into v7;
		
		--SIMPASS��1-12��ˢ����
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
		
		--SIMPASS��ˢ��������
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

		--��¼����ÿ���ϱ����ܱ�
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , 
		    MONTHPAYMONEY , YEARPAYMONEY , TOTALPAYMONEY , STATTIME
		)values(
		    '215021'      , 'SIMPASS��'  , v1            , v2           ,
		    v3            , v4           , v5            , 
		    v7            , v8           , v9            , P_MONTH
		);    
commit;
		-----------------UIMPASS��-----------------	  
		v8 := 0;
		v9 := 0;
		v_count := 1;
		--UIMPASS����������
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno like '215022%'
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--UIMPASS��1-12�·�����
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno like '215022%'
		and to_char(selltime,'yyyy') = v_year;
		
		--UIMPASS�����·�����
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno like '215022%'
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--UIMPASS�������ѿ�
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno like '215022%';
		
		--UIMPASS�����������ۿ�
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno like '215022%'and a.LASTCONSUMETIME is null;
		
		
		--UIMPASS������ˢ����
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_month||'
		     where cardno like ''215022%''';
		execute immediate v_sql into v7;
		
		--UIMPASS��1-12��ˢ����
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
		
		--UIMPASS��ˢ��������
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

		--��¼����ÿ���ϱ����ܱ�
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , 
		    MONTHPAYMONEY , YEARPAYMONEY , TOTALPAYMONEY , STATTIME
		)values(
		    '215022'      , 'UIMPASS��'  , v1            , v2           ,
		    v3            , v4           , v5            , 
		    v7            , v8           , v9            , P_MONTH
		);
		commit;
		--------------------�ϼ�-------------------		  
		v8 := 0;
		v9 := 0;
		v_count := 1;
		--��������
		select count(*) into v1
		from TF_F_CARDREC 
		where to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--1-12�·�����
		select count(*) into v2
		from TF_F_CARDREC 
		where to_char(selltime,'yyyy') = v_year;
		
		--���·�����
		select count(*) into v3
		from TF_F_CARDREC 
		where to_char(selltime,'yyyyMM') = P_MONTH;
		
		--�����ѿ�
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year;
		
		--���������ۿ�
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' 
		and a.cardno =b.cardno 
		and to_char(b.selltime,'yyyy')=v_year
		and a.LASTCONSUMETIME is null;
		
		
		--����ˢ����
		v_sql := 'select sum(trademoney)
		     from tf_trade_right_'||v_month;
		execute immediate v_sql into v7;			
		
		--1-12��ˢ����
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
		
		--ˢ��������
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

		--��¼����ÿ���ϱ����ܱ�
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , 
		    MONTHPAYMONEY , YEARPAYMONEY , TOTALPAYMONEY , STATTIME
		)values(
		    '215033'      , '�ϼ�'       , v1            , v2           ,
		    v3            , v4           , v5            , 
		    v7            , v8           , v9            , P_MONTH
		);  
commit;
		------------------԰���꿨-----------------
		
		--԰���꿨��������
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDPARKACC_SZ)
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--԰���꿨1-12�·�����
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDPARKACC_SZ)
		and to_char(selltime,'yyyy') = v_year;
		
		--԰���꿨���·�����
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDPARKACC_SZ)
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--԰���꿨�����ѿ�
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno in (select cardno from TF_F_CARDPARKACC_SZ);
		
		--԰���꿨���������ۿ�
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno in (select cardno from TF_F_CARDPARKACC_SZ)and a.LASTCONSUMETIME is null;

		--��¼����ÿ���ϱ����ܱ�
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , STATTIME
		)values(
		    '215035'      , '԰���꿨'   , v1            , v2           ,
		    v3            , v4           , v5            , P_MONTH
		);
commit;
		-------------------�����꿨-----------------
		--�����꿨��������
		select count(*) into v1
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDXXPARKACC_SZ)
		and   to_char(selltime,'yyyyMM') <= P_MONTH;
		
		--�����꿨1-12�·�����
		select count(*) into v2
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDXXPARKACC_SZ)
		and to_char(selltime,'yyyy') = v_year;
		
		--�����꿨���·�����
		select count(*) into v3
		from TF_F_CARDREC 
		where cardno in (select cardno from TF_F_CARDXXPARKACC_SZ)
		and to_char(selltime,'yyyyMM') = P_MONTH;
		
		--�����꿨�����ѿ�
		select count(*) into v4
		from TF_F_CARDEWALLETACC 
		where usetag ='1' 
		and to_char(LASTCONSUMETIME,'yyyy')=v_year
		and cardno in (select cardno from TF_F_CARDXXPARKACC_SZ);
		
		--�����꿨���������ۿ�
		select count(b.cardno) into v5
		from TF_F_CARDEWALLETACC a,TF_F_CARDREC b
		where a.usetag ='1' and a.cardno =b.cardno and to_char(b.selltime,'yyyy')=v_year
		and a.cardno in (select cardno from TF_F_CARDXXPARKACC_SZ)and a.LASTCONSUMETIME is null;

		--��¼����ÿ���ϱ����ܱ�
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , STATTIME
		)values(
		    '215040'      , '�����꿨'   , v1            , v2           ,
		    v3            , v4           , v5            , P_MONTH
		);    
		commit;
	  -------------------����ͨ��-----------------

		--������ͨ�����������
		select 
		    sum(nvl(CONSUMENUM,0)) , sum(nvl(UNCONSUNMENUM,0)) , 
		    sum(nvl(MONTHPAYMONEY,0)) , sum(nvl(YEARPAYMONEY,0)) , sum(nvl(TOTALPAYMONEY,0))
		into
		    v4,v5,v7,v8,v9
		from  TF_MONTHCARDSTAT
		where STATTIME = P_MONTH
		and   CARDID in('215005','215013','215031','215016','215021','215022');
		
		--����ͨ����������
		select count(*) into v1
    from TF_F_CARDREC 
    where cardno not like '215005%' 
    and   cardno not like '215013%' 
    and   cardno not like '215016%'
    and   cardno not like '215021%'
    and   cardno not like '215022%'
    and   cardno not like '215031%'
    and   to_char(selltime,'yyyyMM') <= P_MONTH;
    
    --����ͨ��1-12�·�����
		select count(*) into v2
    from TF_F_CARDREC 
    where cardno not like '215005%' 
    and   cardno not like '215013%' 
    and   cardno not like '215016%'
    and   cardno not like '215021%'
    and   cardno not like '215022%'
    and   cardno not like '215031%'
    and   to_char(selltime,'yyyy') = v_year;
    
    --����ͨ�����·�����
		select count(*) into v3
    from TF_F_CARDREC 
    where cardno not like '215005%' 
    and   cardno not like '215013%' 
    and   cardno not like '215016%'
    and   cardno not like '215021%'
    and   cardno not like '215022%'
    and   cardno not like '215031%'
    and   to_char(selltime,'yyyyMM') = P_MONTH;
		
		--��¼����ÿ���ϱ����ܱ�
		insert into TF_MONTHCARDSTAT(
		    CARDID        , CARDTYPENAME , TOTALNUM      , YEARNUM      , 
		    MONTHNUM      , CONSUMENUM   , UNCONSUNMENUM , 
		    MONTHPAYMONEY , YEARPAYMONEY , TOTALPAYMONEY , STATTIME
		)SELECT
		    '215001'         , '����ͨ��'      , v1               , v2              ,
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