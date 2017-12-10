using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using Common;

public partial class ASP_PrivilegePR_PR_LogonTradeQuery : Master.FrontMaster
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

        UserCardHelper.selectDepts(context, selDEPARTNAME, true);

        UserCardHelper.selectStaffs(context, selSTAFFNAME, selDEPARTNAME, true);
    }

    protected void selDEPARTNAME_SelectedIndexChanged(object sender, EventArgs e)
    {
        UserCardHelper.selectStaffs(context, selSTAFFNAME, selDEPARTNAME, true);
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
        DataTable data = SPHelper.callQuery("SP_PR_Query", context, "QueryLogonTrade", selDEPARTNAME.SelectedValue, selSTAFFNAME.SelectedValue, txtFromDate.Text.Trim(), txtToDate.Text.Trim());
        if (data.Rows.Count == 0)
        {
            context.AddMessage("没有查询出任何记录");
            return null;
        }

        for (int i = 0; i < data.Rows.Count; i++)
        {
            if (i == 1) continue;

            if (data.Rows[i]["IPADDR"].ToString() == "") data.Rows[i]["IPADDR"] = data.Rows[i - 1]["IPADDR"].ToString();
        }

        //data 按照时间倒序
        DataView dataView = data.DefaultView;
        dataView.Sort = "OPERATETIME desc";
        data = dataView.ToTable();
        return data;
    }
    private Boolean DateValidation()
    {
        //对开始日期结束日期进行校验
        UserCardHelper.validateDateRange(context, txtFromDate, txtToDate, true);

        if (!context.hasError())
        {
            Validation valid = new Validation(context);
            if (valid.beDate(txtFromDate, "").Value.AddMonths(3) < DateTime.Now)
            {
                context.AddError("起始时间超过3个月",txtFromDate);
            }
        }

        if (selSTAFFNAME.SelectedValue == "")
        {
            context.AddError("员工号不能为空",selSTAFFNAME);
        }

        return !(context.hasError());
    }

    protected void gvResult_Page(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }
}