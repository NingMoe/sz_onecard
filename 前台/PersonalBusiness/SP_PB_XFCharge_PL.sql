CREATE OR REPLACE PROCEDURE SP_PB_XFCharge
(
		p_ID	          char,
		p_CARDNO	      char,
		p_PASSWD	      char,
		p_CARDTRADENO	  char,
		p_CARDMONEY	    int,
		p_CARDACCMONEY	int,
		p_ASN	          char,
		p_CARDTYPECODE	char,
		p_SUPPLYMONEY	  out int,
		p_TRADETYPECODE	char,
		p_TERMNO        char,
		p_OPERCARDNO		char,
		p_TRADEID	      out char, -- Return trade id
		p_currOper	    char,
		p_currDept	    char,
		p_retCode       out char, -- Return Code
		p_retMsg        out varchar2  -- Return Message

)
AS
    v_TradeID char(16);
    v_CURRENTTIME   date;
    v_XFCARDNO      char(14);
    v_sMONEY        int;
    v_ex            exception;
	v_JiMing		char(1);

BEGIN
    -- 1) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;

    -- 2) Execute procedure SP_PB_XFCommit
		SP_PB_XFCommit (p_CARDNO, p_PASSWD, v_XFCARDNO, v_sMONEY, v_CURRENTTIME,
		    v_TradeID, p_currOper, p_currDept, p_retCode, p_retMsg);

    IF p_retCode != '0000000000' THEN
        ROLLBACK; RETURN;
    END IF;
	--判断卡是记名卡还是非记名卡
	SP_GetJiMing(p_CARDNO,v_JiMing);
	if(v_JiMing='1') THEN
		if((p_CARDMONEY+v_sMONEY)>500000) THEN
			p_retCode := 'AWDX000001';
			p_retMsg  := '记名卡充值后卡内余额不能大于5000元';
			ROLLBACK; RETURN;
		end if;
	ELSE
		if((p_CARDMONEY+v_sMONEY)>100000) THEN
			p_retCode := 'AWDX000002';
			p_retMsg  := '不记名卡充值后卡内余额不能大于1000元';
			ROLLBACK; RETURN;
		end if;
	end if;
	
    p_SUPPLYMONEY := v_sMONEY;
	
    -- 3) Execute procedure SP_PB_UpdateAcc
		SP_PB_UpdateAcc (p_ID, p_CARDNO, p_CARDTRADENO, p_CARDMONEY,
		    p_CARDACCMONEY, v_TradeID, p_ASN, p_CARDTYPECODE,
		    p_SUPPLYMONEY, p_TRADETYPECODE, p_TERMNO, v_CURRENTTIME,
		    p_currOper, p_currDept, p_retCode, p_retMsg);

    IF p_retCode != '0000000000' THEN
        ROLLBACK; RETURN;
    END IF;

    -- 4) Log the operate
    BEGIN
		    INSERT INTO TF_B_TRADE
		        (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,CURRENTMONEY,PREMONEY,
		        NEXTMONEY,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
		    VALUES
		        (v_TradeID,p_ID,'14',p_CARDNO,p_ASN,p_CARDTYPECODE,p_CARDTRADENO,
		        p_SUPPLYMONEY,p_CARDMONEY,p_CARDMONEY+p_SUPPLYMONEY,p_currOper,p_currDept,v_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001002119';
	            p_retMsg  := 'Can not log the operate' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 5) insert a row of Electronic wallet supply log
    BEGIN
		    INSERT INTO TF_CZC_SELFSUPPLY
		        (TRADEID,ID,CZCARDNO,PASSWD,CARDNO,CARDTRADENO,PREMONEY,TERMNO,OPERATESTAFFNO,
		        OPERATEDEPARTID,UPDATETIME)
		    VALUES
		        (v_TradeID,p_ID,v_XFCARDNO,p_PASSWD,p_CARDNO,p_CARDTRADENO,p_CARDMONEY,
		        p_TERMNO,p_currOper,p_currDept,v_CURRENTTIME);

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001002120';
	            p_retMsg  := 'Can not insert a row of Electronic wallet supply log' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 6) Log the writeCard
		BEGIN
		    INSERT INTO TF_CARD_TRADE
		    		(TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,lMoney,lOldMoney,strTermno,
		    		Cardtradeno,OPERATETIME,SUCTAG)
		    VALUES
		    		(v_TradeID,p_TRADETYPECODE,p_OPERCARDNO,p_CARDNO,p_SUPPLYMONEY,p_CARDMONEY,
		    		p_TERMNO,p_CARDTRADENO,v_CURRENTTIME,'0');

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001139';
	            p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;
/

show errors