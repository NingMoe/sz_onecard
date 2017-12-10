CREATE OR REPLACE PROCEDURE SP_EW_SaleChangeCard
(   
		p_ID	              char, --��¼��ˮ��
		p_TRADETYPECODE     char, --ҵ�����ͱ���
		p_CARDCOST	        int , --����
		p_NEWCARDNO	        char, --�¿�����
		p_OLDCARDNO	        char, --�ɿ�����
		p_CARDTRADENO     	char, --�����������
		p_CHANGECODE	      char, --�������ͱ���
		p_SELLCHANNELCODE	  char, --�ۿ���������
		p_CARDACCMONEY	    int,  --�˻����
		p_TOTALSUPPLYMONEY	int,  --�ܳ�ֵ���
		p_CUSTNAME	        varchar2, --����
		p_CUSTSEX	          varchar2, --�Ա�
		p_CUSTBIRTH	        varchar2, --��������
		p_PAPERTYPECODE	    varchar2, --֤������
		p_PAPERNO          	varchar2, --֤������
		p_CUSTADDR	        varchar2, --��ϵ��ַ
		p_CUSTPOST	        varchar2, --��������
		p_CUSTPHONE	        varchar2, --��ϵ�绰
		p_CUSTEMAIL         varchar2, --�����ʼ�
		p_REMARK	          varchar2, --��ע		
		p_TRADEORIGIN       varchar2, --ҵ����Դ
		p_currOper	        char,
		p_currDept	        char,
		p_TRADEID    	      out char, -- Return Trade Id
		p_retCode	          out char, -- Return Code
		p_retMsg     	      out varchar2  -- Return Message
)
AS
    v_TradeID             char(16);
    v_ex                  exception;
    v_today               date := sysdate ;
BEGIN
    -- 1) Update new card's resource statecode
    BEGIN
		    UPDATE TL_R_ICUSER
		    SET    RESSTATECODE  = '06',
		           SELLTIME      = v_today,
		           UPDATESTAFFNO = p_currOper,
		           UPDATETIME    = v_today
		    WHERE  CARDNO        = p_NEWCARDNO
		    AND    RESSTATECODE  = '01';

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001004105';
	            p_retMsg  := 'Error occurred while updating resource statecode of new card' || SQLERRM;
	            RETURN;
    END;

		-- 2) Update old card's info
		BEGIN
		    UPDATE TF_F_CARDREC
		    SET    RSRV1         = p_NEWCARDNO
		    WHERE  CARDNO        = p_OLDCARDNO
		    AND    USETAG        = '0';

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
			      WHEN OTHERS THEN
			          p_retCode := 'S001004103';
			          p_retMsg  := 'Error occurred while updating rec info of old card' || SQLERRM;
			      RETURN;
		END;    			
    
    -- 3) Insert a row in CARDREC
    BEGIN
		    INSERT INTO TF_F_CARDREC(
		        CARDNO           , ASN                , CARDTYPECODE     , CARDSURFACECODE   ,
		        CARDMANUCODE     , CARDCHIPTYPECODE   , APPTYPECODE      , APPVERNO          ,
		        DEPOSIT          , CARDCOST           , PRESUPPLYMONEY   , CUSTRECTYPECODE   ,
		        SELLTIME         , SELLCHANNELCODE    , DEPARTNO         , STAFFNO           ,
		        CARDSTATE        , VALIDENDDATE       , USETAG           , SERSTARTTIME      ,
		        SERSTAKETAG      , SERVICEMONEY       , UPDATESTAFFNO    , UPDATETIME
		   )SELECT
		        p_NEWCARDNO      , t.ASN              , t.CARDTYPECODE   , t.CARDSURFACECODE ,
		        t.MANUTYPECODE   , t.CARDCHIPTYPECODE , t.APPTYPECODE    , t.APPVERNO        ,
		        0                , p_CARDCOST         , t.PRESUPPLYMONEY , '1'               ,
		        v_today          , p_SELLCHANNELCODE  , p_currDept       , p_currOper        ,
		        '11'             , t.VALIDENDDATE     , '1'              , v_today           ,
		        '0'              , 0                  , p_currOper       , v_today
		    FROM TL_R_ICUSER t
		    WHERE CARDNO = p_NEWCARDNO;
        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001004100';
	            p_retMsg  := 'Error occurred while insert a row in cardrec' || SQLERRM;
	            RETURN;
    END;
    
    -- 4) insert a row of elec wallet
    BEGIN        	
		    INSERT INTO TF_F_CARDEWALLETACC(
		        CARDNO                , CARDACCMONEY        , USETAG               , CREDITSTATECODE      ,
		        CREDITSTACHANGETIME   , CREDITCONTROLCODE   , CREDITCOLCHANGETIME  , ACCSTATECODE         ,
		        SUPPLYREALMONEY       , TOTALCONSUMETIMES   , TOTALSUPPLYTIMES     , TOTALCONSUMEMONEY    ,
		        TOTALSUPPLYMONEY      , FIRSTSUPPLYTIME     , LASTSUPPLYTIME       , OFFLINECARDTRADENO   ,
		        ONLINECARDTRADENO     , RSRV1               , RSRV2                , RSRV3                ,
		        REMARK
		   )SELECT
		        p_NEWCARDNO           , p_CARDACCMONEY      , '1'                   , t.CREDITSTATECODE   ,
		        t.CREDITSTACHANGETIME , t.CREDITCONTROLCODE , t.CREDITCOLCHANGETIME , '01'                ,
		        0                     , 0                   , 1                     , 0                   ,
		        p_TOTALSUPPLYMONEY    , t.FIRSTSUPPLYTIME   , t.LASTSUPPLYTIME      , '0000'              ,
		        p_CARDTRADENO         , t.RSRV1             , t.RSRV2               , t.RSRV3             , 
		        t.REMARK
		    FROM TF_F_CARDEWALLETACC t
		    WHERE CARDNO = p_OLDCARDNO;
		    
		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001004101';
	            p_retMsg  := 'Error occurred while insert a row of elec wallet' || SQLERRM;
	            RETURN;
    END;      
    
    -- 6) insert a row of cust info
    BEGIN
		    INSERT INTO TF_F_CUSTOMERREC(
		        CARDNO          , CUSTNAME    , CUSTSEX    , CUSTBIRTH     ,
		        PAPERTYPECODE   , PAPERNO     , CUSTADDR   , CUSTPOST      ,
		        CUSTPHONE       , CUSTEMAIL   , USETAG     , UPDATESTAFFNO ,
		        UPDATETIME      , REMARK
		   )VALUES(
		        p_NEWCARDNO     , p_CUSTNAME  , p_CUSTSEX  , p_CUSTBIRTH   ,
		        p_PAPERTYPECODE , p_PAPERNO   , p_CUSTADDR , p_CUSTPOST    ,
		        p_CUSTPHONE     , p_CUSTEMAIL , '1'        , p_currOper    ,
		        v_today         , p_REMARK
		        );

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001004104';
	            p_retMsg  := 'Error occurred while insert a row of cust info' || SQLERRM;
	            RETURN;
    END;                
		    
		-- 7) Get trade id
    SP_GetSeq(seq => v_TradeID); 
    p_TRADEID := v_TradeID;
		    
    -- 8) new card
    BEGIN
		    INSERT INTO TF_B_CUSTOMERCHANGE(
		        TRADEID        , CARDNO          , CUSTNAME      , CUSTSEX     ,
		        CUSTBIRTH      , PAPERTYPECODE   , PAPERNO       , CUSTADDR    ,
		        CUSTPOST       , CUSTPHONE       , CUSTEMAIL     , CHGTYPECODE ,
		        OPERATESTAFFNO , OPERATEDEPARTID , OPERATETIME
		   )VALUES(
		        v_TradeID      , p_NEWCARDNO     , p_CUSTNAME    , p_CUSTSEX   ,
		        p_CUSTBIRTH    , p_PAPERTYPECODE , p_PAPERNO     , p_CUSTADDR  ,
		        p_CUSTPOST     , p_CUSTPHONE     , p_CUSTEMAIL   , '00'        ,
		        p_currOper     , p_currDept      , v_today
		        ); 

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001004109';
	            p_retMsg  := 'Fail to log the operation of new card cust info change' || SQLERRM;
	            RETURN;
    END;
    
    -- 9) Log operation
    BEGIN
		    INSERT INTO TF_B_TRADE(
		        TRADEID         , ID             , TRADETYPECODE       , CARDNO         ,
		        ASN             , CARDTYPECODE   , CARDTRADENO         , REASONCODE     ,
		        OLDCARDNO       , DEPOSIT        , OLDCARDMONEY        , CURRENTMONEY   ,
		        OPERATESTAFFNO  , OPERATEDEPARTID, OPERATETIME         , CARDSTATE      , 
		        SERSTAKETAG     , TRADEORIGIN
		   )SELECT
		        v_TradeID       , p_ID           , p_TRADETYPECODE     , p_NEWCARDNO    ,
		        t.ASN           , t.CARDTYPECODE , p_CARDTRADENO       , p_CHANGECODE   ,
		        p_OLDCARDNO     , 0              , 0                   , p_CARDACCMONEY ,
		        p_currOper      , p_currDept     , v_today             , t.CARDSTATE    , 
		        t.SERSTAKETAG   , p_TRADEORIGIN
		    FROM TF_F_CARDREC t
		    WHERE CARDNO = p_OLDCARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001004108';
	            p_retMsg  := 'Fail to log the operation' || SQLERRM;
	            RETURN;
    END;    
    
  p_retCode := '0000000000';
	p_retMsg  := '';
	RETURN;
END;    		     

/
show errors         	