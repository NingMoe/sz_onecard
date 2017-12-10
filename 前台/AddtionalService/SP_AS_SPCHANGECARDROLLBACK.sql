/* ------------------------------------
Copyright (C) 2015-2016 linkage Software 
 All rights reserved.
<author>gl</author>
<createDate>2015-04-14</createDate>
<description>世乒卡换卡业务存储过程</description>
------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_AS_SPCHANGECARDROLLBACK
(
  p_ID              char,
  p_OLDCARDNO       char,
  p_NEWCARDNO       char,
  p_TRADETYPECODE    char,
  p_CANCELTRADEID   char,
  p_REASONCODE      char,
  p_CARDTRADENO     char,
  p_TRADEPROCFEE    int,
  p_OTHERFEE        int,
  p_CARDSTATE       char,
  p_SERSTAKETAG     char,
  p_TERMNO      char,
  p_OPERCARDNO    char,
  p_TRADEID        out char, -- Return Trade Id
  p_currOper        char,
  p_currDept        char,
  p_retCode        out char, -- Return Code
  p_retMsg         out varchar2  -- Return Message

)
AS
    v_TRADETYPECODE char(2);
    v_TradeID char(16);
    v_CURRENTTIME date := sysdate;
    v_ex          exception;
BEGIN
    -- 1) update card info
    BEGIN
        UPDATE TF_F_CARDREC
        SET CARDSTATE = p_CARDSTATE,
            USETAG = '1',
            SERSTAKETAG = p_SERSTAKETAG,
            UPDATESTAFFNO = p_currOper,
            UPDATETIME = v_CURRENTTIME,
            RSRV1 = null
        WHERE CARDNO = p_OLDCARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001021102';
              p_retMsg  := 'Fail to update card info' || SQLERRM;
              ROLLBACK; RETURN;
    END;


     -- 2) Select tradetypecode
     BEGIN
      SELECT b.CANCELCODE INTO v_TRADETYPECODE
      FROM TF_B_TRADE a,TD_M_TRADETYPE b
      WHERE a.TRADEID = p_CANCELTRADEID AND b.TRADETYPECODE = a.TRADETYPECODE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_retCode := 'S001022107';
            p_retMsg  := 'Can not find changcard info,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

     -- 3) update resstate
     BEGIN
         UPDATE TL_R_ICUSER
         SET DESTROYTIME = null,
             RESSTATECODE = '06',
             UPDATESTAFFNO = p_currOper,
            UPDATETIME = v_CURRENTTIME
        WHERE CARDNO = p_OLDCARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001021103';
              p_retMsg  := 'Fail to update resstate' || SQLERRM;
              ROLLBACK; RETURN;
    END;

     -- 4) update acc info
     BEGIN
         UPDATE TF_F_CARDEWALLETACC
         SET USETAG = '1'
         WHERE CARDNO = p_OLDCARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001021104';
              p_retMsg  := 'Fail to update acc info' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 5) Get trade id
    SP_GetSeq(seq => v_TradeID);
    p_TRADEID := v_TradeID;

     -- 6) update operation
     BEGIN
         UPDATE TF_B_TRADE
         SET CANCELTAG = '1',
         CANCELTRADEID = v_TradeID
         WHERE TRADEID = p_CANCELTRADEID;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001021105';
              p_retMsg  := 'Fail to update operation' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 7) update destroy operation
    IF p_REASONCODE = '12' OR p_REASONCODE = '13' THEN
      BEGIN
         UPDATE TF_B_TRADE
         SET CANCELTAG = '1',
         CANCELTRADEID = v_TradeID
         WHERE CARDNO = p_NEWCARDNO AND TRADETYPECODE = p_TRADETYPECODE AND CANCELTAG = '0';

          IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
      EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001022106';
                p_retMsg  := 'Fail to update destroy operation' || SQLERRM;
                ROLLBACK; RETURN;
      END;
     END IF;

    -- 8) log tradefee,update by shil 2012.05.17
    BEGIN
      INSERT INTO TF_B_TRADEFEE
             (ID,TRADEID,TRADETYPECODE,CARDNO,CARDTRADENO,CARDSERVFEE,CARDDEPOSITFEE,TRADEPROCFEE,
             OTHERFEE,OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        SELECT
              p_ID,v_TradeID,v_TRADETYPECODE,p_NEWCARDNO,p_CARDTRADENO,0-CARDSERVFEE,0-CARDDEPOSITFEE,
              p_TRADEPROCFEE,p_OTHERFEE,p_currOper,p_currDept,v_CURRENTTIME
        FROM TF_B_TRADEFEE
        WHERE TRADEID = p_CANCELTRADEID;

    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001004112';
              p_retMsg  := 'Fail to log tradefee' || SQLERRM;
              ROLLBACK; RETURN;
    END;

     -- 9) 8log operation
     BEGIN
         INSERT INTO TF_B_TRADE
                (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,CARDTRADENO,REASONCODE,OLDCARDNO,
                OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,CANCELTRADEID)
           SELECT
                 v_TradeID,p_ID,v_TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,p_CARDTRADENO,p_REASONCODE,
                 p_OLDCARDNO,p_currOper,p_currDept,v_CURRENTTIME,p_CANCELTRADEID
           FROM TF_F_CARDREC
           WHERE CARDNO = p_NEWCARDNO;

    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001004108';
              p_retMsg  := 'Fail to log operation' || SQLERRM;
              ROLLBACK; RETURN;
    END;

    -- 10) update resstate
    BEGIN
        UPDATE TL_R_ICUSER
        SET RESSTATECODE = '05',
            SELLTIME = null,
            UPDATESTAFFNO = p_currOper,
            UPDATETIME = v_CURRENTTIME
        WHERE CARDNO = p_NEWCARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001001105';
                p_retMsg  := 'Fail to update resstatecode' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    -- 11) delete card info
    BEGIN
        DELETE FROM TF_F_CARDREC WHERE CARDNO = p_NEWCARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001020105';
                p_retMsg  := 'Fail to delete card info' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    -- 12) delete acc info
    BEGIN
        DELETE FROM TF_F_CARDEWALLETACC WHERE CARDNO = p_NEWCARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001020106';
                p_retMsg  := 'Fail to delete acc info' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    -- 13) delete customer info
    BEGIN
        DELETE FROM TF_F_CUSTOMERREC WHERE CARDNO = p_NEWCARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
            WHEN OTHERS THEN
                p_retCode := 'S001020107';
                p_retMsg  := 'Fail to delete customer info' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    -- 14) Log the writeCard
    BEGIN
        INSERT INTO TF_CARD_TRADE
            (TRADEID,TRADETYPECODE,strOperCardNo,strCardNo,strTermno,OPERATETIME,SUCTAG)
        VALUES
            (v_TradeID,v_TRADETYPECODE,p_OPERCARDNO,p_NEWCARDNO,p_TERMNO,v_CURRENTTIME,'0');

    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001001139';
              p_retMsg  := 'Fail to log the writeCard' || SQLERRM;
              ROLLBACK; RETURN;
    END;
	---15) 更新套餐关联表
  BEGIN
	   UPDATE TF_F_SPPACKAGETYPEATION SET CARDNO=p_OLDCARDNO where CARDNO=p_NEWCARDNO;
    EXCEPTION
        WHEN OTHERS THEN
				p_retCode := 'S001001109';
			  p_retMsg  := 'Fail to log the packagetypealion' || SQLERRM;
				ROLLBACK;
				RETURN;
  END;
  p_retCode := '0000000000';
  p_retMsg  := '';
  RETURN;
END;
/
show errors