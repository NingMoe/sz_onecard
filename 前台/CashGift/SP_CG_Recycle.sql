/******************************************************/
-- Author  : 
-- Created : 
-- UpdatedAuthor : wdx
-- Updated : 2012-2-10 11:01
-- Content : ��������Ŀ��������Ի��գ�����ֻ���۳��Ŀ����ܻ���
-- Purpose : ��𿨻���
/******************************************************/
create or replace procedure SP_CG_Recycle
(
    p_cardNo          char, -- ����-����-16λ����
    p_wallet1         int , -- ����-����Ǯ�����1
    p_wallet2         int , -- ����-����Ǯ�����2
    p_startDate       char, -- ����-��ʼ��Ч��(yyyyMMdd)
    p_endDate         char, -- ����-������Ч��(yyyyMMdd)

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

	-- �����״̬�Ƿ��Ѿ��ǻ��գ����������ʾ���ղ��źͻ���Ա��
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
        raise_application_error(-20101, '��Ƭ�Ѿ����ڻ���״̬' || ',���ղ���:' || v_DEPARTNAME || ',����Ա��:' || v_staffname);
    end if;
	--ֻ���۳��Ŀ����ܻ���
	if v_char != '06' then
        raise_application_error(-20102, '�����۳�״̬�Ŀ����ܻ���' );
    end if;

	--��֤��Ƭ�˻����Ϳ�������Ƿ����  add by ����
	select cardaccmoney into v_cardaccmoney from tf_f_cardewalletacc where cardno = p_cardNo;
	if v_cardaccmoney - p_wallet1 - p_wallet2 <> 0 then
	raise_application_error(-20103, '�˻���ƽ����ռ��ʱ��δ��');
	end if;
	
	update tl_r_icuser
    set resstatecode = '04',
    reclaimtime  = v_today,
    UPDATESTAFFNO = p_currOper,
    UPDATETIME = v_today,
    ASSIGNEDDEPARTID = p_currDept,  --���Ŀ�Ƭ��������
    ASSIGNEDSTAFFNO = p_currOper    --���Ŀ�Ƭ����Ա��
    where  CARDNO = p_cardNo;

    --�޸Ŀ����ϱ���Ϣ, ���ж��Ƿ���Ч����һ�У���Ϊ�����¿�������
    update TF_F_CARDREC
    set CARDSTATE = '30',
    UPDATESTAFFNO = p_currOper,
    UPDATETIME = v_today
    where CARDNO = p_cardNo;

    -- ��¼һ����𿨻���̨��
    SP_GetSeq(seq => v_seq);
    insert into TF_B_TRADE_CASHGIFT
        (TRADEID, CARDNO, ID, TRADETYPECODE, ASN, wallet1, wallet2,
        cardstartdate, cardenddate, dbstartdate, dbenddate, delayenddate,
        OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME,ISNEWTAG)
    values(v_seq, p_cardNo, p_ID, '52', p_asn, p_wallet1, p_wallet2,
        p_startDate, p_endDate, null, null, null,
        p_currOper, p_currDept, v_today,'1');
	
	--����ת���룬add by liuhe20131227
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

