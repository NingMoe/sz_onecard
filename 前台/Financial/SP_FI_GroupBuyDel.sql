create or replace procedure SP_FI_GroupBuyDel
(
    p_msgGroupCodes   varchar2, -- 团购劵号组
    p_msgGroupNames   varchar2, -- 团购商家组


    p_currOper            char,
    p_currDept            char,
    p_retCode   out char, -- Return Code
    p_retMsg    out varchar2  -- Return Message
)
as
		v_groupId  varchar2(100); --对应团购流水号
    v_today date := sysdate;
    v_sub varchar2(100);      --单个团购劵号
    v_subName varchar2(100);  --单个团购商家
    v_idx   pls_integer;      --团购劵号计数起始位置
    v_last  pls_integer;      --团购劵号计数结束位置
    v_idxName   pls_integer;  --团购商家计数起始位置
    v_lastName  pls_integer;  --团购商家计数结束位置
begin
			begin
                v_last := 1;
								v_lastName := 1;
                loop         --遍历团购劵号
									 BEGIN
                    v_idx := instr(p_msgGroupCodes, ',', v_last);
                    if v_idx = 0 then
                       v_sub := substr(p_msgGroupCodes, v_last);
                    else
                       v_sub := substr(p_msgGroupCodes, v_last, v_idx - v_last); --获取单个团购劵号
                    end if;

										v_idxName := instr(p_msgGroupNames, ',', v_lastName);
										if v_idxName = 0 then
											 v_subName := substr(p_msgGroupNames, v_lastName);
                    else
											 v_subName := substr(p_msgGroupNames, v_lastName, v_idxName - v_lastName);  --获取单个团购商家
                    end if;


                    v_last := v_idx + 1;
										v_lastName := v_idxName + 1;
										BEGIN
												--查找团购劵号
                       SELECT a."ID" INTO v_groupId FROM TF_F_GROUPBUY_RECORD a,TD_M_GROUPBUY_SHOP e
											 WHERE a.SHOPID=e.SHOPID AND a.CODE=v_sub AND e.SHOPNAME=v_subName AND a.CANCELCODE='0';
												exception when others then
												p_retCode := SQLCODE;
												p_retMsg  := sqlerrm;
												ROLLBACK; RETURN;
										END;
                    BEGIN
												--更新团购记录表
										 UPDATE TF_F_GROUPBUY_RECORD SET CANCELCODE='1' WHERE "ID"=v_groupId;
												exception when others then
												p_retCode := SQLCODE;
												p_retMsg  := sqlerrm;
												ROLLBACK; RETURN;

										END;
										BEGIN
												--更新团购业务关联表
										 UPDATE TF_F_GROUPBUY_TRADE SET CANCELCODE='1' WHERE GROUPID=v_groupId;
												exception when others then
												p_retCode := SQLCODE;
												p_retMsg  := sqlerrm;
												ROLLBACK; RETURN;

										END;
										BEGIN
											for o IN (SELECT TRADEID FROM TF_F_GROUPBUY_TRADE WHERE GROUPID=v_groupId)
											loop
												 BEGIN
															--插入团购业务台账表
													 INSERT INTO TF_B_GROUPBUY_LEDGERS(GROUPID,TRADEID,OPERATIONCODE,ALLOTSTAFFNO,ALLOTDEPARTID,ALLOTTIME)
															VALUES(v_groupId,o.TRADEID,'1',p_currOper,p_currDept,v_today);

														exception when others then
														p_retCode := SQLCODE;
														p_retMsg  := sqlerrm;
														ROLLBACK; RETURN;
													END;
											end loop;
										END;
                    exit when v_idx = 0;
									END;
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
    COMMIT; RETURN;


end;
/
