CREATE OR REPLACE PROCEDURE SP_EW_UPDATECARDORDER
(
    p_CARDORDERID    CHAR,
    p_COUNT          INT,
    p_currOper       CHAR, -- Current Operator 
    p_retCode    OUT CHAR, -- Return Code 
    p_retMsg     OUT VARCHAR2
)
AS
    v_today    date := sysdate;
    v_seqNo    CHAR(16);  
    v_ex            EXCEPTION;    
    V_CARDORDERSTATE    CHAR(1);   --订购单状态
    V_ORDERCARDNUM      INT    ;   --订购单要求数量
    V_ALREADYARRIVENUM  INT    ;   --已到货数量    
BEGIN
    --查询卡所属订购单号和需求单号
    SELECT CARDNUM ,
           ALREADYARRIVENUM
    INTO   V_ORDERCARDNUM ,
           V_ALREADYARRIVENUM
    FROM TF_F_SMK_CARDORDER 
    WHERE  CARDORDERID = p_CARDORDERID
    AND    CARDORDERSTATE IN('1','3') --1审核通过，3部分到货
    AND    USETAG = '1'    ;
    
    IF p_COUNT + V_ALREADYARRIVENUM >= V_ORDERCARDNUM THEN
       V_CARDORDERSTATE := '4';  --全部到货
    ELSE
       V_CARDORDERSTATE := '3';  --部分到货
    END IF;     
    
    BEGIN
        --更新订购单
        UPDATE TF_F_SMK_CARDORDER
        SET    CARDORDERSTATE = V_CARDORDERSTATE ,  --订购单状态
               ALREADYARRIVENUM = V_ALREADYARRIVENUM + p_COUNT  --已到货数量
        WHERE  CARDORDERID = p_CARDORDERID
        AND    USETAG = '1';
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570117'; p_retMsg  := '更新订购单失败'|| SQLERRM;
            ROLLBACK; RETURN;
    END;    
    
	SP_GetSeq(seq => v_seqNo);
	
    BEGIN
        --记录单据管理台账表
        INSERT INTO TF_B_SMK_ORDERMANAGE(
            TRADEID          , ORDERID           , OPERATETYPECODE   ,
            CARDNUM          , OPERATETIME       , OPERATESTAFF      
        )VALUES(
            v_seqNo          , p_CARDORDERID     , '07'              ,
            p_COUNT          , V_TODAY           , P_CURROPER        
            );    
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570119'; p_retMsg  := '记录单据管理台账表失败'|| SQLERRM;
            ROLLBACK; RETURN;       
    END;

    p_retCode := '0000000000'; p_retMsg  := '';
    RETURN;
END;

/
SHOW ERRORS