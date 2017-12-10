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
using Master;
using TM;
using TDO.InvoiceTrade;
using PDO.InvoiceTrade;

public partial class ASP_InvoiceTrade_IT_PrintJs : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化收款方、纳税人识别号、开票人、开票时间

            txtPayer.Text = "个人";
            txtPayee.Text = "苏州市民卡有限公司";
            txtTaxPayerId.Text = "9132050874558352XW";
            txtStaff.Text = context.s_UserName;
            txtDate.Text = DateTime.Now.ToString("yyyy-MM-dd");


            CommonHelper.SetInvoiceValues(context, txtCode, null);
            //txtCode.ReadOnly = true;
            //txtInvoiceId.ReadOnly = true;

            //初始化苏信开户行
            string sqlSZBank = "select * from TD_M_SZBANK where USETAG='1'";
            DataTable dt = tm.selByPKDataTable(context, sqlSZBank, 0);
            FillDropDownListBANK(selSZBank, dt);
            //指定收款方名称
            selSZBank_SelectedIndexChanged(sender, e);
            //初始化发票项目


            string sqlPROJ="select * from TD_M_INVOICEPROJ where ISFREE=1";
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_INVOICEPROJTDO ddoTD_M_INVOICEPROJTDOIn = new TD_M_INVOICEPROJTDO();
            TD_M_INVOICEPROJTDO[] ddoTD_M_INVOICEPROJTDOOutArr = (TD_M_INVOICEPROJTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_INVOICEPROJTDOIn, typeof(TD_M_INVOICEPROJTDO), null, sqlPROJ);
            FillDropDownList(selProj1, ddoTD_M_INVOICEPROJTDOOutArr, "INVOICEPROJNAME", "INVOICEPROJNAME");
            FillDropDownList(selProj2, ddoTD_M_INVOICEPROJTDOOutArr, "INVOICEPROJNAME", "INVOICEPROJNAME");
            FillDropDownList(selProj3, ddoTD_M_INVOICEPROJTDOOutArr, "INVOICEPROJNAME", "INVOICEPROJNAME");
            FillDropDownList(selProj4, ddoTD_M_INVOICEPROJTDOOutArr, "INVOICEPROJNAME", "INVOICEPROJNAME");
            FillDropDownList(selProj5, ddoTD_M_INVOICEPROJTDOOutArr, "INVOICEPROJNAME", "INVOICEPROJNAME");


            //增加单价和数量 add by youyue 20160407
            txtPrice1.Attributes.Add("OnKeyup", "javascript:return Total();");
            txtPrice2.Attributes.Add("OnKeyup", "javascript:return Total();");
            txtPrice3.Attributes.Add("OnKeyup", "javascript:return Total();");
            txtNum1.Attributes.Add("OnKeyup", "javascript:return Total();");
            txtNum2.Attributes.Add("OnKeyup", "javascript:return Total();");
            txtNum3.Attributes.Add("OnKeyup", "javascript:return Total();");

            //txtAmount1.Attributes.Add("OnKeyup", "javascript:return Change();");
            //txtAmount2.Attributes.Add("OnKeyup", "javascript:return Change();");
            //txtAmount3.Attributes.Add("OnKeyup", "javascript:return Change();");
            //txtAmount4.Attributes.Add("OnKeyup", "javascript:return Change();");
            //txtAmount5.Attributes.Add("OnKeyup", "javascript:return Change();");

            lblValidateCode.Text = InvoiceHelper.AutoGetValidateCode();
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


    private void FillDropDownList(DropDownList control, DDOBase[] data, string label, string value)
    {
        control.Items.Add(new ListItem("---请选择---", ""));
        foreach (DDOBase ddoDDOBase in data)
        {
            control.Items.Add(new ListItem(ddoDDOBase.GetString(label), ddoDDOBase.GetString(value)));
        }
    }
    //苏信开户行
    private void FillDropDownListBANK(DropDownList control, DataTable data)
    {
        control.Items.Add(new ListItem("---请选择---", ""));
        int i = 1;
        int weizhi = 0;
        foreach (DataRow dr in data.Rows)
        {
            control.Items.Add(new ListItem(dr["BANKCODE"].ToString() + ":" + dr["BANKNAME"].ToString(), dr["BANKNAME"].ToString()));
            if (dr["ISDEFAULT"].ToString() == "1")
            {
                weizhi = i;
            }
            i++;
        }
        control.SelectedIndex = weizhi;

    }
    //获取苏信开户行信息
    private string GetSZBank(string str)
    {
        string[] szbanks = selSZBank.Items[selSZBank.SelectedIndex].Text.Split(new char[] { ':' }); ;
        //string[] szbanks = selSZBank.Text.Split(new char[] { ':' });
        string bankname = "";
        string bankcode = "";
        if (szbanks.Length > 1)
        {
            bankname = szbanks[1];
            bankcode = szbanks[0];
        }
        if (str == "BANKNAME")
        {
            return bankname;
        }
        else if (str == "BANKCODE")
        {
            return bankcode;
        }
        else
        {
            return "";
        }
    }
    protected void btnClear_Click(object sender, EventArgs e)
    {
        hidPrinted.Value = "false";

        btnPrintFaPiao.Text = "打印发票";
        txtPayCode.Enabled = true;
        txtPayer.Enabled = true;
        txtInvoiceId.Enabled = true;
        selProj1.Enabled = true;
        selProj2.Enabled = true;
        selProj3.Enabled = true;
        selProj4.Enabled = true;
        selProj5.Enabled = true;
        txtAmount1.Enabled = true;
        txtAmount2.Enabled = true;
        txtAmount3.Enabled = true;
        txtAmount4.Enabled = true;
        txtAmount5.Enabled = true;
        txtNote.Enabled = true;

        txtPayer.Text = "个人";
        txtPayCode.Text = "";
        txtInvoiceId.Text = "";
        selProj1.SelectedValue = "";
        selProj2.SelectedValue = "";
        selProj3.SelectedValue = "";
        selProj4.SelectedValue = "";
        selProj5.SelectedValue = "";
        txtAmount1.Text = "";
        txtAmount2.Text = "";
        txtAmount3.Text = "";
        txtAmount4.Text = "";
        txtAmount5.Text = "";
        txtNote.Text = "";

        txtTotal.Text = "";
        txtTotal2.Text = "";


        txtCode.Text = "";
        txtCode.Enabled = true;
        selSZBank.Enabled = true;
        CommonHelper.SetInvoiceValues(context, txtCode, null);
        //txtCode.ReadOnly = true;
        //txtInvoiceId.ReadOnly = true;
        lblValidateCode.Text = InvoiceHelper.AutoGetValidateCode();

        txtPrice1.Text = "";
        txtPrice2.Text = "";
        txtPrice3.Text = "";
        txtPrice4.Text = "";
        txtPrice5.Text = "";
        txtNum1.Text = "";
        txtNum2.Text = "";
        txtNum3.Text = "";
        txtNum4.Text = "";
        txtNum5.Text = "";
    }

    protected void Print_Click(object sender, EventArgs e)
    {
        bool ok = true;//存储过程调用成功

        //数据校验
        if (!InvoiceValidate())
            return;

        //附注行数不能超过4行
        string[] notes = txtNote.Text.Split(new char[] { '\n' });
        if (notes.Length > 4)
        {
            context.AddError("附注行数不能超过4行");
            return;
        }
        //首次打印时，调用开票存储过程

        if (hidPrinted.Value == "false")
        {
           
            SP_IT_BillingPDO pdo = new SP_IT_BillingPDO();
            pdo.volno = txtCode.Text.Trim();
            pdo.isFree = "1";
            pdo.payer = txtPayer.Text.Trim();
            pdo.billNo = txtInvoiceId.Text.Trim();
            pdo.payeeName=txtPayee.Text.Trim();
            pdo.taxNo = txtTaxPayerId.Text.Trim();
            pdo.drawer = txtStaff.Text.Trim();
            pdo.date = DateTime.ParseExact(txtDate.Text.Trim(), "yyyy-MM-dd", null);
            pdo.amount = getAmount();
            pdo.note = txtNote.Text.Trim();//.Replace(" ", "&nbsp;").Replace("\n", "<br>");

            pdo.proj1 = selProj1.SelectedValue;
            if (txtAmount1.Text.Trim() != "")
                pdo.fee1 = getFee(txtAmount1);

            pdo.proj2 = selProj2.SelectedValue;
            if (txtAmount2.Text.Trim() != "")
                pdo.fee2 = getFee(txtAmount2);

            pdo.proj3 = selProj3.SelectedValue;
            if (txtAmount3.Text.Trim() != "")
                pdo.fee3 = getFee(txtAmount3);

            pdo.proj4 = selProj4.SelectedValue;
            if (txtAmount4.Text.Trim() != "")
                pdo.fee4 = getFee(txtAmount4);

            pdo.proj5 = selProj5.SelectedValue;
            if (txtAmount5.Text.Trim() != "")
                pdo.fee5 = getFee(txtAmount5);

            pdo.callingCode = selCalling.SelectedValue;
            pdo.callingName = selCalling.Items[selCalling.SelectedIndex].Text;
            //验证码
            pdo.validatecode = lblValidateCode.Text;
            pdo.bankName = GetSZBank("BANKNAME");
            pdo.bankAccount = GetSZBank("BANKCODE");
            ok = TMStorePModule.Excute(context, pdo);
            if (ok)
            {
                AddMessage("M200005001");

                //开票成功时，可以补打印，不能修改

                hidPrinted.Value = "true";
                btnPrintFaPiao.Text = "补打印";
                DisableInput();
            }
        }
        if (ok)
        {
            //设置发票数据，调用打印JS
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

    //单个项目金额，单位分
    private int getFee(TextBox tb)
    {
        string s = tb.Text.Trim();
        if (s == "")
            return 0;

        Decimal d = Convert.ToDecimal(s) * 100;
        return (int)d;
    }

    //转为货币格式
    private string getInvoiceFee(string str)
    {
        if (str == "")
            return "";

        double d = Convert.ToDouble(str);
        return d.ToString("0.00");
    }

    //数据校验
    public bool InvoiceValidate()
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
        WebControl[] projs = new WebControl[5] { selProj1, selProj2, selProj3, selProj4, selProj5 };
        WebControl[] fees = new WebControl[5] { txtAmount1, txtAmount2, txtAmount3, txtAmount4, txtAmount5 };

        WebControl[] prices = new WebControl[3] { txtPrice1, txtPrice2, txtPrice3 };
        WebControl[] nums = new WebControl[3] { txtNum1, txtNum2, txtNum3 };

        if (!iv.validateItems(projs, fees))
            b = false;

        //新增验证单价和数量  add by youyue 20160407
        if (!iv.validateItems2(prices, nums))
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
        ptnFaPiao.JuanHao = txtCode.Text.Trim();
        Decimal i = getAmount();
        ptnFaPiao.JinE = (i / 100).ToString("0.00");

        ptnFaPiao.JinEChina = ConvertNumChn.ConvertSum(ptnFaPiao.JinE);

        ptnFaPiao.KaiPiaoRen = context.s_UserName;

        ArrayList projs = new ArrayList();
        string[] proj1 = new string[4] { selProj1.SelectedValue, getInvoiceFee(txtPrice1.Text.Trim()), txtNum1.Text.Trim(), getInvoiceFee(txtAmount1.Text.Trim()) };
        string[] proj2 = new string[4] { selProj2.SelectedValue, getInvoiceFee(txtPrice2.Text.Trim()), txtNum2.Text.Trim(), getInvoiceFee(txtAmount2.Text.Trim()) };
        string[] proj3 = new string[4] { selProj3.SelectedValue, getInvoiceFee(txtPrice3.Text.Trim()), txtNum3.Text.Trim(), getInvoiceFee(txtAmount3.Text.Trim()) };
        string[] proj4 = new string[4] { selProj4.SelectedValue, getInvoiceFee(txtPrice4.Text.Trim()), txtNum4.Text.Trim(), getInvoiceFee(txtAmount4.Text.Trim()) };
        string[] proj5 = new string[4] { selProj5.SelectedValue, getInvoiceFee(txtPrice5.Text.Trim()), txtNum5.Text.Trim(), getInvoiceFee(txtAmount5.Text.Trim()) };
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
        ptnFaPiao.ValidateCode = lblValidateCode.Text;
        ptnFaPiao.BankName = GetSZBank("BANKNAME");
        ptnFaPiao.BankAccount = GetSZBank("BANKCODE");
        ptnFaPiao.CallingName = selCalling.Items[selCalling.SelectedIndex].Text;
    }

    //设置发票内容不可编辑
    private void DisableInput()
    {
        txtPayer.Enabled = false;
        txtInvoiceId.Enabled = false;
        selProj1.Enabled = false;
        selProj2.Enabled = false;
        selProj3.Enabled = false;
        selProj4.Enabled = false;
        selProj5.Enabled = false;
        txtAmount1.Enabled = false;
        txtAmount2.Enabled = false;
        txtAmount3.Enabled = false;
        txtAmount4.Enabled = false;
        txtAmount5.Enabled = false;
        txtNote.Enabled = false;
        selSZBank.Enabled = false;
        txtCode.Enabled = false;
        txtPayCode.Enabled = false;

    }
    protected void selSZBank_SelectedIndexChanged(object sender, EventArgs e)
    {
        // Common.Log.Info(GetSZBank("BANKNAME"), "AppLog");
        if (selSZBank.SelectedValue != "")
        {
            string sqlSZBank = "select payeename from TD_M_SZBANK where bankname='" + selSZBank.SelectedValue + "'";
            DataTable dt = tm.selByPKDataTable(context, sqlSZBank, 0);
            if (dt.Rows.Count > 0)
            {
                txtPayee.Text = dt.Rows[0]["payeename"].ToString();
            }
        }
        else
        {
            txtPayee.Text = "";
        }


    }
}
