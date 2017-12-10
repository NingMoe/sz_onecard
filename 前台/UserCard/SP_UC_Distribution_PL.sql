CREATE OR REPLACE PROCEDURE SP_UC_Distribution
(
    P_sessionId  varchar2, -- Session ID
    p_assignedStaff char, -- Assigned Staff No to be distributed to
    p_currOper      char, -- Current Operator
    p_currDept      char, -- Curretn Operator's Department
    p_retCode  out  char, -- Return Code
    p_retMsg out varchar2  -- Return Message
)
AS
    v_quantity      int;
    v_today         date := sysdate;
    v_assignedDept  char(4); -- Assigned Dept  No to be distributed to
    v_ex            EXCEPTION;
	v_seqNo         CHAR(16);  
BEGIN

    BEGIN
        SELECT DEPARTNO INTO v_assignedDept
            FROM  TD_M_INSIDESTAFF
            WHERE STAFFNO = p_assignedStaff;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'A002P04D02'; p_retMsg  := '无法得到分配员工所在的部门编码' || SQLERRM;
            RETURN;
    END;

    -- 1) update the stock info   
    SELECT  count(*) INTO v_quantity FROM TMP_UC_CardNoList WHERE SessionId = P_sessionId;
    
    BEGIN
        UPDATE  TL_R_ICUSER
        SET   UPDATETIME       = v_today        ,
              ALLOCTIME        = v_today        ,
              UPDATESTAFFNO    = p_currOper     ,
              ASSIGNEDSTAFFNO  = p_assignedStaff,
              ASSIGNEDDEPARTID = v_assignedDept ,
              RESSTATECODE     = '05'   -- Distributed
        WHERE CARDNO IN (SELECT CardNo FROM TMP_UC_CardNoList WHERE SessionId = P_sessionId)
        AND   RESSTATECODE     = '01';   -- Stocked-out
    
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P03B01'; p_retMsg  := '更新用户卡库存信息失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
        
    SP_GetSeq(seq => v_seqNo);

     -- 2) log this operation 
    BEGIN
        INSERT INTO TF_R_CARDALLOT
            (TRADEID, CARDNO, ACCEPTSTAFFNO, ACCEPTDEPARTID, 
            ALLOTTIME, ALLOTSTAFFNO, ALLOTDEPARTID, OPERATIONCODE)
        SELECT v_seqNo, CardNo, p_assignedStaff, v_assignedDept,
            v_today  , p_currOper  , p_currDept   , '0'
        FROM TMP_UC_CardNoList WHERE SessionId = P_sessionId;
        
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P03B02'; p_retMsg  := '新增分配操作日志失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors

CREATE OR REPLACE PROCEDURE SP_UC_UnDistribution
(
    P_sessionId  varchar2, -- Session ID
    p_currOper      char, -- Current Operator
    p_currDept      char, -- Curretn Operator's Department
    p_retCode  out  char, -- Return Code
    p_retMsg out varchar2  -- Return Message
)
AS
    v_quantity      int;
    v_today         date := sysdate;
    v_ex            EXCEPTION;
	v_seqNo         CHAR(16);  

BEGIN
        
    -- 1) update the stock info
    BEGIN
        SELECT count(*) INTO v_quantity FROM TMP_UC_CardNoList WHERE SessionId = P_sessionId;
        UPDATE  TL_R_ICUSER
            SET   UPDATETIME       = v_today,
                  UPDATESTAFFNO    = p_currOper,
                  ALLOCTIME        = null,
                  ASSIGNEDSTAFFNO  = p_currOper,
                  ASSIGNEDDEPARTID = p_currDept,
                  RESSTATECODE     = '01'  -- Stocked-out
            WHERE CARDNO IN 
                (SELECT CardNo FROM TMP_UC_CardNoList WHERE SessionId = P_sessionId)
            AND   RESSTATECODE     = '05';  -- Distributed
        
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P03C01'; p_retMsg  := '更新用户卡库存信息失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    SP_GetSeq(seq => v_seqNo);

    -- 2) log this operation 
    BEGIN
        INSERT INTO TF_R_CARDALLOT
          (TRADEID, CARDNO, ALLOTTIME, ALLOTSTAFFNO, ALLOTDEPARTID, OPERATIONCODE)
        SELECT v_seqNo, CardNo, v_today, p_currOper, p_currDept    , '2'
        FROM TMP_UC_CardNoList WHERE SessionId = P_sessionId;
     EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P03C02'; p_retMsg  := '新增取消分配操作日志失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
       
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors

