create or replace procedure SP_SD_SupplyDiffRec
(
    p_remark        varchar2,
    p_currOper      char,
    p_currDept      char,
    p_retCode   out char,
    p_retMsg    out varchar2
)
as
    v_currdate      date := sysdate;
    v_cardNo        char(16);
    v_tradetime     date;
    v_seqNo         char(16);
    v_seqNum        number(16);
    v_quantity      int;

begin
    -- ��Ϊ�������ѻ�Ϊ׼����COMPSTATE = '0'(�������ѻ���)ʱ���������ر�
    insert into TF_SUPPLY_EXCLUDE (IDENTIFYNO)
    select ID from TP_SUPPLY_DIFF
    where  ID in (select f0 from tmp_common)
    and    COMPSTATE = '0';

    -- ���»��մ���
    update TP_SUPPLY_DIFF
    set    RENEWTYPECODE = decode(COMPSTATE,
                                '0', '1', -- �������ѻ���ʱ ȫ�����
                                '2', '2' -- ����    ʱ ȫ�����
                                )
    where  ID in (select f0 from tmp_common);

    -- ���µ���Ǯ���˻���Ϣ
    for v_c in
    (
        select CARDNO, CARDTRADENO, TRADEDATE, TRADETIME, COMPMONEY, PREMONEY
        from TP_SUPPLY_DIFF
        where ID in (select f0 from tmp_common)
    )
    loop
        v_cardNo    := v_c.CARDNO;
        v_tradetime := to_date(v_c.TRADEDATE || v_c.TRADETIME, 'YYYYMMDDHH24MISS');

        begin -- �����״̬CARDSTATE = '02'(����״̬), ȡ���¿���
            select RSRV1 into v_cardNo
            from   TF_F_CARDREC
            where  CARDNO = v_cardNo and CARDSTATE = '02'
            and    RSRV1 is not null;
        exception when others then null;
        end;

        -- ���µ���Ǯ���˻����е��״γ�ֵʱ�䣬�ܳ�ֵ�������ܳ�ֵ�����˻����
         update TF_F_CARDEWALLETACC
         set    FIRSTSUPPLYTIME  = nvl(FIRSTSUPPLYTIME, v_tradetime),
                TOTALSUPPLYTIMES = TOTALSUPPLYTIMES + 1,
                TOTALSUPPLYMONEY = TOTALSUPPLYMONEY + v_c.COMPMONEY,
                CARDACCMONEY     = CARDACCMONEY     + v_c.COMPMONEY
         where  CARDNO           = v_cardno;

        -- ���µ���Ǯ���˻����е�����ֵʱ�䣬���������ֵ���׺ţ�����ֵ���
        update  TF_F_CARDEWALLETACC
        set     LASTSUPPLYTIME    = v_tradetime,
                ONLINECARDTRADENO = v_c.CARDTRADENO,
                SUPPLYREALMONEY   = v_c.PREMONEY
        where   CARDNO            = v_cardno
        and    (ONLINECARDTRADENO is null or ONLINECARDTRADENO < v_c.CARDTRADENO);

    end loop;

    -- ���ݻ������ݵ���ʷ��
    insert into TH_SUPPLY_DIFF(
        ID, CARDNO, ASN, CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
        TRADEDATE,  TRADETIME,    TRADEMONEY,  PREMONEY,  SUPPLYLOCNO,
        SAMNO,  POSNO,   STAFFNO, TAC,  TRADEID, TACSTATE,    BATCHNO,
        SUPPLYCOMFEE,  BALUNITNO, CALLINGNO,  CORPNO,   DEPARTNO,
        DEALTIME,   COMPTTIME,   COMPMONEY,    COMPSTATE ,RENEWTYPECODE )
    select  ID, CARDNO, ASN, CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
        TRADEDATE,  TRADETIME,    TRADEMONEY,  PREMONEY,  SUPPLYLOCNO,
        SAMNO,  POSNO,   STAFFNO, TAC,  TRADEID, TACSTATE,    BATCHNO,
        SUPPLYCOMFEE,  BALUNITNO, CALLINGNO,  CORPNO,   DEPARTNO,
        DEALTIME,   COMPTTIME,   COMPMONEY,    COMPSTATE, RENEWTYPECODE
    from TP_SUPPLY_DIFF
    where ID in (select f0 from tmp_common);

    v_quantity := SQL%ROWCOUNT;
    SP_GetSeq(v_quantity, v_seqNo);   
    v_seqNum := to_number(v_seqNo);  

    -- �����˹���ֵ����̨�˱�
    insert into TF_B_SUPPLY_MANUAL(
        BUSINESSID,CARDNO,ASN,CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
        TRADEDATE,TRADETIME  ,TRADEMONEY, PREMONEY,SUPPLYLOCNO,
        SAMNO,POSNO,  STAFFNO,      TAC,TRADEID,TACSTATE,
        BATCHNO   ,SUPPLYCOMFEE ,BALUNITNO     ,CALLINGNO,CORPNO,DEPARTNO,
        DEALTIME  ,COMPTTIME,COMPMONEY,COMPSTATE,RENEWMONEY,
        RENEWTIME,RENEWSTAFFNO,RENEWTYPECODE,RENEWREMARK)
    select substr('0000000000000000'|| to_char(v_seqNum + rownum), -16),
        CARDNO,ASN,CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
        TRADEDATE,TRADETIME  ,TRADEMONEY, PREMONEY,SUPPLYLOCNO,
        SAMNO,POSNO,  STAFFNO,      TAC,TRADEID,TACSTATE,
        BATCHNO   ,SUPPLYCOMFEE ,BALUNITNO     ,CALLINGNO,CORPNO,DEPARTNO,
        DEALTIME  ,COMPTTIME,COMPMONEY,COMPSTATE,COMPMONEY,
        v_currdate, p_currOper,  RENEWTYPECODE, p_remark
    from TP_SUPPLY_DIFF
    where ID in (select f0 from tmp_common);

    -- �����ֵ���սӿڱ�
    INSERT INTO TI_SUPPLY_MANUAL(
       ID,CARDNO,ASN,CARDTRADENO,TRADETYPECODE,CARDTYPECODE,
       TRADEDATE,TRADETIME,TRADEMONEY,PREMONEY,SUPPLYLOCNO,
       SAMNO,POSNO,STAFFNO,TAC,TRADEID,TACSTATE,BATCHNO,SUPPLYCOMFEE,
       BALUNITNO,CALLINGNO,CORPNO,DEPARTNO,DEALTIME,
       COMPTTIME,COMPMONEY,COMPSTATE,
       RENEWMONEY,RENEWTIME,RENEWSTAFFNO,RENEWTYPECODE,
       RENEWREMARK,DEALSTATECODE)
    SELECT  
       ID,CARDNO,ASN,CARDTRADENO,TRADETYPECODE,CARDTYPECODE,
       TRADEDATE,TRADETIME,TRADEMONEY,PREMONEY,SUPPLYLOCNO,
       SAMNO,POSNO,STAFFNO,TAC,TRADEID,TACSTATE,BATCHNO,SUPPLYCOMFEE,
       BALUNITNO,CALLINGNO,CORPNO,DEPARTNO,DEALTIME,
       COMPTTIME,COMPMONEY,COMPSTATE,
       COMPMONEY, v_currdate, p_currOper, RENEWTYPECODE,
       p_remark, '0' 
    from  TP_SUPPLY_DIFF
    where ID in (select f0 from tmp_common)
    and   COMPSTATE in('0', '2');

    -- �����ֵ������Ѿ����յļ�¼
    delete from TP_SUPPLY_DIFF
    where ID in (select f0 from tmp_common);

    p_retCode := '0000000000';
    p_retMsg  := '' || v_quantity;
    commit; return;
exception when others then
    p_retCode := sqlcode;
    p_retMsg  := sqlerrm;
    rollback; return;
end;

/
show errors

