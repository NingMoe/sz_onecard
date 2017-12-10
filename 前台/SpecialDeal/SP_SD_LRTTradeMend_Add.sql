CREATE OR REPLACE PROCEDURE SP_SD_LRTTradeMend_Add
(    
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
    V_TODAY     DATE := SYSDATE;
    V_TRADEID   CHAR(16)       ;
    V_EX        EXCEPTION      ;
BEGIN
	  --��ȡ������ˮ��
	  SP_GetSeq(seq => V_TRADEID);
	  
	  BEGIN
      --��¼��콻�ײ�¼̨�˱�
      INSERT INTO TF_B_LRTTRADE_MANUAL(
          TRADEID      , CARDNO         , TRADEDATE    , TRADETIME   ,
          TRADEMONEY   , CITYNO         , ERRORREASON  , RENEWTIME   ,
          RENEWSTAFFNO , CHECKSTATECODE , DEALRESULT   , DEALSTAFFNO ,
          DEALDATE     , REMARK
     )VALUES(
          V_TRADEID    , P_CARDNO       , P_TRADEDATE  , P_TRADETIME  ,
          P_TRADEMONEY , '2150'         , P_REASON     , V_TODAY      ,
          p_currOper   , '0'            , P_DEALRESULT , P_DEALSTAFF  ,
          P_DEALDATE   , P_REMARK
           );
     IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
         WHEN OTHERS THEN
           P_RETCODE := 'S094570010';
           P_RETMSG  := '��¼��콻�ײ�¼̨�˱�ʧ��'||SQLERRM;      
           ROLLBACK; RETURN;
    END;
    
    p_retCode := '0000000000';
	  p_retMsg  := '�ɹ�';
	  COMMIT; RETURN;    

END;

/
show errors