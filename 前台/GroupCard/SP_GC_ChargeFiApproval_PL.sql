CREATE OR REPLACE PROCEDURE SP_GC_ChargeFiApproval
(
    p_sessionId  varchar2, -- Session ID
    p_stateCode char, -- '2' Fi Approved, '3' Rejected
    p_currOper  char, -- Current Operator
    p_currDept  char, -- Current Operator's Department
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_amount        INT;
    v_quantity      int;
    v_ex            EXCEPTION;
    v_count         int  := 0;

BEGIN

    -- 1) Check the state code 
    IF NOT (p_stateCode = '2' OR p_stateCode = '3') THEN
        p_retCode := 'A004P06B01'; p_retMsg  := '状态码必须是''2'' (财务已审核) 或 ''3'' (作废)';
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_quantity FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId;
    IF v_quantity is null or v_quantity <= 0 THEN
        p_retCode := 'A004P04B01'; p_retMsg  := '没有任何企服卡充值数据需要处理';
        RETURN;
    END IF;
    
    -- 2) Update the master tracing record
    BEGIN
        UPDATE TF_GROUP_SUPPLYSUM
        SET    EXAMSTAFFNO   = p_currOper ,
               EXAMTIME      = v_today ,
               STATECODE     = p_stateCode
        WHERE  STATECODE     = '1'
        AND    ID IN 
            (SELECT BatchNo FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId);

        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;            
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P06B02'; p_retMsg  := '更新企服卡充值总量台帐失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
            
    SELECT  sum(AMOUNT) INTO v_amount FROM TF_GROUP_SUPPLYSUM
    WHERE   ID IN (SELECT BatchNo FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId);

    -- 3) Update the finance detail records' state
    BEGIN
        UPDATE TF_GROUP_SUPPLYCHECK
        SET    STATECODE      = p_stateCode,
               OPERATESTAFFNO = p_currOper ,
               OPERATEDEPARTID= p_currDept ,
               OPERATETIME    = v_today
        WHERE  ID IN 
            (SELECT BatchNo FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId)
        AND    STATECODE     = '1';
        
        IF  SQL%ROWCOUNT != v_amount THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P06B03'; p_retMsg  := '更新企服卡财务充值明细失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    

    IF p_stateCode = '3' THEN  -- Rejected By Finance
        BEGIN
            UPDATE TF_GROUP_SUPPLY
            SET    STATECODE      = p_stateCode    ,
                   OPERATESTAFFNO = p_currOper,
                   OPERATEDEPARTID= p_currDept ,
                   OPERATETIME    = v_today
            WHERE  ID IN 
                (SELECT BatchNo FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId)
            AND    STATECODE     = '1';
                
            IF  SQL%ROWCOUNT != v_amount THEN RAISE v_ex; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S004P06B04'; p_retMsg  := '更新企服卡充值明细失败,' || SQLERRM;
                ROLLBACK; RETURN;
        END;
    ELSE  -- Approved, update the accounts' balance
        BEGIN
            v_count := 0;
            
            MERGE INTO TF_GROUP_SUPPLYCHECK fi
            USING      TF_F_CARDOFFERACC    t
            ON         (fi.CARDNO = t.CARDNO and  fi.ID IN 
                    (SELECT BatchNo FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId))
            when matched then
                update SET    fi.PREOFFERMONEY = t.OFFERMONEY;
            
            IF  SQL%ROWCOUNT != v_amount THEN RAISE v_ex; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S004P06B04'; p_retMsg  := '更新企服卡充值明细失败,' || SQLERRM;
                ROLLBACK; RETURN;
        END;
       
        BEGIN        
            FOR v_cursor IN (
                SELECT fi.CARDNO, fi.SUPPLYMONEY offerMoney
                FROM   TF_GROUP_SUPPLYCHECK fi
                WHERE  fi.ID IN 
                    (SELECT BatchNo FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId)
            )
            LOOP   
				--充值后账户余额小于0，则不能提交
				BEGIN
					select t.OFFERMONEY+v_cursor.offerMoney 
					into v_quantity   
					from TF_F_CARDOFFERACC t  
					where t.cardno=v_cursor.CardNo
					and usetag in ('1','2');
					if v_quantity<0 THEN
					p_retCode := 'SWDXP04B03'; p_retMsg  :=v_cursor.cardno|| '充值后企服卡账户余额小于0';
					ROLLBACK; RETURN;
					end if;
				EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'SWDXP05BX1'; p_retMsg  := v_cursor.CardNo||'企服卡账户不存在' || SQLERRM;
				ROLLBACK; RETURN;
				END;
				
                UPDATE TF_F_CARDOFFERACC t
                SET    t.OFFERMONEY = t.OFFERMONEY + v_cursor.offerMoney
                WHERE  t.CARDNO = v_cursor.CARDNO
                	AND  t.USETAG in( '1','2');
                
                v_count := v_count + SQL%ROWCOUNT ;
            END LOOP;
            
            IF  v_count != v_amount THEN RAISE v_ex; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S004P06B05'; p_retMsg  := '更新企服卡可充值帐户失败,' || SQLERRM;
                ROLLBACK; RETURN;
        END;
    END IF;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors
