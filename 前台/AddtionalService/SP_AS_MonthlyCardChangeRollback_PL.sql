CREATE OR REPLACE PROCEDURE SP_AS_MonthlyCardChangeRo
(
    p_ID                  char,
    p_cardNo              char,
    p_cardTradeNo         char,

    p_cancelTradeId       char,

    p_terminalNo          char,

    p_currCardNo          char,
    p_currOper            char,
    p_currDept            char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today    date := sysdate;
    v_seqNo    char(16);
    v_fnType   CHAR(2);
    v_appType  TF_F_CARDCOUNTACC.APPTYPE%type;
    v_ex       exception;
    
    v_oldCardNo    TF_B_TRADE.OLDCARDNO%type;
    v_sersTakeTag  TF_B_TRADE.SERSTAKETAG%type;
    v_reasonCode   TF_B_TRADE.REASONCODE%type;
    v_cardState    TF_B_TRADE.CARDSTATE%type;
    v_tradeProcFee TF_B_TRADEFEE.TRADEPROCFEE%type;
    v_otherFee     TF_B_TRADEFEE.OTHERFEE%type;
	v_tradeFee    int DEFAULT 0;
	V_FEETYPE	  CHAR(1);
    
BEGIN
	BEGIN
	    SELECT OLDCARDNO  , SERSTAKETAG  , REASONCODE  , CARDSTATE  
	    INTO   v_oldCardNo, v_sersTakeTag, v_reasonCode, v_CARDSTATE
	    FROM   TF_B_TRADE
	    WHERE  TRADEID = p_cancelTradeId;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00515B001'; p_retMsg  := '查询换卡台帐信息失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
	
	BEGIN
	    SELECT TRADEPROCFEE  ,  OTHERFEE
	    INTO   v_tradeProcFee,  v_otherFee
	    FROM   TF_B_TRADEFEE
	    WHERE  TRADEID = p_cancelTradeId;
    EXCEPTION 
	WHEN NO_DATA_FOUND THEN
		v_tradeProcFee := 0;
		v_otherFee := 0;
	WHEN OTHERS THEN
        p_retCode := 'S00515B002'; p_retMsg  := '查询换卡费用信息失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
	
 
    
    -- 1) Execute procedure SP_PB_ChangeCard
    SP_PB_ChangeCardRollback(
        p_ID           ,    v_oldCardNo      , p_cardNo         , '04', p_cancelTradeId   ,
        v_reasonCode   ,    p_cardTradeNo    , v_tradeProcFee   , v_otherFee        ,    
        v_cardState    ,    v_sersTakeTag    , p_terminalNo     , p_currCardNo      ,
        v_seqNo        ,    p_currOper       , p_currDept       , p_retCode         ,
        p_retMsg       );

    IF p_retCode != '0000000000' THEN
        ROLLBACK; RETURN;
    END IF;

    -- 2) Update monthly info of oldcard
    
    BEGIN
        UPDATE TF_F_CARDCOUNTACC
        SET    USETAG        = '1',
               UPDATESTAFFNO = p_currOper,
               UPDATETIME    = v_today
        WHERE   CARDNO       = v_oldCardNo;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00515B003'; p_retMsg  := '更新旧卡月票卡资料失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 3) Insert a row of monthly info
    BEGIN
        DELETE FROM TF_F_CARDCOUNTACC WHERE CARDNO = p_cardNo;
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
     EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00515B004'; p_retMsg  := '删除新卡月票卡资料失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 4) Log card change
    BEGIN
        UPDATE TF_CARD_TRADE
        SET    strFlag = '02FF'
        WHERE  TRADEID = v_seqNo;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00515B005'; p_retMsg  := '更新月票卡换卡卡内交易台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;


    BEGIN
        DELETE FROM TF_F_CARDUSEAREA WHERE CARDNO = p_cardNo;
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00515B006'; p_retMsg  := '删除卡片与月票功能项之间的关联关系失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    
    BEGIN
		SELECT APPTYPE INTO v_appType
	    FROM   TF_F_CARDCOUNTACC
	    WHERE  CARDNO = v_oldCardNo;

	    select decode(v_appType, '01', '03', '02', '04', '03', '05','04','09') into v_fnType from dual;
		
        UPDATE TF_F_CARDUSEAREA
        SET    USETAG        = '1'       ,
               UPDATESTAFFNO = p_currOper , UPDATETIME    = v_today
        WHERE  CARDNO = v_oldCardNo AND FUNCTIONTYPE = v_fnType;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00515B007'; p_retMsg  := '恢复卡片与月票卡功能项关联关系失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
	
	 -- 代理营业厅根据保证金修改可领卡额度，add by liuhe 20111230
	IF v_reasonCode = '12' OR v_reasonCode = '14' 
		THEN V_FEETYPE := '3';
		
		BEGIN
			SELECT  -CARDDEPOSITFEE - CARDSERVFEE INTO v_tradeFee
			FROM TF_B_TRADEFEE
			WHERE TRADEID = p_CANCELTRADEID;

		EXCEPTION
		WHEN NO_DATA_FOUND THEN
			p_retCode := 'S001009101';
			p_retMsg  := '没有从现金台账表取到数据' || SQLERRM;
			ROLLBACK; RETURN;
		END;
		
	ELSE  V_FEETYPE := '2';
	END IF;
   
	BEGIN
		  SP_PB_DEPTBALFEEROLLBACK(v_seqNo, p_CANCELTRADEID,
					V_FEETYPE ,--1预付款,2保证金,3预付款和保证金
					 v_tradeFee,
					 p_currOper,p_currDept,p_retCode,p_retMsg);
		
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
