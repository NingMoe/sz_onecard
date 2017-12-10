CREATE OR REPLACE PROCEDURE SP_PS_TransferFiApprovalPass
(
    p_tradeId          CHAR,
    p_tradeTypeCode    CHAR,

    p_balUnitNo        CHAR,
    p_balUnit           VARCHAR2,
    p_balUnitTypeCode  CHAR,
    p_channelNo        CHAR,
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

    p_purPoseType      CHAR,  --add by jiangbb 2012-05-21 收款人账户类型
    p_bankChannel      CHAR,
    p_RegionCode         CHAR,
    p_DeliveryModeCode   CHAR,
    p_AppCallingCode     CHAR,

    --add del update bal unit  stuff info
    p_updateStuff      CHAR,

    p_currOper         CHAR,
    p_currDept         CHAR,
    p_retCode          OUT CHAR,
    p_retMsg           OUT VARCHAR2
)
AS
    v_currdate         DATE := SYSDATE;
    v_ex               EXCEPTION;
    v_comSchemeNo      CHAR(8);
    v_comstype         CHAR(1);
    v_beginTime        DATE;
    v_endTime          DATE;
    v_quantity         INT;
    v_balComsID        CHAR(8);
    v_ctComScheme      INT;    --balunit 's comscheme counts

BEGIN

   --1)when add a new balunit info
   IF p_tradeTypeCode = '61' THEN

      BEGIN
     --a. add baiunit info
       INSERT INTO TF_TRADE_BALUNIT
       (BALUNITNO, BALUNIT, BALUNITTYPECODE, SOURCETYPECODE, CALLINGNO, CORPNO,
        DEPARTNO, BANKCODE, BANKACCNO, CREATETIME, SERMANAGERCODE, BALLEVEL,
        BALCYCLETYPECODE, BALINTERVAL, FINCYCLETYPECODE, FININTERVAL, FINTYPECODE,
        COMFEETAKECODE,FINBANKCODE,LINKMAN, UNITPHONE, UNITADD,CHANNELNO,
        UNITEMAIL, UPDATETIME, UPDATESTAFFNO, USETAG, REMARK,PURPOSETYPE,BankChannelCode, REGIONCODE, DELIVERYMODECODE, APPCALLINGCODE )
     VALUES
      (p_balUnitNo, p_balUnit, p_balUnitTypeCode, p_sourceTypeCode, p_callingNo, p_corpNo,
       p_departNo, p_bankCode, p_bankAccno, v_currdate, p_serManagerCode, p_balLevel,
       p_balCycleTypeCode, p_balInterval,  p_finCycleTypeCode, p_finInterval, p_finTypeCode,
       p_comFeeTakeCode, p_finBankCode, p_linkMan, p_unitPhone, p_unitAdd, p_channelNo,
       p_uintEmail, v_currdate, p_updateStuff, '1', p_remark,p_purPoseType,p_bankChannel, p_RegionCode, p_DeliveryModeCode, p_AppCallingCode );

       EXCEPTION
         WHEN OTHERS THEN
           p_retCode := 'S008109001';
           p_retMsg  := '';
           ROLLBACK; RETURN;
      END;

       --b. add comscheme info
     BEGIN
         INSERT INTO TD_TBALUNIT_COMSCHEME
         (BALUNITNO, COMSCHEMENO, BEGINTIME, ENDTIME, UPDATESTAFFNO, UPDATETIME, ID, USETAG)
       SELECT p_balUnitNo, COMSCHEMENO, BEGINTIME, ENDTIME, p_updateStuff, v_currdate, ID, '1'
       FROM TF_TBALUNIT_COMSCHEMECHANGE WHERE TRADEID = p_tradeId ;

       EXCEPTION
           WHEN OTHERS THEN
          -- raise;
             p_retCode := 'S008109002';
             p_retMsg  := '1';
             ROLLBACK; RETURN;
     END;
     --c. sourceTypeCode为信息亭时
     IF p_sourceTypeCode = '01' THEN
     BEGIN
       INSERT INTO TD_M_TRADE_SOURCE
         (SOURCECODE, BALUNITNO, USETAG, UPDATESTAFFNO, UPDATETIME )
       VALUES('0C' || p_departNo, p_balUnitNo, '1', p_updateStuff, v_currdate );
         EXCEPTION
           WHEN OTHERS THEN
             p_retCode := 'S008109102';
             p_retMsg  := '';
             ROLLBACK; RETURN;
        END;
      END IF;
   --2) when modify the balunit info and usetag = '1'
   ElSIF p_tradeTypeCode = '62' THEN

     --2)update baiunit info
     BEGIN
       UPDATE TF_TRADE_BALUNIT
          SET
              BALUNITTYPECODE  =  p_balUnitTypeCode,

              SOURCETYPECODE   =  p_sourceTypeCode,
              CALLINGNO        =  p_callingNo,
              CORPNO           =  p_corpNo,
              DEPARTNO         =  p_departNo,

              BANKCODE         =  p_bankCode,
              BANKACCNO         =  p_bankAccno,
              SERMANAGERCODE   =  p_serManagerCode,
              BALLEVEL         =  p_balLevel,
              BALCYCLETYPECODE =  p_balCycleTypeCode,
              BALINTERVAL       =  p_balInterval,
              FINCYCLETYPECODE =  p_finCycleTypeCode,
              FININTERVAL       =  p_finInterval,
              FINTYPECODE       =  p_finTypeCode,
              COMFEETAKECODE   =  p_comFeeTakeCode,
              FINBANKCODE      =  p_finBankCode,
              LINKMAN           =  p_linkMan,
              UNITPHONE         =  p_unitPhone,
              UNITADD           =  p_unitAdd  ,
              UNITEMAIL        =  p_uintEmail,
              CHANNELNO        =  p_channelNo,
              USETAG           =  '1',
              REMARK           =  p_remark,
              UPDATESTAFFNO     =  p_updateStuff,
              UPDATETIME       =  v_currdate,
              BALUNIT           =  p_balUnit,
              PURPOSETYPE      =  p_purPoseType,
              BankChannelCode  =  p_bankChannel,
              REGIONCODE       =  p_RegionCode,
              DELIVERYMODECODE =  p_DeliveryModeCode,
              APPCALLINGCODE   =  p_AppCallingCode
        WHERE BALUNITNO         =  p_balUnitNo;

    IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION
          WHEN OTHERS THEN
            p_retCode := 'S008109003';
            p_retMsg  := '';
            ROLLBACK; RETURN;
      END;


   --3) when delete the balunit info and usetag = '0'
   ElSIF p_tradeTypeCode = '63' THEN

      BEGIN
     --a.update baiunit info
       UPDATE TF_TRADE_BALUNIT
        SET USETAG =  '0'  ,
            UPDATESTAFFNO  =  p_updateStuff,
            UPDATETIME    =  v_currdate
      WHERE BALUNITNO = p_balUnitNo;

     IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
       EXCEPTION
         WHEN OTHERS THEN
           p_retCode := 'S008109003';
           p_retMsg  := '';
           ROLLBACK; RETURN;
    END;
       ---b. update balunit's com fee scheme
      BEGIN
         UPDATE TD_TBALUNIT_COMSCHEME
          SET USETAG = '0',
              UPDATESTAFFNO  =  p_updateStuff,
              UPDATETIME    =  v_currdate


        WHERE BALUNITNO =  p_balUnitNo;

         --IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
         EXCEPTION
           WHEN OTHERS THEN
             p_retCode := 'S008109004';
             p_retMsg  := SQLERRM;
            ROLLBACK; RETURN;
       END;

   --4) when add a balunit 's comscheme
   ElSIF p_tradeTypeCode = '66' THEN

      --I. get com fee schemeno,beginTime,endTime,balComsID
      SELECT COMSCHEMENO, BEGINTIME, ENDTIME,ID
        INTO v_comSchemeNo, v_beginTime, v_endTime,v_balComsID
      FROM TF_TBALUNIT_COMSCHEMECHANGE WHERE TRADEID = p_tradeId;

      --II. get the comSchemeNo 's type
      SELECT TYPECODE INTO v_comstype FROM TF_TRADE_COMSCHEME WHERE COMSCHEMENO = v_comSchemeNo;

      --V. whether  the seam scheme is repeated
      SELECT COUNT(*) INTO v_quantity FROM TD_TBALUNIT_COMSCHEME tcoms
        WHERE tcoms.BALUNITNO = p_balUnitNo AND tcoms.COMSCHEMENO = v_comSchemeNo AND
         tcoms.USETAG  = '1' AND tcoms.BEGINTIME = v_beginTime AND tcoms.ENDTIME = v_endTime;

      IF v_quantity >= 1 THEN
          p_retCode := 'A008109116';
          p_retMsg  := '';
          RETURN;
        END IF;

       --VI. whether diff SCHEME has overlap  time between v_beginTime and v_endTime
        SELECT COUNT(*) INTO v_quantity
       FROM TF_TRADE_COMSCHEME tcoms, TD_TBALUNIT_COMSCHEME tbcoms
       WHERE tcoms.COMSCHEMENO = tbcoms.COMSCHEMENO AND tbcoms.USETAG = '1' AND
         tcoms.TYPECODE != v_comstype AND tbcoms.BALUNITNO  = p_balUnitNo AND
       (tbcoms.BEGINTIME between v_beginTime AND v_endTime OR
        tbcoms.ENDTIME between v_beginTime AND v_endTime );

      IF v_quantity >= 1 THEN
           p_retCode := 'A008109104';
           p_retMsg  := '';
           RETURN;
        END IF;


     --VIII.   add baiunit's com fee scheme info
       BEGIN
         INSERT INTO  TD_TBALUNIT_COMSCHEME
       (BALUNITNO, COMSCHEMENO, BEGINTIME, ENDTIME, UPDATESTAFFNO, UPDATETIME, ID, USETAG)
       VALUES
         (p_balUnitNo, v_comSchemeNo, v_beginTime, v_endTime,
          p_updateStuff, v_currdate, v_balComsID,  '1' );

       EXCEPTION
         WHEN OTHERS THEN
           p_retCode := 'S008109002';
           p_retMsg  := '2';
           ROLLBACK; RETURN;
       END;

   --5) when update the balunit's comscheme info
   ElSIF p_tradeTypeCode = '67' THEN

      --I.get modify com fee scheme info ,schemeno,beginTime,endTime,balComsID
      SELECT COMSCHEMENO, BEGINTIME, ENDTIME,ID
        INTO v_comSchemeNo, v_beginTime, v_endTime,v_balComsID
      FROM TF_TBALUNIT_COMSCHEMECHANGE WHERE TRADEID = p_tradeId;

      --V. get the comSchemeNo 's type
      SELECT TYPECODE INTO v_comstype FROM TF_TRADE_COMSCHEME WHERE COMSCHEMENO = v_comSchemeNo;

      --VI. check the seam comscheme is repeated
      SELECT COUNT(*) INTO v_quantity FROM TD_TBALUNIT_COMSCHEME tcoms
        WHERE tcoms.BALUNITNO = p_balUnitNo AND tcoms.COMSCHEMENO = v_comSchemeNo AND
         tcoms.USETAG  = '1' AND tcoms.BEGINTIME = v_beginTime AND tcoms.ENDTIME = v_endTime;

      IF v_quantity >= 1 THEN
          p_retCode := 'A008109116';
          p_retMsg  := '';
          RETURN;
        END IF;

      --VI. whether diff SCHEME has overlap  time between v_beginTime and v_endTime
      SELECT COUNT(*) INTO v_quantity
      FROM TF_TRADE_COMSCHEME tcoms, TD_TBALUNIT_COMSCHEME tbcoms
      WHERE tcoms.COMSCHEMENO = tbcoms.COMSCHEMENO AND tbcoms.USETAG = '1' AND
        tcoms.TYPECODE != v_comstype AND tbcoms.BALUNITNO  = p_balUnitNo AND
      (tbcoms.BEGINTIME between v_beginTime AND v_endTime OR
       tbcoms.ENDTIME between v_beginTime AND v_endTime );

     IF v_quantity >= 1 THEN
           p_retCode := 'A008109104';
           p_retMsg  := '';
           RETURN;
        END IF;


     --VII. update baiunit com scheme info
     BEGIN
         UPDATE TD_TBALUNIT_COMSCHEME
            SET BEGINTIME         =  v_beginTime,
                 ENDTIME           =  v_endTime,
                 UPDATESTAFFNO      =  p_updateStuff,
                UPDATETIME        =  v_currdate
          WHERE ID                = v_balComsID ;

          IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
          EXCEPTION
            WHEN OTHERS THEN
            p_retCode := 'S008109004';
            p_retMsg  := SQLERRM;
            ROLLBACK; RETURN;
       END;

     --6) when delete the comschemes info
   ElSIF p_tradeTypeCode = '68' THEN

       -- a. check current balUnitNo has only one comschemen
     BEGIN
         SELECT COUNT(*) INTO v_ctComScheme FROM TD_TBALUNIT_COMSCHEME
         WHERE BALUNITNO = p_balUnitNo AND USETAG = '1';

       IF v_ctComScheme = 1 THEN
           p_retCode := 'A008109113';
           p_retMsg  := '';
           RETURN;
        END IF;
       END;

       -- b. get delete com fee scheme info
       SELECT ID INTO v_balComsID FROM TF_TBALUNIT_COMSCHEMECHANGE WHERE TRADEID = p_tradeId;

    BEGIN
       UPDATE TD_TBALUNIT_COMSCHEME
        SET USETAG = '0'    ,
             UPDATESTAFFNO  =  p_updateStuff,
            UPDATETIME    =  v_currdate

      WHERE ID =  v_balComsID;

        IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
              p_retCode := 'S008109004';
              p_retMsg  := SQLERRM;
              ROLLBACK; RETURN;
       END;

  END IF;


  -- 7) add trade balunit change event info
  IF p_balUnitTypeCode != '04' THEN
      BEGIN
        INSERT INTO TD_TRADE_BALEVENT
        (  ID, EVENTTYPECODE, BALUNITNO, DEALSTATECODE1,DEALSTATECODE2, OCCURTIME)
      VALUES
        (p_tradeId, '00' || p_tradeTypeCode, p_balUnitNo , '0', '0', v_currdate );

          EXCEPTION
             WHEN OTHERS THEN
               p_retCode := 'S008109007';
               p_retMsg  := '';
               ROLLBACK; RETURN;
      END;
   END IF;

  --8)  update the exam log info
  BEGIN
    UPDATE TF_B_ASSOCIATETRADE_EXAM
       SET STATECODE        =    '2' ,
           EXAMSTAFFNO      =    p_currOper,
           EXAMDEPARTNO     =    p_currDept,
           EXAMKTIME        =    v_currdate

     WHERE TRADEID          =    p_tradeId;

    IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
      WHEN OTHERS THEN
        p_retCode := 'S008109008';
        p_retMsg  := '';
        ROLLBACK; RETURN;
   END;

   p_retCode := '0000000000';
   p_retMsg  := '';
   COMMIT; RETURN;

END;
/

show errors