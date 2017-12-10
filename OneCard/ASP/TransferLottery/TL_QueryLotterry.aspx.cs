using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using Common;
using Master;
using PDO.PersonalBusiness;
using TM;
/// <summary>
/// 抽奖资格查询 
/// 董翔 20140613
/// </summary>
public partial class ASP_TransferLottery_TL_QueryLotterry : Master.Master
{
    /// <summary>
    /// 页面初始化

    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            DataTable dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_LOTTERYTASKALL");
            ddlLotteryPeriod.DataTextField = "LOTTERYPERIOD";
            ddlLotteryPeriod.DataValueField = "LOTTERYPERIOD";
            ddlLotteryPeriod.DataSource = dt;
            ddlLotteryPeriod.DataBind(); 
        }
    }

    /// <summary>
    /// 读卡校验
    /// </summary>
    /// <returns></returns>
    private Boolean ReadCardValidation(TextBox text)
    {
        //对卡号进行非空、长度、数字检验 
        if (text.Text.Trim() == "")
            context.AddError("A001004113", txtCardno);
        else
        {
            if (Validation.strLen(text.Text.Trim()) != 16)
                context.AddError("A001004114", text);
            else if (!Validation.isNum(text.Text.Trim()))
                context.AddError("A001004115", text);
        }

        return !(context.hasError());

    }

    //读卡
    protected void btnReadCard_Click(object sender, EventArgs e)
    {
        //对输入卡号进行检验

        if (!txtCardno.Text.StartsWith("A"))
        {
            if (!ReadCardValidation(txtCardno))
                return;
        }
        DataTable dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_LOTTERYDATA",ddlLotteryPeriod.SelectedValue, txtCardno.Text);
        if (dt.Rows.Count == 0)
        {
            context.AddError("该卡没有换乘记录"); 
        } 
        gvResult.DataSource = dt;
        gvResult.DataBind();
    }
}