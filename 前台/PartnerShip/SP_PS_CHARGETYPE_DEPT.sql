CREATE OR REPLACE PROCEDURE SP_PS_CHARGETYPE_DEPT
(
    P_FUNCCODE        VARCHAR2, --���ܱ���
    P_CHARGETYPECODE  VARCHAR2, --��ֵӪ��ģʽ����
    P_DEPTNO          CHAR, --���ű���
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    V_TODAY      DATE:=SYSDATE;
    V_COUNT      INT;
    V_EX         EXCEPTION;
/*
    �������ֵӪ��ģʽ��ϵά���洢����
    2012-12-12
    shil
    ���ο���
*/    
BEGIN
    --�����������ֵӪ��ģʽ��ϵ
    IF P_FUNCCODE = 'ADD' THEN
        SELECT COUNT(*) INTO V_COUNT 
        FROM TD_DEPT_CHARGETYPE a 
        WHERE a.CHARGETYPECODE = P_CHARGETYPECODE 
        AND a.DEPTNO = P_DEPTNO 
        AND a.USETAG = '1';
        
        IF V_COUNT > 0 THEN
            p_retCode := 'S094570252'; 
            p_retMsg  := '�˲������ֵӪ��ģʽ��ϵ�Ѵ���';
            RETURN;
        END IF;
        
        BEGIN
            MERGE INTO TD_DEPT_CHARGETYPE a USING DUAL
            ON(a.CHARGETYPECODE = P_CHARGETYPECODE AND a.DEPTNO = P_DEPTNO)
            WHEN MATCHED THEN UPDATE SET 
                USETAG = '1' ,
                UPDATESTAFFNO = P_CURROPER,
                UPDATETIME = V_TODAY
            WHEN NOT MATCHED THEN 
                INSERT(CHARGETYPECODE,DEPTNO,USETAG,UPDATESTAFFNO,UPDATETIME)
                VALUES(P_CHARGETYPECODE,P_DEPTNO,'1',P_CURROPER,V_TODAY);
                
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570253'; 
            p_retMsg  := '�����������ֵӪ��ģʽ��ϵʧ��,' || SQLERRM;
            ROLLBACK; RETURN;
        END;
    END IF;
    
    --ɾ���������ֵӪ��ģʽ��ϵ
    IF P_FUNCCODE = 'DELETE' THEN
        BEGIN
            UPDATE TD_DEPT_CHARGETYPE
            SET    USETAG = '0' , 
                   UPDATESTAFFNO = P_CURROPER,
                   UPDATETIME = V_TODAY
            WHERE  CHARGETYPECODE = P_CHARGETYPECODE 
            AND    DEPTNO = P_DEPTNO 
            AND    USETAG = '1';
            
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570254'; 
            p_retMsg  := 'ɾ���������ֵӪ��ģʽ��ϵʧ��,' || SQLERRM;
            ROLLBACK; RETURN;            
        END;
    END IF;
    
    p_retCode := '0000000000';
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;  
END;

/
show errors
