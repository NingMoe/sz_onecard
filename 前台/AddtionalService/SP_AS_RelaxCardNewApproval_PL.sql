CREATE OR REPLACE PROCEDURE SP_AS_RelaxCardNewApproval
(
    p_currOper          char,
    p_currDept          char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
	v_CARDNO		char(16);
	v_custName		varchar(200);
	v_paperType		char(2);
	v_paperNo		varchar(200);
	v_custPhone		varchar(200);
	v_custAddr		varchar(600);
	v_validType		char(1);
	v_ID			char(18);
	v_CARDTRADENO	CHAR(4);		--�����������
	v_ASN			CHAR(16);		--ASN��
	v_TRADEFEE		INT;
	v_OPERCARDNO	CHAR(16);		--����Ա����
	v_TERMINALNO	CHAR(12);		--112233445566
	v_OLDENDDATENUM	CHAR(12);		--԰���꿨�ı�־λΪ'01',���������꿨�ı�־λΪ'02'.��������16����.
	v_ENDDATENUM	CHAR(12);		--
    v_today         date := sysdate;
    v_endDate       CHAR(8);
    v_tagValue      TD_M_TAG.TAGVALUE%TYPE;
    v_totalTimes    INT;
	v_XXPARKID		char(24);		--�����꿨�����ʱ��

    v_openYearMonth CHAR(6);
    v_ex            exception;
    v_seqNo         char(16);
    v_cardType      CHAR(2);
    v_updateTime    date;
BEGIN
	
	--����Ա���Ź̶�
	v_OPERCARDNO :='0000000000000000';
	--�����������
	v_TERMINALNO := '112233445566';
	--�Ͽ��ĵ�����
	v_OLDENDDATENUM :='200812210164';
	
	--f0 У���Ƿ���ڿͻ���Ϣ
	--f1 ����
	--f2 ����
	--f3 ֤������
	--f4 ֤������
	--f5 ��ϵ�绰
	--f6 ��ϵ��ַ
	--f7 enddatenum =>v_ENDDATENUM ��ǰ̨���ɴ���
	--f8 tradefee =>v_TRADEFEE ǰ̨����
	BEGIN
	FOR v_cur in (SELECT f0,f1,f2,f3,f4,f5,f6,f7,f8,f9 FROM TMP_COMMON)
	LOOP
		v_validType :=v_cur.f0;
		v_CARDNO :=v_cur.f1;
		v_custName :=v_cur.f2;
		v_paperType :=v_cur.f3;
		v_paperNo :=v_cur.f4;
		v_custPhone :=v_cur.f5;
		v_custAddr :=v_cur.f6;
		v_ENDDATENUM :=v_cur.f7;
		v_TRADEFEE :=v_cur.f8;
		v_XXPARKID :=v_cur.f9;
		v_ID := to_char(sysdate,'MMDDHH24MISS') || SUBSTR(v_CARDNO,-8);
		v_CARDTRADENO := '0000';
		
		SELECT ASN INTO v_ASN FROM TL_R_ICUSER
		WHERE CARDNO = v_CARDNO;
		-- 2) Get enddate
		BEGIN
			SELECT TAGVALUE INTO v_tagValue FROM  TD_M_TAG
			WHERE   TAGCODE = 'XXPARK_ENDDATE' AND USETAG = '1';
			v_endDate := substr(v_tagValue, 1, 8);
		EXCEPTION WHEN OTHERS THEN
			p_retCode := 'A00505B001'; p_retMsg  := 'ȱ�ٲ���-���������꿨��������';
			RETURN;
		END;

		-- 3) Get total times
		BEGIN
			SELECT CAST(TAGVALUE AS INT) INTO v_totalTimes FROM  TD_M_TAG
			WHERE  TAGCODE = 'XXPARK_NUM' AND USETAG = '1';
		EXCEPTION WHEN NO_DATA_FOUND THEN
			p_retCode := 'S00505B002'; p_retMsg  := 'ȱ��ϵͳ����-���������꿨�ܹ�����';
			RETURN;
		END;

		v_openYearMonth := to_char(v_today, 'yyyyMM');

		-- 5) New row, or Update
		BEGIN
			MERGE INTO TF_F_CARDXXPARKACC_SZ t USING DUAL
			ON (t.CARDNO = v_CARDNO)
			WHEN MATCHED THEN
				UPDATE SET
					CURRENTOPENYEAR = v_openYearMonth,
					CARDTIMES       = CARDTIMES + 1,
					CURRENTPAYTIME  = v_today,
					CURRENTPAYFEE   = v_TRADEFEE,
					ENDDATE         = v_endDate,
					USETAG          = '1',
					TOTALTIMES      = v_totalTimes,
					SPARETIMES      = v_totalTimes,
					UPDATESTAFFNO   = p_currOper,
					UPDATETIME      = v_today,
					RERVCHAR        = v_OLDENDDATENUM
			WHEN NOT MATCHED THEN
				INSERT
					(CARDNO,CURRENTOPENYEAR,CARDTIMES,CURRENTPAYTIME,CURRENTPAYFEE,
					ENDDATE,USETAG,TOTALTIMES,SPARETIMES,UPDATESTAFFNO,UPDATETIME, RERVCHAR)
				VALUES
					(v_CARDNO,v_openYearMonth,1,v_today,
					v_TRADEFEE,v_endDate,'1',v_totalTimes,v_totalTimes,p_currOper,v_today, v_OLDENDDATENUM);

			IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION WHEN OTHERS THEN
			p_retCode := 'S00505B005'; p_retMsg  := '�������߸��»��������꿨��Ϣʧ��,���󿨺�Ϊ��'|| v_CARDNO|| ',' || SQLERRM;
			ROLLBACK; RETURN;
		END;

		begin
			select operatetime INTO v_updateTime
			from (select t.operatetime
				from tf_b_trade t
				where t.cardno = v_CARDNO
				and t.tradetypecode = '25'
				and t.canceltradeid is null
				order by t.operatetime desc)
			where rownum < 2;

			if trunc(v_updateTime, 'DD') = trunc(sysdate, 'DD') then
				p_retCode := 'S00501B000'; p_retMsg  := '���������꿨���տ�ͨ���������ٴο�ͨ�����󿨺�Ϊ'|| v_CARDNO;
				return;
			end if;
		exception when no_data_found then null;
		end;

		-- 6) Get trade id
		SP_GetSeq(seq => v_seqNo);

		SELECT CARDTYPECODE INTO v_cardType FROM TL_R_ICUSER WHERE CARDNO = v_CARDNO;
		-- 7) Log the operation
		BEGIN
			INSERT INTO TF_B_TRADE
				(TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,
				OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
			VALUES
				(v_seqNo,v_ID,'25',v_CARDNO,v_ASN,v_cardType,
				p_currOper,p_currDept,v_today);
		EXCEPTION WHEN OTHERS THEN
			p_retCode := 'S00505B006'; p_retMsg  := '�������������꿨��̨ͨ��ʧ��,���󿨺�Ϊ��'|| v_CARDNO|| ',' || SQLERRM;
			ROLLBACK; RETURN;
		END;

		-- 8) Update cust info
		BEGIN
		MERGE INTO TF_F_CUSTOMERREC USING DUAL
		ON (CARDNO = v_CARDNO)
		WHEN MATCHED THEN
			UPDATE 
			SET    CUSTNAME      = v_custName  ,
				   PAPERTYPECODE = v_paperType ,
				   PAPERNO       = v_paperNo   ,
				   CUSTADDR      = v_custAddr  ,
				   CUSTPHONE     = v_custPhone ,
				   UPDATESTAFFNO = p_currOper  ,
				   UPDATETIME    = v_today
			WHERE  CARDNO        = v_CARDNO
		WHEN NOT MATCHED THEN
			INSERT 
				(CARDNO		,CUSTNAME	,PAPERTYPECODE	,PAPERNO	,
				CUSTPHONE	,CUSTADDR	,USETAG)
			VALUES(v_CARDNO	,v_custName	,v_paperType	,v_paperNo	,
				v_custPhone	,v_custAddr	,'1');

			IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION WHEN OTHERS THEN
			p_retCode := 'S00505B007'; p_retMsg  := '���¿ͻ�����ʧ��,���󿨺�Ϊ��'|| v_CARDNO|| ',' || SQLERRM;
			ROLLBACK; RETURN;
		END;

		BEGIN
			INSERT INTO TF_B_CUSTOMERCHANGE
			  (TRADEID,CARDNO,CUSTNAME,CUSTSEX,CUSTBIRTH,PAPERTYPECODE,
			   PAPERNO,CUSTADDR,CUSTPOST,CUSTPHONE,CUSTEMAIL,REMARK,
			   CHGTYPECODE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
			VALUES
			  (v_seqNo,v_CARDNO,v_custName,'','',v_paperType,
			   v_paperNo,v_custAddr,'',v_custPhone,'','',
			   '01',p_currOper,p_currDept,v_today);
		EXCEPTION WHEN OTHERS THEN
			p_retCode := 'S00505B008'; p_retMsg  := '�����ͻ����ϱ��̨��ʧ��,���󿨺�Ϊ��'|| v_CARDNO|| ',' || SQLERRM;
			ROLLBACK; RETURN;
		END;

		-- 9) Log the cash
		BEGIN
			INSERT INTO TF_B_TRADEFEE
				(ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,FUNCFEE,
				OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
			VALUES
				(v_ID,v_seqNo,'25',v_CARDNO,v_CARDTRADENO,v_TRADEFEE,
				p_currOper,p_currDept,v_today);
		EXCEPTION WHEN OTHERS THEN
			p_retCode := 'S00505B009'; p_retMsg  := '�������������꿨��ͨ�ֽ�̨��ʧ��,���󿨺�Ϊ��'|| v_CARDNO|| ',' || SQLERRM;
			ROLLBACK; RETURN;
		END;

		-- 10) Log card change
		BEGIN
			INSERT INTO TF_CARD_TRADE
				(TRADEID, TRADETYPECODE, strOperCardNo, strCardNo, strTermno, strEndDateNum, OPERATETIME)
			VALUES(v_seqNo, '25', v_OPERCARDNO, v_CARDNO, v_TERMINALNO, v_ENDDATENUM, v_today);
		EXCEPTION WHEN OTHERS THEN
			p_retCode := 'S00505B010'; p_retMsg  := '�������������꿨��ͨ��Ƭ����̨��ʧ��,���󿨺�Ϊ��'|| v_CARDNO|| ',' || SQLERRM;
			ROLLBACK; RETURN;
		END;

		-- 11) Setup the relation between cards and features.
		BEGIN
			MERGE INTO TF_F_CARDUSEAREA USING DUAL
			ON (CARDNO        = v_CARDNO AND FUNCTIONTYPE  = '08')
			WHEN MATCHED THEN
				UPDATE
				SET    USETAG        = '1',
					   ENDTIME       = v_endDate ,
					   UPDATESTAFFNO = p_currOper,
					   UPDATETIME    = v_today
			WHEN NOT MATCHED THEN
				INSERT
					  (CARDNO  , FUNCTIONTYPE, USETAG, ENDTIME  , UPDATESTAFFNO , UPDATETIME)
				VALUES(v_CARDNO, '08'        , '1'   , v_endDate, p_currOper    , v_today);

			IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION WHEN OTHERS THEN
			p_retCode := 'S00505B011'; p_retMsg  := '���»�������Ƭ����������꿨�����������ϵʧ��,���󿨺�Ϊ��'|| v_CARDNO|| ',' || SQLERRM;
			ROLLBACK; RETURN;
		END;

	  -- ����Ӫҵ���ֿ�Ԥ���add by liuhe 20120104
	  BEGIN
		SP_PB_DEPTBALFEE(v_seqNo, '1' ,--1Ԥ����,2��֤��,3Ԥ����ͱ�֤��
			   v_TRADEFEE,
					   v_today,p_currOper,p_currDept,p_retCode,p_retMsg);

		IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
			EXCEPTION
			WHEN OTHERS THEN
				ROLLBACK; RETURN;
	  END;
	  
	  --���������꿨�����ʱ��
	  BEGIN
		UPDATE TF_XXPARK_NEW_LOAD
		   SET DEALCODE = '1'
		 WHERE ID = v_XXPARKID;
		IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION WHEN OTHERS THEN
			p_retCode := 'S00505B097'; p_retMsg  := '���������꿨����ʧ��,���󿨺�Ϊ��'|| v_CARDNO|| ',' || SQLERRM;
			ROLLBACK; RETURN;
	  END;
	END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
		ROLLBACK;RETURN;
	END;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors

