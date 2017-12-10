-- =============================================
-- AUTHOR:		liuhe
-- CREATE DATE: 2013-09-23
-- DESCRIPTION:	���ο�-���մ洢����
-- =============================================
CREATE OR REPLACE PROCEDURE SP_AS_SZTravelCardRecycle
(
	p_ID	          char,
	p_CARDNO	      char,
	p_ASN			  char,
	p_CARDTRADENO	  char,--����-�������
    p_STARTDATE       char,--����-��ʼ��Ч��(yyyyMMdd)
    p_ENDDATE         char,--����-������Ч��(yyyyMMdd)
	p_REASONCODE	  char,--�˿�����
	p_CARDMONEY       int,  --�������
	p_REFUNDMONEY	  int,--�˳�ֵ,����
	p_REFUNDDEPOSIT	  int,--��Ѻ��,����
	p_TRADEPROCFEE    int,--�������ѣ�����
	p_CUSTNAME	      varchar2,--�ͻ�����
	p_PAPERTYPECODE	  varchar2,--֤������
	p_PAPERNO         varchar2,--֤������
	p_CUSTPHONE	      varchar2,--��ϵ�绰
	p_BANKNAME	      varchar2,--��������
	p_BANKNAMESUB	  varchar2,--֧��
	p_BANKACCNO	  	  varchar2,--�����˺�
	p_PURPOSETYPE	  varchar2,--�˻�����
	p_REMARK	      varchar2,--��ע
	p_OPERCARDNO	  char,
	p_CHECKSTAFFNO	  char,
	p_CHECKDEPARTNO	  char,
	p_TRADEID         out char,
	p_currOper	      char,
	p_currDept	      char,
	p_retCode	      out char, -- Return Code
	p_retMsg     	  out varchar2  -- Return Message
)
AS
    v_CARDSTATE        char(2);
    v_TODAY            date := sysdate;
    v_CARDACCMONEY     int;
    v_ASSIGNEDSTAFFNO  char(6);
	v_RESSTATECODE	   char(2);
	v_DEPOSIT          int;
	v_DEPOSIT2       int; --ת����Ѻ���
    v_EX               exception;
BEGIN

    BEGIN
        SELECT RESSTATECODE , ASSIGNEDSTAFFNO
		INTO   V_CARDSTATE  , V_ASSIGNEDSTAFFNO 
        FROM TL_R_ICUSER
        WHERE CARDNO = P_CARDNO;
		
		SELECT DEPOSIT INTO v_DEPOSIT FROM TF_F_CARDREC WHERE CARDNO = P_CARDNO; 
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        P_RETCODE := 'S094570355';
        P_RETMSG  := 'δ�ҵ�������¼,'|| SQLERRM;
        RETURN;
    END;

    --ֻ���۳��Ŀ����ܻ���
    IF V_CARDSTATE != '06' THEN
        P_RETCODE := 'S094570356';
        P_RETMSG  := '�����۳�״̬�Ŀ����ܻ���';
        RETURN;
    END IF;
	
	SP_GETSEQ(SEQ => p_TRADEID);
		
	IF p_REASONCODE = '11' OR p_REASONCODE = '12' OR p_REASONCODE = '13' THEN---�ɶ�������
		
		v_RESSTATECODE := '04';

		--��֤��Ƭ�˻����Ϳ�������Ƿ����
		SELECT CARDACCMONEY INTO V_CARDACCMONEY FROM TF_F_CARDEWALLETACC WHERE CARDNO = P_CARDNO;
		IF V_CARDACCMONEY - P_CARDMONEY < 0 THEN
			P_RETCODE := 'S094570357';
			P_RETMSG  := '�������С�ڿ�������ʱ���ܻ���';
			RETURN;
		ELSE 
			--����ǿɶ������գ�Ȧ�ῨƬ���Ҹ����˻����Ա�֤�������۳���ʱ���˳�ƽ
			BEGIN
				UPDATE TF_F_CARDEWALLETACC
				SET  CARDACCMONEY = CARDACCMONEY - P_CARDMONEY              
				WHERE  CARDNO = p_CARDNO
				AND USETAG='1' 
				AND V_CARDACCMONEY - P_CARDMONEY>=0;
				
				IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
			EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S001002113';
					p_retMsg  := 'S001002113:�����˻���ʧ��';
					ROLLBACK; RETURN;
			END;
		END IF;
		
		---��¼����ҵ��̨�ʣ��ɶ�currentmoney��Ϊ0
		BEGIN
			INSERT INTO TF_B_TRADE
				(TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,REASONCODE,CURRENTMONEY,
				OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,CARDSTATE,SERSTAKETAG)
			SELECT
				p_TRADEID,p_ID,'7K',p_CARDNO,p_ASN,CARDTYPECODE,p_CARDTRADENO,p_REASONCODE,p_REFUNDMONEY + p_REFUNDDEPOSIT + p_TRADEPROCFEE,
				p_currOper,p_currDept,v_TODAY,CARDSTATE,SERSTAKETAG
			FROM TF_F_CARDREC
			WHERE CARDNO = p_CARDNO;
			 
			EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S001008106';
					p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
					ROLLBACK; RETURN;
		END;
		
		---�ֽ�̨��
		BEGIN
			INSERT INTO TF_B_TRADEFEE
				(ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,PREMONEY,CARDDEPOSITFEE,SUPPLYMONEY,
				TRADEPROCFEE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
			VAlUES
				(p_ID,p_TRADEID,'7K',p_CARDNO,p_CARDTRADENO,p_CARDMONEY,p_REFUNDDEPOSIT ,p_REFUNDMONEY,
				p_TRADEPROCFEE,p_currOper,p_currDept,v_TODAY);

		EXCEPTION
			WHEN OTHERS THEN
				p_retCode := 'S001007119';
				p_retMsg  := 'Fail to log the cash' || SQLERRM;
				ROLLBACK; RETURN;
		END;
		
		--д��̨��
		BEGIN
					
			INSERT INTO TF_CARD_TRADE
                    (TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,lMoney,lOldMoney,strTermno,
                    Cardtradeno,OPERATETIME,SUCTAG)
            VALUES
                    (p_TRADEID,'7K',p_OPERCARDNO,p_CARDNO,p_CARDMONEY,p_CARDMONEY,'112233445566',
                    p_CARDTRADENO,v_TODAY,'0');
					
		EXCEPTION
			WHEN OTHERS THEN
				p_retCode := 'S001001139';
				p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
				ROLLBACK; RETURN;
		END;

	ELSE ---���ɶ�������
	
		v_RESSTATECODE := '03'; --���ɶ�����״̬��Ϊ���ϣ��������۳�
		
		--��¼����ת��̨�ʱ�
		BEGIN
		 INSERT INTO TF_B_TRADE_SZTRAVEL_RF
		   (TRADEID, CARDNO, ID, ASN, BANKNAME, BANKNAMESUB, BANKACCNO, BACKMONEY,
		   BACKDEPOSIT, 
		   CUSTNAME, PAPERTYPECODE, PAPERNO, CUSTPHONE,
		   PURPOSETYPE, ISUPDATED, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME, REMARK)
		 VALUES
		   (p_TRADEID, p_CARDNO, p_ID, p_ASN, p_BANKNAME, p_BANKNAMESUB,p_BANKACCNO,0,
       DECODE(p_REASONCODE,'15',v_DEPOSIT - p_TRADEPROCFEE,0),
	   p_CUSTNAME, p_PAPERTYPECODE, p_PAPERNO, p_CUSTPHONE,
		   p_PURPOSETYPE, 0, p_currOper, p_currDept, v_TODAY, p_REMARK);

		EXCEPTION
			WHEN OTHERS THEN
				p_retCode := 'S001001940';
				p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
				ROLLBACK; RETURN;
		END;
		
		---��¼����ҵ��̨�ʣ� ���ɶ�currentmoneyΪ0
		BEGIN
			INSERT INTO TF_B_TRADE
				(TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,REASONCODE,CURRENTMONEY,
				OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,CHECKSTAFFNO,CHECKDEPARTNO,CHECKTIME,CARDSTATE,SERSTAKETAG)
			SELECT
				p_TRADEID,p_ID,'7K',p_CARDNO,p_ASN,CARDTYPECODE,p_CARDTRADENO,p_REASONCODE,0,
				p_currOper,p_currDept,v_TODAY,p_CHECKSTAFFNO,p_CHECKDEPARTNO,v_TODAY,CARDSTATE,SERSTAKETAG
			FROM TF_F_CARDREC
			WHERE CARDNO = p_CARDNO;
			 
			EXCEPTION
				WHEN OTHERS THEN
					p_retCode := 'S001008106';
					p_retMsg  := 'Error occurred while log the operation' || SQLERRM;
					ROLLBACK; RETURN;
		END;
		
	END IF;

	IF p_REASONCODE = '15' THEN-- ���ɶ�p_REFUNDDEPOSIT�������Ϊ0������ת����Ѻ�𲻵���v_DEPOSIT + p_REFUNDDEPOSIT,Ӧ�õ���0
		v_DEPOSIT2 := 0;
	ELSE v_DEPOSIT2 := v_DEPOSIT + p_REFUNDDEPOSIT;
	END IF;
    --��¼���ο���չҵ��̨�ʱ�
    BEGIN
        INSERT INTO TF_B_TRADE_SZTRAVEL(
            TRADEID            , CARDNO         , ID              , TRADETYPECODE ,
            ASN                , DEPOSIT        , TRADEPROCFEE    , CARDACCMONEY  ,
            CARDSTARTDATE      , CARDENDDATE    , DBSTARTDATE     , DBENDDATE     ,
            DELAYENDDATE       , OPERATESTAFFNO , OPERATEDEPARTID , OPERATETIME   ,
			OLDASSIGNEDSTAFFNO , ASSIGNEDSTAFFNO
       )VALUES(
            p_TRADEID         , P_CARDNO       , P_ID            , '7K'          ,
            P_ASN             , v_DEPOSIT2 , p_TRADEPROCFEE , P_CARDMONEY   ,
            P_STARTDATE       , P_ENDDATE      , NULL            , NULL          ,
            NULL              , P_CURROPER     , P_CURRDEPT      , V_TODAY       ,
			V_ASSIGNEDSTAFFNO , P_CURROPER
            );

        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE := 'S094570360';
        P_RETMSG  := '��¼���ο���չҵ��̨�ʱ�ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;
    END;
	
    --���¿�����
    BEGIN
        UPDATE TL_R_ICUSER
        SET    RESSTATECODE     = v_RESSTATECODE,
               RECLAIMTIME      = V_TODAY   ,
               UPDATESTAFFNO    = P_CURROPER,
               UPDATETIME       = V_TODAY   ,
               ASSIGNEDDEPARTID = P_CURRDEPT,   --���Ŀ�Ƭ��������
               ASSIGNEDSTAFFNO  = P_CURROPER    --���Ŀ�Ƭ����Ա��
        WHERE  CARDNO = P_CARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE := 'S094570358';
        P_RETMSG  := '���¿�����ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;
    END;

    --�޸Ŀ����ϱ���Ϣ
    BEGIN
        UPDATE TF_F_CARDREC
        SET    CARDSTATE     = '31', --���ο�����
			   SERVICEMONEY  = DEPOSIT,
               UPDATESTAFFNO = P_CURROPER,
               UPDATETIME    = V_TODAY
        WHERE  CARDNO = P_CARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE := 'S094570359';
        P_RETMSG  := '���¿����ϱ�ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;
    END;

    P_RETCODE := '0000000000';
    P_RETMSG  := '';
    COMMIT; RETURN;

END;


/

show errors
