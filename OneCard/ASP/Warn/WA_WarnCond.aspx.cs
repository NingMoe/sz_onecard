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

public partial class ASP_Warn_WA_WarnCond : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        UserCardHelper.resetData(gvResult, null);
        SPHelper.fillDDL(context, selWarnType1, true,
            "SP_WA_Query", "WarnTypeDDL");
        SPHelper.fillDDL(context, selWarnType, true,
            "SP_WA_Query", "WarnTypeDDL");
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.resetData(gvResult,
            SPHelper.callWAQuery(context, "QueryWarnCond",
                txtCondCode1.Text,
                txtCondName1.Text,
                selCondRange1.SelectedValue,
                selWarnLevel1.SelectedValue,
                selCondCate1.SelectedValue));
    }

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

        val.notEmpty(selCondRange, "A860P01004: 条件范围必须选择");
        val.notEmpty(selWarnLevel, "A860P01005: 告警级别必须选择");
        val.notEmpty(selCondCate, "A860P01006: 条件类别必须选择");
        
        b = val.notEmpty(txtCondStr, "A860P01007: 条件字符串不能为空");
        if (b) val.maxLength(txtCondStr, 256, "A860P01008: 条件字符串不能超过256位");

        val.maxLength(txtRemark, 100, "A860P01009: 备注不能超过100位");

        val.notEmpty(selWarnType, "A860P010109: 告警类型必须选择");

    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        validate(false);
        if (context.hasError()) return;

        SP_WA_WarnCondPDO pdo = new SP_WA_WarnCondPDO();
        pdo.funcCode = "Add";
        pdo.condCode = txtCondCode.Text;
        pdo.condName = txtCondName.Text;
        pdo.condRange = selCondRange.SelectedValue;
        pdo.warnType = selWarnType.SelectedValue;
        pdo.warnLevel = selWarnLevel.SelectedValue;
        pdo.condCate = selCondCate.SelectedValue;
        pdo.condStr = txtCondStr.Text;
        pdo.remark = txtRemark.Text;


        bool ok = TMStorePModule.Excute(context, pdo);
        btnQuery_Click(sender, e);

        if (ok) AddMessage("D860P01001: 新增监控条件成功");
    }

    protected void btnMod_Click(object sender, EventArgs e)
    {
        validate(false);
        if (context.hasError()) return;

        SP_WA_WarnCondPDO pdo = new SP_WA_WarnCondPDO();
        pdo.funcCode = "Mod";
        pdo.oldCondCode = hidCondCode.Value;
        pdo.condCode = txtCondCode.Text;
        pdo.condName = txtCondName.Text;
        pdo.condRange = selCondRange.SelectedValue;
        pdo.warnType = selWarnType.SelectedValue;
        pdo.warnLevel = selWarnLevel.SelectedValue;
        pdo.condCate = selCondCate.SelectedValue;
        pdo.condStr = txtCondStr.Text;
        pdo.remark = txtRemark.Text;


        bool ok = TMStorePModule.Excute(context, pdo);
        btnQuery_Click(sender, e);

        if (ok) AddMessage("D860P01002: 修改监控条件成功");
    }

    protected void btnDel_Click(object sender, EventArgs e)
    {
        validate(true);
        if (context.hasError()) return;

        SP_WA_WarnCondPDO pdo = new SP_WA_WarnCondPDO();
        pdo.funcCode = "Del";
        pdo.oldCondCode = hidCondCode.Value;

        bool ok = TMStorePModule.Excute(context, pdo);
        btnQuery_Click(sender, e);

        if (ok) AddMessage("D860P01003: 删除监控条件成功");
    }

    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        // 得到选择行        GridViewRow selectRow = gvResult.SelectedRow;
        txtCondCode.Text = Server.HtmlDecode(selectRow.Cells[1].Text).Trim();
        hidCondCode.Value = txtCondCode.Text;
        txtCondName.Text = Server.HtmlDecode(selectRow.Cells[2].Text).Trim();
        selCondRange.SelectedValue = selectRow.Cells[3].Text.Substring(0,1);
        selWarnLevel.SelectedValue = selectRow.Cells[4].Text;
        selCondCate.SelectedValue = selectRow.Cells[5].Text.Substring(0, 1);
        selWarnType.Text = selectRow.Cells[6].Text.Substring(0, 1);
        txtCondStr.Text = Server.HtmlDecode(selectRow.Cells[7].Text).Trim();
        txtRemark.Text = Server.HtmlDecode(selectRow.Cells[8].Text).Trim();
    }
}
