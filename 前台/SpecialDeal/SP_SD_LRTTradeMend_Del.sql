CREATE OR REPLACE PROCEDURE SP_SD_LRTTradeMend_Del
(
    P_TRADEID       char     ,  --业务流水号
    p_currOper	    char     ,
		p_currDept	    char     ,
		p_retCode       out char , -- Return Code
		p_retMsg        out varchar2  -- Return Message  
)
AS
    V_EX        EXCEPTION      ;
BEGIN
    --删除轻轨交易补录台账表记录
    BEGIN
      DELETE FROM TF_B_LRTTRADE_MANUAL WHERE TRADEID = P_TRADEID AND CHECKSTATECODE = '0';
      
     IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
     EXCEPTION
         WHEN OTHERS THEN
           P_RETCODE := 'S094570012';
           P_RETMSG  := '删除轻轨交易补录台账表记录失败'||SQLERRM;      
           ROLLBACK; RETURN;        
    END;
    
    p_retCode := '0000000000';
	  p_retMsg  := '成功';
	  COMMIT; RETURN;        
END;

/
show errors