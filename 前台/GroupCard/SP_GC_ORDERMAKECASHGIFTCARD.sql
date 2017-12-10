CREATE OR REPLACE PROCEDURE SP_GC_ORDERMAKECASHGIFTCARD
(
    p_ORDERNO           CHAR,  --������  
    P_CARDNO            CHAR,  --����
    P_VALUE             INT,
    p_wallet1           int , -- ����-����Ǯ�����1
    p_wallet2           int , -- ����-����Ǯ�����2
    p_startDate         char, -- ����-��ʼ��Ч��(yyyyMMdd)
    p_endDate           char, -- ����-������Ч��(yyyyMMdd)

    p_expiredDate       char, -- ����ʧЧ����(yyyyMMdd)
    p_saleMoney         int , -- ������Ԫ

    p_ID                char,
    p_cardTradeNo       char,
    p_asn               char,
    p_sellChannelCode   char,
    p_terminalNo        char,
    p_cardPrice     out int,
    p_currCardNo        char,
    p_seqNO       out char,
    p_writeCardScript out varchar2,
    p_currOper          char    ,
    p_currDept          char    ,
    p_retCode       out char    ,  -- Return Code
    p_retMsg        out varchar2   -- Return Message  
)
AS
    v_seqNo              CHAR(16); --ҵ����ˮ��
    V_EX                 EXCEPTION;
    V_TODAY              DATE := SYSDATE;
    V_ORDERSTATE         CHAR(2);
/*
    �����ƿ�-����ƿ�
    ʯ��
*/    
BEGIN
    --�޸����𿨶�����ϸ��    
    BEGIN
        UPDATE TF_F_CASHGIFTORDER
        SET    LEFTQTY = LEFTQTY - 1
        WHERE  ORDERNO = p_ORDERNO
        AND    VALUE = P_VALUE
        AND    LEFTQTY > 0;
        
        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570316';
        p_retMsg  := '�������𿨶�����ϸ��ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;         
    END;
   
    
    --���������۳��洢��ֵ�洢����
    SP_CG_SaleCard_nocom(
        p_submit     => '1',
        p_cardNo     => P_CARDNO ,
        p_wallet1    => p_wallet1,
        p_wallet2    => p_wallet2,
        p_startDate  => p_startDate,
        p_endDate    => p_endDate,
        p_expiredDate => p_expiredDate,
        p_saleMoney   => p_saleMoney,
        p_ID          => p_ID,
        p_cardTradeNo => p_cardTradeNo,
        p_asn         => p_asn,
        p_sellChannelCode => p_sellChannelCode,
        p_terminalNo  => p_terminalNo,
        p_cardPrice   => p_cardPrice,
        p_custName    => '',
        p_custSex     => '',
        p_custBirth   => '',
        p_paperType   => '',
        p_paperNo     => '',
        p_custAddr    => '',
        p_custPost    => '',
        p_custPhone   => '',
        p_custEmail   => '',
        p_remark      => '',
        p_seqNO       => v_seqNo,
        p_currCardNo  => p_currCardNo,
        p_writeCardScript => p_writeCardScript,
        p_currOper => p_currOper ,
        p_currDept => p_currDept ,
        p_retCode => p_retCode,
        p_retMsg => p_retMsg
    );
    IF p_retCode != '0000000000' THEN
        ROLLBACK;RETURN;
    END IF;
    
    --�ش���ˮ�Ÿ�ֵ
    p_seqNO := v_seqNo;
    
    --��¼����̨�˱�
    BEGIN
        INSERT INTO TF_F_ORDERTRADE (
            TRADEID         , ORDERNO           , TRADECODE       , MONEY             , GROUPNAME      , NAME   ,
            CASHGIFTMONEY   , CHARGECARDMONEY   , SZTCARDMONEY    , CUSTOMERACCMONEY  , GETDEPARTMENT  ,
            GETDATE         , REMARK            , OPERATEDEPARTNO , OPERATESTAFFNO    , OPERATETIME    ,
            MAKETYPE        , MAKECARDTYPE      , READERMONEY     , GARDENCARDMONEY   , RELAXCARDMONEY
       )SELECT
            v_seqNo         , p_ORDERNO         , '07'            , p_saleMoney        , A.GROUPNAME    , A.NAME ,
            A.CASHGIFTMONEY , A.CHARGECARDMONEY , A.SZTCARDMONEY  , A.CUSTOMERACCMONEY , A.GETDEPARTMENT,
            A.GETDATE       , A.REMARK          , p_currDept      , p_currOper         , v_today        ,
            '1'             , P_VALUE           , A.READERMONEY   , A.GARDENCARDMONEY  , A.RELAXCARDMONEY
        FROM TF_F_ORDERFORM A
        WHERE ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570320';
        p_retMsg :=  '��¼����̨�˱�ʧ��'|| SQLERRM ;
        rollback; return;
    END;
    
    
    
     --��¼���𿨶�����ϵ��
    BEGIN
        INSERT INTO TF_F_CASHGIFTRELATION(ORDERNO,CARDNO)VALUES(p_ORDERNO,P_CARDNO);
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570317';
        p_retMsg  := '��¼���𿨶�����ϵ��ʧ��,'|| SQLERRM;
        ROLLBACK; RETURN;   
    END;
    
    
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
        P_RETMSG  := '���¶�����ʧ��,'||SQLERRM;      
        ROLLBACK; RETURN;          
    END;
    END IF;
    
    p_retCode := '0000000000'; 
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;    
END;

/
SHOW ERRORS