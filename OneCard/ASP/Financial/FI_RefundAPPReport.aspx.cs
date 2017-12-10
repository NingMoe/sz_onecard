using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using PDO.Financial;
using Master;
using System.Data;

public partial class ASP_Financial_FI_RefundAPPReport  : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
         if (!Page.IsPostBack)
        {
            //初始化日期
            txtFromDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            
            
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


        DataTable dt = GroupCardHelper.callQuery(context, "REFUNDAPP_QUERY", txtFromDate.Text, txtToDate.Text, selChannel.SelectedValue);
        if (dt == null || dt.Rows.Count < 1)
        {
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
            context.AddError("未查出记录");
            return;
        }

        UserCardHelper.resetData(gvResult, dt);
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
    private double totalCharges = 0;    //充值
    private double totalRefunds = 0;    //退款
    private int totalCount = 0;         //笔数
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            totalCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[2]));
            totalRefunds += Convert.ToDouble(GetTableCellValue(e.Row.Cells[3]));
            totalCount += Convert.ToInt32(GetTableCellValue(e.Row.Cells[4]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[2].Text = totalCharges.ToString("n");
            e.Row.Cells[3].Text = totalRefunds.ToString("n");
            e.Row.Cells[4].Text = totalCount.ToString();

        }
    }

}