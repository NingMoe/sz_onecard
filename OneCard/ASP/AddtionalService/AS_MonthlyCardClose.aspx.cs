using System;
using System.Data;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using TDO.BusinessCode;
using Common;
using TM;
using System.Text;
using PDO.AdditionalService;
using PDO.PersonalBusiness;
using TDO.ResourceManager;
using TDO.UserManager;

/***************************************************************
 * 功能名: 附加业务_月票卡关闭
 * 更改日期      姓名           摘要
 * ----------    -----------    --------------------------------
 * 2012/04/28    liuhe			初次开发
 * 
 ****************************************************************/
public partial class ASP_AddtionalService_AS_MonthlyCardClose : Master.FrontMaster
{

    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

    }

    /// <summary>
    /// 读卡按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        // 读取卡片类型
        readCardType(txtCardNo.Text, labCardType);

        // 读取卡片状态
        ASHelper.readCardState(context, txtCardNo.Text, txtCardState);

        // 读取客户资料
        readCustInfo(txtCardNo.Text, labCustName, labCustBirth,
            labPaperType, labPaperNo, labCustSex, labCustPhone, labCustPost,
            labCustAddr, labEmail, labRemark);

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            labPaperNo.Text = CommonHelper.GetPaperNo(labPaperNo.Text);
            labCustPhone.Text = CommonHelper.GetCustPhone(labCustPhone.Text);
            labCustAddr.Text = CommonHelper.GetCustAddress(labCustAddr.Text);
        }

        // 查询月票卡应用类型，区域名称，区域代码
        DataTable data = ASHelper.callQuery(context, "CardAppInfo", txtCardNo.Text);
        if (data.Rows.Count != 1)
        {
            labMonthlyCardType.Text = "非月票卡";
            context.AddError("A005110001: 当前卡片不是月票卡");
            btnSubmit.Enabled = false;
            return;
        }
        string type = (string)(data.Rows[0].ItemArray[0]);
        hidMonthlyType.Value = type;
        labMonthlyCardType.Text
            = type == "01" ? "学生月票卡"
            : type == "02" ? "老人月票卡"
            : type == "03" ? "高龄卡"
            : type == "04" ? "残疾人爱心卡"
            : type == "05" ? "劳模卡"
            : type == "06" ? "教育卡" //add by youyue 20140611增加06:教育卡
            : type == "07" ? "献血卡" //add by youyue 20160823增加07:献血卡
            : "未知月票卡";

        try
        {
            labMonthlyCardDistrict.Text = (string)(data.Rows[0].ItemArray[2]) + ":" + (string)(data.Rows[0].ItemArray[1]);
        }
        catch (Exception)
        {
            labMonthlyCardDistrict.Text = "";
        }

        btnPrintPZ.Enabled = false;
        btnSubmit.Enabled = !context.hasError();
    }


    /// <summary>
    /// 确认对话框确认处理
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnConfirm_Click(object sender, EventArgs e)
    {
        if (hidWarning.Value == "yes")    // 是否继续
        {
            btnSubmit.Enabled = true;
        }
        else if (hidWarning.Value == "writeSuccess") // 写卡成功
        {
            clearCustInfo(txtCardNo, labMonthlyCardType, labMonthlyCardDistrict);
            hidMonthlyType.Value = "";

            AddMessage("D005130902: 月票卡关闭成功");
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("A00513C001: 写卡失败");
        }
        if (chkPingzheng.Checked && btnPrintPZ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printInvoice();", true);
        }

        hidWarning.Value = ""; // 清除警告信息
    }

    /// <summary>
    /// 提交按钮事件
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        context.SPOpen();
        context.AddField("p_ID").Value = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("p_cardNo").Value = txtCardNo.Text;
        context.AddField("p_operCardNo").Value = context.s_CardID; // 操作员卡
        context.AddField("p_terminalNo").Value = "112233445566";

        bool ok = context.ExecuteSP("SP_AS_MonthlyCardClose");

        btnSubmit.Enabled = false;

        // 存储过程执行成功，显示成功消息
        if (ok)
        {
            // 准备收据打印数据
            ASHelper.preparePingZheng(ptnPingZheng, txtCardNo.Text, labCustName.Text, "月票卡关闭", "0.00"
               , "0.00", "", labPaperNo.Text, "0.00", "0.00", "0.00", context.s_UserID,
               context.s_DepartName,
               labPaperType.Text, "0.00", "0.00");

            btnPrintPZ.Enabled = true;

            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "endMonthlyInfoNew();", true);
        }
    }

}
