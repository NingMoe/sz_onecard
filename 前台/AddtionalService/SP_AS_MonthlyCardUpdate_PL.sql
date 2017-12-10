CREATE OR REPLACE PROCEDURE SP_AS_MonthlyCardUpdate
(
    p_ID               char,
    p_cardNo           char,
    p_asn              char,

    p_operCardNo        char,
    p_terminalNo        char,

    p_custName         varchar2,
    p_custSex          varchar2,
    p_custBirth        varchar2,
    p_paperType        varchar2,
    p_paperNo          varchar2,
    p_custAddr         varchar2,
    p_custPost         varchar2,
    p_custPhone        varchar2,
    p_custEmail        varchar2,
    p_remark           varchar2,

    p_appType          char,
    p_assignedArea     char,
    p_needWriteCard    char,

    p_currOper         char,
    p_currDept         char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_ex            exception;
    v_oldAppType    TF_F_CARDCOUNTACC.APPTYPE%type;
    v_seqNo         char(16);

    v_cardType      CHAR(2);
BEGIN

    SP_GetSeq(seq => v_seqNo);

    -- 2) Update cust info
    BEGIN
        UPDATE TF_F_CUSTOMERREC
        SET    CUSTNAME      = nvl(p_custName,CUSTNAME)  ,
               CUSTSEX       = nvl(p_custSex,CUSTSEX)   ,
               CUSTBIRTH     = nvl(p_custBirth,CUSTBIRTH) ,
               PAPERTYPECODE = nvl(p_paperType,PAPERTYPECODE),
               PAPERNO       = nvl(p_paperNo,PAPERNO)   ,
               CUSTADDR      = nvl(p_custAddr ,CUSTADDR) ,
               CUSTPOST      = nvl(p_custPost ,CUSTPOST) ,
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

    BEGIN
        INSERT INTO TF_B_CUSTOMERCHANGE
          (TRADEID,CARDNO,CUSTNAME,CUSTSEX,CUSTBIRTH,PAPERTYPECODE,
           PAPERNO,CUSTADDR,CUSTPOST,CUSTPHONE,CUSTEMAIL,REMARK,
           CHGTYPECODE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
          (v_seqNo,p_cardNo,p_custName,p_custSex,p_custBirth,p_paperType,
           p_paperNo,p_custAddr,p_custPost,p_custPhone,p_custEmail,p_remark,
           '01',p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00513B002'; p_retMsg  := '新增客户资料变更台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 3) Update monthly info of oldcard
    BEGIN
        SELECT APPTYPE INTO v_oldAppType FROM TF_F_CARDCOUNTACC WHERE CARDNO = p_cardNo;
        UPDATE TF_F_CARDCOUNTACC
        SET   APPTYPE       = p_appType     ,
              ASSIGNEDAREA  = p_assignedArea,
              UPDATESTAFFNO = p_currOper    ,
              UPDATETIME    = v_today
        WHERE CARDNO        = p_cardNo;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00513B003'; p_retMsg  := '更新月票卡资料失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;


    SELECT CARDTYPECODE INTO v_cardType FROM TL_R_ICUSER WHERE CARDNO = p_cardNo;

    -- 6) Log the operation
    BEGIN
        INSERT INTO TF_B_TRADE
            (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
            (v_seqNo,p_ID,'77',p_cardNo,p_asn,v_cardType,
            p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00513B006'; p_retMsg  := '新增月票卡资料更新台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 7) Log card change
    if p_needWriteCard = 'y' then
        BEGIN
            INSERT INTO TF_CARD_TRADE
                (TRADEID, TRADETYPECODE, strOperCardNo, strCardNo, strTermno, strFlag, OPERATETIME)
            VALUES(v_seqNo, '77', p_operCardNo, p_cardNo, p_terminalNo, 
            p_assignedArea || decode(p_custSex, '0', 'C1', 'C0'), v_today);
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S00513B007'; p_retMsg  := '新增月票卡资料更新卡片交易台帐失败,' || SQLERRM;
            ROLLBACK; RETURN;
        END;
    end if;

    if v_oldAppType != p_appType then
        --  更新功能项
        BEGIN
            UPDATE TF_F_CARDUSEAREA
            SET    FUNCTIONTYPE  = decode(p_appType, '01', '03', '02', '04', '03', '05', '04' , '09', '05', '06','06','15'),
                   UPDATESTAFFNO = p_currOper , UPDATETIME    = v_today
            WHERE  CARDNO = p_cardNo 
            AND    FUNCTIONTYPE  = decode(v_oldAppType, '01', '03', '02', '04', '03', '05', '04' , '09', '05', '06','06','15');

            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S00511B008'; p_retMsg  := '更新卡片与学生月票卡功能项关联关系失败,' || SQLERRM;
            ROLLBACK; RETURN;
        END;
    end if;
    
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors
