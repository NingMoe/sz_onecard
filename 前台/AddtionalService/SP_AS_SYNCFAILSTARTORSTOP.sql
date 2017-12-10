CREATE OR REPLACE PROCEDURE SP_AS_SYNCFAILSTARTORSTOP
(
       p_SESSIONID varchar2,
       p_TYPE      char, --0 图书馆，1, 休闲  2园林
       p_STATE     char, --0 重新同步，1设为同步成功（不同步）
       p_currOper  char, -- Current Operator
       p_currDept  char, -- Current Operator's Department
       p_retCode   out char, -- Return Code
       p_retMsg    out varchar2 -- Return Message
) AS
       v_EX        exception;
       v_TRADEID          char(16);
BEGIN

  FOR v_cur in (SELECT A.CARDNO,A.Tradeid
                  FROM TMP_AS_SYNCFAIL A
                 WHERE A.SESSIONID = p_SESSIONID) LOOP

      --  Get trade id
      SP_GetSeq(seq => v_TRADEID);

      IF P_TYPE='0' THEN
         BEGIN
           UPDATE TF_B_LIB_SYNC T SET T.SYNCCODE=p_STATE WHERE T.Tradeid=v_cur.Tradeid AND T.SYNCCODE='2';
            IF SQL%ROWCOUNT != 1 THEN
              RAISE v_EX;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S001010001';
              p_retMsg  := '更新图书馆同步记录失败' || SQLERRM;
              RETURN;
              ROLLBACK;
           END;
     END IF;

      IF P_TYPE='1' THEN
         BEGIN
           UPDATE TF_B_GARDENXXCARD T SET T.Dealtype=p_STATE WHERE T.Tradeid=v_cur.Tradeid AND T.Dealtype='2';
            IF SQL%ROWCOUNT != 1 THEN
              RAISE v_EX;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S001010002';
              p_retMsg  := '更新休闲同步记录失败' ||SQLERRM;
              RETURN;
              ROLLBACK;
           END;
     END IF;

      IF P_TYPE='2' THEN
         BEGIN
           UPDATE TF_B_GARDENCARD T SET T.Dealtype=p_STATE WHERE T.Tradeid=v_cur.Tradeid AND T.Dealtype='2';
            IF SQL%ROWCOUNT != 1 THEN
              RAISE v_EX;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S001010003';
              p_retMsg  := '更新园林同步记录失败' || SQLERRM;
              RETURN;
              ROLLBACK;
           END;
     END IF;

     --记录修改台账
     BEGIN
         INSERT INTO TF_B_SYNCFAILTRADE(TRADEID,CARDNO,SYNCTYPE,SYNCCODE,UPDATESTAFFNO,OPERATETIME)
         VALUES(v_TRADEID,v_cur.cardno,P_TYPE,p_STATE,p_currOper,sysdate);
           IF SQL%ROWCOUNT != 1 THEN
              RAISE v_EX;
            END IF;
          EXCEPTION
            WHEN OTHERS THEN
              p_retCode := 'S001010004';
              p_retMsg  := '更新台账记录失败' || SQLERRM;
              RETURN;
              ROLLBACK;
     END;
  END LOOP;
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT;
  RETURN;
END;
