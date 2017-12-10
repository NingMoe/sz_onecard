CREATE OR REPLACE PROCEDURE SP_SD_SpeAdjustAccInput
(
    p_ID                 CHAR,      --记录流水号
    p_cardNo             CHAR,      --IC卡号
    p_cardUser           VARCHAR2,  --持卡人用户名
    p_userPhone          VARCHAR2,  --持卡人电话
    p_refundMoney        INT,       --退款金额
    p_ReBrokerage				 INT,       --应退还商户佣金
    p_adjAccReson        CHAR,      --调帐原因
    p_remark             VARCHAR2,  --交易说明
    p_currOper	         CHAR,      --操作员工工号
    p_currDept	         CHAR,      --操作员工所在部门
    p_retCode            OUT CHAR ,    --错误代码
    p_retMsg             OUT VARCHAR2  --错误消息
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