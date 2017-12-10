using System;
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;
using PDO.Financial;
using Master;
using Common;
using TDO.BalanceParameter;

// 商户转账日报
public partial class ASP_FI_EOC_DAILY_REPORT_CA : Master.ExportMaster
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

    private double totalCharges = 0;
    private double totalComfees = 0;
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            totalCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[4]));
            totalComfees += Convert.ToDouble(GetTableCellValue(e.Row.Cells[5]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[4].Text = totalCharges.ToString("n");
            e.Row.Cells[5].Text = totalComfees.ToString("n");
        }

        //6:REMARK 7:PURPOSETYPE
        e.Row.Cells[6].Attributes["class"] = "Hide";
        e.Row.Cells[7].Attributes["class"] = "Hide";
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

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        if (!checkEndDate()) return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "TD_EOC_DAILY_REPORT_CA";
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        pdo.var3 = selTrans.SelectedValue;

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
        if (gvResult.Rows.Count > 0)
        {
            ExportToXML(gvResult, hidNo.Value + ".txt");
        }
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
                Response.Write("<record date=\"" + txtToDate.Text.Trim() + "\" currencyType=\"CNY\" orderNo=\"" + irows + "\" erpNo=\"\" payAccNo=\"325661000018010179037\" payAccNme=\"苏州市民卡有限公司（充值户）\" payOpenBank=\"交通银行苏州吴中支行\" isOtherBank=\"" + isOtherBank + "\" isSameCity=\"1\" recAccNo=\"" + gvr.Cells[3].Text.Trim() + "\" recAccNme=\"" + gvr.Cells[2].Text.Trim() + "\" recOpenBank=\"" + gvr.Cells[0].Text.Trim() + "\" money=\"" + Convert.ToInt32(Convert.ToDecimal(gvr.Cells[4].Text) * 100) + "\" usage=\"" + gvr.Cells[1].Text.Trim() + ", " + gvr.Cells[5].Text.Trim() + "\" comment=\"\" preflg=\"0\" predate=\"\"/>");
                //}
                //else
                //{
                //    Response.Write("<record date=\"" + txtToDate.Text.Trim() + "\" currencyType=\"CNY\" orderNo=\"" + irows + "\" erpNo=\"\" payAccNo=\"325661000018010179037\" payAccNme=\"苏州市民卡有限公司（充值户）\" payOpenBank=\"交通银行苏州吴中支行\" isOtherBank=\"" + isOtherBank + "\" isSameCity=\"1\" recAccNo=\"" + gvr.Cells[3].Text.Trim() + "\" recAccNme=\"" + gvr.Cells[2].Text.Trim() + "\" recOpenBank=\"" + gvr.Cells[0].Text.Trim() + "\" money=\"" + Convert.ToInt32(Convert.ToDecimal(gvr.Cells[4].Text) * 100) + "\" usage=\"" + gvr.Cells[1].Text.Trim() + ", " + gvr.Cells[5].Text.Trim() + "\" comment=\"\" preflg=\"0\" predate=\"\"/>");
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
            string payeeCifType = gvr.Cells[7].Text.Trim();

            string channel = "3";
            if (gvr.Cells[0].Text.Trim().IndexOf("苏州银行") != -1)
            {
                channel = "0";
            }

            string remark = "";
            if (gvr.Cells[5].Text.Trim() != "" && gvr.Cells[1].Text.Trim() != "")
            {
                remark = gvr.Cells[5].Text.Trim() + "，" + gvr.Cells[1].Text.Trim();
            }
            else
            {
                remark = gvr.Cells[5].Text.Trim()  + gvr.Cells[1].Text.Trim();
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

}
