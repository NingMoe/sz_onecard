CREATE OR REPLACE PROCEDURE SP_PB_ChangeRemark
(
	p_fromCardNo    CHAR, -- From Card No. 
    p_toCardNo      CHAR, -- End  Card No. 
    p_remark        varchar2,
    p_currOper      CHAR, -- Current Operator 
    p_currDept      CHAR, -- Curretn Operator's Department 
    p_retCode   OUT CHAR, -- Return Code 
    p_retMsg    OUT varchar2
)
AS
    v_today         date := sysdate;
    v_quantity      INT;
    v_ex            EXCEPTION;
	v_seqNo         CHAR(16);  

BEGIN
    select p_toCardNo - p_fromCardNo + 1 into v_quantity from dual;
    
    BEGIN
        update TF_F_CUSTOMERREC
        set remark = trim(remark) || p_remark
        where cardno between p_fromCardNo and p_toCardNo;
        
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P07B02'; p_retMsg  := '更新客户信息失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    SP_GetSeq(seq => v_seqNo);

    BEGIN
        INSERT INTO TF_B_CUSTOMERCHANGE
              (TRADEID, CARDNO, REMARK, 
               CHGTYPECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME )
        SELECT v_seqNo , cardno, p_remark,
               '01'       , p_currOper, p_currDept  , v_today
        FROM   tf_f_cardrec
       where   cardno between p_fromCardNo and p_toCardNo;

        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P07B03'; p_retMsg  := '新增客户资料变更台帐失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors