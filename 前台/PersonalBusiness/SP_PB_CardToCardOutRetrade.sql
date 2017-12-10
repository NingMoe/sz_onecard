CREATE OR REPLACE PROCEDURE SP_PB_CardToCardOutRetrade
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
    p_TRADEID       char , --Return trade id
    p_currOper      char     ,
    p_currDept      char     ,
    p_retCode       out char , -- Return Code
    p_retMsg        out varchar2  -- Return Message    
)
AS
    V_TRADEID       CHAR(16)  ;
    V_TODAY         DATE := SYSDATE;
    V_EX            EXCEPTION      ;
BEGIN
    --获取业务流水号
    SP_GetSeq(seq => V_TRADEID);
    
    --写卡成功后，将卡卡转账记录台账表的转账状态由2、圈提待写卡，改为0、圈提待转账
    BEGIN
        UPDATE TF_B_CARDTOCARDREG
        SET    TRANSTATE = '0'
        WHERE  TRADEID = p_TRADEID
        AND    TRANSTATE = '2';
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570008';
            p_retMsg  := '更新卡卡转账记录台账表失败'|| SQLERRM;
            ROLLBACK; RETURN;
    END;

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