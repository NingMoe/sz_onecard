CREATE OR REPLACE PROCEDURE SP_SYN_CARDFILEADD
(
	P_FILENAME			VARCHAR2	,	--制卡文件名
	P_UPDATETIME		DATE		,	--操作时间
	P_CARDORDERID		CHAR		,	--订购单号
	
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode          out char     ,  -- Return Code
	p_retMsg           out varchar2 ,  -- Return Message  
	
	p_FILEID		   out CHAR		   --制卡文件ID
)
AS
    V_SEQ           CHAR(16);
	V_EX			EXCEPTION;
BEGIN

	SP_GETSEQ(SEQ => V_SEQ);
	
	BEGIN
	INSERT INTO TF_SYN_CARDFILE(
				ID,			FILENAME,		INISTIME,		DEALCODE,
				FILETYPE,	ORDERSATATE,	CARDORDERID)
		VALUES(V_SEQ,		P_FILENAME,		P_UPDATETIME,	'0'		,
				'03',			'1',		P_CARDORDERID);
	IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX;END IF;
	EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S094780023'; p_retMsg  := '新增制卡文件名同步表失败' || SQLERRM;
					ROLLBACK; RETURN;
	END;

    p_retCode := '0000000000';
	p_retMsg  := '';
	RETURN; 	
	
END;

/
SHOW ERRORS	
