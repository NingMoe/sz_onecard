CREATE OR REPLACE PROCEDURE SP_PB_RETURNREADER
(
    P_SERIALNUMBER         VARCHAR2,  --读卡器序列号
    P_READERNUMBER         INT     ,  --读卡器数量
    p_MONEY                INT     ,  --退还金额
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
    V_ID                CHAR(18);
/*
--  读卡器退货
--  初次编写
--  石磊
--  2013-04-05
*/
BEGIN 
    --记录读卡器历史表
    BEGIN
        INSERT INTO TH_R_READER(
            SERIALNUMBER    , READERSTATE      , MANUCODE , MONEY       , 
            INSTIME         , INSTAFFNO        , OUTTIME  , OUTSTAFFNO  ,
            ASSIGNEDSTAFFNO , ASSIGNEDDEPARTID , SALETIME , SALESTAFFNO ,
            CHANGETIME      , CHANGESTAFFNO    , RSRV1
       )SELECT
            SERIALNUMBER    , READERSTATE      , MANUCODE , MONEY       , 
            INSTIME         , INSTAFFNO        , OUTTIME  , OUTSTAFFNO  ,
            ASSIGNEDSTAFFNO , ASSIGNEDDEPARTID , SALETIME , SALESTAFFNO ,
            CHANGETIME      , CHANGESTAFFNO    , RSRV1
        FROM TL_R_READER
        WHERE SERIALNUMBER = P_SERIALNUMBER;
        
        IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570281'; p_retMsg  := '记录读卡器历史表失败,' || SQLERRM;
            ROLLBACK; RETURN;            
    END;
    
    --更新读卡器库存表
    BEGIN
        UPDATE TL_R_READER
        SET    READERSTATE      = '4'        , --退货回收
               ASSIGNEDSTAFFNO  = p_currOper ,
               ASSIGNEDDEPARTID = p_currDept ,
               SALETIME      = '',
               SALESTAFFNO   = '',
               CHANGETIME    = '',
               CHANGESTAFFNO = '',
               RSRV1 = ''
        WHERE  SERIALNUMBER = P_SERIALNUMBER
        AND    READERSTATE = '2' ;
        
        IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570282'; p_retMsg  := '更新读卡器库存表失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    --记录读卡器客户资料历史表
    BEGIN
        INSERT INTO TH_F_READERCUSTREC(
            SERIALNUMBER  , CUSTNAME  , CUSTSEX       , CUSTBIRTH   ,
            PAPERTYPECODE , PAPERNO   , CUSTADDR      , CUSTPOST    ,
            CUSTPHONE     , CUSTEMAIL , UPDATESTAFFNO , UPDATETIME  ,
            REMARK
       )SELECT 
            SERIALNUMBER  , CUSTNAME  , CUSTSEX       , CUSTBIRTH   ,
            PAPERTYPECODE , PAPERNO   , CUSTADDR      , CUSTPOST    ,
            CUSTPHONE     , CUSTEMAIL , UPDATESTAFFNO , UPDATETIME  ,
            REMARK
        FROM TF_F_READERCUSTREC
        WHERE SERIALNUMBER = P_SERIALNUMBER;
        
        IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570283'; p_retMsg  := '记录读卡器客户资料历史表失败,' || SQLERRM;
            ROLLBACK; RETURN;        
    END;
    --删除读卡器客户资料表
    BEGIN
        DELETE TF_F_READERCUSTREC WHERE  SERIALNUMBER = P_SERIALNUMBER; 

        IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570284'; p_retMsg  := '删除读卡器客户资料表失败' || SQLERRM;
            ROLLBACK; RETURN;        
    END;

    --获取流水号
    SP_GetSeq(seq => v_seqNo); 
    p_TRADEID := v_seqNo;
	
    --记录读卡器操作台账表,06退货
    BEGIN
        INSERT INTO TF_B_READER(
            TRADEID     , OPERATETYPECODE , BEGINSERIALNUMBER , ENDSERIALNUMBER,
            MONEY       , READERNUMBER    , OPERATETIME       , OPERATESTAFFNO     
       )VALUES(
            v_seqNo     , '1C'            , P_SERIALNUMBER    , P_SERIALNUMBER ,
            -p_MONEY    , P_READERNUMBER  , V_TODAY           , p_currOper     
            );
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570285'; p_retMsg  := '记录读卡器操作台账表失败' || SQLERRM;
            ROLLBACK; RETURN;            
    END;

    --记录读卡器操作同步表
    BEGIN
        INSERT INTO TF_B_READER_SYNC(
            TRADEID , OPERATETYPECODE , SERIALNUMBER   , SYNCFLAG , OPERATETIME
       )VALUES(
            v_seqNo , '06'            , P_SERIALNUMBER , '0'      , V_TODAY);
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570286'; p_retMsg  := '记录读卡器操作台账表失败' || SQLERRM;
            ROLLBACK; RETURN;    
    END;
    
    v_ID := TO_CHAR(SYSDATE, 'MMDDHHMMSS') || SUBSTR(P_SERIALNUMBER, -8);
    --记录现金台账
    BEGIN
        INSERT INTO TF_B_TRADEFEE(
            ID         , TRADEID        , TRADETYPECODE   , CARDNO          ,
            OTHERFEE   , OPERATESTAFFNO , OPERATEDEPARTID , OPERATETIME 
       )VALUES(
            v_ID        , v_seqNo        , '1C'            , P_SERIALNUMBER ,
            -p_MONEY    , p_currOper     , p_currDept      , V_TODAY        
            );

    EXCEPTION
        WHEN OTHERS THEN    
            p_retCode := 'S094570287';
            p_retMsg  := '记录现金台账表失败' || SQLERRM;
            ROLLBACK; RETURN;
    END;     
                         

    
    --代理营业厅抵扣预付款
    BEGIN
      SP_PB_DEPTBALFEE(v_seqNo, '3' ,--1预付款,2保证金,3预付款和保证金
                       -p_MONEY,V_TODAY,p_currOper,p_currDept,p_retCode,p_retMsg);
    
     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;
    
    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;        
END;

/
show errors