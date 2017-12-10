CREATE OR REPLACE PROCEDURE SP_RM_CREATEKEY
(
    P_PUBLICKEY              VARCHAR ,
    P_PRIVATEKEY             VARCHAR,
    P_CURROPER              CHAR     ,
    P_CURRDEPT              CHAR     ,
    P_RETCODE           OUT CHAR     ,
    P_RETMSG            OUT VARCHAR2 
)
AS
    v_seqNo              CHAR(16); --业务流水号
    V_COUNT           INT;          --数量
    V_ID              INT;
    V_TODAY           DATE         := SYSDATE    ;
    V_EX              EXCEPTION                  ;

BEGIN
        
      
    BEGIN
      --参数赋值
      SELECT COUNT(*) INTO V_COUNT FROM TD_M_PUBLICANDPRIVATEKEY ;  
      IF V_COUNT <1 THEN  
        V_ID:=0;
      ELSE
        V_ID:=V_COUNT+1;
      END IF;
    END;
     
      BEGIN
      
        --记录公私钥维护表
        INSERT INTO TD_M_PUBLICANDPRIVATEKEY(
            ID            , PUBLICKEY    , PRIVATEKEY   , OPERATESTAFFNO    ,OPERATEDEPTID      ,OPERATETIME
       )VALUES(
            V_ID          , P_PUBLICKEY  , P_PRIVATEKEY , P_CURROPER        ,p_CURRDEPT        ,V_TODAY 
            );
          
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION
        WHEN OTHERS THEN
              p_retCode := 'S094570157'; p_retMsg  := '记录公私钥维护表失败' || SQLERRM;
              ROLLBACK; RETURN;              
       END;        
     
       BEGIN
       --记录公私钥操作台帐表
        SP_GetSeq(seq => v_seqNo);
         INSERT INTO TF_B_PUBLICANDPRIVATEKEYLOG(
         TRADEID      ,STAFFNO    ,OPERTIME   ,ID       ,OPERTYPECODE 
         )VALUES(
            v_seqNo    ,P_CURROPER ,V_TODAY    ,V_ID    ,'00'
                      );
       END;
 
     
     p_retCode := '0000000000'; p_retMsg  := '成功';
     COMMIT; RETURN;   
END;
/
show errors