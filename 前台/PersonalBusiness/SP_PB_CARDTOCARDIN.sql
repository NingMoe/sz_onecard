CREATE OR REPLACE PROCEDURE SP_PB_CARDTOCARDIN
(
    P_ID            CHAR     , --记录流水号
    p_OUTTRADEID    CHAR     , --圈提业务流水号
    P_INCARDNO      CHAR     , --圈存卡号
    P_OUTCARDNO     CHAR     , --圈提卡号
    P_TRADETYPECODE CHAR     , --业务类型
    P_CARDTRADENO   CHAR     , --联机交易序号
    P_SUPPLYMONEY   INT      , --圈存金额    
    P_CARDMONEY     INT      , --卡内余额
    P_OPERCARDNO    CHAR     , --操作员卡号
    P_TERMNO        CHAR     , --终端号
    p_CHECKSTAFFNO	CHAR     , --审核员工编码
		p_CHECKDEPARTNO	CHAR     , --审核部门编码
		p_TRADEID	      out char , --Return trade id
		p_currOper	    char     ,
		p_currDept	    char     ,
		p_retCode       out char , -- Return Code
		p_retMsg        out varchar2  -- Return Message    
)
AS
    V_TRADEID           CHAR(16)  ;
    V_TOTALSUPPLYTIMES  INT       ;
    V_TODAY        DATE := SYSDATE;
    V_EX           EXCEPTION      ;
BEGIN
    --获取业务流水号
    SP_GetSeq(seq => V_TRADEID);
    p_TRADEID := V_TRADEID;	
    
    --更新IC卡电子钱包账户表
    BEGIN
    UPDATE TF_F_CARDEWALLETACC															
    SET		 CARDACCMONEY      = CARDACCMONEY + P_SUPPLYMONEY   ,
		       SUPPLYREALMONEY   = P_CARDMONEY                    ,
		       TOTALSUPPLYTIMES  = TOTALSUPPLYTIMES+1			       	,								
	         TOTALSUPPLYMONEY  = TOTALSUPPLYMONEY+P_SUPPLYMONEY ,									
		       LASTSUPPLYTIME    = V_TODAY									      ,			
	         ONLINECARDTRADENO = P_CARDTRADENO
    WHERE	 CARDNO            = P_INCARDNO;
    
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S094570002';
        P_RETMSG  := '更新IC卡电子钱包账户表失败'||SQLERRM;      
        ROLLBACK; RETURN;
    END;        
    
    --查询卡总消费次数
		BEGIN
		    SELECT TOTALSUPPLYTIMES 
		    INTO   V_TOTALSUPPLYTIMES
		    FROM   TF_F_CARDEWALLETACC
		    WHERE  CARDNO = P_INCARDNO;

    EXCEPTION
				    WHEN NO_DATA_FOUND THEN
				    p_retCode := 'S094570006';
				    p_retMsg  := '没有查询出总消费次数记录';
				    ROLLBACK; RETURN;
    END;    
    
    --如果是第一次消费，更新首次消费时间字段
    IF V_TOTALSUPPLYTIMES = 1 THEN
		    BEGIN
		        UPDATE TF_F_CARDEWALLETACC
		        SET    FIRSTSUPPLYTIME = V_TODAY
		        WHERE  CARDNO = P_INCARDNO;

		        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
				EXCEPTION
			        WHEN OTHERS THEN
			            p_retCode := 'S094570003';
			            p_retMsg  := '更新IC卡电子钱包账户表首次充值时间字段失败';
			            ROLLBACK; RETURN;
		    END;
    END IF;      
    
    --更新主台账表
    BEGIN
    UPDATE TF_B_TRADE
    SET    RSRV2 = P_INCARDNO
    WHERE  TRADEID   = p_OUTTRADEID 
    AND    TRADETYPECODE = '5A'
    AND    CANCELTAG = '0' ; 
    
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S094570008';
        P_RETMSG  := '更新主台账表失败'||SQLERRM;  
        ROLLBACK; RETURN;
    END;
    
    --记录主台账表
    BEGIN
    INSERT INTO TF_B_TRADE(
        TRADEID      , ID              , CARDNO          , TRADETYPECODE   , 
        ASN          , CARDTYPECODE    , CARDTRADENO     , CURRENTMONEY    , 
        PREMONEY     , NEXTMONEY       , OPERATESTAFFNO  , OPERATEDEPARTID , 
        OPERATETIME  , RSRV2           , CHECKSTAFFNO    , CHECKDEPARTNO   
   )SELECT
        V_TRADEID    , P_ID            , P_INCARDNO      , P_TRADETYPECODE , 
        ASN          , CARDTYPECODE    , P_CARDTRADENO   , P_SUPPLYMONEY   , 
        P_CARDMONEY  , P_CARDMONEY + P_SUPPLYMONEY, P_CURROPER , P_CURRDEPT, 
        V_TODAY      , P_OUTCARDNO     , p_CHECKSTAFFNO  , p_CHECKDEPARTNO
    FROM TF_F_CARDREC
    WHERE CARDNO = P_INCARDNO;
    
    EXCEPTION
        WHEN OTHERS THEN
	          P_retCode := 'S094570004';
	          P_retMsg  := '记录主台账表失败' || SQLERRM;
	          ROLLBACK; RETURN;          
    END;    
    
    --更新卡卡转账记录表
    BEGIN
    UPDATE TF_B_CARDTOCARDREG
    SET    INCARDNO  = P_INCARDNO ,
           MONEY     = P_SUPPLYMONEY ,
           INSTAFFNO = P_CURROPER ,
           INDEPTNO  = P_CURRDEPT ,
           INTIME    = V_TODAY    ,
           TRANSTATE = '1'
    WHERE  TRADEID = p_OUTTRADEID
    AND    TRANSTATE = '0';
    
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S094570007';
        P_RETMSG  := '更新更新卡卡转账记录表失败'||SQLERRM;       
        ROLLBACK; RETURN;   
    END;
    
    --记录业务写卡台账表
    BEGIN
    INSERT INTO TF_CARD_TRADE(
        TRADEID       , TRADETYPECODE   , strOperCardNo , strCardNo     ,
        lMoney        , lOldMoney       , strTermno     , OPERATETIME   ,
        SUCTAG        , Cardtradeno
   )VALUES(
        V_TRADEID     , P_TRADETYPECODE , P_OPERCARDNO  , P_INCARDNO    ,
        P_SUPPLYMONEY , P_CARDMONEY     , P_TERMNO      , v_today       ,
        '0'           , p_CARDTRADENO
          );
    EXCEPTION
        WHEN OTHERS THEN
	          P_retCode := 'S094570005';
	          P_retMsg  := '记录业务写卡台账表失败' || SQLERRM;
	          ROLLBACK; RETURN;           
    END;
    
    p_retCode := '0000000000';
	  p_retMsg  := '成功';
	  COMMIT; RETURN;        
END;

/
show errors