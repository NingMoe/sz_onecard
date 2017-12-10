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
using Master;
using Common;
using TM;
using TDO.ResourceManager;
using TDO.CardManager;
using System.Text;
using PDO.GroupCard;

// 用户卡查询处理

public partial class ASP_GroupCard_GC_ChargeQuery : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        UserCardHelper.resetData(gvResult, null);
    }

    private int totalRecords = 0;
    private decimal totalCharges = 0;

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            totalRecords += 1;
            totalCharges += Convert.ToDecimal(e.Row.Cells[4].Text);
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].ColumnSpan = 3;
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[2].Visible = false;
            e.Row.Cells[3].Text = "记录数:" + totalRecords;
            e.Row.Cells[4].Text = "总金额:" + totalCharges;
        }
    }
    // gridview分页处理
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //UserCardHelper.resetData(gvResult, null);

        string strQueryType = selQueryType.SelectedValue.Trim(); 
        //gvResult.ShowFooter =  (selQueryType.SelectedValue != "ChangeHis");
        if (strQueryType == "GetCardNoByCust" || strQueryType == "GetCustByCardNo" ||
            strQueryType == "ChangeHis")
        {
            gvResult.ShowFooter = false;
        }

        //gvResult.AllowPaging = false;

        // 根据条件进行查询
        DataTable data = GroupCardHelper.callQuery(context, "QueryChargeHistory",
            selQueryType.SelectedValue, txtVar1.Text.Trim());

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        totalRecords = 0; totalCharges = 0;
        UserCardHelper.resetData(gvResult, data);
    }
}
