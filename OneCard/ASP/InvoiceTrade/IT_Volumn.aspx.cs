using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using PDO.UserCard;
using Master;
using Common;

public partial class ASP_InvoiceTrade_IT_Volumn : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        labDept.Text = context.s_DepartName;

        queryVolumne();

    }

    private void queryVolumne()
    {
        SP_UC_QueryPDO pdo = new SP_UC_QueryPDO();

        pdo.funcCode = "InvoiceVolumnQuery";
        pdo.var1 = context.s_DepartID;

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);
        if (data == null || data.Rows.Count == 0)
        {
            txtVolumn.Text = "";
            labUpdateStaff.Text = "";
            labUpdateTime.Text = "";
        }
        else
        {
            Object[] obj = data.Rows[0].ItemArray;
            txtVolumn.Text = "" + obj[0];
            labUpdateStaff.Text = "" + obj[1];
            labUpdateTime.Text = "" + obj[2];
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        txtVolumn.Text = txtVolumn.Text.Trim();
        if (Validation.strLen(txtVolumn.Text) != 12)
        {
            context.AddError("卷号长度必须是12位");
            return;
        }

        SP_UC_QueryPDO pdo = new SP_UC_QueryPDO();

        pdo.funcCode = "InvoiceVolumnSave";
        pdo.var1 = context.s_DepartID;
        pdo.var2 = txtVolumn.Text;
        pdo.var3 = context.s_UserID;

        StoreProScene storePro = new StoreProScene();
        storePro.Execute(context, pdo);

        context.AddMessage("卷号设置成功");

        queryVolumne();
    }
}
