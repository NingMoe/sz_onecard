CREATE OR REPLACE PROCEDURE SP_AS_GardenCardChange
(
    p_ID                char,
    p_oldCardNo         char,
    p_newCardNo         char,
    p_asn               char,

    p_operCardNo        char,
    p_terminalNo        char,
    p_endDateNum        char,

    p_custName          varchar2,
    p_custSex           varchar2,
    p_custBirth         varchar2,
    p_paperType         varchar2,
    p_paperNo           varchar2,
    p_custAddr          varchar2,
    p_custPost          varchar2,
    p_custPhone         varchar2,
    p_custEmail         varchar2,
    p_remark            varchar2,

	p_passPaperNo		varchar2,		--加*的证件号码
	p_passCustName		varchar2,		--加*的姓名
	p_SERVICEFOR		char,			--校验旧卡是否到期字段，0不同步给园林表示已过期 1同步给园林表示未过期

    p_currOper          char,
    p_currDept          char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)

AS
    v_today         date := sysdate;
    v_cardType      CHAR(2);
    v_ex            exception;
    v_seqNo         char(16);
    v_endDate       CHAR(8);
	v_spareTimes	int;
	  v_Picture    BLOB;
		v_countImage int;

BEGIN

    -- 2) Update old card's usetag
    BEGIN
        UPDATE TF_F_CARDPARKACC_SZ  SET USETAG = '0' WHERE CARDNO = p_oldCardNo AND USETAG='1';
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00502B001'; p_retMsg  := '更新园林年卡旧卡有效标志失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    SELECT CARDTYPECODE INTO v_cardType FROM TL_R_ICUSER WHERE CARDNO = p_oldCardNo;

    -- 3) Update cust info 不是市民卡才允许修改客户资料
	IF SUBSTR(p_newCardNo,5,2) != '18' THEN
		BEGIN
			UPDATE TF_F_CUSTOMERREC
			SET    CUSTNAME      = nvl(p_custName,CUSTNAME) ,
				   CUSTSEX       = nvl(p_custSex,CUSTSEX)   ,
				   CUSTBIRTH     = nvl(p_custBirth,CUSTBIRTH) ,
				   PAPERTYPECODE = nvl(p_paperType,PAPERTYPECODE) ,
				   PAPERNO       = nvl(p_paperNo,PAPERNO)   ,
				   CUSTADDR      = nvl(p_custAddr,CUSTADDR)  ,
				   CUSTPOST      = nvl(p_custPost ,CUSTPOST) ,
				   CUSTPHONE     = nvl(p_custPhone,CUSTPHONE) ,
				   CUSTEMAIL     = nvl(p_custEmail,CUSTEMAIL) ,
				   REMARK        = nvl(p_remark,REMARK)    ,
				   UPDATESTAFFNO = p_currOper  ,
				   UPDATETIME    = v_today
			WHERE  CARDNO        = p_newCardNo;

			IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION WHEN OTHERS THEN
			p_retCode := 'S00502B002'; p_retMsg  := '更新客户资料失败,' || SQLERRM;
			ROLLBACK; RETURN;
		END;
	END IF;

    -- 4) Get trade id
    SP_GetSeq(seq => v_seqNo);

    BEGIN
        INSERT INTO TF_B_CUSTOMERCHANGE
          (TRADEID,CARDNO,CUSTNAME,CUSTSEX,CUSTBIRTH,PAPERTYPECODE,
           PAPERNO,CUSTADDR,CUSTPOST,CUSTPHONE,CUSTEMAIL,REMARK,
           CHGTYPECODE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES
          (v_seqNo,p_newCardNo,p_custName,p_custSex,p_custBirth,p_paperType,
           p_paperNo,p_custAddr,p_custPost,p_custPhone,p_custEmail,p_remark,
           '01',p_currOper,p_currDept,v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00502B003'; p_retMsg  := '新增客户资料变更台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 5) Insert a new row
    BEGIN
        merge into TF_F_CARDPARKACC_SZ t1
        using (select * from TF_F_CARDPARKACC_SZ where CARDNO = p_oldCardNo) t2
        on (t1.CARDNO = p_newCardNo)
        when matched then
            UPDATE SET t1.CURRENTOPENYEAR = t2.CURRENTOPENYEAR,
                       t1.CARDTIMES       = 1                 ,
                       t1.CURRENTPAYTIME  = t2.CURRENTPAYTIME ,
                       t1.CURRENTPAYFEE   = t2.CURRENTPAYFEE  ,
                       t1.ENDDATE         = t2.ENDDATE        ,
                       t1.USETAG          = '1'               ,
                       t1.TOTALTIMES      = t2.TOTALTIMES     ,
                       t1.SPARETIMES      = t2.SPARETIMES     ,
                       t1.UPDATESTAFFNO   = p_currOper        ,
                       t1.UPDATETIME      = v_today
        when not matched then
            INSERT
                (CARDNO,CURRENTOPENYEAR,CARDTIMES,CURRENTPAYTIME,
                CURRENTPAYFEE,ENDDATE,USETAG,TOTALTIMES,SPARETIMES,UPDATESTAFFNO,UPDATETIME)
            VALUES(p_newCardNo, t2.CURRENTOPENYEAR,1, t2.CURRENTPAYTIME,
                t2.CURRENTPAYFEE, t2.ENDDATE, '1', t2.TOTALTIMES, t2.SPARETIMES,p_currOper,v_today);

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;

        SELECT ENDDATE,SPARETIMES INTO v_endDate,v_spareTimes FROM TF_F_CARDPARKACC_SZ WHERE CARDNO = p_oldCardNo;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00502B004'; p_retMsg  := '从旧卡向新卡复制园林年卡信息失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 6) Log the operation
    BEGIN
        INSERT INTO TF_B_TRADE
            (TRADEID, ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,OLDCARDNO,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,RSRV1)
        VALUES
            (v_seqNo,p_ID,'36',p_newCardNo,p_asn,v_cardType,p_oldCardNo,
            p_currOper,p_currDept,v_today,p_SERVICEFOR);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00502B005'; p_retMsg  := '新增园林年卡补换卡台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 10) Log card change
    BEGIN
        INSERT INTO TF_CARD_TRADE
            (TRADEID, TRADETYPECODE, strOperCardNo, strCardNo, strTermno, strEndDateNum, OPERATETIME)
        VALUES(v_seqNo, '36', p_operCardNo, p_newCardNo, p_terminalNo, p_endDateNum, v_today);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00502B006'; p_retMsg  := '新增园林年卡补换卡卡片交易台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 11) Setup the relation between cards and features.
    BEGIN
        MERGE INTO TF_F_CARDUSEAREA t1
        USING      dual
        ON         (t1.CARDNO = p_newCardNo AND t1.FUNCTIONTYPE = '02')
        WHEN MATCHED THEN
            UPDATE SET t1.USETAG = '1', t1.ENDTIME = v_endDate,
            UPDATESTAFFNO = p_currOper, UPDATETIME = v_today
        WHEN NOT MATCHED THEN
            INSERT  (CARDNO    , FUNCTIONTYPE, USETAG, UPDATESTAFFNO , UPDATETIME)
            VALUES  (p_newCardNo, '02'        , '1'   , p_currOper, v_today);

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00502B007'; p_retMsg  := '新增卡片与园林年卡功能项关联关系失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    BEGIN
        UPDATE TF_F_CARDUSEAREA
        SET    USETAG        = '0'       ,  ENDTIME       = null,
               UPDATESTAFFNO = p_currOper , UPDATETIME    = v_today
        WHERE  CARDNO = p_oldCardNo AND FUNCTIONTYPE = '02';

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S00502B008'; p_retMsg  := '关闭卡片与园林年卡功能项关联关系失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
	
	BEGIN 
		SELECT count(*) INTO v_countImage FROM TF_F_CARDPARKPHOTO_SZ t WHERE  t.CARDNO=p_oldCardNo;
    END;
	

    IF v_COUNTIMAGE = '1' THEN
		---13)新卡照片更换为旧卡照片
		--）记录新卡照片历史表
			BEGIN
				INSERT INTO TB_F_CARDPARKPHOTO_SZ(CARDNO,PICTURE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
				SELECT p_newCardNo,t.PICTURE,p_currOper,p_currDept,v_today
				FROM TF_F_CARDPARKPHOTO_SZ t WHERE t.cardno=p_oldCardNo ;
				IF SQL%ROWCOUNT != 1 THEN
				  RAISE v_EX;
				END IF;
				EXCEPTION
				WHEN OTHERS THEN
				p_retCode := 'S001011144';
				p_retMsg  := 'Error occurred while insert TB_F_CARDPARKPHOTO_SZ info' ||SQLERRM;
				ROLLBACK;
				RETURN;
			END;
		
		SELECT picture INTO v_Picture FROM TF_F_CARDPARKPHOTO_SZ t WHERE   t.CARDNO=p_oldCardNo;
       BEGIN
					    MERGE INTO TF_F_CARDPARKPHOTO_SZ t USING DUAL
              ON (t.CARDNO = p_newCardNo)
            WHEN MATCHED THEN
              UPDATE
                 SET t.PICTURE         = v_Picture,
                     t.OPERATETIME     = v_today,
                     t.OPERATEDEPARTID = p_currDept,
                     t.OPERATESTAFFNO  = p_currOper
            WHEN NOT MATCHED THEN
              INSERT
                (CARDNO,
                 PICTURE,
                 OPERATETIME,
                 OPERATEDEPARTID,
                 OPERATESTAFFNO)
              VALUES
                (p_newCardNo,
                 v_Picture,
                 v_today,
                 p_currDept,
                 p_currOper);
       END;
		END IF;
		

	--同步园林接口 旧卡在有效期内的数据则同步给园林
	IF p_SERVICEFOR = '1' THEN
		BEGIN
		  SP_AS_SynGardenCard(p_newCardNo,p_asn,p_paperType,p_passPaperNo,p_passCustName,
							v_endDate,v_spareTimes,'2',v_today,p_oldCardNo,'',v_seqNo,
							p_currOper,p_currDept,p_retCode,p_retMsg);

		IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
			EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK; RETURN;
		END;
	END IF;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;

/

show errors