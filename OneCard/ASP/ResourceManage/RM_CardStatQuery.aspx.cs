using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Common;

public partial class ASP_ResourceManage_RM_CardStatQuery : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if(!IsPostBack)
        {
            DataTable dt1 = ChargeCardHelper.callQuery(context, "F8");
            GroupCardHelper.fill(selCardState, dt1, true);
            DataTable dt2 = ChargeCardHelper.callQuery(context, "F9");
            GroupCardHelper.fill(selCardCorp, dt2, true);
            UserCardHelper.resetData(gvResult, null);
        }
    }

    protected void gvResult_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void lvwQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[4].Text = Convert.ToInt32(e.Row.Cells[4].Text).ToString();
        }
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!submitValidation())
            return;

        if (context.hasError())
        {
            UserCardHelper.resetData(gvResult, null);
            return;
        }

        DataTable data = ChargeCardHelper.callQuery(context, "F10", selCardCorp.SelectedValue, txtYear.Text, txtCardBatch.Text,selCardState.SelectedValue);
        UserCardHelper.resetData(gvResult, data);

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N007P00001: 查询结果为空");
        }
    }

    protected Boolean submitValidation()
    {
        if (txtCardBatch.Text!="")
        {
            if (!Validation.isNum(txtCardBatch.Text.Trim()))
                context.AddError("批次号必须是数字", txtCardBatch);
        }
        if (txtYear.Text != "")
        {
            if (!Validation.isNum(txtYear.Text.Trim()))
                context.AddError("年份必须是数字", txtYear);
        }
       
        return !context.hasError();
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            ExportGridView(gvResult);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }
}