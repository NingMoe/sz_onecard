CREATE OR REPLACE PROCEDURE SP_RM_CARDORDER
(
	P_CARDORDERTYPE        CHAR     ,  --����������
	P_APPLYORDERID         CHAR     ,  --���󵥺�
	P_CARDTYPECODE         CHAR     ,  --�����ͱ���
	P_CARDSURFACECODE	     CHAR     ,  --�������ͱ���
	P_CARDSAMPLECODE	     CHAR     ,  --��������
	P_CARDNAME             VARCHAR2 ,  --��Ƭ����
	P_CARDFACEAFFIRMWAY    CHAR     ,  --����ȷ�Ϸ�ʽ
	P_VALUECODE            CHAR     ,  --��ֵ
	P_CARDNUM              INT      ,  --��Ƭ����
	P_REQUIREDATE          CHAR     ,  --Ҫ�󵽻�����
	P_BEGINCARDNO          VARCHAR2 ,  --��ʼ����
	P_ENDCARDNO            VARCHAR2 ,  --��������
	P_CARDCHIPTYPECODE     CHAR     ,	 --оƬ����
	P_COSTYPECODE          CHAR     ,  --COS����
	P_MANUTYPECODE         CHAR     ,  --��Ƭ����
	P_APPVERNO             CHAR     ,  --Ӧ�ð汾
	P_VALIDBEGINDATE       CHAR     ,  --��ʼ��Ч��
	P_VALIDENDDATE         CHAR     ,  --������Ч��
	P_ORDERID              out CHAR ,  --��������
	P_REMARK               VARCHAR2 ,  --��ע
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode          out char     ,  -- Return Code
	p_retMsg           out varchar2    -- Return Message  
)
AS
    v_seqNo     CHAR(16);
    V_ORDERID   CHAR(18);
    v_exist     INT     ;
    V_EX        EXCEPTION      ;
    V_TODAY     DATE := SYSDATE;
    V_FROMCARD  CHAR(16)       ;
    V_TOCARD    CHAR(16)       ;
    V_CARDNO    CHAR(16)       ;
    V_FROMCARD2  INT       ;
    V_TOCARD2    INT      ;
    V_CARDNO2    CHAR(14)       ;
    V_ALREADYORDERNUM INT;          --�Ѷ�������
    V_APPLYORDERSTATE CHAR(1);      --����״̬
    V_APPLYCARDNUM    INT;          --����Ҫ������
BEGIN
	--�ж������Ƿ���ɶ���    
	SELECT CARDNUM,ALREADYORDERNUM 
	INTO   V_APPLYCARDNUM,V_ALREADYORDERNUM 
	FROM   TF_F_APPLYORDER 
	WHERE  APPLYORDERID = P_APPLYORDERID;
	
	IF P_CARDNUM + V_ALREADYORDERNUM >= V_APPLYCARDNUM THEN
	   V_APPLYORDERSTATE := '2';  --��ɶ���
	ELSE
	   V_APPLYORDERSTATE := '1';  --�����µ�
	END IF;   
	    
	--���¿�Ƭ����
	BEGIN
		UPDATE TF_F_APPLYORDER
		SET    APPLYORDERSTATE = V_APPLYORDERSTATE ,
		       ALREADYORDERNUM = P_CARDNUM + V_ALREADYORDERNUM 
		WHERE  APPLYORDERID    = P_APPLYORDERID
		AND    APPLYORDERSTATE IN ('0','1')
		AND    USETAG = '1';
	
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
  EXCEPTION
    WHEN OTHERS THEN
      P_RETCODE := 'S094570103';
      P_RETMSG  := '���¿�Ƭ����ʧ��'||SQLERRM;      
      ROLLBACK; RETURN; 		
  END;	
	
  --��ȡ��ˮ��
	SP_GetSeq(seq => v_seqNo);
  --���ɶ�����
  V_ORDERID := 'DG'||v_seqNo;
	
  IF P_CARDORDERTYPE = '01' OR P_CARDORDERTYPE = '02' THEN --������û����µ�
      --��ѯ�Ƿ����п�Ƭ�ڿ���
      SELECT count(*) INTO v_exist FROM  TL_R_ICUSER WHERE CARDNO BETWEEN P_BEGINCARDNO AND P_ENDCARDNO;

	    IF v_exist > 0 THEN
	        p_retCode := 'A002P01B01'; p_retMsg  := '���п�Ƭ�����ڿ���';
	        ROLLBACK;RETURN;
	    END IF;
      --��ѯ�Ƿ����п����¶�����
      SELECT COUNT(*) INTO v_exist FROM TD_M_CARDNO_EXCLUDE WHERE CARDNO BETWEEN P_BEGINCARDNO AND P_ENDCARDNO;
      
	    IF v_exist > 0 THEN
	        p_retCode := 'S094570150'; p_retMsg  := '���п�Ƭ�¶�����';
	        ROLLBACK;RETURN;
	    END IF;    

      --��¼��Ƭ�µ��������ر�
	    V_FROMCARD := TO_NUMBER(P_BEGINCARDNO);
	    V_TOCARD   := TO_NUMBER(P_ENDCARDNO);
	
	    BEGIN
	        LOOP
	            V_CARDNO := SUBSTR('0000000000000000' || TO_CHAR(V_FROMCARD), -16);
	
	            INSERT INTO TD_M_CARDNO_EXCLUDE( 
	                CARDNO    , CARDORDERID  , CARDTYPECODE    , CARDSURFACECODE
	           )VALUES(
	                V_CARDNO  , V_ORDERID    , P_CARDTYPECODE  , P_CARDSURFACECODE
	                );
	
	            EXIT WHEN  V_FROMCARD  >=  V_TOCARD;
	
	            V_FROMCARD := V_FROMCARD + 1;
	        END LOOP;
	    EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S094570151'; p_retMsg  := '��¼��Ƭ�µ��������ر�ʧ��' || SQLERRM;
	            ROLLBACK; RETURN;
	    END;	
  END IF;    
  
  IF P_CARDORDERTYPE = '03' THEN --����ǳ�ֵ���µ�
      --��¼��Ƭ�µ��������ر�
	    V_FROMCARD2 := TO_NUMBER(SUBSTR(P_BEGINCARDNO,7,8));
	    V_TOCARD2   := TO_NUMBER(SUBSTR(P_ENDCARDNO,7,8));
	
	    BEGIN
	        LOOP
	            V_CARDNO2 := SUBSTR(P_BEGINCARDNO,0,6)||SUBSTR('00000000' || TO_CHAR(V_FROMCARD2), -8);
	
	            INSERT INTO TD_M_CHARGECARDNO_EXCLUDE( 
	                CARDNO    , CARDORDERID  
             )VALUES(
                  V_CARDNO2  , V_ORDERID    
                  );
  
              EXIT WHEN  V_FROMCARD2  >=  V_TOCARD2;
  
              V_FROMCARD2 := V_FROMCARD2 + 1;
          END LOOP;
      EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S094570152'; p_retMsg  := '��¼��ֵ����Ƭ�µ��������ر�ʧ��' || SQLERRM;
              ROLLBACK; RETURN;
      END;  
      
      --��¼��ֵ��������־��
      BEGIN
        INSERT INTO TL_XFC_MANAGELOG(  
            ID            , STAFFNO     , OPERTIME , OPERTYPECODE ,  
            STARTCARDNO   , ENDCARDNO  
        )VALUES(  
            v_seqNo       , P_CURROPER  , V_TODAY  , '05'         ,  
            P_BEGINCARDNO , P_ENDCARDNO  
            );   
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION
        WHEN OTHERS THEN
          P_RETCODE := 'S094570154';
          P_RETMSG  := '��¼��ֵ��������־��ʧ��'||SQLERRM;      
          ROLLBACK; RETURN;            
      END;
  END IF;
  
  BEGIN
    --��¼��Ƭ������
    INSERT INTO TF_F_CARDORDER(
        CARDORDERID    , CARDORDERTYPE       , APPLYORDERID      , CARDORDERSTATE     ,
        USETAG         , CARDTYPECODE        , CARDSURFACECODE   , CARDSAMPLECODE     ,
        CARDNAME       , CARDFACEAFFIRMWAY   , VALUECODE         , CARDNUM            ,
        REQUIREDATE    , BEGINCARDNO         , ENDCARDNO         , CARDCHIPTYPECODE   ,
        COSTYPECODE    , MANUTYPECODE        , APPVERNO          , VALIDBEGINDATE     ,
        VALIDENDDATE   , ORDERTIME           , ORDERSTAFFNO      , REMARK
    )VALUES(
        V_ORDERID      , P_CARDORDERTYPE     , P_APPLYORDERID    , '0'                ,
        '1'            , P_CARDTYPECODE      , P_CARDSURFACECODE , P_CARDSAMPLECODE   ,
        P_CARDNAME     , P_CARDFACEAFFIRMWAY , P_VALUECODE       , P_CARDNUM          ,
        P_REQUIREDATE  , P_BEGINCARDNO       , P_ENDCARDNO       , P_CARDCHIPTYPECODE ,
        P_COSTYPECODE  , P_MANUTYPECODE      , P_APPVERNO        , P_VALIDBEGINDATE   ,
        P_VALIDENDDATE , V_TODAY             , P_CURROPER        , P_REMARK
        );
        
     IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         P_RETCODE := 'S094570102';
         P_RETMSG  := '��¼��Ƭ��������ʧ��'||SQLERRM;      
         ROLLBACK; RETURN;              
  END;
  
  BEGIN
    --��¼���ݹ���̨�˱�
    INSERT INTO TF_B_ORDERMANAGE(
        TRADEID        , ORDERTYPECODE       , ORDERID           , OPERATETYPECODE  ,
        CARDTYPECODE   , CARDSURFACECODE     , CARDSAMPLECODE    ,
        CARDNAME       , CARDFACEAFFIRMWAY   , VALUECODE         , CARDNUM          ,
        REQUIREDATE    , BEGINCARDNO         , ENDCARDNO         , CARDCHIPTYPECODE ,
        COSTYPECODE    , MANUTYPECODE        , APPVERNO          , VALIDBEGINDATE   ,
        VALIDENDDATE   , OPERATETIME         , OPERATESTAFF      , REMARK
    )VALUES(
        v_seqNo        , '02'                , V_ORDERID         , '01'             ,
        P_CARDTYPECODE , P_CARDSURFACECODE   , P_CARDSAMPLECODE  ,
        P_CARDNAME     , P_CARDFACEAFFIRMWAY , P_VALUECODE       , P_CARDNUM          ,
        P_REQUIREDATE  , P_BEGINCARDNO       , P_ENDCARDNO       , P_CARDCHIPTYPECODE ,
        P_COSTYPECODE  , P_MANUTYPECODE      , P_APPVERNO        , P_VALIDBEGINDATE   ,
        P_VALIDENDDATE , V_TODAY             , P_CURROPER        , P_REMARK
        );
     IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
       WHEN OTHERS THEN
         P_RETCODE := 'S094570104';
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