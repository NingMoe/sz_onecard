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
      if p_funcCode = 'Query_ResourceOrder' then            --��ѯ������
         open p_cursor for
          SELECT A.RESOURCEORDERID ,                                  --��������
                 A.APPLYORDERID ,                                     --���󵥺�
                 A.ORDERSTATE || ':' ||D.CODEDESC ORDERSTATE,                                       --������״̬
                 C.RESUOURCETYPE,                                     --��Դ����
                 B.RESOURCENAME,                                      --��Դ����
                 A.RESOURCECODE  ,                                    --��Դ����
                 A.RESOURCENUM  ,                                     --��������
                 A.REQUIREDATE  ,                                     --Ҫ�󵽻�����
                 A.ORDERTIME        ,                                 --�µ�ʱ��
                 A.ORDERSTAFFNO||':'||E.STAFFNAME ORDERSTAFF,         --�µ�Ա��
                 A.REMARK                                             --��ע
          FROM   TF_F_RESOURCEORDER  A ,          ---��Դ��������
                 TD_M_RESOURCE      B ,           ---��Դ��
                 TD_M_RESOURCETYPE  C ,           ---��Դ���ͱ�
                 TD_M_RMCODING     D,              ---�����
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
      elsif p_funcCode = 'Query_ResourceType' then         --��ѯ��Դ���
          open p_cursor for
          SELECT RESUOURCETYPE,RESUOURCETYPECODE
          FROM TD_M_RESOURCETYPE ORDER BY RESUOURCETYPECODE;
      elsif p_funcCode = 'Query_Resource' then         --��ѯ��Դ
          open p_cursor for
          SELECT  RESOURCENAME,RESOURCECODE
          FROM TD_M_RESOURCE T
          WHERE (P_VAR1 IS NULL  OR P_VAR1 = T.RESOURCETYPE);
      elsif p_funcCode = 'Query_ResourceOrderInfo' then         --��ѯ��������ϸ
          open p_cursor for
          SELECT A.RESOURCEORDERID ,                                  --��������
                 A.APPLYORDERID ,                                     --���󵥺�
                 A.ORDERSTATE ||':'||E.CODEDESC STATE ,               --������״̬
                 C.RESUOURCETYPE,                                     --��Դ����
                 B.RESOURCENAME,                                      --��Դ����
                 A.RESOURCECODE  ,                                    --��Դ����
                 A.RESOURCENUM  ,                                     --��������
                 NVL(A.ALREADYARRIVENUM,0) ALREADYARRIVENUM,                                  --�ѵ�������
                 A.REQUIREDATE  ,                                     --Ҫ�󵽻�����
                 A.ORDERTIME        ,                                 --�µ�ʱ��
                 A.ORDERSTAFFNO ||':'||D.STAFFNAME  STAFFNAME,        --�µ�Ա��
                 A.REMARK           ,                                 --��ע
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
          FROM   TF_F_RESOURCEORDER  A ,          ---��Դ��������
                 TD_M_RESOURCE      B ,           ---��Դ��
                 TD_M_RESOURCETYPE  C ,           ---��Դ���ͱ�
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
 	ELSIF p_funcCode = 'Query_GridResourceType' then         --��ѯ��Դ�����ϸ
          open p_cursor for
		  SELECT    A.RESUOURCETYPE ��Դ����, ---��Դ����
					B.RESOURCECODE ��Դ����,  ---��Դ����
					B.RESOURCENAME ��Դ����, ---��Դ����
					B.ATTRIBUTE1 ��������,B.ATTRIBUTE2,B.ATTRIBUTE3,B.ATTRIBUTE4,B.ATTRIBUTE5,B.ATTRIBUTE6, ---��������
					B.DESCPIRTION ����  ---����
		   FROM     TD_M_RESOURCETYPE A , TD_M_RESOURCE B
		   WHERE    A.RESUOURCETYPECODE = B.RESOURCETYPE
		   AND      (A.RESUOURCETYPECODE = P_VAR1 OR P_VAR1 IS NULL OR P_VAR1 = '')
		   ORDER BY B.UPDATETIME DESC;
    ELSIF p_funcCode = 'Query_ListResourceType' then		  --��ѯ��Դ����ϸ
		open p_cursor for
		  SELECT    B.RESOURCECODE,  ---��Դ����
					B.RESOURCENAME, ---��Դ����
					B.DESCPIRTION,  ---����
					B.RESOURCETYPE,    --��Դ���ͱ���
					B.ATTRIBUTE1,		--��������
					B.ATTRIBUTETYPE1,   --��������
					B.ATTRIBUTEISNULL1, --�Ƿ����
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
	ELSIF p_funcCode = 'Query_Department' then         --��ѯ���벿��
          open p_cursor for
          SELECT  DEPARTNAME,DEPARTNO
          FROM TD_M_INSIDEDEPART ORDER BY 2;
    ELSIF p_funcCode = 'Query_Staff' then         --��ѯ����Ա��
          open p_cursor for
          SELECT T.STAFFNAME,T.STAFFNO
          FROM TD_M_INSIDESTAFF T
          WHERE (P_VAR1 IS NULL  OR P_VAR1 = T.DEPARTNO);
	ELSIF p_funcCode = 'Query_GetResourceApply' then    ---��ѯ��Դ���õ�
		  open p_cursor for
		  SELECT A.GETORDERID ,                                       --���õ���
		 A.ORDERSTATE ||':'||F.CODEDESC STATE ,               --������״̬
		 C.RESUOURCETYPE,                                     --��Դ����
		 B.RESOURCENAME,                                      --��Դ����
		 A.RESOURCECODE  ,                                    --��Դ����
			 A.APPLYGETNUM  ,                                     --������������
			 A.AGREEGETNUM  ,                                     --ͬ����������
		   A.ORDERTIME        ,                                 --����ʱ��
			 D.STAFFNO ||':'|| D.STAFFNAME  STAFFNAME ,           --����Ա��
			 E.DEPARTNO ||':'|| E.DEPARTNAME  DEPARTNAME,         --���벿��
				 A.USEWAY  ,                                          --��;
				 A.REMARK           ,                                 --��ע
			 G.STAFFNO ||':' ||G.STAFFNAME GETSTAFFNAME,						--����Ա��
			 A.ALREADYGETNUM,																			--��������
			 A.LATELYGETDATE,																		  --�����������
			  B.ATTRIBUTE1  BATTRIBUTE1  ,
			 A.ATTRIBUTE1  AATTRIBUTE1,      --���ԣ����������Բ����ƴ����ʾ��GridView�У�
			 B.ATTRIBUTE2  BATTRIBUTE2,
			 A.ATTRIBUTE2  AATTRIBUTE2,
			 B.ATTRIBUTE3  BATTRIBUTE3,
			 A.ATTRIBUTE3  AATTRIBUTE3,
		   B.ATTRIBUTE4  BATTRIBUTE4,
			 A.ATTRIBUTE4  AATTRIBUTE4,
			 B.ATTRIBUTE5  BATTRIBUTE5,
		   A.ATTRIBUTE5  AATTRIBUTE5,
		   B.ATTRIBUTE6  BATTRIBUTE6,
			 A.ATTRIBUTE6  AATTRIBUTE6                                      --��Դ����6
		  FROM    TF_F_GETRESOURCEORDER  A ,       ---��Դ���õ���
					TD_M_RESOURCE      B ,           ---��Դ��
				TD_M_RESOURCETYPE  C ,           ---��Դ���ͱ�
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
	ELSIF p_funcCode = 'Query_GetAttribute' then    ---��ѯ��Դ����
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
			SELECT A.APPLYORDERID ���󵥺�,   --���󵥺�
			   A.APPLYORDERTYPE ||':'||D.CODEDESC ����״̬,  --����״̬
			   C.RESUOURCETYPE ��Դ����,   --��Դ����
			   B.RESOURCENAME ��Դ����,    --��Դ����
			   A.RESOURCECODE ��Դ����,    --��Դ����
			   A.RESOURCENUM ����,     --����
			   A.REQUIREDATE Ҫ�󵽻�����,     --Ҫ�󵽻�����
			   A.ORDERDEMAND ����Ҫ��,    --����Ҫ��
			   A.ORDERTIME �µ�ʱ��,      --�µ�ʱ��
			   A.ORDERSTAFFNO �µ�Ա��,   --�µ�Ա��
			   A.ALREADYORDERNUM �Ѷ�������,--�Ѷ�������
			   A.LATELYDATE �������ʱ��,     --�������ʱ��
			   A.ALREADYARRIVENUM �ѵ�������, --�ѵ�������
			   B.ATTRIBUTE1 ����1,
			   A.ATTRIBUTE1 ����ֵ1,      --���ԣ����������Բ����ƴ����ʾ��GridView�У�
			   B.ATTRIBUTE2 ����2,
			   A.ATTRIBUTE2 ����ֵ2,
			   B.ATTRIBUTE3 ����3,
			   A.ATTRIBUTE3 ����ֵ3,
			   B.ATTRIBUTE4 ����4,
			   A.ATTRIBUTE4 ����ֵ4,
			   B.ATTRIBUTE5 ����5,
			   A.ATTRIBUTE5 ����ֵ5,
			   B.ATTRIBUTE6 ����6,
			   A.ATTRIBUTE6 ����ֵ6,
			   A.REMARK  ��ע        --��ע
			FROM   TF_F_RESOURCEAPPLYORDER  A ,     ---��Դ���󵥱�
				   TD_M_RESOURCE      B ,           ---��Դ��
				   TD_M_RESOURCETYPE  C ,           ---��Դ���ͱ�
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
	ELSIF p_funcCode = 'Query_GridUnderOrder' then					--��Դ�µ���ȡGrid��Ϣ
			open p_cursor for
			SELECT A.APPLYORDERID ���󵥺�,                                     --���󵥺�
				   C.RESUOURCETYPE ��Դ����,                                     --��Դ����
				   B.RESOURCENAME ��Դ����,                                      --��Դ����
				   A.RESOURCECODE ��Դ����,                                      --��Դ����
				   B.ATTRIBUTE1 ����,
				   A.ATTRIBUTE1,      --���ԣ����������Բ����ƴ����ʾ��GridView�У�
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
				   A.RESOURCENUM �µ�����,                                       --�µ�����
				   A.REQUIREDATE Ҫ�󵽻�����,                                   --Ҫ�󵽻�����
				   A.LATELYDATE �����������,                                    --�����������
				   A.ORDERTIME �µ�ʱ��,                                         --�µ�ʱ��
				   D.STAFFNAME �µ�Ա��,                                  		 --�µ�Ա��
				   A.ALREADYORDERNUM �Ѷ�������,                                 --�Ѷ�������
				   A.ORDERDEMAND ����Ҫ��,                                       --����Ҫ��
				   A.REMARK ��ע                                           		 --��ע
			FROM   TF_F_RESOURCEAPPLYORDER  A ,     ---��Դ���󵥱�
				   TD_M_RESOURCE      B ,           ---��Դ��
				   TD_M_RESOURCETYPE  C ,           ---��Դ���ͱ�
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
	ELSIF p_funcCode = 'Query_ListUnderOrder' then				--��Դ�µ���ȡ��ϸ��Ϣ
			open p_cursor for
			SELECT A.APPLYORDERID ,                                     --���󵥺�
				   C.RESUOURCETYPE,                                     --��Դ����
				   B.RESOURCENAME,                                      --��Դ����
				   A.RESOURCENUM,                                       --�µ�����
				   A.REQUIREDATE,                                       --Ҫ�󵽻�����
				   A.LATELYDATE,                                        --�����������
				   A.ORDERTIME ,                                        --�µ�ʱ��
				   D.STAFFNAME  ,                                       --����Ա��
				   A.ALREADYORDERNUM ,                                  --�Ѷ�������
				   A.ORDERDEMAND ,                                      --����Ҫ��
				   A.REMARK ,                                           --��ע
				   B.ATTRIBUTE1,
				   A.ATTRIBUTE1,      --���ԣ����������Բ����ƴ����ʾ��GridView�У�
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
			FROM   TF_F_RESOURCEAPPLYORDER  A ,     ---��Դ���󵥱�
				   TD_M_RESOURCE      B ,           ---��Դ��
				   TD_M_RESOURCETYPE  C ,           ---��Դ���ͱ�
				   TD_M_INSIDESTAFF  D
			WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
			AND    B.RESOURCECODE = A.RESOURCECODE
			AND    D.STAFFNO = A.ORDERSTAFFNO
			AND    A.APPLYORDERID = P_VAR1 ;
	ELSIF p_funcCode = 'Query_ResourceUnderExam' THEN			--��Դ�µ����
		open p_cursor for
			SELECT A.RESOURCEORDERID ��������,                        --��������
				   A.APPLYORDERID  ���󵥺�,                          --���󵥺�
				   A.ORDERSTATE ||':'||F.CODEDESC ������״̬,         --������״̬
				   C.RESUOURCETYPE ��Դ����,                          --��Դ����
				   B.RESOURCENAME ��Դ����,                           --��Դ����
				   B.ATTRIBUTE1 ����,
				   A.ATTRIBUTE1,      --���ԣ����������Բ����ƴ����ʾ��GridView�У�
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
				   A.RESOURCENUM  ����,                               --����
				   A.REQUIREDATE  Ҫ�󵽻�����,                       --Ҫ�󵽻�����
				   A.LATELYDATE   �����������,                       --�����������
				   A.ALREADYARRIVENUM  �ѵ�������,                    --�ѵ�������
				   A.ORDERTIME �µ�ʱ��,                              --�µ�ʱ��
				   D.STAFFNAME  �µ�Ա��,                             --�µ�Ա��
				   A.EXAMTIME  ���ʱ��,                              --���ʱ��
				   E.STAFFNAME ���Ա��,                              --���Ա��
				   A.REMARK ��ע                                      --��ע
			  FROM   TF_F_RESOURCEORDER  A ,          ---��Դ��������
				   TD_M_RESOURCE      B ,           ---��Դ��
				   TD_M_RESOURCETYPE  C ,           ---��Դ���ͱ�
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
   ELSIF p_funcCode = 'Query_GetResourceApplyNoApproved' THEN			--��Դ��������
		open p_cursor for
		  SELECT A.GETORDERID ,                                       --���õ���
       C.RESUOURCETYPE,                                     --��Դ����
       B.RESOURCENAME,                                      --��Դ����
       A.RESOURCECODE  ,                                    --��Դ����
       A.APPLYGETNUM  ,                                     --������������
       A.ORDERTIME        ,                                 --����ʱ��
       D.STAFFNO ||':'|| D.STAFFNAME  STAFFNAME,            --����Ա��
       E.DEPARTNO ||':'|| E.DEPARTNAME  DEPARTNAME,         --���벿��
       A.USEWAY  ,                                          --��;
       A.REMARK  ,                                        --��ע
       B.ATTRIBUTE1  BATTRIBUTE1  ,
			 A.ATTRIBUTE1  AATTRIBUTE1,      --���ԣ����������Բ����ƴ����ʾ��GridView�У�
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
      FROM   TF_F_GETRESOURCEORDER  A ,       ---��Դ���õ���
       TD_M_RESOURCE      B ,           ---��Դ��
       TD_M_RESOURCETYPE  C ,           ---��Դ���ͱ�
       TD_M_INSIDESTAFF  D ,
       TD_M_INSIDEDEPART  E
      WHERE  C.RESUOURCETYPECODE = B.RESOURCETYPE
      AND    B.RESOURCECODE = A.RESOURCECODE
      AND    D.STAFFNO = A.ORDERSTAFFNO
      AND    E.DEPARTNO = D.DEPARTNO
			AND    A.USETAG = '1'
			AND    A.ORDERSTATE = '0'
			ORDER BY A.ORDERTIME DESC;
		ELSIF p_funcCode = 'Query_STOCK' THEN			--����ѯ
		open p_cursor for
		  SELECT A.RESUOURCETYPECODE||':'||RESUOURCETYPE ��Դ����, B.RESOURCECODE||':'||RESOURCENAME ��Դ����,NVL(INSNUM,0) �����,NVL(USENUM,0) ������
			FROM TD_M_RESOURCETYPE A
			INNER JOIN TD_M_RESOURCE B ON A.RESUOURCETYPECODE = B.RESOURCETYPE
			LEFT JOIN TL_R_RESOURCESUM C ON C.RESOURCECODE = B.RESOURCECODE
			WHERE (P_VAR1 is null or RESUOURCETYPECODE = P_VAR1)
			AND (P_VAR2 is null or B.RESOURCECODE = P_VAR2);
		ELSIF p_funcCode = 'Query_STOCK_DEPART' THEN			--����ѯ
		open p_cursor for
		  select tr.ASSIGNEDDEPARTID||':'||tm.DEPARTNAME ����,count(*) ����
		  from TL_R_RESOURCE tr,TD_M_INSIDEDEPART tm
		  where tr.ASSIGNEDDEPARTID = tm.DEPARTNO(+)
		  and tr.RESOURCECODE = P_VAR1
		  and tr.STOCKSATECODE = '01'
		  group by tr.ASSIGNEDDEPARTID,tm.DEPARTNAME
		  order by tr.ASSIGNEDDEPARTID;
	 ELSIF p_funcCode = 'Query_ResourceList' THEN			--��Դ�����ϸ
		open p_cursor for
		SELECT C.RESUOURCETYPECODE||':'||RESUOURCETYPE  ��Դ����,
				B.RESOURCECODE||':'||RESOURCENAME ��Դ����,
				B.ATTRIBUTE1 ��Դ����,
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
				A.ASSIGNEDDEPARTID||':'||D.DEPARTNAME ����,
				A.ASSIGNEDSTAFFNO||':'||E.STAFFNAME ӪҵԱ,
				A.USETIME ����ʱ��
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
     ELSIF p_funcCode = 'Query_GetResourceDistribution' THEN			--��Դ�ɷ���ѯ
		open p_cursor for
		  SELECT A.GETORDERID ,                                       --���õ���
       A.ORDERSTATE ||':'||F.CODEDESC STATE ,               --���õ�״̬
       C.RESUOURCETYPE,                                     --��Դ����
       B.RESOURCENAME,                                      --��Դ����
       A.RESOURCECODE  ,                                    --��Դ����
       A.APPLYGETNUM  ,                                     --������������
       A.AGREEGETNUM  ,                                     --ͬ����������
       A.ORDERTIME        ,                                 --����ʱ��
       D.STAFFNO ||':'|| D.STAFFNAME  STAFFNAME,            --����Ա��
       E.DEPARTNO ||':'|| E.DEPARTNAME  DEPARTNAME,         --���ղ���
       A.USEWAY  ,                                          --��;
       A.REMARK  ,                                          --��ע
       B.ATTRIBUTE1  BATTRIBUTE1  ,
			 A.ATTRIBUTE1  AATTRIBUTE1,      --���ԣ����������Բ����ƴ����ʾ��GridView�У�
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
			FROM    TF_F_GETRESOURCEORDER  A ,       ---��Դ���õ���
					TD_M_RESOURCE      B ,           ---��Դ��
				TD_M_RESOURCETYPE  C ,           ---��Դ���ͱ�
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
    ELSIF p_funcCode = 'Query_GetResource' THEN			             --��Դ���ò�ѯ
		open p_cursor for
		  SELECT A.GETORDERID ,                                 --���õ���
       A.ORDERSTATE ||':'||F.CODEDESC STATE ,               --���õ�״̬
       C.RESUOURCETYPE,                                     --��Դ����
       B.RESOURCENAME,                                      --��Դ����
       A.RESOURCECODE  ,                                    --��Դ����
       A.APPLYGETNUM  ,                                     --������������
       A.AGREEGETNUM  ,                                     --ͬ����������
       A.ALREADYGETNUM ,                                    --����������
       A.LATELYGETDATE  ,                                   --�������ʱ��
       A.GETSTAFFNO ,                                       --����Ա��
       A.ORDERTIME        ,                                 --����ʱ��
       D.STAFFNO ||':'|| D.STAFFNAME  STAFFNAME,            --����Ա��
       E.DEPARTNO ||':'|| E.DEPARTNAME  DEPARTNAME,         --���벿��
       A.USEWAY  ,                                          --��;
       A.REMARK  ,                                           --��ע
       A.APPLYGETNUM,																				--������������
       A.AGREEGETNUM,																				--ͬ����������
       A.ALREADYGETNUM, 																			--����������
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
			FROM   TF_F_GETRESOURCEORDER  A ,       ---��Դ���õ���
       TD_M_RESOURCE      B ,           ---��Դ��
       TD_M_RESOURCETYPE  C ,           ---��Դ���ͱ�
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
  ELSIF p_funcCode = 'Query_ResourceStockReturn' THEN			             --��Դ�˿��ѯ
		open p_cursor for
		  SELECT A.GETORDERID ,                                 --���õ���
       A.ORDERSTATE ||':'||F.CODEDESC STATE ,               --���õ�״̬
       C.RESUOURCETYPE,                                     --��Դ����
       B.RESOURCENAME,                                      --��Դ����
       A.RESOURCECODE  ,                                    --��Դ����
       A.APPLYGETNUM  ,                                     --������������
       A.AGREEGETNUM  ,                                     --ͬ����������
       A.ALREADYGETNUM ,                                    --����������
       A.LATELYGETDATE  ,                                   --�������ʱ��
       A.GETSTAFFNO ,                                       --����Ա��
       A.ORDERTIME        ,                                 --����ʱ��
       D.STAFFNO ||':'|| D.STAFFNAME  STAFFNAME,            --����Ա��
       E.DEPARTNO ||':'|| E.DEPARTNAME  DEPARTNAME,         --���벿��
       A.USEWAY  ,                                          --��;
       A.REMARK  ,                                           --��ע
       A.APPLYGETNUM,																				--������������
       A.AGREEGETNUM,																				--ͬ����������
       A.ALREADYGETNUM, 																			--����������
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
			FROM   TF_F_GETRESOURCEORDER  A ,       ---��Դ���õ���
       TD_M_RESOURCE      B ,           ---��Դ��
       TD_M_RESOURCETYPE  C ,           ---��Դ���ͱ�
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
  ELSIF p_funcCode = 'Query_GetResourceChose' THEN			             --��Դ���ò�ѯ
		open p_cursor for
		  SELECT A.GETORDERID ,                                 --���õ���
       A.ORDERSTATE ||':'||F.CODEDESC STATE ,               --���õ�״̬
       C.RESUOURCETYPE,                                     --��Դ����
       B.RESOURCENAME,                                      --��Դ����
       A.RESOURCECODE  ,                                    --��Դ����
       A.APPLYGETNUM  ,                                     --������������
       A.AGREEGETNUM  ,                                     --ͬ����������
       A.ALREADYGETNUM ,                                    --����������
       A.LATELYGETDATE  ,                                   --�������ʱ��
       A.GETSTAFFNO ,                                       --����Ա��
       A.ORDERTIME        ,                                 --����ʱ��
       D.STAFFNO ||':'|| D.STAFFNAME  STAFFNAME,            --����Ա��
       E.DEPARTNO ||':'|| E.DEPARTNAME  DEPARTNAME,         --���벿��
       A.USEWAY  ,                                          --��;
       A.REMARK  ,                                           --��ע
       A.APPLYGETNUM,																				--������������
       A.AGREEGETNUM,																				--ͬ����������
       A.ALREADYGETNUM, 																			--����������
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
			FROM   TF_F_GETRESOURCEORDER  A ,       ---��Դ���õ���
       TD_M_RESOURCE      B ,           ---��Դ��
       TD_M_RESOURCETYPE  C ,           ---��Դ���ͱ�
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
  ELSIF p_funcCode = 'Query_GetMaintainApply' THEN			             --��Դά�������ѯ
		open p_cursor for
		 SELECT A.MAINTAINORDERID ,                             --ά������
       A.ORDERSTATE ||':'||F.CODEDESC STATE ,               --ά����״̬
       C.RESUOURCETYPE,                                     --��Դ����
       B.RESOURCENAME,                                      --��Դ����
       A.MAINTAINREASON  ,                                  --����ԭ��
       E.DEPARTNO ||':'|| E.DEPARTNAME DEPARTNAME ,         --����ά������
       H.STAFFNO ||':'|| H.STAFFNAME  MAINTAINSTAFF,        --ά��Ա��
       A.MAINTAINREQUEST,                                   --ά��Ҫ��
       TO_CHAR(A.TIMELIMIT,'YYYYMMDD') TIMELIMIT,           --ά������
       A.FEEDBACK,                                          --������Ϣ
       A.ORDERTIME,                                         --�µ�ʱ��
       D.STAFFNO ||':'|| D.STAFFNAME STAFFNAME,             --�µ�Ա��
       G.DEPARTNO ||':'||G.DEPARTNAME ORDERDEPART,          --�µ�����
       A.REMARK                                             --��ע
       FROM   TF_F_RESOURCEMAINTAINORDER  A ,       ---��Դά����
       TD_M_RESOURCE      B ,           ---��Դ��
       TD_M_RESOURCETYPE  C ,           ---��Դ���ͱ�
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
   ELSIF p_funcCode = 'Query_ResourceMaintain' THEN                   --��Դά����ѯ
    open p_cursor for
    SELECT MAINTAINORDERID,DECODE(A.ORDERSTATE,'0','�����','1','���ͨ��','2','�������') ORDERSTATE,C.RESUOURCETYPECODE ||':'|| C.RESUOURCETYPE RESUOURCETYPE,
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
	ELSIF p_funcCode = 'QueryForResourceOrder' THEN			--��������ѯ
		open p_cursor for
		SELECT A.RESOURCEORDERID ��������,                                  --��������
			   A.APPLYORDERID ���󵥺�,                                     --���󵥺�
			   A.ORDERSTATE ||':'||F.CODEDESC ������״̬,               	--������״̬
			   C.RESUOURCETYPE ��Դ����,                                    --��Դ����
			   B.RESOURCENAME ��Դ����,                                     --��Դ����
			   B.ATTRIBUTE1 ����,
			   A.ATTRIBUTE1,      --���ԣ����������Բ����ƴ����ʾ��GridView�У�
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
			   A.RESOURCENUM  ����,                                     	 --����
			   A.REQUIREDATE  Ҫ�󵽻�����,                                  --Ҫ�󵽻�����
			   A.LATELYDATE   �����������,                                  --�����������
			   A.ALREADYARRIVENUM  �ѵ�������,                               --�ѵ�������
			   A.ORDERTIME  �µ�ʱ��,                                 		 --�µ�ʱ��
			   D.STAFFNAME  �µ�Ա��,                                 		 --�µ�Ա��
			   A.EXAMTIME   ���ʱ��,                                 		 --���ʱ��
			   E.STAFFNAME ���Ա��,                                         --���Ա��
			   A.REMARK ��ע                                 				 --��ע
		FROM   TF_F_RESOURCEORDER  A ,          ---��Դ��������
			   TD_M_RESOURCE      B ,           ---��Դ��
			   TD_M_RESOURCETYPE  C ,           ---��Դ���ͱ�
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
    ELSIF p_funcCode = 'Query_ContractList' THEN --��ѯ��ͬ�б�
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
	 ELSIF p_funcCode = 'Query_DocumentList' THEN   --��ѯ�ĵ��б�
		open p_cursor for
    SELECT CONTRACTCODE,
		CONTRACTNAME,
		CONTRACTID,
		SIGNINGCOMPANY,
		SIGNINGDATE,
		DECODE(DOCUMENTTYPE,'1','˵������','2','����Э��','3','���������ļ�','4','��˾�ĵ�','5','�����ĵ�') DOCUMENTTYPE
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
ELSIF p_funcCode = 'Query_MaintainStaff' THEN --��ѯά��Ա��
		open p_cursor for
    SELECT DISTINCT STAFFNAME FROM TF_F_STAFFSIGNINSHEET T ;
 ELSIF p_funcCode = 'Query_StaffSignIn' THEN---��ѯԱ��ǩ����¼
    open p_cursor for
    SELECT  T.CARDNO,T.SIGNINSHEETID,																								
        T.STAFFNAME,																								
        T.SIGNINTIME,																								
        decode( T.STATE,'0','δƥ��','1','��ƥ��',T.STATE) STATE,																								
        T.OPERATEDEPT	||':'||D.DEPARTNAME OPERATEDEPT																							
    FROM    TF_F_STAFFSIGNINSHEET T ,td_m_insidedepart D  																								
    WHERE   T.OPERATEDEPT= D.departno(+)  																								
    AND    (p_var1 IS NULL OR p_var1 = '' OR to_char(t.SIGNINTIME,'yyyymmdd')>= p_var1)--ǩ��ʱ��																								
    AND    (p_var2 IS NULL OR p_var2 = '' OR to_char(t.SIGNINTIME,'yyyymmdd')<= p_var2)																								
    AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 =t.STATE)---ƥ�����																								
    AND    (p_var4 IS NULL OR p_var4 = '' OR t.STAFFNAME =p_var4)
    order by T.SIGNINTIME;
  ELSIF p_funcCode = 'Query_StaffMaintainInput' THEN--��ѯ¼��Ĺ���
    open p_cursor for	
    SELECT  T.SIGNINMAINTAINID,--ά������																						
        T.MAINTAINDEPT||':'|| D.DEPARTNAME MAINTAINDEPT,--ά������																						
        T.RESUOURCETYPECODE||':'||B.RESUOURCETYPE RESUOURCETYPE,  ---��Դ����																						
        T.RESOURCECODE||':'||C.RESOURCENAME  RESOURCENAME,        ---��Դ����																						
        T.USETIME||'Сʱ' USETIME,----ά��ʱ��																						
        T.UPDATETIME,--ά��ʱ��																						
        T.STAFFNAME ,---ά��Ա��
        decode( T.RELATEDSTATE,'0','δƥ��','1','��ƥ��',T.RELATEDSTATE) RELATEDSTATE ,--�Ƿ�ƥ��
        T.STATE,																						
        T.EXPLANATION  ---ά��˵��																						
    FROM    TF_F_STAFFMAINTAIN T ,TD_M_RESOURCETYPE B,TD_M_RESOURCE C,TD_M_INSIDEDEPART D 																						
    WHERE   T.MAINTAINDEPT= D.DEPARTNO  																						
    AND     T.RESUOURCETYPECODE=B.RESUOURCETYPECODE																						
    AND     T.RESOURCECODE=C.RESOURCECODE																																												
    AND    (p_var1 IS NULL OR p_var1 = '' OR to_char(t.UPDATETIME,'yyyymmdd')>= p_var1)																						
    AND    (p_var2 IS NULL OR p_var2 = '' OR to_char(t.UPDATETIME,'yyyymmdd')<= p_var2)																						
    AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 =t.Maintaindept)  ---����
    AND    (p_var4 IS NULL OR p_var4 = '' OR p_var4 =t.RESUOURCETYPECODE)	---��Դ����																						
		AND    (p_var5 IS NULL OR p_var5 = '' OR p_var5 =t.RESOURCECODE)	---��Դ����	
    AND    (p_var6 IS NULL OR p_var6 = '' OR p_var6 =t.RELATEDSTATE)	---�Ƿ�ƥ��
    ORDER BY T.UPDATETIME;				
  ELSIF p_funcCode = 'Query_StaffMaintainQuery' THEN--��ѯ���й���	
    open p_cursor for		
    SELECT  T.SIGNINMAINTAINID,--ά������																													
        T.MAINTAINDEPT||':'|| D.DEPARTNAME MAINTAINDEPT,--ά������																													
        T.RESUOURCETYPECODE||':'||B.RESUOURCETYPE RESUOURCETYPE,  ---��Դ����																													
        T.RESOURCECODE||':'||C.RESOURCENAME  RESOURCENAME,        ---��Դ����																													
        T.USETIME,----ά��ʱ��																													
        T.SIGNINTIME,--ά��ʱ��																													
        T.STAFFNAME ,---ά��Ա��																													
        T.EXPLANATION,  ---ά��˵��	
        decode(P.ISFINISHED,'0','δ���','1','�����',P.ISFINISHED) ISFINISHED, --�Ƿ����
        P.CONFIRMATION, --ȷ��˵��
        decode(P.SATISFATION,'1','һ�Ǽ�','2','���Ǽ�','3','���Ǽ�','4','���Ǽ�','5','���Ǽ�',P.SATISFATION) SATISFATION --�����																											
    FROM    TF_F_STAFFMAINTAIN T ,TF_F_CONFIRMSTAFFMAINTAIN P,TD_M_RESOURCETYPE B,TD_M_RESOURCE C,TD_M_INSIDEDEPART D 																													
    WHERE   T.MAINTAINDEPT= D.DEPARTNO  																													
    AND     T.RESUOURCETYPECODE=B.RESUOURCETYPECODE																													
    AND     T.SIGNINMAINTAINID=P.SIGNINMAINTAINID(+)																													
    AND     T.RESOURCECODE=C.RESOURCECODE		
    AND     T.RELATEDSTATE='1'																											
    AND    (p_var1 IS NULL OR p_var1 = '' OR to_char(t.UPDATETIME,'yyyymmdd')>= p_var1)																													
    AND    (p_var2 IS NULL OR p_var2 = '' OR to_char(t.UPDATETIME,'yyyymmdd')<= p_var2)																													
    AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 =t.MAINTAINDEPT)  ---ά������
    AND    (p_var4 IS NULL OR p_var4 = '' OR p_var4 =t.STAFFNAME)  ---ά��Ա��																												
    AND    (p_var5 IS NULL OR p_var5 = '' OR p_var5 =t.STATE)  ---ά����״̬
    ORDER BY T.SIGNINTIME	;																												
	ELSIF p_funcCode = 'Query_StaffMaintain' THEN--��ѯ����
    open p_cursor for	
    SELECT  T.SIGNINMAINTAINID,--ά������																						
        T.MAINTAINDEPT||':'|| D.DEPARTNAME MAINTAINDEPT,--ά������																						
        T.RESUOURCETYPECODE||':'||B.RESUOURCETYPE RESUOURCETYPE,  ---��Դ����																						
        T.RESOURCECODE||':'||C.RESOURCENAME  RESOURCENAME,        ---��Դ����																						
        T.USETIME||'Сʱ' USETIME,----ά��ʱ��																						
        T.SIGNINTIME,--ά��ʱ��																						
        T.STAFFNAME ,---ά��Ա��
        decode( P.ISFINISHED,'0','0:δ���','1','1:�����',P.ISFINISHED) ISFINISHED ,--������
        decode( T.STATE,'0','0:δȷ��','1','1:��ȷ��',T.STATE) STATE ,--�Ƿ�ȷ��																						
        T.EXPLANATION , ---ά��˵��	
        decode(P.SATISFATION,'1','1:һ�Ǽ�','2','2:���Ǽ�','3','3:���Ǽ�','4','4:���Ǽ�','5','5:���Ǽ�',P.SATISFATION) SATISFATION, --�����
        P.CONFIRMATION,   ---ȷ��˵��
        P.CONFIRMID  --ȷ�ϵ���																					
    FROM    TF_F_STAFFMAINTAIN T ,TF_F_CONFIRMSTAFFMAINTAIN P,TD_M_RESOURCETYPE B,TD_M_RESOURCE C,TD_M_INSIDEDEPART D 																						
    WHERE   T.MAINTAINDEPT= D.DEPARTNO 
    AND     T.SIGNINMAINTAINID=P.SIGNINMAINTAINID(+) 																						
    AND     T.RESUOURCETYPECODE=B.RESUOURCETYPECODE																						
    AND     T.RESOURCECODE=C.RESOURCECODE																																												
    AND    (p_var1 IS NULL OR p_var1 = '' OR to_char(t.UPDATETIME,'yyyymmdd')>= p_var1)																						
    AND    (p_var2 IS NULL OR p_var2 = '' OR to_char(t.UPDATETIME,'yyyymmdd')<= p_var2)																						
    AND    (p_var3 IS NULL OR p_var3 = '' OR p_var3 =t.MAINTAINDEPT)  ---����
    AND    (p_var4 IS NULL OR p_var4 = '' OR p_var4 =p.ISFINISHED)	---������	
    AND    (p_var5 IS NULL OR p_var5 = '' OR p_var5 =T.STATE);
  end if;
end;


/
show errors