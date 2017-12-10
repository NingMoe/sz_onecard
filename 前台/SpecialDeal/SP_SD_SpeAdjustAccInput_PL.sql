CREATE OR REPLACE PROCEDURE SP_SD_SpeAdjustAccInput
(
    p_ID                 CHAR,      --��¼��ˮ��
    p_cardNo             CHAR,      --IC����
    p_cardUser           VARCHAR2,  --�ֿ����û���
    p_userPhone          VARCHAR2,  --�ֿ��˵绰
    p_refundMoney        INT,       --�˿���
    p_ReBrokerage				 INT,       --Ӧ�˻��̻�Ӷ��
    p_adjAccReson        CHAR,      --����ԭ��
    p_remark             VARCHAR2,  --����˵��
    p_currOper	         CHAR,      --����Ա������
    p_currDept	         CHAR,      --����Ա�����ڲ���
    p_retCode            OUT CHAR ,    --�������
    p_retMsg             OUT VARCHAR2  --������Ϣ
)
AS
    v_currdate   DATE := SYSDATE;
    v_seqNo      CHAR(16);
  	v_ex         EXCEPTION;
    v_quantity   int;

BEGIN

  --1) get the sequence number
  SP_GetSeq(seq => v_seqNo);


  --2) add TF_B_SPEADJUSTACC info
  BEGIN
    INSERT INTO TF_B_SPEADJUSTACC
			(
			  TRADEID,TRADETYPECODE,ID,CARDNO,CARDTRADENO,TRADEDATE,
        TRADETIME,PREMONEY,TRADEMONEY,REFUNDMENT,CUSTPHONE,
        CUSTNAME,CALLINGNO,CORPNO,DEPARTNO,BALUNITNO,
        REASONCODE,REMARK,STATECODE,STAFFNO,OPERATETIME,REBROKERAGE )		
    SELECT 
        v_seqNo,'97',ID,p_cardNo,CARDTRADENO,TRADEDATE,
        TRADETIME,PREMONEY,TRADEMONEY,p_refundMoney,p_userPhone,
        p_cardUser,CALLINGNO,CORPNO,DEPARTNO,BALUNITNO,
        p_adjAccReson,p_remark,'0', p_currOper, v_currdate ,p_ReBrokerage    
     FROM TQ_TRADE_RIGHT WHERE ID = p_ID ;

    IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S009110002';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;


  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT;RETURN;

END;


/
show errors