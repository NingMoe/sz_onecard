CREATE OR REPLACE PROCEDURE SP_SD_LRTTradeMend_Mod
(
    P_TRADEID       char     ,  --业务流水号
    P_CARDNO        char     ,  --卡号
    P_TRADEDATE     char     ,  --交易日期    
    P_TRADETIME     char     ,  --交易时间
    P_TRADEMONEY    int      ,  --交易金额
    P_DEALRESULT    varchar2 ,  --处理结果
    P_DEALSTAFF     varchar2 ,  --处理员工
    P_DEALDATE      char     ,  --处理日期
    P_REASON        varchar2 ,  --原因
    P_REMARK        varchar2 ,  --备注
    p_currOper	    char     ,
		p_currDept	    char     ,
		p_retCode       out char , -- Return Code
		p_retMsg        out varchar2  -- Return Message  
)
AS
    V_EX        EXCEPTION      ;
BEGIN
	  --更新轻轨交易补录台账表
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
           P_RETMSG  := '更新轻轨交易补录台账表失败'||SQLERRM;      
           ROLLBACK; RETURN;     
     END;
     
    p_retCode := '0000000000';
	  p_retMsg  := '成功';
	  COMMIT; RETURN;        
END;

/
show errors