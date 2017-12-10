CREATE OR REPLACE PROCEDURE SP_RC_UPDATESYNCSTATE
(
 
  P_TRADEID        varchar2 :='',
  P_CARDNO         varchar2 :='',
  P_SYNCSYSCODE    varchar2 :='',
  P_STATE          varchar2 :='',
  P_ERROR          varchar2 :='',
  P_SYSCSYSTRADEID varchar2 :='',

  P_SUCC_NUM     NUMBER := 0,
  P_FAIL_NUM     NUMBER := 0,
  p_currOper       varchar2 :='',
  p_currDept       varchar2 :='',
  P_RETCODE        OUT CHAR, -- Return Code
  P_RETMSG         OUT VARCHAR2 -- Return Message
) AS
  V_COUNT NUMBER := 0;
  V_RUN_STATE CHAR := '1';
  V_TODAY DATE := SYSDATE;
  V_EX EXCEPTION;
BEGIN

    -- ����ͬ��̨���ӱ�
    BEGIN
      UPDATE TF_B_SYNC
         SET SYNCCODE       = P_STATE,
             SYNCTIME       = V_TODAY,
             SYNCERRINFO    = NVL(P_ERROR,SYNCERRINFO),
             SYNCSYSTRADEID = P_SYSCSYSTRADEID
       WHERE TRADEID = P_TRADEID
         AND CITIZEN_CARD_NO = P_CARDNO
         AND SYNCSYSCODE=P_SYNCSYSCODE;
       
      IF SQL%ROWCOUNT = 0 THEN
        RAISE V_EX;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S00100W001';
        P_RETMSG := '����ͬ��̨���ӱ�ʧ��,' || SQLERRM;
        ROLLBACK;
        RETURN;
    END;


  P_RETCODE := '0000000000';
  P_RETMSG := '';
  COMMIT;
  RETURN;
END;
/
show errors
