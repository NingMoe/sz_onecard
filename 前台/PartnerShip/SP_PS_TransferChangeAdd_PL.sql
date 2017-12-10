CREATE OR REPLACE PROCEDURE SP_PS_TransferChangeAdd
(
    p_balUnitNo        CHAR,
    p_balUnit           VARCHAR2,
    p_balUnitTypeCode   CHAR,
    p_sourceTypeCode   CHAR,
    p_callingNo         CHAR,
    p_corpNo           CHAR,
    p_departNo         CHAR,
    p_bankCode         CHAR,
    p_bankAccno         VARCHAR2,
    p_serManagerCode   CHAR,
    --p_createTime     CHAR(20),
    p_balLevel         CHAR,
    p_balCycleTypeCode CHAR,
    p_balInterval       INT,
    p_finCycleTypeCode CHAR,
    p_finInterval       INT,
    p_finTypeCode       CHAR,
    p_comFeeTakeCode   CHAR,
    p_finBankCode      CHAR,
    p_linkMan           VARCHAR2,
    p_unitPhone         VARCHAR2,
    p_unitAdd           VARCHAR2,
    p_uintEmail        VARCHAR2,
    p_remark           VARCHAR2,
    p_comSchemeNo      CHAR,
    p_beginTime        CHAR,--YYYY-MM-DD HH24:MI:SS
    p_endTime          CHAR,

    p_purPoseType      CHAR, --add by jiangbb
    p_bankChannel      CHAR,
    p_RegionCode       CHAR,
    p_DeliveryModeCode CHAR,
    p_AppCallingCode   CHAR,

    p_currOper         CHAR,
    p_currDept         CHAR,
    p_retCode          OUT CHAR ,
    p_retMsg           OUT VARCHAR2
)
AS
    v_currdate    DATE := SYSDATE;
    v_seqNo       CHAR(16);
    v_balComsID   CHAR(8);
BEGIN

   -- 1) get one comscheme Code, A5  means get coms scheme code, len = 8
   SP_GetBizAppCode(1, 'A5', 8, v_balComsID);

   --2) get the sequence number
   SP_GetSeq(seq => v_seqNo);

   --3)  add main log info
   BEGIN
     INSERT INTO TF_B_ASSOCIATETRADE
       (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO,OPERATEDEPARTID,
        OPERATETIME, STATECODE)
     VALUES(v_seqNo, '61', p_balUnitNo, p_currOper, p_currDept, v_currdate, '1' );

   EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008107003';
         p_retMsg  := '';
         ROLLBACK; RETURN;
   END;

   --4) add additional log info  into TF_B_TRADE_BALUNITCHANGE
   BEGIN
   INSERT INTO TF_B_TRADE_BALUNITCHANGE
     (TRADEID, BALUNITNO, BALUNIT, BALUNITTYPECODE, SOURCETYPECODE,
      CALLINGNO, CORPNO, DEPARTNO, BANKCODE, BANKACCNO, SERMANAGERCODE, CREATETIME,
      BALLEVEL, BALCYCLETYPECODE, BALINTERVAL, FINCYCLETYPECODE, FININTERVAL,
      FINTYPECODE, COMFEETAKECODE, FINBANKCODE , LINKMAN,  UNITPHONE,
      UNITADD, UNITEMAIL , REMARK,PURPOSETYPE, BankChannelCode, REGIONCODE, DELIVERYMODECODE, APPCALLINGCODE)
    VALUES(v_seqNo, p_balUnitNo, p_balUnit, p_balUnitTypeCode, p_sourceTypeCode,
       p_callingNo, p_corpNo, p_departNo, p_bankCode, p_bankAccno, p_serManagerCode, v_currdate,
       p_balLevel, p_balCycleTypeCode, p_balInterval, p_finCycleTypeCode, p_finInterval,
       p_finTypeCode, p_comFeeTakeCode, p_finBankCode, p_linkMan, p_unitPhone,
       p_unitAdd, p_uintEmail , p_remark,p_purPoseType, p_bankChannel, p_RegionCode, p_DeliveryModeCode, p_AppCallingCode);

    EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008107004';
         p_retMsg  := '';
         ROLLBACK; RETURN;
   END;

   --5) add additional log info  into TF_TBALUNIT_COMSCHEMECHANGE
   BEGIN
   INSERT INTO TF_TBALUNIT_COMSCHEMECHANGE
    (TRADEID,  COMSCHEMENO, BALUNITNO,  ID,  BEGINTIME, ENDTIME )
   VALUES(v_seqNo, p_comSchemeNo, p_balUnitNo, v_balComsID,
          TO_DATE(p_beginTime, 'YYYY-MM-DD HH24:MI:SS'),
          TO_DATE(p_endTime, 'YYYY-MM-DD HH24:MI:SS') );

    EXCEPTION
       WHEN OTHERS THEN
         p_retCode := 'S008104007';
         p_retMsg  := '';
         ROLLBACK; RETURN;
   END;

   p_retCode := '0000000000';
   p_retMsg  := '';
   COMMIT; RETURN;

END;
/

show errors