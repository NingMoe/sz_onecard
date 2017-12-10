create or replace procedure SP_GC_SETEXPORTSERIAL
(
    P_FUNCCODE     VARCHAR2,  --���ܱ���
    p_EXPORTDATE   char,      --��������
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
            --��¼������ű����
            INSERT INTO TD_M_EXPORTSERIAL (EXPORTDATE,SERIALNO) VALUES(p_EXPORTDATE,'0001');
            IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
            P_RETCODE := 'S094570335';
            P_RETMSG  := '��¼������ű����ʧ��,'||SQLERRM;      
            ROLLBACK; RETURN;         
        END;
    END IF;
    
    IF P_FUNCCODE = 'MODIFY' THEN
        BEGIN
            SELECT SERIALNO INTO V_SERIALNO FROM TD_M_EXPORTSERIAL WHERE EXPORTDATE = p_EXPORTDATE;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
            P_RETCODE := 'S094570336';
            P_RETMSG  := 'δ�ҵ����쵼����¼';      
            RETURN;     
        END;
        --���������к�
        V_NEWSERIALNO := SUBSTR('0000'||(V_SERIALNO + 1),-4);
        
        BEGIN
            --��¼������ű����
            UPDATE TD_M_EXPORTSERIAL 
            SET    SERIALNO = V_NEWSERIALNO
            WHERE EXPORTDATE = p_EXPORTDATE;
            IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
            P_RETCODE := 'S094570337';
            P_RETMSG  := '���µ�����ű����ʧ��,'||SQLERRM;      
            ROLLBACK; RETURN;         
        END;
    END IF;   
	
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;  	
END;

/
SHOW ERRORS