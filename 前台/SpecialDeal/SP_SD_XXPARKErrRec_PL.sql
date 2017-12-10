CREATE OR REPLACE PROCEDURE SP_SD_XXPARKErrRec
(
    p_renewRemark     VARCHAR2,
    p_billMonth       CHAR,
    p_currOper        CHAR,
    p_currDept        CHAR,
    p_retCode     OUT CHAR,
    p_retMsg      OUT VARCHAR2
)
AS
    v_c               SYS_REFCURSOR;
    v_currdate        DATE := SYSDATE;
    v_seqNo           CHAR(16);
    v_quantity        INT;

    v_row             TF_XXPARK_ERROR_01%rowtype;
    v_cardstate       CHAR(2);

BEGIN
    v_quantity := 0;

    OPEN v_c FOR '
        SELECT *
        FROM  TF_XXPARK_ERROR_' || p_billMonth || '
        WHERE DEALSTATECODE = ''0''
        AND   ID IN (SELECT f0 FROM TMP_COMMON)
        AND   BALUNITNO IS NOT NULL
        AND   BALUNITNO <> ''NOTFOUND''
        AND   CARDNO IS NOT NULL
        ';
    LOOP
        fetch v_c into v_row;
        exit when v_c%NOTFOUND;
        
        --判断卡是否可以回收只有(10售卡,11换卡售卡,21退卡未销户,22换卡未转值)这几种状态的可以回收
        select CARDSTATE INTO v_cardstate from TF_F_CARDREC WHERE CARDNO=v_row.cardno;
        IF v_cardstate  NOT IN('10','11','21','22') THEN
          raise_application_error(-20101,
                        '卡号为' || v_row.cardno || '的卡不可回收,不属于可回收状态');
        END IF;
            
        v_quantity := v_quantity + 1;
        --) update TF_TRADE_ERROR_XX info
        EXECUTE IMMEDIATE '
            UPDATE TF_XXPARK_ERROR_' || p_billMonth || '
            SET   DEALSTATECODE = ''2''
            WHERE ID = ''' || v_row.ID || '''';

        UPDATE TF_F_CARDXXPARKACC_SZ
        SET SPARETIMES = LEAST(SPARETIMES, v_row.SPARETIMES)
        WHERE CARDNO = v_row.CARDNO;

        SP_GetSeq(seq => v_seqNo);

        INSERT INTO TF_B_XXPARK_MANUAL
            (TRADEID, ID, CARDNO, POSNO, SAMNO,
             TRADEDATE, TRADETIME, SPARETIMES, ENDDATE,
             BATCHNO, BALUNITNO, DEALTIME, 
             RENEWTIME, RENEWSTAFFNO, RENEWTYPECODE, RENEWREMARK)
        VALUES
            (v_seqNo, v_row.ID, v_row.CARDNO, v_row.POSNO, v_row.SAMNO,
             v_row.TRADEDATE, v_row.TRADETIME, v_row.SPARETIMES, v_row.ENDDATE,
             v_row.BATCHNO, v_row.BALUNITNO, v_row.DEALTIME,
             v_currdate, p_currOper, '0', p_renewRemark);

        DELETE FROM TQ_XXPARK_ERROR
        WHERE ID = v_row.ID;

        INSERT INTO TQ_XXPARK_RIGHT
            (ID, CARDNO, POSNO, SAMNO, TRADEDATE, TRADETIME, SPARETIMES, ENDDATE,
             BATCHNO, BALUNITNO, DEALTIME)
        VALUES
            (v_row.ID, v_row.CARDNO, v_row.POSNO, v_row.SAMNO, 
            v_row.TRADEDATE, v_row.TRADETIME, v_row.SPARETIMES, v_row.ENDDATE,
            v_row.BATCHNO, v_row.BALUNITNO, v_row.DEALTIME);

        INSERT INTO TF_XXPARK_MANUAL_HS(
            ID, CARDNO, POSNO, SAMNO, 
            TRADEDATE, TRADETIME, SPARETIMES, ENDDATE,
            BATCHNO, BALUNITNO, DEALTIME,RENEWTRADEID,
            RENEWTIME, RENEWSTAFFNO, RENEWTYPECODE, RENEWREMARK)
        VALUES(
            v_row.ID, v_row.CARDNO, v_row.POSNO, v_row.SAMNO,
            v_row.TRADEDATE, v_row.TRADETIME, v_row.SPARETIMES, v_row.ENDDATE,
            v_row.BATCHNO, v_row.BALUNITNO, v_row.DEALTIME, v_seqNo,
            v_currdate, p_currOper, '0', p_renewRemark);

    END LOOP;
    CLOSE v_c;

    p_retCode := '0000000000';
    p_retMsg  := '' || v_quantity;
    COMMIT; RETURN;
EXCEPTION WHEN OTHERS THEN
    IF v_c%ISOPEN THEN CLOSE v_c; END IF;

    p_retCode := SQLCODE;
    p_retMsg  := SQLERRM;
    ROLLBACK; RETURN;
END;

/
show errors

