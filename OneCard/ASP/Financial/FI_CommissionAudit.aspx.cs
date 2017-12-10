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

public partial class ASP_Financial_FI_CommissionAudit : Master.Master
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            btnBilling.Enabled = false;
            btnWithdraw.Enabled = false;
        }
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        if (!DataValidate())
            return;

        UserCardHelper.resetData(gvResult, null);

        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "GET_AUDIT_DATA";
        pdo.var3 = context.s_UserID;
        pdo.var4 = txtNo.Text.Trim();

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        string auditState = pdo.var8;

        if (data == null || data.Rows.Count == 0)
        {
            AddMessage("N005030001: 查询结果为空");
        }
        else
        {
            UserCardHelper.resetData(gvResult, data);

            if (auditState == "0")//未审核
            {
                txtState.Text = "未审核";
                btnBilling.Enabled = true;
                btnWithdraw.Enabled = false;
            }
            else if (auditState == "1")//已审核
            {
                txtState.Text = "已审核";
                btnBilling.Enabled = false;
                btnWithdraw.Enabled = true;
            }
            else if (auditState == "2")//已回退
            {
                txtState.Text = "已回退";
                btnBilling.Enabled = false;
                btnWithdraw.Enabled = false;
            }
            else
            {
                txtState.Text = "";
                btnBilling.Enabled = false;
                btnWithdraw.Enabled = false;
            }
        }
    }

    protected void btnBilling_Click(object sender, EventArgs e)
    {
        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "AUDIT_CONFIRM";
        pdo.var3 = context.s_UserID;
        pdo.var4 = txtNo.Text.Trim();

        StoreProScene storePro = new StoreProScene();
        DataTable data2 = storePro.Execute(context, pdo);

        AddMessage("开票成功");
    }

    protected void btnWithdraw_Click(object sender, EventArgs e)
    {
        SP_FI_QueryPDO pdo = new SP_FI_QueryPDO();
        pdo.funcCode = "AUDIT_FEEDBACK";
        pdo.var3 = context.s_UserID;
        pdo.var4 = txtNo.Text.Trim();

        StoreProScene storePro = new StoreProScene();
        DataTable data = storePro.Execute(context, pdo);

        AddMessage("已回退");
    }

    private bool DataValidate()
    {
        string strNo = txtNo.Text.Trim();
        if (strNo == "")
        {
            context.AddError("A300001001: 商户佣金凭证号为空");
            return false;
        }
        return true;
    }
}
