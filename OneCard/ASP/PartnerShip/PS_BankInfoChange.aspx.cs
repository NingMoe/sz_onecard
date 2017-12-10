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
using TDO.BalanceChannel;
using Common;
using TM;
using PDO.PartnerShip;

public partial class ASP_PartnerShip_PS_BankInfoChange : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!Page.IsPostBack)
        {
            initLoad(sender, e);
        }
    }
    protected void initLoad(object sender, EventArgs e)
    {
        TMTableModule tmTMTableModule = new TMTableModule();
        //初始化银行下拉列表值

        TD_M_BANKTDO ddoTD_M_BANKIn = new TD_M_BANKTDO();
        TD_M_BANKTDO[] ddoTD_M_BANKOutArr = (TD_M_BANKTDO[])tmTMTableModule.selByPKArr(context, ddoTD_M_BANKIn, typeof(TD_M_BANKTDO), "S008107211", "TD_M_BANK", null);

        ControlDeal.SelectBoxFill(selFinBank.Items, ddoTD_M_BANKOutArr, "BANK", "BANKCODE", true);
    }
    protected void selFinBank_changed(object sender, EventArgs e)
    {
        DataTable dt = SPHelper.callPSQuery(context, "QueryBranch", selFinBank.SelectedValue);
        GroupCardHelper.fill(selFinBranch, dt, true);
    }
    private Boolean BankValidation()
    {
        //对银行编码做长度,英数字检验
        if (Validation.strLen(txtBankcode.Text.Trim()) != 4)
        {
            context.AddError("A008113001", txtBankcode);
        }

        if (!Validation.isCharNum(txtBankcode.Text))
        {
            context.AddError("A008113002", txtBankcode);
        }

        //对银行名称做非空,长度检验
        if (txtBank.Text.Trim() == "")
        {
            context.AddError("A008113004", txtBank);
        }

        if (Validation.strLen(txtBank.Text.Trim()) > 200)
        {
            context.AddError("A008113003", txtBank);
        }

        return !(context.hasError());
    }
    protected void btnAdd_Click(object sender, EventArgs e)
    {
        //对银行编码和银行名称做检验
        if (!BankValidation())
            return;

        SP_PS_BankInfoPDO pdo = new SP_PS_BankInfoPDO();
        pdo.BankCode = txtBankcode.Text.Trim();
        pdo.Bank = txtBank.Text.Trim();

        bool ok = TMStorePModule.Excute(context, pdo);

        if (ok)
        {
            AddMessage("M008113100");
            clearCustInfo(txtBankcode, txtBank);
            initLoad(sender, e);
        }
    }
}
