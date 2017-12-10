CREATE OR REPLACE PROCEDURE SP_FI_INSERTEXPORTSQL
(
  P_REPORTDATE        varchar2 :='',
  P_REPORTTYPE        varchar2 :='',
  P_USETAG            char,
  p_currOper          varchar2 :='',
  p_currDept          varchar2 :='',
  p_retCode   out char, -- Return Code
  p_retMsg    out varchar2  -- Return Message

) AS
  v_TradeID char(16);
  V_TODAY DATE := SYSDATE;
  V_EX EXCEPTION;
BEGIN

    -- 记录商户转账日报sql文件导出台账表
    BEGIN
        -- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);

     INSERT INTO TF_B_EXPORTSQL(
          TRADEID ,REPORTDATE ,REPORTTYPE ,OPERATESTAFFNO, OPERATEDEPARTNO, OPERATETIME, USETAG
     )values(
          v_TradeID, P_REPORTDATE, P_REPORTTYPE, p_currOper,  p_currDept, V_TODAY, P_USETAG);

    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S00100W002';
        p_retMsg := '商户转账日报sql文件导出台账表失败,' || SQLERRM;
        ROLLBACK;
        RETURN;
    END;


  p_retCode := '0000000000';
  p_retMsg := '';
  COMMIT;
  RETURN;
END;
/
show errors