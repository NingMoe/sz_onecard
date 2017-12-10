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

// 吴江旅游年卡关闭处理
public partial class ASP_AddtionalService_AS_TravelCardClose : Master.FrontMaster
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

        decimal total = initFeeList(gvResult, "A6", 7);

        txtRealRecv.Text = total.ToString("0");
        hidAccRecv.Value = total.ToString("n");
    }

    // 检查卡内次数是否最初开通次数

    private void checkParkCardTimes(int cardTimes)
    {
        string str = ASHelper.readTravelTimes(context).Trim();
        if (context.hasError()) return;

        int maxTimes = Convert.ToInt32(str);

        if (cardTimes != maxTimes)
        {
            context.AddError("A006010001: 吴江旅游年卡已经使用，不允许关闭");
        }
    }

    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        btnPrintPZ.Enabled = false;

        // 读取库内吴江旅游年卡相关信息(到期日期，可用次数，开卡次数）
        ASHelper.readTravelInfo(context, txtCardNo,
            labDbExpDate, labDbUsableTimes, labDbOpenTimes);

        // 读取客户信息
        readCustInfo(txtCardNo.Text,
            txtCustName, txtCustBirth,
            selPaperType, txtPaperNo,
            selCustSex, txtCustPhone,
            txtCustPost, txtCustAddr, txtEmail, txtRemark);

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
            txtCustPhone.Text = CommonHelper.GetCustPhone(txtCustPhone.Text);
            txtCustAddr.Text = CommonHelper.GetCustAddress(txtCustAddr.Text);
        }

        labGardenEndDate.Text = hidParkInfo.Value.Substring(2, 8);
        string times = hidParkInfo.Value.Substring(10, 2);
        int intTimes = Convert.ToInt32(times, 16);
        labUsableTimes.Text = times == "FF" ? "FF" : "" + intTimes;

        if (!context.hasError())
        {
            checkParkCardTimes(intTimes);
        }

        btnSubmit.Enabled = !context.hasError();
    }

    // 确认对话框确认处理

    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "writeSuccess")      // 写卡成功
        {
            AddMessage("D006010001: 吴江旅游年卡关闭成功");
        }
        else if (hidWarning.Value == "writeFail")    // 写卡失败
        {
            context.AddError("A006010004: 写卡失败，吴江旅游年卡关闭失败");
        }

        hidWarning.Value = "";                       // 清除警告信息
        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }
    }

    // 吴江旅游年卡关闭提交处理
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        // 调用吴江旅游年卡关闭存储过程
        
        context.SPOpen();
        context.AddField("p_ID").Value=DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("p_cardNo").Value=txtCardNo.Text;
        context.AddField("p_cardTradeNo").Value = hidTradeNo.Value;
        context.AddField("p_asn").Value = hidAsn.Value.Substring(4, 16);
        context.AddField("p_tradeFee").Value = (int)(Double.Parse(hidAccRecv.Value) * 100);
        context.AddField("p_operCardNo").Value = context.s_CardID;
        context.AddField("p_terminalNo").Value ="112233445566";
        context.AddField("p_endDateNum").Value = "FFFFFFFFFFFF";
                

        //// 12位,年月日8位+标志位2位+次数2位

        //// 吴江旅游年卡的标志位为'01',休闲年卡的标志位为'02'.次数都是16进制.
        //// string endDate = DateTime.Now.AddDays(-1).ToString("yyyyMMdd");
        //pdo.endDateNum = "FFFFFFFFFFFF";
        hidParkInfo.Value = "FFFFFFFFFFFF";

        // 执行存储过程
        bool ok = context.ExecuteSP("SP_AS_TravelCardClose");
        btnSubmit.Enabled = false;

        // 执行成功，显示成功消息

        if (ok)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "startWjLvyou();", true);
            btnPrintPZ.Enabled = true;

            ASHelper.preparePingZheng(ptnPingZheng, txtCardNo.Text, txtCustName.Text, "吴江旅游年卡关闭", "0.00"
                , "0.00", "", txtPaperNo.Text, "0.00", "0.00", hidAccRecv.Value, context.s_UserID,
                context.s_DepartName,
                txtPaperNo.Text, "0.00", hidAccRecv.Value);
        }
    }

}
