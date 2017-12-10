create or replace procedure SP_TL_AwardChargeCard
(
  P_ChargeCard		  VARCHAR2,	--��ֵ����
  P_CUSTNAME        VARCHAR2, --�ͻ�����
  P_PAPERTYPECODE   VARCHAR2, --֤������
  P_PAPERNO         VARCHAR2, --֤������
  P_CUSTSEX         VARCHAR2, --�Ա�
  P_CUSTPHONE       VARCHAR2, --�ֻ�
 
  P_CARDNO          VARCHAR2, --�н�����
  P_CARDTYPECODE    CHAR,     --�н���������	 
  P_BONUS           INT,
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode          out char     ,  -- Return Code
	p_retMsg           out varchar2    -- Return Message  
)
AS
  V_EX        EXCEPTION       ;
  V_TODAY DATE :=SYSDATE; 
  V_SUM   INT;
  V_MONEY INT; 
  v_seqNo      char(16) ;
 BEGIN
   --��֤��ֵ���ܽ��
   BEGIN
   		SELECT SUM(MONEY) INTO V_SUM																								
			  FROM TD_XFC_INITCARD C																													
			 INNER JOIN TP_XFC_CARDVALUE V																													
			    ON C.VALUECODE = V.VALUECODE																													
			 WHERE XFCARDNO IN																													
			       (SELECT STRVALUE FROM TABLE(FN_SPLIT(P_ChargeCard, ',')));								 
 			EXCEPTION 
   	    WHEN OTHERS THEN 
   	    p_retCode := 'S210020005'; p_retMsg  := '��֤��ֵ���ܽ��ʧ��' || SQLERRM;
	      ROLLBACK; RETURN;
   END; 
   IF V_SUM != P_BONUS THEN
				 p_retCode := 'S210020004'; p_retMsg  := '��ֵ���ܳ�ֵ������ܽ��𲻷������ʵ' ;
	       ROLLBACK; RETURN;
	 END IF;
   
   --У���н��ܽ��
 	 BEGIN
 	 	 SELECT  SUM(BONUS) INTO V_SUM																																					
			FROM TF_TT_WINNERLIST W																																												
			INNER JOIN TF_TT_LOTTERYTASK T ON W.LOTTERYPERIOD = T.LOTTERYPERIOD		
			INNER JOIN TD_M_AWARDS A ON W.AWARDS = A.AWARDSCODE						 																																			
			WHERE W.CARDNO = P_CARDNO AND CARDTYPECODE = P_CARDTYPECODE  AND W.STATES = 0 AND W.AWARDS != '0' AND TO_DATE(T.LOTTERYPERIOD,'YYYYMM')  >=  add_months(sysdate,-13);																																								
 	 	  EXCEPTION 
   	    WHEN OTHERS THEN 
   	    p_retCode := 'S210020009'; p_retMsg  := 'У���н��ܽ��ʧ��' || SQLERRM;
	      ROLLBACK; RETURN;
 	 END; 
 	 IF V_SUM != P_BONUS THEN
 	 		  p_retCode := 'S210020009'; p_retMsg  := '��ֵ���ܳ�ֵ������ܽ��𲻷�' || SQLERRM;
	      ROLLBACK; RETURN;
   END IF;
   
  
   
   BEGIN
   		 FOR v_cur in (SELECT STRVALUE FROM TABLE(FN_SPLIT(P_ChargeCard, ',')))
   		 LOOP
           --��֤��ֵ��״̬
           BEGIN
           		SELECT MONEY INTO V_MONEY  FROM TD_XFC_INITCARD C																					
							INNER JOIN TP_XFC_CARDVALUE V ON C.VALUECODE = V.VALUECODE																					
							WHERE CARDSTATECODE IN ('3', '4', '5')																				
							AND XFCARDNO = v_cur.STRVALUE;	
					    EXCEPTION WHEN OTHERS THEN 
									p_retCode := 'S210020005'; p_retMsg  := '��ֵ��' ||v_cur.STRVALUE ||'״̬��Ч';
	       					ROLLBACK; RETURN;
						  
           END;
           
           --���³�ֵ���˻���
           BEGIN
           	  UPDATE TD_XFC_INITCARD
			        SET    CARDSTATECODE = DECODE(CARDSTATECODE, '5', '5', '4'),
			               ACTIVETIME    = V_TODAY    ,
			               ACTIVESTAFFNO = p_currOper ,
			               SALETIME      = V_TODAY    ,
			               SALESTAFFNO   = p_currOper
			        WHERE  XFCARDNO = v_cur.STRVALUE
			        AND    CARDSTATECODE in ('3', '4', '5')
			        AND    ASSIGNDEPARTNO = p_currDept
			        AND    SALETIME is null and SALESTAFFNO is null;
			       IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
   					 EXCEPTION WHEN OTHERS THEN
			        p_retCode := 'S210020006'; p_retMsg := '���³�ֵ��״̬ʧ��,' || SQLERRM;
			        ROLLBACK; RETURN;   	
           END;
           
           SP_GetSeq(seq => v_seqNo);
           
           --������ֵ�����������־
           BEGIN
           		INSERT INTO TL_XFC_MANAGELOG
			            (ID,STAFFNO,OPERTIME,OPERTYPECODE,STARTCARDNO,ENDCARDNO)
			        VALUES
			            (v_seqNo,p_currOper,V_TODAY,'04',v_cur.STRVALUE,v_cur.STRVALUE);
			    		EXCEPTION WHEN OTHERS THEN
			        p_retCode := 'S210020007'; p_retMsg := '���³�ֵ���ۿ�������־ʧ��,' || SQLERRM;
			        ROLLBACK; RETURN; 
           END;
           
            --�����ۿ���־
            BEGIN
				        INSERT INTO TF_XFC_SELL
				            (TRADEID, TRADETYPECODE, AMOUNT, STARTCARDNO, ENDCARDNO,
				                MONEY , STAFFNO  , OPERATETIME, REMARK)
				        VALUES(v_seqNo , '8Q'    , 1, v_cur.STRVALUE, v_cur.STRVALUE,
				            V_MONEY, p_currOper, v_today,  '');
				    EXCEPTION WHEN OTHERS THEN
				        p_retCode := 'S210020008'; p_retMsg  := '��¼��ֵ���ۿ�����̨��ʧ��,' || SQLERRM;
				        ROLLBACK; RETURN;
				    END;
				    
				    --��¼�ۿ��ֽ�̨��
				    BEGIN
				    	INSERT INTO TF_XFC_SELLFEE (TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO, MONEY, STAFFNO,OPERATETIME)
				        VALUES(v_seqNo, '8Q', v_cur.STRVALUE, v_cur.STRVALUE, V_MONEY, p_currOper, v_today);
				    EXCEPTION WHEN OTHERS THEN
				        p_retCode := 'S007P04B04'; p_retMsg  := '��¼�ۿ��ֽ�̨��ʧ��,' || SQLERRM;
				        ROLLBACK; RETURN; 
				    END; 
       END LOOP;
   END;
    
   
   --��¼���콱��¼̨�ʱ�
   BEGIN
	   	INSERT INTO TF_B_AWARDS																																						
			(TRADEID,CARDNO,CARDTYPECODE,AWARDTYPE,CHARGECARDNO,CHARGEMONEY,OPERATETIME,OPERATEDEPARTID,OPERATESTAFFNO,NAME,PAPERTYPECODE,PAPERNO,TEL)																																						
			VALUES																																						
			(v_seqNo,P_CARDNO,P_CARDTYPECODE,'1',P_ChargeCard,P_BONUS,V_TODAY,P_CURRDEPT,P_CURROPER,P_CUSTNAME,P_PAPERTYPECODE,P_PAPERNO,P_CUSTPHONE);	
			EXCEPTION
			WHEN OTHERS THEN
		            p_retCode := 'S210020002'; p_retMsg  := '��¼�콱��¼̨�ʱ�ʧ��' || SQLERRM;
		            ROLLBACK; RETURN;
   END;
   
   --���¡��н�������
   BEGIN
	   	UPDATE TF_TT_WINNERLIST SET STATES = '1',AWARDSTRADE = 	v_seqNo																																										
			WHERE CARDNO = P_CARDNO AND CARDTYPECODE = P_CARDTYPECODE AND STATES = '0' AND AWARDS != '0' AND TO_DATE(LOTTERYPERIOD,'YYYYMM')  >=  add_months(sysdate,-13);																																												
 			IF  SQL%ROWCOUNT = 0 THEN RAISE v_ex; END IF;
 			EXCEPTION
 			WHEN OTHERS THEN
          p_retCode := 'S210020003'; p_retMsg  := '�����н�������ʧ��' || SQLERRM;
          ROLLBACK; RETURN;
   END; 
	
  p_retCode := '0000000000';
	p_retMsg  := '';
	COMMIT; RETURN; 
	
END;

/
SHOW ERRORS	