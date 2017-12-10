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
    if P_VAR2 = '0' then -- ����ͨ�� 
        open p_cursor for
        SELECT ROWNUM AS  NUM, '' TRADEID, B.USETAG, B.DBALUNITNO, B.DBALUNIT, B.CREATETIME,
				 B.BANKCODE, F.BANK BANKNAME,		
				 B.BANKACCNO, B.FININTERVAL, B.FINBANKCODE, G.BANK FINBANK, B.LINKMAN,
				 B.UNITPHONE, B.UNITADD , B.BALINTERVAL,		
				 B.BALCYCLETYPECODE, B.FINCYCLETYPECODE,		
				 B.FINTYPECODE, B.REMARK, B.UNITEMAIL, 		
				DECODE(B.BALCYCLETYPECODE, '00', 'Сʱ', '01','��', '02', '��', '03', '�̶���', '04', '��Ȼ��',	
				B.BALCYCLETYPECODE) BALCYCLETYPE,
				DECODE(B.FINCYCLETYPECODE, '00', 'Сʱ', '01','��', '02', '��', '03', '�̶���', '04', '��Ȼ��',	
				B.FINCYCLETYPECODE) FINCYCLETYPE,
				DECODE(B.FINTYPECODE, '0', '������ת��', '1', '����Ԥ����',		
				B.FINTYPECODE) FINTYPE,
				DECODE(B.DEPTTYPE, '0', '��Ӫ����', '1', '��������', '2', '�����̻�',		
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
    elsif P_VAR2 in ('1', '2') then -- �������ϻ��ߵȴ�����
        open p_cursor for
		SELECT * FROM(
			SELECT  row_number() over(ORDER BY J.OPERATETIME)AS  NUM, 
				 B.TRADEID, '1' USETAG, B.DBALUNITNO, B.DBALUNIT, B.CREATETIME, 
				 B.BANKCODE, F.BANK BANKNAME,
				 B.BANKACCNO, B.FININTERVAL, B.FINBANKCODE, G.BANK FINBANK, B.LINKMAN,
				 B.UNITPHONE, B.UNITADD , B.BALINTERVAL,
				 B.BALCYCLETYPECODE, B.FINCYCLETYPECODE,
				 B.FINTYPECODE, B.REMARK, B.UNITEMAIL, 
				DECODE(B.BALCYCLETYPECODE, '00', 'Сʱ', '01','��', '02', '��', '03', '�̶���', '04', '��Ȼ��',
					 B.BALCYCLETYPECODE) BALCYCLETYPE,
				DECODE(B.FINCYCLETYPECODE, '00', 'Сʱ', '01','��', '02', '��', '03', '�̶���', '04', '��Ȼ��',
					 B.FINCYCLETYPECODE) FINCYCLETYPE,
				DECODE(B.FINTYPECODE, '0', '������ת��', '1', '����Ԥ����',
					 B.FINTYPECODE) FINTYPE,
				DECODE(B.DEPTTYPE, '0', '��Ӫ����', '1', '��������','2', '�����̻�',
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
    elsif P_VAR2 in ('3', '4') then -- �ȴ���������������
        open p_cursor for
		SELECT * FROM(
			SELECT row_number() over(ORDER BY J.OPERATETIME)AS NUM, 
					B.TRADEID, '1' USETAG, B.DBALUNITNO, B.DBALUNIT, B.CREATETIME,		
					B.BANKCODE, F.BANK BANKNAME,	
					B.BANKACCNO, B.FININTERVAL, B.FINBANKCODE, G.BANK FINBANK, B.LINKMAN,	
					B.UNITPHONE, B.UNITADD ,  B.BALINTERVAL,	
					B.BALCYCLETYPECODE, B.FINCYCLETYPECODE,	
					B.FINTYPECODE, B.REMARK, B.UNITEMAIL, 	
					DECODE(B.BALCYCLETYPECODE, '00', 'Сʱ', '01','��', '02', '��', '03', '�̶���', '04', '��Ȼ��',		
					B.BALCYCLETYPECODE) BALCYCLETYPE,		
					DECODE(B.FINCYCLETYPECODE, '00', 'Сʱ', '01','��', '02', '��', '03', '�̶���', '04', '��Ȼ��',		
					B.FINCYCLETYPECODE) FINCYCLETYPE,		
					DECODE(B.FINTYPECODE, '0', '������ת��', '1', '����Ԥ����',		
					B.FINTYPECODE) FINTYPE,		
					DECODE(B.DEPTTYPE, '0', '��Ӫ����', '1', '��������', '2', '�����̻�',	
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

elsif p_funcCode = 'QueryBalUnitInfo' then --��ѯ������㵥Ԫ��Ϣ
    open p_cursor for
    SELECT 
        a.DBALUNITNO  , a.DBALUNIT    , b.BANK OPENBANK  , a.BANKACCNO      ,
        a.CREATETIME  , a.BALINTERVAL , a.FININTERVAL    , c.bank OUTBANK   ,
        decode(a.BALCYCLETYPECODE,'00','Сʱ','01','��','02','��','03','�̶���','04','��Ȼ��',a.BALCYCLETYPECODE) BALCYCLETYPECODE ,
        decode(a.FINCYCLETYPECODE,'00','Сʱ','01','��','02','��','03','�̶���','04','��Ȼ��',a.FINCYCLETYPECODE) FINCYCLETYPECODE,
        decode(a.FINTYPECODE,'0','������ת��','1','����Ԥ����',a.FINTYPECODE) FINTYPECODE,
        a.LINKMAN     , a.UNITPHONE   , a.UNITADD        , a.UNITEMAIL      ,
        decode(a.DEPTTYPE,'0','��Ӫ����','1','��������','2','�����̻�',a.DEPTTYPE) DEPTTYPE,
        A.PREPAYWARNLINE/100.0 PREPAYWARNLINE,A.PREPAYLIMITLINE/100.0 PREPAYLIMITLINE,a.REMARK
    FROM TF_DEPT_BALUNIT a,td_m_bank b,td_m_bank c
    WHERE a.BANKCODE  = b.BANKCODE(+)
    AND   a.FINBANKCODE  = c.BANKCODE(+)
    AND   a.USETAG     = '1'
    AND   a.DBALUNITNO = p_var1
    ;
elsif p_funcCode = 'QueryBalUnitPrepayInfo' then --��ѯ������㵥ԪԤ�����¼
    open p_cursor for    
    SELECT 
        decode(a.TRADETYPECODE,'11','�����Ԥ����','12','����֧��Ԥ����',a.TRADETYPECODE) ҵ������,
        a.DBALUNITNO ���㵥Ԫ����, b.DBALUNIT ���㵥Ԫ����, a.CURRENTMONEY/100.0 �������, 
        a.PREMONEY/100.0 ����ǰ���, a.NEXTMONEY/100.0 ���������, a.OPERATETIME ����ʱ��,a.REMARK ��ע,
		TO_CHAR(a.FINDATE,'YYYY-MM-DD') �������� ,a.FINTRADENO �����, a.FINBANK �������� , a.USEWAY ��;
    FROM TF_B_DEPTACCTRADE a,TF_DEPT_BALUNIT b
    WHERE a.DBALUNITNO = b.DBALUNITNO
    AND   a.CANCELTAG = '0'
    AND   a.TRADETYPECODE IN('11','12')
    AND   a.DBALUNITNO = P_VAR1
    AND   (p_var2 is null or p_var2 = '' or a.OPERATETIME >= to_date(p_var2||'000000','yyyymmddhh24miss'))
    AND   (p_var3 is null or p_var3 = '' or a.OPERATETIME <= to_date(p_var3||'235959','yyyymmddhh24miss'))
    ORDER BY a.OPERATETIME DESC
    ; 
elsif p_funcCode = 'QueryBalUnitPrepayExamInfo' then --��ѯ�����Ԥ������֧��¼
    open p_cursor for    
    SELECT 
        decode(a.STATECODE,'1','�����','2','���ͨ��','3','�������',a.STATECODE) ���״̬,
        decode(a.TRADETYPECODE,'11','�����Ԥ����','12','����֧��Ԥ����',a.TRADETYPECODE) ҵ������,
        a.DBALUNITNO ���㵥Ԫ����, b.DBALUNIT ���㵥Ԫ����, a.CURRENTMONEY/100.0 ���׽��, 
        a.CHINESEMONEY ����д,c.STAFFNAME ����Ա��, a.OPERATETIME ����ʱ��, a.REMARK ��ע,
		TO_CHAR(a.FINDATE,'YYYY-MM-DD') �������� ,a.FINTRADENO �����, a.FINBANK �������� , a.USEWAY ��;
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
elsif p_funcCode = 'QueryBalUnitPrepayCancelInfo' then --��ѯ�������Ԥ������֧��¼
    open p_cursor for    
    SELECT 
        decode(a.STATECODE,'1','�����','2','���ͨ��','3','�������',a.STATECODE) ���״̬,
        decode(a.TRADETYPECODE,'11','�����Ԥ����','12','����֧��Ԥ����',a.TRADETYPECODE) ҵ������,
        a.DBALUNITNO ���㵥Ԫ����, b.DBALUNIT ���㵥Ԫ����, a.CURRENTMONEY/100.0 ���׽��, 
        a.CHINESEMONEY ����д,c.STAFFNAME ����Ա��, a.OPERATETIME ����ʱ��,
        d.STAFFNAME ���Ա�� , a.EXAMKTIME ���ʱ�� ,  a.REMARK ��ע,
		TO_CHAR(a.FINDATE,'YYYY-MM-DD') �������� ,a.FINTRADENO �����, a.FINBANK �������� , a.USEWAY ��;
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
elsif p_funcCode = 'QueryDeptBalComScheme' then --��ѯ������㵥ԪӶ�𷽰�
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
    elsif p_funcCode = 'QueryBalUnitDepositInfo' then --��ѯ������㵥Ԫ��֤���¼
    open p_cursor for    
    SELECT 
        decode(a.TRADETYPECODE,'01','����汣֤��','02','����֧����֤��',a.TRADETYPECODE) ҵ������,
        a.DBALUNITNO ���㵥Ԫ����, b.DBALUNIT ���㵥Ԫ����, a.CURRENTMONEY/100.0 �������, 
        a.PREMONEY/100.0 ����ǰ���, a.NEXTMONEY/100.0 ��������, a.OPERATETIME ����ʱ��, a.REMARK ��ע
    FROM TF_B_DEPTACCTRADE a,TF_DEPT_BALUNIT b
    WHERE a.DBALUNITNO = b.DBALUNITNO
    AND   a.CANCELTAG = '0'
    AND   a.TRADETYPECODE IN('01','02')
    AND   a.DBALUNITNO = P_VAR1
    ORDER BY a.OPERATETIME DESC
    ; 
elsif p_funcCode = 'QueryBalUnitDepositExamInfo' then --��ѯ����˱�֤����֧��¼
    open p_cursor for    
    SELECT 
        decode(a.STATECODE,'1','�����','2','���ͨ��','3','�������',a.STATECODE) ���״̬,
        decode(a.TRADETYPECODE,'01','����汣֤��','02','����֧����֤��',a.TRADETYPECODE) ҵ������,
        a.DBALUNITNO ���㵥Ԫ����, b.DBALUNIT ���㵥Ԫ����, a.CURRENTMONEY/100.0 ���׽��, 
        a.CHINESEMONEY ����д,c.STAFFNAME ����Ա��, a.OPERATETIME ����ʱ��, a.REMARK ��ע
    FROM TF_B_DEPTACC_EXAM a,TF_DEPT_BALUNIT b, TD_M_INSIDESTAFF c
    WHERE a.DBALUNITNO = b.DBALUNITNO
    AND   a.OPERATESTAFFNO = c.STAFFNO(+)
    AND   a.STATECODE = '1'
    AND   b.USETAG = '1'
    AND   a.TRADETYPECODE IN('01','02')
    AND   a.DBALUNITNO = P_VAR1
    ORDER BY a.OPERATETIME DESC
    ; 
elsif p_funcCode = 'QueryBalUnitDepositCancelInfo' then --��ѯ������ϱ�֤����֧��¼
    open p_cursor for    
    SELECT 
        decode(a.STATECODE,'1','�����','2','���ͨ��','3','�������',a.STATECODE) ���״̬,
        decode(a.TRADETYPECODE,'01','����汣֤��','02','����֧����֤��',a.TRADETYPECODE) ҵ������,
        a.DBALUNITNO ���㵥Ԫ����, b.DBALUNIT ���㵥Ԫ����, a.CURRENTMONEY/100.0 ���׽��, 
        a.CHINESEMONEY ����д,c.STAFFNAME ����Ա��, a.OPERATETIME ����ʱ��,
        d.STAFFNAME ���Ա�� , a.EXAMKTIME ���ʱ�� , a.REMARK ��ע
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
elsif p_funcCode = 'QueryDeptBalRelation' then --��ѯ������㵥Ԫ��ϵ
    open p_cursor for 
	SELECT * FROM( 
		SELECT row_number() over(ORDER BY R.DBALUNITNO)AS NUM, 
		   R.DBALUNITNO,
		   B.DBALUNIT,
		   R.DEPARTNO,
		   D.DEPARTNAME,
		   DECODE(B.DEPTTYPE, '0', '��Ӫ����', '1', '��������','2', '�����̻�', B.DEPTTYPE) DEPTTYPE
		FROM TD_DEPTBAL_RELATION R, TF_DEPT_BALUNIT B, TD_M_INSIDEDEPART D
		WHERE R.DBALUNITNO = B.DBALUNITNO
		AND R.DEPARTNO = D.DEPARTNO
		AND (P_VAR1 IS NULL OR P_VAR1 = R.DBALUNITNO)
		AND (P_VAR2 IS NULL OR P_VAR2 = R.DEPARTNO)
		AND R.USETAG = '1' AND B.USETAG = '1' 
	)
    ;   
elsif p_funcCode = 'QueryDeptBalDeviceRelation' then --��ѯ������㵥Ԫ�豸��ϵ
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
elsif p_funcCode = 'QueryDeptBalApprovalInfo' then --��ѯ������������㵥Ԫ��Ϣ
    open p_cursor for     
    SELECT  
       T.DTRADETYPECODE, 												
		   CASE WHEN T.DTRADETYPECODE = '01'  THEN '����-���㵥Ԫ'  										
			      WHEN T.DTRADETYPECODE = '02'  THEN '�޸�-���㵥Ԫ' 									
            WHEN T.DTRADETYPECODE = '03'  THEN 'ɾ��-���㵥Ԫ' 									
		        WHEN T.DTRADETYPECODE = '21'  THEN '����-Ӷ�𷽰�' 									
			      WHEN T.DTRADETYPECODE = '22'  THEN '�޸�-Ӷ�𷽰�'  									
			      WHEN T.DTRADETYPECODE = '23'  THEN 'ɾ��-Ӷ�𷽰�' 									
			      WHEN T.DTRADETYPECODE = '11'  THEN '����-���㵥Ԫ�����ϵ' 									
			      WHEN T.DTRADETYPECODE = '12'  THEN '�޸�-���㵥Ԫ�����ϵ'  									
			      WHEN T.DTRADETYPECODE = '13'  THEN 'ɾ��-���㵥Ԫ�����ϵ'  END BIZTYPE,  									
			 B.DBALUNITNO    , B.DBALUNIT   , B.BANKACCNO  ,  
			 F.BANK OPENBANK , B.CREATETIME , B.UNITEMAIL  ,   									
		   CASE WHEN B.DEPTTYPE = '0' THEN '��Ӫ����' 										
		      	WHEN B.DEPTTYPE = '1' THEN '��������' 
				WHEN B.DEPTTYPE = '2' THEN '�����̻�' END DEPTTYPE, 									
	     CASE WHEN B.BALCYCLETYPECODE = '00' THEN 'Сʱ'										
			      WHEN B.BALCYCLETYPECODE = '01' THEN '��'									
			      WHEN B.BALCYCLETYPECODE = '02' THEN '��'									
			      WHEN B.BALCYCLETYPECODE = '03' THEN '�̶���' 									
			      WHEN B.BALCYCLETYPECODE = '04' THEN '��Ȼ��' END BALCYCLETYPE, 									
			 B.BALINTERVAL ,  									
	     CASE WHEN B.FINCYCLETYPECODE = '00' THEN 'Сʱ' 										
			      WHEN B.FINCYCLETYPECODE = '01' THEN '��' 									
		       	WHEN B.FINCYCLETYPECODE = '02' THEN '��' 									
		      	WHEN B.FINCYCLETYPECODE = '03' THEN '�̶���' 									
		       	WHEN B.FINCYCLETYPECODE = '04' THEN '��Ȼ��' END FINCYCLETYPE, 									
		   B.FININTERVAL , 									
		   CASE WHEN B.FINTYPECODE = '0' THEN '������ת��' 										
		      	WHEN B.FINTYPECODE = '1' THEN '����Ԥ����' END FINTYPE, 									
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
elsif p_funcCode = 'QueryCurrentCom' then --��ѯ��ǰӶ�𷽰�
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
elsif p_funcCode = 'QueryAlreadyCom' then --��ѯ����Ӷ�𷽰�
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
elsif p_funcCode = 'QueryCurrentRelation' then --��ѯ��ǰ���㵥Ԫ�����ϵ
    open p_cursor for 	
		SELECT  B.DBALUNIT ,                                																	
			    	D.DEPARTNAME ,                                															
				    DECODE(B.DEPTTYPE, '0', '��Ӫ����', '1', '��������','2', '�����̻�',B.DEPTTYPE) DEPTTYPE									
		FROM   	TH_DEPTBAL_RELATION R,																
				    TF_DEPT_BALUNIT B,															
			    	TD_M_INSIDEDEPART D                              															
		WHERE   R.DBALUNITNO=B.DBALUNITNO                                																	
		AND     R.DEPARTNO=D.DEPARTNO                                															
		AND     R.TRADEID = P_VAR1
		; 															         
elsif p_funcCode = 'QueryAlreadyRelation' then --��ѯ���н��㵥Ԫ�����ϵ
    open p_cursor for 	     
		SELECT B.DBALUNIT ,											
				   D.DEPARTNAME ,											
				   DECODE(B.DEPTTYPE, '0', '��Ӫ����', '1', '��������','2', '�����̻�',B.DEPTTYPE) DEPTTYPE											
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
elsif p_funcCode = 'QueryDeptBalFiApprovalInfo' then --��ѯ���������������㵥Ԫ��Ϣ
    open p_cursor for		
  	SELECT 
  	   E.DTRADETYPECODE, 																												
		   CASE WHEN E.DTRADETYPECODE = '01'  THEN '����-���㵥Ԫ'  																										
				    WHEN E.DTRADETYPECODE = '02'  THEN '�޸�-���㵥Ԫ' 																									
				    WHEN E.DTRADETYPECODE = '03'  THEN 'ɾ��-���㵥Ԫ' 																									
				    WHEN E.DTRADETYPECODE = '21'  THEN '����-Ӷ�𷽰�' 																									
				    WHEN E.DTRADETYPECODE = '22'  THEN '�޸�-Ӷ�𷽰�'                        																									
				    WHEN E.DTRADETYPECODE = '23'  THEN 'ɾ��-Ӷ�𷽰�'                       																									
				    WHEN E.DTRADETYPECODE = '11'  THEN '����-���㵥Ԫ�����ϵ'                       																									
			    	WHEN E.DTRADETYPECODE = '12'  THEN '�޸�-���㵥Ԫ�����ϵ'                        																									
			    	WHEN E.DTRADETYPECODE = '13'  THEN 'ɾ��-���㵥Ԫ�����ϵ'  END BIZTYPE,  																									
			 B.DBALUNITNO , B.DBALUNIT      , B.DEPTTYPE DEPTTYPECODE , 																									
			 B.BANKCODE   , F.BANK OPENBANK , B.BANKACCNO , 																									
		   B.CREATETIME , B.BALCYCLETYPECODE ,  																									
			 CASE WHEN B.DEPTTYPE = '0' THEN '��Ӫ����'																							
				    WHEN B.DEPTTYPE = '1' THEN '��������' 
					WHEN B.DEPTTYPE = '2' THEN '�����̻�' 
					END DEPTTYPE, 																									
			 CASE WHEN B.BALCYCLETYPECODE = '00' THEN 'Сʱ' 																										
				    WHEN B.BALCYCLETYPECODE = '01' THEN '��' 																									
				    WHEN B.BALCYCLETYPECODE = '02' THEN '��' 																									
				    WHEN B.BALCYCLETYPECODE = '03' THEN '�̶���' 																									
				    WHEN B.BALCYCLETYPECODE = '04' THEN '��Ȼ��' END BALCYCLETYPE, 																									
			 B.BALINTERVAL, B.FINCYCLETYPECODE, 																									
			 CASE WHEN B.FINCYCLETYPECODE = '00' THEN 'Сʱ' 																										
				    WHEN B.FINCYCLETYPECODE = '01' THEN '��' 																									
				    WHEN B.FINCYCLETYPECODE = '02' THEN '��' 																									
				    WHEN B.FINCYCLETYPECODE = '03' THEN '�̶���' 																									
				    WHEN B.FINCYCLETYPECODE = '04' THEN '��Ȼ��' END FINCYCLETYPE, 																									
			 B.FININTERVAL, B.FINTYPECODE, 																									
			 CASE WHEN B.FINTYPECODE = '0' THEN '������ת��' 																										
				    WHEN B.FINTYPECODE = '1' THEN '����Ԥ����' END FINTYPE, 																									
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
elsif p_funcCode = 'QueryStaffIsDeptBal' then --��ѯԱ���Ƿ��Ǵ���Ӫҵ��Ա��
    open p_cursor for
    SELECT A.DBALUNITNO , A.DEPTTYPE
    FROM   TF_DEPT_BALUNIT A , TD_DEPTBAL_RELATION B , TD_M_INSIDESTAFF C
    WHERE  A.DBALUNITNO   = B.DBALUNITNO
    AND    B.DEPARTNO     = C.DEPARTNO
    AND    A.USETAG       = '1' --��Ч
    AND    B.USETAG       = '1' --��Ч
    AND    C.DIMISSIONTAG = '1' --��ְ
    AND    C.STAFFNO      = P_VAR1
    ;
elsif p_funcCode = 'QueryDeptBalUnitDeposit' then --��ѯԱ���Ƿ��Ǵ���Ӫҵ��Ա��    
    open p_cursor for
    SELECT A.DEPOSIT/100.0 DEPOSIT, A.USABLEVALUE/100.0 USABLEVALUE, A.STOCKVALUE/100.0 STOCKVALUE, nvl(B.TAGVALUE/100.0,0) TAGVALUE
    FROM   TF_F_DEPTBAL_DEPOSIT A , TD_M_TAG B
    WHERE  A.ACCSTATECODE = '01'
    AND    B.TAGCODE = 'USERCARD_MONEY'
    AND    A.DBALUNITNO = P_VAR1
    ;
elsif p_funcCode = 'QueryDeptIsDeptBal' then --��ѯ�����Ƿ��Ǵ���Ӫҵ������
    open p_cursor for
    SELECT A.DBALUNITNO , A.DEPTTYPE
    FROM   TF_DEPT_BALUNIT A , TD_DEPTBAL_RELATION B
    WHERE  A.DBALUNITNO = B.DBALUNITNO
    AND    A.USETAG     = '1' --��Ч
    AND    B.USETAG     = '1' --��Ч
    AND    B.DEPARTNO   = P_VAR1
    ;
elsif p_funcCode = 'QueryPrepayDepositExam' then --��ѯ�����Ԥ���֤����֧ҵ��    
    open p_cursor for
    SELECT a.ID ,a.TRADETYPECODE,
           decode(a.TRADETYPECODE,'01','����汣֤��','02','����֧����֤��','11','�����Ԥ����','12','����֧��Ԥ����',a.TRADETYPECODE) TRADETYPE,
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
            update TMP_BalDeviceRelation_IMP set checkmsg = '�豸���к����ļ����ظ�' where DEVICENO = v_cur.DEVICENO  and  sessionid=p_var1 and OPTYPECODE = 'ADD';
        else
			select count(1) into v_idx from TD_BALREADER_RELATION where READERNO = v_cur.DEVICENO;
			if v_idx > 0 then
				update TMP_BalDeviceRelation_IMP set checkmsg = '�豸���к��Ѿ�����' where DEVICENO = v_cur.DEVICENO and  sessionid=p_var1 and OPTYPECODE = 'ADD';
			end if;
        end if;
    end loop;
    -- ��ѯ��Ӧ���ж��ٲ��Ϸ�
    open p_cursor for
    select rownum �ļ��к�, BALUNITNO ���㵥Ԫ����, DEVICENO �豸���к�,  nvl(checkmsg , 'OK') �����
    from TMP_BalDeviceRelation_IMP
    where checkmsg is not null and  sessionid=p_var1 and OPTYPECODE = 'ADD';
elsif p_funccode = 'QueryDeviceBal' then
    -- ��ѯ��Ӧ��ϵ
    open p_cursor for
    select rownum �ļ��к�, BALUNITNO ���㵥Ԫ����, DEVICENO �豸���к�, nvl(checkmsg , 'OK') �����
    from TMP_BalDeviceRelation_IMP where sessionid = p_var1 and OPTYPECODE = 'ADD';
	
end if;
end;


/

show errors