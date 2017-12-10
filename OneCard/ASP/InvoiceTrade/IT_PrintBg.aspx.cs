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
using Common;
using TM;
using Master;
using PDO.InvoiceTrade;
using TDO.InvoiceTrade;

public partial class ASP_InvoiceTrade_IT_PrintBg : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化收款方、纳税人识别号、开票人、开票日期


            txtPayee.Text = "苏州市民卡有限公司";
            txtTaxPayerId.Text = "9132050874558352XW";
            txtStaff.Text = context.s_UserName;
            txtDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

            txtAmount1.Attributes.Add("OnKeyup", "javascript:return Change();");
            txtAmount2.Attributes.Add("OnKeyup", "javascript:return Change();");
            txtAmount3.Attributes.Add("OnKeyup", "javascript:return Change();");
            txtAmount4.Attributes.Add("OnKeyup", "javascript:return Change();");
            txtAmount5.Attributes.Add("OnKeyup", "javascript:return Change();");

            //labVolumnNo.Text = InvoiceHelper.queryVolumne(context);
            //txtCode.Text = labVolumnNo.Text;
            CommonHelper.SetInvoiceValues(context, txtCode, txtInvoiceId);
            //txtInvoiceId.Text = GetNextPiaohao();
            txtInvoiceId.ReadOnly = true;
        }

    }


    protected string GetNextPiaohao()
    {
        string sql = string.Format("SELECT MIN(INVOICENO)  FROM TL_R_INVOICE t WHERE   t.VOLUMENO = '{0}' AND t.USESTATECODE='00' AND t.ALLOTSTATECODE ='01' AND t.ALLOTSTAFFNO='{1}'", InvoiceHelper.queryVolumne(context), context.s_UserID);
        TMTableModule tmTMTableModule = new TMTableModule();
        TL_R_INVOICETDO tdoTL_R_INVOICETDO = new TL_R_INVOICETDO();
        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTL_R_INVOICETDO, null, sql.ToString(), 0);
        if (data != null && data.Rows.Count > 0)
        {
            return data.Rows[0][0].ToString();
        }
        return "";

    }



    protected void btnClear_Click(object sender, EventArgs e)
    {
        hidPrinted.Value = "false";

        btnPrintFaPiao.Text = "打印发票";

        txtPayer.Enabled = true;
        txtInvoiceId.Enabled = true;
        txtProj1.Enabled = true;
        txtProj2.Enabled = true;
        txtProj3.Enabled = true;
        txtProj4.Enabled = true;
        txtProj5.Enabled = true;
        txtAmount1.Enabled = true;
        txtAmount2.Enabled = true;
        txtAmount3.Enabled = true;
        txtAmount4.Enabled = true;
        txtAmount5.Enabled = true;
        txtNote.Enabled = true;

        txtPayer.Text = "";
        txtInvoiceId.Text = "";
        txtProj1.Text = "";
        txtProj2.Text = "";
        txtProj3.Text = "";
        txtProj4.Text = "";
        txtProj5.Text = "";
        txtAmount1.Text = "";
        txtAmount2.Text = "";
        txtAmount3.Text = "";
        txtAmount4.Text = "";
        txtAmount5.Text = "";
        txtNote.Text = "";

        txtTotal.Text = "";
        txtTotal2.Text = "";

        txtStaff.Text = context.s_UserName;
        txtDate.Text = DateTime.Now.ToString("yyyy-MM-dd");

        txtStaff.Enabled = true;
        txtDate.Enabled = true;

        labVolumnNo.Text = InvoiceHelper.queryVolumne(context);
        txtCode.Text = labVolumnNo.Text;

        txtInvoiceId.Text = GetNextPiaohao();
        txtInvoiceId.ReadOnly = true;

    }

    protected void Print_Click(object sender, EventArgs e)
    {
        bool ok = true;//存储过程调用成功

        //数据校验
        if (!InvoiceValidate())
            return;

        //首次打印时，调用开票存储过程
        if (hidPrinted.Value == "false")
        {
            SP_IT_BillingPDO pdo = new SP_IT_BillingPDO();
            pdo.payer = txtPayer.Text.Trim();
            pdo.billNo = txtInvoiceId.Text.Trim();
            pdo.taxNo = txtTaxPayerId.Text.Trim();
            pdo.drawer = txtStaff.Text.Trim();
            pdo.date = DateTime.ParseExact(txtDate.Text.Trim(), "yyyy-MM-dd", null);
            pdo.amount = getAmount();
            pdo.note = getNote();

            pdo.proj1 = txtProj1.Text.Trim();
            if (txtAmount1.Text.Trim() != "")
                pdo.fee1 = getFee(txtAmount1);

            pdo.proj2 = txtProj2.Text.Trim();
            if (txtAmount2.Text.Trim() != "")
                pdo.fee2 = getFee(txtAmount2);

            pdo.proj3 = txtProj3.Text.Trim();
            if (txtAmount3.Text.Trim() != "")
                pdo.fee3 = getFee(txtAmount3);

            pdo.proj4 = txtProj4.Text.Trim();
            if (txtAmount4.Text.Trim() != "")
                pdo.fee4 = getFee(txtAmount4);

            pdo.proj5 = txtProj5.Text.Trim();
            if (txtAmount5.Text.Trim() != "")
                pdo.fee5 = getFee(txtAmount5);

            ok = TMStorePModule.Excute(context, pdo);
            if (ok)
            {
                AddMessage("M200005001");

                //开票成功后，可补打印，不能修改发票内容
                hidPrinted.Value = "true";
                btnPrintFaPiao.Text = "补打印";
                DisableInput();

            }
        }

        if (ok)
        {
            //设置发票数据，并调用打印JS
            InitInvoicePrintControl();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "printPaPiaoScript", "printFaPiao();", true);
        }
    }

    //发票总金额，单位分
    private Decimal getAmount()
    {
        Decimal r = Convert.ToDecimal(getFee(txtAmount1)) + Convert.ToDecimal(getFee(txtAmount2)) + Convert.ToDecimal(getFee(txtAmount3));
        r = r + Convert.ToDecimal(getFee(txtAmount4)) + Convert.ToDecimal(getFee(txtAmount5));
        return r;
    }

    //附注
    private string getNote()
    {
        string s = txtNote.Text.Trim();
        return s.Trim();
    }

    //单个项目金额，单位分
    private int getFee(TextBox tb)
    {
        string s = tb.Text.Trim();
        if (s == "")
            return 0;

        Decimal d = Convert.ToDecimal(s) * 100;
        return (int)d;
    }

    //数据校验
    private bool InvoiceValidate()
    {
        bool b = true;
        //付款方非空
        if (txtPayer.Text.Trim() == "")
        {
            context.AddError("A200004021", txtPayer);
            b = false;
        }

        //发票号校验
        InvoiceValidator iv = new InvoiceValidator(context);
        if (!iv.validateId(txtInvoiceId))
            b = false;

        //发票项目校验
        TextBox[] projs = new TextBox[] { txtProj1, txtProj2, txtProj3, txtProj4, txtProj5 };
        TextBox[] fees = new TextBox[] { txtAmount1, txtAmount2, txtAmount3, txtAmount4, txtAmount5 };
        if (!iv.validateItems(projs, fees))
            b = false;

        //开票人非空
        if (txtStaff.Text.Trim() == "")
        {
            context.AddError("A200004024", txtStaff);
            b = false;
        }

        //开票日期非空
        string strDate = txtDate.Text.Trim();
        if (strDate == "")
        {
            context.AddError("A200004025", txtDate);
            b = false;
        }
        else if (!Validation.isDate(strDate))
        {
            context.AddError("A200004026", txtDate);
            b = false;
        }
        return b;
    }

    //设置发票数据
    private void InitInvoicePrintControl()
    {
        DateTime now = DateTime.ParseExact(txtDate.Text.Trim(), "yyyy-MM-dd", null);
        ptnFaPiao.Year = now.ToString("yyyy");
        ptnFaPiao.Month = now.ToString("MM");
        ptnFaPiao.Day = now.ToString("dd");
        ptnFaPiao.FuKuanFang = txtPayer.Text.Trim();
        ptnFaPiao.ShouKuanFang = txtPayee.Text.Trim();
        ptnFaPiao.NaShuiRen = txtTaxPayerId.Text.Trim();
        ptnFaPiao.PiaoHao = txtInvoiceId.Text.Trim();
        ptnFaPiao.FuKuanFangCode = txtPayCode.Text.Trim();
        ptnFaPiao.JuanHao = labVolumnNo.Text.Trim();

        Decimal i = getAmount();
        ptnFaPiao.JinE = (i / 100).ToString("0.00");

        ptnFaPiao.JinEChina = ConvertNumChn.ConvertSum(ptnFaPiao.JinE);

        ptnFaPiao.KaiPiaoRen = txtStaff.Text;

        ArrayList projs = new ArrayList();
        string[] proj1 = new string[2] { txtProj1.Text.Trim(), getInvoiceFee(txtAmount1.Text.Trim()) };
        string[] proj2 = new string[2] { txtProj2.Text.Trim(), getInvoiceFee(txtAmount2.Text.Trim()) };
        string[] proj3 = new string[2] { txtProj3.Text.Trim(), getInvoiceFee(txtAmount3.Text.Trim()) };
        string[] proj4 = new string[2] { txtProj4.Text.Trim(), getInvoiceFee(txtAmount4.Text.Trim()) };
        string[] proj5 = new string[2] { txtProj5.Text.Trim(), getInvoiceFee(txtAmount5.Text.Trim()) };
        projs.Add(proj1);
        projs.Add(proj2);
        projs.Add(proj3);
        projs.Add(proj4);
        projs.Add(proj5);
        ptnFaPiao.ProjectList = projs;

        ArrayList note = new ArrayList();
        string strNote = txtNote.Text.Trim();
        string[] notes = strNote.Split(new char[] { '\n' });
        for (int k = 0; k < notes.Length; k++)
        {
            note.Add(notes[k]);
        }
        ptnFaPiao.RemarkList = note;
    }

    //转为货币格式
    private string getInvoiceFee(string str)
    {
        if (str == "")
            return "";

        double d = Convert.ToDouble(str);
        return d.ToString("0.00");
    }

    //设置发票内容不可编辑
    private void DisableInput()
    {
        txtPayer.Enabled = false;
        txtInvoiceId.Enabled = false;
        txtProj1.Enabled = false;
        txtProj2.Enabled = false;
        txtProj3.Enabled = false;
        txtProj4.Enabled = false;
        txtProj5.Enabled = false;
        txtAmount1.Enabled = false;
        txtAmount2.Enabled = false;
        txtAmount3.Enabled = false;
        txtAmount4.Enabled = false;
        txtAmount5.Enabled = false;
        txtNote.Enabled = false;
        txtStaff.Enabled = false;
        txtDate.Enabled = false;
    }

}
