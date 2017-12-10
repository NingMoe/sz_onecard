CREATE OR REPLACE PROCEDURE SP_UC_DepositChange
(
	p_fromCardNo CHAR, -- From Card No. 
    p_toCardNo   CHAR, -- End  Card No. 
    p_unitPrice  INT , -- Card Unit Price 
    p_currOper   CHAR, -- Current Operator 
    p_currDept   CHAR, -- Curretn Operator's Department 
    p_retCode OUT CHAR, -- Return Code 
    p_retMsg  OUT VARCHAR2
)
AS
	v_fromCard NUMERIC(16);
	v_toCard   NUMERIC(16);
	v_quantity INT;
	v_exist    INT := 0;
	v_today    date := sysdate;
	v_seqNo    CHAR(16);  
	v_ex       exception;
BEGIN
    -- 1) Check card resstate  
    SELECT count(*) INTO v_exist FROM  TL_R_ICUSER 
    WHERE CARDNO BETWEEN p_fromCardNo AND p_toCardNo AND (RESSTATECODE = '01' or RESSTATECODE = '00');
    
    v_fromCard := TO_NUMBER(p_fromCardNo);
    v_toCard   := TO_NUMBER(p_toCardNo);
    v_quantity := v_toCard - v_fromCard + 1;
    
    IF v_quantity != v_exist THEN
        p_retCode := 'A002P01B04'; 
        p_retMsg  := '已有卡片不是出库状态';
        RETURN;
    END IF;
    
    -- 2) Change cardprice
    BEGIN
        UPDATE TL_R_ICUSER SET CARDPRICE = p_unitPrice,UPDATESTAFFNO = p_currOper,UPDATETIME = v_today
        WHERE CARDNO BETWEEN p_fromCardNo AND p_toCardNo;
        
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P03B01'; p_retMsg  := '更新用户卡库存信息失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    -- 3) lOg this operation
    SP_GetSeq(seq => v_seqNo);
    
    BEGIN
        INSERT INTO TF_R_ICUSERTRADE
            (TRADEID,OPETYPECODE,BEGINCARDNO,ENDCARDNO,CARDPRICE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
            (v_seqNo,'KA',p_fromCardNo,p_toCardNo,p_unitPrice,p_currOper,p_currDept,v_today);
            
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P03B03'; 
            p_retMsg  := '向用户卡操作台帐表插入记录失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors