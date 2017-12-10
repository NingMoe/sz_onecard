CREATE OR REPLACE PROCEDURE SP_PB_CARDTOCARDIN
(
    P_ID            CHAR     , --��¼��ˮ��
    p_OUTTRADEID    CHAR     , --Ȧ��ҵ����ˮ��
    P_INCARDNO      CHAR     , --Ȧ�濨��
    P_OUTCARDNO     CHAR     , --Ȧ�Ῠ��
    P_TRADETYPECODE CHAR     , --ҵ������
    P_CARDTRADENO   CHAR     , --�����������
    P_SUPPLYMONEY   INT      , --Ȧ����    
    P_CARDMONEY     INT      , --�������
    P_OPERCARDNO    CHAR     , --����Ա����
    P_TERMNO        CHAR     , --�ն˺�
    p_CHECKSTAFFNO	CHAR     , --���Ա������
		p_CHECKDEPARTNO	CHAR     , --��˲��ű���
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
    --��ȡҵ����ˮ��
    SP_GetSeq(seq => V_TRADEID);
    p_TRADEID := V_TRADEID;	
    
    --����IC������Ǯ���˻���
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
        P_RETMSG  := '����IC������Ǯ���˻���ʧ��'||SQLERRM;      
        ROLLBACK; RETURN;
    END;        
    
    --��ѯ�������Ѵ���
		BEGIN
		    SELECT TOTALSUPPLYTIMES 
		    INTO   V_TOTALSUPPLYTIMES
		    FROM   TF_F_CARDEWALLETACC
		    WHERE  CARDNO = P_INCARDNO;

    EXCEPTION
				    WHEN NO_DATA_FOUND THEN
				    p_retCode := 'S094570006';
				    p_retMsg  := 'û�в�ѯ�������Ѵ�����¼';
				    ROLLBACK; RETURN;
    END;    
    
    --����ǵ�һ�����ѣ������״�����ʱ���ֶ�
    IF V_TOTALSUPPLYTIMES = 1 THEN
		    BEGIN
		        UPDATE TF_F_CARDEWALLETACC
		        SET    FIRSTSUPPLYTIME = V_TODAY
		        WHERE  CARDNO = P_INCARDNO;

		        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
				EXCEPTION
			        WHEN OTHERS THEN
			            p_retCode := 'S094570003';
			            p_retMsg  := '����IC������Ǯ���˻����״γ�ֵʱ���ֶ�ʧ��';
			            ROLLBACK; RETURN;
		    END;
    END IF;      
    
    --������̨�˱�
    BEGIN
    UPDATE TF_B_TRADE
    SET    RSRV2 = P_INCARDNO
    WHERE  TRADEID   = p_OUTTRADEID 
    AND    TRADETYPECODE = '5A'
    AND    CANCELTAG = '0' ; 
    
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S094570008';
        P_RETMSG  := '������̨�˱�ʧ��'||SQLERRM;  
        ROLLBACK; RETURN;
    END;
    
    --��¼��̨�˱�
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
	          P_retMsg  := '��¼��̨�˱�ʧ��' || SQLERRM;
	          ROLLBACK; RETURN;          
    END;    
    
    --���¿���ת�˼�¼��
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
        P_RETMSG  := '���¸��¿���ת�˼�¼��ʧ��'||SQLERRM;       
        ROLLBACK; RETURN;   
    END;
    
    --��¼ҵ��д��̨�˱�
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
	          P_retMsg  := '��¼ҵ��д��̨�˱�ʧ��' || SQLERRM;
	          ROLLBACK; RETURN;           
    END;
    
    p_retCode := '0000000000';
	  p_retMsg  := '�ɹ�';
	  COMMIT; RETURN;        
END;

/
show errors