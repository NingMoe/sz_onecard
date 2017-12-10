CREATE OR REPLACE PROCEDURE SP_AS_TravelCardNew
(
    p_ID                char,  --记录流水号  
    p_cardNo            char,  --卡号      
    p_cardTradeNo       char,  --联机交易序号  
    p_asn               char,  --应用序列号  
    p_tradeFee          int,  --代开功能费  
	p_openTime      char,  --开卡日期    
	P_endTime      char,  --卡有效期    

    p_operCardNo        char,  --操作员卡号    没有填空值
    p_terminalNo        char,  --终端编码      默认值 112233445566
    p_oldEndDateNum     char,  --卡片资料变更  没有填空值
    p_endDateNum        char,  --卡片资料变更  没有填空值

    p_custName          varchar2,  --姓名    没有填空值
    p_custSex           varchar2,  --性别    没有填空值
    p_custBirth         varchar2,  --出生日期  没有填空值
    p_paperType         varchar2,  --证件类型编码  没有填空值
    p_paperNo           varchar2,  --证件号码  没有填空值
    p_custAddr          varchar2,  --联系地址  没有填空值
    p_custPost          varchar2,  --邮政编码  没有填空值
    p_custPhone         varchar2,  --联系电话  没有填空值
    p_custEmail         varchar2,  --电子邮件  没有填空值
    p_remark            varchar2,  --备注  没有填空值
    p_currOper          char,    --操作员工号
    p_currDept          char,    --操作部门号

	p_usetag      varchar2,  --前后台传入参数标识(前台传入1，后台传入2)

    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_id            char(18);
    v_today         date := sysdate;
    v_endDate       char(8);
    v_tagValue      TD_M_TAG.TAGVALUE%TYPE;
    v_totalTimes    INT;
    v_ex            exception;
    v_seqNo         char(16);
    v_cardType      CHAR(2);
    v_updateTime    date;
	v_count			INT;
BEGIN

	IF p_ID IS NULL OR p_ID ='' THEN
		SELECT to_char(sysdate,'mmddhh24miss') || substr(p_cardNo,9,8) INTO v_id FROM DUAL;
  ELSE 
       v_id :=p_ID;
	END IF;
	
    -- 3) Get total times
    BEGIN
        SELECT CAST(TAGVALUE AS INT) INTO v_totalTimes FROM  TD_M_TAG
        WHERE  TAGCODE = 'TRAVEL_NUM' AND USETAG = '1';
    EXCEPTION  WHEN NO_DATA_FOUND THEN
        p_retCode := 'S00601B001'; p_retMsg  := '缺少系统参数-吴江旅游年卡总共次数';
        RETURN;
    END;


    -- 5) New row, or Update
  IF p_usetag = '1' THEN
    BEGIN
      MERGE INTO TF_F_CARDTOURACC_WJ USING DUAL
      ON (CARDNO = p_cardNo)
      WHEN MATCHED THEN
        UPDATE SET
          CURRENTOPENYEAR = p_openTime,
          CARDTIMES       = CARDTIMES + 1,
          CURRENTPAYTIME  = v_today,
          CURRENTPAYFEE   = p_tradeFee,
          ENDDATE         = P_endTime,
          USETAG          = '1',
          TOTALTIMES      = v_totalTimes,
          SPARETIMES      = v_totalTimes,
          UPDATESTAFFNO   = p_currOper,
          UPDATETIME      = v_today,
          RERVCHAR        = p_oldEndDateNum
      WHEN NOT MATCHED THEN
           INSERT (CARDNO,CURRENTOPENYEAR,CARDTIMES,CURRENTPAYTIME,CURRENTPAYFEE,
            ENDDATE,USETAG,TOTALTIMES,SPARETIMES,UPDATESTAFFNO,UPDATETIME, RERVCHAR)
          VALUES
            (p_cardNo,p_openTime,1,v_today,
            p_tradeFee,P_endTime,'1',v_totalTimes,v_totalTimes,p_currOper,v_today, p_oldEndDateNum);

      IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
      p_retCode := 'S00601B003'; p_retMsg  := '更新吴江旅游年卡信息失败,' || SQLERRM;
      ROLLBACK; RETURN;
    END;
  END IF;
  
  IF p_usetag = '2' THEN
    BEGIN
      MERGE INTO TF_F_CARDTOURACC_WJ USING DUAL
      ON (CARDNO = p_cardNo)
      WHEN MATCHED THEN
        UPDATE SET
          CURRENTOPENYEAR = nvl(CURRENTOPENYEAR,p_openTime),
          CARDTIMES       = nvl(CARDTIMES,1),
          CURRENTPAYTIME  = nvl(CURRENTPAYTIME,v_today),
          CURRENTPAYFEE   = nvl(CURRENTPAYFEE,p_tradeFee),
          ENDDATE         = nvl(ENDDATE,P_endTime),
          --USETAG          = '1',
          TOTALTIMES      = nvl(TOTALTIMES,v_totalTimes),
          --SPARETIMES      = v_totalTimes,
          UPDATESTAFFNO   = p_currOper,
          UPDATETIME      = v_today,
          RERVCHAR        = nvl(RERVCHAR,p_oldEndDateNum)
      WHEN NOT MATCHED THEN
           INSERT (CARDNO,CURRENTOPENYEAR,CARDTIMES,CURRENTPAYTIME,CURRENTPAYFEE,
            ENDDATE,USETAG,TOTALTIMES,SPARETIMES,UPDATESTAFFNO,UPDATETIME, RERVCHAR)
          VALUES
            (p_cardNo,p_openTime,1,v_today,
            p_tradeFee,P_endTime,'1',v_totalTimes,v_totalTimes,p_currOper,v_today, p_oldEndDateNum);

      IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
      p_retCode := 'S00601B003'; p_retMsg  := '更新吴江旅游年卡信息失败,' || SQLERRM;
      ROLLBACK; RETURN;
    END;
  END IF;  
  
    begin
        select operatetime INTO v_updateTime
        from (select t.operatetime
            from tf_b_trade t
            where t.cardno = p_cardNo
            and t.tradetypecode = '6A'
            and t.canceltradeid is null
            order by t.operatetime desc)
        where rownum < 2;

        if trunc(v_updateTime, 'DD') = trunc(sysdate, 'DD') then
            p_retCode := 'S00601B004'; p_retMsg  := '吴江旅游年卡当日开通，不允许再次开通';
            ROLLBACK;return;
        end if;
    exception when no_data_found then null;
    end;

    -- 6) Get trade id
    SP_GetSeq(seq => v_seqNo);

    SELECT CARDTYPECODE INTO v_cardType FROM TL_R_ICUSER WHERE CARDNO = p_cardNo;
    -- 7) Log the operation
    BEGIN
        INSERT INTO TF_B_TRADE
            (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
            (v_seqNo,v_id,'6A',p_cardNo,p_asn,v_cardType,
            p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00601B005'; p_retMsg  := '新增吴江旅游年卡开通台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 8) Update cust info 不是市民卡才允许修改客户资料
	IF SUBSTR(p_cardNo,5,2) != '18' THEN	
		BEGIN
			UPDATE TF_F_CUSTOMERREC
			SET    CUSTNAME      = nvl(p_custName,CUSTNAME)  ,
				   CUSTSEX       = nvl(p_custSex,CUSTSEX)   ,
				   CUSTBIRTH     = nvl(p_custBirth,CUSTBIRTH) ,
				   PAPERTYPECODE = nvl(p_paperType,PAPERTYPECODE) ,
				   PAPERNO       = nvl(p_paperNo,PAPERNO)   ,
				   CUSTADDR      = nvl(p_custAddr ,CUSTADDR) ,
				   CUSTPOST      = nvl(p_custPost,CUSTPOST)  ,
				   CUSTPHONE     = nvl(p_custPhone,CUSTPHONE) ,
				   CUSTEMAIL     = nvl(p_custEmail ,CUSTEMAIL),
				   REMARK        = nvl(p_remark ,REMARK)   ,
				   UPDATESTAFFNO = p_currOper  ,
				   UPDATETIME    = v_today
			WHERE  CARDNO        = p_cardNo;

			IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION WHEN OTHERS THEN
			p_retCode := 'S00501B007'; p_retMsg  := '更新客户资料失败,' || SQLERRM;
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
        p_retCode := 'S00501B008'; p_retMsg  := '新增客户资料变更台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 9) Log the cash
    BEGIN
        INSERT INTO TF_B_TRADEFEE
            (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,FUNCFEE,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
            (v_id,v_seqNo,'6A',p_cardNo,p_cardTradeNo,p_tradeFee,
            p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00601B006'; p_retMsg  := '新增吴江旅游年卡开通现金台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 10) Log card change
    BEGIN
        INSERT INTO TF_CARD_TRADE
            (TRADEID, TRADETYPECODE, strOperCardNo, strCardNo, strTermno, strEndDateNum, OPERATETIME)
        VALUES(v_seqNo, '6A', p_operCardNo, p_cardNo, p_terminalNo, p_endDateNum, v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00601B007'; p_retMsg  := '新增吴江旅游年卡开通卡片交易台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 11) Setup the relation between cards and features.
    BEGIN
        MERGE INTO TF_F_CARDUSEAREA  USING DUAL
        ON ( CARDNO = p_cardNo AND FUNCTIONTYPE  = '12')
        WHEN MATCHED THEN
            UPDATE
            SET    USETAG        = '1',
                   ENDTIME       = P_endTime ,
                   UPDATESTAFFNO = p_currOper,
                   UPDATETIME    = v_today
        WHEN NOT MATCHED THEN
            INSERT
                  (CARDNO  , FUNCTIONTYPE, USETAG, ENDTIME  , UPDATESTAFFNO , UPDATETIME)
            VALUES(p_cardNo, '12'        , '1'   , P_endTime, p_currOper    , v_today);

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00501B011'; p_retMsg  := '更新或新增卡片与吴江旅游年卡功能项关联关系失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

  --前台调用时执行代理营业厅抵扣预付款
  -- 代理营业厅抵扣预付款，add by liuhe 20120104
  IF p_usetag = '1' THEN
    BEGIN
      SP_PB_DEPTBALFEE(v_seqNo, '1' ,--1预付款,2保证金,3预付款和保证金
               p_tradeFee,
               v_today,p_currOper,p_currDept,p_retCode,p_retMsg);

      IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK; RETURN;
    END;
  END IF;

    p_retCode := '0000000000'; p_retMsg  := 'OK';
    RETURN;
END;
/
show errors