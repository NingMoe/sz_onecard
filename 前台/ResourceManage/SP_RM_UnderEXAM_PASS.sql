--------------------------------------------------
--  �����µ����ͨ���洢����
--  ���α�д
--  ������
--  2012-11-26
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_UnderEXAM_PASS
(
    P_SESSIONID       CHAR,
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    V_RESOURCEORDERID		CHAR(18);     --��������
	V_APPLYORDERID			CHAR(18);		--���󵥺�
	V_RESOURCECODE			CHAR(6);		--��Դ����
	V_ATTRIBUTE1			VARCHAR2(50);	--��Դ����1
	V_ATTRIBUTE2			VARCHAR2(50);	--��Դ����2
	V_ATTRIBUTE3			VARCHAR2(50);	--��Դ����3
	V_ATTRIBUTE4			VARCHAR2(50);	--��Դ����4
	V_ATTRIBUTE5			VARCHAR2(50);	--��Դ����5
	V_ATTRIBUTE6			VARCHAR2(50);	--��Դ����6
	V_RESOURCENUM			INT;			--��������
	V_REQUIREDATE			CHAR(8);		--Ҫ�󵽻�����
	V_LATELYDATE			CHAR(8);		--�����������
	V_ALREADYARRIVENUM		INT;			--�ѵ�������
	V_RESOURCEAPPLYNUM		INT;			--��������
	V_APPLYORDERTYPE		CHAR(1);		--����״̬
	
	v_seqNo           CHAR(16);     --��ˮ��
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
    
BEGIN
	SELECT f0 INTO V_RESOURCEORDERID FROM TMP_COMMON WHERE f1 = p_SESSIONID;
	
	  --��ȡ��ˮ��
	  SP_GetSeq(seq => v_seqNo);
	  BEGIN
	  	--������ֵ
			SELECT
					APPLYORDERID  ,RESOURCECODE    ,ATTRIBUTE1    ,ATTRIBUTE2     ,
					ATTRIBUTE3    ,ATTRIBUTE4      ,ATTRIBUTE5    ,ATTRIBUTE6     ,
					RESOURCENUM   ,REQUIREDATE     ,LATELYDATE    ,ALREADYARRIVENUM
			INTO
					V_APPLYORDERID  ,V_RESOURCECODE    ,V_ATTRIBUTE1    ,V_ATTRIBUTE2     ,
					V_ATTRIBUTE3    ,V_ATTRIBUTE4      ,V_ATTRIBUTE5    ,V_ATTRIBUTE6     ,
					V_RESOURCENUM   ,V_REQUIREDATE     ,V_LATELYDATE    ,V_ALREADYARRIVENUM
			FROM   TF_F_RESOURCEORDER   ---��Դ������
			WHERE  RESOURCEORDERID = V_RESOURCEORDERID ;
			  EXCEPTION
					WHEN NO_DATA_FOUND THEN
						  p_retCode := 'S094570156'; 
						  p_retMsg  := 'δ�ҵ�������';
						  ROLLBACK; RETURN;
	  END;
	  
	  BEGIN
			SELECT RESOURCENUM  INTO V_RESOURCEAPPLYNUM FROM TF_F_RESOURCEAPPLYORDER  ---��Դ����	
			WHERE APPLYORDERID = V_APPLYORDERID; 	
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					p_retCode := 'S094780060'; 
				    p_retMsg  := 'δ�ҵ�����';
				    ROLLBACK; RETURN;
	  END;
		
		--���¶�����
	BEGIN
			UPDATE TF_F_RESOURCEORDER  
			SET    ORDERSTATE = '1'     ,
			       EXAMTIME = V_TODAY       ,
			       EXAMSTAFFNO = P_CURROPER
			WHERE  RESOURCEORDERID = V_RESOURCEORDERID ;
		
			  IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
			EXCEPTION
			  WHEN OTHERS THEN
				P_RETCODE := 'S001002402';
				P_RETMSG  := '���¶�������ʧ��'||SQLERRM;
				ROLLBACK; RETURN;
	  END;
		
	--����״̬
	IF V_RESOURCENUM<V_RESOURCEAPPLYNUM THEN
		V_APPLYORDERTYPE :='1';
    ELSE
		V_APPLYORDERTYPE :='2';
	END IF;
	
	--�������󵥱�
	BEGIN
		UPDATE  TF_F_RESOURCEAPPLYORDER
		SET     APPLYORDERTYPE = V_APPLYORDERTYPE
		WHERE   APPLYORDERID = V_APPLYORDERID;
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
			EXCEPTION
			  WHEN OTHERS THEN
				P_RETCODE := 'S001002403';
				P_RETMSG  := '�������󵥱�ʧ��'||SQLERRM;      
				ROLLBACK; RETURN; 
	END;

	--��¼���ݹ���̨�˱�
	BEGIN	
		INSERT INTO TF_B_RESOURCEORDERMANAGE(
			TRADEID           , ORDERTYPECODE           , ORDERID           , OPERATETYPECODE     ,
			ORDERDEMAND       , MAINTAINREASON          , RESOURCECODE      , ATTRIBUTE1          ,
			ATTRIBUTE2        , ATTRIBUTE3              , ATTRIBUTE4        , ATTRIBUTE5          ,
			ATTRIBUTE6        , RESOURCENUM             , REQUIREDATE       , LATELYDATE          ,
			ALREADYORDERNUM   ,ALREADYARRIVENUM         , APPLYGETNUM       , AGREEGETNUM         ,
			ALREADYGETNUM     , LATELYGETDATE           , GETSTAFFNO        , OPERATETIME         ,
			OPERATESTAFFNO
		)VALUES(
			v_seqNo           ,  '02'		            , V_RESOURCEORDERID , '03'				  ,
			''                , ''                      , V_RESOURCECODE    , V_ATTRIBUTE1        ,
			V_ATTRIBUTE2      , V_ATTRIBUTE3            , V_ATTRIBUTE4      , V_ATTRIBUTE5        ,
			V_ATTRIBUTE6      , V_RESOURCENUM           , V_REQUIREDATE     , V_LATELYDATE        ,
			0                 , V_ALREADYARRIVENUM      , NULL              , NULL                ,
			NULL              , NULL                    , NULL              , V_TODAY       ,
			P_CURROPER);
		IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S001002405';
					  P_RETMSG  := '��¼��Դ���ݹ���̨��ʧ��'||SQLERRM;      
					  ROLLBACK; RETURN;	
	END;

    p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;    	  
END;

/
show errors