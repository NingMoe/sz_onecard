--批量激活直销充值卡
CREATE OR REPLACE PROCEDURE SP_CC_ActivateDirectSale
(
    p_sessionID  varchar2,
    p_currOper   char,
    p_currDept   char,
    p_retCode    out char,
    p_retMsg     out varchar2
)
AS
    v_seqNo      char(16) ;
    v_ex         exception;
    v_totalValue int      ;
    v_quantity   int      ;
    v_today      date     ;
    v_dept       char(4)  ;  
BEGIN 
    
    FOR V_CUR IN (SELECT * FROM TMP_UnActivateChargeCard WHERE F7 = p_sessionID)
      LOOP
      
          --激活充值卡
          BEGIN
            SP_GetSeq(seq => v_seqNo);
            SP_CC_Activate_ChargeCard(V_CUR.F0, V_CUR.F1, '4', '',
                v_seqNo, p_currOper, p_currDept, p_retCode, p_retMsg);
            IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
              ROLLBACK; RETURN;
          END;
          
          --直销充值卡
          BEGIN
              select tf.departno into v_dept from td_m_insidestaff tf where tf.staffno = V_CUR.F9;
              SP_CC_DirectSale_ChargeCard(V_CUR.F0, V_CUR.F1,
                  v_totalValue, v_quantity, v_today,
                  V_CUR.F9, v_dept, p_retCode, p_retMsg);

              IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
              EXCEPTION WHEN OTHERS THEN
                  ROLLBACK; RETURN;
          END;

          SP_GetSeq(seq => v_seqNo);

          BEGIN
              INSERT INTO TF_XFC_BATCHSELL(TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO,
                  CARDVALUE, AMOUNT, TOTALMONEY, CUSTNAME, PAYTYPE, PAYTAG,
                  PAYTIME,  STAFFNO, OPERATETIME, REMARK)
              VALUES(v_seqNo, '84', V_CUR.F0, V_CUR.F1,
                  v_totalValue/v_quantity, v_quantity, v_totalValue, V_CUR.F2, V_CUR.F4, V_CUR.F3,
                  to_date(V_CUR.F5, 'YYYYMMDD'),  V_CUR.F9, v_today, V_CUR.F6);
          EXCEPTION WHEN OTHERS THEN
                p_retCode := 'S007P02B02'; p_retMsg := '新增批量直销操作台帐失败,' || SQLERRM;
                ROLLBACK; RETURN;
          END;

          IF V_CUR.F4 = '1' THEN
              --4) Log the trade fee when paid by cash
              BEGIN
                  INSERT INTO TF_XFC_SELLFEE(TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO, MONEY, STAFFNO,OPERATETIME)
                  VALUES(v_seqNo, '84', V_CUR.F0, V_CUR.F1, v_totalValue, V_CUR.F9, v_today);
              EXCEPTION WHEN OTHERS THEN
                  p_retCode := 'S007P02B03'; p_retMsg  := '新增批量直销现金台帐失败,' || SQLERRM;
                  ROLLBACK; RETURN;
              END;
          END IF;
          
          --更新订单表
          BEGIN
              UPDATE TF_F_ORDER SET   RSRV1 = '1' WHERE ORDERNO = V_CUR.F8;
               IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
              EXCEPTION WHEN OTHERS THEN
                p_retCode := 'S943901B02'; p_retMsg  := '更新订单表失败,' || SQLERRM;
                ROLLBACK; RETURN;
          END;
          
      END LOOP;
    
     p_retCode := '0000000000'; p_retMsg := '';
     COMMIT; RETURN;
END;

/
show errors;
