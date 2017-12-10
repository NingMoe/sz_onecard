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

public partial class ASP_Financial_FI_PunchSale : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtStatMonth.Text = DateTime.Today.AddMonths(-1).ToString("yyyyMM");
        }
    }
    protected Boolean validation(string month)
    {
        if (Validation.isEmpty(txtStatMonth))
        {
            context.AddError("汇总年月不能为空");
            return false;
        }
        else if (!Validation.isDate(txtStatMonth.Text.Trim(), "yyyyMM"))
        {
            context.AddError("查询时间格式必须为yyyyMM");
            return false;
        }
        else if (txtStatMonth.Text.CompareTo(month) >= 0)
        {
            context.AddError("汇总年月不能大于等于当前月");
            return false;
        }
        return true;
    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        string todaymonth = DateTime.Today.ToString("yyyyMM");
        //校验输入有效性
        if (!validation(todaymonth)) return;
        //查询汇总结果

        string queryYearMonth = txtStatMonth.Text.Trim();
        DataTable data = ASHelper.callQuery(context, "QueryFIPunchSale", queryYearMonth);

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
            return;
        }
        gvResult.DataSource = data;
        gvResult.DataBind();       
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

    protected void lvwQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            if (e.Row.Cells[0].Text.Trim() == "利金卡")
            {
                e.Row.Cells[1].Text = "----";
                e.Row.Cells[2].Text = "----";
                e.Row.Cells[3].Text = "----";
                e.Row.Cells[4].Text = "----";
                //沉淀资金、充值总量等金额栏位千分位显示
                e.Row.Cells[5].Text = Convert.ToDecimal(e.Row.Cells[5].Text).ToString("n");
                e.Row.Cells[6].Text = Convert.ToDecimal(e.Row.Cells[6].Text).ToString("n");
                e.Row.Cells[7].Text = Convert.ToDecimal(e.Row.Cells[7].Text).ToString("n");
                e.Row.Cells[8].Text = Convert.ToDecimal(e.Row.Cells[8].Text).ToString("n");
            }
            else if (e.Row.Cells[0].Text.Trim() == "充值卡" || e.Row.Cells[0].Text.Trim() == "企服卡后台")
            {
                e.Row.Cells[1].Text = "----";
                e.Row.Cells[2].Text = "----";
                e.Row.Cells[3].Text = "----";
                e.Row.Cells[4].Text = "----";
                e.Row.Cells[7].Text = "----";
                e.Row.Cells[8].Text = "----";
                //沉淀资金、充值总量等金额栏位千分位显示
                e.Row.Cells[5].Text = Convert.ToDecimal(e.Row.Cells[5].Text).ToString("n");
                e.Row.Cells[6].Text = Convert.ToDecimal(e.Row.Cells[6].Text).ToString("n");
            }
            else
            {
                //沉淀资金、充值总量等金额栏位千分位显示
                e.Row.Cells[5].Text = Convert.ToDecimal(e.Row.Cells[5].Text).ToString("n");
                e.Row.Cells[6].Text = Convert.ToDecimal(e.Row.Cells[6].Text).ToString("n");
                e.Row.Cells[7].Text = Convert.ToDecimal(e.Row.Cells[7].Text).ToString("n");
                e.Row.Cells[8].Text = Convert.ToDecimal(e.Row.Cells[8].Text).ToString("n");
            }
        }
    }
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header)
        {
            GridViewRow rowHeader1 = new GridViewRow(0, 0, DataControlRowType.Header, DataControlRowState.Normal);
            TableCellCollection cells = e.Row.Cells;
            TableCell headerCell = new TableCell();
            headerCell.Text = "";
            rowHeader1.Cells.Add(headerCell);

            headerCell = new TableCell();
            headerCell.Text = "";
            rowHeader1.Cells.Add(headerCell);

            headerCell = new TableCell();
            headerCell.Text = "";
            rowHeader1.Cells.Add(headerCell);

            headerCell = new TableCell();
            headerCell.Text = "1-12月活卡量(张)";
            rowHeader1.Cells.Add(headerCell);

            headerCell = new TableCell();
            headerCell.Text = "";
            rowHeader1.Cells.Add(headerCell);

            headerCell = new TableCell();
            headerCell.Text = "";
            rowHeader1.Cells.Add(headerCell);

            headerCell = new TableCell();
            headerCell.Text = "";
            rowHeader1.Cells.Add(headerCell);

            headerCell = new TableCell();
            headerCell.Text = "";
            rowHeader1.Cells.Add(headerCell);

            headerCell = new TableCell();
            headerCell.Text = "";
            rowHeader1.Cells.Add(headerCell);

            rowHeader1.Cells.Add(headerCell);
            rowHeader1.CssClass = "tabbt";
            rowHeader1.Cells[0].ColumnSpan = 1;
            rowHeader1.Cells[1].ColumnSpan = 1;
            rowHeader1.Cells[2].ColumnSpan = 1;
            rowHeader1.Cells[3].ColumnSpan = 2;
            rowHeader1.Cells[4].ColumnSpan = 1;
            rowHeader1.Cells[5].ColumnSpan = 1;
            rowHeader1.Cells[6].ColumnSpan = 1;
            rowHeader1.Cells[7].ColumnSpan = 1;
            rowHeader1.Cells[8].ColumnSpan = 1;
            rowHeader1.Cells[3].VerticalAlign = VerticalAlign.Middle;
            rowHeader1.Cells[3].HorizontalAlign = HorizontalAlign.Center;
            rowHeader1.Visible = true;
            gvResult.Controls[0].Controls.AddAt(0, rowHeader1);
        }
    }
}