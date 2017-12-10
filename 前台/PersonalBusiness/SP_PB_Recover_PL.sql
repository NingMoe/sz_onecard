CREATE OR REPLACE PROCEDURE SP_PB_Recover
(
        p_ID               char,
        p_CARDACCMONEY     int,
        p_CANCELMONEY       int,
        p_CARDTRADENO       char,
        p_CARDNO           char,
        p_TRADETYPECODE  char,
        p_ASN               char,
        p_CARDTYPECODE     char,
        p_CARDMONEY         int,
        p_SUPPLYID         char,
        p_TERMNO                 char,
        p_OPERCARDNO         char,
        p_TRADEID           out char, -- Return trade id
        p_currOper         char,
        p_currDept         char,
        p_retCode        out char, -- Return Code
        p_retMsg         out varchar2  -- Return Message

)
AS
    v_TradeID char(16);
    v_SupplyTradeid char(16);
    v_CURRENTTIME date := sysdate;
    v_ex          exception;
BEGIN
    -- 1) Updated electronic wallet account information
    BEGIN
            UPDATE  TF_F_CARDEWALLETACC
            SET  CARDACCMONEY = CARDACCMONEY - p_CANCELMONEY,
                SUPPLYREALMONEY = p_CARDMONEY,
                TOTALSUPPLYTIMES = TOTALSUPPLYTIMES - 1,
                TOTALSUPPLYMONEY = TOTALSUPPLYMONEY - p_CANCELMONEY,
                ONLINECARDTRADENO = p_CARDTRADENO
                WHERE  CARDNO = p_CARDNO;

            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001009102';
                p_retMsg  := 'Error to Update electronic wallet account' || SQLERRM;
                ROLLBACK; RETURN;
    END;

    -- 2) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;

    -- 3)
    BEGIN
            SELECT TRADEID INTO v_SupplyTradeid
            FROM TF_B_TRADE
            WHERE ID = p_SUPPLYID;

            EXCEPTION
    WHEN NO_DATA_FOUND THEN
            p_retCode := 'A001009101';
            p_retMsg  := 'Can not find supply id' || SQLERRM;
            ROLLBACK; RETURN;
        END;

    -- 3) Log the operate
    BEGIN
            INSERT INTO TF_B_TRADE
                (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,CURRENTMONEY,PREMONEY,NEXTMONEY,
                OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,CANCELTRADEID,RSRV2)
            SELECT 
                 v_TradeID,p_ID,p_TRADETYPECODE,p_CARDNO,p_ASN,p_CARDTYPECODE,p_CARDTRADENO,
                 0 - p_CANCELMONEY,p_CARDMONEY,p_CARDMONEY - p_CANCELMONEY,p_currOper,p_currDept,v_CURRENTTIME,
                 v_SupplyTradeid,RSRV2
		    FROM TF_B_TRADE
			WHERE ID = p_SUPPLYID;

        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001009103';
                p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
                ROLLBACK; RETURN;
    END;

    -- 4) Log account change
    BEGIN
            INSERT INTO TF_B_TRADEFEE
                (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,PREMONEY,SUPPLYMONEY,OPERATESTAFFNO,
                OPERATEDEPARTID,OPERATETIME)
            VALUES
                (p_ID,v_TradeID,p_TRADETYPECODE,p_CARDNO,p_CARDTRADENO,p_CARDMONEY,-p_CANCELMONEY,p_currOper,p_currDept,v_CURRENTTIME);

        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001009104';
                p_retMsg  := 'Error to log account change' || SQLERRM;
                ROLLBACK; RETURN;
    END;

    -- 5) Updated electronic wallet account information
    BEGIN
            INSERT INTO TF_B_EWALLETCHANGE
                (TRADEID,ID,CARDNO,ASN,TRADETYPECODE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
            VALUES
                (v_TradeID,p_SUPPLYID,p_CARDNO,p_ASN,p_TRADETYPECODE,p_currOper,p_currDept,v_CURRENTTIME);

        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001009105';
                p_retMsg  := 'Error to log wallet account change' || SQLERRM;
                ROLLBACK; RETURN;
    END;

    -- 6) Record an electronic wallet recharge log
    BEGIN
            INSERT INTO TF_SUPPLY_REALTIME
                (ID,CARDNO,ASN,CARDTRADENO,TRADETYPECODE,CARDTYPECODE,TRADEDATE,TRADETIME,TRADEMONEY,
                PREMONEY,SUPPLYLOCNO,SAMNO,OPERATESTAFFNO,OPERATETIME)
            VALUES
                (p_ID,p_CARDNO,p_ASN,p_CARDTRADENO,p_TRADETYPECODE,p_CARDTYPECODE,
                TO_CHAR(v_CURRENTTIME,'YYYYMMDD'),TO_CHAR(v_CURRENTTIME,'HH24MISS'),
                0 - p_CANCELMONEY,p_CARDMONEY,p_currDept,p_TERMNO,p_currOper,v_CURRENTTIME);

        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001009106';
                p_retMsg  := 'Error occurred while insert a row of wallet recharge log' || SQLERRM;
                ROLLBACK; RETURN;
    END;

    -- 7) Update operation
    BEGIN
            UPDATE TF_B_TRADE
            SET CANCELTAG = '1',
            CANCELTRADEID = v_TradeID
            WHERE ID = p_SUPPLYID
			AND CANCELTAG not in ('1');--防止多次重复提交

            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001009109';
                p_retMsg  := 'Error occurred while update operation' || SQLERRM;
                ROLLBACK; RETURN;
    END;

        -- 8) Log the writeCard
        BEGIN
            INSERT INTO TF_CARD_TRADE
                    (TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,lMoney,lOldMoney,strTermno,OPERATETIME,SUCTAG)
            VALUES
                    (v_TradeID,p_TRADETYPECODE,p_OPERCARDNO,p_CARDNO,0 - p_CANCELMONEY,p_CARDMONEY,p_TERMNO,v_CURRENTTIME,'0');

        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001001139';
                p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
                ROLLBACK; RETURN;
    END;
    
    ------ 代理营业厅抵扣预付款，add by liuhe 20111230
     BEGIN
         SP_PB_DEPTBALFEEROLLBACK(v_TradeID, v_SupplyTradeid,
                    '1' ,--1预付款,2保证金,3预付款和保证金
                     - p_CANCELMONEY,
                     p_currOper,p_currDept,p_retCode,p_retMsg);
                         
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