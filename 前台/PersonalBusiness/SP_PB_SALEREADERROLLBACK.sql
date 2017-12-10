CREATE OR REPLACE PROCEDURE SP_PB_SALEREADERROLLBACK
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
    v_seqNo             CHAR(16)       ;
    V_EX                EXCEPTION      ;
    V_TODAY             DATE := SYSDATE;
    V_FROMREADERNO      INT;
    V_TOREADERNO        INT;
    V_READERNO          VARCHAR2(32);    
    V_ID                CHAR(18);
    V_COUNT             INT;
    V_TRADEID           CHAR(16);
/*
--  读卡器出售返销存储过程
--  初次编写
--  石磊
--  2013-01-29
*/
BEGIN
    --判断是否当天当操作员售出读卡器
	SELECT TRADEID INTO V_TRADEID 
	FROM(
		SELECT TRADEID 
		FROM TF_B_READER 
		WHERE OPERATETYPECODE = '1A'
		AND   BEGINSERIALNUMBER = P_SERIALNUMBER
		AND   ENDSERIALNUMBER = P_ENDSERIALNUMBER
		AND   OPERATESTAFFNO = p_currOper
		AND   TO_CHAR(OPERATETIME,'YYYYMMDD') = TO_CHAR(V_TODAY,'YYYYMMDD')
		ORDER BY OPERATETIME DESC)
	WHERE ROWNUM = 1;
    
    IF V_TRADEID IS NULL THEN
        p_retCode := 'S094570260'; p_retMsg  := '未找到当前操作员当天读卡器出售记录,' || SQLERRM;
        RETURN;
    END IF;
    
    --更新读卡器操作台账表出售记录，回退标志置为1（已回退）
    BEGIN
        UPDATE TF_B_READER 
        SET    CANCELTAG = '1'
        WHERE  TRADEID = V_TRADEID;
        
        IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570261'; p_retMsg  := '更新读卡器操作台账表出售记录失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
        
    IF p_FUNCCODE = 'SINGLESALEROLLBACK' THEN --单个出售返销        
        --更新读卡器库存表
        BEGIN
            UPDATE TL_R_READER
            SET    READERSTATE      = '1'    ,
                   SALETIME         = ''     ,
                   SALESTAFFNO      = '' 
            WHERE  SERIALNUMBER = P_SERIALNUMBER
            AND    READERSTATE = '2' ;
            
            IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S094570262'; p_retMsg  := '更新读卡器库存表失败,' || SQLERRM;
                ROLLBACK; RETURN;
        END;
        
        --删除读卡器客户资料表记录
        BEGIN
            DELETE FROM TF_F_READERCUSTREC WHERE SERIALNUMBER = P_SERIALNUMBER;
            
            IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S094570263'; p_retMsg  := '删除读卡器客户资料表记录失败,' || SQLERRM;
                ROLLBACK; RETURN;
        END;
    ELSIF p_FUNCCODE = 'BATCHSALEROLLBACK' THEN --批量出售返销    
        --更新读卡器库存表   
        BEGIN                
            UPDATE TL_R_READER
            SET    READERSTATE      = '1'   ,
                   SALETIME         = ''    ,
                   SALESTAFFNO      = '' 
            WHERE  SERIALNUMBER BETWEEN P_SERIALNUMBER AND P_ENDSERIALNUMBER
            AND    READERSTATE = '2' ;
            
            IF SQL%ROWCOUNT != P_READERNUMBER THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S094570264'; p_retMsg  := '批量更新读卡器库存表失败' || SQLERRM;
                ROLLBACK; RETURN;    
        END;
        
        --删除读卡器客户资料表记录
        BEGIN
            DELETE FROM TF_F_READERCUSTREC WHERE SERIALNUMBER BETWEEN P_SERIALNUMBER AND P_ENDSERIALNUMBER;
            
            IF SQL%ROWCOUNT != P_READERNUMBER THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S094570265'; p_retMsg  := '批量删除读卡器客户资料表记录失败,' || SQLERRM;
                ROLLBACK; RETURN;
        END;        
    END IF;   

    --获取流水号
    SP_GetSeq(seq => v_seqNo); 
    p_TRADEID := v_seqNo;
	
    --记录读卡器操作台账表,04出售返销
    BEGIN
        INSERT INTO TF_B_READER(
            TRADEID     , OPERATETYPECODE , BEGINSERIALNUMBER , ENDSERIALNUMBER  ,
            MONEY       , READERNUMBER    , OPERATETIME       , OPERATESTAFFNO   , 
            REMARK      , CANCELTRADEID
       )VALUES(
            v_seqNo     , 'R1'            , P_SERIALNUMBER    , P_ENDSERIALNUMBER ,
            -p_MONEY*P_READERNUMBER , P_READERNUMBER , V_TODAY , p_currOper       , 
            P_REMARK    , V_TRADEID);
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570266'; p_retMsg  := '记录读卡器操作台账表失败' || SQLERRM;
            ROLLBACK; RETURN;            
    END;

    --记录读卡器操作同步表
    V_FROMREADERNO := TO_NUMBER(P_SERIALNUMBER);
    V_TOREADERNO   := TO_NUMBER(P_ENDSERIALNUMBER);
    
    BEGIN
    LOOP  
        V_READERNO := SUBSTR('00000000000000000000000000000000' || TO_CHAR(V_FROMREADERNO), -LENGTH(V_FROMREADERNO));
        --记录读卡器操作台账表
        BEGIN
            INSERT INTO TF_B_READER_SYNC(
                TRADEID , OPERATETYPECODE , SERIALNUMBER   , SYNCFLAG , OPERATETIME
           )VALUES(
                v_seqNo , '04'            , V_READERNO     , '0'      , V_TODAY);
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S094570267'; p_retMsg  := '记录读卡器操作台账表失败' || SQLERRM;
                ROLLBACK; RETURN;    
        END;
        
        v_ID := TO_CHAR(SYSDATE, 'MMDDHHMMSS') || SUBSTR(V_READERNO, -8);
        --记录现金台账
        BEGIN
            INSERT INTO TF_B_TRADEFEE(
                ID         , TRADEID        , TRADETYPECODE   , CARDNO      ,
                OTHERFEE   , OPERATESTAFFNO , OPERATEDEPARTID , OPERATETIME 
           )VALUES(
                v_ID        , v_seqNo        , 'R1'            , V_READERNO  ,
                -p_MONEY    , p_currOper     , p_currDept      , V_TODAY        
                );

        EXCEPTION
            WHEN OTHERS THEN    
                p_retCode := 'S094570268';
                p_retMsg  := '记录现金台账表失败' || SQLERRM;
                ROLLBACK; RETURN;
        END;     
                
        EXIT WHEN  V_FROMREADERNO  >=  V_TOREADERNO;
        
        V_FROMREADERNO := V_FROMREADERNO + 1;
        --重新获取流水号
        SP_GetSeq(seq => v_seqNo); 
    END LOOP;             
        
    END;    
    
    --代理营业厅抵扣预付款
    BEGIN
      SP_PB_DEPTBALFEE(v_seqNo, '3' ,--1预付款,2保证金,3预付款和保证金
                       -p_MONEY*P_READERNUMBER,V_TODAY,p_currOper,p_currDept,p_retCode,p_retMsg);
    
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