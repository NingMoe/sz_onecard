create or replace procedure SP_WA_WarnCustomer
(
    p_funcCode     varchar,
    p_paperTypeCode char,
    p_paperNo      varchar2,
    p_custName     varchar2,
    p_custSex      char    ,
    p_custBir      char	   ,

    p_currOper     char    ,
    p_currDept     char    ,
    p_retCode  out char    ,
    p_retMsg   out varchar2
)
as
    v_int          int;
begin
	--新增
	if p_funcCode in ('Add') then
		begin
			select COUNT(CUSTNAME) INTO v_int 
			FROM TF_F_WARNCUSTOMER 
			WHERE PAPERTYPECODE = p_paperTypeCode AND PAPERNO = p_paperNo;
			
			EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
		end;
		
		if (v_int > 0) then
			p_retCode := 'S094780149'; p_retMsg  := '恐怖分子黑名单表中已存在该证件号码的记录';
			rollback; return;
		end if;
		
		begin
			insert into TF_F_WARNCUSTOMER(PAPERTYPECODE	,PAPERNO	,CUSTNAME	,CUSTSEX	,CUSTBIRTH,
					UPDATEDEPARTNO	,UPDATESTAFFNO	,UPDATETIME)
				values(p_paperTypeCode	,p_paperNo		,p_custName	,p_custSex	,p_custBir	,
					p_currDept	,p_currOper	,sysdate);
			if SQL%ROWCOUNT != 1 then
				p_retCode := 'S094780150'; p_retMsg  := '新增恐怖分子黑名单表失败';
				rollback;return;			end if;
		end;
	end if;

	--修改
	if p_funcCode in ('Mod') then
		begin
			update TF_F_WARNCUSTOMER set CUSTNAME = p_custName,
										CUSTSEX	= p_custSex,
										CUSTBIRTH = p_custBir
			where PAPERTYPECODE = p_paperTypeCode
			 and PAPERNO = p_paperNo;
			if SQL%ROWCOUNT != 1 then
				p_retCode := 'S094780151'; p_retMsg  := '修改恐怖分子黑名单表失败';
				rollback;return;
			end if;
		end;
	end if;
	
	--删除
	if p_funcCode in ('Del') then
		begin
			delete TF_F_WARNCUSTOMER where PAPERTYPECODE = p_paperTypeCode and PAPERNO = p_paperNo;
			if SQL%ROWCOUNT != 1 then
				p_retCode := 'S094780152'; p_retMsg  := '删除恐怖分子黑名单表失败';
				rollback;return;
			end if;
		end;
	end if;

    p_retCode := '0000000000'; p_retMsg  := '';
    commit; return;
end;

/

show errors

