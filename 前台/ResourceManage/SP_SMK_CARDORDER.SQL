CREATE OR REPLACE PROCEDURE SP_SMK_CARDORDER
(
	P_APPLYORDERTYPE		CHAR	,	--订购单类型 01：成品卡；02：半成品卡
	P_FILENAME				VARCHAR2,	--制卡文件名
	P_MANUTYPECODE			CHAR	,	--卡厂商
	P_BATCHNO				VARCHAR2,	--批次号
	P_CARDSUM				CHAR	,	--卡数量
	P_BATCHDATE				CHAR	,	--批次日期
	P_BEGINCARDNO			VARCHAR2,	--开始卡号
	P_ENDCARDNO				VARCHAR2,	--结束日期
	P_ID					CHAR	,	--制卡文件名对于ID
	P_REMARK				VARCHAR2,	--备注
	
	P_SMKMANUTYPECODE		CHAR	,	--市民卡对应卡厂商编码
	P_INSERTTYPE			CHAR	,	--是否选择制卡文件名 0：是 1：否 （未填写制卡文件名则在零星制卡文件名称表中新增一行记录）
	
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode          out char     ,  -- Return Code
	p_retMsg           out varchar2    -- Return Message  
)
AS
	V_FILENAME	VARCHAR2(255)	;		--文件名称
    V_EX        EXCEPTION       ;
    V_FROMCARD  CHAR(16)		;
    V_TOCARD    CHAR(16)		;
    V_CARDNO    CHAR(16)		;
    v_exist     INT				;
    v_seqNo     CHAR(16)		;
    V_ORDERID   CHAR(18)		;
	V_TODAY DATE :=SYSDATE;
	V_FILEID	CHAR(16)		;		--制卡文件名ID
BEGIN

	--获取流水号
	SP_GetSeq(seq => v_seqNo);
	--生成订购单号
	V_ORDERID := 'DG'||v_seqNo;

	--查询是否已有卡片在库中
      SELECT count(*) INTO v_exist FROM  TL_R_ICUSER WHERE CARDNO BETWEEN P_BEGINCARDNO AND P_ENDCARDNO;

	    IF v_exist > 0 THEN
	        p_retCode := 'A002P01B01'; p_retMsg  := '已有卡片存在于库中';
	        ROLLBACK;RETURN;
	    END IF;
      --查询是否已有卡号下订购单
      SELECT COUNT(*) INTO v_exist FROM TD_M_SMKCARDNO_EXCLUDE WHERE CARDNO BETWEEN P_BEGINCARDNO AND P_ENDCARDNO;
      
	    IF v_exist > 0 THEN
	        p_retCode := 'S094570150'; p_retMsg  := '已有卡片下订购单';
	        ROLLBACK;RETURN;
	    END IF;    

      --记录卡片下单卡号排重表
	    V_FROMCARD := TO_NUMBER(P_BEGINCARDNO);
	    V_TOCARD   := TO_NUMBER(P_ENDCARDNO);
	
	    BEGIN
	        LOOP
	            V_CARDNO := SUBSTR('0000000000000000' || TO_CHAR(V_FROMCARD), -16);
	
	            INSERT INTO TD_M_SMKCARDNO_EXCLUDE( 
	                CARDNO    , CARDORDERID
	           )VALUES(
	                V_CARDNO  , V_ORDERID
	                );
	
	            EXIT WHEN  V_FROMCARD  >=  V_TOCARD;
	
	            V_FROMCARD := V_FROMCARD + 1;
	        END LOOP;
	    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S094570151'; p_retMsg  := '记录卡片下单卡号排重表失败' || SQLERRM;
	            ROLLBACK; RETURN;
	    END;
	
	V_FILENAME :=P_FILENAME;
		
	--同步卡管系统修改制卡文件名表存储过程 成品卡才做修改制卡文件名表
	IF P_APPLYORDERTYPE = '01' THEN
		IF P_INSERTTYPE = '0' THEN		--填写了制卡文件名则需更新制卡文件名表
			BEGIN
				SP_SYN_CARDFILEMODIFY(P_ID,'1',V_TODAY,V_ORDERID,
									p_currOper,p_currDept,p_retCode,p_retMsg);
			IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
				EXCEPTION
				WHEN OTHERS THEN
					ROLLBACK; RETURN;	
			END; 
			V_FILEID :=P_ID;
		ELSE							--未填写制卡文件名则需新增制卡文件名表
			BEGIN
				V_FILENAME := P_SMKMANUTYPECODE || '_' || P_BATCHNO || '_' || P_BATCHDATE || '_' || P_CARDSUM || '.txt';
				SP_SYN_CARDFILEADD(V_FILENAME,V_TODAY,V_ORDERID,
									p_currOper,p_currDept,p_retCode,p_retMsg,V_FILEID);
			IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
				EXCEPTION
				WHEN OTHERS THEN
					ROLLBACK; RETURN;
			END;
		END IF;
	END IF;
	
	--记录市民卡订购单表
	BEGIN
		INSERT INTO TF_F_SMK_CARDORDER(																		
		CARDORDERID        , CARDORDERTYPE    , CARDORDERSTATE   , USETAG    ,																		
		FILENAME           , MANUTYPECODE     ,  BATCHNO         , CARDNUM   ,																		
		BATCHDATE          , BEGINCARDNO      , ENDCARDNO        , ORDERTIME ,																		
		ORDERSTAFFNO       , REMARK			  , FILEID														
		)VALUES(																		
		V_ORDERID           , P_APPLYORDERTYPE  , '0'		     , '1'           ,																		
		V_FILENAME          , P_MANUTYPECODE    , P_BATCHNO      , P_CARDSUM     ,																		
		P_BATCHDATE         , P_BEGINCARDNO     , P_ENDCARDNO    , V_TODAY	     ,																		
		p_currOper           ,P_REMARK          , V_FILEID
		);
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION
        WHEN OTHERS THEN
          P_RETCODE := 'S094780020';
          P_RETMSG  := '添加市民卡订购单表失败'||SQLERRM;      
          ROLLBACK; RETURN;
	END;
	
	--记录市民卡单据管理台帐表
	BEGIN
		INSERT INTO TF_B_SMK_ORDERMANAGE(
		TRADEID				,ORDERID			,OPERATETYPECODE	,CARDNUM			,
		MANUTYPECODE		,BATCHNO			,FILENAME			,BATCHDATE			,
		OPERATETIME			,OPERATESTAFF		,REMARK
		)VALUES
		(v_seqNo			,V_ORDERID			,'01'				,P_CARDSUM			,
		P_MANUTYPECODE		,P_BATCHNO			,V_FILENAME			,P_BATCHDATE		,
		V_TODAY				,p_currOper			,P_REMARK);
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION
        WHEN OTHERS THEN
          P_RETCODE := 'S094780021';
          P_RETMSG  := '添加市民卡单据管理台帐表失败'||SQLERRM;      
          ROLLBACK; RETURN;
	END;
	
    p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN; 
	
END;

/
SHOW ERRORS	