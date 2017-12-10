CREATE OR REPLACE PROCEDURE SP_GC_ORDERMAKESZTCARD
(
    p_ORDERNO           CHAR,  --订单号  
    P_CARDNO            CHAR,  --卡号
    P_CARDTYPECODE      CHAR,  --卡类型
    p_ID1               CHAR,  --售卡ID
    p_ID2               CHAR,  --充值ID
    p_SALETRADETYPECODE CHAR,  --业务类型
    p_DEPOSIT           int,
    p_CARDCOST          int,
    p_SALEOTHERFEE      int,
    p_CARDTRADENO       char,
    p_SELLCHANNELCODE   char,
    p_SERSTAKETAG       char,
    p_CUSTRECTYPECODE   char, 
    
    p_CARDMONEY        int,
    p_CARDACCMONEY     int,
    p_ASN              char,
    p_SUPPLYMONEY      int,
    p_CHARGEOTHERFEE   int,
    p_CHARGETRADETYPECODE  char,
    
    p_TERMNO           char,
    p_OPERCARDNO       char,
    p_CHARGETYPE   varchar2, --充值营销模式编码
    p_TRADEID1      out char, -- Return trade id    
    p_TRADEID2      out char, -- Return trade id    
    
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS
    v_cardPrice          INT;
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;
    V_MONEY              INT;
    v_saletype           CHAR(2);
    v_deposit            int;
    v_cardcost           int;
    V_ORDERSTATE         CHAR(2);    
/*
    订单制卡-市民卡B卡制卡
    石磊
*/
BEGIN
    --如果是初次制卡，则修改订单状态
    SELECT ORDERSTATE INTO V_ORDERSTATE FROM TF_F_ORDERFORM WHERE ORDERNO = p_ORDERNO;
    IF V_ORDERSTATE = '03' THEN
    BEGIN
        UPDATE TF_F_ORDERFORM
        SET    ORDERSTATE = '04' ,
               UPDATEDEPARTNO = p_currDept,
               UPDATESTAFFNO = p_currOper ,
               UPDATETIME = v_today
        WHERE  ORDERNO = p_ORDERNO
        AND    ORDERSTATE = '03';
        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE := 'S094570338';
        P_RETMSG  := '更新订单表失败,'||SQLERRM;      
        ROLLBACK; RETURN;          
    END;
    END IF;  
    
    --修改市民卡B卡订单明细表
    BEGIN
        UPDATE TF_F_SZTCARDORDER
        SET    LEFTQTY = LEFTQTY - 1
        WHERE  ORDERNO = p_ORDERNO
        AND    CARDTYPECODE = P_CARDTYPECODE
        AND    LEFTQTY > 0;
        
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570321';
        p_retMsg  := '更新市民卡B卡订单明细表失败,'|| SQLERRM;
        ROLLBACK; RETURN;             
    END;
    
    --记录市民卡B卡订单关系表
    BEGIN
        INSERT INTO TF_F_SZTCARDRELATION(ORDERNO,CARDNO)VALUES(p_ORDERNO,P_CARDNO);
        
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570322';
        p_retMsg  := '记录市民卡B卡订单关系表失败,'|| SQLERRM;
        ROLLBACK; RETURN;         
    END;    
    
    --查询卡单价
    SELECT CARDPRICE,SALETYPE INTO v_cardPrice,v_saletype FROM TL_R_ICUSER WHERE CARDNO = p_cardNo;
    
    IF(v_saletype = '01') THEN --卡费
        v_deposit  := 0;
        v_cardcost := v_cardPrice; 
    ELSE
        v_deposit  := v_cardPrice;
        v_cardcost := 0;
    END IF;
    
    --计算涉及金额
    V_MONEY := p_SUPPLYMONEY + v_cardPrice;
    
    --调用售卡存储过程
    SP_PB_SaleCard(
        p_ID => p_ID1,
        p_CARDNO  => p_cardNo,
        p_DEPOSIT  => v_deposit, 
        p_CARDCOST => v_cardcost ,
        p_OTHERFEE        => p_SALEOTHERFEE, 
        p_CARDTRADENO     => p_cardTradeNo, 
        p_CARDTYPECODE    => SUBSTR(P_CARDTYPECODE,0,2),
        p_CARDMONEY       => p_CARDMONEY, 
        p_SELLCHANNELCODE => p_sellChannelCode, 
        p_SERSTAKETAG     => p_SERSTAKETAG, 
        p_TRADETYPECODE   => p_SALETRADETYPECODE,
        p_CUSTNAME        => '',
        p_CUSTSEX         => '', 
        p_CUSTBIRTH       => '', 
        p_PAPERTYPECODE   => '', 
        p_PAPERNO         => '',
        p_CUSTADDR        => '',
        p_CUSTPOST        => '',
        p_CUSTPHONE       => '',
        p_CUSTEMAIL       => '',
        p_REMARK          => '',
        p_CUSTRECTYPECODE => '0', 
        p_TERMNO          => p_TERMNO, 
        p_OPERCARDNO      => p_OPERCARDNO,
        p_CURRENTTIME     => v_today, 
        p_TRADEID         => p_TRADEID1, 
        p_currOper        => p_currOper, 
        p_currDept        => p_currDept, 
        p_retCode         => p_retCode, 
        p_retMsg          => p_retMsg
    );
    IF p_retCode != '0000000000' THEN
        RETURN;ROLLBACK;
    END IF;        
       
    --记录订单台账表
    BEGIN
        INSERT INTO TF_F_ORDERTRADE (
            TRADEID         , ORDERNO           , TRADECODE       , MONEY             , GROUPNAME      , NAME   ,
            CASHGIFTMONEY   , CHARGECARDMONEY   , SZTCARDMONEY    , CUSTOMERACCMONEY  , GETDEPARTMENT  ,
            GETDATE         , REMARK            , OPERATEDEPARTNO , OPERATESTAFFNO    , OPERATETIME    ,
            MAKETYPE        , MAKECARDTYPE      , READERMONEY     , GARDENCARDMONEY   , RELAXCARDMONEY
       )SELECT
            p_TRADEID1      , p_ORDERNO         , '07'            , V_MONEY       , A.GROUPNAME    , A.NAME ,
            A.CASHGIFTMONEY , A.CHARGECARDMONEY , A.SZTCARDMONEY  , A.CUSTOMERACCMONEY , A.GETDEPARTMENT,
            A.GETDATE       , A.REMARK          , p_currDept      , p_currOper         , v_today        ,
            '2'             , P_CARDTYPECODE    , A.READERMONEY   , A.GARDENCARDMONEY  , A.RELAXCARDMONEY
        FROM TF_F_ORDERFORM A
        WHERE ORDERNO = p_ORDERNO;
    exception when others then
        p_retCode := 'S094570323';
        p_retMsg :=  '记录订单台账表失败'|| SQLERRM ;
        rollback; return;
    END;            
    
    --调用充值存储过程
    SP_PB_Charge(
        p_ID            => p_ID2,
        p_CARDNO        => p_CARDNO,
        p_CARDTRADENO   => p_CARDTRADENO,
        p_CARDMONEY     => p_CARDMONEY,
        p_CARDACCMONEY  => p_CARDACCMONEY,
        p_ASN           => p_ASN,
        p_CARDTYPECODE  => SUBSTR(P_CARDTYPECODE,0,2),
        p_SUPPLYMONEY   => p_SUPPLYMONEY,
        p_OTHERFEE      => p_CHARGEOTHERFEE,
        p_TRADETYPECODE => p_CHARGETRADETYPECODE,
        p_TERMNO        => p_TERMNO,
        p_OPERCARDNO    => p_OPERCARDNO,
        p_CHARGETYPE    => p_CHARGETYPE,
        p_TRADEID       => p_TRADEID2,
        p_currOper      => p_currOper,
        p_currDept      => p_currDept,
        p_retCode       => p_retCode,
        p_retMsg        => p_retMsg
    );
    IF p_retCode != '0000000000' THEN
        RETURN;ROLLBACK;
    END IF;                 
    
    p_retCode := '0000000000'; 
    p_retMsg  := '成功';
    COMMIT; RETURN;    
END;

/
SHOW ERRORS