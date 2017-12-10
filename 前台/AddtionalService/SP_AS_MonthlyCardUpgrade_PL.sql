CREATE OR REPLACE PROCEDURE SP_AS_MonthlyCardUpgrade
(
    p_ID               char,
    p_cardNo           char,
    p_deposit          int,
    p_cardCost         int,
    p_otherFee         int,
    p_cardTradeNo      char,
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

    p_assignedArea     char,

    p_currOper         char,
    p_currDept         char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_ex            exception;
    v_seqNo         char(16);
    v_eldDeposit    int;
    v_cardType      CHAR(2);
BEGIN

    SP_GetSeq(seq => v_seqNo);

    -- 2) Update cust info 不是市民卡才允许修改客户资料
	IF SUBSTR(p_cardNo,5,2) != '18' THEN	
		BEGIN
			UPDATE TF_F_CUSTOMERREC
			SET    CUSTNAME      = nvl(p_custName,CUSTNAME)  ,
				   CUSTSEX       = nvl(p_custSex,CUSTSEX)   ,
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
			p_retCode := 'S00511B001'; p_retMsg  := '更新客户资料失败,' || SQLERRM;
			ROLLBACK; RETURN;
		END;
	END IF;

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
        p_retCode := 'S00511B002'; p_retMsg  := '新增客户资料变更台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 3) Update monthly info of oldcard
    BEGIN
        UPDATE TF_F_CARDCOUNTACC
        SET   APPTYPE       = '03',
              ASSIGNEDAREA  = p_assignedArea,
              UPDATESTAFFNO = p_currOper,
              UPDATETIME    = v_today
        WHERE CARDNO        = p_cardNo;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00511B003'; p_retMsg  := '更新月票卡资料失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    SELECT BASEFEE INTO v_eldDeposit
    FROM TD_M_TRADEFEE
    WHERE TRADETYPECODE = '23' AND FEETYPECODE = '00';

    -- 4) Modify Card p_deposit
    BEGIN
        UPDATE TF_F_CARDREC
        SET   DEPOSIT       = v_eldDeposit,
              UPDATESTAFFNO = p_currOper,
              UPDATETIME    = v_today
        WHERE CARDNO        = p_cardNo;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00511B004'; p_retMsg  := '更新卡片押金失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 5) Log the cash
    BEGIN
        INSERT INTO TF_B_TRADEFEE
            (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,CARDSERVFEE,CARDDEPOSITFEE,OTHERFEE,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
            (p_ID, v_seqNo, '76', p_cardNo, p_cardTradeNo, p_cardCost, p_deposit, p_otherFee,
            p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00511B005'; p_retMsg  := '新增月票卡升级现金台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    SELECT CARDTYPECODE INTO v_cardType FROM TL_R_ICUSER WHERE CARDNO = p_cardNo;

    -- 6) Log the operation
    BEGIN
        INSERT INTO TF_B_TRADE
            (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CURRENTMONEY,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
            (v_seqNo,p_ID,'76',p_cardNo,p_asn,v_cardType,p_cardCost+p_deposit,
            p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00511B006'; p_retMsg  := '新增月票卡升级台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 7) Log card change
    BEGIN
        INSERT INTO TF_CARD_TRADE
            (TRADEID, TRADETYPECODE, strOperCardNo, strCardNo, strTermno, strFlag, OPERATETIME)
        VALUES(v_seqNo, '76', p_operCardNo, p_cardNo, p_terminalNo, 
        p_assignedArea || decode(p_custSex, '0', 'C1', 'C0'), v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00511B007'; p_retMsg  := '新增月票卡升级卡片交易台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 8) 更新功能项
    BEGIN
        UPDATE TF_F_CARDUSEAREA
        SET    FUNCTIONTYPE  = '05'      ,
               UPDATESTAFFNO = p_currOper , UPDATETIME    = v_today
        WHERE  CARDNO = p_cardNo AND FUNCTIONTYPE = '04';

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00511B008'; p_retMsg  := '更新卡片与老人月票卡功能项关联关系失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors
