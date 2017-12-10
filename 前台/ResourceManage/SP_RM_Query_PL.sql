create or replace procedure SP_RM_Query
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
    p_var10      varchar2,
    p_var11      varchar2,
    p_cursor out SYS_REFCURSOR
)
as
	v_sql varchar2(100) := '';
begin
      if p_funcCode = 'TP_XFC_CARDVALUE' then
          open p_cursor for
          select t.VALUE,t.VALUECODE from TP_XFC_CARDVALUE t;

      elsif  p_funcCode = 'InitCardFaceAffirmWay' then -- 初始化卡面确认方式 add by shil
          open p_cursor for
          select CODEDESC,CODEVALUE
          from   TD_M_RMCODING
          where  TABLENAME = 'TF_F_APPLYORDER'
          and    COLNAME   = 'CARDFACEAFFIRMWAY';

      elsif  p_funcCode = 'USECARD_ORDER' then -- 查询用户卡领用单 add by Yin
          open p_cursor for
          select t.getcardorderid 领用单号,
          m.cardtypename 卡片类型,
          s.cardsurfacename 卡面类型,
          t.applygetnum 领用数量,
          t.useway 用途,
          t.ordertime 申请时间,
          st.staffname 申请员工,
          de.departname 申请部门,
          t.getcardorderstate || ':' ||  B.CODEDESC 审核状态,
          t.remark 备注
          from  TF_F_GETCARDORDER t
          inner join TD_M_RMCODING B on  t.getcardorderstate = B.CODEVALUE
          inner join td_m_cardtype m on t.cardtypecode = m.cardtypecode
          inner join td_m_cardsurface s on t.cardsurfacecode = s.cardsurfacecode
          inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
          inner join td_m_insidedepart de on st.departno = de.departno
          where
          B.TABLENAME = 'TF_F_GETCARDORDER' and B.Colname = 'GETCARDORDERSTATE'  and
          t.getcardordertype = '01' and
          (p_var1 is null or t.getcardorderstate = p_var1)  --审核状态
          and (p_var2 is null or to_char(t.ordertime,'yyyymmdd') >= p_var2) --开始日期
          and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') <= p_var3) --结束日期
          and (p_var4 is null or t.orderstaffno = p_var4)
          and (p_var5 is null or de.departno = p_var5)
          Order by t.getcardorderid desc;

       elsif  p_funcCode = 'CHARGECARD_ORDER' then -- 查询充值卡领用单 add by Yin
          open p_cursor for
          select t.getcardorderid 领用单号,
          m.value 充值卡面值,
          t.applygetnum 领用数量,
          t.useway 用途,
          t.ordertime 申请时间,
          st.staffname 申请员工,
          de.departname 申请部门,
          t.getcardorderstate || ':' ||  B.CODEDESC 审核状态,
          t.remark 备注
          from  TF_F_GETCARDORDER t inner join  TD_M_RMCODING B on  t.getcardorderstate = B.CODEVALUE
          inner join TP_XFC_CARDVALUE m on m.VALUECODE = t.valuecode
          inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
          inner join td_m_insidedepart de on st.departno = de.departno
          where
          B.TABLENAME = 'TF_F_GETCARDORDER' and B.Colname = 'GETCARDORDERSTATE'  and
          t.getcardordertype = '02' and
          (p_var1 is null or t.getcardorderstate = p_var1)
          and (p_var2 is null or to_char(t.ordertime,'yyyymmdd') >= p_var2)
          and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') <= p_var3)
          and (p_var4 is null or t.orderstaffno = p_var4)
          and (p_var5 is null or de.departno = p_var5)
          order by t.getcardorderid	desc;

elsif  p_funcCode = 'queryCardSample' then  --根据卡面类型查询卡样编码 add by shil
    open p_cursor for
    SELECT a.CARDSAMPLECODE , b.CARDSAMPLE
    FROM   TD_M_CARDSURFACE a, TD_M_CARDSAMPLE b
    WHERE  a.CARDSAMPLECODE = b.CARDSAMPLECODE
    AND    a.CARDSURFACECODE = p_var1;

elsif  p_funcCode = 'queryCardFaceByCardType' then  --通过卡类型查询卡面类型 add by shil
    open p_cursor for
    SELECT CARDSURFACENAME , CARDSURFACECODE
    FROM   TD_M_CARDSURFACE
    WHERE  (p_var1 is null or p_var1 = '' or substr(CARDSURFACECODE,1,2) = p_var1);

elsif  p_funcCode = 'queryApplyStock' then  --查询下单申请存货补货 add by shil
    open p_cursor for
		SELECT A.APPLYORDERID ,                                     --需求单号
		       A.APPLYORDERSTATE||':'||B.CODEDESC STATE,            --需求单状态
		       A.CARDTYPECODE||':'||D.CARDTYPENAME CARDTYPE,        --卡类型
		       A.CARDSURFACECODE||':'||C.CARDSURFACENAME CARDFACE,  --卡面类型
		       A.CARDSAMPLECODE,                            --卡样编码
		       A.CARDNUM       ,                            --卡片数量
		       A.REQUIREDATE   ,                            --要求到货日期
		       A.ORDERDEMAND   ,                            --订单要求
		       A.REMARK        ,                            --备注
		       A.ORDERTIME     ,                            --下单时间
		       A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF, --下单员工
		       A.ALREADYORDERNUM ,                          --已订购数量
		       A.LATELYDATE    ,                            --最近到货时间
		       (A.ALREADYARRIVENUM - A.RETURNCARDNUM) NUM   --已到货数量
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_RMCODING    B ,
		       TD_M_CARDSURFACE C ,
		       TD_M_CARDTYPE    D ,
		       TD_M_INSIDESTAFF E
		WHERE  A.APPLYORDERSTATE = B.CODEVALUE
		AND    B.COLNAME = 'APPLYORDERSTATE'
		AND    B.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.CARDTYPECODE = D.CARDTYPECODE
		AND    A.CARDSURFACECODE = C.CARDSURFACECODE
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    A.APPLYORDERTYPE = '01'
		AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.CARDSURFACECODE)
		AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = A.APPLYORDERID)
		AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
		AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
		AND   (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = A.APPLYORDERSTATE)
		AND    P_VAR6 = A.USETAG
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'queryApplyNew' then    --查询下单申请新制卡片 add by shil
    open p_cursor for
		SELECT A.APPLYORDERID ,                             --需求单号
		       A.APPLYORDERSTATE||':'||B.CODEDESC STATE,    --需求单状态
		       A.CARDNAME     ,                             --卡片名称
		       A.CARDFACEAFFIRMWAY||':'||C.CODEDESC WAY,    --卡面确认方式
		       A.CARDNUM       ,                            --卡片数量
		       A.REQUIREDATE   ,                            --要求到货日期
		       A.ORDERDEMAND   ,                            --订单要求
		       A.REMARK        ,                            --备注
		       A.ORDERTIME     ,                            --下单时间
		       A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF, --下单员工
		       A.ALREADYORDERNUM ,                          --已订购数量
		       A.LATELYDATE    ,                            --最近到货时间
		       (A.ALREADYARRIVENUM - A.RETURNCARDNUM) NUM   --已到货数量
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_RMCODING    B ,
		       TD_M_RMCODING    C ,
		       TD_M_INSIDESTAFF E
		WHERE  A.APPLYORDERSTATE = B.CODEVALUE
		AND    B.COLNAME = 'APPLYORDERSTATE'
		AND    B.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.CARDFACEAFFIRMWAY = C.CODEVALUE
		AND    C.COLNAME = 'CARDFACEAFFIRMWAY'
		AND    C.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    A.APPLYORDERTYPE = '02'
		AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.CARDNAME)
		AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = A.APPLYORDERID)
		AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
		AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
		AND   (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = A.APPLYORDERSTATE)
		AND    P_VAR6 = A.USETAG
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'queryApplyChargeCard' then  --查询下单申请充值卡 add by shil
    open p_cursor for
		SELECT A.APPLYORDERID ,                             --需求单号
		       A.APPLYORDERSTATE||':'||B.CODEDESC STATE,    --需求单状态
		       A.VALUECODE||':'||C.VALUE VALUECODE,         --充值卡面值
		       A.CARDNUM       ,                            --卡片数量
		       A.REQUIREDATE   ,                            --要求到货日期
		       A.ORDERDEMAND   ,                            --订单要求
		       A.REMARK        ,                            --备注
		       A.ORDERTIME     ,                            --下单时间
		       A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF, --下单员工
		       A.ALREADYORDERNUM ,                          --已订购数量
		       A.LATELYDATE    ,                            --最近到货时间
		       (A.ALREADYARRIVENUM - A.RETURNCARDNUM) NUM   --已到货数量
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_RMCODING    B ,
		       TP_XFC_CARDVALUE C ,
		       TD_M_INSIDESTAFF E
		WHERE  A.APPLYORDERSTATE = B.CODEVALUE
		AND    B.COLNAME = 'APPLYORDERSTATE'
		AND    B.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.VALUECODE = C.VALUECODE
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    A.APPLYORDERTYPE = '03'
		AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.VALUECODE)
		AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = A.APPLYORDERID)
		AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
		AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR TO_DATE(P_VAR4||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
		AND   (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = A.APPLYORDERSTATE)
		AND    P_VAR6 = A.USETAG
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'queryCardFaceAffirmAppleyOrder' then  --查询待卡面确认的需求单 add by shil
    open p_cursor for
		SELECT A.APPLYORDERID ,                             --需求单号
		       A.CARDNAME     ,                             --卡片名称
		       A.CARDFACEAFFIRMWAY||':'||B.CODEDESC WAY,    --卡面确认方式
		       A.CARDNUM       ,                            --卡片数量
		       A.REQUIREDATE   ,                            --要求到货日期
		       A.ORDERDEMAND   ,                            --订单要求
		       A.ORDERTIME     ,                            --下单时间
		       A.ORDERSTAFFNO||':'||C.STAFFNAME ORDERSTAFF, --下单员工
		       A.REMARK                                     --备注
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_RMCODING    B ,
		       TD_M_INSIDESTAFF C
		WHERE  A.CARDFACEAFFIRMWAY = B.CODEVALUE
		AND    B.COLNAME = 'CARDFACEAFFIRMWAY'
		AND    B.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.ORDERSTAFFNO = C.STAFFNO
		AND    A.APPLYORDERTYPE = '02'
		AND    A.APPLYORDERSTATE = '0'
		AND    A.CARDSAMPLECODE IS NULL
		AND    A.USETAG = '1'
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'queryUseCardApplyOrder' then  --查询用户卡需求单 add by shil
    open p_cursor for
		SELECT A.APPLYORDERID ,                                     --需求单号
		       A.APPLYORDERTYPE||':'||B.CODEDESC ORDERTYPE  ,       --需求单类型
		       A.CARDTYPECODE||':'||D.CARDTYPENAME CARDTYPE ,       --卡类型
		       A.CARDSURFACECODE||':'||C.CARDSURFACENAME CARDFACE,  --卡面类型
		       A.CARDSAMPLECODE,                            --卡样编码
		       A.CARDNAME      ,                            --卡片名称
		       A.CARDFACEAFFIRMWAY||':'||F.CODEDESC WAY ,   --卡面确认方式
		       A.CARDNUM       ,                            --卡片数量
		       A.REQUIREDATE   ,                            --要求到货日期
		       A.ORDERDEMAND   ,                            --订单要求
		       A.REMARK        ,                            --备注
		       A.ORDERTIME     ,                            --下单时间
		       A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF ,--下单员工
		       A.ALREADYORDERNUM                            --已订购数量
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_RMCODING    B ,
		       TD_M_CARDSURFACE C ,
		       TD_M_CARDTYPE    D ,
		       TD_M_INSIDESTAFF E ,
          (SELECT CODEVALUE,CODEDESC
           FROM  TD_M_RMCODING
           WHERE COLNAME = 'CARDFACEAFFIRMWAY'
           AND TABLENAME = 'TF_F_APPLYORDER') F
		WHERE  A.APPLYORDERTYPE = B.CODEVALUE
		AND    B.COLNAME = 'APPLYORDERTYPE'
		AND    B.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.CARDFACEAFFIRMWAY = F.CODEVALUE(+)
		AND    A.CARDTYPECODE = D.CARDTYPECODE(+)
		AND    A.CARDSURFACECODE = C.CARDSURFACECODE(+)
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    A.APPLYORDERTYPE IN ('01','02')
		AND    A.APPLYORDERSTATE IN ('0','1')
		AND    A.USETAG = '1'
		AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.APPLYORDERID)
		AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
		AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'queryChargeCardApplyOrder' then  --查询充值卡卡需求单 add by shil
    open p_cursor for
		SELECT A.APPLYORDERID ,                             --需求单号
		       A.VALUECODE||':'||C.VALUE VALUECODE ,        --充值卡面值
		       A.CARDNUM       ,                            --卡片数量
		       A.REQUIREDATE   ,                            --要求到货日期
		       A.ORDERDEMAND   ,                            --订单要求
		       A.REMARK        ,                            --备注
		       A.ORDERTIME     ,                            --下单时间
		       A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF ,--下单员工
		       A.ALREADYORDERNUM                            --已订购数量
		FROM   TF_F_APPLYORDER  A ,
		       TP_XFC_CARDVALUE C ,
		       TD_M_INSIDESTAFF E
		WHERE  A.VALUECODE = C.VALUECODE
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    A.APPLYORDERTYPE = '03'
		AND    A.APPLYORDERSTATE IN ('0','1')
		AND    A.USETAG = '1'
		AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.APPLYORDERID)
		AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
		AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'queryMaxCardNo' then  --获取充值卡账户表和排重表中相应年份，厂家，面值对应的最大卡号 add by hzl
    open p_cursor for
    
    select Max(a.cardno) from (select  Max(t.xfcardno) cardno from TD_XFC_INITCARD t
    where t.YEAR =P_VAR2 and t.CORPCODE = P_VAR1
    and t.valuecode = P_VAR3 
    union all Select  Max(b.cardno) cardno from TD_M_CHARGECARDNO_EXCLUDE b where substr(b.cardno,0,2) = P_VAR2 
    and substr(b.cardno,6,1) =P_VAR1 
    and substr(b.cardno,5,1) = P_VAR3) a;
	
elsif  p_funcCode = 'queryCompanyNo' then  --查询厂家编号 add by hzl
    open p_cursor for 
    Select a.NEW_PASSWD From TD_XFC_INITCARD a Where a.XFCARDNO = P_VAR1;
    
elsif  p_funcCode = 'queryCardValueNum' then  --查询领卡申请选择的面额数量  add by hzl
    open p_cursor for 
    select count(a.XFCARDNO) total from TD_XFC_INITCARD a  where a.CARDSTATECODE = '2' and a.VALUECODE = P_VAR1;

elsif  p_funcCode = 'queryCardValueLeftNum' then  --查询领卡审核库存余量  add by hzl
    open p_cursor for 
    select b.VALUE,count(a.XFCARDNO) total from TD_XFC_INITCARD a ,TP_XFC_CARDVALUE b 
    where a.CARDSTATECODE = '2' and a.VALUECODE = b.VALUECODE(+) and a.VALUECODE in P_VAR1 group by b.VALUE; 
    
elsif  p_funcCode = 'queryUseCardOrder' then  --查询待审核用户卡订购单 add by shil
    open p_cursor for
		SELECT A.CARDORDERID      ,                                  --订购单号
		       A.APPLYORDERID     ,                                  --需求单号
		       A.CARDORDERTYPE||':'||B.CODEDESC     CARDORDERTYPE ,  --订购类型
		       A.CARDTYPECODE||':'||D.CARDTYPENAME       CARDTYPE ,  --卡片类型
		       A.CARDSURFACECODE||':'||C.CARDSURFACENAME CARDFACE ,  --卡面类型
		       A.CARDSAMPLECODE   ,                                  --卡样编码
		       A.CARDNUM          ,                                  --卡片数量
		       A.REQUIREDATE      ,                                  --要求到货日期
		       A.BEGINCARDNO      ,                                  --起始卡号
		       A.ENDCARDNO        ,                                  --结束卡号
		       A.CARDCHIPTYPECODE||':'||F.CARDCHIPTYPENAME CARDCHIP, --卡芯片
		       A.COSTYPECODE||':'||E.COSTYPE     COSTYPE  ,          --COS类型
		       A.MANUTYPECODE||':'||G.MANUNAME   MANUNAME ,          --卡片厂商
		       A.APPVERNO         ,                          --应用版本号
		       A.VALIDBEGINDATE   ,                          --起始有效日期
		       A.VALIDENDDATE     ,                          --结束有效日期
		       A.ORDERTIME        ,                          --下单时间
		       A.ORDERSTAFFNO||':'||H.STAFFNAME  ORDERSTAFF ,--下单员工
		       A.EXAMTIME         ,                          --审核时间
		       A.EXAMSTAFFNO||':'||I.STAFFNAME   EXAMSTAFF , --审核员工
		       A.REMARK           ,                          --备注
		       A.CARDORDERSTATE||':'||J.CODEDESC STATE       --审核状态
		FROM   TF_F_CARDORDER    A ,
		       TD_M_RMCODING     B ,
		       TD_M_CARDSURFACE  C ,
		       TD_M_CARDTYPE     D ,
		       TD_M_COSTYPE      E , --COS类型编码表
		       TD_M_CARDCHIPTYPE F , --芯片类型编码表
		       TD_M_MANU         G , --卡片厂商编码表
		       TD_M_INSIDESTAFF  H ,
		       TD_M_INSIDESTAFF  I ,
		       TD_M_RMCODING     J
		WHERE  A.CARDORDERTYPE = B.CODEVALUE
		AND    B.COLNAME = 'CARDORDERTYPE'
		AND    B.TABLENAME = 'TF_F_CARDORDER'
		AND    A.CARDORDERSTATE = J.CODEVALUE
		AND    J.COLNAME = 'CARDORDERSTATE'
		AND    J.TABLENAME = 'TF_F_CARDORDER'
		AND    A.CARDSURFACECODE = C.CARDSURFACECODE(+)
		AND    A.CARDTYPECODE = D.CARDTYPECODE(+)
		AND    A.COSTYPECODE = E.COSTYPECODE(+)
		AND    A.CARDCHIPTYPECODE = F.CARDCHIPTYPECODE(+)
		AND    A.MANUTYPECODE = G.MANUCODE(+)
		AND    A.ORDERSTAFFNO = H.STAFFNO(+)
		AND    A.EXAMSTAFFNO = I.STAFFNO(+)
		AND    A.CARDORDERTYPE IN ('01','02')
		AND    A.USETAG = '1'
		AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.CARDORDERID )
		AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = A.CARDORDERSTATE)
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'queryChargeCardOrder' then  --查询待审核充值卡卡订购单 add by shil
    open p_cursor for
		SELECT A.CARDORDERID      ,                          --订购单号
		       A.APPLYORDERID     ,                          --需求单号
		       A.VALUECODE||':'||B.VALUE VALUECODE ,         --充值卡面值
		       A.CARDNUM          ,                          --卡片数量
		       A.REQUIREDATE      ,                          --要求到货日期
		       A.BEGINCARDNO      ,                          --起始卡号
		       A.ENDCARDNO        ,                          --结束卡号
		       A.ORDERTIME        ,                          --下单时间
		       A.ORDERSTAFFNO||':'||C.STAFFNAME ORDERSTAFF , --下单员工
		       A.EXAMTIME         ,                          --审核时间
		       A.EXAMSTAFFNO||':'||D.STAFFNAME  EXAMSTAFF  , --审核员工
		       A.REMARK           ,                          --备注
		       A.CARDORDERSTATE||':'||E.CODEDESC STATE     , --审核状态
           A.VALIDENDDATE     ,                          --有效期
           F.CORPNAME                                    --卡片厂商
		FROM   TF_F_CARDORDER    A ,
		       TP_XFC_CARDVALUE  B ,
		       TD_M_INSIDESTAFF  C ,
		       TD_M_INSIDESTAFF  D ,
		       TD_M_RMCODING     E ,
           TP_XFC_CORP       F
		WHERE  A.VALUECODE = B.VALUECODE(+)
		AND    A.ORDERSTAFFNO = C.STAFFNO(+)
		AND    A.EXAMSTAFFNO = D.STAFFNO(+)
    AND    A.MANUTYPECODE = F.CORPCODE(+)
		AND    A.CARDORDERSTATE = E.CODEVALUE
		AND    E.COLNAME = 'CARDORDERSTATE'
		AND    E.TABLENAME = 'TF_F_CARDORDER'
		AND    A.CARDORDERTYPE = '03'
		AND    A.USETAG = '1'
		AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.CARDORDERID )
		AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = A.CARDORDERSTATE)
		ORDER BY A.ORDERTIME DESC;

elsif  p_funcCode = 'UseCardOrderQuery' then  --用户卡订购单查询 add by shil
	IF P_VAR3 IS NOT NULL THEN
		V_SQL := V_SQL||'AND  A.CARDORDERSTATE IN('||P_VAR3||')';
	END IF;
    DBMS_OUTPUT.PUT_LINE(V_SQL);
	open p_cursor for
		'SELECT A.CARDORDERID      ,                                  --订购单号
		       A.CARDORDERTYPE||'':''||B.CODEDESC  ORDERTYPE  ,       --订购类型
		       A.APPLYORDERID     ,                                   --需求单号
		       A.CARDTYPECODE||'':''||D.CARDTYPENAME    CARDTYPE ,    --卡片类型
		       A.CARDSURFACECODE||'':''||C.CARDSURFACENAME CARDFACE , --卡面类型
		       A.CARDSAMPLECODE,                                    --卡样编码
		       A.CARDNAME         ,                                 --卡片名称
		       A.CARDFACEAFFIRMWAY||'':''||J.CODEDESC  WAY,         --卡面确认方式
		       A.CARDNUM          ,                                 --卡片数量
		       A.REQUIREDATE      ,                                 --要求到货日期
		       A.LATELYDATE       ,                                 --最近到货日期
		       A.ALREADYARRIVENUM ,                                 --已到货数量
		       A.RETURNCARDNUM    ,                                 --退货数量
		       A.BEGINCARDNO      ,                                 --起始卡号
		       A.ENDCARDNO        ,                                 --结束卡号
		       A.CARDCHIPTYPECODE||'':''||F.CARDCHIPTYPENAME CARDCHIP,--卡芯片
		       A.COSTYPECODE||'':''||E.COSTYPE      COSTYPE,          --COS类型
		       A.MANUTYPECODE||'':''||G.MANUNAME    MANUNAME,         --卡片厂商
		       A.APPVERNO         ,                          --应用版本号
		       A.VALIDBEGINDATE   ,                          --起始有效日期
		       A.VALIDENDDATE     ,                          --结束有效日期
		       A.ORDERTIME        ,                          --下单时间
		       A.ORDERSTAFFNO||'':''||H.STAFFNAME  ORDERSTAFF, --下单员工
		       A.EXAMTIME         ,                          --审核时间
		       A.EXAMSTAFFNO||'':''||I.STAFFNAME   EXAMSTAFF,  --审核员工
		       A.REMARK           ,                          --备注
		       A.CARDORDERSTATE||'':''||K.CODEDESC  STATE      --审核状态
		FROM   TF_F_CARDORDER    A ,
		       TD_M_RMCODING     B ,
		       TD_M_CARDSURFACE  C ,
		       TD_M_CARDTYPE     D ,
		       TD_M_COSTYPE      E , --COS类型编码表
		       TD_M_CARDCHIPTYPE F , --芯片类型编码表
		       TD_M_MANU         G , --卡片厂商编码表
		       TD_M_INSIDESTAFF  H ,
		       TD_M_INSIDESTAFF  I ,
		       (SELECT CODEVALUE,CODEDESC
           FROM  TD_M_RMCODING
           WHERE COLNAME = ''CARDFACEAFFIRMWAY''
           AND TABLENAME = ''TF_F_APPLYORDER'') J ,
		       TD_M_RMCODING     K
		WHERE  A.CARDORDERTYPE = B.CODEVALUE
		AND    B.COLNAME = ''CARDORDERTYPE''
		AND    B.TABLENAME = ''TF_F_CARDORDER''
		AND    A.CARDFACEAFFIRMWAY = J.CODEVALUE(+)
		AND    A.CARDORDERSTATE = K.CODEVALUE
		AND    K.COLNAME = ''CARDORDERSTATE''
		AND    K.TABLENAME = ''TF_F_CARDORDER''
		AND    A.CARDSURFACECODE = C.CARDSURFACECODE(+)
		AND    A.CARDTYPECODE = D.CARDTYPECODE(+)
		AND    A.COSTYPECODE = E.COSTYPECODE(+)
		AND    A.CARDCHIPTYPECODE = F.CARDCHIPTYPECODE(+)
		AND    A.MANUTYPECODE = G.MANUCODE(+)
		AND    A.ORDERSTAFFNO = H.STAFFNO(+)
		AND    A.EXAMSTAFFNO = I.STAFFNO(+)
		AND    A.CARDORDERTYPE IN (''01'',''02'')
		AND    A.USETAG = ''1''
		AND   ('''||P_VAR1||''' IS NULL OR '''||P_VAR1||''' = '''' OR TO_DATE('''||P_VAR1||'000000'',''YYYYMMDDHH24MISS'') <= A.ORDERTIME)
		AND   ('''||P_VAR2||''' IS NULL OR '''||P_VAR2||''' = '''' OR TO_DATE('''||P_VAR2||'235959'',''YYYYMMDDHH24MISS'') >= A.ORDERTIME)
		AND   ('''||P_VAR4||''' IS NULL OR '''||P_VAR4||''' = '''' OR '''||P_VAR4||''' = A.CARDORDERID)
		AND   ('''||P_VAR5||''' IS NULL OR '''||P_VAR5||''' = '''' OR '''||P_VAR5||''' = A.APPLYORDERID)
		AND   ('''||P_VAR6||''' IS NULL OR '''||P_VAR6||''' = '''' OR '''||P_VAR6||''' = A.CARDSURFACECODE)
		'||v_sql||'
		ORDER BY A.ORDERTIME DESC';
elsif  p_funcCode = 'ChargeCardOrderQuery' then  --充值卡卡订购单查询 add by shil
	IF P_VAR3 IS NOT NULL THEN
		V_SQL := V_SQL||'AND  A.CARDORDERSTATE IN('||P_VAR3||')';
	END IF;
	DBMS_OUTPUT.PUT_LINE(V_SQL);
    open p_cursor for
		'SELECT A.CARDORDERID      ,                      --订购单号
		       A.APPLYORDERID     ,                      --需求单号
		       A.VALUECODE||'':''||B.VALUE CARDVALUE ,     --充值卡面值
		       A.CARDNUM          ,                      --卡片数量
		       A.REQUIREDATE      ,                      --要求到货日期
		       A.LATELYDATE       ,                      --最近到货日期
		       A.ALREADYARRIVENUM ,                      --已到货数量
		       A.RETURNCARDNUM    ,                      --退货数量
		       A.BEGINCARDNO      ,                      --起始卡号
		       A.ENDCARDNO        ,                      --结束卡号
		       A.ORDERTIME        ,                      --下单时间
		       A.ORDERSTAFFNO||'':''||C.STAFFNAME ORDERSTAFF,  --下单员工
		       A.EXAMTIME         ,                          --审核时间
		       A.EXAMSTAFFNO||'':''||D.STAFFNAME EXAMSTAFF ,   --审核员工
		       A.REMARK           ,                          --备注
		       A.CARDORDERSTATE||'':''||E.CODEDESC  STATE      --审核状态
		FROM   TF_F_CARDORDER    A ,
		       TP_XFC_CARDVALUE  B ,
		       TD_M_INSIDESTAFF  C ,
		       TD_M_INSIDESTAFF  D ,
		       TD_M_RMCODING     E
		WHERE  A.VALUECODE = B.VALUECODE(+)
		AND    A.CARDORDERSTATE = E.CODEVALUE
		AND    E.COLNAME = ''CARDORDERSTATE''
		AND    E.TABLENAME = ''TF_F_CARDORDER''
		AND    A.ORDERSTAFFNO = C.STAFFNO(+)
		AND    A.EXAMSTAFFNO = D.STAFFNO(+)
		AND    A.CARDORDERTYPE = ''03''
		AND    A.USETAG = ''1''
		AND   ('''||P_VAR1||''' IS NULL OR '''||P_VAR1||''' = '''' OR TO_DATE('''||P_VAR1||'000000'',''YYYYMMDDHH24MISS'') <= A.ORDERTIME)
		AND   ('''||P_VAR2||''' IS NULL OR '''||P_VAR2||''' = '''' OR TO_DATE('''||P_VAR2||'235959'',''YYYYMMDDHH24MISS'') >= A.ORDERTIME)
		AND   ('''||P_VAR4||''' IS NULL OR '''||P_VAR4||''' = '''' OR '''||P_VAR4||''' = A.CARDORDERID)
		AND   ('''||P_VAR5||''' IS NULL OR '''||P_VAR5||''' = '''' OR '''||P_VAR5||''' = A.APPLYORDERID)
		'||v_sql||'
		ORDER BY A.ORDERTIME DESC';

elsif  p_funcCode = 'QuerySignInUseCardSORDER' then  --查询签收入库卡所属订购单 add by shil
    open p_cursor for
		SELECT A.CARDORDERID      ,                                --订购单号
		       A.CARDORDERTYPE||':'||B.CODEDESC ORDERTYPE,         --订购类型
		       A.CARDTYPECODE||':'||D.CARDTYPENAME CARDTYPE,       --卡片类型
		       A.CARDSURFACECODE||':'||C.CARDSURFACENAME CARDFACE, --卡面类型
		       A.CARDNAME         ,                          --卡片名称
		       A.CARDNUM          ,                          --订购数量
		       A.BEGINCARDNO      ,                          --起始卡号
		       A.ENDCARDNO        ,                          --结束卡号
		       A.REQUIREDATE      ,                          --要求到货日期
		       A.LATELYDATE       ,                          --最近到货日期
		       A.ALREADYARRIVENUM ,                          --已到货数量
		       A.RETURNCARDNUM    ,                          --退货数量
		       A.MANUTYPECODE||':'||E.MANUNAME MANUNAME  ,   --卡片厂商
		       A.ORDERTIME        ,                          --下单时间
		       A.ORDERSTAFFNO||':'||F.STAFFNAME  STAFF  ,    --下单员工
		       A.REMARK                                      --备注
		FROM   TF_F_CARDORDER    A ,
		       TD_M_RMCODING     B ,
		       TD_M_CARDSURFACE  C ,
		       TD_M_CARDTYPE     D ,
		       TD_M_MANU         E , --卡片厂商编码表
		       TD_M_INSIDESTAFF  F
		WHERE  A.CARDORDERTYPE = B.CODEVALUE
		AND    B.COLNAME = 'CARDORDERTYPE'
		AND    B.TABLENAME = 'TF_F_CARDORDER'
		AND    A.CARDORDERSTATE IN ('1','3','4') --1审核通过，3部分到货，4全部到货
		AND    A.CARDSURFACECODE = C.CARDSURFACECODE
		AND    A.CARDTYPECODE = D.CARDTYPECODE
		AND    A.MANUTYPECODE = E.MANUCODE
		AND    A.ORDERSTAFFNO = F.STAFFNO
		AND    P_VAR1 = APPLYORDERID
		ORDER BY A.CARDORDERID DESC;

elsif  p_funcCode = 'QuerySignInChargeCardSORDER' then  --查询签收入库卡所属订购单 add by shil
    open p_cursor for
		SELECT A.CARDORDERID      ,                      --订购单号
		       A.VALUECODE||':'||B.VALUE CARDVALUE,      --充值卡面值
		       A.CARDNUM          ,                      --订购数量
		       A.BEGINCARDNO      ,                      --起始卡号
		       A.ENDCARDNO        ,                      --结束卡号
		       A.REQUIREDATE      ,                      --要求到货日期
		       A.LATELYDATE       ,                      --最近到货日期
		       A.ALREADYARRIVENUM ,                      --已到货数量
		       A.RETURNCARDNUM    ,                      --退货数量
		       A.ORDERTIME        ,                      --下单时间
		       A.ORDERSTAFFNO||':'||C.STAFFNAME STAFF,   --下单员工
		       A.REMARK                                  --备注
		FROM   TF_F_CARDORDER    A ,
		       TP_XFC_CARDVALUE  B ,
		       TD_M_INSIDESTAFF  C
		WHERE  A.VALUECODE = B.VALUECODE
		AND    A.ORDERSTAFFNO = C.STAFFNO
		AND    A.CARDORDERSTATE IN ('1','3','4') --1审核通过，3部分到货，4全部到货
		AND    P_VAR1 = APPLYORDERID
		ORDER BY A.CARDORDERID DESC;

elsif  p_funcCode = 'QuerySignInUseCardSApplyORDER' then  --查询签收入库用户卡所属需求单 add by shil
    open p_cursor for
    SELECT A.APPLYORDERID ,                                     --需求单号
		       A.APPLYORDERTYPE||':'||B.CODEDESC ORDERTYPE  ,       --需求单类型
		       A.CARDTYPECODE||':'||D.CARDTYPENAME CARDTYPE,        --卡类型
		       A.CARDSURFACECODE||':'||C.CARDSURFACENAME CARDFACE,  --卡面类型
		       A.CARDNAME      ,                            --卡片名称
		       A.CARDNUM       ,                            --下单数量
		       A.REQUIREDATE   ,                            --要求到货日期
		       A.REMARK        ,                            --备注
		       A.ORDERTIME     ,                            --下单时间
		       A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF, --下单员工
		       A.LATELYDATE    ,                            --最近到货日期
		       A.ALREADYARRIVENUM  ,                        --已到货数量
		       A.RETURNCARDNUM                              --退货数量
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_RMCODING    B ,
		       TD_M_CARDSURFACE C ,
		       TD_M_CARDTYPE    D ,
		       TD_M_INSIDESTAFF E
		WHERE  A.APPLYORDERTYPE = B.CODEVALUE
		AND    B.COLNAME = 'APPLYORDERTYPE'
		AND    B.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.CARDTYPECODE = D.CARDTYPECODE(+)
		AND    A.CARDSURFACECODE = C.CARDSURFACECODE(+)
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    A.APPLYORDERID = P_VAR1;

elsif  p_funcCode = 'QuerySignInChargeCardSApplyORDER' then		--查询签收入库充值卡所属需求单 add by shil
    open p_cursor for
		SELECT A.APPLYORDERID ,                             --需求单号
		       A.APPLYORDERTYPE||':'||B.CODEDESC ORDERTYPE ,--需求单类型
		       A.VALUECODE||':'||C.VALUE VALUECODE,         --充值卡面值
		       A.CARDNUM       ,                            --下单数量
		       A.REQUIREDATE   ,                            --要求到货日期
		       A.REMARK        ,                            --备注
		       A.ORDERTIME     ,                            --下单时间
		       A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF, --下单员工
		       A.LATELYDATE    ,                            --最近到货时间
		       A.ALREADYARRIVENUM  ,                        --已到货数量
		       A.RETURNCARDNUM                              --退货数量
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_RMCODING    B ,
		       TP_XFC_CARDVALUE C ,
		       TD_M_INSIDESTAFF E
		WHERE  A.APPLYORDERTYPE = B.CODEVALUE
		AND    B.COLNAME = 'APPLYORDERTYPE'
		AND    B.TABLENAME = 'TF_F_APPLYORDER'
		AND    A.VALUECODE = C.VALUECODE
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    A.APPLYORDERID = P_VAR1;

elsif  p_funcCode = 'STOCK_USECARD' then -- 查询用户卡库存
		IF p_var3 = '01' THEN
			open p_cursor for
			select '01' 卡片状态,卡片类型,卡面类型, sum(入库数量) 入库数量,sum(出库数量) 出库数量, sum(回收数量) 回收数量,卡样编码
			FROM (
			select b.cardtypecode ||':'|| b.cardtypename 卡片类型,
				T.cardsurfacecode ||':'|| T.cardsurfacename 卡面类型,
				T.total 入库数量,0 出库数量,0 回收数量,T.CARDSAMPLECODE 卡样编码
				from
				(
				SELECT c.cardsurfacecode,
				c.cardsurfacename,
				substr(c.cardsurfacecode,1,2) cardtypecode,
				c.CARDSAMPLECODE,
				count(a.cardno) total
				 FROM TD_M_CARDSURFACE c,
				 (select * from TL_R_ICUSER where
					 RESSTATECODE = '00') a --入库
				  where c.cardsurfacecode = a.cardsurfacecode(+)
				  and c.cardsurfacecode not in(SELECT CARDSURFACECODE FROM TD_M_USECARDWARNCONFIG)
				  group by c.cardsurfacecode,c.cardsurfacename,a.cardtypecode,c.CARDSAMPLECODE
				 ) T ,TD_M_CARDTYPE b
				 where T.cardtypecode = b.cardtypecode
					and (p_var1 = '' or p_var1 is null or b.cardtypecode = p_var1)
					and (p_var2 = '' or p_var2 is null or T.CARDSURFACECODE = p_var2)
			union
			select b.cardtypecode ||':'|| b.cardtypename 卡片类型,
				T.cardsurfacecode ||':'|| T.cardsurfacename 卡面类型,
				0 入库数量,T.total 出库数量,0 回收数量,T.CARDSAMPLECODE 卡样编码
				from
				(
				SELECT c.cardsurfacecode,
				c.cardsurfacename,
				substr(c.cardsurfacecode,1,2) cardtypecode,
				c.CARDSAMPLECODE,
				count(a.cardno) total
				 FROM TD_M_CARDSURFACE c,
				 (select * from TL_R_ICUSER where
					 RESSTATECODE in ('01','02')) a --出库;领用
				  where c.cardsurfacecode = a.cardsurfacecode(+)
				  and c.cardsurfacecode not in(SELECT CARDSURFACECODE FROM TD_M_USECARDWARNCONFIG)
				  group by c.cardsurfacecode,c.cardsurfacename,a.cardtypecode,c.CARDSAMPLECODE
				 ) T ,TD_M_CARDTYPE b
				 where T.cardtypecode = b.cardtypecode
					and (p_var1 = '' or p_var1 is null or b.cardtypecode = p_var1)
					and (p_var2 = '' or p_var2 is null or T.CARDSURFACECODE = p_var2)
      union
      select b.cardtypecode ||':'|| b.cardtypename 卡片类型,
				T.cardsurfacecode ||':'|| T.cardsurfacename 卡面类型,
				0 入库数量,0 出库数量,T.total 回收数量,T.CARDSAMPLECODE 卡样编码
				from
				(
				SELECT c.cardsurfacecode,
				c.cardsurfacename,
				substr(c.cardsurfacecode,1,2) cardtypecode,
				c.CARDSAMPLECODE,
				count(a.cardno) total
				 FROM TD_M_CARDSURFACE c,
				 (select * from TL_R_ICUSER where
					 RESSTATECODE = '04') a --回收
				  where c.cardsurfacecode = a.cardsurfacecode(+)
          and cardtypecode = '05'
				  and c.cardsurfacecode not in(SELECT CARDSURFACECODE FROM TD_M_USECARDWARNCONFIG)
				  group by c.cardsurfacecode,c.cardsurfacename,a.cardtypecode,c.CARDSAMPLECODE
				 ) T ,TD_M_CARDTYPE b
				 where T.cardtypecode = b.cardtypecode
					and (p_var1 = '' or p_var1 is null or b.cardtypecode = p_var1)
					and (p_var2 = '' or p_var2 is null or T.CARDSURFACECODE = p_var2)
			)
			GROUP BY 卡片类型,卡面类型,卡样编码 ORDER BY 卡片类型,卡面类型
				 ;
		ELSIF p_var3 = '02' THEN
			open p_cursor for
			select '02' 卡片状态,b.cardtypecode ||':'|| b.cardtypename 卡片类型,
				T.cardsurfacecode ||':'|| T.cardsurfacename 卡面类型,
				T.total 剩余数量,0 回收数量,T.CARDSAMPLECODE 卡样编码
				from
				(
				SELECT c.cardsurfacecode,
				c.cardsurfacename,
				substr(c.cardsurfacecode,1,2) cardtypecode,
				c.CARDSAMPLECODE,
				count(a.cardno) total
				 FROM TD_M_CARDSURFACE c,
				 (select * from TL_R_ICUSER where
					 RESSTATECODE = '15') a --下单
				  where c.cardsurfacecode = a.cardsurfacecode(+)
				  and c.cardsurfacecode not in(SELECT CARDSURFACECODE FROM TD_M_USECARDWARNCONFIG)
				  group by c.cardsurfacecode,c.cardsurfacename,a.cardtypecode,c.CARDSAMPLECODE
				 ) T ,TD_M_CARDTYPE b
				 where T.cardtypecode = b.cardtypecode
				and (p_var1 = '' or p_var1 is null or b.cardtypecode = p_var1)
				and (p_var2 = '' or p_var2 is null or T.CARDSURFACECODE = p_var2)
				 ORDER BY 卡片类型,卡面类型;
		END IF;
elsif  p_funcCode = 'STOCK_CHARGECARD' then -- 查询充值卡库存库存
		IF (p_var1 = '' or p_var1 is null) THEN
			IF p_var2 = '01' THEN
				open p_cursor for
					SELECT '01' 卡片状态,面值,sum(入库数量) 入库数量,sum(出库数量) 出库数量
					FROM (
					select f.valuecode||':'||f.VALUE 面值,count(t.XFCARDNO) 入库数量,0 出库数量
					  from TP_XFC_CARDVALUE f,
					  (select * from  TD_XFC_INITCARD
					  where CARDSTATECODE = '2' --入库
					  ) t
					  where f.VALUECODE = t.VALUECODE(+)
					  and f.VALUECODE not in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
					  group by f.VALUE,f.valuecode,t.CARDSTATECODE
					union
					select f.valuecode||':'||f.VALUE 面值,0 入库数量,count(t.XFCARDNO) 出库数量
					  from TP_XFC_CARDVALUE f,
					  (select * from  TD_XFC_INITCARD
					  where CARDSTATECODE = '3' --出库
					  ) t
					  where f.VALUECODE = t.VALUECODE(+)
					  and f.VALUECODE not in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
					  group by f.VALUE,f.valuecode,t.CARDSTATECODE
					)
					GROUP BY 面值 ORDER BY 面值;

			ELSIF p_var2 = '02' THEN
					open p_cursor for
					select 'C' 卡片状态,f.valuecode||':'||f.VALUE 面值,count(t.XFCARDNO) 剩余数量
						  from TP_XFC_CARDVALUE f,
						  (select * from  TD_XFC_INITCARD
						  where CARDSTATECODE = 'C' --下单
						  ) t
						  where f.VALUECODE = t.VALUECODE(+)
						  and f.VALUECODE not in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
						  group by f.VALUE,f.valuecode,t.CARDSTATECODE
						  ORDER BY f.valuecode;
			END IF;
		ELSE
			IF (p_var2 = '01') THEN
					open p_cursor for
					SELECT '01' 卡片状态,面值,sum(入库数量) 入库数量,sum(出库数量) 出库数量
					FROM (
					select f.valuecode||':'||f.VALUE 面值,count(*) 入库数量,0 出库数量
					  from TD_XFC_INITCARD t,TP_XFC_CARDVALUE f
					  where t.VALUECODE = f.VALUECODE(+)
					  and (p_var1 = '' or p_var1 is null or t.VALUECODE = p_var1)
					  and t.CARDSTATECODE = '2'	--入库
					  and f.VALUECODE not in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
					  group by f.VALUE,f.valuecode,t.CARDSTATECODE
					  union
					select f.valuecode||':'||f.VALUE 面值,0 入库数量,count(*) 出库数量
					  from TD_XFC_INITCARD t,TP_XFC_CARDVALUE f
					  where t.VALUECODE = f.VALUECODE(+)
					  and (p_var1 = '' or p_var1 is null or t.VALUECODE = p_var1)
					  and t.CARDSTATECODE = '3'  --出库
					  and f.VALUECODE not in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
					  group by f.VALUE,f.valuecode,t.CARDSTATECODE
					)
					GROUP BY 面值 ORDER BY 面值;
			ELSIF (p_var2 = '02') THEN
					open p_cursor for
					select 'C' 卡片状态,f.valuecode||':'||f.VALUE 面值,0 入库数量,count(*) 出库数量
					  from TD_XFC_INITCARD t,TP_XFC_CARDVALUE f
					  where t.VALUECODE = f.VALUECODE(+)
					  and (p_var1 = '' or p_var1 is null or t.VALUECODE = p_var1)
					  and t.CARDSTATECODE = 'C'  --下单
					  and f.VALUECODE not in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
					  group by f.VALUE,f.valuecode,t.CARDSTATECODE;
			END IF;
		END IF;

   elsif p_funcCode = 'USECARD_NOAPPROVED' then -- 查询未审批的用户卡申请单  add by Yin
      open p_cursor for
      select
      t.getcardorderid , --领用单号
      m.cardtypecode,    --卡片类型编码
      m.cardtypename ,   --卡片类型名称
      s.cardsurfacecode, --卡面类型编码
      s.cardsurfacename ,	--卡面类型名称
      t.applygetnum ,     --申请领用数量
      t.useway ,          --用途
      t.ordertime ,        --申请时间
      t.orderstaffno ,	  --申请员工编码
      st.staffname,      --申请员工名称
      de.departno,	         --申请部门编码
      de.departname ,	     --申请部门名称
      t.remark 			      --备注
      from  TF_F_GETCARDORDER t
      inner join td_m_cardtype m on t.cardtypecode = m.cardtypecode
      inner join td_m_cardsurface s on t.cardsurfacecode = s.cardsurfacecode
      inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
      inner join td_m_insidedepart de on st.departno = de.departno
      where t.GETCARDORDERTYPE = '01' and  t.GETCARDORDERSTATE = '0'
      order by t.getcardorderid desc;

elsif p_funcCode = 'CHARGECARD_NOAPPROVED' then -- 查询未审批的充值卡申请单  add by Yin
      open p_cursor for
      select
      t.getcardorderid ,    --领用单号
      m.valuecode,          --面额编码
      m.value ,						 --面额
      t.applygetnum ,      --申请领用数量
      t.useway ,           --用途
      t.ordertime ,        --申请时间
      t.orderstaffno ,     --申请员工编码
      st.staffname,		     --申请员工名称
      de.departno,				--申请部门编码
      de.departname ,			--申请部门名称
      t.remark 						--备注
      from  TF_F_GETCARDORDER t
      inner join TP_XFC_CARDVALUE m on m.VALUECODE = t.valuecode
      inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
      inner join td_m_insidedepart de on st.departno = de.departno
      where t.GETCARDORDERTYPE = '02'and	t.GETCARDORDERSTATE = '0'
      order by t.getcardorderid desc;
elsif p_funcCode = 'USECARD_APPROVED' then -- 查询审批通过的用户卡申请单  add by Yin
      if p_var5 = '0' then
        open p_cursor for
            select
            t.getcardorderid ,  -- 领用单号
            m.cardtypecode,    --卡片类型
            m.cardtypename ,  --卡片类型名称
            s.cardsurfacecode, --卡面类型编码
            s.cardsurfacename ,--卡面类型名称
            t.applygetnum ,  --申请领用数量
            t.agreegetnum ,  --同意领用数量
            t.alreadygetnum , --已经领用数量
            t.useway ,  --用途
            t.ordertime ,  --申请时间
            t.orderstaffno , --领用员工
            st.staffname,		--领用员工名称
            de.departname ,--领用部门名称
            t.remark 						 --备注
            from  TF_F_GETCARDORDER t
            inner join td_m_cardtype m on t.cardtypecode = m.cardtypecode
            inner join td_m_cardsurface s on t.cardsurfacecode = s.cardsurfacecode
            inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
            inner join td_m_insidedepart de on st.departno = de.departno
            where
            (p_var1 is null or t.getcardorderid = p_var1)
            and (p_var2 is null or t.getstaffno = p_var2)
            and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') >= p_var3)
            and (p_var4 is null or to_char(t.ordertime,'yyyymmdd') <= p_var4)
            and (t.getcardorderstate = '1'  or t.getcardorderstate = '3' or t.getcardorderstate = '4')
            and t.PRINTCOUNT >= p_var6 and (p_var7 is null or t.PRINTCOUNT <= p_var7)
            order by t.getcardorderid desc;
      elsif p_var5 = '1' then
          open p_cursor for
            select
            t.getcardorderid ,  -- 领用单号
            m.cardtypecode,    --卡片类型
            m.cardtypename ,  --卡片类型名称
            s.cardsurfacecode, --卡面类型编码
            s.cardsurfacename ,--卡面类型名称
            t.applygetnum ,  --申请领用数量
            t.agreegetnum ,  --同意领用数量
            t.alreadygetnum , --已经领用数量
            t.useway ,  --用途
            t.ordertime ,  --申请时间
            t.orderstaffno , --领用员工
            st.staffname,		--领用员工名称
            de.departname ,--领用部门名称
            t.remark 						 --备注
            from  TF_F_GETCARDORDER t
            inner join td_m_cardtype m on t.cardtypecode = m.cardtypecode
            inner join td_m_cardsurface s on t.cardsurfacecode = s.cardsurfacecode
            inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
            inner join td_m_insidedepart de on st.departno = de.departno
            where  --(t.getcardorderstate = '1'  or t.getcardorderstate = '3') and
            (p_var1 is null or t.getcardorderid = p_var1)
            and (p_var2 is null or t.getstaffno = p_var2)
            and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') >= p_var3)
            and (p_var4 is null or to_char(t.ordertime,'yyyymmdd') <= p_var4)
            and (t.getcardorderstate = '1'  or t.getcardorderstate = '3')
            and t.PRINTCOUNT >= p_var6 and (p_var7 is null or t.PRINTCOUNT <= p_var7)
            order by t.getcardorderid desc;
      elsif p_var5 = '2' then
          open p_cursor for
            select
            t.getcardorderid ,  -- 领用单号
            m.cardtypecode,    --卡片类型
            m.cardtypename ,  --卡片类型名称
            s.cardsurfacecode, --卡面类型编码
            s.cardsurfacename ,--卡面类型名称
            t.applygetnum ,  --申请领用数量
            t.agreegetnum ,  --同意领用数量
            t.alreadygetnum , --已经领用数量
            t.useway ,  --用途
            t.ordertime ,  --申请时间
            t.orderstaffno , --领用员工
            st.staffname,		--领用员工名称
            de.departname ,--领用部门名称
            t.remark 						 --备注
            from  TF_F_GETCARDORDER t
            inner join td_m_cardtype m on t.cardtypecode = m.cardtypecode
            inner join td_m_cardsurface s on t.cardsurfacecode = s.cardsurfacecode
            inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
            inner join td_m_insidedepart de on st.departno = de.departno
            where  --(t.getcardorderstate = '1'  or t.getcardorderstate = '3') and
            (p_var1 is null or t.getcardorderid = p_var1)
            and (p_var2 is null or t.getstaffno = p_var2)
            and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') >= p_var3)
            and (p_var4 is null or to_char(t.ordertime,'yyyymmdd') <= p_var4)
            and t.PRINTCOUNT >= p_var6 and (p_var7 is null or t.PRINTCOUNT <= p_var7)
            and  t.getcardorderstate = '4'
            order by t.getcardorderid desc;
      end if;
elsif p_funcCode = 'CHARGECARD_APPROVED' then -- 查询审批通过的充值卡申请单  add by Yin
      if p_var5 = '0' then
        open p_cursor for
          select
          t.getcardorderid, --领用单号
          m.valuecode, --面额编码
          m.value,				--面额
          t.applygetnum, --申请领用数量
          t.agreegetnum, --同意领用数量
          t.alreadygetnum, --已经领用数量
          t.useway, --用途
          t.ordertime, --申请时间
          t.orderstaffno,	 --申请员工
          st.staffname,		--申请员工名称
          de.departname, --部门名称
          t.remark			--备注
          from  TF_F_GETCARDORDER t
          inner join TP_XFC_CARDVALUE m on m.VALUECODE = t.valuecode
          inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
          inner join td_m_insidedepart de on st.departno = de.departno
          where (t.getcardorderstate = '1' or t.getcardorderstate = '3' or t.getcardorderstate = '4')
          and (p_var1 is null or t.getcardorderid = p_var1)
          and (p_var2 is null or t.getstaffno = p_var2)
          and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') >= p_var3)
          and (p_var4 is null or to_char(t.ordertime,'yyyymmdd') <= p_var4)
          and t.PRINTCOUNT >= p_var6 and (p_var7 is null or t.PRINTCOUNT <= p_var7)
          order by t.getcardorderid desc;
      elsif p_var5 = '1' then
        open p_cursor for
          select
          t.getcardorderid, --领用单号
          m.valuecode, --面额编码
          m.value,				--面额
          t.applygetnum, --申请领用数量
          t.agreegetnum, --同意领用数量
          t.alreadygetnum, --已经领用数量
          t.useway, --用途
          t.ordertime, --申请时间
          t.orderstaffno,	 --申请员工
          st.staffname,		--申请员工名称
          de.departname, --部门名称
          t.remark			--备注
          from  TF_F_GETCARDORDER t
          inner join TP_XFC_CARDVALUE m on m.VALUECODE = t.valuecode
          inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
          inner join td_m_insidedepart de on st.departno = de.departno
          where (t.getcardorderstate = '1' or t.getcardorderstate = '3')
          and (p_var1 is null or t.getcardorderid = p_var1)
          and (p_var2 is null or t.getstaffno = p_var2)
          and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') >= p_var3)
          and (p_var4 is null or to_char(t.ordertime,'yyyymmdd') <= p_var4)
          and t.PRINTCOUNT >= p_var6 and (p_var7 is null or t.PRINTCOUNT <= p_var7)
          order by t.getcardorderid desc;
      elsif p_var5 = '2' then
        open p_cursor for
          select
          t.getcardorderid, --领用单号
          m.valuecode, --面额编码
          m.value,				--面额
          t.applygetnum, --申请领用数量
          t.agreegetnum, --同意领用数量
          t.alreadygetnum, --已经领用数量
          t.useway, --用途
          t.ordertime, --申请时间
          t.orderstaffno,	 --申请员工
          st.staffname,		--申请员工名称
          de.departname, --部门名称
          t.remark			--备注
          from  TF_F_GETCARDORDER t
          inner join TP_XFC_CARDVALUE m on m.VALUECODE = t.valuecode
          inner join td_m_insidestaff st on t.ORDERSTAFFNO =  st.STAFFNO
          inner join td_m_insidedepart de on st.departno = de.departno
          where (t.getcardorderstate = '4')
          and (p_var1 is null or t.getcardorderid = p_var1)
          and (p_var2 is null or t.getstaffno = p_var2)
          and (p_var3 is null or to_char(t.ordertime,'yyyymmdd') >= p_var3)
          and (p_var4 is null or to_char(t.ordertime,'yyyymmdd') <= p_var4)
          and t.PRINTCOUNT >= p_var6 and (p_var7 is null or t.PRINTCOUNT <= p_var7)
          order by t.getcardorderid desc;
      end if;
elsif p_funcCode = 'USECARD_DEPART' then
		  open p_cursor for
		  select tm.DEPARTNO||':'||tm.DEPARTNAME 网点,count(tr.CARDNO) 数量
		  from (SELECT * FROM TL_R_ICUSER where RESSTATECODE = '01' and CARDTYPECODE = p_var1 and CARDSURFACECODE = p_var2) tr,TD_M_INSIDEDEPART tm
		  where tm.DEPARTNO = tr.ASSIGNEDDEPARTID
		  group by tm.DEPARTNO,tm.DEPARTNAME
		  order by 数量 desc;
elsif p_funcCode = 'GIFTUSECARD_DEPART' then
      open p_cursor for
		  select 网点,sum(数量) 数量, sum(回收数量) 回收数量
			FROM (
			select T.DEPARTNO||':'||T.DEPARTNAME 网点,
        count(T.CARDNO) 数量,0 回收数量
        from
        (
        SELECT a.cardno,b.departno,b.departname FROM TL_R_ICUSER a,TD_M_INSIDEDEPART b
         where a.RESSTATECODE='01'
         and a.CARDTYPECODE = p_var1
         and a.CARDSURFACECODE = p_var2
         and a.assigneddepartid = b.departno
         ) T
         group by t.departno,t.departname
			union
			select T.DEPARTNO||':'||T.DEPARTNAME 网点,
        0 数量,count(T.CARDNO) 回收数量
        from
        (
        SELECT a.cardno,b.departno,b.departname FROM TL_R_ICUSER a,TD_M_INSIDEDEPART b
         where a.RESSTATECODE='04'
         and a.CARDTYPECODE = p_var1
         and a.CARDSURFACECODE = p_var2
         and a.assigneddepartid = b.departno
         ) T
         group by t.departno,t.departname
         )
         group by 网点 order by 数量;
elsif p_funcCode = 'CHARGE_DEPART' then
		  open p_cursor for
		  select tm.DEPARTNO||':'||tm.DEPARTNAME 网点,count(tr.XFCARDNO) 数量
		  from TD_M_INSIDEDEPART tm,(select * from TD_XFC_INITCARD where CARDSTATECODE = '3' and VALUECODE = p_var1) tr
		  where tm.DEPARTNO = tr.ASSIGNDEPARTNO
		  group by tm.DEPARTNO,tm.DEPARTNAME
		  order by 数量 desc;
elsif p_funcCode = 'HISTORY_USECARD' then
		  open p_cursor for
		  select b.CARDTYPECODE ||':'|| b.CARDTYPENAME 卡片类型,c.CARDSURFACECODE ||':'|| c.CARDSURFACENAME 卡面类型,
		  a.BEGINCARDNO 起始卡号,a.ENDCARDNO 终止卡号,
		  a.ASSIGNEDDEPARTID ||':'|| e.DEPARTNAME 领用部门,a.ASSIGNEDSTAFFNO ||':'|| d.STAFFNAME 领用员工,a.OPERATETIME 领用时间,
		  SUM(to_number(substr(a.ENDCARDNO,-8))-to_number(substr(a.BEGINCARDNO,-8))+1) 领用数量
		  from TF_R_ICUSERTRADE a,TD_M_CARDTYPE b,TD_M_CARDSURFACE c,TD_M_INSIDESTAFF d,TD_M_INSIDEDEPART e
		  where SUBSTR(a.ENDCARDNO,5,2) = b.CARDTYPECODE(+)
		  and SUBSTR(a.ENDCARDNO,5,4) = c.CARDSURFACECODE(+)
		  and a.ASSIGNEDSTAFFNO = d.STAFFNO(+)
		  and a.ASSIGNEDDEPARTID = e.DEPARTNO(+)
		  and a.OPETYPECODE in ('01')
		  and (p_var1 = '' or p_var1 is null or a.CARDTYPECODE = p_var1)
		  and (p_var2 = '' or p_var2 is null or a.CARDSURFACECODE = p_var2)
		  and (p_var3 = '' or p_var3 is null or a.ASSIGNEDSTAFFNO = p_var3)
		  and (p_var4 IS NULL OR p_var4 = '' OR a.OPERATETIME >=TO_DATE(p_var4||'000000','YYYYMMDDHH24MISS'))
		  and (p_var5 IS NULL OR p_var5 = '' OR a.OPERATETIME <= TO_DATE(p_var5||'235959','YYYYMMDDHH24MISS'))
		  and (p_var6 = '' or p_var6 is null or a.ASSIGNEDDEPARTID = p_var6)
		  and (p_var7 is null or p_var7 = '' or p_var7 between a.BEGINCARDNO and a.ENDCARDNO)
		  group by b.CARDTYPECODE,b.CARDTYPENAME,c.CARDSURFACECODE,c.CARDSURFACENAME,a.ASSIGNEDSTAFFNO,
		  d.STAFFNAME,a.OPERATETIME,a.ASSIGNEDDEPARTID,e.DEPARTNAME,a.BEGINCARDNO,a.ENDCARDNO
		  order by b.CARDTYPECODE , c.CARDSURFACECODE , a.OPERATETIME desc;
elsif p_funcCode = 'HISTORY_CHARGECARD' then
		  open p_cursor for
		  select t.valuecode||':'||x.VALUE 面值,t.startcardno 起始卡号,t.ENDCARDNO 终止卡号,
		  t.GETDEPARTID ||':'|| e.DEPARTNAME 领用部门,t.GETSTAFFNO ||':'|| f.STAFFNAME 领用员工,t.OPERTIME 领用时间,
		  SUM(to_number(substr(t.ENDCARDNO,-8))-to_number(substr(t.startcardno,-8))+1) 领用数量
		  from TL_XFC_MANAGELOG t,TD_M_INSIDESTAFF f,TP_XFC_CARDVALUE x,TD_M_INSIDEDEPART e
		  where t.GETSTAFFNO = f.STAFFNO(+)
		  and t.valuecode = x.valuecode(+)
		  and t.OPERTYPECODE in ('03')
		  and t.GETDEPARTID = e.DEPARTNO(+)
		  and (p_var1 = '' or p_var1 is null or t.valuecode = p_var1)
		  and  (p_var2 IS NULL OR p_var2 = '' OR t.OPERTIME >= TO_DATE(p_var2||'000000','YYYYMMDDHH24MISS'))
		  and  (p_var3 IS NULL OR p_var3 = '' OR t.OPERTIME <= TO_DATE(p_var3||'235959','YYYYMMDDHH24MISS'))
		  and (p_var4 = '' or p_var4 is null or t.GETSTAFFNO = p_var4)
		  and (p_var5 = '' or p_var5 is null or t.GETDEPARTID = p_var5)
		  and (p_var6 is null or p_var6 = '' or p_var6 between t.startcardno and t.ENDCARDNO)
		  group by t.valuecode,x.VALUE,t.GETSTAFFNO,F.STAFFNAME,T.OPERTIME,t.startcardno,t.ENDCARDNO,
		  t.GETDEPARTID,e.DEPARTNAME
		  order by x.VALUE , t.OPERTIME desc;
elsif p_funcCode = 'WARN_USECARD' then
      BEGIN
		 IF p_VAR3 = '0' THEN
     open p_cursor for
			SELECT a.CARDTYPECODE || ':' || a.CARDTYPENAME 卡片类型,b.CARDSURFACECODE || ':' || b.CARDSURFACENAME 卡面类型
			FROM TD_M_CARDTYPE a,TD_M_CARDSURFACE b
			WHERE a.CARDTYPECODE = substr(b.CARDSURFACECODE,1,2)
			AND (P_VAR1 IS NULL OR P_VAR1 = '' OR a.CARDTYPECODE = P_VAR1)
			AND (p_VAR2 IS NULL OR p_VAR2 = '' OR b.CARDSURFACECODE = p_VAR2)
			AND b.CARDSURFACECODE not in (select CARDSURFACECODE from TD_M_USECARDWARNCONFIG)
			ORDER BY a.CARDTYPECODE,b.CARDSURFACECODE;
		ELSIF p_VAR3 = '1' THEN
    open p_cursor for
			SELECT a.CARDTYPECODE || ':' || a.CARDTYPENAME 卡片类型,b.CARDSURFACECODE || ':' || b.CARDSURFACENAME 卡面类型
			FROM TD_M_CARDTYPE a,TD_M_CARDSURFACE b
			WHERE a.CARDTYPECODE = substr(b.CARDSURFACECODE,1,2)
			AND (P_VAR1 IS NULL OR P_VAR1 = '' OR a.CARDTYPECODE = P_VAR1)
			AND (p_VAR2 IS NULL OR p_VAR2 = '' OR b.CARDSURFACECODE = p_VAR2)
			AND b.CARDSURFACECODE in (select CARDSURFACECODE from TD_M_USECARDWARNCONFIG)
			ORDER BY a.CARDTYPECODE,b.CARDSURFACECODE;
		END IF;
		END;
elsif p_funcCode = 'WARN_CHARGECARD' then
      BEGIN
		 IF p_VAR2 = '0' THEN
     open p_cursor for
			SELECT a.VALUECODE || ':' || a.VALUE 面值
			FROM TP_XFC_CARDVALUE a
			WHERE (P_VAR1 IS NULL OR P_VAR1 = '' OR a.VALUECODE = P_VAR1)
			AND a.VALUECODE not in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
			ORDER BY a.VALUECODE;
		ELSIF p_VAR2 = '1' THEN
    open p_cursor for
			SELECT a.VALUECODE || ':' || a.VALUE 面值
			FROM TP_XFC_CARDVALUE a
			WHERE (P_VAR1 IS NULL OR P_VAR1 = '' OR a.VALUECODE = P_VAR1)
			AND a.VALUECODE in (select VALUECODE from TD_M_CHCARDWARNCONFIG)
			ORDER BY a.VALUECODE;
		END IF;
		END;
elsif p_funcCode = 'CARDFACE' then
		BEGIN
		IF p_VAR3 = '0' THEN
		open p_cursor for
		select a.CARDTYPECODE ||':'|| a.CARDTYPENAME 卡片类型,b.CARDSURFACECODE ||':'|| b.CARDSURFACENAME 卡面类型,
			b.CARDSURFACENOTE 卡面类型说明,b.CARDSAMPLECODE 卡样编码,decode(b.USETAG,'0','无效','1','有效') 有效标志,
			b.UPDATESTAFFNO ||':'|| m.STAFFNAME 更新员工,b.UPDATETIME 更新时间
		from TD_M_CARDTYPE a,TD_M_CARDSURFACE b,TD_M_INSIDESTAFF m
		where a.CARDTYPECODE = substr(b.CARDSURFACECODE,1,2)
			and b.UPDATESTAFFNO = m.STAFFNO(+)
			and (P_VAR1 = '' or P_VAR1 is null or a.CARDTYPECODE = P_VAR1)
			and (p_VAR2 = '' or p_VAR2 is null or b.CARDSURFACECODE = p_VAR2)
      ORDER BY A.CARDTYPECODE,B.CARDSURFACECODE;
		ELSIF p_VAR3 = '1' THEN
		open p_cursor for
		select a.CARDTYPECODE ||':'|| a.CARDTYPENAME 卡片类型,b.CARDSURFACECODE ||':'|| b.CARDSURFACENAME 卡面类型,
			b.CARDSURFACENOTE 卡面类型说明,b.CARDSAMPLECODE 卡样编码,decode(b.USETAG,'0','无效','1','有效') 有效标志,
			b.UPDATESTAFFNO ||':'|| m.STAFFNAME 更新员工,b.UPDATETIME 更新时间
		from TD_M_CARDTYPE a,TD_M_CARDSURFACE b,TD_M_INSIDESTAFF m
		where a.CARDTYPECODE = substr(b.CARDSURFACECODE,1,2)
			and b.UPDATESTAFFNO = m.STAFFNO(+)
			and (P_VAR1 = '' or P_VAR1 is null or a.CARDTYPECODE = P_VAR1)
			and (p_VAR2 = '' or p_VAR2 is null or b.CARDSURFACECODE = p_VAR2)
			and (b.CARDSAMPLECODE is not null)
      ORDER BY A.CARDTYPECODE,B.CARDSURFACECODE;
		ELSIF p_VAR3 = '2' THEN
		open p_cursor for
		select a.CARDTYPECODE ||':'|| a.CARDTYPENAME 卡片类型,b.CARDSURFACECODE ||':'|| b.CARDSURFACENAME 卡面类型,
			b.CARDSURFACENOTE 卡面类型说明,decode(b.USETAG,'0','无效','1','有效') 有效标志,
			b.UPDATESTAFFNO ||':'|| m.STAFFNAME 更新员工,b.UPDATETIME 更新时间
		from TD_M_CARDTYPE a,TD_M_CARDSURFACE b,TD_M_INSIDESTAFF m
		where a.CARDTYPECODE = substr(b.CARDSURFACECODE,1,2)
			and b.UPDATESTAFFNO = m.STAFFNO(+)
			and (P_VAR1 = '' or P_VAR1 is null or a.CARDTYPECODE = P_VAR1)
			and (p_VAR2 = '' or p_VAR2 is null or b.CARDSURFACECODE = p_VAR2)
			and (b.CARDSAMPLECODE is null or b.CARDSAMPLECODE = '')
      ORDER BY A.CARDTYPECODE,B.CARDSURFACECODE;
		END IF;
		END;
ELSIF p_funcCode = 'CARDSECTION' then
	open p_cursor for
		select b.CARDNOCONFIGID,b.CARDTYPECODE ||':'|| a.CARDTYPENAME 卡片类型,b.BEGINCARDNO 起始号码,b.ENDCARDNO 终止号码
		from TD_M_CARDTYPE a,TD_M_CARDNOCONFIG b
		where b.CARDTYPECODE= a.CARDTYPECODE(+)
			and B.USETAG <> '0'
			and (P_VAR1 = '' or P_VAR1 is null or b.CARDTYPECODE = P_VAR1)
		ORDER BY b.CARDTYPECODE,b.BEGINCARDNO;

elsif p_funcCode = 'APPLYORDERSEARCH' then -- 根据需求单号查询出所有需要打印的存货补货卡或者新制卡需求单 add by Yin
    open p_cursor for

    'SELECT A.APPLYORDERID ,
		       A.CARDTYPECODE || '':'' || D.CARDTYPENAME CARDTYPE,
		       A.CARDSURFACECODE || '':'' || C.CARDSURFACENAME CARDFACE,
		       A.CARDSAMPLECODE,
		       A.CARDNUM       ,
		       A.CARDNAME      ,
		       decode(A.CARDFACEAFFIRMWAY,''1'',''1:电子'',''2'',''2:样卡'',''3'',''3:不需要确认'',A.CARDFACEAFFIRMWAY) CARDFACEAFFIRMWAY ,
		       A.REQUIREDATE   ,
		       A.ORDERDEMAND   ,
		       A.REMARK        ,
		       A.ORDERTIME     ,
		       A.ORDERSTAFFNO || '':''|| E.STAFFNAME ORDERSTAFF ,
		       F.DEPARTNO || '':'' || F.DEPARTNAME DEPARTNAME
		FROM   TF_F_APPLYORDER  A ,
		       TD_M_CARDSURFACE C ,
		       TD_M_CARDTYPE    D ,
		       TD_M_INSIDESTAFF E,
		       td_m_insidedepart F

		WHERE  A.CARDTYPECODE = D.CARDTYPECODE
		AND    A.CARDSURFACECODE = C.CARDSURFACECODE
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    E.DEPARTNO = F.DEPARTNO
    AND    A.APPLYORDERID in (' || p_var1 || ')
		AND    A.USETAG = ''1''
		ORDER BY A.ORDERTIME DESC';

elsif   p_funcCode = 'APPLYCHARGECARDSEARCH' then -- 根据需求单号查询出所有需要打印的充值卡需求单 add by Yin
    open p_cursor for
		'SELECT A.APPLYORDERID ,
		       A.VALUECODE || '':'' || C.VALUE VALUECODE,
		       A.CARDNUM       ,
		       A.REQUIREDATE   ,
		       A.ORDERDEMAND   ,
		       A.REMARK        ,
		       A.ORDERTIME     ,
		       A.ORDERSTAFFNO || '':''|| E.STAFFNAME ORDERSTAFF,
           F.DEPARTNO || '':'' || F.DEPARTNAME DEPARTNAME
		FROM   TF_F_APPLYORDER  A ,
		       TP_XFC_CARDVALUE C ,
		       TD_M_INSIDESTAFF E ,
           td_m_insidedepart F

		WHERE  A.VALUECODE = C.VALUECODE
		AND    A.ORDERSTAFFNO = E.STAFFNO
		AND    E.DEPARTNO = F.DEPARTNO
    AND    A.APPLYORDERID in (' || p_var1 || ')
		AND    A.USETAG = ''1''
		ORDER BY A.ORDERTIME DESC';

elsif  p_funcCode = 'USERCARDORDERSEARCH' then -- 根据订购单号查询出所有需要打印的用户卡订购单 add by Yin
    open p_cursor for
		'SELECT A.CARDORDERID,
		       A.CARDTYPECODE || '':'' || D.CARDTYPENAME    CARDTYPE ,
		       A.CARDSURFACECODE || '':'' || C.CARDSURFACENAME CARDFACE ,
		       A.CARDSAMPLECODE,
		       A.CARDNAME,
		       A.CARDNUM          ,
		       A.REQUIREDATE      ,
		       A.BEGINCARDNO      ,
		       A.ENDCARDNO        ,
		       A.ORDERSTAFFNO || '':'' || H.STAFFNAME  ORDERSTAFF,
           F.DEPARTNO || '':'' || F.DEPARTNAME DEPARTNAME,
		       A.REMARK
		FROM   TF_F_CARDORDER    A ,
		       TD_M_CARDSURFACE  C ,
		       TD_M_CARDTYPE     D ,
		       TD_M_INSIDESTAFF  H ,
           td_m_insidedepart F
		WHERE  A.CARDSURFACECODE = C.CARDSURFACECODE
		AND    A.CARDTYPECODE = D.CARDTYPECODE
		AND    A.ORDERSTAFFNO = H.STAFFNO
    AND    H.DEPARTNO = F.DEPARTNO
		AND    A.USETAG = ''1''
		AND    A.CARDORDERID in (' ||  p_var1 ||  ')
		ORDER BY A.ORDERTIME DESC';

elsif p_funcCode = 'CHARGECARDORDERSEARCH' then -- 根据订购单号查询出所有需要打印的充值卡订购单 add by Yin

    open p_cursor for
		'SELECT A.CARDORDERID      ,
		       A.VALUECODE || '':'' || B.VALUE CARDVALUE ,
		       A.CARDNUM          ,
		       A.REQUIREDATE      ,
		       A.BEGINCARDNO      ,
		       A.ENDCARDNO        ,
		       A.ORDERTIME        ,
		       A.ORDERSTAFFNO || '':'' || C.STAFFNAME ORDERSTAFF,
           F.DEPARTNO || '':'' || F.DEPARTNAME ,
		       A.REMARK
		FROM   TF_F_CARDORDER    A ,
		       TP_XFC_CARDVALUE  B ,
		       TD_M_INSIDESTAFF  C ,
		       td_m_insidedepart F
		WHERE  A.VALUECODE = B.VALUECODE
		AND    A.ORDERSTAFFNO = C.STAFFNO
    AND    C.DEPARTNO = F.DEPARTNO
		AND    A.USETAG = ''1''
		AND    A.CARDORDERID in (' ||  p_var1 ||  ')
		ORDER BY A.ORDERTIME DESC';

ELSIF p_funcCode = 'TD_M_CARDSURFACE' then	--卡面过滤
	open p_cursor for
		select CARDSURFACENAME, CARDSURFACECODE from TD_M_CARDSURFACE
		where CARDSURFACECODE not in (select CARDSURFACECODE from TD_M_USECARDWARNCONFIG)
		and (P_VAR1 = '' or P_VAR1 is null or substr(CARDSURFACECODE,1,2) = P_VAR1)
		order by CARDSURFACECODE;
ELSIF p_funcCode = 'TP_XFC_CARDVALUESELECT' THEN --面值过滤
	open p_cursor for
		select t.VALUE,t.VALUECODE from TP_XFC_CARDVALUE t
		where VALUECODE NOT IN(select VALUECODE from TD_M_CHCARDWARNCONFIG)
		ORDER BY t.VALUECODE;
ELSIF p_funcCode = 'GETCARDSAMPLECODE' THEN	--查询出卡样
	open p_cursor for
		SELECT CARDSAMPLECODE FROM TD_M_CARDSURFACE WHERE CARDSURFACECODE = P_VAR1;
elsif p_funcCode = 'GETUSECARDREPORT' then --用户卡领用历史统计
		  open p_cursor for
		  select e.DEPARTNAME 领用部门,b.CARDTYPENAME 卡片类型,c.CARDSURFACENAME 卡面类型,
		  SUM(to_number(substr(a.ENDCARDNO,-8))-to_number(substr(a.BEGINCARDNO,-8))+1) 领用数量
		  from TF_R_ICUSERTRADE a,TD_M_CARDTYPE b,TD_M_CARDSURFACE c,TD_M_INSIDEDEPART e
		  where SUBSTR(a.ENDCARDNO,5,2) = b.CARDTYPECODE(+)
		  and SUBSTR(a.ENDCARDNO,5,4) = c.CARDSURFACECODE(+)
		  and a.ASSIGNEDDEPARTID = e.DEPARTNO(+)
		  and a.OPETYPECODE in ('01')
		  and (p_var1 = '' or p_var1 is null or SUBSTR(a.ENDCARDNO,5,2) = p_var1)
		  and (p_var2 = '' or p_var2 is null or SUBSTR(a.ENDCARDNO,5,4) = p_var2)
		  and (p_var3 IS NULL OR p_var3 = '' OR a.OPERATETIME >=TO_DATE(p_var3||'000000','YYYYMMDDHH24MISS'))
		  and (p_var4 IS NULL OR p_var4 = '' OR a.OPERATETIME <= TO_DATE(p_var4||'235959','YYYYMMDDHH24MISS'))
		  and (p_var5 = '' or p_var5 is null or a.ASSIGNEDDEPARTID = p_var5)
		  group by b.CARDTYPENAME,c.CARDSURFACENAME,e.DEPARTNAME
		  order by e.DEPARTNAME,b.CARDTYPENAME,c.CARDSURFACENAME desc;
elsif p_funcCode = 'GETCHARGECARDREPORT' then --充值卡领用历史统计
		  open p_cursor for
		  select e.DEPARTNAME 领用部门,x.VALUE 面值,SUM(to_number(substr(t.ENDCARDNO,-8))-to_number(substr(t.startcardno,-8))+1) 领用数量
		  from TL_XFC_MANAGELOG t,TD_M_INSIDESTAFF f,TP_XFC_CARDVALUE x,TD_M_INSIDEDEPART e
		  where t.STAFFNO = f.STAFFNO(+)
		  and t.valuecode = x.valuecode(+)
		  and t.OPERTYPECODE in ('03')
		  and f.DEPARTNO = e.DEPARTNO
		  and (p_var1 = '' or p_var1 is null or t.valuecode = p_var1)
		  and  (p_var2 IS NULL OR p_var2 = '' OR t.OPERTIME >= TO_DATE(p_var2||'000000','YYYYMMDDHH24MISS'))
		  and  (p_var3 IS NULL OR p_var3 = '' OR t.OPERTIME <= TO_DATE(p_var3||'235959','YYYYMMDDHH24MISS'))
		  and (p_var4 = '' or p_var4 is null or e.DEPARTNO = p_var4)
		  group by x.VALUE,e.DEPARTNAME
		  order by e.DEPARTNAME,x.VALUE desc;
elsif p_funcCode = 'TD_M_MANUWITHCODING' then
		open p_cursor for
		SELECT B.CODEDESC,B.CODEVALUE,A.MANUCODE
		FROM TD_M_MANU A,TD_M_RMCODING B
		WHERE A.MANUNAME=B.CODEDESC
		AND B.TABLENAME='TD_M_MANU' AND COLNAME='MANUNAME';
elsif p_funcCode = 'GETFILENAME' then
		open p_cursor for
		SELECT FILENAME,ID
		FROM TF_SYN_CARDFILE
		WHERE  DEALCODE = '0'
		   AND FILETYPE = '03'
		   AND (ORDERSATATE = '0' or ORDERSATATE is null and filename not like 'E%')
		   ORDER BY ID;
elsif p_funcCode = 'SMKOrderQuery' then --市民卡订购单查询
		  open p_cursor for
		  SELECT A.CARDORDERID      ,                                 --订购单号
			       A.CARDORDERTYPE||':'||B.CODEDESC  ORDERTYPE  ,       --订购类型
			       C.CODEVALUE ||'_' || A.BATCHNO || '_' || A.BATCHDATE || '_' || A.CARDNUM || '_SX.txt'        ORDERFILENAME,                                 --制卡文件名
			       A.MANUTYPECODE ||':'||G.MANUNAME  MANUNAME       ,   --卡厂商
			       C.CODEVALUE	 MANUFILECODE																	  ,   --卡厂商	编码
			       A.BATCHNO ,                                      --批次号
			       A.BATCHDATE   ,                                 --批次日期
			       A.CARDNUM ,                                  --订购数量
			       A.BEGINCARDNO      ,                                 --起始卡号
			       A.ENDCARDNO        ,                                 --结束卡号
			       A.ORDERTIME        ,                          --下单时间
			       A.ORDERSTAFFNO||':'||H.STAFFNAME  ORDERSTAFF, --下单员工
			       A.EXAMTIME         ,                          --审核时间
			       A.EXAMSTAFFNO||':'||I.STAFFNAME   EXAMSTAFF,  --审核员工
			       A.REMARK           ,                          --备注
			       A.CARDORDERSTATE||':'||K.CODEDESC  STATE      --审核状态
			FROM   TF_F_SMK_CARDORDER A ,
			       TD_M_RMCODING     B ,
			       TD_M_MANU         G , --卡片厂商编码值
			       TD_M_RMCODING		 C ,
			       TD_M_INSIDESTAFF  H ,
			       TD_M_INSIDESTAFF  I ,
			       TD_M_RMCODING       K	 -- 订单状态编码值
			WHERE  A.CARDORDERTYPE = B.CODEVALUE
			AND    B.COLNAME = 'CARDORDERTYPE'
			AND    B.TABLENAME = 'TF_F_SMK_CARDORDER'
			AND    A.CARDORDERSTATE = K.CODEVALUE
			AND    K.COLNAME = 'CARDORDERSTATE'
			AND    K.TABLENAME = 'TF_F_SMK_CARDORDER'
			AND    C.TABLENAME = 'TD_M_MANU'
			AND    C.COLNAME = 'MANUNAME'
			AND    C.CODEDESC = G.MANUNAME
			AND    A.MANUTYPECODE = G.MANUCODE(+)
			AND    A.ORDERSTAFFNO = H.STAFFNO(+)
			AND    A.EXAMSTAFFNO = I.STAFFNO(+)
			AND    A.USETAG = '1'
			AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR TO_DATE(P_VAR1||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
			AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
			AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR P_VAR3 = A.CARDORDERSTATE)
			AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = A.CARDORDERID)
			AND   (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = A.CARDORDERTYPE)
			ORDER BY A.ORDERTIME DESC;
elsif p_funcCode = 'selectSmkExam' then
		open p_cursor for
		SELECT A.CARDORDERID      ,                                  --订购单号
			   DECODE(A.CARDORDERTYPE,'01','成品卡','02','半成品卡')     CARDORDERTYPE ,  --订购类型
			   DECODE(A.CARDORDERSTATE,'0','待审核','1','审核通过','2','审核作废','3','部分到货','4','全部到货')  CARDORDERSTATE,  --订购单状态
			   A.FILENAME         ,                                  --制卡文件名
			   A.MANUTYPECODE||':'||G.MANUNAME   MANUNAME ,          --卡厂商
			   A.BATCHNO          ,                                  --批次号
			   A.CARDNUM          ,                                  --订购数量
			   A.BATCHDATE        ,                                  --批次日期
			   A.BEGINCARDNO      ,                                  --起始卡号
			   A.ENDCARDNO        ,                                  --结束卡号
			   A.ORDERTIME        ,                          --下单时间
			   A.ORDERSTAFFNO||':'||H.STAFFNAME  ORDERSTAFF ,--下单员工
			   A.EXAMTIME         ,                          --审核时间
			   A.EXAMSTAFFNO||':'||I.STAFFNAME   EXAMSTAFF , --审核员工
			   A.REMARK                                      --备注
		FROM   TF_F_SMK_CARDORDER    A ,
			   TD_M_MANU         G , --卡片厂商编码表
         TD_M_INSIDESTAFF  H ,
         TD_M_INSIDESTAFF  I
    WHERE  A.MANUTYPECODE = G.MANUCODE(+)
    AND    A.ORDERSTAFFNO = H.STAFFNO(+)
    AND    A.EXAMSTAFFNO = I.STAFFNO(+)
    AND    A.USETAG = '1'
    AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.CARDORDERID )
    AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = A.CARDORDERSTATE)
    ORDER BY A.ORDERTIME DESC;
elsif p_funcCode = 'queryTask' then --生成制卡页面的任务查询
    open p_cursor for
    SELECT         A.CARDORDERID ,                               --订单号
           A.VALUECODE||':'||C.VALUE VALUECODE ,         --充值卡面值
           A.CARDNUM       ,                             --下单数量
           A.CARDORDERSTATE||':'||B.CODEDESC STATE,       --审核状态
           A.ORDERTIME      ,                            --下单时间
           D.TASKID        ,                            --任务ID
           A.APPVERNO      ,                            --批次号
           A.MANUTYPECODE     ,                          --厂商
           DECODE( D.TASKSTATE,'0','0:待处理','1','1:处理中','2','2:处理成功','3','3:处理失败','4' ,'4:作废','5','5:删除','6','6:待删除','7','7:已删除制卡文件',D.TASKSTATE) TASKSTATE, --任务状态
           A.BEGINCARDNO||'-'||A.ENDCARDNO  SECTION,    --充值卡号段
           D.TASKSTARTTIME,                             --任务开始时间
           D.TASKENDTIME,                               --任务结束时间
           nvl2(D.OPERATOR,D.OPERATOR||':'||E.STAFFNAME,null) ORDERSTAFF,     --操作员工
           D.DATETIME ,                               --操作时间
           D.FILEPATH ,                               --文件下载地址
           D.REMARK                                   --说明
    FROM   TF_F_CARDORDER  A , --卡片订单
           TD_M_RMCODING    B ,
           TP_XFC_CARDVALUE C ,
           TF_F_MAKECARDTASK D, --制卡任务表
           TD_M_INSIDESTAFF E
    WHERE  B.COLNAME = 'CARDORDERSTATE'
    AND    B.TABLENAME = 'TF_F_CARDORDER'
    AND    A.CARDORDERSTATE = B.CODEVALUE
    AND    A.VALUECODE = C.VALUECODE
    AND    D.OPERATOR = E.STAFFNO(+)
    AND    A.CARDORDERID = D.CARDORDERID(+)
    AND    A.CARDORDERTYPE = '03' --充值卡类型
    AND   ( A.CARDORDERSTATE = '1' or  A.CARDORDERSTATE = '3' or A.CARDORDERSTATE = '4'or  A.CARDORDERSTATE = '5')--订购单审核通过
    AND    A.USETAG = '1'  --有效
    AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.CARDORDERID ) --订购单号
    AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
    AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
    order by A.ORDERTIME desc;
elsif p_funcCode = 'queryKey' then --厂家公私钥维护页面查询
   open p_cursor for
   SELECT A.ID,nvl2(A.CORPCODE,A.CORPCODE||':'||B.CORPNAME,null) PRODUCER ,A.PUBLICKEY,A.PRIVATEKEY,A.OPERATETIME
   FROM TD_M_PUBLICANDPRIVATEKEY A,TP_XFC_CORP B
   WHERE A.CORPCODE = B.CORPCODE(+)
   AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.CORPCODE )
   ORDER BY A.ID;
   
elsif p_funcCode = 'QryHasExistPwd' then
      open p_cursor for
      select XFCARDNO,NEW_PASSWD
              from TD_XFC_INITCARD 
      where NEW_PASSWD= p_var1;
elsif  p_funcCode = 'queryMaxCardNo2' then  --获取充值卡账户表和排重表中最大卡号后8位 add by youyue
    open p_cursor for
    select Max(a.cardno) from (select   Max(substr(t.xfcardno,7,8)) cardno from TD_XFC_INITCARD t
    union all Select   Max(substr(b.cardno,7,8)) cardno from TD_M_CHARGECARDNO_EXCLUDE b ) a;
 end if;
end;
/
show errors