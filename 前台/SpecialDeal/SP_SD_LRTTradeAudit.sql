CREATE OR REPLACE PROCEDURE SP_SD_LRTTradeAudit
(
    P_FUNCODE       varchar2 ,  --功能编码
    P_TRADEID       char     ,  --业务流水号
    P_CARDTRADENO   char     ,  --交易序号
    p_currOper	    char     ,
		p_currDept	    char     ,
		p_retCode       out char , -- Return Code
		p_retMsg        out varchar2  -- Return Message  
)
AS
    V_EX        EXCEPTION      ;
    V_TODAY     DATE := SYSDATE;
BEGIN
    --审核通过
    IF P_FUNCODE = 'PASS' THEN
    	--更新轻轨交易补录台账表
    	BEGIN
    	  UPDATE TF_B_LRTTRADE_MANUAL
        SET    CHECKSTATECODE = '1'           ,
               CARDTRADENO    = P_CARDTRADENO ,
               CHECKSTAFFNO   = p_currOper    ,
               CHECKTIME      = V_TODAY
        WHERE  TRADEID        = P_TRADEID
        AND    CHECKSTATECODE = '0';
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
              P_RETCODE := 'S094570013';
              P_RETMSG  := '更新通过轻轨交易补录台账表失败'||SQLERRM;      
              ROLLBACK; RETURN;          
    	END;
    END IF;
    --审核作废
    IF P_FUNCODE = 'CANCEL' THEN
    	--更新轻轨交易补录台账表
    	BEGIN
    	  UPDATE TF_B_LRTTRADE_MANUAL
        SET    CHECKSTATECODE = '2'           ,
               CHECKSTAFFNO   = p_currOper    ,
               CHECKTIME      = V_TODAY
        WHERE  TRADEID        = P_TRADEID
        AND    CHECKSTATECODE = '0';
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
            WHEN OTHERS THEN
              P_RETCODE := 'S094570014';
              P_RETMSG  := '更新作废轻轨交易补录台账表失败'||SQLERRM;      
              ROLLBACK; RETURN;           
    	END;    	
    END IF;
    
    p_retCode := '0000000000';
	  p_retMsg  := '成功';
	  COMMIT; RETURN;    

END;

/
show errors