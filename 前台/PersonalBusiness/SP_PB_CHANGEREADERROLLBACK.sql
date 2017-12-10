CREATE OR REPLACE PROCEDURE SP_PB_CHANGEREADERROLLBACK
(
	P_OLDSERIALNUMBER      VARCHAR2,  --�ɶ��������к�
	P_SERIALNUMBER         VARCHAR2,  --�¶��������к�
	p_MONEY                INT     ,  --�˻����
    p_TRADEID          out char , --Return trade id
	p_currOper	           char    ,
	p_currDept	           char    ,
	p_retCode          out char    ,  -- Return Code
	p_retMsg           out varchar2   -- Return Message  
)
AS 
    v_seqNo             CHAR(16)       ;
    V_EX                EXCEPTION      ;
    V_TODAY             DATE := SYSDATE;
	V_ID                CHAR(18);
    V_TRADEID           CHAR(16);	
/*
--  ���������������洢����
--  ���α�д
--  ʯ��
--  2013-01-29
*/
BEGIN
    --�ж��Ƿ��쵱����Ա����������
	SELECT TRADEID INTO V_TRADEID 
	FROM(
		SELECT TRADEID 
		FROM TF_B_READER 
		WHERE OPERATETYPECODE = '1B'
		AND   BEGINSERIALNUMBER = P_SERIALNUMBER
		AND   OLDSERIALNUMBER = P_OLDSERIALNUMBER
		AND   OPERATESTAFFNO = p_currOper
		AND   TO_CHAR(OPERATETIME,'YYYYMMDD') = TO_CHAR(V_TODAY,'YYYYMMDD')
		ORDER BY OPERATETIME DESC)
	WHERE ROWNUM = 1;
    
    IF V_TRADEID IS NULL THEN
        p_retCode := 'S094570276'; p_retMsg  := 'δ�ҵ���ǰ����Ա���������������¼,' || SQLERRM;
        RETURN;
    END IF;
	
    --���¶���������̨�˱������¼�����˱�־��Ϊ1���ѻ��ˣ�
    BEGIN
        UPDATE TF_B_READER 
        SET    CANCELTAG = '1'
        WHERE  TRADEID = V_TRADEID;
        
        IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570277'; p_retMsg  := '���¶���������̨�˱������¼ʧ��,' || SQLERRM;
            ROLLBACK; RETURN;
    END;	
	
	--�����¶���������
	BEGIN
		UPDATE TL_R_READER 
		SET    READERSTATE = '1'     , --����
		       SALETIME    = ''      ,
			   SALESTAFFNO = '' 
		WHERE  SERIALNUMBER = P_SERIALNUMBER
		AND    READERSTATE = '2'; --�۳�
		IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570269'; p_retMsg  := '�����¶���������ʧ��' || SQLERRM;
			ROLLBACK; RETURN;
	END;
	
	--��¼�¶������ͻ����ϱ�
	BEGIN
		DELETE FROM TF_F_READERCUSTREC WHERE SERIALNUMBER = P_SERIALNUMBER;
		
		IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570270'; p_retMsg  := '��¼�������ͻ����ϱ�ʧ��' || SQLERRM;
			ROLLBACK; RETURN;				
	END;	
	
	--���¾ɶ���������
	BEGIN
		UPDATE TL_R_READER 
		SET    READERSTATE   = '2'   , --�۳�
		       CHANGETIME    = ''    ,
			   CHANGESTAFFNO = '' 
		WHERE  SERIALNUMBER = P_OLDSERIALNUMBER
		AND    READERSTATE = '3'; --��������
		IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570271'; p_retMsg  := '���¾ɶ���������ʧ��' || SQLERRM;
			ROLLBACK; RETURN;		
	END;
	
	--���¾ɶ���������
	BEGIN
		UPDATE TF_F_READERCUSTREC 
		SET    USETAG       = '1'   --��Ч
		WHERE  SERIALNUMBER = P_OLDSERIALNUMBER
		AND    USETAG       = '0';  --��Ч
		IF SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570272'; p_retMsg  := '���¾ɶ���������ʧ��' || SQLERRM;
			ROLLBACK; RETURN;		
	END;	
	
	--��ȡ��ˮ��
	SP_GetSeq(seq => v_seqNo); 
	p_TRADEID := v_seqNo;
	
	--��¼����������̨�˱�05��������
	BEGIN
		INSERT INTO TF_B_READER(
		    TRADEID     , OPERATETYPECODE , BEGINSERIALNUMBER , ENDSERIALNUMBER ,
			MONEY       , READERNUMBER    , OPERATETIME       , OPERATESTAFFNO  , 
			OLDSERIALNUMBER , CANCELTRADEID
	   )VALUES(
			v_seqNo     , 'R2'            , P_SERIALNUMBER    , P_SERIALNUMBER  ,
			-p_MONEY    , 1               , V_TODAY           , p_currOper      , 
			P_OLDSERIALNUMBER , V_TRADEID);
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570273'; p_retMsg  := '��¼����������̨�˱�ʧ��' || SQLERRM;
			ROLLBACK; RETURN;			
	END;
	
	--��¼����������ͬ����
	BEGIN
		INSERT INTO TF_B_READER_SYNC(
		    TRADEID , OPERATETYPECODE , SERIALNUMBER   , OLDSERIALNUMBER   , SYNCFLAG , OPERATETIME
	   )VALUES(
			v_seqNo , '05'            , P_SERIALNUMBER , P_OLDSERIALNUMBER ,'0'      , V_TODAY);
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570274'; p_retMsg  := '��¼����������̨�˱�ʧ��' || SQLERRM;
			ROLLBACK; RETURN;			
	END;	
	
	v_ID := TO_CHAR(SYSDATE, 'MMDDHHMMSS') || SUBSTR(P_SERIALNUMBER, -8);
	--��¼�ֽ�̨��
	BEGIN
		INSERT INTO TF_B_TRADEFEE(
			ID         , TRADEID        , TRADETYPECODE   , CARDNO        ,
			OTHERFEE   , OPERATESTAFFNO , OPERATEDEPARTID , OPERATETIME 
	   )VALUES(
			v_ID       , v_seqNo        , 'R2'            , P_SERIALNUMBER ,
			-p_MONEY   , p_currOper     , p_currDept      , V_TODAY        
			);

	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570275';
			p_retMsg  := '��¼�ֽ�̨�˱�ʧ��' || SQLERRM;
			ROLLBACK; RETURN;
	END; 	
	
	-- ����Ӫҵ���ֿ�Ԥ����
	BEGIN
	  SP_PB_DEPTBALFEE(v_seqNo, '3' ,--1Ԥ����,2��֤��,3Ԥ����ͱ�֤��
				       -p_MONEY,V_TODAY,p_currOper,p_currDept,p_retCode,p_retMsg);
	
     IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK; RETURN;
   END;	
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;		
END;

/
SHOW ERRORS
