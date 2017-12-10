/*
create time :2014/1/8 22:51
creator :wdx
content:备付金报表统计
*/

create or replace procedure SP_MDCH_beifuji_report_day
(
	p_tradedate	char,
	p_tablename	varchar2,
    p_retCode    out int, -- Return Code
    p_retMsg     out varchar2  -- Return Message

)
as
    v_now            date := sysdate;
	v_monthstart	 char(8);
BEGIN
	

	delete from TF_F_beifujinreport where tradedate=p_tradedate and (p_tablename is null or p_tablename = tablename);
	/*
IF p_tablename is null or p_tablename = '1-1' THEN
	
	insert into TF_F_beifujinreport(tablename,tradedate,description,f1,f2)
	--业务系统中贷记客户资金账户金额,手续费支出
	select '1-1',p_tradedate,'支付机构XX银行客户备付金入金业务明细表', nvl(sum(money),0),0 from (
		select nvl(sum(MONEY)/100.0,0) money
		from TF_FUNDSANALYSIS
		where STATTIME =p_tradedate
		and NAME in ('营业厅充值','代理充值','在线充付商户代理充值','充值卡现金售卡','充值卡直销售卡','企服卡充值对账','礼金卡售卡','旅游卡售卡')
		union all
		select nvl(sum(MONEY)/100.0,0) money
		from TF_FUNDSANALYSIS 
		where STATTIME =p_tradedate
		and NAME in ('退充值转账')
	) temp;

	--入金的手续费 按月统计 如果是月底，则统计
	if(substr(to_char(to_date(p_tradedate,'yyyyMMdd')+1,'yyyyMMdd'),1,6)<>substr(p_tradedate,1,6)) then 
		v_monthstart:=substr(p_tradedate,1,6) || '01';--某月的第一天
		update TF_F_beifujinreport set f2=(
		SELECT -SUM(money) FROM (
		--电信 每笔7/1000
		Select sum(trademoney)/100.0*7/1000.0 money
		From tq_supply_right
		Where substr(balunitno,1,6) in ('0D')
		And tradedate between v_monthstart and p_tradedate
		Union all
		--全民付 3.8/1000
		Select sum(trademoney)/100.0*3.8/1000.0 money
		From tq_supply_right
		Where balunitno in ('21000001')
		And tradedate between v_monthstart and p_tradedate
		Union all
		--在线充付  3.8/1000
		Select sum(trademoney)/100.0*3.8/1000.0 money
		From tq_supply_right
		Where balunitno in ('14000001')
		And tradedate between v_monthstart and p_tradedate
		Union all

		--网点佣金转账日报
		SELECT  
					 SUM(A.COMFEE)/100.0 money
				FROM TF_DEPTBALTRADE_AllFIN A
				WHERE TO_CHAR(A.ENDTIME,'YYYYMMDD') >= TO_CHAR((TO_DATE(v_monthstart,'YYYYMMDD')+1),'YYYYMMDD')
				AND   TO_CHAR(A.ENDTIME,'YYYYMMDD') <= TO_CHAR((TO_DATE(p_tradedate,'YYYYMMDD')+1),'YYYYMMDD')
		UNION ALL
		--信息亭佣金

		SELECT SUM(TIMES)*1.0 money
				 FROM (SELECT COUNT(*) TIMES,CARDNO,SAMNO
                                      FROM TQ_SUPPLY_RIGHT
                                     WHERE TRADETYPECODE = '02'
                                       AND SUBSTR(BALUNITNO,1,2)='0C'
                                       AND TRADEMONEY>=10000
                                       AND TRADEDATE >= v_monthstart AND TRADEDATE <= p_tradedate
                                  GROUP BY CARDNO,SAMNO )
                                  WHERE TIMES <=5
        UNION ALL
        SELECT SUM(MONEY)/10000.0 money
         FROM  (SELECT COUNT(*) TIMES,SUM(TRADEMONEY) MONEY,CARDNO,SAMNO
                                     FROM TQ_SUPPLY_RIGHT
                                    WHERE TRADETYPECODE = '02'
                                      AND SUBSTR(BALUNITNO,1,2)='0C'
                                      AND TRADEMONEY<10000
                                      AND TRADEDATE >= v_monthstart AND TRADEDATE <= p_tradedate
                                 GROUP BY CARDNO,SAMNO )
                                  WHERE TIMES <=5
		UNION ALL
		SELECT COUNT(*)*5.0 money
		FROM (SELECT CARDNO,SAMNO,SUM(TRADEMONEY)/10000.0 MONEY
              FROM TQ_SUPPLY_RIGHT
             WHERE SUBSTR(BALUNITNO,1,2)='0C'
               AND (CARDNO,SAMNO) IN (SELECT CARDNO,SAMNO FROM
                                        (SELECT COUNT(*) TIMES,CARDNO,SAMNO
                                           FROM TQ_SUPPLY_RIGHT
                                          WHERE TRADETYPECODE = '02'
                                            AND SUBSTR(BALUNITNO,1,2)='0C'
                                            AND TRADEDATE >= v_monthstart AND TRADEDATE <= p_tradedate
                                       GROUP BY CARDNO,SAMNO )
                                       WHERE TIMES >5)
          GROUP BY CARDNO,SAMNO)
		WHERE MONEY>5
		UNION ALL
		SELECT NVL(SUM(MONEY),0) money
        FROM (SELECT CARDNO,SAMNO,SUM(TRADEMONEY)/10000.0 MONEY
                FROM TQ_SUPPLY_RIGHT
               WHERE SUBSTR(BALUNITNO,1,2)='0C'
                 AND (CARDNO,SAMNO) IN (SELECT CARDNO,SAMNO FROM
                                          (SELECT COUNT(*) TIMES,CARDNO,SAMNO
                                             FROM TQ_SUPPLY_RIGHT
                                            WHERE TRADETYPECODE = '02'
                                              AND SUBSTR(BALUNITNO,1,2)='0C'
                                              AND TRADEDATE >= v_monthstart AND TRADEDATE <= p_tradedate
                                         GROUP BY CARDNO,SAMNO )
                                         WHERE TIMES >5)
            GROUP BY CARDNO,SAMNO)
		WHERE MONEY<=5
		UNION ALL
		--退款手续费
		select nvl(-sum(BACKMONEY-FACTMONEY)/100.0,0) money
                from tf_b_refund a 
                where to_char(a.operatetime,'yyyyMMdd') >=v_monthstart and to_char(a.operatetime,'yyyyMMdd')<=p_tradedate
	   ) temp 
	   ) where tablename='1-1' and tradedate=p_tradedate;
	 
	end if;
	 
end if;
*/
IF p_tablename is null or p_tablename = '1-2' THEN
	--表1-2
	insert into TF_F_beifujinreport(tablename,tradedate,description,f1,f2,f3)
	--本期业务系统中借记客户资金账户金额,本期业务应出金金额,手续费收入
	select '1-2',p_tradedate,'支付机构客户备付金出金业务明细表', nvl(sum(money),0),0,0 from (
	--出金
	--本期业务系统中借记客户资金账户金额
	select nvl(sum(MONEY)/100.0,0) money
	from TF_FUNDSANALYSIS
	where STATTIME =p_tradedate
	and NAME in ('商户转账','轻轨转账','出租车转账','联机消费','公交回收','礼金卡回收','出租车消费补录')
	union all
	select nvl(sum(MONEY)/100.0,0) money
	from TF_FUNDSANALYSIS 
	where STATTIME =p_tradedate
	and NAME='特殊调账'
	) temp;
	
	update TF_F_beifujinreport set f3=f3+(
	--手续费 按天统计 佣金扣减在转账金额
	SELECT -nvl(sum(MONEY)/100.0,0) from (
		select nvl(sum(COMFEE),0) money
		from TF_TRADE_OUTCOMEFIN a
		where COMFEETAKECODE='1'--在转账金额扣减
		and to_char(endtime-1,'yyyyMMdd') >= p_tradedate and to_char(endtime-1,'yyyyMMdd') <=p_tradedate
		union all
		select nvl(-SUM(NVL(d.REBROKERAGE,0)),0) money from TF_B_SPEADJUSTACC d where
        d.STATECODE IN ('1','2') And D.CHECKTIME IS NOT NULL
        And d.CHECKTIME >= TO_DATE(p_tradedate,'yyyyMMdd')
        And d.CHECKTIME < TO_DATE(p_tradedate,'yyyyMMdd')+1
        and d.balunitno in (select balunitno from tf_trade_balunit where COMFEETAKECODE='1')
	) temp) where tablename='1-2' and tradedate=p_tradedate;
	
	
	--出金的手续费 按月统计 如果是月底，则统计
	/*if(substr(to_char(to_date(p_tradedate,'yyyyMMdd')+1,'yyyyMMdd'),1,6)<>substr(p_tradedate,1,6)) then 
		update TF_F_beifujinreport set f3=f3+(
		--手续费 按天统计 佣金不扣减在转账金额
		SELECT -nvl(sum(MONEY)/100.0,0) from (
		select nvl(sum(COMFEE)/100.0,0) money
		from TF_TRADE_OUTCOMEFIN a
		where COMFEETAKECODE='0'--在转账金额扣减
		and to_char(endtime-1,'yyyyMMdd') >= p_tradedate and to_char(endtime-1,'yyyyMMdd') <=p_tradedate
		union all
		select nvl(-SUM(NVL(d.REBROKERAGE,0)),0) money from TF_B_SPEADJUSTACC d where
        d.STATECODE IN ('1','2') And D.CHECKTIME IS NOT NULL
        And d.CHECKTIME >= TO_DATE(p_tradedate,'yyyyMMdd')
        And d.CHECKTIME < TO_DATE(p_tradedate,'yyyyMMdd')+1
        and d.balunitno in (select balunitno from tf_trade_balunit where COMFEETAKECODE='0')
		) temp) where tablename='1-2' and tradedate=p_tradedate;
	
	end if;*/
	--本期业务应出金金额
	update TF_F_beifujinreport set f2=f1-f3 where tablename='1-2' and tradedate=p_tradedate;
end if;	

IF p_tablename is null or p_tablename = '1-4' THEN
	--表1-4
	--本期业务系统中客户资金账户借方发生额,本期业务系统中客户资金账户贷方发生额	,手续费收入
	insert into TF_F_beifujinreport(tablename,tradedate,description,f1,f2,f3)
	select '1-4',p_tradedate,'支付机构客户资金账户转账业务统计表', nvl(sum(money),0),nvl(sum(fumoney),0),0 from (
		select sum(currentmoney)/100.0 money,-sum(currentmoney)/100.0 fumoney
		from tf_b_trade t
		where t.tradetypecode in ('04') and operatetime >=to_date(p_tradedate,'yyyyMMdd') and operatetime <to_date(p_tradedate,'yyyyMMdd')+1
	) temp;
	
	--表1-5 支付机构客户资金账户余额统计表 客户资金账户期初余额	本期入金业务贷记客户资金账户金额	本期出金业务借记客户资金账户金额
	--客户资金账户借方发生额	客户资金账户贷方发生额 客户资金账户期末余额
		
end if;

IF p_tablename is null or p_tablename = '1-5' THEN
	insert into TF_F_beifujinreport(tablename,tradedate,description,f1,f2,f3,f4,f5,f6)
	select '1-5',p_tradedate,'支付机构客户资金账户余额统计表', 0,nvl(sum(money),0),nvl(sum(chumoney),0),nvl(sum(neimoney),0),nvl(sum(neifumoney),0),0 from (
		
		select nvl(sum(MONEY)/100.0,0) money,0 chumoney,0 neimoney,0 neifumoney
		from TF_FUNDSANALYSIS
		where STATTIME =p_tradedate
		and NAME in ('营业厅充值','代理充值','在线充付商户代理充值','充值卡现金售卡','充值卡直销售卡','企服卡充值对账','礼金卡售卡','旅游卡售卡')
		union all
		select nvl(sum(MONEY)/100.0,0) money,0 chumoney,0 neimoney,0 neifumoney
		from TF_FUNDSANALYSIS 
		where STATTIME =p_tradedate
		and NAME in ('退充值转账')
		union all
		select 0 money,nvl(sum(MONEY)/100.0,0) chumoney,0 neimoney,0 neifumoney
		from TF_FUNDSANALYSIS
		where STATTIME =p_tradedate
		and NAME in ('商户转账','轻轨转账','出租车转账','联机消费','公交回收','礼金卡回收','出租车消费补录')
		union all
		select 0 money,nvl(sum(MONEY)/100.0,0) chumoney,0 neimoney,0 neifumoney
		from TF_FUNDSANALYSIS 
		where STATTIME =p_tradedate
		and NAME='特殊调账'
		
		union all
		select 0 money,0 chumoney,sum(currentmoney)/100.0 neimoney,-sum(currentmoney)/100.0 neifumoney
		from tf_b_trade t
		where t.tradetypecode in ('04') and operatetime >=to_date(p_tradedate,'yyyyMMdd') and operatetime <to_date(p_tradedate,'yyyyMMdd')+1
		
	) temp;

end if;

IF p_tablename is null or p_tablename = '1-7' THEN
	--表1-7 支付机构现金购卡业务统计表
	--本期接受现金形式的客户备付金金额
	insert into TF_F_beifujinreport(tablename,tradedate,description,f1)
	select '1-7',p_tradedate,'支付机构现金购卡业务统计表', nvl(sum(money),0) from (
	
		select nvl((sum(b.carddepositfee) + sum(b.supplymoney)),0)/100.0 money
		from tf_b_trade a, tf_b_tradefee b
		where a.tradeid = b.tradeid(+)
		and a.tradetypecode in ('50','51','F0','F1') and b.supplymoney!=0
		and a.operatetime >=to_date(p_tradedate,'yyyyMMdd') and a.operatetime <to_date(p_tradedate,'yyyyMMdd')+1
		
		union all
		select -nvl(sum(t.CASHGIFTMONEY/100.0),0) money
		from TF_F_ORDERFORM t
		where not exists (select b.orderno from tf_f_paytype b where b.paytypecode in ('2') and t.orderno = b.orderno)
		and t.ORDERSTATE not in ('00','01','09') 
		--通过业务系统做的订单，其他是通过导过来的。
		and substr(t.orderno,1,2) = '20'
		and FINANCEAPPROVERTIME >=to_date(p_tradedate,'yyyyMMdd') and FINANCEAPPROVERTIME <to_date(p_tradedate,'yyyyMMdd')+1
	) temp;
	
end if;

IF p_tablename is null or p_tablename = '1-8' THEN
	--表1-8  支付机构预付卡现金赎回业务统计表
	
	--本期以自有资金先行赎回预付卡的金额
	insert into TF_F_beifujinreport(tablename,tradedate,description,f1)
	select '1-8',p_tradedate,'支付机构预付卡现金赎回业务统计表', nvl(sum(money),0) from (
		select nvl(sum(MONEY)/100.0,0) money from TF_FUNDSANALYSIS where  NAME in ('退卡退余额','销户退余额','旅游卡可读回收','旅游卡不可读回收')
		and STATTIME=p_tradedate	
	) temp;
end if;

IF p_tablename is null or p_tablename = '1-10' THEN
	--表1-10  支付机构XX银行客户备付金业务未达账项分析表
	
	--≤5日	6-10日	≥11日
	--笔数	金额	笔数	金额	笔数	金额
	insert into TF_F_beifujinreport(tablename,tradedate,description,f1,f2,f3,f4,f5,f6)
	select '1-10',p_tradedate,'支付机构XX银行客户备付金业务未达账项分析表', 0,0,0,0,0,0
	from dual;
	update TF_F_beifujinreport set (f1,f2)=(
		select sum(count),sum(sum) from (
			--  <=5  笔数  金额
			select nvl(sum(count),0) count ,nvl(sum(SUM),0) sum
			from TF_F_CASHGIFTORDER a--礼金卡
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --只能是呈批单
			  where aaa.orderno=aa.orderno 
			  and not exists (select orderno from tf_f_paytype where paytypecode in ('0','1','2','3') and orderno = aa.orderno)
			  and paytypecode = '4'
			  )
			  and aa.FINANCEAPPROVERTIME >=to_date(p_tradedate,'yyyyMMdd') and aa.FINANCEAPPROVERTIME <to_date(p_tradedate,'yyyyMMdd')+1
			  and exists(select 1 from TF_F_ORDERTRADE where orderno=aa.orderno and TRADECODE='14' 
			  and abs(trunc(aa.FINANCEAPPROVERTIME)-trunc(OPERATETIME) )<=5)
			)
			union all
			select nvl(sum(count),0) count,nvl(sum(SUM),0) sum
			from TF_F_CHARGECARDORDER a  --充值卡
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --只能是呈批单
			  where aaa.orderno=aa.orderno 
			  and not exists (select orderno from tf_f_paytype where paytypecode in ('0','1','2','3') and orderno = aa.orderno)
			  and paytypecode = '4'
			  )
			  and aa.FINANCEAPPROVERTIME >=to_date(p_tradedate,'yyyyMMdd') and aa.FINANCEAPPROVERTIME <to_date(p_tradedate,'yyyyMMdd')+1
			  and exists(select 1 from TF_F_ORDERTRADE where orderno=aa.orderno and TRADECODE='14' 
			  and abs(trunc(aa.FINANCEAPPROVERTIME)-trunc(OPERATETIME) )<=5)
			)
			union all
			select nvl(sum(count),0) count,nvl(sum(TOTALMONEY),0) sum
			from TF_F_SZTCARDORDER a --市民卡B卡
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --只能是呈批单
			  where aaa.orderno=aa.orderno 
			  and not exists (select orderno from tf_f_paytype where paytypecode in ('0','1','2','3') and orderno = aa.orderno)
			  and paytypecode = '4'
			  )
			  and aa.FINANCEAPPROVERTIME >=to_date(p_tradedate,'yyyyMMdd') and aa.FINANCEAPPROVERTIME <to_date(p_tradedate,'yyyyMMdd')+1
			  and exists(select 1 from TF_F_ORDERTRADE where orderno=aa.orderno and TRADECODE='14' 
			  and abs(trunc(aa.FINANCEAPPROVERTIME)-trunc(OPERATETIME) )<=5)
			)
			
			
		) temp
	) where tablename='1-10' and tradedate =p_tradedate;
	
	--6-10 笔数 金额
	update TF_F_beifujinreport set (f3,f4)=(
		select sum(count),sum(sum) from (
			--  <=5  笔数  金额
			select nvl(sum(count),0) count ,nvl(sum(SUM),0) sum
			from TF_F_CASHGIFTORDER a--礼金卡
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --只能是呈批单
			  where aaa.orderno=aa.orderno 
			  and not exists (select orderno from tf_f_paytype where paytypecode in ('0','1','2','3') and orderno = aa.orderno)
			  and paytypecode = '4'
			  )
			  and aa.FINANCEAPPROVERTIME >=to_date(p_tradedate,'yyyyMMdd') and aa.FINANCEAPPROVERTIME <to_date(p_tradedate,'yyyyMMdd')+1
			  and exists(select 1 from TF_F_ORDERTRADE where orderno=aa.orderno and TRADECODE='14' 
			  and abs(trunc(aa.FINANCEAPPROVERTIME)-trunc(OPERATETIME) )<=10 and abs(trunc(aa.FINANCEAPPROVERTIME)-trunc(OPERATETIME) )>=6)
			)
			union all
			select nvl(sum(count),0) count,nvl(sum(SUM),0) sum
			from TF_F_CHARGECARDORDER a  --充值卡
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --只能是呈批单
			  where aaa.orderno=aa.orderno 
			  and not exists (select orderno from tf_f_paytype where paytypecode in ('0','1','2','3') and orderno = aa.orderno)
			  and paytypecode = '4'
			  )
			  and aa.FINANCEAPPROVERTIME >=to_date(p_tradedate,'yyyyMMdd') and aa.FINANCEAPPROVERTIME <to_date(p_tradedate,'yyyyMMdd')+1
			  and exists(select 1 from TF_F_ORDERTRADE where orderno=aa.orderno and TRADECODE='14' 
			  and abs(trunc(aa.FINANCEAPPROVERTIME)-trunc(OPERATETIME) )<=10 and abs(trunc(aa.FINANCEAPPROVERTIME)-trunc(OPERATETIME) )>=6)
			)
			union all
			select nvl(sum(count),0) count,nvl(sum(TOTALMONEY),0) sum
			from TF_F_SZTCARDORDER a --市民卡B卡
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --只能是呈批单
			  where aaa.orderno=aa.orderno 
			  and not exists (select orderno from tf_f_paytype where paytypecode in ('0','1','2','3') and orderno = aa.orderno)
			  and paytypecode = '4'
			  )
			  and aa.FINANCEAPPROVERTIME >=to_date(p_tradedate,'yyyyMMdd') and aa.FINANCEAPPROVERTIME <to_date(p_tradedate,'yyyyMMdd')+1
			  and exists(select 1 from TF_F_ORDERTRADE where orderno=aa.orderno and TRADECODE='14' 
			  and abs(trunc(aa.FINANCEAPPROVERTIME)-trunc(OPERATETIME) )<=10 and abs(trunc(aa.FINANCEAPPROVERTIME)-trunc(OPERATETIME) )>=6)
			)
			
			
		) temp
	) where tablename='1-10' and tradedate =p_tradedate;
	
	--11 笔数 金额
	update TF_F_beifujinreport set (f5,f6)=(
		select sum(count),sum(sum) from (
			--  <=5  笔数  金额
			select nvl(sum(count),0) count ,nvl(sum(SUM),0) sum
			from TF_F_CASHGIFTORDER a--礼金卡
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --只能是呈批单
			  where aaa.orderno=aa.orderno 
			  and not exists (select orderno from tf_f_paytype where paytypecode in ('0','1','2','3') and orderno = aa.orderno)
			  and paytypecode = '4'
			  )
			  and aa.FINANCEAPPROVERTIME >=to_date(p_tradedate,'yyyyMMdd') and aa.FINANCEAPPROVERTIME <to_date(p_tradedate,'yyyyMMdd')+1
			  and exists(select 1 from TF_F_ORDERTRADE where orderno=aa.orderno and TRADECODE='14' 
			  and abs(trunc(aa.FINANCEAPPROVERTIME)-trunc(OPERATETIME) )>=11)
			)
			union all
			select nvl(sum(count),0) count,nvl(sum(SUM),0) sum
			from TF_F_CHARGECARDORDER a  --充值卡
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --只能是呈批单
			  where aaa.orderno=aa.orderno 
			  and not exists (select orderno from tf_f_paytype where paytypecode in ('0','1','2','3') and orderno = aa.orderno)
			  and paytypecode = '4'
			  )
			  and aa.FINANCEAPPROVERTIME >=to_date(p_tradedate,'yyyyMMdd') and aa.FINANCEAPPROVERTIME <to_date(p_tradedate,'yyyyMMdd')+1
			  and exists(select 1 from TF_F_ORDERTRADE where orderno=aa.orderno and TRADECODE='14' 
			  and abs(trunc(aa.FINANCEAPPROVERTIME)-trunc(OPERATETIME) )>=11)
			)
			union all
			select nvl(sum(count),0) count,nvl(sum(TOTALMONEY),0) sum
			from TF_F_SZTCARDORDER a --市民卡B卡
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --只能是呈批单
			  where aaa.orderno=aa.orderno 
			  and not exists (select orderno from tf_f_paytype where paytypecode in ('0','1','2','3') and orderno = aa.orderno)
			  and paytypecode = '4'
			  )
			  and aa.FINANCEAPPROVERTIME >=to_date(p_tradedate,'yyyyMMdd') and aa.FINANCEAPPROVERTIME <to_date(p_tradedate,'yyyyMMdd')+1
			  and exists(select 1 from TF_F_ORDERTRADE where orderno=aa.orderno and TRADECODE='14' 
			  and abs(trunc(aa.FINANCEAPPROVERTIME)-trunc(OPERATETIME) )>=11)
			)
			
			
		) temp
	) where tablename='1-10' and tradedate =p_tradedate;
	
	update TF_F_beifujinreport set f2=f2/100.0,f4=f4/100.0,f6=f6/100.0 where tablename='1-10' and tradedate =p_tradedate;
	
end if;

IF p_tablename is null or p_tablename = '1-13' THEN
	--表1-13 预付卡发行企业备付金账户中售卡押金统计表
	--期初备付金账户中押金余额  转账方式收到 现金形式缴存 转账方式直接付出 现金形式先行赎回业务中申请结转金额 期末备付金账户中押金余额
	insert into TF_F_beifujinreport(tablename,tradedate,description,f1,f2,f3,f4,f5,f6)
	select '1-13',p_tradedate,'预付卡发行企业备付金账户中售卡押金统计表', nvl(sum(chushimoney),0),0,nvl(sum(xianjinmoney),0),0,nvl(sum(shumoney),0) ,0
	from (
		select nvl(sum(CARDDEPOSITFEE)/100.0,0) chushimoney,0 zhuanmoney,0 xianjinmoney,0 zhuanfumoney,0 shumoney ,0 momoney from tf_b_tradefee where operatetime <to_date(p_tradedate,'yyyyMMdd') 
		and tradetypecode in ('7H')
		union all
		--现金形式缴存
		select 0 chushimoney,0 zhuanmoney,nvl(sum(CARDDEPOSITFEE)/100.0,0) xianjinmoney,0 zhuanfumoney,0 shumoney ,0 momoney from tf_b_tradefee where operatetime >=to_date(p_tradedate,'yyyyMMdd') and operatetime <to_date(p_tradedate,'yyyyMMdd')+1
		and tradetypecode in ('7H')
		union all
		--现金形式先行赎回业务中申请结转金额
		select 0 chushimoney,0 zhuanmoney,0 xianjinmoney,0 zhuanfumoney,-nvl(sum(a.backmoney + a.backdeposit),0)/100.0 shumoney ,0 momoney
		from tf_b_trade_sztravel_rf a  where a.isupdated = '1'   
		and operatetime >=to_date(p_tradedate,'yyyyMMdd') and operatetime <to_date(p_tradedate,'yyyyMMdd')+1
	) temp;
	--期末备付金账户中押金余额
	update TF_F_beifujinreport set f6=f1+f2+f3+f4+f5 where tablename='1-13' and tradedate=p_tradedate;
end if;
	p_retCode := 0;
    p_retMsg  := 'OK';
    COMMIT; 
    RETURN; 
 EXCEPTION WHEN OTHERS THEN
    p_retCode := -8; p_retMsg  := '备付金报表统计失败,' || SQLERRM;
    ROLLBACK; RETURN;
end;
/
show errors