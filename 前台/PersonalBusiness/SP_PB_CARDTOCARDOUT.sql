CREATE OR REPLACE PROCEDURE SP_PB_CARDTOCARDOUT
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
	
	--����Ƿ����·����ҵ��
	BEGIN
	SELECT COUNT(1) INTO V_TIMES FROM TF_B_TRADE T WHERE CARDNO = P_OUTCARDNO AND CARDTRADENO = P_CARDTRADENO;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN NULL;
	END;	
	
	--����ͬ������ͬ����������ŵ�̨�ʼ�¼����ʾ�˿�������Ȧ�� ֱ����ʾ�ɹ�
	IF V_TIMES >= 1 THEN
		P_retCode := '0000000000';
		P_retMsg  := '';
		RETURN;
	END IF;
	
    --��ȡҵ����ˮ��
    SP_GetSeq(seq => V_TRADEID);
    p_TRADEID := V_TRADEID;    
    
    --��¼����ת�˼�¼̨�˱�
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
            P_retMsg  := '��¼����ת�˼�¼��ʧ��' || SQLERRM;
            ROLLBACK; RETURN;
    END;
          
    --����IC������Ǯ���˻���    
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
        P_RETMSG  := '����IC������Ǯ���˻���ʧ��'||SQLERRM;  
        ROLLBACK; RETURN;  
    END;
    
    --��ѯ�������Ѵ���
    BEGIN
        SELECT TOTALCONSUMETIMES 
        INTO   V_TOTALCONSUMETIMES
        FROM   TF_F_CARDEWALLETACC
        WHERE  CARDNO = P_OUTCARDNO;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
        p_retCode := 'S094570006';
        p_retMsg  := 'û�в�ѯ�������Ѵ�����¼';
        ROLLBACK; RETURN;
    END;    
    
    --����ǵ�һ�����ѣ������״�����ʱ���ֶ�
    IF V_TOTALCONSUMETIMES =1 THEN
        BEGIN
            UPDATE TF_F_CARDEWALLETACC
            SET    FIRSTCONSUMETIME = V_TODAY
            WHERE  CARDNO = P_OUTCARDNO;

            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S094570003';
                p_retMsg  := '����IC������Ǯ���˻����״�����ʱ���ֶ�ʧ��';
                ROLLBACK; RETURN;
        END;
    END IF;    
    
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