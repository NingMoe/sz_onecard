CREATE OR REPLACE PROCEDURE SP_RM_MAKECARDFILEPATHDELETE
(
    P_TASKID          CHAR,      --����ID
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
    
BEGIN
  
   
    
    --�����ƿ������
    BEGIN
      UPDATE TF_F_MAKECARDTASK 
      SET    FILEPATH = NULL            --����ƿ��ļ�·��
      WHERE  TASKID = P_TASKID ;    
    
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S094570108';
        P_RETMSG  := '�����ƿ������ʧ��'||SQLERRM;      
        ROLLBACK; RETURN;       
    END;  
          

    p_retCode := '0000000000';
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;      
END;
/
show errors;