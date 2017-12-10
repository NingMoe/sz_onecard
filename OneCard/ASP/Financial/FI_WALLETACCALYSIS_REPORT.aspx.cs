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
using PDO.Financial;
using Master;

public partial class ASP_Financial_FI_WALLETACCALYSIS_REPORT : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtFromDate.Text = DateTime.Today.AddMonths(-1).ToString("yyyyMM");
          
            //初始化列表
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
        }
    }

    /// <summary>
    /// 查询校验
    /// </summary>
    /// <returns></returns>
    private bool validate()
    {
        Validation valid = new Validation(context);

        if (Validation.isEmpty(txtFromDate))
        {
            context.AddError("查询时间不能为空");
        }
        else if (!Validation.isDate(txtFromDate.Text.Trim(), "yyyyMM"))
        {
            context.AddError("查询时间格式必须为yyyyMM");
        }

        if (context.hasError())
            return false;
        else
            return true;
    }
    /// <summary>
    /// 查询按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.resetData(gvResult, null);

        validate();
        if (context.hasError()) return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "WALLET_ACC_TOTAL";
        pdo.var1 = txtFromDate.Text.Substring(0, 6);
   
        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);


        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
            btnPrint.Enabled = false;          
        }
        else
        {
            btnPrint.Enabled = true;         
        }

        UserCardHelper.resetData(gvResult, data);

    }
    /// <summary>
    /// 导出
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
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
    private decimal chargecardmoney = 0;
    private decimal custacctmoney = 0;
    private decimal cardacctmoney = 0;
    private decimal totalmoney = 0;
    /// <summary>
    /// 查询结果行绑定事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
        if (e.Row.RowType == DataControlRowType.DataRow && gvResult.ShowFooter)
        {
            chargecardmoney += Convert.ToDecimal(e.Row.Cells[1].Text);
            custacctmoney += Convert.ToDecimal(e.Row.Cells[2].Text);
            cardacctmoney += Convert.ToDecimal(e.Row.Cells[3].Text);
            totalmoney += Convert.ToDecimal(e.Row.Cells[4].Text);
        }
        else if (e.Row.RowType == DataControlRowType.Footer && gvResult.ShowFooter)
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[1].Text = chargecardmoney.ToString("n");
            e.Row.Cells[2].Text = custacctmoney.ToString("n");
            e.Row.Cells[3].Text = cardacctmoney.ToString("n");
            e.Row.Cells[4].Text = totalmoney.ToString("n");
        }
    }

}
