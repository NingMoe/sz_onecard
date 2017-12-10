using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using PDO.Financial;


public partial class ASP_Financial_FI_LRTTradeRecover : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期


            txtFromDate.Text = DateTime.Today.AddDays(-15).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.AddDays(-15).ToString("yyyyMMdd");
        }
    }

    private double totalCharges = 0;
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {

        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            if (selTradeType.SelectedValue == "0")
                totalCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[1]));
            else
                totalCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[4]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            if (selTradeType.SelectedValue == "0")
                e.Row.Cells[1].Text = totalCharges.ToString("n");
            else
                e.Row.Cells[4].Text = totalCharges.ToString("n");
        }
    }

    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }



    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        if (selTradeType.SelectedValue == "0")
        {
            pdo.funcCode = "QUERYLRTTRECOVERCOUNT";
        }
        else
        {
            pdo.funcCode = "QUERYLRTTRECOVERLIST";
        }

        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        StoreProScene storePro = new StoreProScene();

        DataTable data = storePro.Execute(context, pdo);
        hidNo.Value = pdo.var9;

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        totalCharges = 0;
        UserCardHelper.resetData(gvResult, data);
    }

    /// <summary>
    /// 分页事件
    /// </summary>
    protected void gvResult_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
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

    private void validate()
    {
        Validation valid = new Validation(context);

        bool b = Validation.isEmpty(txtFromDate);
        DateTime? fromDate = null, toDate = null;
        if (!b)
        {
            fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");
        }
        b = Validation.isEmpty(txtToDate);
        if (!b)
        {
            toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }
    }
}
