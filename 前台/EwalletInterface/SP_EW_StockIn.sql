CREATE OR REPLACE PROCEDURE SP_EW_StockIn
(
    p_CardNo        CHAR, -- Card No. 
    p_cosType       CHAR, -- COS Type 
    p_unitPrice     INT , -- Card Unit Price
    p_chipType      CHAR, -- Chip Type 
    p_producer      CHAR, -- Card Manufacturer 
    p_appVersion    CHAR, -- Application Version 
    p_effDate       CHAR, -- Effective Date 
    p_expDate       CHAR, -- Expired Date 
    p_currOper      CHAR, -- Current Operator 
    p_retCode   OUT CHAR, -- Return Code 
    p_retMsg    OUT VARCHAR2
)
AS
	v_asn        CHAR(16);
	v_cardNo     CHAR(16);
	v_exist      INT := 0;
	v_today      date := sysdate;
	v_seqNo      CHAR(16);  
	v_currDept   CHAR(4) ; --部门编码
	v_faceType   CHAR(4) ; -- Card Face Type 
	v_cardType   CHAR(2) ; -- Card Type
	v_ex         EXCEPTION;
	V_CARDNUM    INT    ;   --库存表中待订购数量
/*
	市民卡电子钱包部分卡入库存储过程
	修订历史：2012-11-20 考虑市民卡下单，入库时卡片由下单状态更新为入库状态，并追踪订单状态。
*/	
BEGIN
    --获取卡片类型和卡面类型
    v_cardType  := substr(p_CardNo,5,2);
    v_faceType  := substr(p_CardNo,5,4);
    
    --获取部门编码
    BEGIN
        SELECT DEPARTNO 
        INTO   v_currDept
        FROM   TD_M_INSIDESTAFF
        WHERE  STAFFNO = p_currOper;
    EXCEPTION WHEN NO_DATA_FOUND THEN 
        v_currDept := '9002';
    END; 

    -- 1) Tell if there is any card already in the stock  
	BEGIN
		SELECT COUNT(*) INTO V_CARDNUM 
		FROM   TL_R_ICUSER 
		WHERE  CARDNO = p_CardNo
		AND    RESSTATECODE  = '15';

		IF V_CARDNUM < 1 THEN
			p_retCode := 'S094570114'; 
			p_retMsg  := '入库的用户卡中存在卡片不为订购状态的卡';
			ROLLBACK; RETURN;
		END IF;    
	END;

    -- 2) Stockin

    BEGIN
        v_asn := '00215000' || SUBSTR(p_CardNo, -8);

		--更新用户卡库存表
		UPDATE TL_R_ICUSER
		SET    RESSTATECODE     = '00'        ,  --入库状态
			   ASN              = v_asn       ,
			   CARDPRICE        = p_unitPrice ,
			   COSTYPECODE      = p_cosType   ,
			   CARDTYPECODE     = v_cardType  ,
			   CARDSURFACECODE  = v_faceType  ,
			   CARDCHIPTYPECODE = p_chipType  ,
			   APPTYPECODE      = '01'        ,
			   APPVERNO         = p_appVersion,
			   MANUTYPECODE     = p_producer  ,
			   VALIDBEGINDATE   = p_effDate   ,
			   VALIDENDDATE     = p_expDate   ,
			   INSTIME          = v_today     ,
			   UPDATESTAFFNO    = P_CURROPER  ,
			   UPDATETIME       = v_today    
		WHERE  RESSTATECODE     = '15'          --订购状态
		AND    CARDNO = p_CardNo;
		
	IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
	EXCEPTION
	WHEN OTHERS THEN
		p_retCode := 'S094570115'; p_retMsg  := '更新用户卡库存表失败,'|| SQLERRM;
		ROLLBACK; RETURN;   
    END;
     
    SP_GetSeq(seq => v_seqNo);

    -- 3) log the stockin operation
    BEGIN
        INSERT INTO TF_R_SMKICUSERTRADE(	
            TRADEID           , CARDNO           ,
            COSTYPECODE       , CARDTYPECODE     , MANUTYPECODE    , CARDSURFACECODE , 	
            CARDCHIPTYPECODE  , CARDPRICE        , OPETYPECODE     ,  	
            OPERATESTAFFNO    , OPERATEDEPARTID  , OPERATETIME
       )VALUES(	
            v_seqNo           , p_CardNo         ,
            p_cosType         , v_cardType       , p_producer       , v_faceType     , 	
            p_chipType        , p_unitPrice      ,'00'              , 	
            p_currOper        , v_currDept       , v_today	
            );
 
       IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S002P01B03'; p_retMsg  := '新增用户卡入库操作台帐失败' || SQLERRM;
             RETURN;
    END;
		
    p_retCode := '0000000000'; p_retMsg  := '';
    RETURN;
END;
/

show errors    