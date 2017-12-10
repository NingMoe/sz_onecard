using Common;
using System;
using System.Data;
using System.Text;
/// <summary>
/// 换乘抽奖 -- 交通局版本
/// 董翔 20140523
/// </summary>
public partial class TransferLottery_Lottery : Master.TransferLotteryMaster
{
     /// <summary>
     /// 初始化
     /// </summary>
     /// <param name="sender"></param>
     /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            if (hidAward.Value == "")
            {
               hidAward.Value = "0";
            } 
            DataTable dt = SPHelper.callQuery("SP_TL_Query", context, "QUERY_LOTTERYTASKALL", "");
            ddlLotteryPeriod.DataTextField = "LOTTERYPERIOD";
            ddlLotteryPeriod.DataValueField = "LOTTERYPERIOD";
            ddlLotteryPeriod.DataSource = dt;
            ddlLotteryPeriod.DataBind();
            ddlLotteryPeriod.SelectedIndex = 0;
            InitPage();
            ASHelper.initPaperTypeList(context, selPapertype);
        }
       
    }
     
    /// <summary>
    /// 页面初始化
    /// </summary>
    private void InitPage()
    {
        lblPeriod.Text = ddlLotteryPeriod.SelectedValue;
        hidLottery.Value = "0";
        InitValidation();
        if (context.hasError())
        {
            hidLottery.Value = "2";
        }
        if (hidLottery.Value == "1")
        {
            ShowWinnerList(ddlLotteryPeriod.SelectedValue); 
        }
    }
     
    /// <summary>
    /// 初始化验证
    /// </summary>
    private void InitValidation()
    {
        TLHelper.ValidationLottery(context, ddlLotteryPeriod.SelectedValue, hidAward, hidLottery);
    }

 
    /// <summary>
    /// 奖期变更
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void ddlLotteryPeriod_SelectedIndexChanged(object sender, EventArgs e)
    {
        ShowWinnerList(ddlLotteryPeriod.SelectedValue);
        InitPage(); 
    }
     
    /// <summary>
    /// 显示中奖名单
    /// </summary>
    /// <param name="lotteryPeriod">奖期</param>
    private void ShowWinnerList(string lotteryPeriod)
    { 
        //查询中奖名单
        string winnerList = TLHelper.ShowWinnerList(context, lotteryPeriod, hidAward.Value);
         if (!string.IsNullOrEmpty(winnerList))
        {
            litWinnerList.Text = winnerList;
        }
        else
        {
            litWinnerList.Text = "";
        }
    }

    /// <summary>
    /// 特等奖TAB
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void linkAward0_Click(object sender, EventArgs e)
    {
        hidAward.Value = "0";
        InitPage();
    }

    /// <summary>
    /// 一等奖TAB
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void linkAward1_Click(object sender, EventArgs e)
    {
        hidAward.Value = "1";
        InitPage();
    }

    /// <summary>
    /// 二等奖TAB
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void linkAward2_Click(object sender, EventArgs e)
    {
        hidAward.Value = "2";
        InitPage();
    }

    /// <summary>
    /// 三等奖TAB
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void linkAward3_Click(object sender, EventArgs e)
    {
        hidAward.Value = "3";
        InitPage();
    }

    /// <summary>
    /// 重置
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void linkShow_Click(object sender, EventArgs e)
    {
        InitPage();
    }

    /// <summary>
    /// 领奖
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnAward_Click(object sender, EventArgs e)
    {
        #region 对用户信息进行验证
        //对用户姓名进行非空、长度检验
        if (txtCusname.Text.Trim() == "")
            context.AddError("请输入领奖人姓名", txtCusname);
        else if (Validation.strLen(txtCusname.Text.Trim()) > 50)
            context.AddError("领奖人姓名长度不能大于25", txtCusname);


        //对证件类型进行非空检验
        if (selPapertype.SelectedValue == "")
            context.AddError("请选择领奖人证件类型", selPapertype);


        //对联系电话进行非空、长度、数字检验  
        if (txtCustphone.Text.Trim() == "")
            context.AddError("请输入领奖人电话", txtCustphone);
        else if (Validation.strLen(txtCustphone.Text.Trim()) > 20)
            context.AddError("领奖人电话长度大于20位", txtCustphone);
        else if (!Validation.isNum(txtCustphone.Text.Trim()))
            context.AddError("领奖人电话不是数字", txtCustphone);


        //对证件号码进行非空、长度、英数字检验
        if (txtCustpaperno.Text.Trim() == "")
            context.AddError("请输入领奖人证件号码", txtCustpaperno);
        else if (!Validation.isCharNum(txtCustpaperno.Text.Trim()))
            context.AddError("领奖人证件号码格式不正确", txtCustpaperno);
        else if (Validation.strLen(txtCustpaperno.Text.Trim()) > 20)
            context.AddError("领奖人证件号码长度大于20", txtCustpaperno);

        //对充值卡卡号校验
        if (string.IsNullOrEmpty(txtChargeCard.Text))
        {
            context.AddError("请输入充值卡号", txtChargeCard);
        }
        string[] cards = txtChargeCard.Text.Split(',');
        if(cards.Length != 4)
        {
            context.AddError("请输入4张充值卡", txtChargeCard);
        }
        else 
        {
            foreach (string s in cards)
            {
                if (string.IsNullOrEmpty(s))
                {
                    context.AddError("充值卡号不能为空", txtChargeCard);
                    break;
                }
                else if (s.Length != 14)
                {
                    context.AddError("充值卡号:" + s + "不正确", txtChargeCard);
                    break;
                }
                else if (!ValidateCardNo(s))
                {
                    context.AddError("充值卡号:" + s + "不正确", txtChargeCard);
                    break;
                }
            }
        } 
        #endregion
        //对领奖信息验证进行检验
        if (!context.hasError())
        {
            context.SPOpen();
            context.AddField("P_LOTTERYPERIOD").Value = ddlLotteryPeriod.SelectedValue;
            context.AddField("P_CARDNO").Value = hidCardno.Value;
            context.AddField("P_CHARGECARD").Value = txtChargeCard.Text.Trim();
            StringBuilder strBuilder = new StringBuilder();
            AESHelp.AESEncrypt(txtCusname.Text, ref strBuilder);
            context.AddField("P_CUSTNAME").Value = strBuilder.ToString();
            context.AddField("P_PAPERTYPECODE").Value = selPapertype.SelectedValue;
            AESHelp.AESEncrypt(txtCustpaperno.Text, ref strBuilder);
            context.AddField("P_PAPERNO").Value = strBuilder.ToString();
            AESHelp.AESEncrypt(txtCustphone.Text, ref strBuilder);
            context.AddField("P_CUSTPHONE").Value = strBuilder.ToString();
            if (context.ExecuteSP("SP_TL_SpecialAward"))
            {
                txtCusname.Text = "";
                selPapertype.SelectedIndex = -1;
                txtCustpaperno.Text = "";
                txtCustphone.Text = "";
                hidShowAward.Value = "";
                context.AddMessage("领奖登记成功");
            }
        }
        else
        {
            hidShowAward.Value = "1";
        }
        //显示中奖名单
        ShowWinnerList(ddlLotteryPeriod.SelectedValue); 
    }

    /// <summary>
    /// 校验充值卡卡号
    /// </summary>
    /// <param name="cardNo">卡号</param>
    /// <returns></returns>
    public  bool ValidateCardNo(string cardNo)
    {
        // 充值卡号,第1,2位表示年份,数字;第3,4位表示批次号,数字;
        // 第5位表示面值,字母;第6位表示厂商,字母;后8位是递增的序号.
        for (int i = 0; i < 4; ++i)
        {
            if (cardNo[i] > '9' || cardNo[i] < '0')
            {
                return false;
            }
        }
        for (int i = 4; i < 6; ++i)
        {
            if (!(cardNo[i] >= 'a' && cardNo[i] <= 'z'
                || cardNo[i] >= 'A' && cardNo[i] <= 'Z'))
                return false;
        }

        for (int i = 6; i < 14; ++i)
        {
            if (cardNo[i] > '9' || cardNo[i] < '0')
            {
                return false;
            }
        }

        return true;
    }
}