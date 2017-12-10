CREATE OR REPLACE PROCEDURE SP_PB_CARDTOCARDOUT
(
    P_ID            CHAR     , --记录流水号
    P_OUTCARDNO     CHAR     , --圈提卡号
    P_TRADETYPECODE CHAR     , --业务类型
    P_CARDTRADENO   CHAR     , --联机交易序号
    P_SUPPLYMONEY   INT      , --圈提金额    
    P_CARDMONEY     INT      , --卡内余额
    P_REMARK        VARCHAR2 , --备注
    P_OPERCARDNO    CHAR     , --操作员卡号
    P_TERMNO        CHAR     , --终端号
    p_TRADEID   out char , --Return trade id
    p_currOper      char     ,
    p_currDept      char     ,
    p_retCode       out char , -- Return Code
    p_retMsg        out varchar2  -- Return Message    
)
AS
	V_TIMES			INT:= 0;
    V_TRADEID           CHAR(16)  ;
    V_TOTALCONSUMETIMES INT       ;
    V_TODAY        DATE := SYSDATE;
    V_EX           EXCEPTION      ;
BEGIN
	
	--检查是否重新发起的业务
	BEGIN
	SELECT COUNT(1) INTO V_TIMES FROM TF_B_TRADE T WHERE CARDNO = P_OUTCARDNO AND CARDTRADENO = P_CARDTRADENO;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN NULL;
	END;	
	
	--有相同卡号相同联机交易序号的台帐记录，表示此卡已做过圈提 直接提示成功
	IF V_TIMES >= 1 THEN
		P_retCode := '0000000000';
		P_retMsg  := '';
		RETURN;
	END IF;
	
    --获取业务流水号
    SP_GetSeq(seq => V_TRADEID);
    p_TRADEID := V_TRADEID;    
    
    --记录卡卡转账记录台账表
    BEGIN 
        INSERT INTO TF_B_CARDTOCARDREG(
            TRADEID    , OUTCARDNO   , MONEY         , OUTSTAFFNO   ,
            OUTDEPTNO  , OUTTIME     , TRANSTATE     , REMARK
       )VALUES(
            V_TRADEID  , P_OUTCARDNO , P_SUPPLYMONEY , P_CURROPER   , 
            P_CURRDEPT , V_TODAY     , '2'           , P_REMARK
              );
    EXCEPTION
        WHEN OTHERS THEN
            P_retCode := 'S094570001';
            P_retMsg  := '记录卡卡转账记录表失败' || SQLERRM;
            ROLLBACK; RETURN;
    END;
          
    --更新IC卡电子钱包账户表    
    BEGIN
    UPDATE TF_F_CARDEWALLETACC
    SET    CONSUMEREALMONEY  = P_CARDMONEY                  ,
           CARDACCMONEY      = CARDACCMONEY - P_SUPPLYMONEY ,
           TOTALCONSUMETIMES = TOTALCONSUMETIMES + 1        ,
           TOTALCONSUMEMONEY = TOTALCONSUMEMONEY + P_SUPPLYMONEY ,
           LASTCONSUMETIME   = V_TODAY                      ,
           ONLINECARDTRADENO = P_CARDTRADENO
    WHERE  CARDNO = P_OUTCARDNO
    AND    USETAG = '1'; 
    
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S094570002';    
        P_RETMSG  := '更新IC卡电子钱包账户表失败'||SQLERRM;  
        ROLLBACK; RETURN;  
    END;
    
    --查询卡总消费次数
    BEGIN
        SELECT TOTALCONSUMETIMES 
        INTO   V_TOTALCONSUMETIMES
        FROM   TF_F_CARDEWALLETACC
        WHERE  CARDNO = P_OUTCARDNO;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        p_retCode := 'S094570006';
        p_retMsg  := '没有查询出总消费次数记录';
        ROLLBACK; RETURN;
    END;    
    
    --如果是第一次消费，更新首次消费时间字段
    IF V_TOTALCONSUMETIMES =1 THEN
        BEGIN
            UPDATE TF_F_CARDEWALLETACC
            SET    FIRSTCONSUMETIME = V_TODAY
            WHERE  CARDNO = P_OUTCARDNO;

            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S094570003';
                p_retMsg  := '更新IC卡电子钱包账户表首次消费时间字段失败';
                ROLLBACK; RETURN;
        END;
    END IF;    
    
    --记录主台账表
    BEGIN
        INSERT INTO TF_B_TRADE(
            TRADEID      , ID              , CARDNO          , TRADETYPECODE   , 
            ASN          , CARDTYPECODE    , CARDTRADENO     , CURRENTMONEY    , 
            PREMONEY     , NEXTMONEY       , OPERATESTAFFNO  , OPERATEDEPARTID , 
            OPERATETIME  
       )SELECT
            V_TRADEID    , P_ID            , P_OUTCARDNO     , P_TRADETYPECODE , 
            ASN          , CARDTYPECODE    , P_CARDTRADENO   , 0-P_SUPPLYMONEY , 
            P_CARDMONEY  , P_CARDMONEY - P_SUPPLYMONEY, P_CURROPER , P_CURRDEPT, 
            V_TODAY      
        FROM TF_F_CARDREC
        WHERE CARDNO = P_OUTCARDNO;
    
    EXCEPTION
        WHEN OTHERS THEN
              P_retCode := 'S094570004';
              P_retMsg  := '记录主台账表失败' || SQLERRM;
              ROLLBACK; RETURN;          
    END;
              
    --记录业务写卡台账表
    BEGIN
        INSERT INTO TF_CARD_TRADE(
            TRADEID        , TRADETYPECODE   , strOperCardNo , strCardNo     ,
            lMoney         , lOldMoney       , strTermno     , OPERATETIME   ,
            SUCTAG        
       )VALUES(
            V_TRADEID      , P_TRADETYPECODE , P_OPERCARDNO  , P_OUTCARDNO   ,
            -P_SUPPLYMONEY , P_CARDMONEY     , P_TERMNO      , v_today       ,
            '0'           
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