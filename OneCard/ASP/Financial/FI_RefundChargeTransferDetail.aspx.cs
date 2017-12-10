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
using System.IO;
using NPOI.HSSF.UserModel;

public partial class ASP_Financial_FI_RefundChargeTransferDetail : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期
            txtFromDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.AddDays(-1).ToString("yyyyMMdd");
        }
    }

    private double totalCharges = 0;
    private double totalrefundCharges = 0;

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (gvResult.ShowFooter && e.Row.RowType == DataControlRowType.DataRow)
        {
            totalCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[4]));
            totalrefundCharges += Convert.ToDouble(GetTableCellValue(e.Row.Cells[5]));
        }
        else if (e.Row.RowType == DataControlRowType.Footer)  //页脚 
        {
            e.Row.Cells[0].Text = "总计";
            e.Row.Cells[4].Text = totalCharges.ToString("n");
            e.Row.Cells[5].Text = totalrefundCharges.ToString("n");
        }
        //7:PURPOSETYPE       
        e.Row.Cells[7].Attributes["class"] = "Hide";
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

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.resetData(gvResult, null);

        validate();
        if (context.hasError()) return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "REFUND_EOC_REPORT";
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);
        hidNo.Value = pdo.var9;

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
            btnPrint.Enabled = false;
        }
        else
        {
            btnPrint.Enabled = true;
        }

        totalCharges = 0;
        UserCardHelper.resetData(gvResult, data);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            //隐藏PURPOSETYPE列
            gvResult.HeaderRow.Cells[7].Visible = false;
            foreach (GridViewRow gvr in gvResult.Rows)
            {
                gvr.Cells[7].Visible = false;
            }
            gvResult.FooterRow.Cells[7].Visible = false;

            ExportGridView(gvResult);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
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
            response.Charset = "UTF-8";
            response.ContentType = "application/vnd-excel";//"application/vnd.ms-excel";
            System.Web.HttpContext.Current.Response.AddHeader("Content-Disposition", string.Format("attachment; filename=batchTransfer.xls"));
            System.Web.HttpContext.Current.Response.BinaryWrite(data);
            #endregion
        }

        //excel.WriteToFile();
    }

    protected void btnExportPayFile_Click(object sender, EventArgs e)
    {
        ExportToFile(gvResult, "转账_" + hidNo.Value + ".txt");
    }

    protected void ExportToFile(GridView gv, string filename)
    {
        Response.Clear();
        Response.Buffer = true;
        Response.Charset = "GB2312";
        Response.ContentType = "application/vnd.text"; Response.ContentType = "text/plain";
        Response.AddHeader("Content-disposition", "attachment; filename=" + Server.UrlEncode(filename));
        Response.ContentEncoding = System.Text.Encoding.GetEncoding("GB2312");

        foreach (GridViewRow gvr in gv.Rows)
        {
            //string temp = gvr.Cells[1].Text.Trim();
            //Response.Write(temp.PadRight(20)); // 银行账号
            //string money = "" + Convert.ToInt32(Convert.ToDecimal(gvr.Cells[3].Text) * 100);
            //Response.Write(money.PadLeft(16)); // 金额
            //temp = gvr.Cells[2].Text.Trim();
            //Response.Write(temp + "".PadRight(30 - Validation.strLen(temp)));// 卡号
            //Response.Write("\r\n");

            Response.Write("2@"); // 业务种类
            Response.Write(DateTime.Now.ToString("yyyy-MM-dd")); // 导出日期
            Response.Write("@553301040004064@"); // 苏信农行帐号
            string money = gvr.Cells[4].Text.Trim(); // 以元为单位
            Response.Write(money.PadLeft(11));
            string temp = gvr.Cells[0].Text.Trim();
            Response.Write("@" + temp + "".PadRight(50 - Validation.strLen(temp)));
            Response.Write("@" + "".PadRight(24));
            temp = gvr.Cells[1].Text.Trim().PadRight(34);
            Response.Write("@" + temp);
            temp = gvr.Cells[2].Text.Trim();
            Response.Write("@" + temp + "".PadRight(50 - Validation.strLen(temp)) + "@");
            temp = gvr.Cells[5].Text.Trim(); // 以元为单位
            Response.Write(temp.PadLeft(18));
            temp = gvr.Cells[3].Text.Trim();
            Response.Write("@" + temp + "".PadRight(20 - Validation.strLen(temp)));
            Response.Write("\r\n");
        }

        Response.Flush();
        Response.End();
    }

    protected void btnExportXML_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
            pdo.funcCode = "REFUND_EOC_REPORT_OUT";
            pdo.var1 = txtFromDate.Text;
            pdo.var2 = txtToDate.Text;
            StoreProScene storePro = new StoreProScene();

            DataTable data = storePro.Execute(context, pdo);

            if (data != null && data.Rows.Count != 0)
            {
                ExportToExcel(data);
            }
            else
            {
                context.AddMessage("需要导出记录为空，不能导出");
            }
            //ExportToXML(gvResult, "转账_" + hidNo.Value + ".txt");
        }
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

            Response.Write("<record recordNo=\"" + irows + "\" payeeAcNo=\"" + gvr.Cells[1].Text.Trim() + "\" payeeAcName=\"" + gvr.Cells[2].Text.Trim() + "\" payeeBankName=\"" + gvr.Cells[0].Text.Trim() + "\" payeeBankId=\"\" payeeCifType=\"" + payeeCifType + "\" amount=\"" + Convert.ToDecimal(gvr.Cells[4].Text) + "\" channel=\"" + channel + "\" remark=\"\" erpNo=\"\"/>");

            Response.Write("\r\n");
        }
        Response.Write("</payList>");
        Response.Write("\r\n");
        Response.Write("</batchPayFile>");
        Response.Write("\r\n");
        Response.Flush();
        Response.End();
    }
}
