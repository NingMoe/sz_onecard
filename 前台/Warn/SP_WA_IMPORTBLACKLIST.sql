CREATE OR REPLACE PROCEDURE SP_WA_IMPORTBLACKLIST
(
    p_sessionID       char,
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode         out char, -- Return Code
    p_retMsg          out varchar2  -- Return Message
)
AS
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;

    v_cardno          varchar2(16);       --卡号
    v_overtimemoney           int;        --超时金额
    v_listtype        char(2);            --名单类型
    v_remark          varchar2(100);      --备注

BEGIN
  for v_c in (select * from tmp_blacklist where f4 = p_sessionID)
    loop
        --新增黑名单
        BEGIN
          INSERT INTO  TF_B_WARN_BLACK
          (CARDNO, CREATETIME, WARNTYPE, WARNLEVEL,
        UPDATESTAFFNO, UPDATETIME, DOWNTIME, REMARK,
        BLACKSTATE, BLACKTYPE, BLACKLEVEL, OVERTIMEMONEY,LISTTYPECODE)
         VALUES
        (v_c.f0, V_TODAY, NULL, '1',
        P_CURROPER, V_TODAY, NULL, v_c.f3,
        '0', '3', '0', v_c.f2,v_c.f1);

          IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
                EXCEPTION
                WHEN OTHERS THEN
                  P_RETCODE := 'S094780024';
                  P_RETMSG  := '新增账单表失败'||SQLERRM;
                  ROLLBACK; RETURN;
        END;

           -- 生成备份台账
  BEGIN
    INSERT INTO TH_B_WARN_BLACK
    (HSEQNO, BACKTIME, BACKSTAFF, BACKWHY,
    CARDNO, CREATETIME, WARNTYPE, WARNLEVEL,
    UPDATESTAFFNO, UPDATETIME, DOWNTIME, REMARK,
    BLACKSTATE, BLACKTYPE, BLACKLEVEL, OVERTIMEMONEY,LISTTYPECODE)
    SELECT
        TH_B_WARN_BLACK_SEQ.NEXTVAL, V_TODAY, P_CURROPER,  '5',
        CARDNO, CREATETIME, WARNTYPE, WARNLEVEL,
        UPDATESTAFFNO, UPDATETIME, DOWNTIME, REMARK,
        BLACKSTATE, BLACKTYPE, BLACKLEVEL,OVERTIMEMONEY,LISTTYPECODE
    FROM     TF_B_WARN_BLACK
    WHERE     CARDNO = v_c.f0;

    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'S002W01002';
              P_RETMSG  := '新增黑名单备份表失败' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    end loop;

  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;

END;
/
