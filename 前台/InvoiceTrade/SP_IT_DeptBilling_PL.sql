create or replace procedure SP_IT_DeptBilling
(
    p_ID                char,
    p_cardNo            varchar,
    p_isFree            char,
    p_volno             char,
    p_payer             varchar2,
    p_billNo            char,
  p_payeeName      varchar2,
    p_taxNo             varchar2,
    p_drawer            varchar2,
    p_date              date,
    p_amount            number,
    p_note              varchar2,
    p_proj1             varchar2,
    p_fee1              int,
    p_proj2             varchar2,
    p_fee2              int,
    p_proj3             varchar2,
    p_fee3              int,
    p_proj4             varchar2,
    p_fee4              int,
    p_proj5             varchar2,
    p_fee5              int,
  p_bankName          varchar2,
  p_bankAccount       varchar2,
  p_validatecode    char,--验证码
  p_CallingCode    varchar2,--行业代码
  p_CallingName    varchar2,--行业名称
  P_SESSIONID    varchar2 ,
    p_currOper          char,
    p_currDept          char,
    p_retCode       out char,
    p_retMsg        out varchar2
)
as
    v_today         date  := sysdate;


    v_ex            exception;
    v_seqNo         TF_B_INVOICE.TRADEID%TYPE;
    v_quantity      int;
begin

    begin
    SELECT count(*) into v_quantity  FROM TL_R_INVOICE tri where
    tri.ALLOTSTATECODE='02' and tri.usestatecode='00'
    and tri.ALLOTSTAFFNO=p_currOper and tri.invoiceno=p_billNo
    and volumeno=p_volno;
    if v_quantity=0 then
            p_retCode := 'A200004001';
            p_retMsg  := '';
            return;
    end if;
    exception
        when others then
            p_retCode := 'A200004002';
            p_retMsg  := '';
            return;
    end;

    begin
        update TL_R_INVOICE
        set    USESTATECODE  = '01'
        where  INVOICENO     = p_billNo
        and    VOLUMENO      = p_volno;

        if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
    exception when others then
        p_retCode := 'S200004003';
        p_retMsg  := '';
        rollback; return;
    end;

    begin
        insert into TF_F_INVOICE(
            INVOICENO, VOLUMENO,ID, PROJ1  , FEE1  , PROJ2  , FEE2  , PROJ3  , FEE3  , PROJ4  , FEE4  , PROJ5  , FEE5  , TRADEFEE,
            PAYMAN , TRADESTAFF, TRADETIME,PAYEENAME, TAXNO  , OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME,REMARK,ISFREE,RSRV3,bankname,bankaccount,CallingCode,CallingName)
        values(
            p_billNo , p_volno ,p_ID, p_proj1, p_fee1, p_proj2, p_fee2, p_proj3, p_fee3, p_proj4, p_fee4, p_proj5, p_fee5, p_amount,
            p_payer, p_drawer  , p_date   ,p_payeeName, p_taxNo, p_currOper    , p_currDept     , v_today    ,p_note,p_isFree,p_validatecode,p_bankname,p_bankaccount,p_CallingCode,p_CallingName);

        if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
    exception
        when others then
            p_retCode := 'S200004004';
            p_retMsg  := '';
            rollback; return;
    end;

    SP_GetSeq(seq => v_seqNo);

    begin
        insert into TF_B_INVOICE(ID,Cardno,
            TRADEID, INVOICENO, VOLUMENO, FUNCTIONTYPECODE, PROJ1  , FEE1  , PROJ2  , FEE2  , PROJ3  , FEE3  , PROJ4  , FEE4  , PROJ5  , FEE5  , TRADEFEE,
            PAYMAN , TRADESTAFF,TRADETIME,PAYEENAME,TAXNO   ,OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME, REMARK,Isfree,rsrv3,bankname,bankaccount,CallingCode,CallingName)
        values(p_ID,p_cardNo,
            v_seqNo, p_billNo , p_volno , 'L0'            , p_proj1, p_fee1, p_proj2, p_fee2, p_proj3, p_fee3, p_proj4, p_fee4, p_proj5, p_fee5, p_amount,
            p_payer, p_drawer  , p_date  , p_payeeName,p_taxNo, p_currOper   , p_currDept     , v_today    , p_note,p_isFree,p_validatecode,p_bankname,p_bankaccount,p_CallingCode,p_CallingName);

        if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
    exception when others then
        p_retCode := 'S200004005';
        p_retMsg  := '';
        rollback; return;
    end;

    BEGIN
        FOR cur_data IN
        (
            SELECT * FROM TMP_TF_B_DEPTINVOICE TMP
            WHERE TMP.SESSIONID = P_SESSIONID
        )
        LOOP
            begin
              INSERT INTO TF_B_DEPTINVOICE (TRADEID, TRADETYPECODE, CURRENTMONEY, VOLUMENO, INVOICENO, STAFFNO, OPERATETIME)
              VALUES (cur_data.tradeid, cur_data.tradetypecode, to_number(cur_data.currentmoney), cur_data.volumeno, cur_data.invoiceno, p_currOper, v_today);
            exception when others then
              p_retCode := 'S000005002';
              p_retMsg := '插入网点打印记录表失败'|| SQLERRM ;
              rollback; return;
            end;
        END LOOP;
    END;

    p_retCode := '0000000000';
    p_retMsg    := '';

    commit; return;

end;
/

show errors