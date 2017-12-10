CREATE OR REPLACE PROCEDURE SP_RC_INSERTRESYNC
(
  P_TRADEID        varchar2 :='',
  P_CITIZEN_CARD_NO         varchar2 :='',
  P_SYNCSYSCODE    varchar2 :='',
  P_CURROPER       varchar2 :='',
  P_CURRDEPT       varchar2 :='',
  P_RETCODE        OUT CHAR, -- Return Code
  P_RETMSG         OUT VARCHAR2 -- Return Message
) AS
  V_SEQ CHAR(16);
  V_TODAY DATE := SYSDATE;
  V_EX EXCEPTION;
BEGIN

    -- 记录异常同步台账子表
    BEGIN
     SP_GETSEQ(SEQ => V_SEQ);
     INSERT INTO TF_B_YSKRESYNC(
          SYNCTRADEID   , TRADEID       , SYNCSYSCODE    , CITIZEN_CARD_NO           ,
          SYNCCODE      , SYNCERRINFO   , OPERATESTAFFNO , OPERATEDEPARTNO  ,
          OPERATETIME
     )SELECT
          V_SEQ         , a.TRADEID     , a.SYNCSYSCODE  , a.CITIZEN_CARD_NO         ,
          a.SYNCCODE    , a.SYNCERRINFO , P_CURROPER     , P_CURRDEPT       ,
          V_TODAY
      FROM   TF_B_SYNC a
      WHERE a.TRADEID = P_TRADEID
      AND   a.CITIZEN_CARD_NO = P_CITIZEN_CARD_NO
      AND   a.SYNCSYSCODE = P_SYNCSYSCODE;

      IF SQL%ROWCOUNT = 0 THEN
        RAISE V_EX;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S00100W002';
        P_RETMSG := '记录异常同步台账子表,' || SQLERRM;
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