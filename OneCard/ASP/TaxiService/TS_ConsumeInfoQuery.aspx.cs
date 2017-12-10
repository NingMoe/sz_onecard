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
using TM;
using Common;
using TDO.ConsumeBalance;
using TDO.BalanceChannel;

public partial class ASP_TaxiService_TS_ConsumeInfoQuery : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始出租消费信息列表
            UserCardHelper.resetData(gvResult, null);

            // 初始化交易起讫日期
            txtBeginDate.Text = DateTime.Now.AddMonths(-1).ToString("yyyyMMdd");
            txtEndDate.Text = DateTime.Now.ToString("yyyyMMdd"); 
        }
    }

    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        //查询结果分页
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        //读司机卡片信息中的卡号,查询库中信息
        UserCardHelper.resetData(gvResult, null);

        QueryValidationFalse();
        if (context.hasError())return;

        DataTable dt = QueryTradeInfo();

        UserCardHelper.resetData(gvResult, dt);
    }

    private void QueryValidationFalse()
    {
        //对司机工号非空,数字,长度的检测
        txtStaffNoExt.Text = txtStaffNoExt.Text.Trim();
        txtStaffNoExt.Text = txtStaffNoExt.Text;
        string strStaffNo = txtStaffNoExt.Text;
        if (Validation.strLen(strStaffNo) != 0)
        {
            if (!Validation.isNum(strStaffNo))
                context.AddError("A003100002", txtStaffNoExt);
            else if (Validation.strLen(strStaffNo) != 6)
                context.AddError("A003100003", txtStaffNoExt);
        }

        //对起始和终止日期的校验        UserCardHelper.validateDateRange(context, txtBeginDate, txtEndDate, false);

    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        QueryValidationFalse();

        if (context.hasError())return;

        DataTable dt = QueryTradeInfo();

        UserCardHelper.resetData(gvResult, dt);
    }


    private DataTable QueryTradeInfo()
    {
        //从出租消费正常清单查询表(TQ_TAXI_RIGHT)中读取数据        return SPHelper.callTSQuery(context, "ConsumeInfoQuery", txtStaffNoExt.Text,
            txtBeginDate.Text, txtEndDate.Text);
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            gvResult.AllowPaging = false;
            DataTable dt = QueryTradeInfo();
            UserCardHelper.resetData(gvResult, dt);
            ExportGridView(gvResult);
            gvResult.AllowPaging = true;
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
        //保存当前查询出的交易信息
        ExportGridView(gvResult);
    }
}
