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
using Common;
using TM;

public partial class ASP_Warn_WA_MonitorList : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        UserCardHelper.resetData(gvResult, null);

        SPHelper.fillDDL(context, selCondCode1, true, "SP_WA_Query", "WarnCondDDL", "1");
        SPHelper.fillDDL(context, selWarnType1, true, "SP_WA_Query", "WarnTypeDDL");

        SPHelper.fillDDL(context, selCondCode, true, "SP_WA_Query", "WarnCondDDL", "1");
        SPHelper.fillDDL(context, selWarnType, true, "SP_WA_Query", "WarnTypeDDL");
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.validateCardNo(context, txtCardNo1, true);

        if (context.hasError()) return;

        UserCardHelper.resetData(gvResult,
            SPHelper.callWAQuery(context, "QueryMonitorList",
                txtCardNo1.Text, selCondCode1.SelectedValue, selWarnType1.SelectedValue));
    }

    private void validate(bool forDelete)
    {
        UserCardHelper.validateCardNo(context, txtCardNo, forDelete);
        if (forDelete) return;

        Validation val = new Validation(context);

        val.notEmpty(selWarnLevel, "A860P01005: 告警级别必须选择");
        val.notEmpty(selWarnType, "A860P010109: 告警类型必须选择");
        val.notEmpty(selCondCode, "A860P030101: 告警条件必须选择");
        val.maxLength(txtRemark, 100, "A860P01009: 备注不能超过100位");
    }

    private void prepareSp()
    {
        context.DBOpen("StorePro");

        context.AddField("P_FUNCCODE", "String", "input");
        context.AddField("P_SEQNO", "string", "input");
        context.AddField("P_CARDNO", "string", "input");
        context.AddField("P_CONDCODE", "string", "input");
        context.AddField("P_WARNTYPE", "string", "input");
        context.AddField("P_WARNLEVEL", "Int32", "input");
        context.AddField("P_REMARK", "String", "input");
    }


    protected void btnAdd_Click(object sender, EventArgs e)
    {
        validate(false);
        if (context.hasError())return;

        prepareSp();
        context.SetFieldValue("p_funcCode", "Add");
        context.SetFieldValue("p_cardNo", txtCardNo.Text);
        context.SetFieldValue("P_CONDCODE", selCondCode.SelectedValue);
        context.SetFieldValue("p_warnType", selWarnType.SelectedValue);
        context.SetFieldValue("p_warnLevel", selWarnLevel.SelectedValue);
        context.SetFieldValue("p_remark", txtRemark.Text);

        bool ok = context.ExecuteSP("SP_WA_MonitorList");

        if (ok)
        {
            AddMessage("D860P03001: 新增监控名单成功");
            btnQuery_Click(sender, e);
        }
    }
    protected void btnMod_Click(object sender, EventArgs e)
    {
        validate(false);
        if (context.hasError())return;

        prepareSp();
        context.SetFieldValue("p_funcCode", "Mod");
        context.SetFieldValue("P_SEQNO", labSeqNo.Text);

        context.SetFieldValue("p_cardNo", txtCardNo.Text);
        context.SetFieldValue("P_CONDCODE", selCondCode.SelectedValue);
        context.SetFieldValue("p_warnType", selWarnType.SelectedValue);
        context.SetFieldValue("p_warnLevel", selWarnLevel.SelectedValue);
        context.SetFieldValue("p_remark", txtRemark.Text);

        bool ok = context.ExecuteSP("SP_WA_MonitorList");

        if (ok)
        {
            AddMessage("D860P03002: 修改增监控名单成功");
            btnQuery_Click(sender, e);
        }
    }
    protected void btnDel_Click(object sender, EventArgs e)
    {
        validate(true);
        if (context.hasError())return;

        prepareSp();
        context.SetFieldValue("p_funcCode", "Del");
        context.SetFieldValue("P_SEQNO", labSeqNo.Text);

        bool ok = context.ExecuteSP("SP_WA_MonitorList");

        if (ok)
        {
            AddMessage("D860P03003: 删除增监控名单成功");
            btnQuery_Click(sender, e);
        }
    }

    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        // 得到选择行
        GridViewRow selectRow = gvResult.SelectedRow;
        labSeqNo.Text = selectRow.Cells[1].Text;
        txtCardNo.Text = selectRow.Cells[2].Text;
        selCondCode.SelectedValue = selectRow.Cells[3].Text.Substring(0, 4);
        selWarnType.SelectedValue = selectRow.Cells[4].Text.Substring(0, 1);
        selWarnLevel.SelectedValue = selectRow.Cells[5].Text.Substring(0, 1);
        labCreateTime.Text = selectRow.Cells[6].Text;
        txtRemark.Text = Server.HtmlDecode(selectRow.Cells[7].Text).Trim();
    }
}
