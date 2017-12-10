CREATE OR REPLACE PROCEDURE SP_RM_OTHER_ApplyOrder
(
    P_RESOURCECODE      CHAR, 			--��Դ����
	P_ATTRIBUTE1		CHAR,			--����1
	P_ATTRIBUTE2		CHAR,			--����2
	P_ATTRIBUTE3		CHAR,			--����3
	P_ATTRIBUTE4		CHAR,			--����4
	P_ATTRIBUTE5		CHAR,			--����5
	P_ATTRIBUTE6		CHAR,			--����6
	P_RESOURCENUM		INT,			--�µ�����
	P_ORDERDEMAND		CHAR,			--����Ҫ��
	P_REQUIREDATE		CHAR,			--Ҫ�󵽻�����
	P_REMARK			CHAR,			--��ע
	P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2,  -- Return Message
	
	P_APPLYORDERID out char				--��������
)
AS
	v_seqNo			  CHAR(16);		--��ˮ��
    V_APPLYORDERID	  CHAR(18);		--���󵥺�
    V_EXIST           INT     ;     --��������
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
BEGIN
	--��ȡ��ˮ��
	SP_GetSeq(seq => v_seqNo);
	--�������󵥺�
	V_APPLYORDERID := 'XQ'||v_seqNo;
	
	--��¼��Դ���󵥱�
	BEGIN
	INSERT INTO TF_F_RESOURCEAPPLYORDER(											
		APPLYORDERID        , APPLYORDERTYPE , USETAG             , ORDERDEMAND    ,
		RESOURCECODE        , ATTRIBUTE1     , ATTRIBUTE2         , ATTRIBUTE3       ,											
		ATTRIBUTE4          , ATTRIBUTE5     , ATTRIBUTE6         , RESOURCENUM   ,											
		REQUIREDATE         , LATELYDATE     , ALREADYORDERNUM    , ALREADYARRIVENUM  ,
		ORDERTIME           , ORDERSTAFFNO   , REMARK											
	)VALUES(
		V_APPLYORDERID      , '0'			    , '1'              , P_ORDERDEMAND    ,											
		P_RESOURCECODE      , P_ATTRIBUTE1      , P_ATTRIBUTE2     , P_ATTRIBUTE3     ,											
		P_ATTRIBUTE4        , P_ATTRIBUTE5      , P_ATTRIBUTE6     , P_RESOURCENUM    ,											
		P_REQUIREDATE       , NULL              , 0                , 0                ,											
		V_TODAY             , P_CURROPER        , P_REMARK										
	);
	IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S001002220';
					  P_RETMSG  := '��¼��Դ���󵥱�ʧ��'||SQLERRM;
					  ROLLBACK; RETURN;
	END;

	--��¼��Դ���ݹ���̨��
	BEGIN
	INSERT INTO TF_B_RESOURCEORDERMANAGE(
		TRADEID           , ORDERTYPECODE           , ORDERID	        , OPERATETYPECODE     ,
		ORDERDEMAND       , MAINTAINREASON          , RESOURCECODE      , ATTRIBUTE1          ,
		ATTRIBUTE2        , ATTRIBUTE3              , ATTRIBUTE4        , ATTRIBUTE5          ,
		ATTRIBUTE6        , RESOURCENUM             , REQUIREDATE       , LATELYDATE          ,
		ALREADYORDERNUM   ,ALREADYARRIVENUM         , APPLYGETNUM       , AGREEGETNUM         ,						
		ALREADYGETNUM     , LATELYGETDATE           , GETSTAFFNO        , OPERATETIME         ,
		OPERATESTAFFNO
	)VALUES(
		v_seqNo           ,  '01'		            , V_APPLYORDERID	, '00'				  ,
		P_ORDERDEMAND     , NULL                    , P_RESOURCECODE    , P_ATTRIBUTE1        ,
		P_ORDERDEMAND     , NULL                    , P_RESOURCECODE    , P_ATTRIBUTE1        ,
		P_ATTRIBUTE2      , P_ATTRIBUTE3            , P_ATTRIBUTE4      , P_ATTRIBUTE5        ,
		0                 , 0                       , NULL              , NULL                ,							
		NULL              , NULL                    , NULL              , V_TODAY             ,
		P_CURROPER
		);
	IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
				  EXCEPTION
					WHEN OTHERS THEN
					  P_RETCODE := 'S001002221';
					  P_RETMSG  := '��¼��Դ���ݹ���̨�ʱ�ʧ��'||SQLERRM;
					  ROLLBACK; RETURN;
	END;
	
	p_retCode := '0000000000';
	p_retMsg  := '';
	P_APPLYORDERID :=V_APPLYORDERID;
	COMMIT; RETURN;   
END;


/
show errors