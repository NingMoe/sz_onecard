CREATE OR REPLACE PROCEDURE SP_RM_MaintainFeedBack  --资源维护单反馈信息提交
(
  P_MAINTAINORDERID      CHAR     ,      --维护单号
  P_FEEDBACK             VARCHAR2 ,      --反馈信息
  P_currOper             char     ,
  P_currDept             char     ,
  P_retCode              out char     ,  -- Return Code
  P_retMsg               out varchar2    -- Return Message
)
AS
    v_seqNo             CHAR(16)       ;
    V_TODAY             DATE := SYSDATE;
    V_EX                EXCEPTION      ;
BEGIN
  
 BEGIN
  --更新资源维护单表
  UPDATE TF_F_RESOURCEMAINTAINORDER
  SET FEEDBACK  = FEEDBACK||P_FEEDBACK
  WHERE MAINTAINORDERID = P_MAINTAINORDERID;

    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
      WHEN OTHERS THEN
          p_retCode := 'SR00120001';
          p_retMsg  := '更新资源维护单表失败'|| SQLERRM;
          ROLLBACK; RETURN;
  END;

  p_retCode := '0000000000';
  p_retMsg  := '成功';
  COMMIT; RETURN;
END;
/
SHOW ERROR;
