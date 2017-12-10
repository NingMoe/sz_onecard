create or replace procedure SP_SMK_Query
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
if p_funcCode = 'TD_M_RMCODING' then
	open p_cursor for
	SELECT B.CODEDESC,B.CODEVALUE,A.MANUCODE 
	FROM TD_M_MANU A,TD_M_RMCODING B 
	WHERE A.MANUNAME=B.CODEDESC
	AND B.TABLENAME='TD_M_MANU' AND COLNAME='MANUNAME';
end if;	
end;

/
show errors