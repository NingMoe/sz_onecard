CREATE OR REPLACE PROCEDURE SP_PS_Num_ADD_2
(
    num   int,
    nextNum out int,
    flag   out  int
)
as
begin
flag:=0;

if(num=57) then
nextNum:=48;
flag:=1;
return;
end if;
nextNum:=num+1;
end;
/

show errors