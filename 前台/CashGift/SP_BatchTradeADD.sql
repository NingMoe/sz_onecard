/******************************************************/
-- Author  : liuhe
-- Created : 20120831
-- UpdatedAuthor : 
-- Updated : 
-- Content : 
-- Purpose : �������д��̨�˱�
/******************************************************/
CREATE OR REPLACE PROCEDURE SP_BatchTradeADD
(
	P_BATCHID			CHAR, -- ���κ�
	P_NEEDCOUNT			INT,  -- ��������
	P_CURRNETMONEY		INT,  -- ���ſ��ۿ����
	P_SUCCOUNT			INT,  -- �ɹ�����
	P_ERRCOUNT			INT,  -- ʧ������
	P_SUCCARDNO			CHAR, -- �ɹ����ţ����Ŷ��ŷָ�
	P_ERRCARDNO			CHAR, -- ʧ�ܿ��ţ����Ŷ��ŷָ�
	P_TRADETYPECODE		CHAR, -- ҵ�����ͣ�����ҵ��̨������
	P_OPERATETYPECODE	CHAR, -- �������ͣ�01д��ǰ��02д����
	p_OPERCARDNO		CHAR, -- ��ǰ����Ա����
	P_ERRMSG			CHAR, -- ������Ϣ
	P_REMARK			CHAR, -- ��ע

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

