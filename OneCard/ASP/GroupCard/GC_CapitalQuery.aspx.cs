using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using TDO.UserManager;
using Common;
using TM;
using NPOI.HSSF.UserModel;
using System.IO;
using PDO.GroupCard;
using Master;

/**********************************
 * 客户资金查询
 * 2014-12-12
 * gl
 * 初次编写
 * ********************************/
public partial class ASP_GroupCard_GC_CapitalQuery : Master.Master
{
    #region 初始化
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //默认选中单位订单
            hidOrderType.Value = "comorder";
            initLoad();
        }
        selectTab(this, this.GetType(), hidOrderType);
    }

    private void initLoad()
    {
        //初始化单位证件类型
        selActerPapertype.Items.Add(new ListItem("---请选择---", ""));
        selActerPapertype.Items.Add(new ListItem("01:组织机构代码证", "01"));
        selActerPapertype.Items.Add(new ListItem("02:企业营业执照", "02"));
        selActerPapertype.Items.Add(new ListItem("03:税务登记证", "03"));

        //初始化证件类型
        ASHelper.initPaperTypeList(context, selPapertype);

        //初始化时间
        //单位
        txtComFromDate.Text = DateTime.Today.AddMonths(-1).ToString("yyyyMM");
        txtComToDate.Text = DateTime.Today.AddMonths(-1).ToString("yyyyMM");
        //个人
        txtPerFromDate.Text = DateTime.Today.AddMonths(-1).ToString("yyyyMM");
        txtPerToDate.Text = DateTime.Today.AddMonths(-1).ToString("yyyyMM");

        //消费时间
        txtFromDate.Text = DateTime.Today.AddMonths(-1).ToString("yyyyMMdd");
        txtToDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");

        //初始化GridView
        gvResult.DataSource = new DataTable();
        gvResult.DataBind();
        gvResult.DataKeyNames = new string[] { "ORDERNO" };//用于RataBound时查询付款方式

        gvSource.DataSource = new DataTable();
        gvSource.DataBind();

        gvTarget.DataSource = new DataTable();
        gvTarget.DataBind();
    }
    //选择选项卡
    private void selectTab(Page page, Type type, HiddenField hidOrderType)
    {
        if (hidOrderType.Value.Equals("comorder"))
            ScriptManager.RegisterStartupScript(page, type, "selectTabScript", "SelectComOrder();", true);
        else
            ScriptManager.RegisterStartupScript(page, type, "selectTabScript", "SelectPerOrder();", true);
    }
    #endregion

    #region Event Handler
    /// <summary>
    /// 查询时订单输入性验证
    /// </summary>
    /// <returns></returns>
    private void QueryValidate(TextBox txtFromDate,TextBox txtToDate)
    {
        Validation valid = new Validation(context);
        bool b1 = Validation.isEmpty(txtFromDate);
        bool b2 = Validation.isEmpty(txtToDate);
        DateTime? fromDate = null, toDate = null;
        if (b1 || b2)
            context.AddError("订单开始月份和结束月份必须填写");
        else
        {
            if (!b1)
                fromDate = valid.beMonth(txtFromDate, "订单开始月份范围起始值格式必须为yyyyMM");
            if (!b2)
                toDate = valid.beMonth(txtToDate, "订单结束月份范围终止值格式必须为yyyyMM");
        }
        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "订单开始月份不能大于结束月份");
        }
    }
   
    /// <summary>
    /// 单位订单查询
    /// </summary>
    protected void btnComQuery_Click(object sender, EventArgs e)
    {
        QueryValidate(txtComFromDate,txtComToDate);
        if (context.hasError()) return;

        //资金来源
        gvSource.DataSource = new DataTable();
        gvSource.DataBind();

        //资金去向
        gvTarget.DataSource = new DataTable();
        gvTarget.DataBind();

        string groupName = ""; //单位名称
        groupName = txtGroupName.Text.Trim();

        string groupType = "";//证件类型
        groupType = selActerPapertype.SelectedValue;

        string groupNo = "";//证件号码
        groupNo = txtCompaperno.Text.Trim();

        string fromDate = txtComFromDate.Text.Trim();
        string toDate = txtComToDate.Text.Trim();
        DataTable dt = GroupCardHelper.callOrderQuery(context, "AllOrderInfoComSelect",groupName,groupType,groupNo,fromDate,toDate);
        if (dt == null || dt.Rows.Count < 1)
        {
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();

            context.AddError("未查出订单记录");
            return;
        }
        gvResult.DataSource = dt;
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;

    }

    /// <summary>
    /// 个人订单查询
    /// </summary>
    protected void btnPerQuery_Click(object sender, EventArgs e)
    {
        QueryValidate(txtPerFromDate, txtPerToDate);
        if (context.hasError()) return;

        //资金来源
        gvSource.DataSource = new DataTable();
        gvSource.DataBind();

        //资金去向
        gvTarget.DataSource = new DataTable();
        gvTarget.DataBind();

        string perName = ""; //姓名
        perName = txtActername.Text.Trim();

        string perType = "";//证件类型
        perType = selPapertype.SelectedValue;

        string perNo = "";//证件号码
        perNo = txtActerPaperno.Text.Trim();

        string fromDate = txtPerFromDate.Text.Trim();
        string toDate = txtPerToDate.Text.Trim();
        DataTable dt = GroupCardHelper.callOrderQuery(context, "AllOrderInfoPerSelect", perName, perType, perNo, fromDate, toDate);
        if (dt == null || dt.Rows.Count < 1)
        {
            gvResult.DataSource = new DataTable();
            gvResult.DataBind();
            context.AddError("未查出订单记录");
            return;
        }
        gvResult.DataSource = dt;
        gvResult.DataBind();
        gvResult.SelectedIndex = -1;
    }
  
     /// <summary>
    /// 选择不同行
    /// </summary>
    protected void gvResult_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (gvResult.SelectedIndex == -1)
            return;
        string orderno = gvResult.SelectedRow.Cells[0].Text;

        //资金来源
        DataTable dt = GroupCardHelper.callOrderQuery(context, "QueryCheckRelationInfo", orderno);
        if (dt.Rows.Count > 0)
        {
            gvSource.DataSource = dt;
            gvSource.DataBind();
        }
        else
        {
            gvSource.DataSource = null;//清空GridView
            gvSource.DataBind();
        }

        string fromDate = txtFromDate.Text.Trim();
        string toDate = txtToDate.Text.Trim();
        //资金去向
        dt = GroupCardHelper.callOrderQuery(context, "OrderTargetInfoSelect", orderno, fromDate, toDate);
        if (dt.Rows.Count > 0)
        {
            gvTarget.DataSource = dt;
            gvTarget.DataBind();
        }
        else
        {
            gvTarget.DataSource = null;//清空GridView
            gvTarget.DataBind();
        }
    }
    /// <summary>
    /// 注册行单击事件
    /// </summary>
    public void gvResult_RowCreated(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //注册行单击事件
            e.Row.Attributes.Add("onclick", "javascirpt:__doPostBack('gvResult','Select$" + e.Row.RowIndex + "')");
        }
    }

  
    /// <summary>
    /// 分页
    /// </summary>
    protected void gvResult_PageIndexChanging(object sender, GridViewPageEventArgs e)
    {
        gvResult.PageIndex = e.NewPageIndex;
        if (hidOrderType.Value.Equals("comorder"))
        {
            btnComQuery_Click(sender, e);
        }
        else
        {
            btnPerQuery_Click(sender, e);
        }
    }
    /// <summary>
    /// RowDataBound
    /// </summary>
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            //选择员工GRIDVIEW中的一行记录
            string orderno = gvResult.DataKeys[e.Row.RowIndex]["ORDERNO"].ToString();
            string queryPaytype = @"select pa.paytypecode from tf_f_paytype pa where pa.orderno ='" + orderno + " ' ";
            string payType = "";
            context.DBOpen("Select");
            DataTable data = context.ExecuteReader(queryPaytype);
            if (data.Rows.Count > 0)
            {
                for (int i = 0; i < data.Rows.Count; i++)
                {
                    payType += Paytype(data.Rows[i][0].ToString()) + ",";
                }
                payType = payType.Remove(payType.LastIndexOf(","), 1);
            }

            e.Row.Cells[12].Text = payType;

        }
    }
    /// <summary>
    /// 获取支付方式
    /// </summary>
    /// <param name="paytypecode">支付编码</param>
    private string Paytype(string paytypecode)
    {
        string paytype = "";
        switch (paytypecode)
        {
            case "0":
                paytype = "支/本票";
                break;
            case "1":
                paytype = "转账";
                break;
            case "2":
                paytype = "现金";
                break;
            case "3":
                paytype = "刷卡";
                break;
            case "4":
                paytype = "呈批单";
                break;
            default:
                paytype = "";
                break;
        }
        return paytype;
    }

    /// <summary>
    /// 消费查询时输入性验证
    /// </summary>
    private void QueryFeeValidate()
    {
        Validation valid = new Validation(context);
        bool b1 = Validation.isEmpty(txtFromDate);
        bool b2 = Validation.isEmpty(txtToDate);
        DateTime? fromDate = null, toDate = null;
        if (b1 || b2)
            context.AddError("消费开始日期和结束日期必须填写");
        else
        {
            if (!b1)
                fromDate = valid.beDate(txtFromDate, "消费开始日期范围起始值格式必须为yyyyMMdd");
            if (!b2)
                toDate = valid.beDate(txtToDate, "消费结束日期范围终止值格式必须为yyyyMMdd");
        }
        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "消费开始日期不能大于结束日期");
        }
    }
    /// <summary>
    /// 消费查询
    /// </summary>
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        QueryFeeValidate();
        if (context.hasError()) return;
        if (gvResult.SelectedIndex == -1 || gvResult.Rows.Count < gvResult.SelectedIndex + 1)
        {
            context.AddError("请选中一条订单记录");
            return;
        }
        string orderno = gvResult.SelectedRow.Cells[0].Text;
        string fromDate = txtFromDate.Text.Trim();
        string toDate = txtToDate.Text.Trim();
        //资金去向
        DataTable dt = GroupCardHelper.callOrderQuery(context, "OrderTargetInfoSelect", orderno, fromDate, toDate);
        if (dt.Rows.Count > 0)
        {
            gvTarget.DataSource = dt;
            gvTarget.DataBind();
        }
        else
        {
            gvTarget.DataSource = null;//清空GridView
            gvTarget.DataBind();
        }
    }
    /// <summary>
    /// 导出事件
    /// </summary>
    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.SelectedIndex == -1 || gvResult.Rows.Count < gvResult.SelectedIndex + 1)
        {
            context.AddError("请选中一条订单记录");
            return;
        }
        string orderno = gvResult.SelectedRow.Cells[0].Text;
        //选中的订单信息
        DataTable dt = GroupCardHelper.callOrderQuery(context, "OrderInfoSelectByNo", orderno);
        dt.TableName = "客户订单信息";
        //资金来源
        DataTable dtSource = new DataTable();
        if (gvSource.Rows.Count > 0)
            dtSource = GridViewToDataTable(gvSource);
        dtSource.TableName = "客户资金来源";
        //资金去向
        DataTable dtTarget = new DataTable();
        if (gvTarget.Rows.Count > 0)
            dtTarget = GridViewToDataTable(gvTarget);
        dtTarget.TableName = "客户资金去向";

        ExportMultiSheetExcel(dt, dtSource, dtTarget);
    }
    #endregion

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
            HSSFSheet sheet = workbook.CreateSheet(dtSources[k].TableName.ToString());

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
    private  DataTable GridViewToDataTable(GridView gv)
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