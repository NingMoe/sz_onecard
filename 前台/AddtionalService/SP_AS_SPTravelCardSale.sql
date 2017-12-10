/* ------------------------------------
Copyright (C) 2015-2016 linkage Software 
 All rights reserved.
<author>gl</author>
<createDate>2015-04-14</createDate>
<description>世乒卡开卡存储过程</description>
------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_AS_SPTravelCardSale
(
       p_ID            char,
       p_CARDNO        char,
       p_CARDCOST      int,      ---卡费
       p_CARDTRADENO   char,
       p_CUSTNAME      varchar2,
       p_CUSTSEX       varchar2,
       p_CUSTBIRTH     varchar2,
       p_PAPERTYPECODE varchar2,
       p_PAPERNO       varchar2,
       p_CUSTADDR      varchar2,
       p_CUSTPOST      varchar2,
       p_CUSTPHONE     varchar2,
       p_CUSTEMAIL     varchar2,
       p_REMARK        varchar2,
       p_OPERCARDNO    char,
       p_TRADEID       out char, -- Return Trade Id
       p_PACKAGETYPECODE  char,
	   p_WRITECARDSCRIPT  varchar2,
       p_currOper      char,
       p_currDept      char,
       p_retCode       out char, -- Return Code
       p_retMsg        out varchar2 -- Return Message
 ) AS
       v_TRADEID          char(16);
       v_CARDTYPECODE     char(2);
       v_CARDSURFACECODE  char(4);
       v_MANUTYPECODE     char(2);
       v_CARDCHIPTYPECODE char(2);
       v_APPTYPECODE      char(2);
       v_APPVERNO         char(2);
       v_PRESUPPLYMONEY   int;
       v_VALIDENDDATE     char(8);
       v_ASN              char(16);
       v_TRADETYPECODE    char(2);
       v_ex exception;
       v_CURRENTTIME DATE;
       v_FUNCFEE   int;      ---套餐费
BEGIN
  -- 1) Get system time
  v_CURRENTTIME   := sysdate;

  --- 2) Get TRADETYPECODE
  v_TRADETYPECODE := 'E1';

  ---3) Get PACKAGEFEE
  BEGIN
       SELECT PACKAGEFEE INTO v_FUNCFEE FROM TD_M_SPPACKAGETYPE WHERE PACKAGETYPECODE=p_PACKAGETYPECODE;
  END;

  -- 4) Update card resource statecode
  BEGIN
    UPDATE TL_R_ICUSER
       SET RESSTATECODE  = '06',
           SELLTIME      = v_CURRENTTIME,
           UPDATESTAFFNO = p_currOper,
           UPDATETIME    = v_CURRENTTIME
     WHERE CARDNO = p_CARDNO;

    IF SQL%ROWCOUNT != 1 THEN
      RAISE v_ex;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      p_retCode := 'S001001101';
      p_retMsg  := 'Error occurred while updating resource statecode' ||
                   SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 3) Get initialize info
  SELECT ASN,
         CARDTYPECODE,
         CARDSURFACECODE,
         MANUTYPECODE,
         CARDCHIPTYPECODE,
         APPTYPECODE,
         APPVERNO,
         PRESUPPLYMONEY,
         VALIDENDDATE
    INTO v_ASN,
         v_CARDTYPECODE,
         v_CARDSURFACECODE,
         v_MANUTYPECODE,
         v_CARDCHIPTYPECODE,
         v_APPTYPECODE,
         v_APPVERNO,
         v_PRESUPPLYMONEY,
         v_VALIDENDDATE
    FROM TL_R_ICUSER
   WHERE CARDNO = p_CARDNO;

  -- 4) Insert a row in CARDREC
  BEGIN
    INSERT INTO TF_F_CARDREC
      (CARDNO,
       ASN,
       CARDTYPECODE,
       CARDSURFACECODE,
       CARDMANUCODE,
       CARDCHIPTYPECODE,
       APPTYPECODE,
       APPVERNO,
       DEPOSIT,
       CARDCOST,
       PRESUPPLYMONEY,
       CUSTRECTYPECODE,
       SELLTIME,
       SELLCHANNELCODE,
       DEPARTNO,
       STAFFNO,
       CARDSTATE,
       VALIDENDDATE,
       USETAG,
       SERSTARTTIME,
       SERSTAKETAG,
       SERVICEMONEY,
       UPDATESTAFFNO,
       UPDATETIME)
    VALUES
      (p_CARDNO,
       v_ASN,
       v_CARDTYPECODE,
       v_CARDSURFACECODE,
       v_MANUTYPECODE,
       v_CARDCHIPTYPECODE,
       v_APPTYPECODE,
       v_APPVERNO,
       '0',
       p_CARDCOST,
       '0',
       '0',
       v_CURRENTTIME,
       '01',
       p_currDept,
       p_currOper,
       '10',
       v_VALIDENDDATE,
       '1',
       v_CURRENTTIME,
       '3',
       0,
       p_currOper,
       v_CURRENTTIME);

  EXCEPTION
    WHEN OTHERS THEN
      p_retCode := 'S001001102'; --'S001001102';
      p_retMsg  := 'Error occurred while insert a row in cardrec' ||
                   SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  --5) insert a row of elec wallet
  BEGIN
    INSERT INTO TF_F_CARDEWALLETACC
      (CARDNO,
       CARDACCMONEY,
       USETAG,
       CREDITSTATECODE,
       CREDITSTACHANGETIME,
       CREDITCONTROLCODE,
       CREDITCOLCHANGETIME,
       ACCSTATECODE,
       CONSUMEREALMONEY,
       SUPPLYREALMONEY,
       TOTALCONSUMETIMES,
       TOTALSUPPLYTIMES,
       TOTALCONSUMEMONEY,
       TOTALSUPPLYMONEY,
       OFFLINECARDTRADENO,
       ONLINECARDTRADENO)
    VALUES
      (p_CARDNO,
       '0',
       '1',
       '00',
       v_CURRENTTIME,
       '00',
       v_CURRENTTIME,
       '01',
       0,
       0,
       0,
       0,
       0,
       0,
       '0000',
       p_CARDTRADENO);

  EXCEPTION
    WHEN OTHERS THEN
      p_retCode := 'S001001103';
      p_retMsg  := 'Error occurred while insert a row of elec wallet' ||
                   SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  --6) insert a row of cust info
  BEGIN
    INSERT INTO TF_F_CUSTOMERREC
      (CARDNO,
       CUSTNAME,
       CUSTSEX,
       CUSTBIRTH,
       PAPERTYPECODE,
       PAPERNO,
       CUSTADDR,
       CUSTPOST,
       CUSTPHONE,
       CUSTEMAIL,
       USETAG,
       UPDATESTAFFNO,
       UPDATETIME,
       REMARK)
    VALUES
      (p_CARDNO,
       p_CUSTNAME,
       p_CUSTSEX,
       p_CUSTBIRTH,
       p_PAPERTYPECODE,
       p_PAPERNO,
       p_CUSTADDR,
       p_CUSTPOST,
       p_CUSTPHONE,
       p_CUSTEMAIL,
       '1',
       p_currOper,
       v_CURRENTTIME,
       p_REMARK);

  EXCEPTION
    WHEN OTHERS THEN
      p_retCode := 'S001001104';
      p_retMsg  := 'Error occurred while insert a row of cust info' ||
                   SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 7) Get trade id
  SP_GetSeq(seq => v_TradeID);
  p_TRADEID := v_TradeID;

  -- 8) Log operation
  BEGIN
    INSERT INTO TF_B_TRADE
      (TRADEID,
       ID,
       TRADETYPECODE,
       CARDNO,
       ASN,
       CARDTYPECODE,
       CARDTRADENO,
       CURRENTMONEY,
       PREMONEY,
       OPERATESTAFFNO,
       OPERATEDEPARTID,
       OPERATETIME)
    VALUES
      (v_TRADEID,
       p_ID,
       v_TRADETYPECODE,
       p_CARDNO,
       v_ASN,
       v_CARDTYPECODE,
       p_CARDTRADENO,
       0,
       0,
       p_currOper,
       p_currDept,
       v_CURRENTTIME);

  EXCEPTION
    WHEN OTHERS THEN
      p_retCode := 'S001001105';
      p_retMsg  := 'Fail to log the operation' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 9) Log the operation of cust info change
  BEGIN
    INSERT INTO TF_B_CUSTOMERCHANGE
      (TRADEID,
       CARDNO,
       CUSTNAME,
       CUSTSEX,
       CUSTBIRTH,
       PAPERTYPECODE,
       PAPERNO,
       CUSTADDR,
       CUSTPOST,
       CUSTPHONE,
       CUSTEMAIL,
       CHGTYPECODE,
       OPERATESTAFFNO,
       OPERATEDEPARTID,
       OPERATETIME)
    VALUES
      (v_TRADEID,
       p_CARDNO,
       p_CUSTNAME,
       p_CUSTSEX,
       p_CUSTBIRTH,
       p_PAPERTYPECODE,
       p_PAPERNO,
       p_CUSTADDR,
       p_CUSTPOST,
       p_CUSTPHONE,
       p_CUSTEMAIL,
       '00',
       p_currOper,
       p_currDept,
       v_CURRENTTIME);

  EXCEPTION
    WHEN OTHERS THEN
      p_retCode := 'S001001106';
      p_retMsg  := 'Fail to log the operation of cust info change' ||
                   SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 10) Log the cash
  BEGIN
    INSERT INTO TF_B_TRADEFEE
      (ID,
       TRADEID,
       TRADETYPECODE,
       CARDNO,
       CARDTRADENO,
       CARDSERVFEE,
       FUNCFEE,
       OPERATESTAFFNO,
       OPERATEDEPARTID,
       OPERATETIME)
    VALUES
      (p_ID,
       v_TRADEID,
       v_TRADETYPECODE,
       p_CARDNO,
       p_CARDTRADENO,
       p_CARDCOST,
       v_FUNCFEE,
       p_currOper,
       p_currDept,
       v_CURRENTTIME);

  EXCEPTION
    WHEN OTHERS THEN
      p_retCode := 'S001001107';
      p_retMsg  := 'Fail to log the cash' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  -- 11) Log the writeCard
  BEGIN
    INSERT INTO TF_CARD_TRADE
      (TRADEID,
       TRADETYPECODE,
       strOperCardNo,
       strCardNo,
       strTermno,
       OPERATETIME,
       SUCTAG,
			 WRITECARDSCRIPT)
    VALUES
      (v_TRADEID,
       v_TRADETYPECODE,
       p_OPERCARDNO,
       p_CARDNO,
       '112233445566',
       v_CURRENTTIME,
       '0',
		p_WRITECARDSCRIPT);

  EXCEPTION
    WHEN OTHERS THEN
      p_retCode := 'S001001108';
      p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
      ROLLBACK;
      RETURN;
  END;

  --- 12) 插入关联表
  BEGIN
    INSERT　INTO TF_F_SPPACKAGETYPEATION(PACKAGETYPECODE,CARDNO,ENDDATE,TRADEID,UPDATESTAFFNO,UPDATEDEPARTID,UPDATETIME)
    SELECT p_PACKAGETYPECODE,p_CARDNO,ENDDATE,v_TRADEID,p_currOper,p_currDept,v_CURRENTTIME
    FROM TD_M_SPPACKAGETYPE t WHERE t.PACKAGETYPECODE=p_PACKAGETYPECODE;
  exception
    when others then
      p_retCode := 'S001001109';
     p_retMsg  := 'Fail to log the packagetypealion' || SQLERRM;
      ROLLBACK;
      RETURN;
  end;

  p_retCode := '0000000000';
  p_retMsg  := '';
  RETURN;
END;
/
show errors