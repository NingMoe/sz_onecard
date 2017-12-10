CREATE OR REPLACE PROCEDURE SP_PB_SAREADERROLLBACK_COMMIT
(
    p_FUNCCODE             VARCHAR2,  --功能编码
    P_SERIALNUMBER         VARCHAR2,  --读卡器序列号
    P_ENDSERIALNUMBER      VARCHAR2,  --结束读卡器序列号
    P_READERNUMBER         INT     ,  --读卡器数量
    p_REMARK               VARCHAR2,  --备注
    p_MONEY                INT     ,  --单个退还金额
    p_TRADEID          out char , --Return trade id
    p_currOper             char    ,
    p_currDept             char    ,
    p_retCode          out char    ,  -- Return Code
    p_retMsg           out varchar2   -- Return Message  
)
AS
    V_EX              EXCEPTION;
/*
--  读卡器出售提交存储过程
--  初次编写
--  石磊
--  2013-05-26
*/    
BEGIN
    BEGIN
        SP_PB_SALEREADERROLLBACK(
            P_FUNCCODE         => P_FUNCCODE         ,
            P_SERIALNUMBER     => P_SERIALNUMBER     ,
            P_ENDSERIALNUMBER  => P_ENDSERIALNUMBER  ,
            P_READERNUMBER     => P_READERNUMBER     ,
            p_REMARK           => p_REMARK           ,
            p_MONEY            => p_MONEY            ,
            p_TRADEID          => p_TRADEID          ,
            P_CURROPER         => P_CURROPER         ,
            P_CURRDEPT         => P_CURRDEPT         ,
            P_RETCODE          => P_RETCODE          ,
            P_RETMSG           => P_RETMSG
        );
        IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;    
END;

/
show errors