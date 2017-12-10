CREATE OR REPLACE PROCEDURE SP_GETITEMID(
    ITEMID                    OUT  CHAR     ,
    P_ICCARDNO                VARCHAR2      ,
    P_SAMNO                   VARCHAR2
)
AS

BEGIN
    --获取消费欠费表、销账记录表和销账账目表的账目标识、实时交易流水号和销账流水号

    ITEMID := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')|| LPAD( P_SAMNO, 12, 0) ||SUBSTR( LPAD( P_ICCARDNO, 16, 0), -4 );

EXCEPTION
    WHEN OTHERS THEN
    ITEMID :=NULL;RAISE;
END;
/
show errors