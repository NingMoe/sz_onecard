

CREATE OR REPLACE PROCEDURE SP_BusStaffInfo_Input
(   
   p_CALLINGSTAFFNO   CHAR,          --��ҵԱ����      
   p_CALLINGNO	      CHAR,          --��ҵ����
   --p_BALUNITNO	      CHAR,        --��Ԫ����            
   p_currOper	        CHAR,          --����Ա��   
   p_currDept	        CHAR,          --����Ա�����ڲ���      
   p_retCode   	      OUT CHAR,      --���ش���
   p_retMsg     	    OUT VARCHAR2   --������Ϣ
                                           
)
AS
   v_quantity         INT;                 --��ʱ����    
   v_currdate         DATE := SYSDATE;     --��ǰ����
   v_seqNo            CHAR(16);            --ҵ����ˮ��  
                 
BEGIN 
	
	--1) �����ҵԱ�������Ƿ����
	BEGIN
	 SELECT COUNT(*) INTO v_quantity FROM TD_M_CALLINGSTAFF 
	   WHERE STAFFNO = p_CALLINGSTAFFNO AND CALLINGNO = p_CALLINGNO ;
	  
	  IF v_quantity >= 1 THEN
       p_retCode := 'A003100033';
       p_retMsg  := '��ҵԱ�������Ѵ���,' || SQLERRM;
       RETURN;
    END IF; 
  END;
	
   
	--2) ������ҵԱ���������Ϣ
  BEGIN
    INSERT INTO TD_M_CALLINGSTAFF
		  (STAFFNO, CALLINGNO, UPDATESTAFFNO, UPDATETIME)
    VALUES
      (p_CALLINGSTAFFNO, p_CALLINGNO, p_currOper, v_currdate);
			
    EXCEPTION
     WHEN OTHERS THEN
       p_retCode := 'S003100003';
       p_retMsg  := '����������ҵԱ���������Ϣʧ��,' || SQLERRM;
       ROLLBACK; RETURN;
  END; 
		
	--3) ȡ��ҵ����ˮ��
	SP_GetSeq(seq => v_seqNo); 
	      
	--4) ���Ӻ������ҵ��̨��������Ϣ  
	BEGIN
    INSERT INTO TF_B_ASSOCIATETRADE
		 (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
 	  VALUES
 	   (v_seqNo, '46', p_CALLINGSTAFFNO, p_currOper, p_currDept, v_currdate);
 	 
 	  EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S003100008';
        p_retMsg  := '���Ӻ������ҵ��̨��������Ϣʧ��,' || SQLERRM;
        ROLLBACK; RETURN;
  END;   
	
  --5) ������ҵԱ���������ϱ���ӱ���Ϣ    
  BEGIN 
  	INSERT INTO TF_B_CALLINGSTAFFCHANGE(TRADEID, STAFFNO, CALLINGNO)
    VALUES (v_seqNo, p_CALLINGSTAFFNO, p_CALLINGNO);
  	 
 	 EXCEPTION
	   WHEN OTHERS THEN
	     p_retCode := 'S003100010';
	     p_retMsg  := '������ҵԱ���������ϱ���ӱ���Ϣʧ��,' || SQLERRM;
	     ROLLBACK; RETURN;
  END;    
		    
  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
  
END;

/
show errors   
