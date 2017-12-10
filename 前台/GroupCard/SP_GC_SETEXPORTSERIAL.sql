create or replace procedure SP_GC_SETEXPORTSERIAL
(
    P_FUNCCODE     VARCHAR2,  --功能编码
    p_EXPORTDATE   char,      --导出日期
    p_currOper     char,           -- Current Operator
    p_currDept     char,           -- Curretn Operator's Department
    p_retCode      out char,       -- Return Code
    p_retMsg       out varchar2    -- Return Message
)
AS
    v_ex            EXCEPTION;
    V_SERIALNO      CHAR(4);
    V_NEWSERIALNO   CHAR(4);
BEGIN
    IF P_FUNCCODE = 'ADD' THEN
        BEGIN
            --记录导出序号编码表
            INSERT INTO TD_M_EXPORTSERIAL (EXPORTDATE,SERIALNO) VALUES(p_EXPORTDATE,'0001');
            IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
            P_RETCODE := 'S094570335';
            P_RETMSG  := '记录导出序号编码表失败,'||SQLERRM;      
            ROLLBACK; RETURN;         
        END;
    END IF;
    
    IF P_FUNCCODE = 'MODIFY' THEN
        BEGIN
            SELECT SERIALNO INTO V_SERIALNO FROM TD_M_EXPORTSERIAL WHERE EXPORTDATE = p_EXPORTDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            P_RETCODE := 'S094570336';
            P_RETMSG  := '未找到当天导出记录';      
            RETURN;     
        END;
        --计算新序列号
        V_NEWSERIALNO := SUBSTR('0000'||(V_SERIALNO + 1),-4);
        
        BEGIN
            --记录导出序号编码表
            UPDATE TD_M_EXPORTSERIAL 
            SET    SERIALNO = V_NEWSERIALNO
            WHERE EXPORTDATE = p_EXPORTDATE;
            IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
            P_RETCODE := 'S094570337';
            P_RETMSG  := '更新导出序号编码表失败,'||SQLERRM;      
            ROLLBACK; RETURN;         
        END;
    END IF;   
	
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;  	
END;

/
SHOW ERRORS