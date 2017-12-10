CREATE OR REPLACE PROCEDURE SP_AS_CARDPARKBLACKLIST
(
    P_FUNCCODE      VARCHAR2,
    P_PAPERNO       CHAR,
    p_currOper      char,
    p_currDept      char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    V_TODAY        DATE:=SYSDATE;
    V_EX           EXCEPTION;
/*
苏州园林黑名单加入与撤销存储过程
shil
20120926
*/
BEGIN
    IF P_FUNCCODE = 'ADDBLACKLIST' THEN
	--记录苏州园林年卡黑名单表，状态为有效
    BEGIN
        MERGE INTO TF_F_CARDPARKBLACKLIST USING DUAL
        ON (PAPERNO = P_PAPERNO)
        WHEN MATCHED THEN
            UPDATE SET 
            USETAG        = '1',
            UPDATESTAFFNO = p_currOper,
            UPDATETIME    = V_TODAY
        WHEN NOT MATCHED THEN
            INSERT 
              (PAPERNO,USETAG,UPDATESTAFFNO,UPDATETIME)
            VALUES
              (P_PAPERNO,'1',p_currOper,V_TODAY);

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570221'; p_retMsg  := '加入黑名单失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;    
    END IF;

    IF P_FUNCCODE = 'DELETEBLACKLIST' THEN
	--更新苏州园林年卡黑名单表记录为无效
    BEGIN
        UPDATE TF_F_CARDPARKBLACKLIST
        SET    USETAG        = '0',
               UPDATESTAFFNO = p_currOper,
               UPDATETIME    = V_TODAY
        WHERE  PAPERNO = P_PAPERNO;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570222'; p_retMsg  := '取消黑名单失败,' || SQLERRM;
        ROLLBACK; RETURN;		
    END;
    END IF;
	
    p_retCode := '0000000000'; p_retMsg  := '成功';
    COMMIT; RETURN;
END;
/
show errors