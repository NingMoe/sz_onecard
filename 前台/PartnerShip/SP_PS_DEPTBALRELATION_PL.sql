  -- =============================================
  -- AUTHOR:    LIUHE
  -- CREATE DATE: 2011-12-28
  -- DESCRIPTION:  ������㵥ԪӶ�𷽰���ɾ��
  -- MODIFY: 
  -- =============================================
CREATE OR REPLACE PROCEDURE SP_PS_DEPTBALRELATION
(
	P_BALUNITNO     CHAR,
	P_DEPARTNO   	CHAR,
	P_OPTYPE        CHAR,
	P_CURROPER CHAR,
	P_CURRDEPT CHAR,
	P_RETCODE  OUT CHAR,
	P_RETMSG   OUT VARCHAR2
)
AS
  V_CURRDATE  DATE := SYSDATE;
  V_SEQNO     CHAR(16);
  V_DTRADETYPECODE CHAR(2);
  V_COUNT 	  INT;
BEGIN
	
	
	IF P_OPTYPE = 'ADD' THEN 
		
		V_DTRADETYPECODE :='11';
	
			--�жϵ�ǰ�����Ƿ��ж�Ӧ�Ľ��㵥Ԫ,������
		SELECT	COUNT(*) INTO V_COUNT
		FROM  TF_B_DEPTBALTRADE B, TH_DEPTBAL_RELATION R
		WHERE B.TRADEID = R.TRADEID
			AND  B.STATECODE = '1'
			AND  R.DEPARTNO  =  P_DEPARTNO;

		IF V_COUNT > 0 THEN
				p_retCode := 'S008107911';
				p_retMsg  := '��ǰ�����Ѿ��ж�Ӧ�Ľ��㵥ԪΪ������״̬';
				RETURN;
		END IF;

		--�жϵ�ǰ�����Ƿ��ж�Ӧ�Ľ��㵥Ԫ,�����
		SELECT	COUNT(*) INTO V_COUNT
		FROM  TF_B_DEPTBALTRADE_EXAM E, TH_DEPTBAL_RELATION  R
		WHERE E.TRADEID = R.TRADEID
			AND  E.STATECODE = '1'
			AND  R.DEPARTNO  =  P_DEPARTNO;

		IF V_COUNT > 0 THEN
					 p_retCode := 'S008107912';
				p_retMsg  := '��ǰ�����Ѿ��ж�Ӧ�Ľ��㵥ԪΪ�����״̬';
				RETURN;
		END IF;

		--�жϵ�ǰ�����Ƿ��ж�Ӧ�Ľ��㵥Ԫ,����ͨ��
		SELECT	COUNT(*) INTO V_COUNT
		FROM 	TD_DEPTBAL_RELATION
		WHERE	DEPARTNO = P_DEPARTNO
			  AND USETAG = '1';

		IF V_COUNT > 0 THEN
				p_retCode := 'S008107913';
				p_retMsg  := '��ǰ�����Ѿ��ж�Ӧ�Ľ��㵥Ԫ';
				RETURN;
		END IF;
	
	
	ELSIF P_OPTYPE = 'DEL' THEN V_DTRADETYPECODE :='13';
	
		--�жϵ�ǰ�����Ƿ��ж�Ӧ�Ľ��㵥Ԫ,������
		SELECT	COUNT(*) INTO V_COUNT
		FROM  TF_B_DEPTBALTRADE B, TH_DEPTBAL_RELATION R
		WHERE B.TRADEID = R.TRADEID
			AND  B.STATECODE = '1'
			AND  R.DEPARTNO  =  P_DEPARTNO;

		IF V_COUNT > 0 THEN
				p_retCode := 'S008107911';
				p_retMsg  := '��ǰ�����Ѿ��ж�Ӧ�Ľ��㵥ԪΪ������״̬';
				RETURN;
		END IF;

		--�жϵ�ǰ�����Ƿ��ж�Ӧ�Ľ��㵥Ԫ,�����
		SELECT	COUNT(*) INTO V_COUNT
		FROM  TF_B_DEPTBALTRADE_EXAM E, TH_DEPTBAL_RELATION  R
		WHERE E.TRADEID = R.TRADEID
			AND  E.STATECODE = '1'
			AND  R.DEPARTNO  =  P_DEPARTNO;

		IF V_COUNT > 0 THEN
					 p_retCode := 'S008107912';
				p_retMsg  := '��ǰ�����Ѿ��ж�Ӧ�Ľ��㵥ԪΪ�����״̬';
				RETURN;
		END IF;
		
		 --�жϽ��㵥Ԫ�Ƿ��ѽ���
    	SELECT COUNT(*) INTO V_COUNT FROM TF_DEPTBALTRADE_BAL WHERE DBALUNITNO = P_BALUNITNO;
        IF V_COUNT != 0 THEN --�ѽ���
		        P_RETCODE := 'S008109020';
		        P_RETMSG  := '������㵥Ԫ�ѽ��㣬����ɾ��';   
		    RETURN; 
		END IF; 
		
	END IF; 

  --2) GET THE SEQUENCE NUMBER
  SP_GETSEQ(SEQ => V_SEQNO);


  --3) ADD MAIN LOG INFO
  BEGIN
    INSERT INTO TF_B_DEPTBALTRADE
      (TRADEID,
       DTRADETYPECODE,
       ASSOCIATECODE,
       OPERATESTAFFNO,
       OPERATEDEPARTID,
       OPERATETIME,
       STATECODE)
    VALUES
      (V_SEQNO, V_DTRADETYPECODE, P_BALUNITNO, P_CURROPER, P_CURRDEPT, V_CURRDATE, '1');

  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S008107071';
      P_RETMSG  := '��¼̨����Ϣʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  --4) ADD ADDITIONAL LOG INFO  INTO TF_TBALUNIT_COMSCHEMECHANGE
  BEGIN
	INSERT INTO TH_DEPTBAL_RELATION	
		(TRADEID, DEPARTNO, DBALUNITNO,	
		USETAG, UPDATESTAFFNO,UPDATETIME) 	
	VALUES	(V_SEQNO, P_DEPARTNO, P_BALUNITNO, 		
		'1', P_CURROPER, V_CURRDATE); 

  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S008107072';
      P_RETMSG  := '��¼������㵥Ԫ��ϵ��ʷ��ʧ��'|| SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  --5) ADD ADDITIONAL LOG INFO  INTO TF_B_TRADE_BALUNITCHANGE
  BEGIN
    INSERT INTO TH_DEPT_BALUNIT
      (TRADEID ,
      DBALUNITNO,
       DBALUNIT,
       BANKCODE,
       BANKACCNO,
       CREATETIME,
       BALCYCLETYPECODE,
       BALINTERVAL,
       FINCYCLETYPECODE,
       FININTERVAL,
       FINTYPECODE,
       FINBANKCODE,
       LINKMAN,
       UNITPHONE,
       UNITADD,
       UNITEMAIL,
       USETAG,
       DEPTTYPE,
       PREPAYWARNLINE,
       PREPAYLIMITLINE,
       UPDATESTAFFNO,
       UPDATETIME,
       REMARK)
      SELECT V_SEQNO,
             DBALUNITNO,
             DBALUNIT,
             BANKCODE,
             BANKACCNO,
             CREATETIME,
             BALCYCLETYPECODE,
             BALINTERVAL,
             FINCYCLETYPECODE,
             FININTERVAL,
             FINTYPECODE,
             FINBANKCODE,
             LINKMAN,
             UNITPHONE,
             UNITADD,
             UNITEMAIL,
             USETAG,
             DEPTTYPE,
             PREPAYWARNLINE,
             PREPAYLIMITLINE,
             UPDATESTAFFNO,
             UPDATETIME,
             REMARK
        FROM TF_DEPT_BALUNIT
       WHERE DBALUNITNO = P_BALUNITNO;

  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S008107082';
      P_RETMSG  := 'д��������㵥Ԫ����ʷ��ʧ��' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  P_RETCODE := '0000000000';
  P_RETMSG  := '';
  COMMIT;
  RETURN;
END;



/

  SHOW ERRORS
