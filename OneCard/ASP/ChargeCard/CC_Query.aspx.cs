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
using Common;
using TDO.ChargeCard;
using Master;
using PDO.ChargeCard;

public partial class ASP_ChargeCard_CC_Query : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        DataTable data = ChargeCardHelper.callQuery(context, "F8");
        GroupCardHelper.fill(selCardState, data, true);

        UserCardHelper.resetData(gvResult, null);
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        ChargeCardHelper.validateCardNoRange(context, txtFromCardNo, txtToCardNo, false);

        if (context.hasError())
        {
            UserCardHelper.resetData(gvResult, null);

            return;
        }

        DataTable data = ChargeCardHelper.callQuery(context, "F6",
            txtFromCardNo.Text, txtToCardNo.Text, selCardState.SelectedValue);
        UserCardHelper.resetData(gvResult, data);

        if (data == null || data.Rows.Count == 0 )
        {
            AddMessage("N007P00001: 查询结果为空");
        }
    }

    protected void gvResult_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void lvwQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
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
