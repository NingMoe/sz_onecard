using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Common;

public partial class ASP_PrivilegePR_PR_LogonInfoQuery : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            ShowNonDataGridView();
            Init_Page();
        }
    }

    /// <summary>
    /// 初始化列表
    /// </summary>
    private void ShowNonDataGridView()
    {
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
    }
    protected void Init_Page()
    {
        //初始化日期
        DateTime date = new DateTime();
        date = DateTime.Today;
        txtFromDate.Text = date.AddMonths(-1).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");
    }

    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!DateValidation())
            return;
        gvResult.DataSource = Query();
        gvResult.DataBind();
    }

    //查询登录记录
    protected DataTable Query()
    {
        DataTable data = SPHelper.callQuery("SP_PR_Query", context, "QueryLogonLog", txtStaffNo.Text.Trim(), txtFromDate.Text.Trim(), txtToDate.Text.Trim());
        if (data.Rows.Count == 0)
        {
            context.AddMessage("没有查询出任何记录");
            return null;
        }       
        return data;
    }
    private Boolean DateValidation()
    {
        //对开始日期结束日期进行校验
        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, true);

        return !(context.hasError());
    }

    protected void gvResult_Page(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    } 
}