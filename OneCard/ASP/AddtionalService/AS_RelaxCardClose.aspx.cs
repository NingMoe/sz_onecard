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
using PDO.AdditionalService;
using TM;

// 休闲年卡关闭处理
public partial class ASP_AddtionalService_AS_RelaxCardClose : Master.FrontMaster
{
    // 页面装载
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 设置焦点以及按键事件
        txtRealRecv.Attributes["onfocus"] = "this.select();";
        txtRealRecv.Attributes["onkeyup"] = "realRecvChanging(this);";
        if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

        // 初始化费用列表
        decimal total = initFeeList(gvResult, "3B", 7);

        txtRealRecv.Text = total.ToString("0");
        hidAccRecv.Value = total.ToString("n");
    }

    // 检查卡内次数是否最初开通次数
    private void checkXXParkCardTimes(int cardTimes)
    {
        string str = ASHelper.readXXParkTimes(context).Trim();
        if (context.hasError()) return;

        int maxTimes = Convert.ToInt32(str);

        if (cardTimes != maxTimes)
        {
            context.AddError("A005080003: 休闲年卡已经使用，不允许关闭");
        }
    }
    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        btnPrintPZ.Enabled = false;
        // 读取库内休闲卡相关信息(到期日期，可用次数，开卡次数）
        ASHelper.readRelaxInfo(context, txtCardNo,
            labDbExpDate, labDbUsableTimes, labDbOpenTimes);

        //套餐名称
        ASHelper.readPackage(context, txtCardNo.Text, labPackage, hidFuncType);

        // 读取客户信息
        readCustInfo(txtCardNo.Text,
            txtCustName, txtCustBirth,
            selPaperType, txtPaperNo,
            selCustSex, txtCustPhone,
            txtCustPost, txtCustAddr, txtEmail, txtRemark);

        labGardenEndDate.Text = hidParkInfo.Value.Substring(0, 8);
        string times = hidParkInfo.Value.Substring(10, 2);
        int intTimes = Convert.ToInt32(times, 16);
        labUsableTimes.Text = times == "FF" ? "FF" : "" + intTimes;

        if (!context.hasError())
        {
            checkXXParkCardTimes(intTimes);
        }

        btnSubmit.Enabled = !context.hasError();
    }

    // 确认对话框确认处理
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "writeSuccess")      // 写卡成功
        {
            AddMessage("D005080002: 前台写卡成功，休闲年卡关闭成功");
        }
        else if (hidWarning.Value == "writeFail")    // 写卡失败
        {
            context.AddError("A00508C001: 前台写卡失败，休闲年卡关闭失败");
        }
        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }

        hidWarning.Value = "";                       // 清除警告信息
    }

    // 休闲年卡关闭提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 调用休闲年卡关闭存储过程
        SP_AS_RelaxCardClosePDO pdo = new SP_AS_RelaxCardClosePDO();
        pdo.ID = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        pdo.cardNo = txtCardNo.Text;
        pdo.cardTradeNo = hidTradeNo.Value;
        pdo.asn = hidAsn.Value.Substring(4, 16);
        pdo.tradeFee = (int)(Double.Parse(hidAccRecv.Value) * 100);
        pdo.operCardNo = context.s_CardID; // 操作员卡
        pdo.terminalNo = "112233445566";   // 目前固定写成112233445566

        // 12位,年月日8位+标志位2位+次数2位
        // 园林年卡的标志位为'01',休闲年卡的标志位为'02'.次数都是16进制.
        string endDate = DateTime.Now.AddDays(-1).ToString("yyyyMMdd");
        pdo.endDateNum = "FFFFFFFFFFFF";
        hidParkInfo.Value = pdo.endDateNum;

        // 执行存储过程
        bool ok = TMStorePModule.Excute(context, pdo);
        btnSubmit.Enabled = false;

        // 执行成功，显示成功消息
        if (ok)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startXXPark();", true);
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardNo.Text, txtCustName.Text, "休闲年卡关闭", "0.00"
                , "0.00", "", txtPaperNo.Text, "0.00", "0.00", hidAccRecv.Value, context.s_UserID,
                context.s_DepartName,
                selPaperType.Text, "0.00", hidAccRecv.Value);
        }
    }

}
