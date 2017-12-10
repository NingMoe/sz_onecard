CREATE OR REPLACE PROCEDURE SP_RM_MODIFYKEY
(
    P_ID                    INT      ,
    P_CORPCODE              CHAR     ,
    P_CURROPER              CHAR     ,
    P_CURRDEPT              CHAR     ,
    P_RETCODE           OUT CHAR     ,
    P_RETMSG            OUT VARCHAR2 
)
AS
    v_seqNo              CHAR(16); --业务流水号
    V_COUNT           INT;
    V_CORPCODE        CHAR(1);
    V_TODAY           DATE         := SYSDATE    ;
    V_EX              EXCEPTION                  ;

BEGIN
    SELECT COUNT(*) INTO V_COUNT FROM TD_M_PUBLICANDPRIVATEKEY WHERE CORPCODE = P_CORPCODE;
    IF V_COUNT>0 THEN
     p_retCode := 'S094570156'; p_retMsg  := '此卡片厂商已存在公私钥对' || SQLERRM;
              ROLLBACK; RETURN; 
    END IF;
    
    SELECT CORPCODE INTO V_CORPCODE FROM TD_M_PUBLICANDPRIVATEKEY WHERE ID = P_ID;
    IF V_CORPCODE IS NOT NULL THEN
    p_retCode := 'S094570158'; p_retMsg  := '此公私钥对已分配卡片厂商' || SQLERRM;
         ROLLBACK; RETURN; 
    END IF;
     
    BEGIN
    --更新公私钥维护表
      UPDATE TD_M_PUBLICANDPRIVATEKEY 
      SET CORPCODE = P_CORPCODE,
      OPERATESTAFFNO = P_CURROPER,
      OPERATEDEPTID = P_CURRDEPT,
      OPERATETIME = V_TODAY
      WHERE ID = P_ID;
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION
        WHEN OTHERS THEN
              p_retCode := 'S094570157'; p_retMsg  := '更新公私钥维护表失败' || SQLERRM;
              ROLLBACK; RETURN;              
       END;     
      BEGIN
       --记录公私钥操作台帐表
        SP_GetSeq(seq => v_seqNo);
         INSERT INTO TF_B_PUBLICANDPRIVATEKEYLOG(
         TRADEID      ,STAFFNO    ,OPERTIME   ,ID       ,OPERTYPECODE 
         )VALUES(
            v_seqNo    ,P_CURROPER ,V_TODAY    ,P_ID   ,'01'
                      );
       END;

     p_retCode := '0000000000'; p_retMsg  := '成功';
     COMMIT; RETURN;   
END;
/
show errors