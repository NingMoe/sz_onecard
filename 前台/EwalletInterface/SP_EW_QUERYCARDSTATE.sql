CREATE OR REPLACE PROCEDURE SP_EW_QUERYCARDSTATE
(
    p_CARDNO            CHAR,  --卡号
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message
)
AS
    V_CARDACCMONEY      INT;
    V_FIRSTSUPPLYTIME   DATE;
    V_COUNT             INT;
BEGIN
    --查询卡账户表
    BEGIN
        SELECT CARDACCMONEY,FIRSTSUPPLYTIME INTO V_CARDACCMONEY,V_FIRSTSUPPLYTIME FROM TF_F_CARDEWALLETACC WHERE CARDNO = p_CARDNO;
    EXCEPTION WHEN NO_DATA_FOUND THEN
        V_CARDACCMONEY := '';
        V_FIRSTSUPPLYTIME := '';
    END;

    IF (V_CARDACCMONEY <> 0) OR (V_FIRSTSUPPLYTIME IS NOT NULL) THEN
        p_retCode := 'S094570091';
        p_retMsg  := '此卡已做过充值';
        RETURN;
    END IF;
    --判断是否开通月票
    SELECT COUNT(*) INTO V_COUNT FROM TF_F_CARDCOUNTACC WHERE CARDNO = p_CARDNO;
    IF V_COUNT > 0 THEN
        p_retCode := 'S094570092';
        p_retMsg  := '此卡已开通月票';
        RETURN;
    END IF;
    --判断是否开通园林年卡
    SELECT COUNT(*) INTO V_COUNT FROM TF_F_CARDPARKACC_SZ WHERE CARDNO = p_CARDNO;
    IF V_COUNT > 0 THEN
        p_retCode := 'S094570093';
        p_retMsg  := '此卡已开通园林年卡';
        RETURN;
    END IF;
    --判断是否开通休闲年卡
    SELECT COUNT(*) INTO V_COUNT FROM TF_F_CARDXXPARKACC_SZ WHERE CARDNO = p_CARDNO;
    IF V_COUNT > 0 THEN
        p_retCode := 'S094570094';
        p_retMsg  := '此卡已开通休闲年卡';
        RETURN;
    END IF;

    --判断是否开通专有账户
    SELECT COUNT(*) INTO V_COUNT FROM TF_F_CUST_ACCT WHERE ICCARD_NO = p_CARDNO;
    IF V_COUNT > 0 THEN
        p_retCode := 'S094570096';
        p_retMsg  := '此卡已开通专有账户';
        RETURN;
    END IF;

    --查询主台账
    FOR V_CUR IN(SELECT TRADETYPECODE FROM TF_B_TRADE WHERE CARDNO = p_CARDNO)
    LOOP
        IF (V_CUR.TRADETYPECODE IS NOT NULL AND V_CUR.TRADETYPECODE <> '01' AND V_CUR.TRADETYPECODE <> 'A1') THEN --不是售卡业务类型
            p_retCode := 'S094570097';
            p_retMsg  := '此卡已做过领卡之外的操作';
            RETURN;
        END IF;
    END LOOP;

    p_retCode := '0000000000';
    p_retMsg  := '成功';
    RETURN;
END;

/
show errors   