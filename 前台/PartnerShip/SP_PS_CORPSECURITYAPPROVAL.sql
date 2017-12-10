CREATE OR REPLACE PROCEDURE SP_PS_CORPSECURITYAPPROVAL
(
    P_FUNCCODE              VARCHAR2 ,
    P_CORPNO                CHAR     ,--商户编码
    P_APPCALLINGNO          CHAR     ,--应用行业编码
    P_REGISTEREDCAPITAL     INT      ,--注册资金
    P_SECURITYVALUE         INT      ,--安全值
    P_CURROPER              CHAR     ,
    P_CURRDEPT              CHAR     ,
    P_RETCODE           OUT CHAR     ,
    P_RETMSG            OUT VARCHAR2 
)
AS
    V_FUNCCODE        VARCHAR2(16) := P_FUNCCODE ;
    V_TODAY           DATE         := SYSDATE    ;
    V_QUANTITY        INT                        ;
    v_tradeID       CHAR(16);
    V_EXITTRADEID   CHAR(16);
    V_EX              EXCEPTION                  ;
    V_COUNT           INT;
BEGIN
SP_GetSeq(seq => v_tradeID); --生成流水号
        -- 添加
        IF V_FUNCCODE = 'ADD' THEN
        
            --查询是否存在此商户的安全值审核信息
           SELECT  COUNT(*) INTO V_QUANTITY
           FROM   TF_F_CORPSECURITYAPPROVAL
           WHERE  CORPNO = P_CORPNO
           AND    ISVALID = '1';
           
       IF V_QUANTITY > 0 THEN
        P_RETCODE := 'A001002100';
        P_RETMSG  := '已有此商户的安全值审核信息存在于库中,如果需要修改安全值,请点击修改按钮';
        ROLLBACK; RETURN;
       END IF;
       
      IF V_QUANTITY <1 THEN     
          
        --插入商户安全值审核表
        BEGIN
            
            --APPROVESTATE为0是待审核状态,1是审核通过状态;ISVALID为1是有效,0是无效
            INSERT INTO TF_F_CORPSECURITYAPPROVAL(
            ID              , CORPNO              , APPROVESTATE     , ISVALID       ,
            SECURITYVALUE   ,REGISTEREDCAPITAL    , APPCALLINGNO        ,OPERATOR     ,
             OPERDEPT       , OPERATETIME         
            )VALUES(
            v_tradeID       , P_CORPNO            , '0'              , '1'           ,
            P_SECURITYVALUE , P_REGISTEREDCAPITAL , P_APPCALLINGNO   , P_CURROPER    ,
            P_CURRDEPT      ,V_TODAY          
            );
        EXCEPTION WHEN OTHERS THEN
            P_RETCODE := 'S004102001' ;
            P_RETMSG  := '插入商户安全值审核表失败,'||SQLERRM ;
        ROLLBACK;RETURN;
        END;
        END IF;
       END IF;

     
     --修改
     IF V_FUNCCODE = 'MODIFY' THEN
    

      --查询是否存在此商户的安全值待审核信息
       SELECT  COUNT(*) INTO V_COUNT
       FROM   TF_F_CORPSECURITYAPPROVAL
       WHERE  CORPNO = P_CORPNO
       AND    ISVALID = '1'
       AND    APPROVESTATE='0';
       
       IF V_COUNT > 1 THEN
        P_RETCODE := 'A001002101';
        P_RETMSG  := '此商户的安全值待审核审核信息在库中有重复';
        RETURN;
       END IF;
       
       IF V_COUNT=1  THEN 
         SELECT ID INTO V_EXITTRADEID  FROM   TF_F_CORPSECURITYAPPROVAL 
         WHERE  CORPNO = P_CORPNO
         AND    ISVALID = '1'
         AND    APPROVESTATE='0'; 
       
        BEGIN
         UPDATE  TF_F_CORPSECURITYAPPROVAL tmb
        SET     tmb.SECURITYVALUE    = P_SECURITYVALUE      ,
                tmb.operator         = p_curroper           ,
                tmb.operdept         = p_currdept           ,
                tmb.operatetime      = v_today
        WHERE   tmb.ID          = V_EXITTRADEID   ;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE :=  'S004102002';
        P_RETMSG  := '更新商户安全值审核表失败' || SQLERRM;
        ROLLBACK; RETURN;
     END;
     END IF;
     
     IF V_COUNT<1  THEN 
     
      --插入商户安全值审核表
        BEGIN
            
            --APPROVESTATE为0是待审核状态,1是审核通过状态;ISVALID为1是有效,0是无效
            INSERT INTO TF_F_CORPSECURITYAPPROVAL(
            ID              , CORPNO              , APPROVESTATE     , ISVALID       ,
            SECURITYVALUE   ,REGISTEREDCAPITAL    , APPCALLINGNO        ,OPERATOR     ,
             OPERDEPT       , OPERATETIME         
            )VALUES(
            v_tradeID       , P_CORPNO            , '0'              , '1'           ,
            P_SECURITYVALUE , P_REGISTEREDCAPITAL , P_APPCALLINGNO   , P_CURROPER    ,
            P_CURRDEPT      ,V_TODAY          
            );
        EXCEPTION WHEN OTHERS THEN
            P_RETCODE := 'S004102003' ;
            P_RETMSG  := '插入购卡个人安全值审核表失败,'||SQLERRM ;
        ROLLBACK;RETURN;
        END;
      END IF;
     
     
   END IF;
      
     
     
     
     p_retCode := '0000000000'; p_retMsg  := '成功';
     COMMIT; RETURN;   
END;
/
show errors;