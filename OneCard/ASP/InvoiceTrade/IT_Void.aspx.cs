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

using PDO.InvoiceTrade;

using TM;
using Common;
using TDO.InvoiceTrade;

public partial class ASP_InvoiceTrade_IT_Void : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
           
            divRead.Visible = false;
            CommonHelper.SetInvoicedValues(context, txtVolumn, reverseInvoiceId);
        }
    }



    public bool InvoiceValidate()
    {
        InvoiceValidator iv = new InvoiceValidator(context);
        return iv.validateId(reverseInvoiceId);
    }

    protected void InvoiceVoid_Click(object sender, EventArgs e)
    {
        if (btnNext.Visible)
        {
            context.AddError("请先点击下一步，再进行作废");
            return;
        }
        if (!InvoiceValidate())
            return;
        
        //发票作废存储过程　
        SP_IT_VoidPDO pdo = new SP_IT_VoidPDO();
        pdo.volno = txtVolumn.Text.Trim();
        pdo.invoiceNo = reverseInvoiceId.Text.Trim();
        pdo.reason = ddlReason.SelectedValue;
        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            btnNext.Visible = true;
            reverseInvoiceId.ReadOnly = false;
            txtVolumn.ReadOnly = false;
            ddlReason.Enabled = true;
            divRead.Visible = false;
            btnNew.Visible = false;
           
            btnVoid.Visible = false;
            AddMessage("M200003001");
        }
    }


    protected void Next_Click(object sender, EventArgs e)
    {
        string invoiceno=reverseInvoiceId.Text.Trim();
        string volumeno=txtVolumn.Text.Trim();
        if (!Validation.isNum(volumeno) || Validation.strLen(volumeno) != 12)
        {
            context.AddError("发票代码只能为数字且为12位", txtVolumn);

        }
        if (!Validation.isNum(invoiceno) || Validation.strLen(invoiceno) != 8)
        {
            context.AddError("发票代码只能为数字且为8位", reverseInvoiceId);

        }
        if (context.hasError())
        {
            return;
        }
        string sql = "";
        if (CommonHelper.IsDepartLead(context))
        {
            sql = string.Format("select t.usestatecode,t.allotstatecode from TL_R_INVOICE t where t.invoiceno='{0}' and t.volumeno='{1}' and t.allotdepartno='{2}'",invoiceno,volumeno,context.s_DepartID);
        }
        else
        {
            sql = string.Format("select t.usestatecode,t.allotstatecode from TL_R_INVOICE t where t.invoiceno='{0}' and t.volumeno='{1}' and t.allotstaffno='{2}'", invoiceno, volumeno, context.s_UserID);
        }
        TMTableModule tmTMTableModule = new TMTableModule();

        TL_R_INVOICETDO tdoTF_F_INVOICETDO = new TL_R_INVOICETDO();
        DataTable data = tmTMTableModule.selByPKDataTable(context, tdoTF_F_INVOICETDO, null, sql, 0);
        if (data.Rows.Count == 1)
        {
            if (ddlReason.SelectedValue == "有效开票")
            {
                if (data.Rows[0][0].ToString() == "01" && data.Rows[0][1].ToString() == "02")
                {
                    btnNext.Visible = false;
                    reverseInvoiceId.ReadOnly = true;
                    txtVolumn.ReadOnly = true;
                    ddlReason.Enabled = false;
                    btnVoid.Visible = true;
                    btnNew.Visible = true;
                    divRead.Visible = true;
                    Read_Click(sender, e);
                }
                else
                {
                    context.AddMessage("发票不是有效开票状态，请检查");
                    return;
                }

            }
            else
            {
                btnNext.Visible = false;
                reverseInvoiceId.ReadOnly = true;
                txtVolumn.ReadOnly = true;
                ddlReason.Enabled = false;
                btnVoid.Visible = true;
                btnNew.Visible = true;
            }
        }
        else
        {
            context.AddMessage("发票未开或不存在或不属于当前员工或所在部门");
            return;
        }

    }

    //读发票
    protected void Read_Click(object sender, EventArgs e)
    {
        ClearInvoice();
        hidReaded.Value = "false";
        txtCode.Text = txtVolumn.Text.Trim();
        if (Validation.strLen(txtVolumn.Text) != 12)
        {
            context.AddError("卷号长度必须是12位");
            return;
        }

        //读取并设置发票内容
        TMTableModule tmTMTableModule = new TMTableModule();
        TF_F_INVOICETDO tdoTF_F_INVOICETDO = new TF_F_INVOICETDO();

        string strSql = "SELECT f.PROJ1,f.FEE1,f.PROJ2,f.FEE2,f.PROJ3,f.FEE3,f.PROJ4,f.FEE4,f.PROJ5,f.FEE5,f.TRADEFEE, "
            + "f.PAYMAN,f.TAXNO,f.REMARK,f.PayeeName "
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
            txtNote.Text = getData(row[13]).Replace("&nbsp;", " ").Replace("<br>", "\n"); ;
            txtTotal.Text = ConvertNumChn.ConvertSum(getMoneyString(getData(row[10])));
            txtStaff.Text = context.s_UserName;
            txtDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtPayee.Text = getData(row[14]); ;

            txtNote.Text = txtNote.Text;
            txtInvoiceId.Text = reverseInvoiceId.Text.Trim();
            hidNo.Value = reverseInvoiceId.Text.Trim();
            hidVolumn.Value = txtVolumn.Text;
            hidReaded.Value = "true";
            EnableInput();
        }
        else
        {
            context.AddMessage("发票未开或不存在");
            return;
        }
    }

    protected void New_Click(object sender, EventArgs e)
    {
        ClearInvoice();
        btnNext.Visible = true;
        reverseInvoiceId.ReadOnly = false;
        txtVolumn.ReadOnly = false;
        ddlReason.Enabled = true;
        btnVoid.Visible = false;
        btnNew.Visible = false;
        divRead.Visible = false;
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

        return (Convert.ToDouble(str) / 100).ToString("0.00");
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
        txtPayee.Text = "";

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
        txtNote.Enabled = false;
    }

    private void EnableInput()
    {
        txtInvoiceId.Enabled = true;
        txtNote.Enabled = true;
    }
}
