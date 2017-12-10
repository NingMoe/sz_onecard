-- =============================================
-- AUTHOR:		董翔
-- CREATE DATE: 2011-07-6
-- DESCRIPTION:	联机账户批量充值审批
-- =============================================
CREATE OR REPLACE PROCEDURE SP_CA_BATCHCHARGEAPPROVAL
(
  P_BATCHNO   CHAR, -- Batch Number
  P_STATECODE CHAR, -- '1' Approved, '3' Rejected
  P_CURROPER  CHAR, -- Current Operator
  P_CURRDEPT  CHAR, -- Current Operator's Department
  P_RETCODE   OUT CHAR, -- Return Code
  P_RETMSG    OUT VARCHAR2 -- Return Message
) AS
  V_TODAY DATE := SYSDATE;
  V_AMOUNT INT;
  V_EX EXCEPTION;

BEGIN

  -- 1) Check the state code
  IF NOT (P_STATECODE = '1' OR P_STATECODE = '3') THEN
    P_RETCODE := 'A004P05B01';
    P_RETMSG := '状态码必须是''1'' (通过)或者''3'' (作废)';
    RETURN;
  END IF;

  BEGIN
    SELECT AMOUNT INTO V_AMOUNT FROM TF_F_SUPPLYSUM WHERE ID = P_BATCHNO;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006012013';
      P_RETMSG := '充值总量台帐表中不存在所指定批次号的记录,' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 2) Update the charge master record's state
  BEGIN
    UPDATE TF_F_SUPPLYSUM
       SET CHECKSTAFFNO  = P_CURROPER,
           CHECKDEPARTNO = P_CURRDEPT,
           CHECKTIME     = V_TODAY,
           STATECODE     = P_STATECODE
     WHERE ID = P_BATCHNO
       AND STATECODE = '0';
  
    IF SQL%ROWCOUNT != 1 THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006012014';
      P_RETMSG := '更新专有帐户批量充值总量台帐失败,' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 3) Update the charge detail records' state
  BEGIN
    UPDATE TF_F_SUPPLY
       SET STATECODE       = P_STATECODE,
           OPERATESTAFFNO  = P_CURROPER,
           OPERATEDEPARTID = P_CURRDEPT,
           OPERATETIME     = V_TODAY
     WHERE ID = P_BATCHNO
       AND STATECODE = '0';
  
    IF SQL%ROWCOUNT != V_AMOUNT THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006012015';
      P_RETMSG := '更新专有帐户批量充值明细台帐失败,' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 4) Copy the approved detail records to finance table
  IF P_STATECODE = '1' THEN
    BEGIN
      INSERT INTO TF_F_SUPPLYCHECK
        (ID,
         CARDNO,
         ACCT_TYPE_NO,
         SUPPLYMONEY,
         STATECODE,
         OPERATESTAFFNO,
         OPERATEDEPARTID,
         OPERATETIME,
         RSRV1)
        SELECT ID,
               CARDNO,
               ACCT_TYPE_NO,
               SUPPLYMONEY,
               STATECODE,
               OPERATESTAFFNO,
               OPERATEDEPARTID,
               OPERATETIME,
               RSRV1
          FROM TF_F_SUPPLY
         WHERE ID = P_BATCHNO;
    
      IF SQL%ROWCOUNT != V_AMOUNT THEN
        RAISE V_EX;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S006012016';
        P_RETMSG := '新增专有帐户批量财务明细台帐失败,' || SQLERRM;
        ROLLBACK;
        RETURN;
    END;
  END IF;

  P_RETCODE := '0000000000';
  P_RETMSG := '';
  COMMIT;
  RETURN;
END;
/
SHOW ERROR
