CREATE OR REPLACE PROCEDURE SP_CC_SETSERVICE
(
  P_RECYCELTIME           INT      ,
  P_ISSTART               CHAR     ,
  p_currOper              CHAR     ,
  p_currDept              CHAR     ,
  p_retCode              out char     ,  -- Return Code
  p_retMsg               out varchar2    -- Return Message
)
AS
    V_TODAY             DATE := SYSDATE;
    V_EX EXCEPTION;
BEGIN


  --修改服务配置参数表
  BEGIN
      UPDATE TD_M_SERVICESET SET
          RECYCELTIME  =  P_RECYCELTIME  , ISSTART =  P_ISSTART  ,
          OPERATESTAFFNO = p_currOper, OPERATEDEPTID = p_currDept , OPERATETIME  =  V_TODAY
      WHERE SERVICEID =  '0001';
      IF SQL%ROWCOUNT != 1 THEN
        RAISE V_EX;
      END IF;
      EXCEPTION
      WHEN OTHERS THEN
          p_retCode := 'SR00150002';
          p_retMsg  := '修改服务配置参数失败'|| SQLERRM;
          ROLLBACK; RETURN;
  END;

  p_retCode := '0000000000';
  p_retMsg  := '成功';
  COMMIT; RETURN;
END;
/
