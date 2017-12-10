create or replace procedure SP_PS_Query_DeptBal
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
    v_idx       pls_integer;
begin
if p_funcCode = 'QueryDeptBalUnit' then
    if P_VAR2 = '0' then -- 财审通过 
        open p_cursor for
        SELECT ROWNUM AS  NUM, '' TRADEID, B.USETAG, B.DBALUNITNO, B.DBALUNIT, B.CREATETIME,
				 B.BANKCODE, F.BANK BANKNAME,		
				 B.BANKACCNO, B.FININTERVAL, B.FINBANKCODE, G.BANK FINBANK, B.LINKMAN,
				 B.UNITPHONE, B.UNITADD , B.BALINTERVAL,		
				 B.BALCYCLETYPECODE, B.FINCYCLETYPECODE,		
				 B.FINTYPECODE, B.REMARK, B.UNITEMAIL, 		
				DECODE(B.BALCYCLETYPECODE, '00', '小时', '01','天', '02', '周', '03', '固定月', '04', '自然月',	
				B.BALCYCLETYPECODE) BALCYCLETYPE,
				DECODE(B.FINCYCLETYPECODE, '00', '小时', '01','天', '02', '周', '03', '固定月', '04', '自然月',	
				B.FINCYCLETYPECODE) FINCYCLETYPE,
				DECODE(B.FINTYPECODE, '0', '财务部门转账', '1', '结入预付款',		
				B.FINTYPECODE) FINTYPE,
				DECODE(B.DEPTTYPE, '0', '自营网点', '1', '代理网点', '2', '代理商户',		
				B.DEPTTYPE) DEPTTYPE,
				B.DEPTTYPE AS DEPTTYPECODE,
				B.PREPAYWARNLINE/100.0 PREPAYWARNLINE,B.PREPAYLIMITLINE/100.0 PREPAYLIMITLINE,
				P_VAR2 AS APRVSTATE,B.DBALUNITKEY
		FROM  TF_DEPT_BALUNIT B, TD_M_BANK F, TD_M_BANK G		
		WHERE (P_VAR1 IS NULL OR P_VAR1 = B.DBALUNITNO)	
			AND  (P_VAR3 IS NULL OR P_VAR3 = B.DEPTTYPE)
			AND   B.BANKCODE       = F.BANKCODE (+)		
			AND   B.FINBANKCODE    = G.BANKCODE (+)		
			AND   B.USETAG = '1'		
			AND   ROWNUM <= 100		
			ORDER BY  B.DBALUNITNO		
			;
    elsif P_VAR2 in ('1', '2') then -- 财审作废或者等待财审
        open p_cursor for
		SELECT * FROM(
			SELECT  row_number() over(ORDER BY J.OPERATETIME)AS  NUM, 
				 B.TRADEID, '1' USETAG, B.DBALUNITNO, B.DBALUNIT, B.CREATETIME, 
				 B.BANKCODE, F.BANK BANKNAME,
				 B.BANKACCNO, B.FININTERVAL, B.FINBANKCODE, G.BANK FINBANK, B.LINKMAN,
				 B.UNITPHONE, B.UNITADD , B.BALINTERVAL,
				 B.BALCYCLETYPECODE, B.FINCYCLETYPECODE,
				 B.FINTYPECODE, B.REMARK, B.UNITEMAIL, 
				DECODE(B.BALCYCLETYPECODE, '00', '小时', '01','天', '02', '周', '03', '固定月', '04', '自然月',
					 B.BALCYCLETYPECODE) BALCYCLETYPE,
				DECODE(B.FINCYCLETYPECODE, '00', '小时', '01','天', '02', '周', '03', '固定月', '04', '自然月',
					 B.FINCYCLETYPECODE) FINCYCLETYPE,
				DECODE(B.FINTYPECODE, '0', '财务部门转账', '1', '结入预付款',
					 B.FINTYPECODE) FINTYPE,
				DECODE(B.DEPTTYPE, '0', '自营网点', '1', '代理网点','2', '代理商户',
					 B.DEPTTYPE) DEPTTYPE,B.DEPTTYPE AS	DEPTTYPECODE ,
					B.PREPAYWARNLINE/100.0 PREPAYWARNLINE,B.PREPAYLIMITLINE/100.0 PREPAYLIMITLINE,
					P_VAR2 AS APRVSTATE,'' as DBALUNITKEY
			FROM  TH_DEPT_BALUNIT B, TD_M_BANK F, TD_M_BANK G,
					TF_B_DEPTBALTRADE_EXAM J
			WHERE B.TRADEID        = J.TRADEID  
				AND J.STATECODE = DECODE(P_VAR2, '1', '3', '2', '1')
				AND  (P_VAR1 IS NULL OR P_VAR1 = B.DBALUNITNO)
				AND  (P_VAR3 IS NULL OR P_VAR3 = B.DEPTTYPE)
				AND   B.BANKCODE       = F.BANKCODE (+)
				AND   B.FINBANKCODE    = G.BANKCODE (+)
				AND   ROWNUM <= 100
		);
    elsif P_VAR2 in ('3', '4') then -- 等待审批或审批作废
        open p_cursor for
		SELECT * FROM(
			SELECT row_number() over(ORDER BY J.OPERATETIME)AS NUM, 
					B.TRADEID, '1' USETAG, B.DBALUNITNO, B.DBALUNIT, B.CREATETIME,		
					B.BANKCODE, F.BANK BANKNAME,	
					B.BANKACCNO, B.FININTERVAL, B.FINBANKCODE, G.BANK FINBANK, B.LINKMAN,	
					B.UNITPHONE, B.UNITADD ,  B.BALINTERVAL,	
					B.BALCYCLETYPECODE, B.FINCYCLETYPECODE,	
					B.FINTYPECODE, B.REMARK, B.UNITEMAIL, 	
					DECODE(B.BALCYCLETYPECODE, '00', '小时', '01','天', '02', '周', '03', '固定月', '04', '自然月',		
					B.BALCYCLETYPECODE) BALCYCLETYPE,		
					DECODE(B.FINCYCLETYPECODE, '00', '小时', '01','天', '02', '周', '03', '固定月', '04', '自然月',		
					B.FINCYCLETYPECODE) FINCYCLETYPE,		
					DECODE(B.FINTYPECODE, '0', '财务部门转账', '1', '结入预付款',		
					B.FINTYPECODE) FINTYPE,		
					DECODE(B.DEPTTYPE, '0', '自营网点', '1', '代理网点', '2', '代理商户',	
					B.DEPTTYPE) DEPTTYPE, B.DEPTTYPE AS	DEPTTYPECODE ,	
					B.PREPAYWARNLINE/100.0 PREPAYWARNLINE,B.PREPAYLIMITLINE/100.0 PREPAYLIMITLINE,
					P_VAR2 AS APRVSTATE,'' as DBALUNITKEY
			FROM  TH_DEPT_BALUNIT B, TD_M_BANK F, TD_M_BANK G, TF_B_DEPTBALTRADE J		
			WHERE B.TRADEID        = J.TRADEID  		
			AND J.STATECODE = DECODE(P_VAR2, '3', '3', '4', '1')		
			AND  (P_VAR1 IS NULL OR P_VAR1 = B.DBALUNITNO)	
			AND  (P_VAR3 IS NULL OR P_VAR3 = B.DEPTTYPE)			
			AND   B.BANKCODE       = F.BANKCODE (+)		
			AND   B.FINBANKCODE    = G.BANKCODE (+)		
			AND   ROWNUM <= 100		
		);
    end if;

elsif p_funcCode = 'QueryBalUnitInfo' then --查询网点结算单元信息
    open p_cursor for
    SELECT 
        a.DBALUNITNO  , a.DBALUNIT    , b.BANK OPENBANK  , a.BANKACCNO      ,
        a.CREATETIME  , a.BALINTERVAL , a.FININTERVAL    , c.bank OUTBANK   ,
        decode(a.BALCYCLETYPECODE,'00','小时','01','天','02','周','03','固定月','04','自然月',a.BALCYCLETYPECODE) BALCYCLETYPECODE ,
        decode(a.FINCYCLETYPECODE,'00','小时','01','天','02','周','03','固定月','04','自然月',a.FINCYCLETYPECODE) FINCYCLETYPECODE,
        decode(a.FINTYPECODE,'0','财务部门转账','1','结入预付款',a.FINTYPECODE) FINTYPECODE,
        a.LINKMAN     , a.UNITPHONE   , a.UNITADD        , a.UNITEMAIL      ,
        decode(a.DEPTTYPE,'0','自营网点','1','代理网点','2','代理商户',a.DEPTTYPE) DEPTTYPE,
        A.PREPAYWARNLINE/100.0 PREPAYWARNLINE,A.PREPAYLIMITLINE/100.0 PREPAYLIMITLINE,a.REMARK
    FROM TF_DEPT_BALUNIT a,td_m_bank b,td_m_bank c
    WHERE a.BANKCODE  = b.BANKCODE(+)
    AND   a.FINBANKCODE  = c.BANKCODE(+)
    AND   a.USETAG     = '1'
    AND   a.DBALUNITNO = p_var1
    ;
elsif p_funcCode = 'QueryBalUnitPrepayInfo' then --查询网点结算单元预付款记录
    open p_cursor for    
    SELECT 
        decode(a.TRADETYPECODE,'11','财务存预付款','12','财务支出预付款',a.TRADETYPECODE) 业务类型,
        a.DBALUNITNO 结算单元编码, b.DBALUNIT 结算单元名称, a.CURRENTMONEY/100.0 发生金额, 
        a.PREMONEY/100.0 发生前余额, a.NEXTMONEY/100.0 发生后余额, a.OPERATETIME 操作时间,a.REMARK 备注,
		TO_CHAR(a.FINDATE,'YYYY-MM-DD') 划款日期 ,a.FINTRADENO 划款单号, a.FINBANK 划款银行 , a.USEWAY 用途
    FROM TF_B_DEPTACCTRADE a,TF_DEPT_BALUNIT b
    WHERE a.DBALUNITNO = b.DBALUNITNO
    AND   a.CANCELTAG = '0'
    AND   a.TRADETYPECODE IN('11','12')
    AND   a.DBALUNITNO = P_VAR1
    AND   (p_var2 is null or p_var2 = '' or a.OPERATETIME >= to_date(p_var2||'000000','yyyymmddhh24miss'))
    AND   (p_var3 is null or p_var3 = '' or a.OPERATETIME <= to_date(p_var3||'235959','yyyymmddhh24miss'))
    ORDER BY a.OPERATETIME DESC
    ; 
elsif p_funcCode = 'QueryBalUnitPrepayExamInfo' then --查询待审核预付款收支记录
    open p_cursor for    
    SELECT 
        decode(a.STATECODE,'1','待审核','2','审核通过','3','审核作废',a.STATECODE) 审核状态,
        decode(a.TRADETYPECODE,'11','财务存预付款','12','财务支出预付款',a.TRADETYPECODE) 业务类型,
        a.DBALUNITNO 结算单元编码, b.DBALUNIT 结算单元名称, a.CURRENTMONEY/100.0 交易金额, 
        a.CHINESEMONEY 金额大写,c.STAFFNAME 操作员工, a.OPERATETIME 操作时间, a.REMARK 备注,
		TO_CHAR(a.FINDATE,'YYYY-MM-DD') 划款日期 ,a.FINTRADENO 划款单号, a.FINBANK 划款银行 , a.USEWAY 用途
    FROM TF_B_DEPTACC_EXAM a,TF_DEPT_BALUNIT b, TD_M_INSIDESTAFF c
    WHERE a.DBALUNITNO = b.DBALUNITNO
    AND   a.OPERATESTAFFNO = c.STAFFNO(+)
    AND   a.STATECODE = '1'
    AND   b.USETAG = '1'
    AND   a.TRADETYPECODE IN('11','12')
    AND   a.DBALUNITNO = P_VAR1
    AND   (p_var2 is null or p_var2 = '' or a.OPERATETIME >= to_date(p_var2||'000000','yyyymmddhh24miss'))
    AND   (p_var3 is null or p_var3 = '' or a.OPERATETIME <= to_date(p_var3||'235959','yyyymmddhh24miss'))
    ORDER BY a.OPERATETIME DESC
    ; 
elsif p_funcCode = 'QueryBalUnitPrepayCancelInfo' then --查询审核作废预付款收支记录
    open p_cursor for    
    SELECT 
        decode(a.STATECODE,'1','待审核','2','审核通过','3','审核作废',a.STATECODE) 审核状态,
        decode(a.TRADETYPECODE,'11','财务存预付款','12','财务支出预付款',a.TRADETYPECODE) 业务类型,
        a.DBALUNITNO 结算单元编码, b.DBALUNIT 结算单元名称, a.CURRENTMONEY/100.0 交易金额, 
        a.CHINESEMONEY 金额大写,c.STAFFNAME 操作员工, a.OPERATETIME 操作时间,
        d.STAFFNAME 审核员工 , a.EXAMKTIME 审核时间 ,  a.REMARK 备注,
		TO_CHAR(a.FINDATE,'YYYY-MM-DD') 划款日期 ,a.FINTRADENO 划款单号, a.FINBANK 划款银行 , a.USEWAY 用途
    FROM TF_B_DEPTACC_EXAM a,TF_DEPT_BALUNIT b, TD_M_INSIDESTAFF c ,TD_M_INSIDESTAFF d
    WHERE a.DBALUNITNO = b.DBALUNITNO
    AND   a.OPERATESTAFFNO = c.STAFFNO(+)
    AND   a.EXAMSTAFFNO = d.STAFFNO(+)
    AND   a.STATECODE = '3'
    AND   b.USETAG = '1'
    AND   a.TRADETYPECODE IN('11','12')
    AND   a.DBALUNITNO = P_VAR1
    AND   (p_var2 is null or p_var2 = '' or a.OPERATETIME >= to_date(p_var2||'000000','yyyymmddhh24miss'))
    AND   (p_var3 is null or p_var3 = '' or a.OPERATETIME <= to_date(p_var3||'235959','yyyymmddhh24miss'))
    ORDER BY a.OPERATETIME DESC
    ;        
elsif p_funcCode = 'QueryDeptBalComScheme' then --查询网点结算单元佣金方案
    open p_cursor for    
    SELECT  T.DBALUNITNO, T.DBALUNITNO || ':' || T.DBALUNIT BALUNIT,        
		R.BEGINTIME,R.ENDTIME,    
		C.NAME, C.DCOMSCHEMENO, C.TYPECODE, R.ID,    
		M.TRADETYPECODE || ':' || M.TRADETYPE TRADETYPE, M.TRADETYPECODE,
		N.TRADETYPECODE || ':' || N.TRADETYPE CANCELTRADE, N.TRADETYPECODE AS CANCELTRADECODE
	FROM  TF_DEPT_BALUNIT T,    
		  TF_DEPT_COMSCHEME C,    
		  TD_DEPTBAL_COMSCHEME R,    
		  TD_M_TRADETYPE M ,
		  TD_M_TRADETYPE N  
	WHERE T.DBALUNITNO = R.DBALUNITNO    
		AND C.DCOMSCHEMENO = R.DCOMSCHEMENO    
		AND R.TRADETYPECODE = M.TRADETYPECODE(+)
		AND R.CANCELTRADE = N.TRADETYPECODE(+)    
		AND T.USETAG = '1' 
		AND R.USETAG = '1' 
		AND C.USETAG = '1' 
		AND (P_VAR1 IS NULL OR R.DBALUNITNO = P_VAR1)    
		AND (P_VAR2 IS NULL OR R.DCOMSCHEMENO = P_VAR2)    
		AND (P_VAR3 IS NULL OR R.TRADETYPECODE = P_VAR3)    
		AND (P_VAR4 IS NULL OR R.ENDTIME <=    
		  ADD_MONTHS(SYSDATE, P_VAR4))  
		AND (P_VAR5 IS NULL OR T.DEPTTYPE = P_VAR5)  
	ORDER BY R.DBALUNITNO,R.TRADETYPECODE,R.DCOMSCHEMENO
    ; 	
    elsif p_funcCode = 'QueryBalUnitDepositInfo' then --查询网点结算单元保证金记录
    open p_cursor for    
    SELECT 
        decode(a.TRADETYPECODE,'01','财务存保证金','02','财务支出保证金',a.TRADETYPECODE) 业务类型,
        a.DBALUNITNO 结算单元编码, b.DBALUNIT 结算单元名称, a.CURRENTMONEY/100.0 发生金额, 
        a.PREMONEY/100.0 发生前金额, a.NEXTMONEY/100.0 发生后金额, a.OPERATETIME 操作时间, a.REMARK 备注
    FROM TF_B_DEPTACCTRADE a,TF_DEPT_BALUNIT b
    WHERE a.DBALUNITNO = b.DBALUNITNO
    AND   a.CANCELTAG = '0'
    AND   a.TRADETYPECODE IN('01','02')
    AND   a.DBALUNITNO = P_VAR1
    ORDER BY a.OPERATETIME DESC
    ; 
elsif p_funcCode = 'QueryBalUnitDepositExamInfo' then --查询待审核保证金收支记录
    open p_cursor for    
    SELECT 
        decode(a.STATECODE,'1','待审核','2','审核通过','3','审核作废',a.STATECODE) 审核状态,
        decode(a.TRADETYPECODE,'01','财务存保证金','02','财务支出保证金',a.TRADETYPECODE) 业务类型,
        a.DBALUNITNO 结算单元编码, b.DBALUNIT 结算单元名称, a.CURRENTMONEY/100.0 交易金额, 
        a.CHINESEMONEY 金额大写,c.STAFFNAME 操作员工, a.OPERATETIME 操作时间, a.REMARK 备注
    FROM TF_B_DEPTACC_EXAM a,TF_DEPT_BALUNIT b, TD_M_INSIDESTAFF c
    WHERE a.DBALUNITNO = b.DBALUNITNO
    AND   a.OPERATESTAFFNO = c.STAFFNO(+)
    AND   a.STATECODE = '1'
    AND   b.USETAG = '1'
    AND   a.TRADETYPECODE IN('01','02')
    AND   a.DBALUNITNO = P_VAR1
    ORDER BY a.OPERATETIME DESC
    ; 
elsif p_funcCode = 'QueryBalUnitDepositCancelInfo' then --查询审核作废保证金收支记录
    open p_cursor for    
    SELECT 
        decode(a.STATECODE,'1','待审核','2','审核通过','3','审核作废',a.STATECODE) 审核状态,
        decode(a.TRADETYPECODE,'01','财务存保证金','02','财务支出保证金',a.TRADETYPECODE) 业务类型,
        a.DBALUNITNO 结算单元编码, b.DBALUNIT 结算单元名称, a.CURRENTMONEY/100.0 交易金额, 
        a.CHINESEMONEY 金额大写,c.STAFFNAME 操作员工, a.OPERATETIME 操作时间,
        d.STAFFNAME 审核员工 , a.EXAMKTIME 审核时间 , a.REMARK 备注
    FROM TF_B_DEPTACC_EXAM a,TF_DEPT_BALUNIT b, TD_M_INSIDESTAFF c ,TD_M_INSIDESTAFF d
    WHERE a.DBALUNITNO = b.DBALUNITNO
    AND   a.OPERATESTAFFNO = c.STAFFNO(+)
    AND   a.EXAMSTAFFNO = d.STAFFNO(+)
    AND   a.STATECODE = '3'
    AND   b.USETAG = '1'
    AND   a.TRADETYPECODE IN('01','02')
    AND   a.DBALUNITNO = P_VAR1
    ORDER BY a.OPERATETIME DESC
    ;            
elsif p_funcCode = 'QueryDeptBalRelation' then --查询网点结算单元关系
    open p_cursor for 
	SELECT * FROM( 
		SELECT row_number() over(ORDER BY R.DBALUNITNO)AS NUM, 
		   R.DBALUNITNO,
		   B.DBALUNIT,
		   R.DEPARTNO,
		   D.DEPARTNAME,
		   DECODE(B.DEPTTYPE, '0', '自营网点', '1', '代理网点','2', '代理商户', B.DEPTTYPE) DEPTTYPE
		FROM TD_DEPTBAL_RELATION R, TF_DEPT_BALUNIT B, TD_M_INSIDEDEPART D
		WHERE R.DBALUNITNO = B.DBALUNITNO
		AND R.DEPARTNO = D.DEPARTNO
		AND (P_VAR1 IS NULL OR P_VAR1 = R.DBALUNITNO)
		AND (P_VAR2 IS NULL OR P_VAR2 = R.DEPARTNO)
		AND R.USETAG = '1' AND B.USETAG = '1' 
	)
    ;   
elsif p_funcCode = 'QueryDeptBalDeviceRelation' then --查询网点结算单元设备关系
    open p_cursor for 
	SELECT * FROM( 
		SELECT row_number() over(ORDER BY R.DBALUNITNO)AS NUM, 
		   R.DBALUNITNO,
		   B.DBALUNIT,
		   R.READERNO
		FROM TD_BALREADER_RELATION R, TF_DEPT_BALUNIT B
		WHERE R.DBALUNITNO = B.DBALUNITNO
		AND (P_VAR1 IS NULL OR P_VAR1 = R.DBALUNITNO)
		AND	(P_VAR2 IS NULL OR R.READERNO >= P_VAR2)
		AND (P_VAR3 IS NULL OR R.READERNO <= P_VAR3)
		AND B.USETAG = '1'  order by R.DBALUNITNO,R.READERNO
	)
    ;  	
elsif p_funcCode = 'QueryDeptBalApprovalInfo' then --查询待审批网点结算单元信息
    open p_cursor for     
    SELECT  
       T.DTRADETYPECODE, 												
		   CASE WHEN T.DTRADETYPECODE = '01'  THEN '增加-结算单元'  										
			      WHEN T.DTRADETYPECODE = '02'  THEN '修改-结算单元' 									
            WHEN T.DTRADETYPECODE = '03'  THEN '删除-结算单元' 									
		        WHEN T.DTRADETYPECODE = '21'  THEN '增加-佣金方案' 									
			      WHEN T.DTRADETYPECODE = '22'  THEN '修改-佣金方案'  									
			      WHEN T.DTRADETYPECODE = '23'  THEN '删除-佣金方案' 									
			      WHEN T.DTRADETYPECODE = '11'  THEN '增加-结算单元网点关系' 									
			      WHEN T.DTRADETYPECODE = '12'  THEN '修改-结算单元网点关系'  									
			      WHEN T.DTRADETYPECODE = '13'  THEN '删除-结算单元网点关系'  END BIZTYPE,  									
			 B.DBALUNITNO    , B.DBALUNIT   , B.BANKACCNO  ,  
			 F.BANK OPENBANK , B.CREATETIME , B.UNITEMAIL  ,   									
		   CASE WHEN B.DEPTTYPE = '0' THEN '自营网点' 										
		      	WHEN B.DEPTTYPE = '1' THEN '代理网点' 
				WHEN B.DEPTTYPE = '2' THEN '代理商户' END DEPTTYPE, 									
	     CASE WHEN B.BALCYCLETYPECODE = '00' THEN '小时'										
			      WHEN B.BALCYCLETYPECODE = '01' THEN '天'									
			      WHEN B.BALCYCLETYPECODE = '02' THEN '周'									
			      WHEN B.BALCYCLETYPECODE = '03' THEN '固定月' 									
			      WHEN B.BALCYCLETYPECODE = '04' THEN '自然月' END BALCYCLETYPE, 									
			 B.BALINTERVAL ,  									
	     CASE WHEN B.FINCYCLETYPECODE = '00' THEN '小时' 										
			      WHEN B.FINCYCLETYPECODE = '01' THEN '天' 									
		       	WHEN B.FINCYCLETYPECODE = '02' THEN '周' 									
		      	WHEN B.FINCYCLETYPECODE = '03' THEN '固定月' 									
		       	WHEN B.FINCYCLETYPECODE = '04' THEN '自然月' END FINCYCLETYPE, 									
		   B.FININTERVAL , 									
		   CASE WHEN B.FINTYPECODE = '0' THEN '财务部门转账' 										
		      	WHEN B.FINTYPECODE = '1' THEN '结入预付款' END FINTYPE, 									
		   G.BANK  FINBANK  , B.LINKMAN       , B.UNITPHONE      , B.UNITADD    ,
		   C.STAFFNAME      , T.OPERATETIME   , B.REMARK         , T.TRADEID    ,
		   B.PREPAYWARNLINE/100.0 PREPAYWARNLINE , B.PREPAYLIMITLINE/100.0 PREPAYLIMITLINE 
       FROM 	TF_B_DEPTBALTRADE T, TH_DEPT_BALUNIT B , TD_M_BANK F, TD_M_BANK G	,TD_M_INSIDESTAFF C									
       WHERE 	T.TRADEID     = B.TRADEID  										
	     AND    B.BANKCODE    = F.BANKCODE (+)
	     AND    B.FINBANKCODE = G.BANKCODE (+)
	     AND    T.STATECODE   = '1' 
	     AND    T.OPERATESTAFFNO = C.STAFFNO(+)
	     ORDER BY T.OPERATETIME DESC
	     ;
elsif p_funcCode = 'QueryCurrentCom' then --查询当前佣金方案
    open p_cursor for 	     
		SELECT  T.NAME ,											
			    	A.TRADETYPE TRADETYPE,									
				    B.TRADETYPE RETRADETYPE,									
				    TO_CHAR(C.BEGINTIME,'YYYY-MM') BEGINTIME,									
				    TO_CHAR(C.ENDTIME,'YYYY-MM')   ENDTIME, 									
				    T.REMARK 
		FROM    TH_DEPTBAL_COMSCHEME  C,											
				    TF_DEPT_COMSCHEME T ,									
			    	TD_M_TRADETYPE A		,
			    	TD_M_TRADETYPE B						
		WHERE   C.DCOMSCHEMENO  =  T.DCOMSCHEMENO      											
	  AND     C.TRADETYPECODE = A.TRADETYPECODE(+)
	  AND     C.CANCELTRADE = B.TRADETYPECODE(+)									
		AND     C.TRADEID = P_VAR1  
		; 					
elsif p_funcCode = 'QueryAlreadyCom' then --查询已有佣金方案
    open p_cursor for 		
		SELECT  C.NAME ,                    											
			    	A.TRADETYPE TRADETYPE,                									
			    	B.TRADETYPE RETRADETYPE,                									
			    	TO_CHAR(R.BEGINTIME,'YYYY-MM') BEGINTIME,                									
			    	TO_CHAR(R.ENDTIME,'YYYY-MM')   ENDTIME,                 									
			      T.REMARK                                           									
		FROM    TF_DEPT_BALUNIT T,                          											
			    	TF_DEPT_COMSCHEME C,
				    TD_DEPTBAL_COMSCHEME R,
				    TD_M_TRADETYPE A,
				    TD_M_TRADETYPE  B
		WHERE   T.DBALUNITNO = R.DBALUNITNO
	  AND     C.DCOMSCHEMENO = R.DCOMSCHEMENO
	  AND     R.TRADETYPECODE = A.TRADETYPECODE(+)
	  AND     R.CANCELTRADE = B.TRADETYPECODE(+)
	  AND     T.USETAG = '1'
	  AND     R.USETAG = '1'
	  AND     C.USETAG = '1'
	  AND     R.DBALUNITNO = P_VAR1
	  ORDER BY R.TRADETYPECODE
	  ;
elsif p_funcCode = 'QueryCurrentRelation' then --查询当前结算单元网点关系
    open p_cursor for 	
		SELECT  B.DBALUNIT ,                                																	
			    	D.DEPARTNAME ,                                															
				    DECODE(B.DEPTTYPE, '0', '自营网点', '1', '代理网点','2', '代理商户',B.DEPTTYPE) DEPTTYPE									
		FROM   	TH_DEPTBAL_RELATION R,																
				    TF_DEPT_BALUNIT B,															
			    	TD_M_INSIDEDEPART D                              															
		WHERE   R.DBALUNITNO=B.DBALUNITNO                                																	
		AND     R.DEPARTNO=D.DEPARTNO                                															
		AND     R.TRADEID = P_VAR1
		; 															         
elsif p_funcCode = 'QueryAlreadyRelation' then --查询已有结算单元网点关系
    open p_cursor for 	     
		SELECT B.DBALUNIT ,											
				   D.DEPARTNAME ,											
				   DECODE(B.DEPTTYPE, '0', '自营网点', '1', '代理网点','2', '代理商户',B.DEPTTYPE) DEPTTYPE											
		FROM 	 TD_DEPTBAL_RELATION R,											
				   TF_DEPT_BALUNIT B,											
				   TD_M_INSIDEDEPART D											
		WHERE  R.DBALUNITNO=B.DBALUNITNO											
		AND    R.DEPARTNO=D.DEPARTNO			
		AND    R.USETAG = '1'
		AND    B.USETAG = '1'								
		AND    R.DBALUNITNO = P_VAR1
		ORDER BY R.DEPARTNO
		;	        
elsif p_funcCode = 'QueryDeptBalFiApprovalInfo' then --查询待财务审核网点结算单元信息
    open p_cursor for		
  	SELECT 
  	   E.DTRADETYPECODE, 																												
		   CASE WHEN E.DTRADETYPECODE = '01'  THEN '增加-结算单元'  																										
				    WHEN E.DTRADETYPECODE = '02'  THEN '修改-结算单元' 																									
				    WHEN E.DTRADETYPECODE = '03'  THEN '删除-结算单元' 																									
				    WHEN E.DTRADETYPECODE = '21'  THEN '增加-佣金方案' 																									
				    WHEN E.DTRADETYPECODE = '22'  THEN '修改-佣金方案'                        																									
				    WHEN E.DTRADETYPECODE = '23'  THEN '删除-佣金方案'                       																									
				    WHEN E.DTRADETYPECODE = '11'  THEN '增加-结算单元网点关系'                       																									
			    	WHEN E.DTRADETYPECODE = '12'  THEN '修改-结算单元网点关系'                        																									
			    	WHEN E.DTRADETYPECODE = '13'  THEN '删除-结算单元网点关系'  END BIZTYPE,  																									
			 B.DBALUNITNO , B.DBALUNIT      , B.DEPTTYPE DEPTTYPECODE , 																									
			 B.BANKCODE   , F.BANK OPENBANK , B.BANKACCNO , 																									
		   B.CREATETIME , B.BALCYCLETYPECODE ,  																									
			 CASE WHEN B.DEPTTYPE = '0' THEN '自营网点'																							
				    WHEN B.DEPTTYPE = '1' THEN '代理网点' 
					WHEN B.DEPTTYPE = '2' THEN '代理商户' 
					END DEPTTYPE, 																									
			 CASE WHEN B.BALCYCLETYPECODE = '00' THEN '小时' 																										
				    WHEN B.BALCYCLETYPECODE = '01' THEN '天' 																									
				    WHEN B.BALCYCLETYPECODE = '02' THEN '周' 																									
				    WHEN B.BALCYCLETYPECODE = '03' THEN '固定月' 																									
				    WHEN B.BALCYCLETYPECODE = '04' THEN '自然月' END BALCYCLETYPE, 																									
			 B.BALINTERVAL, B.FINCYCLETYPECODE, 																									
			 CASE WHEN B.FINCYCLETYPECODE = '00' THEN '小时' 																										
				    WHEN B.FINCYCLETYPECODE = '01' THEN '天' 																									
				    WHEN B.FINCYCLETYPECODE = '02' THEN '周' 																									
				    WHEN B.FINCYCLETYPECODE = '03' THEN '固定月' 																									
				    WHEN B.FINCYCLETYPECODE = '04' THEN '自然月' END FINCYCLETYPE, 																									
			 B.FININTERVAL, B.FINTYPECODE, 																									
			 CASE WHEN B.FINTYPECODE = '0' THEN '财务部门转账' 																										
				    WHEN B.FINTYPECODE = '1' THEN '结入预付款' END FINTYPE, 																									
			 B.FINBANKCODE , G.BANK FINBANK , B.LINKMAN   , B.UNITPHONE   ,  																									
			 B.UNITADD     , B.REMARK       , B.UNITEMAIL , E.TRADEID     , 
			 S.STAFFNAME   , E.OPERATETIME CHECKTIME      , T.OPERATESTAFFNO OPERTSTUFFNO ,
			 B.PREPAYWARNLINE/100.0 PREPAYWARNLINE , B.PREPAYLIMITLINE/100.0 PREPAYLIMITLINE 																									
	     FROM TF_B_DEPTBALTRADE_EXAM E,TH_DEPT_BALUNIT B, TF_B_DEPTBALTRADE T,TD_M_INSIDESTAFF S,TD_M_BANK F, TD_M_BANK G  																										
       WHERE E.TRADEID = B.TRADEID AND E.TRADEID = T.TRADEID 																										
			 AND   B.BANKCODE       = F.BANKCODE (+)                        																										
			 AND   B.FINBANKCODE = G.BANKCODE(+)  																										
			 AND   E.OPERATESTAFFNO = S.STAFFNO(+)																										
			 AND   E.STATECODE = '1' 																										
			 ORDER BY E.OPERATETIME DESC
			 ;
elsif p_funcCode = 'QueryStaffIsDeptBal' then --查询员工是否是代理营业厅员工
    open p_cursor for
    SELECT A.DBALUNITNO , A.DEPTTYPE
    FROM   TF_DEPT_BALUNIT A , TD_DEPTBAL_RELATION B , TD_M_INSIDESTAFF C
    WHERE  A.DBALUNITNO   = B.DBALUNITNO
    AND    B.DEPARTNO     = C.DEPARTNO
    AND    A.USETAG       = '1' --有效
    AND    B.USETAG       = '1' --有效
    AND    C.DIMISSIONTAG = '1' --在职
    AND    C.STAFFNO      = P_VAR1
    ;
elsif p_funcCode = 'QueryDeptBalUnitDeposit' then --查询员工是否是代理营业厅员工    
    open p_cursor for
    SELECT A.DEPOSIT/100.0 DEPOSIT, A.USABLEVALUE/100.0 USABLEVALUE, A.STOCKVALUE/100.0 STOCKVALUE, nvl(B.TAGVALUE/100.0,0) TAGVALUE
    FROM   TF_F_DEPTBAL_DEPOSIT A , TD_M_TAG B
    WHERE  A.ACCSTATECODE = '01'
    AND    B.TAGCODE = 'USERCARD_MONEY'
    AND    A.DBALUNITNO = P_VAR1
    ;
elsif p_funcCode = 'QueryDeptIsDeptBal' then --查询部门是否是代理营业厅部门
    open p_cursor for
    SELECT A.DBALUNITNO , A.DEPTTYPE
    FROM   TF_DEPT_BALUNIT A , TD_DEPTBAL_RELATION B
    WHERE  A.DBALUNITNO = B.DBALUNITNO
    AND    A.USETAG     = '1' --有效
    AND    B.USETAG     = '1' --有效
    AND    B.DEPARTNO   = P_VAR1
    ;
elsif p_funcCode = 'QueryPrepayDepositExam' then --查询待审核预付款保证金收支业务    
    open p_cursor for
    SELECT a.ID ,a.TRADETYPECODE,
           decode(a.TRADETYPECODE,'01','财务存保证金','02','财务支出保证金','11','财务存预付款','12','财务支出预付款',a.TRADETYPECODE) TRADETYPE,
           a.DBALUNITNO , b.DBALUNIT, a.CURRENTMONEY/100.0 CURRENTMONEY, a.CHINESEMONEY,  c.STAFFNAME, a.OPERATETIME, a.REMARK,
		   TO_CHAR(a.FINDATE,'YYYY-MM-DD') FINDATE ,a.FINTRADENO , a.FINBANK  , a.USEWAY 
    FROM   TF_B_DEPTACC_EXAM a, TF_DEPT_BALUNIT b, TD_M_INSIDESTAFF c
    WHERE  a.DBALUNITNO = b.DBALUNITNO
    AND    a.OPERATESTAFFNO = c.STAFFNO(+)
    AND    a.STATECODE = '1'
    order by a.OPERATETIME desc
    ;  
elsif p_funccode = 'QueryInvalidLines' then
    for v_cur in (select DEVICENO, BALUNITNO from TMP_BalDeviceRelation_IMP where sessionid=p_var1 and OPTYPECODE = 'ADD')
    loop
        select count(1) into v_idx from TMP_BalDeviceRelation_IMP where DEVICENO = v_cur.DEVICENO  and  sessionid=p_var1 and OPTYPECODE = 'ADD';
        if v_idx > 1 then
            update TMP_BalDeviceRelation_IMP set checkmsg = '设备序列号在文件中重复' where DEVICENO = v_cur.DEVICENO  and  sessionid=p_var1 and OPTYPECODE = 'ADD';
        else
			select count(1) into v_idx from TD_BALREADER_RELATION where READERNO = v_cur.DEVICENO;
			if v_idx > 0 then
				update TMP_BalDeviceRelation_IMP set checkmsg = '设备序列号已经存在' where DEVICENO = v_cur.DEVICENO and  sessionid=p_var1 and OPTYPECODE = 'ADD';
			end if;
        end if;
    end loop;
    -- 查询对应中有多少不合法
    open p_cursor for
    select rownum 文件行号, BALUNITNO 结算单元编码, DEVICENO 设备序列号,  nvl(checkmsg , 'OK') 检查结果
    from TMP_BalDeviceRelation_IMP
    where checkmsg is not null and  sessionid=p_var1 and OPTYPECODE = 'ADD';
elsif p_funccode = 'QueryDeviceBal' then
    -- 查询对应关系
    open p_cursor for
    select rownum 文件行号, BALUNITNO 结算单元编码, DEVICENO 设备序列号, nvl(checkmsg , 'OK') 检查结果
    from TMP_BalDeviceRelation_IMP where sessionid = p_var1 and OPTYPECODE = 'ADD';
	
end if;
end;


/

show errors