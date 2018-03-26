using System;
using System.Data;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using NPOI.HSSF.UserModel;
using PDO.Financial;
using TDO.BalanceChannel;
using TDO.BalanceParameter;
using TM;


public partial class ASP_Financial_FI_DiscountOutcomfindReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;
        UserCardHelper.resetData(gvResult, null);
        TMTableModule tmTMTableModule = new TMTableModule();
        //初始化查询输入的行业名称下拉列表框


        //从行业编码表(TD_M_CALLINGNO)中读取数据，放入查询输入行业名称下拉列表中
        TD_M_CALLINGNOTDO tdoTD_M_CALLINGNOIn = new TD_M_CALLINGNOTDO();
        TD_M_CALLINGNOTDO[] tdoTD_M_CALLINGNOOutArr = (TD_M_CALLINGNOTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_CALLINGNOIn, typeof(TD_M_CALLINGNOTDO), "S008100213", "TD_M_CALLINGNO_DISCOUNT", null);

        ControlDeal.SelectBoxFillWithCode(selCalling.Items, tdoTD_M_CALLINGNOOutArr, "CALLING", "CALLINGNO", true);

        txtBeginDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
        txtEndDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");

    }


    protected void selCalling_SelectedIndexChanged(object sender, EventArgs e)
    {
        //选择查询的行业名称后,初始化单位名称,初始化结算单元名称
        selCorp.Items.Clear();
        selDepart.Items.Clear();
        selBalUint.Items.Clear();

        InitCorp(selCalling, selCorp, "TD_M_CORPCALLUSAGE_DISCOUNT");//加载存在优惠方案的单位名称

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
        InitDepart(selCorp, selDepart, "TD_M_DEPARTUSAGE_DISCOUNT");
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
    protected void InitCorp(DropDownList origindwls, DropDownList extdwls, String sqlCondition)
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
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_CALLING_DISCOUNT", null);
        }

        //查询选定单位下的结算单元
        else if (balType == "01")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = selCalling.SelectedValue;
            tdoTF_TRADE_BALUNITIn.CORPNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_CORP_DISCOUNT", null);
        }

        //查询选定部门下的结算单元
        else if (balType == "02")
        {
            tdoTF_TRADE_BALUNITIn.CALLINGNO = selCalling.SelectedValue;
            tdoTF_TRADE_BALUNITIn.CORPNO = selCorp.SelectedValue;
            tdoTF_TRADE_BALUNITIn.DEPARTNO = dwls.SelectedValue;
            tdoTF_TRADE_BALUNITOutArr = (TF_TRADE_BALUNITTDO[])tmTMTableModule.selByPKArr(context, tdoTF_TRADE_BALUNITIn, typeof(TF_TRADE_BALUNITTDO), null, "TF_TRADE_BALUNITALL_DEPART_DISCOUNT", null);
        }

        ControlDeal.SelectBoxFill(selBalUint.Items, tdoTF_TRADE_BALUNITOutArr, "BALUNIT", "BALUNITNO", true);
    }
    // 查询输入校验处理
    private void validate()
    {
        Validation valid = new Validation(context);

        bool b1 = Validation.isEmpty(txtBeginDate);
        bool b2 = Validation.isEmpty(txtEndDate);
        DateTime? fromDate = null, toDate = null;

        if (!b1)
        {
            fromDate = valid.beDate(txtBeginDate, "开始日期范围起始值格式必须为yyyyMMdd");
        }
        if (!b2)
        {
            toDate = valid.beDate(txtEndDate, "结束日期范围终止值格式必须为yyyyMMdd");
        }

        if (fromDate != null && toDate != null)
        {
            valid.check(fromDate.Value.CompareTo(toDate.Value) <= 0, "开始日期不能大于结束日期");
        }


    }
    protected void btnQuery_Click(object sender, EventArgs e)
    {

        validate();
        if (context.hasError()) return;
        hidBeginDate.Value = txtBeginDate.Text.ToString().Trim();
        hidEndDate.Value = txtEndDate.Text.ToString().Trim();
        //优惠商户转账信息
        DataTable data = SPHelper.callPSQuery(context, "QueryDiscountOutComfindReport", txtBeginDate.Text, txtEndDate.Text,selCalling.SelectedValue,
            selCorp.SelectedValue, selDepart.SelectedValue, selBalUint.SelectedValue,selType.SelectedValue);
        

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        UserCardHelper.resetData(gvResult, data);


    }

    //private double originTradeMoney =0;//原交易金额（商户转账日报的转账金额）
    private double totalCharges = 0;      //转账金额
    private double totalREFUNDMENT = 0;      //退货总优惠金额

    private double totalFinfee = 0;  // 消费总优惠 
    private double totalCommission = 0;  // 佣金差 
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            //originTradeMoney += Convert.ToDouble(GetTableCellValue(e.Row.Cells[5]));
            totalCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[5]));
            totalFinfee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[6]));
            totalREFUNDMENT += Convert.ToDouble(GetTableCellValue(e.Row.Cells[7]));
            totalCommission += Convert.ToDouble(GetTableCellValue(e.Row.Cells[8]));
            

        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            //e.Row.Cells[5].Text = originTradeMoney.ToString("n");
            e.Row.Cells[5].Text = totalCharges.ToString("n");
            e.Row.Cells[6].Text = totalFinfee.ToString("n");
            e.Row.Cells[7].Text = totalREFUNDMENT.ToString("n");
            e.Row.Cells[8].Text = totalCommission.ToString("n");
        }

    }
    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
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
    private void validate2()
    {
        //判断凭证日期是否为同一天

        if (txtBeginDate.Text != txtEndDate.Text)
        {
            context.AddError("查询日期不是同一天，凭证导出必须为日结");
        }

        ////对财务转账类型进行非空检验

        //if (selTrans.SelectedValue == "")
        //{
        //    context.AddError("请先选择财务转账类型", selTrans);
        //}
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
            DateTime endDate = DateTime.ParseExact(txtEndDate.Text.Trim(), "yyyyMMdd", null);
            if (endDate.CompareTo(dealDate) >= 0)
            {
                context.AddError("结束日期过大，未结算");
                return false;
            }
        }
        return true;
    }

    protected void btnExportSql_Click(object sender, EventArgs e)
    {
        if (hidEndDate.Value == "")
        {
            context.AddError("导出凭证前请先查询商户对账信息。");
            return;
        }
        validate();
        validate2();
        if (context.hasError()) return;
        if (!checkEndDate()) return;

        StringBuilder sql = new StringBuilder();
        //摘要日期，月日（09.01）

        string mdDate = hidEndDate.Value.Substring(4, 2) + "." + hidEndDate.Value.Substring(6, 2);
        //当前日期，年月日（2013.9.1）

        string currentDate = string.Format("{0:yyyy.MM.dd}", DateTime.Now);
        //会计周期，取月份（09）

        string striperiod = currentDate.Substring(5, 2);
        //当前年份的第一天

        string stryear = currentDate.Substring(0, 4) + "-01-01";
        //选择导入的数据库名称
        string sqlExportToYongYou = "ufdata_306_" + currentDate.Substring(0, 4) + "..gl_accvouch";
        //总金额，借方金额
        double totalMoney = 0;

        DataTable data = SPHelper.callPSQuery(context, "QueryDiscountOutComfindReport", txtBeginDate.Text, txtEndDate.Text, selCalling.SelectedValue,
           selCorp.SelectedValue, selDepart.SelectedValue, selBalUint.SelectedValue, selType.SelectedValue);
 

        int dataRowsCount = data.Rows.Count;
        if (dataRowsCount <= 0)
        {
            context.AddMessage(string.Format("查询结果为空，不能导出优惠商户转账财务凭证"));
            return;
        }

        if (data.Rows.Count > 0)
        {
            sql.Append("Begin ");
            sql.Append("declare @maxinoId int;");
            sql.Append("select @maxinoId=ISNULL(MAX(ISNULL(INO_ID,0)),0) + 1 from " + sqlExportToYongYou + " where csign='付' and iperiod =" + striperiod + " and dbill_date >= '" + stryear + "'");
            sql.Append(";");
            for (int i = 0; i < data.Rows.Count; i++)
            {
                sql.Append("insert into " + sqlExportToYongYou + "(");
                sql.Append("IPERIOD,"); //会计期间
                sql.Append("CSIGN,");   //凭证类别字

                sql.Append("ISIGNSEQ,"); //凭证类别排序号

                sql.Append("INO_ID,"); //凭证编号
                sql.Append("INID,"); //行号
                sql.Append("DBILL_DATE,"); //制单日期
                sql.Append("IDOC,"); //附单据数
                sql.Append("CBILL,"); //制单人

                sql.Append("IBOOK,"); //记账标志
                sql.Append("CDIGEST,"); //摘要
                sql.Append("CCODE,"); //科目编码
                sql.Append("MC,"); //贷方金额
                sql.Append("DT_DATE,"); //票号发生日期
                sql.Append("CITEM_ID,"); //项目编码
                sql.Append("CITEM_CLASS,"); //项目大类编码
                sql.Append("CCODE_EQUAL,"); //对方科目编码
                sql.Append("DOUTBILLDATE,"); //外部凭证制单日期
                sql.Append("BVOUCHEDIT,"); //凭证是否可修改

                sql.Append("BVALUEEDIT,"); //分录数值是否可修改
                sql.Append("BCODEEDIT,");//分录科目是否可修改

                sql.Append("BPCSEDIT,");//分录往来项是否可修改

                sql.Append("BDEPTEDIT,");//分录部门是否可修改

                sql.Append("BITEMEDIT)");//分录项目是否可修改

                sql.Append("values(");
                sql.Append(striperiod).Append(",");//会计期间
                sql.Append("'" + dropSignType.SelectedItem.Text + "'").Append(",");//凭证类别字

                sql.Append(dropSignType.SelectedValue).Append(",");//凭证类别排序号

                sql.Append("@maxinoId").Append(",");//凭证编号
                sql.Append(i + 1).Append(",");//行号
                sql.Append("'" + currentDate + "'").Append(",");//制单日期
                sql.Append(-1).Append(",");//附单据数
                sql.Append("'" + context.s_UserName + "'").Append(",");//制单人

                sql.Append(0).Append(",");//记账标志
                sql.Append("'结算" + mdDate + " " + currentDate + "'").Append(",");//摘要
                sql.Append("'" + dropcCodeD.SelectedValue + "'").Append(",");//科目编码贷方  
                sql.Append(data.Rows[i]["转账金额"]).Append(",");//贷方金额
                sql.Append("'" + currentDate + "'").Append(",");//票号发生日期
                sql.Append("'" + dropcItemId.SelectedValue + "'").Append(",");//项目编码
                sql.Append("'" + dropcItemClass.SelectedValue + "'").Append(",");//项目大类编码
                sql.Append("'" + dropcCodeJ.SelectedValue + "'").Append(",");//对方科目编码
                sql.Append("'" + currentDate + "'").Append(","); //外部凭证制单日期
                sql.Append(1).Append(",");
                sql.Append(1).Append(",");
                sql.Append(1).Append(",");
                sql.Append(1).Append(",");
                sql.Append(1).Append(",");
                sql.Append(1).Append(")");
                sql.Append(";");
                totalMoney += Convert.ToDouble(data.Rows[i]["转账金额"]);
            }

            sql.Append("insert into " + sqlExportToYongYou + "(");
            sql.Append("IPERIOD,"); //会计期间
            sql.Append("CSIGN,");   //凭证类别字

            sql.Append("ISIGNSEQ,"); //凭证类别排序号

            sql.Append("INO_ID,"); //凭证编号
            sql.Append("INID,"); //行号
            sql.Append("DBILL_DATE,"); //制单日期
            sql.Append("IDOC,"); //附单据数
            sql.Append("CBILL,"); //制单人

            sql.Append("IBOOK,"); //记账标志
            sql.Append("CDIGEST,"); //摘要
            sql.Append("CCODE,"); //科目编码
            sql.Append("MD,"); //借方金额
            sql.Append("DT_DATE,"); //票号发生日期
            sql.Append("CSUP_ID,"); //供应商编码

            sql.Append("CCODE_EQUAL,"); //对方科目编码
            sql.Append("DOUTBILLDATE,"); //外部凭证制单日期
            sql.Append("BVOUCHEDIT,"); //凭证是否可修改

            sql.Append("BVALUEEDIT,"); //分录数值是否可修改
            sql.Append("BCODEEDIT,");//分录科目是否可修改

            sql.Append("BPCSEDIT,");//分录往来项是否可修改

            sql.Append("BDEPTEDIT,");//分录部门是否可修改

            sql.Append("BITEMEDIT)");//分录项目是否可修改

            sql.Append("values(");
            sql.Append(striperiod).Append(",");//会计期间
            sql.Append("'" + dropSignType.SelectedItem.Text + "'").Append(",");//凭证类别字

            sql.Append(dropSignType.SelectedValue).Append(",");//凭证类别排序号

            sql.Append("@maxinoId").Append(",");//凭证编号
            sql.Append(dataRowsCount + 1).Append(",");//行号
            sql.Append("'" + currentDate + "'").Append(",");//制单日期
            sql.Append(-1).Append(",");//附单据数
            sql.Append("'" + context.s_UserName + "'").Append(",");//制单人

            sql.Append(0).Append(",");//记账标志
            sql.Append("'结算" + mdDate + " " + currentDate + "'").Append(",");//摘要
            sql.Append("'" + dropcCodeJ.SelectedValue + "'").Append(",");//科目编码借方  
            sql.Append(totalMoney).Append(",");//借方金额
            sql.Append("'" + currentDate + "'").Append(",");//票号发生日期
            sql.Append("'" + dropcSupId.SelectedValue + "'").Append(",");//供应商编码

            sql.Append("'" + dropcCodeD.SelectedValue + "'").Append(",");//对方科目编码
            sql.Append("'" + currentDate + "'").Append(","); //外部凭证制单日期
            sql.Append(1).Append(",");
            sql.Append(1).Append(",");
            sql.Append(1).Append(",");
            sql.Append(1).Append(",");
            sql.Append(1).Append(",");
            sql.Append(1).Append(")");
            sql.Append(";");
            sql.Append("END");
        }

        //记录商户日报sql文件导出台账表并导出sql文件
        context.DBOpen("StorePro");
        context.AddField("P_REPORTDATE").Value = hidEndDate.Value;
        context.AddField("P_REPORTTYPE").Value = '1';//和商户转账日报区分开
        context.AddField("P_USETAG").Value = '1';
        bool ok = false;
        ok = context.ExecuteSP("SP_FI_INSERTEXPORTSQL");
        if (ok)
        {
            Response.Clear();
            Response.Buffer = false;
            Response.ContentType = "application/octet-stream";
            Response.AppendHeader("content-disposition", "attachment;filename= FinancePZ" + hidEndDate.Value + ".sql;");
            Response.Write(sql.ToString());
            Response.Flush();
            Response.End();
        }
        else
        {
            context.AddError("记录商户日报sql文件导出台账表失败");
            return;
        }
    }

    protected void btnExportXML_Click(object sender, EventArgs e)
    {

        DataTable dataFi = SPHelper.callPSQuery(context, "QueryDiscountOutFiApprovalBank", selCalling.SelectedValue,
            selCorp.SelectedValue, selDepart.SelectedValue, selBalUint.SelectedValue,
           txtBeginDate.Text, txtEndDate.Text, selType.SelectedValue);
        if (dataFi != null && dataFi.Rows.Count != 0)
        {
            ExportToExcel(dataFi);
        }
       

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
            System.Web.HttpContext.Current.Response.AddHeader("Content-Disposition", string.Format("attachment; filename=batchDiscountTransfer.xls"));
            System.Web.HttpContext.Current.Response.BinaryWrite(data);
            #endregion
        }

        //excel.WriteToFile();
    }
}