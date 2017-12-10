-- =============================================
-- AUTHOR:		liuhe
-- CREATE DATE: 2012-08-31
-- DESCRIPTION:	��������ۿ����ã���������ۿ��ӱ�
-- =============================================
CREATE OR REPLACE PROCEDURE SP_BatchTradelistADD
(
    P_BATCHID		  CHAR, -- ���κ�
    P_CARDNO          CHAR, -- ����-����-16λ����
    P_ASN             CHAR, -- ����-ASN
    P_WALLET1         INT , -- ����-����Ǯ�����1
    P_WALLET2         INT , -- ����-����Ǯ�����2
    P_STARTDATE       CHAR, -- ����-��ʼ��Ч��(YYYYMMDD)
    P_ENDDATE         CHAR, -- ����-������Ч��(YYYYMMDD)
    P_ONLINETRADENO   CHAR, -- ����-�����������
    P_OFFLINETRADENO  CHAR, -- ����-�����������
	P_TRADETYPECODE	  CHAR, -- ҵ�����ͣ�����ҵ��̨������
	P_OPERATETYPECODE  CHAR, -- �������ͣ�01д��ǰ��02д����
	P_ERRMSG		  CHAR, -- ������Ϣ
	P_SUCCTAG		  CHAR, -- �ɹ���ʶ
	P_REMARK		  CHAR, -- ��ע
	P_TRADEID		  CHAR, -- ̨��ID

    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    P_RETCODE     OUT CHAR,
    P_RETMSG      OUT VARCHAR2
)
AS
    V_TODAY           DATE := SYSDATE;
    V_SEQ             CHAR(16);
BEGIN
    
   -- 1) Get trade id
   IF P_TRADEID IS NULL THEN 
		SP_GETSEQ(SEQ => V_SEQ);
   ELSE 
		V_SEQ:=P_TRADEID;
   END IF;
	
    -- 2) Log the operate
	BEGIN--��¼������־
		INSERT INTO TF_B_TRADE_BATCHLIST
					(TRADEID, BATCHID, CARDNO, OPERATETYPECODE, TRADETYPECODE, OPERATESTAFFNO, OPERATETIME, 
					ASN, WALLET1, WALLET2, VALIDBEGINDATE, VALIDENDDATE, ONLINETRADENO, OFFLINETRADENO,
					SUCCESSTAG,ERRMSG, REMARK)
		VALUES
					(V_SEQ, P_BATCHID, P_CARDNO, P_OPERATETYPECODE, P_TRADETYPECODE, P_CURROPER, V_TODAY, 
					P_ASN, P_WALLET1, P_WALLET2, P_STARTDATE, P_ENDDATE, P_ONLINETRADENO, P_OFFLINETRADENO,
					P_SUCCTAG,P_ERRMSG, P_REMARK);
			EXCEPTION
				WHEN OTHERS THEN
					P_RETCODE := 'S009009901';
					P_RETMSG  := 'ERROR OCCURRED WHILE LOG THE OPERATION' || SQLERRM;
					ROLLBACK; RETURN;
	END;

    P_RETCODE := '0000000000';
    P_RETMSG  := '';
    COMMIT; RETURN;

END;

/
SHOW ERRORS

