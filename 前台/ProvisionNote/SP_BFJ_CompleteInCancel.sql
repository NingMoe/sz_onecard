/*
create time:2014/8/18
creator:dongx
modify time:2014-11-14 by jiangbb
content:���ƥ����ɷ���
*/

CREATE OR REPLACE PROCEDURE SP_BFJ_CompleteInCancel
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
	v_count				 int;	
	v_bankCount          int;
	v_sum_bankless       int :=0;	   --����δ���˻���
	v_sum_businessless   int :=0;	   --ҵ��δ���˻���
	v_bankless       int;			   --����δ����
	v_businessless   int;		       --ҵ��δ����
	v_bankaccount    varchar2(120);    --�����˺�
BEGIN
	--��ѯ�����������
	BEGIN 
		SELECT count(1) INTO v_count FROM TF_F_BFJ_TASK WHERE BFJDATE = p_tradeDate AND ISINMATCH = '1';
		IF v_count != 1 THEN
			p_retCode := 'SBFJ004000';
			p_retMsg  := p_tradeDate || '��δ���ȷ����ɣ�����ȡ��';
			ROLLBACK; RETURN;			
		END IF;   
	END;
	
	
	-- 1)��ѯ�����������  
	BEGIN  
		SELECT count(1) INTO v_count FROM 
		(SELECT DISTINCT FILEDATE,BANKCODE FROM TF_F_BFJ_OBAB WHERE FILEDATE = p_tradeDate) O
		INNER JOIN TD_M_BFJ_BANK B ON B.SYSTEMCODE = O.BANKCODE
		WHERE FILEDATE = p_tradeDate;
		SELECT count(1) INTO v_bankCount FROM TD_M_BFJ_BANK WHERE ISCOOPERATIVE = '1';
		IF v_count != v_bankCount THEN
			p_retCode := 'SBFJ003001';
			p_retMsg  := '��������û�����ˣ��޷�ȷ�����';
			ROLLBACK; RETURN;			
		END IF;  
	END; 
	
	--2)��ѯ��һ��ȷ��״̬
	IF p_tradeDate != '20141001' THEN 
		BEGIN
			SELECT COUNT(BFJDATE) INTO  v_count																		
			FROM TF_F_BFJ_TASK																				
			WHERE BFJDATE = TO_CHAR(TO_DATE(p_tradeDate,'yyyyMMdd') + 1,'yyyyMMdd')
			AND BANKLESS IS NOT NULL 
			AND BUSINESSLESS IS NOT NULL
			AND ISOUTMATCH = '1'
			AND ISINMATCH = '1';																		
			IF v_count != 1 THEN
				p_retCode := 'SBFJ004002';
				p_retMsg  := '���ȷ�����ɺ�һ������' || SQLERRM;
				ROLLBACK; RETURN;			
			END IF;  
		END; 
	END IF;
	
	--3) ��ѯ��������Ϣ��ϸ��
	BEGIN
		 FOR v_cur IN (
			SELECT B.SYSTEMCODE, O.BANKACCOUNT, B.SYSTEMNAME 																										
			FROM TD_M_BFJ_BANK B																												
			LEFT JOIN TF_F_BFJ_OBAB O ON B.SYSTEMCODE = O.BANKCODE AND O.FILEDATE = p_tradeDate																												
			WHERE ISCOOPERATIVE  = '1'		  
		 )
		 LOOP
			 IF v_cur.BANKACCOUNT IS NULL THEN
				p_retCode := 'SBFJ003003';
				p_retMsg  := v_cur.SYSTEMNAME ||'û�����ˣ��޷�ȷ�����' || SQLERRM;
				ROLLBACK; RETURN;		
			 END IF;
			 
			 --��ѯ����Ĭ���˻�
			 BEGIN 
			 SELECT ACCOUNT INTO v_bankaccount
			 FROM TD_M_BFJ_BANK 
			 WHERE SYSTEMCODE = v_cur.SYSTEMCODE; 
			 EXCEPTION WHEN OTHERS THEN
				p_retCode := 'SBFJ003004';
				p_retMsg  := '��ѯ����Ĭ���˻���' || SQLERRM;
				ROLLBACK; RETURN;
			 END; 
			 
			IF v_bankaccount = v_cur.BANKACCOUNT THEN
			BEGIN
				--����ҵ��δ����
				BEGIN
				SELECT NVL(SUM(NVL(LEFTMONEY,TRADECHARGE)),0) INTO v_businessless
				FROM TF_F_BFJ_OCAB
				WHERE TO_DATE(FILEDATE,'yyyyMMdd') <= TO_DATE(p_tradeDate,'yyyyMMdd')
				AND BANKNAME = v_cur.SYSTEMCODE	
				AND BANKACCOUNT = v_bankaccount
				AND (ISNEEDMATCH IS NULL OR ISNEEDMATCH = '0')
				AND AMOUNTTYPE = '0';
				EXCEPTION WHEN OTHERS THEN
					p_retCode := 'SBFJ003006';
					p_retMsg  := '����ҵ��δ����ʧ��' || SQLERRM;
					ROLLBACK; RETURN;
				END;
				
				--��������δ����
				BEGIN
				SELECT NVL(SUM(NVL(LEFTMONEY,TRADEMONEY)),0) INTO v_bankless
				FROM TF_F_BFJ_TRADERECORD
				WHERE TRADEDATE <= TO_DATE(p_tradeDate,'yyyyMMdd')
				AND OTHERBANK = v_cur.SYSTEMCODE																				
				AND ISNEEDMATCH = '0'																				
				AND AMOUNTTYPE = '0';
				EXCEPTION WHEN OTHERS THEN
					p_retCode := 'SBFJ003007';
					p_retMsg  := '��������δ����ʧ��' || SQLERRM;
					ROLLBACK; RETURN;
				END;
				 
				v_sum_businessless := v_sum_businessless + v_businessless;
				
				--�������б�������Ϣ��ϸ��
				BEGIN
				UPDATE TF_F_BFJ_OBAB 
				SET BANKLESS = NVL(BANKLESS,0) - v_bankless,
					BUSINESSLESS = NVL(BUSINESSLESS,0) - v_businessless 
				WHERE BANKCODE = v_cur.BANKACCOUNT 
				AND FILEDATE = p_tradeDate;
				EXCEPTION WHEN OTHERS THEN
					p_retCode := 'SBFJ003008';
					p_retMsg  := '�������б�������Ϣ��ϸ��ʧ��' || SQLERRM;
					ROLLBACK; RETURN; 
				END;
			END;
			ELSE
			BEGIN
				--�������б�������Ϣ��ϸ��
				BEGIN
				UPDATE TF_F_BFJ_OBAB 
				SET BANKLESS = 0,
					BUSINESSLESS = 0 
				WHERE BANKCODE = v_cur.BANKACCOUNT
				AND FILEDATE = p_tradeDate;
				EXCEPTION WHEN OTHERS THEN
					p_retCode := 'SBFJ003008';
					p_retMsg  := '�������б�������Ϣ��ϸ��ʧ��' || SQLERRM;
					ROLLBACK; RETURN; 
				END;		
			END;
			END IF; 
		 END LOOP;
	END;
	
	--��������δ���ʻ��� 
	BEGIN
	SELECT NVL(SUM(NVL(LEFTMONEY,TRADEMONEY)),0) INTO v_sum_bankless
	FROM TF_F_BFJ_TRADERECORD
	WHERE TRADEDATE <= TO_DATE(p_tradeDate,'yyyyMMdd')
	AND ISNEEDMATCH = '0'
	AND AMOUNTTYPE = '0';
	EXCEPTION WHEN OTHERS THEN
		p_retCode := 'SBFJ003011';
		p_retMsg  := '��������δ���ʻ���ʧ��' || SQLERRM;
		ROLLBACK; RETURN;
	END;
	
	-- 4)��ѯ����������� 
	BEGIN  
		SELECT count(1) INTO v_count FROM TF_F_BFJ_TASK WHERE BFJDATE = p_tradeDate AND ISOUTMATCH = '1';
		IF v_count = 1 THEN
		BEGIN
			UPDATE TF_F_BFJ_OBAB SET SYNCSTATES = '1' WHERE FILEDATE = p_tradeDate;
			EXCEPTION WHEN OTHERS THEN
				p_retCode := 'SBFJ003009';
				p_retMsg  := '�������б�������Ϣ��ϸ��ʧ��' || SQLERRM;
				ROLLBACK; RETURN;  	
		END;
		--����ϵͳҵ���˵���
		BEGIN
			UPDATE TF_F_BFJ_TRADERECORD SET SYNCSTATES = '1' WHERE TRADEDATE = TO_DATE(p_tradeDate,'YYYYMMDD');
			EXCEPTION WHEN OTHERS THEN
				p_retCode := 'SBFJ003011';
				p_retMsg  := '����ϵͳҵ���˵���ʧ��' || SQLERRM;
				ROLLBACK; RETURN; 
		END;
		END IF;
	END;
	
	
	--5.���±����������
	BEGIN
		UPDATE TF_F_BFJ_TASK SET ISINMATCH = '1' ,INMATCHSTAFFNO = NULL , INMATCHDATE = NULL,
		BANKLESS = NVL(BANKLESS,0) - v_sum_bankless, BUSINESSLESS = NVL(BUSINESSLESS,0) - v_sum_businessless
		WHERE BFJDATE = p_tradeDate;
		EXCEPTION WHEN OTHERS THEN
			p_retCode := 'SBFJ003010';
			p_retMsg  := '���±����������ʧ��' || SQLERRM;
			ROLLBACK; RETURN; 
	END;
	
	p_retCode := '0000000000';
    p_retMsg  := 'OK';
    COMMIT; 
    RETURN;  
end;
/
show errors