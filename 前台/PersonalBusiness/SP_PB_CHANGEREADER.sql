--------------------------------------------------
--  读卡器更换存储过程
--  初次编写
--  石磊
--  2012-08-22
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_PB_CHANGEREADER
(
	P_OLDSERIALNUMBER      VARCHAR2,  --旧读卡器序列号
	P_SERIALNUMBER         VARCHAR2,  --新读卡器序列号
	p_MONEY                INT     ,  --更换金额
	p_REMARK	           VARCHAR2,  --备注
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
BEGIN
	--更新新读卡器库存表
	BEGIN
		UPDATE TL_R_READER 
		SET    READERSTATE = '2'        , --售出
		       SALETIME    = V_TODAY    ,
			   SALESTAFFNO = p_currOper 
		WHERE  SERIALNUMBER = P_SERIALNUMBER
		AND    READERSTATE IN ('1','4'); --出库,退货回收
		IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570210'; p_retMsg  := '更新新读卡器库存表失败' || SQLERRM;
			ROLLBACK; RETURN;		
	END;
	
	--记录新读卡器客户资料表
	BEGIN
		INSERT INTO TF_F_READERCUSTREC (
			SERIALNUMBER    , CUSTNAME   , CUSTSEX   , CUSTBIRTH     , 
			PAPERTYPECODE   , PAPERNO    , CUSTADDR  , CUSTPOST      ,
			CUSTPHONE       , CUSTEMAIL  , USETAG    , UPDATESTAFFNO ,
			UPDATETIME      , REMARK
		)SELECT
			P_SERIALNUMBER  , t.CUSTNAME , t.CUSTSEX , t.CUSTBIRTH   ,
			t.PAPERTYPECODE , t.PAPERNO  , t.CUSTADDR, t.CUSTPOST    ,
			t.CUSTPHONE     , t.CUSTEMAIL, '1'       , p_currOper    ,
			V_TODAY         , t.REMARK
		FROM   TF_F_READERCUSTREC t
		WHERE  SERIALNUMBER = P_OLDSERIALNUMBER
		AND    USETAG = '1';
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570216'; p_retMsg  := '记录读卡器客户资料表失败' || SQLERRM;
			ROLLBACK; RETURN;				
	END;	
	
	--更新旧读卡器库存表
	BEGIN
		UPDATE TL_R_READER 
		SET    READERSTATE   = '3'        , --更换回收
		       CHANGETIME    = V_TODAY    ,
			   CHANGESTAFFNO = p_currOper 
		WHERE  SERIALNUMBER = P_OLDSERIALNUMBER
		AND    READERSTATE = '2'; --售出
		IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570211'; p_retMsg  := '更新旧读卡器库存表失败' || SQLERRM;
			ROLLBACK; RETURN;		
	END;
	
	--更新旧读卡器客户资料表
	BEGIN
		UPDATE TF_F_READERCUSTREC 
		SET    USETAG       = '0'   --无效
		WHERE  SERIALNUMBER = P_OLDSERIALNUMBER
		AND    USETAG       = '1';  --有效
		IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570217'; p_retMsg  := '更新旧读卡器客户资料表失败' || SQLERRM;
			ROLLBACK; RETURN;		
	END;	
	
	--获取流水号
	SP_GetSeq(seq => v_seqNo); 
	p_TRADEID := v_seqNo;
	
	--记录读卡器操作台账表
	BEGIN
		INSERT INTO TF_B_READER(
		    TRADEID     , OPERATETYPECODE , BEGINSERIALNUMBER , ENDSERIALNUMBER ,
			MONEY       , READERNUMBER    , OPERATETIME       , OPERATESTAFFNO  , 
			REMARK      , OLDSERIALNUMBER
	   )VALUES(
			v_seqNo     , '1B'            , P_SERIALNUMBER    , P_SERIALNUMBER  ,
			p_MONEY     , 1               , V_TODAY           , p_currOper      , 
			P_REMARK    , P_OLDSERIALNUMBER);
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570212'; p_retMsg  := '记录读卡器操作台账表失败' || SQLERRM;
			ROLLBACK; RETURN;			
	END;
	
	--记录读卡器操作同步表
	BEGIN
		INSERT INTO TF_B_READER_SYNC(
		    TRADEID , OPERATETYPECODE , SERIALNUMBER   , OLDSERIALNUMBER   , SYNCFLAG , OPERATETIME
	   )VALUES(
			v_seqNo , '03'            , P_SERIALNUMBER , P_OLDSERIALNUMBER ,'0'      , V_TODAY);
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570213'; p_retMsg  := '记录读卡器操作台账表失败' || SQLERRM;
			ROLLBACK; RETURN;			
	END;	
	
	v_ID := TO_CHAR(SYSDATE, 'MMDDHHMMSS') || SUBSTR(P_SERIALNUMBER, -8);
	--记录现金台账
	BEGIN
		INSERT INTO TF_B_TRADEFEE(
			ID         , TRADEID        , TRADETYPECODE   , CARDNO        ,
			OTHERFEE   , OPERATESTAFFNO , OPERATEDEPARTID , OPERATETIME 
	   )VALUES(
			v_ID       , v_seqNo        , '1B'            , P_SERIALNUMBER ,
			p_MONEY    , p_currOper     , p_currDept      , V_TODAY        
			);

	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570217';
			p_retMsg  := '记录现金台账表失败' || SQLERRM;
			ROLLBACK; RETURN;
	END; 	
	
	-- 代理营业厅抵扣预付款
	BEGIN
	  SP_PB_DEPTBALFEE(v_seqNo, '3' ,--1预付款,2保证金,3预付款和保证金
				       p_MONEY,V_TODAY,p_currOper,p_currDept,p_retCode,p_retMsg);
	
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