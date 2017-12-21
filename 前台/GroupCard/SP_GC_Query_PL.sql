create or replace procedure SP_GC_Query
(
    p_funcCode   varchar2,
    p_var1       varchar2,
    p_var2       varchar2,
    p_var3       varchar2,
    p_var4       varchar2,
    p_var5       varchar2,
    p_var6       varchar2,
    p_var7       varchar2,
    p_var8       varchar2,
    p_var9       varchar2,
    p_cursor out SYS_REFCURSOR
)
as
    v_int        int;
    v_f0         varchar2(256);
    v_funcList   varchar2(1024);
begin

if p_funcCode = 'OpenItems' then
    open p_cursor for
    select f1 CardNo, f2 CustName, f3 CustSex, f4 CustBirth,
           f5 PaperType, f6 PaperNo, f7 CustAddr, f8 CustPost, f9 CustPhone, f10 CustEmail
    from   TMP_COMMON;

elsif p_funcCode = 'BadItems' then
    open p_cursor for
    select count(1)
    from   TMP_COMMON
    where  f0 <> 'OK';

elsif p_funcCode = 'Fee2DepositCheckSaleDay' then
    open p_cursor for
    select distinct to_char(t.selltime, 'yyyymmdd')
    from tf_f_cardrec t
    where t.cardno between p_var1 and p_var2
    and rownum <= 2;

elsif p_funcCode = 'Fee2DepositCheckCardCost' then
    open p_cursor for
    select 1
    from tf_f_cardrec t
    where t.cardno between p_var1 and p_var2
    and  t.cardcost = 0;

elsif p_funcCode = 'Fee2DepositQuery' then
    delete from tmp_common;
    insert into tmp_common(f1, f2, f3, f4, f5)
    select cardno, to_char(selltime, 'yyyy-mm-dd'), cardcost, deposit, servicemoney
    from  tf_f_cardrec
    where cardno between p_var1 and p_var2;

    for v_c1 in (select f1 from tmp_common)
    loop
        v_funcList := null;
        for v_c2 in (select to_char(u.updatetime, 'yyyy-mm-dd:')
                || nvl(f.functionname, u.functiontype) func
            from tf_f_cardusearea u, td_m_function f
            where u.cardno = v_c1.f1
            and   u.usetag = '1'
            and   (u.endtime is null or u.endtime >= to_char(sysdate, 'YYYYMMDD'))
            and   u.functiontype = f.functiontype(+))

        loop
            if (v_funcList is null) then v_funcList := v_c2.func;
            else v_funcList := v_funcList || ',' || v_c2.func;
            end if;
        end loop;
        update tmp_common set f6 = v_funcList where f1 = v_c1.f1;
    end loop;

    open p_cursor for
    select to_char(rownum) "#", f1 卡号, f2 售卡日期,
        to_number(f3)/100.0 卡费, to_number(f4)/100.0 卡押金, to_number(f5)/100.0 实收服务费,
        f6 开通功能
    from tmp_common;


elsif p_funcCode = 'ChargeItems' then
    open p_cursor for
    select CardNo, ChargeAmount/100.0 ChargeAmount
    from   TMP_GC_BatchChargeFile
    where  SessionId = p_var1;


elsif p_funcCode = 'TD_GROUP_CUSTOMER' then
    open p_cursor for
    SELECT CORPNAME, CORPCODE
    FROM TD_GROUP_CUSTOMER WHERE USETAG = '1'
    ORDER BY CORPCODE;

elsif p_funcCode = 'OpenBatchNo' then
    open p_cursor for
    SELECT ID, ID || '-' || NVL(OLDFLAG,'0')
    FROM   TF_GROUP_SELLSUM
    WHERE  STATECODE = '0';

elsif p_funcCode = 'OpenCorpName' then
    open p_cursor for
    SELECT g.CORPNAME
    FROM   TD_GROUP_CUSTOMER g, TF_GROUP_SELLSUM s
    WHERE  g.CORPCODE = s.CORPNO
    AND    s.ID = p_var1;

elsif p_funcCode = 'OpenAprvOld' then
    open p_cursor for
    SELECT c.CARDNO , c.CUSTNAME, c.PAPERNO,
           0.0 DEPOSIT,
           0.0 CARDFEE,
           0.0 CHARGEAMOUNT
    FROM   TF_B_CUSTOMERCHANGE c
    WHERE  c.TRADEID = p_var1;

elsif p_funcCode = 'OpenAprvNew' then

    open p_cursor for
    SELECT change.cardno, change.custname, change.paperno,
           NVL(tmp.DEPOSIT, 0.0) DEPOSIT, NVL(tmp.CARDFEE, 0.0) CARDFEE, NVL(tmp.CHARGEAMOUNT, 0.0) CHARGEAMOUNT

    FROM TF_B_CUSTOMERCHANGE change,
           (
            SELECT t.CARDNO,
               c.deposit/100.0 DEPOSIT,
               c.cardcost/100.0 CARDFEE,
               a.totalsupplymoney/100.0 CHARGEAMOUNT
            FROM   TF_B_TRADE t,TF_F_CARDREC c,TF_F_CARDEWALLETACC a
            WHERE  a.CARDNO = t.CARDNO
            AND     c.CARDNO = t.CARDNO
            AND    t.TRADEID = p_var1
            ) tmp

    where change.cardno = tmp.cardno(+)
    and   change.TRADEID = p_var1;



elsif p_funcCode = 'OpenFiItems' then
    open p_cursor for
    SELECT t.ID, g.CORPNAME, t.DEPOSITFEE/100.0 DEPOSITFEE,
           t.CARDCOST/100.0    CARDCOST   ,
           t.SUPPLYMONEY/100.0 SUPPLYMONEY,
           t.TOTALMONEY/100.0  TOTALMONEY ,
           t.AMOUNT, t.CHECKTIME, s.STAFFNAME

    FROM   TF_GROUP_SELLSUM t, TD_GROUP_CUSTOMER g, TD_M_INSIDESTAFF s

    WHERE  t.CORPNO       = g.CORPCODE
    AND    t.CHECKSTAFFNO = s.STAFFNO
    AND    t.STATECODE    = '1' ;


elsif p_funcCode = 'QueryCustInfo' then
    open p_cursor for
    SELECT CUSTNAME, CUSTSEX , CUSTBIRTH, PAPERTYPECODE,
           PAPERNO , CUSTADDR, CUSTPOST , CUSTPHONE, CUSTEMAIL
    FROM   TF_F_CUSTOMERREC
    WHERE  CARDNO = p_var1;



elsif p_funcCode = 'CardState' then
    open p_cursor for
    SELECT b.RESSTATE
    FROM   TL_R_ICUSER        a,
           TD_M_RESOURCESTATE b
    WHERE  a.RESSTATECODE    = b.RESSTATECODE
    AND    a.CARDNO          = p_var1;

elsif p_funcCode = 'QueryCardInfo' then
  if(p_var1='01') then --wdx 20111212 查询优化
    open p_cursor for
    SELECT B.CARDNO, B.CUSTNAME, B.PAPERNO, B.CUSTPHONE
    FROM   TF_F_CUSTOMERREC B
    WHERE    B.CARDNO    = p_var2;
  elsif(p_var1='02') THEN
    open p_cursor for
    SELECT B.CARDNO, B.CUSTNAME, B.PAPERNO, B.CUSTPHONE
    FROM   TF_F_CUSTOMERREC B
    WHERE    B.PAPERNO   = p_var2;
  elsif(p_var1='03') THEN
    open p_cursor for
    SELECT B.CARDNO, B.CUSTNAME, B.PAPERNO, B.CUSTPHONE
    FROM   TF_F_CUSTOMERREC B
    WHERE    B.CUSTNAME  = p_var2;
  elsif(p_var1='04') THEN
    open p_cursor for
    SELECT B.CARDNO, B.CUSTNAME, B.PAPERNO, B.CUSTPHONE
    FROM   TF_F_CUSTOMERREC B
    WHERE    B.CUSTPHONE = p_var2;
  end if;

elsif p_funcCode = 'RefundCardRecordCheck' then


for v_c in (select f1,f2 from TMP_COMMON)
    loop
        v_f0 := null;
            begin
                -- 2) 检查卡片是否已经售卡
                select 1 into v_int
                from TF_F_CARDREC
                where CARDNO = v_c.f2
                and   CARDSTATE in ('10', '11');
            exception when no_data_found then
                v_f0 := '卡片还未售出';
            end;


        if v_f0 is null then v_f0 := 'OK'; end if;

        update TMP_COMMON t set t. f0 = v_f0 where t.f1 = v_c.f1;
    end loop;
    open p_cursor for
    select f0 ValidRet, f2 CardNo, f3 TradeDate, f4 TradeMoney, f5 BankName,
           f6 BankAcc, f7 CusName, f8 Remark ,decode(f9,'1','对公','2','对私') purPoseType
    from   TMP_COMMON;
elsif p_funcCode = 'QueryOrderCount' then
	open p_cursor for
	SELECT COUNT(1) FROM TF_F_XXOL_ORDERDETAIL T,TF_F_XXOL_ORDER F,TD_M_PAPERTYPE M
	WHERE T.ORDERNO = F.ORDERNO(+)
	AND T.PAPERTYPE = M.PAPERTYPECODE(+)
	AND (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = F.ORDERTYPE)
	AND (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = T.ORDERNO)
	AND (P_VAR3 IS NULL OR P_VAR3 = '' OR T.CREATETIME >= TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS'))
	AND (P_VAR4 IS NULL OR P_VAR4 = '' OR T.CREATETIME <= TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS'))
	AND (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = T.ISREJECT)
	AND (P_VAR6 IS NULL OR P_VAR6 = '' OR P_VAR6 = F.PAYCANAL)
	;
elsif p_funcCode = 'QueryRelaxOrder' then
	open p_cursor for
	SELECT * FROM (
	SELECT ROWNUM SEQINDEX,A.* FROM (
	SELECT T.ORDERDETAILID,T.ORDERNO,T.CARDNO,P.PACKAGETYPENAME PACKAGETYPE,
		T.CUSTNAME,T.PAPERTYPE,T.PAPERNO,T.CUSTPHONE,T.ADDRESS,T.CUSTPOST,DECODE(T.CUSTSEX,'0','男','1','女') CUSTSEX,
		T.CUSTBIRTH,T.CUSTEMAIL,DECODE(F.PAYCANAL,'01','支付宝','02','微信','03','银联') PAYCANAL,
		DECODE(F.ORDERTYPE,'0','新办卡开通','1','有卡开通','2','修改资料') ORDERTYPE,M.PAPERTYPENAME,
		DECODE(T.DETAILSTATES,'0','等待处理','1','制卡完成','2','已发货') DETAILSTATES,
		TO_CHAR(T.CREATETIME,'YYYYMMDD') UPDATETIME,F.CUSTNAME LOGCUSTNAME,F.ADDRESS LOGADDRESS,F.CUSTPHONE LOGCUSTPHONE
	FROM TF_F_XXOL_ORDERDETAIL T,TF_F_XXOL_ORDER F,TD_M_PAPERTYPE M,TD_M_PACKAGETYPE P
	WHERE T.ORDERNO = F.ORDERNO(+)
	AND T.PAPERTYPE = M.PAPERTYPECODE(+)
	AND T.PACKAGETYPE = P.PACKAGETYPECODE
	AND (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = F.ORDERTYPE)
	AND (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = T.ORDERNO)
	AND (P_VAR3 IS NULL OR P_VAR3 = '' OR T.CREATETIME >= TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS'))
	AND (P_VAR4 IS NULL OR P_VAR4 = '' OR T.CREATETIME <= TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS'))
	AND (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = T.ISREJECT)
	AND (P_VAR6 IS NULL OR P_VAR6 = '' OR P_VAR6 = F.PAYCANAL)
	ORDER BY T.CREATETIME DESC
	) A)
	WHERE SEQINDEX >= TO_NUMBER(P_VAR7)
	AND SEQINDEX < TO_NUMBER(P_VAR8)
	;
elsif p_funcCode = 'QueryRelaxProduceCount' then
	open p_cursor for
	SELECT COUNT(1)
	FROM TF_F_XXOL_ORDERDETAIL T,TF_F_XXOL_ORDER F,TD_M_PAPERTYPE M
	WHERE T.ORDERNO = F.ORDERNO(+)
	AND T.PAPERTYPE = M.PAPERTYPECODE(+)
	AND T.DETAILSTATES = '0'	--等待处理
	AND T.ISREJECT = '1'		--未驳回状态
	AND F.ORDERTYPE = '0'		--购卡开通
	AND (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = T.ORDERNO)
	AND (P_VAR3 IS NULL OR P_VAR3 = '' OR T.CREATETIME >= TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS'))
	AND (P_VAR4 IS NULL OR P_VAR4 = '' OR T.CREATETIME <= TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS'))
	AND (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = F.PAYCANAL)
	;
elsif p_funcCode = 'QueryRelaxOrderProduce' then	--制卡页面
	open p_cursor for
	SELECT * FROM (
	SELECT ROWNUM SEQINDEX,A.* FROM (
	SELECT T.ORDERDETAILID,T.ORDERNO,T.CARDNO,P.PACKAGETYPENAME PACKAGETYPENAME,
		T.CUSTNAME,T.PAPERTYPE,T.PAPERNO,T.CUSTPHONE,T.ADDRESS,T.CUSTPOST,DECODE(T.CUSTSEX,'0','男','1','女') CUSTSEX,
		T.CUSTBIRTH,T.CUSTEMAIL,DECODE(F.PAYCANAL,'01','支付宝','02','微信','03','银联') PAYCANAL,
		DECODE(F.ORDERTYPE,'0','新办卡开通','1','有卡开通','2','修改资料') ORDERTYPE,M.PAPERTYPENAME,
		DECODE(T.DETAILSTATES,'0','等待处理','1','制卡完成','2','已发货','3','驳回') DETAILSTATES,
		C.CARDSURFACENAME CARDSURFACENAME,
		TO_CHAR(T.CREATETIME,'YYYYMMDD') UPDATETIME,F.CUSTNAME RECENAME,F.ADDRESS RECEADDRESS,F.CUSTPHONE RECEPHONE,F.CUSTPOST RECEPOST,
		T.PACKAGETYPE PACKAGETYPECODE,T.FUNCFEE
	FROM TF_F_XXOL_ORDERDETAIL T,TF_F_XXOL_ORDER F,TD_M_PAPERTYPE M,TD_M_PACKAGETYPE P,TD_M_CARDSURFACE C
	WHERE T.ORDERNO = F.ORDERNO(+)
	AND T.PAPERTYPE = M.PAPERTYPECODE(+)
	AND T.CARDTYPECODE = C.CARDSURFACECODE(+)
	AND T.PACKAGETYPE = P.PACKAGETYPECODE
	AND T.DETAILSTATES = '0'	--等待处理
	AND T.ISREJECT = '1'		--未驳回状态
	AND F.ORDERTYPE = '0'		--购卡开通
	AND (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = T.ORDERNO)
	AND (P_VAR3 IS NULL OR P_VAR3 = '' OR T.CREATETIME >= TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS'))
	AND (P_VAR4 IS NULL OR P_VAR4 = '' OR T.CREATETIME <= TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS'))
	AND (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = F.PAYCANAL)
	ORDER BY T.CREATETIME DESC) A)
	WHERE SEQINDEX >= TO_NUMBER(P_VAR6) AND SEQINDEX < TO_NUMBER(P_VAR7)
	;	
elsif p_funcCode = 'QueryRelaxOrderDistrabutionAll' then	--配送
	open p_cursor for
	SELECT T.ORDERNO,DECODE(T.ORDERSTATES,0,'等待处理','1','制卡完成','2','已发货') ORDERSTATES,
	T.CUSTNAME,T.ADDRESS,T.CUSTPHONE,T.CUSTPOST,T.CREATETIME,T.TRACKINGNO,T.TRACKINGCOPCODE
	FROM TF_F_XXOL_ORDER T
	WHERE ISREJECT = '1'
	AND (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = T.ORDERSTATES)
	AND (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = T.ORDERNO)
	AND (P_VAR3 IS NULL OR P_VAR3 = '' OR T.CREATETIME >= TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS'))
	AND (P_VAR4 IS NULL OR P_VAR4 = '' OR T.CREATETIME <= TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS'))
	AND (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = T.CUSTPHONE)
	AND (P_VAR6 IS NULL OR P_VAR6 = '' OR P_VAR6 = T.PAYCANAL)
	ORDER BY T.CREATETIME DESC
	;
elsif p_funcCode = 'QueryRelaxOrderDistrabutionList' then	--配送页面明细
	open p_cursor for
	SELECT T.ORDERDETAILID,T.ORDERNO,T.CARDNO,P.PACKAGETYPENAME PACKAGETYPENAME,
		T.CUSTNAME,T.PAPERTYPE,T.PAPERNO,T.CUSTPHONE,T.ADDRESS,T.CUSTPOST,DECODE(T.CUSTSEX,'0','男','1','女') CUSTSEX,
		T.CUSTBIRTH,T.CUSTEMAIL,DECODE(F.PAYCANAL,'01','支付宝','02','微信','03','银联') PAYCANAL,
		DECODE(F.ORDERTYPE,'0','新办卡开通','1','有卡开通','2','修改资料') ORDERTYPE,M.PAPERTYPENAME,
		DECODE(T.DETAILSTATES,'0','等待处理','1','制卡完成','2','已发货','3','驳回') DETAILSTATES,
		TO_CHAR(T.CREATETIME,'YYYYMMDD') UPDATETIME,F.CUSTNAME RECENAME,F.ADDRESS RECEADDRESS,F.CUSTPHONE RECEPHONE,F.CUSTPOST RECEPOST,
		T.PACKAGETYPE PACKAGETYPECODE,T.FUNCFEE
	FROM TF_F_XXOL_ORDERDETAIL T,TF_F_XXOL_ORDER F,TD_M_PAPERTYPE M,TD_M_PACKAGETYPE P
	WHERE T.ORDERNO = F.ORDERNO(+)
	AND T.PAPERTYPE = M.PAPERTYPECODE(+)
	AND T.PACKAGETYPE = P.PACKAGETYPECODE
	AND t.ORDERNO = P_VAR1
	ORDER BY T.CREATETIME DESC
	;
elsif p_funcCode = 'QueryExportDistrabution' then --导出配送明细
	OPEN P_CURSOR FOR
	SELECT ORDERNO,CUSTNAME,ADDRESS,CUSTPHONE,CUSTPOST,TRACKINGCOPNAME,TRACKINGNO,WM_CONCAT (A.CARDNO) CARDNO FROM (
	SELECT T.ORDERNO,T.CUSTNAME,T.ADDRESS,T.CUSTPHONE,T.CUSTPOST,T.TRACKINGNO,M.TRACKINGCOPNAME
	,F.CARDNO
	FROM TF_F_XXOL_ORDER T,TF_F_XXOL_ORDERDETAIL F,TD_M_TRACKINGCOP M,TMP_ORDER TMP
	WHERE T.ISREJECT = '1'
	AND T.ORDERNO = F.ORDERNO
	AND T.ORDERNO = TMP.F1
	AND TMP.F0 = P_VAR1
	AND T.TRACKINGCOPCODE = M.TRACKINGCOPCODE(+)
	ORDER BY T.CREATETIME DESC) A
	GROUP BY ORDERNO,CUSTNAME,ADDRESS,CUSTPHONE,CUSTPOST,TRACKINGNO,TRACKINGCOPNAME;
elsif p_funcCode = 'QueryOrderDetailCardNo' then --获取订单号对应的卡号
	OPEN P_CURSOR FOR
	SELECT F.ORDERNO,WMSYS.WM_CONCAT(F.CARDNO) FROM TF_F_XXOL_ORDERDETAIL F
	WHERE F.ORDERNO = P_VAR1 GROUP BY F.ORDERNO;
elsif p_funcCode= 'QueryOrderDetail' then
	open p_cursor for
	SELECT T.CUSTNAME,T.PAPERTYPE,T.PAPERNO,T.CUSTPHONE,T.ADDRESS,
	T.CUSTPOST,T.CUSTSEX,T.CUSTBIRTH,T.CUSTEMAIL,T.FUNCFEE,T.PACKAGETYPE
	FROM TF_F_XXOL_ORDERDETAIL T
	WHERE T.ORDERDETAILID = P_VAR1;
elsif p_funcCode= 'QueryTrackingCop' then
	open p_cursor for
	SELECT TRACKINGCOPNAME,TRACKINGCOPCODE FROM TD_M_TRACKINGCOP WHERE USETAG = '1' ORDER BY TRACKINGCOPCODE;
elsif p_funcCode= 'QueryTMPRelax' then	--获取休闲数据，用以发起休闲订单状态变更通知
	open p_cursor for
    SELECT F.ORDERNO,F.ORDERDETAILID DETAILID,F.CARDNO,DECODE(F.ISREJECT,'0','3','1','4') ORDERSTATE,
	M.TRACKINGCOPNAME LOGISTICSCOMPANY,D.TRACKINGNO,'' REMARK
	FROM TMP_ORDER T,TF_F_XXOL_ORDERDETAIL F,TF_F_XXOL_ORDER D,TD_M_TRACKINGCOP M
	WHERE T.F0 = P_VAR1
	AND T.F1 = F.ORDERNO
	AND F.ORDERNO = D.ORDERNO
	AND T.F2 = F.ORDERDETAILID
	AND D.TRACKINGCOPCODE = M.TRACKINGCOPCODE(+);
elsif p_funcCode = 'QueryDistrabution' then
	open p_cursor for
    SELECT F.ORDERNO,F.ORDERDETAILID DETAILID,F.CARDNO,'2' ORDERSTATE,
	M.TRACKINGCOPNAME LOGISTICSCOMPANY,D.TRACKINGNO,'' REMARK
	FROM TF_F_XXOL_ORDERDETAIL F,TF_F_XXOL_ORDER D,TD_M_TRACKINGCOP M,TMP_ORDER T
	WHERE T.F1 = D.ORDERNO
	AND F.ORDERNO = D.ORDERNO
	AND D.TRACKINGCOPCODE = M.TRACKINGCOPCODE(+);

elsif p_funcCode = 'QueryOrderCount' then
	open p_cursor for
	SELECT COUNT(1) FROM TF_F_XXOL_ORDERDETAIL T,TF_F_XXOL_ORDER F,TD_M_PAPERTYPE M
	WHERE T.ORDERNO = F.ORDERNO(+)
	AND T.PAPERTYPE = M.PAPERTYPECODE
	AND (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = F.ORDERTYPE)
	AND (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = T.ORDERNO)
	AND (P_VAR3 IS NULL OR P_VAR3 = '' OR T.CREATETIME >= TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS'))
	AND (P_VAR4 IS NULL OR P_VAR4 = '' OR T.CREATETIME <= TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS'))
	AND (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = T.ISREJECT)
	AND (P_VAR6 IS NULL OR P_VAR6 = '' OR P_VAR6 = F.PAYCANAL)
	;
elsif p_funcCode = 'QueryRelaxOrder' then
	open p_cursor for
	SELECT * FROM (
	SELECT ROWNUM SEQINDEX,A.* FROM (
	SELECT T.ORDERDETAILID,T.ORDERNO,T.CARDNO,P.PACKAGETYPENAME PACKAGETYPE,
		T.CUSTNAME,T.PAPERTYPE,T.PAPERNO,T.CUSTPHONE,T.ADDRESS,T.CUSTPOST,DECODE(T.CUSTSEX,'0','男','1','女') CUSTSEX,
		T.CUSTBIRTH,T.CUSTEMAIL,DECODE(F.PAYCANAL,'01','支付宝','02','微信','03','银联') PAYCANAL,
		DECODE(F.ORDERTYPE,'0','售卡','1','开通','2','修改资料') ORDERTYPE,M.PAPERTYPENAME,
		DECODE(T.DETAILSTATES,'0','等待处理','1','制卡完成','2','已发货') DETAILSTATES,
		TO_CHAR(T.CREATETIME,'YYYYMMDD') UPDATETIME,F.CUSTNAME LOGCUSTNAME,F.ADDRESS LOGADDRESS,F.CUSTPHONE LOGCUSTPHONE
	FROM TF_F_XXOL_ORDERDETAIL T,TF_F_XXOL_ORDER F,TD_M_PAPERTYPE M,TD_M_PACKAGETYPE P
	WHERE T.ORDERNO = F.ORDERNO(+)
	AND T.PAPERTYPE = M.PAPERTYPECODE
	AND T.PACKAGETYPE = P.PACKAGETYPECODE
	AND (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = F.ORDERTYPE)
	AND (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = T.ORDERNO)
	AND (P_VAR3 IS NULL OR P_VAR3 = '' OR T.CREATETIME >= TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS'))
	AND (P_VAR4 IS NULL OR P_VAR4 = '' OR T.CREATETIME <= TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS'))
	AND (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = T.ISREJECT)
	AND (P_VAR6 IS NULL OR P_VAR6 = '' OR P_VAR6 = F.PAYCANAL)
	ORDER BY T.CREATETIME DESC
	) A)
	WHERE SEQINDEX >= TO_NUMBER(P_VAR7)
	AND SEQINDEX < TO_NUMBER(P_VAR8)
	;
elsif p_funcCode = 'QueryRelaxProduceCount' then
	open p_cursor for
	SELECT COUNT(1)
	FROM TF_F_XXOL_ORDERDETAIL T,TF_F_XXOL_ORDER F,TD_M_PAPERTYPE M
	WHERE T.ORDERNO = F.ORDERNO(+)
	AND T.PAPERTYPE = M.PAPERTYPECODE
	AND T.DETAILSTATES = '0'	--等待处理
	AND T.ISREJECT = '1'		--未驳回状态
	AND F.ORDERTYPE = '0'		--购卡开通
	AND (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = T.ORDERNO)
	AND (P_VAR3 IS NULL OR P_VAR3 = '' OR T.CREATETIME >= TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS'))
	AND (P_VAR4 IS NULL OR P_VAR4 = '' OR T.CREATETIME <= TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS'))
	AND (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = F.PAYCANAL)
	;
elsif p_funcCode = 'QueryRelaxOrderProduce' then	--制卡页面
	open p_cursor for
	SELECT * FROM (
	SELECT ROWNUM SEQINDEX,A.* FROM (
	SELECT T.ORDERDETAILID,T.ORDERNO,T.CARDNO,P.PACKAGETYPENAME PACKAGETYPENAME,
		T.CUSTNAME,T.PAPERTYPE,T.PAPERNO,T.CUSTPHONE,T.ADDRESS,T.CUSTPOST,DECODE(T.CUSTSEX,'0','男','1','女') CUSTSEX,
		T.CUSTBIRTH,T.CUSTEMAIL,DECODE(F.PAYCANAL,'01','支付宝','02','微信','03','银联') PAYCANAL,
		DECODE(F.ORDERTYPE,'0','售卡','1','开通','2','修改资料') ORDERTYPE,M.PAPERTYPENAME,
    DECODE(T.DETAILSTATES,'0','等待处理','1','制卡完成','2','已发货','3','驳回') DETAILSTATES, C.CARDSURFACENAME CARDSURFACENAME,
		TO_CHAR(T.CREATETIME,'YYYYMMDD') UPDATETIME,F.CUSTNAME RECENAME,F.ADDRESS RECEADDRESS,F.CUSTPHONE RECEPHONE,F.CUSTPOST RECEPOST,
		T.PACKAGETYPE PACKAGETYPECODE,T.FUNCFEE
  FROM TF_F_XXOL_ORDERDETAIL T,TF_F_XXOL_ORDER F,TD_M_PAPERTYPE M,TD_M_PACKAGETYPE P,TD_M_CARDSURFACE C
	WHERE T.ORDERNO = F.ORDERNO(+)
	AND T.PAPERTYPE = M.PAPERTYPECODE
   AND T.CARDTYPECODE = C.CARDSURFACECODE(+)
	AND T.PACKAGETYPE = P.PACKAGETYPECODE
	AND T.DETAILSTATES = '0'	--等待处理
	AND T.ISREJECT = '1'		--未驳回状态
	AND F.ORDERTYPE = '0'		--购卡开通
	AND (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = T.ORDERNO)
	AND (P_VAR3 IS NULL OR P_VAR3 = '' OR T.CREATETIME >= TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS'))
	AND (P_VAR4 IS NULL OR P_VAR4 = '' OR T.CREATETIME <= TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS'))
	AND (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = F.PAYCANAL)
	ORDER BY T.CREATETIME DESC) A)
	WHERE SEQINDEX >= TO_NUMBER(P_VAR6) AND SEQINDEX < TO_NUMBER(P_VAR7)
	;	
elsif p_funcCode = 'QueryRelaxOrderDistrabutionAll' then	--配送
	open p_cursor for
	SELECT T.ORDERNO,DECODE(T.ORDERSTATES,0,'等待处理','1','制卡完成','2','已发货') ORDERSTATES,
	T.CUSTNAME,T.ADDRESS,T.CUSTPHONE,T.CUSTPOST,T.CREATETIME,T.TRACKINGNO,T.TRACKINGCOPCODE
	FROM TF_F_XXOL_ORDER T
	WHERE ISREJECT = '1'
	AND (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = T.ORDERSTATES)
	AND (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = T.ORDERNO)
	AND (P_VAR3 IS NULL OR P_VAR3 = '' OR T.CREATETIME >= TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS'))
	AND (P_VAR4 IS NULL OR P_VAR4 = '' OR T.CREATETIME <= TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS'))
	AND (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = T.CUSTPHONE)
	AND (P_VAR6 IS NULL OR P_VAR6 = '' OR P_VAR6 = T.PAYCANAL)
	ORDER BY T.CREATETIME DESC
	;
elsif p_funcCode = 'QueryRelaxOrderDistrabutionList' then	--配送页面明细
	open p_cursor for
	SELECT T.ORDERDETAILID,T.ORDERNO,T.CARDNO,P.PACKAGETYPENAME PACKAGETYPENAME,
		T.CUSTNAME,T.PAPERTYPE,T.PAPERNO,T.CUSTPHONE,T.ADDRESS,T.CUSTPOST,DECODE(T.CUSTSEX,'0','男','1','女') CUSTSEX,
		T.CUSTBIRTH,T.CUSTEMAIL,DECODE(F.PAYCANAL,'01','支付宝','02','微信','03','银联') PAYCANAL,
		DECODE(F.ORDERTYPE,'0','售卡','1','开通','2','修改资料') ORDERTYPE,M.PAPERTYPENAME,
		DECODE(T.DETAILSTATES,'0','等待处理','1','制卡完成','2','已发货','3','驳回') DETAILSTATES,
		TO_CHAR(T.CREATETIME,'YYYYMMDD') UPDATETIME,F.CUSTNAME RECENAME,F.ADDRESS RECEADDRESS,F.CUSTPHONE RECEPHONE,F.CUSTPOST RECEPOST,
		T.PACKAGETYPE PACKAGETYPECODE,T.FUNCFEE
	FROM TF_F_XXOL_ORDERDETAIL T,TF_F_XXOL_ORDER F,TD_M_PAPERTYPE M,TD_M_PACKAGETYPE P
	WHERE T.ORDERNO = F.ORDERNO(+)
	AND T.PAPERTYPE = M.PAPERTYPECODE
	AND T.PACKAGETYPE = P.PACKAGETYPECODE
	AND t.ORDERNO = P_VAR1
	ORDER BY T.CREATETIME DESC
	;
elsif p_funcCode= 'QueryOrderDetail' then
	open p_cursor for
	SELECT T.CUSTNAME,T.PAPERTYPE,T.PAPERNO,T.CUSTPHONE,T.ADDRESS,
	T.CUSTPOST,T.CUSTSEX,T.CUSTBIRTH,T.CUSTEMAIL,T.FUNCFEE,T.PACKAGETYPE
	FROM TF_F_XXOL_ORDERDETAIL T
	WHERE T.ORDERDETAILID = P_VAR1;
elsif p_funcCode= 'QueryTrackingCop' then
	open p_cursor for
	SELECT TRACKINGCOPNAME,TRACKINGCOPCODE FROM TD_M_TRACKINGCOP WHERE USETAG = '1' ORDER BY TRACKINGCOPCODE;
elsif p_funcCode= 'QueryTMPRelax' then	--获取休闲数据，用以发起休闲订单状态变更通知
	open p_cursor for
    SELECT F.ORDERNO,F.ORDERDETAILID DETAILID,F.CARDNO,DECODE(F.DETAILSTATES,'0','4','1','2','3') ORDERSTATE,
	M.TRACKINGCOPNAME LOGISTICSCOMPANY,D.TRACKINGNO,'' REMARK
	FROM TMP_ORDER T,TF_F_XXOL_ORDERDETAIL F,TF_F_XXOL_ORDER D,TD_M_TRACKINGCOP M
	WHERE T.F0 = P_VAR1
	AND T.F1 = F.ORDERNO
	AND F.ORDERNO = D.ORDERNO
	AND T.F2 = F.ORDERDETAILID
	AND D.TRACKINGCOPCODE = M.TRACKINGCOPCODE(+);
elsif p_funcCode = 'QueryDistrabution' then
	open p_cursor for
    SELECT F.ORDERNO,F.ORDERDETAILID DETAILID,F.CARDNO,DECODE(F.DETAILSTATES,'0','4','1','2','3') ORDERSTATE,
	M.TRACKINGCOPNAME LOGISTICSCOMPANY,D.TRACKINGNO,'' REMARK
	FROM TF_F_XXOL_ORDERDETAIL F,TF_F_XXOL_ORDER D,TD_M_TRACKINGCOP M,TMP_ORDER T
	WHERE T.F1 = D.ORDERNO
	AND F.ORDERNO = D.ORDERNO
	AND D.TRACKINGCOPCODE = M.TRACKINGCOPCODE(+);
ELSIF P_FUNCCODE = 'REFUNDAPP_QUERY' THEN--查询充值补登报表
  open p_cursor for
        select TRADETIME 交易日期,DECODE(CHANNELNO,'01','APP',CHANNELNO)  渠道,SUM(充值) 充值,SUM(退款) 退款,SUM(笔数) 笔数 from
            (select substr(a.TRADETIME,0,8) TRADETIME,a.CHANNELNO,sum(a.TRADEMONEY)/100.0 充值,0 退款,COUNT(*) 笔数
            from TF_OUT_ADDTRADE a
            where ( p_var1 is null or p_var1 = '' or substr(a.TRADETIME,0,8) >= p_var1)
                and ( p_var2 is null or p_var2 = '' or substr(a.TRADETIME,0,8)<= p_var2)
                and (p_var3 is null or p_var3 = '' or a.CHANNELNO = p_var3)
                and a.ISREFUND='0'
                group by a.TRADETIME,a.CHANNELNO
       union all
        select to_char(a.refundtime,'yyyyMMdd') TRADETIME,a.CHANNELNO,0 充值,sum(a.TRADEMONEY)/100.0 退款,COUNT(*) 笔数
            from TF_OUT_ADDTRADE a
            where ( p_var1 is null or p_var1 = '' or to_char(a.refundtime,'yyyyMMdd')>=p_var1)
                and ( p_var2 is null or p_var2 = '' or to_char(a.refundtime,'yyyyMMdd')<=p_var2)
               and (p_var3 is null or p_var3 = '' or a.CHANNELNO = p_var3)
                and a.ISREFUND='1'
                group by to_char(a.refundtime,'yyyyMMdd'),a.CHANNELNO)
                group by TRADETIME,CHANNELNO  order by TRADETIME,CHANNELNO;
ELSIF P_FUNCCODE = 'GetTableCard' THEN--查询订单号对应的卡号
	open p_cursor for
	SELECT CARDNO FROM TF_F_ZZOL_SYNC WHERE TRADETYPECODE = '01' AND DETAILNO = P_VAR1;
end if;
end;

/
show errors;