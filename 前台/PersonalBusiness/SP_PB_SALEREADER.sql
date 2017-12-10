--------------------------------------------------
--  读卡器出售存储过程
--  初次编写
--  石磊
--  2012-08-21
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_PB_SALEREADER
(
    p_FUNCCODE             VARCHAR2,  --功能编码
    P_SERIALNUMBER         VARCHAR2,  --读卡器序列号
    P_ENDSERIALNUMBER      VARCHAR2,  --结束读卡器序列号
    P_READERNUMBER         INT     ,  --读卡器数量
    p_CUSTNAME             VARCHAR2,  --客户姓名
    p_CUSTSEX              VARCHAR2,  --客户性别
    p_CUSTBIRTH            VARCHAR2,  --出生日期
    p_PAPERTYPECODE        VARCHAR2,  --证件类型
    p_PAPERNO              VARCHAR2,  --证件号码
    p_CUSTADDR             VARCHAR2,  --联系地址
    p_CUSTPOST             VARCHAR2,  --邮政编码
    p_CUSTPHONE             VARCHAR2,  --联系电话
    p_CUSTEMAIL            VARCHAR2,  --电子邮件
    p_REMARK               VARCHAR2,  --备注
    p_MONEY                INT     ,  --销售金额
    p_TRADEID          out char , --Return trade id
    p_currOper             char    ,
    p_currDept             char    ,
    p_retCode          out char    ,  -- Return Code
    p_retMsg           out varchar2   -- Return Message  
)
AS 
    v_seqNo             CHAR(16)       ;
    V_EX                EXCEPTION      ;
    V_TODAY             DATE := SYSDATE;
    V_FROMREADERNO      INT;
    V_TOREADERNO        INT;
    V_READERNO          VARCHAR2(32);    
    V_ID                CHAR(18);
BEGIN
    IF p_FUNCCODE = 'SINGLESALE' THEN
        --更新读卡器库存表
        BEGIN
            UPDATE TL_R_READER
            SET    READERSTATE      = '2'        ,
                   SALETIME         = V_TODAY    ,
                   SALESTAFFNO      = p_currOper 
            WHERE  SERIALNUMBER = P_SERIALNUMBER
            AND    READERSTATE IN('1','4') ;
            
            IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S094570207'; p_retMsg  := '更新读卡器库存表失败' || SQLERRM;
                ROLLBACK; RETURN;
        END;

    ELSIF p_FUNCCODE = 'BATCHSALE' THEN
        BEGIN
            UPDATE TL_R_READER
            SET    READERSTATE      = '2'        ,
                   SALETIME         = V_TODAY    ,
                   SALESTAFFNO      = p_currOper 
            WHERE  SERIALNUMBER BETWEEN P_SERIALNUMBER AND P_ENDSERIALNUMBER
            AND    READERSTATE IN('1','4') ;
            
            IF SQL%ROWCOUNT != P_READERNUMBER THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S094570215'; p_retMsg  := '批量更新读卡器库存表失败' || SQLERRM;
                ROLLBACK; RETURN;    
        END;
    END IF;
    
    --获取流水号
    SP_GetSeq(seq => v_seqNo); 
    p_TRADEID := v_seqNo;	
    --记录读卡器操作台账表
    BEGIN
        INSERT INTO TF_B_READER(
            TRADEID     , OPERATETYPECODE , BEGINSERIALNUMBER , ENDSERIALNUMBER  ,
            MONEY       , READERNUMBER    , OPERATETIME       , OPERATESTAFFNO   , 
            REMARK       
       )VALUES(
            v_seqNo     , '1A'            , P_SERIALNUMBER    , P_ENDSERIALNUMBER ,
            p_MONEY*P_READERNUMBER , P_READERNUMBER , V_TODAY , p_currOper        , 
            P_REMARK    );
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570208'; p_retMsg  := '记录读卡器操作台账表失败' || SQLERRM;
            ROLLBACK; RETURN;            
    END;
    
    --记录读卡器操作同步表
    V_FROMREADERNO := TO_NUMBER(P_SERIALNUMBER);
    V_TOREADERNO   := TO_NUMBER(P_ENDSERIALNUMBER);
    
    BEGIN
    LOOP  
        V_READERNO := SUBSTR('00000000000000000000000000000000' || TO_CHAR(V_FROMREADERNO), -LENGTH(V_FROMREADERNO));
        BEGIN
            INSERT INTO TF_B_READER_SYNC(
                TRADEID , OPERATETYPECODE , SERIALNUMBER   , SYNCFLAG , OPERATETIME
           )VALUES(
                v_seqNo , '02'            , V_READERNO     , '0'      , V_TODAY);
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S094570209'; p_retMsg  := '记录读卡器操作台账表失败' || SQLERRM;
                ROLLBACK; RETURN;    
        END;

        --记录读卡器客户资料表
        BEGIN
            INSERT INTO TF_F_READERCUSTREC(
                SERIALNUMBER    , CUSTNAME   , CUSTSEX   , CUSTBIRTH     , 
                PAPERTYPECODE   , PAPERNO    , CUSTADDR  , CUSTPOST      ,
                CUSTPHONE       , CUSTEMAIL  , USETAG    , UPDATESTAFFNO ,
                UPDATETIME      , REMARK
           )VALUES(
                V_READERNO      , p_CUSTNAME , p_CUSTSEX , p_CUSTBIRTH   ,
                p_PAPERTYPECODE , p_PAPERNO  , p_CUSTADDR, p_CUSTPOST    ,
                p_CUSTPHONE     , p_CUSTEMAIL, '1'       , p_currOper    ,
                V_TODAY         , p_REMARK
                );
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S094570214'; p_retMsg  := '记录读卡器客户资料表失败' || SQLERRM;
                ROLLBACK; RETURN;                
        END;
        
        v_ID := TO_CHAR(SYSDATE, 'MMDDHHMMSS') || SUBSTR(V_READERNO, -8);
        --记录现金台账
        BEGIN
            INSERT INTO TF_B_TRADEFEE(
                ID         , TRADEID        , TRADETYPECODE   , CARDNO      ,
                OTHERFEE   , OPERATESTAFFNO , OPERATEDEPARTID , OPERATETIME 
           )VALUES(
                v_ID       , v_seqNo        , '1A'            , V_READERNO  ,
                p_MONEY    , p_currOper     , p_currDept      , V_TODAY        
                );

        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S094570216';
                p_retMsg  := '记录现金台账表失败' || SQLERRM;
                ROLLBACK;RETURN;
        END;     
                
        EXIT WHEN  V_FROMREADERNO  >=  V_TOREADERNO;
        
        V_FROMREADERNO := V_FROMREADERNO + 1;
        --重新获取流水号
        SP_GetSeq(seq => v_seqNo); 
    END LOOP;             
        
    END;    
    
    -- 代理营业厅抵扣预付款
    BEGIN
      SP_PB_DEPTBALFEE(v_seqNo, '3' ,--1预付款,2保证金,3预付款和保证金
                       p_MONEY*P_READERNUMBER,V_TODAY,p_currOper,p_currDept,p_retCode,p_retMsg);
    
     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;
    
    p_retCode := '0000000000';
    p_retMsg  := '';
    RETURN;        
END;

/
show errors