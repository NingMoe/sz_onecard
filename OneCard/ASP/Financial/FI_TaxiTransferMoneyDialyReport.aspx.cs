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
using PDO.Financial;
using Master;
using Common;
using TDO.BalanceParameter;

public partial class ASP_Financial_FI_TaxiTransferMoneyDialyReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtDate.Text = DateTime.Now.AddHours(-12).ToString("yyyy-MM-dd");
            if (DateTime.Now.AddHours(-12).Date == DateTime.Today)
            {
                radTime.SelectedIndex = 0;
            }
            else if (DateTime.Now.AddHours(-12).Date < DateTime.Today)
            {
                radTime.SelectedIndex = 1;
            }
        }
    }

    private double totalCharges = 0;
    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            totalCharges += Convert.ToDouble(e.Row.Cells[3].Text);
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[3].Text = totalCharges.ToString("n");
        }
    }
    // 查询输入校验处理
    private void validate()
    {
        string strDate = txtDate.Text.Trim();
        if (strDate == "")
        {
            context.AddError("请输入日期");
        }
        else
        {
            try
            {
                DateTime.ParseExact(strDate, "yyyy-MM-dd", null);
            }
            catch
            {
                context.AddError("日期格式必须为yyyy-MM-dd");
            }
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
            DateTime endDate = DateTime.ParseExact(txtDate.Text.Trim(), "yyyy-MM-dd", null);
            if (endDate.CompareTo(dealDate) > 0)
            {
                context.AddError("出账日期过大，未结算");
                return false;
            }
        }
        return true;
    }

    // 查询
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        validate();
        if (context.hasError()) return;

        if (!checkEndDate()) return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "TAXI_EOC_DAILY_REPORT";
        pdo.var1 = txtDate.Text.Trim().Replace("-", "") + radTime.SelectedValue;
        pdo.var2 = selTrans.SelectedValue;

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);
        hidNo.Value = pdo.var9;

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }

        totalCharges = 0;
        UserCardHelper.resetData(gvResult, data);

        if (selTrans.SelectedValue == "0" && txtDate.Text.Trim().Length != 0)//为农行导出文件拼凑字符如，10.19出租上午
        {
            string date = Convert.ToDateTime(txtDate.Text.Trim()).ToString("MM.dd");

            this.hidDateText.Value = date + "出租" + this.radTime.SelectedItem.Text;
        }
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            if (selTrans.SelectedValue == "3")//财务张家港转账
            {
                ExportGridViewForZJG(gvResult);
            }
            else
            {
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
        if (selTrans.SelectedValue == "2")
        {
            ExportToFile(gvResult, "交行代发工资_" + hidNo.Value + ".plz");
        }
        else
        {
            ExportToFile(gvResult, "代发工资_" + hidNo.Value + ".txt");
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

        if (selTrans.SelectedValue == "2")
        {
            decimal totalmoney = 0;
            foreach (GridViewRow gvr in gv.Rows)
            {
                totalmoney = totalmoney + Convert.ToDecimal(gvr.Cells[3].Text) * 100;
            }
            Response.Write("<?xml version=\"1.0\" encoding=\"GBK\"?>");
            Response.Write("\r\n");
            Response.Write("<batchPayFile>");
            Response.Write("\r\n");
            Response.Write("<summary tranType=\"90\" orderDay=\"\" currencyType=\"CNY\" payMonth=\"" + txtDate.Text.Trim().Replace("-", "").Substring(0, 6) + "\" payAcct=\"325661000018010179037\" sumMoney=\"" + Convert.ToInt32(totalmoney) + "\" sumRecords=\"" + gv.Rows.Count + "\"/>");
            Response.Write("\r\n");
            Response.Write("<payList>");
            Response.Write("\r\n");
            foreach (GridViewRow gvr in gv.Rows)
            {
                Response.Write("<record workNo=\"\" workName=\"" + gvr.Cells[2].Text.Trim() + "\" cardNo=\"" + gvr.Cells[1].Text.Trim() + "\" money=\"" + Convert.ToInt32(Convert.ToDecimal(gvr.Cells[3].Text) * 100) + "\" cardType=\"0\" comment=\"\"/>");
                Response.Write("\r\n");
            }
            Response.Write("</payList>");
            Response.Write("\r\n");
            Response.Write("</batchPayFile>");
            Response.Write("\r\n");
        }
        else if (selTrans.SelectedValue == "0")//农行转账
        {
            for (int i = 0; i < gv.Rows.Count; i++)
            {
                GridViewRow gvr = gv.Rows[i];

                Response.Write((i + 1).ToString() + ","); // 序号
                Response.Write(gvr.Cells[1].Text.Trim() + ","); // 银行账号
                Response.Write(gvr.Cells[2].Text.Trim() + ",");// 姓名
                Response.Write(gvr.Cells[3].Text + ","); // 金额
                Response.Write(this.hidDateText.Value);//10.19出租上午
                Response.Write("\r\n");
            }
        }
        else
        {
            foreach (GridViewRow gvr in gv.Rows)
            {
                string temp = gvr.Cells[1].Text.Trim();
                Response.Write(temp.PadRight(20)); // 银行账号
                string money = "" + Convert.ToInt32(Convert.ToDecimal(gvr.Cells[3].Text) * 100);
                Response.Write(money.PadLeft(16)); // 金额
                temp = gvr.Cells[2].Text.Trim();
                Response.Write(temp + "".PadRight(30 - Validation.strLen(temp)));// 姓名
                Response.Write("\r\n");
            }
        }
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
        Response.Write("<table cellpadding='0' cellspacing='0' border='1' style='BORDER-COLLAPSE: collapse;width:600px;vnd.ms-excel.numberformat:@;' bordercolor='black'>");
        Response.Write("<tr><td>总笔数：</td><td>" + gv.Rows.Count.ToString() + "</td><td colspan='2'></td></tr>");
        Response.Write("<tr><td>总金额：</td><td>" + gv.FooterRow.Cells[3].Text + "</td><td colspan='2'></td></tr>");
        Response.Write("<tr align='center'><td>序号</td><td>姓名</td><td>卡号</td><td>金额</td></tr>");

        for (int i = 0; i < gv.Rows.Count; i++)
        {
            GridViewRow gvr = gv.Rows[i];
            Response.Write("<tr>");
            Response.Write("<td align='center'>" + (i + 1).ToString() + "</td>"); // 序号
            Response.Write("<td>" + gv.Rows[i].Cells[2].Text + "</td>"); // 姓名
            Response.Write("<td>" + gv.Rows[i].Cells[1].Text + "</td>"); // 卡号
            Response.Write("<td>" + gv.Rows[i].Cells[3].Text + "</td>"); // 金额
            Response.Write("</tr>");
        }

        Response.Flush();
        Response.End();
    }
}
