/* ------------------------------------
Copyright (C) 2015-2016 linkage Software 
 All rights reserved.
<author>gl</author>
<createDate>2015-04-14</createDate>
<description>世乒卡换卡存储过程</description>
------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_AS_SPTRAVELCHANGECARD
(
    p_ID                  char,
    p_CUSTRECTYPECODE     char,
    p_CARDCOST            int,
    p_NEWCARDNO           char,
    p_OLDCARDNO           char,
    p_ONLINECARDTRADENO   char,
    p_CHECKSTAFFNO        char,
    p_CHECKDEPARTNO       char,
    p_CHANGECODE          char,
    p_ASN                 char,
    p_CARDTYPECODE        char,
    p_SELLCHANNELCODE     char,
    p_TRADETYPECODE       char,
    p_DEPOSIT             int,
    p_SERSTARTTIME        date,
    p_SERVICEMONE         int,
    p_CARDACCMONEY        int,
    p_NEWSERSTAKETAG      char,
    p_SUPPLYREALMONEY     int,
    p_TOTALSUPPLYMONEY    int,
    p_OLDDEPOSIT          int,
    p_SERSTAKETAG         char,
    p_PREMONEY            int,
    p_NEXTMONEY           int,
    p_CURRENTMONEY        int,
    p_TERMNO              char,
    p_OPERCARDNO          char,
    p_CURRENTTIME     out date, -- Return Operate Time
    p_TRADEID         out char, -- Return Trade Id
    p_TRADEID2        out char,
	p_WRITECARDSCRIPT     varchar2,
    p_currOper            char,
    p_currDept            char,
    p_retCode         out char, -- Return Code
    p_retMsg          out varchar2  -- Return Message
)
AS
    v_TradeID char(16);
    v_CARDSURFACECODE     char(4);
    v_MANUTYPECODE        char(2);
    v_CARDCHIPTYPECODE    char(2);
    v_APPTYPECODE         char(2);
    v_APPVERNO            char(2);
    v_PRESUPPLYMONEY      int;
    v_VALIDENDDATE        char(8);
    v_CREDITSTATECODE     char(2);
    v_CREDITSTACHANGETIME DATE;
    v_CREDITCONTROLCODE   char(2);
    v_CREDITCOLCHANGETIME DATE;
    v_RSRV1               varchar2(20);
    v_RSRV2               varchar2(20);
    v_RSRV3               DATE;
    v_REMARK              varchar2(100);
    v_FIRSTSUPPLYTIME     DATE;
    v_LASTSUPPLYTIME      DATE;
    v_CUSTNAME            varchar2(200);
    v_CUSTSEX             varchar2(2);
    v_CUSTBIRTH           varchar2(8);
    v_PAPERTYPECODE       varchar2(2);
    v_PAPERNO             varchar2(200);
    v_CUSTADDR            varchar2(600);
    v_CUSTPOST            varchar2(6);
    v_CUSTPHONE           varchar2(200);
    v_CUSTEMAIL           varchar2(30);
    v_TRADEID_1           char(16);
    v_USETAG              char(1);
    v_ex                  exception;
    v_NSALETYPE           varchar2(2); --新卡售卡方式
    v_OSALETYPE           varchar2(2); --旧卡售卡方式
    v_ODEPOSIT            int;         --旧卡押金
    v_OCARDCOST           int;         --旧卡卡费
    v_PAYMONEY            int;         --支付金额
    v_MONEY               int := 0;    --未支付金额
  v_DEPOSIT        INT;       --新卡押金
  v_CARDCOST        INT;       --新卡卡费
BEGIN
    -- 1) Get system time
    p_CURRENTTIME := sysdate;

    -- 2) Update new card's resource statecode
    BEGIN
        UPDATE TL_R_ICUSER
        SET    RESSTATECODE  = '06',
               SELLTIME      = p_CURRENTTIME,
               UPDATESTAFFNO = p_currOper,
               UPDATETIME    = p_CURRENTTIME
        WHERE  CARDNO = p_NEWCARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S001004105';
            p_retMsg  := 'Error occurred while updating resource statecode of new card' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    -- 3) Update old card's resource statecode
    BEGIN
        UPDATE TL_R_ICUSER
        SET    DESTROYTIME   = p_CURRENTTIME,
               RESSTATECODE  = '03',
               UPDATESTAFFNO = p_currOper,
               UPDATETIME    = p_CURRENTTIME
        WHERE  CARDNO = p_OLDCARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S001004106';
            p_retMsg  := 'Error occurred while updating resource statecode of old card' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    -- 4) Get initialize info
    SELECT
         CARDSURFACECODE   , MANUTYPECODE     , CARDCHIPTYPECODE   , APPTYPECODE,
         APPVERNO          , PRESUPPLYMONEY   , VALIDENDDATE
    INTO
         v_CARDSURFACECODE , v_MANUTYPECODE   , v_CARDCHIPTYPECODE , v_APPTYPECODE,
         v_APPVERNO        , v_PRESUPPLYMONEY , v_VALIDENDDATE
    FROM TL_R_ICUSER
    WHERE CARDNO = p_NEWCARDNO;

    -- 5) Insert a row in CARDREC
 BEGIN
        INSERT INTO TF_F_CARDREC
            (CARDNO,ASN,CARDTYPECODE,CARDSURFACECODE,CARDMANUCODE,CARDCHIPTYPECODE,APPTYPECODE,APPVERNO,
            DEPOSIT,CARDCOST,PRESUPPLYMONEY,CUSTRECTYPECODE,SELLTIME,SELLCHANNELCODE,DEPARTNO,STAFFNO,
            CARDSTATE,VALIDENDDATE,USETAG,SERSTARTTIME,SERSTAKETAG,SERVICEMONEY,UPDATESTAFFNO,UPDATETIME)
        VALUES
            (p_NEWCARDNO,p_ASN,p_CARDTYPECODE,v_CARDSURFACECODE,v_MANUTYPECODE,v_CARDCHIPTYPECODE,
            v_APPTYPECODE,v_APPVERNO,p_DEPOSIT,p_CARDCOST,v_PRESUPPLYMONEY,p_CUSTRECTYPECODE,
            p_CURRENTTIME,p_SELLCHANNELCODE,p_currDept,p_currOper,'11',v_VALIDENDDATE,
            '1',p_SERSTARTTIME,p_NEWSERSTAKETAG,p_SERVICEMONE,p_currOper,p_CURRENTTIME);

        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001004100';
                p_retMsg  := 'Error occurred while insert a row in cardrec' || SQLERRM;
                ROLLBACK; RETURN;
    END;


    -- 6) Get old card's info
    SELECT
         CREDITSTATECODE,CREDITSTACHANGETIME,CREDITCONTROLCODE,CREDITCOLCHANGETIME,
         FIRSTSUPPLYTIME,LASTSUPPLYTIME,RSRV1,RSRV2,RSRV3,REMARK
    INTO v_CREDITSTATECODE,v_CREDITSTACHANGETIME,
             v_CREDITCONTROLCODE,v_CREDITCOLCHANGETIME,
             v_FIRSTSUPPLYTIME,v_LASTSUPPLYTIME,
             v_RSRV1,v_RSRV2,
             v_RSRV3,v_REMARK
    FROM TF_F_CARDEWALLETACC
    WHERE CARDNO = p_OLDCARDNO;

    -- 7) insert a row of elec wallet
    BEGIN
        INSERT INTO TF_F_CARDEWALLETACC
            (CARDNO,CARDACCMONEY,USETAG,CREDITSTATECODE,CREDITSTACHANGETIME,CREDITCONTROLCODE,
            CREDITCOLCHANGETIME,ACCSTATECODE,SUPPLYREALMONEY,TOTALCONSUMETIMES,TOTALSUPPLYTIMES,
            TOTALCONSUMEMONEY,TOTALSUPPLYMONEY,FIRSTSUPPLYTIME,LASTSUPPLYTIME,OFFLINECARDTRADENO,
            ONLINECARDTRADENO,RSRV1,RSRV2,RSRV3,REMARK)
        VALUES
            (p_NEWCARDNO,p_CARDACCMONEY,'1',v_CREDITSTATECODE,v_CREDITSTACHANGETIME,v_CREDITCONTROLCODE,
            v_CREDITCOLCHANGETIME,'01',p_SUPPLYREALMONEY,0,1,0,p_TOTALSUPPLYMONEY,
            v_FIRSTSUPPLYTIME,v_LASTSUPPLYTIME,'0000',p_ONLINECARDTRADENO,v_RSRV1,v_RSRV2,v_RSRV3,v_REMARK);

    EXCEPTION
        WHEN OTHERS THEN
        p_retCode := 'S001004101';
        p_retMsg  := 'Error occurred while insert a row of elec wallet' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    -- 8) Update old card's wallet usetag
    BEGIN
        UPDATE TF_F_CARDEWALLETACC
        SET  USETAG = '0'
        WHERE  CARDNO = p_OLDCARDNO;

    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S001004102';
            p_retMsg  := 'Error occurred while Updating wallet usetag of old card' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    -- 9) Get old card's cust info
    SELECT
         CUSTNAME    , CUSTSEX    , CUSTBIRTH   , PAPERTYPECODE   ,
         PAPERNO     , CUSTADDR   , CUSTPOST    , CUSTPHONE       ,
         CUSTEMAIL   , USETAG
    INTO v_CUSTNAME  , v_CUSTSEX  , v_CUSTBIRTH , v_PAPERTYPECODE ,
         v_PAPERNO   , v_CUSTADDR , v_CUSTPOST  , v_CUSTPHONE     ,
         v_CUSTEMAIL , v_USETAG
    FROM TF_F_CUSTOMERREC
    WHERE CARDNO = p_OLDCARDNO;

    -- 10) insert a row of cust info
    BEGIN
        INSERT INTO TF_F_CUSTOMERREC(
            CARDNO          , CUSTNAME    , CUSTSEX    , CUSTBIRTH     ,
            PAPERTYPECODE   , PAPERNO     , CUSTADDR   , CUSTPOST      ,
            CUSTPHONE       , CUSTEMAIL   , USETAG     , UPDATESTAFFNO ,
            UPDATETIME
       )VALUES(
            p_NEWCARDNO     , v_CUSTNAME  , v_CUSTSEX  , v_CUSTBIRTH ,
            v_PAPERTYPECODE , v_PAPERNO   , v_CUSTADDR , v_CUSTPOST  ,
            v_CUSTPHONE     , v_CUSTEMAIL , v_USETAG   , p_currOper  ,
            p_CURRENTTIME);

    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S001004104';
            p_retMsg  := 'Error occurred while insert a row of cust info' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    -- 11) update old card's cust info
    BEGIN
        UPDATE TF_F_CUSTOMERREC
        SET  USETAG = '0'
        WHERE  CARDNO = p_OLDCARDNO;

    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S001004129';
            p_retMsg  := 'Error occurred while updating cust info of old card' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    -- 12) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;

   --不可读卡
  IF p_TRADETYPECODE = 'E3' AND (p_CHANGECODE = '13' OR p_CHANGECODE = '15')  THEN
        BEGIN
          --获取旧卡售卡方式
          SELECT SALETYPE INTO  v_OSALETYPE
          FROM   TL_R_ICUSER
          WHERE  CARDNO = p_OLDCARDNO;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_retCode := 'S094570035';
          p_retMsg  := '没有查询出旧卡售卡方式';
          ROLLBACK; RETURN;
        END;

        BEGIN
          --获取新卡售卡方式
          SELECT SALETYPE INTO  v_NSALETYPE
          FROM   TL_R_ICUSER
          WHERE  CARDNO = p_NEWCARDNO;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_retCode := 'S094570036';
          p_retMsg  := '没有查询出新卡售卡方式';
          ROLLBACK; RETURN;
        END;
        --如果旧卡或新卡的售卡方式既不是卡费也不是押金则提示错误
        IF (v_OSALETYPE <> '01' AND v_OSALETYPE <> '02') OR (v_NSALETYPE <> '01' AND v_NSALETYPE <> '02') THEN
          p_retCode := 'S094570037';
          p_retMsg  := '售卡方式不为押金也不为售卡';
          ROLLBACK; RETURN;
        END IF;
        --旧卡售卡方式为卡费，新卡售卡方式为押金
        IF v_OSALETYPE = '01' AND v_NSALETYPE = '02' THEN
          p_retCode := 'S094570038';
          p_retMsg  := '旧卡售卡方式为卡费，不能换卡成押金方式';
          ROLLBACK; RETURN;
        END IF;
         --旧卡售卡方式为卡费，新卡售卡方式为卡费
        IF v_OSALETYPE = '01' AND v_NSALETYPE = '01' THEN
           SELECT CARDCOST INTO v_OCARDCOST
           FROM TF_F_CARDREC
           WHERE CARDNO = p_OLDCARDNO;

           IF p_CARDCOST - v_OCARDCOST > 0 THEN
                v_PAYMONEY := p_CARDCOST - v_OCARDCOST ;
           ELSE
              v_MONEY    := v_OCARDCOST;
              v_PAYMONEY := 0;
           END IF;

           BEGIN
              INSERT INTO TF_B_TRADEFEE(
                 ID                  , TRADEID        , TRADETYPECODE   , CARDNO          ,
                 CARDTRADENO         , CARDDEPOSITFEE , OPERATESTAFFNO  , OPERATEDEPARTID ,
                 OPERATETIME         , CARDSERVFEE
              )VALUES(
                 p_ID                , v_TradeID      , p_TRADETYPECODE , p_NEWCARDNO     ,
                 p_ONLINECARDTRADENO , p_DEPOSIT      , p_currOper      , p_currDept      ,
                 p_CURRENTTIME       , v_PAYMONEY
              );

              EXCEPTION
                WHEN OTHERS THEN
                  p_retCode := 'S094570041';
                  p_retMsg  := '记录现金台账表失败' || SQLERRM;
                  ROLLBACK; RETURN;
            END;
        END IF;
  END IF;

    -- 13) Log operation
    BEGIN
        INSERT INTO TF_B_TRADE(
            TRADEID         , ID             , TRADETYPECODE       , CARDNO        ,
            ASN             , CARDTYPECODE   , CARDTRADENO         , REASONCODE    ,
            OLDCARDNO       , DEPOSIT        , OLDCARDMONEY        , CURRENTMONEY  ,
            OPERATESTAFFNO  , OPERATEDEPARTID, OPERATETIME         , CHECKSTAFFNO  ,
            CHECKDEPARTNO   , CHECKTIME      , CARDSTATE           , SERSTAKETAG   ,
            RSRV1
       )SELECT
            v_TradeID       , p_ID           , p_TRADETYPECODE     , p_NEWCARDNO    ,
            p_ASN           , p_CARDTYPECODE , p_ONLINECARDTRADENO , p_CHANGECODE   ,
            p_OLDCARDNO     , p_OLDDEPOSIT   , p_SUPPLYREALMONEY   , p_CARDACCMONEY ,
            p_currOper      , p_currDept     , p_CURRENTTIME       , p_CHECKSTAFFNO ,
            p_CHECKDEPARTNO , p_CURRENTTIME  , CARDSTATE           , SERSTAKETAG    ,
            v_MONEY
        FROM TF_F_CARDREC
        WHERE CARDNO = p_OLDCARDNO;

    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S001004108';
            p_retMsg  := 'Fail to log the operation' || SQLERRM;
            ROLLBACK; RETURN;
    END;

        -- 14) Update old card's info
        BEGIN
            UPDATE TF_F_CARDREC
            SET    CARDSTATE     = '22',
                   USETAG        = '0' ,
                   SERSTAKETAG   = p_SERSTAKETAG,
                   UPDATESTAFFNO = p_currOper,
                   UPDATETIME    = p_CURRENTTIME,
                   RSRV1         = p_NEWCARDNO
            WHERE  CARDNO        = p_OLDCARDNO
            AND    USETAG        = '1';

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION
                  WHEN OTHERS THEN
                      p_retCode := 'S001004103';
                      p_retMsg  := 'Error occurred while updating rec info of old card' || SQLERRM;
                  ROLLBACK; RETURN;
        END;

    -- 15) Log the operation of cust info change
    BEGIN
        INSERT INTO TF_B_CUSTOMERCHANGE(
            TRADEID         , CARDNO      , CHGTYPECODE , OPERATESTAFFNO  ,
            OPERATEDEPARTID , OPERATETIME
       )VALUES(
            v_TradeID       , p_OLDCARDNO , '11'        , p_currOper      ,
            p_currDept      , p_CURRENTTIME );

    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S001004131';
            p_retMsg  := 'Fail to log the operation of cust info change' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    -- 16) new card
    BEGIN
        INSERT INTO TF_B_CUSTOMERCHANGE(
            TRADEID        , CARDNO          , CUSTNAME     , CUSTSEX     ,
            CUSTBIRTH      , PAPERTYPECODE   , PAPERNO      , CUSTADDR    ,
            CUSTPOST       , CUSTPHONE       , CUSTEMAIL    , CHGTYPECODE ,
            OPERATESTAFFNO , OPERATEDEPARTID , OPERATETIME
       )VALUES(
            v_TradeID      , p_NEWCARDNO     , v_CUSTNAME   , v_CUSTSEX   ,
            v_CUSTBIRTH    , v_PAPERTYPECODE , v_PAPERNO    , v_CUSTADDR  ,
            v_CUSTPOST     , v_CUSTPHONE     , v_CUSTEMAIL  , '00'        ,
            p_currOper     , p_currDept      , p_CURRENTTIME );

    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S001004109';
            p_retMsg  := 'Fail to log the operation of new card cust info change' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    -- 17) Get trade id
    SP_GetSeq(seq => v_TRADEID_1);
    p_TRADEID2 := v_TradeID_1;

    -- 18) Log the cash
  IF p_TRADETYPECODE = 'E3' AND (p_CHANGECODE = '12' OR p_CHANGECODE = '14')  THEN

        BEGIN
          --获取旧卡售卡方式
          SELECT SALETYPE INTO  v_OSALETYPE
          FROM   TL_R_ICUSER
          WHERE  CARDNO = p_OLDCARDNO;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_retCode := 'S094570035';
          p_retMsg  := '没有查询出旧卡售卡方式';
          ROLLBACK; RETURN;
        END;

        BEGIN
          --获取新卡售卡方式
          SELECT SALETYPE INTO  v_NSALETYPE
          FROM   TL_R_ICUSER
          WHERE  CARDNO = p_NEWCARDNO;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          p_retCode := 'S094570036';
          p_retMsg  := '没有查询出新卡售卡方式';
          ROLLBACK; RETURN;
        END;
        --如果旧卡或新卡的售卡方式既不是卡费也不是押金则提示错误
        IF (v_OSALETYPE <> '01' AND v_OSALETYPE <> '02') OR (v_NSALETYPE <> '01' AND v_NSALETYPE <> '02') THEN
          p_retCode := 'S094570037';
          p_retMsg  := '售卡方式不为押金也不为售卡';
          ROLLBACK; RETURN;
        END IF;
        --旧卡售卡方式为卡费，新卡售卡方式为押金
        IF v_OSALETYPE = '01' AND v_NSALETYPE = '02' THEN
          p_retCode := 'S094570038';
          p_retMsg  := '旧卡售卡方式为卡费，不能换卡成押金方式';
          ROLLBACK; RETURN;
        END IF;

        BEGIN
            INSERT INTO TF_B_TRADEFEE(
             ID                  , TRADEID     , TRADETYPECODE   , CARDNO         ,
             CARDTRADENO         , CARDSERVFEE , CARDDEPOSITFEE  , OPERATESTAFFNO ,
             OPERATEDEPARTID     , OPERATETIME
            )VALUES(
             p_ID                , v_TradeID   , p_TRADETYPECODE , p_NEWCARDNO    ,
             p_ONLINECARDTRADENO , p_CARDCOST  , p_DEPOSIT       , p_currOper     ,
             p_currDept          , p_CURRENTTIME);

              EXCEPTION
                 WHEN OTHERS THEN
                        p_retCode := 'S001004112';
                        p_retMsg  := 'Fail to log the cash' || SQLERRM;
                        ROLLBACK; RETURN;
         END;
    
  END IF;

    -- 19) Log trans operation
    IF p_CHANGECODE = '12' OR p_CHANGECODE = '13' THEN
        BEGIN
            INSERT INTO TF_B_TRADE(
                TRADEID     , ID                , TRADETYPECODE       , CARDNO      ,
                ASN         , CARDTYPECODE      , CARDTRADENO         , REASONCODE  ,
                OLDCARDNO   , OLDCARDMONEY      , CURRENTMONEY        , PREMONEY    ,
                NEXTMONEY   , OPERATESTAFFNO    , OPERATEDEPARTID     , OPERATETIME
           )VALUES(
                v_TRADEID_1 , p_ID              , '04'                , p_NEWCARDNO  ,
                p_ASN       , p_CARDTYPECODE    , p_ONLINECARDTRADENO , p_CHANGECODE ,
                p_OLDCARDNO , p_SUPPLYREALMONEY , p_CURRENTMONEY      , p_PREMONEY   ,
                p_NEXTMONEY , p_currOper        , p_currDept          , p_CURRENTTIME);

        EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001004110';
                p_retMsg  := 'Fail to log trans operation' || SQLERRM;
                ROLLBACK; RETURN;
        END;
    END IF;

    -- 20) Update card state
    IF p_CHANGECODE = '12' OR p_CHANGECODE = '13' THEN
        BEGIN
            UPDATE TF_F_CARDREC
            SET    CARDSTATE = '02'
            WHERE  CARDNO = p_OLDCARDNO;

            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION
              WHEN OTHERS THEN
                  p_retCode := 'S001004103';
                  p_retMsg  := 'Error occurred while updating rec info of old card' || SQLERRM;
              ROLLBACK; RETURN;
        END;
    END IF;



    -- 21) Log the writeCard
    BEGIN
        INSERT INTO TF_CARD_TRADE(
            TRADEID       , TRADETYPECODE   , strOperCardNo     , cardtradeno        ,
            strCardNo     , lMoney          , lOldMoney         , strTermno          ,
            OPERATETIME   , SUCTAG          , WRITECARDSCRIPT
       )VALUES(
            v_TradeID     , p_TRADETYPECODE , p_OPERCARDNO      , p_ONLINECARDTRADENO ,
            p_NEWCARDNO   , p_CURRENTMONEY  , p_SUPPLYREALMONEY , p_TERMNO            ,
            p_CURRENTTIME , '0'             , p_WRITECARDSCRIPT);

    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S001001139';
            p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
            ROLLBACK; RETURN;
    END;
		
		---22) 更新套餐关联表
  BEGIN
	   UPDATE TF_F_SPPACKAGETYPEATION SET CARDNO=p_NEWCARDNO where CARDNO=p_OLDCARDNO;
    EXCEPTION
        WHEN OTHERS THEN
				p_retCode := 'S001001109';
			  p_retMsg  := 'Fail to log the packagetypealion' || SQLERRM;
				ROLLBACK;
				RETURN;
  END;

  p_retCode := '0000000000';
    p_retMsg  := '';
    commit;RETURN;
END;
/
show errors