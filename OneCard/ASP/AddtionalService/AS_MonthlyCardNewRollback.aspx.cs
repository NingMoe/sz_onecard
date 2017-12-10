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
using TDO.BusinessCode;
using Common;
using TM;
using System.Text;
using PDO.AdditionalService;
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using TDO.UserManager;
using System.Collections.Generic;

// 月票卡售卡返销
public partial class ASP_AddtionalService_AS_MonthlyCardNewRollback : Master.FrontMaster
{
    // 页面装载
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

        //add by jiangbb 解密
        CommonHelper.AESDeEncrypt(data, new List<string>(new string[] { "CUSTNAME", "CUSTPHONE", "CUSTADDR", "PAPERNO" }));

        Object[] row = data.Rows[0].ItemArray;

        txtCustName.Text = ASHelper.getCellValue(row[0]);
        string paperType = (ASHelper.getCellValue(row[2])).Trim();
        selPaperType.Text = "";
        txtPaperNo.Text = ASHelper.getCellValue(row[3]);

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

        hidSeqNo.Value = "";
        labTradeTime.Text = "";
        labFee.Text = "";
        labTradeType.Text = "";

        //卡账户有效性检验

        SP_AccCheckPDO pdo = new SP_AccCheckPDO();
        pdo.CARDNO = txtCardNo.Text;
        bool ok = TMStorePModule.Excute(context, pdo);

        if (!ok) return;

        DataTable data = ASHelper.callQuery(context, "ReadNewTrades", txtCardNo.Text, context.s_UserID);
        if (data.Rows.Count < 1)
        {
            context.AddError("A005140001: 当前卡片没有当日当班可以返销的交易");
            return;
        }

        readCustInfo();

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
        }

        Object[] row = data.Rows[0].ItemArray;
        hidSeqNo.Value = "" + row[0];

        DataTable data2 = ASHelper.callQuery(context, "ReadTradeTypeName", (string)row[1]);
        if (data2.Rows.Count > 0)
        {
            labTradeType.Text = "" + data2.Rows[0].ItemArray[0];
        }
        else
        {
            labTradeType.Text = "" + row[1];
        }

        labTradeTime.Text = "" + row[2];

        // 应退费用
        DataTable data3 = ASHelper.callQuery(context, "ReadTradeFee", (string)row[0]);
        decimal deposit = 0, cardCost = 0, otherFee = 0;

        if (data3.Rows.Count > 0)
        {
            deposit = (decimal)data3.Rows[0].ItemArray[0];
            cardCost = (decimal)data3.Rows[0].ItemArray[1];
            otherFee = (decimal)data3.Rows[0].ItemArray[2];
        }
        labFee.Text = "押金: " + deposit + " + 卡费:" + cardCost + " + 其它费用:" + otherFee
            + " = 总共: " + (deposit + cardCost + otherFee);

        hidAccRecv.Value = "-" +  (deposit + cardCost + otherFee).ToString("n");

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
            AddMessage("D005140002: 月票卡售卡/补卡返销成功");
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("A00514C001: 写卡失败");
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
        SP_AS_MonthlyCardNewRollbackPDO pdo = new SP_AS_MonthlyCardNewRollbackPDO();
        pdo.ID = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        pdo.cardNo = txtCardNo.Text;
        pdo.cardTradeNo = hidTradeNo.Value;
        pdo.cardMoney = (int)(Double.Parse(txtCardBalance.Value) * 100);

        pdo.cancelTradeId = hidSeqNo.Value;

        pdo.terminalNo = "112233445566";   // 目前固定写成112233445566
        pdo.currCardNo = context.s_CardID;

        // 执行存储过程
        bool ok = TMStorePModule.Excute(context, pdo);
        btnSubmit.Enabled = false;

        // 存储过程执行成功，返回成功消息

        if (ok)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "endMonthlyInfo();", true);
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardNo.Text, txtCustName.Text, "月票卡售卡/补卡返销", "0.00"
                , hidAccRecv.Value, "", txtPaperNo.Text, "0.00", "0.00", hidAccRecv.Value, context.s_UserID,
                context.s_DepartName,
                selPaperType.Text, "0.00", "0.00");
        }
    }
}
