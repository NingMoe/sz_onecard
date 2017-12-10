create or replace procedure SP_PB_CHANGEUSERINFOSYNCUPDATE
(
    P_TRADEID                    VARCHAR2,
    P_CARDNO                     VARCHAR2,
    P_STATE                      VARCHAR2,
    P_ERROR                      VARCHAR2,
    p_retCode                 OUT VARCHAR2  ,
    p_retMsg                  OUT VARCHAR2
)
as
  v_TradeID char(16);
  V_TODAY DATE := SYSDATE;
    V_EX EXCEPTION;

  BEGIN
    -- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);
  
      BEGIN
        UPDATE TF_B_SYNC SET
        SYNCSYSTRADEID    = v_TradeID,
        SYNCCODE       = P_STATE,
        SYNCERRINFO=P_ERROR,
        SYNCTIME=V_TODAY
        where TRADEID = P_TRADEID
         AND CITIZEN_CARD_NO = P_CARDNO;

        IF SQL%ROWCOUNT = 0 THEN
        RAISE V_EX;
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S00100W001';
        P_RETMSG := '更新同步台帐子表失败,' || SQLERRM;
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
