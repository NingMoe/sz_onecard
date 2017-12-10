CREATE OR REPLACE PROCEDURE SP_PS_PreDeExam_Cancel
(
    P_ID              CHAR     , --审核流水号
    P_CURROPER        CHAR     ,
    P_CURRDEPT        CHAR     ,
    P_RETCODE     OUT CHAR     ,
    P_RETMSG      OUT VARCHAR2
)
AS
    V_TODAY           DATE         := SYSDATE    ;
    V_EX              EXCEPTION                  ;
BEGIN
	BEGIN
      --更新预付款保证金业务台账审核表
      UPDATE TF_B_DEPTACC_EXAM
      SET    EXAMSTAFFNO   = P_CURROPER ,
             EXAMDEPARTNO  = P_CURRDEPT ,
             EXAMKTIME     = V_TODAY    ,
             STATECODE     = '3'
      WHERE  ID            = P_ID
      AND    STATECODE     = '1';  
    
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
      P_RETCODE := 'S008905012';
      P_RETMSG  := '更新预付款保证金业务台账审核表失败'||SQLERRM;
      ROLLBACK;RETURN;    		
	END;
	  p_retCode := '0000000000'; p_retMsg  := '成功';
    commit; return;	 
END;

/
SHOW ERRORS