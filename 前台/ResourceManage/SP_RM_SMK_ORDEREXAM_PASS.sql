--------------------------------------------------
--  �����µ����ͨ���洢����
--  ���α�д
--  ������
--  2012-11-26
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_SMK_ORDEREXAM_PASS
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
				CARDORDERSTATE , REMARK
			INTO
			    V_CARDNUM      , V_BEGINCARDNO , V_ENDCARDNO    , V_CARDORDERTYPE,
			  	V_FILENAME     , V_MANUTYPECODE, V_BATCHNO      , V_BATCHDATE    ,
				V_CARDORDERSTATE, V_REMARK
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
			SET    CARDORDERSTATE = '1'     ,
			       EXAMTIME = V_TODAY       ,
			       EXAMSTAFFNO = P_CURROPER
			WHERE  CARDORDERID = V_CARDORDERID ;		
		
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        P_RETCODE := 'S094570107';
        P_RETMSG  := '���¶�����ʧ��'||SQLERRM;      
        ROLLBACK; RETURN; 			
	  END;				
		
	    -- �ж�ʱ�����п�Ƭ�ڿ�
	    SELECT count(*) INTO v_exist FROM  TL_R_ICUSER WHERE CARDNO BETWEEN V_BEGINCARDNO AND V_ENDCARDNO;
	
	    IF v_exist > 0 THEN
	        p_retCode := 'A002P01B01'; p_retMsg  := '���п�Ƭ�����ڿ���';
	        ROLLBACK;RETURN;
	    END IF;
	
	    --�û������
	    V_FROMCARD := TO_NUMBER(V_BEGINCARDNO);
	    V_TOCARD   := TO_NUMBER(V_ENDCARDNO);
	
	    BEGIN
	        LOOP
	            V_CARDNO := SUBSTR('0000000000000000' || TO_CHAR(V_FROMCARD), -16);
	            V_ASN    := '00215000' || SUBSTR(V_CARDNO, -8);
	            --��¼IC������
	            INSERT INTO TL_R_ICUSER( 
	                CARDNO          , ASN              , CARDPRICE    , 
	                UPDATESTAFFNO   , UPDATETIME       , 
	                MANUTYPECODE    , RESSTATECODE
	           )VALUES(
	                V_CARDNO        , V_ASN            , 0            , 
	                P_CURROPER      , V_TODAY          , 
	                V_MANUTYPECODE  , '15'         );
	
	            EXIT WHEN  V_FROMCARD  >=  V_TOCARD;
	
	            V_FROMCARD := V_FROMCARD + 1;
	        END LOOP;
	    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S002P01B02'; p_retMsg  := '��¼����Ǯ��IC������ʧ��,' || SQLERRM;
	            ROLLBACK; RETURN;
	    END;
	
	    
	
	    --��¼�û���������̨��
	    BEGIN
	        INSERT INTO TF_R_ICUSERTRADE(
	            TRADEID          , BEGINCARDNO     , ENDCARDNO       , CARDNUM         ,
	            CARDTYPECODE     , MANUTYPECODE    , OPETYPECODE      , OPERATESTAFFNO ,
				OPERATEDEPARTID  , OPERATETIME
	       )VALUES(
	            v_seqNo          , V_BEGINCARDNO   , V_ENDCARDNO     , V_CARDNUM       , 
	            '18'      		 , V_MANUTYPECODE  ,'20'             , P_CURROPER      ,
				P_CURRDEPT       , V_TODAY
	            );
	    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S002P01B03'; p_retMsg  := '��¼�û���������̨��ʧ��' || SQLERRM;
	            ROLLBACK; RETURN;
	    END;
		
			--ɾ����Ƭ�µ��������ر��¼
			BEGIN
				DELETE FROM TD_M_SMKCARDNO_EXCLUDE WHERE CARDORDERID = V_CARDORDERID;
				
				IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		  EXCEPTION
		     WHEN OTHERS THEN
		          p_retCode := 'S094570157'; p_retMsg  := 'ɾ����Ƭ�µ��������ر��¼ʧ��' || SQLERRM;
		          ROLLBACK; RETURN;				
			END;

		--��¼���ݹ���̨�˱�
		BEGIN	
			INSERT INTO TF_B_SMK_ORDERMANAGE(
					TRADEID				,ORDERID			,OPERATETYPECODE	,CARDNUM			,
					MANUTYPECODE		,BATCHNO			,FILENAME			,BATCHDATE			,
					OPERATETIME			,OPERATESTAFF		,REMARK
					)VALUES
					(v_seqNo			,V_CARDORDERID    	,'03'				,V_CARDNUM			,
					V_MANUTYPECODE		,V_BATCHNO			,V_FILENAME			,V_BATCHDATE		,
					V_TODAY				,p_currOper			,V_REMARK);
					IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S094780021';
					  P_RETMSG  := '������񿨵��ݹ���̨�ʱ�ʧ��'||SQLERRM;      
					  ROLLBACK; RETURN;				  
		END;
		
		--ͬ������ϵͳ�������񿨿���
		BEGIN
			SP_CM_ORDERIN(V_BEGINCARDNO,V_ENDCARDNO,
						p_currOper,p_currDept,p_retCode,p_retMsg);
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
show errors