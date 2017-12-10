CREATE OR REPLACE PROCEDURE SP_PS_GetNextNo
(
    p_funcCode   varchar2,
    p_prefix     varchar2,
    p_output   out  varchar2
)
as
v_num1 int;
v_num2 int;
v_num3 int;
v_num4 int;
v_num5 int;
v_nextNum1 int;
v_nextNum2 int;
v_nextNum3 int;
v_nextNum4 int;
v_nextNum5 int;
v_flag int;
v_max  varchar2(50);
v_quantity int;
begin
if p_funcCode='NEXTCORPNO' then
select count(*) into v_quantity from TD_M_CORP where  CORPNO like p_prefix||'%';
if(v_quantity<1) then
p_output:=p_prefix||'00';
return;
end if;
SELECT MAX(SUBSTR(T.CORPNO, -2)) into v_max
    FROM TD_M_CORP T where CORPNO like p_prefix||'%';
    if v_max='ZZ' then
    p_output:='';
    return;
    end if;
        v_num2:=ASCII(substr(v_max,2,1));
         v_num1:=ASCII(substr(v_max,1,1));
v_nextNum1:=v_num1;
v_nextNum2:=v_num2;
sp_ps_num_add_1(v_num2,v_nextNum2,v_flag);
if(v_flag=1) then
sp_ps_num_add_1(v_num1,v_nextNum1,v_flag);
end if;
p_output:=p_prefix||CHR(v_nextNum1)||CHR(v_nextNum2);

elsif p_funcCode='NEXTBALUNITNO' then
select count(*) into v_quantity from TF_B_TRADE_BALUNITCHANGE where  BALUNITNO like p_prefix||'%';
if(v_quantity<1) then
p_output:=p_prefix||'000';
return;
end if;

SELECT LPAD(MAX(SUBSTR(T.BALUNITNO, -3)),3,'0') INTO v_max
    FROM TF_B_TRADE_BALUNITCHANGE T where T.BALUNITNO like p_prefix||'%';

    if v_max='999' then
    p_output:='';
    return;
    end if;

      v_num3:=ASCII(substr(v_max,3,1));
        v_num2:=ASCII(substr(v_max,2,1));
         v_num1:=ASCII(substr(v_max,1,1));
v_nextNum1:=v_num1;
v_nextNum2:=v_num2;
v_nextNum3:=v_num3;

sp_ps_num_add_2(v_num3,v_nextNum3,v_flag);

if(v_flag=1) then
sp_ps_num_add_2(v_num2,v_nextNum2,v_flag);
end if;
if(v_flag=1) then
sp_ps_num_add_2(v_num1,v_nextNum1,v_flag);
end if;
p_output:=p_prefix||CHR(v_nextNum1)||CHR(v_nextNum2)||CHR(v_nextNum3);
end if;

end;
/

show errors