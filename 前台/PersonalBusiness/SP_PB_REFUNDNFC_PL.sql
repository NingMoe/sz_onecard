CREATE OR REPLACE PROCEDURE SP_PB_REFUNDNFC
(
    p_SESSIONID  varchar2, -- Session ID
    p_STATE char, -- '1'  Approved, '2' Rejected
    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_quantity      INT;
    v_ex            EXCEPTION;
    v_TRADEID       VARCHAR2(32);
    v_statecode     char(1);
    v_CARDNO         CHAR(16);
    v_TRADECODE     char(1);
    v_seqNo        char(16);

BEGIN
    --判断是否有数据需要处理
    SELECT COUNT(*) INTO v_quantity FROM TMP_COMMON WHERE f1 = p_SESSIONID;
    IF v_quantity is null or v_quantity <= 0 THEN
        p_retCode := 'A004P01001'; p_retMsg  := '没有任何数据需要处理';
        RETURN;
    END IF;
    


  BEGIN
    FOR V_CUR IN (SELECT f0 FROM TMP_COMMON WHERE f1 = p_sessionId)
    LOOP
    v_TRADEID:=V_CUR.f0;
    --查询退款状态
    SELECT REFUNDSTATUS,CARDNO INTO v_statecode,v_CARDNO FROM TF_SUPPLY_REFUND WHERE TRADEID  = v_TRADEID ;

    IF  p_STATE='1' THEN

      v_TRADECODE:='1';
      --如果有允许退款的记录
        IF v_statecode = '1' THEN
            p_retCode := 'S094570231';
            p_retMsg :=V_CUR.f0||'充值交易流水已经允许退款,不可以再次操作' ;
        RETURN;
        END IF;

    END IF;

    IF p_STATE='2'  THEN

       v_TRADECODE:='2';
        --如果有不允许退款的记录
        IF v_statecode = '2' THEN
            p_retCode := 'S094570232';
           p_retMsg :=V_CUR.f0||'充值交易流水已经不允许退款,不可以再次操作' ;
       RETURN;
        END IF;
    END IF;

		 --更新充值退款表        
    BEGIN
        UPDATE TF_SUPPLY_REFUND
        SET    REFUNDSTATUS     = p_STATE,
               CHECKSTAFF       = p_currOper,
               CHECKTIME        = v_today
        WHERE  REFUNDSTATUS     = v_statecode
        AND    TRADEID =v_TRADEID;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P03B02'; p_retMsg  := '更新充值退款表失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
   --生成流水号
    SP_GetSeq(seq => v_seqNo); 
		  --记录退款审核操作台帐表
    BEGIN
        INSERT INTO TF_F_REFUNDTRADE(ID,TRADEID, CARDNO, TRADECODE, PRESTATE, UPDATESTAFFNO,UPDATEDEPARTID, UPDATETIME)
        VALUES(v_seqNo,v_TRADEID,v_CARDNO,v_TRADECODE,v_statecode, p_currOper    ,p_currDept, V_TODAY);
        
        IF  SQL%ROWCOUNT !=1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P03B03'; p_retMsg  := '记录退款审核操作台帐表失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

		
		
		
		END LOOP;
		
   		
		
	END;
    
 
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors
