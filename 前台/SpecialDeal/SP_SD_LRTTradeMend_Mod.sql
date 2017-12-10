CREATE OR REPLACE PROCEDURE SP_SD_LRTTradeMend_Mod
(
    P_TRADEID       char     ,  --ҵ����ˮ��
    P_CARDNO        char     ,  --����
    P_TRADEDATE     char     ,  --��������    
    P_TRADETIME     char     ,  --����ʱ��
    P_TRADEMONEY    int      ,  --���׽��
    P_DEALRESULT    varchar2 ,  --������
    P_DEALSTAFF     varchar2 ,  --����Ա��
    P_DEALDATE      char     ,  --��������
    P_REASON        varchar2 ,  --ԭ��
    P_REMARK        varchar2 ,  --��ע
    p_currOper	    char     ,
		p_currDept	    char     ,
		p_retCode       out char , -- Return Code
		p_retMsg        out varchar2  -- Return Message  
)
AS
    V_EX        EXCEPTION      ;
BEGIN
	  --������콻�ײ�¼̨�˱�
	  BEGIN
    UPDATE TF_B_LRTTRADE_MANUAL
    SET    CARDNO      = P_CARDNO     ,
           TRADEDATE   = P_TRADEDATE  ,
           TRADETIME   = P_TRADETIME  ,
           TRADEMONEY  = P_TRADEMONEY ,
           ERRORREASON = P_REASON     ,
           DEALRESULT  = P_DEALRESULT ,
           DEALSTAFFNO = P_DEALSTAFF  ,
           DEALDATE    = P_DEALDATE   ,
           REMARK      = P_REMARK
     WHERE TRADEID     = P_TRADEID
     AND   CHECKSTATECODE = '0';
     
     IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
         WHEN OTHERS THEN
           P_RETCODE := 'S094570011';
           P_RETMSG  := '������콻�ײ�¼̨�˱�ʧ��'||SQLERRM;      
           ROLLBACK; RETURN;     
     END;
     
    p_retCode := '0000000000';
	  p_retMsg  := '�ɹ�';
	  COMMIT; RETURN;        
END;

/
show errors