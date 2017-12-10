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
using PDO.InvoiceTrade;
using TM;

public partial class ASP_InvoiceTrade_IT_Freeze : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            txtBeginNo.Attributes.Add("onblur", "javascript:return Change();");
            txtCount.Attributes.Add("onkeyup", "javascript:return txtCountControlChange();");
            txtCount.Attributes.Add("onblur", "javascript:return txtCountControlChange();");
        }
    }

    protected void InvoiceStockIn_Click(object sender, EventArgs e)
    {
        if (!InvoiceValidate())
            return;

        //调用发票入库存储过程
        SP_IT_FreezePDO pdo = new SP_IT_FreezePDO();
        pdo.beginNo = txtBeginNo.Text.Trim();
        pdo.endNo = hidEndNo.Value.Trim();
        pdo.volumeno = this.txtVolumnNo.Text.Trim();

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M200EE1001:发票冻结成功");
        }

    }

    public bool InvoiceValidate()
    {
        if (Validation.strLen(txtVolumnNo.Text) != 12)
        {
            context.AddError("A200001991:发票代码长度必须是12位", txtVolumnNo);
            return false;
        }

        if (Validation.isNum(this.txtCount.Text) == false)
        {
            context.AddError("A200001992:发票份数必须是数字", txtCount);
            return false;
        }

        InvoiceValidator iv = new InvoiceValidator(context);
        return iv.validateIdRange(txtBeginNo, hidEndNo.Value.Trim());
    }
}
