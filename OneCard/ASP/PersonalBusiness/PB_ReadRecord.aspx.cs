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
using PDO.PersonalBusiness;
using Master;

public partial class ASP_PersonalBusiness_PB_ReadRecord : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!context.s_Debugging) setReadOnly(txtCardno);

        setReadOnly(cMoney);

        //设置GridView绑定的DataTable
        UserCardHelper.resetData(lvwQuery, null);
    }

    private Boolean DBreadValidation()
    {
        //对卡号进行数字检验
        Cardno.Text = Cardno.Text.Trim();
        if (Cardno.Text != "")
        {
            if (!Validation.isNum(Cardno.Text)) context.AddError("A001004115", Cardno);
        }

        return !(context.hasError());
    }

    protected void btnQuery_Click(object sender, EventArgs e)
    {
        //对输入卡号进行检验
        if (!DBreadValidation())
            return;

        {
            DataTable data = SPHelper.callPBQuery(context, "QueryCardRecords", Cardno.Text);
            UserCardHelper.resetData(lvwQuery, data);

            if (data.Rows.Count == 0)
            {
                context.AddError("A001023103");
                return;
            }
        }

    }

    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        cMoney.Text = ((Convert.ToDecimal(hiddencMoney.Value)) / (Convert.ToDecimal(100))).ToString("0.00");

        //查询临时表TMP_PB_ReadRecord中数据
        DataTable data = SPHelper.callPBQuery(context, "SaveTempRecords",
            Session.SessionID, txtCardno.Text, hidTradeno.Value, hidTradeMoney.Value, hidTradeType.Value,
            hidTradeTerm.Value, hidTradeDate.Value, hidTradeTime.Value, hiddencMoney.Value);

        UserCardHelper.resetData(lvwQuery, data);

        btnSave.Enabled = true;
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        SP_PB_ReadRecordPDO pdo = new SP_PB_ReadRecordPDO();

        pdo.CARDNO = txtCardno.Text;
        pdo.CARDMONEY = Convert.ToInt32(hiddencMoney.Value);
        pdo.SESSIONID = Session.SessionID;

        bool ok = TMStorePModule.Excute(context, pdo);
        if (ok)
        {
            AddMessage("M001023100");

            UserCardHelper.resetData(lvwQuery, null);
            btnSave.Enabled = false;
        }
    }
    protected void lvwQuery_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        ControlDeal.RowDataBound(e);
    }
}
