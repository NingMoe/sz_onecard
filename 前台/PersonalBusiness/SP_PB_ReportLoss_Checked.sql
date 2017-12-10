create or replace PROCEDURE sp_pb_reportloss_checked
(
    P_CARDNO                CHAR,         
    P_CARDNEWSTATE          CHAR,         
    P_RETCODE               OUT CHAR,     
    P_RETMSG                OUT VARCHAR2  
)
AS
    V_EXISTS          INT;
    P_CARDSTATE       CHAR(2); 
    V_EX              EXCEPTION;
    V_CUSTRECTYPECODE CHAR(1);
BEGIN
    BEGIN
    
    SELECT COUNT(CARDNO) INTO V_EXISTS FROM TF_F_CARDREC WHERE CARDNO=P_CARDNO;
    IF V_EXISTS = 0 THEN
       RAISE V_EX;
    END IF;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'A099001106';
              P_RETMSG  := '该卡号不存在' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    BEGIN
    
    SELECT CARDSTATE,CUSTRECTYPECODE INTO P_CARDSTATE,V_CUSTRECTYPECODE FROM TF_F_CARDREC WHERE CARDNO=P_CARDNO;
    
    IF P_CARDSTATE=P_CARDNEWSTATE THEN
       RAISE V_EX;
    ELSE
       
       IF P_CARDSTATE='03' AND P_CARDNEWSTATE='04' THEN
          RAISE V_EX;
       END IF;
    END IF;
    EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'A099001107';
              P_RETMSG  := '重复操作或者操作不合法' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    
    BEGIN
    
    IF V_CUSTRECTYPECODE!=1 THEN
       RAISE V_EX;
    END IF;
     EXCEPTION
          WHEN OTHERS THEN
              P_RETCODE := 'A099001108';
              P_RETMSG  := '非记名卡不能挂失解挂' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    
    P_RETCODE := '0000000000';
    P_RETMSG  := '';
    COMMIT; RETURN;
END;
/
SHOW ERRORS