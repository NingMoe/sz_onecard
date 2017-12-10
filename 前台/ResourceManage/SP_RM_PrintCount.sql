--记录出库时打印次数
--create by Yin

CREATE OR REPLACE PROCEDURE SP_RM_PrintCount
(
    p_sessionID CHAR,
    p_currOper      char, -- Current Operator
    p_currDept      char, -- Curretn Operator's Department
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message
)
AS
  v_ex            EXCEPTION;
  BEGIN
       for v_cur in (select * from tmp_common where F0 = p_sessionID)
       loop
           BEGIN
             UPDATE TF_F_GETCARDORDER TF SET TF.PRINTCOUNT = TF.PRINTCOUNT + 1 WHERE TF.GETCARDORDERID = v_cur.f1;
             IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
             EXCEPTION
             WHEN OTHERS THEN
                  p_retCode := 'A943912911'; p_retMsg  := '更新领用单表失败' || SQLERRM;
                  ROLLBACK; 
                  RETURN;
           END;
       end loop;
              
      p_retCode := '0000000000';
      p_retMsg  := '';
      COMMIT; RETURN;    
  END;

/
show errors
