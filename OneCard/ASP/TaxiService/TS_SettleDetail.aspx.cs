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
using TDO.ConsumeBalance;
using Common;
using TDO.BalanceChannel;


public partial class ASP_TaxiService_TS_SettleDetail : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        //设置结算明细信息列表表头
        UserCardHelper.resetData(gvResult, null);

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
        tdoTD_M_CORPIn.CALLINGNO = "02";

        TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context,
            tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, "TD_M_CORPCALLUSAGE", null);
        ControlDeal.SelectBoxFillWithCode(selCorp.Items, tdoTD_M_CORPOutArr, 
            "CORP", "CORPNO", true);
    }
    
   public void gvResult_Page(Object sender, GridViewPageEventArgs e)
   {
       //分页处理
       gvResult.PageIndex = e.NewPageIndex;
       btnQuery_Click(sender, e);

   }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询输入结算日期的结算明细信息
        UserCardHelper.validateDateRange(context, txtBeginDate, txtEndDate, true);
        if (context.hasError()) return;

        UserCardHelper.resetData(gvResult, QueryDriver());
    }

    protected void selCorp_SelectedIndexChanged(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_TRADE_BALUNITTDO tdoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();
        tdoTF_TRADE_BALUNITIn.CORPNO = selCorp.SelectedValue;

        TF_TRADE_BALUNITTDO[] tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context,
            tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TD_M_STAFFNO", null);

        ControlDeal.SelectBoxFillWithCode(selStaffno.Items, tdoTF_TRADE_BALUNITOutArr,
            "BALUNIT", "BALUNITNO", true);
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            ControlDeal.RowDataBound(e);
            int times = Convert.ToInt32(Convert.ToDouble(e.Row.Cells[0].Text));
            e.Row.Cells[0].Text = "" + times;
        }
    }


    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            gvResult.AllowPaging = false;
            DataTable dt = QueryDriver();
            UserCardHelper.resetData(gvResult, dt);
            ExportGridView(gvResult);
            gvResult.AllowPaging = true;
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }


    private DataTable QueryDriver()
    {
        //从出租消费正常清单查询表(TQ_TAXI_RIGHT)中读取数据
        if (selStaffno.SelectedValue != "")
        {
            return SPHelper.callTSQuery(context, "SettleDetail", selCorp.SelectedValue,
                txtBeginDate.Text, txtEndDate.Text, selStaffno.SelectedValue.Substring(2, 6));
        }
        else
        {
            return SPHelper.callTSQuery(context, "SettleDetail", selCorp.SelectedValue,
                txtBeginDate.Text, txtEndDate.Text);
        }
        
    }

}
