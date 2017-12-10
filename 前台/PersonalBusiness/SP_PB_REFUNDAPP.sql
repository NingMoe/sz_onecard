CREATE OR REPLACE PROCEDURE SP_PB_REFUNDAPP
(
    p_SESSIONID  varchar2, -- Session ID
    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_quantity      INT;
    v_ex            EXCEPTION;
    v_TRADEID       VARCHAR2(32);
    v_TRADEID2       CHAR(16);
    v_ID            CHAR(18);
    v_statecode     char(1);
    v_CARDNO         CHAR(16);
    v_CHANNELNO     char(2);
    v_PAYMENTTYPE   char(2);
    v_TRADEMONEY   INT;
    v_currOper     CHAR(6);
    v_currDept     CHAR(4);

BEGIN
    --判断是否有数据需要处理
    SELECT COUNT(*) INTO v_quantity FROM TMP_ORDER WHERE f1 = p_SESSIONID;
    IF v_quantity is null or v_quantity <= 0 THEN
        p_retCode := 'A004P01001'; p_retMsg  := '没有任何数据需要处理';
        RETURN;
    END IF;



  BEGIN
    FOR V_CUR IN (SELECT f0 FROM TMP_ORDER WHERE f1 = p_sessionId)
    LOOP
    v_TRADEID:=V_CUR.f0;
    --查询退款状态,卡号,交易金额,渠道,付款方式,
    SELECT ISREFUND ,CARDNO,TRADEMONEY,CHANNELNO,PAYMENTTYPE  INTO v_statecode,v_CARDNO,v_TRADEMONEY,v_CHANNELNO,v_PAYMENTTYPE FROM TF_OUT_ADDTRADE WHERE TRADEID  = v_TRADEID ;

      --如果有允许退款的记录
        IF v_statecode = '1' THEN
            p_retCode := 'S094570231';
            p_retMsg :=V_CUR.f0||'充值交易流水已经允许退款,不可以再次操作' ;
        RETURN;
        END IF;
     --如果是专有账户则退款金额记为0 
     IF v_PAYMENTTYPE='04' THEN 
     
        v_TRADEMONEY:=0;
     
     END IF;
        
     BEGIN
        --在充值补登支付方式对应操作员编码表查找对应操作员和操作员部门
          SELECT STAFFNO,DEPARTNO INTO v_currOper,v_currDept FROM TD_M_PAYMENTSTAFF WHERE PAYMENTTYPE=V_PAYMENTTYPE;
          EXCEPTION WHEN NO_DATA_FOUND THEN
          p_retCode := 'S094570232'; p_retMsg  := '缺少参数-充值补登支付方式对应操作员编码';
          RETURN;
     END;


     --更新充值退款表
    BEGIN
        UPDATE TF_OUT_ADDTRADE
        SET    ISREFUND     = '1',
               REFUNDTIME   =v_today,
               REFUNDSTAFF=p_currOper
        WHERE  TRADEID =v_TRADEID;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P03B02'; p_retMsg  := '更新补登订单表失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;


    v_ID :=to_char(sysdate,'MMddHH24miss')||substr(v_CARDNO,9,8);
    SP_GetSeq(seq => v_TradeID2);
    --写入业务台帐 RSRV1:渠道  RSRV2:交易方式
    BEGIN
        INSERT INTO TF_B_TRADE
            (TRADEID,ID,TRADETYPECODE,CARDNO,CURRENTMONEY,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,RSRV1,RSRV2)
         VAlUES
            (v_TradeID2,v_ID,'S2',v_CARDNO,-v_TRADEMONEY,
            v_currOper, v_currDept,v_today,v_CHANNELNO,v_PAYMENTTYPE);
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode:= 'S004P03B03';
               p_retMsg  := '记录业务台帐失败' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    --写入现金台账
    BEGIN
        INSERT INTO TF_B_TRADEFEE
            (ID,TRADEID,TRADETYPECODE,CARDNO,SUPPLYMONEY,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VAlUES
            (v_ID,v_TradeID2,'S2',v_CARDNO,-v_TRADEMONEY,
            v_currOper,v_currDept,v_today);

    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S004P03B04';
              p_retMsg  := '记录现金台账表失败' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    END LOOP;



  END;


    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;


/
show errors
