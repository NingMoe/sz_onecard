CREATE OR REPLACE PROCEDURE SP_RM_ORDEREXAM_PASS
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
    V_CARDNUM         INT;          --��Ƭ����
    V_BEGINCARDNO     VARCHAR2(16); --��ʼ����
    V_ENDCARDNO       VARCHAR2(16); --��������
    V_COSTYPE         CHAR(2);      --COS����
    V_CARDTYPE        CHAR(2);      --������
    V_FACETYPE        CHAR(4);      --��������
    V_CARDSAMPLECODE  CHAR(6);      --��������
    V_CHIPTYPE        CHAR(2);      --оƬ����
    V_PRODUCER        CHAR(2);      --��Ƭ����
    V_APPVERSION      CHAR(2);      --Ӧ�ð汾
    V_EFFDATE         CHAR(8);      --��Ч��ʼ����
    V_EXPDATE         CHAR(8);      --��Ч��������
    V_VALUECODE       CHAR(1);      --������
    V_FROMCARD        NUMERIC(16);  --��ʼ����
    V_TOCARD          NUMERIC(16);  --��������
    V_CARDNO          VARCHAR2(16); --����
    V_ASN             CHAR(16);     --ASN��
    v_seqNo           CHAR(16);     --��ˮ��
    V_EXIST           INT     ;     --��������
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
    
BEGIN
	FOR cur IN (SELECT f0 FROM TMP_COMMON WHERE f1 = p_SESSIONID) 
	LOOP
	  V_CARDORDERID := cur.f0;
	  --��ȡ��ˮ��
	  SP_GetSeq(seq => v_seqNo);
	  BEGIN
	  	--������ֵ
			SELECT
			    CARDNUM        , BEGINCARDNO   , ENDCARDNO       ,VALUECODE     ,
			    COSTYPECODE    , CARDTYPECODE  , CARDSURFACECODE , COSTYPECODE  ,
			    MANUTYPECODE   , APPVERNO      , VALIDBEGINDATE  , VALIDENDDATE ,
			    CARDORDERTYPE  , CARDSAMPLECODE
			INTO
			    V_CARDNUM      , V_BEGINCARDNO , V_ENDCARDNO    ,V_VALUECODE   ,
			  	V_COSTYPE      , V_CARDTYPE    , V_FACETYPE     , V_CHIPTYPE   ,
			  	V_PRODUCER     , V_APPVERSION  , V_EFFDATE      , V_EXPDATE    ,
			  	V_CARDORDERTYPE, V_CARDSAMPLECODE
			FROM TF_F_CARDORDER
			WHERE CARDORDERID = V_CARDORDERID;
	  EXCEPTION
			WHEN NO_DATA_FOUND THEN
		          p_retCode := 'S094570156'; 
		          p_retMsg  := 'δ�ҵ�������';
		          ROLLBACK; RETURN;
	  END;
		
		--���¶�����
		BEGIN
			UPDATE TF_F_CARDORDER 
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
		
		--�ж��Ƿ����û���
		IF V_CARDORDERTYPE ='01' OR V_CARDORDERTYPE ='02' THEN --������û�������������û������ƿ�Ƭ
	    -- �ж�ʱ�����п�Ƭ�ڿ�
	    SELECT count(*) INTO v_exist FROM  TL_R_ICUSER WHERE CARDNO BETWEEN V_BEGINCARDNO AND V_ENDCARDNO;
	
	    IF v_exist > 0 THEN
	        p_retCode := 'A002P01B01'; p_retMsg  := '���п�Ƭ�����ڿ���';
	        ROLLBACK;RETURN;
	    END IF;
	
	    --�û������
	    V_FROMCARD := TO_NUMBER(V_BEGINCARDNO);
	    V_TOCARD   := TO_NUMBER(V_ENDCARDNO);
	    
	    IF V_CARDORDERTYPE ='02' THEN --������û������ƿ�Ƭ
	    BEGIN
	    	--����IC����������
	    	UPDATE TD_M_CARDSURFACE
	    	SET    CARDSAMPLECODE = V_CARDSAMPLECODE
	    	WHERE  CARDSURFACECODE = V_FACETYPE
	    	AND    CARDSAMPLECODE IS NULL;
	    	
	      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	    EXCEPTION
	      WHEN OTHERS THEN
	          p_retCode := 'S094570170'; p_retMsg  := '����IC����������ʧ��' || SQLERRM;
	          ROLLBACK; RETURN;
	    END;
	    END IF;
	
	    BEGIN
	        LOOP
	            V_CARDNO := SUBSTR('0000000000000000' || TO_CHAR(V_FROMCARD), -16);
	            V_ASN    := '00215000' || SUBSTR(V_CARDNO, -8);
	            --��¼IC������
	            INSERT INTO TL_R_ICUSER( 
	                CARDNO          , ASN              , CARDPRICE    , 
	                UPDATESTAFFNO   , UPDATETIME       , COSTYPECODE  , CARDTYPECODE  , 
	                CARDSURFACECODE , CARDCHIPTYPECODE , MANUTYPECODE , APPTYPECODE   , 
	                APPVERNO        , VALIDBEGINDATE   , VALIDENDDATE , RESSTATECODE
	           )VALUES(
	                V_CARDNO        , V_ASN            , 0            , 
	                P_CURROPER      , V_TODAY          , V_COSTYPE    , V_CARDTYPE    , 
	                V_FACETYPE      , V_CHIPTYPE       , V_PRODUCER   , '01'          , 
	                V_APPVERSION    , V_EFFDATE        , V_EXPDATE    , '15');
	
	            EXIT WHEN  V_FROMCARD  >=  V_TOCARD;
	
	            V_FROMCARD := V_FROMCARD + 1;
	        END LOOP;
	    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S002P01B02'; p_retMsg  := '��¼IC������ʧ��,' || SQLERRM;
	            ROLLBACK; RETURN;
	    END;
	
	    
	
	    --��¼�û���������̨��
	    BEGIN
	        INSERT INTO TF_R_ICUSERTRADE(
	            TRADEID          , BEGINCARDNO     , ENDCARDNO       , CARDNUM         ,
	            COSTYPECODE      , CARDTYPECODE    , MANUTYPECODE    , CARDSURFACECODE , 
	            CARDCHIPTYPECODE , OPETYPECODE     , OPERATESTAFFNO  , OPERATEDEPARTID , 
	            OPERATETIME
	       )VALUES(
	            v_seqNo          , V_BEGINCARDNO   , V_ENDCARDNO     , V_CARDNUM       , 
	            V_COSTYPE        , V_CARDTYPE      , V_PRODUCER      , V_FACETYPE      , 
	            V_CHIPTYPE       , '20'            , P_CURROPER      , P_CURRDEPT      , 
	            V_TODAY
	            );
	    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S002P01B03'; p_retMsg  := '��¼�û���������̨��ʧ��' || SQLERRM;
	            ROLLBACK; RETURN;
	    END;
		
			--ɾ����Ƭ�µ��������ر��¼
			BEGIN
				DELETE FROM TD_M_CARDNO_EXCLUDE WHERE CARDORDERID = V_CARDORDERID;
				
				IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		  EXCEPTION
		     WHEN OTHERS THEN
		          p_retCode := 'S094570157'; p_retMsg  := 'ɾ����Ƭ�µ��������ر��¼ʧ��' || SQLERRM;
		          ROLLBACK; RETURN;				
			END;    
     
      
    END IF;

    --��¼���ݹ���̨�˱�
    BEGIN
      INSERT INTO TF_B_ORDERMANAGE(
          TRADEID          , ORDERTYPECODE     , ORDERID           , OPERATETYPECODE  ,
          CARDTYPECODE     , CARDSURFACECODE   , CARDSAMPLECODE    , VALUECODE        , 
          CARDNUM          , REQUIREDATE       , BEGINCARDNO       , ENDCARDNO        , 
          CARDCHIPTYPECODE , COSTYPECODE       , MANUTYPECODE      , APPVERNO         , 
          VALIDBEGINDATE   , VALIDENDDATE      , OPERATETIME       , OPERATESTAFF      
      )SELECT
          v_seqNo            , '02'              , t.CARDORDERID     , '03'             ,
          t.CARDTYPECODE     , t.CARDSURFACECODE , t.CARDSAMPLECODE  , t.VALUECODE      , 
          t.CARDNUM          , t.REQUIREDATE     , t.BEGINCARDNO     , t.ENDCARDNO      , 
          t.CARDCHIPTYPECODE , t.COSTYPECODE     , t.MANUTYPECODE    , t.APPVERNO       , 
          t.VALIDBEGINDATE   , t.VALIDENDDATE    , V_TODAY           , P_CURROPER        
       FROM  TF_F_CARDORDER t
       WHERE CARDORDERID = V_CARDORDERID; 
       
       IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
       WHEN OTHERS THEN
            p_retCode := 'S094570108'; p_retMsg  := '��¼���ݹ���̨�˱�ʧ��' || SQLERRM;
            ROLLBACK; RETURN;                   
    END;

  END LOOP;
    p_retCode := '0000000000';
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;        
END;
/
show errors