using System;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using PDO.Financial;
using TDO.BalanceParameter;
using System.Web;
using System.IO;
using NPOI.HSSF.UserModel;

// 商户转账日报
public partial class ASP_Financial_FI_EOC_DAILY_REPORT_NEW : Master.ExportMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期


            txtFromDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");

            UserCardHelper.resetData(gvResult, null);

            return;
        }

    }

    private double totalCharges = 0;      //转账金额
    private double totalREFUNDMENT = 0;      //退货金额

    private double totalFinfee = 0;  // 实结算金额 
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            totalCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[4]));
            totalFinfee += Convert.ToDouble(GetTableCellValue(e.Row.Cells[10]));
            totalREFUNDMENT += Convert.ToDouble(GetTableCellValue(e.Row.Cells[9]));
            if ((e.Row.Cells[5].Text.Trim().Equals(".00")))
            {
                e.Row.Cells[5].Text = "0";
            }

        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[4].Text = totalCharges.ToString("n");
            e.Row.Cells[9].Text = totalREFUNDMENT.ToString("n");
            e.Row.Cells[10].Text = totalFinfee.ToString("n");
        }

        //6:REMARK 7:PURPOSETYPE 8:BankChannelCode
        e.Row.Cells[6].Attributes["class"] = "Hide";
        e.Row.Cells[7].Attributes["class"] = "Hide";
        e.Row.Cells[8].Attributes["class"] = "Hide";
    }

    private string GetTableCellValue(TableCell cell)
    {
        string s = cell.Text.Trim();
        if (s == "&nbsp;" || s == "")
            return "0";
        return s;
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

    //验证凭证制作数据录入
    private void validate2()
    {
        //判断凭证日期是否为同一天

        if (txtFromDate.Text != txtToDate.Text)
        {
            context.AddError("查询日期不是同一天，凭证导出必须为日结");
        }

        ////对财务转账类型进行非空检验

        //if (selTrans.SelectedValue == "")
        //{
        //    context.AddError("请先选择财务转账类型", selTrans);
        //}
    }

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;
        if (!checkEndDate()) return;
        hidBeginDate.Value = txtFromDate.Text.ToString().Trim();
        hidEndDate.Value = txtToDate.Text.ToString().Trim();

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "TD_EOC_DAILY_REPORT_NEW";
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        pdo.var3 = selTrans.SelectedValue;
        //pdo.var4 = context.s_Area;//归属区域

        StoreProScene storePro = new StoreProScene();

        DataTable data = storePro.Execute(context, pdo);

        hidNo.Value = pdo.var9;

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        UserCardHelper.resetData(gvResult, data);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            if (selTrans.SelectedValue == "5")//财务张家港转账
            {
                ExportGridViewForZJG(gvResult);
            }
            else
            {
                //隐藏REMARK、PURPOSETYPE列

                gvResult.HeaderRow.Cells[6].Visible = false;
                gvResult.HeaderRow.Cells[7].Visible = false;
                foreach (GridViewRow gvr in gvResult.Rows)
                {
                    gvr.Cells[6].Visible = false;
                    gvr.Cells[7].Visible = false;
                }
                gvResult.FooterRow.Cells[6].Visible = false;
                gvResult.FooterRow.Cells[7].Visible = false;

                ExportGridView(gvResult);
            }
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }

    protected void btnExportPayFile_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            if (selTrans.SelectedValue == "0")
            {
                ExportToFile(gvResult, "农行转账支付文件_" + hidNo.Value + ".txt");
            }

            if (selTrans.SelectedValue == "4")
            {
                ExportToFile(gvResult, "交行转账支付文件_" + hidNo.Value + ".plz");
            }
            else
            {
                context.AddError("只能导出农行、交行转账文件");
            }
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
    }

    protected void btnExportXML_Click(object sender, EventArgs e)
    {

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "TD_EOC_DAILY_REPORTFiApprovalBank";
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        pdo.var3 = selTrans.SelectedValue;
        StoreProScene storePro = new StoreProScene();

        DataTable data = storePro.Execute(context, pdo);

        if (data != null && data.Rows.Count != 0)
        {
            //苏州苏汽龙捷汽车服务有限公司 该公司付款用途项置空 modify by jiangbb 2015-09-08 SZCIC-XQ-20150812-001
            foreach (DataRow item in data.Rows)
            {
                if (item[2].ToString() == "苏州苏汽龙捷汽车服务有限公司")
                {
                    item[9] = "";
                }
            }
            ExportToExcel(data);
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
            System.Web.HttpContext.Current.Response.AddHeader("Content-Disposition", string.Format("attachment; filename=batchTransfer.xls"));
            System.Web.HttpContext.Current.Response.BinaryWrite(data);
            #endregion
        }

        //excel.WriteToFile();
    }

    protected void ExportToFile(GridView gv, string filename)
    {
        Response.Clear();
        Response.Buffer = true;
        Response.Charset = "GB2312";
        Response.ContentType = "application/vnd.text"; Response.ContentType = "text/plain";
        Response.AddHeader("Content-disposition", "attachment; filename=" + Server.UrlEncode(filename));
        Response.ContentEncoding = System.Text.Encoding.GetEncoding("GB2312");

        if (selTrans.SelectedValue == "0")
        {
            foreach (GridViewRow gvr in gv.Rows)
            {
                Response.Write("2@"); // 业务种类
                Response.Write(DateTime.Now.ToString("yyyy-MM-dd")); // 导出日期
                Response.Write("@553301040004064@"); // 苏信农行帐号
                string money = gvr.Cells[4].Text.Trim(); // 以元为单位

                Response.Write(money.PadLeft(11));
                string temp = gvr.Cells[0].Text.Trim();
                Response.Write("@" + temp + "".PadRight(50 - Validation.strLen(temp)));
                Response.Write("@" + "".PadRight(24));
                temp = gvr.Cells[3].Text.Trim().PadRight(34);
                Response.Write("@" + temp);
                temp = gvr.Cells[2].Text.Trim();
                Response.Write("@" + temp + "".PadRight(50 - Validation.strLen(temp)) + "@");
                temp = gvr.Cells[5].Text.Trim(); // 以元为单位

                Response.Write(temp.PadLeft(18));
                temp = gvr.Cells[1].Text.Trim();
                Response.Write("@" + temp + "".PadRight(20 - Validation.strLen(temp)));
                Response.Write("\r\n");
            }
        }

        if (selTrans.SelectedValue == "4")
        {
            decimal totalmoney = 0;
            foreach (GridViewRow gvr in gv.Rows)
            {
                totalmoney = totalmoney + Convert.ToDecimal(gvr.Cells[4].Text) * 100;
            }
            Response.Write("<?xml version=\"1.0\" encoding=\"GBK\"?>");
            Response.Write("\r\n");
            Response.Write("<batchPayFile>");
            Response.Write("\r\n");
            Response.Write("<summary date=\"" + txtToDate.Text.Trim() + "\" currencyType=\"CNY\" sumMoney=\"" + Convert.ToInt32(totalmoney) + "\" sumRecords=\"" + gv.Rows.Count + "\"/>");
            Response.Write("\r\n");
            Response.Write("<payList>");
            Response.Write("\r\n");

            int irows;
            foreach (GridViewRow gvr in gv.Rows)
            {
                irows = gvr.RowIndex + 1;

                //包含“交行”或“交通银行”时，isOtherBank为0，不包含是为1
                string bankname = gvr.Cells[0].Text.Trim();
                int tag = bankname.IndexOf("交行") + bankname.IndexOf("交通银行");
                string isOtherBank;

                if (tag > -2)
                {
                    isOtherBank = "0";
                }
                else
                {
                    isOtherBank = "1";
                }

                //if (gvr.Cells[1].Text.Trim().Substring(0,2) == "交")
                //{
                Response.Write("<record date=\"" + txtToDate.Text.Trim() + "\" currencyType=\"CNY\" orderNo=\"" + irows + "\" erpNo=\"\" payAccNo=\"325661000018010179037\" payAccNme=\"苏州市城市信息化建设有限公司（充值户）\" payOpenBank=\"交通银行苏州吴中支行\" isOtherBank=\"" + isOtherBank + "\" isSameCity=\"1\" recAccNo=\"" + gvr.Cells[3].Text.Trim() + "\" recAccNme=\"" + gvr.Cells[2].Text.Trim() + "\" recOpenBank=\"" + gvr.Cells[0].Text.Trim() + "\" money=\"" + Convert.ToInt32(Convert.ToDecimal(gvr.Cells[4].Text) * 100) + "\" usage=\"" + gvr.Cells[1].Text.Trim() + ", " + gvr.Cells[5].Text.Trim() + "\" comment=\"\" preflg=\"0\" predate=\"\"/>");
                //}
                //else
                //{
                //    Response.Write("<record date=\"" + txtToDate.Text.Trim() + "\" currencyType=\"CNY\" orderNo=\"" + irows + "\" erpNo=\"\" payAccNo=\"325661000018010179037\" payAccNme=\"苏州市城市信息化建设有限公司（充值户）\" payOpenBank=\"交通银行苏州吴中支行\" isOtherBank=\"" + isOtherBank + "\" isSameCity=\"1\" recAccNo=\"" + gvr.Cells[3].Text.Trim() + "\" recAccNme=\"" + gvr.Cells[2].Text.Trim() + "\" recOpenBank=\"" + gvr.Cells[0].Text.Trim() + "\" money=\"" + Convert.ToInt32(Convert.ToDecimal(gvr.Cells[4].Text) * 100) + "\" usage=\"" + gvr.Cells[1].Text.Trim() + ", " + gvr.Cells[5].Text.Trim() + "\" comment=\"\" preflg=\"0\" predate=\"\"/>");
                //}
                Response.Write("\r\n");
            }
            Response.Write("</payList>");
            Response.Write("\r\n");
            Response.Write("</batchPayFile>");
            Response.Write("\r\n");
        }

        Response.Flush();
        Response.End();
    }

    protected void ExportToXML(GridView gv, string filename)
    {
        Response.Clear();
        Response.Buffer = true;
        Response.Charset = "UTF-8";
        Response.ContentType = "application/vnd.text"; Response.ContentType = "text/plain";
        Response.AddHeader("Content-disposition", "attachment; filename=" + Server.UrlEncode(filename));
        Response.ContentEncoding = System.Text.Encoding.GetEncoding("UTF-8");

        decimal totalmoney = 0;
        foreach (GridViewRow gvr in gv.Rows)
        {
            totalmoney = totalmoney + Convert.ToDecimal(gvr.Cells[4].Text);
        }
        Response.Write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
        Response.Write("\r\n");
        Response.Write("<batchPayFile>");
        Response.Write("\r\n");
        Response.Write("<summary payerAcNo=\"7066602001120105002221\" currency=\"CNY\" sumAmount=\"" + totalmoney + "\" sumRecords=\"" + gv.Rows.Count + "\"/>");
        Response.Write("\r\n");
        Response.Write("<payList>");
        Response.Write("\r\n");

        int irows;
        foreach (GridViewRow gvr in gv.Rows)
        {
            irows = gvr.RowIndex + 1;
            string payeeCifType = gvr.Cells[7].Text.Trim().Replace("&nbsp;", "");
            string bankChannelCode = gvr.Cells[8].Text.Trim().Replace("&nbsp;", "");

            string channel = bankChannelCode;

            if (string.IsNullOrEmpty(bankChannelCode))
            {
                channel = "3";
                if (gvr.Cells[0].Text.Trim().IndexOf("苏州银行") != -1)
                {
                    channel = "0";
                }
            }

            string remark = "";
            if (gvr.Cells[5].Text.Trim() != "" && gvr.Cells[1].Text.Trim() != "")
            {
                remark = "编码" + gvr.Cells[1].Text.Trim() + "佣金" + gvr.Cells[5].Text.Trim();//changed by youyue
            }
            else
            {
                remark = gvr.Cells[1].Text.Trim() + gvr.Cells[5].Text.Trim();//changed by youyue 
            }

            Response.Write("<record recordNo=\"" + irows + "\" payeeAcNo=\"" + gvr.Cells[3].Text.Trim() + "\" payeeAcName=\"" + gvr.Cells[2].Text.Trim() + "\" payeeBankName=\"" + gvr.Cells[0].Text.Trim() + "\" payeeBankId=\"\" payeeCifType=\"" + payeeCifType + "\" amount=\"" + Convert.ToDecimal(gvr.Cells[4].Text) + "\" channel=\"" + channel + "\" remark=\"" + remark + "\" erpNo=\"\"/>");

            Response.Write("\r\n");
        }
        Response.Write("</payList>");
        Response.Write("\r\n");
        Response.Write("</batchPayFile>");
        Response.Write("\r\n");
        Response.Flush();
        Response.End();
    }
    /// <summary>
    /// 转出银行为张家港的导出表格

    /// </summary>
    /// <param name="gv"></param>
    protected void ExportGridViewForZJG(GridView gv)
    {
        Response.Clear();
        Response.Buffer = true;
        Response.Charset = "GB2312";
        Response.AppendHeader("Content-Disposition", "attachment;filename=export.xls");

        Response.ContentEncoding = System.Text.Encoding.GetEncoding("GB2312");
        Response.ContentType = "application/ms-excel";//设置输出文件类型为excel文件。 
        Response.Write("<meta http-equiv=Content-Type content=\"text/html; charset=GB2312\">");

        Response.Write("</table>");
        Response.Write("<table cellpadding='0' cellspacing='0' border='1' style='BORDER-COLLAPSE: collapse;width:800px;vnd.ms-excel.numberformat:@;' bordercolor='black'>");
        Response.Write("<tr><td>总笔数：</td><td>" + gv.Rows.Count.ToString() + "</td><td colspan='3'></td></tr>");
        Response.Write("<tr><td>总金额：</td><td>" + gv.FooterRow.Cells[4].Text + "</td><td colspan='3'></td></tr>");
        Response.Write("<tr align='center'><td>序号</td><td>转入户名</td><td>转入账号</td><td>金额</td><td>商户代码</td></tr>");

        for (int i = 0; i < gv.Rows.Count; i++)
        {
            GridViewRow gvr = gv.Rows[i];
            Response.Write("<tr>");
            Response.Write("<td align='center'>" + (i + 1).ToString() + "</td>"); // 序号
            Response.Write("<td>" + gv.Rows[i].Cells[2].Text + "</td>"); // 转入户名
            Response.Write("<td>" + gv.Rows[i].Cells[3].Text + "</td>"); // 转入账号
            Response.Write("<td>" + gv.Rows[i].Cells[4].Text + "</td>"); // 金额
            Response.Write("<td>" + gv.Rows[i].Cells[1].Text + "</td>"); // 商户代码
            Response.Write("</tr>");
        }

        Response.Flush();
        Response.End();
    }

    /// <summary>
    /// 导出商户转账日报到sql文件中

    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnExportSql_Click(object sender, EventArgs e)
    {
        if (hidEndDate.Value == "")
        {
            context.AddError("导出凭证前请先查询商户转账信息。");
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

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "TD_EOC_DAILY_REPORT";
        pdo.var1 = hidBeginDate.Value;
        pdo.var2 = hidEndDate.Value;
        pdo.var3 = selTrans.SelectedValue;
        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);
        int dataRowsCount = data.Rows.Count;
        if (dataRowsCount <= 0)
        {
            context.AddMessage(string.Format("查询结果为空，不能导出商户日报财务凭证"));
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
                sql.Append(data.Rows[i]["转帐金额"]).Append(",");//贷方金额
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
                totalMoney += Convert.ToDouble(data.Rows[i]["转帐金额"]);
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
        context.AddField("P_REPORTTYPE").Value = '0';
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
}
