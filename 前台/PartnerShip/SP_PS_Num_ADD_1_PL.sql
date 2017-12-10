CREATE OR REPLACE PROCEDURE SP_PS_Num_ADD_1
(
    num   int,
    nextNum out int,
    flag   out  int
)
as
begin
flag:=0;
if(num=57) then
nextNum:=65;
return;
end if;

if(num=90) then
nextNum:=48;
flag:=1;
return;
end if;
nextNum:=num+1;
end;
/

show errors