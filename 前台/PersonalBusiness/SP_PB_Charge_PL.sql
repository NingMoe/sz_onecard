CREATE OR REPLACE PROCEDURE SP_PB_Charge
(
        p_ID               char,
        p_CARDNO           char,
        p_CARDTRADENO      char,
        p_CARDMONEY        int,
        p_CARDACCMONEY     int,
        p_ASN              char,
        p_CARDTYPECODE     char,
        p_SUPPLYMONEY      int,
        p_OTHERFEE         int,
        p_TRADETYPECODE    char,
        p_TERMNO           char,
        p_OPERCARDNO       char,
        p_CHARGETYPE   varchar2, --充值营销模式编码
        p_TRADEID      out char, -- Return trade id
        p_currOper         char,
        p_currDept         char,
        p_retCode      out char, -- Return Code
        p_retMsg       out varchar2  -- Return Message

)
AS
    v_TradeID char(16);
    v_CURRENTTIME date := sysdate;
    v_ex          exception;
    V_COUNT           INT;
BEGIN
    
    --add by liuhe20121113添加对代理点充值金额的限制
    SELECT  COUNT(*) INTO V_COUNT                                                                 
    FROM     TF_DEPT_BALUNIT B , TD_DEPTBAL_RELATION R                                                                
    WHERE     B.DBALUNITNO = R.DBALUNITNO                                                        
            AND B.DEPTTYPE = '1'                                                        
            AND R.USETAG = '1'                                                        
            AND B.USETAG = '1'                                                        
            AND R.DEPARTNO = P_CURRDEPT;
    IF V_COUNT = 1 THEN
        SP_ProxyChargeLimit(P_CARDNO,v_CURRENTTIME,P_CARDTRADENO,p_SUPPLYMONEY,'02',p_currOper,p_currDept,p_retCode,p_retMsg);
        IF p_retCode != '0000000000' THEN
            ROLLBACK; RETURN;
        END IF;
    END IF;
    
      -- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;
    
    -- 2) Execute procedure SP_PB_UpdateAcc
    SP_PB_UpdateAcc (p_ID, p_CARDNO, p_CARDTRADENO, p_CARDMONEY,
         p_CARDACCMONEY, v_TradeID, p_ASN, p_CARDTYPECODE, p_SUPPLYMONEY,
         p_TRADETYPECODE, p_TERMNO, v_CURRENTTIME,p_currOper,p_currDept, p_retCode,p_retMsg);

    IF p_retCode != '0000000000' THEN
        ROLLBACK; RETURN;
    END IF;

    -- 3) Log the operatefee
    BEGIN
            INSERT INTO TF_B_TRADEFEE
                (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,PREMONEY,SUPPLYMONEY, OTHERFEE,
                OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
            VALUES
                (p_ID,v_TradeID,'02',p_CARDNO,p_CARDTRADENO,p_CARDMONEY,
                p_SUPPLYMONEY,p_OTHERFEE,p_currOper,p_currDept,v_CURRENTTIME);

        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001002114';
                p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
                ROLLBACK; RETURN;
    END;

        -- 4) Log the operate
        BEGIN
            INSERT INTO TF_B_TRADE
                (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,CURRENTMONEY,
                PREMONEY,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,RSRV2)
            VALUES
                (v_TradeID,p_ID,'02',p_CARDNO,p_ASN,p_CARDTYPECODE,p_CARDTRADENO,p_SUPPLYMONEY,
                p_CARDMONEY,p_currOper,p_currDept,v_CURRENTTIME,p_CHARGETYPE);

        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001002119';
                p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
                ROLLBACK; RETURN;
    END;

        -- 11) Log the writeCard
        BEGIN
            INSERT INTO TF_CARD_TRADE
                    (TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,lMoney,lOldMoney,strTermno,
                    Cardtradeno,OPERATETIME,SUCTAG)
            VALUES
                    (v_TradeID,p_TRADETYPECODE,p_OPERCARDNO,p_CARDNO,p_SUPPLYMONEY,p_CARDMONEY,
                    p_TERMNO,p_CARDTRADENO,v_CURRENTTIME,'0');

        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001001139';
                p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
                ROLLBACK; RETURN;
    END;
    
    -- 代理营业厅抵扣预付款
    BEGIN
      SP_PB_DEPTBALFEE(p_TRADEID, '1' ,--1预付款,2保证金,3预付款和保证金
                     p_SUPPLYMONEY + p_OTHERFEE,
                     v_CURRENTTIME,p_currOper,p_currDept,p_retCode,p_retMsg);
    
     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;
    
  p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors