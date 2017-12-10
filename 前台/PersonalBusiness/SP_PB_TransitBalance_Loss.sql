CREATE OR REPLACE PROCEDURE SP_PB_TransitBalance_Loss
(
		p_SESSIONID	      varchar2,            --�ỰID
		p_NEWCARDNO	      char,                --�¿�����
		p_LOSSCARDNO	      char,              --�ɿ�����  ��Ϊ��ʧ��
		p_TRADETYPECODE		char,                --��������
		p_NEWCARDACCMONEY	int,                 --�¿��ʻ����
		p_CURRENTMONEY	  int,                 --תֵ���
		p_OLDCARDACCMONEY	int,                 --�ɿ��ʻ����
		p_PREMONEY	      int,                 --�¿��������
		p_ASN	            char,                --�¿�Ӧ�����к�
		p_CARDTRADENO	    char,                --�����������
		p_CARDTYPECODE	  char,                --�¿�����
		p_CHANGERECORD    char,                --��ǰתֵ��־ 0 δ
		p_TERMNO					char,                --�ն˺�
		p_OPERCARDNO			char,                --����Ա����
		p_TRADEID	        out char,            -- ���ؽ������к�
		p_currOper	      char,                --��ǰ����Ա
		p_currDept	      char,                --��ǰ����
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
    -- 1) �޸ĵ���Ǯ���˻���Ϣ
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

    -- 2)�޸�IC�����ϱ�״̬
    --  00δ�۳���01������21�˿���02�����ջء�22������03��ʧ��04�ڹҡ�
    --  10�۳���11�����۳���30��𿨻��ա�23��ʧתֵ
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

    -- 2) �ж��Ƿ��һ�ΰ���ҵ��
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

    -- 3)���ڵ�һ�ΰ���ҵ���޸ĵ���Ǯ����Ϣ
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

    -- 4) ���  trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;

    -- 5) ��¼ҵ��̨��
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

    -- 6) ��¼д��̨��
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

    -- 7) ��tempdb..TransitBalance��ü�¼��
    SELECT
    		 COUNT(*) INTO v_totalRecords
    FROM TMP_PB_TransitBalance
    WHERE SESSIONID = p_SESSIONID;

    -- 8)�����Ҫתֵ���б�
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

						-- A) ����¿��˻����
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

						-- B) ��þɿ��˻����
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

						-- C) �޸Ŀ�״̬
						UPDATE TF_F_CARDREC
						SET CARDSTATE = '02'
						WHERE CARDNO = IV_OLDCARDNO_LIST;

						-- D) Get trade id
		        SP_GetSeq(seq => v_TRADEID_LIST);

						-- E) ��¼תֵ����̨��
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
