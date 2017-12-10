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

public partial class ASP_PersonalBusiness_PB_ChangeDbBalanceApproval : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        initGridView();
    }

    private void initGridView()
    {
        DataTable data = SPHelper.callPBQuery(context, "QryCardBalanceChange");
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

                TextBox custName = (TextBox)gvr.FindControl("txtCustName");
                if (custName != null && chkApprove.Checked)
                {
                    val.notEmpty(custName, "客户姓名必须输入");
                }
                TextBox custContact = (TextBox)gvr.FindControl("txtCustContact");
                if (custContact != null && chkApprove.Checked)
                {
                    val.notEmpty(custContact, "联系方式必须输入");
                }
                if (context.hasError()) break;

                ++count;
                context.ExecuteNonQuery("insert into TMP_COMMON(f0, f4, f5) values('" +
                    gvr.Cells[1].Text + "','" + custName.Text + "', '" + custContact.Text + "')");

            }
        }
        context.DBCommit();

        if (context.hasError()) return;
 
        // 没有选中任何行，则返回错误
        if (count <= 0)
        {
            context.AddError("A004P03R01: 没有选中任何行");
        }
        if (context.hasError()) return;
      
        context.SPOpen();
        context.AddField("p_stateCode").Value = chkApprove.Checked ? "2" : "3";

        bool ok = context.ExecuteSP("SP_PB_ChangeDbBalanceApproval");
        if (ok)
        {
            context.AddMessage(chkApprove.Checked 
                ? "修改库内卡余额已经成功生效" : "作废成功");
        }

        initGridView();
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow ||
            e.Row.RowType == DataControlRowType.Header ||
            e.Row.RowType == DataControlRowType.Footer)
        {
            e.Row.Cells[1].Visible = false;
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