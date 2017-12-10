CREATE OR REPLACE PROCEDURE SP_PS_CHARGETYPE
(
    P_FUNCCODE        VARCHAR2, --功能编码
    P_CHARGETYPECODE  VARCHAR2, --充值营销模式编码
    P_CHARGETYPENAME  VARCHAR2, --充值营销模式名称
    P_CHARGETYPESTATE VARCHAR2, --充值营销模式说明
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    V_TODAY      DATE:=SYSDATE;
    V_EX         EXCEPTION;
/*
    充值营销模式维护存储过程
    2012-12-12
    shil
    初次开发
*/    
BEGIN    
    --新增充值营销模式
    IF P_FUNCCODE = 'ADD' THEN
        BEGIN
            INSERT INTO TD_M_CHARGETYPE
            (CHARGETYPECODE,CHARGETYPENAME,CHARGETYPESTATE,USETAG,UPDATESTAFFNO,UPDATETIME)
            VALUES
            (TD_M_CHARGETYPE_SEQ.NEXTVAL, P_CHARGETYPENAME,P_CHARGETYPESTATE,'1',P_CURROPER,V_TODAY);
                
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570255'; 
            p_retMsg  := '新增充值营销模式失败,' || SQLERRM;
            ROLLBACK; RETURN;
        END;
    END IF;
    
    --删除充值营销模式
    IF P_FUNCCODE = 'DELETE' THEN
        BEGIN
            UPDATE TD_M_CHARGETYPE
            SET    USETAG = '0' , 
                   UPDATESTAFFNO = P_CURROPER,
                   UPDATETIME = V_TODAY
            WHERE  CHARGETYPECODE = P_CHARGETYPECODE 
            AND    USETAG = '1';
            
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570256'; 
            p_retMsg  := '删除充值营销模式失败,' || SQLERRM;
            ROLLBACK; RETURN;            
        END;
    END IF;
    
    p_retCode := '0000000000';
    p_retMsg  := '成功';
    COMMIT; RETURN;  
END;

/
show errors
