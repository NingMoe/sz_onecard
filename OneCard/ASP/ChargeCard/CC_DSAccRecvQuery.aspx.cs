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
using TM;
using PDO.ChargeCard;
using Common;

// 直销到账处理
public partial class ASP_ChargeCard_CC_DSAccRecvQuery : Master.Master
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        DataTable dt = new DataTable();
        gvResult.DataSource = dt;
        gvResult.DataBind();
    }

    // 换页处理
    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    // 查询按钮点击事件处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        // 根据是否到账以及客户姓名查询直销台帐（客户姓名为模糊查询）
        DataTable data = ChargeCardHelper.callQuery(context, "F01",
            radRecvd.Checked ? "1" : "0", txtCustName.Text.Trim());

        gvResult.DataSource = data;
        gvResult.DataBind();

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N007P00001: 查询结果为空");
        }

        // 初始化gridview中的是否到账复选框和到帐时间输入框
        for (int i = 0; i < gvResult.Rows.Count; ++i)
        {
            GridViewRow gvr = gvResult.Rows[i];
            Label cb = (Label)gvr.FindControl("lblState");
            cb.Text = radRecvd.Checked ? "已到帐" : "未到账";

        }
    }

  
}
