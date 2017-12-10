using System;
using System.Data;
using System.Configuration;
using System.Collections;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Web.UI.HtmlControls;
using PDO.Warn;
using TM;
using Common;

public partial class ASP_Warn_WA_AntiWarnCond : Master.Master
{
    //初始化
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        UserCardHelper.resetData(gvResult, null);
        SPHelper.fillDDL(context, selSubjectType, true,
            "SP_WA_Query", "ANTIWarnTypeDDL", "SUBJECT_TYPE");
        SPHelper.fillDDL(context, selSubjectType1, true,
           "SP_WA_Query", "ANTIWarnTypeDDL", "SUBJECT_TYPE");
        selRiskGrade.Items.Add(new ListItem("---请选择---", ""));
        selRiskGrade.Items.Add(new ListItem("01:低风险", "01"));
        selRiskGrade.Items.Add(new ListItem("02:中风险", "02"));
        selRiskGrade.Items.Add(new ListItem("03:高风险", "03"));

        //selSubjectType.Items.Add(new ListItem("---请选择---", ""));
        //selSubjectType.Items.Add(new ListItem("01:客户", "01"));
        //selSubjectType.Items.Add(new ListItem("02:卡账户", "02"));
        //selSubjectType.Items.Add(new ListItem("03:商户", "03"));
        //selSubjectType.Items.Add(new ListItem("04:商户终端", "04"));

        selLimitType.Items.Add(new ListItem("---请选择---", ""));
        selLimitType.Items.Add(new ListItem("01:大额", "01"));
        selLimitType.Items.Add(new ListItem("02:可疑", "02"));

        selRiskGrade1.Items.Add(new ListItem("---请选择---", ""));
        selRiskGrade1.Items.Add(new ListItem("01:低风险", "01"));
        selRiskGrade1.Items.Add(new ListItem("02:中风险", "02"));
        selRiskGrade1.Items.Add(new ListItem("03:高风险", "03"));

        //selSubjectType1.Items.Add(new ListItem("---请选择---", ""));
        //selSubjectType1.Items.Add(new ListItem("01:客户", "01"));
        //selSubjectType1.Items.Add(new ListItem("02:卡账户", "02"));
        //selSubjectType1.Items.Add(new ListItem("03:商户", "03"));
        //selSubjectType1.Items.Add(new ListItem("04:商户终端", "04"));

        selLimitType1.Items.Add(new ListItem("---请选择---", ""));
        selLimitType1.Items.Add(new ListItem("01:大额", "01"));
        selLimitType1.Items.Add(new ListItem("02:可疑", "02"));

        //01消费清单表，02充值清单表，03订单表
        selCondCate.Items.Add(new ListItem("---请选择---", ""));
        selCondCate.Items.Add(new ListItem("01:消费清单表", "01"));
        selCondCate.Items.Add(new ListItem("02:充值清单表", "02"));
        selCondCate.Items.Add(new ListItem("03:订单表", "03"));
        //01按日,02按月
        selDateType.Items.Add(new ListItem("---请选择---", ""));
        selDateType.Items.Add(new ListItem("01:按日", "01"));
        selDateType.Items.Add(new ListItem("02:按月", "02"));
    }

    //查询按钮事件
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.resetData(gvResult,
            SPHelper.callWAQuery(context, "QueryWarnCondANTI",
                txtCondCode1.Text,
                txtCondName1.Text,
                selRiskGrade1.SelectedValue,
                selSubjectType1.SelectedValue,
                selLimitType1.SelectedValue));
    }

    //条件校验
    private void validate(bool onlyTypeCode)
    {
        Validation val = new Validation(context);
  
        // 条件编码必须是4位英数
        bool b = val.fixedLength(txtCondCode, 4, "A860P01001: 条件编码必须是4位英数");
        if (b) val.beAlpha(txtCondCode, "A860P01001: 条件编码必须是4位英数");

        if (onlyTypeCode) return;

        // 条件名称不能为空，并且不能超过100位
        b = val.maxLength(txtCondName, 256, "A860P01002: 条件名称不能超过256位");
        if (b) val.notEmpty(txtCondName, "A860P01003: 条件名称不能为空");

        val.notEmpty(selRiskGrade, "A860P01004: 风险等级必须选择");
        val.notEmpty(selSubjectType, "A860P01005: 主体类型必须选择");
        val.notEmpty(selLimitType, "A860P01006: 额度分类必须选择");
        val.notEmpty(selUsetag, "A860P01010：有效标识必须选择");
        val.notEmpty(selCondCate, "A860P01010：有效标识必须选择");
        val.notEmpty(selDateType, "A860P01010：有效标识必须选择");
        
        b = val.notEmpty(txtCondStr, "A860P01007: 条件字符串不能为空");
        if (b) val.maxLength(txtCondStr, 2000, "A860P01008: 条件字符串不能超过2000位");

        val.maxLength(txtRemark, 100, "A860P01009: 备注不能超过100位");

    }

    //添加按钮事件
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        validate(false);
        if (context.hasError()) return;

        SP_WA_WarnCond_ANTIPDO pdo = new SP_WA_WarnCond_ANTIPDO();
        pdo.funcCode = "Add";
        pdo.condCode = txtCondCode.Text;
        pdo.condName = txtCondName.Text;
        pdo.riskGrade = selRiskGrade.SelectedValue;
        pdo.subjectType = selSubjectType.SelectedValue;
        pdo.limitType = selLimitType.SelectedValue;
        pdo.condStr = txtCondStr.Text;
        pdo.remark = txtRemark.Text;
        pdo.usetag = selUsetag.SelectedValue;
        pdo.condCate = selCondCate.SelectedValue;
        pdo.dateType = selDateType.SelectedValue;
        pdo.condWhere = txtCondWhere.Text;

        bool ok = TMStorePModule.Excute(context, pdo);
        btnQuery_Click(sender, e);

        if (ok) AddMessage("D860P01001: 新增反洗钱监控条件成功");
    }

    //修改按钮事件
    protected void btnMod_Click(object sender, EventArgs e)
    {
        validate(false);
        if (context.hasError()) return;

        SP_WA_WarnCond_ANTIPDO pdo = new SP_WA_WarnCond_ANTIPDO();
        pdo.funcCode = "Mod";
        pdo.oldCondCode = hidCondCode.Value;
        pdo.condCode = txtCondCode.Text;
        pdo.condName = txtCondName.Text;
        pdo.riskGrade = selRiskGrade.SelectedValue;
        pdo.subjectType = selSubjectType.SelectedValue;
        pdo.limitType = selLimitType.SelectedValue;
        pdo.condStr = txtCondStr.Text;
        pdo.remark = txtRemark.Text;
        pdo.usetag = selUsetag.SelectedValue;
        pdo.condCate = selCondCate.SelectedValue;
        pdo.dateType = selDateType.SelectedValue;
        pdo.condWhere = txtCondWhere.Text;
        bool ok = TMStorePModule.Excute(context, pdo);
        btnQuery_Click(sender, e);

        if (ok) AddMessage("D860P01002: 修改反洗钱监控条件成功");
    }

    //删除按钮事件
    protected void btnDel_Click(object sender, EventArgs e)
    {
        validate(true);
        if (context.hasError()) return;

        SP_WA_WarnCond_ANTIPDO pdo = new SP_WA_WarnCond_ANTIPDO();
        pdo.funcCode = "Del";
        pdo.oldCondCode = hidCondCode.Value;

        bool ok = TMStorePModule.Excute(context, pdo);
        btnQuery_Click(sender, e);

        if (ok) AddMessage("D860P01003: 删除反洗钱监控条件成功");
    }

    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        // 得到选择行        GridViewRow selectRow = gvResult.SelectedRow;
        txtCondCode.Text = Server.HtmlDecode(selectRow.Cells[1].Text).Trim();
        hidCondCode.Value = txtCondCode.Text;
        txtCondName.Text = Server.HtmlDecode(selectRow.Cells[2].Text).Trim();
        selRiskGrade.SelectedValue = selectRow.Cells[3].Text.Substring(0,2);
        selSubjectType.SelectedValue = selectRow.Cells[4].Text.Substring(0, 2);
        selLimitType.SelectedValue = selectRow.Cells[5].Text.Substring(0, 2);
        selUsetag.SelectedValue = selectRow.Cells[6].Text.Substring(0, 1);
        txtRemark.Text = Server.HtmlDecode(selectRow.Cells[7].Text).Trim();
        txtCondStr.Text = Server.HtmlDecode(selectRow.Cells[8].Text).Trim();


        selCondCate.SelectedValue = selectRow.Cells[9].Text.Substring(0, 2);
        selDateType.SelectedValue = selectRow.Cells[10].Text.Substring(0, 2);
        txtCondWhere.Text = Server.HtmlDecode(selectRow.Cells[11].Text).Trim(); ;
    }
}
