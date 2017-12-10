CREATE OR REPLACE PROCEDURE SP_PS_UnitInfoChangeAdd
( p_corpNo     CHAR,
  p_corp     VARCHAR2,
  p_callingNo  CHAR,
  p_corpAdd     VARCHAR2,
  p_corpMark   VARCHAR2,
  p_linkMan     VARCHAR2,
  p_corpPhone  VARCHAR2,
  p_remark     VARCHAR2,
  p_regionCode CHAR,
  p_companyPaperType CHAR,
  p_companyPaperNo VARCHAR2,
  p_corporation VARCHAR2,
  p_companyEndTime CHAR,
  p_paperType CHAR,
  p_paperNo VARCHAR2,
  p_paperEndDate CHAR,
  p_registeredCapital INT,
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

  p_currOper   CHAR,
  p_currDept   CHAR,
  p_retCode    OUT CHAR,
  p_retMsg     OUT VARCHAR2
)

AS
  v_currdate DATE := SYSDATE;
  v_seqNo    CHAR(16);
  v_quantity INT;
BEGIN


   -- 2) add corp info
   BEGIN
    INSERT INTO TD_M_CORP
    (CORPNO, CORP, CALLINGNO,  CORPADD, CORPMARK, LINKMAN,
     CORPPHONE, USETAG, REMARK, UPDATESTAFFNO, UPDATETIME, REGIONCODE,
     COMPANYPAPERTYPE , COMPANYPAPERNO ,CORPORATION ,COMPANYENDTIME ,PAPERTYPE  ,PAPERNO  ,PAPERENDDATE ,
     REGISTEREDCAPITAL ,COMPANYMANAGERPAPERTYPE ,COMPANYMANAGERNO ,APPCALLINGNO,MANAGEAREA)
    VALUES
      (p_corpNo, p_corp, p_callingNo, p_corpAdd, p_corpMark, p_linkMan,
       p_corpPhone, '1', p_remark, p_currOper, v_currdate, p_regionCode,
       p_companyPaperType ,p_companyPaperNo ,p_corporation ,p_companyEndTime ,p_paperType , p_paperNo  ,p_paperEndDate ,
       p_registeredCapital,p_companymanagerpapertype,p_companymanagerno,p_appcallingno,p_managearea);

    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008100008';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END;

     -- 2.1) add corp info AES
    BEGIN
    INSERT INTO TD_A_CORP
    (CORPNO, CORP, CALLINGNO,  CORPADD, CORPMARK, LINKMAN,
     CORPPHONE, USETAG, REMARK, UPDATESTAFFNO, UPDATETIME, REGIONCODE,
     COMPANYPAPERTYPE , COMPANYPAPERNO ,COMPANYENDTIME ,PAPERTYPE  ,PAPERNO  ,PAPERENDDATE ,
     REGISTEREDCAPITAL ,COMPANYMANAGERPAPERTYPE ,COMPANYMANAGERNO ,APPCALLINGNO,MANAGEAREA)
    VALUES
      (p_corpNo, p_corp, p_callingNo, p_corpAddAes, p_corpMark, p_linkManAes,
       p_corpPhoneAes, '1', p_remark, p_currOper, v_currdate, p_regionCode,
       p_companyPaperType ,p_companyPaperNoAes ,p_companyEndTime ,p_paperType , p_paperNoAes  ,p_paperEndDate ,
       p_registeredCapital,p_companymanagerpapertype,p_companymanagernoAes,p_appcallingno,p_managearea);

    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008100009';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END;

   --3) get the sequence number
   SP_GetSeq(seq => v_seqNo);

   --4) add main log info  , '54' means add corp info
   BEGIN
    INSERT INTO TF_B_ASSOCIATETRADE
    (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
    VALUES
   (v_seqNo, '54', p_corpNo, p_currOper, p_currDept, v_currdate);

  EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008100005';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END;

   -- 5) add additional log info
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