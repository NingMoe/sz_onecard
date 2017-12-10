CREATE OR REPLACE PROCEDURE SP_SD_ConsumeErrCancel
(
    p_renewRemark     VARCHAR2,
    p_billMonth       CHAR,
    p_currOper        CHAR,
    p_currDept        CHAR,
    p_retCode     OUT CHAR,
    p_retMsg      OUT VARCHAR2
)
AS
    v_seqNo           CHAR(16);
    v_seqNum          NUMBER(16);
    v_quantity        INT      ;

BEGIN
    --1) update TF_TRADE_ERROR_[01-12] info
    EXECUTE IMMEDIATE '
        UPDATE TF_TRADE_ERROR_' || p_billMonth || '
        SET    DEALSTATECODE = ''3''
        WHERE  DEALSTATECODE = ''0''
        AND    ID IN ( SELECT F0 FROM TMP_COMMON)
    ';

    v_quantity := SQL%ROWCOUNT;

    --2) delete the TF_TRADE_EXCLUDE info
    EXECUTE IMMEDIATE '
        DELETE FROM TF_TRADE_EXCLUDE
        WHERE IDENTIFYNO IN (
            SELECT ID
            FROM TF_TRADE_ERROR_' || p_billMonth || ' 
            WHERE DEALSTATECODE = ''3''
            AND   ID IN ( SELECT F0 FROM TMP_COMMON)
        )
    ';

    -- IF SQL%ROWCOUNT != v_quantity THEN 
    --     raise_application_error(-20101, '从排重表中删除被作废异常清单ID的数目不正确');
    -- END IF;

    --3) get the sequence number
    SP_GetSeq(v_quantity, v_seqNo);
    v_seqNum := TO_NUMBER(v_seqNo);

    --4) add TF_B_TRADE_MANUAL info
    EXECUTE IMMEDIATE '
    INSERT INTO TF_B_TRADE_MANUAL (
        TRADEID,
        ID, CARDNO, RECTYPE, ICTRADETYPECODE, ASN, CARDTRADENO,
        SAMNO, PSAMVERNO, POSNO, POSTRADENO, TRADEDATE, TRADETIME,
        PREMONEY, TRADEMONEY, SMONEY, BALUNITNO, TRADECOMFEE,
        CALLINGNO, CORPNO, DEPARTNO, CALLINGSTAFFNO, CITYNO, TAC,
        TACSTATE, MAC, SOURCEID, BATCHNO, DEALTIME, ERRORREASONCODE,
        RENEWTIME, RENEWSTAFFNO,
        DEALSTATECODE, RENEWTYPECODE, RENEWSTATECODE, RENEWREMARK)
    SELECT
        LPAD(TO_CHAR(' || v_seqNum || ' + ROWNUM - 1), 16, ''0''),
        ID, CARDNO, RECTYPE, ICTRADETYPECODE, ASN, CARDTRADENO,
        SAMNO, PSAMVERNO, POSNO, POSTRADENO, TRADEDATE, TRADETIME,
        PREMONEY, TRADEMONEY, SMONEY, BALUNITNO, 0,
        CALLINGNO, CORPNO, DEPARTNO, CALLINGSTAFFNO, CITYNO, TAC,
        TACSTATE, MAC, SOURCEID, BATCHNO, DEALTIME, ERRORREASONCODE,
        sysdate, ''' || p_currOper || ''',
        ''0'', ''3'', ''2'', ''' || p_renewRemark || '''
    FROM  TF_TRADE_ERROR_' || p_billMonth || ' 
    WHERE DEALSTATECODE = ''3''
    AND   ID IN ( SELECT F0 FROM TMP_COMMON)
    ';
    IF SQL%ROWCOUNT != v_quantity THEN 
        raise_application_error(-20102, '将被作废异常清单加入人工回收台账表数目不正确');
    END IF;

    p_retCode := '0000000000';
    p_retMsg  := '' || v_quantity;
    COMMIT;RETURN;

EXCEPTION WHEN OTHERS THEN
    p_retCode := sqlcode;
    p_retMsg  := sqlerrm;
    ROLLBACK; RETURN;
END;

/
show errors



