CREATE OR REPLACE PROCEDURE SP_GC_InfoUpdate
(
    p_currOper  char,
    p_currDept  char,
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message
)
AS
    v_today         date := sysdate;
    v_quantity      INT;
    v_ex            EXCEPTION;
	v_seqNo         CHAR(16);  

BEGIN

    -- 1) Check the v_quantity of changes
    SELECT COUNT(*) INTO v_quantity FROM TMP_COMMON WHERE substr(f1,5,2) != '18';
    IF v_quantity = 0 THEN
        p_retCode := 'A004P07B01'; p_retMsg  := '没有任何资料需要更新';
        RETURN;
    END IF;

    -- 2) Update the customers' basic information
    BEGIN
        merge into TF_F_CUSTOMERREC a
        using      TMP_COMMON b
        on        (a.CARDNO = b.f1 and substr(f1,5,2) != '18')
        when matched then
            update set 
                   a.CUSTNAME      = nvl(a.CUSTNAME, b.f2),
                   a.CUSTSEX       = nvl(a.CUSTSEX, b.f3), 
                   a.CUSTBIRTH     = nvl(a.CUSTBIRTH, b.f4),
                   a.PAPERTYPECODE = nvl(a.PAPERTYPECODE, b.f5), 
                   a.PAPERNO       = nvl(a.PAPERNO, b.f6),
                   a.CUSTADDR      = nvl(a.CUSTADDR, b.f7), 
                   a.CUSTPOST      = nvl(a.CUSTPOST, b.f8), 
                   a.CUSTPHONE     = nvl(a.CUSTPHONE, b.f9),
                   a.CUSTEMAIL     = nvl(a.CUSTEMAIL, b.f10), 
                   a.UPDATESTAFFNO = p_currOper , 
                   a.UPDATETIME    = v_today    ;

        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;

    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P07B02'; p_retMsg  := '更新客户资料失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    SP_GetSeq(seq => v_seqNo);

    -- 3) Log the customer inforation changes
    BEGIN
        INSERT INTO TF_B_CUSTOMERCHANGE
              (TRADEID, CARDNO, CUSTNAME, CUSTSEX, CUSTBIRTH, 
               PAPERTYPECODE, PAPERNO, CUSTADDR, CUSTPOST, CUSTPHONE, CUSTEMAIL,
               CHGTYPECODE, OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME )
        SELECT v_seqNo , f1, f2, f3, f4,
               f5, f6, f7, f8, f9, f10,
               '01'       , p_currOper, p_currDept  , v_today
        FROM   TMP_COMMON;

        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P07B03'; p_retMsg  := '新增客户资料变更台帐失败,' || SQLERRM;
            ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors
