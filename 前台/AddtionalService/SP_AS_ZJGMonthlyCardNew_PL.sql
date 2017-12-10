CREATE OR REPLACE PROCEDURE SP_AS_ZJGMonthlyCardNew
(
    p_ID                  char,
    p_cardNo              char,
    p_deposit             int,
    p_cardCost            int,
    p_otherFee            int,
    p_cardTradeNo         char,
    p_asn                 char,
    p_cardMoney           int,
    p_sellChannelCode     char,
    p_serTakeTag          char,
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
    p_currCardNo          char,
    
    p_isChangeCard        char,
    p_oldCardNo           char,
    p_currOper            char,
    p_currDept            char,
	p_ENDDATE			  out char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_ex            exception;
    v_seqNo         char(16);
    v_cardType      CHAR(2);
    v_fnType        CHAR(2);
	v_ENDDATE		char(8);

BEGIN

	--有效期,1-9月份开通的则有效期为当年的年底，10-12月份开通的则有效期为下年年底
	v_ENDDATE:=to_char(v_today,'yyyy')||'1231';
	if(to_char(v_today,'MM')>'09') THEN
		v_ENDDATE:=(to_char(v_today,'yyyy')+1)||'1231';
	ELSE
		v_ENDDATE:=to_char(v_today,'yyyy')||'1231';
	end if;
  --如果是补换卡页面，则新卡的有效期是旧卡的有效期
  IF p_isChangeCard='1' THEN
	  SELECT ENDTIME INTO v_ENDDATE FROM TF_F_CARDCOUNTACC
		WHERE CARDNO = p_oldCardNo;
	
  END IF;
	p_ENDDATE:=v_ENDDATE;
    -- 2) Insert a row of monthly info
    BEGIN
        INSERT INTO TF_F_CARDCOUNTACC
            (CARDNO,APPTYPE,ASSIGNEDAREA,APPTIME,APPSTAFFNO,USETAG,
            UPDATESTAFFNO,UPDATETIME,ENDTIME)
        VALUES
            (p_cardNo,p_appType,p_assignedArea,v_today,p_currOper,'1',
            p_currOper,v_today,v_ENDDATE);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00509B001'; p_retMsg  := '新增月票卡资料失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 4) Setup the relation between cards and features.
    select decode(p_appType, '11', '10', '12', '11','16', '13','17','16') into v_fnType from dual;

    BEGIN
        INSERT INTO TF_F_CARDUSEAREA
              (CARDNO , FUNCTIONTYPE, USETAG, UPDATESTAFFNO , UPDATETIME)
        VALUES(p_cardNo, v_fnType     , '1'   , p_currOper, v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00509B003'; p_retMsg  := '新增卡片与月票卡功能项关联关系失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    --补换卡页面需要关闭旧卡的月票功能
    IF p_isChangeCard='1' THEN
    
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
    END IF;

	SP_GetSeq(seq => v_seqNo);
	  -- 2) Log the operate
    BEGIN
		    INSERT INTO TF_B_TRADE
		        (TRADEID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,OPERATESTAFFNO,OPERATEDEPARTID,
		        OPERATETIME)
			SELECT 	v_seqNo,p_tradeTypeCode,p_CARDNO,ASN,CARDTYPECODE,p_currOper,p_currDept, v_today
			FROM tl_r_icuser
			WHERE cardno=p_cardno;

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001008106';
	            p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

	--写卡台帐
	BEGIN
		    INSERT INTO TF_CARD_TRADE
		    		(TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,OPERATETIME,SUCTAG,strEndDateNum)
		    VALUES
		    		(v_seqNo,p_tradeTypeCode,p_currCardNo,p_CARDNO,v_today,'0',p_appType||v_ENDDATE);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001139';
	            p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
	            ROLLBACK; RETURN;
    END;


    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;

/

show errors
