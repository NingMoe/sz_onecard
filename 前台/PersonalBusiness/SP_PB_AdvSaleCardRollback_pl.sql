create or replace procedure SP_PB_AdvSaleCardRollback
(
    p_operCardNo     char,
    p_currOper       char,
    p_currDept       char,
    p_retCode    out char, -- Return Code
    p_retMsg     out varchar2  -- Return Message

)
as
    v_ID             char(18);
    v_toCardNo       char(16);
    v_seqNo          char(16);
begin
    for v_c1 in (select f0, f1 from tmp_common)
    loop
        select nvl(v_c1.f1, v_c1.f0) into v_toCardNo from dual;

        for v_c2 in
        (
            SELECT a.CARDNO, b.DEPOSIT, b.CARDCOST, c.TRADEID
            FROM TL_R_ICUSER a, TF_F_CARDREC b, TF_B_TRADE c
            WHERE a.CARDNO BETWEEN v_c1.f0 AND v_toCardNo
            and   a.CARDNO = b.CARDNO
            and a.CARDNO = c.CARDNO
            and c.TRADETYPECODE = '01'
        )
        loop
            SP_PB_SaleCardRollback(
                to_char(sysdate, 'mmddhh24miss') ||'0000' || SUBSTR(v_c2.CARDNO,-4),
                v_c2.CARDNO, '', 0, v_c2.DEPOSIT, v_c2.CARDCOST, v_c2.TRADEID, 0, 0,
                '112233445566', p_operCardNo, v_seqNo, p_currOper, p_currDept, p_retCode, p_retMsg);
            if p_retCode != '0000000000' then
                raise_application_error(-20101, p_retMsg);
            end if;
        end loop;
    end loop;

    p_retCode := '0000000000'; p_retMsg  := '';
    commit; return;

exception when others then
    p_retcode := sqlcode;
    p_retMsg  := rpad(sqlerrm, 127);
    rollback; return;
end;
/

show errors

