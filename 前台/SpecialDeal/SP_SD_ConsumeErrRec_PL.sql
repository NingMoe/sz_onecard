CREATE OR REPLACE PROCEDURE SP_SD_ConsumeErrRec
(
    p_renewRemark     VARCHAR2,
    p_billMonth       CHAR    ,
    p_currOper        CHAR    ,
    p_currDept        CHAR    ,
    p_retCode     OUT CHAR    ,
    p_retMsg      OUT VARCHAR2
)
AS
    v_c               SYS_REFCURSOR;
    v_tradeTS         DATE;
    v_today           DATE := SYSDATE;
    v_seqNo           CHAR(16);
    v_quantity        INT     ;
    v_depositUpdated  INT     ;

    v_cardNo          TF_TRADE_ERROR_01.CARDNO%type;
    v_cardNoLast      TF_TRADE_ERROR_01.CARDNO%type := null;
    v_row             TF_TRADE_ERROR_01%rowtype;

    v_comsumeTimes    TF_F_CARDEWALLETACC.TOTALCONSUMETIMES%type;
    v_comsumeMoney    TF_F_CARDEWALLETACC.TOTALCONSUMEMONEY%type;
	v_count				int;
	v_cardstate       CHAR(2);
BEGIN
    v_quantity := 0;
    --1) update TF_F_CARDEWALLETACC info
    OPEN v_c FOR '
        SELECT *
        FROM  TF_TRADE_ERROR_' || p_billMonth || '
        WHERE DEALSTATECODE = ''0''
        AND   Trim(ID) IN (SELECT f0 FROM TMP_COMMON)
        AND   BALUNITNO IS NOT NULL
        AND   BALUNITNO <> ''NOTFOUND''
        AND   CARDNO IS NOT NULL
        ORDER BY CARDNO, CARDTRADENO';
    LOOP
	
	
	
        v_depositUpdated := 0;
        fetch v_c into v_row;
		      
		    
		    --�жϿ��Ƿ���Ի���ֻ��(10�ۿ�,11�����ۿ�,21�˿�δ����,22����δתֵ)�⼸��״̬�Ŀ��Ի���
        select CARDSTATE INTO v_cardstate from TF_F_CARDREC WHERE CARDNO=v_row.cardno;
        IF v_cardstate  NOT IN('10','11','21','22') THEN
          raise_application_error(-20101,
                        '����Ϊ' || v_row.cardno || '�Ŀ����ɻ���,�����ڿɻ���״̬');
        END IF;
		
        -- ���Ѻ�������쳣���գ��жϷ������ȡ���
        -- ��ʱ�������Ƿ��л���ҵ��ֻ����Ѻ�����Ѷ�Ӧ�Ŀ�Ƭ
        if v_row.ictradetypecode = '06' then
            exit when v_c%NOTFOUND;

            update tf_f_cardrec
            set    serstaketag = '6',
                   deposit    = deposit - v_row.trademoney
            where  serstaketag = '5'
            and    cardno     = v_row.cardno;

            v_depositUpdated := SQL%ROWCOUNT;

            if  v_depositUpdated = 1 then
                update tf_f_cardewalletacc
                set    totalconsumetimes = totalconsumetimes + 1,
                       totalconsumemoney = totalconsumemoney + v_row.trademoney,
                       cardaccmoney      = cardaccmoney      - v_row.trademoney
                where  cardno = v_row.cardno;
                IF SQL%ROWCOUNT != 1 THEN
                    raise_application_error(-20101,
                        '����' || v_cardNo || '��Ӧ�ĵ���Ǯ���˻���Ϣʧ��');
                END IF;
            end if;

        else
		
            exit when v_c%NOTFOUND and v_cardNoLast is null;
			 
            -- ������仯ʱ�����������ʱ�����Ϣ
            if v_cardNoLast is not null and
                (v_c%NOTFOUND OR v_cardNoLast <> v_row.CARDNO)  then
                UPDATE TF_F_CARDEWALLETACC
                SET    LASTCONSUMETIME    = v_tradeTS,
                       OFFLINECARDTRADENO = v_row.CARDTRADENO,
                       CONSUMEREALMONEY   = v_row.PREMONEY
                WHERE  CARDNO             = v_cardNo
                AND   (OFFLINECARDTRADENO IS NULL
                    OR OFFLINECARDTRADENO < v_row.CARDTRADENO);

                UPDATE TF_F_CARDEWALLETACC
                SET    TOTALCONSUMETIMES = TOTALCONSUMETIMES + v_comsumeTimes,
                       TOTALCONSUMEMONEY = TOTALCONSUMEMONEY + v_comsumeMoney,
                       CARDACCMONEY      = CARDACCMONEY - v_comsumeMoney
                WHERE  CARDNO            = v_cardNo;

                IF SQL%ROWCOUNT != 1 THEN
                    raise_application_error(-20101,
                        '����' || v_cardNo || '��Ӧ�ĵ���Ǯ���˻���Ϣʧ��');
                END IF;
            end if;

            exit when v_c%NOTFOUND;

			--�ж��Ƿ��ص�(�嵥���Ƿ��Ѵ���)
			select count(*)
			into v_count
			from tq_trade_right 
			where id=v_row.id;
			if v_count>0 THEN
			raise_application_error(-20101,
                        '�嵥' || v_row.id || '��Ӧ��������Ϣ�Ѵ���');
			end if;
		
			--�ж��Ƿ����·ݱ��д���
			execute immediate 'SELECT count(*)
			FROM ' || 'TF_TRADE_RIGHT_'||to_char(add_months(sysdate,-6),'MM') || ' WHERE ID='''||v_row.id||''''
			into v_count;
			if v_count>0 THEN
			raise_application_error(-20101,
                        '�·��嵥' || v_row.id || '��Ӧ��������Ϣ�Ѵ���');
			end if;
			
            if (v_cardNoLast is null or v_cardNoLast <> v_row.CARDNO) then
                v_cardNo     := v_row.CARDNO;
                v_cardNoLast := v_row.CARDNO;
                v_comsumeTimes := 0; v_comsumeMoney := 0;

                BEGIN -- �����״̬CARDSTATE = '02'(����״̬), ȡ���¿���
                    SELECT RSRV1 INTO v_cardNo
                    FROM   TF_F_CARDREC
                    WHERE  CARDNO = v_cardNo AND CARDSTATE = '02'
                    AND    RSRV1 IS NOT NULL;
                EXCEPTION WHEN OTHERS THEN NULL;
                END;

                v_tradeTS := TO_DATE(v_row.TRADEDATE || v_row.TRADETIME, 'YYYYMMDDHH24MISS');

                --a.update the first consume time
                UPDATE TF_F_CARDEWALLETACC
                SET    FIRSTCONSUMETIME  = v_tradeTS
                WHERE  CARDNO            = v_cardNo
                AND    TOTALCONSUMETIMES = 0;
            end if;

            v_comsumeTimes := v_comsumeTimes + 1;
            v_comsumeMoney := v_comsumeMoney + v_row.TRADEMONEY;
        end if;

        if v_row.ictradetypecode != '06' or v_depositUpdated = 1 then
            --4) get the sequence number
            SP_GetSeq(seq => v_seqNo);

            --5) ���������쳣�˹�����̨��
            INSERT INTO TF_B_TRADE_MANUAL(
                TRADEID, ID, CARDNO, RECTYPE, ICTRADETYPECODE, ASN, CARDTRADENO,
                SAMNO, PSAMVERNO, POSNO, POSTRADENO, TRADEDATE, TRADETIME,
                PREMONEY, TRADEMONEY, SMONEY, BALUNITNO,TRADECOMFEE,
                CALLINGNO, CORPNO, DEPARTNO, CALLINGSTAFFNO, CITYNO, TAC,
                TACSTATE, MAC, SOURCEID, BATCHNO, DEALTIME, ERRORREASONCODE,
                RENEWTIME, RENEWSTAFFNO,
                DEALSTATECODE, RENEWTYPECODE, RENEWSTATECODE, RENEWREMARK)
            VALUES(
                v_seqNo, v_row.ID, v_row.CARDNO, v_row.RECTYPE, v_row.ICTRADETYPECODE, v_row.ASN, v_row.CARDTRADENO,
                v_row.SAMNO, v_row.PSAMVERNO, v_row.POSNO, v_row.POSTRADENO, v_row.TRADEDATE, v_row.TRADETIME,
                v_row.PREMONEY, v_row.TRADEMONEY, v_row.SMONEY, v_row.BALUNITNO, 0,
                v_row.CALLINGNO, v_row.CORPNO, v_row.DEPARTNO, v_row.CALLINGSTAFFNO, v_row.CITYNO, v_row.TAC,
                v_row.TACSTATE, v_row.MAC, v_row.SOURCEID, v_row.BATCHNO, v_row.DEALTIME, v_row.ERRORREASONCODE,
                v_today, p_currOper,
                '0', '0', '1', p_renewRemark);

            --6) �����˹����սӿ�
            INSERT INTO TI_TRADE_MANUAL(
                ID, CARDNO, RECTYPE, ICTRADETYPECODE, ASN, CARDTRADENO,
                SAMNO, PSAMVERNO, POSNO, POSTRADENO, TRADEDATE, TRADETIME,
                PREMONEY, TRADEMONEY, SMONEY, BALUNITNO,TRADECOMFEE,
                CALLINGNO, CORPNO, DEPARTNO, CALLINGSTAFFNO, CITYNO, TAC,
                TACSTATE, MAC, SOURCEID, BATCHNO, DEALTIME, ERRORREASONCODE,
                RENEWTRADEID, RENEWTIME, RENEWSTAFFNO, RENEWTYPECODE,
                DEALSTATECODE, RENEWREMARK)
            VALUES(
                v_row.ID, v_row.CARDNO, v_row.RECTYPE, v_row.ICTRADETYPECODE, v_row.ASN, v_row.CARDTRADENO,
                v_row.SAMNO, v_row.PSAMVERNO, v_row.POSNO, v_row.POSTRADENO, v_row.TRADEDATE, v_row.TRADETIME,
                v_row.PREMONEY, v_row.TRADEMONEY, v_row.SMONEY, v_row.BALUNITNO, 0,
                v_row.CALLINGNO, v_row.CORPNO, v_row.DEPARTNO, v_row.CALLINGSTAFFNO, v_row.CITYNO, v_row.TAC,
                v_row.TACSTATE, v_row.MAC, v_row.SOURCEID, v_row.BATCHNO, v_row.DEALTIME, v_row.ERRORREASONCODE,
                v_seqNo, v_today, p_currOper, '0',
                '0', p_renewRemark);

            v_quantity := v_quantity + 1;

            --) update TF_TRADE_ERROR_XX info
            EXECUTE IMMEDIATE
                'UPDATE TF_TRADE_ERROR_' || p_billMonth || '
                 SET   DEALSTATECODE = ''2''
                 WHERE ID = ''' || v_row.ID || '''';

        end if;
    END LOOP;
    CLOSE v_c;

    p_retCode := '0000000000';
    p_retMsg  := '' || v_quantity;
    COMMIT; RETURN;
EXCEPTION WHEN OTHERS THEN
    IF v_c%ISOPEN THEN CLOSE v_c; END IF;

    p_retCode := SQLCODE;
    p_retMsg  := SQLERRM;
    ROLLBACK; RETURN;
END;

/
show errors

