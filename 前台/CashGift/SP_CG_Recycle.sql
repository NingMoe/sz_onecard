/******************************************************/
-- Author  : 
-- Created : 
-- UpdatedAuthor : wdx
-- Updated : 2012-2-10 11:01
-- Content : 出库或分配的卡本来可以回收，现在只有售出的卡才能回收
-- Purpose : 礼金卡回收
/******************************************************/
create or replace procedure SP_CG_Recycle
(
    p_cardNo          char, -- 读卡-卡号-16位卡号
    p_wallet1         int , -- 读卡-电子钱包余额1
    p_wallet2         int , -- 读卡-电子钱包余额2
    p_startDate       char, -- 读卡-起始有效期(yyyyMMdd)
    p_endDate         char, -- 读卡-结束有效期(yyyyMMdd)

    p_ID              char,
    p_cardTradeNo     char,
    p_asn             char,
    p_currOper        char,
    p_currDept        char,
    p_retCode     out char,
    p_retMsg      out varchar2
)
as
    v_char             char(2);
    v_today            date := sysdate;
    v_seq              char(16);
    v_cardaccmoney     int;
    v_assigneddepartid char(4);
    v_assignedstaffno  char(6);
    v_staffname        varchar2(20);
    v_departname       varchar2(40);
    v_isdepabal        int;
    v_dbalunitno       char(8);
    v_usablevalue      int;
    v_deposit          int;
    v_cardnum          int;
    v_cardprice        int;
	v_count			   int;
begin

	-- 检查库存状态是否已经是回收，如果回收提示回收部门和回收员工
	select count(*) into v_count  from tl_r_icuser 
	where  cardno = p_cardno and assigneddepartid is not null and assignedstaffno is not null;
	
	if(v_count = 1) then
		select a.resstatecode,a.assigneddepartid,a.assignedstaffno,b.departname,c.staffname
		into v_char,v_assigneddepartid,v_assignedstaffno,v_departname,v_staffname
		from tl_r_icuser a,td_m_insidedepart b,td_m_insidestaff c
		where a.cardno = p_cardno and a.assigneddepartid = b.departno and a.assignedstaffno = c.staffno;
	else 
		select resstatecode into v_char
		from tl_r_icuser
		where cardno = p_cardNo;
	end if;
	
    if v_char = '04' then
        raise_application_error(-20101, '卡片已经处于回收状态' || ',回收部门:' || v_DEPARTNAME || ',回收员工:' || v_staffname);
    end if;
	--只有售出的卡才能回收
	if v_char != '06' then
        raise_application_error(-20102, '不是售出状态的卡不能回收' );
    end if;

	--验证卡片账户余额和卡内余额是否相等  add by 殷华荣
	select cardaccmoney into v_cardaccmoney from tf_f_cardewalletacc where cardno = p_cardNo;
	if v_cardaccmoney - p_wallet1 - p_wallet2 <> 0 then
	raise_application_error(-20103, '账户不平或回收间隔时间未到');
	end if;
	
	update tl_r_icuser
    set resstatecode = '04',
    reclaimtime  = v_today,
    UPDATESTAFFNO = p_currOper,
    UPDATETIME = v_today,
    ASSIGNEDDEPARTID = p_currDept,  --更改卡片归属部门
    ASSIGNEDSTAFFNO = p_currOper    --更改卡片归属员工
    where  CARDNO = p_cardNo;

    --修改卡资料表信息, 不判断是否有效更新一行，因为可能新卡被回收
    update TF_F_CARDREC
    set CARDSTATE = '30',
    UPDATESTAFFNO = p_currOper,
    UPDATETIME = v_today
    where CARDNO = p_cardNo;

    -- 记录一条礼金卡回收台帐
    SP_GetSeq(seq => v_seq);
    insert into TF_B_TRADE_CASHGIFT
        (TRADEID, CARDNO, ID, TRADETYPECODE, ASN, wallet1, wallet2,
        cardstartdate, cardenddate, dbstartdate, dbenddate, delayenddate,
        OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME,ISNEWTAG)
    values(v_seq, p_cardNo, p_ID, '52', p_asn, p_wallet1, p_wallet2,
        p_startDate, p_endDate, null, null, null,
        p_currOper, p_currDept, v_today,'1');
	
	--回收转收入，add by liuhe20131227
	if p_wallet2<>0 or p_wallet1<>0 then
		insert into tf_b_lijinincome
		values ( p_cardNo,p_wallet2,p_wallet1,'02',sysdate,null);
		 
		update tf_f_cardewalletacc  set cardaccmoney = 0  where cardno = p_cardno;

		update tf_f_cardrec set deposit = 0,servicemoney = p_wallet2 where cardno = p_cardno;
	end if;
	 

    p_retCode := '0000000000';
    p_retMsg  := '';
    commit; return;

exception when others then
    p_retcode := sqlcode;
    p_retmsg  := sqlerrm;
    rollback; return;
end;

/
show errors

