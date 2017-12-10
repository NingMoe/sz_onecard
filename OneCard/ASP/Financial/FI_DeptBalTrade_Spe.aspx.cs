using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using PDO.Financial;
using TDO.UserManager;
using TM;
using System.IO;
using NPOI.HSSF.UserModel;
using System.Web;

public partial class ASP_Financial_FI_DeptBalTrade_Spe : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期


            txtFromDate.Text = DateTime.Today.ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");

            //初始化部门


            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);

            UserCardHelper.resetData(gvResult, new DataTable());
        }
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[0].Visible = false; //网点编号

        }
    }

    // 查询输入校验处理
    private void validate()
    {
        Validation valid = new Validation(context);

        bool b = Validation.isEmpty(txtFromDate);
        DateTime? fromDate = null, toDate = null;
        if (b)
        {
            context.AddError("开始日期不能为空", txtFromDate);
        }
        else
        {
            fromDate = valid.beDate(txtFromDate, "开始日期范围起始值格式必须为yyyyMMdd");
        }
        b = Validation.isEmpty(txtToDate);
        if (b)
        {
            context.AddError("结束日期不能为空", txtToDate);
        }
        else
        {
            toDate = valid.beDate(txtToDate, "结束日期范围终止值格式必须为yyyyMMdd");
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }
    }

    public void gvResult_Page(Object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        btnQuery_Click(sender, e);
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //UserCardHelper.resetData(gvResult, null);

        validate();
        if (context.hasError()) return;

        DataTable data = GetSource();

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
    /// 取得数据源
    /// </summary>
    /// <returns></returns>
    private DataTable GetSource()
    {
        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "DEPTEBALTRADE_SPE";
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        pdo.var3 = selDept.SelectedValue;

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);
        return data;
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {

        if (gvResult.Rows.Count > 0)
        {
            //ExportGridView(gvResult);
            DataTable dt = GetSource();
            ExportToExcel(dt);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }

    protected void ExportToExcel(DataTable dt)
    {
        string path = HttpContext.Current.Server.MapPath("../../") + "Tools\\客服网点名称及帐号.xls";

        FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read);

        HSSFWorkbook workbookTemp = new HSSFWorkbook(fs);

        HSSFSheet sheetTemp = (HSSFSheet)workbookTemp.GetSheetAt(0);

        //取的模板列
        DataTable dtTeamplate = ExportToDataTable(sheetTemp);
        //DataTable dtTeamplate = new DataTable();
        //fs.Close();
        dt.Columns.Add("银行帐号");
        dt.Columns.Add("户名");

        //更改列的顺序
        dt.Columns["银行帐号"].SetOrdinal(2);
        dt.Columns["户名"].SetOrdinal(3);

        for (int i = 0; i < dt.Rows.Count; i++)
        {
            string bankCode = "";
            string userName = "";

            DataRow[] dtRow = new DataRow[0];
            
            foreach (DataRow item in dtTeamplate.Rows)
            {
                if (item[0].ToString() == dt.Rows[i][0].ToString())
                {

                    bankCode = item[2].ToString();
                    userName = item[3].ToString();
                }
            }

            dt.Rows[i]["银行帐号"] = bankCode;
            dt.Rows[i]["户名"] = userName;
        }

        HSSFWorkbook workbook = new HSSFWorkbook();

        HSSFSheet sheet = workbook.CreateSheet("sheet1");

        sheet.CreateRow(0);

        //设置居中
        HSSFCellStyle cellStyle = workbook.CreateCellStyle();
        cellStyle.Alignment = CellHorizontalAlignment.CENTER;

        #region 标题
        sheet.GetRow(0).CreateCell(0, HSSFCellType.STRING);
        sheet.GetRow(0).GetCell(0).CellStyle = cellStyle;
        sheet.GetRow(0).GetCell(0).SetCellValue("网点编号");

        sheet.GetRow(0).CreateCell(1, HSSFCellType.STRING);
        sheet.GetRow(0).GetCell(1).CellStyle = cellStyle;
        sheet.GetRow(0).GetCell(1).SetCellValue("网点名称");

        sheet.GetRow(0).CreateCell(2, HSSFCellType.STRING);
        sheet.GetRow(0).GetCell(2).CellStyle = cellStyle;
        sheet.GetRow(0).GetCell(2).SetCellValue("银行帐号");

        sheet.GetRow(0).CreateCell(3, HSSFCellType.STRING);
        sheet.GetRow(0).GetCell(3).CellStyle = cellStyle;
        sheet.GetRow(0).GetCell(3).SetCellValue("户名");

        sheet.GetRow(0).CreateCell(4, HSSFCellType.STRING);
        sheet.GetRow(0).GetCell(4).CellStyle = cellStyle;
        sheet.GetRow(0).GetCell(4).SetCellValue("押金退还");

        sheet.GetRow(0).CreateCell(5, HSSFCellType.STRING);
        sheet.GetRow(0).GetCell(5).CellStyle = cellStyle;
        sheet.GetRow(0).GetCell(5).SetCellValue("旅游卡押金退还");

        sheet.GetRow(0).CreateCell(6, HSSFCellType.STRING);
        sheet.GetRow(0).GetCell(6).CellStyle = cellStyle;
        sheet.GetRow(0).GetCell(6).SetCellValue("销户金额");
        #endregion

        for (int i = 0; i < dt.Rows.Count; i++)
        {
            if (sheet.GetRow(1+i) == null)
            {
                sheet.CreateRow(1+i);
            }
            for (int j = 0; j < dt.Columns.Count; j++)
            {
                if (sheet.GetRow(1+i).GetCell(j) == null)
                {

                    sheet.GetRow(1+i).CreateCell(j, HSSFCellType.STRING);

                    sheet.GetRow(1+i).GetCell(j).CellStyle = cellStyle;
                }

                sheet.GetRow(1+i).GetCell(j).SetCellValue(dt.Rows[i][j].ToString());
            }
        }


        //设置单元格宽度
        sheet.SetColumnWidth(0, 20 * 256);
        sheet.SetColumnWidth(1, 20 * 256);
        sheet.SetColumnWidth(2, 20 * 256);
        sheet.SetColumnWidth(3, 20 * 256);
        sheet.SetColumnWidth(4, 20 * 256);
        sheet.SetColumnWidth(5, 20 * 256);
        sheet.SetColumnWidth(6, 20 * 256);

        MemoryStream ms = new MemoryStream();
        using (ms)
        {
            workbook.Write(ms);
            byte[] data = ms.ToArray();
            #region 客户端保存
            HttpResponse response = System.Web.HttpContext.Current.Response;
            response.Clear();
            response.Charset = "UTF-8";
            response.ContentType = "application/vnd-excel";//"application/vnd.ms-excel";
            System.Web.HttpContext.Current.Response.AddHeader("Content-Disposition", string.Format("attachment; filename=deptTransfer.xls"));
            System.Web.HttpContext.Current.Response.BinaryWrite(data);
            #endregion
        }

        //excel.WriteToFile();
    }

    /// <summary>
    /// 把Sheet中的数据转换为DataTable
    /// </summary>
    /// <param name="sheet"></param>
    /// <returns></returns>
    private DataTable ExportToDataTable(HSSFSheet sheet)
    {
        DataTable dt = new DataTable();

        //默认，第一行是字段
        HSSFRow headRow = sheet.GetRow(0);

        //设置datatable字段
        for (int i = headRow.FirstCellNum, len = headRow.LastCellNum; i < len; i++)
        {
            dt.Columns.Add(headRow.Cells[i].StringCellValue);
        }
        //遍历数据行
        for (int i = (sheet.FirstRowNum + 1), len = sheet.LastRowNum + 1; i < len; i++)
        {
            HSSFRow tempRow = sheet.GetRow(i);
            DataRow dataRow = dt.NewRow();

            //遍历一行的每一个单元格
            for (int r = 0, j = tempRow.FirstCellNum, len2 = tempRow.LastCellNum; j < len2; j++, r++)
            {

                HSSFCell cell = tempRow.GetCell(j);

                if (cell != null)
                {
                    switch (cell.CellType)
                    {
                        case HSSFCellType.STRING:
                            dataRow[r] = cell.StringCellValue;
                            break;
                        case HSSFCellType.NUMERIC:
                            dataRow[r] = cell.NumericCellValue;
                            break;
                        case HSSFCellType.BOOLEAN:
                            dataRow[r] = cell.BooleanCellValue;
                            break;
                        default: dataRow[r] = "ERROR";
                            break;
                    }
                }
            }
            dt.Rows.Add(dataRow);
        }
        return dt;
    }
}
