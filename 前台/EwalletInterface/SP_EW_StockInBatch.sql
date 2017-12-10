CREATE OR REPLACE PROCEDURE SP_EW_StockInBatch
(
	p_TRADEID     CHAR , -- tradeid
	p_unitPrice   INT , -- Card Unit Price
	p_effDate     CHAR, -- Effective Date 
	p_expDate     CHAR, -- Expired Date 
	p_currOper    CHAR, -- Current Operator 
	p_retCode OUT CHAR, -- Return Code 
	p_retMsg  OUT VARCHAR2
)
AS
	v_cardNo     CHAR(16);
	v_asn        CHAR(16);
	v_exist      INT := 0;
	v_today      date := sysdate;
	v_seqNo      CHAR(16);  
	v_currDept   CHAR(4) ; --���ű���
	v_faceType   CHAR(4) ; -- Card Face Type 
	v_cardType   CHAR(2) ; -- Card Type
	v_ex         EXCEPTION;
	v_COSTYPE    CHAR(2);
	v_CHIPTYPE   CHAR(2);
	v_PRODUCE    CHAR(2);
	v_APPVERNO   CHAR(2);
	V_COUNT      INT;
	V_CARDORDERID       CHAR(18);
	V_CARDORDERSTATE    CHAR(1);   --������״̬
    V_ORDERCARDNUM      INT    ;   --������Ҫ������
    V_ALREADYARRIVENUM  INT    ;   --�ѵ�������		
BEGIN
	--��ȡ���ű���
	BEGIN
		SELECT DEPARTNO 
		INTO   v_currDept
		FROM   TD_M_INSIDESTAFF
		WHERE  STAFFNO = p_currOper;
	EXCEPTION WHEN NO_DATA_FOUND THEN 
		v_currDept := '9002';
	END; 
	
	SELECT COUNT(*) INTO V_COUNT FROM TF_B_CARDRECORDSET WHERE TRADEID = p_TRADEID;
	
    FOR V_CUR IN (SELECT CARDNO, COSTYPE , CHIPTYPE, PRODUCE , APPVERSION  FROM TF_B_CARDRECORDSET WHERE TRADEID = p_TRADEID)
	LOOP
		v_CARDNO   := V_CUR.CARDNO;
		v_COSTYPE  := V_CUR.COSTYPE;
		v_CHIPTYPE := V_CUR.CHIPTYPE;
		v_PRODUCE  := V_CUR.PRODUCE;
		v_APPVERNO := V_CUR.APPVERSION;
		
		--��ȡ��Ƭ���ͺͿ�������
		v_cardType  := substr(v_CARDNO,5,2);
		v_faceType  := substr(v_CARDNO,5,4);

		--�жϿ�Ƭ�Ƿ��Ƕ���״̬
		BEGIN
			SELECT COUNT(*) INTO v_exist 
			FROM   TL_R_ICUSER 
			WHERE  CARDNO = v_CARDNO
			AND    RESSTATECODE  = '15';

			IF v_exist < 1 THEN
				p_retCode := 'S094570114'; 
				p_retMsg  := '�����û����д��ڿ�Ƭ��Ϊ����״̬�Ŀ�';
				ROLLBACK; RETURN;
			END IF;    
		END;
		
		--���
		BEGIN
			v_asn    := '00215000' || SUBSTR(v_CARDNO, -8);
												
			--�����û�������
			UPDATE TL_R_ICUSER
			SET    RESSTATECODE     = '00'        ,  --���״̬
				   ASN              = v_asn       ,
				   CARDPRICE        = p_unitPrice ,
				   COSTYPECODE      = v_COSTYPE   ,
				   CARDTYPECODE     = v_cardType  ,
				   CARDSURFACECODE  = v_faceType  ,
				   CARDCHIPTYPECODE = v_CHIPTYPE  ,
				   APPTYPECODE      = '01'        ,
				   APPVERNO         = v_APPVERNO  ,
				   VALIDBEGINDATE   = p_effDate   ,
				   VALIDENDDATE     = p_expDate   ,
				   INSTIME          = v_today     ,
				   UPDATESTAFFNO    = P_CURROPER  ,
				   UPDATETIME       = v_today    
			WHERE  RESSTATECODE     = '15'          --����״̬
			AND    CARDNO = v_CARDNO;		

			IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
			WHEN OTHERS THEN
				p_retCode := 'S094570115'; p_retMsg  := '�����û�������ʧ��,' || SQLERRM;
				RETURN;
		END;
		 
		SP_GetSeq(seq => v_seqNo);

		--��¼���񿨿�����̨�˱�
		BEGIN
			INSERT INTO TF_R_SMKICUSERTRADE(	
				TRADEID         , CARDNO           , COSTYPECODE       , CARDTYPECODE , 
				MANUTYPECODE    , CARDSURFACECODE  , CARDCHIPTYPECODE  , CARDPRICE    , 
				OPETYPECODE     , OPERATESTAFFNO   , OPERATEDEPARTID   , OPERATETIME
		   )VALUES(	
				v_seqNo         , v_CARDNO         , v_COSTYPE         , v_cardType   , 
				v_PRODUCE       , v_faceType       , v_CHIPTYPE        , p_unitPrice  ,
				'00'            , p_currOper       , v_currDept        , v_today	
				);
	
		   IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
			WHEN OTHERS THEN
				p_retCode := 'S002P01B03'; p_retMsg  := '�����û���������̨��ʧ��' || SQLERRM;
				RETURN;
		END;
    END LOOP;
	
	--��ѯ�������������ź����󵥺�
	SELECT CARDORDERID ,
	       CARDNUM ,
		   ALREADYARRIVENUM
	INTO   V_CARDORDERID ,
	       V_ORDERCARDNUM ,
		   V_ALREADYARRIVENUM
	FROM TF_F_SMK_CARDORDER 
	WHERE (v_CARDNO BETWEEN BEGINCARDNO AND ENDCARDNO)
	AND    CARDORDERSTATE IN('1','3') --1���ͨ����3���ֵ���
	AND    USETAG = '1'	;
	
	IF V_COUNT + V_ALREADYARRIVENUM >= V_ORDERCARDNUM THEN
	   V_CARDORDERSTATE := '4';  --ȫ������
	ELSE
	   V_CARDORDERSTATE := '3';  --���ֵ���
	END IF; 	
	
	BEGIN
		--���¶�����
		UPDATE TF_F_SMK_CARDORDER
		SET    CARDORDERSTATE = V_CARDORDERSTATE ,  --������״̬
			   LATELYDATE     = TO_CHAR(V_TODAY,'YYYYMMDD') ,
			   ALREADYARRIVENUM = V_ALREADYARRIVENUM + V_COUNT  --�ѵ�������
		WHERE  CARDORDERID = V_CARDORDERID
		AND    USETAG = '1';
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570117'; p_retMsg  := '���¶�����ʧ��'|| SQLERRM;
			ROLLBACK; RETURN;
	END;	
	
	BEGIN
		--��¼���ݹ���̨�˱�
		INSERT INTO TF_B_SMK_ORDERMANAGE(
			TRADEID          , ORDERID           , OPERATETYPECODE   ,
			CARDNUM          , OPERATETIME       , OPERATESTAFF      
		)VALUES(
			v_seqNo          , V_CARDORDERID     , '07'              ,
			V_COUNT          , V_TODAY           , P_CURROPER        
			);    
	EXCEPTION
		WHEN OTHERS THEN
			p_retCode := 'S094570119'; p_retMsg  := '��¼���ݹ���̨�˱�ʧ��'|| SQLERRM;
			ROLLBACK; RETURN;	   
	END;		
	
    p_retCode := '0000000000'; p_retMsg  := '';
    RETURN;
END;
/

show errors   