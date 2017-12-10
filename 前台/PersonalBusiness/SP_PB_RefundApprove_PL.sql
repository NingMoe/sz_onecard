CREATE OR REPLACE PROCEDURE SP_PB_RefundApprove
(
	p_sessionId	 char,  --sessionid
    p_stateCode  char,  --�Ƿ�ͨ��
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
        p_retCode := 'A00PP01BX1'; p_retMsg  := 'û���κ��˿��¼������Ҫ����';
        RETURN;
    END IF;

--��鿨���Ƿ���� f8���׽�� f9���� f10�˿�ID f11��ֵID
    BEGIN
        FOR v_cur in (SELECT f8,f9,f10,f11 FROM TMP_COMMON where f7 = p_sessionId)
        LOOP
 if p_statecode='2' then--������ͨ������
        --����ֵ��¼ID�Ƿ����
        select count(*) INTO v_quantity from tq_supply_right where id=v_cur.f11;
        IF v_quantity IS NULL OR v_quantity <= 0 THEN
        p_retCode := 'A00PP01BX1'; 
        p_retMsg  := '��ֵ��¼ID:'||v_cur.f11||'������';
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
    --�Ƿ�ǰ��ֵ��¼�������˿�
  select count(ID) into v_quantity from tf_b_refund where id=v_cur.f11;
  if(v_quantity>0) THEN
    p_retCode := 'SEE1014102';
        p_retMsg  := '��ֵ��¼'||v_cur.f11||'�������˿����';
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
