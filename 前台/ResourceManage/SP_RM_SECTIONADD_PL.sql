create or replace procedure SP_RM_SECTIONADD
(
    p_cardtypecode        char,        --卡片类型
    p_begincardno         char,        --起始卡号
    p_endcardno           char,        --终止卡号
    p_currOper            char,        --员工编码
    p_currDept            char,        --部门编码
    p_retCode         out char, -- Return Code
    p_retMsg          out varchar2  -- Return Message
)
as
    v_count        int;
    v_data        date;
    v_ex        EXCEPTION;
BEGIN
    v_data :=sysdate;
    BEGIN
        SELECT count(*) INTO v_count FROM 
        (SELECT * FROM TD_M_CARDNOCONFIG
        WHERE USETAG <> '0'
            AND (BEGINCARDNO BETWEEN p_begincardno AND p_endcardno
            OR ENDCARDNO BETWEEN p_begincardno AND p_endcardno)
        UNION
        SELECT * FROM TD_M_CARDNOCONFIG
        WHERE USETAG <> '0'
            AND (p_begincardno BETWEEN BEGINCARDNO AND ENDCARDNO
            OR p_endcardno BETWEEN BEGINCARDNO AND BEGINCARDNO));    
        IF v_count != 0 THEN
            p_retCode := 'S094780014';
            p_retMsg  := '卡号段在库中存在重复记录';
            ROLLBACK;RETURN;
        END IF;
    END;
    --insert TD_M_CARDNOCONFIG
    BEGIN
    INSERT INTO TD_M_CARDNOCONFIG(
	    CARDNOCONFIGID                 , CARDTYPECODE   , BEGINCARDNO   , ENDCARDNO   ,
		UPDATETIME                     , UPDATESTAFFNO  , USETAG        , CREATETIME  ,
		CREATESTAFFNO                  , UPDATETAG)
    VALUES
	    (TD_M_CARDNOCONFIG_SEQ.NEXTVAL , p_cardtypecode , p_begincardno , p_endcardno ,
		v_data                         , p_currOper     , '1'           , v_data      ,
		p_currOper                     , '1');
    IF  SQL%ROWCOUNT != 1 THEN RAISE v_ex; END IF;    
        EXCEPTION
                  WHEN OTHERS THEN
                      p_retCode := 'S094780012';
                      p_retMsg  := '新增用户卡卡号段配置表失败' || SQLERRM;
                  ROLLBACK; RETURN;
    END;
    
    p_retCode := '0000000000';
    p_retMsg  := '';
    COMMIT; RETURN;
END;

/
show errors