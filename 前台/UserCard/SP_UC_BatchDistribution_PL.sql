CREATE OR REPLACE PROCEDURE SP_UC_BatchDistribution
(
    p_fromCardNo char, -- From Card No.
    p_toCardNo   char, -- End  Card No.
    p_distType   smallint, -- 0 for individual 1 for bank
    p_assignee   char, -- staff no (p_distType is 0) or bank no (p_distType is 1)
    p_currOper   char, -- Current Operator
    p_currDept   char, -- Curretn Operator's Department
    p_retCode  out  char, -- Return Code
    p_retMsg out varchar2  -- Return Message
)
AS
	v_fromCard      NUMERIC(16);
	v_toCard        NUMERIC(16);
    v_quantity      int;
    v_dbquantity    int;
    v_today         date := sysdate;
    v_ex            EXCEPTION;
	v_seqNo         CHAR(16);  
    
    v_assignedDept char(4);
    v_newState     char(2);
    v_operCode     char(1);

BEGIN

    v_fromCard := TO_NUMBER(p_fromCardNo);
    v_toCard   := TO_NUMBER(p_toCardNo);
    v_quantity := v_toCard - v_fromCard + 1;

    
    -- 1) check the state in the range
    SELECT count(*) INTO v_dbquantity
       FROM TL_R_ICUSER
       WHERE  CARDNO BETWEEN p_fromCardNo AND p_toCardNo
       AND    RESSTATECODE  = '01'
       AND    ASSIGNEDSTAFFNO = p_currOper
       AND    ASSIGNEDDEPARTID = p_currDept;
    IF v_quantity != v_dbquantity THEN
        p_retCode := 'A002P04D01'; p_retMsg  := '号段范围内卡片状态不一致或者卡片不属于当前登录员工及部门';
        RETURN; 
    END IF;

    -- 2) get the dept id for individual staff
    IF p_distType = 0 THEN -- individual
        BEGIN
            SELECT DEPARTNO INTO v_assignedDept FROM TD_M_INSIDESTAFF WHERE STAFFNO = p_assignee;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'A002P04D02'; p_retMsg  := '无法得到分配员工所在的部门信息';
                RETURN; 
        END;
    
        v_newState := '05'; -- distribution
        v_operCode := '0';
    ELSIF p_distType = 1 THEN -- bank
        v_assignedDept := NULL;
        v_newState := '12'; -- sale on commission
        v_operCode := '1' ;
    ELSE
        p_retCode := 'A002P04D03'; p_retMsg  := '非法的分配类型';
        RETURN; 
    END IF;

    -- 3) update the stock info
    BEGIN
        UPDATE  TL_R_ICUSER
            SET   UPDATETIME       = v_today     ,
                  ALLOCTIME        = v_today     ,
                  UPDATESTAFFNO    = p_currOper     ,
                  ASSIGNEDSTAFFNO  = p_assignee     ,
                  ASSIGNEDDEPARTID = v_assignedDept ,
                  RESSTATECODE     = v_newState
            WHERE CARDNO BETWEEN p_fromCardNo AND p_toCardNo;
        
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P04D04'; p_retMsg  := '更新用户卡库存信息失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    SP_GetSeq(seq => v_seqNo);

    -- 4) log the batch distribution 
    BEGIN
        INSERT INTO TF_R_CARDALLOT
          (TRADEID, CARDNO, ACCEPTSTAFFNO, ACCEPTDEPARTID, 
          ALLOTTIME, ALLOTSTAFFNO, ALLOTDEPARTID, OPERATIONCODE)
        SELECT v_seqNo, CARDNO, p_assignee, v_assignedDept,
            v_today, p_currOper    , p_currDept    , v_operCode
        FROM   TL_R_ICUSER
        WHERE  CARDNO BETWEEN p_fromCardNo AND p_toCardNo;
        
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P04D05'; p_retMsg  := '新增分配操作日志失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors

CREATE OR REPLACE PROCEDURE SP_UC_BatchUnDistribution
(
    p_fromCardNo char, -- From Card No.
    p_toCardNo   char, -- End  Card No.
    p_currOper   char, -- Current Operator
    p_currDept   char, -- Curretn Operator's Department
    p_retCode  out  char, -- Return Code
    p_retMsg out varchar2  -- Return Message
)
AS
	v_fromCard      NUMERIC(16);
	v_toCard        NUMERIC(16);
    v_quantity      int;
    v_dbquantity    int;
    v_today         date := sysdate;
    v_ex            EXCEPTION;
	v_seqNo         CHAR(16);  
BEGIN
 
    v_fromCard := TO_NUMBER(p_fromCardNo);
    v_toCard   := TO_NUMBER(p_toCardNo);
    v_quantity := v_toCard - v_fromCard + 1;

    -- 1) check the state in the range
    SELECT count(*) INTO v_dbquantity  FROM TL_R_ICUSER
    WHERE  CARDNO BETWEEN p_fromCardNo AND p_toCardNo
    AND    RESSTATECODE  in ('05', '12')
    AND    UPDATESTAFFNO = p_currOper;
    IF v_quantity != v_dbquantity THEN
        p_retCode := 'A002P04E01'; p_retMsg  := '号段范围内卡片状态不一致';
        RETURN; 
    END IF;

    -- 2) update the stock info
    BEGIN
        UPDATE  TL_R_ICUSER
        SET   UPDATETIME       = v_today,
              UPDATESTAFFNO    = p_currOper,
              ALLOCTIME        = null,
              ASSIGNEDSTAFFNO  = p_currOper,
              ASSIGNEDDEPARTID = p_currDept,
              RESSTATECODE     = '01'             -- Stocked-out
        WHERE CARDNO BETWEEN p_fromCardNo AND p_toCardNo
        AND   RESSTATECODE in ('05', '12');
        
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P04E02'; p_retMsg  := '更新用户卡库存信息失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    SP_GetSeq(seq => v_seqNo);

    -- 2) log this operation 
    BEGIN
        INSERT INTO TF_R_CARDALLOT
          (TRADEID, CARDNO, 
          ALLOTTIME, ALLOTSTAFFNO, ALLOTDEPARTID, OPERATIONCODE)
        SELECT v_seqNo, CARDNO, 
            v_today, p_currOper    , p_currDept    , '2'
        FROM TL_R_ICUSER
        WHERE CARDNO BETWEEN p_fromCardNo AND p_toCardNo;
            
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P04E03'; p_retMsg  := '新增批量取消分配操作日志失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors

