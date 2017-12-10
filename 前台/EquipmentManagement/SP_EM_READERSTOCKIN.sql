--------------------------------------------------
--  读卡器入库存储过程
--  初次编写
--  石磊
--  2012-08-20
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_EM_READERSTOCKIN
(
    P_FROMREADERNO         VARCHAR2 ,  --起始读卡器序列号
	P_TOREADERNO           VARCHAR2 ,  --结束读卡器序列号
	P_READERNUMBER         INT  ,      --读卡器数量
	P_MANUCODE             CHAR ,      --读卡器厂商编码
	P_REMARK               VARCHAR2 ,  --备注
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode          out char     ,  -- Return Code
	p_retMsg           out varchar2    -- Return Message  
)
AS 
    v_seqNo             CHAR(16)       ;
    V_TODAY             DATE := SYSDATE;
	V_EXIST             INT;
	V_FROMREADERNO      INT;
	V_TOREADERNO        INT;
	V_READERNO          VARCHAR2(32);
BEGIN
	--验证是否已有读卡器在库中
	SELECT COUNT(*) INTO V_EXIST FROM  TL_R_READER WHERE SERIALNUMBER BETWEEN P_FROMREADERNO AND P_TOREADERNO;

	IF V_EXIST > 0 THEN    
	p_retCode := 'S094570200'; p_retMsg  := '已有读卡器在库中';
	RETURN;
	END IF;

	--读卡器入库存表
	V_FROMREADERNO := TO_NUMBER(P_FROMREADERNO);
	V_TOREADERNO   := TO_NUMBER(P_TOREADERNO);

	BEGIN
	LOOP  
		V_READERNO := SUBSTR('00000000000000000000000000000000' || TO_CHAR(V_FROMREADERNO), -LENGTH(V_FROMREADERNO));
				
		INSERT INTO TL_R_READER( 
			SERIALNUMBER , READERSTATE , MANUCODE   , INSTIME  , INSTAFFNO
	   )VALUES(
			V_READERNO   , '0'         , P_MANUCODE , V_TODAY  ,  p_currOper);
		
		EXIT WHEN  V_FROMREADERNO  >=  V_TOREADERNO;
		
		V_FROMREADERNO := V_FROMREADERNO + 1;
	END LOOP; 
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570201'; p_retMsg  := '新增读卡器库存表失败' || SQLERRM;
			ROLLBACK; RETURN;
	END;
	
	--获取流水号
	SP_GetSeq(seq => v_seqNo); 
	
	--记录读卡器操作台账表
	BEGIN
		INSERT INTO TF_B_READER(
		    TRADEID     , OPERATETYPECODE , BEGINSERIALNUMBER , ENDSERIALNUMBER ,
			MANUCODE    , READERNUMBER    , OPERATETIME       , OPERATESTAFFNO  , 
			REMARK
	   )VALUES(
			v_seqNo     , '00'            , P_FROMREADERNO    , P_TOREADERNO    ,
			P_MANUCODE  , P_READERNUMBER  , V_TODAY           , p_currOper      , 
			P_REMARK
	        );
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570202'; p_retMsg  := '记录读卡器操作台账表失败' || SQLERRM;
			ROLLBACK; RETURN;			
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;	

/
show errors