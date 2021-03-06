CREATE OR REPLACE PROCEDURE SP_AS_RelaxCardNewRollback
(
    p_ID                char,
    p_cardNo            char,
    p_cardTradeNo       char,
    p_asn               char,

    p_operCardNo        char,
    p_terminalNo        char,
    p_oldEndDateNum     char,
    p_endDateNum    out char,
    p_cancelTradeId in out char,
    p_option            char, -- 0 - commit with check 1 - commit w/o check 2 - only check w/o commit
	p_XFCardNo			char,
	
	p_paperType         varchar2,		--证件类型
	p_passPaperNo		varchar2,		--加*的证件号码
	p_passCustName		varchar2,		--加*的姓名
	p_CITYCODE			char,

    p_currOper          char,
    p_currDept          char,
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message
)
AS
    v_today             date := sysdate;
    v_seqNo             char(16);
    v_opTime            date := null;
    v_openEndDateNum    char(12);
    v_cancelCode        char(2);
	v_RSRV2				char(2);
	v_RSRV3				char(1);
	v_tradeFee          int;
	v_endDate			char(8);
	v_accounttype		char(1);
	v_packageTypeCode	char(2);
	v_spareTimes		int;
  v_ex          exception;
BEGIN
    if p_option in ('0', '2') then
        for v_cur in
        (
            SELECT * FROM TF_B_TRADE
            WHERE  CARDNO = p_cardNo
            AND    OPERATETIME BETWEEN ADD_MONTHS(SYSDATE, -1) AND SYSDATE
            AND    CANCELTAG = '0' AND CANCELTRADEID IS NULL
            ORDER BY OPERATETIME DESC
        )
        loop
            if v_opTime is null then
                v_opTime := v_cur.OPERATETIME;
            end if;

            exit when v_opTime <> v_cur.OPERATETIME;

            if v_cur.TRADETYPECODE = '25' then
                if p_cancelTradeId is null then
                    p_cancelTradeId := v_cur.TRADEID;
                elsif p_cancelTradeId <> v_cur.TRADEID then
                    raise_application_error(-20100, '传入返销交易序号不能被返销' );
                end if;

                exit;
            end if;
        end loop;
    end if;

    if p_cancelTradeId is null then
        raise_application_error(-20101, '没有当月可以返销的休闲开通交易' );
    else
        -- 查看是否有之后的返销业务，如果已经有了返销，不允许再次返销
        begin
            select operatetime into v_opTime
            from tf_b_trade
            where cardno = p_cardNo
            and tradetypecode = 'B5'
            and operatetime >= v_opTime;

            raise_application_error(-20101, '已经返销过休闲开通，不允许递归返销' );
        exception when no_data_found then null;
        end;
    end if;

    if p_option in ('0', '1') then
		
		--记录上一次开通时套餐类型、账户开通方式
		BEGIN
		SELECT RSRV2,RSRV3 INTO v_RSRV2,v_RSRV3 FROM TF_F_CARDUSEAREA T 
		WHERE T.CARDNO	= p_cardNo AND T.FUNCTIONTYPE  = '08';
		exception when no_data_found then
			null;
		END;
		
        -- 2) Update
        SELECT NVL(RERVCHAR, 'FFFFFFFFFFFF'),ENDDATE,SPARETIMES,PACKAGETYPECODE,ACCOUNTTYPE 
		INTO p_endDateNum,v_endDate,v_spareTimes,v_packageTypeCode,v_accounttype
        FROM TF_F_CARDXXPARKACC_SZ
        WHERE CARDNO = p_cardNo;

        SELECT strEndDateNum INTO v_openEndDateNum
        FROM TF_CARD_TRADE
        WHERE TRADEID = p_cancelTradeId;

        if p_oldEndDateNum not in(p_endDateNum, v_openEndDateNum) then
            raise_application_error(-20102,
                '卡片内休闲信息已经被更改，不允许返销' );
        end if;

        UPDATE  TF_F_CARDXXPARKACC_SZ
        SET USETAG          = DECODE(p_endDateNum, 'FFFFFFFFFFFF', '0', '1'),
            ENDDATE         = substr(p_endDateNum, 1, 8), -- 恢复之前的enddate
			PACKAGETYPECODE = v_RSRV2, 					  -- 恢复之前的套餐
			ACCOUNTTYPE		= v_RSRV3,					  -- 恢复之前的账户开通方式
            CARDTIMES       = CARDTIMES - 1,
            UPDATESTAFFNO   = p_currOper,
            UPDATETIME      = v_today,
            RERVCHAR        = p_oldEndDateNum
        WHERE CARDNO = p_cardNo;

        IF  SQL%ROWCOUNT != 1 THEN
            raise_application_error(-20103, '设置惠民休闲年卡有效标识为无效时失败' );
        END IF;

        SP_GetSeq(seq => v_seqNo);

        SELECT r.CANCELCODE INTO v_cancelCode
        FROM TF_B_TRADE t, td_m_tradetype r
        WHERE t.TRADEID = p_cancelTradeId
        AND   t.TRADETYPECODE = r.TRADETYPECODE;

        -- 4) Log the operation
        INSERT INTO TF_B_TRADE
            (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME, CANCELTRADEID,RSRV2)
        SELECT
            v_seqNo,p_ID,v_cancelCode,p_cardNo,p_asn,CARDTYPECODE,
            p_currOper,p_currDept,v_today, p_cancelTradeId,RSRV2
        FROM TF_B_TRADE
        WHERE TRADEID = p_cancelTradeId;

        update TF_B_TRADE
        set    CANCELTAG = '1',
               CANCELTRADEID = v_seqNo
        WHERE  TRADEID = p_cancelTradeId;

        -- 5) Log the cash
        INSERT INTO TF_B_TRADEFEE
            (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,
            CARDDEPOSITFEE, CARDSERVFEE, OTHERFEE, FUNCFEE,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        SELECT
            p_ID,v_seqNo,v_cancelCode, p_cardNo,p_cardTradeNo,
            -CARDDEPOSITFEE, -CARDSERVFEE, -OTHERFEE, -FUNCFEE,
            p_currOper,p_currDept,v_today
        FROM TF_B_TRADEFEE
        WHERE TRADEID = p_cancelTradeId;

        -- 6) Log card change
        INSERT INTO TF_CARD_TRADE
            (TRADEID, TRADETYPECODE, strOperCardNo, strCardNo, strTermno, strEndDateNum, OPERATETIME)
        VALUES(v_seqNo, v_cancelCode, p_operCardNo, p_cardNo, p_terminalNo, p_endDateNum, v_today);
		
        -- 7) breakup the relation between cards and features.
        UPDATE TF_F_CARDUSEAREA
        SET    USETAG        = DECODE(p_endDateNum, 'FFFFFFFFFFFF', '0', '1'),
               UPDATESTAFFNO = p_currOper,
               UPDATETIME    = v_today,
               ENDTIME       = substr(p_endDateNum, 1, 8),
			   RSRV1		 = v_RSRV2,
			   RSRV2		 = '',
			   RSRV3		 = ''
        WHERE  CARDNO        = p_cardNo
        AND    FUNCTIONTYPE  = '08';
        IF  SQL%ROWCOUNT != 1 THEN
            raise_application_error(-20104, '更新卡片与惠民休闲年卡功能项关联关系失败' );
        END IF;
		
		--返销充值卡部分
		IF p_XFCardNo IS NOT NULL THEN
			BEGIN
				SP_AS_XFCommitRollBack(
									p_TRADEID	=>	p_cancelTradeId,
									p_retCode	=>	P_RETCODE,
									P_RETMSG	=>	P_RETMSG
				);
			IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
			EXCEPTION
			WHEN OTHERS THEN
			  ROLLBACK; RETURN;
			END;
		END IF;

    ------ 代理营业厅抵扣预付款，add by liuhe 20120104
    BEGIN
      SELECT -CARDDEPOSITFEE -CARDSERVFEE -OTHERFEE -FUNCFEE INTO V_TRADEFEE
      FROM TF_B_TRADEFEE
      WHERE TRADEID = P_CANCELTRADEID;

       SP_PB_DEPTBALFEEROLLBACK(V_SEQNO, P_CANCELTRADEID,
            '1' ,--1预付款,2保证金,3预付款和保证金
             V_TRADEFEE,
             P_CURROPER,P_CURRDEPT,P_RETCODE,P_RETMSG);

      IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
    EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK; RETURN;
    END;
	
	BEGIN
		  SP_AS_SynGardenXXCard(p_cardNo,p_asn,p_paperType,p_passPaperNo,p_passCustName,
							v_endDate,v_spareTimes,'3',v_today,'','',V_SEQNO,
							v_packageTypeCode,v_accounttype,p_CITYCODE,
							p_currOper,p_currDept,p_retCode,p_retMsg);
							
		IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
			EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK; RETURN;
	END;

    end if;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;

exception when others then
    p_retcode := sqlcode;
    p_retmsg  := sqlerrm;
    rollback; return;

END;
/

show errors
