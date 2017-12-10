CREATE OR REPLACE PROCEDURE SP_SD_SpeAdjustAcc
(
    p_ID                CHAR,
    p_CARDNO            CHAR,
    p_CARDTRADENO       CHAR,
    p_CARDMONEY         INT,
    p_CARDACCMONEY      INT,
    p_ASN               CHAR,
    p_CARDTYPECODE      CHAR,
    p_TRADETYPECODE     CHAR,
    p_TERMNO            CHAR,
    p_ADJUSTMONEY       INT,
    p_OPERCARDNO        CHAR,
    p_currOper          CHAR,
    p_currDept          CHAR,
    p_retCode       OUT CHAR,
    p_retMsg        OUT VARCHAR2
)

AS
    v_seqNo            CHAR(16);
    v_seqNo_B          CHAR(16);
    v_currTime         DATE;
    v_ex               EXCEPTION;
    v_cardno	         CHAR(16);
    v_quantity         INT;

BEGIN

    --1) get the sequence number
    SP_GetSeq(seq => v_seqNo);

    --2) Execute SP_PB_UpdateAcc
    SP_PB_UpdateAcc(p_ID    , p_CARDNO  , p_CARDTRADENO , p_CARDMONEY  , p_CARDACCMONEY ,
                    v_seqNo , p_ASN     , p_CARDTYPECODE, p_ADJUSTMONEY, p_TRADETYPECODE,
                    p_TERMNO, v_currTime, p_currOper    , p_currDept   , p_retCode      ,
                    p_retMsg);

    IF p_retCode !='0000000000' THEN
      ROLLBACK; RETURN;
    END IF;
	
    BEGIN
        INSERT INTO TF_B_TRADE
                    ( TRADEID, ID  , TRADETYPECODE  , CARDNO  , ASN  , CARDTYPECODE  , CARDTRADENO , CURRENTMONEY ,
                      PREMONEY  , NEXTMONEY                 ,OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME )
        VALUES
                    ( v_seqNo, p_ID, p_TRADETYPECODE, p_CARDNO, p_ASN, p_CARDTYPECODE, p_CARDTRADENO , p_ADJUSTMONEY,
                     p_CARDMONEY, p_CARDMONEY + p_ADJUSTMONEY, p_currOper  , p_currDept     , v_currTime  );

        EXCEPTION WHEN OTHERS THEN
                p_retCode := 'S009113116';
                p_retMsg  := SQLERRM;
                ROLLBACK; RETURN;
    END;
			
          
    BEGIN 
        FOR cur_AdjAcc IN ( SELECT CARDNO
            FROM  TMP_ADJUSTACC_IMP) LOOP
            v_cardno := cur_AdjAcc.CARDNO;
        --4) update the TF_SPEADJUSTOFFERACC info
        SELECT COUNT(*) INTO v_quantity FROM TF_SPEADJUSTOFFERACC WHERE CARDNO = v_cardno;
        IF v_quantity >= 1 THEN
            BEGIN
                UPDATE TF_SPEADJUSTOFFERACC
                SET  OFFERMONEY       = 0,
                     TOTALSUPPLYTIMES = TOTALSUPPLYTIMES + 1,
                     TOTALSUPPLYMONEY = TOTALSUPPLYMONEY + p_ADJUSTMONEY
                WHERE CARDNO = v_cardno;

                IF SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                p_retCode := 'S009113114';
                p_retMsg  := SQLERRM;
                ROLLBACK; RETURN;
            END;
        END IF;

        --5) update TF_B_SPEADJUSTACC info
        SELECT COUNT(*) INTO v_quantity FROM TF_B_SPEADJUSTACC WHERE 
        CARDNO = v_cardno AND STATECODE='1' and TRADETYPECODE = '97';
        IF v_quantity >= 1 THEN
            BEGIN
                UPDATE TF_B_SPEADJUSTACC
                SET    STATECODE     = '2'       ,
                       SUPPTRADEID   = v_seqNo   ,
                       SUPPSTAFFNO   = p_currOper,
                       SUPPTIME      = v_currTime
                WHERE  CARDNO        = v_cardno
                AND    TRADETYPECODE = '97'
                AND    STATECODE     = '1';
                IF SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                p_retCode := 'S009111002';
                p_retMsg  := SQLERRM;
                ROLLBACK; RETURN;
            END;
        END IF;
        END LOOP;
    END;


    --6) add TF_SPEADJUST_SUPPLY info
    BEGIN
        INSERT INTO TF_SPEADJUST_SUPPLY
            (TRADEID, ID  , CARDNO  , ASN  , CARDTYPECODE  , CARDTRADENO  , TRADEMONEY   ,
            PREMONEY   , TERMNO  , OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
        VALUES
           (v_seqNo , p_ID, p_CARDNO, p_ASN, p_CARDTYPECODE, p_CARDTRADENO, p_ADJUSTMONEY,
            p_CARDMONEY, p_TERMNO, p_currOper    , p_currDept     , v_currTime );

    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S009113115';
        p_retMsg  := SQLERRM;
        ROLLBACK; RETURN;
    END;
    -- Log the writeCard
    BEGIN
        INSERT INTO TF_CARD_TRADE
        (TRADEID, TRADETYPECODE  , strOperCardNo, strCardNo, lMoney       , lOldMoney  , strTermno,
         Cardtradeno,OPERATETIME, SUCTAG)
        VALUES
        (v_seqNo, p_TRADETYPECODE, p_OPERCARDNO , p_CARDNO , p_ADJUSTMONEY, p_CARDMONEY, p_TERMNO ,
         p_CARDTRADENO,v_currTime , '0'   );

    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S009113117';
        p_retMsg  := SQLERRM;
        ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT;RETURN;

END;

/
show errors