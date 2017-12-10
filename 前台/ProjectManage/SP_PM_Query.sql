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
	if p_funcCode = 'Query_Project' then --查询项目
    open p_cursor for
    SELECT  PROJECTCODE 项目编号,PROJECTNAME 项目名称,STARTDATE 项目开始日期,PROJECTDESC 项目概况,
    P.UPDATESTAFFNO||':'||S.STAFFNAME 更新员工 ,P.UPDATETIME 更新时间
    FROM TD_M_PROJECT P 
    LEFT JOIN TD_M_INSIDESTAFF S ON P.UPDATESTAFFNO = S.STAFFNO
		WHERE   (P_VAR1 IS NULL OR P_VAR1 = '' OR TO_DATE(P_VAR1||'000000','YYYYMMDDHH24MISS') <= P.STARTDATE)																										
			AND   (P_VAR2 IS NULL OR P_VAR2 = '' OR TO_DATE(P_VAR2||'235959','YYYYMMDDHH24MISS') >= P.STARTDATE)	
			AND   (P_VAR3 IS NULL OR P_VAR3 = PROJECTNAME);
 elsif p_funcCode = 'Query_ProjectJob' then --查询计划项目
 		open p_cursor for
 			SELECT B.JOBCODE 计划编号,                     												
			       B.JOBDESC 计划说明,                     													
			       B.EXPECTEDDATE 预计完成日期,                  	                        
			       B.JOBSTAFF|| ':' || D.STAFFNAME 计划执行人,                           
			       B.COMPLETEDESC 实际情况描述,                                           
			       B.ACTUALDATE 实际完成日期 ,                                       
			       B.UPDATESTAFFNO || ':' || C.STAFFNAME 更新员工,                           
			       B.UPDATETIME 更新员工                                              
			FROM TF_B_PROJECTJOB B                            
			LEFT JOIN TD_M_INSIDESTAFF C  ON   B.UPDATESTAFFNO = C.STAFFNO    
			LEFT JOIN TD_M_INSIDESTAFF D  ON   B.JOBSTAFF = D.STAFFNO                         
			WHERE  P_VAR1 = B.PROJECTCODE;                            
	elsif p_funcCode = 'Query_ProjectList' then --查询计划项目
 		open p_cursor for
 			SELECT PROJECTNAME 项目名称,PROJECTCODE 项目编号
		    FROM TD_M_PROJECT P ; 
  elsif p_funcCode = 'Query_ProjectJobList' then --查询待完成项目计划
 		open p_cursor for
 			SELECT PROJECTNAME 项目名称,STARTDATE 项目开始日期,PROJECTDESC 项目概况,
 			JOBDESC 计划说明,EXPECTEDDATE 预计完成日期,P.PROJECTCODE,JOBCODE
		    FROM TD_M_PROJECT P
		    INNER JOIN TF_B_PROJECTJOB J ON P.PROJECTCODE = J.PROJECTCODE 
		    WHERE J.JOBSTAFF = P_VAR1
		    AND ACTUALDATE IS NULL;  

end if;
end;
/
show error;

