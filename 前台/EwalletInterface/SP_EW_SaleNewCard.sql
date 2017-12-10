CREATE OR REPLACE PROCEDURE SP_EW_SaleNewCard
(
		p_ID	            char,     --记录流水号
		p_CARDNO	        char,     --卡号
		p_CARDCOST	      int,      --卡费
		p_CARDTRADENO	    char,     --联机交易序号
		p_CARDMONEY	      int,      --卡内余额
		p_SELLCHANNELCODE	char,     --售卡渠道编码
		p_CUSTNAME	      varchar2, --用户姓名
		p_CUSTSEX	        varchar2, --用户性别
		p_CUSTBIRTH	      varchar2, --出生日期
		p_PAPERTYPECODE	  varchar2, --证件类型
		p_PAPERNO        	varchar2, --证件号码	
		p_CUSTADDR	      varchar2, --联系地址
		p_CUSTPOST	      varchar2, --邮政编码
		p_CUSTPHONE	      varchar2, --联系电话
		p_CUSTEMAIL       varchar2, --电子邮件
		p_REMARK	        varchar2, --备注
		p_TRADEORIGIN     varchar2, --业务来源
		p_currOper	      char,
		p_currDept	      char,
		p_TRADEID         out char, -- Return Trade Id
		p_retCode	        out char, -- Return Code
		p_retMsg     	    out varchar2  -- Return Message
)
AS
    v_today            DATE := sysdate;
    v_TradeID          char(16);
    v_CARDSURFACECODE  char(4);
    v_MANUTYPECODE     char(2);
    v_CARDCHIPTYPECODE char(2);
    v_APPTYPECODE      char(2);
    v_APPVERNO         char(2);
    v_PRESUPPLYMONEY   int;
    v_VALIDENDDATE     char(8);
    v_ASN	             char(16);
    v_CARDTYPECODE	   char(2);
    v_ex          exception;
BEGIN    
    -- 1) Update card resource statecode
    BEGIN
		    UPDATE TL_R_ICUSER        
		    SET    RESSTATECODE  = '06',
		           SELLTIME      = v_today,     
		           UPDATESTAFFNO = p_currOper,      
		           UPDATETIME    = v_today      
		    WHERE  CARDNO        = p_CARDNO
		    AND    RESSTATECODE  = '01';

		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001105';
	            p_retMsg  := 'Error occurred while updating resource statecode' || SQLERRM;
	            RETURN;
    END;    
    
    -- 2) Get initialize info    
    SELECT 
          ASN        , CARDSURFACECODE   , MANUTYPECODE   , CARDCHIPTYPECODE   , APPTYPECODE   ,
          APPVERNO   , PRESUPPLYMONEY    , VALIDENDDATE   , CARDTYPECODE
    INTO  v_ASN      , v_CARDSURFACECODE , v_MANUTYPECODE , v_CARDCHIPTYPECODE , v_APPTYPECODE ,
          v_APPVERNO , v_PRESUPPLYMONEY  , v_VALIDENDDATE , v_CARDTYPECODE
    FROM  TL_R_ICUSER       
    WHERE CARDNO = p_CARDNO;    
    
    -- 3) Insert a row in CARDREC
    BEGIN
		    INSERT INTO TF_F_CARDREC(
		        CARDNO        , ASN               , CARDTYPECODE   , CARDSURFACECODE  ,
		        CARDMANUCODE  , CARDCHIPTYPECODE  , APPTYPECODE    , APPVERNO         ,
		        DEPOSIT       , CARDCOST          , PRESUPPLYMONEY , CUSTRECTYPECODE  ,
		        SELLTIME      , SELLCHANNELCODE   , DEPARTNO       , STAFFNO          ,
		        CARDSTATE     , VALIDENDDATE      , USETAG         , SERSTARTTIME     ,
		        SERSTAKETAG   , SERVICEMONEY      , UPDATESTAFFNO  , UPDATETIME
		   )VALUES(  
		        p_CARDNO      , v_ASN             , v_CARDTYPECODE   , v_CARDSURFACECODE ,
		        v_MANUTYPECODE, v_CARDCHIPTYPECODE, v_APPTYPECODE    , v_APPVERNO        ,      
		        0             , p_CARDCOST        , v_PRESUPPLYMONEY , '1'               ,
		        v_today       , p_SELLCHANNELCODE , p_currDept       , p_currOper        ,
		        '10'          , v_VALIDENDDATE    , '1'              , v_today           ,
		        '0'           , 0                 , p_currOper       , v_today
		        );
		        
		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001102';
	            p_retMsg  := 'Error occurred while insert a row in cardrec' || SQLERRM;
	            RETURN;
    END;
    
    --4) insert a row of elec wallet
    BEGIN
		    INSERT INTO TF_F_CARDEWALLETACC(
		        CARDNO              , CARDACCMONEY      , USETAG              , CREDITSTATECODE  ,
		        CREDITSTACHANGETIME , CREDITCONTROLCODE , CREDITCOLCHANGETIME , ACCSTATECODE     ,
		        CONSUMEREALMONEY    , SUPPLYREALMONEY   , TOTALCONSUMETIMES   , TOTALSUPPLYTIMES ,
		        TOTALCONSUMEMONEY   , TOTALSUPPLYMONEY  , OFFLINECARDTRADENO  , ONLINECARDTRADENO
		   )VALUES(
		        p_CARDNO            , p_CARDMONEY       , '1'                 , '00'             ,
		        v_today             , '00'              , v_today             , '01'             ,
		        0                   , 0                 , 0                   , 0                ,
		        0                   , 0                 , '0000'              , p_CARDTRADENO
		        );
		        
		    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001106';
	            p_retMsg  := 'Error occurred while insert a row of elec wallet' || SQLERRM;
	            RETURN;
    END;    
    
    --5) insert a row of cust info
    BEGIN
		    INSERT INTO TF_F_CUSTOMERREC(
		        CARDNO          , CUSTNAME    , CUSTSEX    , CUSTBIRTH     ,
		        PAPERTYPECODE   , PAPERNO     , CUSTADDR   , CUSTPOST      ,
		        CUSTPHONE       , CUSTEMAIL   , USETAG     , UPDATESTAFFNO ,
		        UPDATETIME      , REMARK
		   )VALUES(
		        p_CARDNO        , p_CUSTNAME  , p_CUSTSEX  , p_CUSTBIRTH   ,
		        p_PAPERTYPECODE , p_PAPERNO   , p_CUSTADDR , p_CUSTPOST    , 
		        p_CUSTPHONE     , p_CUSTEMAIL , '1'        , p_currOper    ,
		        v_today         , p_REMARK
		        );
		        
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001103';
	            p_retMsg  := 'Error occurred while insert a row of cust info' || SQLERRM;
	            RETURN;
    END;    
    
    -- 6) Get trade id
    SP_GetSeq(seq => v_TradeID); 
    p_TRADEID := v_TradeID;
    
    -- 7) Log operation
    BEGIN
		    INSERT INTO TF_B_TRADE(
		        TRADEID     , ID              , TRADETYPECODE     , CARDNO        ,
		        ASN         , CARDTYPECODE    , CARDTRADENO       , CURRENTMONEY  ,
		        PREMONEY    , OPERATESTAFFNO  , OPERATEDEPARTID   , OPERATETIME   ,
		        TRADEORIGIN
		   )VALUES(
		        v_TradeID   , p_ID            , '01'              , p_CARDNO      ,
		        v_ASN       , v_CARDTYPECODE  , p_CARDTRADENO     , p_CARDCOST    ,
		        p_CARDMONEY , p_currOper      , p_currDept        , v_today       ,
		        p_TRADEORIGIN
		        );
		        
       IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001107';
	            p_retMsg  := 'Fail to log the operation' || SQLERRM;
	            RETURN;
    END;
    
    -- 8) Log the operation of cust info change
    BEGIN
		    INSERT INTO TF_B_CUSTOMERCHANGE(
		        TRADEID         , CARDNO          , CUSTNAME    , CUSTSEX      ,
		        CUSTBIRTH       , PAPERTYPECODE   , PAPERNO     , CUSTADDR     ,
		        CUSTPOST        , CUSTPHONE       , CUSTEMAIL   , CHGTYPECODE  ,
		        OPERATESTAFFNO  , OPERATEDEPARTID , OPERATETIME
		   )VALUES(
		        v_TradeID       , p_CARDNO        , p_CUSTNAME  , p_CUSTSEX    ,
		        p_CUSTBIRTH     , p_PAPERTYPECODE , p_PAPERNO   , p_CUSTADDR   ,
		        p_CUSTPOST      , p_CUSTPHONE     , p_CUSTEMAIL , '00'         ,
		        p_currOper      , p_currDept      , v_today
		        );
		        
       IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
		EXCEPTION
	        WHEN OTHERS THEN
	            p_retCode := 'S001001108';
	            p_retMsg  := 'Fail to log the operation of cust info change' || SQLERRM;
	            RETURN;
    END;     
          
    
  p_retCode := '0000000000';
	p_retMsg  := '';
  RETURN;
END;

/

show errors    