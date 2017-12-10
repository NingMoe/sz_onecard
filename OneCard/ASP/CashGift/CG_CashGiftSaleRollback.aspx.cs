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
using System.Text;

public partial class ASP_CashGift_CG_CashGiftSaleRollback : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";
    }

    // 读取客户信息
    private void readCustInfo()
    {
        DataTable data = ASHelper.callQuery(context, "QueryCustInfo", txtCardNo.Text);
        if (data.Rows.Count == 0)
        {
            context.AddError("A00501A002: 无法读取卡片客户资料");
            return;
        }
        Object[] row = data.Rows[0].ItemArray;

        txtCustName.Text = ASHelper.getCellValue(row[0]);

        //add by jiangbb 2012-06-07 解密
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESDeEncrypt(txtCustName.Text, ref strBuilder);
        txtCustName.Text = strBuilder.ToString();

        string paperType = (ASHelper.getCellValue(row[2])).Trim();
        selPaperType.Text = "";
        txtPaperNo.Text = ASHelper.getCellValue(row[3]);

        strBuilder = new StringBuilder();
        AESHelp.AESDeEncrypt(txtPaperNo.Text, ref strBuilder);
        txtPaperNo.Text = strBuilder.ToString();

        data = ASHelper.callQuery(context, "ReadPaperName", paperType);
        if (data.Rows.Count > 0)
        {
            selPaperType.Text = (string)data.Rows[0].ItemArray[0];
        }
    }

    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        btnPrintPZ.Enabled = false;

        labTradeTime.Text = "";
        labFee.Text = "";
        labTradeType.Text = "";

        //卡账户有效性检验

        checkCashGiftAccountInfo(txtCardNo.Text);

        context.DBOpen("StorePro");

        context.AddField("P_ID");
        context.AddField("P_CARDNO").Value = txtCardNo.Text;
        context.AddField("P_CARDTRADENO").Value = hidTradeNo.Value;
        context.AddField("P_CANCELTRADEID", "string", "inputoutput", "16");
        context.AddField("P_TERMINALNO");
        context.AddField("P_WALLET1").Value = (int)(Convert.ToDecimal(txtCardBalance.Value) * 100);
        context.AddField("P_WALLET2").Value = (int)(Convert.ToDecimal(txtWallet2.Value) * 100);
        context.AddField("P_OPTION").Value = "2"; // only check
        context.AddField("P_CURRCARDNO").Value = context.s_CardID;
        context.AddField("p_writeCardScript");

        // 执行存储过程
        bool ok = context.ExecuteSP("SP_CG_SaleCardRollback");
        if (!ok) return;

        DataTable data = SPHelper.callQuery("SP_CG_Query", context, "ReadNewTrades", 
            context.GetField("P_CANCELTRADEID").Value.ToString());
        if (data.Rows.Count < 1)
        {
            context.AddError("当前卡片没有当日当班可以返销的利金卡售卡交易");
            return;
        }

        readCustInfo();

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
        }
        

        Object[] row = data.Rows[0].ItemArray;
        labTradeType.Text = "" + row[2];

        labTradeTime.Text = "" + row[3];

        labFee.Text = ((decimal)row[4]).ToString("n") + "元";

        hidAccRecv.Value = "-" + labFee.Text;

        btnSubmit.Enabled = !context.hasError();
    }

    // 确认对话框确认处理

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")    // 是否继续
        {
            btnSubmit.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess") // 写卡成功
        {
            SubmitDB(sender, e);
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("写卡失败");
        }
        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }

        hidWarning.Value = ""; // 清除警告信息
    }


     // 售卡/补卡返销
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        DataTable data = SPHelper.callQuery("SP_CG_Query", context,
           "QryCashGiftCardPrice", txtCardNo.Text);

        if (data == null || data.Rows.Count == 0)
        {
            context.AddError("查询卡片价格失败");
            return;
        }
        
        string writeCardScript = "endCashGiftCard('"
                + DateTime.Now.AddDays(-1).ToString("yyyyMMdd")
                + "', " + (decimal)(data.Rows[0].ItemArray[0])
                + ");";
        ViewState["writeCardScript"] = writeCardScript;
        ScriptManager.RegisterStartupScript(
                   this, this.GetType(), "writeCardScript", writeCardScript, true);

    }

    // 售卡/补卡返销
    protected void SubmitDB(object sender, EventArgs e)
    {
       

        context.DBOpen("StorePro");

        context.AddField("P_ID").Value = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("P_CARDNO").Value = txtCardNo.Text;
        context.AddField("P_CARDTRADENO").Value = hidTradeNo.Value;
        context.AddField("P_CANCELTRADEID", "string", "inputoutput", "16");
        context.AddField("P_TERMINALNO").Value = "112233445566";   // 目前固定写成112233445566
        context.AddField("P_WALLET1").Value = (int)(Convert.ToDecimal(txtCardBalance.Value) * 100);
        context.AddField("P_WALLET2").Value = (int)(Convert.ToDecimal(txtWallet2.Value) * 100);
        context.AddField("P_OPTION").Value = "0"; // only check
        context.AddField("P_CURRCARDNO").Value = context.s_CardID;

        context.AddField("p_writeCardScript").Value = ViewState["writeCardScript"].ToString();

        // 执行存储过程
        bool ok = context.ExecuteSP("SP_CG_SaleCardRollback");
        btnSubmit.Enabled = false;

        // 存储过程执行成功，返回成功消息


        if (ok)
        {


            AddMessage("利金卡售卡返销成功");
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardNo.Text, txtCustName.Text, "利金卡售卡返销", "0.00"
                , hidAccRecv.Value, "", txtPaperNo.Text, "0.00", "0.00", hidAccRecv.Value, context.s_UserID,
                context.s_DepartName,
                selPaperType.Text, "0.00", "0.00");
        }
        else
        {
            context.AddError("利金卡售卡返销不成功");
        }
    }
}
