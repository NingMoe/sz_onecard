-- =============================================
-- AUTHOR:		LIUHE
-- CREATE DATE: 2011-12-26
-- DESCRIPTION:	����Ӫҵ��ʹ�ÿ�Ƭ�͵ֿ۸����ʱ���ô洢����
-- MODIFY: 2012-2-16 LIUHE ȥ�����洢���̶Ա�֤���ĸ��£�
--						�쿨����Ϊ�ڳ���ʱ���ƣ�����ҵ��ʱ���ٸ���
-- =============================================
CREATE OR REPLACE PROCEDURE SP_PB_DEPTBALFEEROLLBACK
(
    P_TRADEID    	    CHAR, -- ����̨�˼�¼��TRADEID
	P_CANCELTRADEID     CHAR, -- ԭ̨�˼�¼TRADEID
	P_FEETYPE 			CHAR, --1Ԥ����,2��֤��,3Ԥ����ͱ�֤��
	P_TRADEFEE          INT, -- --����������
    P_CURROPER          CHAR,
    P_CURRDEPT          CHAR,
    P_RETCODE           OUT CHAR, -- RETURN CODE
    P_RETMSG            OUT VARCHAR2  -- RETURN MESSAGE
)
AS
	V_DBALUNITNO 	CHAR(8);
	V_CARDPRICE     INT := 1000;
	V_COUNT   		INT;
	V_CURRENTTIME   DATE := SYSDATE;
	V_EX          	EXCEPTION;
BEGIN

	---�ж��Ƿ��Ǵ���Ӫҵ��
	SELECT  COUNT(*) INTO V_COUNT 																
	FROM 	TF_DEPT_BALUNIT B , TD_DEPTBAL_RELATION R																
	WHERE 	B.DBALUNITNO = R.DBALUNITNO														
			AND B.DEPTTYPE = '1'														
			AND R.USETAG = '1'														
			AND B.USETAG = '1'														
			AND R.DEPARTNO = P_CURRDEPT;
	
    IF V_COUNT = 1 THEN--����Ǵ���Ӫҵ����ִ���������
		
		----��ȡ������㵥Ԫ����
		BEGIN
		
		    SELECT 		R.DBALUNITNO INTO V_DBALUNITNO													
			FROM 		TD_DEPTBAL_RELATION R													
			WHERE 		R.DEPARTNO = P_CURRDEPT 													
						AND  R.USETAG = '1';	
					
		EXCEPTION
	        WHEN NO_DATA_FOUND THEN
	            P_RETCODE := 'S001001990';
	            P_RETMSG  := '��ȡ���㵥Ԫ����ʧ��' || SQLERRM;
	            ROLLBACK; RETURN;
		END;
	
		IF P_FEETYPE = '1' OR P_FEETYPE = '3' OR P_FEETYPE = '4'THEN
		
			-----���������ʽ����̨��
			BEGIN
			
				UPDATE 		TF_B_DEPTACCTRADE						
				SET 		CANCELTAG = '1',						
							CANCELTRADEID = P_TRADEID						
				WHERE 		TRADEID = P_CANCELTRADEID;						
	  
			  IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF; 
			EXCEPTION
				  WHEN OTHERS THEN
					  P_RETCODE := 'S001001993';
					  P_RETMSG  := '���������ʽ����̨��ʧ��' || SQLERRM;
					  ROLLBACK; RETURN;
			END;
		
			---��¼����̨�˼�¼
			BEGIN
			
				INSERT INTO TF_B_DEPTACCTRADE
						(TRADEID, TRADETYPECODE, DBALUNITNO, 
						CURRENTMONEY, PREMONEY, NEXTMONEY, 
						OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME, CANCELTAG,CANCELTRADEID)
				SELECT
						P_TRADEID, 'A2', P.DBALUNITNO, 
						- P_TRADEFEE, P.PREPAY, P.PREPAY - P_TRADEFEE, 
						P_CURROPER, P_CURRDEPT, V_CURRENTTIME, '0',P_CANCELTRADEID
				FROM 	TF_F_DEPTBAL_PREPAY P
				WHERE 	P.DBALUNITNO = V_DBALUNITNO 
				AND 	P.ACCSTATECODE='01';
				
				IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
			EXCEPTION
				  WHEN OTHERS THEN
					  P_RETCODE := 'S001001991';
					  P_RETMSG  := '����Ԥ�������ʧ��' || SQLERRM;
					  ROLLBACK; RETURN;
			END; 
		
		
			---����Ԥ�������
			BEGIN
			
				UPDATE 	TF_F_DEPTBAL_PREPAY P
				SET 	P.PREPAY = P.PREPAY - P_TRADEFEE,
						UPDATESTAFFNO = P_CURROPER,
						UPDATETIME = V_CURRENTTIME
				WHERE 	P.DBALUNITNO = V_DBALUNITNO 
				AND 	P.ACCSTATECODE='01'; 
				  
			  IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;    
			EXCEPTION
				  WHEN OTHERS THEN
					  P_RETCODE := 'S001001992';
					  P_RETMSG  := '���±�֤���˻���ʧ��' || SQLERRM;
					  ROLLBACK; RETURN;
			END;
			
		END IF;
		
		/*--- liuhe��20120216ע�͵��Ա�֤����쿨��Ⱥ�������ĸ���
		IF P_FEETYPE = '2' OR P_FEETYPE = '3' THEN
		---��ȡ��ͨ����ֵ�������ֵ
		BEGIN
		
			SELECT   TAGVALUE INTO V_CARDPRICE   
			FROM     TD_M_TAG   
			WHERE    TAGCODE='USERCARD_MONEY';    
		
		EXCEPTION
			  WHEN NO_DATA_FOUND THEN
				  P_RETCODE := 'S001001995';
				  P_RETMSG  := '��ȡ��ͨ����ֵ�������ʧ��' || SQLERRM;
				  ROLLBACK; RETURN;
		END;
    
		---���±�֤���˻������ӿ��쿨���
		BEGIN
		
			UPDATE  TF_F_DEPTBAL_DEPOSIT      
			SET   	USABLEVALUE = USABLEVALUE - V_CARDPRICE,  
					STOCKVALUE = STOCKVALUE + V_CARDPRICE,  
					UPDATESTAFFNO = P_CURROPER,
					UPDATETIME = V_CURRENTTIME  
			WHERE  	DBALUNITNO = V_DBALUNITNO;  
			  
		  IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;    
		EXCEPTION
			  WHEN OTHERS THEN
				  P_RETCODE := 'S001001994';
				  P_RETMSG  := '���±�֤���˻���ʧ��' || SQLERRM;
				  ROLLBACK; RETURN;
		END;
		
		END IF;
		
		IF P_FEETYPE = '4' THEN
			---���±�֤���˻������ӿ��쿨���
			BEGIN
			
				UPDATE  TF_F_DEPTBAL_DEPOSIT      
				SET   	USABLEVALUE = USABLEVALUE + P_TRADEFEE,  
						STOCKVALUE = STOCKVALUE - P_TRADEFEE,  
						UPDATESTAFFNO = P_CURROPER,
						UPDATETIME = V_CURRENTTIME  
				WHERE  	DBALUNITNO = V_DBALUNITNO;  
				  
			  IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;    
			EXCEPTION
				  WHEN OTHERS THEN
					  P_RETCODE := 'S001001996';
					  P_RETMSG  := '���±�֤���˻���ʧ��' || SQLERRM;
					  ROLLBACK; RETURN;
			END;
		END IF;
		*/
    
  END IF;

    P_RETCODE := '0000000000';
	P_RETMSG  := '';
	RETURN;
  
END;



/

SHOW ERRORS
