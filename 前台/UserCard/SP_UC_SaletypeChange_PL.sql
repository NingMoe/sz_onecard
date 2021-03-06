CREATE OR REPLACE PROCEDURE SP_UC_SaletypeChange
(
    P_FROMCARDNO 		CHAR, -- FROM CARD NO. 
    P_TOCARDNO   		CHAR, -- END  CARD NO. 
	P_SALETYPE			CHAR, -- SALE CARD TYPE
	P_CURROPER	        CHAR,
	P_CURRDEPT	        CHAR,
	P_RETCODE	        OUT CHAR, -- RETURN CODE
	P_RETMSG     	    OUT VARCHAR2  -- RETURN MESSAGE

)
AS
    V_FROMCARD      NUMERIC(16);
    V_TOCARD        NUMERIC(16);
	V_QUANTITY      INT;
    V_DBQUANTITY    INT;
	V_TODAY         DATE := SYSDATE;
    V_EX            EXCEPTION;
	V_SEQNO         CHAR(16);  

BEGIN

	-- 1) TELL THE CONSISTENCE OF V_QUANTITY 
    V_FROMCARD := TO_NUMBER(P_FROMCARDNO);
    V_TOCARD   := TO_NUMBER(P_TOCARDNO);
    V_QUANTITY := V_TOCARD - V_FROMCARD + 1;
	
	
	SELECT COUNT(*) INTO V_DBQUANTITY
    FROM TL_R_ICUSER
    WHERE CARDNO BETWEEN P_FROMCARDNO AND P_TOCARDNO
    AND   RESSTATECODE IN ('01','05') AND (SALETYPE IS NULL OR SALETYPE <> P_SALETYPE);  -- IN STOCKIN
    IF V_QUANTITY != V_DBQUANTITY THEN
        P_RETCODE := 'A002P02F01'; P_RETMSG  := '请检查更新卡片的库存状态是否是出库或分配并且更新前售卡方式是否与所选不同';
        RETURN; 
    END IF;    

	
	 -- 2) UPDATE THE IC CARD STOCK TABLE
	BEGIN
        UPDATE  TL_R_ICUSER
        SET 	UPDATETIME       = V_TODAY     ,
				UPDATESTAFFNO    = P_CURROPER     ,
				SALETYPE         = P_SALETYPE
        WHERE CARDNO  BETWEEN P_FROMCARDNO AND P_TOCARDNO
        AND   RESSTATECODE   IN ('01','05');
        
        IF  SQL%ROWCOUNT != V_QUANTITY THEN RAISE V_EX; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            P_RETCODE := 'S002P02B02'; P_RETMSG  := '更新IC卡库存信息失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
	
	 -- 3) LOG THIS OPERATION 
    -- GET THE SEQUENCE NUMBER 
    SP_GETSEQ(SEQ => V_SEQNO);
    BEGIN
        INSERT INTO TF_R_ICUSERTRADE
            (TRADEID,   BEGINCARDNO, ENDCARDNO, CARDNUM, RSRV1,
            OPETYPECODE, OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME)
        VALUES  
            (V_SEQNO, P_FROMCARDNO, P_TOCARDNO, V_QUANTITY, P_SALETYPE,
            '16',       P_CURROPER     , P_CURRDEPT     ,  V_TODAY);
    EXCEPTION
        WHEN OTHERS THEN
            P_RETCODE := 'S002P01B03'; P_RETMSG  := '新增用户卡入库操作台帐失败' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    P_RETCODE := '0000000000'; P_RETMSG  := '';
    COMMIT; RETURN;
	
	
END;
/

SHOW ERRORS