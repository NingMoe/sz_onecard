create or replace procedure SP_RM_RETURNCARD
(
		P_BEGINCARDNO		VARCHAR2,
		P_ENDCARDNO			VARCHAR2,
		p_returnmsg			char,  --�˻�ԭ��
		P_SIGNTYPE      CHAR,  --ǩ�����ͣ�0�û�����1��ֵ��
		p_seqNo         out char,
		p_currOper      char,
		p_currDept	    char,
		p_retCode	     	out char, -- Return Code
		p_retMsg     	 	out varchar2  -- Return Message
)
as
    v_seqNo             CHAR(16)       ;
    V_EX                EXCEPTION      ;
    V_TODAY             DATE := SYSDATE;
    V_QUANTITY          INT        ;   --����
    V_CARDTYPE          CHAR(2):='';   --��Ƭ����
    V_FACETYPE          CHAR(4):='';   --��������
    V_VALUECODE         CHAR(1):='';   --��ֵ
    V_CARDORDERID       CHAR(18);  --��������
    V_APPLYORDERID      CHAR(18);  --���󵥺�
    V_CARDORDERSTATE    CHAR(1);   --������״̬
    V_CARDNUM           INT    ;   --�����д���������
    V_ORDERCARDNUM      INT    ;   --������Ҫ������
    V_ALREADYARRIVENUM  INT    ;   --�ѵ�������
    V_RETURNCARDNUM     INT    ;   --�˻�����
	  V_FROMCARDNO        VARCHAR2(16);  --��ʼ����
    V_TOCARDNO          VARCHAR2(16);  --��������
    V_FCARDNO           VARCHAR2(16);  --��ʼ����
    V_ECARDNO           VARCHAR2(16);  --��������
    V_COUNT             INT     ;  --��Ƭ����
BEGIN

  --�鿴��Ƭ�Ƿ���ͬһ������
  select count(distinct t.MANUTYPECODE) into V_COUNT  from TL_R_ICUSER t where  t.cardno between P_BEGINCARDNO and P_ENDCARDNO;
  if V_COUNT > 1 then
     p_retCode := 'S094390132';
		 p_retMsg  := '���Ŷ��ڴ��ڲ�ͬ���̵Ŀ���';
     return;
  end if;

	--��Ƭ����
	V_QUANTITY := substr(P_ENDCARDNO,-8) - substr(P_BEGINCARDNO,-8) + 1;
	
	IF P_SIGNTYPE = '0' THEN --������û���
	--��ȡ��Ƭ���ͺͿ�������
	  V_CARDTYPE  := SUBSTR(P_BEGINCARDNO,5,2);
	  V_FACETYPE  := SUBSTR(P_BEGINCARDNO,5,4);
	
	BEGIN
		SELECT COUNT(*) INTO V_CARDNUM
	    FROM   TL_R_ICUSER
	    WHERE  CARDNO BETWEEN P_BEGINCARDNO AND P_ENDCARDNO
	    AND    RESSTATECODE  = '00';

	    IF V_CARDNUM < V_QUANTITY THEN
		    p_retCode := 'S094570132';
		    p_retMsg  := '�˻����û����д��ڿ�Ƭ��Ϊ���״̬�Ŀ�';
		    ROLLBACK; RETURN;
	    END IF;
		
		--�����û�������
			UPDATE TL_R_ICUSER
			SET    RESSTATECODE  = '15'       ,  --����״̬
			       INSTIME       = V_TODAY    ,
			       UPDATESTAFFNO = P_CURROPER ,
			       UPDATETIME    = V_TODAY
			WHERE  RESSTATECODE  = '00'          --���״̬
			AND    (CARDNO BETWEEN P_BEGINCARDNO AND P_ENDCARDNO);

	  EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'S094570134'; p_retMsg  := '�����û�������ʧ��'|| SQLERRM;
	        ROLLBACK; RETURN;
	END;
	
	ELSIF P_SIGNTYPE = '1'  THEN
		
		BEGIN
		  SELECT COUNT(*) INTO V_CARDNUM
		  FROM TD_XFC_INITCARD
		  WHERE (XFCARDNO BETWEEN P_BEGINCARDNO AND P_ENDCARDNO)
		  AND CARDSTATECODE = '2';

	    IF V_CARDNUM < V_QUANTITY THEN
		    p_retCode := 'S094570142';
		    p_retMsg  := '�˻��ĳ�ֵ���д��ڿ�Ƭ��Ϊ���״̬�Ŀ�';
		    ROLLBACK; RETURN;
	    END IF;

	    --���³�ֵ���˻���
      UPDATE TD_XFC_INITCARD
      SET    CARDSTATECODE = 'C'        ,  --����״̬
             INTIME        = V_TODAY    ,
             INSTAFFNO     = P_CURROPER
      WHERE  CARDSTATECODE = '2'          	--���״̬
      AND   (XFCARDNO BETWEEN P_BEGINCARDNO AND P_ENDCARDNO) ;

	  EXCEPTION
	    WHEN OTHERS THEN
	        p_retCode := 'S094570124'; p_retMsg  := '���³�ֵ���˻���ʧ��'|| SQLERRM;
	        ROLLBACK; RETURN;
	  END;

	END IF;
	
	BEGIN
	  --��ѯ������������ʼ����
	  SELECT BEGINCARDNO INTO V_FROMCARDNO 
	  FROM TF_F_CARDORDER 
	  WHERE BEGINCARDNO <= P_BEGINCARDNO 
	  AND ENDCARDNO >= P_BEGINCARDNO 
	  AND CARDORDERSTATE IN ('1','3','4') --1�����ͨ����3�����ֵ�����4��ȫ������	
	  AND USETAG = '1'; 
	  EXCEPTION
		  WHEN NO_DATA_FOUND THEN
			  p_retCode := 'S094570111'; p_retMsg  := 'δ�ҵ���ʼ��������������';
			  ROLLBACK;RETURN;  
	END;
	  
	BEGIN
	  SELECT BEGINCARDNO INTO V_TOCARDNO 
	  FROM TF_F_CARDORDER 
	  WHERE BEGINCARDNO <= P_ENDCARDNO 
	  AND ENDCARDNO >= P_ENDCARDNO 
	  AND CARDORDERSTATE IN ('1','3','4') --1�����ͨ����3�����ֵ�����4��ȫ������	
	  AND USETAG = '1'; 
	EXCEPTION
	  WHEN NO_DATA_FOUND THEN
	      p_retCode := 'S094570120'; p_retMsg  := 'δ�ҵ�������������������';
	      ROLLBACK;RETURN;
	END;
	
	BEGIN
	FOR V_C IN (SELECT CARDORDERID, APPLYORDERID , VALUECODE , BEGINCARDNO , ENDCARDNO
  	            FROM TF_F_CARDORDER 
  	            WHERE (BEGINCARDNO BETWEEN V_FROMCARDNO AND V_TOCARDNO )
  	            AND    CARDORDERSTATE IN ('1','3','4') --1�����ͨ����3�����ֵ�����4��ȫ������
  	            AND    USETAG = '1'
  	            )
    LOOP
	  V_CARDORDERID  := V_C.CARDORDERID;
      V_APPLYORDERID := V_C.APPLYORDERID;
      V_VALUECODE    := V_C.VALUECODE;
	  
		IF V_C.BEGINCARDNO > P_BEGINCARDNO AND V_C.ENDCARDNO >= P_ENDCARDNO THEN
			 BEGIN 
			     V_COUNT   := SUBSTR(P_ENDCARDNO , -8) - SUBSTR(V_C.BEGINCARDNO , -8) + 1;  --���㶩�������˻�����
			     V_FCARDNO := V_C.BEGINCARDNO;
			     V_ECARDNO := P_ENDCARDNO;
			  END;   
			ELSIF V_C.BEGINCARDNO > P_BEGINCARDNO AND V_C.ENDCARDNO < P_ENDCARDNO THEN  
			  BEGIN
			      V_COUNT := SUBSTR(V_C.ENDCARDNO, -8) - SUBSTR(V_C.BEGINCARDNO, -8) + 1;  --���㶩�������˻�����
			      V_FCARDNO := V_C.BEGINCARDNO;
			      V_ECARDNO := V_C.ENDCARDNO;
			   END;   
			ELSIF V_C.BEGINCARDNO <= P_BEGINCARDNO AND V_C.ENDCARDNO >= P_ENDCARDNO THEN
			   BEGIN  
			      V_COUNT := SUBSTR(P_ENDCARDNO, -8) - SUBSTR(P_BEGINCARDNO, -8) + 1;  --���㶩�������˻�����
			      V_FCARDNO := P_BEGINCARDNO;
			      V_ECARDNO := P_ENDCARDNO;
			   END;   
			ELSIF V_C.BEGINCARDNO <= P_BEGINCARDNO AND V_C.ENDCARDNO < P_ENDCARDNO THEN
			   BEGIN   
			      V_COUNT := SUBSTR(V_C.ENDCARDNO, -8) - SUBSTR(P_BEGINCARDNO, -8) + 1;  --���㶩�������˻�����
			      V_FCARDNO := P_BEGINCARDNO;
			      V_ECARDNO := V_C.ENDCARDNO;
			   END;
		 END IF;
		 
		 --�ж϶������Ƿ�ȫ������
	SELECT CARDNUM          ,
	       ALREADYARRIVENUM ,
	       RETURNCARDNUM
	INTO   V_ORDERCARDNUM      , --��������
	       V_ALREADYARRIVENUM  , --�ѵ�������
	       V_RETURNCARDNUM       --���˻�����
	FROM   TF_F_CARDORDER
	WHERE  CARDORDERID = V_CARDORDERID;

	IF V_ALREADYARRIVENUM - V_RETURNCARDNUM - V_COUNT <= 0 THEN
	   V_CARDORDERSTATE := '1';  --���ͨ��
	ELSE
	   V_CARDORDERSTATE := '3';  --���ֵ���
	END IF;
	
	BEGIN
		--���¶�����
		UPDATE TF_F_CARDORDER		
		SET    CARDORDERSTATE = V_CARDORDERSTATE ,  --������״̬			
			     RETURNCARDNUM  = V_RETURNCARDNUM + V_COUNT       --���˻�����		
		WHERE  CARDORDERID = V_CARDORDERID		
		AND    USETAG = '1';		

	EXCEPTION
	  WHEN OTHERS THEN
		    p_retCode := 'S094570117'; p_retMsg  := '���¶�����ʧ��'|| SQLERRM;
		    ROLLBACK; RETURN;
	END;
	
	BEGIN
		--��������
		UPDATE TF_F_APPLYORDER	
			SET ALREADYARRIVENUM = ALREADYARRIVENUM - V_COUNT ,  --�ѵ�������			
				RETURNCARDNUM  = V_RETURNCARDNUM + V_COUNT       --���˻�����			
			WHERE  APPLYORDERID = V_APPLYORDERID			
		AND    USETAG = '1';			
	EXCEPTION
		WHEN OTHERS THEN
		    p_retCode := 'S094570118'; p_retMsg  := '��������ʧ��'|| SQLERRM;
		    ROLLBACK; RETURN;
	END;
	
	--��ȡ��ˮ��
	SP_GetSeq(seq => v_seqNo); 
	
	IF P_SIGNTYPE = '0' THEN --������û���
		  --��¼�û�������̨�˱�
		  BEGIN
		      INSERT INTO TF_R_ICUSERTRADE(
		          TRADEID          , BEGINCARDNO     , ENDCARDNO       , CARDNUM         ,
		          CARDTYPECODE     , CARDSURFACECODE , OPETYPECODE     , OPERATESTAFFNO  , 
		          OPERATEDEPARTID  , OPERATETIME
		     )VALUES(
		          v_seqNo          , V_FCARDNO       , V_ECARDNO       , V_COUNT         , 
				  V_CARDTYPE       , V_FACETYPE      , '22'            , P_CURROPER      , 
		          P_CURRDEPT       , V_TODAY
		          );
		  EXCEPTION
		      WHEN OTHERS THEN
		          p_retCode := 'S094570116'; p_retMsg  := '��¼�û�������̨�˱�ʧ��' || SQLERRM;
		          ROLLBACK; RETURN;
		  END;  
    ELSIF P_SIGNTYPE = '1' THEN --����ǳ�ֵ��
		--��¼��ֵ��������־��
		  BEGIN
				INSERT INTO TL_XFC_MANAGELOG(
					ID           , STAFFNO    , OPERTIME , OPERTYPECODE ,
					STARTCARDNO  , ENDCARDNO  , RETURNREASON , VALUECODE
				)VALUES(
					v_seqNo      , P_CURROPER , V_TODAY  , '07'         ,
					V_FCARDNO    , V_ECARDNO  , p_returnmsg , V_VALUECODE
					);
		  EXCEPTION
			  WHEN OTHERS THEN
				  p_retCode := 'S094570125'; p_retMsg  := '��¼��ֵ��������־��ʧ��' || SQLERRM;
				  ROLLBACK; RETURN;
	  END;
	END IF;
	
	BEGIN
		--��¼���ݹ���̨�˱�
		INSERT INTO TF_B_ORDERMANAGE(
		    TRADEID          , ORDERTYPECODE     , ORDERID           , OPERATETYPECODE   ,
		    CARDTYPECODE     , CARDSURFACECODE   , CARDNUM           , LATELYDATE        ,
		    ALREADYARRIVENUM ,RETURNCARDNUM      , BEGINCARDNO       , ENDCARDNO         ,
		    OPERATETIME      , OPERATESTAFF      , VALUECODE
		)VALUES(
		    v_seqNo          , '02'              , V_CARDORDERID     , '08'              ,
		    V_CARDTYPE       , V_FACETYPE        , V_COUNT        , TO_CHAR(V_TODAY,'YYYYMMDD') ,
		    V_ALREADYARRIVENUM , V_RETURNCARDNUM + V_COUNT , V_FCARDNO , V_ECARDNO , 
		    V_TODAY          , P_CURROPER        , V_VALUECODE
		    );
	EXCEPTION
		WHEN OTHERS THEN
		    p_retCode := 'S094570119'; p_retMsg  := '��¼���ݹ���̨�˱�ʧ��'|| SQLERRM;
		    ROLLBACK; RETURN;
	END;
	
	END LOOP;
	END;
	p_seqNo := v_seqNo;
	p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN;
END;

/
show errors
