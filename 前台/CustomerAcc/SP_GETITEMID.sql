CREATE OR REPLACE PROCEDURE SP_GETITEMID(
    ITEMID                    OUT  CHAR     ,
    P_ICCARDNO                VARCHAR2      ,
    P_SAMNO                   VARCHAR2
)
AS

BEGIN
    --��ȡ����Ƿ�ѱ����˼�¼���������Ŀ�����Ŀ��ʶ��ʵʱ������ˮ�ź�������ˮ��

    ITEMID := TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')|| LPAD( P_SAMNO, 12, 0) ||SUBSTR( LPAD( P_ICCARDNO, 16, 0), -4 );

EXCEPTION
    WHEN OTHERS THEN
    ITEMID :=NULL;RAISE;
END;
/
show errors