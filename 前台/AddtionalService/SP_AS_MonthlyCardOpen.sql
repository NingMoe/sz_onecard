CREATE OR REPLACE PROCEDURE SP_AS_MonthlyCardOpen
(
    p_ID                  char,
    p_cardNo              char,
    p_deposit             int,
    p_cardCost            int,
    p_otherFee            int,
    p_cardTradeNo         char,
   -- p_asn                 char,
    p_cardMoney           int,
    --p_sellChannelCode     char,
   -- p_serTakeTag          char,
    p_tradeTypeCode       char,

    p_terminalNo          char,

    p_custName            varchar2,
    p_custSex             varchar2,
    p_custBirth           varchar2,
    p_paperType           varchar2,
    p_paperNo             varchar2,
    p_custAddr            varchar2,
    p_custPost            varchar2,
    p_custPhone           varchar2,
    p_custEmail           varchar2,
    p_remark              varchar2,

    p_custRecTypeCode     char,
    p_appType             char,
    p_assignedArea        char,
    --p_currCardNo          char,
    p_currOper            char,
    p_currDept            char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_ex            exception;
    v_seqNo         char(16);
    v_cardType      CHAR(2);
    v_fnType        CHAR(2);
    v_TradeID       char(16);
    v_ASN              char(16);

BEGIN

    SELECT CARDTYPECODE INTO v_cardType FROM TL_R_ICUSER WHERE CARDNO = p_cardNo;

    -- 3) Get initialize info
    SELECT ASN INTO v_ASN
    FROM TL_R_ICUSER
    WHERE CARDNO = p_cardNo;
    
    -- 7) Get trade id
    SP_GetSeq(seq => v_TradeID);
    --p_TRADEID := v_TradeID;    

    -- 8) Log operation
    BEGIN
            INSERT INTO TF_B_TRADE
                (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,
            CARDTRADENO,CURRENTMONEY,PREMONEY,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,RSRV2)
            VALUES
                (v_TradeID,p_ID,p_TRADETYPECODE,p_CARDNO,v_ASN,v_cardType,
            p_CARDTRADENO,p_DEPOSIT+p_CARDCOST,p_CARDMONEY,
                p_currOper,p_currDept,sysdate,p_appType);

        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001001107';
                p_retMsg  := 'Fail to log the operation' || SQLERRM;
                ROLLBACK; RETURN;
    END;

    -- 11) Log the writeCard
    BEGIN
            INSERT INTO TF_CARD_TRADE
                    (TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,strTermno,OPERATETIME,SUCTAG)
            VALUES
                    (v_TradeID,p_TRADETYPECODE,p_terminalNo,p_CARDNO,p_custRecTypeCode,sysdate,'0');

        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001001139';
                p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
                ROLLBACK; RETURN;
    END;

    -- 2) Insert a row of monthly info
    BEGIN
        merge into TF_F_CARDCOUNTACC t using dual
        on (t.CARDNO = p_cardNo)
        when matched then update set 
            t.APPTYPE = p_appType,
            t.ASSIGNEDAREA = p_assignedArea,
            t.APPTIME = v_today,
            t.APPSTAFFNO = p_currOper,
            t.USETAG = '1',
            t.UPDATESTAFFNO = p_currOper,
            t.UPDATETIME = v_today
        when not matched then         
          INSERT 
            (CARDNO,APPTYPE,ASSIGNEDAREA,APPTIME,APPSTAFFNO,USETAG,UPDATESTAFFNO,UPDATETIME)
            VALUES
                (p_cardNo,p_appType,p_assignedArea,v_today,p_currOper,'1',p_currOper,v_today);        
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00509B001'; p_retMsg  := '新增月票卡资料失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    BEGIN
        UPDATE  TF_F_CARDREC
        SET 
            SERSTAKETAG     = '3',
            UPDATESTAFFNO   = P_CURROPER,
            UPDATETIME      = V_TODAY
        WHERE CARDNO = P_CARDNO ;

        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S00504fB907'; P_RETMSG  := '更新卡资料表服务收取标识失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    
    -- 3) Log card change
    BEGIN
        UPDATE TF_CARD_TRADE
        SET    strFlag = p_assignedArea || decode(p_custSex, '0', 'C1', 'C0')
        WHERE  TRADEID = v_TradeID;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00509B002'; p_retMsg  := '更新月票卡售卡卡片交易台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 4) Setup the relation between cards and features.
    select decode(p_appType, '01', '03', '02', '04', '03', '05' , '04' , '09', '05' , '06','06','15') into v_fnType from dual;

    BEGIN
        merge into TF_F_CARDUSEAREA t using dual
        on (t.CARDNO = p_cardNo and t.FUNCTIONTYPE=v_fnType)
        when matched then update set 
            t.UPDATETIME = v_today,
            t.USETAG = '1',
            t.UPDATESTAFFNO = p_currOper
        when not matched then         
          INSERT 
            (CARDNO , FUNCTIONTYPE, USETAG, UPDATESTAFFNO , UPDATETIME)
        VALUES(p_cardNo, v_fnType     , '1'   , p_currOper, v_today); 

    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00509B003'; p_retMsg  := '新增卡片与月票卡功能项关联关系失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

  -- 2) Update cust info 不是市民卡才允许修改客户资料
    IF SUBSTR(p_cardNo,5,2) != '18' THEN    
        BEGIN
            UPDATE TF_F_CUSTOMERREC
            SET    CUSTNAME      = nvl(p_custName ,CUSTNAME) ,
                   CUSTSEX       = nvl(p_custSex ,CUSTSEX)  ,
                   CUSTBIRTH     = nvl(p_custBirth,CUSTBIRTH) ,
                   PAPERTYPECODE = nvl(p_paperType,PAPERTYPECODE) ,
                   PAPERNO       = nvl(p_paperNo,PAPERNO)   ,
                   CUSTADDR      = nvl(p_custAddr,CUSTADDR)  ,
                   CUSTPOST      = nvl(p_custPost,CUSTPOST)  ,
                   CUSTPHONE     = nvl(p_custPhone,CUSTPHONE) ,
                   CUSTEMAIL     = nvl(p_custEmail,CUSTEMAIL) ,
                   REMARK        = nvl(p_remark,REMARK)    ,
                   UPDATESTAFFNO = p_currOper  ,
                   UPDATETIME    = v_today
            WHERE  CARDNO        = p_cardNo;

            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S00513B001'; p_retMsg  := '更新客户资料失败,' || SQLERRM;
            ROLLBACK; RETURN;
        END;
    END IF;

    BEGIN
        INSERT INTO TF_B_CUSTOMERCHANGE
          (TRADEID,CARDNO,CUSTNAME,CUSTSEX,CUSTBIRTH,PAPERTYPECODE,
           PAPERNO,CUSTADDR,CUSTPOST,CUSTPHONE,CUSTEMAIL,REMARK,
           CHGTYPECODE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
          (v_TradeID,p_cardNo,p_custName,p_custSex,p_custBirth,p_paperType,
           p_paperNo,p_custAddr,p_custPost,p_custPhone,p_custEmail,p_remark,
           '01',p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00513B002'; p_retMsg  := '新增客户资料变更台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/
SHOW ERRORS