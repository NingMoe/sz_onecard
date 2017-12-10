CREATE OR REPLACE PROCEDURE SP_PB_SALEREADER_COMMIT
(
    p_FUNCCODE             VARCHAR2,  --功能编码
    P_SERIALNUMBER         VARCHAR2,  --读卡器序列号
    P_ENDSERIALNUMBER      VARCHAR2,  --结束读卡器序列号
    P_READERNUMBER         INT     ,  --读卡器数量
    p_CUSTNAME               VARCHAR2,  --客户姓名
    p_CUSTSEX               VARCHAR2,  --客户性别
    p_CUSTBIRTH               VARCHAR2,  --出生日期
    p_PAPERTYPECODE           VARCHAR2,  --证件类型
    p_PAPERNO              VARCHAR2,  --证件号码
    p_CUSTADDR               VARCHAR2,  --联系地址
    p_CUSTPOST               VARCHAR2,  --邮政编码
    p_CUSTPHONE               VARCHAR2,  --联系电话
    p_CUSTEMAIL            VARCHAR2,  --电子邮件
    p_REMARK               VARCHAR2,  --备注
    p_MONEY                INT     ,  --销售金额
    p_TRADEID          out char , --Return trade id
    p_currOper               char    ,
    p_currDept               char    ,
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
        SP_PB_SALEREADER(
            P_FUNCCODE         => P_FUNCCODE         ,
            P_SERIALNUMBER     => P_SERIALNUMBER     ,
            P_ENDSERIALNUMBER  => P_ENDSERIALNUMBER  ,
            P_READERNUMBER     => P_READERNUMBER     ,
            p_CUSTNAME         => p_CUSTNAME         ,
            p_CUSTSEX          => p_CUSTSEX          ,
            p_CUSTBIRTH        => p_CUSTBIRTH        ,
            p_PAPERTYPECODE    => p_PAPERTYPECODE    ,
            p_PAPERNO          => p_PAPERNO          ,
            p_CUSTADDR         => p_CUSTADDR         ,
            p_CUSTPOST         => p_CUSTPOST         ,
            p_CUSTPHONE        => p_CUSTPHONE        ,
            p_CUSTEMAIL        => p_CUSTEMAIL        ,
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