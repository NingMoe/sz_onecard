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
using PDO.InvoiceTrade;

public partial class ASP_InvoiceTrade_IT_BatchVoid : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            //注册JS事件
            txtBeginNo.Attributes.Add("OnKeyup", "javascript:return Change();");
            txtEndNo.Attributes.Add("OnKeyup", "javascript:return Change();");
            labVolumnNo.Text = InvoiceHelper.queryVolumne(context); ;
        }

    }

    protected void InvoiceVoid_Click(object sender, EventArgs e)
    {
        //数据校验
        if (!InvoiceValidate())
            return;

        ////调用发票作废存储过程

        //SP_IT_VoidPDO pdo = new SP_IT_VoidPDO();
        //pdo.beginNo = txtBeginNo.Text.Trim();
        //pdo.endNo = txtEndNo.Text.Trim();

        //bool ok = TMStorePModule.Excute(context, pdo);
        //if (ok)
        //{
        //    AddMessage("M200003001");
        //}

    }

    //数据校验
    public bool InvoiceValidate()
    {
        InvoiceValidator iv = new InvoiceValidator(context);
        return iv.validateIdRange(txtBeginNo, txtEndNo);
    }
}
