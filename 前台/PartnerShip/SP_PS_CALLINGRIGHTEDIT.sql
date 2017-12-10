CREATE OR REPLACE PROCEDURE SP_PS_CALLINGRIGHTEDIT
(
    P_CALLINGNO             CHAR    ,
    P_CALLINGRIGHTVALUE     FLOAT     ,
    P_APPLYTYPE             CHAR,
    P_REMARK               VARCHAR2  , 
    P_CURROPER              CHAR     ,
    P_CURRDEPT              CHAR     ,
    P_RETCODE           OUT CHAR     ,
    P_RETMSG            OUT VARCHAR2 
)
AS
    V_COUNT           INT;
    V_TODAY           DATE         := SYSDATE    ;
    V_EX              EXCEPTION                  ;

BEGIN
    
      
    BEGIN
    --更新行业权值表
      UPDATE TD_M_CALLINGRIGHTVALUE 
      SET CALLINGRIGHTVALUE = P_CALLINGRIGHTVALUE,
          REMARK  = P_REMARK,
          UPDATESTAFFNO = P_CURROPER,
          UPDATETIME = V_TODAY
      WHERE CALLINGNO= P_CALLINGNO 
      AND APPLYTYPE = P_APPLYTYPE;
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION
        WHEN OTHERS THEN
              p_retCode := 'S094570157'; p_retMsg  := '更新行业权值表失败' || SQLERRM;
              ROLLBACK; RETURN;              
       END;     
     

     p_retCode := '0000000000'; p_retMsg  := '成功';
     COMMIT; RETURN;   
END;
/
show errors;
