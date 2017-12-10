using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using PDO.Financial;
using Master;
using Common;
using TDO.BalanceParameter;

// 商户转账日报
public partial class ASP_FI_JiangYin_CloseReport : Master.ExportMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期

            txtFromDate.Text = DateTime.Today.ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");

            UserCardHelper.resetData(gvResult, null);
            return;
        }

    }

    private double total1 = 0;
    private double total2 = 0;
    private double total3 = 0;
    private double total4 = 0;
    private double total5 = 0;
    private double total6 = 0;
 
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            total1 += Convert.ToDouble(GetTableCellValue(e.Row.Cells[2]));
            total2 += Convert.ToDouble(GetTableCellValue(e.Row.Cells[3]));
            total3 += Convert.ToDouble(GetTableCellValue(e.Row.Cells[4]));
            total4 += Convert.ToDouble(GetTableCellValue(e.Row.Cells[5]));
            total5 += Convert.ToDouble(GetTableCellValue(e.Row.Cells[6]));
            total6 += Convert.ToDouble(GetTableCellValue(e.Row.Cells[7]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[2].Text = total1.ToString();
            e.Row.Cells[3].Text = total2.ToString("n");
            e.Row.Cells[4].Text = total3.ToString();
            e.Row.Cells[5].Text = total4.ToString("n");
            e.Row.Cells[6].Text = total5.ToString();
            e.Row.Cells[7].Text = total6.ToString("n");
        }
    }

    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }

    
    // 查询输入校验处理
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

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "JIANGYIN_FILE_REPORT";
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        pdo.var3 = "";

        StoreProScene storePro = new StoreProScene();

        DataTable data = storePro.Execute(context, pdo);

        hidNo.Value = pdo.var9;

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        UserCardHelper.resetData(gvResult, data);
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
