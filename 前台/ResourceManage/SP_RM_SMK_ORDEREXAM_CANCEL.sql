--------------------------------------------------
--  �����µ����ͨ���洢����
--  ���α�д
--  ������
--  2012-11-26
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_SMK_ORDEREXAM_CANCEL
(
    P_SESSIONID       CHAR,
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    V_CARDORDERID     CHAR(18);     --��������
    V_CARDORDERTYPE   CHAR(2);      --��������
	V_CARDORDERSTATE  CHAR(1);		--������״̬
	V_FILENAME		  VARCHAR2(255);--�ƿ��ļ���
    V_CARDNUM         INT;          --��������
    V_BEGINCARDNO     VARCHAR2(16); --��ʼ����
    V_ENDCARDNO       VARCHAR2(16); --��������
	V_BATCHNO		  VARCHAR2(30); --���κ�
	V_BATCHDATE		  VARCHAR2(20);	--��������
    V_MANUTYPECODE    CHAR(2);      --��Ƭ����
	V_REMARK		  VARCHAR2(255);--��ע
	V_ID			  NUMERIC(16);  --�ƿ��ļ�����ID
        
    V_FROMCARD        NUMERIC(16);  --��ʼ����
    V_TOCARD          NUMERIC(16);  --��������
    V_CARDNO          VARCHAR2(16); --����
    V_ASN             CHAR(16);     --ASN��
    v_seqNo           CHAR(16);     --��ˮ��
    V_EXIST           INT     ;     --��������
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
    
BEGIN
	SELECT f0 INTO V_CARDORDERID FROM TMP_COMMON WHERE f1 = p_SESSIONID;
	
	  --��ȡ��ˮ��
	  SP_GetSeq(seq => v_seqNo);
	  BEGIN
	  	--������ֵ
			SELECT
			    CARDNUM        , BEGINCARDNO   , ENDCARDNO       , CARDORDERTYPE,
			    FILENAME       , MANUTYPECODE  , BATCHNO         , BATCHDATE 	,
				CARDORDERSTATE , REMARK		   , FILEID
			INTO
			    V_CARDNUM      , V_BEGINCARDNO , V_ENDCARDNO    , V_CARDORDERTYPE,
			  	V_FILENAME     , V_MANUTYPECODE, V_BATCHNO      , V_BATCHDATE    ,
				V_CARDORDERSTATE, V_REMARK	   , V_ID
			FROM TF_F_SMK_CARDORDER
			WHERE CARDORDERID = V_CARDORDERID;
	  EXCEPTION
			WHEN NO_DATA_FOUND THEN
		          p_retCode := 'S094570156'; 
		          p_retMsg  := 'δ�ҵ�������';
		          ROLLBACK; RETURN;
	  END;
		
		--���¶�����
		BEGIN
			UPDATE TF_F_SMK_CARDORDER 
			SET    CARDORDERSTATE = '2'     ,
			       EXAMTIME = V_TODAY       ,
			       EXAMSTAFFNO = P_CURROPER
			WHERE  CARDORDERID = V_CARDORDERID 
				AND CARDORDERSTATE IN ('0','1');	--0:�����  1�����ͨ��
		
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S094570107';
        P_RETMSG  := '���¶�����ʧ��'||SQLERRM;      
        ROLLBACK; RETURN; 			
	  END;				
		
		--ɾ����Ƭ�µ��������ر��¼
		IF V_CARDORDERSTATE = '0' THEN
			BEGIN
				DELETE FROM TD_M_SMKCARDNO_EXCLUDE WHERE CARDORDERID = V_CARDORDERID;
				
				IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		  EXCEPTION
			 WHEN OTHERS THEN
				  p_retCode := 'S094570157'; p_retMsg  := 'ɾ����Ƭ�µ��������ر��¼ʧ��' || SQLERRM;
				  ROLLBACK; RETURN;				
			END;
		END IF;

		--��¼���ݹ���̨�˱�
		BEGIN	
			INSERT INTO TF_B_SMK_ORDERMANAGE(
					TRADEID				,ORDERID			,OPERATETYPECODE	,CARDNUM			,
					MANUTYPECODE		,BATCHNO			,FILENAME			,BATCHDATE			,
					OPERATETIME			,OPERATESTAFF		,REMARK
					)VALUES
					(v_seqNo			,V_CARDORDERID    	,'04'				,V_CARDNUM			,
					V_MANUTYPECODE		,V_BATCHNO			,V_FILENAME			,V_BATCHDATE		,
					V_TODAY				,p_currOper			,V_REMARK);
					IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S094780021';
					  P_RETMSG  := '������񿨵��ݹ���̨�ʱ�ʧ��'||SQLERRM;
					  ROLLBACK; RETURN;
		END;
		
			--ͬ������ϵͳ�޸��ƿ��ļ�����洢����
		IF V_CARDORDERTYPE = '01' THEN
			BEGIN
				SP_SYN_CARDFILEMODIFY(V_ID,'0',V_TODAY,V_CARDORDERID,
									p_currOper,p_currDept,p_retCode,p_retMsg);
			IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
				EXCEPTION
				WHEN OTHERS THEN
					ROLLBACK; RETURN;
			END; 
		END IF;

    p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;    	  
END;

/
show errors