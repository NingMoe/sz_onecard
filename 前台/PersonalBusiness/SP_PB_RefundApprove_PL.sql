CREATE OR REPLACE PROCEDURE SP_PB_RefundApprove
(
	p_sessionId	 char,  --sessionid
    p_stateCode  char,  --是否通过
	p_currOper   char,  -- Current Operator
    p_currDept   char,  -- Current Operator's Department
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message
)
AS
    v_TradeID char(16);
    v_CURRENTTIME date := sysdate;
    v_ex          exception;
    v_bankcode    char(4);
    v_quantity    int;
BEGIN

SELECT COUNT(*) INTO v_quantity
    FROM TMP_COMMON where f7 = p_sessionId;
    
    IF v_quantity IS NULL OR v_quantity <= 0 THEN
        p_retCode := 'A00PP01BX1'; p_retMsg  := '没有任何退款记录数据需要处理';
        RETURN;
    END IF;

--检查卡号是否存在 f8交易金额 f9卡号 f10退款ID f11充值ID
    BEGIN
        FOR v_cur in (SELECT f8,f9,f10,f11 FROM TMP_COMMON where f7 = p_sessionId)
        LOOP
 if p_statecode='2' then--如果审核通过，则
        --检查充值记录ID是否存在
        select count(*) INTO v_quantity from tq_supply_right where id=v_cur.f11;
        IF v_quantity IS NULL OR v_quantity <= 0 THEN
        p_retCode := 'A00PP01BX1'; 
        p_retMsg  := '充值记录ID:'||v_cur.f11||'不存在';
        rollback;
        RETURN;
        END IF;
            SP_AccCheck(v_cur.f9, p_currOper, p_currDept, p_retCode, p_retMsg);
            IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;



             -- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);
    
     -- 2) Log operation
    BEGIN
        INSERT INTO TF_B_TRADE
              (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CURRENTMONEY,OPERATESTAFFNO,
              OPERATEDEPARTID,OPERATETIME)
          SELECT
                v_TradeID,v_cur.f11,'91',CARDNO,ASN,CARDTYPECODE,v_cur.f8,p_currOper,
                p_currDept,v_CURRENTTIME
          FROM tf_f_cardrec t
          WHERE CARDNO = v_cur.f9;
          
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001014101';
              p_retMsg  := 'Fail to log the operation' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    --是否当前充值记录已做过退款
  select count(ID) into v_quantity from tf_b_refund where id=v_cur.f11;
  if(v_quantity>0) THEN
    p_retCode := 'SEE1014102';
        p_retMsg  := '充值记录'||v_cur.f11||'已做过退款，请检查';
        ROLLBACK; RETURN;
  end if;
    -- 3) Log the refund
    BEGIN
        INSERT INTO TF_B_REFUND
              (TRADEID,ID,TRADETYPECODE,CARDNO,BANKCODE,BANKACCNO,BACKMONEY,CUSTNAME,
              BACKSLOPE,FACTMONEY,OPERATESTAFFNO,OPERATETIME,rsrv1,PURPOSETYPE)
        select v_tradeID,v_cur.f11,TRADETYPECODE,CARDNO,BANKCODE,BANKACCNO,BACKMONEY,CUSTNAME,
              BACKSLOPE,FACTMONEY,OPERATESTAFFNO,v_CURRENTTIME,remark,PURPOSETYPE
              from tf_b_refundpl t 
              where t.tradeid=v_cur.f10;

    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001014102';
              p_retMsg  := 'Fail to log the refund' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    
    -- 4) update acc
    BEGIN
        UPDATE TF_F_CARDEWALLETACC
        SET CARDACCMONEY = CARDACCMONEY - v_cur.f8,
            TOTALSUPPLYTIMES = TOTALSUPPLYTIMES - 1,
            TOTALSUPPLYMONEY = TOTALSUPPLYMONEY - v_cur.f8
        WHERE CARDNO = v_cur.f9
		AND USETAG='1';

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001014100';
              p_retMsg  := 'Fail to update acc' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    end if;
   
       BEGIN
         update tf_b_refundpl t 
    set t.state=p_statecode 
    where t.tradeid=v_cur.f10;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001014100';
              p_retMsg  := 'Fail to update acc' || SQLERRM;
              ROLLBACK; RETURN;
    END;
    
        END LOOP;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK; RETURN;
    END;
    
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
END;
/
show errors
