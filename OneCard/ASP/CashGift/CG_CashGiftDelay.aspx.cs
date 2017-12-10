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

public partial class ASP_CashGift_CG_CashGiftDelay : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 测试模式下卡号可以输入
        if (!context.s_Debugging) txtCardNo.Attributes["readonly"] = "true";

        // 设置可读属性
        setReadOnly(txtCardBalance, txtStartDate, txtEndDate, txtCardState, txtWallet2);
    }
    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        // 读取卡片类型
        readCardType(txtCardNo.Text, labCardType);

        // 读取卡片状态
        ASHelper.readCardState(context, txtCardNo.Text, txtCardState);

        readCustInfo(txtCardNo.Text,
            txtCustName, txtCustBirth,
            selPaperType, txtPaperNo,
            selCustSex, txtCustPhone,
            txtCustPost, txtCustAddr, txtEmail, txtRemark);

        checkCashGiftAccountInfo(txtCardNo.Text);
        if (Convert.ToDecimal(txtCardBalance.Text) <= 0)
        {
            context.AddError("电子钱包1余额过小，不允许延期");
        }
        
        // 读取其他信息
        DataTable data = SPHelper.callQuery("SP_CG_Query", context, "QryGashInfo", txtCardNo.Text);
        if (data == null || data.Rows.Count == 0)
        {
            context.AddError("没有查询到利金卡相关信息");
        }
        else
        {
            labDbStartDate.Text = "" + data.Rows[0].ItemArray[0];
            labDbEndDate.Text = "" + data.Rows[0].ItemArray[1];
            labDbMoney.Text = ((Decimal)data.Rows[0].ItemArray[2]).ToString("n");
            labDbSaleMoney.Text = ((Decimal)data.Rows[0].ItemArray[3]).ToString("n");
            if (Convert.ToDecimal(labDbMoney.Text) <= 0)
            {
                context.AddError("卡账户余额过小，不允许延期");
            }
        }

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
            clearCustInfo(txtCardNo, txtCustName, txtCustBirth, selPaperType, txtPaperNo,
               selCustSex, txtCustPhone, txtCustPost, txtCustAddr, txtEmail, txtRemark);

            AddMessage("利金卡延期成功");
        }
        else if (hidWarning.Value == "writeFail") // 写卡失败
        {
            context.AddError("前台写卡失败");
        }


        hidWarning.Value = ""; // 清除警告信息
    }
 
    // 提交判断
    private void submitValidate()
    {
        Validation val = new Validation(context);

        DateTime? ret = val.beDate(txtExpDate, "有效期延长时间必须填写，且必须为yyyyMMdd格式");
        if (ret.HasValue)
        {
            //if (txtExpDate.Text.CompareTo(DateTime.Now.ToString("yyyyMMdd")) <= 0)
            //{
            //    context.AddError("有效期延长不能设置到今天以前（包括今天)");
            //}
            //else 
            //if (txtExpDate.Text.CompareTo(txtEndDate.Text) <= 0)
            //{
            //    context.AddError("有效期延长不能设置到原来结束日期以前（包括当天)", txtExpDate);
            //}
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        submitValidate();
        if (context.hasError()) return;

        context.DBOpen("StorePro");

        context.AddField("p_cardNo").Value = txtCardNo.Text;
        context.AddField("p_wallet1").Value = (int)(Convert.ToDecimal(txtCardBalance.Text) * 100);
        context.AddField("p_wallet2").Value = (int)(Convert.ToDecimal(txtWallet2.Text == "NaN" ? "0.00" : txtWallet2.Text) * 100);
        context.AddField("p_startDate").Value = txtStartDate.Text;
        context.AddField("p_endDate").Value = txtEndDate.Text;

        context.AddField("p_expiredDate").Value = txtExpDate.Text;
        context.AddField("p_dbStartDate").Value = labDbStartDate.Text;
        context.AddField("p_dbEndDate").Value = labDbEndDate.Text;

        string writeCardScript = "delayCashGiftCard('" + txtExpDate.Text + "');";
        context.AddField("p_writeCardScript").Value = writeCardScript;

        context.AddField("p_ID").Value = DealString.GetRecordID(hidTradeNo.Value, hidAsn.Value);
        context.AddField("p_cardTradeNo").Value = hidTradeNo.Value;
        context.AddField("p_asn").Value = hidAsn.Value.Substring(4, 16);

        bool ok = context.ExecuteSP("SP_CG_Delay");

        btnSubmit.Enabled = false;

        // 存储过程执行成功，显示成功消息
        if (ok)
        {
            ScriptManager.RegisterStartupScript(
                this, this.GetType(), "writeCardScript", writeCardScript, true);
        }
    }
}
