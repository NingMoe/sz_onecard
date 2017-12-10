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

public partial class ASP_Warn_WA_LossBlackList : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        UserCardHelper.resetData(gvResult, null);

        SPHelper.fillDDL(context, selWarnType, true,
            "SP_WA_Query", "WarnTypeDDL");
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.validateCardNo(context, txtCardNo1, true);

        if (context.hasError()) return;

        UserCardHelper.resetData(gvResult,
            SPHelper.callWAQuery(context, "QueryLossBlackList", txtCardNo1.Text));
        hidCardNo.Value = txtCardNo1.Text;
    }

    protected void btnDown_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            SPHelper.callWAQuery(context, "UpdateDownloadTime", hidCardNo.Value);
            ExportToFile(gvResult, "黑名单列表_" + DateTime.Today.ToString("yyyyMMdd") + ".txt");
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }

    protected void ExportToFile(GridView gv, string filename)
    {
        Response.Clear();
        Response.Buffer = true;
        Response.Charset = "GB2312";
        Response.ContentType = "application/vnd.text"; Response.ContentType = "text/plain";
        Response.AddHeader("Content-disposition", "attachment; filename=" + Server.UrlEncode(filename));
        Response.ContentEncoding = System.Text.Encoding.GetEncoding("GB2312");

        foreach (GridViewRow gvr in gv.Rows)
        {
            Response.Write(gvr.Cells[1].Text);
            Response.Write("\r\n");
        }

        Response.Flush();
        Response.End();

    }

    public void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        // 得到选择行

        GridViewRow selectRow = gvResult.SelectedRow;
        txtCardNo.Text = selectRow.Cells[1].Text;
        hidCardNoForDelAndMod.Value = txtCardNo.Text;

        labCreateTime.Text = selectRow.Cells[2].Text;

        selWarnType.SelectedValue = selectRow.Cells[3].Text.Substring(0, 1);
        selWarnLevel.SelectedValue = selectRow.Cells[4].Text.Substring(0, 1);
        labDownTime.Text = selectRow.Cells[5].Text;
        txtRemark.Text = Server.HtmlDecode(selectRow.Cells[6].Text).Trim();
    }

    private void validate(bool onlyCardNo)
    {
        Validation val = new Validation(context);

        UserCardHelper.validateCardNo(context, txtCardNo, false);

        if (onlyCardNo) return;

        val.notEmpty(selWarnLevel, "A860P01005: 告警级别必须选择");
        val.notEmpty(selWarnType, "A860P010109: 告警类型必须选择");

        val.maxLength(txtRemark, 100, "A860P01009: 备注不能超过100位");
    }

    private void prepareSp()
    {
        context.DBOpen("StorePro");

        context.AddField("p_funcCode");
        context.AddField("p_oldCardNo");
        context.AddField("p_cardNo");
        context.AddField("p_warnType");
        context.AddField("p_warnLevel", "Int32");
        context.AddField("p_remark");
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        validate(false);
        if (context.hasError()) return;

        prepareSp();
        context.SetFieldValue("p_funcCode", "Add");
        context.SetFieldValue("p_cardNo", txtCardNo.Text);
        context.SetFieldValue("p_warnType", selWarnType.SelectedValue);
        context.SetFieldValue("p_warnLevel", selWarnLevel.SelectedValue);
        context.SetFieldValue("p_remark", txtRemark.Text);

        bool ok = context.ExecuteSP("SP_WA_LossBlackList");

        if (ok)
        {
            AddMessage("D860P02001: 新增黑名单成功");
            btnQuery_Click(sender, e);
        }
    }
    protected void btnMod_Click(object sender, EventArgs e)
    {
        validate(false);
        if (context.hasError()) return;

        prepareSp();
        context.SetFieldValue("p_funcCode", "Mod");
        context.SetFieldValue("p_oldCardNo", hidCardNoForDelAndMod.Value);
        context.SetFieldValue("p_cardNo", txtCardNo.Text);
        context.SetFieldValue("p_warnType", selWarnType.SelectedValue);
        context.SetFieldValue("p_warnLevel", selWarnLevel.SelectedValue);
        context.SetFieldValue("p_remark", txtRemark.Text);
        bool ok = context.ExecuteSP("SP_WA_LossBlackList");

        if (ok)
        {
            AddMessage("D860P02002: 修改黑名单成功");
            btnQuery_Click(sender, e);
        }
    }
    protected void btnDel_Click(object sender, EventArgs e)
    {
        validate(true);
        if (context.hasError()) return;

        prepareSp();
        context.SetFieldValue("p_funcCode", "Del");
        context.SetFieldValue("p_oldCardNo", hidCardNoForDelAndMod.Value);
        bool ok = context.ExecuteSP("SP_WA_LossBlackList");

        if (ok)
        {
            AddMessage("D860P02003: 删除黑名单成功");
            btnQuery_Click(sender, e);
        }
    }
}
