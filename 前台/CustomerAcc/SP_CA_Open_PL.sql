/*
	专有账户批量开户提交
*/
CREATE OR REPLACE PROCEDURE SP_CA_Open
(
    P_SESSIONID     VARCHAR2, -- Session ID
    p_groupCode     char,  -- Group Code
    p_oldFlag       char,  -- Open with old cards?
    p_currOper      char,  -- Current Operator
    p_currDept      char,  -- Current Operator's Department
    p_retCode       out char, -- Return Code
    p_retMsg        out varchar2  -- Return Message
)
AS
    v_quantity      int;
    v_soldQuantity  int;
    v_today         date := sysdate;
	  v_seqNo         CHAR(16);  
    v_ex            EXCEPTION;
    v_depositFee    int;
    v_servFee       int;
    v_chargeFee     int;
    v_totalFee      int;

BEGIN

    -- 1) Check if the group code is OK
    BEGIN
        SELECT 1 INTO v_quantity
        FROM TD_GROUP_CUSTOMER
        WHERE CORPCODE = p_groupCode AND USETAG = '1';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_retCode := 'A004P01B01'; p_retMsg  := '无法识别的集团客户编码';
            RETURN;
    END;
    
    BEGIN
        FOR v_cur in (SELECT f1 FROM TMP_COMMON where F13 = P_SESSIONID)
        LOOP
            SP_AccCheck(v_cur.f1, p_currOper, p_currDept, p_retCode, p_retMsg);
            IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
        END LOOP;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK; RETURN;
    END;
    
    SELECT COUNT(*) INTO v_quantity
    FROM TMP_COMMON where F13 = P_SESSIONID;
    
    IF v_quantity IS NULL OR v_quantity <= 0 THEN
        p_retCode := 'A004P01BX1'; p_retMsg  := '没有任何企服卡开卡数据需要处理';
        RETURN;
    END IF;

    -- 2) Check if the cards are already sold before
    SELECT COUNT(*) INTO v_soldQuantity FROM TF_F_CARDREC 
    WHERE CARDSTATE in ('10', '11') -- SOLD
    AND  CARDNO IN (SELECT f1 FROM TMP_COMMON where F13 = P_SESSIONID);

    IF v_quantity != v_soldQuantity THEN
        p_retCode := 'A004P01B02'; p_retMsg  := '存在未售出卡片';
        RETURN;
    END IF;

    SP_GetSeq(seq => v_seqNo);

    -- 3) Record the business
    /*BEGIN
        INSERT INTO TF_B_TRADE
               (TRADEID, CARDNO, TRADETYPECODE, CORPNO,     
                OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
        SELECT  v_seqNo , f1, '22'         , p_groupCode, 
                p_currOper     , p_currDept      , v_today
        FROM   TMP_COMMON where F13 = P_SESSIONID;
        
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P01B03'; p_retMsg  := '记录企服卡开卡操作台帐,' || SQLERRM;
            ROLLBACK; RETURN;
    END;*/
    
    
       
    -- 4) Record the customer info changes
    /*BEGIN
        INSERT INTO TF_B_CUSTOMERCHANGE
            (  TRADEID  , CARDNO, CUSTNAME, CUSTSEX, CUSTBIRTH,
               PAPERTYPECODE, PAPERNO, CUSTADDR, CUSTPOST, CUSTPHONE,CUSTEMAIL,
               CHGTYPECODE  , OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME)
        SELECT v_seqNo  , f1, f2, f3, f4,
               f5    , f6, f7, f8, f9,f10,
               '00'         , p_currOper    , p_currDept      , v_today
        FROM   TMP_COMMON;
        
        IF  SQL%ROWCOUNT != v_quantity THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P01B04'; p_retMsg  := '新增客户资料变更,' || SQLERRM;
            ROLLBACK; RETURN;
    END;*/
    
    -- 旧卡开卡时不查询费用
    IF p_oldFlag = '0' THEN
        SELECT SUM(c.DEPOSIT), SUM(c.CARDCOST)
        INTO   v_depositFee, v_servFee
        FROM   TF_F_CARDREC c
        WHERE  c.CARDNO IN (SELECT f1 FROM TMP_COMMON where F13 = P_SESSIONID);

        SELECT SUM(t.SUPPLYMONEY)
        INTO   v_chargeFee
        FROM   TF_B_TRADEFEE t, TF_B_TRADE d
        WHERE  t.TRADETYPECODE  in ( '02')
        AND    t.TRADEID = d.TRADEID  AND d.CANCELTAG = '0'
        AND    t.CARDNO IN (SELECT f1 FROM TMP_COMMON where F13 = P_SESSIONID);

    END IF;

    if v_depositFee is null then v_depositFee := 0; end if;
    if v_servFee is null then v_servFee := 0; end if;
    if v_chargeFee is null then v_chargeFee := 0; end if;

    v_totalFee := v_depositFee + v_servFee + v_chargeFee;

    -- 5) log the operation
    BEGIN
        INSERT INTO TF_GROUP_SELLSUM
              (ID    , CORPNO    , DEPOSITFEE,  CARDCOST, SUPPLYMONEY, OLDFLAG,
              TOTALMONEY, AMOUNT , SELLSTAFFNO,    SELLDEPARTNO,  SELLTIME, STATECODE)
        VALUES( v_seqNo, p_groupCode, v_depositFee, v_servFee, v_chargeFee, p_oldFlag,
               v_totalFee,v_quantity,p_currOper    , p_currDept    , v_today, '0');
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S004P01B05'; p_retMsg  := '新增专有账户开户总量台帐,' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    BEGIN
       INSERT INTO TF_F_OPENACC
	      (ID,
	       CARDNO,
	       ACCTYPE,
	       STATECODE,
	       CUSTNAME,
	       CUSTBIRTH,
	       PAPERTYPECODE,
	       PAPERNO,
	       CUSTSEX,
	       CUSTPHONE,
	       CUSTTELPHONE,
	       CUSTPOST,
	       CUSTADDR,
	       CUSTEMAIL,
	       OPERATESTAFFNO,
	       OPERATEDEPARTID,
	       OPERATETIME
	       )
	      SELECT V_SEQNO,
	             F1,
	             F14,
	             '0',
				       F2,
				       F4,
				       F5,
				       F6,
				       F3,
				       F9,
				       F10,
				       F8,
				       F7,
				       F11,
				       p_currOper,
				       p_currDept,
				       v_today
	        FROM TMP_COMMON
	        WHERE F13 = P_SESSIONID;
	  
		    IF SQL%ROWCOUNT != v_quantity THEN
		      RAISE V_EX;
		    END IF;
		  EXCEPTION
		    WHEN OTHERS THEN
		      P_RETCODE := 'S006012011';
		      P_RETMSG := '新增专有帐户批量开户明细台帐失败,' || SQLERRM;
		      ROLLBACK;
		      RETURN;
       
    END;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors

