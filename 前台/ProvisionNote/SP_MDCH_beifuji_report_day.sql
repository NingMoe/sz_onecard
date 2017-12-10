/*
create time :2014/1/8 22:51
creator :wdx
content:�����𱨱�ͳ��
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
	--ҵ��ϵͳ�д��ǿͻ��ʽ��˻����,������֧��
	select '1-1',p_tradedate,'֧������XX���пͻ����������ҵ����ϸ��', nvl(sum(money),0),0 from (
		select nvl(sum(MONEY)/100.0,0) money
		from TF_FUNDSANALYSIS
		where STATTIME =p_tradedate
		and NAME in ('Ӫҵ����ֵ','�����ֵ','���߳丶�̻������ֵ','��ֵ���ֽ��ۿ�','��ֵ��ֱ���ۿ�','�������ֵ����','����ۿ�','���ο��ۿ�')
		union all
		select nvl(sum(MONEY)/100.0,0) money
		from TF_FUNDSANALYSIS 
		where STATTIME =p_tradedate
		and NAME in ('�˳�ֵת��')
	) temp;

	--���������� ����ͳ�� ������µף���ͳ��
	if(substr(to_char(to_date(p_tradedate,'yyyyMMdd')+1,'yyyyMMdd'),1,6)<>substr(p_tradedate,1,6)) then 
		v_monthstart:=substr(p_tradedate,1,6) || '01';--ĳ�µĵ�һ��
		update TF_F_beifujinreport set f2=(
		SELECT -SUM(money) FROM (
		--���� ÿ��7/1000
		Select sum(trademoney)/100.0*7/1000.0 money
		From tq_supply_right
		Where substr(balunitno,1,6) in ('0D')
		And tradedate between v_monthstart and p_tradedate
		Union all
		--ȫ�� 3.8/1000
		Select sum(trademoney)/100.0*3.8/1000.0 money
		From tq_supply_right
		Where balunitno in ('21000001')
		And tradedate between v_monthstart and p_tradedate
		Union all
		--���߳丶  3.8/1000
		Select sum(trademoney)/100.0*3.8/1000.0 money
		From tq_supply_right
		Where balunitno in ('14000001')
		And tradedate between v_monthstart and p_tradedate
		Union all

		--����Ӷ��ת���ձ�
		SELECT  
					 SUM(A.COMFEE)/100.0 money
				FROM TF_DEPTBALTRADE_AllFIN A
				WHERE TO_CHAR(A.ENDTIME,'YYYYMMDD') >= TO_CHAR((TO_DATE(v_monthstart,'YYYYMMDD')+1),'YYYYMMDD')
				AND   TO_CHAR(A.ENDTIME,'YYYYMMDD') <= TO_CHAR((TO_DATE(p_tradedate,'YYYYMMDD')+1),'YYYYMMDD')
		UNION ALL
		--��ϢͤӶ��

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
		--�˿�������
		select nvl(-sum(BACKMONEY-FACTMONEY)/100.0,0) money
                from tf_b_refund a 
                where to_char(a.operatetime,'yyyyMMdd') >=v_monthstart and to_char(a.operatetime,'yyyyMMdd')<=p_tradedate
	   ) temp 
	   ) where tablename='1-1' and tradedate=p_tradedate;
	 
	end if;
	 
end if;
*/
IF p_tablename is null or p_tablename = '1-2' THEN
	--��1-2
	insert into TF_F_beifujinreport(tablename,tradedate,description,f1,f2,f3)
	--����ҵ��ϵͳ�н�ǿͻ��ʽ��˻����,����ҵ��Ӧ������,����������
	select '1-2',p_tradedate,'֧�������ͻ����������ҵ����ϸ��', nvl(sum(money),0),0,0 from (
	--����
	--����ҵ��ϵͳ�н�ǿͻ��ʽ��˻����
	select nvl(sum(MONEY)/100.0,0) money
	from TF_FUNDSANALYSIS
	where STATTIME =p_tradedate
	and NAME in ('�̻�ת��','���ת��','���⳵ת��','��������','��������','��𿨻���','���⳵���Ѳ�¼')
	union all
	select nvl(sum(MONEY)/100.0,0) money
	from TF_FUNDSANALYSIS 
	where STATTIME =p_tradedate
	and NAME='�������'
	) temp;
	
	update TF_F_beifujinreport set f3=f3+(
	--������ ����ͳ�� Ӷ��ۼ���ת�˽��
	SELECT -nvl(sum(MONEY)/100.0,0) from (
		select nvl(sum(COMFEE),0) money
		from TF_TRADE_OUTCOMEFIN a
		where COMFEETAKECODE='1'--��ת�˽��ۼ�
		and to_char(endtime-1,'yyyyMMdd') >= p_tradedate and to_char(endtime-1,'yyyyMMdd') <=p_tradedate
		union all
		select nvl(-SUM(NVL(d.REBROKERAGE,0)),0) money from TF_B_SPEADJUSTACC d where
        d.STATECODE IN ('1','2') And D.CHECKTIME IS NOT NULL
        And d.CHECKTIME >= TO_DATE(p_tradedate,'yyyyMMdd')
        And d.CHECKTIME < TO_DATE(p_tradedate,'yyyyMMdd')+1
        and d.balunitno in (select balunitno from tf_trade_balunit where COMFEETAKECODE='1')
	) temp) where tablename='1-2' and tradedate=p_tradedate;
	
	
	--����������� ����ͳ�� ������µף���ͳ��
	/*if(substr(to_char(to_date(p_tradedate,'yyyyMMdd')+1,'yyyyMMdd'),1,6)<>substr(p_tradedate,1,6)) then 
		update TF_F_beifujinreport set f3=f3+(
		--������ ����ͳ�� Ӷ�𲻿ۼ���ת�˽��
		SELECT -nvl(sum(MONEY)/100.0,0) from (
		select nvl(sum(COMFEE)/100.0,0) money
		from TF_TRADE_OUTCOMEFIN a
		where COMFEETAKECODE='0'--��ת�˽��ۼ�
		and to_char(endtime-1,'yyyyMMdd') >= p_tradedate and to_char(endtime-1,'yyyyMMdd') <=p_tradedate
		union all
		select nvl(-SUM(NVL(d.REBROKERAGE,0)),0) money from TF_B_SPEADJUSTACC d where
        d.STATECODE IN ('1','2') And D.CHECKTIME IS NOT NULL
        And d.CHECKTIME >= TO_DATE(p_tradedate,'yyyyMMdd')
        And d.CHECKTIME < TO_DATE(p_tradedate,'yyyyMMdd')+1
        and d.balunitno in (select balunitno from tf_trade_balunit where COMFEETAKECODE='0')
		) temp) where tablename='1-2' and tradedate=p_tradedate;
	
	end if;*/
	--����ҵ��Ӧ������
	update TF_F_beifujinreport set f2=f1-f3 where tablename='1-2' and tradedate=p_tradedate;
end if;	

IF p_tablename is null or p_tablename = '1-4' THEN
	--��1-4
	--����ҵ��ϵͳ�пͻ��ʽ��˻��跽������,����ҵ��ϵͳ�пͻ��ʽ��˻�����������	,����������
	insert into TF_F_beifujinreport(tablename,tradedate,description,f1,f2,f3)
	select '1-4',p_tradedate,'֧�������ͻ��ʽ��˻�ת��ҵ��ͳ�Ʊ�', nvl(sum(money),0),nvl(sum(fumoney),0),0 from (
		select sum(currentmoney)/100.0 money,-sum(currentmoney)/100.0 fumoney
		from tf_b_trade t
		where t.tradetypecode in ('04') and operatetime >=to_date(p_tradedate,'yyyyMMdd') and operatetime <to_date(p_tradedate,'yyyyMMdd')+1
	) temp;
	
	--��1-5 ֧�������ͻ��ʽ��˻����ͳ�Ʊ� �ͻ��ʽ��˻��ڳ����	�������ҵ����ǿͻ��ʽ��˻����	���ڳ���ҵ���ǿͻ��ʽ��˻����
	--�ͻ��ʽ��˻��跽������	�ͻ��ʽ��˻����������� �ͻ��ʽ��˻���ĩ���
		
end if;

IF p_tablename is null or p_tablename = '1-5' THEN
	insert into TF_F_beifujinreport(tablename,tradedate,description,f1,f2,f3,f4,f5,f6)
	select '1-5',p_tradedate,'֧�������ͻ��ʽ��˻����ͳ�Ʊ�', 0,nvl(sum(money),0),nvl(sum(chumoney),0),nvl(sum(neimoney),0),nvl(sum(neifumoney),0),0 from (
		
		select nvl(sum(MONEY)/100.0,0) money,0 chumoney,0 neimoney,0 neifumoney
		from TF_FUNDSANALYSIS
		where STATTIME =p_tradedate
		and NAME in ('Ӫҵ����ֵ','�����ֵ','���߳丶�̻������ֵ','��ֵ���ֽ��ۿ�','��ֵ��ֱ���ۿ�','�������ֵ����','����ۿ�','���ο��ۿ�')
		union all
		select nvl(sum(MONEY)/100.0,0) money,0 chumoney,0 neimoney,0 neifumoney
		from TF_FUNDSANALYSIS 
		where STATTIME =p_tradedate
		and NAME in ('�˳�ֵת��')
		union all
		select 0 money,nvl(sum(MONEY)/100.0,0) chumoney,0 neimoney,0 neifumoney
		from TF_FUNDSANALYSIS
		where STATTIME =p_tradedate
		and NAME in ('�̻�ת��','���ת��','���⳵ת��','��������','��������','��𿨻���','���⳵���Ѳ�¼')
		union all
		select 0 money,nvl(sum(MONEY)/100.0,0) chumoney,0 neimoney,0 neifumoney
		from TF_FUNDSANALYSIS 
		where STATTIME =p_tradedate
		and NAME='�������'
		
		union all
		select 0 money,0 chumoney,sum(currentmoney)/100.0 neimoney,-sum(currentmoney)/100.0 neifumoney
		from tf_b_trade t
		where t.tradetypecode in ('04') and operatetime >=to_date(p_tradedate,'yyyyMMdd') and operatetime <to_date(p_tradedate,'yyyyMMdd')+1
		
	) temp;

end if;

IF p_tablename is null or p_tablename = '1-7' THEN
	--��1-7 ֧�������ֽ𹺿�ҵ��ͳ�Ʊ�
	--���ڽ����ֽ���ʽ�Ŀͻ���������
	insert into TF_F_beifujinreport(tablename,tradedate,description,f1)
	select '1-7',p_tradedate,'֧�������ֽ𹺿�ҵ��ͳ�Ʊ�', nvl(sum(money),0) from (
	
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
		--ͨ��ҵ��ϵͳ���Ķ�����������ͨ���������ġ�
		and substr(t.orderno,1,2) = '20'
		and FINANCEAPPROVERTIME >=to_date(p_tradedate,'yyyyMMdd') and FINANCEAPPROVERTIME <to_date(p_tradedate,'yyyyMMdd')+1
	) temp;
	
end if;

IF p_tablename is null or p_tablename = '1-8' THEN
	--��1-8  ֧������Ԥ�����ֽ����ҵ��ͳ�Ʊ�
	
	--�����������ʽ��������Ԥ�����Ľ��
	insert into TF_F_beifujinreport(tablename,tradedate,description,f1)
	select '1-8',p_tradedate,'֧������Ԥ�����ֽ����ҵ��ͳ�Ʊ�', nvl(sum(money),0) from (
		select nvl(sum(MONEY)/100.0,0) money from TF_FUNDSANALYSIS where  NAME in ('�˿������','���������','���ο��ɶ�����','���ο����ɶ�����')
		and STATTIME=p_tradedate	
	) temp;
end if;

IF p_tablename is null or p_tablename = '1-10' THEN
	--��1-10  ֧������XX���пͻ�������ҵ��δ�����������
	
	--��5��	6-10��	��11��
	--����	���	����	���	����	���
	insert into TF_F_beifujinreport(tablename,tradedate,description,f1,f2,f3,f4,f5,f6)
	select '1-10',p_tradedate,'֧������XX���пͻ�������ҵ��δ�����������', 0,0,0,0,0,0
	from dual;
	update TF_F_beifujinreport set (f1,f2)=(
		select sum(count),sum(sum) from (
			--  <=5  ����  ���
			select nvl(sum(count),0) count ,nvl(sum(SUM),0) sum
			from TF_F_CASHGIFTORDER a--���
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --ֻ���ǳ�����
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
			from TF_F_CHARGECARDORDER a  --��ֵ��
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --ֻ���ǳ�����
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
			from TF_F_SZTCARDORDER a --����B��
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --ֻ���ǳ�����
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
	
	--6-10 ���� ���
	update TF_F_beifujinreport set (f3,f4)=(
		select sum(count),sum(sum) from (
			--  <=5  ����  ���
			select nvl(sum(count),0) count ,nvl(sum(SUM),0) sum
			from TF_F_CASHGIFTORDER a--���
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --ֻ���ǳ�����
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
			from TF_F_CHARGECARDORDER a  --��ֵ��
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --ֻ���ǳ�����
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
			from TF_F_SZTCARDORDER a --����B��
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --ֻ���ǳ�����
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
	
	--11 ���� ���
	update TF_F_beifujinreport set (f5,f6)=(
		select sum(count),sum(sum) from (
			--  <=5  ����  ���
			select nvl(sum(count),0) count ,nvl(sum(SUM),0) sum
			from TF_F_CASHGIFTORDER a--���
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --ֻ���ǳ�����
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
			from TF_F_CHARGECARDORDER a  --��ֵ��
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --ֻ���ǳ�����
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
			from TF_F_SZTCARDORDER a --����B��
			where exists(
			  select 1 from TF_F_ORDERFORM aa 
			  where aa.orderno=a.orderno 
			  and exists(
			  select orderno from tf_f_paytype aaa
			  --ֻ���ǳ�����
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
	--��1-13 Ԥ����������ҵ�������˻����ۿ�Ѻ��ͳ�Ʊ�
	--�ڳ��������˻���Ѻ�����  ת�˷�ʽ�յ� �ֽ���ʽ�ɴ� ת�˷�ʽֱ�Ӹ��� �ֽ���ʽ�������ҵ���������ת��� ��ĩ�������˻���Ѻ�����
	insert into TF_F_beifujinreport(tablename,tradedate,description,f1,f2,f3,f4,f5,f6)
	select '1-13',p_tradedate,'Ԥ����������ҵ�������˻����ۿ�Ѻ��ͳ�Ʊ�', nvl(sum(chushimoney),0),0,nvl(sum(xianjinmoney),0),0,nvl(sum(shumoney),0) ,0
	from (
		select nvl(sum(CARDDEPOSITFEE)/100.0,0) chushimoney,0 zhuanmoney,0 xianjinmoney,0 zhuanfumoney,0 shumoney ,0 momoney from tf_b_tradefee where operatetime <to_date(p_tradedate,'yyyyMMdd') 
		and tradetypecode in ('7H')
		union all
		--�ֽ���ʽ�ɴ�
		select 0 chushimoney,0 zhuanmoney,nvl(sum(CARDDEPOSITFEE)/100.0,0) xianjinmoney,0 zhuanfumoney,0 shumoney ,0 momoney from tf_b_tradefee where operatetime >=to_date(p_tradedate,'yyyyMMdd') and operatetime <to_date(p_tradedate,'yyyyMMdd')+1
		and tradetypecode in ('7H')
		union all
		--�ֽ���ʽ�������ҵ���������ת���
		select 0 chushimoney,0 zhuanmoney,0 xianjinmoney,0 zhuanfumoney,-nvl(sum(a.backmoney + a.backdeposit),0)/100.0 shumoney ,0 momoney
		from tf_b_trade_sztravel_rf a  where a.isupdated = '1'   
		and operatetime >=to_date(p_tradedate,'yyyyMMdd') and operatetime <to_date(p_tradedate,'yyyyMMdd')+1
	) temp;
	--��ĩ�������˻���Ѻ�����
	update TF_F_beifujinreport set f6=f1+f2+f3+f4+f5 where tablename='1-13' and tradedate=p_tradedate;
end if;
	p_retCode := 0;
    p_retMsg  := 'OK';
    COMMIT; 
    RETURN; 
 EXCEPTION WHEN OTHERS THEN
    p_retCode := -8; p_retMsg  := '�����𱨱�ͳ��ʧ��,' || SQLERRM;
    ROLLBACK; RETURN;
end;
/
show errors