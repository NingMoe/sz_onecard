/* ------------------------------------
Copyright (C) 2015-2016 linkage Software 
 All rights reserved.
<author>gl</author>
<createDate>2015-04-14</createDate>
<description>世乒卡售卡返销存储过程</description>
------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_AS_SPTravelCardSaleRollback
(
    p_ID              char,
    p_CARDNO        char,
    p_CARDTRADENO     char,
    p_CARDSERVFEE         int,--卡费
    p_FUNCFEE       int,      ---套餐费
    p_CANCELTRADEID   char,
    p_TERMNO      char,
    p_OPERCARDNO    char,
    p_currOper        char,
    p_currDept        char,
    p_retCode          out char, -- Return Code
    p_retMsg           out varchar2  -- Return Message

)
AS
    v_TRADETYPECODE  char(2);
    v_TradeID char(16);
    v_CURRENTTIME   date := sysdate;
    v_ex            exception;          
BEGIN
    -- 1) update resstate
    BEGIN
        UPDATE TL_R_ICUSER
        SET RESSTATECODE = '05',
            SELLTIME = null,
            UPDATESTAFFNO = p_currOper,
            UPDATETIME = v_CURRENTTIME
        WHERE CARDNO = p_CARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001001105';
              p_retMsg  := 'Fail to update resstatecode' || SQLERRM;
              ROLLBACK; RETURN;
    END;


    -- 2) Get trade id
    SP_GetSeq(seq => v_TradeID);

    -- 3) Select tradetypecode
    BEGIN
        SELECT b.CANCELCODE INTO v_TRADETYPECODE
        FROM TF_B_TRADE a,TD_M_TRADETYPE b
        WHERE a.TRADEID = p_CANCELTRADEID AND b.TRADETYPECODE = a.TRADETYPECODE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_retCode := 'A001020101';
            p_retMsg  := 'Can not find psam,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    -- 4)update salerecord
    BEGIN
      UPDATE TF_B_TRADE
      SET CANCELTAG  = '1',
      CANCELTRADEID = v_TradeID
      WHERE TRADEID = p_CANCELTRADEID;

            IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001020102';
              p_retMsg  := 'Fail to update salerecord' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 5)log the tradefee
    BEGIN
        INSERT INTO TF_B_TRADEFEE
               (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,CARDSERVFEE,FUNCFEE,
               OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
           SELECT
                 p_ID,v_TradeID,v_TRADETYPECODE,CARDNO,p_CARDTRADENO,p_CARDSERVFEE,p_FUNCFEE,
                 p_currOper,p_currDept,v_CURRENTTIME
           FROM TF_F_CARDREC
           WHERE CARDNO = p_CARDNO;

    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001020103';
              p_retMsg  := 'Fail to log the tradefee' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 6)log the operation
    BEGIN
        INSERT INTO TF_B_TRADE
               (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,CURRENTMONEY,
               OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,CANCELTRADEID)
           SELECT
                 v_TradeID,p_ID,v_TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,p_CARDTRADENO,
                 0,p_currOper,p_currDept,v_CURRENTTIME,p_CANCELTRADEID
           FROM TF_F_CARDREC
           WHERE CARDNO = p_CARDNO;

    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001020104';
              p_retMsg  := 'Fail to log the operation' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 7)delete card info
    BEGIN
        DELETE FROM TF_F_CARDREC WHERE CARDNO = p_CARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001020105';
              p_retMsg  := 'Fail to delete card info' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 8)delete acc info
    BEGIN
        DELETE FROM TF_F_CARDEWALLETACC WHERE CARDNO = p_CARDNO;

         IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001020106';
              p_retMsg  := 'Fail to delete card info' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 9)delete customer info
    BEGIN
        DELETE FROM TF_F_CUSTOMERREC WHERE CARDNO = p_CARDNO;

         IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001020107';
              p_retMsg  := 'Fail to delete customer info' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 10) Log the writeCard
    BEGIN

    INSERT INTO TF_CARD_TRADE
        (TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,lMoney,lOldMoney,strTermno,OPERATETIME,SUCTAG)
    VALUES
        (v_TradeID,v_TRADETYPECODE,p_OPERCARDNO,p_CARDNO,0,0,p_TERMNO,v_CURRENTTIME,'0');

    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001001139';
              p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
              ROLLBACK; RETURN;
    END;
 -- 11)delete packagetypealion info
    BEGIN
        DELETE FROM TF_F_SPPACKAGETYPEATION WHERE CARDNO = p_CARDNO;

         IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001020140';
              p_retMsg  := 'Fail to delete packagetypealion info' || SQLERRM;
              ROLLBACK; RETURN;
    END;


  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
END;
/
show errors