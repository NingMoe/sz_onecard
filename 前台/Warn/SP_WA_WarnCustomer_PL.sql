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
	--����
	if p_funcCode in ('Add') then
		begin
			select COUNT(CUSTNAME) INTO v_int 
			FROM TF_F_WARNCUSTOMER 
			WHERE PAPERTYPECODE = p_paperTypeCode AND PAPERNO = p_paperNo;
			
			EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
		end;
		
		if (v_int > 0) then
			p_retCode := 'S094780149'; p_retMsg  := '�ֲ����Ӻ����������Ѵ��ڸ�֤������ļ�¼';
			rollback; return;
		end if;
		
		begin
			insert into TF_F_WARNCUSTOMER(PAPERTYPECODE	,PAPERNO	,CUSTNAME	,CUSTSEX	,CUSTBIRTH,
					UPDATEDEPARTNO	,UPDATESTAFFNO	,UPDATETIME)
				values(p_paperTypeCode	,p_paperNo		,p_custName	,p_custSex	,p_custBir	,
					p_currDept	,p_currOper	,sysdate);
			if SQL%ROWCOUNT != 1 then
				p_retCode := 'S094780150'; p_retMsg  := '�����ֲ����Ӻ�������ʧ��';
				rollback;return;			end if;
		end;
	end if;

	--�޸�
	if p_funcCode in ('Mod') then
		begin
			update TF_F_WARNCUSTOMER set CUSTNAME = p_custName,
										CUSTSEX	= p_custSex,
										CUSTBIRTH = p_custBir
			where PAPERTYPECODE = p_paperTypeCode
			 and PAPERNO = p_paperNo;
			if SQL%ROWCOUNT != 1 then
				p_retCode := 'S094780151'; p_retMsg  := '�޸Ŀֲ����Ӻ�������ʧ��';
				rollback;return;
			end if;
		end;
	end if;
	
	--ɾ��
	if p_funcCode in ('Del') then
		begin
			delete TF_F_WARNCUSTOMER where PAPERTYPECODE = p_paperTypeCode and PAPERNO = p_paperNo;
			if SQL%ROWCOUNT != 1 then
				p_retCode := 'S094780152'; p_retMsg  := 'ɾ���ֲ����Ӻ�������ʧ��';
				rollback;return;
			end if;
		end;
	end if;

    p_retCode := '0000000000'; p_retMsg  := '';
    commit; return;
end;

/

show errors

