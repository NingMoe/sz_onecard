CREATE OR REPLACE PROCEDURE SP_PS_CALLINGRIGHTADD
(
    P_CALLINGNO       CHAR,          
    P_CALLINGRIGHTVALUE    FLOAT,
    P_APPLYTYPE       CHAR,        
    P_REMARK         varchar2,      
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS

    V_COUNT           INT;
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;

BEGIN
  SELECT COUNT(*) INTO V_COUNT FROM TD_M_CALLINGRIGHTVALUE WHERE CALLINGNO =P_CALLINGNO AND APPLYTYPE = P_APPLYTYPE;
  IF V_COUNT>0 THEN
   P_RETCODE := 'S094780023';
   P_RETMSG  := '已经存在此行业的行业权值,不可再新增';
   ROLLBACK; RETURN;
END IF;
  
  --新增行业权值表
  BEGIN
    INSERT INTO  TD_M_CALLINGRIGHTVALUE(                                                                
    CALLINGNO            , CALLINGRIGHTVALUE      ,APPLYTYPE  , UPDATESTAFFNO       , UPDATETIME          , REMARK        )                                                            
VALUES(                                                                
    P_CALLINGNO          ,P_CALLINGRIGHTVALUE     , P_APPLYTYPE ,P_CURROPER         , V_TODAY           ,    P_REMARK      );                                                             
                            
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S094780024';
            P_RETMSG  := '新增行业权值表失败,'||SQLERRM;
            ROLLBACK; RETURN;
   
  END;
  
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;   
END;
/
show errors;
