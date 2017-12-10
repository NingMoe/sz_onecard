/******************************************************/
-- Author  : wdx
-- Created : 2012-2-14 ���� 09:34:44
-- Purpose : ���ſ���������
/******************************************************/
create or replace procedure SP_IT_SZBANKDELETE
(
    p_bankName          varchar2, -- ����������
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
	--ɾ��
	begin
		delete from td_m_szbank 
		where bankname=p_bankName;
		IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF; 
	exception when others then
        p_retCode := 'S00IT00004';
        p_retMsg  := 'ɾ�����ſ�����Ϣ���ñ�ʧ�ܡ�'||SQLERRM;
        rollback; return;	
	end;
	
	--��¼̨��	
	begin
		insert into tf_b_szbank(
			bankname,bankcode,payeeName,isdefault,
			usetag,updatedepartno,updatestaffno,updatetime,
			tradetypecode
			)
		select 
			p_bankName,bankCode,payeeName,isDefault,
			usetag,p_currDept,p_currOper,v_today,
			'02'
		from td_m_szbank 
		where bankname=p_bankName;
	exception when others then
        p_retCode := 'S00IT00005';
        p_retMsg  := '�������ſ�����Ϣ����̨�ʱ�ʧ�ܡ�'||SQLERRM;
        rollback; return;	
	end;
	p_retCode:='0000000000';
	p_retMsg:='';
	commit;
end;

/
show errors

