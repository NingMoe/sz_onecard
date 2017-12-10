CREATE OR REPLACE PROCEDURE SP_PS_CHARGETYPE
(
    P_FUNCCODE        VARCHAR2, --���ܱ���
    P_CHARGETYPECODE  VARCHAR2, --��ֵӪ��ģʽ����
    P_CHARGETYPENAME  VARCHAR2, --��ֵӪ��ģʽ����
    P_CHARGETYPESTATE VARCHAR2, --��ֵӪ��ģʽ˵��
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    V_TODAY      DATE:=SYSDATE;
    V_EX         EXCEPTION;
/*
    ��ֵӪ��ģʽά���洢����
    2012-12-12
    shil
    ���ο���
*/    
BEGIN    
    --������ֵӪ��ģʽ
    IF P_FUNCCODE = 'ADD' THEN
        BEGIN
            INSERT INTO TD_M_CHARGETYPE
            (CHARGETYPECODE,CHARGETYPENAME,CHARGETYPESTATE,USETAG,UPDATESTAFFNO,UPDATETIME)
            VALUES
            (TD_M_CHARGETYPE_SEQ.NEXTVAL, P_CHARGETYPENAME,P_CHARGETYPESTATE,'1',P_CURROPER,V_TODAY);
                
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570255'; 
            p_retMsg  := '������ֵӪ��ģʽʧ��,' || SQLERRM;
            ROLLBACK; RETURN;
        END;
    END IF;
    
    --ɾ����ֵӪ��ģʽ
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
            p_retMsg  := 'ɾ����ֵӪ��ģʽʧ��,' || SQLERRM;
            ROLLBACK; RETURN;            
        END;
    END IF;
    
    p_retCode := '0000000000';
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;  
END;

/
show errors
