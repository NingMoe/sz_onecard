CREATE OR REPLACE PROCEDURE SP_SYN_CARDFILEMODIFY
(
	P_ID				CHAR		,	--制卡文件名
	P_ORDERSATATE		CHAR		,	--下单状态
	P_UPDATETIME		DATE		,	--操作时间
	P_CARDORDERID		CHAR		,	--订购单号
	
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode          out char     ,  -- Return Code
	p_retMsg           out varchar2    -- Return Message  
)
AS
	V_EX	EXCEPTION;
BEGIN
	BEGIN
	UPDATE TF_SYN_CARDFILE 
		SET ORDERSATATE = P_ORDERSATATE	,
			CARDORDERID = P_CARDORDERID	,
			UPDATETIME	= P_UPDATETIME
	WHERE ID = P_ID;
	IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX;END IF;
	EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S094780022'; p_retMsg  := '更新制卡文件名同步表失败' || SQLERRM;
					ROLLBACK; RETURN;
	END;

    p_retCode := '0000000000';
	p_retMsg  := '';
	RETURN; 	
	
END;

/
SHOW ERRORS	
