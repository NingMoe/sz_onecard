CREATE OR REPLACE PROCEDURE SP_RM_OTHER_UnderOrder
(
    P_APPLYORDERID      CHAR, 			--需求单号
	P_RESOURCECODE		CHAR,			--资源编码
	P_ATTRIBUTE1		CHAR,			--属性1
	P_ATTRIBUTE2		CHAR,			--属性2
	P_ATTRIBUTE3		CHAR,			--属性3
	P_ATTRIBUTE4		CHAR,			--属性4
	P_ATTRIBUTE5		CHAR,			--属性5
	P_ATTRIBUTE6		CHAR,			--属性6
	P_RESOURCENUM		INT,			--下单数量
	P_TODAY				CHAR,			--下单时间
	P_ORDERDEMAND		CHAR,			--订单要求
	P_REQUIREDATE		CHAR,			--要求到货日期
	P_REMARK			CHAR,			--备注
	P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
	v_seqNo			  CHAR(16);		--流水号
    V_RESOURCEORDERID CHAR(18);		--订购单号
    V_EXIST           INT     ;     --存在数量
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
BEGIN
	
	--获取流水号
	SP_GetSeq(seq => v_seqNo);
	--生成订购单号
	V_RESOURCEORDERID := 'DG'||v_seqNo;
	
	--验证此需求单对应的订购单号是否存在
	SELECT  COUNT(*) INTO V_EXIST  FROM TF_F_RESOURCEORDER WHERE APPLYORDERID = P_APPLYORDERID ;
		IF v_exist > 0 THEN
				P_RETCODE := 'A094780054';
				P_RETMSG  := '此需求单对应的订购单号已存在';
				ROLLBACK; RETURN;
			END IF;
	
	--记录资源订购单
	
	BEGIN
	INSERT INTO TF_F_RESOURCEORDER(						
		RESOURCEORDERID     , APPLYORDERID    , ORDERSTATE            , USETAG       ,						
		RESOURCECODE        , ATTRIBUTE1      , ATTRIBUTE2            , ATTRIBUTE3   ,						
		ATTRIBUTE4          , ATTRIBUTE5      , ATTRIBUTE6            , RESOURCENUM  ,						
		REQUIREDATE         , LATELYDATE      , ALREADYARRIVENUM      , ORDERTIME    ,						
		ORDERSTAFFNO        , EXAMTIME        , EXAMSTAFFNO           , REMARK						
	)VALUES(						
		V_RESOURCEORDERID   , P_APPLYORDERID  , '0'   		          , '1'		      , 						
		P_RESOURCECODE      , P_ATTRIBUTE1    , P_ATTRIBUTE2          , P_ATTRIBUTE3  ,						
		P_ATTRIBUTE4        , P_ATTRIBUTE5    , P_ATTRIBUTE6          , P_RESOURCENUM ,						
		P_REQUIREDATE       , NULL            , 0                     , TO_DATE(P_TODAY,'yyyyMMdd'),
		P_CURROPER          , NULL            , NULL                  , P_REMARK					
		);
	IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S001002308';
					  P_RETMSG  := '记录资源订购单失败'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	--更新资源需求单
	BEGIN
	UPDATE  TF_F_RESOURCEAPPLYORDER    									
       SET  ALREADYORDERNUM = P_RESOURCENUM   ---已订购数量(此时的P_RESCOUCENUM是批准的订购数量（可以小于需求数量）)									
	 WHERE  APPLYORDERID = P_APPLYORDERID;
	IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S001002309';
					  P_RETMSG  := '更新资源需求单失败'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	--记录资源单据管理台帐表
	BEGIN
	INSERT INTO TF_B_RESOURCEORDERMANAGE(				
		TRADEID           , ORDERTYPECODE           , ORDERID           , OPERATETYPECODE     ,				
		ORDERDEMAND       , MAINTAINREASON          , RESOURCECODE      , ATTRIBUTE1          ,				
		ATTRIBUTE2        , ATTRIBUTE3              , ATTRIBUTE4        , ATTRIBUTE5          ,				
		ATTRIBUTE6        , RESOURCENUM             , REQUIREDATE       , LATELYDATE          ,				
		ALREADYORDERNUM   ,ALREADYARRIVENUM         , APPLYGETNUM       , AGREEGETNUM         ,			
		ALREADYGETNUM     , LATELYGETDATE           , GETSTAFFNO        , OPERATETIME         ,			
		OPERATESTAFFNO			
	)VALUES(
		v_seqNo           ,  '02'		            , V_RESOURCEORDERID , '01'				  ,				
		P_ORDERDEMAND     , NULL                    , P_RESOURCECODE    , P_ATTRIBUTE1        ,				
		P_ATTRIBUTE2      , P_ATTRIBUTE3            , P_ATTRIBUTE4      , P_ATTRIBUTE5        ,				
		P_ATTRIBUTE6      , P_RESOURCENUM           , P_REQUIREDATE     , NULL                ,				
		P_RESOURCENUM     , 0                       , NULL              , NULL                ,				
		 0                , NULL                    , NULL              , V_TODAY             ,   			
		P_CURROPER  			
		);				
	IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S001002310';
					  P_RETMSG  := '记录资源单据管理台帐表失败'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
SHOW ERRORS
	