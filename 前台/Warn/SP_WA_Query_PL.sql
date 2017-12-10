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

if  p_funcCode = 'QueryWarnCond' then -- 查询告警条件
    open p_cursor for
    select t.CONDCODE 条件编码, t.CONDNAME 条件名称,
           decode(t.CONDRANGE, 0, '0: 全局范围', 1, '1: 个性范围', t.CONDRANGE) 条件范围,
           t.WARNLEVEL 告警级别,
           decode(t.CONDCATE, 0, '0: 帐户类', 1, '1: 清单类', t.CONDCATE) 应用类别,
           c.CODEVALUE || ':' || c.CODENAME 告警类型,
           t.CONDSTR 条件字符串, t.REMARK 备注
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
elsif  p_funcCode = 'WarnTypeDDL' then -- 查询告警类型
    open p_cursor for
    select t.CODENAME, t.CODEVALUE
    from   TD_M_CODING t
    where  t.CODECATE = 'CATE_WARN_TYPE'
    ;
elsif p_funcCode = 'QueryBlackList' then -- 查询黑名单
    open p_cursor for
    select t.CARDNO 卡号, t.CREATETIME 生成时间, c.CODEVALUE || ':' || c.CODENAME 告警类型,
           t.WARNLEVEL 告警级别, t.DOWNTIME 下载时间, t.REMARK 备注,
           t.UPDATESTAFFNO || ':' || s.STAFFNAME 更新员工, t.UPDATETIME 更新时间
    from   TF_B_WARN_BLACK t, TD_M_INSIDESTAFF s, TD_M_CODING c
    where  t.UPDATESTAFFNO = s.STAFFNO(+)
    and    t.WARNTYPE = c.CODEVALUE
    and    c.CODECATE = 'CATE_WARN_TYPE'
	and     t.BLACKTYPE is null
    and    (p_var1 is null or p_var1 = t.CARDNO)
    ;
elsif p_funcCode = 'QueryLossBlackList' then -- 查询挂失黑名单
    open p_cursor for
    select t.CARDNO 卡号, t.CREATETIME 生成时间, c.CODEVALUE || ':' || c.CODENAME 告警类型,
           t.WARNLEVEL 告警级别, t.DOWNTIME 下载时间, t.REMARK 备注,decode(t.BLACKSTATE, 0, '0:黑名单', 1, '1:已锁定卡',2, '2:正常卡', t.BLACKSTATE) 黑名单状态,
           t.UPDATESTAFFNO || ':' || s.STAFFNAME 更新员工, t.UPDATETIME 更新时间
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

elsif p_funcCode = 'QueryMonitorList' then -- 查询监控名单
    open p_cursor for
    select t.SEQNO "#", t.CARDNO 卡号, w.CONDCODE || ':' || w.CONDNAME 告警条件,
           c.CODEVALUE || ':' || c.CODENAME 告警类型,
           t.WARNLEVEL 告警级别, t.CREATETIME 生成时间, t.REMARK 备注,
           t.UPDATESTAFFNO || ':' || s.STAFFNAME 更新员工, t.UPDATETIME 更新时间
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
    select t.TASKDAY 日期, decode(t.TASKSTATE, 0, '新生成', 1, '运行中', 2, '已完成', t.TASKSTATE) 状态,
    t.STARTTIME 开始时间, t.ENDTIME 结束时间, t.CARDSCNT 卡数量,
    t.TRADESTARTTIME 清单开始, t.TRADEENDTIME 清单结束, t.TRADEWARNSCNT 清单告警单,
    t.TRADERETCODE 清单返回码, t.TRADERETMSG 清单返回消息,
    t.ACCSTARTTIME 账户开始, t.ACCENDTIME 账户结束, t.ACCWARNSCNT 账户告警单,
    t.ACCRETCODE 账户返回码, t.ACCRETMSG 账户返回消息
    from  TF_B_WARN_TASK t
    where (p_var1 is null or t.TASKDAY >= p_var1)
    and   (p_var2 is null or t.TASKDAY <= p_var2)
    order by t.TASKDAY desc
    ;

elsif p_funcCode = 'QueryWarnTable' then -- 查询告警单
    open p_cursor for
    select W.CARDNO,
           NVL2(W.CONDCODE, W.CONDCODE || ':' || C.CONDNAME, '') AS CONDNAME,
           W.INITIALTIME, W.LASTTIME,
           W.DETAILS, W.WARNTYPE || ':' || D.CODENAME AS WARNTYPE, W.WARNLEVEL,
           decode(W.WARNSRC, '0', '0:全局条件', '1', '1:黑名单', '2', '2:监控名单', W.WARNSRC) AS WARNSRC,
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

elsif p_funcCode = 'QueryWarnDetail' then -- 查询告警详单
    open p_cursor for
    select W.ID,  NVL2(W.CONDCODE, W.CONDCODE || ':' || C.CONDNAME, '') AS CONDNAME,
           W.LASTTIME, W.WARNTYPE || ':' || D.CODENAME AS WARNTYPE, W.WARNLEVEL,
           decode(W.WARNSRC, '0', '0:全局条件', '1', '1:黑名单', '2', '2:监控名单', W.WARNSRC) AS WARNSRC,
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
	WHERE  A.BLACKTYPE = '3'   ---3为轻轨黑名单
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

--反洗钱
  elsif p_funcCode='AntiSubjectQuery' then--主体查询
  open p_cursor for
  select * from TF_B_WARN_ANTI a
  where (P_VAR1 IS NULL OR P_VAR1 ='' OR P_VAR1 = a.CONDCODE)
  AND (P_VAR2 IS NULL OR P_VAR2 ='' OR P_VAR2 = a.RISKGRADE)
  AND (P_VAR3 IS NULL OR P_VAR3 ='' OR P_VAR3 = a.SUBJECTTYPE)
  AND (P_VAR4 IS NULL OR P_VAR4 ='' OR P_VAR4 = a.LIMITTYPE)
  AND LASTTIME BETWEEN to_date(P_VAR5,'yyyyMMdd') and to_date(P_VAR6,'yyyyMMdd')+1
  ORDER BY NAME;
  
 elsif p_funcCode='AntiSubjectTradeQuery' then--主体交易查询
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
   
   elsif p_funcCode='AntiSubjectTradeQueryTMP' then--主体交易查询 根据临时表查询
	open p_cursor for
   select * from TF_B_WARN_DETAIL_ANTI t
   WHERE  t.SUBJECTID in (select b.f0 from TMP_COMMON_ANTI1 b)
   ORDER BY t.NAME;
   
elsif p_funcCode='AntiSubjectQueryXML' then--主体交易查询-导出报文
 open p_cursor for
   select * from TF_B_WARN_ANTI t,TMP_COMMON_ANTI1 b
   WHERE  t.id=b.f0
   ORDER BY NAME; 
elsif p_funcCode='AntiSubjectTradeQueryXML' then--主体交易查询-导出报文
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
	
elsif  p_funcCode = 'QueryWarnCondANTI' then -- 查询告警条件
    open p_cursor for
    select t.CONDCODE 条件编码, t.CONDNAME 条件名称,
           decode(t.RISKGRADE, '01', '01: 低风险', '02', '02: 中风险','03','03：高风险', t.RISKGRADE) 风险等级,
		   decode(t.SUBJECTTYPE, '01', '01: 客户', '02', '02: 卡账户','03','03:商户','04','04:商户终端','05','05:商户和卡账户', t.SUBJECTTYPE) 主体类型,
		   decode(t.LIMITTYPE, '01', '01: 大额', '02', '02: 可疑', t.LIMITTYPE) 额度分类,
		   decode(t.USETAG, '1', '1: 有效', '0', '0: 无效', t.USETAG) 有效标识,
		   t.REMARK 备注,t.CONDCONTENT 内容,
		   decode(t.condcate, '01', '01: 消费清单表', '02', '02: 充值清单表','03','03: 订单表',t.condcate) 应用类型,
		   decode(t.datetype, '01', '01: 按日', '02', '02: 按月', t.datetype) 日期类型,
		   t.condWhere "WHERE语句"
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
	
elsif  p_funcCode = 'ANTIWarnTypeDDL' then -- 查询告警类型
    open p_cursor for
    select t.CODENAME, t.CODEVALUE
    from   TD_M_CODING t
    where  t.CODECATE = p_var1
    ;
elsif p_funcCode = 'QueryWarnCustomer' then --恐怖人员维护
	open p_cursor for
	select a.CUSTNAME,a.PAPERTYPECODE,b.PAPERTYPENAME,a.PAPERNO,decode(a.CUSTSEX,'0','男','1','女','') CUSTSEX,a.CUSTBIRTH 
	from TF_F_WARNCUSTOMER a,TD_M_PAPERTYPE b
	where a.PAPERTYPECODE = b.PAPERTYPECODE(+)
	and (p_var1 is null or p_var1 = '' or p_var1 = a.CUSTNAME)
	and (p_var2 is null or p_var2 = '' or p_var2 = a.PAPERTYPECODE)
	and (p_var3 is null or p_var3 = '' or p_var3 = a.PAPERNO)
	;
--反洗钱
elsif p_funcCode='BHAntiSubjectQuery' then--关闭交易主体查询
  open p_cursor for
  select * from TH_B_WARN_ANTI a
  where (P_VAR1 IS NULL OR P_VAR1 ='' OR P_VAR1 = a.CONDCODE)
  AND (P_VAR2 IS NULL OR P_VAR2 ='' OR P_VAR2 = a.RISKGRADE)
  AND (P_VAR3 IS NULL OR P_VAR3 ='' OR P_VAR3 = a.SUBJECTTYPE)
  AND (P_VAR4 IS NULL OR P_VAR4 ='' OR P_VAR4 = a.LIMITTYPE)
  AND LASTTIME BETWEEN to_date(P_VAR5,'yyyyMMdd') and to_date(P_VAR6,'yyyyMMdd')+1
  ORDER BY NAME;
elsif p_funcCode='BHAntiSubjectTradeQueryTMP' then--关闭交易主体查询 根据临时表查询
	open p_cursor for
   select * from TH_B_WARN_DETAIL_ANTI t
   WHERE  t.SUBJECTID in (select b.f0 from TMP_COMMON_ANTI1 b)
   ORDER BY t.NAME;
elsif p_funcCode='BHAntiSubjectQueryXML' then--关闭交易主体查询-导出报文
 open p_cursor for
   select * from TH_B_WARN_ANTI t,TMP_COMMON_ANTI1 b
   WHERE  t.id=b.f0
   ORDER BY NAME;
elsif p_funcCode='BHAntiSubjectTradeQueryXML' then--关闭交易主体查询-导出报文
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
	WHERE  A.GRAYTYPE = '0'   ---0为轻轨灰名单
	AND A.UPDATESTAFFNO = B.STAFFNO
	AND (P_VAR1 IS NULL OR P_VAR1 = A.CARDNO)
	AND (P_VAR2 IS NULL OR A.CREATETIME >= TO_DATE(P_VAR2||'000000','YYYYMMDDHH24MISS'))
	AND (P_VAR2 IS NULL OR A.CREATETIME <= TO_DATE(P_VAR3||'235959','YYYYMMDDHH24MISS'))
	ORDER BY A.CREATETIME DESC,A.CARDNO;
end if;


end;
/
show errors