/******************************************************/
-- Author  : liuhe
-- Created : 20120831
-- UpdatedAuthor : 
-- Updated : 
-- Content : 
-- Purpose : 添加批量写卡台账表
/******************************************************/
CREATE OR REPLACE PROCEDURE SP_BatchTradeADD
(
	P_BATCHID			CHAR, -- 批次号
	P_NEEDCOUNT			INT,  -- 操作数量
	P_CURRNETMONEY		INT,  -- 单张卡售卡金额
	P_SUCCOUNT			INT,  -- 成功数量
	P_ERRCOUNT			INT,  -- 失败数量
	P_SUCCARDNO			CHAR, -- 成功卡号，多张逗号分隔
	P_ERRCARDNO			CHAR, -- 失败卡号，多张逗号分隔
	P_TRADETYPECODE		CHAR, -- 业务类型，参照业务台账主表
	P_OPERATETYPECODE	CHAR, -- 操作类型，01写卡前，02写卡后
	p_OPERCARDNO		CHAR, -- 当前操作员卡号
	P_ERRMSG			CHAR, -- 错误消息
	P_REMARK			CHAR, -- 备注

	P_CURROPER			CHAR,
	P_CURRDEPT			CHAR,
	P_RETCODE			OUT CHAR,
	P_RETMSG			OUT VARCHAR2
)
AS
    V_TODAY           DATE := SYSDATE;
    V_SEQ             CHAR(16);
BEGIN
    
   -- 1) Get trade id
    SP_GETSEQ(SEQ => V_SEQ);

    -- 2) Log the operate
    BEGIN
	
	INSERT INTO TF_B_TRADE_BATCH
	  (TRADEID,BATCHID, OPERATETYPECODE, TRADETYPECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME, OPERCARDNO,
	  NEEDCOUNT, CURRNETMONEY, SUCCOUNT, ERRCOUNT, SUCCARDNO, ERRCARDNO, ERRMSG, REMARK)
	VALUES
	  (V_SEQ,P_BATCHID, P_OPERATETYPECODE, P_TRADETYPECODE, P_CURROPER, P_CURRDEPT , V_TODAY, p_OPERCARDNO,
	  P_NEEDCOUNT, P_CURRNETMONEY, P_SUCCOUNT, P_ERRCOUNT, P_SUCCARDNO, P_ERRCARDNO, P_ERRMSG, P_REMARK);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S009009902';
	            p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    P_RETCODE := '0000000000';
    P_RETMSG  := '';
    COMMIT; RETURN;

END;

/
SHOW ERRORS

