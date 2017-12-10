create or replace procedure SP_RM_DOWNLOADKEYLOG
(
    P_FUNCCODE     VARCHAR2 , --功能编码
    P_ID           INT      ,--公私钥对索引
    p_currOper     char,           -- Current Operator
    p_currDept     char,           -- Curretn Operator's Department
    p_retCode      out char,       -- Return Code
    p_retMsg       out varchar2    -- Return Message
)
AS

    v_seqNo          CHAR(16);
    v_today         date:=sysdate;
    v_ex            EXCEPTION;

BEGIN

 SP_GetSeq(seq => v_seqNo); --生成流水号
    IF P_FUNCCODE = 'PUBLIC' THEN   
       
        BEGIN
       --记录公私钥操作台帐表(下载公钥)
        SP_GetSeq(seq => v_seqNo);
         INSERT INTO TF_B_PUBLICANDPRIVATEKEYLOG(
         TRADEID      ,STAFFNO    ,OPERTIME   ,ID       ,OPERTYPECODE 
         )VALUES(
            v_seqNo    ,P_CURROPER ,V_TODAY    ,P_ID    ,'02'
                      );
         IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002801';
            P_RETMSG  := '记录公私钥操作台帐表失败'||SQLERRM;
            ROLLBACK; RETURN;
       END;
    END IF;

    IF P_FUNCCODE = 'PRIVATE' THEN
         BEGIN
       --记录公私钥操作台帐表(下载私钥)
        SP_GetSeq(seq => v_seqNo);
         INSERT INTO TF_B_PUBLICANDPRIVATEKEYLOG(
         TRADEID      ,STAFFNO    ,OPERTIME   ,ID       ,OPERTYPECODE 
         )VALUES(
            v_seqNo    ,P_CURROPER ,V_TODAY    ,P_ID    ,'03'
                      );
         IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
            P_RETCODE := 'S001002802';
            P_RETMSG  := '记录公私钥操作台帐表失败'||SQLERRM;
            ROLLBACK; RETURN;
       END;
    END IF;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/
show errors
