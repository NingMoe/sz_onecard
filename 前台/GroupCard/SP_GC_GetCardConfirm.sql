
/* 
        订单确认完成 
        创建 殷华荣 2013-03-27
*/

CREATE OR REPLACE PROCEDURE SP_GC_GetCardConfirm
(
    p_orderNo  varchar2,   --订单号
    p_transactor char,     --经办人
    p_custName   varchar2, --客户姓名
    p_payMode    char,     --付款方式
    p_accRecv    char,     --到账标记
    p_recvDate   char,     --到账日期
    p_remark     varchar2,
    p_currOper   char,
    p_currDept   char,
    p_retCode    out char,
    p_retMsg     out varchar2
)
AS
    v_seqNo      char(16) ;
    v_ex         exception;
    v_totalValue int      ;
    v_quantity   int      ;
    v_today      date:=sysdate ;
    v_dept       char(4)  ;
    V_AMOUNT     int;
    V_COUNT      int;
    V_ACCID      CHAR(12);
    V_SUPPLYSTAFFNO CHAR(6);
    V_SUPPLYDEPARTNO VARCHAR2(8);
    V_TRADEID    CHAR(16);
    v_beginserialnumber char(16);
    v_endserialnumber char(16);
    v_num        int;
    v_price      int;
    V_FROMCARD2  INT;
    V_TOCARD2    INT; 
    V_CARDNUM     INT;
    V_CHARGECARDNUM  INT;
BEGIN
  
    /* 完成充值卡的激活直销 */
    begin
       for v_ch in ( select * from TF_F_CHARGECARDRELATION where ORDERNO = p_orderNo)
         loop
            --判断充值卡是否是出库状态
            BEGIN
              V_FROMCARD2:=TO_NUMBER(SUBSTR(v_ch.fromcardno,7,8));
              V_TOCARD2:=TO_NUMBER(SUBSTR(v_ch.tocardno,7,8));
              V_CARDNUM:=V_TOCARD2-V_FROMCARD2+1;
              SELECT COUNT(*) INTO V_CHARGECARDNUM FROM TD_XFC_INITCARD T WHERE T.XFCARDNO BETWEEN v_ch.fromcardno AND v_ch.tocardno
             AND T.CARDSTATECODE ='3';
             IF V_CHARGECARDNUM!= V_CARDNUM THEN
                p_retCode := 'A000P00B01'; p_retMsg  := '卡号段'||v_ch.fromcardno||'到'||v_ch.tocardno||'的充值卡在库里不全为出库状态';
                ROLLBACK;RETURN;
           END IF;
            END;
            --激活充值卡
            BEGIN
              SP_GetSeq(seq => v_seqNo);
              SP_CC_Activate_ChargeCard(v_ch.fromcardno, v_ch.tocardno, '4', '',
                  v_seqNo, p_currOper, p_currDept, p_retCode, p_retMsg);
              IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
              EXCEPTION WHEN OTHERS THEN
                ROLLBACK; RETURN;
            END;
            --直销充值卡
            BEGIN
                --select tf.departno into v_dept from td_m_insidestaff tf where tf.staffno = p_transactor;
                SP_CC_DirectSale_ChargeCard(v_ch.fromcardno, v_ch.tocardno,
                    v_totalValue, v_quantity, v_today,
                    p_currOper, p_currDept, p_retCode, p_retMsg);

                IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                    ROLLBACK; RETURN;
            END;

            BEGIN
                INSERT INTO TF_XFC_BATCHSELL(TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO,
                    CARDVALUE, AMOUNT, TOTALMONEY, CUSTNAME, PAYTYPE, PAYTAG,
                    PAYTIME,  STAFFNO, OPERATETIME, REMARK, RSRV1)
                VALUES(v_seqNo, '84', v_ch.fromcardno, v_ch.tocardno,
                    v_totalValue/v_quantity, v_quantity, v_totalValue, p_custName, p_payMode, p_accRecv,
                    to_date(p_recvDate, 'YYYYMMDD'),  p_currOper, v_today, p_remark, '0');
            EXCEPTION WHEN OTHERS THEN
                  p_retCode := 'S007P02B02'; p_retMsg := '新增批量直销操作台帐失败,' || SQLERRM;
                  ROLLBACK; RETURN;
            END;

            IF p_payMode = '1' THEN
                --4) Log the trade fee when paid by cash
                BEGIN
                    INSERT INTO TF_XFC_SELLFEE(TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO, MONEY, STAFFNO,OPERATETIME,RSRV1)
                    VALUES(v_seqNo, '84', v_ch.fromcardno, v_ch.tocardno, v_totalValue, p_currOper, v_today,'0');
                EXCEPTION WHEN OTHERS THEN
                    p_retCode := 'S007P02B03'; p_retMsg  := '新增批量直销现金台帐失败,' || SQLERRM;
                    ROLLBACK; RETURN;
                END;
            END IF;
            
            --记录订单台账
            BEGIN
               insert into TF_F_ORDERTRADE 
               (    
                  TRADEID,        ORDERNO,                    ORDERSTATE,                TRADECODE,        GROUPNAME,    
                  CANCELTAG,    OPERATEDEPARTNO,    OPERATESTAFFNO,        OPERATETIME
               )
               values
               (
                  v_seqNo,    p_orderNo,        '07',                            '10',                    p_custName,
                  '0',                p_currDept,                p_currOper,           v_today    
               );
               EXCEPTION WHEN OTHERS THEN
                  p_retCode := 'S943901B03'; p_retMsg  := '更新订单台账表失败,' || SQLERRM;
                  ROLLBACK; RETURN;
            END;
            
         end loop;
    end;
    
    /* 完成专有账户的充值 */
    begin
      --查询专有账户批量充值批次号
      for v_c in (select * from TF_F_CUSTOMERACCRELATION where ORDERNO = p_orderNo)
        loop
            -- 2) Update the master tracing record
            BEGIN
              UPDATE TF_F_SUPPLYSUM
               SET EXAMSTAFFNO = P_CURROPER,
                   EXAMTIME    = V_TODAY,
                   STATECODE   = '2'
               WHERE STATECODE = '1' AND ID = v_c.batchno;

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
                 SET STATECODE       = '2',
                     OPERATESTAFFNO  = P_CURROPER,
                     OPERATEDEPARTID = P_CURRDEPT,
                     OPERATETIME     = V_TODAY
               WHERE ID = v_c.batchno
                 AND STATECODE = '1';

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
                SP_CA_CHARGE_nocom(V_ACCID,V_CURSOR.CARDNO,V_CURSOR.OFFERMONEY,
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
            
            --记录订单台账
            BEGIN
               insert into TF_F_ORDERTRADE 
               (    
                  TRADEID,        ORDERNO,                    ORDERSTATE,                TRADECODE,        GROUPNAME,    
                  CANCELTAG,    OPERATEDEPARTNO,    OPERATESTAFFNO,        OPERATETIME,  RSRV1
               )
               values
               (
                  v_seqNo,    p_orderNo,        '07',                            '10',                    p_custName,
                  '0',                p_currDept,                p_currOper,           v_today    ,  v_c.batchno
               );
               EXCEPTION WHEN OTHERS THEN
                  p_retCode := 'S943901B03'; p_retMsg  := '更新订单台账表失败,' || SQLERRM;
                  ROLLBACK; RETURN;
            END;
            
        end loop; 
    end;
    /*完成读卡器出售*/
    for v_c in ( select ORDERNO,BEGINSERIALNUMBER,ENDSERIALNUMBER,VALUE PRICE,COUNT NUM from TF_F_READERRELATION where ORDERNO = p_orderNo)
    loop
    v_beginserialnumber := v_c.BEGINSERIALNUMBER;
    v_endserialnumber := v_c.ENDSERIALNUMBER;
    v_num := v_c.NUM;
    v_price := v_c.PRICE;
    BEGIN
        SP_PB_SALEREADER(
            P_FUNCCODE         => 'BATCHSALE'         ,
            P_SERIALNUMBER     => v_beginserialnumber ,
            P_ENDSERIALNUMBER  => v_endserialnumber   ,
            P_READERNUMBER     => v_num      ,
            p_CUSTNAME         => ''           ,
            p_CUSTSEX          => ''           ,
            p_CUSTBIRTH        => ''           ,
            p_PAPERTYPECODE    => ''           ,
            p_PAPERNO          => ''           ,
            p_CUSTADDR         => ''           ,
            p_CUSTPOST         => ''           ,
            p_CUSTPHONE        => ''           ,
            p_CUSTEMAIL        => ''           ,
            p_REMARK           => '订单'       ,
            p_MONEY            => v_price      ,
            p_TRADEID          => V_TRADEID    ,
            P_CURROPER         => P_CURROPER   ,
            P_CURRDEPT         => P_CURRDEPT   ,
            P_RETCODE          => P_RETCODE    ,
            P_RETMSG           => P_RETMSG
        );
        IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK; RETURN;
    END;    
    
    --记录订单台账
    BEGIN
       insert into TF_F_ORDERTRADE 
       (    
          TRADEID,      ORDERNO,            ORDERSTATE,         TRADECODE,     GROUPNAME,    
          CANCELTAG,    OPERATEDEPARTNO,    OPERATESTAFFNO,     OPERATETIME,   RSRV1
       )
       values
       (
          V_TRADEID,    p_orderNo,        '07',                  '10',         p_custName,
          '0',          p_currDept,        p_currOper,           v_today    ,  v_c.BEGINSERIALNUMBER
       );
       EXCEPTION WHEN OTHERS THEN
          p_retCode := 'S094570350'; p_retMsg  := '更新订单台账表失败,' || SQLERRM;
          ROLLBACK; RETURN;
    END;
    end loop;
    
    --更新订单表
    BEGIN
        UPDATE TF_F_ORDERFORM SET   ORDERSTATE = '08',UPDATEDEPARTNO=p_currDept,UPDATESTAFFNO=p_currOper,UPDATETIME=v_today WHERE ORDERNO = p_orderNo;
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
