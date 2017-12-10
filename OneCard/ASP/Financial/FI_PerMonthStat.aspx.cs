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

public partial class ASP_Financial_FI_PerMonthStat : Master.ExportMaster
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
        else if (txtStatMonth.Text.CompareTo(month) > 0)
        {
            context.AddError("汇总年月不能大于当前月");
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
        SP_FI_QUERYCARDSTATPDO pdo = new SP_FI_QUERYCARDSTATPDO();
        if (txtStatMonth.Text.Trim() == todaymonth)
        {
            pdo.funcCode = "QUERYNOWSTAT";
        }
        else
        {
            pdo.funcCode = "QUERYHISTORYSTAT";
        }
        pdo.MONTH = txtStatMonth.Text.Trim();

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);
            
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
            if (e.Row.Cells[0].Text.Trim() != "苏州通卡" && e.Row.Cells[0].Text.Trim() != "SIMPASS卡" &&
                e.Row.Cells[0].Text.Trim() != "市民卡A卡" && e.Row.Cells[0].Text.Trim() != "市民卡B卡" &&
                e.Row.Cells[0].Text.Trim() != "合计")
            {
                //非苏州通卡，SIMPASS卡，合计，无POS机投放数据
                e.Row.Cells[6].Text = "----";
            }
            if (e.Row.Cells[0].Text.Trim() == "月票卡")
            {
                //月票卡无刷卡量数据
                e.Row.Cells[8].Text = "----";
                e.Row.Cells[9].Text = "----";
                e.Row.Cells[10].Text = "----";
                //沉淀资金千分位显示
                e.Row.Cells[7].Text = Convert.ToDecimal(e.Row.Cells[7].Text).ToString("n");
            }
            else if (e.Row.Cells[0].Text.Trim() == "园林年卡" || e.Row.Cells[0].Text.Trim() == "休闲年卡")
            {
                //园林年卡、休闲年卡无沉淀资金及刷卡数据
                e.Row.Cells[7].Text = "----";
                e.Row.Cells[8].Text = "----";
                e.Row.Cells[9].Text = "----";
                e.Row.Cells[10].Text = "----";
            }
            else
            {
                //沉淀资金、刷卡数据千分位显示
                e.Row.Cells[7].Text = Convert.ToDecimal(e.Row.Cells[7].Text).ToString("n");
                e.Row.Cells[8].Text = Convert.ToDecimal(e.Row.Cells[8].Text).ToString("n");
                e.Row.Cells[9].Text = Convert.ToDecimal(e.Row.Cells[9].Text).ToString("n");
                e.Row.Cells[10].Text = Convert.ToDecimal(e.Row.Cells[10].Text).ToString("n");
            }
            
        }
    }
    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }
    protected void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.Header)
        {
            GridViewRow rowHeader1 = new GridViewRow(0, 0, DataControlRowType.Header, DataControlRowState.Normal);
            TableCellCollection cells = e.Row.Cells;
            TableCell headerCell = new TableCell();
            headerCell.Text = "";
            //headerCell.RowSpan = 1;
            //headerCell.ColumnSpan = 1;
            rowHeader1.Cells.Add(headerCell);

            headerCell = new TableCell();
            headerCell.Text = "";
            //headerCell.ColumnSpan = 3;
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
            //rowHeader1.Cells[0].RowSpan =2;
            rowHeader1.Cells[1].ColumnSpan = 1;
            rowHeader1.Cells[2].ColumnSpan = 1;
            rowHeader1.Cells[3].ColumnSpan = 1;
            rowHeader1.Cells[4].ColumnSpan = 2;
            rowHeader1.Cells[5].ColumnSpan = 1;
            rowHeader1.Cells[6].ColumnSpan = 1;
            rowHeader1.Cells[7].ColumnSpan = 1;
            rowHeader1.Cells[8].ColumnSpan = 1;
            rowHeader1.Cells[9].ColumnSpan = 1;
            rowHeader1.Cells[4].VerticalAlign = VerticalAlign.Middle;
            rowHeader1.Cells[4].HorizontalAlign = HorizontalAlign.Center;
            //rowHeader1.Cells[1].VerticalAlign = VerticalAlign.Middle;
            //rowHeader1.Cells[1].HorizontalAlign = HorizontalAlign.Center;
            //rowHeader1.Cells[2].VerticalAlign = VerticalAlign.Middle;
            //rowHeader1.Cells[2].HorizontalAlign = HorizontalAlign.Center;
            rowHeader1.Visible = true;
            gvResult.Controls[0].Controls.AddAt(0, rowHeader1);

            //GridViewRow rowHeader2 = new GridViewRow(0, 0, DataControlRowType.Header, DataControlRowState.Normal);
            //headerCell.Text = "项目";
            ////headerCell.RowSpan = 1;
            ////headerCell.ColumnSpan = 1;
            //rowHeader2.Cells.Add(headerCell);

            //headerCell = new TableCell();
            //headerCell.Text = "发卡总量";
            ////headerCell.ColumnSpan = 3;
            //rowHeader2.Cells.Add(headerCell);

            //headerCell = new TableCell();
            //headerCell.Text = "1-12月发卡量(张)";
            //rowHeader2.Cells.Add(headerCell);

            //headerCell = new TableCell();
            //headerCell.Text = "当月发卡量";
            //rowHeader2.Cells.Add(headerCell);

            //headerCell = new TableCell();
            //headerCell.Text = "有消费卡";
            //rowHeader2.Cells.Add(headerCell);

            //headerCell = new TableCell();
            //headerCell.Text = "无消费新售卡";
            //rowHeader2.Cells.Add(headerCell);

            //headerCell = new TableCell();
            //headerCell.Text = "POS机投放总量";
            //rowHeader2.Cells.Add(headerCell);

            //headerCell = new TableCell();
            //headerCell.Text = "沉淀资金总量:万元";
            //rowHeader2.Cells.Add(headerCell);

            //headerCell = new TableCell();
            //headerCell.Text = "当月刷卡量:万元";
            //rowHeader2.Cells.Add(headerCell);

            //headerCell = new TableCell();
            //headerCell.Text = "1-12月刷卡量:万元";
            //rowHeader2.Cells.Add(headerCell);

            //headerCell = new TableCell();
            //headerCell.Text = "刷卡额总量:万元";
            //rowHeader2.Cells.Add(headerCell);

            //rowHeader2.Cells.Add(headerCell);
            //rowHeader2.CssClass = "tabbt";
            //rowHeader2.Cells[0].ColumnSpan = 1;
            //rowHeader2.Cells[1].ColumnSpan = 1;
            //rowHeader2.Cells[2].ColumnSpan = 1;
            //rowHeader2.Cells[3].ColumnSpan = 1;
            //rowHeader2.Cells[4].ColumnSpan = 1;
            //rowHeader2.Cells[5].ColumnSpan = 1;
            //rowHeader2.Cells[6].ColumnSpan = 1;
            //rowHeader2.Cells[7].ColumnSpan = 1;
            //rowHeader2.Cells[8].ColumnSpan = 1;
            //rowHeader2.Cells[9].ColumnSpan = 1;
            //rowHeader2.Cells[10].ColumnSpan = 1;
            //rowHeader2.Cells[0].VerticalAlign = VerticalAlign.Middle;
            //rowHeader2.Cells[0].HorizontalAlign = HorizontalAlign.Center;
            //rowHeader2.Cells[1].VerticalAlign = VerticalAlign.Middle;
            //rowHeader2.Cells[1].HorizontalAlign = HorizontalAlign.Center;
            //rowHeader2.Cells[2].VerticalAlign = VerticalAlign.Middle;
            //rowHeader2.Cells[2].HorizontalAlign = HorizontalAlign.Center;
            //rowHeader2.Cells[3].VerticalAlign = VerticalAlign.Middle;
            //rowHeader2.Cells[3].HorizontalAlign = HorizontalAlign.Center;
            //rowHeader2.Cells[4].VerticalAlign = VerticalAlign.Middle;
            //rowHeader2.Cells[4].HorizontalAlign = HorizontalAlign.Center;
            //rowHeader2.Cells[5].VerticalAlign = VerticalAlign.Middle;
            //rowHeader2.Cells[5].HorizontalAlign = HorizontalAlign.Center;
            //rowHeader2.Cells[6].VerticalAlign = VerticalAlign.Middle;
            //rowHeader2.Cells[6].HorizontalAlign = HorizontalAlign.Center;
            //rowHeader2.Cells[7].VerticalAlign = VerticalAlign.Middle;
            //rowHeader2.Cells[7].HorizontalAlign = HorizontalAlign.Center;
            //rowHeader2.Cells[8].VerticalAlign = VerticalAlign.Middle;
            //rowHeader2.Cells[8].HorizontalAlign = HorizontalAlign.Center;
            //rowHeader2.Cells[9].VerticalAlign = VerticalAlign.Middle;
            //rowHeader2.Cells[9].HorizontalAlign = HorizontalAlign.Center;
            //rowHeader2.Cells[10].VerticalAlign = VerticalAlign.Middle;
            //rowHeader2.Cells[10].HorizontalAlign = HorizontalAlign.Center;
            //rowHeader2.Visible = true;
            //gvResult.Controls[0].Controls.AddAt(1, rowHeader2);

            //context.AddMessage(rowHeader1.Cells[0].Text);
        }

    }
}