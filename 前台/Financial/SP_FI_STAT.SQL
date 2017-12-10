create or replace procedure SP_FI_STAT
(
    p_funcCode   varchar2,
    p_var1   in out    varchar2,
    p_var2   in out    varchar2,
    p_var3   in out    varchar2,
    p_var4   in out    varchar2,
    p_var5   in out    varchar2,
    p_var6   in out    varchar2,
    p_var7   in out    varchar2,
    p_var8   in out    varchar2,
    p_var9   in out    varchar2,
    p_cursor out SYS_REFCURSOR
)
as
    v1 varchar2(16);
    v2 varchar2(16);
    v3 varchar2(16);
    v4 varchar2(16);
    v5 varchar2(16);
    v6 varchar2(16);
    v7 varchar2(16);
    v8 varchar2(16);
    v9 varchar2(16);
    v10 varchar2(16);
    v11 varchar2(16);
    m1 varchar2(16);
    m2 varchar2(16);
    m3 varchar2(16);
    m4 varchar2(16);

begin
if p_funcCode = 'CardSaleStat' then -- 售卡统计
    DELETE FROM TMP_FI_STAT;

    -- 自营点售卡统计
    for v_cur in (
        select t.departno, t.departname
        from TD_M_INSIDEDEPART t
        where t.departno in ('0006','0007','0008','0009','0011','0004','0103','0016','0017','0018')
    )
    loop
        SELECT SUM(CARDDEPOSITFEE + CARDSERVFEE) INTO v2 -- 总金额
        FROM TF_B_TRADEFEE
        WHERE TRADETYPECODE in ('01', '23', '31', '32','70','71','72','7A','7B')--20110923添加残疾人月票开卡补卡'7A','7B'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v3  -- 联名卡
        FROM TF_B_TRADE
        WHERE TRADETYPECODE = '01'
        AND CARDTYPECODE in ('11','12') AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v4 -- 非联名卡
        FROM TF_B_TRADE
        WHERE TRADETYPECODE = '01'
        AND CARDTYPECODE IN ('01','02') AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v5 -- 礼金卡
        FROM TF_B_TRADE
        WHERE TRADETYPECODE = '01'
        AND CARDTYPECODE IN ('03','04','05') AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v6 -- 月票卡
        FROM TF_B_TRADE
        WHERE TRADETYPECODE IN ('31','32','70','71','7A','7B') AND CANCELTAG = '0'--20110923添加残疾人月票开卡补卡'7A','7B'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v7 -- 高龄卡
        FROM TF_B_TRADE
        WHERE TRADETYPECODE IN ('23','72') AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v8 -- 移动Simpass卡
        FROM TF_B_TRADE
        WHERE TRADETYPECODE = '01'
        AND CARDTYPECODE = '21' AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v9 -- 电信Simpass卡
        FROM TF_B_TRADE WHERE TRADETYPECODE = '01'
        AND CARDTYPECODE = '22' AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT TO_NUMBER(v3) + TO_NUMBER(v4) + TO_NUMBER(v5)
             + TO_NUMBER(v6) + TO_NUMBER(v7) + TO_NUMBER(v8)
             + TO_NUMBER(v9) INTO v1 -- 售卡总数
        FROM DUAL;

        INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5, f6, f7, f8, f9)
        VALUES (v_cur.departname, v1, nvl(v2, 0), v3, v4, v5, v6, v7, v8, v9);
    end loop;

    -- 银行售卡统计
    SELECT COUNT(1), SUM(DEPOSIT) INTO v1, v2
    FROM TF_OUTSELL_COMMIT
    WHERE CARDTYPECODE in ('11','12') AND SELLLOCNO LIKE '5%'
    AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
    AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1;

    INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5, f6, f7, f8, f9)
    VALUES ('农业银行', v1, nvl(v2, 0), v1, 0, 0, 0, 0, 0, 0);

    INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5, f6, f7, f8, f9)
    SELECT '合计',
           SUM(TO_NUMBER(f1)), SUM(TO_NUMBER(f2)), SUM(TO_NUMBER(f3)),
           SUM(TO_NUMBER(f4)), SUM(TO_NUMBER(f5)), SUM(TO_NUMBER(f6)),
           SUM(TO_NUMBER(f7)), SUM(TO_NUMBER(f8)), SUM(TO_NUMBER(f9))
    FROM   TMP_FI_STAT;

    open p_cursor for
    select f0 "网点"      , f1 "售卡总数(张)", TO_NUMBER(f2)/100.0 "总金额(元)",
           f3 "联名卡(张)", f4 "非联名卡(张)", f5 "礼金卡(张)",
           f6 "月票卡(张)", f7 "高龄卡(张)"  , f8 "移动Simpass卡(张)",
           f9 "电信Simpass卡(张)"
    from   TMP_FI_STAT
    ;

elsif p_funcCode = 'ChangeCardStat' then -- 换卡统计
    DELETE FROM TMP_FI_STAT;
    for v_cur in (
        select t.departno, t.departname
        from TD_M_INSIDEDEPART t
        where t.departno in ('0006','0007','0008','0009','0011','0004','0103','0016','0017','0018')
    )
    loop

        SELECT COUNT(1) INTO v2 --自然损坏卡
        FROM TF_B_TRADE
        WHERE TRADETYPECODE IN ('03','73','74','75','7C')----20110923添加残疾人月票换卡'7C'
        AND REASONCODE IN ('13','15') AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v3 -- 人为损坏卡
        FROM TF_B_TRADE
        WHERE TRADETYPECODE IN ('03','73','74','75','7C')----20110923添加残疾人月票换卡'7C'
        AND REASONCODE IN ('12','14') AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT TO_NUMBER(v2) + TO_NUMBER(v3) INTO v1 FROM DUAL; -- 换卡总数

        SELECT COUNT(1) INTO v4 -- 联名卡换卡
        FROM TF_B_TRADE WHERE TRADETYPECODE = '03'
        AND (OLDCARDNO LIKE '____11%' or OLDCARDNO LIKE '____12%') AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v5 -- 非联名卡换卡
        FROM TF_B_TRADE WHERE TRADETYPECODE = '03'
        AND (OLDCARDNO LIKE '____01%' OR OLDCARDNO LIKE '____02%') AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v6 -- 礼金卡换卡
        FROM TF_B_TRADE WHERE TRADETYPECODE = '03'
        AND CARDTYPECODE IN ('03','04','05') AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v7 -- 月票卡换卡
        FROM TF_B_TRADE
        WHERE TRADETYPECODE IN ('73','74','7C') AND CANCELTAG = '0' ----20110923添加残疾人月票换卡'7C'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v8 -- 高龄卡换卡
        FROM TF_B_TRADE
        WHERE TRADETYPECODE = '75' AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v9 -- 移动Simpass卡换卡
        FROM TF_B_TRADE WHERE TRADETYPECODE = '03'
        AND CARDTYPECODE = '21' AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v10 -- 电信Simpass卡换卡
        FROM TF_B_TRADE WHERE TRADETYPECODE = '03'
        AND CARDTYPECODE = '22' AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT TO_NUMBER(v3) + TO_NUMBER(v2)  INTO v1 -- 换卡总数
        FROM DUAL;

        INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10)
        VALUES (v_cur.departname, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10);
    end loop;

    INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10)
    SELECT '合计',
           SUM(TO_NUMBER(f1)), SUM(TO_NUMBER(f2)), SUM(TO_NUMBER(f3)),
           SUM(TO_NUMBER(f4)), SUM(TO_NUMBER(f5)), SUM(TO_NUMBER(f6)),
           SUM(TO_NUMBER(f7)), SUM(TO_NUMBER(f8)), SUM(TO_NUMBER(f9)),
           SUM(TO_NUMBER(f10))
    FROM   TMP_FI_STAT;

    open p_cursor for
    select f0 "网点"      , f1 "换卡总数(张)", f2 "自然损坏数(张)",
           f3 "人为损坏数(张)", f4 "联名卡(张)", f5 "非联名卡(张)",
           f6 "礼金卡(张)", f7 "月票卡(张)", f8 "高龄卡(张)",
           f9 "移动Simpass卡(张)", f10 "电信Simpass卡(张)"
    from   TMP_FI_STAT
    ;

elsif p_funcCode = 'ReturnCardStat' then -- 退卡统计
    DELETE FROM TMP_FI_STAT;
    for v_cur in (
        select t.departno, t.departname
        from TD_M_INSIDEDEPART t
        where t.departno in ('0006','0007','0008','0009','0011','0004','0103','0016','0017','0018')
    )
    loop

        SELECT COUNT(1) INTO v2 --联名卡退卡
        FROM TF_B_TRADE WHERE TRADETYPECODE = '05'
        AND CARDTYPECODE in ('11','12') AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v3 -- 非联名卡退卡
        FROM TF_B_TRADE
        WHERE CARDNO NOT IN (SELECT CARDNO FROM TF_F_CARDCOUNTACC)
        AND TRADETYPECODE = '05' AND CARDTYPECODE IN ('01','02') AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v4 -- 礼金卡退卡
        FROM TF_B_TRADE WHERE TRADETYPECODE = '05'
        AND CARDTYPECODE IN ('03','04','05') AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v5 -- 月票卡退卡
        FROM TF_B_TRADE a,TF_F_CARDCOUNTACC b
        WHERE a.CARDNO = b.CARDNO AND b.APPTYPE in ('01','02','04')--20110923添加残疾人月票退卡'04'
        AND a.CANCELTAG = '0' AND a.TRADETYPECODE = '05'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v6 -- 高龄卡退卡
        FROM TF_B_TRADE a,TF_F_CARDCOUNTACC b
        WHERE a.CARDNO = b.CARDNO AND b.APPTYPE = '03'
        AND a.CANCELTAG = '0' AND a.TRADETYPECODE = '05'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v7 --移动Simpass退卡
        FROM TF_B_TRADE WHERE TRADETYPECODE = '05'
        AND CARDTYPECODE = '21' AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v8 --电信Simpass退卡
        FROM TF_B_TRADE WHERE TRADETYPECODE = '05'
        AND CARDTYPECODE = '22' AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT TO_NUMBER(v2) + TO_NUMBER(v3) + TO_NUMBER(v4)
             + TO_NUMBER(v5) + TO_NUMBER(v6) + TO_NUMBER(v7)
             + TO_NUMBER(v8) INTO v1 -- 退卡总数
        FROM DUAL;

        INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5, f6, f7, f8)
        VALUES (v_cur.departname, v1, v2, v3, v4, v5, v6, v7, v8);
    end loop;

    INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5, f6, f7, f8)
    SELECT '合计',
           SUM(TO_NUMBER(f1)), SUM(TO_NUMBER(f2)), SUM(TO_NUMBER(f3)),
           SUM(TO_NUMBER(f4)), SUM(TO_NUMBER(f5)), SUM(TO_NUMBER(f6)),
           SUM(TO_NUMBER(f7)), SUM(TO_NUMBER(f8))
    FROM   TMP_FI_STAT;

    open p_cursor for
    select f0 "网点"      , f1 "退卡总数(张)", f2 "联名卡(张)", f3 "非联名卡(张)",
           f4 "礼金卡(张)", f5 "月票卡(张)", f6 "高龄卡(张)",
           f7 "移动Simpass卡(张)", f8 "电信Simpass卡(张)"
    from   TMP_FI_STAT
    ;
elsif p_funcCode = 'ChargeCardStat' then -- 充值统计
    DELETE FROM TMP_FI_STAT;

    -- 1. 首先查营业厅的充值
    for v_cur in (
        select t.departno, t.departname
        from TD_M_INSIDEDEPART t
        where t.departno in ('0006','0007','0008','0009','0011','0004','0103','0016','0017','0018')
    )
    loop
        -- todo:
        SELECT  SUM(SUPPLYMONEY) INTO v4
        FROM TF_B_TRADEFEE
        WHERE TRADETYPECODE IN ('02', 'B1')
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT COUNT(1) INTO v3
        FROM TF_B_TRADE
        WHERE TRADETYPECODE = '02' AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND OPERATEDEPARTID = v_cur.departno;

        SELECT SUM(MONEY), SUM(AMOUNT) INTO v6, v5
        FROM TF_XFC_SELL a, TD_M_INSIDESTAFF b
        WHERE TRADETYPECODE = '80' AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
        AND a.STAFFNO = b.STAFFNO AND b.DEPARTNO = v_cur.departno;

        SELECT NVL(v4, 0), NVL(v5, 0), NVL(v6, 0) INTO v4, v5, v6 FROM DUAL;

        SELECT TO_NUMBER(v3) + TO_NUMBER(v5) INTO v1 -- 充值总数
        FROM DUAL;

        SELECT TO_NUMBER(v4) + TO_NUMBER(v6) INTO v2 -- 充值总金额
        FROM DUAL;


        INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11)
        VALUES (v_cur.departname, v1, v2, v3, v4, v5, v6, 0, 0, 0, 0, 0);
    end loop;

    -- 2. 查大客户中心的企服卡充值
    SELECT SUM(AMOUNT), SUM(TOTALMONEY) INTO v5, v6
    FROM TF_XFC_BATCHSELL
    WHERE TRADETYPECODE = '84' --充值卡直销
    AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
    AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1
    AND STAFFNO IN (SELECT STAFFNO FROM TD_M_INSIDESTAFF WHERE DEPARTNO = '0004');

    SELECT SUM(AMOUNT), SUM(SUPPLYMONEY) INTO v9, v10
    FROM TF_F_SUPPLYSUM
    WHERE STATECODE = '2' AND SUPPLYDEPARTNO = '0004'--企服卡充值
    AND SUPPLYTIME >= TO_DATE(p_var1,'yyyyMMdd')
    AND SUPPLYTIME <= TO_DATE(p_var2,'yyyyMMdd') + 1;

    SELECT TO_NUMBER(v5) + TO_NUMBER(v9) INTO v1 -- 充值总数
    FROM DUAL;

    SELECT TO_NUMBER(v6) + TO_NUMBER(v10) INTO v2 -- 充值总金额
    FROM DUAL;

    INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11)
    VALUES('大客户中心',       v1,  v2,  0,  0, v5, v6,  0,  0, v9, v10, 0);

    -- 3. 银行等充值
    for v_cur in (
        select t.BALUNITNO, SUBSTR(t.BALUNIT, 1, 8) BALUNIT, m.RULEEXP
        from TF_SELSUP_BALUNIT t, TD_M_SELSUP_LOCRULE m
        where t.BALUNITNO in ('0Z00000A','0Z00000E','0Z00000L')
        AND t.BALUNITNO = m.BALUNITNO
    )
    loop
        SELECT SUM(TRADEMONEY), COUNT(TRADEMONEY) INTO v4, v3
        FROM TQ_SUPPLY_RIGHT
        WHERE TRADETYPECODE = '02' AND SUPPLYLOCNO LIKE v_cur.RULEEXP --现金充值
        AND TRADEDATE BETWEEN p_var1 and p_var2 AND BANKCARDNO is null;

        SELECT SUM(TRADEMONEY), COUNT(TRADEMONEY) INTO v8, v7
        FROM TQ_SUPPLY_RIGHT
        WHERE TRADETYPECODE = '02' AND SUPPLYLOCNO LIKE v_cur.RULEEXP --圈存充值
        AND TRADEDATE BETWEEN p_var1 and p_var2 AND BANKCARDNO is not null;

        SELECT SUM(TRADEMONEY), COUNT(TRADEMONEY) INTO v6, v5
        FROM TQ_SUPPLY_RIGHT
        WHERE TRADETYPECODE = '14' AND SUPPLYLOCNO LIKE v_cur.RULEEXP
        AND TRADEDATE BETWEEN p_var1 and p_var2; --充值卡充值

        SELECT SUM(TRADEMONEY), COUNT(TRADEMONEY) INTO v10, v9
        FROM TQ_SUPPLY_RIGHT
        WHERE TRADETYPECODE = '21' AND SUPPLYLOCNO LIKE v_cur.RULEEXP
        AND TRADEDATE BETWEEN p_var1 and p_var2;--企服卡充值

        SELECT NVL(v3, 0), NVL(v4, 0), NVL(v5, 0) INTO v3, v4, v5 FROM DUAL;
        SELECT NVL(v6, 0), NVL(v9, 0), NVL(v10, 0) INTO v6, v9, v10 FROM DUAL;
        SELECT NVL(v7, 0), NVL(v8, 0) INTO v7, v8 FROM DUAL;

        SELECT TO_NUMBER(v3) + TO_NUMBER(v5) + TO_NUMBER(v7) + TO_NUMBER(v9) INTO v1 -- 充值总数
        FROM DUAL;

        SELECT TO_NUMBER(v4) + TO_NUMBER(v6) + TO_NUMBER(v8) + TO_NUMBER(v10) INTO v2 -- 充值总金额
        FROM DUAL;

        INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11)
        VALUES (v_cur.BALUNIT, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, 0);
    end loop;

    -- 4. 电信等充值
    for v_cur in (
        select t.BALUNITNO, SUBSTR(t.BALUNIT, 1, 8) BALUNIT, m.RULEEXP
        from TF_SELSUP_BALUNIT t, TD_M_SELSUP_LOCRULE m
        where t.BALUNITNO in ('0D000100')
        AND t.BALUNITNO = m.BALUNITNO
    )
    loop
        SELECT SUM(TRADEMONEY), COUNT(TRADEMONEY), SUM(TRADEMONEY)*0.00007 INTO v4, v3, v11
        FROM TQ_SUPPLY_RIGHT
        WHERE TRADETYPECODE = '02' AND SUPPLYLOCNO LIKE v_cur.RULEEXP --现金充值
        AND TRADEDATE BETWEEN p_var1 and p_var2 AND BANKCARDNO is null;

        SELECT SUM(TRADEMONEY), COUNT(TRADEMONEY) INTO v8, v7
        FROM TQ_SUPPLY_RIGHT
        WHERE TRADETYPECODE = '02' AND SUPPLYLOCNO LIKE v_cur.RULEEXP --圈存充值
        AND TRADEDATE BETWEEN p_var1 and p_var2 AND BANKCARDNO is not null;

        SELECT SUM(TRADEMONEY), COUNT(TRADEMONEY) INTO v6, v5
        FROM TQ_SUPPLY_RIGHT
        WHERE TRADETYPECODE = '14' AND SUPPLYLOCNO LIKE v_cur.RULEEXP
        AND TRADEDATE BETWEEN p_var1 and p_var2; --充值卡充值

        SELECT SUM(TRADEMONEY), COUNT(TRADEMONEY) INTO v10, v9
        FROM TQ_SUPPLY_RIGHT
        WHERE TRADETYPECODE = '21' AND SUPPLYLOCNO LIKE v_cur.RULEEXP
        AND TRADEDATE BETWEEN p_var1 and p_var2;--企服卡充值

        SELECT NVL(v3, 0), NVL(v4, 0), NVL(v5, 0) INTO v3, v4, v5 FROM DUAL;
        SELECT NVL(v6, 0), NVL(v9, 0), NVL(v10, 0) INTO v6, v9, v10 FROM DUAL;
        SELECT NVL(v7, 0), NVL(v8, 0), NVL(v11, 0) INTO v7, v8, v11 FROM DUAL;

        SELECT TO_NUMBER(v3) + TO_NUMBER(v5) + TO_NUMBER(v7) + TO_NUMBER(v9) INTO v1 -- 充值总数
        FROM DUAL;

        SELECT TO_NUMBER(v4) + TO_NUMBER(v6) + TO_NUMBER(v8) + TO_NUMBER(v10) INTO v2 -- 充值总金额
        FROM DUAL;

        INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11)
        VALUES (v_cur.BALUNIT, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11);
    end loop;

    -- 4 信息亭充值
    SELECT SUM(TRADEMONEY), COUNT(TRADEMONEY) INTO v4, v3
    FROM TQ_SUPPLY_RIGHT
    WHERE TRADETYPECODE = '02' AND BALUNITNO = '0C000008'--现金充值
    AND TRADEDATE BETWEEN p_var1 and p_var2;

    SELECT SUM(TRADEMONEY), COUNT(TRADEMONEY) INTO v6, v5
    FROM TQ_SUPPLY_RIGHT
    WHERE TRADETYPECODE = '14' AND SUPPLYLOCNO = '0008' AND SAMNO LIKE '0c%'
    AND TRADEDATE BETWEEN p_var1 and p_var2; --充值卡充值

    SELECT SUM(TRADEMONEY), COUNT(TRADEMONEY) INTO  v10, v9
    FROM TQ_SUPPLY_RIGHT
    WHERE TRADETYPECODE = '21' AND SUPPLYLOCNO = '0008' AND SAMNO LIKE '0c%'
    AND TRADEDATE BETWEEN p_var1 and p_var2;--企服卡充值

    SELECT NVL(v3, 0), NVL(v4, 0), NVL(v5, 0) INTO v3, v4, v5 FROM DUAL;
    SELECT NVL(v6, 0), NVL(v9, 0), NVL(v10, 0) INTO v6, v9, v10 FROM DUAL;

    SELECT TO_NUMBER(v3) + TO_NUMBER(v5) + TO_NUMBER(v9) INTO v1 -- 充值总数
    FROM DUAL;

    SELECT TO_NUMBER(v4) + TO_NUMBER(v6) + TO_NUMBER(v10) INTO v2 -- 充值总金额
    FROM DUAL;

    --佣金计算
    select sum(times)*1.0 into m1
         from (select COUNT(1) times,cardno,samno
                                      from tq_supply_right
                                     where tradetypecode = '02'
                                       and substr(balunitno,1,2)='0C'
                                       and trademoney>=10000
                                       and ( p_var1 is null or p_var1 = '' or tradedate >= p_var1)
                                       and ( p_var2 is null or p_var2 = '' or tradedate <= p_var2)
                                  group by cardno,samno )
                                  where times <=5;

    select sum(money)/10000.0 into m2
         from  (select COUNT(1) times,sum(trademoney) money,cardno,samno
                                     from tq_supply_right
                                    where tradetypecode = '02'
                                      and substr(balunitno,1,2)='0C'
                                      and trademoney<10000
                                      and ( p_var1 is null or p_var1 = '' or tradedate >= p_var1)
                                      and ( p_var2 is null or p_var2 = '' or tradedate <= p_var2)
                                 group by cardno,samno )
                                  where times <=5;

    select COUNT(1)*5.0 into m3
       from (select cardno,samno,sum(trademoney)/10000.0 money
              from TQ_SUPPLY_RIGHT
             where substr(BALUNITNO,1,2)='0C'
               and (cardno,samno) in (select cardno,samno from
                                        (select COUNT(1) times,cardno,samno
                                           from tq_supply_right
                                          where tradetypecode = '02'
                                            and substr(balunitno,1,2)='0C'
                                            and ( p_var1 is null or p_var1 = '' or tradedate >= p_var1)
                                            and ( p_var2 is null or p_var2 = '' or tradedate <= p_var2)
                                       group by cardno,samno )
                                       where times >5)
          group by cardno,samno)
      where money>5;

    select nvl(sum(money),0) into m4
        from (select cardno,samno,sum(trademoney)/10000.0 money
                from TQ_SUPPLY_RIGHT
               where substr(BALUNITNO,1,2)='0C'
                 and (cardno,samno) in (select cardno,samno from
                                          (select COUNT(1) times,cardno,samno
                                             from tq_supply_right
                                            where tradetypecode = '02'
                                              and substr(balunitno,1,2)='0C'
                                              and ( p_var1 is null or p_var1 = '' or tradedate >= p_var1)
                                              and ( p_var2 is null or p_var2 = '' or tradedate <= p_var2)
                                         group by cardno,samno )
                                         where times >5)
            group by cardno,samno)
       where money<=5;

    SELECT TO_NUMBER(m1) + TO_NUMBER(m2) + TO_NUMBER(m3) + TO_NUMBER(m4) INTO v11 -- 佣金总额
    FROM DUAL;

    INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11)
    VALUES ('信息亭代理充值', v1, v2, v3, v4, v5, v6, 0, 0, v9, v10, v11);

    -- 合计
    INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11)
    SELECT '合计',
           SUM(TO_NUMBER(f1)), SUM(TO_NUMBER(f2)), SUM(TO_NUMBER(f3)),
           SUM(TO_NUMBER(f4)), SUM(TO_NUMBER(f5)), SUM(TO_NUMBER(f6)),
           SUM(TO_NUMBER(f7)), SUM(TO_NUMBER(f8)), SUM(TO_NUMBER(f9)),
           SUM(TO_NUMBER(f10)), SUM(f11)
    FROM   TMP_FI_STAT;

    open p_cursor for
    select f0 "网点"      ,
           f1 "总笔数(笔)", TO_NUMBER(f2)/100.0 "总金额(元)", f3 "现金(笔)", TO_NUMBER(f4)/100 "现金金额(元)",
           f5 "充值卡(张)", TO_NUMBER(f6)/100.0 "充值卡金额(元)"  , f7 "圈存(笔)", TO_NUMBER(f8)/100.0 "圈存金额(元)",
           f9 "企服卡(笔)", TO_NUMBER(f10)/100.0 "企服卡金额(元)", TO_NUMBER(f11) "佣金(元)"
    from   TMP_FI_STAT
    ;

elsif p_funcCode = 'Cardusestate' then
    DELETE FROM TMP_FI_STAT;
    for v_cur in (
        select t.cardtypecode, t.cardtypename
        from td_m_cardtype t
        where t.cardtypecode in ('13','11','12','21','22')
    )
    loop
        SELECT COUNT(1) INTO v1 FROM TF_F_CARDREC
        WHERE SELLTIME BETWEEN TO_DATE(p_var1,'yyyyMMdd') AND TO_DATE(p_var2,'yyyyMMdd') + 1
        AND USETAG = '1' AND CARDTYPECODE = v_cur.cardtypecode;

        SELECT COUNT(1) INTO v2 FROM TF_F_CARDREC
        WHERE CARDNO IN (SELECT CARDNO FROM TF_F_CARDREC
                         WHERE SELLTIME BETWEEN TO_DATE(p_var1,'yyyyMMdd') AND TO_DATE(p_var2,'yyyyMMdd') + 1
                         AND USETAG = '1' AND CARDTYPECODE = v_cur.cardtypecode)
        AND CARDNO IN (SELECT CARDNO FROM TQ_TRADE_RIGHT
                       WHERE DEALTIME between add_months(TO_DATE(p_var2,'yyyyMMdd') + 1,-3) and TO_DATE(p_var2,'yyyyMMdd') + 1
                       AND SUBSTR(CARDNO,5,2) = v_cur.cardtypecode);

        SELECT v1 - v2 INTO v3 FROM DUAL;

        SELECT COUNT(1) INTO v4
        FROM TF_B_TRADE WHERE TRADETYPECODE = '05'
        AND CARDTYPECODE = v_cur.cardtypecode AND CANCELTAG = '0'
        AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
        AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1;

        SELECT nvl(SUM(CARDACCMONEY),0) INTO v5 FROM TF_F_CARDEWALLETACC
        WHERE CARDNO IN (SELECT CARDNO FROM TF_F_CARDREC
                         WHERE SELLTIME BETWEEN TO_DATE(p_var1,'yyyyMMdd') AND TO_DATE(p_var2,'yyyyMMdd') + 1
                         AND USETAG = '1' AND CARDTYPECODE = v_cur.cardtypecode);

        INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5)
        VALUES (substr(v_cur.cardtypename,1,8), v1, v2, v3, v4, v5);
    end loop;

    SELECT COUNT(1) INTO v1 FROM TF_F_CARDREC
    WHERE SELLTIME BETWEEN TO_DATE(p_var1,'yyyyMMdd') AND TO_DATE(p_var2,'yyyyMMdd') + 1
    AND USETAG = '1' AND CARDTYPECODE in ('01','02');

    SELECT COUNT(1) INTO v2 FROM TF_F_CARDREC
    WHERE CARDNO IN (SELECT CARDNO FROM TF_F_CARDREC
                     WHERE SELLTIME BETWEEN TO_DATE(p_var1,'yyyyMMdd') AND TO_DATE(p_var2,'yyyyMMdd') + 1
                     AND USETAG = '1' AND CARDTYPECODE in ('01','02'))
    AND CARDNO IN (SELECT CARDNO FROM TQ_TRADE_RIGHT
                   WHERE DEALTIME between add_months(TO_DATE(p_var2,'yyyyMMdd') + 1,-3) and TO_DATE(p_var2,'yyyyMMdd') + 1
                   AND SUBSTR(CARDNO,5,2) in ('01','02'));

    SELECT v1 - v2 INTO v3 FROM DUAL;

    SELECT COUNT(1) INTO v4
    FROM TF_B_TRADE WHERE TRADETYPECODE = '05'
    AND CARDTYPECODE in ('01','02') AND CANCELTAG = '0'
    AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
    AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1;

    SELECT nvl(SUM(CARDACCMONEY),0) INTO v5 FROM TF_F_CARDEWALLETACC
    WHERE CARDNO IN (SELECT CARDNO FROM TF_F_CARDREC
                     WHERE SELLTIME BETWEEN TO_DATE(p_var1,'yyyyMMdd') AND TO_DATE(p_var2,'yyyyMMdd') + 1
                     AND USETAG = '1' AND CARDTYPECODE in ('01','02'));

    INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5)
    VALUES ('非联名卡', v1, v2, v3, v4, v5);


    SELECT COUNT(1) INTO v1 FROM TF_F_CARDREC_CNPC
    WHERE SELLTIME BETWEEN TO_DATE(p_var1,'yyyyMMdd') AND TO_DATE(p_var2,'yyyyMMdd') + 1
    AND USETAG = '1' AND substr(cardno,5,4) in ('0402','0403');

    SELECT COUNT(1) INTO v2 FROM TF_F_CARDREC
    WHERE CARDNO IN (SELECT CARDNO FROM TF_F_CARDREC_CNPC
                     WHERE SELLTIME BETWEEN TO_DATE(p_var1,'yyyyMMdd') AND TO_DATE(p_var2,'yyyyMMdd') + 1
                     AND USETAG = '1' AND substr(cardno,5,4) in ('0402','0403'))
    AND CARDNO IN (SELECT CARDNO FROM TQ_TRADE_RIGHT
                   WHERE DEALTIME between add_months(TO_DATE(p_var2,'yyyyMMdd') + 1,-3) and TO_DATE(p_var2,'yyyyMMdd') + 1
                   AND substr(cardno,5,4) in ('0402','0403'));

    SELECT v1 - v2 INTO v3 FROM DUAL;

    SELECT COUNT(1) INTO v4
    FROM TF_B_TRADE WHERE TRADETYPECODE = '05'
    AND substr(cardno,5,4) in ('0402','0403') AND CANCELTAG = '0'
    AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
    AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1;

    SELECT nvl(SUM(CARDACCMONEY),0) INTO v5 FROM TF_F_CARDEWALLETACC_CNPC
    WHERE CARDNO IN (SELECT CARDNO FROM TF_F_CARDREC_CNPC
                     WHERE SELLTIME BETWEEN TO_DATE(p_var1,'yyyyMMdd') AND TO_DATE(p_var2,'yyyyMMdd') + 1
                     AND USETAG = '1' AND substr(cardno,5,4) in ('0402','0403'));

    INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5)
    VALUES ('中石油卡', v1, v2, v3, v4, v5);


    SELECT COUNT(1) INTO v1 FROM TF_F_CARDREC
    WHERE SELLTIME BETWEEN TO_DATE(p_var1,'yyyyMMdd') AND TO_DATE(p_var2,'yyyyMMdd') + 1
    AND USETAG = '1' AND substr(cardno,5,4) in ('0405','0408');

    SELECT COUNT(1) INTO v2 FROM TF_F_CARDREC
    WHERE CARDNO IN (SELECT CARDNO FROM TF_F_CARDREC
                     WHERE SELLTIME BETWEEN TO_DATE(p_var1,'yyyyMMdd') AND TO_DATE(p_var2,'yyyyMMdd') + 1
                     AND USETAG = '1' AND substr(cardno,5,4) in ('0405','0408'))
    AND CARDNO IN (SELECT CARDNO FROM TQ_TRADE_RIGHT
                   WHERE DEALTIME between add_months(TO_DATE(p_var2,'yyyyMMdd') + 1,-3) and TO_DATE(p_var2,'yyyyMMdd') + 1
                   AND substr(cardno,5,4) in ('0405','0408'));

    SELECT v1 - v2 INTO v3 FROM DUAL;

    SELECT COUNT(1) INTO v4
    FROM TF_B_TRADE WHERE TRADETYPECODE = '05'
    AND substr(cardno,5,4) in ('0405','0408') AND CANCELTAG = '0'
    AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
    AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1;

    SELECT nvl(SUM(CARDACCMONEY),0) INTO v5 FROM TF_F_CARDEWALLETACC
    WHERE CARDNO IN (SELECT CARDNO FROM TF_F_CARDREC
                     WHERE SELLTIME BETWEEN TO_DATE(p_var1,'yyyyMMdd') AND TO_DATE(p_var2,'yyyyMMdd') + 1
                     AND USETAG = '1' AND substr(cardno,5,4) in ('0405','0408'));

    INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5)
    VALUES ('中移动VIP卡', v1, v2, v3, v4, v5);


    SELECT COUNT(1) INTO v1 FROM TF_F_CARDREC
    WHERE SELLTIME BETWEEN TO_DATE(p_var1,'yyyyMMdd') AND TO_DATE(p_var2,'yyyyMMdd') + 1
    AND USETAG = '1' AND substr(cardno,5,4) in ('0401', '0301', '0501');

    SELECT COUNT(1) INTO v2 FROM TF_F_CARDREC
    WHERE CARDNO IN (SELECT CARDNO FROM TF_F_CARDREC
                     WHERE SELLTIME BETWEEN TO_DATE(p_var1,'yyyyMMdd') AND TO_DATE(p_var2,'yyyyMMdd') + 1
                     AND USETAG = '1' AND substr(cardno,5,4) in ('0401', '0301', '0501'))
    AND CARDNO IN (SELECT CARDNO FROM TQ_TRADE_RIGHT
                   WHERE DEALTIME between add_months(TO_DATE(p_var2,'yyyyMMdd') + 1,-3) and TO_DATE(p_var2,'yyyyMMdd') + 1
                   AND substr(cardno,5,4) in ('0401', '0301', '0501'));

    SELECT v1 - v2 INTO v3 FROM DUAL;

    SELECT COUNT(1) INTO v4
    FROM TF_B_TRADE WHERE TRADETYPECODE = '05'
    AND substr(cardno,5,4) in ('0401', '0301', '0501') AND CANCELTAG = '0'
    AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
    AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1;

    SELECT nvl(SUM(CARDACCMONEY),0) INTO v5 FROM TF_F_CARDEWALLETACC
    WHERE CARDNO IN (SELECT CARDNO FROM TF_F_CARDREC
                     WHERE SELLTIME BETWEEN TO_DATE(p_var1,'yyyyMMdd') AND TO_DATE(p_var2,'yyyyMMdd') + 1
                     AND USETAG = '1' AND substr(cardno,5,4) in ('0401', '0301', '0501'));

    INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5)
    VALUES ('礼金卡', v1, v2, v3, v4, v5);

    SELECT COUNT(1) INTO v1 -- 月票卡
    FROM TF_B_TRADE
    WHERE TRADETYPECODE IN ('31','32','70','71') AND CANCELTAG = '0'
    AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
    AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1;

    SELECT COUNT(1) INTO v2 FROM TF_F_CARDREC
    WHERE CARDNO IN (SELECT cardno FROM TF_B_TRADE
                     WHERE TRADETYPECODE IN ('31','32','70','71') AND CANCELTAG = '0'
                     AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
                     AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1)
    AND CARDNO IN (SELECT CARDNO FROM TQ_TRADE_RIGHT
                   WHERE DEALTIME between add_months(TO_DATE(p_var2,'yyyyMMdd') + 1,-3) and TO_DATE(p_var2,'yyyyMMdd') + 1);

    SELECT v1 - v2 INTO v3 FROM DUAL;

    SELECT COUNT(1) INTO v4 -- 月票卡退卡
    FROM TF_B_TRADE a,TF_F_CARDCOUNTACC b
    WHERE a.CARDNO = b.CARDNO AND b.APPTYPE in ('01','02','04')--20110923添加残疾人月票类型'04'
    AND a.CANCELTAG = '0' AND a.TRADETYPECODE = '05'
    AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
    AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1;

    SELECT nvl(SUM(CARDACCMONEY),0) INTO v5 FROM TF_F_CARDEWALLETACC
    WHERE CARDNO IN (SELECT cardno FROM TF_B_TRADE
                     WHERE TRADETYPECODE IN ('31','32','70','71','7A','7B') AND CANCELTAG = '0'
                     AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
                     AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1);

    INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5)
    VALUES ('月票卡', v1, v2, v3, v4, v5);



    SELECT COUNT(1) INTO v1 -- 高龄卡
    FROM TF_B_TRADE
    WHERE TRADETYPECODE IN ('23','72') AND CANCELTAG = '0'
    AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
    AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1;

    SELECT COUNT(1) INTO v2 FROM TF_F_CARDREC
    WHERE CARDNO IN (SELECT cardno FROM TF_B_TRADE
                     WHERE TRADETYPECODE IN ('23','72') AND CANCELTAG = '0'
                     AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
                     AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1)
    AND CARDNO IN (SELECT CARDNO FROM TQ_TRADE_RIGHT
                   WHERE DEALTIME between add_months(TO_DATE(p_var2,'yyyyMMdd') + 1,-3) and TO_DATE(p_var2,'yyyyMMdd') + 1);

    SELECT v1 - v2 INTO v3 FROM DUAL;

    SELECT COUNT(1) INTO v4 -- 高龄卡退卡
    FROM TF_B_TRADE a,TF_F_CARDCOUNTACC b
    WHERE a.CARDNO = b.CARDNO AND b.APPTYPE = '03'
    AND a.CANCELTAG = '0' AND a.TRADETYPECODE = '05'
    AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
    AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1;

    SELECT nvl(SUM(CARDACCMONEY),0) INTO v5 FROM TF_F_CARDEWALLETACC
    WHERE CARDNO IN (SELECT cardno FROM TF_B_TRADE
                     WHERE TRADETYPECODE IN ('23','72') AND CANCELTAG = '0'
                     AND OPERATETIME >= TO_DATE(p_var1,'yyyyMMdd')
                     AND OPERATETIME <= TO_DATE(p_var2,'yyyyMMdd') + 1);

    INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5)
    VALUES ('高龄卡', v1, v2, v3, v4, v5);

    open p_cursor for
    select f0 "卡类型" , f1 "发卡量", f2 "在用卡", f3 "睡眠卡", f4 "退卡",
           case when TO_NUMBER(f1)!=0 then round(TO_NUMBER(f5)/100.0/TO_NUMBER(f1),2) else 0 end  "卡均余额"
    from   TMP_FI_STAT
    ;

elsif p_funcCode = 'groupcuststate' then
    DELETE FROM TMP_FI_STAT;
    for v_cur in (
        select t.CORPNAME, t.CORPCODE
        from TD_GROUP_CUSTOMER t
        where t.usetag = '1'
    )
    loop
        SELECT COUNT(*) into v1 from TD_GROUP_ACCT where CORPNO = v_cur.CORPCODE and usetag = '1';

        select nvl(SUM(SUPPLYMONEY),0) into v2 FROM TF_F_SUPPLYSUM WHERE CORPNO = v_cur.CORPCODE AND STATECODE = '2';

        select NVL(SUM(TOTALMONEY),0) into v3 from TF_XFC_BATCHSELL
        where trim(custname) = trim(v_cur.CORPNAME);

        select nvl(SUM(t.rel_balance),0) INTO v4 from tf_f_cust_acct t, TD_GROUP_ACCT d
        where t.acct_id = d.acct_id and d.CORPNO = v_cur.CORPCODE and d.usetag = '1';

        select nvl(SUM(t.CARDACCMONEY),0) INTO v5 from tf_f_cardewalletacc t, TD_GROUP_ACCT d,tf_f_cust_acct f
        where t.CARDNO = f.iccard_no and f.acct_id = d.acct_id and d.CORPNO = v_cur.CORPCODE and t.usetag = '1';

        INSERT INTO TMP_FI_STAT(f0, f1, f2, f3, f4, f5)
        VALUES (substr(v_cur.CORPNAME,1,8), v1, v2, v3, v4, v5);

        open p_cursor for
        select f0 "单位" , f1 "企服卡张数", TO_NUMBER(f2)/100.0 "充值额", TO_NUMBER(f3)/100.0 "充值卡金额",
                TO_NUMBER(f4)/100.0 "后台沉淀总金额", TO_NUMBER(f5)/100.0 "电子钱包总余额"
        from   TMP_FI_STAT
        ;
    end loop;

end if;

end;

/
show errors