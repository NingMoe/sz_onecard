create or replace procedure SP_PM_Query
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
	if p_funcCode = 'Query_Project' then --��ѯ��Ŀ
    open p_cursor for
    SELECT  PROJECTCODE ��Ŀ���,PROJECTNAME ��Ŀ����,STARTDATE ��Ŀ��ʼ����,PROJECTDESC ��Ŀ�ſ�,
    P.UPDATESTAFFNO||':'||S.STAFFNAME ����Ա�� ,P.UPDATETIME ����ʱ��
    FROM TD_M_PROJECT P 
    LEFT JOIN TD_M_INSIDESTAFF S ON P.UPDATESTAFFNO = S.STAFFNO
		WHERE   (P_VAR1 IS NULL OR P_VAR1 = '' OR TO_DATE(P_VAR1||'000000','YYYYMMDDHH24MISS') <= P.STARTDATE)																										
			AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'235959','YYYYMMDDHH24MISS') >= P.STARTDATE)	
			AND   (P_VAR3 IS NULL OR P_VAR3 = PROJECTNAME);
 elsif p_funcCode = 'Query_ProjectJob' then --��ѯ�ƻ���Ŀ
 		open p_cursor for
 			SELECT B.JOBCODE �ƻ����,                     												
			       B.JOBDESC �ƻ�˵��,                     													
			       B.EXPECTEDDATE Ԥ���������,                  	                        
			       B.JOBSTAFF|| ':' || D.STAFFNAME �ƻ�ִ����,                           
			       B.COMPLETEDESC ʵ���������,                                           
			       B.ACTUALDATE ʵ��������� ,                                       
			       B.UPDATESTAFFNO || ':' || C.STAFFNAME ����Ա��,                           
			       B.UPDATETIME ����Ա��                                              
			FROM TF_B_PROJECTJOB B                            
			LEFT JOIN TD_M_INSIDESTAFF C  ON   B.UPDATESTAFFNO = C.STAFFNO    
			LEFT JOIN TD_M_INSIDESTAFF D  ON   B.JOBSTAFF = D.STAFFNO                         
			WHERE  P_VAR1 = B.PROJECTCODE;                            
	elsif p_funcCode = 'Query_ProjectList' then --��ѯ�ƻ���Ŀ
 		open p_cursor for
 			SELECT PROJECTNAME ��Ŀ����,PROJECTCODE ��Ŀ���
		    FROM TD_M_PROJECT P ; 
  elsif p_funcCode = 'Query_ProjectJobList' then --��ѯ�������Ŀ�ƻ�
 		open p_cursor for
 			SELECT PROJECTNAME ��Ŀ����,STARTDATE ��Ŀ��ʼ����,PROJECTDESC ��Ŀ�ſ�,
 			JOBDESC �ƻ�˵��,EXPECTEDDATE Ԥ���������,P.PROJECTCODE,JOBCODE
		    FROM TD_M_PROJECT P
		    INNER JOIN TF_B_PROJECTJOB J ON P.PROJECTCODE = J.PROJECTCODE 
		    WHERE J.JOBSTAFF = P_VAR1
		    AND ACTUALDATE IS NULL;  

end if;
end;
/
show error;

