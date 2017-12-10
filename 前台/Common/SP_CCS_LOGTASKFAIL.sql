CREATE OR REPLACE PROCEDURE SP_CCS_LOGTASKFAIL
(
    p_TASKID char,
    p_REASON varchar2,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_ex           exception ;
BEGIN


    -- 1) UPDATE THE TASK
    BEGIN
        UPDATE TF_F_MAKECARDTASK
        SET TASKSTATE = '3',
            TASKENDTIME = sysdate,
            REMARK = p_REASON
        WHERE TASKID = p_TASKID;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S009000002'; p_retMsg := '更新制卡任务表失败' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg  := '';
END;
/
show errors