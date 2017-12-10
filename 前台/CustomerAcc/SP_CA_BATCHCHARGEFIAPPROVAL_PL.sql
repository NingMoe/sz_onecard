-- =============================================
-- AUTHOR:		董翔
-- CREATE DATE: 2011-07-6
-- DESCRIPTION:	联机账户批量充值财务审批
-- 修改: 2013-01-28 账户充值时操作员工记成导入充值文件首次提交的员工
-- =============================================
CREATE OR REPLACE PROCEDURE SP_CA_BATCHCHARGEFIAPPROVAL
(
  P_SESSIONID VARCHAR2, -- Session ID
  P_STATECODE CHAR, -- '2' Fi Approved, '3' Rejected
  P_CURROPER  CHAR, -- Current Operator
  P_CURRDEPT  CHAR, -- Current Operator's Department
  P_RETCODE   OUT CHAR, -- Return Code
  P_RETMSG    OUT VARCHAR2 -- Return Message
) AS
  V_TODAY DATE := SYSDATE;
  V_AMOUNT INT;
  V_QUANTITY INT;
  V_EX EXCEPTION;
  V_COUNT INT := 0;
  V_ACCID CHAR(12);
  V_SUPPLYSTAFFNO CHAR(6);
  V_SUPPLYDEPARTNO VARCHAR2(8);
  v_tradeID char(16);
BEGIN

  -- 1) Check the state code
  IF NOT (P_STATECODE = '2' OR P_STATECODE = '3') THEN
    P_RETCODE := 'A004P06B01';
    P_RETMSG := '状态码必须是''2'' (财务已审核) 或 ''3'' (作废)';
    RETURN;
  END IF;

  SELECT COUNT(*)
    INTO V_QUANTITY
    FROM TMP_GC_BATCHNOLIST
   WHERE SESSIONID = P_SESSIONID;
  IF V_QUANTITY IS NULL OR V_QUANTITY <= 0 THEN
    P_RETCODE := 'A006014011';
    P_RETMSG := '没有任何专有帐户批量充值数据需要处理';
    RETURN;
  END IF;

  -- 2) Update the master tracing record
  BEGIN
    UPDATE TF_F_SUPPLYSUM
       SET EXAMSTAFFNO = P_CURROPER,
           EXAMTIME    = V_TODAY,
           STATECODE   = P_STATECODE
     WHERE STATECODE = '1'
       AND ID IN (SELECT BATCHNO
                    FROM TMP_GC_BATCHNOLIST
                   WHERE SESSIONID = P_SESSIONID);

    IF SQL%ROWCOUNT != V_QUANTITY THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006014012';
      P_RETMSG := '更新专有帐户批量充值总量台帐失败,' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  SELECT SUM(AMOUNT)
    INTO V_AMOUNT
    FROM TF_F_SUPPLYSUM
   WHERE ID IN (SELECT BATCHNO
                  FROM TMP_GC_BATCHNOLIST
                 WHERE SESSIONID = P_SESSIONID);

  -- 3) Update the finance detail records' state
  BEGIN
    UPDATE TF_F_SUPPLYCHECK
       SET STATECODE       = P_STATECODE,
           OPERATESTAFFNO  = P_CURROPER,
           OPERATEDEPARTID = P_CURRDEPT,
           OPERATETIME     = V_TODAY
     WHERE ID IN (SELECT BATCHNO
                    FROM TMP_GC_BATCHNOLIST
                   WHERE SESSIONID = P_SESSIONID)
       AND STATECODE = '1';

    IF SQL%ROWCOUNT != V_AMOUNT THEN
      RAISE V_EX;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006014013';
      P_RETMSG := '更新专有帐户批量财务充值明细失败,' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  IF P_STATECODE = '3' THEN
    -- Rejected By Finance
    BEGIN
      UPDATE TF_F_SUPPLY
         SET STATECODE       = P_STATECODE,
             OPERATESTAFFNO  = P_CURROPER,
             OPERATEDEPARTID = P_CURRDEPT,
             OPERATETIME     = V_TODAY
       WHERE ID IN (SELECT BATCHNO
                      FROM TMP_GC_BATCHNOLIST
                     WHERE SESSIONID = P_SESSIONID)
         AND STATECODE = '1';

      IF SQL%ROWCOUNT != V_AMOUNT THEN
        RAISE V_EX;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S006014014';
        P_RETMSG := '更新专有帐户批量充值明细失败,' || SQLERRM;
        ROLLBACK;
        RETURN;
    END;
  ELSE
    -- Approved, update the accounts' balance
    BEGIN
      V_COUNT := 0;
      FOR V_CURSOR IN (SELECT FI.ID, FI.CARDNO,FI.ACCT_TYPE_NO, FI.SUPPLYMONEY OFFERMONEY
                         FROM TF_F_SUPPLYCHECK FI
                        WHERE FI.ID IN
                              (SELECT BATCHNO
                                 FROM TMP_GC_BATCHNOLIST
                                WHERE SESSIONID = P_SESSIONID))
      LOOP
        
        SELECT TO_CHAR(TF.ACCT_ID) INTO V_ACCID FROM TF_F_CUST_ACCT TF 
        WHERE TF.ACCT_TYPE_NO = V_CURSOR.ACCT_TYPE_NO AND TF.ICCARD_NO = V_CURSOR.CARDNO; 
        
        SELECT SUPPLYSTAFFNO,SUPPLYDEPARTNO INTO V_SUPPLYSTAFFNO,V_SUPPLYDEPARTNO FROM tf_f_supplysum WHERE ID = V_CURSOR.ID;
        
        --充值
        SP_CA_CHARGE_nocom(V_ACCID,V_CURSOR.CARDNO,V_CURSOR.OFFERMONEY,
		'0','8L',V_SUPPLYSTAFFNO,V_SUPPLYDEPARTNO,v_tradeID,P_RETCODE,P_RETMSG);
        IF p_retCode != '0000000000' THEN
            ROLLBACK; RETURN;
        END IF;
        V_COUNT := V_COUNT + SQL%ROWCOUNT;
      END LOOP;
      /*IF V_COUNT != V_AMOUNT THEN
        RAISE V_EX;
      END IF;*/
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S006014015';
        P_RETMSG := '更新专有帐户批量可充值帐户失败,' || SQLERRM;
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
