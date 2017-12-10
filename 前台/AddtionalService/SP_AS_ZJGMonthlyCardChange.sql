
--wdx 20111117
CREATE OR REPLACE PROCEDURE SP_AS_ZJGMonthlyCardChange
(
    p_ID                  char,
    p_custRecTypeCode     char,
    p_cardCost            int,
    p_newCardNo           char,
    p_oldCardNo           char,
    p_cardTradeNo         char,
    p_checkStaffNo        char,
    p_checkDeptNo         char,
    p_changeCode          char,
    p_asn                 char,

    p_sellChannelCode     char,
    p_tradeTypeCode       char,
    p_deposit             int,
    p_serStartTime        date,
    p_serviceMoney        int,
    p_cardAccMoney        int,
    p_newSersTakeTag      char,
    p_supplyRealMoney     int,
    p_totalSupplyMoney    int,
    p_oldDeposit          int,
    p_sersTakeTag         char,
    p_preMoney            int,
    p_nextMoney           int,
    p_currentMoney        int,
    p_appType             char,--月票类型
    p_assignedArea        char,
    p_custSex             char,
    p_terminalNo        char,
    p_operateCard         char,
    p_currOper            char,
    p_currDept            char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_cardType CHAR(2);
    v_today    date;
    v_seqNo    char(16);
    v_seqNo2   char(16);
    v_fnType   CHAR(2);
    v_ex       exception;
BEGIN

   

    -- 2) Update monthly info of oldcard
    BEGIN
        UPDATE TF_F_CARDCOUNTACC
        SET    USETAG        = '0',
               UPDATESTAFFNO = p_currOper,
               UPDATETIME    = v_today
        WHERE   CARDNO       = p_oldCardNo;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00512B001'; p_retMsg  := '更新旧卡月票卡资料失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 3) Insert a row of monthly info
    BEGIN
        INSERT INTO TF_F_CARDCOUNTACC
            (CARDNO,APPTYPE,ASSIGNEDAREA,APPTIME,ENDTIME,APPSTAFFNO,USETAG,
            UPDATESTAFFNO,UPDATETIME)
		SELECT p_newCardNo,APPTYPE,ASSIGNEDAREA,v_today,ENDTIME,p_currOper,'1',p_currOper,v_today
		FROM TF_F_CARDCOUNTACC
		WHERE CARDNO = p_oldCardNo;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00512B002'; p_retMsg  := '新增新卡月票卡资料失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;


    -- 5) Setup the relation between cards and features.
    select decode(p_appType, '11', '10', '12', '11','16', '13','17','16')  into v_fnType from dual;

    BEGIN
        INSERT INTO TF_F_CARDUSEAREA
              (CARDNO    , FUNCTIONTYPE, USETAG, UPDATESTAFFNO , UPDATETIME)
        VALUES(p_newCardNo, v_fnType     , '1'   , p_currOper, v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00512B004'; p_retMsg  := '新增卡片与月票功能项之间的关联关系失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    BEGIN
        UPDATE TF_F_CARDUSEAREA
        SET    USETAG        = '0'       ,
               UPDATESTAFFNO = p_currOper , UPDATETIME    = v_today
        WHERE  CARDNO = p_oldCardNo AND FUNCTIONTYPE = v_fnType;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00512B005'; p_retMsg  := '关闭卡片与月票卡功能项关联关系失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors
