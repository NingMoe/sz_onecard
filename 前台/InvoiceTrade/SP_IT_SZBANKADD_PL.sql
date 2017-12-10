/******************************************************/
-- Author  : wdx
-- Created : 2012-2-14 上午 09:34:44
-- Purpose : 苏信开户行配置
/******************************************************/
create or replace procedure SP_IT_SZBANKADD
(
    p_bankName          varchar2, -- 开户行名称
    p_bankCode         	varchar2 , -- 开户行帐号
	p_payeeName			varchar2,--收款方名称
	p_isDefault			char,
	p_usetag			char,
    p_currOper        	char,
    p_currDept        	char,
    p_retCode     		out char,
    p_retMsg      		out varchar2
)
as
    v_int				int;
    v_today           date := sysdate;
    v_seq             char(16);
begin
    --判断开户行名称是否存在
	select count(*) into v_int
	from td_m_szbank
	where bankname=p_bankname;
	if(v_int>0) then
		p_retCode:='S00IT00001';
		p_retMsg:='开户行名称已存在';
		return;
	end if;
	
	--插入
	begin
		insert into td_m_szbank(
			bankname,bankcode,payeeName,isdefault,
			usetag,updatedepartno,updatestaffno,updatetime
			)
		values(
			p_bankName,p_bankCode,p_payeeName,p_isDefault,
			p_usetag,p_currDept,p_currOper,v_today);
	exception when others then
        p_retCode := 'S00IT00002';
        p_retMsg  := '插入苏信开户信息配置表失败。'||SQLERRM;
        rollback; return;	
	end;
	
	--记录台帐	
	begin
		insert into tf_b_szbank(
			bankname,bankcode,payeeName,isdefault,
			usetag,updatedepartno,updatestaffno,updatetime,tradetypecode
			)
		values(
			p_bankName,p_bankCode,p_payeeName,p_isDefault,
			p_usetag,p_currDept,p_currOper,v_today,'01');
	exception when others then
        p_retCode := 'S00IT00003';
        p_retMsg  := '插入苏信开户信息配置台帐表失败。'||SQLERRM;
        rollback; return;	
	end;
	p_retCode:='0000000000';
	p_retMsg:='';
	commit;
end;

/
show errors

