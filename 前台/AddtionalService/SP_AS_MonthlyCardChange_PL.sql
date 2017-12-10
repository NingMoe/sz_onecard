CREATE OR REPLACE PROCEDURE SP_AS_MonthlyCardChange
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
    p_appType             char,
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
	V_FEETYPE	  CHAR(1);
BEGIN

    SELECT CARDTYPECODE INTO v_cardType FROM TL_R_ICUSER WHERE CARDNO = p_newCardNo;

    -- 1) Execute procedure SP_PB_ChangeCard
    SP_PB_ChangeCard(
        p_ID           ,    p_custRecTypeCode, p_cardCost       , p_newCardNo       ,
        p_oldCardNo    ,    p_cardTradeNo    , p_checkStaffNo   , p_checkDeptNo     ,
        p_changeCode   ,    p_asn            , v_cardType       , p_sellChannelCode ,
        p_tradeTypeCode,    p_deposit        , p_serStartTime   , p_serviceMoney    ,
        p_cardAccMoney ,    p_newSersTakeTag , p_supplyRealMoney, p_totalSupplyMoney,
        p_oldDeposit   ,    p_sersTakeTag    , p_preMoney       , p_nextMoney       ,
        p_currentMoney ,    p_terminalNo     , p_operateCard    , v_today           ,
        v_seqNo, v_seqNo2,  p_currOper       , p_currDept       , p_retCode         ,
        p_retMsg       );

    IF p_retCode != '0000000000' THEN
        ROLLBACK; RETURN;
    END IF;

    -- 2) Update monthly info of oldcard
    BEGIN
        UPDATE TF_F_CARDCOUNTACC
        SET    USETAG        = '0',
               UPDATESTAFFNO = p_currOper,
               UPDATETIME    = v_today
        WHERE   CARDNO       = p_oldCardNo
		AND USETAG='1';

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00512B001'; p_retMsg  := '���¾ɿ���Ʊ������ʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 3) Insert a row of monthly info
    BEGIN
        INSERT INTO TF_F_CARDCOUNTACC
            (CARDNO,APPTYPE,ASSIGNEDAREA,APPTIME,APPSTAFFNO,USETAG,
            UPDATESTAFFNO,UPDATETIME)
        VALUES
            (p_newCardNo,p_appType,p_assignedArea,v_today,p_currOper,'1',
            p_currOper,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00512B002'; p_retMsg  := '�����¿���Ʊ������ʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    BEGIN
        UPDATE TF_F_CUSTOMERREC SET CUSTSEX = nvl(p_custSex,CUSTSEX) where CARDNO = p_newCardNo;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00512B0X2'; p_retMsg  := '���¿ͻ������е��Ա����,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
        

    -- 4) Log card change
    BEGIN
        UPDATE TF_CARD_TRADE
        SET    strFlag = p_assignedArea || decode(p_custSex, '0', 'C1', 'C0')
        WHERE  TRADEID = v_seqNo;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00512B003'; p_retMsg  := '������Ʊ���������ڽ���̨��ʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 5) Setup the relation between cards and features.
    select decode(p_appType, '01', '03', '02', '04', '03', '05','04','09') into v_fnType from dual;


    BEGIN
        INSERT INTO TF_F_CARDUSEAREA
              (CARDNO    , FUNCTIONTYPE, USETAG, UPDATESTAFFNO , UPDATETIME)
        VALUES(p_newCardNo, v_fnType     , '1'   , p_currOper, v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00512B004'; p_retMsg  := '������Ƭ����Ʊ������֮��Ĺ�����ϵʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    BEGIN
        UPDATE TF_F_CARDUSEAREA
        SET    USETAG        = '0'       ,
               UPDATESTAFFNO = p_currOper , UPDATETIME    = v_today
        WHERE  CARDNO = p_oldCardNo AND FUNCTIONTYPE = v_fnType;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00512B005'; p_retMsg  := '�رտ�Ƭ����Ʊ�������������ϵʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

	-- ����Ӫҵ�����ݱ�֤���޸Ŀ��쿨��ȣ�add by liuhe 20120104
   IF p_CHANGECODE = '12' OR p_CHANGECODE = '14' THEN V_FEETYPE := '3';
   ELSE  V_FEETYPE := '2';
   END IF;
   BEGIN
			  SP_PB_DEPTBALFEE(v_seqNo, V_FEETYPE ,--1Ԥ����,2��֤��,3Ԥ����ͱ�֤��
							 p_CARDCOST + p_DEPOSIT,
							 v_today,p_currOper,p_currDept,p_retCode,p_retMsg);

			 IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
				EXCEPTION
				WHEN OTHERS THEN
					ROLLBACK; RETURN;
	END;
	
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors
