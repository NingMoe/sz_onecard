create or replace procedure SP_SD_SupplyDiffCancel
(
    p_remark        varchar2,
    p_currOper      char,
    p_currDept      char,
    p_retCode   out char,
    p_retMsg    out varchar2
)
as
    v_currdate      date := sysdate;
    v_seqNo         char(16);
    v_seqNum        number(16);
    v_quantity      int;
begin
    -- �����ر���ɾ��
    DELETE FROM TF_SUPPLY_EXCLUDE
    WHERE IDENTIFYNO IN (
        SELECT ID
        FROM TP_SUPPLY_DIFF
        WHERE COMPSTATE != '0' -- (�������ѻ���)
        AND   ID IN (SELECT f0 FROM tmp_common)
        );

    -- ���³�ֵ�ȶԲ�������״̬
    UPDATE TP_SUPPLY_DIFF
    SET RENEWTYPECODE = '4' --(����)
    WHERE ID IN (SELECT f0 FROM tmp_common);

    v_quantity := sql%rowcount;

    -- ���ݻ������ݵ���ʷ��
    INSERT INTO TH_SUPPLY_DIFF(
        ID, CARDNO, ASN, CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
        TRADEDATE,  TRADETIME,    TRADEMONEY,  PREMONEY,  SUPPLYLOCNO,
        SAMNO,  POSNO,   STAFFNO, TAC,  TRADEID, TACSTATE,    BATCHNO,
        SUPPLYCOMFEE,  BALUNITNO, CALLINGNO,  CORPNO,   DEPARTNO,
        DEALTIME,   COMPTTIME,   COMPMONEY,  COMPSTATE ,RENEWTYPECODE )
   SELECT ID, CARDNO, ASN, CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
        TRADEDATE,  TRADETIME,    TRADEMONEY,  PREMONEY,  SUPPLYLOCNO,
        SAMNO,  POSNO,   STAFFNO, TAC,  TRADEID, TACSTATE,    BATCHNO,
        SUPPLYCOMFEE,  BALUNITNO, CALLINGNO,  CORPNO,   DEPARTNO,
        DEALTIME,   COMPTTIME,   COMPMONEY,    COMPSTATE, '4'
    FROM TP_SUPPLY_DIFF
    WHERE ID IN (SELECT f0 FROM tmp_common);

    SP_GetSeq(v_quantity, v_seqNo);
    v_seqNum := TO_NUMBER(v_seqNo);

    -- �����˹���ֵ����̨�˱�
    INSERT INTO  TF_B_SUPPLY_MANUAL(
        BUSINESSID,CARDNO,ASN,CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
        TRADEDATE,TRADETIME  ,TRADEMONEY, PREMONEY,SUPPLYLOCNO,
        SAMNO,POSNO,  STAFFNO,      TAC,TRADEID,TACSTATE,
        BATCHNO   ,SUPPLYCOMFEE ,BALUNITNO     ,CALLINGNO,CORPNO,DEPARTNO,
        DEALTIME  ,COMPTTIME,COMPMONEY,COMPSTATE,RENEWMONEY,
        RENEWTIME,RENEWSTAFFNO,RENEWTYPECODE,RENEWREMARK)
    SELECT SUBSTR('0000000000000000'|| TO_CHAR(v_seqNum + rownum), -16),  
        CARDNO,ASN,CARDTRADENO, TRADETYPECODE, CARDTYPECODE,
        TRADEDATE,TRADETIME  ,TRADEMONEY, PREMONEY,SUPPLYLOCNO,
        SAMNO,POSNO,  STAFFNO,      TAC,TRADEID,TACSTATE,
        BATCHNO   ,SUPPLYCOMFEE ,BALUNITNO     ,CALLINGNO,CORPNO,DEPARTNO,
        DEALTIME  ,COMPTTIME,COMPMONEY,COMPSTATE,COMPMONEY,
        v_currdate, p_currOper,  '4', p_remark
    FROM TP_SUPPLY_DIFF
    WHERE ID IN (SELECT f0 FROM tmp_common);

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


