CREATE OR REPLACE PROCEDURE SP_GC_CASHGIFTCARDRELATION
(
    P_SESSIONID         VARCHAR2, --SESSIONID
    P_ORDERNO           CHAR,  --订单号
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

        
        --判断是否已有利金卡被关联
        SELECT COUNT(*) INTO V_COUNT
        FROM TF_F_CASHGIFTRELATION 
        WHERE CARDNO = V_CARDNO;
         
        IF V_COUNT > 0 THEN
           
            p_retCode := 'S094570345';
            p_retMsg  := '利金卡'||V_CARDNO||'已被关联,关联的利金卡中存在已被关联的利金卡';
             ROLLBACK; RETURN;
        END IF;      
        
        ---记录利金卡订单关系表
        BEGIN
            INSERT INTO TF_F_CASHGIFTRELATION(ORDERNO,CARDNO)
            VALUES (P_ORDERNO,V_CARDNO);
            
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570346';
            p_retMsg  := '记录利金卡订单关系表失败,'|| SQLERRM;
            ROLLBACK; RETURN;           
        END; 
        
         --修改利金卡订单明细表
        BEGIN
            UPDATE TF_F_CASHGIFTORDER
            SET    LEFTQTY = LEFTQTY - 1
            WHERE  ORDERNO = P_ORDERNO
            AND    VALUE = V_PRICE*100.0
            AND    LEFTQTY > 0;
            
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570343';
            p_retMsg  := '更新利金卡订单明细表失败,'|| SQLERRM;
            ROLLBACK; RETURN;
        END;       
       
    END LOOP;
    
    
   
    
    p_retCode := '0000000000'; 
    p_retMsg  := '成功';
    COMMIT; RETURN;    
END;
/
show errors;