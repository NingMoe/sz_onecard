/*
订单确认完成返销
创建 殷华荣 2013-03-28
*/
CREATE OR REPLACE PROCEDURE SP_GC_SubmissionRollBack
(
    p_orderNo    char, 
    p_currOper  char,
    p_currDept  char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
AS
    v_totalValue int      ;
    v_quantity   int      ;
    v_today      date:=sysdate     ;
    V_AMOUNT     int;
    V_COUNT      int;
    V_ACCID      CHAR(12);
    V_SUPPLYSTAFFNO CHAR(6);
    V_SUPPLYDEPARTNO VARCHAR2(8);
    v_ex         exception;
    v_seqNo      char(16) ;
    v_cancelTradeID  char(16);
    v_tradecode  char(2);
    v_tradeid    char(16);
BEGIN
    begin
        select TRADECODE into v_tradecode from(
            select TRADECODE,OPERATESTAFFNO from TF_F_ORDERTRADE 
            where ORDERNO = p_orderNo 
            and to_char(OPERATETIME,'yyyyMMdd') = to_char(sysdate,'yyyyMMdd') 
            order by OPERATETIME desc
       )where OPERATESTAFFNO = p_currOper
        and   TRADECODE = '10'
        and   rownum = 1;
    exception when no_data_found then
        p_retCode := 'S094570338';
        p_retMsg  := '只能返销当天当营业员订单完成确认操作,'||SQLERRM;
        RETURN;
    end;
    
    begin
        for v_ch in ( select * from TF_F_CHARGECARDRELATION where ORDERNO = p_orderNo)
           loop
                   /*返销充值卡到激活未直销状态*/
                    BEGIN
                        SP_CC_DirectSale_RollBack(v_ch.fromcardno, v_ch.tocardno,
                            p_currOper, p_currDept, p_retCode, p_retMsg);
                
                        IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
                            EXCEPTION WHEN OTHERS THEN
                                ROLLBACK; RETURN;
                    END;
                    
                    select TRADEID into v_cancelTradeID from TF_XFC_BATCHSELL 
            where STARTCARDNO = v_ch.fromcardno and ENDCARDNO = v_ch.tocardno
            and TRADETYPECODE = '84' and RSRV1 = '0';
                    
            --更新旧台账
            -- 5)更新旧记录ID
            BEGIN
              SP_GetSeq(seq => v_seqNo);
              UPDATE TF_XFC_BATCHSELL
              SET RSRV1  = '1',
              RSRV2 = v_seqNo
              WHERE TRADEID = v_cancelTradeID;
              IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
              EXCEPTION
                 WHEN OTHERS THEN
                     p_retCode := 'S943901B03';
                     p_retMsg  := '更新订单完成确认台账失败' || SQLERRM;
                     ROLLBACK; RETURN;
            END;
            --增加新返销台账
            BEGIN
                INSERT INTO TF_XFC_BATCHSELL(TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO,
                     OPERATETIME, RSRV2)
                VALUES(v_seqNo, '85', v_ch.fromcardno, v_ch.tocardno,
                     v_today,  v_cancelTradeID);
            EXCEPTION WHEN OTHERS THEN
                  p_retCode := 'S007P02B02'; p_retMsg := '新增批量直销操作台帐失败,' || SQLERRM;
                  ROLLBACK; RETURN;
            END;
            
            --返销充值卡现金台账
            begin
                select TRADEID into v_cancelTradeID from TF_XFC_SELLFEE 
                where STARTCARDNO = v_ch.fromcardno and ENDCARDNO = v_ch.tocardno
                and TRADETYPECODE = '84' and RSRV1 = '0';
                
                --更新就台账记录
                BEGIN
                  UPDATE TF_XFC_SELLFEE
                  SET RSRV1  = '1',
                  RSRV2 = v_seqNo
                  WHERE TRADEID = v_cancelTradeID;
                  IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                         p_retCode := 'S943901B03';
                         p_retMsg  := '更新订单完成确认台账失败' || SQLERRM;
                         ROLLBACK; RETURN;
                END;
                --新增充值卡现金台账
                BEGIN
                    INSERT INTO TF_XFC_SELLFEE(TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO,OPERATETIME,RSRV2)
                    VALUES(v_seqNo, '85', v_ch.fromcardno, v_ch.tocardno, v_today,v_cancelTradeID);
                    EXCEPTION WHEN OTHERS THEN
                        p_retCode := 'S007P02B03'; p_retMsg  := '新增批量直销现金台帐失败,' || SQLERRM;
                        ROLLBACK; RETURN;
                END;
                exception when no_data_found then
                    p_retCode := '0000000000';
            end;
            -- 5)更新旧记录ID
            BEGIN
              UPDATE TF_F_ORDERTRADE
              SET CANCELTAG  = '1',
              CANCELTRADEID = v_seqNo
              WHERE TRADEID = v_cancelTradeID;
              IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
              EXCEPTION
                 WHEN OTHERS THEN
                     p_retCode := 'S943901B03';
                     p_retMsg  := '更新订单完成确认台账失败' || SQLERRM;
                     ROLLBACK; RETURN;
            END;
           
            --记录订单台账表
            BEGIN
               insert into TF_F_ORDERTRADE 
               (    
                  TRADEID,                    ORDERNO,                    ORDERSTATE,                TRADECODE,        
                  CANCELTRADEID,        OPERATEDEPARTNO,    OPERATESTAFFNO,        OPERATETIME
               )
               values
               (
                  v_seqNo,                p_orderNo,        '08',                            '11',                    
                  v_cancelTradeID,    p_currDept,                p_currOper,           v_today    
               );
               EXCEPTION WHEN OTHERS THEN
                  p_retCode := 'S943901B04'; p_retMsg  := '插入订单台账表失败,' || SQLERRM;
                  ROLLBACK; RETURN;
            END;
            
                    /*返销充值卡为未激活状态*/
                    BEGIN
                SP_CC_Activate_ChargeCard(v_ch.fromcardno, v_ch.tocardno,'3','',
                      v_seqNo, p_currOper, p_currDept, p_retCode, p_retMsg);
                  IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                  ROLLBACK; RETURN;
                    END;
           end loop;
    end;
    /*返销专有账户充值*/
    begin
    --查询专有账户批量充值批次号
    for v_c in (select * from TF_F_CUSTOMERACCRELATION where ORDERNO = p_orderNo)
        loop
            -- 2) Update the master tracing record
            BEGIN
              UPDATE TF_F_SUPPLYSUM
               SET EXAMSTAFFNO = null,
                   EXAMTIME    = null,
                   STATECODE   = '1'
               WHERE STATECODE = '2' AND ID = v_c.batchno;

              IF SQL%ROWCOUNT != 1 THEN
                RAISE V_EX;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                P_RETCODE := 'S006014012';
                P_RETMSG := '更新专有帐户批量充值总量台帐失败,' || SQLERRM;
                ROLLBACK;
                RETURN;
            END;

            SELECT SUM(AMOUNT)
              INTO V_AMOUNT
              FROM TF_F_SUPPLYSUM
             WHERE ID = v_c.batchno;

            -- 3) Update the finance detail records' state
            BEGIN
              UPDATE TF_F_SUPPLYCHECK
                 SET STATECODE       = '1',
                     OPERATESTAFFNO  = P_CURROPER,
                     OPERATEDEPARTID = P_CURRDEPT,
                     OPERATETIME     = V_TODAY
               WHERE ID = v_c.batchno
                 AND STATECODE = '2';

              IF SQL%ROWCOUNT != V_AMOUNT THEN
                RAISE V_EX;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                P_RETCODE := 'S006014013';
                P_RETMSG := '更新专有帐户批量财务充值明细失败,' || SQLERRM;
                ROLLBACK;
                RETURN;
            END;
            
            -- Approved, update the accounts' balance
            BEGIN
              V_COUNT := 0;
              FOR V_CURSOR IN (SELECT FI.ID, FI.CARDNO,FI.ACCT_TYPE_NO, FI.SUPPLYMONEY OFFERMONEY
                                 FROM TF_F_SUPPLYCHECK FI
                                WHERE FI.ID = v_c.batchno)
              LOOP

                SELECT TO_CHAR(TF.ACCT_ID) INTO V_ACCID FROM TF_F_CUST_ACCT TF
                WHERE TF.ACCT_TYPE_NO = V_CURSOR.ACCT_TYPE_NO AND TF.ICCARD_NO = V_CURSOR.CARDNO;

                SELECT SUPPLYSTAFFNO,SUPPLYDEPARTNO INTO V_SUPPLYSTAFFNO,V_SUPPLYDEPARTNO FROM tf_f_supplysum WHERE ID = V_CURSOR.ID;

                --充值
                SP_CA_CHARGE_nocom(V_ACCID,V_CURSOR.CARDNO,V_CURSOR.OFFERMONEY * (-1),
            '0','8L',V_SUPPLYSTAFFNO,V_SUPPLYDEPARTNO,v_seqNo,P_RETCODE,P_RETMSG);
                IF p_retCode != '0000000000' THEN
                    ROLLBACK; RETURN;
                END IF;
                V_COUNT := V_COUNT + SQL%ROWCOUNT;
              END LOOP;
              /*IF V_COUNT != V_AMOUNT THEN
                RAISE V_EX;
              END IF;*/
            EXCEPTION
              WHEN OTHERS THEN
                P_RETCODE := 'S006014015';
                P_RETMSG := '更新专有帐户批量可充值帐户失败,' || SQLERRM;
                ROLLBACK;
                RETURN;
            END;
            
            --返销订单台账 专有账户记录
            select TRADEID into v_cancelTradeID 
            from TF_F_ORDERTRADE 
            where orderno = p_orderNo 
            and TRADECODE = '10' and CANCELTAG = '0' and RSRV1 = v_c.batchno;
            
            -- 5)更新旧记录ID
            BEGIN
              UPDATE TF_F_ORDERTRADE
              SET CANCELTAG  = '1',
              CANCELTRADEID = v_seqNo
              WHERE TRADEID = v_cancelTradeID;
              IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
              EXCEPTION
                 WHEN OTHERS THEN
                     p_retCode := 'S094570351';
                     p_retMsg  := '更新订单完成确认台账失败' || SQLERRM;
                     ROLLBACK; RETURN;
            END;
           
            --记录订单台账表
            BEGIN
               insert into TF_F_ORDERTRADE 
               (    
                  TRADEID,                    ORDERNO,                    ORDERSTATE,                TRADECODE,        
                  CANCELTRADEID,        OPERATEDEPARTNO,    OPERATESTAFFNO,        OPERATETIME, RSRV1
               )
               values
               (
                  v_seqNo,                p_orderNo,        '08',                            '11',                    
                  v_cancelTradeID,    p_currDept,                p_currOper,           v_today    , v_c.batchno
               );
               EXCEPTION WHEN OTHERS THEN
                  p_retCode := 'S943901B04'; p_retMsg  := '插入订单台账表失败,' || SQLERRM;
                  ROLLBACK; RETURN;
            END;
            
        end loop;
    end;
    
    /*返销读卡器出售*/
    for v_c in ( select * from TF_F_READERRELATION where ORDERNO = p_orderNo)
    loop
    BEGIN
        SP_PB_SALEREADERROLLBACK(
            P_FUNCCODE         => 'BATCHSALEROLLBACK'   ,
            P_SERIALNUMBER     => v_c.BEGINSERIALNUMBER ,
            P_ENDSERIALNUMBER  => v_c.ENDSERIALNUMBER   ,
            P_READERNUMBER     => v_c.COUNT    ,
            p_REMARK           => '订单'       ,
            p_MONEY            => v_c.VALUE    ,
            p_TRADEID          => v_tradeid    ,
            P_CURROPER         => P_CURROPER   ,
            P_CURRDEPT         => P_CURRDEPT   ,
            P_RETCODE          => P_RETCODE    ,
            P_RETMSG           => P_RETMSG
        );
        IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK; RETURN;
    END;    
    
    --返销订单台账 读卡器记录
    select TRADEID into v_cancelTradeID 
    from TF_F_ORDERTRADE 
    where orderno = p_orderNo 
    and TRADECODE = '10' 
    and CANCELTAG = '0' 
    and RSRV1 = v_c.BEGINSERIALNUMBER;
    
    --更新旧记录ID
    BEGIN
        UPDATE TF_F_ORDERTRADE
        SET    CANCELTAG  = '1',
               CANCELTRADEID = v_tradeid
        WHERE TRADEID = v_cancelTradeID;
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570352';
            p_retMsg  := '更新订单完成确认台账失败' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    --记录订单台账
    BEGIN
       insert into TF_F_ORDERTRADE 
       (    
          TRADEID,      ORDERNO,            ORDERSTATE,         TRADECODE,     CANCELTRADEID   ,
          CANCELTAG,    OPERATEDEPARTNO,    OPERATESTAFFNO,     OPERATETIME,   RSRV1    
       )
       values
       (
          v_tradeid,    p_orderNo,        '08',                  '11',         v_cancelTradeID ,
          '0',          p_currDept,        p_currOper,           v_today    ,  v_c.BEGINSERIALNUMBER
       );
       EXCEPTION WHEN OTHERS THEN
          p_retCode := 'S094570350'; p_retMsg  := '更新订单台账表失败,' || SQLERRM;
          ROLLBACK; RETURN;
    END;
    end loop;
    
    --更新订单表
    BEGIN
        UPDATE TF_F_ORDERFORM SET   ORDERSTATE = '07',UPDATEDEPARTNO=p_currDept,UPDATESTAFFNO=p_currOper,UPDATETIME=v_today WHERE ORDERNO = p_orderNo;
         IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
          p_retCode := 'S943901B02'; p_retMsg  := '更新订单表失败,' || SQLERRM;
          ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg := '';
    COMMIT; RETURN;
END;
/

show errors;
