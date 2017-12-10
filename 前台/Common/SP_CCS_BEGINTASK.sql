CREATE OR REPLACE PROCEDURE SP_CCS_BEGINTASK
(
    p_TASKID char,

    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_ex           exception ;
BEGIN

    -- 1) Update the SERVICE PARAM
    BEGIN
        UPDATE TD_M_SERVICESET
        SET TASKDESC = '��ǰ����' || p_TASKID || '��ʼִ��';

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S009000001'; p_retMsg := '���·������ò�����ʧ��' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 2) UPDATE THE TASK
    BEGIN
        UPDATE TF_F_MAKECARDTASK
        SET TASKSTATE = '1',
            TASKSTARTTIME = sysdate
        WHERE TASKID = p_TASKID;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S009000002'; p_retMsg := '�����ƿ������ʧ��' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg  := '';
END;
/
show errors