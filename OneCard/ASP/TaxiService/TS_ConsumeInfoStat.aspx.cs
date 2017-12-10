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
using TDO.ConsumeBalance;
using TDO.BalanceChannel;

public partial class ASP_TaxiService_TS_ConsumeInfoStat : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始出租消费列表
            lvwTaxiTradeStatInfo.DataSource = new DataTable();
            lvwTaxiTradeStatInfo.DataBind();

            // 初始化交易起讫日期
            txtBeginDate.Text = DateTime.Now.AddMonths(-1).ToString("yyyyMMdd");
            txtEndDate.Text = DateTime.Now.ToString("yyyyMMdd"); 
        }
    }

    public void lvwTaxiTradeStatInfo_Page(Object sender, GridViewPageEventArgs e)
    {
        //分页处理
        lvwTaxiTradeStatInfo.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        //读司机卡片信息中的卡号,查询库中信息
        ClearOutputInfo();

        if (QueryValidationFalse()) return;

        QueryTradeInfo(txtStaffNoExt.Text, txtBeginDate.Text, txtEndDate.Text);
    }

    private Boolean QueryValidationFalse()
    {
        //对司机工号非空,数字,长度的检测
        string strStaffNo = txtStaffNoExt.Text.Trim();

        if (Validation.strLen(strStaffNo) == 0)
            context.AddError("A003100001", txtStaffNoExt);
        else if (!Validation.isNum(strStaffNo))
            context.AddError("A003100002", txtStaffNoExt);
        else if (Validation.strLen(strStaffNo) != 6)
            context.AddError("A003100003", txtStaffNoExt);

        //对起始和终止日期的校验
        UserCardHelper.validateDateRange(context, txtBeginDate, txtEndDate);    

        return context.hasError();
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //查询条件校验
        if (QueryValidationFalse())
        {
            ClearOutputInfo();
            return;
        }

        //查询司机信息
        QueryTradeInfo(txtStaffNoExt.Text.Trim(), txtBeginDate.Text.Trim(), txtEndDate.Text.Trim());

    }

    private void QueryTradeInfo(string strStaffNo, string strBeginDate, string strEndDate)
    {
        //查询在该司机卡上当前输入交易日期消费的的交易记录
        TMTableModule tmTMTableModule = new TMTableModule();

        //从出租消费正常清单查询表(TQ_TAXI_RIGHT)中读取数据
        TQ_TAXI_RIGHTTDO ddoIn = new TQ_TAXI_RIGHTTDO();

        string strSql = "SELECT TRADEDATE 交易日期, count(*) 交易次数 , " +
                        "sum(TRADEMONEY)/100.0 交易金额, max(DEALTIME) 结算日期 FROM TQ_TAXI_RIGHT tqright ";

        ArrayList list = new ArrayList();
        list.Add("tqright.CALLINGSTAFFNO = '" + strStaffNo + "'");
        list.Add("tqright.CALLINGNO = '02'");
        list.Add("tqright.TRADEDATE >= '" + strBeginDate + "'");
        list.Add("tqright.TRADEDATE <= '" + strEndDate + "'");
     
        strSql += DealString.ListToWhereStr(list);
        strSql += " GROUP BY TRADEDATE ";

        DataTable data = tmTMTableModule.selByPKDataTable(context, ddoIn, null, strSql, 0);

        if (data.Rows.Count == 0)
        {
            ClearOutputInfo();
            context.AddError("A003105009");
            return;
        }
 
        //正常交易统计信息列表显示记录
        lvwTaxiTradeStatInfo.DataSource = new DataView(data);
        lvwTaxiTradeStatInfo.DataBind();
    }

    private int totalConut = 0;          //总交易次数
    private double totalMoney = 0.00;    //总交易金额

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            ControlDeal.RowDataBound(e);
            totalMoney += Convert.ToDouble(e.Row.Cells[2].Text);
            int times = Convert.ToInt32(Convert.ToDouble(e.Row.Cells[1].Text));
            totalConut += times;
            e.Row.Cells[1].Text = "" + times;
        }

        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[1].Text = "" + totalConut;
            e.Row.Cells[2].Text = totalMoney.ToString("n");
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        //保存当前查询出的交易信息
        ExportGridView(lvwTaxiTradeStatInfo);
    }

    protected void btnPrint_Click(object sender, EventArgs e)
    {
        //打印当前查询出的交易信息
    }

    private void ClearOutputInfo()
    {
        //清空查询结果列表
        lvwTaxiTradeStatInfo.DataSource = new DataTable();
        lvwTaxiTradeStatInfo.DataBind();
    }
}