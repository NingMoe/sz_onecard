CREATE OR REPLACE PROCEDURE SP_RM_OTHER_UnderOrder
(
    P_APPLYORDERID      CHAR, 			--���󵥺�
	P_RESOURCECODE		CHAR,			--��Դ����
	P_ATTRIBUTE1		CHAR,			--����1
	P_ATTRIBUTE2		CHAR,			--����2
	P_ATTRIBUTE3		CHAR,			--����3
	P_ATTRIBUTE4		CHAR,			--����4
	P_ATTRIBUTE5		CHAR,			--����5
	P_ATTRIBUTE6		CHAR,			--����6
	P_RESOURCENUM		INT,			--�µ�����
	P_TODAY				CHAR,			--�µ�ʱ��
	P_ORDERDEMAND		CHAR,			--����Ҫ��
	P_REQUIREDATE		CHAR,			--Ҫ�󵽻�����
	P_REMARK			CHAR,			--��ע
	P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
	v_seqNo			  CHAR(16);		--��ˮ��
    V_RESOURCEORDERID CHAR(18);		--��������
    V_EXIST           INT     ;     --��������
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
BEGIN
	
	--��ȡ��ˮ��
	SP_GetSeq(seq => v_seqNo);
	--���ɶ�������
	V_RESOURCEORDERID := 'DG'||v_seqNo;
	
	--��֤�����󵥶�Ӧ�Ķ��������Ƿ����
	SELECT  COUNT(*) INTO V_EXIST  FROM TF_F_RESOURCEORDER WHERE APPLYORDERID = P_APPLYORDERID ;
		IF v_exist > 0 THEN
				P_RETCODE := 'A094780054';
				P_RETMSG  := '�����󵥶�Ӧ�Ķ��������Ѵ���';
				ROLLBACK; RETURN;
			END IF;
	
	--��¼��Դ������
	
	BEGIN
	INSERT INTO TF_F_RESOURCEORDER(						
		RESOURCEORDERID     , APPLYORDERID    , ORDERSTATE            , USETAG       ,						
		RESOURCECODE        , ATTRIBUTE1      , ATTRIBUTE2            , ATTRIBUTE3   ,						
		ATTRIBUTE4          , ATTRIBUTE5      , ATTRIBUTE6            , RESOURCENUM  ,						
		REQUIREDATE         , LATELYDATE      , ALREADYARRIVENUM      , ORDERTIME    ,						
		ORDERSTAFFNO        , EXAMTIME        , EXAMSTAFFNO           , REMARK						
	)VALUES(						
		V_RESOURCEORDERID   , P_APPLYORDERID  , '0'   		          , '1'		      , 						
		P_RESOURCECODE      , P_ATTRIBUTE1    , P_ATTRIBUTE2          , P_ATTRIBUTE3  ,						
		P_ATTRIBUTE4        , P_ATTRIBUTE5    , P_ATTRIBUTE6          , P_RESOURCENUM ,						
		P_REQUIREDATE       , NULL            , 0                     , TO_DATE(P_TODAY,'yyyyMMdd'),
		P_CURROPER          , NULL            , NULL                  , P_REMARK					
		);
	IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S001002308';
					  P_RETMSG  := '��¼��Դ������ʧ��'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	--������Դ����
	BEGIN
	UPDATE  TF_F_RESOURCEAPPLYORDER    									
       SET  ALREADYORDERNUM = P_RESOURCENUM   ---�Ѷ�������(��ʱ��P_RESCOUCENUM����׼�Ķ�������������С������������)									
	 WHERE  APPLYORDERID = P_APPLYORDERID;
	IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S001002309';
					  P_RETMSG  := '������Դ����ʧ��'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	--��¼��Դ���ݹ���̨�ʱ�
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
		v_seqNo           ,  '02'		            , V_RESOURCEORDERID , '01'				  ,				
		P_ORDERDEMAND     , NULL                    , P_RESOURCECODE    , P_ATTRIBUTE1        ,				
		P_ATTRIBUTE2      , P_ATTRIBUTE3            , P_ATTRIBUTE4      , P_ATTRIBUTE5        ,				
		P_ATTRIBUTE6      , P_RESOURCENUM           , P_REQUIREDATE     , NULL                ,				
		P_RESOURCENUM     , 0                       , NULL              , NULL                ,				
		 0                , NULL                    , NULL              , V_TODAY             ,   			
		P_CURROPER  			
		);				
	IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S001002310';
					  P_RETMSG  := '��¼��Դ���ݹ���̨�ʱ�ʧ��'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;   
END;

/
SHOW ERRORS
	