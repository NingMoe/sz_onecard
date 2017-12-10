CREATE OR REPLACE PROCEDURE SP_PS_UnitInfoChangeModify
( p_corpNo    CHAR,
  p_corp    VARCHAR2,
  p_callingNo CHAR,
  p_corpAdd    VARCHAR2,
  p_corpMark  VARCHAR2,
  p_linkMan    VARCHAR2,
  p_corpPhone VARCHAR2,
  p_remark    VARCHAR2,
  p_useTag    CHAR,
  p_regionCode CHAR,
  p_companyPaperType  CHAR,
  p_companyPaperNo    VARCHAR2,
  p_corporation VARCHAR2,
  p_companyEndTime    CHAR,
  p_paperType         CHAR,
  p_paperNo           VARCHAR2,
  p_paperEndDate      CHAR,
  p_registeredCapital  int,
  p_companymanagerpapertype CHAR,
  p_companymanagerno  VARCHAR2,
  p_managearea VARCHAR2,
  p_appcallingno CHAR,

  p_corpAddAes     VARCHAR2,
  p_linkManAes      VARCHAR2,
  p_corpPhoneAes   VARCHAR2,
  p_companyPaperNoAes  VARCHAR2,
  p_paperNoAes  VARCHAR2,
  p_companymanagernoAes   VARCHAR2,

  p_currOper  CHAR,
  p_currDept  CHAR,
  p_retCode   OUT CHAR,
  p_retMsg    OUT VARCHAR2
)
AS
  v_currdate  DATE := SYSDATE;
  v_seqNo     CHAR(16);
  v_quantity  INT;
  v_count     INT;
  v_ex        EXCEPTION;

BEGIN

  --1) when useTag=0, check the corp's userful balunit and depart
  IF p_useTag = '0' THEN
  BEGIN
  SELECT COUNT(*) INTO v_quantity FROM TF_TRADE_BALUNIT
    WHERE CORPNO = p_corpNo AND USETAG = '1';

  IF v_quantity >= 1 THEN
       p_retCode := 'A008100018';
       p_retMsg  := '';
       RETURN;
    END IF;
  END;

  BEGIN
    SELECT COUNT(*) INTO v_quantity FROM TD_M_DEPART
    WHERE CORPNO = p_corpNo AND USETAG = '1';

  IF v_quantity >= 1 THEN
       p_retCode := 'A008100019';
       p_retMsg  := '';
       RETURN;
    END IF;
  END;
  END IF;




  --3) upadae corp info
  BEGIN
    UPDATE TD_M_CORP
       SET CORP       =  p_corp,
       CALLINGNO     =  p_callingNo,
       CORPADD       =  p_corpAdd,
       CORPMARK       =  p_corpMark,
       LINKMAN       =  p_linkMan,
       CORPPHONE     =  p_corpPhone,
       REMARK         =  p_remark,
       UPDATESTAFFNO =  p_currOper,
       UPDATETIME     =  v_currdate,
       USETAG         =  p_useTag,
       REGIONCODE    =  p_regionCode,
       COMPANYPAPERTYPE = p_companyPaperType,
       COMPANYPAPERNO   = p_companyPaperNo,
       CORPORATION	   = p_corporation,
       COMPANYENDTIME   = p_companyEndTime,
       PAPERTYPE        = p_paperType,
       PAPERNO          = p_paperNo,
       PAPERENDDATE      = p_paperEndDate,
       REGISTEREDCAPITAL= p_registeredCapital,
       COMPANYMANAGERPAPERTYPE =p_companymanagerpapertype,
       COMPANYMANAGERNO = p_companymanagerno,
       APPCALLINGNO = p_appcallingno,
       MANAGEAREA = p_managearea
     WHERE CORPNO     =  p_corpNo ;

    IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008100003';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;

   --3.1) upadae corp info
  BEGIN
    UPDATE TD_A_CORP
       SET CORP       =  p_corp,
       CALLINGNO     =  p_callingNo,
       CORPADD       =  p_corpAddAes,
       CORPMARK       =  p_corpMark,
       LINKMAN       =  p_linkManAes,
       CORPPHONE     =  p_corpPhoneAes,
       REMARK         =  p_remark,
       UPDATESTAFFNO =  p_currOper,
       UPDATETIME     =  v_currdate,
       USETAG         =  p_useTag,
       REGIONCODE    =  p_regionCode,
       COMPANYPAPERTYPE = p_companyPaperType,
       COMPANYPAPERNO   = p_companyPaperNoAes,
       COMPANYENDTIME   = p_companyEndTime,
       PAPERTYPE        = p_paperType,
       PAPERNO          = p_paperNoAes,
       PAPERENDDATE      = p_paperEndDate,
       REGISTEREDCAPITAL= p_registeredCapital,
       COMPANYMANAGERPAPERTYPE =p_companymanagerpapertype,
       COMPANYMANAGERNO = p_companymanagernoAes,
       APPCALLINGNO = p_appcallingno,
       MANAGEAREA = p_managearea
     WHERE CORPNO     =  p_corpNo ;

    IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008100004';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;

  --4) get the sequence number
  SP_GetSeq(seq => v_seqNo);

  --5) add main log info , '55' means change corp info
  BEGIN
    INSERT INTO TF_B_ASSOCIATETRADE
    (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
    VALUES
      (v_seqNo, '55', p_corpNo, p_currOper, p_currDept, v_currdate);

  EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008100005';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;

  -- 6) add additional log info
  BEGIN
    INSERT INTO TF_B_CORPCHANGE
      (TRADEID, CORP, CORPNO, CALLINGNO, CORPADD, CORPMARK, REMARK, LINKMAN, CORPPHONE, REGIONCODE )
    VALUES
    (v_seqNo, p_corp, p_corpNo, p_callingNo, p_corpAdd,
     p_corpMark, p_remark, p_linkMan, p_corpPhone, p_regionCode);

    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008100006';
        p_retMsg  := '';
        ROLLBACK; RETURN;
  END;

  p_retCode := '0000000000';
  p_retMsg  := '';
  COMMIT; RETURN;
END;
/

show errors