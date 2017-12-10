CREATE OR REPLACE PROCEDURE SP_RELAX_ORDERTRADE
(
  P_RETCODE          OUT CHAR,     --RETURN CODE
  P_RETMSG           OUT VARCHAR2,   --RETURN MESSAGE
  P_TRADETYPE      CHAR,      --交易类型  0购卡开休闲，1开通休闲，2修改资料
  P_ORDERNO      CHAR,      --订单号
  P_ORDERTOTAL    INT,            --订单金额
  P_POSTAGE      INT,            --邮费
  --P_CARDCOST      INT,            --卡费-- delete
  --P_FUNCFEE      INT,            --功能费-- delete
  --P_DISCOUNT      INT,            --优惠 -- delete
  P_PAYCANAL      CHAR,           --支付渠道
  P_PAYTRADEID    VARCHAR2,       --支付流水号
  P_CUSTNAME      VARCHAR2,       --收货人姓名
  P_ADDRESS      VARCHAR2,       --收货人地址
  P_CUSTPHONE      VARCHAR2,       --收货人电话
  P_CUSTPOST      VARCHAR2,       --收货人邮编
  P_REMARK      VARCHAR2        --订单备注
)
AS
    v_TradeID      char(16);    --流水号
    v_ID        char(18);     --记录流水号
    V_TODAY           DATE := SYSDATE;
  V_CUSTCOUT      INT := 0;
  V_ROWCOUNT      INT;
  V_CARDNO      VARCHAR2(16);
  V_ASN        CHAR(16);
  v_CARDTRADENO    CHAR(4);
  V_CARDCOST      INT;
  V_FUNCFEE      INT;
  V_PACKAGETYPE    CHAR(2);
  V_CUSTNAME      VARCHAR2(100);
  V_PAPERTYPE      CHAR(2);
  V_PAPERNO      VARCHAR2(100);
  V_CUSTPHONE      VARCHAR2(100);
  V_ADDRESS      VARCHAR2(200);
  V_CUSTPOST      VARCHAR2(6);
  V_CUSTSEX      VARCHAR2(2);
  V_CUSTBIRTH      VARCHAR2(8);
  V_CUSTEMAIL      VARCHAR2(30);
  V_ENCUSTNAME    VARCHAR2(250);
  V_ENPAPERNO      VARCHAR2(200);
  V_ENCUSTPHONE    VARCHAR2(100);
  V_ENADDRESS      VARCHAR2(600);
  V_ENDDATE      CHAR(30);      --当期休闲年卡结束日期
  V_USABLETIMES    CHAR(30);      --当期休闲年卡开通次数
  V_XTIMES      CHAR(3);      --16进制次数
  V_ENDDATENUM    CHAR(12);      --本期开通休闲标识
  V_SYNENDDATE    CHAR(8);      --休闲到期日
  V_SPARETIMES    INT;        --剩余次数
  V_PACKAGETYPECODE  CHAR(2);      --套餐类型
  V_ACCOUNTTYPE    CHAR(1);      --账户类型
  V_SALYCOUNT      INT;        --制卡完成数量
  V_DEPARTNO      CHAR(4);
  V_STAFFNO      CHAR(6);
    v_DISCOUNT          INT    ;
  v_DISCOUNTTYPE      CHAR(2);            --新增优惠方式
    v_CHARGENO      VARCHAR2(512);       --新增优惠码
  v_CURRENTTIME    date;      --操作时间
    v_XFCARDNO      char(14);    --充值卡号
    v_sMONEY      int;      --充值卡金额
    V_EX              EXCEPTION;
  v_DISCOUNTTYPE2     CHAR(2);

BEGIN

  --获取部门、员工
  V_DEPARTNO := '0029';
  V_STAFFNO := '002900';

  --开通
  IF P_TRADETYPE = '1' THEN

    --增加判断只能允许一笔开通
    BEGIN
      SELECT COUNT(1) INTO V_ROWCOUNT FROM TF_TMP_XXOL_ORDERDETAIL WHERE ORDERNO = P_ORDERNO;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        p_retCode := 'I094780008';
        p_retMsg  := '缺少休闲开通数据';
        RETURN;
    END;

    IF V_ROWCOUNT > 1 THEN
      p_retCode := 'I094780009';
      p_retMsg  := '开通数据大于1笔，请确认';
      RETURN;
    END IF;
    --取得中间表数据
    -- TODO 新增字段
    FOR V_CUR IN (SELECT  CARDNO      ,CARDCOST    ,FUNCFEE    ,PACKAGETYPE  ,
                CUSTNAME    ,PAPERTYPE    ,PAPERNO    ,CUSTPHONE    ,
                ENCRYPTCUSTNAME  ,ENCRYPTPAPERNO  ,ENCRYPTCUSTPHONE,ENCRYPTADDRESS,
                CUSTSEX      ,CUSTBIRTH    ,CUSTEMAIL    ,
                ADDRESS      ,CUSTPOST    ,DISCOUNTTYPE ,CHARGENO, DISCOUNTTYPE2
            FROM TF_TMP_XXOL_ORDERDETAIL
            WHERE ORDERNO = P_ORDERNO)
    LOOP

    V_CARDNO    :=  V_CUR.CARDNO  ;
    V_CARDCOST    :=  V_CUR.CARDCOST  ;
    V_FUNCFEE    :=  V_CUR.FUNCFEE  ;
    V_PACKAGETYPE  :=  V_CUR.PACKAGETYPE  ;
    V_CUSTNAME    :=  V_CUR.CUSTNAME  ;
    V_PAPERTYPE    :=  V_CUR.PAPERTYPE  ;
    V_PAPERNO    :=  V_CUR.PAPERNO  ;
    V_CUSTPHONE    :=  V_CUR.CUSTPHONE  ;
    V_ENCUSTNAME  :=  V_CUR.ENCRYPTCUSTNAME  ;
    V_ENPAPERNO    :=  V_CUR.ENCRYPTPAPERNO  ;
    V_ENCUSTPHONE  :=  V_CUR.ENCRYPTCUSTPHONE  ;
    V_ENADDRESS    :=  V_CUR.ENCRYPTADDRESS  ;
    V_CUSTSEX    :=  V_CUR.CUSTSEX  ;
    V_CUSTBIRTH    :=  V_CUR.CUSTBIRTH  ;
    V_CUSTEMAIL    :=  V_CUR.CUSTEMAIL  ;
    V_ADDRESS    :=  V_CUR.ADDRESS  ;
    V_CUSTPOST    :=  V_CUR.CUSTPOST  ;
    V_DISCOUNTTYPE  :=  V_CUR.DISCOUNTTYPE;
    V_CHARGENO      :=  V_CUR.CHARGENO;
  v_DISCOUNTTYPE2 := V_CUR.DISCOUNTTYPE2;
    --获取流水号
    SP_GetSeq(seq => v_TradeID);

    --获取ASN号
    BEGIN
      SELECT ASN INTO V_ASN FROM TL_R_ICUSER WHERE CARDNO = V_CARDNO;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        p_retCode := 'I094780007';
        p_retMsg  := '获取ASN号失败' || SQLERRM;
        ROLLBACK; RETURN;
    END;

    --获取当期结束日期
   IF V_PACKAGETYPE IN('E1','E2') THEN
    BEGIN
    SELECT TAGVALUE INTO V_ENDDATE FROM TD_M_TAG WHERE  TAGCODE = 'AffectPARK_ENDDATE' AND USETAG = '1';
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
        p_retCode := 'S00505B003';
        p_retMsg  := '缺少系统参数-亲子卡结束日期' || SQLERRM;
        ROLLBACK; RETURN;
    END;
   ELSE
    BEGIN
      SELECT TAGVALUE INTO V_ENDDATE FROM TD_M_TAG WHERE  TAGCODE = 'XXPARK_ENDDATE' AND USETAG = '1';
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
        p_retCode := 'S00505B001';
        p_retMsg  := '缺少系统参数-惠民休闲年卡结束日期' || SQLERRM;
        ROLLBACK; RETURN;
    END;
   END IF;


    --当期休闲年卡开通次数

   IF V_PACKAGETYPE IN('E1','E2') THEN
    BEGIN
    SELECT TAGVALUE INTO V_USABLETIMES FROM  TD_M_TAG WHERE TAGCODE = 'AffectPARK_NUM' AND USETAG = '1';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        p_retCode := 'S00505B004';
        p_retMsg  := '缺少系统参数-亲子卡开卡次数' || SQLERRM;
        ROLLBACK; RETURN;
    END;
   ELSE
     BEGIN
      SELECT TAGVALUE INTO V_USABLETIMES FROM  TD_M_TAG WHERE TAGCODE = 'XXPARK_NUM' AND USETAG = '1';
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
        p_retCode := 'S00505B002';
        p_retMsg  := '缺少系统参数-惠民休闲年卡总共次数' || SQLERRM;
        ROLLBACK; RETURN;
     END;
   END IF;

  IF V_DISCOUNTTYPE = '01' or V_DISCOUNTTYPE2 = '01' THEN
    BEGIN
      SP_AS_XFCommit(   P_CARDNO => V_CARDNO  ,
            p_PASSWD       => V_CHARGENO,
            P_XFCARDNO     => V_XFCARDNO,
            p_SMONEY       => v_SMONEY,
            p_CURRENTTIME  => v_CURRENTTIME,
            p_TRADEID      => v_TradeID,
            p_currOper     => V_STAFFNO,
            p_currDept     => V_DEPARTNO,
            P_RETCODE      => P_RETCODE   ,
            P_RETMSG       => P_RETMSG      );
      IF  (P_RETCODE !='0000000000') THEN
      ROLLBACK;RETURN;
      END IF;
    END;
  END IF;

    --开通次数转16进制
    SELECT TO_CHAR(V_USABLETIMES,'XX') INTO V_XTIMES FROM DUAL;
    --本期开通休闲标识
    V_ENDDATENUM := SUBSTR(V_ENDDATE,1,8) || V_PACKAGETYPE || SUBSTR(V_XTIMES,-2);
    --获取记录流水号
    v_ID := TO_CHAR(SYSDATE, 'MMDDHH24MISS') || SUBSTR(V_CARDNO, -8);
    --设定联机交易序号
    v_CARDTRADENO := '0000';
    --兑换码（参考原休闲开通页面）和优惠码（新增）改状态和新增操作记录
    --优惠码账户表，优惠码使用记录表（关联订单）设计
  IF V_PACKAGETYPE IN('E1','E2') THEN
    BEGIN
      SP_AS_AffectCardNew( p_ID              =>  v_ID      ,
                p_cardNo          =>  V_CARDNO    ,
                p_cardTradeNo     =>  v_CARDTRADENO  ,
                p_asn             =>  V_ASN      ,
                p_tradeFee        =>  V_FUNCFEE    ,
                p_discount        =>  0             ,
                p_operCardNo      =>  ''      ,  --操作员卡号
                p_terminalNo      =>  '112233445566',  --默认
                p_oldEndDateNum   =>  'FFFFFFFFFFFF',  --上次写卡休闲标识
                p_endDateNum      =>  V_ENDDATENUM  ,  --本期开通休闲标识
                p_ACCOUNTTYPE    =>  '1'      ,
                p_PACKAGETPYECODE =>  V_PACKAGETYPE  ,
                p_XFCARDNO      =>    V_XFCARDNO  ,
                p_custName        =>  V_ENCUSTNAME  ,
                p_custSex         =>  V_CUSTSEX    ,
                p_custBirth       =>  V_CUSTBIRTH  ,
                p_paperType       =>  V_PAPERTYPE  ,
                p_paperNo         =>  V_ENPAPERNO  ,
                p_custAddr        =>  V_ENADDRESS  ,
                p_custPost        =>  V_CUSTPOST  ,
                p_custPhone       =>  V_ENCUSTPHONE  ,
                p_custEmail       =>  V_CUSTEMAIL  ,
                p_remark          =>  ''      ,
                p_TradeID         =>  v_TradeID     ,
                p_passPaperNo     =>  V_PAPERNO    ,
                p_passCustName    =>  V_CUSTNAME  ,
                p_CITYCODE            => '2150'       ,
                p_currOper        =>  V_STAFFNO    ,
                p_currDept        =>  V_DEPARTNO  ,
                p_retCode         =>  P_RETCODE    ,
                p_retMsg          =>  P_RETMSG);
      IF  (P_RETCODE !='0000000000') THEN
      ROLLBACK;RETURN;
      END IF;
      END;
  ELSE
      BEGIN
      SP_AS_RelaxCardNew( p_ID              =>  v_ID      ,
                p_cardNo          =>  V_CARDNO    ,
                p_cardTradeNo     =>  v_CARDTRADENO  ,
                p_asn             =>  V_ASN      ,
                p_tradeFee        =>  V_FUNCFEE    ,
                p_operCardNo      =>  ''      ,  --操作员卡号
                p_terminalNo      =>  '112233445566',  --默认
                p_oldEndDateNum   =>  'FFFFFFFFFFFF',  --上次写卡休闲标识
                p_endDateNum      =>  V_ENDDATENUM  ,  --本期开通休闲标识
                p_ACCOUNTTYPE    =>  '1'      ,
                p_PACKAGETPYECODE =>  V_PACKAGETYPE  ,
                p_XFCARDNO      =>    V_XFCARDNO  ,
                p_custName        =>  V_ENCUSTNAME  ,
                p_custSex         =>  V_CUSTSEX    ,
                p_custBirth       =>  V_CUSTBIRTH  ,
                p_paperType       =>  V_PAPERTYPE  ,
                p_paperNo         =>  V_ENPAPERNO  ,
                p_custAddr        =>  V_ENADDRESS  ,
                p_custPost        =>  V_CUSTPOST  ,
                p_custPhone       =>  V_ENCUSTPHONE  ,
                p_custEmail       =>  V_CUSTEMAIL  ,
                p_remark          =>  ''      ,
                p_TradeID         =>  v_TradeID     ,
                p_passPaperNo     =>  V_PAPERNO    ,
                p_passCustName    =>  V_CUSTNAME  ,
          p_CITYCODE            => '2150'       ,
                p_currOper        =>  V_STAFFNO    ,
                p_currDept        =>  V_DEPARTNO  ,
                p_retCode         =>  P_RETCODE    ,
                p_retMsg          =>  P_RETMSG);
      IF  (P_RETCODE !='0000000000') THEN
      ROLLBACK;RETURN;
      END IF;
      END;
  END IF;

    --团购业务录入
    BEGIN
      SP_FI_IFGROUPBUY(P_MSGTRADEIDS   =>  v_TradeID  ,
              P_MSGGROUPCODE  =>  P_PAYTRADEID,
              P_MSGSHOPNO     =>  P_PAYCANAL  ,
              P_MSGREMARK     =>  ''      ,
              P_CURROPER      =>  V_STAFFNO  ,
              P_CURRDEPT      =>  V_DEPARTNO  ,
              P_RETCODE     =>  P_RETCODE  ,
              P_RETMSG      =>  P_RETMSG);
      IF  (P_RETCODE !='0000000000') THEN
      ROLLBACK;RETURN;
      END IF;
    END;


    END LOOP;
  ELSIF P_TRADETYPE = '2' THEN  --修改资料

    --取得中间表数据
    FOR V_CUR IN (SELECT  CARDNO      ,CARDCOST    ,FUNCFEE    ,PACKAGETYPE  ,
                CUSTNAME    ,PAPERTYPE    ,PAPERNO    ,CUSTPHONE    ,
                ENCRYPTCUSTNAME  ,ENCRYPTPAPERNO  ,ENCRYPTCUSTPHONE,ENCRYPTADDRESS,
                CUSTSEX      ,CUSTBIRTH    ,CUSTEMAIL    ,
                ADDRESS      ,CUSTPOST    ,DETAILID
            FROM TF_TMP_XXOL_ORDERDETAIL
            WHERE ORDERNO = P_ORDERNO)
    LOOP
      V_CUSTCOUT := 0;
      V_ENCUSTNAME :='';
      V_ENCUSTNAME :='';
      V_ENPAPERNO :='';
      --判断是否存在用户资料
      BEGIN
        SELECT CUSTNAME,PAPERTYPECODE,PAPERNO INTO V_ENCUSTNAME,V_PAPERTYPE,V_ENPAPERNO
        FROM TF_F_CUSTOMERREC WHERE CARDNO = V_CUR.CARDNO;
        EXCEPTION WHEN NO_DATA_FOUND THEN NULL;
      END;

     IF V_ENCUSTNAME is not null THEN


        --B卡则用传过来数据更新，A卡保持不变
        IF SUBSTR(V_CUR.CARDNO,0,6) != '201518' THEN
          V_ENCUSTNAME := V_CUR.ENCRYPTCUSTNAME;
          V_PAPERTYPE := V_CUR.PAPERTYPE;
          V_ENPAPERNO := V_CUR.ENCRYPTPAPERNO;
        END IF;

        BEGIN
          UPDATE TF_F_CUSTOMERREC
          SET    CUSTNAME      = NVL(V_ENCUSTNAME,CUSTNAME)  ,
               CUSTSEX       = NVL(V_CUR.CUSTSEX,CUSTSEX)   ,
               CUSTBIRTH     = NVL(V_CUR.CUSTBIRTH,CUSTBIRTH) ,
               PAPERTYPECODE = NVL(V_PAPERTYPE,PAPERTYPECODE) ,
               PAPERNO       = NVL(V_ENPAPERNO,PAPERNO)   ,
               CUSTADDR      = NVL(V_CUR.ENCRYPTADDRESS,CUSTADDR)  ,
               CUSTPOST      = NVL(V_CUR.CUSTPOST,CUSTPOST)  ,
               CUSTPHONE     = NVL(V_CUR.ENCRYPTCUSTPHONE,CUSTPHONE) ,
               CUSTEMAIL     = NVL(V_CUR.CUSTEMAIL,CUSTEMAIL) ,
               REMARK        = NVL('',REMARK)    ,
               UPDATESTAFFNO = V_STAFFNO  ,
               UPDATETIME    = V_TODAY
          WHERE  CARDNO        = V_CUR.CARDNO;

          IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION WHEN OTHERS THEN
          P_RETCODE := 'S00506B002'; P_RETMSG  := '更新客户资料失败,' || SQLERRM;
          ROLLBACK; RETURN;
        END;

        --如果订单有卡号修改资料的需要同步修改资料给APP+乐园
        BEGIN
          SELECT COUNT(1) INTO V_SALYCOUNT FROM TF_F_XXOL_ORDERDETAIL T WHERE T.ORDERDETAILID = V_CUR.DETAILID AND t.cardno is not null;
        END;

        IF V_SALYCOUNT > 0 THEN
          --获取下卡ASN号
          V_ASN := '00215000' || SUBSTR(V_CUR.CARDNO, -8);
          ---)获取卡截止时间
          BEGIN
          SELECT ENDDATE,SPARETIMES,PACKAGETYPECODE,ACCOUNTTYPE INTO V_SYNENDDATE,V_SPARETIMES,V_PACKAGETYPECODE,V_ACCOUNTTYPE
          FROM  TF_F_CARDXXPARKACC_SZ
          WHERE  CARDNO=V_CUR.CARDNO;
          EXCEPTION WHEN OTHERS THEN
              P_RETCODE := 'A00505B501'; P_RETMSG  := '获取休闲年卡数据失败';
              RETURN;
          END;
          --获取流水号
          SP_GetSeq(seq => v_TradeID);

          --同步休闲接口
          BEGIN
            SP_AS_SYNGARDENXXCARD(V_CUR.CARDNO,V_ASN,V_CUR.PAPERTYPE,V_ENPAPERNO,V_ENCUSTNAME,
                    V_SYNENDDATE,V_SPARETIMES,'4',V_TODAY,'','',V_TRADEID,
                    V_PACKAGETYPECODE,V_ACCOUNTTYPE,'2150',
                    V_STAFFNO,V_DEPARTNO,P_RETCODE,P_RETMSG);

          IF P_RETCODE != '0000000000' THEN RAISE V_EX; END IF;
            EXCEPTION
            WHEN OTHERS THEN
              ROLLBACK; RETURN;
          END;
        END IF;

      END IF;
    END LOOP;
  END IF;
  --新增兑换码和优惠码使用，使用仅限于开通,和修改资料无关
    BEGIN
  IF P_TRADETYPE IN ( '0' )THEN

    FOR V_CURR IN (SELECT  CARDNO  ,   DISCOUNT,   DISCOUNTTYPE,  CHARGENO, DISCOUNTTYPE2,
        DETAILID
            FROM TF_TMP_XXOL_ORDERDETAIL
            WHERE ORDERNO = P_ORDERNO)
    LOOP
    V_CARDNO        :=  V_CURR.CARDNO;
    V_DISCOUNT      :=  V_CURR.DISCOUNT;
    V_DISCOUNTTYPE  :=  V_CURR.DISCOUNTTYPE;
    V_CHARGENO      :=  V_CURR.CHARGENO;
  v_DISCOUNTTYPE2 := V_CURR.DISCOUNTTYPE2;
     --获取流水号
      SP_GetSeq(seq => v_TradeID);
    IF V_DISCOUNTTYPE = '01' or v_DISCOUNTTYPE2 = '01' THEN

    BEGIN

            SP_AS_XFCommit(   P_CARDNO       => V_CARDNO  ,
                          p_PASSWD       => V_CHARGENO,
                  P_XFCARDNO     => V_XFCARDNO,
                          p_SMONEY       => v_SMONEY,
                  p_CURRENTTIME  => v_CURRENTTIME,
                  p_TRADEID      => v_TradeID,
                  p_currOper     => V_STAFFNO,
                  p_currDept     => V_DEPARTNO,
                  P_RETCODE       => P_RETCODE   ,
                  P_RETMSG       => P_RETMSG      );
            IF  (P_RETCODE !='0000000000') THEN
            ROLLBACK;RETURN;
            END IF;
    END;

    --更新临时表中优惠流水号
    BEGIN
      UPDATE TF_TMP_XXOL_ORDERDETAIL T SET T.DISCOUNTTRADEID = v_TradeID WHERE T.ORDERNO = P_ORDERNO AND DETAILID = V_CURR.DETAILID;
      IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
      EXCEPTION WHEN OTHERS THEN
        P_RETCODE := 'I094780195';
        P_RETMSG  := '更新联机休闲年卡订单临时表失败' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    END IF;
    END LOOP;
  END IF;
  END;
  --休闲订单数据录入
  --todo 验证优惠码或兑换码是否可用（程序sql）
  --兑换码（充值卡）中间状态，保证只有一次，非充值卡使用状态；优惠码（次数增加），
  --订单录入删除卡费、功能费和优惠
  BEGIN
    SP_RELAX_ORDERINPUT(  P_RETCODE    => P_RETCODE    ,
                P_RETMSG    => P_RETMSG    ,
                P_ORDERNO    => P_ORDERNO    ,
                P_ORDERTYPE    => P_TRADETYPE  ,
                P_ORDERTOTAL  => P_ORDERTOTAL  ,
                P_POSTAGE    => P_POSTAGE    ,
              --  P_CARDCOST    => P_CARDCOST    ,
              --  P_FUNCFEE    => P_FUNCFEE    ,
              --  P_DISCOUNT    => P_DISCOUNT    ,
                P_PAYCANAL    => P_PAYCANAL    ,
                P_PAYTRADEID  => P_PAYTRADEID  ,
                P_CUSTNAME    => P_CUSTNAME    ,
                P_ADDRESS    => P_ADDRESS    ,
                P_CUSTPHONE    => P_CUSTPHONE  ,
                P_CUSTPOST    => P_CUSTPOST    ,
                P_REMARK    => P_REMARK    ,
                P_TRADETIME    => V_TODAY);
    IF  (P_RETCODE !='0000000000') THEN
    ROLLBACK;RETURN;
    END IF;
  END;

  --取得中间表数据
  FOR V_CUR IN (SELECT DETAILID FROM TF_TMP_XXOL_ORDERDETAIL WHERE ORDERNO = P_ORDERNO)
  LOOP
    --获取流水号
    SP_GetSeq(seq => v_TradeID);
    --记录订单台帐表
    BEGIN
      INSERT INTO TF_B_XXOL_TRADE(
      TRADEID      , ORDERNO      ,ORDERDETAILID    , TRADETYPECODE  ,
      UPDATEDEPARTID  , UPDATESTAFFNO    ,OPERATETIME
      )VALUES(
      v_TradeID    ,P_ORDERNO      ,V_CUR.DETAILID    , DECODE(P_TRADETYPE,'2','04','00')  ,
      V_DEPARTNO    , V_STAFFNO      ,V_TODAY
      );
    IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;
        EXCEPTION
        WHEN OTHERS THEN
        P_RETCODE := 'S094780092';
        P_RETMSG  := '记录订单台帐表失败'||SQLERRM;
        ROLLBACK; RETURN;
    END;
  END LOOP;

  IF P_RETCODE = '0000000000' THEN
  P_RETMSG := '';
  COMMIT; RETURN;
  END IF;
END;
/
