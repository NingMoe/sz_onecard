create or replace procedure SP_IT_Billing_HD
(
    p_ID                varchar,
    p_volno             char,
    p_isFree            char,
    p_payer             varchar2,
    p_billNo            char,
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

    select count(*) into v_quantity  from TF_F_INVOICE where ID=p_ID ;
    if v_quantity<>0 then
    select count(*) into v_quantity from TF_F_INVOICE f inner join TL_R_INVOICE r
    on f.invoiceno=r.invoiceno and f.volumeno=r.volumeno  where f.ID=p_ID and (r.allotstatecode<>'03' and  r.usestatecode<>'02') ;
    if v_quantity<>0 then
            p_retCode := 'IEA0000001';
            p_retMsg  := '未作废、未红冲、已打印过的流水号不能再打印';
            return;
    end if;
    end if;
    end;
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
            PAYMAN , TRADESTAFF, TRADETIME, TAXNO  , OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME,REMARK,Isfree)
        values(
            p_billNo , p_volno ,p_ID, p_proj1, p_fee1, p_proj2, p_fee2, p_proj3, p_fee3, p_proj4, p_fee4, p_proj5, p_fee5, p_amount,
            p_payer, p_drawer  , p_date   , p_taxNo, p_currOper    , p_currDept     , v_today    ,p_note,p_isFree);

        if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
    exception
        when others then
            p_retCode := 'S200004004';
            p_retMsg  := '';
            rollback; return;
    end;

    SP_GetSeq(seq => v_seqNo);

    begin
        insert into TF_B_INVOICE(
            TRADEID, INVOICENO, VOLUMENO, FUNCTIONTYPECODE, PROJ1  , FEE1  , PROJ2  , FEE2  , PROJ3  , FEE3  , PROJ4  , FEE4  , PROJ5  , FEE5  , TRADEFEE,
            PAYMAN , TRADESTAFF,TRADETIME,TAXNO   ,OPERATESTAFFNO, OPERATEDEPARTID, OPERATETIME, REMARK,Isfree)
        values(
            v_seqNo, p_billNo , p_volno , 'L0'            , p_proj1, p_fee1, p_proj2, p_fee2, p_proj3, p_fee3, p_proj4, p_fee4, p_proj5, p_fee5, p_amount,
            p_payer, p_drawer  , p_date  , p_taxNo, p_currOper   , p_currDept     , v_today    , p_note,p_isFree);

        if  SQL%ROWCOUNT != 1 then raise v_ex; end if;
    exception when others then
        p_retCode := 'S200004005';
        p_retMsg  := '';
        rollback; return;
    end;

    p_retCode := '0000000000';
    p_retMsg    := '';

    commit; return;

end;
/
show errors