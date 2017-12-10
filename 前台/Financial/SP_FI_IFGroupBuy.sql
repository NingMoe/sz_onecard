create or replace procedure SP_FI_IFGroupBuy
(
    p_msgTradeIds   varchar2,
    p_msgGroupCode     varchar2,
    p_msgShopNo  varchar2,
    p_msgRemark   varchar2,
    

    p_currOper            char,
    p_currDept            char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
as 
    v_seqNo  varchar2(16); 
    v_today date := sysdate;
    v_sub varchar2(100);
    v_msgid pls_integer;
    v_idx   pls_integer;
    v_last  pls_integer;
begin
    SP_GetSeq(seq => v_seqNo);
    begin
						--插入团购记录表
            insert into TF_F_GROUPBUY_RECORD(ID, CODE,SHOPID,UPDATESTAFFNO,UPDATEDEPARTID,UPDATETIME, REMARK, CANCELCODE)
                        values  (v_seqNo, p_msgGroupCode, p_msgShopNo, 
                p_currOper, p_currDept, v_today, p_msgRemark,'0');
    exception when others then
        p_retCode := SQLCODE;
        p_retMsg  := SQLERRM;
        ROLLBACK; RETURN;
    end;
 
        begin
                v_last := 1;
                loop
									BEGIN
                    v_idx := instr(p_msgTradeIds, ',', v_last);
                    if v_idx = 0 then
                       v_sub := substr(p_msgTradeIds, v_last);
                    else
                       v_sub := substr(p_msgTradeIds, v_last, v_idx - v_last);
                    end if;

                    v_last := v_idx + 1;
										
										begin
												--插入团购业务关联表
                        insert into TF_F_GROUPBUY_TRADE(TRADEID, GROUPID,CANCELCODE)
                        values(v_sub,v_seqNo,'0');
                        exception when others then
                        p_retCode := SQLCODE;
                        p_retMsg  := sqlerrm;
                        ROLLBACK; RETURN;
                    end;
                    begin
                      --插入团购业务台账表
                        INSERT INTO TF_B_GROUPBUY_LEDGERS(GROUPID,TRADEID,OPERATIONCODE,ALLOTSTAFFNO,ALLOTDEPARTID,ALLOTTIME)
                        VALUES(v_seqNo,v_sub,'0',p_currOper,p_currDept,v_today);
                        exception when others then
                        p_retCode := SQLCODE;
                        p_retMsg  := sqlerrm;
                        ROLLBACK; RETURN;
                    end;
                    exit when v_idx = 0;
                  end;
                end loop;
  exception when others then
            p_retCode := 'S100001001';
            p_retMsg  := sqlerrm;
            ROLLBACK; RETURN;
        end;

    p_retCode := '0000000000';
    if p_retMsg != '' then
       p_retMsg  := '';
    end if;
    RETURN;

end;
/
show errors