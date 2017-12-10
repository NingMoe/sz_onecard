create or replace procedure SP_WA_Query
(
    p_funcCode    varchar2,
    p_var1        varchar2,
    p_var2        varchar2,
    p_var3        varchar2,
    p_var4        varchar2,
    p_var5        varchar2,
    p_var6        varchar2,
    p_var7        varchar2,
    p_var8 in out varchar2,
    p_var9 in out varchar2,
    p_cursor  out SYS_REFCURSOR
)
as

begin

if  p_funcCode = 'QueryWarnCond' then -- ��ѯ�澯����
    open p_cursor for
    select t.CONDCODE ��������, t.CONDNAME ��������,
           decode(t.CONDRANGE, 0, '0: ȫ�ַ�Χ', 1, '1: ���Է�Χ', t.CONDRANGE) ������Χ,
           t.WARNLEVEL �澯����,
           decode(t.CONDCATE, 0, '0: �ʻ���', 1, '1: �嵥��', t.CONDCATE) Ӧ�����,
           c.CODEVALUE || ':' || c.CODENAME �澯����,
           t.CONDSTR �����ַ���, t.REMARK ��ע
    from   TD_M_WARNCOND t, TD_M_CODING c
    where  t.WARNTYPE = c.CODEVALUE
    and    c.CODECATE = 'CATE_WARN_TYPE'
    and    (p_var1 is null or p_var1 = t.CONDCODE)
    and    (p_var2 is null or t.CONDNAME like '%' || p_var2 || '%')
    and    (p_var3 is null or p_var3 = t.CONDRANGE)
    and    (p_var4 is null or p_var4 = t.WARNLEVEL)
    and    (p_var5 is null or p_var5 = t.CONDCATE )
    ;
elsif  p_funcCode = 'WarnCondDDL' then
    open p_cursor for
    select t.CONDNAME, t.CONDCODE
    from   TD_M_WARNCOND t
    where (p_var1 is null or p_var1 = CONDRANGE)
    ;
elsif  p_funcCode = 'WarnTypeDDL' then -- ��ѯ�澯����
    open p_cursor for
    select t.CODENAME, t.CODEVALUE
    from   TD_M_CODING t
    where  t.CODECATE = 'CATE_WARN_TYPE'
    ;
elsif p_funcCode = 'QueryBlackList' then -- ��ѯ������
    open p_cursor for
    select t.CARDNO ����, t.CREATETIME ����ʱ��, c.CODEVALUE || ':' || c.CODENAME �澯����,
           t.WARNLEVEL �澯����, t.DOWNTIME ����ʱ��, t.REMARK ��ע,
           t.UPDATESTAFFNO || ':' || s.STAFFNAME ����Ա��, t.UPDATETIME ����ʱ��
    from   TF_B_WARN_BLACK t, TD_M_INSIDESTAFF s, TD_M_CODING c
    where  t.UPDATESTAFFNO = s.STAFFNO(+)
    and    t.WARNTYPE = c.CODEVALUE
    and    c.CODECATE = 'CATE_WARN_TYPE'
	and     t.BLACKTYPE is null
    and    (p_var1 is null or p_var1 = t.CARDNO)
    ;
elsif p_funcCode = 'QueryLossBlackList' then -- ��ѯ��ʧ������
    open p_cursor for
    select t.CARDNO ����, t.CREATETIME ����ʱ��, c.CODEVALUE || ':' || c.CODENAME �澯����,
           t.WARNLEVEL �澯����, t.DOWNTIME ����ʱ��, t.REMARK ��ע,decode(t.BLACKSTATE, 0, '0:������', 1, '1:��������',2, '2:������', t.BLACKSTATE) ������״̬,
           t.UPDATESTAFFNO || ':' || s.STAFFNAME ����Ա��, t.UPDATETIME ����ʱ��
    from   TF_B_LOSS_BLACK t, TD_M_INSIDESTAFF s, TD_M_CODING c
    where  t.UPDATESTAFFNO = s.STAFFNO(+)
    and    t.WARNTYPE = c.CODEVALUE
    and    c.CODECATE = 'CATE_WARN_TYPE'
	--and     t.BLACKTYPE is null
    and    (p_var1 is null or p_var1 = t.CARDNO)
    ;	
elsif p_funcCode = 'UpdateDownloadTime' then
    update TF_B_WARN_BLACK t
    set    t.DOWNTIME = sysdate
    where  (p_var1 is null or p_var1 = t.CARDNO);
    open p_cursor for select 1 from dual;

elsif p_funcCode = 'QueryMonitorList' then -- ��ѯ�������
    open p_cursor for
    select t.SEQNO "#", t.CARDNO ����, w.CONDCODE || ':' || w.CONDNAME �澯����,
           c.CODEVALUE || ':' || c.CODENAME �澯����,
           t.WARNLEVEL �澯����, t.CREATETIME ����ʱ��, t.REMARK ��ע,
           t.UPDATESTAFFNO || ':' || s.STAFFNAME ����Ա��, t.UPDATETIME ����ʱ��
    from   TF_B_WARN_MONITOR t, TD_M_WARNCOND w, TD_M_INSIDESTAFF s, TD_M_CODING c
    where  t.UPDATESTAFFNO = s.STAFFNO(+)
    and    t.WARNTYPE = c.CODEVALUE
    and    c.CODECATE = 'CATE_WARN_TYPE'
    and    t.CONDCODE  = w.CONDCODE(+)
    and    (p_var1 is null or p_var1 = t.CARDNO)
    and    (p_var2 is null or p_var2 = w.CONDCODE)
    and    (p_var3 is null or p_var3 = c.CODEVALUE)
    ;
elsif p_funcCode = 'QueryWarnTasks' then
    open p_cursor for
    select t.TASKDAY ����, decode(t.TASKSTATE, 0, '������', 1, '������', 2, '�����', t.TASKSTATE) ״̬,
    t.STARTTIME ��ʼʱ��, t.ENDTIME ����ʱ��, t.CARDSCNT ������,
    t.TRADESTARTTIME �嵥��ʼ, t.TRADEENDTIME �嵥����, t.TRADEWARNSCNT �嵥�澯��,
    t.TRADERETCODE �嵥������, t.TRADERETMSG �嵥������Ϣ,
    t.ACCSTARTTIME �˻���ʼ, t.ACCENDTIME �˻�����, t.ACCWARNSCNT �˻��澯��,
    t.ACCRETCODE �˻�������, t.ACCRETMSG �˻�������Ϣ
    from  TF_B_WARN_TASK t
    where (p_var1 is null or t.TASKDAY >= p_var1)
    and   (p_var2 is null or t.TASKDAY <= p_var2)
    order by t.TASKDAY desc
    ;

elsif p_funcCode = 'QueryWarnTable' then -- ��ѯ�澯��
    open p_cursor for
    select W.CARDNO,
           NVL2(W.CONDCODE, W.CONDCODE || ':' || C.CONDNAME, '') AS CONDNAME,
           W.INITIALTIME, W.LASTTIME,
           W.DETAILS, W.WARNTYPE || ':' || D.CODENAME AS WARNTYPE, W.WARNLEVEL,
           decode(W.WARNSRC, '0', '0:ȫ������', '1', '1:������', '2', '2:�������', W.WARNSRC) AS WARNSRC,
           W.PREMONEY/100.0 AS PREMONEY, W.TRADEMONEY/100.0 AS TRADEMONEY, W.ACCBALANCE/100.0 AS ACCBALANCE,
           W.REMARK
    from   TF_B_WARN W, TD_M_WARNCOND C, TD_M_CODING D
    where  W.CONDCODE = C.CONDCODE(+)
    and    (W.WARNTYPE = D.CODEVALUE and D.CODECATE = 'CATE_WARN_TYPE')
    and    (p_var1 is null or p_var1 = W.CARDNO)
    and    (p_var2 is null or p_var2 = W.CONDCODE)
    and    (p_var3 is null or p_var3 = W.WARNTYPE)
    and    (p_var4 is null or p_var4 = W.WARNSRC)
    and    (p_var5 is null or to_number(p_var5)<= W.WARNLEVEL)
    and    (p_var6 is null or to_number(p_var6)<= W.DETAILS)
    and    (p_var7 is null or to_number(p_var7)<= (sysdate - W.INITIALTIME)*24 )
    order by W.LASTTIME desc
    ;

elsif p_funcCode = 'QueryWarnDetail' then -- ��ѯ�澯�굥
    open p_cursor for
    select W.ID,  NVL2(W.CONDCODE, W.CONDCODE || ':' || C.CONDNAME, '') AS CONDNAME,
           W.LASTTIME, W.WARNTYPE || ':' || D.CODENAME AS WARNTYPE, W.WARNLEVEL,
           decode(W.WARNSRC, '0', '0:ȫ������', '1', '1:������', '2', '2:�������', W.WARNSRC) AS WARNSRC,
           W.PREMONEY/100.0 PREMONEY, W.TRADEMONEY/100.0 TRADEMONEY, W.ACCBALANCE/100.0 ACCBALANCE, W.REMARK
    from   TF_B_WARN_DETAIL W, TD_M_WARNCOND C, TD_M_CODING D
    where W.CONDCODE = C.CONDCODE(+)
    and   (W.WARNTYPE = D.CODEVALUE and D.CODECATE = 'CATE_WARN_TYPE')
    and   CARDNO = p_var1
    order by W.LASTTIME DESC;

elsif p_funcCode = 'QueryLRTBlackList' then
	OPEN P_CURSOR FOR
    SELECT A.CARDNO , A.REMARK , A.OVERTIMEMONEY/100.0 OVERTIMEMONEY , A.CREATETIME , B.STAFFNAME, C.LISTTYPENAME,  A.LISTTYPECODE
	FROM   TF_B_WARN_BLACK A, TD_M_INSIDESTAFF B, TD_M_BLACKLISTTYPE C
	WHERE  A.BLACKTYPE = '3'   ---3Ϊ��������
		   AND A.UPDATESTAFFNO = B.STAFFNO
       AND A.LISTTYPECODE=C.LISTTYPECODE(+)
		   AND (P_VAR1 IS NULL OR P_VAR1 = A.CARDNO)
       AND (P_VAR4 IS NULL OR P_VAR4 = A.Listtypecode)
		   AND (P_VAR2 IS NULL OR A.CREATETIME >= TO_DATE(P_VAR2||'000000','YYYYMMDDHH24MISS'))
       AND (P_VAR2 IS NULL OR A.CREATETIME <= TO_DATE(P_VAR3||'235959','YYYYMMDDHH24MISS'))
	ORDER BY A.CREATETIME DESC;

elsif p_funcCode = 'isCardInMonitorTab' then
    select count(1) into p_var8 from tf_b_warn_monitor where cardno = p_var1;
    open p_cursor for select 1 from dual;
elsif p_funcCode = 'isCardInBlackTab' then
    select count(1) into p_var8 from tf_b_warn_black where cardno = p_var1;
    open p_cursor for select 1 from dual;

--��ϴǮ
  elsif p_funcCode='AntiSubjectQuery' then--�����ѯ
  open p_cursor for
  select * from TF_B_WARN_ANTI a
  where (P_VAR1 IS NULL OR P_VAR1 ='' OR P_VAR1 = a.CONDCODE)
  AND (P_VAR2 IS NULL OR P_VAR2 ='' OR P_VAR2 = a.RISKGRADE)
  AND (P_VAR3 IS NULL OR P_VAR3 ='' OR P_VAR3 = a.SUBJECTTYPE)
  AND (P_VAR4 IS NULL OR P_VAR4 ='' OR P_VAR4 = a.LIMITTYPE)
  AND LASTTIME BETWEEN to_date(P_VAR5,'yyyyMMdd') and to_date(P_VAR6,'yyyyMMdd')+1
  ORDER BY NAME;
  
 elsif p_funcCode='AntiSubjectTradeQuery' then--���彻�ײ�ѯ
 open p_cursor for
   select * from TF_B_WARN_DETAIL_ANTI t,TMP_COMMON_ANTI2 b
   WHERE  t.id=b.f0(+)
   and SUBJECTID IN (
	  select ID from TF_B_WARN_ANTI a
	  where (P_VAR1 IS NULL OR P_VAR1 ='' OR P_VAR1 = a.CONDCODE)
	  AND (P_VAR2 IS NULL OR P_VAR2 ='' OR P_VAR2 = a.RISKGRADE)
	  AND (P_VAR3 IS NULL OR P_VAR3 ='' OR P_VAR3 = a.SUBJECTTYPE)
	  AND (P_VAR4 IS NULL OR P_VAR4 ='' OR P_VAR4 = a.LIMITTYPE)
	  AND LASTTIME BETWEEN to_date(P_VAR5,'yyyyMMdd') and to_date(P_VAR6,'yyyyMMdd')+1
   )
   ORDER BY NAME;
   
   elsif p_funcCode='AntiSubjectTradeQueryTMP' then--���彻�ײ�ѯ ������ʱ���ѯ
	open p_cursor for
   select * from TF_B_WARN_DETAIL_ANTI t
   WHERE  t.SUBJECTID in (select b.f0 from TMP_COMMON_ANTI1 b)
   ORDER BY t.NAME;
   
elsif p_funcCode='AntiSubjectQueryXML' then--���彻�ײ�ѯ-��������
 open p_cursor for
   select * from TF_B_WARN_ANTI t,TMP_COMMON_ANTI1 b
   WHERE  t.id=b.f0
   ORDER BY NAME; 
elsif p_funcCode='AntiSubjectTradeQueryXML' then--���彻�ײ�ѯ-��������
 open p_cursor for
   select * from TF_B_WARN_DETAIL_ANTI t,TMP_COMMON_ANTI2 b
   WHERE  t.id=b.f0
   ORDER BY NAME;  
elsif  p_funcCode = 'WarnCondANTIDDL' then
    open p_cursor for
    select t.CONDNAME, t.CONDCODE
    from   TD_M_WARNCOND_ANTI t
    where USETAG='1'
	order by t.CONDCODE asc;
	
elsif  p_funcCode = 'QueryWarnCondANTI' then -- ��ѯ�澯����
    open p_cursor for
    select t.CONDCODE ��������, t.CONDNAME ��������,
           decode(t.RISKGRADE, '01', '01: �ͷ���', '02', '02: �з���','03','03���߷���', t.RISKGRADE) ���յȼ�,
		   decode(t.SUBJECTTYPE, '01', '01: �ͻ�', '02', '02: ���˻�','03','03:�̻�','04','04:�̻��ն�','05','05:�̻��Ϳ��˻�', t.SUBJECTTYPE) ��������,
		   decode(t.LIMITTYPE, '01', '01: ���', '02', '02: ����', t.LIMITTYPE) ��ȷ���,
		   decode(t.USETAG, '1', '1: ��Ч', '0', '0: ��Ч', t.USETAG) ��Ч��ʶ,
		   t.REMARK ��ע,t.CONDCONTENT ����,
		   decode(t.condcate, '01', '01: �����嵥��', '02', '02: ��ֵ�嵥��','03','03: ������',t.condcate) Ӧ������,
		   decode(t.datetype, '01', '01: ����', '02', '02: ����', t.datetype) ��������,
		   t.condWhere "WHERE���"
    from   TD_M_WARNCOND_ANTI t,TD_M_CODING b
    where  t.SUBJECTTYPE=b.CODEVALUE
	and b.CODECATE='SUBJECT_TYPE'
	and (p_var1 is null or p_var1 = t.CONDCODE)
    and    (p_var2 is null or t.CONDNAME like '%' || p_var2 || '%')
    and    (p_var3 is null or p_var3 = t.RISKGRADE)
    and    (p_var4 is null or p_var4 = t.SUBJECTTYPE)
    and    (p_var5 is null or p_var5 = t.LIMITTYPE )
	order by t.CONDCODE asc
    ;
	
elsif  p_funcCode = 'ANTIWarnTypeDDL' then -- ��ѯ�澯����
    open p_cursor for
    select t.CODENAME, t.CODEVALUE
    from   TD_M_CODING t
    where  t.CODECATE = p_var1
    ;
elsif p_funcCode = 'QueryWarnCustomer' then --�ֲ���Աά��
	open p_cursor for
	select a.CUSTNAME,a.PAPERTYPECODE,b.PAPERTYPENAME,a.PAPERNO,decode(a.CUSTSEX,'0','��','1','Ů','') CUSTSEX,a.CUSTBIRTH 
	from TF_F_WARNCUSTOMER a,TD_M_PAPERTYPE b
	where a.PAPERTYPECODE = b.PAPERTYPECODE(+)
	and (p_var1 is null or p_var1 = '' or p_var1 = a.CUSTNAME)
	and (p_var2 is null or p_var2 = '' or p_var2 = a.PAPERTYPECODE)
	and (p_var3 is null or p_var3 = '' or p_var3 = a.PAPERNO)
	;
--��ϴǮ
elsif p_funcCode='BHAntiSubjectQuery' then--�رս��������ѯ
  open p_cursor for
  select * from TH_B_WARN_ANTI a
  where (P_VAR1 IS NULL OR P_VAR1 ='' OR P_VAR1 = a.CONDCODE)
  AND (P_VAR2 IS NULL OR P_VAR2 ='' OR P_VAR2 = a.RISKGRADE)
  AND (P_VAR3 IS NULL OR P_VAR3 ='' OR P_VAR3 = a.SUBJECTTYPE)
  AND (P_VAR4 IS NULL OR P_VAR4 ='' OR P_VAR4 = a.LIMITTYPE)
  AND LASTTIME BETWEEN to_date(P_VAR5,'yyyyMMdd') and to_date(P_VAR6,'yyyyMMdd')+1
  ORDER BY NAME;
elsif p_funcCode='BHAntiSubjectTradeQueryTMP' then--�رս��������ѯ ������ʱ���ѯ
	open p_cursor for
   select * from TH_B_WARN_DETAIL_ANTI t
   WHERE  t.SUBJECTID in (select b.f0 from TMP_COMMON_ANTI1 b)
   ORDER BY t.NAME;
elsif p_funcCode='BHAntiSubjectQueryXML' then--�رս��������ѯ-��������
 open p_cursor for
   select * from TH_B_WARN_ANTI t,TMP_COMMON_ANTI1 b
   WHERE  t.id=b.f0
   ORDER BY NAME;
elsif p_funcCode='BHAntiSubjectTradeQueryXML' then--�رս��������ѯ-��������
 open p_cursor for
   select * from TH_B_WARN_DETAIL_ANTI t,TMP_COMMON_ANTI2 b
   WHERE  t.id=b.f0
   ORDER BY NAME;
elsif p_funcCode = 'isCardInGrayTab' then
    select count(1) into p_var8 from TF_B_WARN_GRAY where cardno = p_var1;
    open p_cursor for select 1 from dual;
elsif p_funcCode = 'QueryGrayList' then
	OPEN P_CURSOR FOR
    SELECT A.CARDNO , A.REMARK , A.CREATETIME , B.STAFFNAME
	FROM   TF_B_WARN_GRAY A, TD_M_INSIDESTAFF B
	WHERE  A.GRAYTYPE = '0'   ---0Ϊ��������
	AND A.UPDATESTAFFNO = B.STAFFNO
	AND (P_VAR1 IS NULL OR P_VAR1 = A.CARDNO)
	AND (P_VAR2 IS NULL OR A.CREATETIME >= TO_DATE(P_VAR2||'000000','YYYYMMDDHH24MISS'))
	AND (P_VAR2 IS NULL OR A.CREATETIME <= TO_DATE(P_VAR3||'235959','YYYYMMDDHH24MISS'))
	ORDER BY A.CREATETIME DESC,A.CARDNO;
end if;


end;
/
show errors