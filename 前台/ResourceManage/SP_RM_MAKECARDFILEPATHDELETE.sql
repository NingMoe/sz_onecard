CREATE OR REPLACE PROCEDURE SP_RM_MAKECARDFILEPATHDELETE
(
    P_TASKID          CHAR,      --任务ID
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
    
BEGIN
  
   
    
    --更新制卡任务表
    BEGIN
      UPDATE TF_F_MAKECARDTASK 
      SET    FILEPATH = NULL            --清空制卡文件路径
      WHERE  TASKID = P_TASKID ;    
    
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S094570108';
        P_RETMSG  := '更新制卡任务表失败'||SQLERRM;      
        ROLLBACK; RETURN;       
    END;  
          

    p_retCode := '0000000000';
    p_retMsg  := '成功';
    COMMIT; RETURN;      
END;
/
show errors;