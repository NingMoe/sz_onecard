CREATE OR REPLACE PROCEDURE SP_GC_OpenFiApproval
(
    p_sessionId  varchar2, -- Session ID
    p_stateCode char, -- '2' Fi Approved, '3' Rejected
    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
	v_smkCount		INT;
    v_today         date := sysdate;
    v_quantity      INT;
    v_batchQty      INT;
    v_ex            EXCEPTION;
    v_hadpass       VARCHAR2(1000):='';
    v_hadcancel     VARCHAR2(1000):='';
    v_hadpassnum    INT:=0;
    v_hadcancelnum  INT:=0;
    v_statecode     char(1);
BEGIN
    -- 1) Check the state code 
    IF NOT (p_stateCode = '2' OR p_stateCode = '3') THEN
        p_retCode := 'A004P03B01'; p_retMsg  := '状态码必须是''2'' (财务审核通过) or ''3'' (作废)';
        RETURN;
    END IF;

    -- 2) Update the tracing record
    SELECT COUNT(*) INTO v_batchQty FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId;
    IF v_batchQty is null or v_batchQty <= 0 THEN
        p_retCode := 'A004P01BX1'; p_retMsg  := '没有任何企服卡开卡数据需要处理';
        RETURN;
    END IF;
    
    SELECT  SUM(AMOUNT) INTO v_quantity FROM TF_GROUP_SELLSUM
    WHERE ID IN 
        (SELECT BatchNo FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId);    
    IF v_quantity is null or v_quantity <= 0 THEN
        p_retCode := 'A004P01BX1'; p_retMsg  := '没有任何企服卡开卡数据需要处理';
        RETURN;
    END IF;
	
	--判断是否已经审核通过或作废
	BEGIN
		FOR V_CUR IN (SELECT BatchNo FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId)
		LOOP
		--查询批次状态
		SELECT STATECODE INTO v_statecode FROM TF_GROUP_SELLSUM WHERE ID = V_CUR.BatchNo;
		--如果审核通过
		IF v_statecode = '2' THEN
		    v_hadpassnum := v_hadpassnum +1;
			v_hadpass := v_hadpass||V_CUR.BatchNo||',';
		END IF;
		--如果审核作废
		IF v_statecode = '3' THEN
		    v_hadcancelnum := v_hadcancelnum +1;
			v_hadcancel := v_hadcancel||V_CUR.BatchNo||',';
		END IF;
		END LOOP;
		
		--去掉结尾的逗号
		v_hadpass := trim (trailing ',' from v_hadpass);
		v_hadcancel := trim (trailing ',' from v_hadcancel);
		
		--如果有审核通过的记录
		IF v_hadpassnum > 0 THEN
		    p_retCode := 'S094570231';
		    p_retMsg :=v_hadpass||'批次开卡企服卡已经财务审核通过' ;
		    --如果没有审核作废的记录则返回
		    IF v_hadcancelnum = 0 THEN
		        RETURN;
		    END IF;
		END IF;
		--如果有审核作废的记录
		IF v_hadcancelnum > 0 THEN
		    p_retCode := 'S094570232';
			IF v_hadpassnum > 0 THEN
				p_retMsg :=p_retMsg||','||v_hadcancel||'批次开卡企服卡已经作废' ;
				RETURN;
			ELSE
				p_retMsg :=v_hadcancel||'批次开卡企服卡已经作废' ;
				RETURN;
			END IF;
		END IF;
	END;
    
            
    BEGIN
        UPDATE TF_GROUP_SELLSUM    
        SET EXAMSTAFFNO = p_currOper, 
            EXAMTIME    = v_today   , 
            STATECODE   = p_stateCode 
        WHERE STATECODE = '1'
        AND ID IN 
            (SELECT BatchNo FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId);
            
        IF  SQL%ROWCOUNT != v_batchQty THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P03B02'; p_retMsg  := '更新企服卡开卡总量台帐失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    IF p_stateCode = '3'  THEN -- Rejected By Finance
        p_retCode := '0000000000';
        p_retMsg  := '';
        COMMIT; RETURN;
    END IF;

    -- 3) Setup the relation between card and group
    BEGIN
        INSERT INTO TD_GROUP_CARD(CARDNO, CORPNO, USETAG, UPDATESTAFFNO, UPDATETIME)
        SELECT CARDNO, CORPNO, '1'   , p_currOper, v_today FROM TF_B_TRADE
        WHERE  TRADEID IN 
            (SELECT BatchNo FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId);
        
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P03B03'; p_retMsg  := '新增卡片与集团客户关联关系失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    --  ) Setup the accounts for the group cards
    BEGIN
        INSERT INTO TF_F_CARDOFFERACC (CARDNO, OFFERMONEY, USETAG, PASSWD  , 
            BEGINTIME, ENDTIME, TOTALSUPPLYTIMES, TOTALSUPPLYMONEY)
        SELECT CARDNO, 0  , '1'   , '0.0-000*0/0.', v_today, to_date('2050-12-31', 'YYYY-MM-DD'), 0, 0
        FROM   TF_B_TRADE
        WHERE  TRADEID IN 
            (SELECT BatchNo FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId);
        
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P03B04'; p_retMsg  := '新增卡片企服卡帐户失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
	
	--获取同一个批次号里市民卡的数量 市民卡不能更新客户资料
	BEGIN
		SELECT COUNT(a.CARDNO) INTO v_smkCount FROM TF_B_CUSTOMERCHANGE a
			WHERE SUBSTR(a.CARDNO,5,2) = '18' AND a.TRADEID IN 
                    (SELECT b.BatchNo FROM TMP_GC_BatchNoList b
                     WHERE b.SessionId = p_sessionId);
	END;

    -- 4) Update the customers' basic information
    BEGIN
        merge into TF_F_CUSTOMERREC a
        using      TF_B_CUSTOMERCHANGE b
        on         (a.CARDNO = b.CARDNO
                   and SUBSTR(b.CARDNO,5,2) != '18' and b.TRADEID IN 
                    (SELECT BatchNo FROM TMP_GC_BatchNoList 
                     WHERE SessionId = p_sessionId))
        when matched then
        update set    
                a.CUSTNAME      = b.CUSTNAME , 
                a.CUSTSEX       = b.CUSTSEX  , 
                a.CUSTBIRTH     = b.CUSTBIRTH,
                a.PAPERTYPECODE = b.PAPERTYPECODE, 
                a.PAPERNO       = b.PAPERNO  ,
                a.CUSTADDR      = b.CUSTADDR , 
                a.CUSTPOST      = b.CUSTPOST , 
                a.CUSTPHONE     = b.CUSTPHONE, 
                a.CUSTEMAIL     = b.CUSTEMAIL, 
                a.UPDATESTAFFNO = p_currOper , 
                a.UPDATETIME    = v_today    ;

        IF  SQL%ROWCOUNT + v_smkCount != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P03B05'; p_retMsg  := '更新客户资料失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
            
    -- 5) Setup the relation between cards and features.
    BEGIN
        INSERT INTO TF_F_CARDUSEAREA
              (CARDNO, FUNCTIONTYPE, USETAG, UPDATESTAFFNO , UPDATETIME)
        SELECT CARDNO, '01'        , '1'   , p_currOper, v_today
        FROM   TF_B_TRADE
        WHERE  TRADEID IN 
            (SELECT BatchNo FROM TMP_GC_BatchNoList WHERE SessionId = p_sessionId);
 
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P03B06'; p_retMsg  := '新增卡片与企服卡功能项的关联关系,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
 
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors
