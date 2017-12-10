create or replace procedure SP_RM_OTHER_Query
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

begin
      if p_funcCode = 'Query_ResourceOrder' then            --查询订购单
         open p_cursor for
          SELECT A.RESOURCEORDERID ,                                  --订购单号
                 A.APPLYORDERID ,                                     --需求单号
                 A.ORDERSTATE || ':' ||D.CODEDESC ORDERSTATE,                                       --订购单状态
                 C.RESUOURCETYPE,                                     --资源类型
                 B.RESOURCENAME,                                      --资源名称
                 A.RESOURCECODE  ,                                    --资源编码
                 A.RESOURCENUM  ,                                     --订购数量
                 A.REQUIREDATE  ,                                     --要求到货日期
                 A.ORDERTIME        ,                                 --下单时间
                 A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF,         --下单员工
                 A.REMARK                                             --备注
          FROM   TF_F_RESOURCEORDER  A ,          ---资源订购单表
                 TD_M_RESOURCE      B ,           ---资源表
                 TD_M_RESOURCETYPE  C ,           ---资源类型表
                 TD_M_RMCODING     D,              ---编码表
                 TD_M_INSIDESTAFF E
          WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
          AND    B.RESOURCECODE = A.RESOURCECODE
          AND    D.TABLENAME= 'TF_F_RESOURCEORDER'
          AND    D.COLNAME = 'ORDERSTATE'
          AND    D.CODEVALUE = A.ORDERSTATE
          AND    A.ORDERSTAFFNO = E.STAFFNO
          AND    A.USETAG = '1'
          AND   (P_VAR1 IS NULL  OR P_VAR1 = C.RESUOURCETYPECODE)
          AND   (P_VAR2 IS NULL  OR P_VAR2 = B.RESOURCECODE)
          AND   (P_VAR3 IS NULL  OR A.ORDERSTATE = P_VAR3)
          AND   (P_VAR4 IS NULL  OR P_VAR4 = A.RESOURCEORDERID )
          AND   (P_VAR5 IS NULL  OR P_VAR5 = A.APPLYORDERID )
          ORDER BY A.ORDERTIME DESC;
      elsif p_funcCode = 'Query_ResourceType' then         --查询资源类别
          open p_cursor for
          SELECT RESUOURCETYPE,RESUOURCETYPECODE
          FROM TD_M_RESOURCETYPE ORDER BY RESUOURCETYPECODE;
      elsif p_funcCode = 'Query_Resource' then         --查询资源
          open p_cursor for
          SELECT  RESOURCENAME,RESOURCECODE
          FROM TD_M_RESOURCE T
          WHERE (P_VAR1 IS NULL  OR P_VAR1 = T.RESOURCETYPE);
      elsif p_funcCode = 'Query_ResourceOrderInfo' then         --查询订购单明细
          open p_cursor for
          SELECT A.RESOURCEORDERID ,                                  --订购单号
                 A.APPLYORDERID ,                                     --需求单号
                 A.ORDERSTATE ||':'||E.CODEDESC STATE ,               --订购单状态
                 C.RESUOURCETYPE,                                     --资源类型
                 B.RESOURCENAME,                                      --资源名称
                 A.RESOURCECODE  ,                                    --资源编码
                 A.RESOURCENUM  ,                                     --订购数量
                 NVL(A.ALREADYARRIVENUM,0) ALREADYARRIVENUM,                                  --已到货数量
                 A.REQUIREDATE  ,                                     --要求到货日期
                 A.ORDERTIME        ,                                 --下单时间
                 A.ORDERSTAFFNO ||':'||D.STAFFNAME  STAFFNAME,        --下单员工
                 A.REMARK           ,                                 --备注
                 B.ATTRIBUTE1,
                 B.ATTRIBUTETYPE1,
                 B.ATTRIBUTEISNULL1,
                 A.ATTRIBUTE1 ATTRIBUTE1VALUE,
                 B.ATTRIBUTE2,
                 B.ATTRIBUTETYPE2,
                 B.ATTRIBUTEISNULL2,
                 A.ATTRIBUTE2 ATTRIBUTE2VALUE,
                 B.ATTRIBUTE3,
                 B.ATTRIBUTETYPE3,
                 B.ATTRIBUTEISNULL3,
                 A.ATTRIBUTE3 ATTRIBUTE3VALUE,
                 B.ATTRIBUTE4,
                 B.ATTRIBUTETYPE4,
                 B.ATTRIBUTEISNULL4,
                 A.ATTRIBUTE4 ATTRIBUTE4VALUE,
                 B.ATTRIBUTE5,
                 B.ATTRIBUTETYPE5,
                 B.ATTRIBUTEISNULL5,
                 A.ATTRIBUTE5 ATTRIBUTE5VALUE,
                 B.ATTRIBUTE6,
                 B.ATTRIBUTETYPE6,
                 B.ATTRIBUTEISNULL6,
                 A.ATTRIBUTE6 ATTRIBUTE6VALUE
          FROM   TF_F_RESOURCEORDER  A ,          ---资源订购单表
                 TD_M_RESOURCE      B ,           ---资源表
                 TD_M_RESOURCETYPE  C ,           ---资源类型表
                 TD_M_INSIDESTAFF  D ,
                 TD_M_RMCODING      E
          WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
          AND    B.RESOURCECODE = A.RESOURCECODE
          AND    D.STAFFNO = A.ORDERSTAFFNO
          AND    A.ORDERSTATE = E.CODEVALUE
          AND    E.COLNAME = 'ORDERSTATE'
          AND    E.TABLENAME = 'TF_F_RESOURCEORDER'
          AND    A.USETAG = '1'
          AND    A.RESOURCEORDERID = P_VAR1;
 	ELSIF p_funcCode = 'Query_GridResourceType' then         --查询资源类别明细
          open p_cursor for
		  SELECT    A.RESUOURCETYPE 资源类型, ---资源类型
					B.RESOURCECODE 资源编码,  ---资源编码
					B.RESOURCENAME 资源名称, ---资源名称
					B.ATTRIBUTE1 属性名称,B.ATTRIBUTE2,B.ATTRIBUTE3,B.ATTRIBUTE4,B.ATTRIBUTE5,B.ATTRIBUTE6, ---属性名称
					B.DESCPIRTION 描述  ---描述
		   FROM     TD_M_RESOURCETYPE A , TD_M_RESOURCE B
		   WHERE    A.RESUOURCETYPECODE = B.RESOURCETYPE
		   AND      (A.RESUOURCETYPECODE = P_VAR1 OR P_VAR1 IS NULL OR P_VAR1 = '')
		   ORDER BY B.UPDATETIME DESC;
    ELSIF p_funcCode = 'Query_ListResourceType' then		  --查询资源表明细
		open p_cursor for
		  SELECT    B.RESOURCECODE,  ---资源编码
					B.RESOURCENAME, ---资源名称
					B.DESCPIRTION,  ---描述
					B.RESOURCETYPE,    --资源类型编码
					B.ATTRIBUTE1,		--属性名称
					B.ATTRIBUTETYPE1,   --领用属性
					B.ATTRIBUTEISNULL1, --是否必填
					B.ATTRIBUTE2,
					B.ATTRIBUTETYPE2,
					B.ATTRIBUTEISNULL2,
					B.ATTRIBUTE3,
					B.ATTRIBUTETYPE3,
					B.ATTRIBUTEISNULL3,
					B.ATTRIBUTE4,
					B.ATTRIBUTETYPE4,
					B.ATTRIBUTEISNULL4,
					B.ATTRIBUTE5,
					B.ATTRIBUTETYPE5,
					B.ATTRIBUTEISNULL5,
					B.ATTRIBUTE6,
					B.ATTRIBUTETYPE6,
					B.ATTRIBUTEISNULL6
		   FROM     TD_M_RESOURCE B
		   WHERE    B.RESOURCECODE = P_VAR1;
	ELSIF p_funcCode = 'Query_Department' then         --查询申请部门
          open p_cursor for
          SELECT  DEPARTNAME,DEPARTNO
          FROM TD_M_INSIDEDEPART ORDER BY 2;
    ELSIF p_funcCode = 'Query_Staff' then         --查询申请员工
          open p_cursor for
          SELECT T.STAFFNAME,T.STAFFNO
          FROM TD_M_INSIDESTAFF T
          WHERE (P_VAR1 IS NULL  OR P_VAR1 = T.DEPARTNO);
	ELSIF p_funcCode = 'Query_GetResourceApply' then    ---查询资源领用单
		  open p_cursor for
		  SELECT A.GETORDERID ,                                       --领用单号
		 A.ORDERSTATE ||':'||F.CODEDESC STATE ,               --订购单状态
		 C.RESUOURCETYPE,                                     --资源类型
		 B.RESOURCENAME,                                      --资源名称
		 A.RESOURCECODE  ,                                    --资源编码
			 A.APPLYGETNUM  ,                                     --申请领用数量
			 A.AGREEGETNUM  ,                                     --同意领用数量
		   A.ORDERTIME        ,                                 --申请时间
			 D.STAFFNO ||':'|| D.STAFFNAME  STAFFNAME ,           --申请员工
			 E.DEPARTNO ||':'|| E.DEPARTNAME  DEPARTNAME,         --申请部门
				 A.USEWAY  ,                                          --用途
				 A.REMARK           ,                                 --备注
			 G.STAFFNO ||':' ||G.STAFFNAME GETSTAFFNAME,						--领用员工
			 A.ALREADYGETNUM,																			--已领数量
			 A.LATELYGETDATE,																		  --最近领用日期
			  B.ATTRIBUTE1  BATTRIBUTE1  ,
			 A.ATTRIBUTE1  AATTRIBUTE1,      --属性（将所有属性查出后，拼接显示在GridView中）
			 B.ATTRIBUTE2  BATTRIBUTE2,
			 A.ATTRIBUTE2  AATTRIBUTE2,
			 B.ATTRIBUTE3  BATTRIBUTE3,
			 A.ATTRIBUTE3  AATTRIBUTE3,
		   B.ATTRIBUTE4  BATTRIBUTE4,
			 A.ATTRIBUTE4  AATTRIBUTE4,
			 B.ATTRIBUTE5  BATTRIBUTE5,
		   A.ATTRIBUTE5  AATTRIBUTE5,
		   B.ATTRIBUTE6  BATTRIBUTE6,
			 A.ATTRIBUTE6  AATTRIBUTE6                                      --资源属性6
		  FROM    TF_F_GETRESOURCEORDER  A ,       ---资源领用单表
					TD_M_RESOURCE      B ,           ---资源表
				TD_M_RESOURCETYPE  C ,           ---资源类型表
				  TD_M_INSIDESTAFF  D ,
					TD_M_INSIDEDEPART  E ,
					TD_M_RMCODING      F,
					TD_M_INSIDESTAFF   G
			WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
			AND    B.RESOURCECODE = A.RESOURCECODE
			AND    D.STAFFNO = A.ORDERSTAFFNO
			AND    E.DEPARTNO = D.DEPARTNO
			AND    A.GETSTAFFNO = G.STAFFNO(+)
			AND    A.ORDERSTATE = F.CODEVALUE
			AND    F.COLNAME = 'ORDERSTATE'
			AND    F.TABLENAME = 'TF_F_GETRESOURCEORDER'
			AND    A.USETAG = '1'
			AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR TO_DATE(P_VAR1||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
			AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
			AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR P_VAR3 = A.ORDERSTATE)
			AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = E.DEPARTNO )
			AND   (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = A.ORDERSTAFFNO )
			AND 	(P_VAR6 IS NULL OR P_VAR6 = '' OR P_VAR6 = C.RESUOURCETYPECODE )
			AND 	(P_VAR7 IS NULL OR P_VAR7 = '' OR P_VAR7 = A.RESOURCECODE )
			AND 	(P_VAR8 IS NULL OR P_VAR8 = '' OR P_VAR8 != A.ORDERSTATE )
			AND 	(P_VAR9 IS NULL OR P_VAR9 = '' OR P_VAR9 != A.ORDERSTATE )
			ORDER BY A.ORDERTIME DESC;
	ELSIF p_funcCode = 'Query_GetAttribute' then    ---查询资源属性
		  open p_cursor for
		  SELECT  A.ATTRIBUTE1,
				A.ATTRIBUTETYPE1,
				A.ATTRIBUTEISNULL1,
				A.ATTRIBUTE2,
				A.ATTRIBUTETYPE2,
				A.ATTRIBUTEISNULL2,
				A.ATTRIBUTE3,
				A.ATTRIBUTETYPE3,
				A.ATTRIBUTEISNULL3,
				A.ATTRIBUTE4,
				A.ATTRIBUTETYPE4,
				A.ATTRIBUTEISNULL4,
				A.ATTRIBUTE5,
				A.ATTRIBUTETYPE5,
				A.ATTRIBUTEISNULL5,
				A.ATTRIBUTE6,
				A.ATTRIBUTETYPE6,
				A.ATTRIBUTEISNULL6
			FROM  TD_M_RESOURCE A
			WHERE A.RESOURCECODE = P_VAR1;
	ELSIF p_funcCode = 'Query_GetApplyOrder' then
			open p_cursor for
			SELECT A.APPLYORDERID 需求单号,   --需求单号
			   A.APPLYORDERTYPE ||':'||D.CODEDESC 需求单状态,  --需求单状态
			   C.RESUOURCETYPE 资源类型,   --资源类型
			   B.RESOURCENAME 资源名称,    --资源名称
			   A.RESOURCECODE 资源编码,    --资源编码
			   A.RESOURCENUM 数量,     --数量
			   A.REQUIREDATE 要求到货日期,     --要求到货日期
			   A.ORDERDEMAND 订单要求,    --订单要求
			   A.ORDERTIME 下单时间,      --下单时间
			   A.ORDERSTAFFNO 下单员工,   --下单员工
			   A.ALREADYORDERNUM 已订购数量,--已订购数量
			   A.LATELYDATE 最近到货时间,     --最近到货时间
			   A.ALREADYARRIVENUM 已到货数量, --已到货数量
			   B.ATTRIBUTE1 属性1,
			   A.ATTRIBUTE1 属性值1,      --属性（将所有属性查出后，拼接显示在GridView中）
			   B.ATTRIBUTE2 属性2,
			   A.ATTRIBUTE2 属性值2,
			   B.ATTRIBUTE3 属性3,
			   A.ATTRIBUTE3 属性值3,
			   B.ATTRIBUTE4 属性4,
			   A.ATTRIBUTE4 属性值4,
			   B.ATTRIBUTE5 属性5,
			   A.ATTRIBUTE5 属性值5,
			   B.ATTRIBUTE6 属性6,
			   A.ATTRIBUTE6 属性值6,
			   A.REMARK  备注        --备注
			FROM   TF_F_RESOURCEAPPLYORDER  A ,     ---资源需求单表
				   TD_M_RESOURCE      B ,           ---资源表
				   TD_M_RESOURCETYPE  C ,           ---资源类型表
				   TD_M_RMCODING      D
			WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
			AND    B.RESOURCECODE = A.RESOURCECODE
			AND    A.APPLYORDERTYPE = D.CODEVALUE
			AND    D.COLNAME = 'ORDERSTATE'
			AND    D.TABLENAME = 'TF_F_RESOURCEORDER'
			AND    A.APPLYORDERTYPE IN ('0','1')
			AND    A.USETAG = '1'
			AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = C.RESUOURCETYPECODE)
			AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = B.RESOURCECODE)
			AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR P_VAR3 = A.APPLYORDERID)
			AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR TO_DATE(P_VAR4||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
			AND   (P_VAR5 IS NULL OR P_VAR5 = '' OR TO_DATE(P_VAR5||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
			ORDER BY A.ORDERTIME DESC;
	ELSIF p_funcCode = 'Query_GridUnderOrder' then					--资源下单获取Grid信息
			open p_cursor for
			SELECT A.APPLYORDERID 需求单号,                                     --需求单号
				   C.RESUOURCETYPE 资源类型,                                     --资源类型
				   B.RESOURCENAME 资源名称,                                      --资源名称
				   A.RESOURCECODE 资源编码,                                      --资源编码
				   B.ATTRIBUTE1 属性,
				   A.ATTRIBUTE1,      --属性（将所有属性查出后，拼接显示在GridView中）
				   B.ATTRIBUTE2,
				   A.ATTRIBUTE2,
				   B.ATTRIBUTE3,
				   A.ATTRIBUTE3,
				   B.ATTRIBUTE4,
				   A.ATTRIBUTE4,
				   B.ATTRIBUTE5,
				   A.ATTRIBUTE5,
				   B.ATTRIBUTE6,
				   A.ATTRIBUTE6,
				   A.RESOURCENUM 下单数量,                                       --下单数量
				   A.REQUIREDATE 要求到货日期,                                   --要求到货日期
				   A.LATELYDATE 最近到货日期,                                    --最近到货日期
				   A.ORDERTIME 下单时间,                                         --下单时间
				   D.STAFFNAME 下单员工,                                  		 --下单员工
				   A.ALREADYORDERNUM 已订购数量,                                 --已订购数量
				   A.ORDERDEMAND 订单要求,                                       --订单要求
				   A.REMARK 备注                                           		 --备注
			FROM   TF_F_RESOURCEAPPLYORDER  A ,     ---资源需求单表
				   TD_M_RESOURCE      B ,           ---资源表
				   TD_M_RESOURCETYPE  C ,           ---资源类型表
				   TD_M_INSIDESTAFF  D
			WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
			AND    B.RESOURCECODE = A.RESOURCECODE
			AND    D.STAFFNO = A.ORDERSTAFFNO
			AND    A.APPLYORDERTYPE IN ('0','1')
			AND    A.USETAG = '1'
			AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.APPLYORDERID)
			AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
			AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
			ORDER BY A.ORDERTIME DESC;
	ELSIF p_funcCode = 'Query_ListUnderOrder' then				--资源下单获取详细信息
			open p_cursor for
			SELECT A.APPLYORDERID ,                                     --需求单号
				   C.RESUOURCETYPE,                                     --资源类型
				   B.RESOURCENAME,                                      --资源名称
				   A.RESOURCENUM,                                       --下单数量
				   A.REQUIREDATE,                                       --要求到货日期
				   A.LATELYDATE,                                        --最近到货日期
				   A.ORDERTIME ,                                        --下单时间
				   D.STAFFNAME  ,                                       --申请员工
				   A.ALREADYORDERNUM ,                                  --已订购数量
				   A.ORDERDEMAND ,                                      --订单要求
				   A.REMARK ,                                           --备注
				   B.ATTRIBUTE1,
				   A.ATTRIBUTE1,      --属性（将所有属性查出后，拼接显示在GridView中）
				   B.ATTRIBUTE2,
				   A.ATTRIBUTE2,
				   B.ATTRIBUTE3,
				   A.ATTRIBUTE3,
				   B.ATTRIBUTE4,
				   A.ATTRIBUTE4,
				   B.ATTRIBUTE5,
				   A.ATTRIBUTE5,
				   B.ATTRIBUTE6,
				   A.ATTRIBUTE6
			FROM   TF_F_RESOURCEAPPLYORDER  A ,     ---资源需求单表
				   TD_M_RESOURCE      B ,           ---资源表
				   TD_M_RESOURCETYPE  C ,           ---资源类型表
				   TD_M_INSIDESTAFF  D
			WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
			AND    B.RESOURCECODE = A.RESOURCECODE
			AND    D.STAFFNO = A.ORDERSTAFFNO
			AND    A.APPLYORDERID = P_VAR1 ;
	ELSIF p_funcCode = 'Query_ResourceUnderExam' THEN			--资源下单审核
		open p_cursor for
			SELECT A.RESOURCEORDERID 订购单号,                        --订购单号
				   A.APPLYORDERID  需求单号,                          --需求单号
				   A.ORDERSTATE ||':'||F.CODEDESC 订购单状态,         --订购单状态
				   C.RESUOURCETYPE 资源类型,                          --资源类型
				   B.RESOURCENAME 资源名称,                           --资源名称
				   B.ATTRIBUTE1 属性,
				   A.ATTRIBUTE1,      --属性（将所有属性查出后，拼接显示在GridView中）
				   B.ATTRIBUTE2,
				   A.ATTRIBUTE2,
				   B.ATTRIBUTE3,
				   A.ATTRIBUTE3,
				   B.ATTRIBUTE4,
				   A.ATTRIBUTE4,
				   B.ATTRIBUTE5,
				   A.ATTRIBUTE5,
				   B.ATTRIBUTE6,
				   A.ATTRIBUTE6,
				   A.RESOURCENUM  数量,                               --数量
				   A.REQUIREDATE  要求到货日期,                       --要求到货日期
				   A.LATELYDATE   最近到货日期,                       --最近到货日期
				   A.ALREADYARRIVENUM  已到货数量,                    --已到货数量
				   A.ORDERTIME 下单时间,                              --下单时间
				   D.STAFFNAME  下单员工,                             --下单员工
				   A.EXAMTIME  审核时间,                              --审核时间
				   E.STAFFNAME 审核员工,                              --审核员工
				   A.REMARK 备注                                      --备注
			  FROM   TF_F_RESOURCEORDER  A ,          ---资源订购单表
				   TD_M_RESOURCE      B ,           ---资源表
				   TD_M_RESOURCETYPE  C ,           ---资源类型表
				   TD_M_INSIDESTAFF  D  ,
				   TD_M_INSIDESTAFF  E  ,
				   TD_M_RMCODING      F
			  WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
			  AND    A.RESOURCECODE = B.RESOURCECODE
			  AND    A.ORDERSTAFFNO = D.STAFFNO(+)
			  AND    A.EXAMSTAFFNO = E.STAFFNO(+)
			  AND    A.ORDERSTATE = F.CODEVALUE
			  AND    F.COLNAME = 'ORDERSTATE'
			  AND    F.TABLENAME = 'TF_F_RESOURCEORDER'
			  AND    A.USETAG = '1'
				AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.RESOURCEORDERID )
				AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = A.ORDERSTATE)
				ORDER BY A.ORDERTIME DESC;
   ELSIF p_funcCode = 'Query_GetResourceApplyNoApproved' THEN			--资源领用审批
		open p_cursor for
		  SELECT A.GETORDERID ,                                       --领用单号
       C.RESUOURCETYPE,                                     --资源类型
       B.RESOURCENAME,                                      --资源名称
       A.RESOURCECODE  ,                                    --资源编码
       A.APPLYGETNUM  ,                                     --申请领用数量
       A.ORDERTIME        ,                                 --申请时间
       D.STAFFNO ||':'|| D.STAFFNAME  STAFFNAME,            --申请员工
       E.DEPARTNO ||':'|| E.DEPARTNAME  DEPARTNAME,         --申请部门
       A.USEWAY  ,                                          --用途
       A.REMARK  ,                                        --备注
       B.ATTRIBUTE1  BATTRIBUTE1  ,
			 A.ATTRIBUTE1  AATTRIBUTE1,      --属性（将所有属性查出后，拼接显示在GridView中）
			 B.ATTRIBUTE2  BATTRIBUTE2,
			 A.ATTRIBUTE2  AATTRIBUTE2,
			 B.ATTRIBUTE3  BATTRIBUTE3,
			 A.ATTRIBUTE3  AATTRIBUTE3,
		   B.ATTRIBUTE4  BATTRIBUTE4,
			 A.ATTRIBUTE4  AATTRIBUTE4,
			 B.ATTRIBUTE5  BATTRIBUTE5,
		   A.ATTRIBUTE5  AATTRIBUTE5,
		   B.ATTRIBUTE6  BATTRIBUTE6,
			 A.ATTRIBUTE6  AATTRIBUTE6
      FROM   TF_F_GETRESOURCEORDER  A ,       ---资源领用单表
       TD_M_RESOURCE      B ,           ---资源表
       TD_M_RESOURCETYPE  C ,           ---资源类型表
       TD_M_INSIDESTAFF  D ,
       TD_M_INSIDEDEPART  E
      WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
      AND    B.RESOURCECODE = A.RESOURCECODE
      AND    D.STAFFNO = A.ORDERSTAFFNO
      AND    E.DEPARTNO = D.DEPARTNO
			AND    A.USETAG = '1'
			AND    A.ORDERSTATE = '0'
			ORDER BY A.ORDERTIME DESC;
		ELSIF p_funcCode = 'Query_STOCK' THEN			--库存查询
		open p_cursor for
		  SELECT A.RESUOURCETYPECODE||':'||RESUOURCETYPE 资源类型, B.RESOURCECODE||':'||RESOURCENAME 资源名称,NVL(INSNUM,0) 入库数,NVL(USENUM,0) 出库数
			FROM TD_M_RESOURCETYPE A
			INNER JOIN TD_M_RESOURCE B ON A.RESUOURCETYPECODE = B.RESOURCETYPE
			LEFT JOIN TL_R_RESOURCESUM C ON C.RESOURCECODE = B.RESOURCECODE
			WHERE (P_VAR1 is null or RESUOURCETYPECODE = P_VAR1)
			AND (P_VAR2 is null or B.RESOURCECODE = P_VAR2);
		ELSIF p_funcCode = 'Query_STOCK_DEPART' THEN			--库存查询
		open p_cursor for
		  select tr.ASSIGNEDDEPARTID||':'||tm.DEPARTNAME 网点,count(*) 数量
		  from TL_R_RESOURCE tr,TD_M_INSIDEDEPART tm
		  where tr.ASSIGNEDDEPARTID = tm.DEPARTNO(+)
		  and tr.RESOURCECODE = P_VAR1
		  and tr.STOCKSATECODE = '01'
		  group by tr.ASSIGNEDDEPARTID,tm.DEPARTNAME
		  order by tr.ASSIGNEDDEPARTID;
	 ELSIF p_funcCode = 'Query_ResourceList' THEN			--资源库存明细
		open p_cursor for
		SELECT C.RESUOURCETYPECODE||':'||RESUOURCETYPE  资源类型,
				B.RESOURCECODE||':'||RESOURCENAME 资源名称,
				B.ATTRIBUTE1 资源属性,
				A.ATTRIBUTE1,
				B.ATTRIBUTE2,
				A.ATTRIBUTE2,
				B.ATTRIBUTE3,
				A.ATTRIBUTE3,
				B.ATTRIBUTE4,
				A.ATTRIBUTE4,
				B.ATTRIBUTE5,
				A.ATTRIBUTE5,
				B.ATTRIBUTE6,
				A.ATTRIBUTE6,
				A.ASSIGNEDDEPARTID||':'||D.DEPARTNAME 网点,
				A.ASSIGNEDSTAFFNO||':'||E.STAFFNAME 营业员,
				A.USETIME 领用时间
			FROM TL_R_RESOURCE A 
			LEFT JOIN TD_M_RESOURCE B ON A.RESOURCECODE = B.RESOURCECODE
			INNER JOIN TD_M_RESOURCETYPE C ON B.RESOURCETYPE = C.RESUOURCETYPECODE
			LEFT JOIN TD_M_INSIDEDEPART D ON A.ASSIGNEDDEPARTID = D.DEPARTNO
			LEFT JOIN TD_M_INSIDESTAFF E ON A.ASSIGNEDSTAFFNO = E.STAFFNO
		WHERE (P_VAR1 is null or C.RESUOURCETYPECODE = P_VAR1)
		AND (P_VAR2 is null or A.RESOURCECODE = P_VAR2)
		AND (P_VAR3 is null or A.ASSIGNEDDEPARTID = P_VAR3)
		AND A.STOCKSATECODE = '01'
		ORDER  BY A.USETIME DESC;
     ELSIF p_funcCode = 'Query_GetResourceDistribution' THEN			--资源派发查询
		open p_cursor for
		  SELECT A.GETORDERID ,                                       --领用单号
       A.ORDERSTATE ||':'||F.CODEDESC STATE ,               --领用单状态
       C.RESUOURCETYPE,                                     --资源类型
       B.RESOURCENAME,                                      --资源名称
       A.RESOURCECODE  ,                                    --资源编码
       A.APPLYGETNUM  ,                                     --申请领用数量
       A.AGREEGETNUM  ,                                     --同意领用数量
       A.ORDERTIME        ,                                 --申请时间
       D.STAFFNO ||':'|| D.STAFFNAME  STAFFNAME,            --接收员工
       E.DEPARTNO ||':'|| E.DEPARTNAME  DEPARTNAME,         --接收部门
       A.USEWAY  ,                                          --用途
       A.REMARK  ,                                          --备注
       B.ATTRIBUTE1  BATTRIBUTE1  ,
			 A.ATTRIBUTE1  AATTRIBUTE1,      --属性（将所有属性查出后，拼接显示在GridView中）
			 B.ATTRIBUTE2  BATTRIBUTE2,
			 A.ATTRIBUTE2  AATTRIBUTE2,
			 B.ATTRIBUTE3  BATTRIBUTE3,
			 A.ATTRIBUTE3  AATTRIBUTE3,
		   B.ATTRIBUTE4  BATTRIBUTE4,
			 A.ATTRIBUTE4  AATTRIBUTE4,
			 B.ATTRIBUTE5  BATTRIBUTE5,
		   A.ATTRIBUTE5  AATTRIBUTE5,
		   B.ATTRIBUTE6  BATTRIBUTE6,
			 A.ATTRIBUTE6  AATTRIBUTE6
			FROM    TF_F_GETRESOURCEORDER  A ,       ---资源领用单表
					TD_M_RESOURCE      B ,           ---资源表
				TD_M_RESOURCETYPE  C ,           ---资源类型表
				  TD_M_INSIDESTAFF  D ,
					TD_M_INSIDEDEPART  E ,
					TD_M_RMCODING      F
			WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
			AND    B.RESOURCECODE = A.RESOURCECODE
			AND    D.STAFFNO = A.ORDERSTAFFNO
			AND    E.DEPARTNO = D.DEPARTNO
			AND    A.ORDERSTATE = F.CODEVALUE
			AND    F.COLNAME = 'ORDERSTATE'
			AND    F.TABLENAME = 'TF_F_GETRESOURCEORDER'
			AND    A.USETAG = '1'
      AND    SUBSTR(A.GETORDERID,0,2)='PF'
			AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR TO_DATE(P_VAR1||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
			AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
			AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR P_VAR3 = A.ORDERSTATE)
			AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = E.DEPARTNO )
			AND   (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = A.ORDERSTAFFNO )
			ORDER BY A.ORDERTIME DESC;
    ELSIF p_funcCode = 'Query_GetResource' THEN			             --资源领用查询
		open p_cursor for
		  SELECT A.GETORDERID ,                                 --领用单号
       A.ORDERSTATE ||':'||F.CODEDESC STATE ,               --领用单状态
       C.RESUOURCETYPE,                                     --资源类型
       B.RESOURCENAME,                                      --资源名称
       A.RESOURCECODE  ,                                    --资源编码
       A.APPLYGETNUM  ,                                     --申请领用数量
       A.AGREEGETNUM  ,                                     --同意领用数量
       A.ALREADYGETNUM ,                                    --已领用数量
       A.LATELYGETDATE  ,                                   --最近领用时间
       A.GETSTAFFNO ,                                       --领用员工
       A.ORDERTIME        ,                                 --申请时间
       D.STAFFNO ||':'|| D.STAFFNAME  STAFFNAME,            --申请员工
       E.DEPARTNO ||':'|| E.DEPARTNAME  DEPARTNAME,         --申请部门
       A.USEWAY  ,                                          --用途
       A.REMARK  ,                                           --备注
       A.APPLYGETNUM,																				--申请领用数量
       A.AGREEGETNUM,																				--同意领用数量
       A.ALREADYGETNUM, 																			--已领用数量
       B.ATTRIBUTE1,
       B.ATTRIBUTETYPE1,
       B.ATTRIBUTEISNULL1,
       A.ATTRIBUTE1 ATTRIBUTE1VALUE,
       B.ATTRIBUTE2,
       B.ATTRIBUTETYPE2,
       B.ATTRIBUTEISNULL2,
       A.ATTRIBUTE2 ATTRIBUTE2VALUE,
       B.ATTRIBUTE3,
       B.ATTRIBUTETYPE3,
       B.ATTRIBUTEISNULL3,
       A.ATTRIBUTE3 ATTRIBUTE3VALUE,
       B.ATTRIBUTE4,
       B.ATTRIBUTETYPE4,
       B.ATTRIBUTEISNULL4,
       A.ATTRIBUTE4 ATTRIBUTE4VALUE,
       B.ATTRIBUTE5,
       B.ATTRIBUTETYPE5,
       B.ATTRIBUTEISNULL5,
       A.ATTRIBUTE5 ATTRIBUTE5VALUE,
       B.ATTRIBUTE6,
       B.ATTRIBUTETYPE6,
       B.ATTRIBUTEISNULL6,
       A.ATTRIBUTE6 ATTRIBUTE6VALUE
			FROM   TF_F_GETRESOURCEORDER  A ,       ---资源领用单表
       TD_M_RESOURCE      B ,           ---资源表
       TD_M_RESOURCETYPE  C ,           ---资源类型表
       TD_M_INSIDESTAFF  D ,
       TD_M_INSIDEDEPART  E ,
       TD_M_RMCODING      F
			WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
			AND    B.RESOURCECODE = A.RESOURCECODE
			AND    D.STAFFNO = A.ORDERSTAFFNO
			AND    E.DEPARTNO = D.DEPARTNO
			AND    A.ORDERSTATE = F.CODEVALUE
			AND    F.COLNAME = 'ORDERSTATE'
			AND    F.TABLENAME = 'TF_F_GETRESOURCEORDER'
			AND    A.USETAG = '1'
      AND    A.ORDERSTATE IN ('1','3')
			AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.GETORDERID )
			AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
			AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
			AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = A.GETSTAFFNO)
      AND   (P_VAR5 IS NULL OR P_VAR5 = '')
			ORDER BY A.ORDERTIME DESC;
  ELSIF p_funcCode = 'Query_ResourceStockReturn' THEN			             --资源退库查询
		open p_cursor for
		  SELECT A.GETORDERID ,                                 --领用单号
       A.ORDERSTATE ||':'||F.CODEDESC STATE ,               --领用单状态
       C.RESUOURCETYPE,                                     --资源类型
       B.RESOURCENAME,                                      --资源名称
       A.RESOURCECODE  ,                                    --资源编码
       A.APPLYGETNUM  ,                                     --申请领用数量
       A.AGREEGETNUM  ,                                     --同意领用数量
       A.ALREADYGETNUM ,                                    --已领用数量
       A.LATELYGETDATE  ,                                   --最近领用时间
       A.GETSTAFFNO ,                                       --领用员工
       A.ORDERTIME        ,                                 --申请时间
       D.STAFFNO ||':'|| D.STAFFNAME  STAFFNAME,            --申请员工
       E.DEPARTNO ||':'|| E.DEPARTNAME  DEPARTNAME,         --申请部门
       A.USEWAY  ,                                          --用途
       A.REMARK  ,                                           --备注
       A.APPLYGETNUM,																				--申请领用数量
       A.AGREEGETNUM,																				--同意领用数量
       A.ALREADYGETNUM, 																			--已领用数量
       B.ATTRIBUTE1,
       B.ATTRIBUTETYPE1,
       B.ATTRIBUTEISNULL1,
       A.ATTRIBUTE1 ATTRIBUTE1VALUE,
       B.ATTRIBUTE2,
       B.ATTRIBUTETYPE2,
       B.ATTRIBUTEISNULL2,
       A.ATTRIBUTE2 ATTRIBUTE2VALUE,
       B.ATTRIBUTE3,
       B.ATTRIBUTETYPE3,
       B.ATTRIBUTEISNULL3,
       A.ATTRIBUTE3 ATTRIBUTE3VALUE,
       B.ATTRIBUTE4,
       B.ATTRIBUTETYPE4,
       B.ATTRIBUTEISNULL4,
       A.ATTRIBUTE4 ATTRIBUTE4VALUE,
       B.ATTRIBUTE5,
       B.ATTRIBUTETYPE5,
       B.ATTRIBUTEISNULL5,
       A.ATTRIBUTE5 ATTRIBUTE5VALUE,
       B.ATTRIBUTE6,
       B.ATTRIBUTETYPE6,
       B.ATTRIBUTEISNULL6,
       A.ATTRIBUTE6 ATTRIBUTE6VALUE
			FROM   TF_F_GETRESOURCEORDER  A ,       ---资源领用单表
       TD_M_RESOURCE      B ,           ---资源表
       TD_M_RESOURCETYPE  C ,           ---资源类型表
       TD_M_INSIDESTAFF  D ,
       TD_M_INSIDEDEPART  E ,
       TD_M_RMCODING      F
			WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
			AND    B.RESOURCECODE = A.RESOURCECODE
			AND    D.STAFFNO = A.ORDERSTAFFNO
			AND    E.DEPARTNO = D.DEPARTNO
			AND    A.ORDERSTATE = F.CODEVALUE
			AND    F.COLNAME = 'ORDERSTATE'
			AND    F.TABLENAME = 'TF_F_GETRESOURCEORDER'
			AND    A.USETAG = '1'
      AND    A.ORDERSTATE IN ('1','3','4')
			AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.GETORDERID )
			AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
			AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
			AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = A.GETSTAFFNO)
      AND   (P_VAR5 IS NULL OR P_VAR5 = '')
			ORDER BY A.ORDERTIME DESC;
  ELSIF p_funcCode = 'Query_GetResourceChose' THEN			             --资源领用查询
		open p_cursor for
		  SELECT A.GETORDERID ,                                 --领用单号
       A.ORDERSTATE ||':'||F.CODEDESC STATE ,               --领用单状态
       C.RESUOURCETYPE,                                     --资源类型
       B.RESOURCENAME,                                      --资源名称
       A.RESOURCECODE  ,                                    --资源编码
       A.APPLYGETNUM  ,                                     --申请领用数量
       A.AGREEGETNUM  ,                                     --同意领用数量
       A.ALREADYGETNUM ,                                    --已领用数量
       A.LATELYGETDATE  ,                                   --最近领用时间
       A.GETSTAFFNO ,                                       --领用员工
       A.ORDERTIME        ,                                 --申请时间
       D.STAFFNO ||':'|| D.STAFFNAME  STAFFNAME,            --申请员工
       E.DEPARTNO ||':'|| E.DEPARTNAME  DEPARTNAME,         --申请部门
       A.USEWAY  ,                                          --用途
       A.REMARK  ,                                           --备注
       A.APPLYGETNUM,																				--申请领用数量
       A.AGREEGETNUM,																				--同意领用数量
       A.ALREADYGETNUM, 																			--已领用数量
       B.ATTRIBUTE1,
       B.ATTRIBUTETYPE1,
       B.ATTRIBUTEISNULL1,
       A.ATTRIBUTE1 ATTRIBUTE1VALUE,
       B.ATTRIBUTE2,
       B.ATTRIBUTETYPE2,
       B.ATTRIBUTEISNULL2,
       A.ATTRIBUTE2 ATTRIBUTE2VALUE,
       B.ATTRIBUTE3,
       B.ATTRIBUTETYPE3,
       B.ATTRIBUTEISNULL3,
       A.ATTRIBUTE3 ATTRIBUTE3VALUE,
       B.ATTRIBUTE4,
       B.ATTRIBUTETYPE4,
       B.ATTRIBUTEISNULL4,
       A.ATTRIBUTE4 ATTRIBUTE4VALUE,
       B.ATTRIBUTE5,
       B.ATTRIBUTETYPE5,
       B.ATTRIBUTEISNULL5,
       A.ATTRIBUTE5 ATTRIBUTE5VALUE,
       B.ATTRIBUTE6,
       B.ATTRIBUTETYPE6,
       B.ATTRIBUTEISNULL6,
       A.ATTRIBUTE6 ATTRIBUTE6VALUE
			FROM   TF_F_GETRESOURCEORDER  A ,       ---资源领用单表
       TD_M_RESOURCE      B ,           ---资源表
       TD_M_RESOURCETYPE  C ,           ---资源类型表
       TD_M_INSIDESTAFF  D ,
       TD_M_INSIDEDEPART  E ,
       TD_M_RMCODING      F
			WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
			AND    B.RESOURCECODE = A.RESOURCECODE
			AND    D.STAFFNO = A.ORDERSTAFFNO
			AND    E.DEPARTNO = D.DEPARTNO
			AND    A.ORDERSTATE = F.CODEVALUE
			AND    F.COLNAME = 'ORDERSTATE'
			AND    F.TABLENAME = 'TF_F_GETRESOURCEORDER'
			AND    A.USETAG = '1'
			AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.GETORDERID )
			AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
			AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR TO_DATE(P_VAR3||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
			AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = A.GETSTAFFNO)
			AND    P_VAR5 = A.ORDERSTATE
			ORDER BY A.ORDERTIME DESC;
  ELSIF p_funcCode = 'Query_GetMaintainApply' THEN			             --资源维护申请查询
		open p_cursor for
		 SELECT A.MAINTAINORDERID ,                             --维护单号
       A.ORDERSTATE ||':'||F.CODEDESC STATE ,               --维护单状态
       C.RESUOURCETYPE,                                     --资源类型
       B.RESOURCENAME,                                      --资源名称
       A.MAINTAINREASON  ,                                  --申请原因
       E.DEPARTNO ||':'|| E.DEPARTNAME DEPARTNAME ,         --申请维护部门
       H.STAFFNO ||':'|| H.STAFFNAME  MAINTAINSTAFF,        --维护员工
       A.MAINTAINREQUEST,                                   --维护要求
       TO_CHAR(A.TIMELIMIT,'YYYYMMDD') TIMELIMIT,           --维护期限
       A.FEEDBACK,                                          --反馈信息
       A.ORDERTIME,                                         --下单时间
       D.STAFFNO ||':'|| D.STAFFNAME STAFFNAME,             --下单员工
       G.DEPARTNO ||':'||G.DEPARTNAME ORDERDEPART,          --下单部门
       A.REMARK                                             --备注
       FROM   TF_F_RESOURCEMAINTAINORDER  A ,       ---资源维护单
       TD_M_RESOURCE      B ,           ---资源表
       TD_M_RESOURCETYPE  C ,           ---资源类型表
       TD_M_INSIDESTAFF   D ,
       TD_M_INSIDEDEPART  E ,
       TD_M_RMCODING      F ,
       TD_M_INSIDEDEPART  G,
       TD_M_INSIDESTAFF   H
       WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
			AND    B.RESOURCECODE = A.RESOURCECODE
			AND    D.STAFFNO = A.ORDERSTAFFNO
      AND    D.DEPARTNO = G.DEPARTNO
      AND    H.STAFFNO(+) = A.MAINTAINSTAFF
			AND    E.DEPARTNO(+) = A.MAINTAINDEPT
			AND    A.ORDERSTATE = F.CODEVALUE
			AND    F.COLNAME = 'ORDERSTATE'
			AND    F.TABLENAME = 'TF_F_RESOURCEMAINTAINORDER'
			AND    A.USETAG = '1'
			AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR TO_DATE(P_VAR1||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
			AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
			AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR P_VAR3 = C.RESUOURCETYPECODE)
			AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = E.DEPARTNO)
      AND   (P_VAR5 IS NULL OR P_VAR5 = '' OR P_VAR5 = A.ORDERSTATE)
      AND    P_VAR6 = D.DEPARTNO
			ORDER BY A.ORDERTIME DESC;
   ELSIF p_funcCode = 'Query_ResourceMaintain' THEN                   --资源维护查询
    open p_cursor for
    SELECT MAINTAINORDERID,DECODE(A.ORDERSTATE,'0','待审核','1','审核通过','2','审核作废') ORDERSTATE,C.RESUOURCETYPECODE ||':'|| C.RESUOURCETYPE RESUOURCETYPE,
      B.RESOURCECODE || ':' || B.RESOURCENAME RESOURCENAME,
      A.MAINTAINREASON,A.FEEDBACK,A.ORDERTIME,A.ORDERSTAFFNO || ':' || D.STAFFNAME STAFFNAME,F.DEPARTNO || ':' || F.DEPARTNAME DEPARTNAME,A.REMARK,A.CHECKNOTE,A.MAINTAINSTAFF  MAINTAINSTAFF,A.TEL
      FROM TF_F_RESOURCEMAINTAINORDER A
      INNER JOIN TD_M_RESOURCE B ON B.RESOURCECODE= A.RESOURCECODE
      INNER JOIN TD_M_RESOURCETYPE C ON B.RESOURCETYPE = C.RESUOURCETYPECODE
      INNER JOIN TD_M_INSIDESTAFF D ON A.ORDERSTAFFNO = D.STAFFNO
      INNER JOIN TD_M_INSIDEDEPART F ON D.DEPARTNO = F.DEPARTNO
      WHERE  (P_VAR1 IS NULL OR P_VAR1 = C.RESUOURCETYPECODE )
      AND  (P_VAR2 IS NULL OR P_VAR2 = B.RESOURCECODE )
      AND (P_VAR3 IS NULL OR P_VAR3 = A.ORDERSTATE )
      AND   (P_VAR5 IS NULL OR P_VAR5 = '' OR TO_DATE(P_VAR5||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
			AND   (P_VAR6 IS NULL OR P_VAR6 = '' OR TO_DATE(P_VAR6||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
			AND (P_VAR7 IS NULL OR P_VAR7 = A.maintainstaff )
			AND (P_VAR8 IS NULL OR P_VAR8 = A.MAINTAINORDERID )
			ORDER BY A.MAINTAINORDERID DESC;
	ELSIF p_funcCode = 'QueryForResourceOrder' THEN			--订购单查询
		open p_cursor for
		SELECT A.RESOURCEORDERID 订购单号,                                  --订购单号
			   A.APPLYORDERID 需求单号,                                     --需求单号
			   A.ORDERSTATE ||':'||F.CODEDESC 订购单状态,               	--订购单状态
			   C.RESUOURCETYPE 资源类型,                                    --资源类型
			   B.RESOURCENAME 资源名称,                                     --资源名称
			   B.ATTRIBUTE1 属性,
			   A.ATTRIBUTE1,      --属性（将所有属性查出后，拼接显示在GridView中）
			   B.ATTRIBUTE2,
			   A.ATTRIBUTE2,
			   B.ATTRIBUTE3,
			   A.ATTRIBUTE3,
			   B.ATTRIBUTE4,
			   A.ATTRIBUTE4,
			   B.ATTRIBUTE5,
			   A.ATTRIBUTE5,
			   B.ATTRIBUTE6,
			   A.ATTRIBUTE6,
			   A.RESOURCENUM  数量,                                     	 --数量
			   A.REQUIREDATE  要求到货日期,                                  --要求到货日期
			   A.LATELYDATE   最近到货日期,                                  --最近到货日期
			   A.ALREADYARRIVENUM  已到货数量,                               --已到货数量
			   A.ORDERTIME  下单时间,                                 		 --下单时间
			   D.STAFFNAME  下单员工,                                 		 --下单员工
			   A.EXAMTIME   审核时间,                                 		 --审核时间
			   E.STAFFNAME 审核员工,                                         --审核员工
			   A.REMARK 备注                                 				 --备注
		FROM   TF_F_RESOURCEORDER  A ,          ---资源订购单表
			   TD_M_RESOURCE      B ,           ---资源表
			   TD_M_RESOURCETYPE  C ,           ---资源类型表
			   TD_M_INSIDESTAFF  D,
			   TD_M_INSIDESTAFF  E,
			   TD_M_RMCODING      F
		WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
		AND    B.RESOURCECODE = A.RESOURCECODE
		AND    D.STAFFNO = A.ORDERSTAFFNO
		AND    E.STAFFNO = A.EXAMSTAFFNO
		AND    A.ORDERSTATE = F.CODEVALUE
		AND    F.COLNAME = 'ORDERSTATE'
		AND    F.TABLENAME = 'TF_F_RESOURCEORDER'
		AND    A.USETAG = '1'
		AND   (P_VAR1 IS NULL OR P_VAR1 = '' OR P_VAR1 = A.RESOURCEORDERID )
		AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR P_VAR2 = A.APPLYORDERID )
		AND   (P_VAR3 IS NULL OR P_VAR3 = '' OR P_VAR3 = A.ORDERSTATE)
		AND   (P_VAR4 IS NULL OR P_VAR4 = '' OR P_VAR4 = C.RESUOURCETYPECODE)
		AND   (P_VAR5 IS NULL OR P_VAR5 = '' OR TO_DATE(P_VAR5||'000000','YYYYMMDDHH24MISS') <= A.ORDERTIME)
		AND   (P_VAR6 IS NULL OR P_VAR6 = '' OR TO_DATE(P_VAR6||'235959','YYYYMMDDHH24MISS') >= A.ORDERTIME)
		ORDER BY A.ORDERTIME DESC;
    ELSIF p_funcCode = 'Query_ContractList' THEN --查询合同列表
		open p_cursor for
    SELECT CONTRACTCODE,
		CONTRACTNAME,
		CONTRACTID,
		SIGNINGCOMPANY,
		SIGNINGDATE
    FROM TL_R_CONTRACT	 A
    WHERE (	P_VAR1 IS NULL OR	TO_DATE(P_VAR1||'000000','YYYYMMDDHH24MISS') <= A.SIGNINGDATE	)
     AND  ( P_VAR2 IS NULL OR   TO_DATE(P_VAR2||'235959','YYYYMMDDHH24MISS') >= A.SIGNINGDATE	)
		 AND  ( P_VAR3 IS NULL OR   CONTRACTNAME LIKE '%' || P_VAR3 || '%')
		 AND  ( P_VAR4 IS NULL OR   SIGNINGCOMPANY LIKE '%' || P_VAR4 || '%')
		 AND  (DOCUMENTTYPE IS NULL OR DOCUMENTTYPE = '0');
	 ELSIF p_funcCode = 'Query_DocumentList' THEN   --查询文档列表
		open p_cursor for
    SELECT CONTRACTCODE,
		CONTRACTNAME,
		CONTRACTID,
		SIGNINGCOMPANY,
		SIGNINGDATE,
		DECODE(DOCUMENTTYPE,'1','说明报告','2','保密协议','3','政府机构文件','4','公司文档','5','其他文档') DOCUMENTTYPE
    FROM TL_R_CONTRACT	 A
    WHERE (	P_VAR1 IS NULL OR	TO_DATE(P_VAR1||'000000','YYYYMMDDHH24MISS') <= A.SIGNINGDATE	)
     AND  ( P_VAR2 IS NULL OR   TO_DATE(P_VAR2||'235959','YYYYMMDDHH24MISS') >= A.SIGNINGDATE	)
		 AND  ( P_VAR3 IS NULL OR   CONTRACTNAME LIKE '%' || P_VAR3 || '%')
		 AND  ( P_VAR4 IS NULL OR   SIGNINGCOMPANY LIKE '%' || P_VAR4 || '%')
		 AND  (DOCUMENTTYPE IS NOT NULL AND  DOCUMENTTYPE != '0')
		  AND  ( P_VAR5 IS NULL OR  DOCUMENTTYPE  =  P_VAR5);
		 
    ELSIF p_funcCode = 'Query_ContractInfo' THEN
		open p_cursor for
    SELECT CONTRACTCODE,
		CONTRACTNAME,
		CONTRACTID,
		SIGNINGCOMPANY,
		SIGNINGDATE,
    CONTRACTDESC,
    CONTRACTFILE,
    CONTRACTFILENAME,
    DOCUMENTTYPE
    FROM TL_R_CONTRACT   A
    WHERE P_VAR1 = CONTRACTCODE  ;
  ELSIF p_funcCode = 'Query_ResourceCode' THEN
    open p_cursor for
    SELECT RESOURCECODE FROM TD_M_RESOURCE ORDER BY RESOURCECODE DESC;

  ELSIF p_funcCode = 'Query_Attribute1' THEN
		open p_cursor for
    SELECT DISTINCT ATTRIBUTE1 FROM TL_R_RESOURCE WHERE P_VAR1 = RESOURCECODE AND ATTRIBUTE1 IS NOT NULL;
  ELSIF p_funcCode = 'Query_Attribute2' THEN
		open p_cursor for
    SELECT DISTINCT ATTRIBUTE2 FROM TL_R_RESOURCE WHERE P_VAR1 = RESOURCECODE AND ATTRIBUTE2 IS NOT NULL;
  ELSIF p_funcCode = 'Query_Attribute3' THEN
		open p_cursor for
    SELECT DISTINCT ATTRIBUTE3 FROM TL_R_RESOURCE WHERE P_VAR1 = RESOURCECODE AND ATTRIBUTE3 IS NOT NULL;
  ELSIF p_funcCode = 'Query_Attribute4' THEN
		open p_cursor for
    SELECT DISTINCT ATTRIBUTE4 FROM TL_R_RESOURCE WHERE P_VAR1 = RESOURCECODE AND ATTRIBUTE4 IS NOT NULL;
  ELSIF p_funcCode = 'Query_Attribute5' THEN
		open p_cursor for
    SELECT DISTINCT ATTRIBUTE5 FROM TL_R_RESOURCE WHERE P_VAR1 = RESOURCECODE AND ATTRIBUTE5 IS NOT NULL;
  ELSIF p_funcCode = 'Query_Attribute6' THEN
		open p_cursor for
    SELECT DISTINCT ATTRIBUTE6 FROM TL_R_RESOURCE WHERE P_VAR1 = RESOURCECODE AND ATTRIBUTE6 IS NOT NULL;
ELSIF p_funcCode = 'Query_MaintainStaff' THEN --查询维护员工
		open p_cursor for
    SELECT DISTINCT STAFFNAME FROM TF_F_STAFFSIGNINSHEET T ;
 ELSIF p_funcCode = 'Query_StaffSignIn' THEN---查询员工签订记录
    open p_cursor for
    SELECT  T.CARDNO,T.SIGNINSHEETID,																								
        T.STAFFNAME,																								
        T.SIGNINTIME,																								
        decode( T.STATE,'0','未匹配','1','已匹配',T.STATE) STATE,																								
        T.OPERATEDEPT	||':'||D.DEPARTNAME OPERATEDEPT																							
    FROM    TF_F_STAFFSIGNINSHEET T ,td_m_insidedepart D  																								
    WHERE   T.OPERATEDEPT= D.departno(+)  																								
    AND    (p_var1 IS NULL OR p_var1 = '' OR to_char(t.SIGNINTIME,'yyyymmdd')>= p_var1)--签到时间																								
    AND    (p_var2 IS NULL OR p_var2 = '' OR to_char(t.SIGNINTIME,'yyyymmdd')<= p_var2)																								
    AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 =t.STATE)---匹配情况																								
    AND    (p_var4 IS NULL OR p_var4 = '' OR t.STAFFNAME =p_var4)
    order by T.SIGNINTIME;
  ELSIF p_funcCode = 'Query_StaffMaintainInput' THEN--查询录入的工单
    open p_cursor for	
    SELECT  T.SIGNINMAINTAINID,--维护单号																						
        T.MAINTAINDEPT||':'|| D.DEPARTNAME MAINTAINDEPT,--维护网点																						
        T.RESUOURCETYPECODE||':'||B.RESUOURCETYPE RESUOURCETYPE,  ---资源类型																						
        T.RESOURCECODE||':'||C.RESOURCENAME  RESOURCENAME,        ---资源名称																						
        T.USETIME||'小时' USETIME,----维护时长																						
        T.UPDATETIME,--维护时间																						
        T.STAFFNAME ,---维护员工
        decode( T.RELATEDSTATE,'0','未匹配','1','已匹配',T.RELATEDSTATE) RELATEDSTATE ,--是否匹配
        T.STATE,																						
        T.EXPLANATION  ---维护说明																						
    FROM    TF_F_STAFFMAINTAIN T ,TD_M_RESOURCETYPE B,TD_M_RESOURCE C,TD_M_INSIDEDEPART D 																						
    WHERE   T.MAINTAINDEPT= D.DEPARTNO  																						
    AND     T.RESUOURCETYPECODE=B.RESUOURCETYPECODE																						
    AND     T.RESOURCECODE=C.RESOURCECODE																																												
    AND    (p_var1 IS NULL OR p_var1 = '' OR to_char(t.UPDATETIME,'yyyymmdd')>= p_var1)																						
    AND    (p_var2 IS NULL OR p_var2 = '' OR to_char(t.UPDATETIME,'yyyymmdd')<= p_var2)																						
    AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 =t.Maintaindept)  ---网点
    AND    (p_var4 IS NULL OR p_var4 = '' OR p_var4 =t.RESUOURCETYPECODE)	---资源类型																						
		AND    (p_var5 IS NULL OR p_var5 = '' OR p_var5 =t.RESOURCECODE)	---资源名称	
    AND    (p_var6 IS NULL OR p_var6 = '' OR p_var6 =t.RELATEDSTATE)	---是否匹配
    ORDER BY T.UPDATETIME;				
  ELSIF p_funcCode = 'Query_StaffMaintainQuery' THEN--查询所有工单	
    open p_cursor for		
    SELECT  T.SIGNINMAINTAINID,--维护单号																													
        T.MAINTAINDEPT||':'|| D.DEPARTNAME MAINTAINDEPT,--维护网点																													
        T.RESUOURCETYPECODE||':'||B.RESUOURCETYPE RESUOURCETYPE,  ---资源类型																													
        T.RESOURCECODE||':'||C.RESOURCENAME  RESOURCENAME,        ---资源名称																													
        T.USETIME,----维护时长																													
        T.SIGNINTIME,--维护时间																													
        T.STAFFNAME ,---维护员工																													
        T.EXPLANATION,  ---维护说明	
        decode(P.ISFINISHED,'0','未完成','1','已完成',P.ISFINISHED) ISFINISHED, --是否完成
        P.CONFIRMATION, --确认说明
        decode(P.SATISFATION,'1','一星级','2','二星级','3','三星级','4','四星级','5','五星级',P.SATISFATION) SATISFATION --满意度																											
    FROM    TF_F_STAFFMAINTAIN T ,TF_F_CONFIRMSTAFFMAINTAIN P,TD_M_RESOURCETYPE B,TD_M_RESOURCE C,TD_M_INSIDEDEPART D 																													
    WHERE   T.MAINTAINDEPT= D.DEPARTNO  																													
    AND     T.RESUOURCETYPECODE=B.RESUOURCETYPECODE																													
    AND     T.SIGNINMAINTAINID=P.SIGNINMAINTAINID(+)																													
    AND     T.RESOURCECODE=C.RESOURCECODE		
    AND     T.RELATEDSTATE='1'																											
    AND    (p_var1 IS NULL OR p_var1 = '' OR to_char(t.UPDATETIME,'yyyymmdd')>= p_var1)																													
    AND    (p_var2 IS NULL OR p_var2 = '' OR to_char(t.UPDATETIME,'yyyymmdd')<= p_var2)																													
    AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 =t.MAINTAINDEPT)  ---维护网点
    AND    (p_var4 IS NULL OR p_var4 = '' OR p_var4 =t.STAFFNAME)  ---维护员工																												
    AND    (p_var5 IS NULL OR p_var5 = '' OR p_var5 =t.STATE)  ---维护单状态
    ORDER BY T.SIGNINTIME	;																												
	ELSIF p_funcCode = 'Query_StaffMaintain' THEN--查询工单
    open p_cursor for	
    SELECT  T.SIGNINMAINTAINID,--维护单号																						
        T.MAINTAINDEPT||':'|| D.DEPARTNAME MAINTAINDEPT,--维护网点																						
        T.RESUOURCETYPECODE||':'||B.RESUOURCETYPE RESUOURCETYPE,  ---资源类型																						
        T.RESOURCECODE||':'||C.RESOURCENAME  RESOURCENAME,        ---资源名称																						
        T.USETIME||'小时' USETIME,----维护时长																						
        T.SIGNINTIME,--维护时间																						
        T.STAFFNAME ,---维护员工
        decode( P.ISFINISHED,'0','0:未完成','1','1:已完成',P.ISFINISHED) ISFINISHED ,--完成情况
        decode( T.STATE,'0','0:未确认','1','1:已确认',T.STATE) STATE ,--是否确认																						
        T.EXPLANATION , ---维护说明	
        decode(P.SATISFATION,'1','1:一星级','2','2:二星级','3','3:三星级','4','4:四星级','5','5:五星级',P.SATISFATION) SATISFATION, --满意度
        P.CONFIRMATION,   ---确认说明
        P.CONFIRMID  --确认单号																					
    FROM    TF_F_STAFFMAINTAIN T ,TF_F_CONFIRMSTAFFMAINTAIN P,TD_M_RESOURCETYPE B,TD_M_RESOURCE C,TD_M_INSIDEDEPART D 																						
    WHERE   T.MAINTAINDEPT= D.DEPARTNO 
    AND     T.SIGNINMAINTAINID=P.SIGNINMAINTAINID(+) 																						
    AND     T.RESUOURCETYPECODE=B.RESUOURCETYPECODE																						
    AND     T.RESOURCECODE=C.RESOURCECODE																																												
    AND    (p_var1 IS NULL OR p_var1 = '' OR to_char(t.UPDATETIME,'yyyymmdd')>= p_var1)																						
    AND    (p_var2 IS NULL OR p_var2 = '' OR to_char(t.UPDATETIME,'yyyymmdd')<= p_var2)																						
    AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 =t.MAINTAINDEPT)  ---网点
    AND    (p_var4 IS NULL OR p_var4 = '' OR p_var4 =p.ISFINISHED)	---完成情况	
    AND    (p_var5 IS NULL OR p_var5 = '' OR p_var5 =T.STATE);
  end if;
end;


/
show errors