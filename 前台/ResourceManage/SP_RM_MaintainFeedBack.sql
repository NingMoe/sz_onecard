CREATE OR REPLACE PROCEDURE SP_RM_MaintainFeedBack  --��Դά����������Ϣ�ύ
(
  P_MAINTAINORDERID      CHAR     ,      --ά������
  P_FEEDBACK             VARCHAR2 ,      --������Ϣ
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
  --������Դά������
  UPDATE TF_F_RESOURCEMAINTAINORDER
  SET FEEDBACK  = FEEDBACK||P_FEEDBACK
  WHERE MAINTAINORDERID = P_MAINTAINORDERID;

    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
      WHEN OTHERS THEN
          p_retCode := 'SR00120001';
          p_retMsg  := '������Դά������ʧ��'|| SQLERRM;
          ROLLBACK; RETURN;
  END;

  p_retCode := '0000000000';
  p_retMsg  := '�ɹ�';
  COMMIT; RETURN;
END;
/
SHOW ERROR;
