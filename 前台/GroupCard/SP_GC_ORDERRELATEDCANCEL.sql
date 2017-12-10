CREATE OR REPLACE PROCEDURE SP_GC_ORDERRELATEDCANCEL
(
    p_ORDERNO           CHAR,  --订单号
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS
    v_seqNo               CHAR(16); --业务流水号
    V_ORDERSTATE          CHAR(2);
    V_CASHGIFTMONEY       INT;
    V_SZTCARDMONEY        INT;
    V_COUNT               INT;
    V_NUM                 INT;
    V_CASHORDERNUM        INT;
    V_SZTORDERNUM         INT;
    V_EX                  EXCEPTION;
    V_TODAY               DATE := SYSDATE;
BEGIN
       
    --判断订单状态是否是领卡补关联完成
    SELECT A.ORDERSTATE,NVL(A.CASHGIFTMONEY,0),NVL(A.SZTCARDMONEY,0) INTO V_ORDERSTATE,V_CASHGIFTMONEY,V_SZTCARDMONEY
    FROM TF_F_ORDERFORM A 
    WHERE A.ORDERNO = p_ORDERNO 
    AND  A.ISRELATED='0';
    
    
    --如果订单状态不是领卡补关联完成
    IF V_ORDERSTATE <> '10' THEN
        p_retCode := 'S094570333';
        p_retMsg  := '订单状态不是领卡补关联完成状态,'|| SQLERRM;
        RETURN;  
    END IF;    
    
    IF V_CASHGIFTMONEY>0 THEN
       --判断是否有利金卡被关联的信息
        SELECT COUNT(*) INTO V_COUNT
        FROM TF_F_CASHGIFTRELATION 
        WHERE ORDERNO = P_ORDERNO ;
         
        IF V_COUNT > 0 THEN
        
          BEGIN
            delete from TF_F_CASHGIFTRELATION WHERE ORDERNO = P_ORDERNO ;
          IF  SQL%ROWCOUNT != V_COUNT then raise v_ex; end IF;
            p_retCode := 'S094570334';
            p_retMsg  := '删除利金卡订单关系表失败';
             ROLLBACK; RETURN;
           END;
        END IF;  
        
        
          --修改利金卡订单明细表
          SELECT COUNT(*) INTO V_CASHORDERNUM FROM TF_F_CASHGIFTORDER  WHERE ORDERNO = P_ORDERNO ;
          
          IF V_CASHORDERNUM>0 THEN
          BEGIN
        
            UPDATE TF_F_CASHGIFTORDER T
            SET    T.LEFTQTY = T.COUNT
            WHERE  T.ORDERNO = P_ORDERNO
            AND    T.LEFTQTY = 0;
            
            IF SQL%ROWCOUNT != V_CASHORDERNUM THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570335';
            p_retMsg  := '更新利金卡订单明细表失败,'|| SQLERRM;
            ROLLBACK; RETURN;
        END;
      END IF;      
        
            
    END IF;
    
    IF V_SZTCARDMONEY>0 THEN
      --判断是否有市民卡B卡被关联的信息
        SELECT COUNT(*) INTO V_NUM
        FROM TF_F_SZTCARDRELATION 
        WHERE ORDERNO = P_ORDERNO ;
         
        IF V_NUM > 0 THEN
        
          BEGIN
            delete from TF_F_SZTCARDRELATION WHERE ORDERNO = P_ORDERNO ;
          IF  SQL%ROWCOUNT != V_NUM then raise v_ex; end IF;
          EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570336';
            p_retMsg  := '删除市民卡B卡订单关系表失败';
             ROLLBACK; RETURN;
           END;
        END IF;  
           
            --修改市民卡B卡订单明细表
          SELECT COUNT(*) INTO V_SZTORDERNUM FROM TF_F_SZTCARDORDER  WHERE ORDERNO = P_ORDERNO ;
          
          IF V_SZTORDERNUM>0 THEN
          BEGIN
        
            UPDATE TF_F_SZTCARDORDER T
            SET    T.LEFTQTY = T.COUNT
            WHERE  T.ORDERNO = P_ORDERNO
            AND    T.LEFTQTY = 0;
            
            IF SQL%ROWCOUNT != V_SZTORDERNUM THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570337';
            p_retMsg  := '更新市民卡B卡订单明细表失败,'|| SQLERRM;
            ROLLBACK; RETURN;
        END;
      END IF;      
            
    END IF;
    
    --更新订单表
    BEGIN
        UPDATE TF_F_ORDERFORM
        SET    ORDERSTATE = '07', -- 领用完成
               UPDATEDEPARTNO = p_currDept,
               UPDATESTAFFNO = p_currOper,
               UPDATETIME = V_TODAY
        WHERE  ORDERNO = p_ORDERNO
        AND    ISRELATED = '0'; --不关联
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570338';
        p_retMsg  := '更新订单表失败,'|| SQLERRM;
        ROLLBACK; RETURN;
    END;
    
    --生成流水号
    SP_GetSeq(seq => v_seqNo);        
    
    --记录订单台账表('16'取消领卡补关联)
    BEGIN
        INSERT INTO TF_F_ORDERTRADE(
            TRADEID         , ORDERNO        , TRADECODE    , 
            OPERATEDEPARTNO , OPERATESTAFFNO , OPERATETIME
        )SELECT 
            v_seqNo         , p_ORDERNO      , '16'         , 
            p_currDept      , p_currOper     , V_TODAY
        FROM TF_F_ORDERFORM 
        WHERE ORDERNO = p_ORDERNO
        ;    
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570339';
        p_retMsg  := '记录订单台账表失败,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;    
    
    p_retCode := '0000000000'; 
    p_retMsg  := '成功';
    COMMIT; RETURN;    
END;
/
show errors;
