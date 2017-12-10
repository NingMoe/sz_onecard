CREATE OR REPLACE PROCEDURE SP_RELAX_ORDERINPUT
(
	P_RETCODE        	OUT CHAR, 		--RETURN CODE
	P_RETMSG         	OUT VARCHAR2,   --RETURN MESSAGE
    P_ORDERNO			CHAR,			--订单号
	P_ORDERTYPE      CHAR,           --订单类型
  P_ORDERTOTAL    INT,            --订单金额
  P_POSTAGE      INT,            --邮费
  --P_CARDCOST      INT,            --卡费
  --P_FUNCFEE      INT,            --功能费
  --P_DISCOUNT      INT,            --优惠
    P_PAYCANAL      CHAR,           --支付渠道
  P_PAYTRADEID    VARCHAR2,       --支付流水号
  P_CUSTNAME      VARCHAR2,       --收货人姓名
  P_ADDRESS      VARCHAR2,       --收货人地址
  P_CUSTPHONE      VARCHAR2,       --收货人电话
  P_CUSTPOST      VARCHAR2,       --收货人邮编
  P_REMARK      VARCHAR2,       --订单备注
  P_TRADETIME      DATE            --操作时间
)
AS
    V_TODAY         DATE := SYSDATE;
  V_EX            EXCEPTION;
BEGIN

  --录入联机休闲年卡订单表
  --将原有的优惠金额、卡费、功能费删除
  BEGIN
  MERGE INTO TF_F_XXOL_ORDER T USING DUAL
  ON (T.ORDERNO = P_ORDERNO)
  WHEN MATCHED THEN
    UPDATE SET
      UPDATETIME  =  P_TRADETIME    ,
      CREATETIME  =  P_TRADETIME    ,
      ISREJECT  =  '1'
  WHEN NOT MATCHED THEN
    INSERT
      (ORDERNO    ,ORDERTYPE    ,ORDERSTATES  ,ORDERTOTAL    ,
      POSTAGE      ,
      PAYCANAL    ,PAYTRADEID    ,CUSTNAME    ,ADDRESS    ,
      CUSTPHONE    ,CUSTPOST    ,REMARK      ,UPDATETIME    ,
      CREATETIME    ,ISREJECT    ,INSTIME)
    VALUES(
      P_ORDERNO    ,P_ORDERTYPE  ,'0'      ,P_ORDERTOTAL  ,
      P_POSTAGE    ,
      P_PAYCANAL    ,P_PAYTRADEID  ,P_CUSTNAME    ,P_ADDRESS    ,
      P_CUSTPHONE    ,P_CUSTPOST    ,P_REMARK    ,P_TRADETIME  ,
      P_TRADETIME    ,'1'      ,P_TRADETIME);

    EXCEPTION WHEN OTHERS THEN
    P_RETCODE := 'I094780004';
    P_RETMSG  := '新增联机休闲年卡订单表失败' || SQLERRM;
    ROLLBACK; RETURN;
  END;

  IF P_ORDERTYPE = '2' THEN

  FOR V_CUR IN (SELECT * FROM TF_TMP_XXOL_ORDERDETAIL
            WHERE ORDERNO = P_ORDERNO)
  LOOP
    BEGIN
      UPDATE TF_F_XXOL_ORDERDETAIL
        SET     CUSTNAME  = V_CUR.CUSTNAME  ,
              PAPERTYPE  = V_CUR.PAPERTYPE  ,
              PAPERNO    = V_CUR.PAPERNO    ,
              CUSTPHONE  = V_CUR.CUSTPHONE  ,
              ADDRESS    = V_CUR.ADDRESS    ,
              CUSTPOST  = V_CUR.CUSTPOST  ,
              REMARK     = V_CUR.REMARK    ,
              CUSTSEX    = V_CUR.CUSTSEX    ,
              CUSTBIRTH  = V_CUR.CUSTBIRTH  ,
              CUSTEMAIL  = V_CUR.CUSTEMAIL  ,
              UPDATETIME  = P_TRADETIME    ,
              CREATETIME  = P_TRADETIME    ,
              ISREJECT  = '1'
      WHERE  ORDERDETAILID  = V_CUR.DETAILID AND ISREJECT = '0';
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'I094780005';
        P_RETMSG  := '修改联机休闲年卡订单明细表失败' || SQLERRM;
        ROLLBACK; RETURN;
    END;
  END LOOP;
  ELSE
    --录入联机休闲年卡订单明细表
    --订单明细增加优惠金额、优惠方式和优惠码
    BEGIN
      INSERT INTO TF_F_XXOL_ORDERDETAIL
        (ORDERDETAILID  ,ORDERNO    ,CARDNO      ,CARDCOST    ,
        FUNCFEE      ,DISCOUNT       ,DISCOUNTTYPE   ,CHARGENO       ,
        PACKAGETYPE      ,CUSTNAME    ,PAPERTYPE    ,DISCOUNTTRADEID,
        PAPERNO      ,CUSTPHONE    ,ADDRESS    ,CUSTPOST    ,
        REMARK      ,UPDATETIME    ,DETAILSTATES  ,CREATETIME    ,
        CUSTSEX      ,CUSTBIRTH    ,CUSTEMAIL    ,ISREJECT    ,
        INSTIME,        DISCOUNT2      ,DISCOUNTTYPE2,  CARDTYPECODE)
      SELECT
        DETAILID    ,ORDERNO    ,CARDNO      ,CARDCOST    ,
        FUNCFEE      ,DISCOUNT       ,DISCOUNTTYPE   ,CHARGENO       ,
        PACKAGETYPE      ,CUSTNAME    ,PAPERTYPE    ,DISCOUNTTRADEID,
        PAPERNO      ,CUSTPHONE    ,ADDRESS    ,CUSTPOST    ,
        REMARK      ,P_TRADETIME  ,'0'      ,P_TRADETIME  ,
        CUSTSEX      ,CUSTBIRTH    ,CUSTEMAIL    ,'1'      ,
        P_TRADETIME,    DISCOUNT2      ,DISCOUNTTYPE2, CARDTYPECODE
      FROM TF_TMP_XXOL_ORDERDETAIL
      WHERE ORDERNO = P_ORDERNO;

      EXCEPTION WHEN OTHERS THEN
      P_RETCODE := 'I094780006';
      P_RETMSG  := '新增联机休闲年卡订单明细表失败' || SQLERRM;
      ROLLBACK; RETURN;
    END;
  END IF;

  P_RETCODE := '0000000000';
  P_RETMSG  := '';
  RETURN;
END;
/
