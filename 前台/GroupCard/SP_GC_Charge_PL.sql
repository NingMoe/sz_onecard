CREATE OR REPLACE PROCEDURE SP_GC_Charge
(
    p_sessionId  varchar2, -- Session ID
    p_groupCode char,    -- Group Code
    p_currOper  char,    -- Current Operator
    p_currDept  char,    -- Current Operator's Department
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_tatalMoney    INT;   -- Total money of charging
    v_amnt          INT;   -- Amount of cards 
    v_tempAmount    INT;
    v_today         date := sysdate;
    v_ex            EXCEPTION;
	v_seqNo         CHAR(16); 
	v_quantity		INT;

BEGIN
    -- 1) Check the v_amount and total money of charging
    SELECT SUM(ChargeAmount), COUNT(*) 
    INTO   v_tatalMoney,  v_amnt
    FROM   TMP_GC_BatchChargeFile  WHERE SessionId = p_sessionId;
    
    IF v_amnt <= 0 THEN
        p_retCode := 'A004P04B01'; p_retMsg  := '没有任何企服卡充值数据需要处理';
        RETURN;
    END IF;

    -- 2) Check whether all the cards belong to the selected group code
    -- SELECT  COUNT(*) INTO v_tempAmount  FROM  TD_GROUP_CARD
    -- WHERE USETAG  = '1'  AND   CORPNO = p_groupCode
    -- AND   CARDNO IN (SELECT CardNo FROM TMP_GC_BatchChargeFile
    --              WHERE SessionId = p_sessionId);
    -- 
    -- IF v_tempAmount != v_amnt THEN
    --     p_retCode := 'A004P04B02'; p_retMsg  := '充值的卡片必须有效地属于同一个集团客户';
    --     RETURN;
    -- END IF;

    SP_GetSeq(seq => v_seqNo);
    
    -- 3) New a tracing record for this batch charging operation
    BEGIN
        INSERT INTO TF_GROUP_SUPPLYSUM
            (  ID    , CORPNO     , SUPPLYMONEY, AMOUNT, 
             SUPPLYSTAFFNO , SUPPLYDEPARTNO, SUPPLYTIME, STATECODE)
        VALUES(v_seqNo, p_groupCode , v_tatalMoney, v_amnt ,
             p_currOper, p_currDept , v_today , '0');
        
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P04B03'; p_retMsg  := '新增企服卡充值总量台帐失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
	--充值后账户余额小于0，则不能提交
	FOR v_curser IN(
		SELECT CardNo,ChargeAmount FROM TMP_GC_BatchChargeFile WHERE SessionId=p_sessionId
	)
	LOOP
		BEGIN
			select t.OFFERMONEY+v_curser.ChargeAmount into v_quantity   
			from TF_F_CARDOFFERACC t  
			where t.cardno=v_curser.CardNo 
			and usetag in ('1','2');
			if v_quantity<0 THEN
			p_retCode := 'SWDXP04B03'; p_retMsg  :=v_curser.cardno|| '充值后企服卡账户余额小于0';
				ROLLBACK; RETURN;
			end if;
		EXCEPTION
			WHEN OTHERS THEN
            p_retCode := 'SWDXP05BX1'; p_retMsg  := v_curser.CardNo||'企服卡账户不存在' || SQLERRM;
            ROLLBACK; RETURN;
		END;
		
		
		
	END LOOP;

    
    -- 4) Create the charging detail
    BEGIN
        INSERT INTO TF_GROUP_SUPPLY
            (  ID    , CARDNO, CORPNO    , SUPPLYMONEY , STATECODE,
            OPERATESTAFFNO, OPERATEDEPARTID,OPERATETIME)
        SELECT v_seqNo, CardNo, p_groupCode, ChargeAmount, '0'      ,
            p_currOper, p_currDept  , v_today
        FROM   TMP_GC_BatchChargeFile  WHERE SessionId = p_sessionId;
        
        IF  SQL%ROWCOUNT != v_amnt THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P04B04'; p_retMsg  := '新增企服卡充值明细台帐失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors
