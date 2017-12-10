--�������񿨶��������˻��ļ�
CREATE OR REPLACE PROCEDURE SP_RM_DOWNLOADSMKORDER
(
	P_CARDORDERID          CHAR     ,  --��������
	p_currOper	           char     ,
	p_currDept	           char     ,
	p_retCode          out char     ,  -- Return Code
	p_retMsg           out varchar2    -- Return Message  
)
AS
  
    V_EX        EXCEPTION      ;
 
BEGIN
	 
	BEGIN
	  --�������ش���
		UPDATE TF_F_SMK_CARDORDER SET DOWNLOADNUM = NVL(DOWNLOADNUM,0) + 1
		WHERE CARDORDERID = P_CARDORDERID;
     EXCEPTION
       WHEN OTHERS THEN
         P_RETCODE := 'S094570100';
         P_RETMSG  := '�������񿨶�����ʧ��'||SQLERRM;      
         ROLLBACK; RETURN;      		       
	END;

  p_retCode := '0000000000';
  p_retMsg  := '�ɹ�';
  COMMIT; RETURN;    	
END;

/
show errors
