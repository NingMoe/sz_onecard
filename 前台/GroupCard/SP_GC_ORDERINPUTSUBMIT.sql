create or replace procedure SP_GC_ORDERINPUTSUBMIT
(
    P_FUNCCODE     VARCHAR2 , --功能编码
    p_ORDERNO      char     , --订单号
    P_ORDERTYPE    CHAR     , --订单类型
    P_INITIATOR    CHAR     , --订单发起方 1 CRM ,2 业务系统
    P_SESSIONID    varchar2 ,
    P_GROUPNAME    varchar2 , --企业名称
    P_COMPANYPAPERTYPE CHAR     , --单位证件类型
    P_COMPANYPAPERNO   VARCHAR2 , --单位证件号码
    P_COMPANYMANAGERNO VARCHAR2 , --法人证件号码
    P_COMPANYENDTIME   VARCHAR2 , --证件有效期
    P_NAME         varchar2 , --联系人姓名
    P_PHONE        varchar2 , --联系人电话
    P_IDCARDNO     varchar2 , --联系人证件号码
    P_BIRTHDAY     VARCHAR2 , --出生日期
    P_PAPERTYPE    CHAR     , --证件类型
    P_SEX          CHAR     , --性别
    P_ADDRESS      VARCHAR2 , --联系地址
    P_EMAIL        VARCHAR2 , --EMAIL
    P_OUTBANK      VARCHAR2 , --转出银行
    P_OUTACCT      VARCHAR2 , --转出账户
    P_TOTALMONEY   integer,   --总金额
    P_TRANSACTOR   char,      --经办人
    P_REMARK       varchar2,  --备注

    P_CASHGIFTMONEY     integer, --礼金卡总金额
    P_CHARGECARDMONEY   integer, --充值卡总金额
    P_SZTCARDMONEY      integer, --市民卡B卡总金额
    P_LVYOUMONEY        integer, --旅游卡总金额
    P_CUSTOMERACCMONEY  integer, --专有账户总充值金额
    P_INVOICETOTALMONEY integer, --发票总金额
    P_GETDEPARTMENT     char,    --领卡网点
    P_GETDATE           char,    --领卡时间
    
    P_READERMONEY       integer, --读卡器总金额
    P_GARDENCARDMONEY   integer, --园林年卡总金额
    P_RELAXCARDMONEY    integer, --休闲年卡总金额
    P_READERNUM         integer, --读卡器数量
    P_READERPRICE       integer, --读卡器单价
    P_GARDENCARDNUM     integer, --园林年卡数量
    P_GARDENCARDPRICE   integer, --园林年卡单价
    P_RELAXCARDNUM      integer, --休闲年卡数量
    P_RELAXCARDPRICE    integer, --休闲年卡单价
    P_MANAGERDEPT       CHAR, --客户经理部门
    P_MANAGER           CHAR, --客户经理
    P_ORDERDATE    char,
    P_ORDERSEQ     char,
    P_OUTORDERNO   out char,
    p_currOper     char,           -- Current Operator
    p_currDept     char,           -- Curretn Operator's Department
    p_retCode      out char,       -- Return Code
    p_retMsg       out varchar2    -- Return Message
)
AS
    V_COUNT         INT;
    v_orderseqNo    CHAR(16);
    v_tradeID       CHAR(16);
    V_COMNO_SEQ     VARCHAR2(6);
    v_today         date:=sysdate;
    v_ex            EXCEPTION;
    V_ID            CHAR(16);
    V_ORDERTYPE     CHAR(1);
BEGIN
    /*
    SELECT NVL((SELECT COMPANYNO
    FROM   TD_M_BUYCARDCOMINFO
    WHERE  COMPANYNAME = P_GROUPNAME),'')
    INTO   V_COMNO_SEQ
    FROM   DUAL;

    --信息不存在时插入新单位信息
    IF V_COMNO_SEQ IS NULL THEN
    BEGIN
        SELECT TD_M_BUYCARDCOM_SEQ.NEXTVAL INTO V_COMNO_SEQ FROM DUAL;
        INSERT INTO TD_M_BUYCARDCOMINFO(
        COMPANYNO        , COMPANYNAME
        )VALUES(
        V_COMNO_SEQ      , P_GROUPNAME
        );
    EXCEPTION WHEN OTHERS THEN
       P_RETCODE := 'S004102001' ;
       P_RETMSG  := '插入购卡单位信息表失败'||SQLERRM ;
       ROLLBACK;RETURN;
    END;
    END IF;  */

    IF P_FUNCCODE = 'ADD' THEN
        IF P_INITIATOR = '1' THEN
            v_orderseqNo := p_ORDERNO ; --获取订单号
        ELSE
            SP_GetSeq(seq => v_orderseqNo); --生成订单号
        END IF;
        
        P_OUTORDERNO := v_orderseqNo;

        SELECT COUNT(*) INTO V_COUNT FROM TF_F_ORDERFORM WHERE ORDERNO = v_orderseqNo;

        IF V_COUNT > 0 THEN
            p_retCode := 'S094570297';
            p_retMsg := '订单已存在';
            ROLLBACK;RETURN;
        END IF;

        IF P_ORDERTYPE = '1' THEN --单位订单
            BEGIN
                SP_PB_ComBuyCardReg(
                    P_FUNCCODE         => 'ADD'              ,
                    P_ID               => ''                 ,
                    P_COMPANYNAME      => P_GROUPNAME        ,
                    P_COMPANYPAPERTYPE => P_COMPANYPAPERTYPE ,
                    P_COMPANYPAPERNO   => P_COMPANYPAPERNO   ,
                    P_COMPANYMANAGERNO => P_COMPANYMANAGERNO ,
                    P_COMPANYENDTIME   => P_COMPANYENDTIME   ,
                    P_NAME             => P_NAME             ,
                    P_PAPERTYPE        => P_PAPERTYPE        ,
                    P_PAPERNO          => P_IDCARDNO         ,
                    P_PHONENO          => P_PHONE            ,
                    P_ADDRESS          => P_ADDRESS          ,
                    P_EMAIL            => P_EMAIL            ,
                    P_OUTBANK          => P_OUTBANK          ,
                    P_OUTACCT          => P_OUTACCT          ,
                    P_STARTCARDNO      => ''                 ,
                    P_ENDCARDNO        => ''                 ,
                    P_BUYCARDDATE      => ''                 ,
                    P_BUYCARDNUM       => ''                 ,
                    P_BUYCARDMONEY     => ''                 ,
                    P_CHARGEMONEY      => ''                 ,
                    P_REMARK           => v_orderseqNo       ,
                    P_CURROPER         => P_CURROPER         ,
                    P_CURRDEPT         => P_CURRDEPT         ,
                    P_RETCODE          => P_RETCODE          ,
                    P_RETMSG           => P_RETMSG
                );
                IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                ROLLBACK; RETURN;
            END;
        ELSE
            BEGIN
                SP_PB_PerBuyCardReg(
                    P_FUNCCODE              => 'ADD'          ,
                    P_ID                    => ''             ,
                    P_NAME                  => P_NAME         ,
                    P_BIRTHDAY              => P_BIRTHDAY     ,
                    P_PAPERTYPE             => P_PAPERTYPE    ,
                    P_PAPERNO               => P_IDCARDNO     ,
                    P_SEX                   => P_SEX          ,
                    P_PHONENO               => P_PHONE        ,
                    P_ADDRESS               => P_ADDRESS      ,
                    P_EMAIL                 => P_EMAIL        ,
                    P_STARTCARDNO           => ''             ,
                    P_ENDCARDNO             => ''             ,
                    P_BUYCARDDATE           => ''             ,
                    P_BUYCARDNUM            => ''             ,
                    P_BUYCARDMONEY          => ''             ,
                    P_CHARGEMONEY           => ''             ,
                    P_REMARK                => v_orderseqNo   ,
                    P_CURROPER              => P_CURROPER     ,
                    P_CURRDEPT              => P_CURRDEPT     ,
                    P_RETCODE               => P_RETCODE      ,
                    P_RETMSG                => P_RETMSG
                    );
                IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                ROLLBACK; RETURN;
            END;
        END IF;
        --SP_GC_GETORDERNO(p_orderDate => P_ORDERDATE,p_orderSeq => v_orderseqNo);

        BEGIN
            INSERT INTO TF_F_ORDERFORM(
                ORDERNO            , ORDERSTATE          , ORDERTYPE         , GROUPNAME         , NAME               ,
                PHONE              , IDCARDNO            , TOTALMONEY        , TRANSACTOR        , INPUTTIME          ,
                REMARK             , CASHGIFTMONEY       , CHARGECARDMONEY   , SZTCARDMONEY      , LVYOUMONEY         , CUSTOMERACCMONEY   ,
                CUSTOMERACCHASMONEY, INVOICETOTALMONEY   , GETDEPARTMENT     , GETDATE           , USETAG             ,
                ORDERDATE          , ORDERSEQ            , UPDATEDEPARTNO    , UPDATESTAFFNO     , UPDATETIME         ,
                INITIATOR          , PAPERTYPE           , READERMONEY       , GARDENCARDMONEY   , RELAXCARDMONEY     ,
                MANAGERDEPT        ,MANAGER
           )VALUES(
                v_orderseqNo       , '01'                , P_ORDERTYPE       , P_GROUPNAME       , P_NAME             ,
                P_PHONE            , P_IDCARDNO          , P_TOTALMONEY      , P_TRANSACTOR      , v_today            ,
                P_REMARK           , P_CASHGIFTMONEY     , P_CHARGECARDMONEY , P_SZTCARDMONEY    , P_LVYOUMONEY       , P_CUSTOMERACCMONEY ,
                0                  , P_INVOICETOTALMONEY , P_GETDEPARTMENT   , P_GETDATE         , '1'                ,
                P_ORDERDATE        , P_ORDERSEQ          , p_currDept        , p_currOper        , v_today            ,
                P_INITIATOR        , P_PAPERTYPE         , P_READERMONEY     , P_GARDENCARDMONEY , P_RELAXCARDMONEY   ,
                P_MANAGERDEPT      ,P_MANAGER
                );
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570300';
            p_retMsg := '插入订单表失败'|| SQLERRM ;
            ROLLBACK;RETURN;
        END;

        --插入利金卡订单明细表
        BEGIN
            FOR cur_data IN
            (
                SELECT * FROM tmp_order TMP
                WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '0'  --代表礼金卡
            )
            LOOP
                BEGIN
                    INSERT INTO TF_F_CASHGIFTORDER (ORDERNO,VALUE,COUNT,SUM,LEFTQTY)
                    VALUES
                    (v_orderseqNo,to_number(cur_data.f2),to_number(cur_data.f3),to_number(cur_data.f4),to_number(cur_data.f3));
                    exception when others then
                    p_retCode := 'S001002203';
                    p_retMsg := '插入利金卡订单明细表失败'|| SQLERRM ;
                    rollback; return;
                END;
            END LOOP;
        END;
        --插入充值卡订单明细表
        BEGIN
           FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '1'  --代表充值卡
           )
           LOOP
              BEGIN
                  INSERT INTO TF_F_CHARGECARDORDER
                  (ORDERNO,VALUECODE,COUNT,SUM,LEFTQTY)
                  VALUES
                  (v_orderseqNo,cur_data.f2,to_number(cur_data.f3),
                  to_number(cur_data.f4),to_number(cur_data.f3));
                  exception when others then
                  p_retCode := 'S001002204';
                  p_retMsg := '插入充值卡订单明细表失败'|| SQLERRM ;
                  rollback; return;
              END;
           END LOOP;
        END;
        --插入苏州通卡订单明细表
        BEGIN
          FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '2'  --代表苏州通卡
           )
           LOOP
              
              IF  to_number(cur_data.f3)<>0  THEN
               BEGIN
                  INSERT INTO TF_F_SZTCARDORDER (ORDERNO,CARDTYPECODE,COUNT,UNITPRICE,TOTALCHARGEMONEY,TOTALMONEY,LEFTQTY)
                  VALUES
                  (v_orderseqNo,cur_data.f2, to_number(cur_data.f3),to_number(cur_data.f4),
                   to_number(cur_data.f5),to_number(cur_data.f6),to_number(cur_data.f3));
                  exception when others then
                  p_retCode := 'S001002205';
                  p_retMsg := '插入苏州通卡订单明细表失败'|| SQLERRM ;
                  rollback; return;
                 END;
               ELSE  --市民卡B卡为旧卡时,即COUNT=0时
                BEGIN  
                  INSERT INTO TF_F_SZTCARDORDER (ORDERNO,CARDTYPECODE,COUNT,UNITPRICE,TOTALCHARGEMONEY,TOTALMONEY,LEFTQTY,ISCHARGE)
                  VALUES
                  (v_orderseqNo,cur_data.f2, to_number(cur_data.f3),to_number(cur_data.f4),
                   to_number(cur_data.f5),to_number(cur_data.f6),to_number(cur_data.f3),1);
                  exception when others then
                  p_retCode := 'S001002206';
                  p_retMsg := '插入苏州通卡订单明细表失败'|| SQLERRM ;
                  rollback; return;
                 END;
               END IF;
              
           END LOOP;
        END;
        
        
         --插入旅游卡订单明细表
        BEGIN
          FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '5'  --代表旅游卡
           )
           LOOP
              
                BEGIN
                  INSERT INTO TF_F_SZTCARDORDER (ORDERNO,CARDTYPECODE,COUNT,UNITPRICE,TOTALCHARGEMONEY,TOTALMONEY,LEFTQTY)
                  VALUES
                  (v_orderseqNo,cur_data.f2, to_number(cur_data.f3),to_number(cur_data.f4),
                   to_number(cur_data.f5),to_number(cur_data.f6),to_number(cur_data.f3));
                  exception when others then
                  p_retCode := 'S001002205';
                  p_retMsg := '插入苏州通卡订单明细表失败'|| SQLERRM ;
                  rollback; return;
                 END;
               
              
           END LOOP;
        END;

        --插入订单发票明细表
        BEGIN
           FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '3'  --代表开票信息
           )
           LOOP
              BEGIN
                  INSERT INTO TF_F_ORDERINVOICE (ORDERNO,INVOICETYPECODE,INVOICEMONEY)
                  VALUES
                  (v_orderseqNo,cur_data.f2, cur_data.f3);
                  exception when others then
                  p_retCode := 'S001002207';
                  p_retMsg :=  '插入订单发票明细表失败'|| SQLERRM ;
                  rollback; return;
              END;
           END LOOP;
        END;

        --插入订单付款方式表
        BEGIN
           FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '4'  --代表付款方式
           )
           LOOP
              BEGIN
                  INSERT INTO TF_F_PAYTYPE (ORDERNO,PAYTYPECODE,PAYTYPENAME)
                  VALUES
                  (v_orderseqNo,cur_data.f2, cur_data.f3);
                  exception when others then
                  p_retCode := 'S001002208';
                  p_retMsg :=  '插入订单付款方式表失败'|| SQLERRM ;
                  rollback; return;
              END;
           END LOOP;
        END;
        
        IF P_READERMONEY > 0 THEN
            --记录读卡器明细表
            BEGIN
                INSERT INTO TF_F_READERORDER(ORDERNO,VALUE,COUNT,SUM,LEFTQTY) VALUES
                (v_orderseqNo,P_READERPRICE,P_READERNUM,P_READERMONEY,P_READERNUM);
            EXCEPTION when others then
                p_retCode := 'S094570339';
                p_retMsg := '记录读卡器明细表失败'|| SQLERRM ;
                rollback; return;
            END;
        END IF;
        
        IF P_GARDENCARDMONEY > 0 THEN
            --记录园林年卡明细表
            BEGIN
                INSERT INTO TF_F_GARDENCARDORDER(ORDERNO,VALUE,COUNT,SUM) VALUES
                (v_orderseqNo,P_GARDENCARDPRICE,P_GARDENCARDNUM,P_GARDENCARDMONEY);
            EXCEPTION when others then
                p_retCode := 'S094570340';
                p_retMsg := '记录园林年卡明细表失败'|| SQLERRM ;
                rollback; return;        
            END;
        END IF;
        
        IF P_RELAXCARDMONEY > 0 THEN
            --记录休闲年卡明细表
            BEGIN
                INSERT INTO TF_F_RELAXCARDORDER(ORDERNO,VALUE,COUNT,SUM) VALUES
                (v_orderseqNo,P_RELAXCARDPRICE,P_RELAXCARDNUM,P_RELAXCARDMONEY);
            EXCEPTION when others then
                p_retCode := 'S094570341';
                p_retMsg := '记录休闲年卡明细表失败'|| SQLERRM ;
                    rollback; return;        
            END;
        END IF;
        
        SP_GetSeq(seq => v_tradeID); --生成流水号
        --记录订单台账
        BEGIN
            INSERT INTO TF_F_ORDERTRADE (
                TRADEID         , ORDERNO           , TRADECODE       , MONEY             , GROUPNAME      , NAME   ,
                CASHGIFTMONEY   , CHARGECARDMONEY   , SZTCARDMONEY    , LVYOUMONEY        , CUSTOMERACCMONEY  , GETDEPARTMENT  ,
                GETDATE         , REMARK            , OPERATEDEPARTNO , OPERATESTAFFNO    , OPERATETIME    ,READERMONEY ,
                GARDENCARDMONEY   , RELAXCARDMONEY
           )VALUES(
                v_tradeID       , v_orderseqNo      , '00'            , P_TOTALMONEY       , P_GROUPNAME    , P_NAME ,
                P_CASHGIFTMONEY , P_CHARGECARDMONEY , P_SZTCARDMONEY  , P_LVYOUMONEY       , P_CUSTOMERACCMONEY , P_GETDEPARTMENT,
                P_GETDATE       , P_REMARK          , p_currDept      , p_currOper         , v_today        ,P_READERMONEY ,
                P_GARDENCARDMONEY , P_RELAXCARDMONEY
                );
            exception when others then
            p_retCode := 'S094570301';
            p_retMsg :=  '插入订单台账表失败'|| SQLERRM ;
            rollback; return;
        END;
    END IF;

    IF P_FUNCCODE = 'MODIFY' THEN
        --返回订单号赋值
        P_OUTORDERNO := p_ORDERNO;
        
        SELECT ORDERTYPE INTO V_ORDERTYPE FROM TF_F_ORDERFORM WHERE ORDERNO = p_ORDERNO;
        IF V_ORDERTYPE = '1' AND P_ORDERTYPE = '1' THEN --单位订单
            BEGIN
                SELECT ID INTO V_ID FROM TF_F_COMBUYCARDREG WHERE REMARK =  p_ORDERNO;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                p_retCode := 'S094570299';
                p_retMsg :=  '未找到单位购卡记录,'|| SQLERRM ;
                rollback; return;
            END;
            BEGIN
                SP_PB_ComBuyCardReg(
                    P_FUNCCODE         => 'MODIFY'           ,
                    P_ID               => V_ID               ,
                    P_COMPANYNAME      => P_GROUPNAME        ,
                    P_COMPANYPAPERTYPE => P_COMPANYPAPERTYPE ,
                    P_COMPANYPAPERNO   => P_COMPANYPAPERNO   ,
                    P_COMPANYMANAGERNO => P_COMPANYMANAGERNO ,
                    P_COMPANYENDTIME   => P_COMPANYENDTIME   ,
                    P_NAME             => P_NAME             ,
                    P_PAPERTYPE        => P_PAPERTYPE        ,
                    P_PAPERNO          => P_IDCARDNO         ,
                    P_PHONENO          => P_PHONE            ,
                    P_ADDRESS          => P_ADDRESS          ,
                    P_EMAIL            => P_EMAIL            ,
                    P_OUTBANK          => P_OUTBANK          ,
                    P_OUTACCT          => P_OUTACCT          ,
                    P_STARTCARDNO      => ''                 ,
                    P_ENDCARDNO        => ''                 ,
                    P_BUYCARDDATE      => ''                 ,
                    P_BUYCARDNUM       => ''                 ,
                    P_BUYCARDMONEY     => ''                 ,
                    P_CHARGEMONEY      => ''                 ,
                    P_REMARK           => p_ORDERNO          ,
                    P_CURROPER         => P_CURROPER         ,
                    P_CURRDEPT         => P_CURRDEPT         ,
                    P_RETCODE          => P_RETCODE          ,
                    P_RETMSG           => P_RETMSG
                );
                IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                ROLLBACK; RETURN;
            END;
        ELSIF V_ORDERTYPE = '2' AND P_ORDERTYPE = '2' THEN --个人订单
            BEGIN
                SELECT ID INTO V_ID FROM TF_F_PERBUYCARDREG WHERE REMARK =  p_ORDERNO;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                p_retCode := 'S094570298';
                p_retMsg :=  '未找到个人购卡记录,'|| SQLERRM ;
                rollback; return;
            END;
            BEGIN
                SP_PB_PerBuyCardReg(
                    P_FUNCCODE              => 'MODIFY'       ,
                    P_ID                    => V_ID           ,
                    P_NAME                  => P_NAME         ,
                    P_BIRTHDAY              => P_BIRTHDAY     ,
                    P_PAPERTYPE             => P_PAPERTYPE    ,
                    P_PAPERNO               => P_IDCARDNO     ,
                    P_SEX                   => P_SEX          ,
                    P_PHONENO               => P_PHONE        ,
                    P_ADDRESS               => P_ADDRESS      ,
                    P_EMAIL                 => P_EMAIL        ,
                    P_STARTCARDNO           => ''             ,
                    P_ENDCARDNO             => ''             ,
                    P_BUYCARDDATE           => ''             ,
                    P_BUYCARDNUM            => ''             ,
                    P_BUYCARDMONEY          => ''             ,
                    P_CHARGEMONEY           => ''             ,
                    P_REMARK                => p_ORDERNO      ,
                    P_CURROPER              => P_CURROPER     ,
                    P_CURRDEPT              => P_CURRDEPT     ,
                    P_RETCODE               => P_RETCODE      ,
                    P_RETMSG                => P_RETMSG
                    );
                IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                ROLLBACK; RETURN;
            END;
        ELSIF V_ORDERTYPE = '2' AND P_ORDERTYPE = '1' THEN --个人订单改单位订单
            BEGIN
                SELECT ID INTO V_ID FROM TF_F_PERBUYCARDREG WHERE REMARK =  p_ORDERNO;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                p_retCode := 'S094570298';
                p_retMsg :=  '未找到个人购卡记录,'|| SQLERRM ;
                rollback; return;
            END;
            --作废个人购卡记录
            BEGIN
                SP_PB_PerBuyCardReg(
                    P_FUNCCODE              => 'DELETE'       ,
                    P_ID                    => V_ID           ,
                    P_NAME                  => ''             ,
                    P_BIRTHDAY              => ''             ,
                    P_PAPERTYPE             => ''             ,
                    P_PAPERNO               => ''             ,
                    P_SEX                   => ''             ,
                    P_PHONENO               => ''             ,
                    P_ADDRESS               => ''             ,
                    P_EMAIL                 => ''             ,
                    P_STARTCARDNO           => ''             ,
                    P_ENDCARDNO             => ''             ,
                    P_BUYCARDDATE           => ''             ,
                    P_BUYCARDNUM            => ''             ,
                    P_BUYCARDMONEY          => ''             ,
                    P_CHARGEMONEY           => ''             ,
                    P_REMARK                => ''             ,
                    P_CURROPER              => P_CURROPER     ,
                    P_CURRDEPT              => P_CURRDEPT     ,
                    P_RETCODE               => P_RETCODE      ,
                    P_RETMSG                => P_RETMSG
                    );
                IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                ROLLBACK; RETURN;
            END;
            --新增单位购卡记录
            BEGIN
                SP_PB_ComBuyCardReg(
                    P_FUNCCODE         => 'ADD'              ,
                    P_ID               => ''                 ,
                    P_COMPANYNAME      => P_GROUPNAME        ,
                    P_COMPANYPAPERTYPE => P_COMPANYPAPERTYPE ,
                    P_COMPANYPAPERNO   => P_COMPANYPAPERNO   ,
                    P_COMPANYMANAGERNO => P_COMPANYMANAGERNO ,
                    P_COMPANYENDTIME   => P_COMPANYENDTIME   ,
                    P_NAME             => P_NAME             ,
                    P_PAPERTYPE        => P_PAPERTYPE        ,
                    P_PAPERNO          => P_IDCARDNO         ,
                    P_PHONENO          => P_PHONE            ,
                    P_ADDRESS          => P_ADDRESS          ,
                    P_EMAIL            => P_EMAIL            ,
                    P_OUTBANK          => P_OUTBANK          ,
                    P_OUTACCT          => P_OUTACCT          ,
                    P_STARTCARDNO      => ''                 ,
                    P_ENDCARDNO        => ''                 ,
                    P_BUYCARDDATE      => ''                 ,
                    P_BUYCARDNUM       => ''                 ,
                    P_BUYCARDMONEY     => ''                 ,
                    P_CHARGEMONEY      => ''                 ,
                    P_REMARK           => p_ORDERNO          ,
                    P_CURROPER         => P_CURROPER         ,
                    P_CURRDEPT         => P_CURRDEPT         ,
                    P_RETCODE          => P_RETCODE          ,
                    P_RETMSG           => P_RETMSG
                );
                IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                ROLLBACK; RETURN;
            END;
        ELSIF V_ORDERTYPE = '1' AND P_ORDERTYPE = '2' THEN --单位订单改个人订单
            BEGIN
                SELECT ID INTO V_ID FROM TF_F_COMBUYCARDREG WHERE REMARK =  p_ORDERNO;
            EXCEPTION WHEN NO_DATA_FOUND THEN
                p_retCode := 'S094570299';
                p_retMsg :=  '未找到单位购卡记录,'|| SQLERRM ;
                rollback; return;
            END;
            --作废单位购卡记录
            BEGIN
                SP_PB_ComBuyCardReg(
                    P_FUNCCODE         => 'DELETE'           ,
                    P_ID               => V_ID               ,
                    P_COMPANYNAME      => ''                 ,
                    P_COMPANYPAPERTYPE => ''                 ,
                    P_COMPANYPAPERNO   => ''                 ,
                    P_COMPANYMANAGERNO => ''                 ,
                    P_COMPANYENDTIME   => ''                 ,
                    P_NAME             => ''                 ,
                    P_PAPERTYPE        => ''                 ,
                    P_PAPERNO          => ''                 ,
                    P_PHONENO          => ''                 ,
                    P_ADDRESS          => ''                 ,
                    P_EMAIL            => ''                 ,
                    P_OUTBANK          => ''                 ,
                    P_OUTACCT          => ''                 ,
                    P_STARTCARDNO      => ''                 ,
                    P_ENDCARDNO        => ''                 ,
                    P_BUYCARDDATE      => ''                 ,
                    P_BUYCARDNUM       => ''                 ,
                    P_BUYCARDMONEY     => ''                 ,
                    P_CHARGEMONEY      => ''                 ,
                    P_REMARK           => ''                 ,
                    P_CURROPER         => P_CURROPER         ,
                    P_CURRDEPT         => P_CURRDEPT         ,
                    P_RETCODE          => P_RETCODE          ,
                    P_RETMSG           => P_RETMSG
                );
                IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                ROLLBACK; RETURN;
            END;
            --新增个人购卡记录
            BEGIN
                SP_PB_PerBuyCardReg(
                    P_FUNCCODE              => 'ADD'          ,
                    P_ID                    => ''             ,
                    P_NAME                  => P_NAME         ,
                    P_BIRTHDAY              => P_BIRTHDAY     ,
                    P_PAPERTYPE             => P_PAPERTYPE    ,
                    P_PAPERNO               => P_IDCARDNO     ,
                    P_SEX                   => P_SEX          ,
                    P_PHONENO               => P_PHONE        ,
                    P_ADDRESS               => P_ADDRESS      ,
                    P_EMAIL                 => P_EMAIL        ,
                    P_STARTCARDNO           => ''             ,
                    P_ENDCARDNO             => ''             ,
                    P_BUYCARDDATE           => ''             ,
                    P_BUYCARDNUM            => ''             ,
                    P_BUYCARDMONEY          => ''             ,
                    P_CHARGEMONEY           => ''             ,
                    P_REMARK                => p_ORDERNO      ,
                    P_CURROPER              => P_CURROPER     ,
                    P_CURRDEPT              => P_CURRDEPT     ,
                    P_RETCODE               => P_RETCODE      ,
                    P_RETMSG                => P_RETMSG
                    );
                IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
            EXCEPTION WHEN OTHERS THEN
                ROLLBACK; RETURN;
            END;
        END IF;
        --更新订单表
        BEGIN
            UPDATE TF_F_ORDERFORM
            SET   ORDERSTATE        = '01' ,
                  ORDERTYPE         = P_ORDERTYPE,
                  GROUPNAME         = P_GROUPNAME,
                  NAME              = P_NAME,
                  PHONE             = P_PHONE,
                  PAPERTYPE         = P_PAPERTYPE,
                  IDCARDNO          = P_IDCARDNO,
                  TOTALMONEY        = P_TOTALMONEY,
                  REMARK            = P_REMARK,
                  CASHGIFTMONEY     = P_CASHGIFTMONEY,
                  CHARGECARDMONEY   = P_CHARGECARDMONEY,
                  SZTCARDMONEY      = P_SZTCARDMONEY,
                  LVYOUMONEY        = P_LVYOUMONEY,
                  READERMONEY       = P_READERMONEY,
                  GARDENCARDMONEY   = P_GARDENCARDMONEY,
                  RELAXCARDMONEY    = P_RELAXCARDMONEY,
                  CUSTOMERACCMONEY  = P_CUSTOMERACCMONEY,
                  INVOICETOTALMONEY = P_INVOICETOTALMONEY,
                  GETDEPARTMENT     = P_GETDEPARTMENT,
                  GETDATE           = P_GETDATE,
                  UPDATEDEPARTNO    = p_currDept,
                  UPDATESTAFFNO     = p_currOper,
                  UPDATETIME        = v_today ,
                  MANAGERDEPT       = P_MANAGERDEPT,
                  MANAGER           = P_MANAGER
            WHERE ORDERNO = p_ORDERNO
            AND   TRANSACTOR = p_currOper
            AND   ORDERSTATE = '00' --修改中
            AND   USETAG = '1'; --有效

            IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;

        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570308';
            p_retMsg := '修改订单表失败,'|| SQLERRM ;
            ROLLBACK;RETURN;
        END;

        --删除明细表
        BEGIN
            DELETE FROM TF_F_CASHGIFTORDER WHERE ORDERNO = p_ORDERNO;
            DELETE FROM TF_F_CHARGECARDORDER WHERE ORDERNO = p_ORDERNO;
            DELETE FROM TF_F_SZTCARDORDER WHERE ORDERNO = p_ORDERNO;
            DELETE FROM TF_F_READERORDER WHERE ORDERNO = p_ORDERNO;
            DELETE FROM TF_F_GARDENCARDORDER WHERE ORDERNO = p_ORDERNO;
            DELETE FROM TF_F_RELAXCARDORDER WHERE ORDERNO = p_ORDERNO;
            DELETE FROM TF_F_ORDERINVOICE WHERE ORDERNO = p_ORDERNO;
            DELETE FROM TF_F_PAYTYPE WHERE ORDERNO = p_ORDERNO;
        EXCEPTION WHEN OTHERS THEN
            p_retCode := 'S094570309';
            p_retMsg := '删除订单明细表失败,'|| SQLERRM ;
            ROLLBACK;RETURN;
        END;

        --插入利金卡订单明细表
        BEGIN
            FOR cur_data IN
            (
                SELECT * FROM tmp_order TMP
                WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '0'  --代表礼金卡
            )
            LOOP
                BEGIN
                    INSERT INTO TF_F_CASHGIFTORDER (ORDERNO,VALUE,COUNT,SUM,LEFTQTY)
                    VALUES
                    (p_ORDERNO,to_number(cur_data.f2),to_number(cur_data.f3),to_number(cur_data.f4),to_number(cur_data.f3));
                    exception when others then
                    p_retCode := 'S001002203';
                    p_retMsg := '插入利金卡订单明细表失败'|| SQLERRM ;
                    rollback; return;
                END;
            END LOOP;
        END;
        --插入充值卡订单明细表
        BEGIN
           FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '1'  --代表充值卡
           )
           LOOP
              BEGIN
                  INSERT INTO TF_F_CHARGECARDORDER
                  (ORDERNO,VALUECODE,COUNT,SUM,LEFTQTY)
                  VALUES
                  (p_ORDERNO,cur_data.f2,to_number(cur_data.f3),
                  to_number(cur_data.f4),to_number(cur_data.f3));
                  exception when others then
                  p_retCode := 'S001002204';
                  p_retMsg := '插入充值卡订单明细表失败'|| SQLERRM ;
                  rollback; return;
              END;
           END LOOP;
        END;
        --插入苏州通卡订单明细表
        BEGIN
          FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '2'  --代表苏州通卡
           )
           LOOP
              BEGIN
                  INSERT INTO TF_F_SZTCARDORDER (ORDERNO,CARDTYPECODE,COUNT,UNITPRICE,TOTALCHARGEMONEY,TOTALMONEY,LEFTQTY)
                  VALUES
                  (p_ORDERNO,cur_data.f2, to_number(cur_data.f3),to_number(cur_data.f4),
                   to_number(cur_data.f5),to_number(cur_data.f6),to_number(cur_data.f3));
                  exception when others then
                  p_retCode := 'S001002205';
                  p_retMsg := '插入苏州通卡订单明细表失败'|| SQLERRM ;
                  rollback; return;
              END;
           END LOOP;
        END;
        

        --插入旅游卡订单明细表
        BEGIN
          FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '5'  --代表旅游卡
           )
           LOOP
              
                BEGIN
                  INSERT INTO TF_F_SZTCARDORDER (ORDERNO,CARDTYPECODE,COUNT,UNITPRICE,TOTALCHARGEMONEY,TOTALMONEY,LEFTQTY)
                  VALUES
                  (p_ORDERNO,cur_data.f2, to_number(cur_data.f3),to_number(cur_data.f4),
                   to_number(cur_data.f5),to_number(cur_data.f6),to_number(cur_data.f3));
                  exception when others then
                  p_retCode := 'S001002205';
                  p_retMsg := '插入苏州通卡订单明细表失败'|| SQLERRM ;
                  rollback; return;
                 END;
               
              
           END LOOP;
        END;

        IF P_READERMONEY > 0 THEN
            --记录读卡器明细表
            BEGIN
                INSERT INTO TF_F_READERORDER(ORDERNO,VALUE,COUNT,SUM,LEFTQTY) VALUES
                (p_ORDERNO,P_READERPRICE,P_READERNUM,P_READERMONEY,P_READERNUM);
            EXCEPTION when others then
                p_retCode := 'S094570339';
                p_retMsg := '记录读卡器明细表失败'|| SQLERRM ;
                rollback; return;
            END;
        END IF;
        
        IF P_GARDENCARDMONEY > 0 THEN
            --记录园林年卡明细表
            BEGIN
                INSERT INTO TF_F_GARDENCARDORDER(ORDERNO,VALUE,COUNT,SUM) VALUES
                (p_ORDERNO,P_GARDENCARDPRICE,P_GARDENCARDNUM,P_GARDENCARDMONEY);
            EXCEPTION when others then
                p_retCode := 'S094570340';
                p_retMsg := '记录园林年卡明细表失败'|| SQLERRM ;
                rollback; return;        
            END;
        END IF;
        
        IF P_RELAXCARDMONEY > 0 THEN
            --记录休闲年卡明细表
            BEGIN
                INSERT INTO TF_F_RELAXCARDORDER(ORDERNO,VALUE,COUNT,SUM) VALUES
                (p_ORDERNO,P_RELAXCARDPRICE,P_RELAXCARDNUM,P_RELAXCARDMONEY);
            EXCEPTION when others then
                p_retCode := 'S094570341';
                p_retMsg := '记录休闲年卡明细表失败'|| SQLERRM ;
                    rollback; return;        
            END;
        END IF;
        
        --更新开票信息
        BEGIN
           FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '3'  --代表开票信息
           )
           LOOP
              BEGIN
                  INSERT INTO TF_F_ORDERINVOICE (ORDERNO,INVOICETYPECODE,INVOICEMONEY)
                  VALUES
                  (p_ORDERNO,cur_data.f2, cur_data.f3);
                  exception when others then
                  p_retCode := 'S001002207';
                  p_retMsg :=  '插入订单发票明细表失败'|| SQLERRM ;
                  rollback; return;
              END;
           END LOOP;
        END;

        --更新付款方式表
        BEGIN
           FOR cur_data IN
           (
                  SELECT * FROM tmp_order TMP
                  WHERE TMP.F0 = P_SESSIONID AND TMP.F1 = '4'  --代表付款方式
           )
           LOOP
              BEGIN
                  INSERT INTO TF_F_PAYTYPE (ORDERNO,PAYTYPECODE,PAYTYPENAME)
                  VALUES
                  (p_ORDERNO,cur_data.f2, cur_data.f3);
                  exception when others then
                  p_retCode := 'S001002208';
                  p_retMsg :=  '插入订单付款方式表失败'|| SQLERRM ;
                  rollback; return;
              END;
           END LOOP;
        END;

        SP_GetSeq(seq => v_tradeID); --生成流水号
        --记录订单台账
        BEGIN
            INSERT INTO TF_F_ORDERTRADE (
                TRADEID         , ORDERNO           , TRADECODE       , MONEY             , GROUPNAME      , NAME      ,
                CASHGIFTMONEY   , CHARGECARDMONEY   , SZTCARDMONEY    , LVYOUMONEY        , CUSTOMERACCMONEY  , GETDEPARTMENT  , ORDERSTATE,
                GETDATE         , REMARK            , OPERATEDEPARTNO , OPERATESTAFFNO    , OPERATETIME    , READERMONEY ,
                GARDENCARDMONEY   , RELAXCARDMONEY
           )VALUES(
                v_tradeID       , p_ORDERNO         , '01'            , P_TOTALMONEY       , P_GROUPNAME    , P_NAME    ,
                P_CASHGIFTMONEY , P_CHARGECARDMONEY , P_SZTCARDMONEY  , P_LVYOUMONEY       , P_CUSTOMERACCMONEY , P_GETDEPARTMENT, '00'      ,
                P_GETDATE       , P_REMARK          , p_currDept      , p_currOper         , v_today        , P_READERMONEY ,
                P_GARDENCARDMONEY ,P_RELAXCARDMONEY
                );
            exception when others then
            p_retCode := 'S094570301';
            p_retMsg :=  '插入订单台账表失败'|| SQLERRM ;
            rollback; return;
        END;
    END IF;

    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/
show errors
