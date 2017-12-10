CREATE OR REPLACE PROCEDURE SP_RM_ORDEREXAM_CANCEL
(
    P_SESSIONID       CHAR,
    P_CURROPER        CHAR,
    P_CURRDEPT        CHAR,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
AS
    V_CARDORDERID     CHAR(18);     --��������
    V_APPLYORDERID    CHAR(18);     --���󵥺�
    V_CARDORDERTYPE   CHAR(2);      --��������
    V_CARDORDERSTATE  CHAR(1);      --����״̬
    V_CARDNUM         INT;          --��Ƭ����
    V_BEGINCARDNO     VARCHAR2(16); --��ʼ����
    V_ENDCARDNO       VARCHAR2(16); --��������
    V_BEGINCARDNO2    VARCHAR2(14); --��ֵ����ʼ����
    V_ENDCARDNO2      VARCHAR2(14); --��ֵ����������
    V_COSTYPE         CHAR(2);      --COS����
    V_CARDTYPE        CHAR(2);      --������
    V_FACETYPE        CHAR(4);      --��������
    V_CHIPTYPE        CHAR(2);      --оƬ����
    V_PRODUCER        CHAR(2);      --��Ƭ����
    V_TASKSTATE       CHAR(1);      --����״̬
    V_ALREADYORDERNUM INT;          --�Ѷ�������
    V_APPLYORDERSTATE CHAR(1);      --����״̬
    v_seqNo           CHAR(16);     --��ˮ��
    V_EXIST           INT     ;     --��������
    V_COUNT           INT;
    V_TODAY           DATE:=SYSDATE;
    V_EX              EXCEPTION;
BEGIN
	FOR cur IN (SELECT f0 FROM TMP_COMMON WHERE f1 = p_SESSIONID) 
	LOOP
		V_CARDORDERID := cur.f0;
		BEGIN
		--������ֵ
			SELECT
				CARDORDERSTATE  , CARDNUM         , BEGINCARDNO     , ENDCARDNO    ,
				COSTYPECODE     , CARDTYPECODE    , CARDSURFACECODE , COSTYPECODE  ,
				MANUTYPECODE    , CARDORDERTYPE   , APPLYORDERID
			INTO
				V_CARDORDERSTATE, V_CARDNUM       , V_BEGINCARDNO  , V_ENDCARDNO  ,
				V_COSTYPE       , V_CARDTYPE      , V_FACETYPE     , V_CHIPTYPE   ,
				V_PRODUCER      , V_CARDORDERTYPE , V_APPLYORDERID
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
			SET    CARDORDERSTATE = '2'     ,
			       EXAMTIME = V_TODAY       ,
			       EXAMSTAFFNO = P_CURROPER
			WHERE  CARDORDERID = V_CARDORDERID 
			AND    CARDORDERSTATE IN ('0','1');   --0������ˣ�1�����ͨ��
	
			IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		EXCEPTION
		WHEN OTHERS THEN
			P_RETCODE := 'S094570109';
			P_RETMSG  := '���¶�����ʧ��'||SQLERRM;      
			ROLLBACK; RETURN; 			
		END;	
	  
		--��ȡ��ˮ��
		SP_GetSeq(seq => v_seqNo);

		--��¼���ݹ���̨�˱�
		BEGIN
			INSERT INTO TF_B_ORDERMANAGE(
			    TRADEID          , ORDERTYPECODE     , ORDERID           , OPERATETYPECODE  ,
			    CARDTYPECODE     , CARDSURFACECODE   , CARDSAMPLECODE    , VALUECODE        , 
			    CARDNUM          , REQUIREDATE       , BEGINCARDNO       , ENDCARDNO        , 
			    CARDCHIPTYPECODE , COSTYPECODE       , MANUTYPECODE      , APPVERNO         , 
			    VALIDBEGINDATE   , VALIDENDDATE      , OPERATETIME       , OPERATESTAFF      
			)SELECT
			    v_seqNo            , '02'              , t.CARDORDERID     , '04'             ,
			    t.CARDTYPECODE     , t.CARDSURFACECODE , t.CARDSAMPLECODE  , '1'              , 
			    t.CARDNUM          , t.REQUIREDATE     , t.BEGINCARDNO     , t.ENDCARDNO      , 
			    t.CARDCHIPTYPECODE , t.COSTYPECODE     , t.MANUTYPECODE    , t.APPVERNO       , 
			    t.VALIDBEGINDATE   , t.VALIDENDDATE    , V_TODAY           , P_CURROPER        
			 FROM  TF_F_CARDORDER t
			 WHERE CARDORDERID = V_CARDORDERID; 
			 
			IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	    EXCEPTION
			WHEN OTHERS THEN
			  p_retCode := 'S094570110'; p_retMsg  := '��¼���ݹ���̨�˱�ʧ��' || SQLERRM;
			  ROLLBACK; RETURN;				       		
		END;		 
		
		IF (V_CARDORDERTYPE ='01' OR V_CARDORDERTYPE ='02') AND V_CARDORDERSTATE = '0' THEN --������û�������������û������ƿ�Ƭ 
			--ɾ����Ƭ�µ��������ر��¼
			BEGIN
				DELETE FROM TD_M_CARDNO_EXCLUDE WHERE CARDORDERID = V_CARDORDERID;
				
				IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		    EXCEPTION
		        WHEN OTHERS THEN
		          p_retCode := 'S094570158'; p_retMsg  := 'ɾ����Ƭ�µ��������ر��¼ʧ��' || SQLERRM;
		          ROLLBACK; RETURN;				
			END;	
		ELSIF  V_CARDORDERTYPE = '03' AND V_CARDORDERSTATE = '0' THEN  --����ǳ�ֵ��
		    BEGIN
				--ɾ����Ƭ�µ��������ر��¼
				  DELETE FROM TD_M_CHARGECARDNO_EXCLUDE WHERE CARDORDERID = V_CARDORDERID;
				
				  IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
		      EXCEPTION
			    WHEN OTHERS THEN
			       p_retCode := 'S094570159'; p_retMsg  := 'ɾ����ֵ����Ƭ�µ��������ر��¼ʧ��' || SQLERRM;
			       ROLLBACK; RETURN;				
			END; 

	    END IF;
		
		IF V_CARDORDERSTATE = '1' THEN --��������ͨ��������
			--�ж������Ƿ���ɶ���    
			SELECT ALREADYORDERNUM
			INTO   V_ALREADYORDERNUM
			FROM   TF_F_APPLYORDER 
			WHERE  APPLYORDERID = V_APPLYORDERID;
			
			IF V_ALREADYORDERNUM - V_CARDNUM <= 0 THEN
			   V_APPLYORDERSTATE := '0';  --δ�¶�����
			ELSE
			   V_APPLYORDERSTATE := '1';  --�����µ�
			END IF;   
			    
			--���¿�Ƭ����
      BEGIN
        UPDATE TF_F_APPLYORDER
        SET    APPLYORDERSTATE = V_APPLYORDERSTATE ,
               ALREADYORDERNUM = V_ALREADYORDERNUM - V_CARDNUM 
        WHERE  APPLYORDERID    = V_APPLYORDERID
        AND    APPLYORDERSTATE IN ('1','2')
        AND    USETAG = '1';
      
              IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION
        WHEN OTHERS THEN
          P_RETCODE := 'S094570103';
          P_RETMSG  := '���¿�Ƭ����ʧ��'||SQLERRM;      
        ROLLBACK; RETURN;     
        END;    
    
      IF V_CARDORDERTYPE ='01' OR V_CARDORDERTYPE ='02' THEN --������û�������������û������ƿ�Ƭ 
      
        SELECT count(*) INTO v_exist FROM  TL_R_ICUSER WHERE (CARDNO BETWEEN V_BEGINCARDNO AND V_ENDCARDNO) AND RESSTATECODE = '15';
    
        IF v_exist <> V_CARDNUM THEN
          p_retCode := 'S094570163'; p_retMsg  := V_CARDORDERID||'�������Ŷ��еĿ��Ų�ȫΪ����״̬';
          ROLLBACK;RETURN;
        END IF;
        
        BEGIN
          --ɾ���û��������¼
          DELETE FROM TL_R_ICUSER WHERE (CARDNO BETWEEN V_BEGINCARDNO AND V_ENDCARDNO) AND RESSTATECODE = '15';
          IF  SQL%ROWCOUNT != V_CARDNUM THEN RAISE V_EX; END IF;
      EXCEPTION
        WHEN OTHERS THEN
          p_retCode := 'S094570159'; p_retMsg  := 'ɾ���û��������¼ʧ��' || SQLERRM;
          ROLLBACK; RETURN;        
        END;
        
        BEGIN
          --��¼�û���������̨��
        INSERT INTO TF_R_ICUSERTRADE(
          TRADEID          , BEGINCARDNO     , ENDCARDNO       , CARDNUM         ,
          COSTYPECODE      , CARDTYPECODE    , MANUTYPECODE    , CARDSURFACECODE , 
          CARDCHIPTYPECODE , OPETYPECODE     , OPERATESTAFFNO  , OPERATEDEPARTID , 
          OPERATETIME
         )VALUES(
          v_seqNo          , V_BEGINCARDNO   , V_ENDCARDNO     , V_CARDNUM       , 
          V_COSTYPE        , V_CARDTYPE      , V_PRODUCER      , V_FACETYPE      , 
          V_CHIPTYPE       , '23'            , P_CURROPER      , P_CURRDEPT      , 
          V_TODAY
          );
          EXCEPTION
        WHEN OTHERS THEN
          p_retCode := 'S094570160'; p_retMsg  := '��¼�û���������̨��ʧ��' || SQLERRM;
          ROLLBACK; RETURN;          
        END;
      
      ELSIF V_CARDORDERTYPE ='03' THEN  --����ǳ�ֵ��
       V_BEGINCARDNO2 := SUBSTR(V_BEGINCARDNO,14);
       V_ENDCARDNO2 :=SUBSTR(V_ENDCARDNO,14);
         SELECT COUNT(*) INTO V_COUNT FROM  TF_F_MAKECARDTASK  WHERE  CARDORDERID = V_CARDORDERID; 
         IF V_COUNT>0 THEN 
          
          BEGIN
        -- ��ѯ�ƿ������
        SELECT TASKSTATE INTO V_TASKSTATE FROM   TF_F_MAKECARDTASK  WHERE  CARDORDERID = V_CARDORDERID;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
              p_retCode := 'S094570161'; 
              p_retMsg  := 'δ�ҵ��˶�������Ӧ���ƿ�����';
              ROLLBACK; RETURN;
         END;
              
        IF V_TASKSTATE IS NOT NULL AND V_TASKSTATE='1' THEN  --��������
          p_retCode := 'S094570162';
          p_retMsg  := V_CARDORDERID||'������������';
          ROLLBACK; RETURN;
        END IF;
        IF V_TASKSTATE='0' THEN
        BEGIN
        --ɾ���ƿ������
           DELETE FROM TF_F_MAKECARDTASK WHERE CARDORDERID = V_CARDORDERID;
           IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
           EXCEPTION
           WHEN OTHERS THEN
            p_retCode := 'S094570163'; p_retMsg  := 'ɾ���ƿ������ʧ��' || SQLERRM;
            ROLLBACK; RETURN;  
          END;
        END IF;
        IF V_TASKSTATE='0' OR V_TASKSTATE ='3' THEN --������������ʧ��ʱ
         BEGIN  
        --ɾ����Ƭ�µ��������ر��¼
          DELETE FROM TD_M_CHARGECARDNO_EXCLUDE WHERE CARDORDERID = V_CARDORDERID;
          IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
             p_retCode := 'S094570164'; p_retMsg  := 'ɾ����Ƭ�µ��������ر��¼ʧ��' || SQLERRM;
             ROLLBACK; RETURN;        
         END; 
         END IF;
        IF V_TASKSTATE='2' THEN --������ɹ�ʱ
         BEGIN
         --���ϳ�ֵ���˻���
          UPDATE TD_XFC_INITCARD SET CARDSTATECODE = 'Z' 
          WHERE XFCARDNO BETWEEN V_BEGINCARDNO2 AND V_ENDCARDNO2;
          IF  SQL%ROWCOUNT = 0 THEN RAISE V_EX; END IF;
          EXCEPTION
          WHEN OTHERS THEN
             p_retCode := 'S094570165'; p_retMsg  := '���ϳ�ֵ���˻���ʧ��' || SQLERRM;
             ROLLBACK; RETURN; 
         END;
          BEGIN
        --��¼��ֵ��������־��
        INSERT INTO TL_XFC_MANAGELOG(
          ID            , STAFFNO    , OPERTIME , OPERTYPECODE ,
          STARTCARDNO   , ENDCARDNO
        )VALUES(
          v_seqNo       , P_CURROPER , V_TODAY  , '09'         ,
          V_BEGINCARDNO2 , V_ENDCARDNO2
          );
            
            IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
        WHEN OTHERS THEN
          p_retCode := 'S094570165'; p_retMsg  := '��¼��ֵ��������־��ʧ��' || SQLERRM;
          ROLLBACK; RETURN;              
      END; 
        END IF;
         
         END IF;
        
        
        
       
          
      END IF;
      END IF;
    END LOOP;  
    p_retCode := '0000000000';
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;        
END;
/
show errors