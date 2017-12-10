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
using PDO.Financial;
using Master;
using Common;

public partial class ASP_Financial_FI_CardFeeMonthlyReport : Master.ExportMaster
{

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期

            txtDate.Text = DateTime.Today.ToString("yyyyMM");
        }
    }

    private int operCount = 0;
    private double totalCharges = 0;

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            operCount += Convert.ToInt32(GetTableCellValue(e.Row.Cells[1]));
            totalCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[2]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计: ";
            e.Row.Cells[1].Text = operCount.ToString();
            e.Row.Cells[2].Text = totalCharges.ToString("n");
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
    private bool validate()
    {
        Validation valid = new Validation(context);

        if(Validation.isEmpty(txtDate)){
            context.AddError("查询时间不能为空");
        }else if (!Validation.isDate(txtDate.Text.Trim(), "yyyyMM")){
            context.AddError("查询时间格式必须为yyyyMM");
        }
        if(context.hasError())
            return false;
        else
            return true;
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.resetData(gvResult, null);

        if(!validate())
            return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "CARDFEE_MONTH_COLLECT";
        pdo.var4 = txtDate.Text.Trim();

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);
        hidNo.Value = pdo.var9;

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        operCount = 0;
        totalCharges = 0;
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
