using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;

public partial class ASP_InvoiceTrade_IT_VoidRollback : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void InvoiceVoidRollback_Click(object sender, EventArgs e)
    {
        if (!InvoiceValidate())
            return;

        if (!VolumenoValidate())
            return;

        //发票作废存储过程　
        context.SPOpen();

        context.AddField("p_INVOICENO").Value = txtNo.Text.Trim();
        context.AddField("p_VOLUMENO").Value = txtVolumeno.Text.Trim();
        context.AddField("p_TRADEID", "string", "Output", "16");

        bool ok = context.ExecuteSP("SP_IT_VoidRollback");
        if (ok)
        {
            AddMessage("发票作废返销成功");
        }

    }

    private bool VolumenoValidate()
    {
        if (txtVolumeno.Text == "")
            context.AddError("发票卷号不能为空");
        else if (!Validation.isNum(txtVolumeno.Text))
            context.AddError("发票卷号不是数字");
        else if (Validation.strLen(txtVolumeno.Text) != 12)
            context.AddError("发票卷号不是12位");

        return !(context.hasError());
    }

    public bool InvoiceValidate()
    {
        InvoiceValidator iv = new InvoiceValidator(context);
        return iv.validateId(txtNo);
    }
}
