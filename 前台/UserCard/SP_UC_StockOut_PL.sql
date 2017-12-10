CREATE OR REPLACE PROCEDURE SP_UC_StockOut
(
    p_fromCardNo    char, -- From Card No.
    p_toCardNo      char, -- End  Card No.
    p_assignedStaff char, -- Assigned Staff No
    p_serviceCycle  char, -- Service Cycle Type
    p_serviceFee    int , -- Service Fee per Service Cycle
    p_retValMode    char, -- Value-Return Mode, like 'Return All' or 'No return'
    P_CARDPRICE     int , -- 代理营业厅领卡卡价值
    p_currOper      char, -- Current Operator
    p_currDept      char, -- Curretn Operator's Department
    
	p_saleType		  char, -- sale card type -- add by jiangbb 2012-05-10
    
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message
)
AS
    v_assignedDept  char(4); -- Assigned Staff's Department    
    v_fromCard      numeric(16);
    v_toCard        numeric(16);
    v_cardNo        char(16);
    v_quantity      int;
    v_dbquantity    int;
    v_today         date := sysdate;
    v_ex            EXCEPTION;
	  v_seqNo         CHAR(16);  
BEGIN
    -- 1) tell the consistence of v_quantity 
    v_fromCard := TO_NUMBER(p_fromCardNo);
    v_toCard   := TO_NUMBER(p_toCardNo);
    v_quantity := v_toCard - v_fromCard + 1;

    BEGIN
        SELECT DEPARTNO INTO v_assignedDept
            FROM  TD_M_INSIDESTAFF
            WHERE STAFFNO = p_assignedStaff;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'A002P04D02'; p_retMsg  := '无法得到分配员工所在的部门编码' || SQLERRM;
            RETURN;
    END;


    SELECT COUNT(*) INTO v_dbquantity
    FROM TL_R_ICUSER
    WHERE CARDNO BETWEEN p_fromCardNo AND p_toCardNo
    AND   RESSTATECODE = '00';  -- IN STOCKIN
    IF v_quantity != v_dbquantity THEN
        p_retCode := 'A002P02B01'; p_retMsg  := '已有卡片不在库';
        RETURN; 
    END IF;    

    -- 2) update the ic card stock table
    BEGIN
        UPDATE  TL_R_ICUSER
        SET UPDATETIME       = v_today     ,
            UPDATESTAFFNO    = p_currOper     ,
            ASSIGNEDSTAFFNO  = p_assignedStaff,
            ASSIGNEDDEPARTID = v_assignedDept ,
            SERVICECYCLE     = p_serviceCycle ,
            EVESERVICEPRICE  = p_serviceFee   ,
            RESSTATECODE     = '01',   -- stockout
            OUTTIME          = v_today,
            SALETYPE         = p_saleType
        WHERE CARDNO  BETWEEN p_fromCardNo AND p_toCardNo
        AND   RESSTATECODE   = '00';
        
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P02B02'; p_retMsg  := '更新IC卡库存信息失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    -- 3) add the value-return information
    IF p_retValMode = '0' THEN     -- no returns
    BEGIN
        LOOP
            v_cardNo := SUBSTR('0000000000000000' || TO_CHAR(v_fromCard), -16);
    
            INSERT INTO TF_F_CARDEWALLETACC_BACK
                (CARDNO,JUDGEMONEY, JUDGEMODE,USETAG,UPDATESTAFFNO, UPDATETIME)
            VALUES
                (v_cardNo, 0, ' ', p_retValMode, p_currOper, v_today);
 
            EXIT WHEN v_fromCard >= v_toCard;
            
            v_fromCard := v_fromCard + 1;
        END LOOP; 
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P02B03'; p_retMsg  := '新增卡片退值信息失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    END IF;

    -- 4) log this operation 
    -- get the sequence number 
    SP_GetSeq(seq => v_seqNo);
    
    BEGIN
        INSERT INTO TF_R_ICUSERTRADE
            (TRADEID,   BEGINCARDNO, ENDCARDNO, CARDNUM, RSRV1,
            ASSIGNEDSTAFFNO, ASSIGNEDDEPARTID,
            OPETYPECODE, OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES  
            (v_seqNo, p_fromCardNo, p_toCardNo, v_quantity, P_CARDPRICE,
             p_assignedStaff, v_assignedDept, 
            '01',       p_currOper     , p_currDept     ,  v_today);
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P02B04'; p_retMsg  := '新增IC卡出库日志失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
            
    p_retCode := '0000000000'; p_retMsg  := '';
    RETURN;
END;
/

show errors
