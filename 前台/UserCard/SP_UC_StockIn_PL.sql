CREATE OR REPLACE PROCEDURE SP_UC_StockIn
(
	p_fromCardNo CHAR, -- From Card No. 
    p_toCardNo   CHAR, -- End  Card No. 
    p_cosType    CHAR, -- COS Type 
    p_unitPrice  INT , -- Card Unit Price 
    p_faceType   CHAR, -- Card Face Type 
    p_cardType   CHAR, -- Card Type 
    p_chipType   CHAR, -- Chip Type 
    p_producer   CHAR, -- Card Manufacturer 
    p_appVersion CHAR, -- Application Version 
    p_effDate    CHAR, -- Effective Date 
    p_expDate    CHAR, -- Expired Date 
    p_currOper   CHAR, -- Current Operator 
    p_currDept   CHAR, -- Curretn Operator's Department 
    p_retCode OUT CHAR, -- Return Code 
    p_retMsg  OUT VARCHAR2
)
-- Return Message
AS
	v_fromCard NUMERIC(16);
	v_toCard   NUMERIC(16);
	v_asn      CHAR(16);
	v_cardNo   CHAR(16);
	v_quantity INT;
	v_exist    INT := 0;
	v_today    date := sysdate;
	v_seqNo    CHAR(16);  
BEGIN
  
    -- 1) Tell if there is any card already in the stock  
    SELECT count(*) INTO v_exist FROM  TL_R_ICUSER WHERE CARDNO BETWEEN p_fromCardNo AND p_toCardNo;
    
    IF v_exist > 0 THEN    
        p_retCode := 'A002P01B01'; p_retMsg  := '已有卡片存在于库中';
        RETURN;
    END IF;

    -- 2) Stockin
    v_fromCard := TO_NUMBER(p_fromCardNo);
    v_toCard   := TO_NUMBER(p_toCardNo);
    v_quantity := v_toCard - v_fromCard + 1;

    BEGIN
        LOOP  
            v_cardNo := SUBSTR('0000000000000000' || TO_CHAR(v_fromCard), -16);
            v_asn    := '00215000' || SUBSTR(v_cardNo, -8);
                    
            INSERT INTO TL_R_ICUSER
                 ( CARDNO , ASN , CARDPRICE , INSTIME  , UPDATESTAFFNO , UPDATETIME,
              COSTYPECODE , CARDTYPECODE, CARDSURFACECODE, CARDCHIPTYPECODE,
             MANUTYPECODE , APPTYPECODE , APPVERNO       , VALIDBEGINDATE ,
             VALIDENDDATE , RESSTATECODE)
            VALUES(v_cardNo, v_asn, p_unitPrice, v_today, p_currOper, v_today ,
                p_cosType  , p_cardType   , p_faceType      , p_chipType      ,
                p_producer , '01'        , p_appVersion    , p_effDate       , 
                p_expDate  , '00');
            
            EXIT WHEN  v_fromCard  >=  v_toCard;
            
            v_fromCard := v_fromCard + 1;
        END LOOP; 
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P01B02'; p_retMsg  := '新增IC卡资料失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
     
    SP_GetSeq(seq => v_seqNo);

    -- 3) log the stockin operation
    BEGIN
        INSERT INTO TF_R_ICUSERTRADE
        (TRADEID,BEGINCARDNO,ENDCARDNO,CARDNUM,COSTYPECODE,CARDTYPECODE,MANUTYPECODE,
            CARDSURFACECODE, CARDCHIPTYPECODE,CARDPRICE,CARDAMOUNTPRICE,
            OPETYPECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
        VALUES  (v_seqNo, p_fromCardNo, p_toCardNo, v_quantity, p_cosType, p_cardType,
                p_producer, p_faceType, p_chipType, p_unitPrice, p_unitPrice * v_quantity,
                '00', p_currOper, p_currDept, v_today);
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P01B03'; p_retMsg  := '新增用户卡入库操作台帐失败' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors

