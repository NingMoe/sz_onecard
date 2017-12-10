create or replace procedure SP_WA_SaleCardForWarn
(
    p_paperTypeCode char,
    p_paperNo      varchar2,
	p_custName	   varchar2,
	p_operName	   varchar2,
	p_deptName	   varchar2,

    p_currOper     char    ,
    p_currDept     char    ,
    p_retCode  out char    ,
    p_retMsg   out varchar2
)
as
    v_int          int;
	v_ex            exception;
begin

	begin
		select COUNT(CUSTNAME) INTO v_int 
		FROM TF_F_WARNCUSTOMER 
		WHERE (PAPERTYPECODE = p_paperTypeCode AND PAPERNO = p_paperNo) or (CUSTNAME = p_custName);
		
		EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
	end;
	
	if (v_int > 0) then
		begin
			SP_PR_SENDMSG_WARN('','���ֲֿ����Ӻ�������Ա����',
				'���ֲֿ����Ӻ�������Ա������Ӫҵ����Ϊ��'||p_deptName||';ӪҵԱΪ��'||p_operName||';ʱ��Ϊ��'||to_char(sysdate,'YYYY/MM/DD HH24:MI:SS')||'��',
				'1','','','','030005','1',p_currOper,p_currDept,p_retCode,p_retMsg);
		IF  p_retCode != '0000000000' THEN RAISE v_ex; END IF;
		exception 
		when others then
			p_retCode := 'A094770550';p_retMsg := '���ֲֿ����Ӻ�������Ա����'|| SQLERRM;
			rollback;return;
		end;
	end if;
		

    p_retCode := '0000000000'; p_retMsg  := '';
    commit; return;
end;

/

show errors

