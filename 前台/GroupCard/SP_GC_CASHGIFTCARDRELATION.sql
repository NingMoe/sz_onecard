CREATE OR REPLACE PROCEDURE SP_GC_CASHGIFTCARDRELATION
(
    P_SESSIONID         VARCHAR2, --SESSIONID
    P_ORDERNO           CHAR,  --������
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS
    
    V_CARDNO             CHAR(16);
    V_PRICE              INT;
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;
    V_COUNT              INT:=0; 
 
BEGIN
    FOR cur_data IN(SELECT * FROM tmp_order TMP WHERE TMP.F0 = P_SESSIONID)LOOP
        V_CARDNO := cur_data.F1;
        V_PRICE :=cur_data.F2;

        
        --�ж��Ƿ��������𿨱�����
        SELECT COUNT(*) INTO V_COUNT
        FROM TF_F_CASHGIFTRELATION 
        WHERE CARDNO = V_CARDNO;
         
        IF V_COUNT > 0 THEN
           
            p_retCode := 'S094570345';
            p_retMsg  := '����'||V_CARDNO||'�ѱ�����,�����������д����ѱ�����������';
             ROLLBACK; RETURN;
        END IF;      
        
        ---��¼���𿨶�����ϵ��
        BEGIN
            INSERT INTO TF_F_CASHGIFTRELATION(ORDERNO,CARDNO)
            VALUES (P_ORDERNO,V_CARDNO);
            
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570346';
            p_retMsg  := '��¼���𿨶�����ϵ��ʧ��,'|| SQLERRM;
            ROLLBACK; RETURN;           
        END; 
        
         --�޸����𿨶�����ϸ��
        BEGIN
            UPDATE TF_F_CASHGIFTORDER
            SET    LEFTQTY = LEFTQTY - 1
            WHERE  ORDERNO = P_ORDERNO
            AND    VALUE = V_PRICE*100.0
            AND    LEFTQTY > 0;
            
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570343';
            p_retMsg  := '�������𿨶�����ϸ��ʧ��,'|| SQLERRM;
            ROLLBACK; RETURN;
        END;       
       
    END LOOP;
    
    
   
    
    p_retCode := '0000000000'; 
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;    
END;
/
show errors;