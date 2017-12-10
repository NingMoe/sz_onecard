CREATE OR REPLACE PROCEDURE SP_EW_StockReturn
(
	p_CardNo         char, -- 卡号
	p_currOper       char, -- 员工编码
	p_retCode        out char, -- Return Code
	p_retMsg         out varchar2  -- Return Message
)
AS
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
    FROM TL_R_ICUSER
    WHERE CARDNO = p_CardNo
    AND   RESSTATECODE = '01' ;   -- 出库
    
    IF v_quantity != 1 THEN
        p_retCode := 'A094392B01'; p_retMsg  := '退库卡片不为出库状态';
        RETURN; 
    END IF;    

    --更新卡库存表
    BEGIN
        UPDATE  TL_R_ICUSER
        SET UPDATETIME       = v_today ,
            UPDATESTAFFNO    = p_currOper ,
            ASSIGNEDSTAFFNO  = null,
            ASSIGNEDDEPARTID = null ,
            SERVICECYCLE     = null ,
            EVESERVICEPRICE  = null ,
            RESSTATECODE     = '00',   -- stockin
            OUTTIME          = null,
            SALETYPE         = null,
            CARDPRICE        = 0  
        WHERE CARDNO = p_CardNo
        AND   RESSTATECODE   = '01';  -- 出库
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S002P02B02'; p_retMsg  := '更新IC卡库存信息失败,' || SQLERRM;
                RETURN;
    END;

    --删除退值表记录
    BEGIN
        delete from TF_F_CARDEWALLETACC_BACK where cardno = p_CardNo;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S094390007'; p_retMsg  := '删除卡片退值信息失败,' || SQLERRM;
                RETURN;
    END;
            
    --记录用户卡库存操作台账表
    SP_GetSeq(seq => v_seqNo);
        
    BEGIN
        INSERT INTO TF_R_SMKICUSERTRADE(
               TRADEID,            OPETYPECODE,   CARDNO   , OPERATESTAFFNO,  
               OPERATEDEPARTID,    OPERATETIME
       )VALUES(
                v_seqNo,           '03',          p_CardNo , p_currOper,
                v_currDept,        v_today
               );
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S002P02B04'; p_retMsg  := '新增IC卡出库日志失败' || SQLERRM;
                RETURN;
    END;	        
        
    p_retCode := '0000000000'; p_retMsg  := '';
    RETURN;
    
END;
/

show errors;
