CREATE OR REPLACE PROCEDURE SP_CA_BATCHCHANGECUSTINFO
(
  P_sessionID char, -- 会话ID
  P_CURROPER CHAR, --当前操作者
  P_CURRDEPT CHAR, --当前操作者部门
  P_RETCODE  OUT CHAR, --错误编码
  P_RETMSG   OUT VARCHAR2 --错误信息
) AS
  V_EX EXCEPTION;
BEGIN
  BEGIN
    /*
     F1  CARDNO,
     F2  CUSTNAME,
     F3  CUSTSEX,
     F4  CUSTBIRTH,
     F5  PAPERTYPE,
     F6  PAPERNO,
     F7  CUSTADDR,
     F8  CUSTPOST,
     F9  CUSTPHONE,
     F10 CUSTTEL,
     F11 CUSTEMAIL
    */
    FOR V_CUR IN (SELECT F1, F2, F3, F4, F5, F6, F7, F8, F9, F10, F11, F12
                    FROM TMP_COMMON where f13 = P_sessionID) LOOP
      SP_CA_CHANGECUSTINFO(-1,
      										 V_CUR.F1, --CARDNO
                           V_CUR.F2, --CUSTNAME
                           V_CUR.F4, --CUSTBIRTH
                           V_CUR.F5, --PAPERTYPE
                           V_CUR.F6, --PAPERNO
                           V_CUR.F3, --CUSTSEX
                           V_CUR.F9, --CUSTPHONE
                           V_CUR.F10, --CUSTTEL
                           V_CUR.F8, --CUSTPOST
                           V_CUR.F7, --CUSTADDR
                           V_CUR.F11, -- CUSTEMAIL
                           0,
                           0,
                           0,
                           P_CURROPER,
                           P_CURRDEPT,
                           P_RETCODE,
                           P_RETMSG);
      IF P_RETCODE != '0000000000' THEN
        ROLLBACK;
        RETURN;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
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