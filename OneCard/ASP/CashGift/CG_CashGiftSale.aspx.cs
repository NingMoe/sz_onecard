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
using System.Text;
using PDO.PersonalBusiness;
using TM;

public partial class ASP_CashGift_CashGiftSale : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 测试模式下卡号可以输入

        if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

        // 设置可读属性

        setReadOnly(txtCardBalance, txtStartDate, txtEndDate, txtCardState, txtWallet2);

        // 初始化证件类型

        ASHelper.initPaperTypeList(context, selPaperType);

        // 初始化性别
        ASHelper.initSexList(selCustSex);
    }

    private void prepareSP()
    {
        context.SPOpen();

        context.AddField("P_SUBMIT", "string", "input");
        context.AddField("P_CARDNO", "string", "input");
        context.AddField("P_WALLET1", "Int32", "input");
        context.AddField("P_WALLET2", "Int32", "input");
        context.AddField("P_STARTDATE", "string", "input");
        context.AddField("P_ENDDATE", "string", "input");
        context.AddField("P_EXPIREDDATE", "string", "input");
        context.AddField("P_SALEMONEY", "Int32", "input");
        context.AddField("P_ID", "string", "input");
        context.AddField("P_CARDTRADENO", "string", "input");
        context.AddField("P_ASN", "string", "input");
        context.AddField("P_SELLCHANNELCODE", "string", "input");
        context.AddField("P_TERMINALNO", "string", "input");
        context.AddField("P_CARDPRICE", "Int32", "output", "");
        context.AddField("P_CUSTNAME", "String", "input");
        context.AddField("P_CUSTSEX", "String", "input");
        context.AddField("P_CUSTBIRTH", "String", "input");
        context.AddField("P_PAPERTYPE", "String", "input");
        context.AddField("P_PAPERNO", "String", "input");
        context.AddField("P_CUSTADDR", "String", "input");
        context.AddField("P_CUSTPOST", "String", "input");
        context.AddField("P_CUSTPHONE", "String", "input");
        context.AddField("P_CUSTEMAIL", "String", "input");
        context.AddField("P_REMARK", "String", "input");
        context.AddField("P_SEQNO", "string", "output", "16");
        context.AddField("P_CURRCARDNO", "string", "input");
        context.AddField("P_WRITECARDSCRIPT", "string", "output", "1024");

    }

    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        #region add by yin 20120104 添加对代理营业厅预付款的验证
        if (DeptBalunitHelper.ValdatePrepay(context) == false)
        {
            return;
        }
        #endregion


        // 读取卡片类型
        readCardType(txtCardNo.Text, labCardType);

        // 读取卡片状态

        ASHelper.readCardState(context, txtCardNo.Text, txtCardState);

        prepareSP();
        context.GetField("P_SUBMIT").Value = "0";
        context.GetField("P_CARDNO").Value = txtCardNo.Text;
        context.GetField("P_WALLET1").Value = (int)(Convert.ToDecimal(txtCardBalance.Text) * 100);
        context.GetField("P_WALLET2").Value = (int)(Convert.ToDecimal(txtWallet2.Text == "NaN" ? "0.00" : txtWallet2.Text) * 100);
        context.GetField("P_STARTDATE").Value = txtStartDate.Text;
        context.GetField("P_ENDDATE").Value = txtEndDate.Text;

        context.ExecuteSP("SP_CG_SaleCard");

        btnPrintSJ.Enabled = false;
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
            #region add by yin 20120104 添加对代理营业厅预付款的验证,扣费后如果超过预警额度则提示
            int opMoney = Convert.ToInt32(Convert.ToDecimal(txtSaleMoney.Text) * 100);
            DeptBalunitHelper.ValdatePrepay(context, opMoney, "1");
            #endregion

            clearCustInfo(txtCardNo, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
               selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);

            context.SPOpen();
            context.AddField("p_TRADEID").Value = hidSeqNo.Value;
            context.AddField("p_CARDTRADENO").Value = hidTradeNo.Value;
            bool ok = context.ExecuteSP("SP_PB_updateCardTrade");

            if (ok) AddMessage("利金卡售卡成功");
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("前台写卡失败");
        }

        if (chkShouju.Checked && btnPrintSJ.Enabled)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript",
                "printShouJu();", true);
        }

        hidWarning.Value = ""; // 清除警告信息
        hidCardnoForCheck.Value = "";//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致

    }

    // 提交判断
    private void submitValidate()
    {
        // 校验客户信息
        custInfoValidate(txtCustName, txtCustBirth,
            selPaperType, txtPaperNo, selCustSex, txtCustPhone, txtCustPost,
            txtCustAddr, txtEmail, txtRemark);

        Validation val = new Validation(context);
        val.beNumber(txtSaleMoney, "售卡金额必须是有效整数金额");

    }

    // 售卡提交
    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        submitValidate();
        if (context.hasError()) return;

        #region add by yin 20120104 添加对代理营业厅预付款的验证,提交前如果扣费后不足最低额度则返回
        int opMoney = Convert.ToInt32(Convert.ToDecimal(txtSaleMoney.Text) * 100);
        if (DeptBalunitHelper.ValdatePrepay(context, opMoney, "2") == false)
        {
            return;
        }
        #endregion

        prepareSP();
        context.GetField("P_SUBMIT").Value = "1"; // 提交售卡
        context.GetField("P_CARDNO").Value = txtCardNo.Text;
        context.GetField("P_WALLET1").Value = (int)(Convert.ToDecimal(txtCardBalance.Text) * 100);
        context.GetField("P_WALLET2").Value = (int)(Convert.ToDecimal(txtWallet2.Text) * 100);
        context.GetField("P_STARTDATE").Value = txtStartDate.Text;
        context.GetField("P_ENDDATE").Value = txtEndDate.Text;

        //int addMonths = Convert.ToInt32(selValidMonths.SelectedValue);
        //// 截止日期=【售卡时间+有效期限】所得月份的最后一天

        //DateTime temp = DateTime.Now.AddMonths(addMonths);
        //string expiredDate =  temp
        //    .AddDays(1 - temp.Day)
        //    .AddMonths(1)
        //    .AddDays(-1).ToString("yyyyMMdd");

        context.GetField("P_EXPIREDDATE").Value = "20501231";

        int saleMoney = Convert.ToInt32(txtSaleMoney.Text) * 100;
        context.GetField("P_SALEMONEY").Value = saleMoney;

        context.GetField("P_ID").Value = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.GetField("P_CARDTRADENO").Value = hidTradeNo.Value;
        context.GetField("P_ASN").Value = hidAsn.Value.Substring(4, 16);

        context.GetField("P_SELLCHANNELCODE").Value = "01";
        context.GetField("P_TERMINALNO").Value = "112233445566";   // 目前固定写成112233445566

        //add by jiangbb 2012-06-07 加密
        StringBuilder strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustName.Text, ref strBuilder);

        context.GetField("P_CUSTNAME").Value = strBuilder.ToString();

        context.GetField("P_CUSTSEX").Value = selCustSex.SelectedValue;
        context.GetField("P_CUSTBIRTH").Value = txtCustBirth.Text;
        context.GetField("P_PAPERTYPE").Value = selPaperType.SelectedValue;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtPaperNo.Text,ref strBuilder);
        context.GetField("P_PAPERNO").Value = strBuilder.ToString();

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustAddr.Text, ref strBuilder);
        context.GetField("P_CUSTADDR").Value = strBuilder.ToString();
        context.GetField("P_CUSTPOST").Value = txtCustPost.Text;

        strBuilder = new StringBuilder();
        AESHelp.AESEncrypt(txtCustPhone.Text, ref strBuilder);
        context.GetField("P_CUSTPHONE").Value = strBuilder.ToString();
        context.GetField("P_CUSTEMAIL").Value = txtEmail.Text;
        context.GetField("P_REMARK").Value = txtRemark.Text;

        context.GetField("P_CURRCARDNO").Value = context.s_CardID;

        bool ok = context.ExecuteSP("SP_CG_SaleCard");

        btnSubmit.Enabled = false;

        // 存储过程执行成功，显示成功消息

        if (ok)
        {
            hidSeqNo.Value = "" + context.GetField("P_SEQNO").Value;

            // 准备收据打印数据
            ASHelper.prepareShouJu(ptnShouJu, txtCardNo.Text, context.s_UserName, txtSaleMoney.Text);
            btnPrintSJ.Enabled = true;

            string writeCardScripts = "" + context.GetField("P_WRITECARDSCRIPT").Value;
            hidCardnoForCheck.Value = txtCardNo.Text;//add by liuhe 20111104用于写卡前验证页面上的卡号和读卡器上的卡是否一致


            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript", writeCardScripts, true);
        }
    }
}
