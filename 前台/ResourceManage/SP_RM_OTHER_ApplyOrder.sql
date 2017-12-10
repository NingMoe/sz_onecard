CREATE OR REPLACE PROCEDURE SP_RM_OTHER_ApplyOrder
(
    P_RESOURCECODE      CHAR, 			--资源编码
	P_ATTRIBUTE1		CHAR,			--属性1
	P_ATTRIBUTE2		CHAR,			--属性2
	P_ATTRIBUTE3		CHAR,			--属性3
	P_ATTRIBUTE4		CHAR,			--属性4
	P_ATTRIBUTE5		CHAR,			--属性5
	P_ATTRIBUTE6		CHAR,			--属性6
	P_RESOURCENUM		INT,			--下单数量
	P_ORDERDEMAND		CHAR,			--订单要求
	P_REQUIREDATE		CHAR,			--要求到货日期
	P_REMARK			CHAR,			--备注
	P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2,  -- Return Message
	
	P_APPLYORDERID out char				--订购单号
)
AS
	v_seqNo			  CHAR(16);		--流水号
    V_APPLYORDERID	  CHAR(18);		--需求单号
    V_EXIST           INT     ;     --存在数量
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
BEGIN
	--获取流水号
	SP_GetSeq(seq => v_seqNo);
	--生成需求单号
	V_APPLYORDERID := 'XQ'||v_seqNo;
	
	--记录资源需求单表
	BEGIN
	INSERT INTO TF_F_RESOURCEAPPLYORDER(											
		APPLYORDERID        , APPLYORDERTYPE , USETAG             , ORDERDEMAND    ,
		RESOURCECODE        , ATTRIBUTE1     , ATTRIBUTE2         , ATTRIBUTE3       ,											
		ATTRIBUTE4          , ATTRIBUTE5     , ATTRIBUTE6         , RESOURCENUM   ,											
		REQUIREDATE         , LATELYDATE     , ALREADYORDERNUM    , ALREADYARRIVENUM  ,
		ORDERTIME           , ORDERSTAFFNO   , REMARK											
	)VALUES(
		V_APPLYORDERID      , '0'			    , '1'              , P_ORDERDEMAND    ,											
		P_RESOURCECODE      , P_ATTRIBUTE1      , P_ATTRIBUTE2     , P_ATTRIBUTE3     ,											
		P_ATTRIBUTE4        , P_ATTRIBUTE5      , P_ATTRIBUTE6     , P_RESOURCENUM    ,											
		P_REQUIREDATE       , NULL              , 0                , 0                ,											
		V_TODAY             , P_CURROPER        , P_REMARK										
	);
	IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S001002220';
					  P_RETMSG  := '记录资源需求单表失败'||SQLERRM;
					  ROLLBACK; RETURN;
	END;

	--记录资源单据管理台帐
	BEGIN
	INSERT INTO TF_B_RESOURCEORDERMANAGE(
		TRADEID           , ORDERTYPECODE           , ORDERID	        , OPERATETYPECODE     ,
		ORDERDEMAND       , MAINTAINREASON          , RESOURCECODE      , ATTRIBUTE1          ,
		ATTRIBUTE2        , ATTRIBUTE3              , ATTRIBUTE4        , ATTRIBUTE5          ,
		ATTRIBUTE6        , RESOURCENUM             , REQUIREDATE       , LATELYDATE          ,
		ALREADYORDERNUM   ,ALREADYARRIVENUM         , APPLYGETNUM       , AGREEGETNUM         ,						
		ALREADYGETNUM     , LATELYGETDATE           , GETSTAFFNO        , OPERATETIME         ,
		OPERATESTAFFNO
	)VALUES(
		v_seqNo           ,  '01'		            , V_APPLYORDERID	, '00'				  ,
		P_ORDERDEMAND     , NULL                    , P_RESOURCECODE    , P_ATTRIBUTE1        ,
		P_ORDERDEMAND     , NULL                    , P_RESOURCECODE    , P_ATTRIBUTE1        ,
		P_ATTRIBUTE2      , P_ATTRIBUTE3            , P_ATTRIBUTE4      , P_ATTRIBUTE5        ,
		0                 , 0                       , NULL              , NULL                ,							
		NULL              , NULL                    , NULL              , V_TODAY             ,
		P_CURROPER
		);
	IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S001002221';
					  P_RETMSG  := '记录资源单据管理台帐表失败'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	P_APPLYORDERID :=V_APPLYORDERID;
	COMMIT; RETURN;   
END;


/
show errors