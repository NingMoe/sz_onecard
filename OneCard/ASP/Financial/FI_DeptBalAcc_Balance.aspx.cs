using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using TM;
using TDO.UserManager;
using Common;

public partial class ASP_Financial_FI_DeptBalAcc_Balance : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {

            //初始化日期
            txtFromDate.Text = DateTime.Now.AddDays(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Now.AddDays(-1).ToString("yyyyMMdd");

            //初始化营业厅
            DeptBalunitHelper.InitDBalUnit(context, selBalUnit, txtBalUnitName);

            showConGridView();
        }
    }

    private bool HasOperPower(string powerCode)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_ROLEPOWERTDO ddoTD_M_ROLEPOWERIn = new TD_M_ROLEPOWERTDO();
        string strSupply = " Select POWERCODE From TD_M_ROLEPOWER Where POWERCODE = '" + powerCode + "' And ROLENO IN ( SELECT ROLENO From TD_M_INSIDESTAFFROLE Where STAFFNO ='" + context.s_UserID + "')";
        DataTable dataSupply = tmTMTableModule.selByPKDataTable(context, ddoTD_M_ROLEPOWERIn, null, strSupply, 0);
        if (dataSupply.Rows.Count > 0)
            return true;
        else
            return false;
    }
    private void showConGridView()
    {
        //显示交易信息列表
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
  
    protected void btnQuery_Click(object sender, System.EventArgs e)
    {
        validate();
        if (context.hasError()) return;
        if (!checkEndDate()) return;
        DataTable data = SPHelper.callQuery("SP_PS_Query_Report", context, "DeptBalAccBalance", txtFromDate.Text, txtToDate.Text, selBalUnit.SelectedValue);
        if (data == null || data.Rows.Count < 1)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        UserCardHelper.resetData(gvResult, data);
    }
    protected void btnExport_Click(object sender, System.EventArgs e)
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
    protected void btnPrint_Click(object sender, System.EventArgs e)
    {

    }
    private double[] totalCharges = new double[11];
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            totalCharges[1] += Convert.ToDouble(GetTableCellValue(e.Row.Cells[1]));
            totalCharges[2] += Convert.ToDouble(GetTableCellValue(e.Row.Cells[2]));
            totalCharges[3] += Convert.ToDouble(GetTableCellValue(e.Row.Cells[3]));
            totalCharges[4] += Convert.ToDouble(GetTableCellValue(e.Row.Cells[4]));
            totalCharges[5] += Convert.ToDouble(GetTableCellValue(e.Row.Cells[5]));
            totalCharges[6] += Convert.ToDouble(GetTableCellValue(e.Row.Cells[6]));
            totalCharges[7] += Convert.ToDouble(GetTableCellValue(e.Row.Cells[7]));
            totalCharges[8] += Convert.ToDouble(GetTableCellValue(e.Row.Cells[8]));
            totalCharges[9] += Convert.ToDouble(GetTableCellValue(e.Row.Cells[9]));
            totalCharges[10] += Convert.ToDouble(GetTableCellValue(e.Row.Cells[10]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[1].Text = totalCharges[1].ToString("n");
            e.Row.Cells[2].Text = totalCharges[2].ToString("n");
            e.Row.Cells[3].Text = totalCharges[3].ToString("n");
            e.Row.Cells[4].Text = totalCharges[4].ToString("n");
            e.Row.Cells[5].Text = totalCharges[5].ToString("n");
            e.Row.Cells[6].Text = totalCharges[6].ToString("n");
            e.Row.Cells[7].Text = totalCharges[7].ToString("n");
            e.Row.Cells[8].Text = totalCharges[8].ToString("n");
            e.Row.Cells[9].Text = totalCharges[9].ToString("n");
            e.Row.Cells[10].Text = totalCharges[10].ToString("n");
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
            GridViewRow rowHeader = new GridViewRow(0, 0, DataControlRowType.Header, DataControlRowState.Normal);
            TableCellCollection cells = e.Row.Cells;
            TableCell headerCell = new TableCell();
            headerCell.Text = "";
            //headerCell.RowSpan = 1;
            //headerCell.ColumnSpan = 1;
            rowHeader.Cells.Add(headerCell);

            headerCell = new TableCell();
            headerCell.Text = "保证金";
            //headerCell.ColumnSpan = 3;
            rowHeader.Cells.Add(headerCell);

            headerCell = new TableCell();
            headerCell.Text = "预付款";
            //headerCell.ColumnSpan = 5;
            rowHeader.Cells.Add(headerCell);
            rowHeader.CssClass = "tabbt";
            rowHeader.Cells[0].ColumnSpan = 1;
            //rowHeader.Cells[0].RowSpan = 2;
            rowHeader.Cells[1].ColumnSpan = 4;
            rowHeader.Cells[2].ColumnSpan = 6;
            rowHeader.Cells[0].VerticalAlign = VerticalAlign.Middle;
            rowHeader.Cells[0].HorizontalAlign = HorizontalAlign.Center;
            rowHeader.Cells[1].VerticalAlign = VerticalAlign.Middle;
            rowHeader.Cells[1].HorizontalAlign = HorizontalAlign.Center;
            rowHeader.Cells[2].VerticalAlign = VerticalAlign.Middle;
            rowHeader.Cells[2].HorizontalAlign = HorizontalAlign.Center;
            rowHeader.Visible = true;
            gvResult.Controls[0].Controls.AddAt(0, rowHeader);
        }

    }

    // 查询输入校验处理
    private void validate()
    {
        Validation valid = new Validation(context);
        bool b1 = Validation.isEmpty(txtFromDate);
        bool b2 = Validation.isEmpty(txtToDate);
        DateTime? fromDate = null, toDate = null;
        if (b1 || b2)
        {
            context.AddError("开始日期和结束日期必须填写");
        }
        else
        {
            if (!b1)
            {
                fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");
            }
            if (!b2)
            {
                toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
            }
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }
    }

    private bool checkEndDate()
    {
        context.DBOpen("Select");
        string sql = "select REALEXECTIME from tp_job where jobno = 'DP000100'";
        DataTable table = context.ExecuteReader(sql);
        if (table != null && table.Rows.Count > 0 && table.Rows[0]["REALEXECTIME"].ToString().Trim().Length > 0)
        {
            DateTime dealDate = Convert.ToDateTime(Convert.ToDateTime(table.Rows[0]["REALEXECTIME"].ToString().Trim()).ToShortDateString());
            DateTime endDate = DateTime.ParseExact(txtToDate.Text.Trim(), "yyyyMMdd", null);
            if (endDate.CompareTo(dealDate) >= 0)
            {
                context.AddError("结束日期过大，未结算");
                return false;
            }
        }
        else
        {
            context.AddError("没有找到有效的结算处理时间");
            return false;
        }
        return true;
    }

    #region 根据输入结算单元名称初始化下拉选项
    /// <summary>
    /// 根据输入结算单元名称初始化下拉选项
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void txtBalUnitName_Changed(object sender, EventArgs e)
    {
        //初始化营业厅
        DeptBalunitHelper.InitDBalUnit(context, selBalUnit, txtBalUnitName);
    }
    #endregion
}