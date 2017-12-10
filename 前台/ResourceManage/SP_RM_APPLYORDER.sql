--------------------------------------------------
--  �µ�����洢����
--  ���α�д
--  ʯ��
--  2012-07-18
--------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_RM_APPLYORDER
(
	P_APPLYORDERTYPE       CHAR     ,  --��������
	P_ORDERDEMAND          VARCHAR2 ,  --����Ҫ��
	P_CARDTYPECODE         CHAR     ,  --�����ͱ���
	P_CARDSURFACECODE	     CHAR     ,  --�������ͱ���
	P_CARDSAMPLECODE	     CHAR     ,  --��������
	P_CARDNAME             VARCHAR2 ,  --��Ƭ����
	P_CARDFACEAFFIRMWAY    CHAR     ,  --����ȷ�Ϸ�ʽ
	P_VALUECODE            CHAR     ,  --��ֵ
	P_CARDNUM              INT      ,  --��Ƭ����
	P_REQUIREDATE          CHAR     ,  --Ҫ�󵽻�����
	P_REMARK               VARCHAR2 ,  --��ע
	P_ORDERID              out char ,  --���󵥺�
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode          out char     ,  -- Return Code
	p_retMsg           out varchar2    -- Return Message  
)
AS
    v_seqNo     CHAR(16);
    V_ORDERID   CHAR(18);
    V_EX        EXCEPTION      ;
    V_TODAY     DATE := SYSDATE;
BEGIN
	--��ȡ��ˮ��
	SP_GetSeq(seq => v_seqNo);
  --���ɶ�����
  V_ORDERID := 'XQ'||v_seqNo;
	
	BEGIN
		--��¼��Ƭ���󵥱�
		INSERT INTO TF_F_APPLYORDER(
		    APPLYORDERID        , APPLYORDERTYPE    , APPLYORDERSTATE   , ORDERDEMAND    ,
		    CARDTYPECODE        , CARDSURFACECODE   , CARDSAMPLECODE    , CARDNAME       ,
		    CARDFACEAFFIRMWAY   , VALUECODE         , CARDNUM           , REQUIREDATE    ,
		    ORDERTIME           , ORDERSTAFFNO      , REMARK            , USETAG
		)VALUES(
		    V_ORDERID           , P_APPLYORDERTYPE  , '0'               , P_ORDERDEMAND  ,
		    P_CARDTYPECODE      , P_CARDSURFACECODE , P_CARDSAMPLECODE  , P_CARDNAME     ,
		    P_CARDFACEAFFIRMWAY , P_VALUECODE       , P_CARDNUM         , P_REQUIREDATE  ,
		    V_TODAY             , P_CURROPER        , P_REMARK          , '1'
		    );
		    
     IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         P_RETCODE := 'S094570100';
         P_RETMSG  := '��¼��Ƭ���󵥱�ʧ��'||SQLERRM;      
         ROLLBACK; RETURN;      		    
	END;
	
	BEGIN
		--��¼���ݹ���̨�˱�
		INSERT INTO TF_B_ORDERMANAGE(
		    TRADEID       , ORDERTYPECODE       , ORDERID           , OPERATETYPECODE  ,
		    ORDERDEMAND   , CARDTYPECODE        , CARDSURFACECODE   , CARDSAMPLECODE   ,
		    CARDNAME      , CARDFACEAFFIRMWAY   , VALUECODE         , CARDNUM          ,
		    REQUIREDATE   , OPERATETIME         , OPERATESTAFF      , REMARK
		)VALUES(
		    v_seqNo       , '01'                , V_ORDERID         , '00'             ,
		    P_ORDERDEMAND , P_CARDTYPECODE      , P_CARDSURFACECODE , P_CARDSAMPLECODE ,
		    P_CARDNAME    , P_CARDFACEAFFIRMWAY , P_VALUECODE       , P_CARDNUM        ,
		    P_REQUIREDATE , V_TODAY             , P_CURROPER        , P_REMARK
		    );
     IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         P_RETCODE := 'S094570101';
         P_RETMSG  := '��¼���ݹ���̨�˱�ʧ��'||SQLERRM;      
         ROLLBACK; RETURN;  	
	END;	
	  P_ORDERID := V_ORDERID;
    p_retCode := '0000000000';
	  p_retMsg  := '�ɹ�';
	  COMMIT; RETURN;    	
END;

/
show errors
