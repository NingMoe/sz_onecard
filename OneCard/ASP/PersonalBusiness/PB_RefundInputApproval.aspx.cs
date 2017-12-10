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

public partial class ASP_PersonalBusiness_PB_RefundInputApproval : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        selQueryType.Items.Add(new ListItem("---请选择---", ""));
        selQueryType.Items.Add(new ListItem("可退", "0"));
        selQueryType.Items.Add(new ListItem("待查", "1"));
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {

        if (selQueryType.SelectedValue == "")
        {
            context.AddError("A094770001:请选择查询状态",selQueryType);
            return;
        }

        DataTable data = SPHelper.callPBQuery(context, "QureyRefundInput",selQueryType.SelectedValue);
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
            ++count;
            CheckBox cb = (CheckBox)gvr.FindControl("ItemCheckBox");
            if (cb != null && cb.Checked)
            {
                HiddenField hiddenTradeID1 = (HiddenField)gvr.FindControl("hiddenTradeID");
                DropDownList custName = (DropDownList)gvr.FindControl("ddlSlope");
                TextBox custContact = (TextBox)gvr.FindControl("txtID");
                if (chkApprove.Checked)
                {
                    if (gvr.Cells[2].Text == "待查")
                    {
                        context.AddError("第" + (count).ToString() + "行退款记录为待查状态，不可通过，请检查");
                    }
                }
                if (context.hasError()) break;

                context.ExecuteNonQuery("insert into TMP_COMMON(f7,f8,f9,f10,f11) values('"+Session.SessionID+"','" + Convert.ToInt32(Convert.ToDouble(gvr.Cells[5].Text) * 100) + "','" + gvr.Cells[3].Text + "','" + hiddenTradeID1.Value + "','"  + gvr.Cells[12].Text + "')");
           
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
        context.AddField("p_sessionId").Value = Session.SessionID;
        context.AddField("p_stateCode").Value = chkApprove.Checked ? "2" : "3";

        bool ok = context.ExecuteSP("SP_PB_RefundApprove");
        if (ok)
        {
            context.AddMessage(chkApprove.Checked 
                ? "退款记录审核通过" : "作废成功");
        }

        //清空临时表数据

        clearTempTable();
        
    }

    /// <summary>
    /// //清空临时表数据
    /// </summary>
    private void clearTempTable()
    {   
        context.DBOpen("Delete");
        context.ExecuteNonQuery("delete from TMP_COMMON where f7='"
            + Session.SessionID + "'");
        context.DBCommit();
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[1].Visible = false; //退款ID
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