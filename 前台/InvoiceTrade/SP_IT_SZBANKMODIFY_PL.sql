/******************************************************/
-- Author  : wdx
-- Created : 2012-2-14 上午 09:34:44
-- Purpose : 苏信开户行配置
/******************************************************/
create or replace procedure SP_IT_SZBANKMODIFY
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
	v_ex          exception;
begin	
	--修改
	begin
		update td_m_szbank 
		set bankCode=p_bankCode,
		payeeName=p_payeeName,
		isdefault=p_isdefault,
		usetag=p_usetag
		where bankname=p_bankName;
		IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF; 
	exception when others then
        p_retCode := 'S00IT00006';
        p_retMsg  := '修改苏信开户信息配置表失败。'||SQLERRM;
        rollback; return;	
	end;
	
	--记录台帐	
	begin
		insert into tf_b_szbank(
			bankname,bankcode,payeeName,isdefault,
			usetag,updatedepartno,updatestaffno,updatetime,
			tradetypecode
			)
		values( 
			p_bankName,p_bankCode,p_payeeName,p_isdefault,
			p_usetag,p_currDept,p_currOper,v_today,
			'03'
			);
	exception when others then
        p_retCode := 'S00IT00007';
        p_retMsg  := '插入苏信开户信息配置台帐表失败。'||SQLERRM;
        rollback; return;	
	end;
	p_retCode:='0000000000';
	p_retMsg:='';
	commit;
end;

/
show errors

