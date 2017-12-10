CREATE OR REPLACE PROCEDURE SP_GC_SZTCARDRELATION
(
    P_SESSIONID         VARCHAR2, --SESSIONID
    P_ORDERNO           CHAR,  --订单号
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS
    
    V_FROMCARDNO             CHAR(16);
    V_TOCARDNO             CHAR(16);
    V_CARDNO               CHAR(16);
    V_CARDNO2              CHAR(16);
    V_FROMCARD2               INT;
    V_TOCARD2                 INT;
    V_FROMCARD3               INT;
    V_TOCARD3                 INT;
    V_CHARGEVALUE             INT;
    V_NUM                     INT;
    V_CARDTYPECODE          CHAR(4);--卡片类型
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;
    V_COUNT              INT:=0; 
 
BEGIN
    FOR cur_data IN(SELECT * FROM tmp_order TMP WHERE TMP.F0 = P_SESSIONID)LOOP
        V_FROMCARDNO := cur_data.F1;
        V_TOCARDNO := cur_data.F2;
        V_CARDTYPECODE := cur_data.F3;
        V_NUM := cur_data.F4;
        --判断是否已有市民卡B卡被关联
        
      V_FROMCARD2 := TO_NUMBER(SUBSTR(V_FROMCARDNO,9,8));
      V_TOCARD2   := TO_NUMBER(SUBSTR(V_TOCARDNO,9,8));
         BEGIN
          LOOP
              V_CARDNO := SUBSTR(V_FROMCARDNO,0,8)||SUBSTR('00000000' || TO_CHAR(V_FROMCARD2), -8);
             SELECT COUNT(*) INTO V_COUNT
              FROM TF_F_SZTCARDRELATION 
                WHERE CARDNO = V_CARDNO;
                IF V_COUNT > 0 THEN
                   p_retCode := 'S094570345';
                   p_retMsg  := '市民卡B卡'||V_CARDNO||'已被关联';
                 ROLLBACK; RETURN;
                END IF;      
  
              EXIT WHEN  V_FROMCARD2  >=  V_TOCARD2;
  
              V_FROMCARD2 := V_FROMCARD2 + 1;
          END LOOP;
      EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S094570152'; p_retMsg  := '判断是否已有市民卡B卡被关联失败' || SQLERRM;
              ROLLBACK; RETURN;
      END;  
       
       
      V_FROMCARD3 := TO_NUMBER(SUBSTR(V_FROMCARDNO,9,8));
      V_TOCARD3   := TO_NUMBER(SUBSTR(V_TOCARDNO,9,8));  
     BEGIN
          LOOP
              V_CARDNO2 := SUBSTR(V_FROMCARDNO,0,8)||SUBSTR('00000000' || TO_CHAR(V_FROMCARD3), -8);
             INSERT INTO TF_F_SZTCARDRELATION(ORDERNO,CARDNO) VALUES (P_ORDERNO,V_CARDNO2);
            
              EXIT WHEN  V_FROMCARD3  >=  V_TOCARD3;
  
              V_FROMCARD3 := V_FROMCARD3 + 1;
          END LOOP;
      EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S094570153'; p_retMsg  := '记录市民卡B卡订单关系表失败' || SQLERRM;
              ROLLBACK; RETURN;
      END;   
         
        
        
      
        
         --修改市民卡B卡订单明细表
        BEGIN
            UPDATE TF_F_SZTCARDORDER
            SET    LEFTQTY = LEFTQTY - V_NUM
            WHERE  ORDERNO = P_ORDERNO
            AND    CARDTYPECODE =V_CARDTYPECODE
            AND    LEFTQTY > 0;
            
            IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570343';
            p_retMsg  := '更新市民卡B卡订单明细表失败,'|| SQLERRM;
            ROLLBACK; RETURN;
        END;       
       
    END LOOP;
    
    
   
    
    p_retCode := '0000000000'; 
    p_retMsg  := '成功';
    COMMIT; RETURN;    
END;
/
show errors;