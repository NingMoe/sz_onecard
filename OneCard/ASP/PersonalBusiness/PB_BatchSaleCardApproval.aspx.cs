using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using System.Data;
using TM;

public partial class ASP_PersonalBusiness_PB_BatchSaleCardApproval : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        initGridView();
    }

    private void initGridView()
    {
        DataTable data = SPHelper.callPBQuery(context, "QueryBatchSaleCard");
        //DataTable data = null;
        UserCardHelper.resetData(gvResult, data);
        bool displaySubmit = data != null && data.Rows.Count > 0;
    }
    // 选中gridview中当前页所有数据项
    protected void CheckAll(object sender, EventArgs e)
    {
        CheckBox cbx = (CheckBox)sender;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox ch = (CheckBox)gvr.FindControl("ItemCheckBox");
            ch.Checked = cbx.Checked;
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 首先清空临时表


        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON ");

        Validation val = new Validation(context);
        // 根据页面数据生成临时表数据

        int count = 0;
        foreach (GridViewRow gvr in gvResult.Rows)
        {
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {

                ++count;
                context.ExecuteNonQuery("insert into TMP_COMMON(f1) values('" + gvr.Cells[1].Text.Trim() + "')");
            }
        }
        if (context.hasError()) return;
        context.DBCommit();
        // 没有选中任何行，则返回错误

        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中任何行");
        }
        if (context.hasError()) return;

        context.SPOpen();
        context.AddField("p_stateCode").Value = chkApprove.Checked ? "2" : "3";
        context.AddField("p_TRADEID", "String", "output", "16", null);

        bool ok = context.ExecuteSP("SP_PB_BatchSaleCardApproval");
        if (ok)
        {
            context.AddMessage(chkApprove.Checked
                ? "批量售卡记录审核通过" : "作废成功");
            chkApprove.Checked = chkReject.Checked = btnSubmit.Enabled = false;
        }
        try
        {
            initGridView();
        }
        catch (Exception ex)
        {
            context.AddError(ex.Message);
            return;
        }

    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[13].Visible = false;
            e.Row.Cells[14].Visible = false;
        }
    }

    // 通过 复选框 改变事件
    protected void chkApprove_CheckedChanged(object sender, EventArgs e)
    {
        if (chkApprove.Checked)
        {
            chkReject.Checked = false;
        }

        btnSubmit.Enabled = (chkApprove.Checked || chkReject.Checked);
    }

    // 作废 复选框 改变事件
    protected void chkReject_CheckedChanged(object sender, EventArgs e)
    {
        if (chkReject.Checked)
        {
            chkApprove.Checked = false;
        }
        btnSubmit.Enabled = (chkApprove.Checked || chkReject.Checked);
    }
}