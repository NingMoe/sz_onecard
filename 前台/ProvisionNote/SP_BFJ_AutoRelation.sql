/*
create time:2014/8/14
creator:dongx
content:�����˵���ϵͳ�˵��Զ�����
update: 20140915 ����Ӫҵ����Ϊ����̨���������ݣ����Զ�����
update��20140925 ���⳵���Զ�����
update: 20141009 �޸��н��׽����˻���ȫһ��������»ᷢ���쳣BUG
update: 20141110 �����˳�ֵ�Զ�ƥ��
*/

CREATE OR REPLACE PROCEDURE SP_BFJ_AutoRelation
(
	p_tradeDate	char,    		-- ���� ��ʽYYYYMMDD
	p_currOper	char,           -- ����Ա��
	p_currDept	char,		    -- ��������
    p_retCode    out char,   	-- Return Code
    p_retMsg     out varchar2   -- Return Message
)
as
    v_now            date := sysdate;  --��ǰʱ��
	v_tradeID	     char(16);		   --���� 
	v_tradeMoney     int; 
	v_count          int;
BEGIN
	
	-- 1)��ѯ����������� 
	BEGIN  
		SELECT COUNT(BFJDATE) INTO  v_count FROM TF_F_BFJ_TASK WHERE BFJDATE = p_tradeDate AND TASKSTATE != '0';
		IF v_count != 1 THEN
			p_retCode := 'SBFJ002001';
			p_retMsg  := '��ѯ�����������ʧ��' || SQLERRM;
			ROLLBACK; RETURN;			
		END IF;  
	END;
	
	--2)��ѯ������¼
	BEGIN
		 FOR v_cur IN (
			SELECT DISTINCT T.TRADEID TID,OC.TRADEID BID,O.ORDERNO,C.ACCOUNTNUMBER ACCOUNT,
			R.MONEY,NVL(OC.USEDMONEY,0) BUSED,NVL(OC.LEFTMONEY,OC.TRADECHARGE) BLEFT,T.USEDMONEY TUSED,T.LEFTMONEY TLEFT 																																
			FROM TF_F_BFJ_TRADERECORD T																																		
			INNER JOIN TF_F_ORDERFORM O ON T.SYSTRADEID = O.ORDERNO																																		
			INNER JOIN TF_F_ORDERCHECKRELATION R ON R.ORDERNO = O.ORDERNO																																		
			INNER JOIN TF_F_CHECK C ON C.CHECKID = R.CHECKID	  
			INNER JOIN TF_F_BFJ_OCAB OC ON OC.OTHERUSERNAME  =  C.ACCOUNTNAME  																													
			AND C.MONEY = OC.TRADECHARGE																																		
			WHERE T.ISNEEDMATCH = '0' 
			AND C.USETAG = '1'
		    AND (OC.ISNEEDMATCH IS NULL OR OC.ISNEEDMATCH = '0')
			AND (OC.LEFTMONEY IS NULL OR OC.LEFTMONEY > 0)
			AND (T.LEFTMONEY IS NULL OR T.LEFTMONEY > 0)
		 )
		 LOOP 
		 --�жϼ�¼�Ƿ��Ѿ���ƥ��
		 BEGIN
			SELECT COUNT(1) INTO v_count
			FROM TF_F_BFJ_BANKRELATION
			WHERE BANKTRADEID = v_cur.BID OR SYSTEMTRADEID = v_cur.TID;  
		 END;
		
		 IF v_count = 0 THEN
		 
			 --2.1)���¡����б���������ϸ��
			 BEGIN
				UPDATE TF_F_BFJ_OCAB SET TRADEMEG = TRADEMEG || ' �������' || v_cur.ORDERNO,
				USEDMONEY = NVL(USEDMONEY,0) + v_cur.MONEY,LEFTMONEY = NVL(LEFTMONEY,TRADECHARGE) - v_cur.MONEY																																					
				WHERE TRADEID = v_cur.BID;
				EXCEPTION WHEN OTHERS THEN
				p_retCode := 'SBFJ002002';
				p_retMsg  := '���¡����б���������ϸ��ʧ��' || SQLERRM;
				ROLLBACK; RETURN;	 
			 END;
			 
			 --2.2)���¡�ϵͳҵ���˵���
			 BEGIN
				UPDATE TF_F_BFJ_TRADERECORD SET USEDMONEY = USEDMONEY + v_cur.MONEY,LEFTMONEY = NVL(LEFTMONEY,TRADEMONEY) - v_cur.MONEY, 
				ACCOUNT = v_cur.ACCOUNT
				WHERE TRADEID = v_cur.TID;
				EXCEPTION WHEN OTHERS THEN
				p_retCode := 'SBFJ002003';
				p_retMsg  := '���¡�ϵͳҵ���˵���ʧ��' || SQLERRM;
				ROLLBACK; RETURN;	 
			 END;
			 v_tradeID := FUN_GETBFJTRADEID(p_tradeDate);
			 --2.3)���롾�˵�������
			 BEGIN
				INSERT INTO TF_F_BFJ_BANKRELATION																										
				(TRADEID,BANKTRADEID,SYSTEMTRADEID,MONEY,UPDATESTAFFNO,UPDATETIME)																										
				VALUES																										
				(v_tradeID,v_cur.BID,v_cur.TID,v_cur.MONEY,p_currOper,v_now);			 
				EXCEPTION WHEN OTHERS THEN
				p_retCode := 'SBFJ002004';
				p_retMsg  := '���롾�˵�������ʧ��' || SQLERRM;
				ROLLBACK; RETURN;	 
			 END;
			 
			 --2.4���롾�˵�����̨�˱�
			 BEGIN
				INSERT INTO TF_B_BFJ_CHECK																																										
				(TRADEID,BANKTRADEID,SYSTEMTRADEID,TRADECODE,MONEY,BANKUSEDMONEY,BANKLEFTMONEY,TRADEUSEDMONEY,TRADELEFTMONEY,OPERATESTAFFNO,OPERATETIME)																																										
				VALUES																																										
				(v_tradeID,v_cur.BID,v_cur.TID,'1',v_cur.MONEY,v_cur.BUSED,v_cur.BLEFT,v_cur.TUSED,v_cur.TLEFT,p_currOper,v_now);	 
				EXCEPTION WHEN OTHERS THEN
				p_retCode := 'SBFJ002005';
				p_retMsg  := '���롾�˵�����̨�˱�ʧ��' || SQLERRM;
				ROLLBACK; RETURN;	 
			 END; 
		 END IF;
		 END LOOP;
	END;
	
	 
	
	/*
	--3) ��ѯ����Ӫҵ�������������
	��ȡ��
	*/
	
	--4)��ѯ���⳵ת��ϵͳ�˵��������˵�
	/*
	 ��ȡ��
	*/
	
	--5.��ѯ�̻�ת��ϵͳ�˵��������˵�
	BEGIN
		FOR v_cur IN (
			SELECT T.TRADEID TID,O.TRADEID BID,T.TRADEMONEY MONEY,NVL(O.USEDMONEY,0) BUSED,NVL(O.LEFTMONEY,O.TRADECHARGE) BLEFT,T.USEDMONEY TUSED,T.LEFTMONEY TLEFT																																																			
			FROM  TF_F_BFJ_TRADERECORD T  																																																					
			INNER JOIN TF_F_BFJ_OCAB O ON O.TRADECHARGE = T.TRADEMONEY AND O.OTHERUSERNAME = T.OTHERUSERNAME AND O.OTHERBANKACCOUNT = T.OTHERBANKACCOUNT
			--INNER JOIN TD_M_BFJ_BANK B ON O.BANKNAME = B.SYSTEMCODE AND O.BANKACCOUNT = B.ACCOUNT
			WHERE T.TRADETYPECODE IN('06', '08')	 
			AND T.ISNEEDMATCH = '0'  				
			AND O.AMOUNTTYPE = '1'		
			AND  (O.ISNEEDMATCH IS NULL OR O.ISNEEDMATCH = '0')  	
			AND  (O.LEFTMONEY IS NULL OR O.LEFTMONEY  =  O.TRADECHARGE) 
			AND  (T.LEFTMONEY IS NULL OR T.LEFTMONEY  =  T.TRADEMONEY)
			ORDER BY O.FILEDATE,T.TRADEDATE
		 )
		 LOOP
		 BEGIN
					--�жϼ�¼�Ƿ��Ѿ���ƥ��
					BEGIN
						SELECT COUNT(1) INTO v_count
						FROM TF_F_BFJ_BANKRELATION
						WHERE BANKTRADEID = v_cur.BID OR SYSTEMTRADEID = v_cur.TID; 
						EXCEPTION WHEN OTHERS THEN
						p_retCode := 'SBFJ002006';
						p_retMsg  := '�жϼ�¼�Ƿ��Ѿ���ƥ��ʧ��' || SQLERRM;
						ROLLBACK; RETURN; 
					END;
					
					IF v_count = 0 THEN
					
						--5.2)���¡����б���������ϸ�� 	
						BEGIN
							UPDATE TF_F_BFJ_OCAB SET USEDMONEY = NVL(USEDMONEY,0) + v_cur.MONEY,LEFTMONEY = NVL(LEFTMONEY,TRADECHARGE) - v_cur.MONEY																																					
							WHERE TRADEID = v_cur.BID;
							EXCEPTION WHEN OTHERS THEN
							p_retCode := 'SBFJ002003';
							p_retMsg  := '���¡����б���������ϸ��ʧ��' || SQLERRM;
							ROLLBACK; RETURN;	 
						END;
						
						--5.3)���¡�ϵͳҵ���˵���
						 BEGIN
							UPDATE TF_F_BFJ_TRADERECORD SET USEDMONEY = NVL(USEDMONEY,0) + v_cur.MONEY,LEFTMONEY = NVL(LEFTMONEY,TRADEMONEY) - v_cur.MONEY																																					
							WHERE TRADEID = v_cur.TID;
							EXCEPTION WHEN OTHERS THEN
							p_retCode := 'SBFJ002003';
							p_retMsg  := '���¡�ϵͳҵ���˵���ʧ��' || SQLERRM;
							ROLLBACK; RETURN;	 
						 END;
						 v_tradeID := FUN_GETBFJTRADEID(p_tradeDate);
						 --5.4)���롾�˵�������
						 BEGIN
							INSERT INTO TF_F_BFJ_BANKRELATION																										
							(TRADEID,BANKTRADEID,SYSTEMTRADEID,MONEY,UPDATESTAFFNO,UPDATETIME)																										
							VALUES																										
							(v_tradeID,v_cur.BID,v_cur.TID,v_cur.MONEY,p_currOper,v_now);			 
							EXCEPTION WHEN OTHERS THEN
							p_retCode := 'SBFJ002004';
							p_retMsg  := '���롾�˵�������ʧ��' || SQLERRM;
							ROLLBACK; RETURN;	 
						 END;
						 
						 --5.5���롾�˵�����̨�˱�
						 BEGIN
							INSERT INTO TF_B_BFJ_CHECK																																										
							(TRADEID,BANKTRADEID,SYSTEMTRADEID,TRADECODE,MONEY,BANKUSEDMONEY,BANKLEFTMONEY,TRADEUSEDMONEY,TRADELEFTMONEY,OPERATESTAFFNO,OPERATETIME)																																										
							VALUES																																										
							(v_tradeID,v_cur.BID,v_cur.TID,'1',v_cur.MONEY,v_cur.BUSED,v_cur.BLEFT,v_cur.TUSED,v_cur.TLEFT,p_currOper,v_now);	 
							EXCEPTION WHEN OTHERS THEN
							p_retCode := 'SBFJ002005';
							p_retMsg  := '���롾�˵�����̨�˱�ʧ��' || SQLERRM;
							ROLLBACK; RETURN;	 
						 END;
				END IF;
		 END;
		 END LOOP; 
	END;
	
	
	
	p_retCode := '0000000000';
    p_retMsg  := 'OK';
    COMMIT; 
    RETURN;  
end;
/
show errors