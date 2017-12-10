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
using TDO.CardManager;
using System.Collections.Generic;

public partial class ASP_InvoiceTrade_IT_PrintHd : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //初始化收款方、纳税人识别号、开票人、开票时间


            txtPayer.Text = "";
            txtPayee.Text = "苏州市民卡有限公司";
            txtTaxPayerId.Text = "9132050874558352XW";
            txtStaff.Text = context.s_UserName;
            txtDate.Text = DateTime.Now.ToString("yyyy-MM-dd");


            //lbljuanhao.Text = InvoiceHelper.queryVolumne(context);
            //txtInvoiceId.Text = GetNextPiaohao();
            

            //初始化发票项目


            string sqlPROJ = "select * from TD_M_INVOICEPROJ where ISFREE=0";
            TMTableModule tmTMTableModule = new TMTableModule();
            TD_M_INVOICEPROJTDO ddoTD_M_INVOICEPROJTDOIn = new TD_M_INVOICEPROJTDO();
            TD_M_INVOICEPROJTDO[] ddoTD_M_INVOICEPROJTDOOutArr = (TD_M_INVOICEPROJTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_INVOICEPROJTDOIn, typeof(TD_M_INVOICEPROJTDO), null,sqlPROJ);
            FillDropDownList(selProj5, ddoTD_M_INVOICEPROJTDOOutArr, "INVOICEPROJNAME", "INVOICEPROJNAME");
            txtAmount5.Attributes.Add("OnKeyup", "javascript:return Change();");
            CommonHelper.SetInvoiceValues(context, txtCode, txtInvoiceId);
            txtCode.ReadOnly = true;
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


    private void FillDropDownList(DropDownList control, DDOBase[] data, string label, string value)
    {
        foreach (DDOBase ddoDDOBase in data)
        {
            control.Items.Add(new ListItem(ddoDDOBase.GetString(label), ddoDDOBase.GetString(value)));
        }
    }

    protected void btnSearch_Click(object sender, EventArgs e)
    {
        //判断记录流水号

        if (txtTradeID.Text.Trim().Replace("'", "") == "")
        {
            context.AddError("IE000H0001");
            return;
        }
        SP_IT_QueryByIDPDO pdo = new SP_IT_QueryByIDPDO("SP_IT_QueryByID");
        pdo.ID = txtTradeID.Text.Trim().Replace("'", "");
        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);
        //string sql = string.Format("select  c.custname,t.supplymoney,t.operatetime,t.cardno,f.CUSTRECTYPECODE from TF_B_TRADEFEE t inner join TF_F_CARDREC f on t.cardno=f.cardno left join TF_F_CUSTOMERREC c on t.cardno=c.cardno where ID='{0}' and t.TradeTypeCode='02'", txtTradeID.Text.Trim().Replace("'", ""));
        //TMTableModule tmTMTableModule = new TMTableModule();

        //TB_F_CUSTOMERRECTDO tdoTB_F_CUSTOMERRECTDO = new TB_F_CUSTOMERRECTDO();
        //DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTB_F_CUSTOMERRECTDO, null, sql.ToString(), 0);
        if (data != null && data.Rows.Count > 0)
        {

            //add by jiangbb 解密 2012-06-27
            CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

            //省卡记名属性根据数据库里判断 modify by jiangbb
            if (data.Rows[0][3].ToString().Length == 19)
            {
                hidIsJiMing.Value = data.Rows[0][4].ToString();
            }
            else
            {
                //判断是否记名卡
                CommonHelper.readCardJiMingState(context, data.Rows[0][3].ToString(), hidIsJiMing);
            }
            //超过90天的不能在打印

            //if (Convert.ToInt32(data.Rows[0][2]) >= Convert.ToInt32(DateTime.Now.ToString("yyyyMMdd"))-90&&  Convert.ToInt32(data.Rows[0][2]) <= Convert.ToInt32(DateTime.Now.ToString("yyyyMMdd")))
            //{
            //    context.AddError("IE00000000");
            //    return;
            //}
            if (hidIsJiMing.Value == "0")
            {
                txtPayer.Text = "不记名卡";
            }
            else
            {
                txtPayer.Text = data.Rows[0][0].ToString();
            }
            txtAmount5.Text = (Convert.ToDecimal(data.Rows[0][1]) / 100).ToString("0.00");
            txtTotal2.Text = (Convert.ToDecimal(data.Rows[0][1]) / 100).ToString("0.00");
            txtTotal.Text = Common.ConvertNumChn.ConvertSum((Convert.ToDecimal(data.Rows[0][1]) / 100).ToString("0.00"));
            txtNote.Text = data.Rows[0][3].ToString();
        }
        else
        {
            context.AddError("记录不存在，请检查");
        }
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        hidPrinted.Value = "false";

        btnPrintFaPiao.Text = "打印发票";

        txtPayer.Enabled = true;
        txtInvoiceId.Enabled = true;

        selProj5.Enabled = true;

        txtAmount5.Enabled = true;
        txtNote.Enabled = true;

        txtPayer.Text = "个人";
        txtInvoiceId.Text = "";

        txtAmount5.Text = "";
        txtNote.Text = "";

        txtTotal.Text = "";
        txtTotal2.Text = "";

        txtCode.Text = InvoiceHelper.queryVolumne(context);


        CommonHelper.SetInvoiceValues(context, txtCode, txtInvoiceId);
        txtCode.ReadOnly = true;
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
            SP_IT_Billing_HDPDO pdo = new SP_IT_Billing_HDPDO();
            pdo.ID = txtTradeID.Text.Trim().Replace("'", "");
            pdo.volno = txtCode.Text.Trim();
            pdo.payer = txtPayer.Text.Trim();
            pdo.billNo = txtInvoiceId.Text.Trim();
            pdo.taxNo = txtTaxPayerId.Text.Trim();
            pdo.drawer = txtStaff.Text.Trim();
            pdo.date = DateTime.ParseExact(txtDate.Text.Trim(), "yyyy-MM-dd", null);
            pdo.amount = getAmount();
            pdo.note = txtNote.Text.Trim();//.Replace(" ", "&nbsp;").Replace("\n", "<br>");
            pdo.proj5 = selProj5.SelectedValue;
            pdo.isFree = "0";
            if (txtAmount5.Text.Trim() != "")
                pdo.fee5 = getFee(txtAmount5);

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
        return Convert.ToDecimal(txtAmount5.Text.Trim()) * 100;
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
        WebControl[] projs = new WebControl[1] { selProj5 };
        WebControl[] fees = new WebControl[1] { txtAmount5 };
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
        DateTime now = DateTime.Now;
        ptnFaPiao.Year = now.ToString("yyyy");
        ptnFaPiao.Month = now.ToString("MM");
        ptnFaPiao.Day = now.ToString("dd");
        ptnFaPiao.FuKuanFang = txtPayer.Text.Trim();
        ptnFaPiao.ShouKuanFang = txtPayee.Text.Trim();
        ptnFaPiao.NaShuiRen = txtTaxPayerId.Text.Trim();
        ptnFaPiao.PiaoHao = txtInvoiceId.Text.Trim();
        ptnFaPiao.FuKuanFangCode = "";
        ptnFaPiao.JuanHao = txtCode.Text.Trim();
        Decimal i = getAmount();
        ptnFaPiao.JinE = (i / 100).ToString("0.00");

        ptnFaPiao.JinEChina = ConvertNumChn.ConvertSum(ptnFaPiao.JinE);

        ptnFaPiao.KaiPiaoRen = context.s_UserName;

        ArrayList projs = new ArrayList();
       
        string[] proj5 = new string[4] { selProj5.SelectedValue,getInvoiceFee(txtAmount5.Text.Trim()),"1", getInvoiceFee(txtAmount5.Text.Trim()) };
     
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

    //设置发票内容不可编辑
    private void DisableInput()
    {
        txtPayer.Enabled = false;
        txtInvoiceId.Enabled = false;

        selProj5.Enabled = false;

        txtAmount5.Enabled = false;
        txtNote.Enabled = false;
    }

}
