CREATE OR REPLACE PROCEDURE SP_PB_CardToCardOutRetrade
(
    P_ID            CHAR     , --��¼��ˮ��
    P_OUTCARDNO     CHAR     , --Ȧ�Ῠ��
    P_TRADETYPECODE CHAR     , --ҵ������
    P_CARDTRADENO   CHAR     , --�����������
    P_SUPPLYMONEY   INT      , --Ȧ����    
    P_CARDMONEY     INT      , --�������
    P_REMARK        VARCHAR2 , --��ע
    P_OPERCARDNO    CHAR     , --����Ա����
    P_TERMNO        CHAR     , --�ն˺�
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
    --��ȡҵ����ˮ��
    SP_GetSeq(seq => V_TRADEID);
    
    --д���ɹ��󣬽�����ת�˼�¼̨�˱��ת��״̬��2��Ȧ���д������Ϊ0��Ȧ���ת��
    BEGIN
        UPDATE TF_B_CARDTOCARDREG
        SET    TRANSTATE = '0'
        WHERE  TRADEID = p_TRADEID
        AND    TRANSTATE = '2';
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570008';
            p_retMsg  := '���¿���ת�˼�¼̨�˱�ʧ��'|| SQLERRM;
            ROLLBACK; RETURN;
    END;

    --��¼��̨�˱�
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
            P_retMsg  := '��¼��̨�˱�ʧ��' || SQLERRM;
            ROLLBACK; RETURN;          
    END;
              
    --��¼ҵ��д��̨�˱�
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
            P_retMsg  := '��¼ҵ��д��̨�˱�ʧ��' || SQLERRM;
            ROLLBACK; RETURN;           
    END;
    p_retCode := '0000000000';
    p_retMsg  := '�ɹ�';
    COMMIT; RETURN;
END;

/
show errors