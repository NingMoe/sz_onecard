/*
����ȷ����ɷ���
���� ���� 2013-03-28
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
        p_retMsg  := 'ֻ�ܷ������쵱ӪҵԱ�������ȷ�ϲ���,'||SQLERRM;
        RETURN;
    end;
    
    begin
        for v_ch in ( select * from TF_F_CHARGECARDRELATION where ORDERNO = p_orderNo)
           loop
                   /*������ֵ��������δֱ��״̬*/
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
                    
            --���¾�̨��
            -- 5)���¾ɼ�¼ID
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
                     p_retMsg  := '���¶������ȷ��̨��ʧ��' || SQLERRM;
                     ROLLBACK; RETURN;
            END;
            --�����·���̨��
            BEGIN
                INSERT INTO TF_XFC_BATCHSELL(TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO,
                     OPERATETIME, RSRV2)
                VALUES(v_seqNo, '85', v_ch.fromcardno, v_ch.tocardno,
                     v_today,  v_cancelTradeID);
            EXCEPTION WHEN OTHERS THEN
                  p_retCode := 'S007P02B02'; p_retMsg := '��������ֱ������̨��ʧ��,' || SQLERRM;
                  ROLLBACK; RETURN;
            END;
            
            --������ֵ���ֽ�̨��
            begin
                select TRADEID into v_cancelTradeID from TF_XFC_SELLFEE 
                where STARTCARDNO = v_ch.fromcardno and ENDCARDNO = v_ch.tocardno
                and TRADETYPECODE = '84' and RSRV1 = '0';
                
                --���¾�̨�˼�¼
                BEGIN
                  UPDATE TF_XFC_SELLFEE
                  SET RSRV1  = '1',
                  RSRV2 = v_seqNo
                  WHERE TRADEID = v_cancelTradeID;
                  IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                         p_retCode := 'S943901B03';
                         p_retMsg  := '���¶������ȷ��̨��ʧ��' || SQLERRM;
                         ROLLBACK; RETURN;
                END;
                --������ֵ���ֽ�̨��
                BEGIN
                    INSERT INTO TF_XFC_SELLFEE(TRADEID, TRADETYPECODE, STARTCARDNO, ENDCARDNO,OPERATETIME,RSRV2)
                    VALUES(v_seqNo, '85', v_ch.fromcardno, v_ch.tocardno, v_today,v_cancelTradeID);
                    EXCEPTION WHEN OTHERS THEN
                        p_retCode := 'S007P02B03'; p_retMsg  := '��������ֱ���ֽ�̨��ʧ��,' || SQLERRM;
                        ROLLBACK; RETURN;
                END;
                exception when no_data_found then
                    p_retCode := '0000000000';
            end;
            -- 5)���¾ɼ�¼ID
            BEGIN
              UPDATE TF_F_ORDERTRADE
              SET CANCELTAG  = '1',
              CANCELTRADEID = v_seqNo
              WHERE TRADEID = v_cancelTradeID;
              IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
              EXCEPTION
                 WHEN OTHERS THEN
                     p_retCode := 'S943901B03';
                     p_retMsg  := '���¶������ȷ��̨��ʧ��' || SQLERRM;
                     ROLLBACK; RETURN;
            END;
           
            --��¼����̨�˱�
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
                  p_retCode := 'S943901B04'; p_retMsg  := '���붩��̨�˱�ʧ��,' || SQLERRM;
                  ROLLBACK; RETURN;
            END;
            
                    /*������ֵ��Ϊδ����״̬*/
                    BEGIN
                SP_CC_Activate_ChargeCard(v_ch.fromcardno, v_ch.tocardno,'3','',
                      v_seqNo, p_currOper, p_currDept, p_retCode, p_retMsg);
                  IF p_retCode != '0000000000' THEN RAISE v_ex; END IF;
                EXCEPTION WHEN OTHERS THEN
                  ROLLBACK; RETURN;
                    END;
           end loop;
    end;
    /*����ר���˻���ֵ*/
    begin
    --��ѯר���˻�������ֵ���κ�
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
                P_RETMSG := '����ר���ʻ�������ֵ����̨��ʧ��,' || SQLERRM;
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
                P_RETMSG := '����ר���ʻ����������ֵ��ϸʧ��,' || SQLERRM;
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

                --��ֵ
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
                P_RETMSG := '����ר���ʻ������ɳ�ֵ�ʻ�ʧ��,' || SQLERRM;
                ROLLBACK;
                RETURN;
            END;
            
            --��������̨�� ר���˻���¼
            select TRADEID into v_cancelTradeID 
            from TF_F_ORDERTRADE 
            where orderno = p_orderNo 
            and TRADECODE = '10' and CANCELTAG = '0' and RSRV1 = v_c.batchno;
            
            -- 5)���¾ɼ�¼ID
            BEGIN
              UPDATE TF_F_ORDERTRADE
              SET CANCELTAG  = '1',
              CANCELTRADEID = v_seqNo
              WHERE TRADEID = v_cancelTradeID;
              IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
              EXCEPTION
                 WHEN OTHERS THEN
                     p_retCode := 'S094570351';
                     p_retMsg  := '���¶������ȷ��̨��ʧ��' || SQLERRM;
                     ROLLBACK; RETURN;
            END;
           
            --��¼����̨�˱�
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
                  p_retCode := 'S943901B04'; p_retMsg  := '���붩��̨�˱�ʧ��,' || SQLERRM;
                  ROLLBACK; RETURN;
            END;
            
        end loop;
    end;
    
    /*��������������*/
    for v_c in ( select * from TF_F_READERRELATION where ORDERNO = p_orderNo)
    loop
    BEGIN
        SP_PB_SALEREADERROLLBACK(
            P_FUNCCODE         => 'BATCHSALEROLLBACK'   ,
            P_SERIALNUMBER     => v_c.BEGINSERIALNUMBER ,
            P_ENDSERIALNUMBER  => v_c.ENDSERIALNUMBER   ,
            P_READERNUMBER     => v_c.COUNT    ,
            p_REMARK           => '����'       ,
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
    
    --��������̨�� ��������¼
    select TRADEID into v_cancelTradeID 
    from TF_F_ORDERTRADE 
    where orderno = p_orderNo 
    and TRADECODE = '10' 
    and CANCELTAG = '0' 
    and RSRV1 = v_c.BEGINSERIALNUMBER;
    
    --���¾ɼ�¼ID
    BEGIN
        UPDATE TF_F_ORDERTRADE
        SET    CANCELTAG  = '1',
               CANCELTRADEID = v_tradeid
        WHERE TRADEID = v_cancelTradeID;
        IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
    EXCEPTION
        WHEN OTHERS THEN
            p_retCode := 'S094570352';
            p_retMsg  := '���¶������ȷ��̨��ʧ��' || SQLERRM;
            ROLLBACK; RETURN;
    END;
    
    --��¼����̨��
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
          p_retCode := 'S094570350'; p_retMsg  := '���¶���̨�˱�ʧ��,' || SQLERRM;
          ROLLBACK; RETURN;
    END;
    end loop;
    
    --���¶�����
    BEGIN
        UPDATE TF_F_ORDERFORM SET   ORDERSTATE = '07',UPDATEDEPARTNO=p_currDept,UPDATESTAFFNO=p_currOper,UPDATETIME=v_today WHERE ORDERNO = p_orderNo;
         IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;
        EXCEPTION WHEN OTHERS THEN
          p_retCode := 'S943901B02'; p_retMsg  := '���¶�����ʧ��,' || SQLERRM;
          ROLLBACK; RETURN;
    END;

    p_retCode := '0000000000'; p_retMsg := '';
    COMMIT; RETURN;
END;
/

show errors;
