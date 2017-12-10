CREATE OR REPLACE PROCEDURE SP_GetJiMing
(
	p_CardNo            char, -- step length
	IsJiMing  			OUT  	CHAR         -- output sequence number
)
AS
v_quantity 	int;
v_custName  varchar(200);
v_paperno	varchar(200);
BEGIN
	--�⽭���񿨣��żҸ�����
	if(substr(p_CardNo,0,6)='215013' or substr(p_CardNo,0,6)='215016') then
		IsJiMing:='1';  
		return;		
	end if;
	--��ͨ��������ܵģ��������������Ч��
	select count(*) into v_quantity 
	from TD_GROUP_CARD 
	where cardno=p_CardNo and usetag='1';
	if(v_quantity>0) then
		IsJiMing:='1';
		return;
	end if;
	--������֤�����ֶ����߾�Ϊ�ǿ�
	BEGIN
		select nvl(custname,'') ,nvl(paperno,'') into v_custname,v_paperno 
		from TF_F_CUSTOMERREC 
		where cardno=p_CardNo;
		if(v_custname is not null and v_paperno is not null) then
		IsJiMing:='1';
		return;
		end if;
	EXCEPTION 
	WHEN NO_DATA_FOUND THEN
		IsJiMing:='0';
	end ;
	IsJiMing:='0';
END;
/
show errors