CREATE OR REPLACE PROCEDURE SP_EW_StockOut
(
    p_CardNo        char, -- Card No.
    p_serviceCycle  char, -- Service Cycle Type
    p_serviceFee    int , -- Service Fee per Service Cycle
    p_currOper      char, -- Current Operator
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message
)
AS
    v_assignedStaff char(6) := '090003'; -- Assigned Staff No
    v_assignedDept  char(4) := '9002'; -- Assigned Staff's Department    
    v_cardNo        char(16);
    v_quantity      int;
    v_today         date := sysdate;
    v_ex            EXCEPTION;
	  v_seqNo         CHAR(16);  
	  v_currDept      CHAR(4) ; --部门编码
BEGIN
    --获取部门编码
    BEGIN
        SELECT DEPARTNO 
        INTO   v_currDept
        FROM   TD_M_INSIDESTAFF
        WHERE  STAFFNO = p_currOper;
    EXCEPTION WHEN NO_DATA_FOUND THEN 
        v_currDept := '9002';
    END;     
    
    SELECT COUNT(*) INTO v_quantity
    FROM  TL_R_ICUSER
    WHERE CARDNO = p_CardNo
    AND   RESSTATECODE = '00';  -- IN STOCKIN
    IF v_quantity != 1 THEN
        p_retCode := 'A002P02B01'; p_retMsg  := '已有卡片不在库';
        RETURN; 
    END IF;      
	  
    -- 2) update the ic card stock table
    BEGIN
        UPDATE  TL_R_ICUSER
        SET     UPDATETIME       = v_today     ,
                UPDATESTAFFNO    = p_currOper     ,
                ASSIGNEDSTAFFNO  = v_assignedStaff,
                ASSIGNEDDEPARTID = v_assignedDept ,
                SERVICECYCLE     = p_serviceCycle ,
                EVESERVICEPRICE  = p_serviceFee   ,
                RESSTATECODE     = '01',   -- stockout
                SALETYPE         = '01',
                OUTTIME          = v_today
        WHERE   CARDNO           = p_CardNo
        AND     RESSTATECODE     = '00';
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P02B02'; p_retMsg  := '更新IC卡库存信息失败,' || SQLERRM;
            RETURN;
    END;	  
    
    -- 3) add the value-return information
    BEGIN
    	v_cardNo := SUBSTR('0000000000000000' || TO_CHAR(p_CardNo), -16);
    	INSERT INTO TF_F_CARDEWALLETACC_BACK(
    	    CARDNO         , JUDGEMONEY    , JUDGEMODE , USETAG  ,
    	    UPDATESTAFFNO  , UPDATETIME
     )VALUES(
          v_cardNo       , 0             , ' '       , '0'     , 
          p_currOper     , v_today
          );
          
      IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P02B03'; p_retMsg  := '新增卡片退值信息失败,' || SQLERRM;
            RETURN;
    END;
    
    -- 4) log this operation 
    -- get the sequence number 
    SP_GetSeq(seq => v_seqNo);
    
    BEGIN
        INSERT INTO TF_R_SMKICUSERTRADE(
            TRADEID         , CARDNO          ,
            RSRV1           , ASSIGNEDSTAFFNO , ASSIGNEDDEPARTID , OPETYPECODE   ,
            OPERATESTAFFNO  , OPERATEDEPARTID , OPERATETIME
       )VALUES(
            v_seqNo         , p_CardNo        ,
            ''              , v_assignedStaff , v_assignedDept   , '01'          ,
            p_currOper      , v_currDept      , v_today
            );
            
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P02B04'; p_retMsg  := '新增IC卡出库日志失败,' || SQLERRM;
            RETURN;
    END;        
    
    p_retCode := '0000000000'; p_retMsg  := '';
    RETURN;
END;
/

show errors    