using Common;
using Master;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NPOI.HSSF.UserModel;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TDO.BalanceChannel;
using TDO.BalanceParameter;
using TM;
public partial class ASP_Financial_FI_ZZTransferReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期

            TMTableModule tmTMTableModule = new TMTableModule();
            txtFromDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.ToString("yyyyMMdd");

            gvResult.DataSource = new DataTable();
            gvResult.DataBind();

        }
    }


    #region Private

    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
    }

    #region selectContorl

    private void InitCorp(DropDownList origindwls, DropDownList extdwls, String sqlCondition)
    {
        // 从单位编码表(TD_M_CORP)中读取数据，放入增加,修改区域中单位信息下拉列表中

        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_CORPTDO tdoTD_M_CORPIn = new TD_M_CORPTDO();
        tdoTD_M_CORPIn.CALLINGNO = origindwls.SelectedValue;

        TD_M_CORPTDO[] tdoTD_M_CORPOutArr = (TD_M_CORPTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CORPIn, typeof(TD_M_CORPTDO), null, sqlCondition, null);
        ControlDeal.SelectBoxFillWithCode(extdwls.Items, tdoTD_M_CORPOutArr, "CORP", "CORPNO", true);
    }

    private void InitDepart(DropDownList origindwls, DropDownList extdwls, String sqlCondition)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //从部门编码表(TD_M_CDEPART)中读取数据，放入下拉列表中


        TD_M_DEPARTTDO tdoTD_M_DEPARTIn = new TD_M_DEPARTTDO();
        tdoTD_M_DEPARTIn.CORPNO = origindwls.SelectedValue;

        TD_M_DEPARTTDO[] tdoTD_M_DEPARTOutArr = (TD_M_DEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_DEPARTIn, typeof(TD_M_DEPARTTDO), null, sqlCondition, null);
        ControlDeal.SelectBoxFillWithCode(extdwls.Items, tdoTD_M_DEPARTOutArr, "DEPART", "DEPARTNO", true);
    }

    private void InitBalUnit(string balType, DropDownList dwls)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_TRADE_BALUNITTDO tdoTF_TRADE_BALUNITIn = new TF_TRADE_BALUNITTDO();
        TF_TRADE_BALUNITTDO[] tdoTF_TRADE_BALUNITOutArr = null;

        //查询选定行业下的结算单元
        if (balType == "00")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_BYCALLING", null);
        }

        //查询选定单位下的结算单元
        else if (balType == "01")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = selCalling.SelectedValue;
            tdoTF_TRADE_BALUNITIn.CORPNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_BYCORP", null);
        }

        //查询选定部门下的结算单元
        else if (balType == "02")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = selCalling.SelectedValue;
            tdoTF_TRADE_BALUNITIn.CORPNO = selCorp.SelectedValue;
            tdoTF_TRADE_BALUNITIn.DEPARTNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_BYDEPART", null);
        }

        ControlDeal.SelectBoxFill(selBalUint.Items, tdoTF_TRADE_BALUNITOutArr, "BALUNIT", "BALUNITNO", true);
    }
    #endregion

    #region validate
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
    #endregion

    #region queryData

    private Dictionary<string, string> DeclarePost()
    {
        Dictionary<string, string> postData = new Dictionary<string, string>();
        postData.Add("channelCode", "ONECARD");
        postData.Add("callNo", selCalling.SelectedValue);
        postData.Add("corpNo", selCorp.SelectedValue);
        postData.Add("departNo", selDepart.SelectedValue);
        postData.Add("balunitNo", selBalUint.SelectedValue);
        postData.Add("fromDate", txtFromDate.Text);
        postData.Add("toDate", txtToDate.Text);

        return postData;
    }

    private DataTable initEmptyDataTable()
    {
        DataTable dt = new DataTable();
        dt.Columns.Add("BANKCODE", typeof(string));//银行编码
        dt.Columns.Add("BALUNITNO", typeof(string));//结算单元编码
        dt.Columns.Add("BALUNITNAME", typeof(string));//结算单元名称
        dt.Columns.Add("PURPOSETYPE", typeof(string));//收款人账户类型
        dt.Columns.Add("BANKACCNO", typeof(string));//银行账号
        dt.Columns.Add("TRANSFEE", typeof(string));//转账金额
        dt.Columns.Add("ENDTIME", typeof(string));//结算时间

        dt.Columns["BANKCODE"].MaxLength = 100;
        dt.Columns["BALUNITNO"].MaxLength = 100;
        dt.Columns["BALUNITNAME"].MaxLength = 100;
        dt.Columns["PURPOSETYPE"].MaxLength = 100;
        dt.Columns["BANKACCNO"].MaxLength = 100;
        dt.Columns["TRANSFEE"].MaxLength = 100;
        dt.Columns["ENDTIME"].MaxLength = 100;

        return dt;
    }

    private DataTable fillDataTable(HttpHelper.TradeType tradetype, Dictionary<string, string> postData)
    {
        string jsonResponse = HttpHelper.ZZPostRequest(tradetype, postData);
        //解析json
        DataTable dt = initEmptyDataTable();
        JObject deserObject = (JObject)JsonConvert.DeserializeObject(jsonResponse);
        string code = "";
        string message = "";
        foreach (JProperty itemProperty in deserObject.Properties())
        {
            string propertyName = itemProperty.Name;
            if (propertyName == "respCode")
            {
                code = itemProperty.Value.ToString();
            }
            else if (propertyName == "respDesc")
            {
                message = itemProperty.Value.ToString();
            }
            else if (propertyName == "transferColl")
            {
                if (itemProperty.Value == null)
                {
                    context.AddMessage("查询结果为空");
                    return null;
                }
            }
        }

        if (code == "0000") //表示成功
        {
            foreach (JProperty itemProperty in deserObject.Properties())
            {
                string propertyName = itemProperty.Name;
                if (propertyName == "transferColl")
                {
                    //DataTable赋值
                    JArray detailArray = new JArray();
                    try
                    {
                        detailArray = (JArray)itemProperty.Value;
                    }
                    catch (Exception)
                    {
                        context.AddMessage("查询结果为空");
                        return new DataTable();
                    }
                    foreach (JObject subItem in detailArray)
                    {
                        DataRow newRow = dt.NewRow();
                        foreach (JProperty subItemJProperty in subItem.Properties())
                        {
                            newRow[subItemJProperty.Name] = subItemJProperty.Value.ToString();
                        }
                        dt.Rows.Add(newRow);
                    }
                }
            }
        }
        else
        {
            context.AddError(message);
        }
        return dt;
    }
    #endregion

    #endregion


    #region protect Event

    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择查询的行业名称后,初始化单位名称,初始化结算单元名称


        selCorp.Items.Clear();
        selDepart.Items.Clear();
        selBalUint.Items.Clear();

        InitCorp(selCalling, selCorp, "TD_M_CORPCALLUSAGE");

        //初始化结算单元(属于选择行业)名称下拉列表值

        InitBalUnit("00", selCalling);

    }
    protected void selCorp_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择查询的单位名称后,初始化部门名称,初始化结算单元名称


        //选定单位后,设置部门下拉列表数据
        if (selCorp.SelectedValue == "")
        {
            selDepart.Items.Clear();
            InitBalUnit("00", selCalling);
            return;
        }

        //初始化单位下的部门信息

        InitDepart(selCorp, selDepart, "TD_M_DEPARTUSAGE");

        //初始化结算单元(属于选择单位)名称下拉列表值

        InitBalUnit("01", selCorp);


    }
    protected void selDepart_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择查询的部门名称后,初始化结算单元名称


        //选定单位后,设置部门下拉列表数据
        if (selDepart.SelectedValue == "")
        {
            InitBalUnit("01", selCorp);
            return;
        }

        //初始化结算单元(属于选择部门)名称下拉列表值

        InitBalUnit("02", selDepart);

    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            e.Row.Cells[5].Text = (Convert.ToDouble(GetTableCellValue(e.Row.Cells[5])) / 100.0).ToString();

            switch (e.Row.Cells[3].Text)
            {
                case "1":
                    e.Row.Cells[3].Text = "对公";
                    break;
                case "2":
                    e.Row.Cells[3].Text = "对私";
                    break;
                default:
                    e.Row.Cells[3].Text = "账户类型异常";
                    break;
            }
        }
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        DataTable data = fillDataTable(HttpHelper.TradeType.ZZTransferQuery, DeclarePost());
        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        //查询银行信息
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_BANKTDO ddoTD_M_BANKIn = new TD_M_BANKTDO();
        DataTable dataBank = tmTMTableModule.selByPKDataTable(context, ddoTD_M_BANKIn, null, "", null, 0);

        for (int i = 0; i < data.Rows.Count; i++)
        {
            string bankNo = data.Rows[i][0].ToString();
            DataRow[] dr = dataBank.Select("BANKCODE='" + bankNo.ToString() + "'");
            if (dr.Length == 1)
            {

                data.Rows[i][0] = dr[0]["BANK"].ToString();
            }
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


    protected void btnExportTransfer_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        DataTable data = fillDataTable(HttpHelper.TradeType.ZZTransferQuery, DeclarePost());

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        data.Columns.Add(new DataColumn("serialNumber", typeof(string)));
        data.Columns.Add(new DataColumn("BANKNAME", typeof(string)));
        data.Columns.Add(new DataColumn("BANKNUMBER", typeof(string)));
        data.Columns.Add(new DataColumn("ISSZBANK", typeof(string)));
        data.Columns.Add(new DataColumn("ISLOCAL", typeof(string)));
        data.Columns.Add(new DataColumn("paymentMark", typeof(string)));

        //查询银行信息
        TMTableModule tmTMTableModule = new TMTableModule();
        TD_M_BANKTDO ddoTD_M_BANKIn = new TD_M_BANKTDO();
        DataTable dataBank = tmTMTableModule.selByPKDataTable(context, ddoTD_M_BANKIn, null, "", null, 0);

        for (int i = 0; i < data.Rows.Count; i++)
        {
            //收款人账户类型
            if (data.Rows[i][3].ToString() == "1")
            {
                data.Rows[i][3] = "0";
            }
            else if (data.Rows[i][3].ToString() == "2")
            {
                data.Rows[i][3] = "1";
            }
            else
            {
                data.Rows[i][3] = "";
            }
            //转账金额
            data.Rows[i][5] = (Convert.ToDouble(data.Rows[i][5].ToString()) / 100.0).ToString();
            //编号
            data.Rows[i][7] = i + 1;
            string bankNo = data.Rows[i][0].ToString();
            DataRow[] dr = dataBank.Select("BANKCODE='" + bankNo.ToString() + "'");
            if (dr.Length == 1)
            {
                //收款人开户行名称-收款人行号-收款人是否本行-收款人是否同城-付款用途
                data.Rows[i][8] = dr[0]["BANK"].ToString();
                data.Rows[i][9] = dr[0]["BANKNUMBER"].ToString();
                data.Rows[i][10] = dr[0]["ISSZBANK"].ToString() == "1" ? "是" : "否";
                data.Rows[i][11] = dr[0]["ISLOCAL"].ToString() == "1" ? "是" : "否";
                data.Rows[i][12] = "";
            }
        }



        data.Columns.Remove("ENDTIME");
        data.Columns.Remove("BANKCODE");
        data.Columns.Remove("BALUNITNO");
        data.Columns["serialNumber"].SetOrdinal(0);
        data.Columns["BANKACCNO"].SetOrdinal(1);
        data.Columns["BALUNITNAME"].SetOrdinal(2);
        data.Columns["BANKNAME"].SetOrdinal(3);
        data.Columns["BANKNUMBER"].SetOrdinal(4);
        data.Columns["PURPOSETYPE"].SetOrdinal(5);
        data.Columns["TRANSFEE"].SetOrdinal(6);
        data.Columns["ISSZBANK"].SetOrdinal(7);
        data.Columns["ISLOCAL"].SetOrdinal(8);
        data.Columns["paymentMark"].SetOrdinal(9);

        ExportToExcel(data);
    }


    protected void ExportToExcel(DataTable dt)
    {
        string path = HttpContext.Current.Server.MapPath("../../") + "Tools\\网银转出模板.xls";

        FileStream fs = new FileStream(path, FileMode.Open, FileAccess.Read);

        HSSFWorkbook workbook = new HSSFWorkbook(fs);

        HSSFSheet sheet = (HSSFSheet)workbook.GetSheetAt(0);

        for (int i = 0; i < dt.Rows.Count; i++)
        {
            if (sheet.GetRow(2 + i) == null)
            {
                sheet.CreateRow(2 + i);
            }
            for (int j = 0; j < dt.Columns.Count; j++)
            {
                if (sheet.GetRow(2 + i).GetCell(j) == null)
                {
                    sheet.GetRow(2 + i).CreateCell(j);
                }

                sheet.GetRow(2 + i).GetCell(j).SetCellValue(dt.Rows[i][j].ToString());
            }
        }

        //增加“结束”行
        sheet.CreateRow(2 + dt.Rows.Count);
        sheet.GetRow(2 + dt.Rows.Count).CreateCell(0);

        sheet.GetRow(2 + dt.Rows.Count).GetCell(0).SetCellValue("结束");

        MemoryStream ms = new MemoryStream();
        using (ms)
        {
            workbook.Write(ms);
            byte[] data = ms.ToArray();
            #region 客户端保存
            HttpResponse response = System.Web.HttpContext.Current.Response;
            response.Clear();
            //Encoding pageEncode = Encoding.GetEncoding(PageEncode);
            response.Charset = "UTF-8";
            response.ContentType = "application/vnd-excel";//"application/vnd.ms-excel";
            System.Web.HttpContext.Current.Response.AddHeader("Content-Disposition", string.Format("attachment; filename=batchTransfer.xls"));
            System.Web.HttpContext.Current.Response.BinaryWrite(data);
            #endregion
        }

        //excel.WriteToFile();
    }
    #endregion

}
