CREATE OR REPLACE PROCEDURE SP_AS_MonthlyCardClose
(
    P_ID                CHAR,
    P_CARDNO            CHAR,
    P_OPERCARDNO        CHAR,
    P_TERMINALNO        CHAR,

    P_CURROPER          CHAR,
    P_CURRDEPT          CHAR,
    P_RETCODE   OUT CHAR, -- RETURN CODE
    P_RETMSG    OUT VARCHAR2  -- RETURN MESSAGE
)
AS
    V_TODAY         DATE := SYSDATE;
    V_CARDTYPE      VARCHAR(2);
	V_ASN			VARCHAR(16);
    V_EX            EXCEPTION;
    V_SEQNO         CHAR(16);
    v_APPTYPE       CHAR(2);
BEGIN

    --  UPDATE
    BEGIN
        UPDATE  TF_F_CARDCOUNTACC
        SET 
            USETAG          = '0',
            UPDATESTAFFNO   = P_CURROPER,
            UPDATETIME      = V_TODAY
        WHERE CARDNO = P_CARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S00504B901'; P_RETMSG  := '设置月票卡有效标识为无效时失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
		
	
    --  UPDATE
    BEGIN
        UPDATE  TF_F_CARDREC
        SET 
            SERSTAKETAG          = '1', 
            UPDATESTAFFNO   = P_CURROPER,
            UPDATETIME      = V_TODAY
        WHERE CARDNO = P_CARDNO;

        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
		
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S00504fB907'; P_RETMSG  := '更新卡资料表服务收取标识失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
	
    SP_GETSEQ(SEQ => V_SEQNO);

    SELECT CARDTYPECODE,ASN INTO V_CARDTYPE,V_ASN FROM TL_R_ICUSER WHERE CARDNO = P_CARDNO;

	select APPTYPE into v_APPTYPE from TF_F_CARDCOUNTACC WHERE CARDNO = P_CARDNO;
	
    --  LOG THE OPERATION
    BEGIN
        INSERT INTO TF_B_TRADE
            (TRADEID,ID,TRADETYPECODE,CARDNO,ASN,CARDTYPECODE,
            OPERATESTAFFNO,OPERATEDEPARTID,OPERATETIME,RSRV2)
        VALUES
            (V_SEQNO,P_ID,'3F',P_CARDNO,V_ASN,V_CARDTYPE,
            P_CURROPER,P_CURRDEPT,V_TODAY,v_APPTYPE);
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S00504B902'; P_RETMSG  := '新增月票卡关闭台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    --  LOG CARD CHANGE
    BEGIN
        INSERT INTO TF_CARD_TRADE
            (TRADEID, TRADETYPECODE, STROPERCARDNO, STRCARDNO, STRTERMNO, OPERATETIME)
        VALUES(V_SEQNO, '3F', P_OPERCARDNO, P_CARDNO, P_TERMINALNO, V_TODAY);
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S00504B904'; P_RETMSG  := '新增月票卡关闭卡片交易台帐失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    --  BREAKUP THE RELATION BETWEEN CARDS AND FEATURES.
    BEGIN
        UPDATE TF_F_CARDUSEAREA
        SET    USETAG        = '0',
               UPDATESTAFFNO = P_CURROPER,
               UPDATETIME    = V_TODAY
        WHERE  CARDNO        = P_CARDNO
        AND    FUNCTIONTYPE  IN  ('03','04','05','09','06','15') AND USETAG ='1';

        IF  SQL%ROWCOUNT < 1 THEN RAISE V_EX; END IF; --当一张卡曾经开通多种月票时，更新可能不止一条
    EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'S00504B905'; P_RETMSG  := '更新卡片与月票卡功能项关联关系失败,' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    P_RETCODE := '0000000000'; P_RETMSG  := '';
    COMMIT; RETURN;
END;
/

show errors
