create or replace procedure SP_GC_ORDERCARDCHANGE
(
    P_SESSIONID    varchar2 ,
    p_ORDERNO      char     , --订单号
    P_TOTALMONEY   integer,   --总金额
    P_CASHGIFTMONEY     integer, --礼金卡总金额
    P_CHARGECARDMONEY   integer, --充值卡总金额
    P_SZTCARDMONEY      integer, --市民卡B卡总金额
    P_LVYOUMONEY        integer, --旅游卡总金额
    P_CUSTOMERACCMONEY  integer, --专有账户总充值金额
    P_READERMONEY       integer, --读卡器总金额
    P_GARDENCARDMONEY   integer, --园林年卡总金额
    P_RELAXCARDMONEY    integer, --休闲年卡总金额
    
    P_READERNUM         integer, --读卡器数量
    P_READERPRICE       integer, --读卡器单价
    P_GARDENCARDNUM     integer, --园林年卡数量
    P_GARDENCARDPRICE   integer, --园林年卡单价
    P_RELAXCARDNUM      integer, --休闲年卡数量
    P_RELAXCARDPRICE    integer, --休闲年卡单价
    
    P_ISRELATED    char, --是否关联

    p_currOper     char,           -- Current Operator
    p_currDept     char,           -- Curretn Operator's Department
    p_retCode      out char,       -- Return Code
    p_retMsg       out varchar2    -- Return Message
)
AS
    V_COUNT         INT;
    v_orderseqNo    CHAR(16);
    v_tradeID       CHAR(16);
    v_today         date:=sysdate;
    v_ex            EXCEPTION;
    V_ID            CHAR(16);
/*
    订单卡更换
    石磊
    2013-05-26
*/
BEGIN    
    --更新订单表
    BEGIN
        UPDATE TF_F_ORDERFORM
        SET   ORDERSTATE        = '03' , --完成分配，订单重新制卡
              ISRELATED         = P_ISRELATED  , 
              CASHGIFTMONEY     = P_CASHGIFTMONEY,
              CHARGECARDMONEY   = P_CHARGECARDMONEY,
              SZTCARDMONEY      = P_SZTCARDMONEY,
              LVYOUMONEY        = P_LVYOUMONEY,
              READERMONEY       = P_READERMONEY,
              GARDENCARDMONEY   = P_GARDENCARDMONEY,
              RELAXCARDMONEY    = P_RELAXCARDMONEY,
              CUSTOMERACCMONEY  = P_CUSTOMERACCMONEY,
              UPDATEDEPARTNO    = p_currDept,
              UPDATESTAFFNO     = p_currOper,
              UPDATETIME        = v_today
        WHERE ORDERNO = p_ORDERNO
        AND   GETDEPARTMENT = p_currDept
        AND   ORDERSTATE = '07' --订单领用完成
        AND   TOTALMONEY = P_TOTALMONEY --总金额一致
        AND   USETAG = '1'; --有效

        IF  SQL%ROWCOUNT != 1 THEN RAISE V_EX; END IF;

    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570308';
        p_retMsg := '修改订单表失败,'|| SQLERRM ;
        ROLLBACK;RETURN;
    END;
	SP_GetSeq(seq => v_tradeID); --生成流水号
    --返销制卡台账
    BEGIN
        UPDATE TF_F_ORDERTRADE
        SET    CANCELTAG = '1' ,
               CANCELTRADEID = v_tradeID
        WHERE  ORDERNO = p_ORDERNO
        AND    TRADECODE = '07'
        AND    CANCELTAG = '0';
        
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S943901B03';
            p_retMsg  := '返销制卡台账失败' || SQLERRM;
            ROLLBACK; RETURN;            
    END;
    
    --取消利金卡订单关系
    BEGIN
        DELETE FROM TF_F_CASHGIFTRELATION WHERE ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570324';
        p_retMsg  := '取消利金卡订单关系失败,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;    
    
    --取消充值卡订单关系
    BEGIN
        DELETE FROM TF_F_CHARGECARDRELATION WHERE ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570325';
        p_retMsg  := '取消充值卡订单关系失败,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;
    
    --取消市民卡B卡订单关系（包括旅游卡）
    BEGIN
        DELETE FROM TF_F_SZTCARDRELATION WHERE ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570326';
        p_retMsg  := '取消市民卡B卡订单关系失败,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;
    
 
    --取消专有账户订单关系
    BEGIN
        DELETE FROM TF_F_CUSTOMERACCRELATION WHERE ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570327';
        p_retMsg  := '取消专有账户订单关系失败,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;
    
    --取消读卡器订单关系
    BEGIN
        DELETE FROM TF_F_READERRELATION WHERE ORDERNO = p_ORDERNO;
    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S094570348';
        p_retMsg  := '取消读卡器订单关系失败,'|| SQLERRM;
        ROLLBACK; RETURN;            
    END;    
    
    --删除明细表
    BEGIN
        DELETE FROM TF_F_CASHGIFTORDER WHERE ORDERNO = p_ORDERNO;
        DELETE FROM TF_F_CHARGECARDORDER WHERE ORDERNO = p_ORDERNO;
        DELETE FROM TF_F_SZTCARDORDER WHERE ORDERNO = p_ORDERNO;
        DELETE FROM TF_F_READERORDER WHERE ORDERNO = p_ORDERNO;
        DELETE FROM TF_F_GARDENCARDORDER WHERE ORDERNO = p_ORDERNO;
        DELETE FROM TF_F_RELAXCARDORDER WHERE ORDERNO = p_ORDERNO;
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

    
    --记录订单台账
    BEGIN
        INSERT INTO TF_F_ORDERTRADE (
            TRADEID           , ORDERNO           , TRADECODE       , MONEY             , GROUPNAME      , NAME        ,
            CASHGIFTMONEY     , CHARGECARDMONEY   , SZTCARDMONEY    , LVYOUMONEY        , CUSTOMERACCMONEY  , GETDEPARTMENT  , ORDERSTATE  ,
            GETDATE           , REMARK            , OPERATEDEPARTNO , OPERATESTAFFNO    , OPERATETIME    , READERMONEY ,
            GARDENCARDMONEY   , RELAXCARDMONEY
       )SELECT 
            v_tradeID         , p_ORDERNO         , '13'            , P_TOTALMONEY       , t.GROUPNAME    , t.NAME    ,
            P_CASHGIFTMONEY   , P_CHARGECARDMONEY , P_SZTCARDMONEY  , P_LVYOUMONEY       , P_CUSTOMERACCMONEY , t.GETDEPARTMENT, '00'      ,
            t.GETDATE         , t.REMARK          , p_currDept      , p_currOper         , v_today        , P_READERMONEY ,
            P_GARDENCARDMONEY , P_RELAXCARDMONEY
        FROM TF_F_ORDERFORM t
        WHERE  ORDERNO = p_ORDERNO;
        exception when others then
        p_retCode := 'S094570301';
        p_retMsg :=  '插入订单台账表失败'|| SQLERRM ;
        rollback; return;
    END;
    
    p_retCode := '0000000000'; p_retMsg  := '';
    COMMIT; RETURN;
END;
/
show errors