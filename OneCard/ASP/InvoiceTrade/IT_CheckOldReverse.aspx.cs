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
using TM;
using Common;
using TDO.InvoiceTrade;

public partial class ASP_InvoiceTrade_IT_CheckOldReverse : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        CommonHelper.SetInvoiceValues(context, txtCode, null);
        //txtCode.Text = txtVolumn.Text;
        //txtInvoiceId.ReadOnly = true;
        lblValidateCode.Text = InvoiceHelper.AutoGetValidateCode();

        //初始化苏信开户行
        string sqlSZBank = "select * from TD_M_SZBANK where USETAG='1'";
        DataTable dt = tm.selByPKDataTable(context, sqlSZBank, 0);
        FillDropDownListBANK(selSZBank, dt);
        //指定收款方名称
        selSZBank_SelectedIndexChanged(sender, e);

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

    //读发票
    protected void Read_Click(object sender, EventArgs e)
    {
        ClearInvoice();
        hidPrinted.Value = "false";
        hidReaded.Value = "false";
        btnPrintFaPiao.Text = "打印发票";
        lblValidateCode.Text = InvoiceHelper.AutoGetValidateCode();
        txtVolumn.Text = txtVolumn.Text.Trim();
        if (Validation.strLen(txtVolumn.Text) != 12)
        {
            context.AddError("发票代码长度必须是12位");
            return;
        }

        //红冲发票号非空、数字、长度校验
        if (!ReverseValidate())
            return;

        //红冲发票号状态及开票时间校验

        if (!checkInvoiceNo())
            return;

        //读取并设置发票内容
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_F_INVOICETDO tdoTF_F_INVOICETDO = new TF_F_INVOICETDO();

        string strSql = "SELECT f.PROJ1,f.FEE1,f.PROJ2,f.FEE2,f.PROJ3,f.FEE3,f.PROJ4,f.FEE4,f.PROJ5,f.FEE5,f.TRADEFEE, "
            + "f.PAYMAN,f.TAXNO,f.REMARK,f.bankname,f.bankaccount,f.payeeName,f.CallingName "
            + "FROM TF_F_INVOICE f "
            + "WHERE f.INVOICENO='" + reverseInvoiceId.Text.Trim() + "' "
            + "AND f.VOLUMENO = '" + txtVolumn.Text + "' ";

        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTF_F_INVOICETDO, null, strSql, 0);
        if (data.Rows.Count == 1)
        {
            Object[] row = data.Rows[0].ItemArray;
            txtProj1.Text = getData(row[0]);
            txtAmount1.Text = getMoneyString(getData(row[1]));
            txtProj2.Text = getData(row[2]);
            txtAmount2.Text = getMoneyString(getData(row[3]));
            txtProj3.Text = getData(row[4]);
            txtAmount3.Text = getMoneyString(getData(row[5]));
            txtProj4.Text = getData(row[6]);
            txtAmount4.Text = getMoneyString(getData(row[7]));
            txtProj5.Text = getData(row[8]);
            txtAmount5.Text = getMoneyString(getData(row[9]));
            txtTotal2.Text = getMoneyString(getData(row[10]));
            txtPayer.Text = getData(row[11]);
            txtTaxPayerId.Text = getData(row[12]);
            txtNote.Text = getData(row[13]);
            txtTotal.Text = ConvertNumChn.ConvertSum(getMoneyString(getData(row[10])));
            txtStaff.Text = context.s_UserName;
            txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            //txtPayee.Text = "苏州市民卡有限公司";
            if(getData(row[14])!="")
                lblSZBank.Text = getData(row[14]) + ":" + getData(row[15]);
            lblPayeeName.Text = getData(row[16]);
            hidNo.Value = reverseInvoiceId.Text.Trim();
            hidVolumn.Value = txtVolumn.Text;
            hidCallingName.Value = getData(row[17]);
            hidReaded.Value = "true";
            EnableInput();
        }
    }

    //打印
    protected void Print_Click(object sender, EventArgs e)
    {
        //必须先读发票才能打印
        if (hidReaded.Value == "false")
        {
            context.AddError("A200006114");
            return;
        }

        //数据校验
        if (!InvoiceValidate())
            return;

        bool ok = true;//存储过程调用成功

        //首次打印，调用红冲存储过程
        if (hidPrinted.Value == "false")
        {
            context.SPOpen();
            context.AddField("p_oldVolumn").Value = hidVolumn.Value;
            context.AddField("p_oldNo").Value = hidNo.Value;
            context.AddField("p_newNo").Value = txtInvoiceId.Text.Trim();
            context.AddField("p_newVolumn").Value = txtCode.Text.Trim();
            context.AddField("p_drawer").Value = txtStaff.Text.Trim();
            
            context.AddField("p_date", "DateTime").Value = DateTime.ParseExact(txtDate.Text.Trim(), "yyyy-MM-dd", null);
            context.AddField("p_validatecode").Value = lblValidateCode.Text;
            context.AddField("p_payeeName").Value = txtPayee.Text.Trim();
            context.AddField("p_bankName").Value = GetSZBank("BANKNAME");
            context.AddField("p_bankAccount").Value = GetSZBank("BANKCODE");
            ok = context.ExecuteSP("SP_IT_CheckOldReverse");
            if (ok)
            {
                AddMessage("M200006001");

                //红冲成功时，可补打印，不可修改发票内容
                hidPrinted.Value = "true";
                btnPrintFaPiao.Text = "补打印";
                DisableInput();
            }
        }
        if (ok)
        {
            //设置发票数据，调用发票打印JS
            InitInvoicePrintControl();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "printPaPiaoScript", "printFaPiao();", true);
        }
    }

    //红冲发票号状态及开票时间校验
    private bool checkInvoiceNo()
    {
        TMTableModule tmTMTableModule = new TMTableModule();

        TL_R_INVOICETDO tdoTL_R_INVOICETDOIn = new TL_R_INVOICETDO();
        tdoTL_R_INVOICETDOIn.INVOICENO = reverseInvoiceId.Text.Trim();

        TL_R_INVOICETDO[] tdoTL_R_INVOICETDOOutArr = (TL_R_INVOICETDO[])tmTMTableModule.selByPKArr(context, tdoTL_R_INVOICETDOIn, typeof(TL_R_INVOICETDO), null, "TL_R_INVOICETDO_ID", null);

        //红冲发票在库存中不存在
        if (tdoTL_R_INVOICETDOOutArr.Length == 0)
        {
            context.AddError("A200006100", reverseInvoiceId);
            return false;
        }

        //发票领用状态是03作废且发票使用状态是01已开票
        TL_R_INVOICETDO a = tdoTL_R_INVOICETDOOutArr[0];
        if (a.ALLOTSTATECODE != "03" || a.USESTATECODE != "01")
        {
            context.AddError("A200016101", reverseInvoiceId);
            return false;
        }

        //上传未成功的发票
        string sqlSZBank = "select count(*) from TF_B_INVOICE where RSRV2='3' and INVOICENO='{0}' and VOLUMENO ='{1}' and FUNCTIONTYPECODE='L2'";
        sqlSZBank = string.Format(sqlSZBank, reverseInvoiceId.Text.Trim(), txtVolumn.Text.Trim());
        DataTable dt = tm.selByPKDataTable(context, sqlSZBank, 0);
        Object obj = dt.Rows[0].ItemArray[0];
        if (obj == DBNull.Value || Convert.ToInt32(obj) == 0)
        {
            context.AddError("A200016102", reverseInvoiceId);
            return false;
        }

        ////////////////////////////////

        TF_F_INVOICETDO tdoTF_F_INVOICETDOIn = new TF_F_INVOICETDO();
        tdoTF_F_INVOICETDOIn.INVOICENO = reverseInvoiceId.Text.Trim();
        TF_F_INVOICETDO[] tdoTF_F_INVOICETDOOutArr = (TF_F_INVOICETDO[])tmTMTableModule.selByPKArr(context, tdoTF_F_INVOICETDOIn, typeof(TF_F_INVOICETDO), null, "TF_F_INVOICETDO_ID", null);

        if (tdoTF_F_INVOICETDOOutArr.Length == 1)
        {
            TF_F_INVOICETDO b = tdoTF_F_INVOICETDOOutArr[0];

            //检查红冲开票不能再红冲
            if (b.OLDINVOICENO != null && b.OLDINVOICENO != "")
            {
                context.AddError("A200006115", reverseInvoiceId);
                return false;
            }

        }
        return true;
    }

    private string getData(Object obj)
    {
        if (obj == DBNull.Value)
            return "";
        return obj.ToString();
    }

    //转为货币格式，并转为负数
    private string getMoneyString(string str)
    {
        if (str == "")
            return "";

        return (-Convert.ToDouble(str) / 100).ToString("0.00");
    }

    //红冲发票号校验
    private bool ReverseValidate()
    {
        InvoiceValidator iv = new InvoiceValidator(context);
        return iv.validateId(reverseInvoiceId);
    }

    //机打票号校验
    private bool InvoiceValidate()
    {
        InvoiceValidator iv = new InvoiceValidator(context);
        return iv.validateId(txtInvoiceId);
    }

    private void ClearInvoice()
    {
        txtProj1.Text = "";
        txtAmount1.Text = "";
        txtProj2.Text = "";
        txtAmount2.Text = "";
        txtProj3.Text = "";
        txtAmount3.Text = "";
        txtProj4.Text = "";
        txtAmount4.Text = "";
        txtProj5.Text = "";
        txtAmount5.Text = "";
        txtTotal2.Text = "";
        txtPayer.Text = "";
        txtTaxPayerId.Text = "";
        txtNote.Text = "";
        txtTotal.Text = "";
        txtStaff.Text = "";
        txtDate.Text = "";
        txtCode.Text = "";
        txtInvoiceId.Text = "";
        //txtPayee.Text = "";

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
        ptnFaPiao.JuanHao = txtCode.Text.Trim();
        Decimal i = getAmount();
        ptnFaPiao.JinE = (i / 100).ToString("0.00");

        ptnFaPiao.JinEChina = ConvertNumChn.ConvertSum(ptnFaPiao.JinE);

        ptnFaPiao.KaiPiaoRen = context.s_UserName;

        ArrayList projs = new ArrayList();
        string[] proj1 = new string[4] { txtProj1.Text.Trim(), getInvoiceFee(txtAmount1.Text.Trim()), "1", getInvoiceFee(txtAmount1.Text.Trim()) };
        string[] proj2 = new string[4] { txtProj2.Text.Trim(), getInvoiceFee(txtAmount2.Text.Trim()), "1", getInvoiceFee(txtAmount2.Text.Trim()) };
        string[] proj3 = new string[4] { txtProj3.Text.Trim(), getInvoiceFee(txtAmount3.Text.Trim()), "1", getInvoiceFee(txtAmount3.Text.Trim()) };
        string[] proj4 = new string[4] { txtProj4.Text.Trim(), getInvoiceFee(txtAmount4.Text.Trim()), "1", getInvoiceFee(txtAmount4.Text.Trim()) };
        string[] proj5 = new string[4] { txtProj5.Text.Trim(), getInvoiceFee(txtAmount5.Text.Trim()), "1", getInvoiceFee(txtAmount5.Text.Trim()) };
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
        ptnFaPiao.Remark = "原发票代码:" + hidVolumn.Value + ";原发票号码:" + hidNo.Value;
        ptnFaPiao.BankName = GetSZBank("BANKNAME");
        ptnFaPiao.BankAccount = GetSZBank("BANKCODE");
        ptnFaPiao.CallingName = hidCallingName.Value;
        
    }

    //单张发票金额
    private int getFee(TextBox tb)
    {
        string s = tb.Text.Trim();
        if (s == "")
            return 0;

        double d = Convert.ToDouble(s) * 100;
        return (int)d;
    }

    //发票总金额，单位分
    private Decimal getAmount()
    {
        Decimal r = Convert.ToDecimal(getFee(txtAmount1)) + Convert.ToDecimal(getFee(txtAmount2)) + Convert.ToDecimal(getFee(txtAmount3));
        r = r + Convert.ToDecimal(getFee(txtAmount4)) + Convert.ToDecimal(getFee(txtAmount5));
        return r;
    }

    //转成货币格式
    private string getInvoiceFee(string str)
    {
        if (str == "")
            return "";

        double d = Convert.ToDouble(str);
        return d.ToString("0.00");
    }

    private void DisableInput()
    {
        txtInvoiceId.Enabled = false;
        txtCode.Enabled = false;
        txtNote.Enabled = false;
        selSZBank.Enabled = false;
    }

    private void EnableInput()
    {
        txtCode.Enabled = true;
        txtInvoiceId.Enabled = true;
        txtNote.Enabled = true;
        selSZBank.Enabled = true;
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
