CREATE OR REPLACE PROCEDURE SP_PB_INSERTBALANCETRADE
(
    p_TRADEID            char,
    p_CARDNO            char,
    p_TRADETYPE            char,
    p_CARDTRADENO        char,
    p_BFBALANCE            int,
    p_TRADEMONEY        int,
    p_AFBALANCE            int,
    p_CURRENTTIME         date,
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar  -- Return Message

)
AS
    v_ex          exception;
BEGIN
    BEGIN
      INSERT INTO  TF_BALANCE_TRADE
            (TRADEID,CARDNO,TRADETYPE,CARDTRADENO,BFBALANCE,TRADEMONEY,AFTBALANCE,TRADETIME,
            INLISTTIME)
        VALUES
            (p_TRADEID,p_CARDNO,p_TRADETYPE,p_CARDTRADENO,p_BFBALANCE,p_TRADEMONEY,p_AFBALANCE,
             p_CURRENTTIME,p_CURRENTTIME);

    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001008106';
              p_retMsg  := 'Error occurred while log the balance' || SQLERRM;
              ROLLBACK; RETURN;
  END;
    p_retCode := '0000000000';
  p_retMsg  := '';
END;

/
show errors