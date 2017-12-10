using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using NPOI.HSSF.UserModel;
using PDO.Financial;
using TDO.BalanceParameter;
using TM;
//description 休闲开通对账报表
//creater     蒋兵兵
//date        2015-06-09
public partial class ASP_Financial_FI_RelaxNewReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期

            TMTableModule tmTMTableModule = new TMTableModule();
            txtFromDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");

            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
        }
    }

    private int totalopentimes = 0;           //开通数量
    private double totalcardcost = 0;         //卡费
    private double totalfuncfee = 0;          //功能费
    private double totalptdiscount = 0;         //优惠金额
    private double totaldhdiscount = 0;         //优惠金额
    private double totalpostage = 0;          //邮费
    private double totalorderfee = 0;         //实际功能费
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            //if (e.Row.RowIndex % 2 == 0 || e.Row.RowIndex == 0)
            //{
            //    //e.Row.Cells[0].RowSpan = 2;
            //    e.Row.Cells[7].RowSpan = 2;
            //}
            //else
            //{
            //    //e.Row.Cells[0].Visible = false;
            //    e.Row.Cells[7].Visible = false;
            //}
            totalopentimes += Convert.ToInt32(GetTableCellValue(e.Row.Cells[2]));
            totalcardcost += Convert.ToDouble(GetTableCellValue(e.Row.Cells[3]));
            totalfuncfee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[4]));
            totalptdiscount += Convert.ToDouble(GetTableCellValue(e.Row.Cells[5]));
            totaldhdiscount += Convert.ToDouble(GetTableCellValue(e.Row.Cells[6]));
            totalpostage += Convert.ToDouble(GetTableCellValue(e.Row.Cells[7]));
            totalorderfee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[8]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[0].ColumnSpan = 2;
            e.Row.Cells[1].Visible = false;
            e.Row.Cells[2].Text = totalopentimes.ToString();
            e.Row.Cells[3].Text = totalcardcost.ToString();
            e.Row.Cells[4].Text = totalfuncfee.ToString();
            e.Row.Cells[5].Text = totalptdiscount.ToString();
            e.Row.Cells[6].Text = totaldhdiscount.ToString();
            e.Row.Cells[7].Text = totalpostage.ToString();
            e.Row.Cells[8].Text = totalorderfee.ToString();
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

    private bool checkEndDate()
    {
        TP_DEALTIMETDO tdoTP_DEALTIMEIn = new TP_DEALTIMETDO();
        TP_DEALTIMETDO[] tdoTP_DEALTIMEOutArr = (TP_DEALTIMETDO[])tm.selByPKArr(context, tdoTP_DEALTIMEIn, typeof(TP_DEALTIMETDO), null, "DEALTIME", null);
        if (tdoTP_DEALTIMEOutArr.Length == 0)
        {
            context.AddError("没有找到有效的结算处理时间");
            return false;
        }
        else
        {
            DateTime dealDate = tdoTP_DEALTIMEOutArr[0].DEALDATE.Date;
            DateTime endDate = DateTime.ParseExact(txtToDate.Text.Trim(), "yyyyMMdd", null);
            if (endDate.CompareTo(dealDate) >= 0)
            {
                context.AddError("结束日期过大，未结算");
                return false;
            }
        }
        return true;
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

       
        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        if (selFunType.SelectedValue == "0")
        {
            pdo.funcCode = "QUERYRELAXNEWREPORT";
        }
        else
        {
            pdo.funcCode = "QUERYGARDENNEWREPORT"; 
        }

        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        pdo.var3 = selTradeType.SelectedValue;
        pdo.var4 = selPayCanal.SelectedValue;

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);
        hidNo.Value = pdo.var9;
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        
        UserCardHelper.resetData(gvResult, data);
    }

    protected void gvResult_PreRender(object sender, EventArgs e)
    {
        //合并行
        //GridViewMergeHelper.MergeGridViewRows(gvResult, 0, 0);
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
    protected void btnExportList_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 1)
        {
            SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
            if (selFunType.SelectedValue == "0")
            {
                pdo.funcCode = "EXCELFORRELAXLIST";
            }
            else
            {
                pdo.funcCode = "EXCELFORGARDENLIST";
            }
          
            pdo.var1 = txtFromDate.Text;
            pdo.var2 = txtToDate.Text;
            pdo.var3 = selTradeType.SelectedValue;
            pdo.var4 = selPayCanal.SelectedValue;

            StoreProScene storePro = new StoreProScene();
            DataTable data = storePro.Execute(context, pdo);

            ExportMultiSheetExcel(data);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }

    #region Private
    /// <summary>
    /// 导出EXCEL,可以导出多个sheet
    /// </summary>
    /// <param name="dtSources">原始数据数组类型</param>
    private void ExportMultiSheetExcel(params  DataTable[] dtSources)
    {
        HSSFWorkbook workbook = new HSSFWorkbook();

        for (int k = 0; k < dtSources.Length; k++)
        {
            HSSFSheet sheet = workbook.CreateSheet("sheet" + k.ToString());

            //填充表头
            HSSFRow dataRow = sheet.CreateRow(0);
            foreach (DataColumn column in dtSources[k].Columns)
            {
                dataRow.CreateCell(column.Ordinal).SetCellValue(column.ColumnName);
            }

            //填充内容
            for (int i = 0; i < dtSources[k].Rows.Count; i++)
            {
                dataRow = sheet.CreateRow(i + 1);
                for (int j = 0; j < dtSources[k].Columns.Count; j++)
                {
                    dataRow.CreateCell(j).SetCellValue(dtSources[k].Rows[i][j].ToString());
                }
            }
        }

        //设置响应的类型为Excel
        Response.ContentType = "application/vnd.ms-excel";
        //设置下载的Excel文件名
        Response.AddHeader("Content-Disposition", string.Format("attachment;filename={0}", "export.xls"));
        //Clear方法删除所有缓存中的HTML输出。但此方法只删除Response显示输入信息，不删除Response头信息。以免影响导出数据的完整性。
        Response.Clear();

        using (MemoryStream ms = new MemoryStream())
        {
            //将工作簿的内容放到内存流中
            workbook.Write(ms);
            //将内存流转换成字节数组发送到客户端
            Response.BinaryWrite(ms.GetBuffer());
            Response.End();
        }

    }
    /// <summary>
    /// 将GridView中控件值转换为string
    /// </summary>
    /// <param name="cell">Cell</param>
    /// <returns>返回值</returns>
    private string GetCellText(TableCell cell)
    {
        string text = cell.Text;
        if (!string.IsNullOrEmpty(text))
        {
            return text;
        }
        foreach (Control control in cell.Controls)
        {
            if (control != null && control is IButtonControl)
            {
                IButtonControl btn = control as IButtonControl;
                text = btn.Text.Replace("\r\n", "").Trim();
                break;
            }
            if (control != null && control is ITextControl)
            {
                LiteralControl lc = control as LiteralControl;
                if (lc != null)
                {
                    continue;
                }
                ITextControl l = control as ITextControl;

                text = l.Text.Replace("\r\n", "").Trim();
                break;
            }
        }
        return text;
    }
    /// <summary>
    /// 将GridView的数据生成DataTable
    /// </summary>
    /// <param name="gv">GridView对象</param>
    /// <returns>转化后的DataTable</returns>
    private DataTable GridViewToDataTable(GridView gv)
    {
        DataTable table = new DataTable();
        int rowIndex = 0;
        List<string> cols = new List<string>();
        if (!gv.ShowHeader && gv.Columns.Count == 0)
        {
            return table;
        }

        GridViewRow headerRow = gv.HeaderRow;
        int columnCount = headerRow.Cells.Count;
        for (int i = 0; i < columnCount; i++)
        {
            string text = GetCellText(headerRow.Cells[i]);
            cols.Add(text);
        }

        foreach (GridViewRow r in gv.Rows)
        {
            if (r.RowType == DataControlRowType.DataRow)
            {
                DataRow row = table.NewRow();
                int j = 0;
                for (int i = 0; i < columnCount; i++)
                {
                    string text = GetCellText(r.Cells[i]);
                    if (!String.IsNullOrEmpty(text))
                    {
                        if (rowIndex == 0)
                        {
                            string columnName = cols[i];
                            if (String.IsNullOrEmpty(columnName))
                            {
                                continue;
                            }
                            if (table.Columns.Contains(columnName))
                            {
                                continue;
                            }
                            DataColumn dc = table.Columns.Add();
                            dc.ColumnName = columnName;
                            dc.DataType = typeof(string);
                        }
                        row[j] = text;
                        j++;
                    }
                }
                rowIndex++;
                table.Rows.Add(row);
            }
        }
        return table;
    }

    #endregion
}
