--------------------------------------------------
--  下单审核作废存储过程
--  初次编写
--  石磊
--  2012-07-24
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_UnderEXAM_CANCEL
(
    P_SESSIONID       CHAR,
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    V_RESOURCEORDERID		CHAR(18);     --订购单号
	V_APPLYORDERID			CHAR(18);		--需求单号
	V_RESOURCECODE			CHAR(6);		--资源编码
	V_ATTRIBUTE1			VARCHAR2(50);	--资源属性1
	V_ATTRIBUTE2			VARCHAR2(50);	--资源属性2
	V_ATTRIBUTE3			VARCHAR2(50);	--资源属性3
	V_ATTRIBUTE4			VARCHAR2(50);	--资源属性4
	V_ATTRIBUTE5			VARCHAR2(50);	--资源属性5
	V_ATTRIBUTE6			VARCHAR2(50);	--资源属性6
	V_RESOURCENUM			INT;			--订购数量
	V_REQUIREDATE			CHAR(8);		--要求到货日期
	V_LATELYDATE			CHAR(8);		--最近到货日期
	V_ALREADYARRIVENUM		INT;			--已到货数量
	V_RESOURCEAPPLYNUM		INT;			--需求数量
	V_APPLYORDERTYPE		CHAR(1);		--需求单状态
	
	v_seqNo           CHAR(16);     --流水号
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
BEGIN
	SELECT f0 INTO V_RESOURCEORDERID FROM TMP_COMMON WHERE f1 = p_SESSIONID;
	
	  --获取流水号
	  SP_GetSeq(seq => v_seqNo);
	  BEGIN
	  	--参数赋值
			SELECT
					APPLYORDERID  ,RESOURCECODE    ,ATTRIBUTE1    ,ATTRIBUTE2     ,
					ATTRIBUTE3    ,ATTRIBUTE4      ,ATTRIBUTE5    ,ATTRIBUTE6     ,
					RESOURCENUM   ,REQUIREDATE     ,LATELYDATE    ,ALREADYARRIVENUM
			INTO
					V_APPLYORDERID  ,V_RESOURCECODE    ,V_ATTRIBUTE1    ,V_ATTRIBUTE2     ,
					V_ATTRIBUTE3    ,V_ATTRIBUTE4      ,V_ATTRIBUTE5    ,V_ATTRIBUTE6     ,
					V_RESOURCENUM   ,V_REQUIREDATE     ,V_LATELYDATE    ,V_ALREADYARRIVENUM
			FROM   TF_F_RESOURCEORDER   ---资源订购单
			WHERE  RESOURCEORDERID = V_RESOURCEORDERID ;
			  EXCEPTION
					WHEN NO_DATA_FOUND THEN
						  p_retCode := 'S094570156'; 
						  p_retMsg  := '未找到订购单';
						  ROLLBACK; RETURN;
	  END;
	
		--更新订购单
	BEGIN
		UPDATE TF_F_RESOURCEORDER  
		SET    ORDERSTATE = '2'     ,
			   EXAMTIME = V_TODAY       ,
			   EXAMSTAFFNO = P_CURROPER
		WHERE  RESOURCEORDERID = V_RESOURCEORDERID ;
	
		  IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		EXCEPTION
		  WHEN OTHERS THEN
			P_RETCODE := 'S001002402';
			P_RETMSG  := '更新订购单表失败'||SQLERRM;
			ROLLBACK; RETURN;
	END;	
		
		--记录单据管理台账表
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
			v_seqNo           ,  '02'		            , V_RESOURCEORDERID , '04'				  ,
			NULL              , NULL                    , V_RESOURCECODE    , V_ATTRIBUTE1        ,
			V_ATTRIBUTE2      , V_ATTRIBUTE3            , V_ATTRIBUTE4      , V_ATTRIBUTE5        ,
			V_ATTRIBUTE6      , V_RESOURCENUM           , V_REQUIREDATE     , V_LATELYDATE        ,
			0                 , V_ALREADYARRIVENUM      , NULL              , NULL                ,
			NULL              , NULL                    , NULL              , V_TODAY       ,
			P_CURROPER);  					
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S001002405';
					  P_RETMSG  := '记录资源单据管理台帐失败'||SQLERRM;      
					  ROLLBACK; RETURN;	
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '成功';
	COMMIT; RETURN;    	  
END;

/
show errors