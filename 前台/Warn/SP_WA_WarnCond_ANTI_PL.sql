create or replace procedure SP_WA_WarnCond_ANTI
(
    p_funcCode     	varchar2,
    p_oldCondCode  	char    ,
    p_condCode     	char    ,
    p_condName     	varchar2,
    p_riskGrade    	char     ,--风险等级
    p_subjectType   char,--主体类型
    p_limitType    	char     ,--额度等级
    p_condStr      	varchar2,
	p_usetag		char,
    p_remark       	varchar2,
	
	p_condCate		char,
	p_dateType		char,
	p_condWhere		varchar2,
	
    p_currOper     	char    ,
    p_currDept     	char    ,
    p_retCode  		out char    ,
    p_retMsg   		out varchar2
)
as
    v_int          int;
begin

    if p_funcCode = 'Del' or 
        (p_funcCode = 'Mod' and p_oldCondCode != p_condCode)
    then
        begin
            select 1 into   v_int
            from   TF_B_WARN_ANTI
            where  CONDCODE = p_oldCondCode;

            raise_application_error(-20102, 
                '条件编码当前正在监控名单中使用，不能被删除');
        exception when no_data_found then null;
        end;
    end if;

    if p_funcCode = 'Add' then
        insert into TD_M_WARNCOND_ANTI(CONDCODE, CONDNAME, RISKGRADE,SUBJECTTYPE, LIMITTYPE,
            CONDCONTENT, UPDATESTAFFNO, UPDATETIME, REMARK,USETAG,CONDCATE,DATETYPE,CONDWHERE)
        values (p_condCode, p_condName, p_riskGrade, p_subjectType,
            p_limitType, p_condStr, p_currOper, sysdate, p_remark,p_usetag,p_condCate,p_dateType,p_condWhere);
    elsif p_funcCode = 'Mod' then
        update TD_M_WARNCOND_ANTI
        set    CONDCODE     = p_condCode ,
               CONDNAME     = p_condName ,
               RISKGRADE    = p_riskGrade,
               SUBJECTTYPE     = p_subjectType ,
               LIMITTYPE    = p_limitType,
               CONDCONTENT      = p_condStr ,
               UPDATESTAFFNO= p_currOper ,
               UPDATETIME   = sysdate    ,
               REMARK       = p_remark,
				USETAG		=p_usetag,
				CONDCATE=p_condCate,
				DATETYPE=p_dateType,
				CONDWHERE=p_condWhere
        where  CONDCODE     = p_oldCondCode;
        if SQL%ROWCOUNT != 1 then
            raise_application_error(-20103, 
                '更新反洗钱监控条件表有效行数不是1');
        end if;
    elsif p_funcCode = 'Del' then
        delete from TD_M_WARNCOND_ANTI
        where  CONDCODE = p_oldCondCode;
        if SQL%ROWCOUNT != 1 then
            raise_application_error(-20104, 
                '删除反洗钱监控条件表有效行数不是1');
        end if;
    end if;


    p_retCode := '0000000000'; p_retMsg  := '';
    commit; return;

exception when others then
    p_retCode := sqlcode;
    p_retMsg  := sqlerrm;
    rollback; return;
end;

/

show errors

