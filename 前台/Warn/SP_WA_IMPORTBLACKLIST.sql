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

    v_cardno          varchar2(16);       --����
    v_overtimemoney           int;        --��ʱ���
    v_listtype        char(2);            --��������
    v_remark          varchar2(100);      --��ע

BEGIN
  for v_c in (select * from tmp_blacklist where f4 = p_sessionID)
    loop
        --����������
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
                  P_RETMSG  := '�����˵���ʧ��'||SQLERRM;
                  ROLLBACK; RETURN;
        END;

           -- ���ɱ���̨��
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
              P_RETMSG  := '�������������ݱ�ʧ��' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    end loop;

  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;

END;
/
