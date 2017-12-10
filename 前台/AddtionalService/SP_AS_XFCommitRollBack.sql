/* ------------------------------------
Copyright (C) 2015-2016 linkage Software 
 All rights reserved.
<author>gl</author>
<createDate>2015-05-13</createDate>
<description>休闲年卡充值卡返销存储过程</description>
------------------------------------ */
CREATE OR REPLACE PROCEDURE SP_AS_XFCommitRollBack
(
    p_TRADEID      VARCHAR2,
	  p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message	
)
AS
    v_enddate date;
    v_PASSWD VARCHAR2(512);
		v_CARDSTATECODE CHAR(1);
    v_ex          exception;
		v_CURRENTTIME  date;
BEGIN

    -- 1) Get system time
    v_CURRENTTIME := sysdate;
    -- 2) Get card information
    BEGIN
        SELECT
             TL_XFC_TRADELOG.PASSWD INTO v_PASSWD
        FROM   TL_XFC_TRADELOG
        WHERE  TL_XFC_TRADELOG.TRADEID = p_TRADEID;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_retCode := 'A001002001';
        p_retMsg  := 'A001002001:未找到开通台账';
        ROLLBACK; RETURN;
    END;

		-- 3) Get card information
    BEGIN
       SELECT

             TD_XFC_INITCARD.CARDSTATECODE,
             TD_XFC_INITCARD.ENDDATE
        INTO v_CARDSTATECODE,v_enddate
        FROM TD_XFC_INITCARD
        WHERE  TD_XFC_INITCARD.NEW_PASSWD = v_PASSWD
        AND TD_XFC_INITCARD.Cardtype='01';

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_retCode := 'A001002116';
        p_retMsg  := 'A001002116:Can not find the record or Error';
        ROLLBACK; RETURN;
    END;

    IF v_CARDSTATECODE != '5' THEN
        p_retCode := 'A001002117';
        p_retMsg  := 'A001002117:状态不是售出';
        ROLLBACK; RETURN;
    END IF;

    IF v_enddate < v_CURRENTTIME THEN
        p_retCode := 'A001002132';
        p_retMsg  := 'A001002132:Enddate is past';
        ROLLBACK; RETURN;
    END IF;

    -- 3) Updated card status
    BEGIN
        UPDATE TD_XFC_INITCARD
        SET  CARDSTATECODE = '4'
        WHERE  NEW_PASSWD = v_PASSWD;

        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001002118';
              p_retMsg  := 'S001002118:Update failure';
              ROLLBACK; RETURN;
    END;

    -- 4) Log xfcard use
    BEGIN
        UPDATE TL_XFC_TRADELOG t SET CANCELTAG='1' WHERE t.tradeid=p_TRADEID;
       
       IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001002119';
              p_retMsg  := 'S001002118:Update failure';
              ROLLBACK; RETURN;
    END;
	
			 -- 5) delete充值卡号 IC卡号对应表
    BEGIN
        DELETE FROM TF_CZC_SELFSUPPLY t  WHERE t.passwd=v_PASSWD;
       
       IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
          WHEN OTHERS THEN
              p_retCode := 'S001002120';
              p_retMsg  := 'S001002120:delete充值卡号 failure';
              ROLLBACK; RETURN;
    END;
  p_retCode := '0000000000';
  p_retMsg  := '';
  RETURN;
END;
/

show errors
