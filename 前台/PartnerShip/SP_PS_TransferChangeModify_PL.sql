CREATE OR REPLACE PROCEDURE SP_PS_TransferChangeModify
(
    p_balUnitNo          CHAR,
    p_balUnit            VARCHAR2,
    p_balUnitTypeCode    CHAR,
    p_sourceTypeCode     CHAR,
    p_callingNo          CHAR,
    p_corpNo             CHAR,
    p_departNo           CHAR,
    p_bankCode           CHAR,
    p_bankAccno          VARCHAR2,
    p_serManagerCode     CHAR,
    p_balLevel           CHAR,
    p_balCycleTypeCode   CHAR,
    p_balInterval        INT,
    p_finCycleTypeCode   CHAR,
    p_finInterval        INT,
    p_finTypeCode        CHAR,
    p_comFeeTakeCode     CHAR,
    p_finBankCode        CHAR,
    p_linkMan            VARCHAR2,
    p_unitPhone          VARCHAR2,
    p_unitAdd            VARCHAR2,
    p_unitEmail          VARCHAR2,
    p_remark             VARCHAR2,
    p_useTag             CHAR,

    p_aprvState          CHAR,
    p_seqNo              CHAR,

    p_comSchemeNo        CHAR,
    p_beginTime          CHAR,--YYYY-MM-DD HH24:MI:SS
    p_endTime            CHAR,

    p_keyInfoChanged     CHAR,

    p_purPoseType        CHAR, --add by jiangbb
    p_bankChannel        CHAR,
    p_RegionCode         CHAR,
    p_DeliveryModeCode   CHAR,
    p_AppCallingCode     CHAR,

    p_currOper           CHAR,
    p_currDept           CHAR,
    p_retCode        OUT CHAR,
    p_retMsg         OUT VARCHAR2
)
AS
    v_currdate           DATE := SYSDATE;
    v_seqNo              CHAR(16);
    v_tradeTypCd         CHAR(2);
    v_ex                 EXCEPTION;

BEGIN
    -- 如果关键信息没有被修改，刚直接提交，不需要进行审批审核
    IF p_keyInfoChanged <> 'Y'   THEN
        BEGIN
            UPDATE TF_TRADE_BALUNIT
            SET
                LINKMAN       =  p_linkMan,
                UNITPHONE     =  p_unitPhone,
                UNITADD       =  p_unitAdd,
                UNITEMAIL     =  p_unitEmail,
                REMARK        =  p_remark,
                PURPOSETYPE   =  p_purPoseType,
                APPCALLINGCODE = p_AppCallingCode,
                UPDATESTAFFNO =  p_currOper,
                UPDATETIME    =  v_currdate
            WHERE
                BALUNITNO     =  p_balUnitNo;

        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S008109003';
            p_retMsg  := '';
            ROLLBACK; RETURN;
        END;

        p_retCode := '0000000000';
        p_retMsg  := '';
        COMMIT; RETURN;
    END IF;

    IF p_aprvState in('1', '2') THEN -- 1: 财审作废 2: 审批通过
        DELETE FROM TF_B_ASSOCIATETRADE_EXAM
        WHERE TRADEID = p_seqNo;
    END IF;

    IF p_aprvState in('1', '2', '3', '4') THEN -- 3: 审批作废 4: 等待审批
        UPDATE TF_B_ASSOCIATETRADE
        SET    STATECODE      = '1'
        ,      ASSOCIATECODE  = p_balUnitNo
        ,      OPERATESTAFFNO = p_currOper
        ,      OPERATEDEPARTID= p_currDept
        ,      OPERATETIME    = v_currdate
        WHERE  TRADEID = p_seqNo;

        UPDATE TF_B_TRADE_BALUNITCHANGE
        SET    BALUNITNO        = p_balUnitNo       , BALUNIT     = p_balUnit    , BALUNITTYPECODE  = p_balUnitTypeCode ,
               SOURCETYPECODE   = p_sourceTypeCode  , CALLINGNO   = p_callingNo  , CORPNO           = p_corpNo          ,
               DEPARTNO         = p_departNo        , BANKCODE    = p_bankCode   , BANKACCNO        = p_bankAccno       ,
               SERMANAGERCODE   = p_serManagerCode  , CREATETIME  = v_currdate   , BALLEVEL         = p_balLevel        ,
               BALCYCLETYPECODE = p_balCycleTypeCode, BALINTERVAL = p_balInterval, FINCYCLETYPECODE = p_finCycleTypeCode,
               FININTERVAL      = p_finInterval     , FINTYPECODE = p_finTypeCode, COMFEETAKECODE   = p_comFeeTakeCode  ,
               FINBANKCODE      = p_finBankCode     , LINKMAN     = p_linkMan    , UNITPHONE        = p_unitPhone       ,
               UNITADD          = p_unitAdd         , UNITEMAIL   = p_unitEmail  , REMARK           = p_remark          ,
               PURPOSETYPE      = p_purPoseType     , BankChannelCode = p_bankChannel , REGIONCODE  = p_RegionCode       ,
               DELIVERYMODECODE = p_DeliveryModeCode , APPCALLINGCODE = p_AppCallingCode
        WHERE  TRADEID = p_seqNo;

        UPDATE TF_TBALUNIT_COMSCHEMECHANGE
        SET    COMSCHEMENO = p_comSchemeNo
        ,      BALUNITNO   = p_balUnitNo
        ,      BEGINTIME   = to_date(p_beginTime, 'YYYY-MM-DD HH24:MI:SS')
        ,      ENDTIME     = to_date(p_endTime  , 'YYYY-MM-DD HH24:MI:SS')
        WHERE  TRADEID = p_seqNo;

        p_retCode := '0000000000';
        p_retMsg  := '';
        COMMIT; RETURN;
    END IF;


    --1) get the sequence number
    SP_GetSeq(seq => v_seqNo);

    --2) set the  v_tradeTypCd , 1 modify balunit , 0 delete balunit
    IF p_useTag = '1' THEN
        v_tradeTypCd := '62';
    ELSE
        v_tradeTypCd := '63';
    END IF;

    --3)  add main log info
    BEGIN
        INSERT INTO TF_B_ASSOCIATETRADE
              (TRADEID, TRADETYPECODE, ASSOCIATECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME, STATECODE)
        VALUES(v_seqNo, v_tradeTypCd , p_balUnitNo  , p_currOper    , p_currDept     , v_currdate , '1'      );

    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S008107003';
        p_retMsg  := '';
        ROLLBACK; RETURN;
    END;

    --4) add additional log info  into TF_B_TRADE_BALUNITCHANGE
    BEGIN
        INSERT INTO TF_B_TRADE_BALUNITCHANGE
           (TRADEID           , BALUNITNO    , BALUNIT      , BALUNITTYPECODE   , SOURCETYPECODE  ,
            CALLINGNO         , CORPNO       , DEPARTNO     , BANKCODE          , BANKACCNO       ,
            SERMANAGERCODE    , CREATETIME   , BALLEVEL     , BALCYCLETYPECODE  , BALINTERVAL     ,
            FINCYCLETYPECODE  , FININTERVAL  , FINTYPECODE  , COMFEETAKECODE    , FINBANKCODE     ,
            LINKMAN           , UNITPHONE    , UNITADD      , UNITEMAIL         , REMARK          ,
            PURPOSETYPE, BankChannelCode, REGIONCODE, DELIVERYMODECODE, APPCALLINGCODE)
        VALUES(v_seqNo        , p_balUnitNo  , p_balUnit    , p_balUnitTypeCode , p_sourceTypeCode,
            p_callingNo       , p_corpNo     , p_departNo   , p_bankCode        , p_bankAccno     ,
            p_serManagerCode  , v_currdate   , p_balLevel   , p_balCycleTypeCode, p_balInterval   ,
            p_finCycleTypeCode, p_finInterval, p_finTypeCode, p_comFeeTakeCode  , p_finBankCode   ,
            p_linkMan         , p_unitPhone  , p_unitAdd    , p_unitEmail       , p_remark        ,
            p_purPoseType, p_bankChannel, p_RegionCode, p_DeliveryModeCode, p_AppCallingCode);

    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S008107004';
        p_retMsg  := '';
        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors