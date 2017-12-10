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

public partial class ASP_Financial_FI_EOC_MONTYLY_REPORT : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtFromDate.Text = DateTime.Today.AddMonths(-1).ToString("yyyyMM");
            txtToDate.Text = DateTime.Today.AddMonths(-1).ToString("yyyyMM");

            //初始详细信息不显示
            divdetail.Visible = false;

            //查询明细按钮不可用
            btnQueryDetail.Enabled = false;

            //初始化列表
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
            //gvResult.DataKeyNames = new string[] { "STATTIME", "MONEY" };
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

        if (Validation.isEmpty(txtToDate))
        {
            context.AddError("查询时间不能为空");
        }
        else if (!Validation.isDate(txtToDate.Text.Trim(), "yyyyMM"))
        {
            context.AddError("查询时间格式必须为yyyyMM");
        }

        if (txtFromDate != null && txtToDate != null)
        {
            valid.check(txtFromDate.Text.CompareTo(txtToDate.Text) <= 0, "开始日期不能大于结束日期");
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
        pdo.funcCode = "FUNDS_COLLECT_TOTAL";
        pdo.var1 = txtFromDate.Text.Substring(0, 6);
        pdo.var2 = txtToDate.Text.Substring(0, 6);

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        //hidNo.Value = pdo.var9;

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
            btnPrint.Enabled = false;
            btnQueryDetail.Enabled = false;
        }
        else
        {
            btnPrint.Enabled = true;
            btnQueryDetail.Enabled = true;
        }

        UserCardHelper.resetData(gvResult, data);

        divdetail.Visible = false;
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
            totalmoney += Convert.ToDecimal(e.Row.Cells[1].Text);
        }
        else if (e.Row.RowType == DataControlRowType.Footer && gvResult.ShowFooter)
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[1].Text = totalmoney.ToString("n");
        }
    }
    /// <summary>
    /// 查询明细按钮点击事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnQueryDetail_Click(object sender, EventArgs e)
    {
        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "FUNDS_COLLECT_DETAIL";
        pdo.var1 = txtFromDate.Text.Substring(0, 6);
        pdo.var2 = txtToDate.Text.Substring(0, 6);

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        //hidNo.Value = pdo.var9;

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
            btnExportDetail.Enabled = false;
            divdetail.Visible = false;
        }
        else
        {
            //labDate.Text = getDataKeys("STATTIME");
            divdetail.Visible = true;
            btnExportDetail.Enabled = true;
        }

        UserCardHelper.resetData(gvResultDetail, data);
    }

    /// <summary>
    /// 导出详细结果
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnExportDetail_Click(object sender, EventArgs e)
    {
        if (gvResultDetail.Rows.Count > 0)
        {
            ExportGridView(gvResultDetail);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }

    protected void gvResultDetail_PreRender(object sender, EventArgs e)
    {
        //合并行
        GridViewMergeHelper.MergeGridViewRows(gvResultDetail, 0, 0);
    }

    private decimal detailtotalmoney = 0;
    /// <summary>
    /// 详细信息行绑定事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void gvResultDetail_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
        if (e.Row.RowType == DataControlRowType.DataRow && gvResult.ShowFooter)
        {
            detailtotalmoney += Convert.ToDecimal(e.Row.Cells[2].Text);
        }
        else if (e.Row.RowType == DataControlRowType.Footer && gvResult.ShowFooter)
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[2].Text = detailtotalmoney.ToString("n");
        }
    }
}
