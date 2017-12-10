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

public partial class ASP_CashGift_CG_CashGiftQuery : Master.FrontMaster
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (Page.IsPostBack) return;

        // 设置可读属性
        setReadOnly(txtCardBalance, txtStartDate, txtEndDate, txtCardState, txtWallet2);
    }
 
    // 读卡处理
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        queryGiftCard();
    }
    // 读数据库处理
    protected void btnReadDBCard_Click(object sender, EventArgs e)
    {
        //对输入卡号进行检验
        if (!DBreadValidation())
            return;

        queryGiftCard();
    }
    private Boolean DBreadValidation()
    {
        //对卡号进行非空、长度、数字检验
        txtCardNo.Text = txtCardNo.Text.Trim();
        if (txtCardNo.Text == "")
        {
            context.AddError("A001004113", txtCardNo);
        }
        else if (!(Validation.strLen(txtCardNo.Text.Trim()) == 16))
        {
            context.AddError("A001004114", txtCardNo);
        }
        else if (!Validation.isNum(txtCardNo.Text.Trim()))
        {
            context.AddError("A001004115", txtCardNo);
        }

        return !(context.hasError());

    }
    protected void queryGiftCard()
    {
        // 读取卡片类型
        readCardType(txtCardNo.Text, labCardType);

        // 读取卡片状态

        ASHelper.readCardState(context, txtCardNo.Text, txtCardState);

        // 读取客户信息
        readCustInfo(txtCardNo.Text,
            txtCustName, txtCustBirth,
            selPaperType, txtPaperNo,
            selCustSex, txtCustPhone,
            txtCustPost, txtCustAddr, txtEmail, txtRemark, true);

        //add by jiangbb 2012-10-15 客户信息隐藏显示 201015：客户信息查看权
        if (!CommonHelper.HasOperPower(context))
        {
            txtPaperNo.Text = CommonHelper.GetPaperNo(txtPaperNo.Text);
            txtCustPhone.Text = CommonHelper.GetCustPhone(txtCustPhone.Text);
            txtCustAddr.Text = CommonHelper.GetCustAddress(txtCustAddr.Text);
        }

        // 读取其他信息
        DataTable data = SPHelper.callQuery("SP_CG_Query", context, "QryGashInfo", txtCardNo.Text);
        if (data != null && data.Rows.Count > 0)
        {
            labDbStartDAte.Text = "" + data.Rows[0].ItemArray[0];
            labDbEndDate.Text = "" + data.Rows[0].ItemArray[1];
            labDbMoney.Text = ((Decimal)data.Rows[0].ItemArray[2]).ToString("n");
            labDbSaleMoney.Text = ((Decimal)data.Rows[0].ItemArray[3]).ToString("n");
            labAssignedDept.Text=data.Rows[0][4].ToString();
            labIsRecycle.Text = data.Rows[0][5].ToString() == "04" ? "是" : "否";
            labRecycleTime.Text = data.Rows[0][6].ToString();
        }
    }
}
