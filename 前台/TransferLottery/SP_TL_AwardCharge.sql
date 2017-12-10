create or replace procedure SP_TL_AwardCharge
(
  P_AWARDCARDNO		  VARCHAR2,	--�콱����
  P_CUSTNAME        VARCHAR2, --�ͻ�����
  P_PAPERTYPECODE   VARCHAR2, --֤������
  P_PAPERNO         VARCHAR2, --֤������
  P_CUSTSEX         VARCHAR2, --�Ա�
  P_CUSTPHONE       VARCHAR2, --�ֻ�
  P_PWD             VARCHAR2,

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
  V_COUNT INT;
  V_ACCT_ID NUMBER(12);
  V_SUM   INT;
  v_tradeID char(16);
 BEGIN
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
 	 		  p_retCode := 'S210020009'; p_retMsg  := '��ֵ���ͽ����ܽ���' || SQLERRM;
	      ROLLBACK; RETURN;
   END IF;
 	
   --��ѯ�콱���Ƿ�ͨר���ʻ�
   BEGIN
   		SELECT ACCT_ID INTO V_ACCT_ID  FROM TF_F_CUST_ACCT WHERE ICCARD_NO = P_AWARDCARDNO AND ACCT_TYPE_NO = '0001';
 			EXCEPTION
 				WHEN NO_DATA_FOUND THEN 
   	    V_ACCT_ID := 0;
   	    WHEN OTHERS THEN 
   	    p_retCode := 'S210020001'; p_retMsg  := '��ѯ�콱���Ƿ�ͨר���ʻ�ʧ��' || SQLERRM;
	      ROLLBACK; RETURN;
   END;
   
   IF V_ACCT_ID = 0 THEN
   		--����
   		BEGIN
      SP_CA_OPENACC(P_CARDNO => P_AWARDCARDNO,
                    P_ACCTYPE => '0001',
                    P_CUSTNAME =>P_CUSTNAME,
                    P_CUSTBIRTH =>'',	
                    P_PAPERTYPECODE =>P_PAPERTYPECODE,
                    P_PAPERNO =>P_PAPERNO,
                    P_CUSTSEX =>P_CUSTSEX,
                    P_CUSTPHONE =>P_CUSTPHONE,
                    P_CUSTTELPHONE =>'',
                    P_CUSTPOST => '',
                    P_CUSTADDR => '',
                    P_CUSTEMAIL =>'',
                    P_ISUPOLDCUS =>'0',
                    P_PWD =>P_PWD,
                    P_LIMIT_EACHTIME =>0,
                    P_LIMIT_DAYAMOUNT =>0,
                    P_CURROPER =>P_CURROPER,
                    P_CURRDEPT =>P_CURRDEPT,
                    P_RETCODE =>P_RETCODE,
                    P_RETMSG =>P_RETMSG);
      IF p_retCode != '0000000000' THEN
          ROLLBACK; RETURN;
      END IF;
      
      --��ѯ�콱���Ƿ�ͨר���ʻ�
	    BEGIN
	   		SELECT ACCT_ID INTO V_ACCT_ID  FROM TF_F_CUST_ACCT WHERE ICCARD_NO = P_AWARDCARDNO AND ACCT_TYPE_NO = '0001';
	 			EXCEPTION 
	   	    WHEN OTHERS THEN 
	   	    p_retCode := 'S210020001'; p_retMsg  := '��ѯ�콱���Ƿ�ͨר���ʻ�ʧ��' || SQLERRM;
		      ROLLBACK; RETURN;
	    END; 
	    END;
   END IF;
   
   --��ֵ
   BEGIN
   	  SP_CA_CHARGE( P_ACCID => V_ACCT_ID,
                    P_CARDNO => P_AWARDCARDNO,
                    P_SUPPLYMONEY =>  P_BONUS,
										P_NEEDTRADEFEE => 0,
										P_TRADETYPECODE => '8Z',
										P_CURROPER =>  P_CURROPER,  
										P_CURRDEPT =>  P_CURRDEPT,   
										p_TRADEID =>  v_tradeID,   
										P_RETCODE =>  P_RETCODE,    
										P_RETMSG  =>  P_RETMSG);
      IF p_retCode != '0000000000' THEN
          ROLLBACK; RETURN;
      END IF; 
   END;
   
   --��¼���콱��¼̨�ʱ�
   BEGIN
	   	INSERT INTO TF_B_AWARDS																																						
			(TRADEID,CARDNO,CARDTYPECODE,AWARDTYPE,AWARDCARDNO,CHARGEMONEY,OPERATETIME,OPERATEDEPARTID,OPERATESTAFFNO,NAME,PAPERTYPECODE,PAPERNO,TEL)																																						
			VALUES																																						
			(v_tradeID,P_CARDNO,P_CARDTYPECODE,'0',P_AWARDCARDNO,P_BONUS,V_TODAY,P_CURRDEPT,P_CURROPER,P_CUSTNAME,P_PAPERTYPECODE,P_PAPERNO,P_CUSTPHONE);	
			EXCEPTION
			WHEN OTHERS THEN
		            p_retCode := 'S210020002'; p_retMsg  := '��¼�콱��¼̨�ʱ�ʧ��' || SQLERRM;
		            ROLLBACK; RETURN;
   END;
   
   --���¡��н�������
   BEGIN
	   	UPDATE TF_TT_WINNERLIST SET STATES = '1',AWARDSTRADE = 	v_tradeID																																										
			WHERE CARDNO = P_CARDNO  AND CARDTYPECODE = P_CARDTYPECODE AND STATES = '0' AND AWARDS != '0' AND TO_DATE(LOTTERYPERIOD,'YYYYMM')  >=  add_months(sysdate,-13);																																												
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