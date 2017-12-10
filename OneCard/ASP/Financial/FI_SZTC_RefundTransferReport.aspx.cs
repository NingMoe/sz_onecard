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
using TM;
using TDO.UserManager;
using System.Collections.Generic;

public partial class ASP_Financial_FI_SZTC_RefundTransferReport : Master.ExportMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化日期


            txtFromDate.Text = DateTime.Today.AddDays(-8).ToString("yyyyMMdd");
            txtToDate.Text = DateTime.Today.AddDays(-7).ToString("yyyyMMdd");

            //初始化部门


            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_INSIDEDEPARTTDO tdoTD_M_INSIDEDEPARTIn = new TD_M_INSIDEDEPARTTDO();
            TD_M_INSIDEDEPARTTDO[] tdoTD_M_INSIDEDEPARTOutArr = (TD_M_INSIDEDEPARTTDO[])tmTMTableModule.selByPKArr(context, tdoTD_M_INSIDEDEPARTIn, typeof(TD_M_INSIDEDEPARTTDO), null, " WHERE USETAG = '1' ORDER BY DEPARTNO");
            ControlDeal.SelectBoxFill(selDept.Items, tdoTD_M_INSIDEDEPARTOutArr, "DEPARTNAME", "DEPARTNO", true);
            InitStaffList(context.s_DepartID);

            UserCardHelper.resetData(gvResult, new DataTable());
        }
    }

    private void InitStaffList(string deptNo)
    {
        if (deptNo == "")
        {

            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DIMMISSIONTAG_USEFUL", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
        else
        {
            TD_M_INSIDESTAFFTDO tdoTD_M_INSIDESTAFFIn = new TD_M_INSIDESTAFFTDO();
            tdoTD_M_INSIDESTAFFIn.DEPARTNO = deptNo;
            tdoTD_M_INSIDESTAFFIn.DIMISSIONTAG = "1";

            TD_M_INSIDESTAFFTDO[] tdoTD_M_INSIDESTAFFOutArr = (TD_M_INSIDESTAFFTDO[])tm.selByPKArr(context, tdoTD_M_INSIDESTAFFIn, typeof(TD_M_INSIDESTAFFTDO), null, "TD_M_INSIDESTAFF_DEPT", null);
            ControlDeal.SelectBoxFill(selStaff.Items, tdoTD_M_INSIDESTAFFOutArr, "STAFFNAME", "STAFFNO", true);
        }
    }

    protected void selDept_Changed(object sender, EventArgs e)
    {
        InitStaffList(selDept.SelectedValue);
    }

    protected void gvResult_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow || e.Row.RowType == DataControlRowType.Header)
        {
            e.Row.Cells[0].Visible = false; //开户行简写

            e.Row.Cells[15].Visible = false;//收款人账户类型

        }

        if (!CommonHelper.HasOperPower(context))
        {
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Cells[3].Text = CommonHelper.GetCustName(e.Row.Cells[3].Text);
                e.Row.Cells[9].Text = CommonHelper.GetPaperNo(e.Row.Cells[9].Text);
                e.Row.Cells[10].Text = CommonHelper.GetCustPhone(e.Row.Cells[10].Text);
            }
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

    // 查询处理
    protected void btnQuery_Click(object sender, EventArgs e)
    {
        UserCardHelper.resetData(gvResult, null);

        validate();
        if (context.hasError()) return;

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "SZTC_REFUNDTRANSFERREPORT";
        pdo.var1 = txtFromDate.Text;
        pdo.var2 = txtToDate.Text;
        pdo.var3 = selDept.SelectedValue;
        pdo.var4 = selStaff.SelectedValue;

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

        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "PAPERNO", "CUSTPHONE" }));

        UserCardHelper.resetData(gvResult, data);
    }

    protected void btnExport_Click(object sender, EventArgs e)
    {
        if (gvResult.Rows.Count > 0)
        {
            //隐藏PURPOSETYPE列


            gvResult.HeaderRow.Cells[0].Visible = false;
            gvResult.HeaderRow.Cells[15].Visible = false;
            foreach (GridViewRow gvr in gvResult.Rows)
            {
                gvr.Cells[0].Visible = false;
                gvr.Cells[15].Visible = false;
            }
            gvResult.FooterRow.Cells[0].Visible = false;
            gvResult.FooterRow.Cells[15].Visible = false;

            ExportGridView(gvResult);
        }
        else
        {
            context.AddMessage("查询结果为空，不能导出");
        }
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
            string money = gvr.Cells[6].Text.Trim(); // 以元为单位


            Response.Write(money.PadLeft(11));
            string temp = gvr.Cells[0].Text.Trim();
            Response.Write("@" + temp + "".PadRight(50 - Validation.strLen(temp)));
            Response.Write("@" + "".PadRight(24));
            temp = gvr.Cells[2].Text.Trim().PadRight(34);
            Response.Write("@" + temp);
            temp = gvr.Cells[3].Text.Trim();
            Response.Write("@" + temp + "".PadRight(50 - Validation.strLen(temp)) + "@");
            temp = gvr.Cells[6].Text.Trim(); // 以元为单位


            Response.Write(temp.PadLeft(18));
            temp = gvr.Cells[7].Text.Trim();
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
            ExportToXML(gvResult, "转账_" + hidNo.Value + ".txt");
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
            totalmoney = totalmoney + Convert.ToDecimal(gvr.Cells[6].Text);
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
            string payeeCifType = gvr.Cells[15].Text.Trim();

            string channel = "3";
            if (gvr.Cells[0].Text.Trim().IndexOf("苏州银行") != -1)
            {
                channel = "0";
            }

            Response.Write("<record recordNo=\"" + irows + "\" payeeAcNo=\"" + gvr.Cells[2].Text.Trim() + "\" payeeAcName=\"" + gvr.Cells[3].Text.Trim() + "\" payeeBankName=\"" + gvr.Cells[0].Text.Trim() + "\" payeeBankId=\"\" payeeCifType=\"" + payeeCifType + "\" amount=\"" + Convert.ToDecimal(gvr.Cells[6].Text) + "\" channel=\"" + channel + "\" remark=\"\" erpNo=\"\"/>");

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
