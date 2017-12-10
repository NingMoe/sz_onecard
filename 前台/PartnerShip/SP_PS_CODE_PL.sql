create or replace procedure SP_PS_CODE
(
    p_funcCode   varchar2,
    p_var1       varchar2,
    p_var2       varchar2,
    p_var3       varchar2,
    p_var4       varchar2,
    p_var5       varchar2,
    p_currOper        char,
    p_currDept        char,
    p_retCode     out char, -- Return Code
    p_retMsg      out varchar2  -- Return Message
)
as
    v_Count int;
    v_ex    exception;
BEGIN
  if p_funcCode = 'RegionCodeAdd' then        --新增地区编码
    BEGIN
        SELECT COUNT(*) INTO v_Count FROM TD_M_REGIONCODE  WHERE REGIONCODE = p_var1;

        IF v_Count != 0 THEN
            p_retCode := 'A008113010';
            p_retMsg  := 'RegionCode exists,' || SQLERRM;
            RETURN;
        END IF;

        INSERT INTO TD_M_RegionCode (REGIONCODE,REGIONNAME,ISUSETAG,UPDATESTAFFNO,UPDATETIME)
        VALUES (p_var1,p_var2,p_var5,p_currOper,sysdate);

    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S008113010';
        p_retMsg  := 'Error occurred while inserting into TD_M_REGIONCODE,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
 elsif p_funcCode = 'RegionCodeModify' then         --修改地区编码
    BEGIN
        SELECT COUNT(*) INTO v_Count FROM TD_M_REGIONCODE  WHERE REGIONCODE = p_var1;

        IF v_Count = 0 THEN
            p_retCode := 'A008113011';
            p_retMsg  := 'RegionCode not exists,' || SQLERRM;
            RETURN;
        END IF;
        
       update TD_M_RegionCode t
        set t.regionname = p_var2,
            t.isusetag = p_var5,
            t.updatestaffno = p_currOper,
            t.updatetime = sysdate
        where t.regioncode = p_var1;
    exception when others then
        p_retCode := 'S008113011';
        p_retMsg    := 'Error occurred while updating TD_M_REGIONCODE' || SQLERRM;
        rollback; return;
    END;
 elsif p_funcCode = 'RegionCodeDelete' then         --删除地区编码
    BEGIN
       delete from TD_M_RegionCode t
       where t.regioncode = p_var1;

    exception when others then
        p_retCode := 'S008113012';
        p_retMsg  := 'Error occurred while deleting from TD_M_REGIONCODE';
        rollback; return;
    END;
 elsif p_funcCode = 'DeliveryModeCodeAdd' then       --新增POS投放模式编码
     BEGIN
        SELECT COUNT(*) INTO v_Count FROM TD_M_DeliveryModeCode  WHERE DELIVERYMODECODE = p_var1;

        IF v_Count != 0 THEN
            p_retCode := 'A008113020';
            p_retMsg  := 'DeliveryModeCode exists,' || SQLERRM;
            RETURN;
        END IF;

        INSERT INTO TD_M_DeliveryModeCode (DELIVERYMODECODE,DELIVERYMODE,ISUSETAG,UPDATESTAFFNO,UPDATETIME)
        VALUES (p_var1,p_var2,p_var5,p_currOper,sysdate);

    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S008113020';
        p_retMsg  := 'Error occurred while inserting into TD_M_DeliveryModeCode,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    elsif p_funcCode = 'DeliveryModeCodeModify' then     --修改POS投放模式编码
    BEGIN
        SELECT COUNT(*) INTO v_Count FROM TD_M_DeliveryModeCode  WHERE DELIVERYMODECODE = p_var1;

        IF v_Count = 0 THEN
            p_retCode := 'A008113021';
            p_retMsg  := 'DeliveryModeCode not exists,' || SQLERRM;
            RETURN;
        END IF;
       update TD_M_DeliveryModeCode t
        set t.DELIVERYMODE = p_var2,
            t.isusetag = p_var5,
            t.updatestaffno = p_currOper,
            t.updatetime = sysdate
        where t.DELIVERYMODECODE = p_var1;
    exception when others then
        p_retCode := 'S008113021';
        p_retMsg    := 'Error occurred while updating TD_M_DeliveryModeCode' || SQLERRM;
        rollback; return;
    END;
    elsif p_funcCode = 'DeliveryModeCodeDelete' then       --删除POS投放模式编码
    BEGIN
       delete from TD_M_DeliveryModeCode t
       where t.DELIVERYMODECODE = p_var1;

    exception when others then
        p_retCode := 'S008113022';
        p_retMsg  := 'Error occurred while deleting from TD_M_DeliveryModeCode';
        rollback; return;
    END;
    elsif p_funcCode = 'AppCallingCodeAdd' then              --新增应用行业编码
     BEGIN
        SELECT COUNT(*) INTO v_Count FROM TD_M_APPCALLINGCODE  WHERE APPCALLINGCODE = p_var1;

        IF v_Count != 0 THEN
            p_retCode := 'A008113030';
            p_retMsg  := 'AppCallingCode exists,' || SQLERRM;
            RETURN;
        END IF;

        INSERT INTO TD_M_APPCALLINGCODE (APPCALLINGCODE,APPCALLING,ISUSETAG,UPDATESTAFFNO,UPDATETIME)
        VALUES (p_var1,p_var2,p_var5,p_currOper,sysdate);

    EXCEPTION WHEN OTHERS THEN
        p_retCode := 'S008113030';
        p_retMsg  := 'Error occurred while inserting into TD_M_APPCALLINGCODE,' || SQLERRM;
        ROLLBACK; RETURN;
    END;
    elsif p_funcCode = 'AppCallingCodeModify' then            --修改应用行业编码
    BEGIN
      SELECT COUNT(*) INTO v_Count FROM TD_M_APPCALLINGCODE  WHERE APPCALLINGCODE = p_var1;

        IF v_Count = 0 THEN
            p_retCode := 'A008113031';
            p_retMsg  := 'AppCallingCode not exists,' || SQLERRM;
            RETURN;
        END IF;
       update TD_M_APPCALLINGCODE t
        set t.APPCALLING = p_var2,
            t.isusetag = p_var5,
            t.updatestaffno = p_currOper,
            t.updatetime = sysdate
        where t.APPCALLINGCODE = p_var1;
    exception when others then
        p_retCode := 'S008113031';
        p_retMsg    := 'Error occurred while updating TD_M_APPCALLINGCODE' || SQLERRM;
        rollback; return;
    END;
    elsif p_funcCode = 'AppCallingCodeDelete' then            --删除应用行业编码
    BEGIN
       delete from TD_M_APPCALLINGCODE t
       where t.APPCALLINGCODE = p_var1;

    exception when others then
        p_retCode := 'S008113032';
        p_retMsg  := 'Error occurred while deleting from TD_M_APPCALLINGCODE';
        rollback; return;
    END;
 end if;
    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;
END;
/

show errors