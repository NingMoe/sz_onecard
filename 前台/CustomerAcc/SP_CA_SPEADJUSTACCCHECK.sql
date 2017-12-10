  -- =============================================
  -- AUTHOR:    董翔
  -- CREATE DATE: 2011-08-04
  -- DESCRIPTION:  联机账户特殊调账审核
  -- =============================================
 CREATE OR REPLACE PROCEDURE SP_CA_SPEADJUSTACCCHECK
(
  P_SESSIONID VARCHAR2, --session id
  P_STATECODE CHAR, -- '1' Approved, '3' Rejected
  P_CURROPER  CHAR, -- Current Operator
  P_CURRDEPT  CHAR, -- Current Operator's Department
  P_RETCODE   OUT CHAR, -- Return Code
  P_RETMSG    OUT VARCHAR2 -- Return Message
) AS
  V_TODAY DATE := SYSDATE;
  V_EX EXCEPTION;

BEGIN

  -- 1) Check the state code
  IF NOT (P_STATECODE = '1' OR P_STATECODE = '3') THEN
    P_RETCODE := 'A004P05B01';
    P_RETMSG := '状态码必须是''1'' (通过)或者''3'' (作废)';
    RETURN;
  END IF;

  -- 2) 处理记录
  BEGIN
    IF P_STATECODE = '1' THEN
      BEGIN
        FOR V_CUR IN (SELECT ICCARD_NO, TRADEID
                        FROM TF_B_ACCT_SPEADJUSTACC
                       WHERE TRADEID IN
                             (SELECT TRADEID
                                FROM TMP_ADJUSTACC_IMP
                               WHERE SESSIONID = P_SESSIONID)) LOOP
          SP_CA_SPEADJUSTACC(V_CUR.ICCARD_NO,
                             V_CUR.TRADEID,
                             P_CURROPER,
                             P_CURRDEPT,
                             P_RETCODE,
                             P_RETMSG);
        
          IF P_RETCODE != '0000000000' THEN
            ROLLBACK;
            RETURN;
          END IF;
        END LOOP;
      END;
    ELSIF P_STATECODE = '3' THEN
      UPDATE TF_B_ACCT_SPEADJUSTACC
         SET STATECODE    = P_STATECODE,
             CHECKSTAFFNO = P_CURROPER,
             CHECKTIME    = V_TODAY
       WHERE TRADEID IN (SELECT TRADEID
                           FROM TMP_ADJUSTACC_IMP
                          WHERE SESSIONID = P_SESSIONID);
        IF SQL%ROWCOUNT <= 0 THEN
		      RAISE V_EX;
		    END IF;
    END IF;
   
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S006012014';
      P_RETMSG := '特殊调账失败' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  P_RETCODE := '0000000000';
  P_RETMSG := '';
  COMMIT;
  RETURN;
END;


/
SHOW ERROR
