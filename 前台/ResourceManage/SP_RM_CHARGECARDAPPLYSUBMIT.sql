
-- create by Yin   2012/07/19
-- 充值卡领卡申请

create or replace procedure SP_RM_CHARGECARDAPPLYSUBMIT
(
       p_USEWAY              varchar2, -- 用途
       p_CARDVALUECODE       varchar2, --卡片类型
       p_APPLYGETNUM         varchar2, --申请领用数量
       P_REMARK              varchar2, --备注
       
       P_getCardOrderID    out char,
       
       p_currOper     char,           -- Current Operator
       p_currDept     char,           -- Curretn Operator's Department
       p_retCode      out char,       -- Return Code
       p_retMsg       out varchar2    -- Return Message
)
AS 
       v_seqNo          CHAR(16);
       v_getCardOrderID CHAR(18);
       v_today          date;
       v_ex             EXCEPTION;
	   	V_TAGCOUNT   		INT;
		V_DEPTCOUNT   		INT;
		V_TAGMONEY			INT;
		V_CHARGEMONEY		INT;
BEGIN
   v_today := sysdate;
   SP_GetSeq(seq => v_seqNo); 
   v_getCardOrderID := 'LY' || v_seqNo;
   
    ---代理营业厅充值限额 add by liuhe20121113
    SELECT COUNT(*) INTO V_TAGCOUNT 
	FROM TD_M_TAG  WHERE TAGCODE='PROXY_CHARGE_LIMIT' AND USETAG='1';
    
	IF V_TAGCOUNT = 1 THEN
			SELECT  COUNT(*) INTO V_DEPTCOUNT 
			FROM 	TF_DEPT_BALUNIT B , TD_DEPTBAL_RELATION R
			WHERE 	B.DBALUNITNO = R.DBALUNITNO
					AND B.DEPTTYPE = '1'
					AND R.USETAG = '1'
					AND B.USETAG = '1'
					AND R.DEPARTNO = P_CURRDEPT;
			IF V_DEPTCOUNT = 1 THEN--如果是代理营业厅
				--查询充值限额
				SELECT TAGVALUE INTO V_TAGMONEY FROM TD_M_TAG WHERE TAGCODE='PROXY_CHARGE_LIMIT' AND USETAG='1';
				SELECT v.MONEY INTO V_CHARGEMONEY FROM TP_XFC_CARDVALUE v WHERE v.VALUECODE = p_CARDVALUECODE;
				---如果当日代理充值总额超过配置的上限则提示错误
				IF V_CHARGEMONEY > V_TAGMONEY THEN 
					P_RETCODE := 'A009010091';
					P_RETMSG := '在代理机构单张卡售卡金额不能超过'||V_TAGMONEY/100.00||'元';
				RETURN;
				END IF;
			END IF;
	END IF;
	
   BEGIN
       --插入领用单表                                                    
        insert into TF_F_GETCARDORDER  
        (
        GETCARDORDERID,               GETCARDORDERTYPE,       GETCARDORDERSTATE,          USETAG,           USEWAY,
        CARDTYPECODE,                 CARDSURFACECODE,        VALUECODE,                  APPLYGETNUM,      AGREEGETNUM,
        ALREADYGETNUM,                LATELYGETDATE,          GETSTAFFNO,                 ORDERTIME,        ORDERSTAFFNO,    
        EXAMTIME,                     EXAMSTAFFNO,           REMARK,                      PRINTCOUNT
        )                                                     
        values                                                    
        (
        v_getCardOrderID,               '02',                  '0',                        '1',              p_USEWAY,
        null,                           null,                  p_CARDVALUECODE,            p_APPLYGETNUM,        0,
        0,                              null,                  null,                       v_today,          p_currOper,
        null,                            null,                 P_REMARK,                   0
        );                                                  
        EXCEPTION WHEN OTHERS THEN
            p_retCode :=   'S094390001';
            p_retMsg := '插入卡片领用单表失败' || sqlerrm;                                              
            rollback;
            return;
    END;
    
    BEGIN
        --写单据管理台账表                                                    
        insert into TF_B_ORDERMANAGE 
        (
        TRADEID,               ORDERTYPECODE,             ORDERID,             OPERATETYPECODE,        ORDERDEMAND,                                                    
        CARDTYPECODE,          CARDSURFACECODE,           CARDSAMPLECODE,      CARDNAME,               CARDFACEAFFIRMWAY,
        VALUECODE,             CARDNUM,                   REQUIREDATE,         LATELYDATE,             ALREADYARRIVENUM,
        RETURNCARDNUM,         BEGINCARDNO,               ENDCARDNO,           CARDCHIPTYPECODE,       COSTYPECODE,
        MANUTYPECODE,          APPVERNO,                  VALIDBEGINDATE,      VALIDENDDATE,           APPLYGETNUM,
        AGREEGETNUM,           ALREADYGETNUM,             LATELYGETDATE,       GETSTAFFNO,              OPERATETIME,            
        OPERATESTAFF,          REMARK
        )                                                    
        values                                                    
        (
        v_seqNo,              '03',                       v_getCardOrderID,        '02',                  null,
        null,                  null,                      null,                    null,                  null,
        p_CARDVALUECODE,       null,                      null,                    null,                  0,
        0,                     null,                      null,                    null,                  null,
        null,                  null,                      null,                    null,                  p_APPLYGETNUM,
        0,                     0,                         null,                    null,                   v_today ,           
        p_currOper,            P_REMARK
        )  ;                                                
                                                            
        EXCEPTION WHEN OTHERS THEN
            p_retCode :=   'S094390002';
            p_retMsg := '插入单据管理台账表失败' || sqlerrm;                                              
            rollback;
            return;                                        

    END;   
    
    P_getCardOrderID := v_getCardOrderID;
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
   
END;

/ 
show errors;

