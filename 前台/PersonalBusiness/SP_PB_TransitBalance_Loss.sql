CREATE OR REPLACE PROCEDURE SP_PB_TransitBalance_Loss
(
		p_SESSIONID	      varchar2,            --会话ID
		p_NEWCARDNO	      char,                --新卡卡号
		p_LOSSCARDNO	      char,              --旧卡卡号  改为挂失卡
		p_TRADETYPECODE		char,                --交易类型
		p_NEWCARDACCMONEY	int,                 --新卡帐户余额
		p_CURRENTMONEY	  int,                 --转值金额
		p_OLDCARDACCMONEY	int,                 --旧卡帐户余额
		p_PREMONEY	      int,                 --新卡卡内余额
		p_ASN	            char,                --新卡应用序列号
		p_CARDTRADENO	    char,                --联机交易序号
		p_CARDTYPECODE	  char,                --新卡类型
		p_CHANGERECORD    char,                --当前转值标志 0 未
		p_TERMNO					char,                --终端号
		p_OPERCARDNO			char,                --操作员卡号
		p_TRADEID	        out char,            -- 返回交易序列号
		p_currOper	      char,                --当前操作员
		p_currDept	      char,                --当前部门
		p_retCode	        out char,            -- Return Code
		p_retMsg     	    out varchar2         -- Return Message
)
AS
    v_TradeID char(16);
	  IV_NEWCARDNO_LIST           char(16);  -- NEWCARDNO
	  IV_OLDCARDNO_LIST           char(16);  -- OLDCARDNO
	  IV_REASONCODE_LIST          char(2);   -- REASONCODE
	  IV_TRADEID_LIST             char(16);  -- TRADEID
	  IV_PREMONEY_LIST            int;       -- PREMONEY OF NEWCARDNO
		IV_NEWASN_LIST              char(16);  -- ASN OF NEW CARD
		IV_NEWCARDTYPECODE_LIST     char(16);  -- CARDTYPECODE OF NEW CARD
		IV_NEWCARDMONEY_LIST        int;       -- ACC MONEY OF NEW CARD
		IV_OLDCARDMONEY_LIST        int;       -- ACC MONEY OF OLD CARD
    v_TRADEID_LIST              char(16);
    v_TOTALSUPPLYTIMES          int;
    v_totalRecords              int;
		v_CURRENTTIME date          := sysdate;
    v_ex                        exception;
BEGIN
    -- 1) 修改电子钱包账户信息
    BEGIN
		    UPDATE TF_F_CARDEWALLETACC
		    SET  CARDACCMONEY = CARDACCMONEY + p_CURRENTMONEY,
		        SUPPLYREALMONEY = p_PREMONEY,
		        TOTALSUPPLYTIMES = TOTALSUPPLYTIMES + 1,
		        TOTALSUPPLYMONEY = TOTALSUPPLYMONEY + p_CURRENTMONEY,
		        LASTSUPPLYTIME = v_CURRENTTIME,
		        ONLINECARDTRADENO = p_CARDTRADENO
		        WHERE  CARDNO = p_NEWCARDNO;

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001002113';
	            p_retMsg  := 'Unable to Updated electronic wallet account information' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 2)修改IC卡资料表卡状态
    --  00未售出、01销户、21退卡、02坏卡收回、22换卡、03挂失、04口挂、
    --  10售出、11换卡售出、30礼金卡回收、23挂失转值
    BEGIN
    	UPDATE TF_F_CARDREC
    	SET CARDSTATE = '23'
    	WHERE CARDNO = p_LOSSCARDNO;

    	IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001021102';
	            p_retMsg  := 'Unable to Updated account information' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 2) 判断是否第一次办理业务
    BEGIN
		    SELECT
		        TOTALSUPPLYTIMES INTO v_TOTALSUPPLYTIMES
		    FROM  TF_F_CARDEWALLETACC
		    WHERE  CARDNO = p_NEWCARDNO;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
	        p_retCode := 'S001002112';
	        p_retMsg  := 'Can not find the record or Error' || SQLERRM;
	        ROLLBACK; RETURN;
		END;

    -- 3)对于第一次办理业务，修改电子钱包信息
    if v_TOTALSUPPLYTIMES = 1 THEN
	    BEGIN
	        UPDATE TF_F_CARDEWALLETACC
	        SET  FIRSTSUPPLYTIME = v_CURRENTTIME
	        WHERE  CARDNO = p_NEWCARDNO;

			    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
			EXCEPTION
		        WHEN OTHERS THEN
		            p_retCode := 'S001002113';
		            p_retMsg  := 'Update failure' || SQLERRM;
		            ROLLBACK; RETURN;
	    END;
    END IF;

    -- 4) 获得  trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;

    -- 5) 记录业务台账
    IF p_CHANGERECORD != '1' THEN
	    BEGIN
		    INSERT INTO TF_B_TRADE
		        (TRADEID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,OLDCARDNO,OLDCARDMONEY,
		        CURRENTMONEY,PREMONEY,NEXTMONEY,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
		    VALUES
		        (v_TradeID,p_TRADETYPECODE,p_NEWCARDNO,p_ASN,p_CARDTYPECODE,p_CARDTRADENO,p_LOSSCARDNO,
		        p_OLDCARDACCMONEY,p_OLDCARDACCMONEY,p_PREMONEY,p_PREMONEY+p_OLDCARDACCMONEY,
		        p_currOper,p_currDept,v_CURRENTTIME);

			EXCEPTION
		        WHEN OTHERS THEN
		            p_retCode := 'S001005113';
		            p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
		            ROLLBACK; RETURN;
	    END;
	  END IF;

    -- 6) 记录写卡台账
    BEGIN
		    INSERT INTO TF_CARD_TRADE
		    		(TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,lMoney,lOldMoney,strTermno,
		    		Cardtradeno,OPERATETIME,SUCTAG)
		    VALUES
		    		(v_TradeID,p_TRADETYPECODE,p_OPERCARDNO,p_NEWCARDNO,p_CURRENTMONEY,p_PREMONEY,p_TERMNO,
		    		p_CARDTRADENO,v_CURRENTTIME,'0');

		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001139';
	            p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
	            ROLLBACK; RETURN;
    END;

    -- 7) 从tempdb..TransitBalance获得记录数
    SELECT
    		 COUNT(*) INTO v_totalRecords
    FROM TMP_PB_TransitBalance
    WHERE SESSIONID = p_SESSIONID;

    -- 8)获得需要转值的列表
    IF v_totalRecords != 0 THEN
	    BEGIN
		    -- Calculate premoney of next trans operation
		    FOR cur_renewdata IN (
		    SELECT A.CARDNO, A.OLDCARDNO,A.REASONCODE, B.TRADEID
				FROM TF_B_TRADE A, TMP_PB_TransitBalance B
				WHERE A.TRADEID = B.TRADEID AND B.SESSIONID = p_SESSIONID) LOOP

			    IV_NEWCARDNO_LIST  := cur_renewdata.CARDNO;
			    IV_OLDCARDNO_LIST  := cur_renewdata.OLDCARDNO;
			    IV_REASONCODE_LIST := cur_renewdata.REASONCODE;
			    IV_TRADEID_LIST    := cur_renewdata.TRADEID;

			    IV_PREMONEY_LIST := p_PREMONEY + p_OLDCARDACCMONEY;

						-- A) 获得新卡账户金额
						BEGIN
							SELECT
								B.ASN, B.CARDTYPECODE, A.CARDACCMONEY
							INTO IV_NEWASN_LIST,IV_NEWCARDTYPECODE_LIST,IV_NEWCARDMONEY_LIST
							FROM TF_F_CARDEWALLETACC A, TF_F_CARDREC B
							WHERE A.CARDNO = IV_NEWCARDNO_LIST AND A.CARDNO = B.CARDNO;

							EXCEPTION
					    WHEN NO_DATA_FOUND THEN
						        p_retCode := 'A001022103';
						        p_retMsg  := 'Can not find the record or Error' || SQLERRM;
						        ROLLBACK; RETURN;
						END;

						-- B) 获得旧卡账户金额
						BEGIN
							SELECT
								CARDACCMONEY INTO IV_OLDCARDMONEY_LIST
							FROM TF_F_CARDEWALLETACC
							WHERE CARDNO = IV_OLDCARDNO_LIST;

							EXCEPTION
						    WHEN NO_DATA_FOUND THEN
							        p_retCode := 'A001022103';
							        p_retMsg  := 'Can not find the record or Error' || SQLERRM;
							        ROLLBACK; RETURN;
						END;

						-- C) 修改卡状态
						UPDATE TF_F_CARDREC
						SET CARDSTATE = '02'
						WHERE CARDNO = IV_OLDCARDNO_LIST;

						-- D) Get trade id
		        SP_GetSeq(seq => v_TRADEID_LIST);

						-- E) 记录转值操作台账
						BEGIN
								INSERT INTO TF_B_TRADE
					        (TRADEID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,REASONCODE,OLDCARDNO,OLDCARDMONEY,
					        CURRENTMONEY,PREMONEY,NEXTMONEY,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
								VALUES
					        (v_TRADEID_LIST,p_TRADETYPECODE,p_NEWCARDNO,p_ASN,p_CARDTYPECODE,
					        IV_REASONCODE_LIST,IV_OLDCARDNO_LIST,IV_OLDCARDMONEY_LIST,IV_OLDCARDMONEY_LIST,
					        IV_PREMONEY_LIST,IV_PREMONEY_LIST+IV_OLDCARDMONEY_LIST,p_currOper,p_currDept,v_CURRENTTIME);

						EXCEPTION
					        WHEN OTHERS THEN
					            p_retCode := 'S001005113';
					            p_retMsg  := 'Error occurred while log the single operation' || SQLERRM;
					            ROLLBACK; RETURN;
				    END;

				    -- E) Calculate premoney of next trans operation
				    IV_PREMONEY_LIST := IV_PREMONEY_LIST + IV_OLDCARDMONEY_LIST;

					END LOOP;
			END;
		END IF;

	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;
/
