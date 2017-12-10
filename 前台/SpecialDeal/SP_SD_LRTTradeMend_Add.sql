CREATE OR REPLACE PROCEDURE SP_SD_LRTTradeMend_Add
(    
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
    V_TODAY     DATE := SYSDATE;
    V_TRADEID   CHAR(16)       ;
    V_EX        EXCEPTION      ;
BEGIN
	  --获取交易流水号
	  SP_GetSeq(seq => V_TRADEID);
	  
	  BEGIN
      --记录轻轨交易补录台账表
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
           P_RETMSG  := '记录轻轨交易补录台账表失败'||SQLERRM;      
           ROLLBACK; RETURN;
    END;
    
    p_retCode := '0000000000';
	  p_retMsg  := '成功';
	  COMMIT; RETURN;    

END;

/
show errors