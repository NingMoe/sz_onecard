create or replace procedure SP_IT_QueryByID
(
    p_ID                         varchar,
    p_cursor           out SYS_REFCURSOR
)
as
    v_quantity          int;
	v_quantity_sk		int;
begin
   if length(p_ID)=18 then
   --说明是通过系统充值的
   
	select  count(*) into v_quantity from  TF_SUPPLY_REALTIME  t where t.ID=p_ID; 
	select  count(*) into v_quantity_sk from  TF_SUPPLY_REALTIME_SK  t where TRIM(t.ID)=p_ID; 
    if(v_quantity>0) then
    open p_cursor for
    select  c.custname,t.trademoney,t.tradedate,t.cardno,f.CUSTRECTYPECODE from  TF_SUPPLY_REALTIME  t   	
    inner join TF_F_CARDREC f on t.cardno=f.cardno left join TF_F_CUSTOMERREC c on t.cardno=c.cardno where 
    rownum<2 and t.tradedate between to_char(sysdate-180,'YYYYMMDD')
    and to_char(sysdate,'YYYYMMDD') and t.ID=p_ID  and t.TradeTypeCode='02';  	
    elsif (v_quantity=0) then
	select  count(*) into v_quantity from  TQ_SUPPLY_RIGHT  t where t.ID=p_ID; 
		if v_quantity > 0 then
		open p_cursor for
		select  c.custname,t.trademoney,t.tradedate,t.cardno,f.CUSTRECTYPECODE from  TQ_SUPPLY_RIGHT  t 	
		inner join TF_F_CARDREC f on t.cardno=f.cardno left join TF_F_CUSTOMERREC c on t.cardno=c.cardno 	
		where t.tradedate between to_char(sysdate-180,'YYYYMMDD') 
		and to_char(sysdate,'YYYYMMDD') and t.ID=p_ID  and t.TradeTypeCode='02' and rownum<2;
		else
			if v_quantity_sk > 0 then
			open p_cursor for
			select  c.custname,t.trademoney,t.tradedate,t.cardno,f.CUSTRECTYPECODE from  TF_SUPPLY_REALTIME_SK  t   	
			inner join TF_F_CARDREC_SK f on t.cardno=f.cardno left join TF_F_CUSTOMACCRE_SK d on t.cardno = d.cardno
			left join TF_F_CUSTOMERREC_SK c on d.customno=c.customno where 
			rownum<2 and t.tradedate between to_char(sysdate-180,'YYYYMMDD')
			and to_char(sysdate,'YYYYMMDD') and TRIM(t.ID)=p_ID  and t.TradeTypeCode='02';  
			elsif v_quantity_sk = 0 then
				select  count(*) into v_quantity_sk from  TQ_SUPPLY_RIGHT_SK  t where t.ID=p_ID;
				if v_quantity_sk > 0 then
					open p_cursor for
					select  c.custname,t.trademoney,t.tradedate,t.cardno,f.CUSTRECTYPECODE from  TQ_SUPPLY_RIGHT_SK  t 	
					inner join TF_F_CARDREC_SK f on t.cardno=f.cardno left join TF_F_CUSTOMACCRE_SK d on t.cardno = d.cardno
					left join TF_F_CUSTOMERREC_SK c on d.customno=c.customno 	
					where t.tradedate between to_char(sysdate-180,'YYYYMMDD') 
					and to_char(sysdate,'YYYYMMDD') and TRIM(t.ID)=p_ID  and t.TradeTypeCode='02' and rownum<2;	 
				end if;
			end if;
		end if;
	end if;
   elsif length(p_ID)<>18 then
   --说明是通过代理点充值的
           select count(*) into v_quantity from  TF_OUTSUPPLY_CARDLOAD  t where t.tradeid=p_ID;			
           if(v_quantity>0) then
                open p_cursor for
                select c.custname,t.trademoney,t.tradedate,f.cardno,f.CUSTRECTYPECODE from  
                TF_OUTSUPPLY_CARDLOAD  t 	inner join TF_F_CARDREC f on t.asn=f.asn 
                left join TF_F_CUSTOMERREC c on f.cardno=c.cardno where t.tradeid=p_ID;			
           elsif(v_quantity=0) then
                open p_cursor for
                select  c.custname,t.trademoney,t.tradedate,t.cardno,f.CUSTRECTYPECODE from  
                TQ_SUPPLY_RIGHT  t 	inner join TF_F_CARDREC f on t.cardno=f.cardno 
                left join TF_F_CUSTOMERREC c on t.cardno=c.cardno 		
                where  t.tradedate between to_char(sysdate-90,'YYYYMMDD') 
                 and to_char(sysdate,'YYYYMMDD') and t.tradeid=p_ID  and t.TradeTypeCode='02' and rownum<2;
           end if;
   end if;
end;
/
show errors