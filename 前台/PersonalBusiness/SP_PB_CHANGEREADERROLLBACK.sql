CREATE OR REPLACE PROCEDURE SP_PB_CHANGEREADERROLLBACK
(
	P_OLDSERIALNUMBER      VARCHAR2,  --旧读卡器序列号
	P_SERIALNUMBER         VARCHAR2,  --新读卡器序列号
	p_MONEY                INT     ,  --退还金额
    p_TRADEID          out char , --Return trade id
	p_currOper	           char    ,
	p_currDept	           char    ,
	p_retCode          out char    ,  -- Return Code
	p_retMsg           out varchar2   -- Return Message  
)
AS 
    v_seqNo             CHAR(16)       ;
    V_EX                EXCEPTION      ;
    V_TODAY             DATE := SYSDATE;
	V_ID                CHAR(18);
    V_TRADEID           CHAR(16);	
/*
--  读卡器更换返销存储过程
--  初次编写
--  石磊
--  2013-01-29
*/
BEGIN
    --判断是否当天当操作员更换读卡器
	SELECT TRADEID INTO V_TRADEID 
	FROM(
		SELECT TRADEID 
		FROM TF_B_READER 
		WHERE OPERATETYPECODE = '1B'
		AND   BEGINSERIALNUMBER = P_SERIALNUMBER
		AND   OLDSERIALNUMBER = P_OLDSERIALNUMBER
		AND   OPERATESTAFFNO = p_currOper
		AND   TO_CHAR(OPERATETIME,'YYYYMMDD') = TO_CHAR(V_TODAY,'YYYYMMDD')
		ORDER BY OPERATETIME DESC)
	WHERE ROWNUM = 1;
    
    IF V_TRADEID IS NULL THEN
        p_retCode := 'S094570276'; p_retMsg  := '未找到当前操作员当天读卡器更换记录,' || SQLERRM;
        RETURN;
    END IF;
	
    --更新读卡器操作台账表更换记录，回退标志置为1（已回退）
    BEGIN
        UPDATE TF_B_READER 
        SET    CANCELTAG = '1'
        WHERE  TRADEID = V_TRADEID;
        
        IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570277'; p_retMsg  := '更新读卡器操作台账表更换记录失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;	
	
	--更新新读卡器库存表
	BEGIN
		UPDATE TL_R_READER 
		SET    READERSTATE = '1'     , --出库
		       SALETIME    = ''      ,
			   SALESTAFFNO = '' 
		WHERE  SERIALNUMBER = P_SERIALNUMBER
		AND    READERSTATE = '2'; --售出
		IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570269'; p_retMsg  := '更新新读卡器库存表失败' || SQLERRM;
			ROLLBACK; RETURN;
	END;
	
	--记录新读卡器客户资料表
	BEGIN
		DELETE FROM TF_F_READERCUSTREC WHERE SERIALNUMBER = P_SERIALNUMBER;
		
		IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570270'; p_retMsg  := '记录读卡器客户资料表失败' || SQLERRM;
			ROLLBACK; RETURN;				
	END;	
	
	--更新旧读卡器库存表
	BEGIN
		UPDATE TL_R_READER 
		SET    READERSTATE   = '2'   , --售出
		       CHANGETIME    = ''    ,
			   CHANGESTAFFNO = '' 
		WHERE  SERIALNUMBER = P_OLDSERIALNUMBER
		AND    READERSTATE = '3'; --更换回收
		IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570271'; p_retMsg  := '更新旧读卡器库存表失败' || SQLERRM;
			ROLLBACK; RETURN;		
	END;
	
	--更新旧读卡器库存表
	BEGIN
		UPDATE TF_F_READERCUSTREC 
		SET    USETAG       = '1'   --有效
		WHERE  SERIALNUMBER = P_OLDSERIALNUMBER
		AND    USETAG       = '0';  --无效
		IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570272'; p_retMsg  := '更新旧读卡器库存表失败' || SQLERRM;
			ROLLBACK; RETURN;		
	END;	
	
	--获取流水号
	SP_GetSeq(seq => v_seqNo); 
	p_TRADEID := v_seqNo;
	
	--记录读卡器操作台账表，05更换返销
	BEGIN
		INSERT INTO TF_B_READER(
		    TRADEID     , OPERATETYPECODE , BEGINSERIALNUMBER , ENDSERIALNUMBER ,
			MONEY       , READERNUMBER    , OPERATETIME       , OPERATESTAFFNO  , 
			OLDSERIALNUMBER , CANCELTRADEID
	   )VALUES(
			v_seqNo     , 'R2'            , P_SERIALNUMBER    , P_SERIALNUMBER  ,
			-p_MONEY    , 1               , V_TODAY           , p_currOper      , 
			P_OLDSERIALNUMBER , V_TRADEID);
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570273'; p_retMsg  := '记录读卡器操作台账表失败' || SQLERRM;
			ROLLBACK; RETURN;			
	END;
	
	--记录读卡器操作同步表
	BEGIN
		INSERT INTO TF_B_READER_SYNC(
		    TRADEID , OPERATETYPECODE , SERIALNUMBER   , OLDSERIALNUMBER   , SYNCFLAG , OPERATETIME
	   )VALUES(
			v_seqNo , '05'            , P_SERIALNUMBER , P_OLDSERIALNUMBER ,'0'      , V_TODAY);
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570274'; p_retMsg  := '记录读卡器操作台账表失败' || SQLERRM;
			ROLLBACK; RETURN;			
	END;	
	
	v_ID := TO_CHAR(SYSDATE, 'MMDDHHMMSS') || SUBSTR(P_SERIALNUMBER, -8);
	--记录现金台账
	BEGIN
		INSERT INTO TF_B_TRADEFEE(
			ID         , TRADEID        , TRADETYPECODE   , CARDNO        ,
			OTHERFEE   , OPERATESTAFFNO , OPERATEDEPARTID , OPERATETIME 
	   )VALUES(
			v_ID       , v_seqNo        , 'R2'            , P_SERIALNUMBER ,
			-p_MONEY   , p_currOper     , p_currDept      , V_TODAY        
			);

	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570275';
			p_retMsg  := '记录现金台账表失败' || SQLERRM;
			ROLLBACK; RETURN;
	END; 	
	
	-- 代理营业厅抵扣预付款
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
SHOW ERRORS
